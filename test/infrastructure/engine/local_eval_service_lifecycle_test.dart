import 'dart:async';

import 'package:apex_chess/core/infrastructure/engine/chess_engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_command.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/uci_event.dart';
import 'package:apex_chess/infrastructure/api/cloud_eval_service.dart'
    show CloudEvalError;
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const startFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
  const afterE4Fen =
      'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';

  group('LocalEvalService lifecycle substrate', () {
    test(
      'serializes repeated FEN analyses without overlapping searches',
      () async {
        final engine = _LifecycleFakeEngine(
          searchDelay: const Duration(milliseconds: 10),
        );
        final service = LocalEvalService(engine: engine);

        final first = service.evaluate(
          startFen,
          depth: 8,
          timeout: const Duration(seconds: 1),
        );
        final second = service.evaluate(
          afterE4Fen,
          depth: 8,
          timeout: const Duration(seconds: 1),
        );

        final results = await Future.wait([first, second]);

        expect(results.map((r) => r.$2), everyElement(isNull));
        expect(engine.startCount, 1);
        expect(engine.overlapDetected, isFalse);
        expect(engine.commands.whereType<UciPosition>(), hasLength(2));
        expect(engine.commands.whereType<UciGo>(), hasLength(2));
      },
    );

    test(
      'invalid FEN is rejected before starting or sending to engine',
      () async {
        final engine = _LifecycleFakeEngine();
        final service = LocalEvalService(engine: engine);

        final (snapshot, error) = await service.evaluate(
          '8/8/8/8/8/8/8',
          timeout: const Duration(milliseconds: 50),
        );

        expect(snapshot, isNull);
        expect(error, CloudEvalError.positionNotFound);
        expect(engine.startCount, 0);
        expect(engine.commands, isEmpty);
      },
    );

    test('search timeout returns a safe failure and sends stop', () async {
      final engine = _LifecycleFakeEngine(emitBestMove: false);
      final service = LocalEvalService(engine: engine);

      final (snapshot, error) = await service.evaluate(
        startFen,
        depth: 8,
        timeout: const Duration(milliseconds: 30),
      );

      expect(snapshot, isNull);
      expect(error, CloudEvalError.serverError);
      expect(engine.commands.whereType<UciStop>(), isNotEmpty);
      expect(engine.overlapDetected, isFalse);
    });

    test(
      'repeated start ready stop and dispose path remains idempotent',
      () async {
        final engine = _LifecycleFakeEngine();
        final service = LocalEvalService(engine: engine);

        for (var i = 0; i < 3; i++) {
          final (snapshot, error) = await service.evaluate(
            startFen,
            depth: 6,
            timeout: const Duration(seconds: 1),
          );
          expect(error, isNull);
          expect(snapshot, isNotNull);
        }

        engine.stop();
        await engine.dispose();
        await engine.dispose();

        expect(engine.disposeCount, 2);
        expect(engine.commands.whereType<UciIsReady>(), isNotEmpty);
        expect(engine.commands.whereType<UciStop>(), isNotEmpty);
      },
    );
  });
}

class _LifecycleFakeEngine implements ChessEngine {
  _LifecycleFakeEngine({
    this.emitBestMove = true,
    this.searchDelay = Duration.zero,
  });

  final bool emitBestMove;
  final Duration searchDelay;
  final commands = <UciCommand>[];
  final _events = StreamController<EngineEvent>.broadcast();

  var startCount = 0;
  var disposeCount = 0;
  var searchInFlight = false;
  var overlapDetected = false;

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  String get bridgeVersion => 'fake-lifecycle';

  @override
  bool isRunning = false;

  @override
  Future<void> start() async {
    startCount++;
    isRunning = true;
  }

  @override
  void send(UciCommand command) {
    commands.add(command);
    if (command is UciIsReady) {
      scheduleMicrotask(() => _events.add(const EngineReadyOk()));
    } else if (command is UciGo) {
      if (searchInFlight) overlapDetected = true;
      searchInFlight = true;
      if (emitBestMove) {
        Future<void>.delayed(searchDelay, () {
          if (_events.isClosed) return;
          _events
            ..add(
              const EngineInfo(
                depth: 8,
                multipv: 1,
                scoreCp: 20,
                nodes: 1000,
                nps: 2000,
                pv: ['e2e4', 'e7e5'],
              ),
            )
            ..add(const EngineBestMove(move: 'e2e4'));
          searchInFlight = false;
        });
      }
    } else if (command is UciStop) {
      searchInFlight = false;
    }
  }

  @override
  void sendRaw(String line) => send(UciRaw(line));

  @override
  void stop() => send(const UciStop());

  @override
  Future<void> dispose() async {
    disposeCount++;
    isRunning = false;
    if (!_events.isClosed) await _events.close();
  }
}
