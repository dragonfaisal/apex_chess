/// Full-game analyzer backed by the on-device Apex AI Analyst.
///
/// Drop-in replacement for [CloudGameAnalyzer] — same public contract
/// (`analyzeFromPgn` + `onProgress`) and the same `AnalysisTimeline` return
/// type so the Review pipeline does not care whether analysis came from
/// Lichess or from local Stockfish.
///
/// Opening-book detection has been dropped from this path because it was
/// implemented via the Lichess Opening Explorer — all analysis is now
/// engine-evaluated. A move that would have been classified as "Book" is
/// now classified by the engine's delta Win% like any other move.
library;

import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/infrastructure/api/cloud_eval_service.dart'
    show CloudEvalError;
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';

/// Exception used to surface user-facing errors to the home / review UI.
/// The UI already handles `CloudAnalysisException`, so we reuse the same
/// shape by name to avoid churning the dialog code. The underlying error
/// values now describe engine failures rather than HTTP errors.
class LocalAnalysisException implements Exception {
  const LocalAnalysisException(this.message);

  final String message;

  @override
  String toString() => 'LocalAnalysisException: $message';

  String get userMessage => message;
}

class LocalGameAnalyzer {
  LocalGameAnalyzer({
    required LocalEvalService eval,
    EvaluationAnalyzer analyzer = const EvaluationAnalyzer(),
    int depth = 12,
  })  : _eval = eval,
        _analyzer = analyzer,
        _depth = depth;

  final LocalEvalService _eval;
  final EvaluationAnalyzer _analyzer;
  final int _depth;

  Future<AnalysisTimeline> analyzeFromPgn(
    String pgn, {
    void Function(int completed, int total)? onProgress,
  }) async {
    final game = PgnGame.parsePgn(pgn);
    final headers = Map<String, String>.from(game.headers);
    Position position = PgnGame.startingPosition(game.headers);
    final startingFen = position.fen;

    final parsed = <_ParsedMove>[];
    for (final node in game.moves.mainline()) {
      final move = position.parseSan(node.san);
      if (move == null) break;
      final fenBefore = position.fen;
      final isWhite = position.turn == Side.white;
      final newPos = position.play(move);
      String uci;
      if (move is NormalMove) {
        uci = '${_sqAlg(move.from)}${_sqAlg(move.to)}'
            '${move.promotion != null ? _roleChar(move.promotion!) : ""}';
      } else {
        uci = node.san;
      }
      parsed.add(_ParsedMove(
        fenBefore: fenBefore,
        fenAfter: newPos.fen,
        san: node.san,
        uci: uci,
        isWhiteMove: isWhite,
      ));
      position = newPos;
    }

    final totalPlies = parsed.length;
    onProgress?.call(0, totalPlies);

    // Seed the starting-position Win% from the engine's opening eval.
    final (startEval, startErr) = await _eval.evaluate(startingFen, depth: _depth);
    if (startErr != null && startErr != CloudEvalError.positionNotFound) {
      throw const LocalAnalysisException(
          'Apex AI Analyst failed to initialise.');
    }
    double prevWinPct = startEval != null
        ? EvaluationAnalyzer.calculateWinPercentage(
            cp: startEval.scoreCp, mate: startEval.mateIn)
        : 50.0;

    final moves = <MoveAnalysis>[];

    for (var ply = 0; ply < totalPlies; ply++) {
      final entry = parsed[ply];

      // One search per ply — the `bestMove` from the "before" search is the
      // engine's recommendation; the Win% delta uses the "after" search.
      final (before, beforeErr) =
          await _eval.evaluate(entry.fenBefore, depth: _depth);
      final (after, afterErr) =
          await _eval.evaluate(entry.fenAfter, depth: _depth);

      if (beforeErr != null && beforeErr != CloudEvalError.positionNotFound) {
        throw const LocalAnalysisException(
            'Quantum Scan failed — engine stopped responding.');
      }
      if (afterErr != null && afterErr != CloudEvalError.positionNotFound) {
        throw const LocalAnalysisException(
            'Quantum Scan failed — engine stopped responding.');
      }

      final winPctAfter = after != null
          ? EvaluationAnalyzer.calculateWinPercentage(
              cp: after.scoreCp, mate: after.mateIn)
          : prevWinPct;

      final result = _analyzer.analyze(
        prevCp: before?.scoreCp,
        prevMate: before?.mateIn,
        currCp: after?.scoreCp,
        currMate: after?.mateIn,
        isWhiteMove: entry.isWhiteMove,
        engineBestMoveUci: before?.bestMoveUci,
        playedMoveUci: entry.uci,
      );

      String? engineBestSan;
      if (before?.bestMoveUci != null) {
        engineBestSan = _tryUciToSan(entry.fenBefore, before!.bestMoveUci!);
      }

      moves.add(MoveAnalysis(
        ply: ply,
        san: entry.san,
        uci: entry.uci,
        fenBefore: entry.fenBefore,
        fenAfter: entry.fenAfter,
        winPercentBefore: prevWinPct,
        winPercentAfter: winPctAfter,
        deltaW: result.deltaW,
        classification: result.quality,
        isWhiteMove: entry.isWhiteMove,
        engineBestMoveSan: engineBestSan,
        engineBestMoveUci: before?.bestMoveUci,
        scoreCpAfter: after?.scoreCp,
        mateInAfter: after?.mateIn,
        inBook: false,
        message: result.message,
      ));

      prevWinPct = winPctAfter;
      onProgress?.call(ply + 1, totalPlies);
    }

    final winPercentages = moves.map((m) => m.winPercentAfter).toList();
    return AnalysisTimeline(
      moves: moves,
      startingFen: startingFen,
      headers: headers,
      winPercentages: winPercentages,
    );
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
}

class _ParsedMove {
  const _ParsedMove({
    required this.fenBefore,
    required this.fenAfter,
    required this.san,
    required this.uci,
    required this.isWhiteMove,
  });

  final String fenBefore;
  final String fenAfter;
  final String san;
  final String uci;
  final bool isWhiteMove;
}
