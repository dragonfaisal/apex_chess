import 'dart:async';
import 'dart:convert';

import 'package:dartchess/dartchess.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/analysis_debug_export.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/infrastructure/engine/eco_book.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bookTsv = 'eco\tname\tpgn\nB00\tKing\'s Pawn Opening\t1. e4\n';
  const regressionPgn = '''
[Event "DrePlayerNZ vs. ALFAISALpro"]
[Site "Chess.com"]
[Date "2025-10-21"]
[White "DrePlayerNZ"]
[Black "ALFAISALpro"]
[Result "0-1"]
[WhiteElo "559"]
[BlackElo "553"]
[TimeControl "180"]
[Termination "ALFAISALpro won by checkmate"]
1. Nf3 Nf6 2. d4 d5 3. Bg5 h6 4. Bh4 Bg4 5. Ne5 Qd6 6. Bg3 Ne4 7. Nxg4 Qb4+ 8.
Nd2 e5 9. c3 Qxb2 10. Nxe4 exd4 11. Nd2 dxc3 12. Nb3 c2 13. Qd2 Bb4 14. Qxb4
Qxa1+ 15. Nxa1 c1=Q# 0-1
''';

  group('LocalGameAnalyzer Phase A', () {
    test(
      'confirmed book is theory; unknown early move is opening phase',
      () async {
        final eval = _ScriptedEvalService();
        final analyzer = LocalGameAnalyzer(
          eval: eval,
          book: EcoBook.fromTsv(bookTsv),
        );

        final timeline = await analyzer.analyzeFromPgn(
          '[Result "*"]\n\n1. a3 *',
          mode: AnalysisMode.deep,
          depth: 12,
        );

        expect(timeline.moves, hasLength(1));
        expect(timeline.moves.first.inBook, isFalse);
        expect(
          timeline.moves.first.openingStatus,
          OpeningStatus.openingPhaseUnknown,
        );
        expect(timeline.moves.first.classification, isNot(MoveQuality.book));
        expect(eval.calls.map((c) => c.multiPv).toSet(), {3});
      },
    );

    test(
      'known theory is book; unknown reply from book position is deviation',
      () async {
        final eval = _ScriptedEvalService();
        final analyzer = LocalGameAnalyzer(
          eval: eval,
          book: EcoBook.fromTsv(bookTsv),
        );

        final timeline = await analyzer.analyzeFromPgn(
          '[Result "*"]\n\n1. e4 h5 *',
          mode: AnalysisMode.deep,
          depth: 12,
        );

        expect(timeline.moves, hasLength(2));
        expect(timeline.moves[0].classification, MoveQuality.book);
        expect(timeline.moves[0].openingStatus, OpeningStatus.bookTheory);
        expect(timeline.moves[0].inBook, isTrue);

        expect(timeline.moves[1].classification, isNot(MoveQuality.book));
        expect(timeline.moves[1].openingStatus, OpeningStatus.bookDeviation);
        expect(timeline.moves[1].inBook, isFalse);
        expect(timeline.moves[1].engineLines, hasLength(3));
        expect(eval.calls.map((c) => c.multiPv).toSet(), {3});
      },
    );

    test('Quick analysis keeps local eval single-PV', () async {
      final eval = _ScriptedEvalService();
      final analyzer = LocalGameAnalyzer(
        eval: eval,
        book: EcoBook.fromTsv(bookTsv),
      );

      await analyzer.analyzeFromPgn(
        '[Result "*"]\n\n1. a3 *',
        mode: AnalysisMode.quick,
        depth: 10,
      );

      expect(eval.calls.map((c) => c.multiPv).toSet(), {1});
    });

    test(
      'supplied PGN keeps 11...dxc3 out of Forced and mate is sane',
      () async {
        final fixture = _fixtureMoves(regressionPgn);
        final eval = _PgnFixtureEvalService(fixture);
        final analyzer = LocalGameAnalyzer(
          eval: eval,
          book: EcoBook.fromTsv('eco\tname\tpgn\n'),
        );

        final timeline = await analyzer.analyzeFromPgn(
          regressionPgn,
          mode: AnalysisMode.deep,
          depth: 12,
        );

        final dxc3 = timeline.moves.singleWhere((m) => m.san == 'dxc3');
        expect(dxc3.uci, 'd4c3');
        expect(dxc3.classification, isNot(MoveQuality.forced));
        expect(dxc3.classification, isNot(MoveQuality.great));
        expect(
          dxc3.classification,
          anyOf(MoveQuality.best, MoveQuality.excellent),
        );
        expect(dxc3.playedEqualsPv1, isTrue);
        expect(dxc3.isFreeCapture, isTrue);

        final bestCount = timeline.moves
            .where((m) => m.classification == MoveQuality.best)
            .length;
        expect(bestCount, greaterThan(0));

        final mate = timeline.moves.singleWhere((m) => m.san == 'c1=Q#');
        expect(mate.classification, isNot(MoveQuality.blunder));
        expect(mate.isWhiteMove, isFalse);

        final debugLine = AnalysisDebugExport.jsonLines(timeline)
            .split('\n')
            .map((line) => jsonDecode(line) as Map<String, dynamic>)
            .singleWhere((j) => j['san'] == 'dxc3');
        expect(debugLine['baseClassification'], isNotNull);
        expect(debugLine['finalClassification'], isNotNull);
        expect(debugLine['reasonCode'], isNot('only_defense'));
        expect(debugLine['pv1'], isNotNull);
        expect(debugLine['pv2'], isNotNull);
        expect(debugLine['pv3'], isNotNull);
        expect(debugLine['isFreeCapture'], isTrue);
      },
    );
  });
}

