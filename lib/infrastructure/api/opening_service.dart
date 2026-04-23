/// Opening detection service — wraps Lichess Opening Explorer.
///
/// For early plies (1–20), queries the opening explorer to:
///   1. Detect book moves → classify as Book, assign opening name/ECO
///   2. Detect deviations → flag for immediate cloud eval + full deltaW penalty
///
/// CRITICAL: A deviation is NOT immune. If the player blunders on move 4,
/// it MUST be flagged as Blunder (??) after cloud eval confirms the loss.
library;

import 'package:apex_chess/infrastructure/api/lichess_opening_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Opening Info
// ─────────────────────────────────────────────────────────────────────────────

class OpeningInfo {
  /// Whether this exact move is in the opening book.
  final bool isBookMove;

  /// Opening name (e.g., "Sicilian Defense: Najdorf Variation").
  final String? openingName;

  /// ECO code (e.g., "B97").
  final String? ecoCode;

  /// How many games have been played with this exact move.
  final int gamesPlayed;

  /// Win rate for the side that played this move.
  final double? winRate;

  /// Whether the position itself is in the book (has data).
  final bool positionInBook;

  /// This is a deviation — move exists but position is in book.
  /// If true, the move MUST be evaluated by the engine for deltaW.
  final bool isDeviation;

  const OpeningInfo({
    required this.isBookMove,
    this.openingName,
    this.ecoCode,
    required this.gamesPlayed,
    this.winRate,
    required this.positionInBook,
    required this.isDeviation,
  });

  /// A move not in the book at all and position also unknown.
  factory OpeningInfo.unknown() => const OpeningInfo(
        isBookMove: false,
        gamesPlayed: 0,
        positionInBook: false,
        isDeviation: false,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class OpeningService {
  final LichessOpeningClient _client;

  /// Maximum ply to check the opening explorer (after this, skip).
  static const int maxBookPly = 20;

  /// Minimum games for a move to be considered "in book".
  static const int minBookGames = 10;

  OpeningService({LichessOpeningClient? client})
      : _client = client ?? LichessOpeningClient();

  /// Checks whether a move is a book move for a given position.
  ///
  /// [fen] — The position BEFORE the move was played.
  /// [playedSan] — The SAN of the move that was played.
  /// [ply] — The 0-indexed ply number.
  ///
  /// Returns [OpeningInfo] with book/deviation status.
  Future<OpeningInfo> checkMove({
    required String fen,
    required String playedSan,
    required int ply,
  }) async {
    // After maxBookPly, don't bother querying the explorer.
    if (ply >= maxBookPly) {
      return OpeningInfo.unknown();
    }

    final explorerResult = await _client.getOpening(fen);

    // If we couldn't reach the API, treat as unknown.
    if (explorerResult == null) {
      return OpeningInfo.unknown();
    }

    // Position has data in the explorer.
    final positionInBook = explorerResult.isInBook;

    // Find the played move in the explorer response.
    ExplorerMove? matchedMove;
    for (final move in explorerResult.moves) {
      if (move.san == playedSan) {
        matchedMove = move;
        break;
      }
    }

    if (matchedMove != null && matchedMove.totalGames >= minBookGames) {
      // ✅ BOOK MOVE — played a known, popular move.
      return OpeningInfo(
        isBookMove: true,
        openingName: explorerResult.openingName,
        ecoCode: explorerResult.ecoCode,
        gamesPlayed: matchedMove.totalGames,
        winRate: matchedMove.whiteWinRate,
        positionInBook: positionInBook,
        isDeviation: false,
      );
    }

    if (positionInBook) {
      // ❌ DEVIATION — position is known but the move is rare/unknown.
      // This move gets NO immunity. It MUST be evaluated for deltaW.
      return OpeningInfo(
        isBookMove: false,
        openingName: explorerResult.openingName,
        ecoCode: explorerResult.ecoCode,
        gamesPlayed: matchedMove?.totalGames ?? 0,
        positionInBook: true,
        isDeviation: true,
      );
    }

    // Position itself is not in the book (very rare opening or late game).
    return OpeningInfo(
      isBookMove: false,
      openingName: explorerResult.openingName,
      ecoCode: explorerResult.ecoCode,
      gamesPlayed: 0,
      positionInBook: false,
      isDeviation: false,
    );
  }

  void dispose() => _client.dispose();
}
