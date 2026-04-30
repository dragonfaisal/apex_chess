/// Cloud-only analysis service — replaces local Stockfish engine.
///
/// Evaluates positions via Lichess Cloud Eval API.
/// Returns `null` when:
///   - Position not in Lichess cloud database
///   - Offline / rate-limited (circuit breaker tripped)
///
/// The caller must handle `null` gracefully (show "requires internet" state).
library;

import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
import 'package:apex_chess/infrastructure/api/lichess_cloud_eval_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Eval Result (normalized to White's POV)
// ─────────────────────────────────────────────────────────────────────────────

class CloudEvalSnapshot {
  /// Centipawns of the best line, White's POV.
  final int? scoreCp;

  /// Mate-in for the best line, White's POV.
  final int? mateIn;

  /// Centipawns of the second-best line, White's POV. `null` when
  /// Lichess only returned a single PV.
  final int? secondBestCp;

  /// Mate-in for the second-best line, White's POV.
  final int? secondBestMate;

  /// Search depth achieved in the cloud.
  final int depth;

  /// Best move in UCI (e.g., "e2e4").
  final String? bestMoveUci;

  /// Principal variation (list of UCI moves).
  final List<String> pvMoves;

  /// Ranked candidate lines when the backend supplied MultiPV.
  final List<EngineLine> engineLines;

  const CloudEvalSnapshot({
    this.scoreCp,
    this.mateIn,
    this.secondBestCp,
    this.secondBestMate,
    required this.depth,
    this.bestMoveUci,
    this.pvMoves = const [],
    this.engineLines = const <EngineLine>[],
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Error States
// ─────────────────────────────────────────────────────────────────────────────

enum CloudEvalError {
  /// Position not in Lichess cloud database.
  positionNotFound,

  /// Rate-limited (429) — circuit breaker tripped.
  rateLimited,

  /// No internet connectivity.
  offline,

  /// Unknown server/network error.
  serverError,
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class CloudEvalService {
  final LichessCloudEvalClient _client;

  CloudEvalService({LichessCloudEvalClient? client})
    : _client = client ?? LichessCloudEvalClient();

  /// Evaluates a FEN position via the Lichess Cloud Eval API.
  ///
  /// [multiPv] controls how many alternate lines to request — pass 2
  /// when the caller needs to detect "only winning move" (Great) by
  /// comparing PV[0] vs PV[1]. The default of 1 keeps live-eval calls
  /// cheap.
  ///
  /// Returns a tuple of (result, error). Exactly one will be non-null.
  Future<(CloudEvalSnapshot?, CloudEvalError?)> evaluate(
    String fen, {
    int multiPv = 1,
  }) async {
    // Check if circuit breaker is tripped before calling.
    if (_client.isRateLimited) {
      return (null, CloudEvalError.rateLimited);
    }

    try {
      final result = await _client.getEvaluation(fen, multiPv: multiPv);

      if (result == null) {
        // Could be 404 (not found) or rate-limited.
        if (_client.isRateLimited) {
          return (null, CloudEvalError.rateLimited);
        }
        return (null, CloudEvalError.positionNotFound);
      }

      // Lichess Cloud Eval returns scores from White's perspective already.
      // But PV moves are always from side-to-move's perspective.
      final bestMove = result.pvMoves.isNotEmpty ? result.pvMoves.first : null;
      final win = const WinPercentCalculator();
      final engineLines = <EngineLine>[
        EngineLine(
          rank: 1,
          moveUci: bestMove,
          scoreCp: result.scoreCp,
          mateIn: result.mateIn,
          depth: result.depth,
          whiteWinPercent: win.forCp(cp: result.scoreCp, mate: result.mateIn),
          pvMoves: result.pvMoves,
        ),
        if (result.secondBestCp != null || result.secondBestMate != null)
          EngineLine(
            rank: 2,
            scoreCp: result.secondBestCp,
            mateIn: result.secondBestMate,
            depth: result.depth,
            whiteWinPercent: win.forCp(
              cp: result.secondBestCp,
              mate: result.secondBestMate,
            ),
          ),
      ];

      return (
        CloudEvalSnapshot(
          scoreCp: result.scoreCp,
          mateIn: result.mateIn,
          secondBestCp: result.secondBestCp,
          secondBestMate: result.secondBestMate,
          depth: result.depth,
          bestMoveUci: bestMove,
          pvMoves: result.pvMoves,
          engineLines: engineLines,
        ),
        null,
      );
    } catch (e) {
      // Network errors (SocketException, etc.) → offline.
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socket') ||
          errorStr.contains('network') ||
          errorStr.contains('connection')) {
        return (null, CloudEvalError.offline);
      }
      return (null, CloudEvalError.serverError);
    }
  }

  void dispose() => _client.dispose();
}
