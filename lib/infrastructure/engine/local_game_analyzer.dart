/// Full-game analyzer backed by the on-device Apex AI Analyst.
///
/// Drop-in replacement for [CloudGameAnalyzer] — same public contract
/// (`analyzeFromPgn` + `onProgress`) and the same `AnalysisTimeline` return
/// type so the Review pipeline does not care whether analysis came from
/// Lichess or from local Stockfish.
///
/// ### Pipeline (per ply)
///
/// 1. Check the embedded ECO opening book for the *before* position. If it
///    is a known theoretical move, classify as [MoveQuality.book] and skip
///    the engine call entirely — saving ~70 % of searches on most opening
///    sequences.
/// 2. Otherwise, request the engine eval for the *before* FEN (mover's
///    POV, normalised to White in the returned snapshot).
/// 3. Request the engine eval for the *after* FEN — which is also the
///    *before* FEN of the next ply, so we cache and reuse it and each ply
///    only costs a single additional search on the happy path.
/// 4. Pass the two snapshots to [EvaluationAnalyzer] to compute deltaW and
///    classify the move (Blunder / Mistake / Inaccuracy / Good / Best /
///    Excellent / Brilliant).
///
/// All evaluations are issued through [LocalEvalService] which now
/// guarantees per-call UCI synchronisation (see that file for details).
library;

import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/position_evaluation.dart';
import 'package:apex_chess/core/domain/services/analysis_debug_export.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/deep_tactical_verifier.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/position_heuristics.dart';
import 'package:apex_chess/core/domain/services/pgn_mainline_validator.dart';
import 'package:apex_chess/core/domain/services/sacrifice_trajectory.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart'
    show AnalysisMode;
import 'package:apex_chess/infrastructure/engine/eco_book.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';

/// Exception used to surface user-facing errors to the home / review UI.
enum LocalAnalysisFailure { invalidPgn, incompleteEvaluation, cancelled }

class LocalAnalysisException implements Exception {
  const LocalAnalysisException(
    this.message, {
    this.failure = LocalAnalysisFailure.incompleteEvaluation,
  });

  final String message;
  final LocalAnalysisFailure failure;

  @override
  String toString() => 'LocalAnalysisException: $message';

  String get userMessage => message;
}

class LocalGameAnalyzer {
  LocalGameAnalyzer({
    required LocalEvalService eval,
    EcoBook? book,
    Future<EcoBook>? bookFuture,
    EvaluationAnalyzer analyzer = const EvaluationAnalyzer(),
    DeepTacticalVerifier tacticalVerifier = const DeepTacticalVerifier(),
    PgnMainlineValidator pgnValidator = const PgnMainlineValidator(),
    int depth = 14,
    // Optional wall-clock cap per position. When null, the analyzer
    // picks a sensible budget for the effective search depth via
    // [defaultMovetimeForDepth] — this keeps "Fast" scans snappy while
    // giving "Quantum Deep Scan" enough time to actually reach its
    // target depth.
    Duration? movetime,
  }) : _eval = eval,
       _book = book,
       _bookFuture = bookFuture,
       _analyzer = analyzer,
       _tacticalVerifier = tacticalVerifier,
       _pgnValidator = pgnValidator,
       _depth = depth,
       _movetimeOverride = movetime;

  /// Sensible per-position wall-clock budget for a given target depth on
  /// real Stockfish + NNUE. Scales monotonically so deeper scans actually
  /// get to run longer; a fixed cap would mean every depth collapses to
  /// whatever the cap reaches first.
  static Duration defaultMovetimeForDepth(int depth) {
    if (depth <= 14) return const Duration(milliseconds: 900);
    if (depth <= 18) return const Duration(milliseconds: 2500);
    if (depth <= 22) return const Duration(milliseconds: 6000);
    return const Duration(milliseconds: 10000);
  }

  final LocalEvalService _eval;
  // Book state is materialised on first `analyzeFromPgn` call. A caller
  // that already has the book ready passes it via `book:`; callers that
  // are racing an async load should pass `bookFuture:` so we await the
  // asset once instead of falling back to engine-only classification.
  EcoBook? _book;
  final Future<EcoBook>? _bookFuture;
  final EvaluationAnalyzer _analyzer;
  final DeepTacticalVerifier _tacticalVerifier;
  final PgnMainlineValidator _pgnValidator;
  final int _depth;
  final Duration? _movetimeOverride;

