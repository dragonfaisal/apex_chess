/// Full-game analyzer backed by the on-device Apex AI Analyst.
///
/// Drop-in replacement for [CloudGameAnalyzer] — same public contract
/// (`analyzeFromPgn` + `onProgress`) and the same `AnalysisTimeline` return
/// type so the Review pipeline does not care whether analysis came from
/// Lichess or from local Stockfish.
///
/// ### Pipeline (per ply)
///
/// 1. Check the verified opening index for provenance only. A confirmed
///    theory hit still receives objective engine evidence so Book can never
///    conceal a severe loss.
/// 2. Request the engine eval for the *before* FEN (mover's
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
import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/entities/position_evaluation.dart';
import 'package:apex_chess/core/domain/services/analysis_debug_export.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/deep_tactical_verifier.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_insight_engine.dart';
import 'package:apex_chess/core/domain/services/position_heuristics.dart';
import 'package:apex_chess/core/domain/services/pgn_mainline_validator.dart';
import 'package:apex_chess/core/domain/services/sacrifice_trajectory.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart'
    show AnalysisMode;
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:apex_chess/infrastructure/openings/opening_index.dart'
    show kApexOpeningArtifactIdentity;

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
    OpeningLookup? openingLookup,
    Future<OpeningLookup>? openingLookupFuture,
    EvaluationAnalyzer analyzer = const EvaluationAnalyzer(),
    DeepTacticalVerifier tacticalVerifier = const DeepTacticalVerifier(),
    PgnMainlineValidator pgnValidator = const PgnMainlineValidator(),
    MoveInsightGenerator insightGenerator = const MoveInsightEngine(),
    int depth = 14,
    // Optional wall-clock cap per position. When null, the analyzer
    // picks a sensible budget for the effective search depth via
    // [defaultMovetimeForDepth] — this keeps "Fast" scans snappy while
    // giving "Quantum Deep Scan" enough time to actually reach its
    // target depth.
    Duration? movetime,
  }) : _eval = eval,
       _openingLookup = openingLookup,
       _openingLookupFuture = openingLookupFuture,
       _analyzer = analyzer,
       _tacticalVerifier = tacticalVerifier,
       _pgnValidator = pgnValidator,
       _insightGenerator = insightGenerator,
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
  // Opening state is materialised on first `analyzeFromPgn` call. Passing
  // the future prevents the first game from racing the asset load.
  OpeningLookup? _openingLookup;
  final Future<OpeningLookup>? _openingLookupFuture;
  String _openingUnavailableReason = 'opening_lookup_not_configured';
  int _lastOpeningLookupCount = 0;
  final EvaluationAnalyzer _analyzer;
  final DeepTacticalVerifier _tacticalVerifier;
  final PgnMainlineValidator _pgnValidator;
  final MoveInsightGenerator _insightGenerator;
  final int _depth;
  final Duration? _movetimeOverride;

  String get engineVersion => _eval.engineVersion;

  /// Number of opening-transition lookups made by the most recent run.
  /// Exact saved reopen never enters this analyzer and therefore stays zero.
  int get lastOpeningLookupCount => _lastOpeningLookupCount;

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
    final analysisMultiPv = mode == AnalysisMode.deep ? 3 : 1;
    // Resolve the movetime budget *after* the caller's depth override is
    // applied — otherwise a depth-22 scan would silently inherit the
    // constructor's depth-14 budget and finish at depth ~14, defeating
    // the premium scan mode entirely.
    final searchMovetime =
        movetime ?? _movetimeOverride ?? defaultMovetimeForDepth(searchDepth);
    _lastOpeningLookupCount = 0;
    // Resolve the transition-aware index eagerly. A load failure remains an
    // explicit unavailable evidence state; it is never downgraded to noMatch.
    if (_openingLookup == null && _openingLookupFuture != null) {
      try {
        _openingLookup = await _openingLookupFuture;
      } catch (_) {
        _openingUnavailableReason = 'opening_lookup_load_failed';
      }
    }
    final openingLookup = _openingLookup;
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
    final standardOpeningStart = _isStandardOpeningStart(
      headers: headers,
      startingFen: startingFen,
    );

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
      String cacheKey() =>
          '$fen|engine=local-${_eval.engineVersion}|classifier=$kApexClassifierVersion|profile=$profile|depth=$effectiveDepth|movetime=${effectiveMovetime.inMilliseconds}|multipv=$effectiveMultiPv';
      final requestCacheKey = cacheKey();
      final hit = cache[requestCacheKey];
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
      if (isCancelled?.call() == true || err == EvalError.cancelled) {
        throw const LocalAnalysisException(
          'Offline review cancelled.',
          failure: LocalAnalysisFailure.cancelled,
        );
      }
      if (err != null || snap == null || !snap.isUsableFor(fen)) {
        if (requiredEvidence) {
          throw LocalAnalysisException(
            'Offline review stopped: no trustworthy evaluation for the exact position.',
          );
        }
        return null;
      }
      // The first evaluation may start Stockfish and replace its provisional
      // `unknown` identity with the UCI-resolved bridge identity. Re-key the
      // successful result after that handshake so the immediately following
      // ply-0 lookup reuses the starting-FEN search.
      cache[cacheKey()] = snap;
      return snap;
    }

    // Book membership is provenance, never a substitute for evaluation.
    // The starting position therefore always receives the same trustworthy
    // score contract as every later position.
    await evalCached(startingFen);

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

      // Opening provenance is an exact transition fact. A known resulting
      // position or early ply can never manufacture Book.
      final openingEvidence = _openingEvidenceFor(
        lookup: openingLookup,
        entry: entry,
        ply: ply,
        standardStart: standardOpeningStart,
      );

      final before = await evalCached(entry.fenBefore);
      // Terminal positions (checkmate / stalemate / insufficient material)
      // are resolved from dartchess at parse time — the engine's response
      // on a mate-on-the-board position is ambiguous (`mate 0` from STM
      // POV). Using the synthesised eval avoids classifying the
      // mate-delivering ply as a Blunder.
      final after = _terminalEvalFor(entry) ?? await evalCached(entry.fenAfter);

      // Derive the pre-move Win% from the exact engine snapshot.
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
      final beforeLines = before.engineLines;
      final openingStatus = _openingStatusFor(openingEvidence, ply: ply);
      final openingCandidate = openingEvidence.selectedCandidate;
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

      // Candidate verification may become authoritative only when its own
      // exact frame is complete. A partial higher search can never borrow the
      // main search's completeness flags.
      final highCandidateComplete =
          highCandidateEval?.targetDepthReached == true &&
          highCandidateEval?.multiPvComplete == true;
      final classificationSnapshot = highCandidateComplete
          ? highCandidateEval!
          : before;
      final classificationLines = classificationSnapshot.engineLines;
      final engineBestMoveUci = classificationSnapshot.bestMoveUci;
      final candidateEvidence = _candidateEvidence(
        entry.fenBefore,
        classificationLines,
      );
      final legalMoveCount = _legalMoveCount(entry.fenBefore);
      final bestMovePv1Consistent =
          engineBestMoveUci != null &&
          classificationLines.isNotEmpty &&
          normalizeCastlingUci(engineBestMoveUci) ==
              normalizeCastlingUci(classificationLines.first.moveUci ?? '');
      final classificationSearchQualityMet =
          classificationSnapshot.targetDepthReached &&
          (after.status == PositionEvaluationStatus.terminal ||
              after.targetDepthReached);
      final evidence = MoveClassificationEvidence(
        mover: entry.isWhiteMove
            ? ClassificationMover.white
            : ClassificationMover.black,
        evaluationBefore: _classificationScoreForSnapshot(
          classificationSnapshot,
        ),
        playedMoveEvaluation: _classificationScoreForSnapshot(after),
        bestMoveEvaluation: classificationLines.isNotEmpty
            ? _classificationScoreForLine(classificationLines.first)
            : _classificationScoreForSnapshot(classificationSnapshot),
        playedMoveUci: entry.uci,
        bestMoveUci: engineBestMoveUci,
        candidates: candidateEvidence,
        requestedMultiPv: classificationSnapshot.requestedMultiPv,
        receivedMultiPv: classificationSnapshot.receivedMultiPv,
        candidateSetComplete: classificationSnapshot.multiPvComplete,
        candidateSetCoherent:
            candidateEvidence.isNotEmpty &&
            candidateEvidence.length == classificationLines.length,
        bestMovePv1Consistent: bestMovePv1Consistent,
        searchQualityMet: classificationSearchQualityMet,
        achievedDepthFloor: _minimumDepth(
          classificationSnapshot,
          after.status == PositionEvaluationStatus.terminal ? null : after,
        ),
        legalMoveCount: legalMoveCount,
        bookState:
            standardOpeningStart && openingEvidence.isVerifiedBookTransition
            ? ClassificationBookState.verified
            : openingEvidence.state == OpeningMatchState.unavailable ||
                  !openingEvidence.isArtifactVerified
            ? ClassificationBookState.unavailable
            : ClassificationBookState.notBook,
        verificationState: shouldVerifyCandidate
            ? highCandidateComplete && tacticalVerdict.verified
                  ? ClassificationVerificationState.complete
                  : ClassificationVerificationState.incomplete
            : ClassificationVerificationState.notRequested,
        forcedState: legalMoveCount == 1
            ? ClassificationForcedState.onlyLegalMove
            : ClassificationForcedState.notForced,
        isSacrifice: sac.isSacrifice,
        isCapture: entry.isCapture,
        isFreeCapture: isFreeCapture,
        isRecapture: isRecapture,
        isTrivialRecapture: sac.isTrivialRecapture,
        isFirstSacrificePly: sac.isFirstSacrificePly,
        tacticalBestOrNearBest: tacticalVerdict.isBestOrNearBest,
        tacticalHasForcingOutcome: tacticalVerdict.hasForcingOutcome,
        tacticalForcedMate: tacticalVerdict.forcedMate,
      );
      final result = _analyzer.analyzeEvidence(evidence);
      if (result.quality == MoveQuality.unavailable) {
        throw const LocalAnalysisException(
          'Offline review stopped: classification evidence was incomplete.',
        );
      }

      String? engineBestSan;
      if (classificationLines.isNotEmpty &&
          classificationLines.first.moveSan != null) {
        engineBestSan = classificationLines.first.moveSan;
      } else if (engineBestMoveUci != null) {
        engineBestSan = _tryUciToSan(entry.fenBefore, engineBestMoveUci);
      }

      final insight = _insightGenerator.generate(
        MoveInsightInput(
          fenBefore: entry.fenBefore,
          fenAfter: entry.fenAfter,
          playedMoveUci: entry.uci,
          playedMoveSan: entry.san,
          isWhiteMove: entry.isWhiteMove,
          classification: result.quality,
          classificationEvidence: evidence,
          preMoveLines: classificationLines,
          postMoveLines: after.engineLines,
          postMoveSearchQualityMet:
              after.status == PositionEvaluationStatus.terminal ||
              after.targetDepthReached,
          engineBestMoveSan: engineBestSan,
          openingEvidence: openingEvidence,
        ),
      );

      moves.add(
        MoveAnalysis(
          ply: ply,
          san: entry.san,
          uci: entry.uci,
          fenBefore: entry.fenBefore,
          fenAfter: entry.fenAfter,
          targetSquare: entry.targetSquare,
          winPercentBefore: result.winPercentBefore,
          winPercentAfter: result.winPercentAfter,
          deltaW: result.deltaW,
          classification: result.quality,
          isWhiteMove: entry.isWhiteMove,
          engineBestMoveSan: engineBestSan,
          engineBestMoveUci: engineBestMoveUci,
          scoreCpAfter: after.scoreCp,
          mateInAfter: after.mateIn,
          // Compatibility mirror only. Opening provenance lives in the
          // immutable evidence and cannot hide an objective error label.
          inBook: result.quality == MoveQuality.book,
          openingStatus: openingStatus,
          openingName: openingCandidate?.openingName,
          ecoCode: openingCandidate?.ecoCode,
          openingEvidence: openingEvidence,
          engineLines: classificationLines,
          baseClassification: result.baseQuality,
          finalClassification: result.quality,
          reasonCode: result.reasonCode,
          classificationEvidence: evidence,
          classificationReasonCodes: result.reasonCodes,
          classificationFailedGates: result.failedGates,
          playedEqualsPv1: result.playedEqualsPv1,
          moverCpLoss: result.moverCpLoss,
          engineEvaluationAvailable: true,
          requestedDepth: searchDepth,
          achievedDepthBefore: classificationSnapshot.depth,
          achievedDepthAfter: after.status == PositionEvaluationStatus.terminal
              ? null
              : after.depth,
          multiPvReceived: classificationSnapshot.receivedMultiPv,
          searchQualityMet: classificationSearchQualityMet,
          isCapture: entry.isCapture,
          isFreeCapture: isFreeCapture,
          isRecapture: isRecapture,
          isSacrifice: sac.isSacrifice,
          isFirstSacrificePly: sac.isFirstSacrificePly,
          tacticalVerdict: tacticalVerdict,
          message:
              result.quality == MoveQuality.book && openingCandidate != null
              ? '${openingCandidate.ecoCode} • '
                    '${openingCandidate.openingName}'
              : result.message,
          coachExplanation: '',
          insight: insight,
          analysisMode: mode.wire,
          classifierVersion: kApexClassifierVersion,
          engineVersion: _eval.engineVersion,
          debugMetadata: {
            'classifierProfile': kApexClassifierProfile,
            'candidateVerified': tacticalVerdict.candidateVerified,
            'verificationDepth': tacticalVerdict.verificationDepth,
            'verificationMultiPV': tacticalVerdict.verificationMultiPV,
            'classificationSource': highCandidateComplete
                ? 'candidateHigh'
                : 'main',
            'classificationDiagnostics': result.diagnosticJson,
            'openingEvidenceState': openingEvidence.state.name,
            'openingEvidenceReason': openingEvidence.reasonCode,
            'openingArtifactId': openingEvidence.artifact.semanticId,
            'moveInsightState': insight.state.name,
          },
        ).sealAnalysisIntegrity(),
      );

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
      explanationPolicyVersion: kApexExplanationPolicyVersion,
      explanationClaimSchemaVersion: kApexExplanationClaimSchemaVersion,
      explanationRendererVersion: kApexExplanationRendererVersion,
      openingArtifact: openingLookup?.identity ?? kApexOpeningArtifactIdentity,
      openingArtifactVerification:
          openingLookup?.verification ??
          OpeningArtifactVerification.unavailable,
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

  List<ClassificationCandidateEvidence> _candidateEvidence(
    String fen,
    List<EngineLine> lines,
  ) => <ClassificationCandidateEvidence>[
    for (final line in lines)
      ClassificationCandidateEvidence(
        rootUci: line.moveUci ?? '',
        rank: line.rank,
        score: _classificationScoreForLine(line) ?? const ClassificationScore(),
        achievedDepth: line.depth,
        isLegal: _tryUciToSan(fen, line.moveUci ?? '') != null,
        pvComplete: line.pvMoves.isNotEmpty,
      ),
  ];

  ClassificationScore? _classificationScoreForSnapshot(EvalSnapshot snapshot) {
    if ((snapshot.scoreCp == null) == (snapshot.mateIn == null) ||
        snapshot.mateIn == 0) {
      return null;
    }
    return ClassificationScore(
      whiteCp: snapshot.scoreCp,
      whiteMate: snapshot.mateIn,
    );
  }

  ClassificationScore? _classificationScoreForLine(EngineLine line) {
    if ((line.scoreCp == null) == (line.mateIn == null) || line.mateIn == 0) {
      return null;
    }
    return ClassificationScore(whiteCp: line.scoreCp, whiteMate: line.mateIn);
  }

  int? _minimumDepth(EvalSnapshot before, EvalSnapshot? after) {
    if (after == null) return before.depth;
    return before.depth < after.depth ? before.depth : after.depth;
  }

  int? _legalMoveCount(String fen) {
    try {
      final position = Chess.fromSetup(Setup.parseFen(fen));
      var count = 0;
      position.legalMoves.forEach((from, destinations) {
        final piece = position.board.pieceAt(from);
        for (final square in destinations.squares) {
          final promotion =
              piece?.role == Role.pawn &&
              (square.rank == 0 || square.rank == 7);
          count += promotion ? 4 : 1;
        }
      });
      return count;
    } on Object {
      return null;
    }
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

  OpeningEvidence _openingEvidenceFor({
    required OpeningLookup? lookup,
    required ValidatedPgnMove entry,
    required int ply,
    required bool standardStart,
  }) {
    if (lookup != null) {
      try {
        _lastOpeningLookupCount++;
        return lookup.lookupTransition(
          fenBefore: entry.fenBefore,
          playedMoveUci: entry.uci,
          fenAfter: entry.fenAfter,
          ply: ply,
          standardStart: standardStart,
        );
      } catch (_) {
        _openingUnavailableReason = 'opening_lookup_runtime_failed';
      }
    }
    return OpeningEvidence(
      artifact: lookup?.identity ?? kApexOpeningArtifactIdentity,
      artifactVerification:
          lookup?.verification ?? OpeningArtifactVerification.unavailable,
      state: OpeningMatchState.unavailable,
      beforePositionKey: OpeningPositionKey.fromFen(entry.fenBefore).value,
      afterPositionKey: OpeningPositionKey.fromFen(entry.fenAfter).value,
      playedUci: entry.uci,
      transitionVerified: false,
      selectedCandidate: null,
      totalCandidateCount: 0,
      matchedPly: ply + 1,
      reasonCode: _openingUnavailableReason,
    );
  }

  OpeningStatus _openingStatusFor(
    OpeningEvidence evidence, {
    required int ply,
  }) => switch (evidence.state) {
    OpeningMatchState.knownTransition => OpeningStatus.bookTheory,
    OpeningMatchState.leftTheory => OpeningStatus.bookDeviation,
    OpeningMatchState.unavailable ||
    OpeningMatchState.noMatch ||
    OpeningMatchState.knownPosition ||
    OpeningMatchState.ambiguousCandidates =>
      ply < _openingPhaseMaxPly
          ? OpeningStatus.openingPhaseUnknown
          : OpeningStatus.notOpening,
  };

  bool _isStandardOpeningStart({
    required Map<String, String> headers,
    required String startingFen,
  }) {
    final normalizedHeaders = <String, String>{
      for (final entry in headers.entries)
        entry.key.trim().toLowerCase(): entry.value.trim(),
    };
    if (normalizedHeaders['setup'] == '1' ||
        normalizedHeaders.containsKey('fen')) {
      return false;
    }
    return OpeningPositionKey.isStandardInitialFen(startingFen);
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
