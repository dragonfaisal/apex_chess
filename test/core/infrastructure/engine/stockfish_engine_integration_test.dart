// Integration test for the full StockfishEngine pipeline.
//
// Skipped unless the native stub library is on the loader's search path.
// To run it locally:
//
//   cmake -S src/native -B build/native
//   cmake --build build/native
//   LD_LIBRARY_PATH=build/native flutter test \
//     test/core/infrastructure/engine/stockfish_engine_integration_test.dart
//
// On Windows / macOS adjust the env var (PATH / DYLD_LIBRARY_PATH) accordingly.

@TestOn('vm')
library;

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:apex_chess/core/infrastructure/engine/engine.dart';
import 'package:flutter_test/flutter_test.dart';

bool _bridgeAvailable() {
  try {
    if (Platform.isLinux || Platform.isAndroid) {
      DynamicLibrary.open('libstockfish_bridge.so');
    } else if (Platform.isWindows) {
      DynamicLibrary.open('stockfish_bridge.dll');
    } else if (Platform.isMacOS || Platform.isIOS) {
      DynamicLibrary.process().lookup('stockfish_create');
    } else {
      return false;
    }
    return true;
  } on Object {
    return false;
  }
}

void main() {
  final skipReason = _bridgeAvailable()
      ? null
      : 'libstockfish_bridge not on loader path — see test comments.';

  group(
    'StockfishEngine (stub pipeline)',
    skip: skipReason,
    () {
      test('handshake surfaces id + uciok', () async {
        final engine = StockfishEngine();
        await engine.start();

        final events = <EngineEvent>[];
        final sub = engine.events.listen(events.add);

        engine.send(const UciHandshake());

        final deadline = DateTime.now().add(const Duration(seconds: 2));
        while (!events.any((e) => e is EngineUciOk) &&
            DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }

        expect(events.whereType<EngineUciOk>(), isNotEmpty);
        expect(events.whereType<EngineId>(), isNotEmpty);

        await sub.cancel();
        await engine.dispose();
      });

      test('go depth yields at least one info and a bestmove', () async {
        final engine = StockfishEngine();
        await engine.start();

        final bestMoveCompleter = Completer<EngineBestMove>();
        var sawInfo = false;

        final sub = engine.events.listen((event) {
          if (event is EngineInfo) sawInfo = true;
          if (event is EngineBestMove && !bestMoveCompleter.isCompleted) {
            bestMoveCompleter.complete(event);
          }
        });

        engine.send(const UciIsReady());
        engine.send(const UciNewGame());
        engine.send(const UciPosition.startpos());
        engine.send(const UciGo.depth(6));

        final best = await bestMoveCompleter.future.timeout(
          const Duration(seconds: 3),
        );

        expect(best.move, isNotEmpty);
        expect(sawInfo, isTrue);

        await sub.cancel();
        await engine.dispose();
      });
    },
  );
}
