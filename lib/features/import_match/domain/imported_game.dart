/// Source-agnostic view model for a single imported game.
///
/// Both [ChessComRepository] and [LichessRepository] map their proprietary
/// responses into this shape so the UI can render a single list without
/// knowing where each row came from.
library;

enum GameSource { chessCom, lichess }

enum GameResult { whiteWon, blackWon, draw, unknown }

enum PlayerColor { white, black }

class ImportedGame {
  const ImportedGame({
    required this.id,
    required this.source,
    required this.whiteName,
    required this.blackName,
    required this.whiteRating,
    required this.blackRating,
    required this.result,
    required this.playedAt,
    required this.timeControl,
    required this.moveCount,
    required this.pgn,
    this.eco,
    this.openingName,
    this.userColor,
  });

  final String id;
  final GameSource source;
  final String whiteName;
  final String blackName;
  final int? whiteRating;
  final int? blackRating;
  final GameResult result;
  final DateTime playedAt;
  final String? timeControl;
  final int moveCount;
  final String pgn;
  final String? eco;
  final String? openingName;
  final PlayerColor? userColor;

  /// Short "3 days ago" style display.
  String get relativeTime {
    final diff = DateTime.now().difference(playedAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  String get resultLabel => switch (result) {
        GameResult.whiteWon => '1–0',
        GameResult.blackWon => '0–1',
        GameResult.draw => '½–½',
        GameResult.unknown => '—',
      };

  /// Resolves the user's outcome given [userColor]; returns null when we
  /// don't know which side the user played.
  String? get userOutcomeLabel {
    if (userColor == null || result == GameResult.unknown) return null;
    final won = (userColor == PlayerColor.white &&
            result == GameResult.whiteWon) ||
        (userColor == PlayerColor.black && result == GameResult.blackWon);
    final drew = result == GameResult.draw;
    if (drew) return 'Drew';
    return won ? 'Won' : 'Lost';
  }
}

class ImportException implements Exception {
  const ImportException(this.userMessage);
  final String userMessage;

  @override
  String toString() => 'ImportException: $userMessage';
}