  String get engineVersion => _eval.engineVersion;

  /// Requests an immediate UCI stop for the active search. The runtime also
  /// invalidates the execution generation, so a racing result cannot commit.
  void cancelActiveAnalysis() => _eval.cancelActiveSearch();

  Future<AnalysisTimeline> analyzeFromPgn(
    String pgn, {
    void Function(int completed, int total)? onProgress,
    int? depth,
    Duration? movetime,
    AnalysisMode mode = AnalysisMode.deep,
    bool Function()? isCancelled,
  }) async {
    final searchDepth = depth ?? _depth;
    // Quick scans cannot honestly verify Brilliant / Great / Forced
    // (spec § 3.6.2/4/6 requires MultiPV + deeper search). Surface the
    // fact to the classifier so those tiers are never emitted from a
    // Quick scan — the Phase A audit flagged "D14 claims Brilliant on
    // a 50 cp drift" as a real-device regression.
    final suppressTrophyTiers = mode == AnalysisMode.quick;
    final analysisMultiPv = mode == AnalysisMode.deep ? 3 : 1;
    // Resolve the movetime budget *after* the caller's depth override is
    // applied — otherwise a depth-22 scan would silently inherit the
    // constructor's depth-14 budget and finish at depth ~14, defeating
    // the premium scan mode entirely.
    final searchMovetime =
        movetime ?? _movetimeOverride ?? defaultMovetimeForDepth(searchDepth);
    // Resolve the book eagerly so book classifications aren't silently
    // skipped when the first analysis runs faster than the asset load.
    if (_book == null && _bookFuture != null) {
      try {
        _book = await _bookFuture;
      } catch (_) {
        // Asset missing / corrupt — fall back to engine-only classification.
        _book = null;
      }
    }
    // Capture into a local so Dart's flow analysis can promote it past
    // the subsequent `await` boundaries inside this method.
    final book = _book;
    final ValidatedPgnGame validated;
    try {
      validated = _pgnValidator.validate(pgn);
    } on PgnValidationException catch (error) {
      throw LocalAnalysisException(
        error.message,
        failure: LocalAnalysisFailure.invalidPgn,
      );
    }
    final headers = validated.headers;
    final startingFen = validated.startingFen;
    final parsed = validated.moves;

    final totalPlies = parsed.length;
    onProgress?.call(0, totalPlies);

    // ── Phase A integration: walk the full move list once to compute
    //    `isFirstSacrificePly` / `isTrivialRecapture` from material
    //    trajectory. Without this, every sacrificed-piece ply (including
    //    the opponent's recapture and the consolidating follow-up) was
    //    being fed `isFirstSacrificePly = true` and could pass the
    //    Brilliant gate, which is exactly the regression the user
    //    flagged in the post-PR-#18 audit. ──
    final trajectory = SacrificeTrajectory.analyze([
      for (final m in parsed)
        TrajectoryPly(
          fenBefore: m.fenBefore,
          fenAfter: m.fenAfter,
          isWhiteMove: m.isWhiteMove,
          targetSquare: m.targetSquare,
        ),
    ]);

    // ── Cache engine evals by FEN. fenAfter[ply N] == fenBefore[ply N+1],
    // so each non-book position is evaluated at most once. ──
    final cache = <String, EvalSnapshot>{};
    var engineSearchCount = 0;
    var engineCacheHitCount = 0;

    Future<EvalSnapshot?> evalCached(
      String fen, {
      int? evalDepth,
      Duration? evalMovetime,
      int? evalMultiPv,
      String profile = 'main',
      bool requiredEvidence = true,
    }) async {
      if (isCancelled?.call() == true) {
        _eval.cancelActiveSearch();
        throw const LocalAnalysisException(
          'Offline review cancelled.',
          failure: LocalAnalysisFailure.cancelled,
        );
      }
      final effectiveDepth = evalDepth ?? searchDepth;
      final effectiveMovetime = evalMovetime ?? searchMovetime;
      final effectiveMultiPv = evalMultiPv ?? analysisMultiPv;
      final cacheKey =
          '$fen|engine=local-${_eval.engineVersion}|classifier=$kApexClassifierVersion|profile=$profile|depth=$effectiveDepth|movetime=${effectiveMovetime.inMilliseconds}|multipv=$effectiveMultiPv';
      final hit = cache[cacheKey];
      if (hit != null) {
        engineCacheHitCount++;
        return hit;
      }
      engineSearchCount++;
      final (snap, err) = await _eval.evaluate(
        fen,
        depth: effectiveDepth,
        movetime: effectiveMovetime,
        multiPv: effectiveMultiPv,
      );
      if (err != null || snap == null || !snap.isUsableFor(fen)) {
        if (requiredEvidence) {
          throw LocalAnalysisException(
            'Offline review stopped: no trustworthy evaluation for the exact position.',
          );
        }
        return null;
      }
      cache[cacheKey] = snap;
      return snap;
    }

    // Seed the starting-position Win% from the engine's opening eval (if
    // not a book position) or from neutral 50 % (book positions).
    EvalSnapshot? startEval;
    if (book == null || !book.contains(startingFen)) {
      startEval = await evalCached(startingFen);
    }
    double prevWinPct = startEval != null
        ? EvaluationAnalyzer.calculateWinPercentage(
            cp: startEval.scoreCp,
            mate: startEval.mateIn,
          )
        : 50.0;

    final moves = <MoveAnalysis>[];

    for (var ply = 0; ply < totalPlies; ply++) {
      if (isCancelled?.call() == true) {
        _eval.cancelActiveSearch();
        throw const LocalAnalysisException(
          'Offline review cancelled.',
          failure: LocalAnalysisFailure.cancelled,
        );
      }
      final entry = parsed[ply];

      // ── Book cutoff: if the move is a known theoretical reply, trust
      // the book and skip the engine entirely. Saves ~70 % of searches in
      // the opening phase and lets batteries live to see move 20. ──
      final bookHit = book?.lookup(entry.fenAfter);
      if (bookHit != null) {
        moves.add(
          MoveAnalysis(
            ply: ply,
            san: entry.san,
            uci: entry.uci,
            fenBefore: entry.fenBefore,
            fenAfter: entry.fenAfter,
            targetSquare: entry.targetSquare,
            winPercentBefore: prevWinPct,
            winPercentAfter: prevWinPct,
            deltaW: 0,
            classification: MoveQuality.book,
            baseClassification: MoveQuality.book,
            finalClassification: MoveQuality.book,
            reasonCode: 'book_theory',
            playedEqualsPv1: false,
            engineEvaluationAvailable: false,
            requestedDepth: searchDepth,
            multiPvReceived: 0,
            searchQualityMet: false,
            isWhiteMove: entry.isWhiteMove,
            engineBestMoveSan: null,
            engineBestMoveUci: null,
            scoreCpAfter: null,
            mateInAfter: null,
            inBook: true,
            openingStatus: OpeningStatus.bookTheory,
            openingName: bookHit.name,
            ecoCode: bookHit.eco,
            engineLines: const <EngineLine>[],
            isCapture: entry.isCapture,
            isRecapture: _isRecapture(parsed, ply),
            message: '${bookHit.eco} • ${bookHit.name}',
            coachExplanation: 'This is opening theory.',
            analysisMode: mode.wire,
            classifierVersion: kApexClassifierVersion,
            engineVersion: _eval.engineVersion,
            debugMetadata: const {'classifierProfile': kApexClassifierProfile},
          ),
        );
        onProgress?.call(ply + 1, totalPlies);
        continue;
      }

      final before = await evalCached(entry.fenBefore);
      // Terminal positions (checkmate / stalemate / insufficient material)
      // are resolved from dartchess at parse time — the engine's response
      // on a mate-on-the-board position is ambiguous (`mate 0` from STM
      // POV). Using the synthesised eval avoids classifying the
      // mate-delivering ply as a Blunder.
      final after = _terminalEvalFor(entry) ?? await evalCached(entry.fenAfter);

      // Derive the *real* pre-move Win% from the engine — `prevWinPct`
      // may be stale if the previous plies came from the book (book moves
      // preserve the prior Win% unchanged, so the book→engine transition
      // would otherwise show an artificial jump on the first real eval).
      final winPctBefore = EvaluationAnalyzer.calculateWinPercentage(
        cp: before!.scoreCp,
        mate: before.mateIn,
      );
      final winPctAfter = EvaluationAnalyzer.calculateWinPercentage(
        cp: after!.scoreCp,
        mate: after.mateIn,
      );

      // Material-trajectory-derived sacrifice signals — see
      // `SacrificeTrajectory.analyze` for the gating rules. The Brilliant
      // gate now sees three correctly-computed flags instead of the
      // legacy `isFirstSacrificePly: true` default that made every
      // recapture a Brilliant candidate.
      final sac = trajectory[ply];
      final isRecapture = _isRecapture(parsed, ply);
      final isFreeCapture = _isFreeCapture(parsed, ply);
      final hasTacticalMotif =
          entry.san.contains('+') ||
          entry.san.contains('#') ||
          entry.san.contains('=') ||
          sac.isSacrifice ||
          (entry.isCapture && !isFreeCapture);
      final beforeLines = before.engineLines;
      final multiPvWhiteWinPercents = beforeLines.length >= 2
          ? beforeLines.map((l) => l.whiteWinPercent).toList(growable: false)
          : null;
      final secondBestWhiteWinPercent = beforeLines.length >= 2
          ? beforeLines[1].whiteWinPercent
          : null;
      final altLineWhiteWinPercent = _bestNonSacAlternativeWhiteWinPercent(
        entry,
        beforeLines,
        sac,
      );
      final openingStatus = _openingStatusFor(
        book: book,
        entry: entry,
        ply: ply,
      );
      final actualContinuation = _actualContinuation(parsed, ply);
      var tacticalVerdict = _tacticalVerifier.verify(
        DeepTacticalInput(
          fenBefore: entry.fenBefore,
          playedMoveUci: entry.uci,
          san: entry.san,
          isWhiteMove: entry.isWhiteMove,
          actualContinuationUci: actualContinuation,
          lowDepthLines: beforeLines,
          isCapture: entry.isCapture,
          isFreeCapture: isFreeCapture,
          isRecapture: isRecapture,
          isSacrifice: sac.isSacrifice,
          deltaW:
              (winPctAfter - winPctBefore) * (entry.isWhiteMove ? 1.0 : -1.0),
        ),
      );

      EvalSnapshot? lowCandidateEval;
      EvalSnapshot? highCandidateEval;
      final shouldVerifyCandidate =
          mode == AnalysisMode.deep && tacticalVerdict.isCandidate;
      if (shouldVerifyCandidate) {
        final lowDepth = searchDepth <= 10 ? searchDepth : 10;
        lowCandidateEval = await evalCached(
          entry.fenBefore,
          evalDepth: lowDepth,
          evalMovetime: const Duration(milliseconds: 650),
          evalMultiPv: 3,
          profile: 'candidate_low_v$kApexClassifierVersion',
          requiredEvidence: false,
        );
        final verificationDepth = searchDepth >= 22
            ? (searchDepth + 2 > 24 ? 24 : searchDepth + 2)
            : 22;
        highCandidateEval = await evalCached(
          entry.fenBefore,
          evalDepth: verificationDepth,
          evalMovetime: searchMovetime + const Duration(milliseconds: 1500),
          evalMultiPv: 5,
          profile: 'candidate_high_v$kApexClassifierVersion',
          requiredEvidence: false,
        );
        tacticalVerdict = _tacticalVerifier.verify(
          DeepTacticalInput(
            fenBefore: entry.fenBefore,
            playedMoveUci: entry.uci,
            san: entry.san,
            isWhiteMove: entry.isWhiteMove,
            actualContinuationUci: actualContinuation,
            lowDepthLines: lowCandidateEval?.engineLines ?? beforeLines,
            highDepthLines:
                highCandidateEval?.engineLines ?? const <EngineLine>[],
            isCapture: entry.isCapture,
            isFreeCapture: isFreeCapture,
            isRecapture: isRecapture,
            isSacrifice: sac.isSacrifice,
            deltaW:
                (winPctAfter - winPctBefore) * (entry.isWhiteMove ? 1.0 : -1.0),
            verificationDepth: verificationDepth,
            verificationMultiPV: 5,
          ),
        );
      }

      final classificationLines =
          highCandidateEval?.engineLines.isNotEmpty == true
          ? highCandidateEval!.engineLines
          : beforeLines;
      final engineBestMoveUci = classificationLines.isNotEmpty
          ? classificationLines.first.moveUci
          : before.bestMoveUci;
      final classificationWinPercents = classificationLines.length >= 2
          ? classificationLines
                .map((l) => l.whiteWinPercent)
                .toList(growable: false)
          : multiPvWhiteWinPercents;
      final classificationSecondBest = classificationLines.length >= 2
          ? classificationLines[1].whiteWinPercent
          : secondBestWhiteWinPercent;

      final result = _analyzer.analyze(
        prevCp: before.scoreCp,
        prevMate: before.mateIn,
        currCp: after.scoreCp,
        currMate: after.mateIn,
        isWhiteMove: entry.isWhiteMove,
        engineBestMoveUci: engineBestMoveUci,
        playedMoveUci: entry.uci,
        isSacrifice: sac.isSacrifice,
        isCapture: entry.isCapture,
        isFreeCapture: isFreeCapture,
        isRecapture: isRecapture,
        hasTacticalMotif: hasTacticalMotif,
        tacticalVerdict: tacticalVerdict,
        isTrivialRecapture: sac.isTrivialRecapture,
        isFirstSacrificePly: sac.isFirstSacrificePly,
        secondBestWhiteWinPercent: classificationSecondBest,
        multiPvWhiteWinPercents: classificationWinPercents,
        altLineWhiteWinPercent: altLineWhiteWinPercent,
        // Only flag `isBook` when the position actually matched our
        // ECO book (handled on the `bookHit != null` branch above —
        // we don't reach here when it did). The classifier no longer
        // forces Book just because we're early in the game.
        isBook: false,
        suppressTrophyTiers: suppressTrophyTiers,
        alternativeEvidenceComplete:
            before.targetDepthReached && before.multiPvComplete,
        deepVerificationComplete:
            highCandidateEval?.targetDepthReached == true &&
            highCandidateEval?.multiPvComplete == true &&
            tacticalVerdict.verified,
      );

      String? engineBestSan;
      if (classificationLines.isNotEmpty &&
          classificationLines.first.moveSan != null) {
        engineBestSan = classificationLines.first.moveSan;
      } else if (engineBestMoveUci != null) {
        engineBestSan = _tryUciToSan(entry.fenBefore, engineBestMoveUci);
      }

      moves.add(
        MoveAnalysis(
          ply: ply,
          san: entry.san,
          uci: entry.uci,
          fenBefore: entry.fenBefore,
          fenAfter: entry.fenAfter,
          targetSquare: entry.targetSquare,
          winPercentBefore: winPctBefore,
          winPercentAfter: winPctAfter,
          deltaW: result.deltaW,
          classification: result.quality,
          isWhiteMove: entry.isWhiteMove,
          engineBestMoveSan: engineBestSan,
          engineBestMoveUci: engineBestMoveUci,
          scoreCpAfter: after.scoreCp,
          mateInAfter: after.mateIn,
          inBook: false,
          openingStatus: openingStatus,
          engineLines: classificationLines,
          baseClassification: result.baseQuality,
          finalClassification: result.quality,
          reasonCode: result.reasonCode,
          playedEqualsPv1: result.playedEqualsPv1,
          moverCpLoss: result.moverCpLoss,
          engineEvaluationAvailable: true,
          requestedDepth: searchDepth,
          achievedDepthBefore: before.depth,
          achievedDepthAfter: after.status == PositionEvaluationStatus.terminal
              ? null
              : after.depth,
          multiPvReceived: before.receivedMultiPv,
          searchQualityMet:
              before.targetDepthReached &&
              (after.status == PositionEvaluationStatus.terminal ||
                  after.targetDepthReached),
          isCapture: entry.isCapture,
          isFreeCapture: isFreeCapture,
          isRecapture: isRecapture,
          isSacrifice: sac.isSacrifice,
          isFirstSacrificePly: sac.isFirstSacrificePly,
          tacticalVerdict: tacticalVerdict,
          message: result.message,
          coachExplanation: tacticalVerdict.humanExplanation.isNotEmpty
              ? tacticalVerdict.humanExplanation
              : result.message,
          analysisMode: mode.wire,
          classifierVersion: kApexClassifierVersion,
          engineVersion: _eval.engineVersion,
          debugMetadata: {
            'classifierProfile': kApexClassifierProfile,
            'candidateVerified': tacticalVerdict.candidateVerified,
            'verificationDepth': tacticalVerdict.verificationDepth,
            'verificationMultiPV': tacticalVerdict.verificationMultiPV,
          },
        ),
      );

      prevWinPct = winPctAfter;
      onProgress?.call(ply + 1, totalPlies);
    }

    final winPercentages = moves.map((m) => m.winPercentAfter).toList();
    final timeline = AnalysisTimeline(
      moves: moves,
      startingFen: startingFen,
      headers: headers,
      winPercentages: winPercentages,
      analysisMode: mode.wire,
      classifierVersion: kApexClassifierVersion,
      engineVersion: _eval.engineVersion,
      providerId: 'local_offline',
      tacticalVerifierVersion: kApexTacticalVerifierVersion,
      openingBookVersion: kApexOpeningBookVersion,
      analysisSchemaVersion: kApexAnalysisSchemaVersion,
      depth: moves
          .expand(
            (move) => <int>[
              if (move.achievedDepthBefore != null) move.achievedDepthBefore!,
              if (move.achievedDepthAfter != null) move.achievedDepthAfter!,
            ],
          )
          .fold<int?>(
            null,
            (min, value) => min == null || value < min ? value : min,
          ),
      requestedDepth: searchDepth,
      movetimeMs: searchMovetime.inMilliseconds,
      multipv: analysisMultiPv,
      candidateVerificationEnabled: mode == AnalysisMode.deep,
      completedAt: DateTime.now().toUtc(),
      completionStatus: AnalysisCompletionStatus.complete,
      expectedPlies: totalPlies,
      engineSearchCount: engineSearchCount,
      engineCacheHitCount: engineCacheHitCount,
    );
    // Phase A integration audit, step A: structured per-ply log so future
    // regressions can be triaged from a single device-log dump. No-op in
    // release.
    AnalysisDebugExport.dump(timeline, tag: 'local');
    return timeline;
  }

