/// Abstract interface for a UCI-speaking chess engine.
///
/// Consumers (feature modules, analyzers, providers) depend on this type so
/// the concrete engine — Stockfish today, something else tomorrow — can be
/// swapped without touching the rest of the app.
library;

import 'uci/uci_command.dart';
import 'uci/uci_event.dart';

/// Public surface of an in-process chess engine.
///
/// The contract is intentionally minimal: push commands, pull events, tear
/// it down. All implementations must be non-blocking with respect to the UI
/// isolate — every call on this interface must return in O(microseconds).
abstract interface class ChessEngine {
  /// Broadcast stream of parsed engine events.
  ///
  /// The stream is a **single-subscription** broadcast: listeners get every
  /// event from the moment they subscribe onward. The stream closes when the
  /// engine is disposed.
  Stream<EngineEvent> get events;

  /// Bridge/build identifier, populated after [start] completes. Mostly
  /// useful for telemetry and debug overlays.
  String get bridgeVersion;

  /// Whether the engine has been started and is ready to receive commands.
  bool get isRunning;

  /// Spawn the worker isolate, open the native bridge, and wait for the
  /// handshake. Must be called exactly once per instance.
  ///
  /// Throws [EngineStartupException] on any failure.
  Future<void> start();

  /// Enqueue a UCI command for the worker. Non-blocking; returns as soon as
  /// the command has been handed off to the worker's message port.
  void send(UciCommand command);

  /// Convenience helper that forwards a raw UCI line without typing.
  void sendRaw(String line) => send(UciRaw(line));

  /// Send `stop` if a search is in progress (engine-side no-op otherwise).
  void stop() => send(const UciStop());

  /// Shut the engine down cleanly: sends `quit`, joins the worker, and
  /// closes [events]. Safe to call more than once.
  Future<void> dispose();
}

/// Thrown from [ChessEngine.start] when the engine cannot be brought up.
class EngineStartupException implements Exception {
  const EngineStartupException(this.message, {this.cause});
  final String message;
  final Object? cause;

  @override
  String toString() =>
      'EngineStartupException: $message${cause == null ? '' : ' (cause: $cause)'}';
}

/// Thrown from [ChessEngine.send] when called before [ChessEngine.start] has
/// completed or after [ChessEngine.dispose].
class EngineNotRunningException implements Exception {
  const EngineNotRunningException();
  @override
  String toString() => 'EngineNotRunningException: engine is not running';
}
