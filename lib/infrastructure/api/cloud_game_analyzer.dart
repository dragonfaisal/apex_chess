/// Cloud-only full game analyzer.
///
/// Orchestrates Opening Explorer + Cloud Eval for complete game analysis:
///   1. For each ply, query Opening Explorer first (plies 0–20).
///   2. If move is in book (≥10 games) → classify as Book, assign name/ECO.
///   3. If move is a DEVIATION → immediately query Cloud Eval for deltaW.
///      NO IMMUNITY. A blunder on move 4 is flagged as Blunder (??).
///   4. After book zone, every move is evaluated via Cloud Eval.
///
/// Returns [AnalysisTimeline] for the review pipeline (identical to mock flow).
library;

import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/services/analysis_debug_export.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/sacrifice_trajectory.dart';
import 'package:apex_chess/infrastructure/api/cloud_eval_service.dart';
import 'package:apex_chess/infrastructure/api/opening_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Error
// ─────────────────────────────────────────────────────────────────────────────

class CloudAnalysisException implements Exception {
  final String message;
  final CloudEvalError? evalError;

  const CloudAnalysisException(this.message, {this.evalError});

  @override
  String toString() => 'CloudAnalysisException: $message';

  /// User-facing message.
  String get userMessage {
    if (evalError == CloudEvalError.offline) {
      return 'Cloud analysis requires an internet connection.';
    }
    if (evalError == CloudEvalError.rateLimited) {
      return 'Rate limited by Lichess. Please try again in a few minutes.';
    }
    return 'Analysis temporarily unavailable. Please try again later.';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Analyzer
// ─────────────────────────────────────────────────────────────────────────────

class CloudGameAnalyzer {
  final CloudEvalService _cloudEval;
  final OpeningService _openings;
  final EvaluationAnalyzer _analyzer;

  CloudGameAnalyzer({
    required CloudEvalService cloudEval,
    required OpeningService openings,
    EvaluationAnalyzer analyzer = const EvaluationAnalyzer(),
  })  : _cloudEval = cloudEval,
        _openings = openings,
        _analyzer = analyzer;

  /// Analyzes a full game from PGN notation.
  ///
  /// [onProgress] — called with (completed, total) for UI progress.
  /// Throws [CloudAnalysisException] on persistent network/rate-limit failures.
  Future<AnalysisTimeline> analyzeFromPgn(
    String pgn, {
    void Function(int completed, int total)? onProgress,
  }) async {
    // 1. Parse PGN → extract all positions + moves.
    final game = PgnGame.parsePgn(pgn);
    final headers = Map<String, String>.from(game.headers);
    Position position = PgnGame.startingPosition(game.headers);
    final startingFen = position.fen;

    final moveList = <_ParsedMove>[];

    for (final node in game.moves.mainline()) {
      final move = position.parseSan(node.san);
      if (move == null) break;

      final fenBefore = position.fen;
      final isWhite = position.turn == Side.white;
      final newPos = position.play(move);

      String uci;
      String targetSquare = '';
      if (move is NormalMove) {
        final rawUci = '${_sqAlg(move.from)}${_sqAlg(move.to)}'
            '${move.promotion != null ? _roleChar(move.promotion!) : ""}';
        // Normalise castling UCIs (e1h1 → e1g1) so the downstream
        // engine-match test and the board aura both land on the king's
        // destination square rather than the rook's.
        uci = normalizeCastlingUci(rawUci);
        targetSquare = uci.substring(2, 4);
      } else {
        uci = node.san;
      }

      moveList.add(_ParsedMove(
        fenBefore: fenBefore,
        fenAfter: newPos.fen,
        san: node.san,
        uci: uci,
        targetSquare: targetSquare,
        isWhiteMove: isWhite,
      ));

      position = newPos;
    }

    final totalPlies = moveList.length;
    onProgress?.call(0, totalPlies);

    // Phase A integration audit: walk the full move list once to compute
    // material-trajectory signals so the Brilliant gate sees correct
    // `isFirstSacrificePly` / `isTrivialRecapture` flags. See
    // `SacrificeTrajectory.analyze` for the gating rules.
    final trajectory = SacrificeTrajectory.analyze([
      for (final m in moveList)
        TrajectoryPly(
          fenBefore: m.fenBefore,
          fenAfter: m.fenAfter,
          isWhiteMove: m.isWhiteMove,
          targetSquare: m.targetSquare,
        ),
    ]);

    // 2. Get starting position eval.
    final (startEval, startErr) = await _cloudEval.evaluate(startingFen);
    if (startErr == CloudEvalError.offline ||
        startErr == CloudEvalError.rateLimited) {
      throw CloudAnalysisException(
        'Cannot reach cloud evaluation service.',
        evalError: startErr,
      );
    }

    double prevWinPct = startEval != null
        ? EvaluationAnalyzer.calculateWinPercentage(
            cp: startEval.scoreCp, mate: startEval.mateIn)
        : 50.0;

    final moves = <MoveAnalysis>[];
    int consecutiveNotFound = 0;
    const int maxConsecutiveNotFound = 5;

    // 3. Analyze each ply.
    for (int ply = 0; ply < totalPlies; ply++) {
      final entry = moveList[ply];

      // ── Phase 5: Opening Explorer Check ──────────────────────────
      final openingInfo = await _openings.checkMove(
        fen: entry.fenBefore,
        playedSan: entry.san,
        ply: ply,
      );

      // ── BOOK MOVE → classify as Book, no engine eval needed ──────
      if (openingInfo.isBookMove) {
        consecutiveNotFound = 0;
        final winPctAfter = prevWinPct; // Book moves: neutral Win% delta.
        moves.add(MoveAnalysis(
          ply: ply,
          san: entry.san,
          uci: entry.uci,
          fenBefore: entry.fenBefore,
          fenAfter: entry.fenAfter,
          targetSquare: entry.targetSquare,
          winPercentBefore: prevWinPct,
          winPercentAfter: winPctAfter,
          deltaW: 0.0,
          classification: MoveQuality.book,
          isWhiteMove: entry.isWhiteMove,
          openingName: openingInfo.openingName,
          ecoCode: openingInfo.ecoCode,
          inBook: true,
          message: openingInfo.openingName != null
              ? '📖 ${openingInfo.openingName}'
              : '📖 Book move (${openingInfo.gamesPlayed} games)',
        ));
        onProgress?.call(ply + 1, totalPlies);
        continue;
      }

      // ── DEVIATION or OUT-OF-BOOK → must evaluate via Cloud Eval ──
      final (afterEval, afterErr) = await _cloudEval.evaluate(entry.fenAfter);

      if (afterErr == CloudEvalError.offline) {
        throw CloudAnalysisException(
          'Lost internet connection during analysis.',
          evalError: afterErr,
        );
      }

      if (afterErr == CloudEvalError.rateLimited) {
        throw CloudAnalysisException(
          'Rate limited during analysis.',
          evalError: afterErr,
        );
      }

      if (afterEval == null) {
        // Position not in cloud database.
        consecutiveNotFound++;

        if (consecutiveNotFound >= maxConsecutiveNotFound) {
          // Too many misses — likely past cloud database coverage.
          // Use neutral classification for remaining moves.
          moves.add(_neutralMove(ply, entry, prevWinPct, openingInfo));
          onProgress?.call(ply + 1, totalPlies);
          continue;
        }

        moves.add(_neutralMove(ply, entry, prevWinPct, openingInfo));
        onProgress?.call(ply + 1, totalPlies);
        continue;
      }

      consecutiveNotFound = 0;

      // ── Calculate Win% and classify ──────────────────────────────
      final currCpWhite = afterEval.scoreCp;
      final currMateWhite = afterEval.mateIn;
      final winPctAfter = EvaluationAnalyzer.calculateWinPercentage(
          cp: currCpWhite, mate: currMateWhite);

      // Pull the before-position eval with multiPv=2 so we can detect
      // "only winning move" (Great) by comparing PV[0] vs PV[1] —
      // exactly how Lichess's own analysis annotator does it.
      final (beforeEval, _) =
          await _cloudEval.evaluate(entry.fenBefore, multiPv: 2);

      // Material-trajectory-derived sacrifice signals. These replace the
      // legacy single-ply heuristic so the Brilliant gate now sees correct
      // `isFirstSacrificePly` and `isTrivialRecapture` flags rather than
      // the hard-coded `true` defaults that produced the post-PR-#18
      // "Brilliant on every recapture" regression.
      final sac = trajectory[ply];

      // Only-winning-move flag — fires when PV[1]'s evaluation drops the
      // mover's Win% by ≥12 percentage points relative to PV[0]. The
      // 12pp threshold matches Lichess's "Only Move" annotation rule
      // (`Only Move` ≈ best move is forced; the alternative is at least
      // an Inaccuracy band). We only set the flag when both PVs are
      // available — multiPv=1 cloud entries never trigger Great.
      final isOnlyWinningMove = _isOnlyWinningMove(
        bestCp: beforeEval?.scoreCp,
        bestMate: beforeEval?.mateIn,
        secondCp: beforeEval?.secondBestCp,
        secondMate: beforeEval?.secondBestMate,
        isWhiteMove: entry.isWhiteMove,
      );

      final result = _analyzer.analyze(
        prevCp: beforeEval?.scoreCp,
        prevMate: beforeEval?.mateIn,
        currCp: currCpWhite,
        currMate: currMateWhite,
        isWhiteMove: entry.isWhiteMove,
        engineBestMoveUci: beforeEval?.bestMoveUci,
        playedMoveUci: entry.uci,
        isSacrifice: sac.isSacrifice,
        isTrivialRecapture: sac.isTrivialRecapture,
        isFirstSacrificePly: sac.isFirstSacrificePly,
        isOnlyWinningMove: isOnlyWinningMove,
        // Cloud analyser also gets the Lichess opening name + ECO when the
        // book layer surfaced one, so the classifier message reads as
        // "· ECO • Opening Name" instead of a bare classification.
        openingName: openingInfo.openingName,
        ecoCode: openingInfo.ecoCode,
      );

      // Resolve engine best move to SAN if available.
      String? engineBestSan;
      if (beforeEval?.bestMoveUci != null) {
        engineBestSan =
            _tryUciToSan(entry.fenBefore, beforeEval!.bestMoveUci!);
      }

      // Coach message.
      String msg = result.message;
      if (openingInfo.isDeviation && openingInfo.openingName != null) {
        msg =
            '⚠️ Deviation from ${openingInfo.openingName} — $msg';
      }

      moves.add(MoveAnalysis(
        ply: ply,
        san: entry.san,
        uci: entry.uci,
        fenBefore: entry.fenBefore,
        fenAfter: entry.fenAfter,
        targetSquare: entry.targetSquare,
        winPercentBefore: prevWinPct,
        winPercentAfter: winPctAfter,
        deltaW: result.deltaW,
        classification: result.quality,
        isWhiteMove: entry.isWhiteMove,
        engineBestMoveSan: engineBestSan,
        openingName: openingInfo.openingName,
        ecoCode: openingInfo.ecoCode,
        inBook: false,
        message: msg,
      ));

      prevWinPct = winPctAfter;
      onProgress?.call(ply + 1, totalPlies);
    }

    // Build winPercentages array from analyzed moves.
    final winPercentages = moves.map((m) => m.winPercentAfter).toList();

    final timeline = AnalysisTimeline(
      moves: moves,
      startingFen: startingFen,
      headers: headers,
      winPercentages: winPercentages,
    );
    // Phase A integration audit, step A: structured per-ply log so
    // future regressions can be triaged from a single device-log dump.
    AnalysisDebugExport.dump(timeline, tag: 'cloud');
    return timeline;
  }

  /// Creates a neutral move when cloud eval is unavailable for a position.
  MoveAnalysis _neutralMove(
    int ply,
    _ParsedMove entry,
    double prevWinPct,
    OpeningInfo openingInfo,
  ) {
    return MoveAnalysis(
      ply: ply,
      san: entry.san,
      uci: entry.uci,
      fenBefore: entry.fenBefore,
      fenAfter: entry.fenAfter,
      targetSquare: entry.targetSquare,
      winPercentBefore: prevWinPct,
      winPercentAfter: prevWinPct,
      deltaW: 0.0,
      classification: MoveQuality.good,
      isWhiteMove: entry.isWhiteMove,
      openingName: openingInfo.openingName,
      ecoCode: openingInfo.ecoCode,
      inBook: false,
      message: '☁️ Position not in cloud database.',
    );
  }

  /// Attempts to convert a UCI move to SAN using dartchess.
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

  static String _sqAlg(Square sq) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + sq.file);
    return '$file${sq.rank + 1}';
  }

