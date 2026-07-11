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
import 'dart:developer' as developer;

import 'package:dartchess/dartchess.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/position_evaluation.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
import 'package:apex_chess/core/infrastructure/engine/engine.dart';
import 'package:apex_chess/core/infrastructure/engine/uci/fen_validator.dart';

/// Re-exported for callers that prefer a non-"cloud" name on the happy path.
typedef EvalSnapshot = PositionEvaluation;

enum EvalError {
  positionNotFound,
  rateLimited,
  offline,
  serverError,
  synchronizationTimeout,
  searchTimeout,
  malformedResponse,
  cancelled,
}

class LocalEvalService {
  LocalEvalService({
    required ChessEngine engine,
    int defaultDepth = 14,
    // Real Stockfish + NNUE on a single desktop thread can take 15-25 s
    // on tactically loaded middlegame positions at depth 14. The previous
    // 10 s cap aborted those searches mid-flight and surfaced as
    // "engine stopped responding" during full-game batch scans.
    Duration defaultTimeout = const Duration(seconds: 45),
  }) : _engine = engine,
       _defaultDepth = defaultDepth,
       _defaultTimeout = defaultTimeout;

  final ChessEngine _engine;
  final int _defaultDepth;
  final Duration _defaultTimeout;

  String get engineVersion => _engine.bridgeVersion;

  void cancelActiveSearch() {
    if (_engine.isRunning) _engine.stop();
  }

  /// Serializes evaluate() calls so only one UCI search is in flight at a
  /// time. Essential — the engine has a single position slot.
  Future<void> _queue = Future<void>.value();

