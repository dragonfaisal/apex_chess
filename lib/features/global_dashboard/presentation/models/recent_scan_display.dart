/// Compact display model for the Stats Recent Scans list.
library;

import 'package:apex_chess/features/archives/domain/archived_game.dart';

class RecentScanDisplay {
  const RecentScanDisplay({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  factory RecentScanDisplay.fromGame(ArchivedGame game, {String? perspective}) {
    final accuracy = (100 - game.averageCpLoss)
        .clamp(0, 100)
        .toStringAsFixed(0);
    final result = _shortResult(game.resultHeadline(userHandle: perspective));
    final moveCount = (game.totalPlies / 2).ceil();
    return RecentScanDisplay(
      title: '${game.white} vs ${game.black}',
      subtitle:
          '$result · $accuracy% · ${game.reviewModeLabel} · $moveCount moves',
    );
  }

  static String _shortResult(String headline) {
    if (headline.startsWith('You won')) return 'You won';
    if (headline.startsWith('You lost')) return 'You lost';
    if (headline.startsWith('Draw')) return 'Draw';
    if (headline == 'White won' || headline == 'Black won') return headline;
    return headline.isEmpty ? 'Result unavailable' : headline;
  }
}