  bool _isRecapture(List<ValidatedPgnMove> parsed, int ply) {
    if (ply <= 0) return false;
    final prev = parsed[ply - 1];
    final curr = parsed[ply];
    return curr.isCapture &&
        prev.targetSquare.isNotEmpty &&
        prev.targetSquare == curr.targetSquare;
  }

  bool _isFreeCapture(List<ValidatedPgnMove> parsed, int ply) {
    final curr = parsed[ply];
    if (!curr.isCapture) return false;
    final before = PositionHeuristics.materialBalanceFromFen(curr.fenBefore);
    final replyFen = ply + 1 < parsed.length
        ? parsed[ply + 1].fenAfter
        : curr.fenAfter;
    final after = PositionHeuristics.materialBalanceFromFen(replyFen);
    if (before == null || after == null) return false;
    final moverSign = curr.isWhiteMove ? 1 : -1;
    return (after - before) * moverSign > 0;
  }

  List<String> _actualContinuation(List<ValidatedPgnMove> parsed, int ply) {
    final out = <String>[];
    for (
      var i = ply + 1;
      i < parsed.length && out.length < DeepTacticalVerifier.replayLimitPlies;
      i++
    ) {
      final uci = parsed[i].uci;
      if (uci.length >= 4) out.add(uci);
    }
    return out;
  }

