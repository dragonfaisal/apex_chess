/// Cloud-only analysis service — replaces local Stockfish engine.
///
/// Evaluates positions via Lichess Cloud Eval API.
/// Returns `null` when:
///   - Position not in Lichess cloud database
///   - Offline / rate-limited (circuit breaker tripped)
///
/// The caller must handle `null` gracefully (show "requires internet" state).
library;

import 'package:apex_chess/infrastructure/api/lichess_cloud_eval_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Eval Result (normalized to White's POV)
// ─────────────────────────────────────────────────────────────────────────────

class CloudEvalSnapshot {
  /// Centipawns from White's perspective.
  final int? scoreCp;

  /// Mate-in from White's perspective.
  final int? mateIn;

  /// Search depth achieved in the cloud.
  final int depth;

  /// Best move in UCI (e.g., "e2e4").
  final String? bestMoveUci;

  /// Principal variation (list of UCI moves).
  final List<String> pvMoves;

  const CloudEvalSnapshot({
    this.scoreCp,
    this.mateIn,
    required this.depth,
    this.bestMoveUci,
    this.pvMoves = const [],
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
  /// The FEN's side-to-move is used to normalize the score to White's POV.
  /// Returns a tuple of (result, error). Exactly one will be non-null.
  Future<(CloudEvalSnapshot?, CloudEvalError?)> evaluate(String fen) async {
    // Check if circuit breaker is tripped before calling.
    if (_client.isRateLimited) {
      return (null, CloudEvalError.rateLimited);
    }

    try {
      final result = await _client.getEvaluation(fen);

      if (result == null) {
        // Could be 404 (not found) or rate-limited.
        if (_client.isRateLimited) {
          return (null, CloudEvalError.rateLimited);
        }
        return (null, CloudEvalError.positionNotFound);
      }

      // Lichess Cloud Eval returns scores from White's perspective already.
      // But PV moves are always from side-to-move's perspective.
      final bestMove =
          result.pvMoves.isNotEmpty ? result.pvMoves.first : null;

      return (
        CloudEvalSnapshot(
          scoreCp: result.scoreCp,
          mateIn: result.mateIn,
          depth: result.depth,
          bestMoveUci: bestMove,
          pvMoves: result.pvMoves,
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
