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

/// Truncates a UCI command for inclusion in an error frame. UCI lines can
/// be very long (`info ... pv ... ... ...`) and the diagnostic only needs
/// enough to identify the command class.
String _redact(String line) {
  const max = 80;
  if (line.length <= max) return line;
  return '${line.substring(0, max)}…';
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
  //
  // Every native call is wrapped: a Dart-side exception in this timer would
  // otherwise propagate to the isolate's unhandled-error port and (because
  // `errorsAreFatal: true` on spawn) take the worker down with a SIGABRT in
  // the host's `DartWorker` thread. Logging + skipping a tick is always
  // safer than killing the engine session.
  final readTimer = Timer.periodic(_readPollInterval, (_) {
    while (true) {
      Pointer<Utf8> linePtr;
      try {
        linePtr = bindings.readLine(handle, 0);
      } on Object {
        // Native side is wedged or the handle is gone — let the next
        // shutdown drain take care of cleanup.
        return;
      }
      if (linePtr == nullptr) break;
      try {
        init.mainSendPort.send(linePtr.toDartString());
      } on Object {
        // Send port closed (host isolate disposed) — drop the line.
      } finally {
        try {
          bindings.freeString(linePtr);
        } on Object {
          // Best-effort free; nothing useful to do on failure.
        }
      }
    }
  });

  commandPort.listen((dynamic msg) {
    if (msg is! _WorkerCommand) return;
    switch (msg) {
      case _WriteCommand(:final line):
        // The host serialises every UCI command through this port. A
        // single bad write (e.g. a malformed FEN that Stockfish's UCI
        // parser doesn't tolerate) must NOT abort the worker — the
        // engine is process-persistent across sessions and we'd lose
        // every other isolate's view of it.
        Pointer<Utf8>? utf;
        try {
          utf = line.toNativeUtf8();
          bindings.write(handle, utf);
        } on Object {
          init.mainSendPort.send(StockfishIsolateError(
              'native write failed for line: ${_redact(line)}'));
        } finally {
          if (utf != null) {
            try {
              malloc.free(utf);
            } on Object {
              // Ignore free failure — the process will reclaim on exit.
            }
          }
        }
      case _ShutdownCommand():
        if (!shutdownCompleter.isCompleted) shutdownCompleter.complete();
    }
  });

  await shutdownCompleter.future;

  readTimer.cancel();
  commandPort.close();

  // `destroy` now just cancels any in-flight search and releases the
  // process-wide session gate — the native bridge intentionally keeps the
  // Stockfish worker / ThreadPool alive for the process lifetime (see
  // `src/native/stockfish_bridge.cpp`) because re-initialising the engine's
  // static ThreadPool was the root cause of the destroyed-mutex SIGABRT.
  // No pre-`stop` is needed here; the bridge sends one itself.
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
