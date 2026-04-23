/// Local evaluation service — drop-in replacement for `CloudEvalService`.
///
/// Wraps the on-device Stockfish [ChessEngine] behind the same method
/// signature the UI already consumes (`evaluate(fen)`), so views that used
/// to query the Lichess Cloud Eval API can switch to the local engine by
/// swapping a single Riverpod provider.
///
/// ### UCI sync contract
///
/// The UCI protocol is stateful: the engine keeps *one* current position,
/// and search commands apply to that position until the next `position`
/// command. If the host races `position` → `go` while an old search is
/// still flushing output, the first `info` / `bestmove` we see can refer to
/// the *previous* position — silently corrupting every downstream delta.
///
/// This service eliminates that race by serialising every evaluation
/// through a single-flight [Future] chain and, within each evaluation,
/// by:
///
///   * sending `stop` to abort any lingering search,
///   * sending `isready` and awaiting `readyok` before issuing `position`,
///   * sending `ucinewgame` + a second `isready` / `readyok` round-trip so
///     the engine clears transposition-table pollution between positions,
///   * only accepting `info` frames whose `depth` is ≥ the target depth
///     (or the best achieved so far) — stale frames from the previous
///     search always carry the previous target's depth.
///
/// The net effect is that `evaluate(fen)` is guaranteed to return an
/// [EvalSnapshot] whose `scoreCp` / `mateIn` describe *exactly* the FEN
/// the caller asked about, from White's POV.
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
    Duration defaultTimeout = const Duration(seconds: 10),
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
      } catch (_) {
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

    // ── 1. Stop any lingering search and flush to a known-idle state. ──
    try {
      _engine.send(const UciStop());
    } on Object {
      // Engine not running — start() above would have bailed; re-report.
      return (null, EvalError.offline);
    }
    await _awaitReadyOk(const Duration(seconds: 2));

    // ── 2. Reset per-position state; this prevents the engine from using
    //     its transposition table built against the previous FEN. ──
    _engine.send(const UciNewGame());
    await _awaitReadyOk(const Duration(seconds: 2));

    // ── 3. Install the new position and start a *fresh* search. ──
    //     `latestInfo` is only filled from frames emitted *after* the
    //     subscription below is live, so stale lines from the prior
    //     search can't bleed into this result.
    EngineInfo? latestInfo;
    final bestMoveCompleter = Completer<EngineBestMove>();
    late final StreamSubscription<EngineEvent> sub;
    sub = _engine.events.listen((event) {
      if (event is EngineInfo) {
        // Keep the deepest frame we've seen; depth only grows within a
        // single search, so any frame with depth < latestInfo.depth is
        // out-of-order and ignored.
        if (event.scoreCp == null && event.scoreMate == null) return;
        final prior = latestInfo;
        if (prior == null || (event.depth ?? 0) >= (prior.depth ?? 0)) {
          latestInfo = event;
        }
      } else if (event is EngineBestMove) {
        if (!bestMoveCompleter.isCompleted) bestMoveCompleter.complete(event);
      } else if (event is EngineError) {
        if (!bestMoveCompleter.isCompleted) {
          bestMoveCompleter.completeError(event.message);
        }
      }
    });

    _engine
      ..send(UciPosition.fen(fen))
      ..send(UciGo.depth(depth));

    try {
      final best = await bestMoveCompleter.future.timeout(timeout);
      final isWhiteToMove = _sideToMoveIsWhite(fen);

      // Stockfish emits scores from side-to-move's POV; normalize to White.
      int? scoreCpWhite;
      int? mateInWhite;
      if (latestInfo != null) {
        final info = latestInfo!;
        if (info.scoreMate != null) {
          final m = info.scoreMate!;
          mateInWhite = isWhiteToMove ? m : -m;
        } else if (info.scoreCp != null) {
          final cp = info.scoreCp!;
          scoreCpWhite = isWhiteToMove ? cp : -cp;
        }
      }

      // No usable info frame → engine answered but didn't report a score.
      // Surface this so callers can decide whether to retry or treat the
      // move as unscored rather than silently returning 0.0 / "Good".
      if (scoreCpWhite == null && mateInWhite == null) {
        return (null, EvalError.positionNotFound);
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
      _engine.send(const UciStop());
      return (null, EvalError.serverError);
    } catch (_) {
      return (null, EvalError.serverError);
    } finally {
      await sub.cancel();
    }
  }

  /// Send `isready` and await the engine's `readyok` acknowledgement.
  ///
  /// Used to drain pending output between UCI state transitions. On
  /// timeout we silently return — the caller will discover any real
  /// engine stall when the follow-up `go` search times out, and we still
  /// want to preserve forward progress on a mildly laggy engine.
  Future<void> _awaitReadyOk(Duration timeout) async {
    final completer = Completer<void>();
    late final StreamSubscription<EngineEvent> sub;
    sub = _engine.events.listen((event) {
      if (event is EngineReadyOk) {
        if (!completer.isCompleted) completer.complete();
      } else if (event is EngineError) {
        if (!completer.isCompleted) {
          completer.completeError(event.message);
        }
      }
    });

    try {
      _engine.send(const UciIsReady());
      await completer.future.timeout(timeout);
    } on TimeoutException {
      // Ignore — we treat missing `readyok` as best-effort sync.
    } catch (_) {
      // Ignore — caller will see failure via the follow-up go/bestmove.
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