class _ScriptedEvalService extends LocalEvalService {
  _ScriptedEvalService() : super(engine: _NoopChessEngine());

  final calls = <_EvalCall>[];
  static const _win = WinPercentCalculator();

  @override
  Future<(EvalSnapshot?, EvalError?)> evaluate(
    String fen, {
    int? depth,
    Duration? movetime,
    Duration? timeout,
    int multiPv = 1,
  }) async {
    calls.add(_EvalCall(fen: fen, multiPv: multiPv));
    final whiteToMove = fen.split(' ').length > 1 && fen.split(' ')[1] == 'w';
    final primaryMove = whiteToMove ? 'g1f3' : 'e7e5';
    final score = whiteToMove ? 30 : 20;
    final requested = multiPv.clamp(1, 3).toInt();
    final candidates = whiteToMove
        ? const [('g1f3', 'Nf3', 30), ('d2d4', 'd4', 10), ('b1c3', 'Nc3', 0)]
        : const [('e7e5', 'e5', 20), ('c7c5', 'c5', 5), ('e7e6', 'e6', -5)];
    final lines = <EngineLine>[
      for (var i = 0; i < requested; i++)
        EngineLine(
          rank: i + 1,
          moveUci: candidates[i].$1,
          moveSan: candidates[i].$2,
          scoreCp: candidates[i].$3,
          depth: depth ?? 12,
          whiteWinPercent: _win.forCp(cp: candidates[i].$3),
          pvMoves: [candidates[i].$1],
        ),
    ];
    return (
      EvalSnapshot(
        scoreCp: score,
        depth: depth ?? 12,
        bestMoveUci: primaryMove,
        pvMoves: [primaryMove],
        engineLines: lines,
        secondBestCp: lines.length >= 2 ? lines[1].scoreCp : null,
      ),
      null,
    );
  }
}

class _PgnFixtureEvalService extends LocalEvalService {
  _PgnFixtureEvalService(this.moves) : super(engine: _NoopChessEngine()) {
    for (final move in moves) {
      bestByFen[move.fenBefore] = move.uci;
      sanByFen[move.fenBefore] = move.san;
      scoreByFen.putIfAbsent(move.fenBefore, () => 0);
      scoreByFen.putIfAbsent(move.fenAfter, () => 0);
    }
    final dxc3 = moves.singleWhere((m) => m.san == 'dxc3');
    scoreByFen[dxc3.fenBefore] = -200;
    scoreByFen[dxc3.fenAfter] = -260;
    final mate = moves.singleWhere((m) => m.san == 'c1=Q#');
    scoreByFen[mate.fenBefore] = -900;
  }

