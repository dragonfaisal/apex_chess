import 'dart:async';

import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const startFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

  group('LocalEvalService MultiPV', () {
    test('returns ranked PV1/PV2/PV3 engine lines with SAN and Win%', () async {
      final engine = _FakeChessEngine(
        bestMove: 'e2e4',
        infos: const [
          EngineInfo(depth: 12, multipv: 1, scoreCp: 30, pv: ['e2e4', 'e7e5']),
          EngineInfo(depth: 12, multipv: 2, scoreCp: 20, pv: ['d2d4', 'd7d5']),
          EngineInfo(depth: 12, multipv: 3, scoreCp: 10, pv: ['g1f3', 'g8f6']),
        ],
      );
      final service = LocalEvalService(engine: engine);

      final (snapshot, error) = await service.evaluate(
        startFen,
        depth: 12,
        multiPv: 3,
        timeout: const Duration(seconds: 1),
      );

      expect(error, isNull);
      expect(snapshot, isNotNull);
      expect(snapshot!.bestMoveUci, 'e2e4');
      expect(snapshot.secondBestCp, 20);
      expect(snapshot.engineLines, hasLength(3));
      expect(snapshot.engineLines.map((l) => l.rank), [1, 2, 3]);
      expect(snapshot.engineLines[0].moveUci, 'e2e4');
      expect(snapshot.engineLines[0].moveSan, 'e4');
      expect(snapshot.engineLines[1].moveUci, 'd2d4');
      expect(snapshot.engineLines[2].pvMoves, ['g1f3', 'g8f6']);
      expect(snapshot.engineLines[0].whiteWinPercent, greaterThan(50));
      expect(
        engine.commands.whereType<UciSetOption>().map((c) => c.toUci()),
        contains('setoption name MultiPV value 3'),
      );
    });

    test('normalizes black-to-move scores back to White POV', () async {
      const fenAfterE4 =
          'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';
      final engine = _FakeChessEngine(
        bestMove: 'e7e5',
        infos: const [
          EngineInfo(depth: 10, multipv: 1, scoreCp: 100, pv: ['e7e5']),
          EngineInfo(depth: 10, multipv: 2, scoreCp: 40, pv: ['c7c5']),
          EngineInfo(depth: 10, multipv: 3, scoreCp: -10, pv: ['e7e6']),
        ],
      );
      final service = LocalEvalService(engine: engine);

      final (snapshot, error) = await service.evaluate(
        fenAfterE4,
        depth: 10,
        multiPv: 3,
        timeout: const Duration(seconds: 1),
      );

      expect(error, isNull);
      expect(snapshot!.scoreCp, -100);
      expect(snapshot.secondBestCp, -40);
      expect(snapshot.engineLines[0].whiteWinPercent, lessThan(50));
      expect(snapshot.engineLines[0].moveSan, 'e5');
    });
  });
}

class _FakeChessEngine implements ChessEngine {
  _FakeChessEngine({required this.bestMove, required this.infos});

  final String bestMove;
  final List<EngineInfo> infos;
  final commands = <UciCommand>[];
  final _events = StreamController<EngineEvent>.broadcast();

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  String get bridgeVersion => 'fake';

  @override
  bool isRunning = false;

  @override
  Future<void> start() async {
    isRunning = true;
  }

  @override
  void send(UciCommand command) {
    commands.add(command);
    if (command is UciIsReady) {
      scheduleMicrotask(() => _events.add(const EngineReadyOk()));
    }
    if (command is UciGo) {
      scheduleMicrotask(() {
        for (final info in infos) {
          _events.add(info);
        }
        _events.add(EngineBestMove(move: bestMove));
      });
    }
  }

  @override
  void sendRaw(String line) => send(UciRaw(line));

  @override
  void stop() => send(const UciStop());

  @override
  Future<void> dispose() async {
    await _events.close();
    isRunning = false;
  }
}