  static const int _openingPhaseMaxPly = 20;

  OpeningStatus _openingStatusFor({
    required EcoBook? book,
    required ValidatedPgnMove entry,
    required int ply,
  }) {
    if (ply >= _openingPhaseMaxPly) return OpeningStatus.notOpening;
    if (book != null && book.contains(entry.fenBefore)) {
      return OpeningStatus.bookDeviation;
    }
    return OpeningStatus.openingPhaseUnknown;
  }

  double? _bestNonSacAlternativeWhiteWinPercent(
    ValidatedPgnMove entry,
    List<EngineLine> lines,
    SacrificeContext sac,
  ) {
    if (!sac.isSacrifice || lines.length < 2) return null;
    for (final line in lines) {
      final moveUci = line.moveUci;
      if (moveUci == null || moveUci.isEmpty) continue;
      if (normalizeCastlingUci(moveUci) == normalizeCastlingUci(entry.uci)) {
        continue;
      }
      if (_lineLooksSacrificial(entry, moveUci)) continue;
      return line.whiteWinPercent;
    }
    return null;
  }

  bool _lineLooksSacrificial(ValidatedPgnMove entry, String moveUci) {
    final afterFen = _tryFenAfterUci(entry.fenBefore, moveUci);
    if (afterFen == null) return false;
    final ctx = SacrificeTrajectory.analyze([
      TrajectoryPly(
        fenBefore: entry.fenBefore,
        fenAfter: afterFen,
        isWhiteMove: entry.isWhiteMove,
        targetSquare: moveUci.length >= 4 ? moveUci.substring(2, 4) : '',
      ),
    ]);
    return ctx.isNotEmpty && ctx.first.isSacrifice;
  }