  final List<_FixtureMove> moves;
  final bestByFen = <String, String>{};
  final sanByFen = <String, String>{};
  final scoreByFen = <String, int>{};
  static const _win = WinPercentCalculator();

  @override
  Future<(EvalSnapshot?, EvalError?)> evaluate(
    String fen, {
    int? depth,
    Duration? movetime,
    Duration? timeout,
    int multiPv = 1,
  }) async {
    final requested = multiPv.clamp(1, 3).toInt();
    final best = bestByFen[fen] ?? _fallbackMove(fen);
    final score = scoreByFen[fen] ?? 0;
    final isDxc3Before = moves.any(
      (m) => m.san == 'dxc3' && m.fenBefore == fen,
    );
    final altScores = isDxc3Before
        ? const <int>[-200, 200, 300]
        : <int>[score, score - 5, score + 5];
    final altMoves = <String>[
      best,
      _alternateMove(fen, best, 0),
      _alternateMove(fen, best, 1),
    ];
    final lines = <EngineLine>[
      for (var i = 0; i < requested; i++)
        EngineLine(
          rank: i + 1,
          moveUci: altMoves[i],
          moveSan: i == 0 ? sanByFen[fen] : null,
          scoreCp: altScores[i],
          depth: depth ?? 12,
          whiteWinPercent: _win.forCp(cp: altScores[i]),
          pvMoves: [altMoves[i]],
        ),
    ];
    return (
      EvalSnapshot(
        scoreCp: score,
        depth: depth ?? 12,
        bestMoveUci: best,
        pvMoves: [best],
        secondBestCp: lines.length >= 2 ? lines[1].scoreCp : null,
        engineLines: lines,
      ),
      null,
    );
  }

  String _fallbackMove(String fen) =>
      fen.split(' ')[1] == 'w' ? 'g1f3' : 'e7e5';

  String _alternateMove(String fen, String best, int index) {
    final white = fen.split(' ')[1] == 'w';
    final candidates = white
        ? const ['d2d4', 'e2e4', 'b1c3', 'g2g3']
        : const ['d7d5', 'e7e5', 'c7c5', 'g7g6'];
    return candidates.firstWhere(
      (m) => m != best,
      orElse: () => candidates[index],
    );
  }
}

List<_FixtureMove> _fixtureMoves(String pgn) {
  final game = PgnGame.parsePgn(pgn);
  Position position = PgnGame.startingPosition(game.headers);
  final out = <_FixtureMove>[];
  for (final node in game.moves.mainline()) {
    final move = position.parseSan(node.san);
    if (move == null) break;
    final fenBefore = position.fen;
    final next = position.play(move);
    var uci = '';
    if (move is NormalMove) {
      final raw =
          '${_sqAlg(move.from)}${_sqAlg(move.to)}'
          '${move.promotion != null ? _roleChar(move.promotion!) : ""}';
      uci = normalizeCastlingUci(raw);
    }
    out.add(
      _FixtureMove(
        san: node.san,
        uci: uci,
        fenBefore: fenBefore,
        fenAfter: next.fen,
      ),
    );
    position = next;
  }
  return out;
}

class _FixtureMove {
  const _FixtureMove({
    required this.san,
    required this.uci,
    required this.fenBefore,
    required this.fenAfter,
  });

  final String san;
  final String uci;
  final String fenBefore;
  final String fenAfter;
}

String _sqAlg(Square sq) {
  final file = String.fromCharCode('a'.codeUnitAt(0) + sq.file);
  return '$file${sq.rank + 1}';
}

String _roleChar(Role role) => switch (role) {
  Role.queen => 'q',
  Role.rook => 'r',
  Role.bishop => 'b',
  Role.knight => 'n',
  _ => '',
};

class _EvalCall {
  const _EvalCall({required this.fen, required this.multiPv});
  final String fen;
  final int multiPv;
}

class _NoopChessEngine implements ChessEngine {
  final _events = StreamController<EngineEvent>.broadcast();

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  String get bridgeVersion => 'noop';

  @override
  bool get isRunning => true;

  @override
  Future<void> start() async {}

  @override
  void send(UciCommand command) {}

  @override
  void sendRaw(String line) {}

  @override
  void stop() {}

  @override
  Future<void> dispose() async {
    await _events.close();
  }
}
