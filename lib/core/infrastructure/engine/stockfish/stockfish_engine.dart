/// Public [ChessEngine] implementation backed by Stockfish via FFI + Isolate.
library;

import 'dart:async';
import 'dart:isolate';

import '../chess_engine.dart';
import '../uci/uci_command.dart';
import '../uci/uci_event.dart';
import '../uci/uci_parser.dart';
import 'stockfish_isolate.dart';

/// Drives a background `libstockfish_bridge` instance.
///
/// Lifecycle:
///
/// ```dart
/// final engine = StockfishEngine();
/// await engine.start();
///
/// final sub = engine.events
///     .whereType<EngineInfo>()
///     .listen((info) => print('cp=${info.scoreCp} pv=${info.pv}'));
///
/// engine.send(const UciHandshake());
/// engine.send(const UciIsReady());
/// engine.send(const UciNewGame());
/// engine.send(const UciPosition.startpos());
/// engine.send(const UciGo.depth(14));
/// // ...
/// await sub.cancel();
/// await engine.dispose();
/// ```
///
/// Internally, [start] spawns a dedicated worker isolate that owns the
/// native handle. All UCI I/O happens on that isolate, which means the host
/// UI isolate is never blocked by engine work regardless of search depth or
/// hash size.
class StockfishEngine implements ChessEngine {
  StockfishEngine({Duration startupTimeout = const Duration(seconds: 5)})
      : _startupTimeout = startupTimeout;

  final Duration _startupTimeout;

  Isolate? _isolate;
  ReceivePort? _fromWorker;
  SendPort? _toWorker;
  StreamSubscription<dynamic>? _workerSub;
  final StreamController<EngineEvent> _events =
      StreamController<EngineEvent>.broadcast();

  String _bridgeVersion = 'unknown';
  bool _running = false;
  bool _disposed = false;
  Completer<void>? _disposeCompleter;

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  String get bridgeVersion => _bridgeVersion;

  @override
  bool get isRunning => _running;

  @override
  Future<void> start() async {
    if (_running) return;
    if (_disposed) {
      throw const EngineStartupException('engine has been disposed');
    }

    final fromWorker = ReceivePort();
    _fromWorker = fromWorker;

    final readyCompleter = Completer<StockfishIsolateReady>();

    _workerSub = fromWorker.listen((dynamic msg) {
      if (msg is StockfishIsolateReady) {
        if (!readyCompleter.isCompleted) readyCompleter.complete(msg);
        return;
      }
      if (msg is StockfishIsolateError) {
        if (!readyCompleter.isCompleted) {
          readyCompleter.completeError(
            EngineStartupException('worker failed: ${msg.message}'),
          );
        } else {
          _events.add(EngineError(msg.message));
        }
        return;
      }
      if (msg is StockfishIsolateClosed) {
        _finalizeClose();
        return;
      }
      if (msg is String) {
        _events.add(parseUciLine(msg));
        return;
      }
    });

    try {
      _isolate = await Isolate.spawn<StockfishIsolateInit>(
        stockfishIsolateEntry,
        StockfishIsolateInit(mainSendPort: fromWorker.sendPort),
        errorsAreFatal: true,
        debugName: 'StockfishEngine',
      );
    } on Object catch (e) {
      await _teardown();
      throw EngineStartupException('Isolate.spawn failed', cause: e);
    }

    final StockfishIsolateReady ready;
    try {
      ready = await readyCompleter.future.timeout(_startupTimeout);
    } on TimeoutException catch (e) {
      await _teardown();
      throw EngineStartupException('engine handshake timed out', cause: e);
    } on Object {
      await _teardown();
      rethrow;
    }

    _toWorker = ready.commandSendPort;
    _bridgeVersion = ready.bridgeVersion;
    _running = true;
  }

  @override
  void send(UciCommand command) {
    final port = _toWorker;
    if (!_running || port == null) {
      throw const EngineNotRunningException();
    }
    sendWriteCommand(port, command.toUci());
  }

  @override
  void sendRaw(String line) => send(UciRaw(line));

  @override
  void stop() => send(const UciStop());

  @override
  Future<void> dispose() async {
    if (_disposed) return _disposeCompleter?.future ?? Future<void>.value();
    _disposed = true;
    _running = false;

    final completer = Completer<void>();
    _disposeCompleter = completer;

    final port = _toWorker;
    if (port != null) {
      sendShutdownCommand(port);
      // The worker will send StockfishIsolateClosed when it's done; that
      // triggers _finalizeClose() which completes this future.
      // Guard against a hung worker with a timeout — but give native
      // cleanup enough headroom to actually finish. The native bridge
      // joins Stockfish's ThreadPool inside `stockfish_destroy`, which
      // can take a couple of seconds on cold devices when a deep search
      // was in flight. The previous 3 s budget routinely fired *before*
      // the native worker had finished joining its threads, leaving
      // half-torn-down `std::mutex` instances behind that the next
      // `stockfish_create` would then race with — that race is the
      // root of the destroyed-mutex SIGABRT in production logs.
      unawaited(
        Future<void>.delayed(const Duration(seconds: 15)).then((_) async {
          if (!completer.isCompleted) {
            await _teardown();
            completer.complete();
          }
        }),
      );
    } else {
      await _teardown();
      completer.complete();
    }

    return completer.future;
  }

  void _finalizeClose() {
    _teardown().whenComplete(() {
      final completer = _disposeCompleter;
      if (completer != null && !completer.isCompleted) completer.complete();
    });
  }

  Future<void> _teardown() async {
    await _workerSub?.cancel();
    _workerSub = null;
    _fromWorker?.close();
    _fromWorker = null;
    _toWorker = null;
    _isolate?.kill(priority: Isolate.beforeNextEvent);
    _isolate = null;
    if (!_events.isClosed) await _events.close();
  }
}