  Future<(EvalSnapshot?, EvalError?)> evaluate(
    String fen, {
    int? depth,
    Duration? movetime,
    Duration? timeout,
    int multiPv = 1,
  }) {
    final completer = Completer<(EvalSnapshot?, EvalError?)>();
    final previous = _queue;
    _queue = previous.then((_) async {
      try {
        final result = await _runOne(
          fen,
          depth: depth ?? _defaultDepth,
          movetime: movetime,
          timeout: timeout ?? _defaultTimeout,
          multiPv: multiPv,
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
    Duration? movetime,
    required Duration timeout,
    required int multiPv,
  }) async {
    // Reject obviously malformed FENs *before* we touch the engine. The
    // UCI position parser inside Stockfish 17 is not defensive against
    // every shape of bad input — feeding it a string that fails this
    // cheap structural check has, in production, abort()'d the
    // worker thread (DartWorker SIGABRT) on the very first move of a
    // game when the upstream caller fed an empty / partial FEN.
    if (!validateFenForEngineCommand(fen).isValid) {
      return (null, EvalError.positionNotFound);
    }

    if (!_engine.isRunning) {
      try {
        await _engine.start();
      } on Object {
        return (null, EvalError.offline);
      }
    }
    if (engineVersion.toLowerCase().contains('stub')) {
      return (null, EvalError.offline);
    }

    // ── 1. Stop any lingering search and flush to a known-idle state. ──
    try {
      _engine.send(const UciStop());
    } on Object {
      // Engine not running — start() above would have bailed; re-report.
      return (null, EvalError.offline);
    }
    if (!await _awaitReadyOk(const Duration(seconds: 2))) {
      return (null, EvalError.synchronizationTimeout);
    }

    // ── 2. Reset per-position state; this prevents the engine from using
    //     its transposition table built against the previous FEN. ──
    _engine.send(const UciNewGame());
    if (!await _awaitReadyOk(const Duration(seconds: 2))) {
      return (null, EvalError.synchronizationTimeout);
    }

    // MultiPV is a sticky UCI option. Set it on every call so a Deep
    // review does not leak PV3 searches into Quick/live evaluations.
    final requestedMultiPv = multiPv.clamp(1, 5).toInt();
    _engine.send(
      UciSetOption(name: 'MultiPV', value: requestedMultiPv.toString()),
    );
    if (!await _awaitReadyOk(const Duration(seconds: 2))) {
      return (null, EvalError.synchronizationTimeout);
    }

    // ── 3. Install the new position and start a *fresh* search. ──
    //     `latestByPv` is only filled from frames emitted *after* the
    //     subscription below is live, so stale lines from the prior
    //     search can't bleed into this result.
    final framesByDepth = <int, Map<int, EngineInfo>>{};
    final bestMoveCompleter = Completer<EngineBestMove>();
    late final StreamSubscription<EngineEvent> sub;
    sub = _engine.events.listen((event) {
      if (event is EngineInfo) {
        if (event.scoreCp == null && event.scoreMate == null) return;
        final rank = event.multipv ?? 1;
        if (rank < 1 || rank > requestedMultiPv) return;
        final eventDepth = event.depth ?? 0;
        if (eventDepth <= 0) return;
        framesByDepth.putIfAbsent(eventDepth, () => <int, EngineInfo>{})[rank] =
            event;
      } else if (event is EngineBestMove) {
        if (!bestMoveCompleter.isCompleted) bestMoveCompleter.complete(event);
      } else if (event is EngineError) {
        if (!bestMoveCompleter.isCompleted) {
          bestMoveCompleter.completeError(event.message);
        }
      }
    });

    // UCI `go` lets the caller combine terminators — whichever fires
    // first stops the search. For batch analysis we want "reach this
    // depth OR at most this wall-clock time, then stop"; depth-only on
    // desktop Stockfish can spend >30s on tactical middlegames which
    // stalls the whole game scan.
    final searchStartedAt = DateTime.now();
    _engine
      ..send(UciPosition.fen(fen))
      ..send(
        movetime != null
            ? UciGo(depth: depth, movetime: movetime)
            : UciGo.depth(depth),
      );

    try {
      final best = await bestMoveCompleter.future.timeout(timeout);
      final elapsedMs = DateTime.now()
          .difference(searchStartedAt)
          .inMilliseconds;
      final isWhiteToMove = _sideToMoveIsWhite(fen);

      final selectedFrame = _selectCompletedFrame(
        framesByDepth,
        requestedMultiPv: requestedMultiPv,
      );
      final lines = _buildEngineLines(
        fen: fen,
        infosByRank: selectedFrame,
        requestedMultiPv: requestedMultiPv,
        isWhiteToMove: isWhiteToMove,
      );
      final bestLine = lines.isNotEmpty ? lines.first : null;
      final secondLine = lines.length >= 2 ? lines[1] : null;
      final scoreCpWhite = bestLine?.scoreCp;
      final mateInWhite = bestLine?.mateIn;

      // No usable info frame → engine answered but didn't report a score.
      // Surface this so callers can decide whether to retry or treat the
      // move as unscored rather than silently returning 0.0 / "Good".
      if (bestLine == null ||
          (scoreCpWhite == null) == (mateInWhite == null) ||
          mateInWhite == 0 ||
          _normalizeCastlingUci(best.move) != bestLine.moveUci) {
        return (null, EvalError.malformedResponse);
      }

      final pv = bestLine.pvMoves;

      // Diagnostic telemetry — off in release builds. Cheap to keep on in
      // debug because each eval already involves ~thousands of UCI lines;
      // a single structured log per search is noise-free and lets us
      // prove the engine is actually *searching* (elapsed_ms should
      // scale with movetime/depth, not collapse to ~0).
      if (kDebugMode) {
        developer.log(
          'uci_eval fen="$fen" depth_target=$depth '
          'depth_reached=${bestLine.depth} '
          'multipv=$requestedMultiPv '
          'lines=${lines.length} '
          'movetime_cap_ms=${movetime?.inMilliseconds ?? '-'} '
          'elapsed_ms=$elapsedMs '
          'score_cp_white=${scoreCpWhite ?? '-'} '
          'mate_in_white=${mateInWhite ?? '-'} '
          'bestmove=${best.move}',
          name: 'apex.engine',
        );
      }

      return (
        EvalSnapshot(
          scoreCp: scoreCpWhite,
          mateIn: mateInWhite,
          secondBestCp: secondLine?.scoreCp,
          secondBestMate: secondLine?.mateIn,
          depth: bestLine.depth,
          bestMoveUci: bestLine.moveUci,
          pvMoves: pv,
          engineLines: lines,
          positionFen: fen,
          requestedDepth: depth,
          requestedMovetimeMs: movetime?.inMilliseconds,
          requestedMultiPv: requestedMultiPv,
          nodes: selectedFrame[1]?.nodes,
          engineTimeMs: selectedFrame[1]?.time?.inMilliseconds,
          elapsedMs: elapsedMs,
          engineVersion: engineVersion,
        ),
        null,
      );
    } on TimeoutException {
      _engine.send(const UciStop());
      return (null, EvalError.searchTimeout);
    } catch (_) {
      return (null, EvalError.serverError);
    } finally {
      await sub.cancel();
    }
  }

  /// Send `isready` and await the engine's `readyok` acknowledgement.
  ///
  /// Used to drain pending output between UCI state transitions. On
  /// A missing acknowledgement is a synchronization failure. Continuing
  /// would make the following score impossible to bind to the requested FEN.
  Future<bool> _awaitReadyOk(Duration timeout) async {
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
      return true;
    } on Object {
      return false;
    } finally {
      await sub.cancel();
    }
  }

  bool _sideToMoveIsWhite(String fen) {
    final parts = fen.split(' ');
    if (parts.length < 2) return true;
    return parts[1].trim().toLowerCase() == 'w';
  }

  List<EngineLine> _buildEngineLines({
    required String fen,
    required Map<int, EngineInfo> infosByRank,
    required int requestedMultiPv,
    required bool isWhiteToMove,
  }) {
    final win = const WinPercentCalculator();
    final lines = <EngineLine>[];
    final roots = <String>{};
    for (var rank = 1; rank <= requestedMultiPv; rank++) {
      final info = infosByRank[rank];
      if (info == null) break;
      if (info.depth == null || info.depth! <= 0) break;
      if (info.scoreBound != null) break;

      final scoreCpWhite = info.scoreCp == null
          ? null
          : isWhiteToMove
          ? info.scoreCp!
          : -info.scoreCp!;
      final mateInWhite = info.scoreMate == null
          ? null
          : isWhiteToMove
          ? info.scoreMate!
          : -info.scoreMate!;
      if ((scoreCpWhite == null) == (mateInWhite == null) || mateInWhite == 0) {
        break;
      }

      final pvMoves = info.pv
          .map(_normalizeCastlingUci)
          .toList(growable: false);
      if (pvMoves.isEmpty) break;
      final moveUci = pvMoves.first;
      if (_tryUciToSan(fen, moveUci) == null) break;
      if (!roots.add(moveUci)) break;
      lines.add(
        EngineLine(
          rank: rank,
          moveUci: moveUci,
          moveSan: _tryUciToSan(fen, moveUci),
          scoreCp: scoreCpWhite,
          mateIn: mateInWhite,
          depth: info.depth!,
          whiteWinPercent: win.forCp(cp: scoreCpWhite, mate: mateInWhite),
          pvMoves: pvMoves,
        ),
      );
    }
    return lines;
  }

  Map<int, EngineInfo> _selectCompletedFrame(
    Map<int, Map<int, EngineInfo>> framesByDepth, {
    required int requestedMultiPv,
  }) {
    final depths = framesByDepth.keys.toList(growable: false)
      ..sort((a, b) => b.compareTo(a));

    for (final depth in depths) {
      final frame = framesByDepth[depth]!;
      if (_contiguousRankCount(frame, requestedMultiPv) == requestedMultiPv) {
        return frame;
      }
    }

    for (final depth in depths) {
      final frame = framesByDepth[depth]!;
      if (_contiguousRankCount(frame, requestedMultiPv) > 0) return frame;
    }
    return const <int, EngineInfo>{};
  }

  int _contiguousRankCount(Map<int, EngineInfo> frame, int requestedMultiPv) {
    var count = 0;
    for (var rank = 1; rank <= requestedMultiPv; rank++) {
      if (!frame.containsKey(rank)) break;
      count++;
    }
    return count;
  }

  String? _tryUciToSan(String fen, String? uci) {
    try {
      if (uci == null || uci.length < 4) return null;
      final pos = Chess.fromSetup(Setup.parseFen(fen));
      final from = _parseSquare(uci.substring(0, 2));
      final to = _parseSquare(uci.substring(2, 4));
      if (from == null || to == null) return null;
      Role? promotion;
      if (uci.length == 5) {
        promotion = switch (uci[4]) {
          'q' => Role.queen,
          'r' => Role.rook,
          'b' => Role.bishop,
          'n' => Role.knight,
          _ => null,
        };
      }
      final move = NormalMove(from: from, to: to, promotion: promotion);
      if (!pos.isLegal(move)) return null;
      return pos.makeSan(move).$2;
    } catch (_) {
      return null;
    }
  }

  static Square? _parseSquare(String alg) {
    if (alg.length != 2) return null;
    final file = alg.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.tryParse(alg[1]);
    if (file < 0 || file > 7 || rank == null || rank < 1 || rank > 8) {
      return null;
    }
    return Square(file + (rank - 1) * 8);
  }

  static String _normalizeCastlingUci(String uci) {
    if (uci.length < 4) return uci;
    final head = uci.substring(0, 4);
    return switch (head) {
      'e1h1' => 'e1g1${uci.substring(4)}',
      'e1a1' => 'e1c1${uci.substring(4)}',
      'e8h8' => 'e8g8${uci.substring(4)}',
      'e8a8' => 'e8c8${uci.substring(4)}',
      _ => uci,
    };
  }
}

/// Cheap structural check on a FEN. Does not validate legality — only
/// the shape Stockfish's UCI `position fen` parser expects.
///
/// Rejects:
///   * null-ish / empty / control-char inputs (Skia / shaper safety),
///   * FENs without exactly 4 or 6 fields,
///   * board fields that are not 8 legal ranks of 8 files,
///   * side, castling, en-passant, and clock fields with invalid shapes.
///
/// Exposed for unit testing via the `isStructurallyValidFenForTesting`
/// indirection at the bottom of this file.
bool _isStructurallyValidFen(String fen) {
  return validateFenForEngineCommand(fen).isValid;
}

/// Test-only re-export of [_isStructurallyValidFen] so the structural
/// validator can be regression-tested without spinning up the engine.
@pragma('vm:entry-point')
bool isStructurallyValidFenForTesting(String fen) =>
    _isStructurallyValidFen(fen);