  static String _roleChar(Role role) => switch (role) {
        Role.queen => 'q',
        Role.rook => 'r',
        Role.bishop => 'b',
        Role.knight => 'n',
        _ => '',
      };

  /// Lichess "Only Move" / Apex *Great* heuristic: the gap between PV[0]
  /// and PV[1] is large enough that picking anything other than the
  /// engine's #1 drops the mover by ≥12 Win%. Returns false when either
  /// score is missing or when the position only carries a single PV.
  static bool _isOnlyWinningMove({
    int? bestCp,
    int? bestMate,
    int? secondCp,
    int? secondMate,
    required bool isWhiteMove,
  }) {
    if (secondCp == null && secondMate == null) return false;
    final wBest =
        EvaluationAnalyzer.calculateWinPercentage(cp: bestCp, mate: bestMate);
    final wSecond = EvaluationAnalyzer.calculateWinPercentage(
        cp: secondCp, mate: secondMate);
    final s = isWhiteMove ? 1.0 : -1.0;
    final gap = (wBest - wSecond) * s;
    return gap >= 12.0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal
// ─────────────────────────────────────────────────────────────────────────────

class _ParsedMove {
  final String fenBefore;
  final String fenAfter;
  final String san;
  final String uci;
  final String targetSquare;
  final bool isWhiteMove;

  const _ParsedMove({
    required this.fenBefore,
    required this.fenAfter,
    required this.san,
    required this.uci,
    required this.targetSquare,
    required this.isWhiteMove,
  });
}