  String? _tryFenAfterUci(String fen, String uci) {
    try {
      if (uci.length < 4) return null;
      final pos = Chess.fromSetup(Setup.parseFen(fen));
      final from = _parseSquare(uci.substring(0, 2));
      final to = _parseSquare(uci.substring(2, 4));
      if (from == null || to == null) return null;
      Role? promotion;
      if (uci.length == 5) {
        promotion = switch (uci[4]) {
          'q' => Role.queen,
          'r' => Role.rook,
          'b' => Role.bishop,
          'n' => Role.knight,
          _ => null,
        };
      }
      final move = NormalMove(from: from, to: to, promotion: promotion);
      if (!pos.isLegal(move)) return null;
      return pos.play(move).fen;
    } catch (_) {
      return null;
    }
  }

  String? _tryUciToSan(String fen, String uci) {
    try {
      if (uci.length < 4) return null;
      final pos = Chess.fromSetup(Setup.parseFen(fen));
      final from = _parseSquare(uci.substring(0, 2));
      final to = _parseSquare(uci.substring(2, 4));
      if (from == null || to == null) return null;
      Role? promotion;
      if (uci.length == 5) {
        promotion = switch (uci[4]) {
          'q' => Role.queen,
          'r' => Role.rook,
          'b' => Role.bishop,
          'n' => Role.knight,
          _ => null,
        };
      }
      final move = NormalMove(from: from, to: to, promotion: promotion);
      if (!pos.isLegal(move)) return null;
      return pos.makeSan(move).$2;
    } catch (_) {
      return null;
    }
  }

