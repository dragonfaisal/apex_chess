/// Local evaluation service — drop-in replacement for `CloudEvalService`.
///
/// Wraps the on-device Stockfish [ChessEngine] behind the same method
/// signature the UI already consumes (`evaluate(fen)`), so views that used
/// to query the Lichess Cloud Eval API can switch to the local engine by
/// swapping a single Riverpod provider.
///
/// The service is deliberately single-flight: each call to [evaluate] waits
/// for any in-flight search to end before driving the engine, ensuring UCI
/// `position` / `go` sequencing is never interleaved.
library;

import 'dart:async';

import 'package:apex_chess/core/infrastructure/engine/engine.dart';
import 'package:apex_chess/infrastructure/api/cloud_eval_service.dart'
    show CloudEvalSnapshot, CloudEvalError;

/// Re-exported for callers that prefer a non-"cloud" name on the happy path.
typedef EvalSnapshot = CloudEvalSnapshot;
typedef EvalError = CloudEvalError;

class LocalEvalService {
  LocalEvalService({
    required ChessEngine engine,
    int defaultDepth = 14,
    Duration defaultTimeout = const Duration(seconds: 8),
  })  : _engine = engine,
        _defaultDepth = defaultDepth,
        _defaultTimeout = defaultTimeout;

  final ChessEngine _engine;
  final int _defaultDepth;
  final Duration _defaultTimeout;

  /// Serializes evaluate() calls so only one UCI search is in flight at a
  /// time. Essential — the engine has a single position slot.
  Future<void> _queue = Future<void>.value();

  Future<(EvalSnapshot?, EvalError?)> evaluate(
    String fen, {
    int? depth,
    Duration? timeout,
  }) {
    final completer = Completer<(EvalSnapshot?, EvalError?)>();
    final previous = _queue;
    _queue = previous.then((_) async {
      try {
        final result = await _runOne(
          fen,
          depth: depth ?? _defaultDepth,
          timeout: timeout ?? _defaultTimeout,
        );
        completer.complete(result);
      } catch (e) {
        // Never let the queue die.
        completer.complete((null, EvalError.serverError));
      }
    });
    return completer.future;
  }

  Future<(EvalSnapshot?, EvalError?)> _runOne(
    String fen, {
    required int depth,
    required Duration timeout,
  }) async {
    if (!_engine.isRunning) {
      try {
        await _engine.start();
      } on Object {
        return (null, EvalError.offline);
      }
    }

    // Drive the UCI handshake once per lifecycle; cheap if already done.
    _engine.send(const UciIsReady());

    EngineInfo? latestInfo;
    final bestMoveCompleter = Completer<EngineBestMove>();
    late final StreamSubscription<EngineEvent> sub;
    sub = _engine.events.listen((event) {
      if (event is EngineInfo) {
        latestInfo = event;
      } else if (event is EngineBestMove) {
        if (!bestMoveCompleter.isCompleted) bestMoveCompleter.complete(event);
      } else if (event is EngineError) {
        if (!bestMoveCompleter.isCompleted) {
          bestMoveCompleter.completeError(event.message);
        }
      }
    });

    _engine
      ..send(const UciNewGame())
      ..send(UciPosition.fen(fen))
      ..send(UciGo.depth(depth));

    try {
      final best = await bestMoveCompleter.future.timeout(timeout);
      final isWhiteToMove = _sideToMoveIsWhite(fen);

      // Stockfish emits scores from side-to-move's POV; normalize to White.
      int? scoreCpWhite;
      int? mateInWhite;
      if (latestInfo != null) {
        if (latestInfo!.scoreMate != null) {
          final m = latestInfo!.scoreMate!;
          mateInWhite = isWhiteToMove ? m : -m;
        } else if (latestInfo!.scoreCp != null) {
          final cp = latestInfo!.scoreCp!;
          scoreCpWhite = isWhiteToMove ? cp : -cp;
        }
      }

      final pv = latestInfo?.pv ?? const <String>[];
      return (
        EvalSnapshot(
          scoreCp: scoreCpWhite,
          mateIn: mateInWhite,
          depth: latestInfo?.depth ?? depth,
          bestMoveUci: best.move,
          pvMoves: pv,
        ),
        null,
      );
    } on TimeoutException {
      _engine.stop();
      return (null, EvalError.serverError);
    } catch (_) {
      return (null, EvalError.serverError);
    } finally {
      await sub.cancel();
    }
  }

  bool _sideToMoveIsWhite(String fen) {
    final parts = fen.split(' ');
    if (parts.length < 2) return true;
    return parts[1].trim().toLowerCase() == 'w';
  }
}
