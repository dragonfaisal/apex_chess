import 'dart:async';

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
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
