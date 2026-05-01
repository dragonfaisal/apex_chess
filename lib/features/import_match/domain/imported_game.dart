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
    GameResult.whiteWon => '1-0',
    GameResult.blackWon => '0-1',
    GameResult.draw => '1/2-1/2',
    GameResult.unknown => '—',
  };

  String get sourceLabel => switch (source) {
    GameSource.chessCom => 'Chess.com',
    GameSource.lichess => 'Lichess',
  };

  String get secondaryResultText => switch (result) {
    GameResult.whiteWon => 'White won · 1-0',
    GameResult.blackWon => 'Black won · 0-1',
    GameResult.draw => 'Draw · 1/2-1/2',
    GameResult.unknown => 'Result unavailable',
  };

  String get whiteResultText => switch (result) {
    GameResult.whiteWon => 'White won',
    GameResult.blackWon => 'Black won',
    GameResult.draw => 'Draw',
    GameResult.unknown => 'Result unavailable',
  };

  String? get opponentName {
    return switch (userColor) {
      PlayerColor.white => blackName,
      PlayerColor.black => whiteName,
      null => null,
    };
  }

  int? get userRating {
    return switch (userColor) {
      PlayerColor.white => whiteRating,
      PlayerColor.black => blackRating,
      null => null,
    };
  }

  int? get opponentRating {
    return switch (userColor) {
      PlayerColor.white => blackRating,
      PlayerColor.black => whiteRating,
      null => null,
    };
  }

  String get perspectiveHeadline {
    final opponent = opponentName;
    if (opponent == null || result == GameResult.unknown) {
      return whiteResultText;
    }
    if (result == GameResult.draw) return 'Draw vs $opponent';
    final won =
        (userColor == PlayerColor.white && result == GameResult.whiteWon) ||
        (userColor == PlayerColor.black && result == GameResult.blackWon);
    return won ? 'You won vs $opponent' : 'You lost vs $opponent';
  }

  String get filterIndex {
    return [
      sourceLabel,
      whiteName,
      blackName,
      opponentName,
      openingName,
      eco,
      timeControl,
      perspectiveHeadline,
      userOutcomeLabel,
      secondaryResultText,
      '$moveCount moves',
    ].whereType<String>().join(' ').toLowerCase();
  }

  bool matchesLocalFilter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return filterIndex.contains(q);
  }

  /// Resolves the user's outcome given [userColor]; returns null when we
  /// don't know which side the user played.
  String? get userOutcomeLabel {
    if (userColor == null || result == GameResult.unknown) return null;
    final won =
        (userColor == PlayerColor.white && result == GameResult.whiteWon) ||
        (userColor == PlayerColor.black && result == GameResult.blackWon);
    final drew = result == GameResult.draw;
    if (drew) return 'Draw';
    return won ? 'Won' : 'Lost';
  }
}

class ImportException implements Exception {
  const ImportException(this.userMessage);
  final String userMessage;

  @override
  String toString() => 'ImportException: $userMessage';
}