  static Square? _parseSquare(String alg) {
    if (alg.length != 2) return null;
    final file = alg.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.tryParse(alg[1]);
    if (file < 0 || file > 7 || rank == null || rank < 1 || rank > 8) {
      return null;
    }
    return Square(file + (rank - 1) * 8);
  }

  // Sacrifice detection lives in [PositionHeuristics] so the cloud
  // analyser can share the same logic without copying the FEN
  // material-balance code.
}

/// Build a signed-from-white-POV [EvalSnapshot] for the position that
/// results from a terminal ply. Returns `null` when the post-move
/// position is not terminal — caller falls back to the normal engine
/// eval path.
///
///   * checkmate: `mateIn = isWhiteMove ? 1 : -1` so the classifier's
///     `moverForcesMate` predicate sees the favourable side and the
///     move is no longer classified as Blunder.
///   * stalemate / insufficient material / 75-move / 5-fold: `scoreCp = 0`
///     so the position reads as drawn, not as "engine unreachable".
EvalSnapshot? _terminalEvalFor(ValidatedPgnMove move) {
  if (move.terminalState == ValidatedTerminalState.checkmate) {
    return EvalSnapshot(
      scoreCp: null,
      mateIn: move.isWhiteMove ? 1 : -1,
      depth: 0,
      bestMoveUci: null,
      pvMoves: const <String>[],
      positionFen: move.fenAfter,
      status: PositionEvaluationStatus.terminal,
    );
  }
  if (move.terminalState == ValidatedTerminalState.stalemate ||
      move.terminalState == ValidatedTerminalState.insufficientMaterial) {
    return EvalSnapshot(
      scoreCp: 0,
      mateIn: null,
      depth: 0,
      bestMoveUci: null,
      pvMoves: const <String>[],
      positionFen: move.fenAfter,
      status: PositionEvaluationStatus.terminal,
    );
  }
  return null;
}
