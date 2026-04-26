// Regression test for the destroyed-mutex SIGABRT.
//
// The previous bridge called `stockfish_main()` once per sf_engine handle;
// that meant every `StockfishEngine().start() / dispose()` cycle re-ran
// Stockfish's static `Threads.set(...)` initialiser, which on Android
// re-destroyed per-worker `std::mutex`es while workers were still
// pthread_mutex_lock-ing them:
//
//     F/libc: FORTIFY: pthread_mutex_lock called on a destroyed mutex
//     Fatal signal 6 (SIGABRT)
//
// The bridge now keeps a process-persistent engine worker and `destroy`
// only releases a session gate. This test spins up and tears down the
// engine 5 times in-process so that, pre-fix, it would deterministically
// SIGABRT on iteration 2+ under the real engine, and at minimum surface
// any regression in the stub's session-gate + `ucinewgame` reset path.
//
// Skipped unless the native stub library is on the loader's search path.
// To run it locally:
//
//   cmake -S src/native -B build/native
//   cmake --build build/native
//   LD_LIBRARY_PATH=build/native flutter test \
//     test/core/infrastructure/engine/stockfish_engine_lifecycle_test.dart

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
    'StockfishEngine lifecycle regression',
    skip: skipReason,
    () {
      test('5x create + dispose cycles without crash or handshake drift',
          () async {
        for (var i = 0; i < 5; i++) {
          final engine = StockfishEngine();
          await engine.start();

          final uciOkCompleter = Completer<void>();
          final bestMoveCompleter = Completer<EngineBestMove>();

          final sub = engine.events.listen((event) {
            if (event is EngineUciOk && !uciOkCompleter.isCompleted) {
              uciOkCompleter.complete();
            }
            if (event is EngineBestMove && !bestMoveCompleter.isCompleted) {
              bestMoveCompleter.complete(event);
            }
          });

          engine.send(const UciHandshake());
          await uciOkCompleter.future.timeout(
            const Duration(seconds: 3),
            onTimeout: () => fail(
              'cycle $i: no uciok received — session gate likely '
              'cross-contaminated between engines',
            ),
          );

          engine.send(const UciIsReady());
          engine.send(const UciNewGame());
          engine.send(const UciPosition.startpos());
          engine.send(const UciGo.depth(4));

          final best = await bestMoveCompleter.future.timeout(
            const Duration(seconds: 3),
            onTimeout: () => fail('cycle $i: no bestmove received'),
          );
          expect(best.move, isNotEmpty, reason: 'cycle $i: empty bestmove');

          await sub.cancel();
          await engine.dispose();
        }
      });
    },
  );
}
