/// Isolate worker that owns the FFI handle and drives engine I/O.
///
/// Lives in its own file so the public engine stays free of `dart:ffi`
/// plumbing and so the entrypoint can be referenced by [Isolate.spawn]
/// without dragging the rest of the app into the worker closure.
///
/// ### Threading model
///
/// A single dedicated isolate owns the engine handle. Two cooperating loops
/// run on its event loop:
///
///   * A [ReceivePort] listener drains [_WriteCommand] messages from the UI
///     isolate and serializes them onto `stockfish_write`.
///   * A periodic [Timer] drains lines from `stockfish_read_line` using a
///     **non-blocking** `timeout_ms = 0` call and forwards them back to the
///     UI isolate as raw `String`s.
///
/// Polling (instead of a blocking read) keeps the isolate's Dart event loop
/// responsive so writes and reads never deadlock each other, and the native
/// bridge's line queue already buffers any burst of engine output between
/// polls so nothing is ever dropped.
library;

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'stockfish_bindings.dart';
import 'stockfish_library.dart';

/// Poll interval for draining engine output. Small enough to feel instant in
/// a search (hundreds of `info` lines per second) and large enough to stay
/// well under 1% CPU at idle.
const Duration _readPollInterval = Duration(milliseconds: 4);

/// Message sent from the main isolate to the worker.
sealed class _WorkerCommand {
  const _WorkerCommand();
}

class _WriteCommand extends _WorkerCommand {
  const _WriteCommand(this.line);
  final String line;
}

class _ShutdownCommand extends _WorkerCommand {
  const _ShutdownCommand();
}

/// Seed payload for [Isolate.spawn].
class StockfishIsolateInit {
  const StockfishIsolateInit({required this.mainSendPort});
  final SendPort mainSendPort;
}

/// Handshake message the worker sends back as its first frame so the main
/// isolate can start pushing commands.
class StockfishIsolateReady {
  const StockfishIsolateReady({
    required this.commandSendPort,
    required this.bridgeVersion,
  });
  final SendPort commandSendPort;
  final String bridgeVersion;
}

/// Fatal error frame emitted by the worker before it exits.
class StockfishIsolateError {
  const StockfishIsolateError(this.message);
  final String message;
  @override
  String toString() => 'StockfishIsolateError($message)';
}

/// Signals the worker is about to exit after a shutdown request.
class StockfishIsolateClosed {
  const StockfishIsolateClosed();
}

/// Entrypoint for [Isolate.spawn].
Future<void> stockfishIsolateEntry(StockfishIsolateInit init) async {
  final StockfishBindings bindings;
  final Pointer<SfEngine> handle;

  try {
    bindings = StockfishBindings(openStockfishBridge());
    handle = bindings.create();
    if (handle == nullptr) {
      init.mainSendPort.send(
        const StockfishIsolateError('stockfish_create returned null'),
      );
      return;
    }
  } on Object catch (e) {
    init.mainSendPort.send(StockfishIsolateError('bridge open failed: $e'));
    return;
  }

  final commandPort = ReceivePort();
  final shutdownCompleter = Completer<void>();

  final versionPtr = bindings.version();
  final version =
      versionPtr == nullptr ? 'unknown' : versionPtr.toDartString();

  init.mainSendPort.send(
    StockfishIsolateReady(
      commandSendPort: commandPort.sendPort,
      bridgeVersion: version,
    ),
  );

  // Drain native output using a non-blocking poll. See class-level docs for
  // why we prefer this over a blocking readLine(-1).
  final readTimer = Timer.periodic(_readPollInterval, (_) {
    // Drain everything available this tick so bursty output (typical during
    // deep searches) doesn't back up behind the poll cadence.
    while (true) {
      final linePtr = bindings.readLine(handle, 0);
      if (linePtr == nullptr) break;
      try {
        init.mainSendPort.send(linePtr.toDartString());
      } finally {
        bindings.freeString(linePtr);
      }
    }
  });

  commandPort.listen((dynamic msg) {
    if (msg is! _WorkerCommand) return;
    switch (msg) {
      case _WriteCommand(:final line):
        final utf = line.toNativeUtf8();
        try {
          bindings.write(handle, utf);
        } finally {
          malloc.free(utf);
        }
      case _ShutdownCommand():
        if (!shutdownCompleter.isCompleted) shutdownCompleter.complete();
    }
  });

  await shutdownCompleter.future;

  readTimer.cancel();
  commandPort.close();

  // Send `stop` before destroy so any in-flight `go` search returns to
  // the UCI prompt before Stockfish's ThreadPool teardown runs. Without
  // this, the native bridge's `quit` lands while search workers are
  // still spinning, and the workers race with their own pool's mutex
  // destruction (the destroyed-mutex SIGABRT).
  final stopUtf = 'stop'.toNativeUtf8();
  try {
    bindings.write(handle, stopUtf);
  } finally {
    malloc.free(stopUtf);
  }

  // `destroy` sends `quit`, joins the native worker thread, and frees the
  // handle. Safe to run on this isolate because we've already stopped both
  // loops above.
  bindings.destroy(handle);

  init.mainSendPort.send(const StockfishIsolateClosed());
}

// Typed helpers so the main isolate doesn't need to know the private
// message shapes above.

/// Send a UCI command line to the worker.
void sendWriteCommand(SendPort port, String line) {
  port.send(_WriteCommand(line));
}

/// Tell the worker to tear itself down.
void sendShutdownCommand(SendPort port) {
  port.send(const _ShutdownCommand());
}
