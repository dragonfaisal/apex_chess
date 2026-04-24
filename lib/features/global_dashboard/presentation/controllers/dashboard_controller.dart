/// Aggregates the ArchivedGame list into the numbers, buckets, and
/// series the Global Dashboard screen renders.
///
/// Pure view-model logic — no I/O, no engine — so the dashboard
/// updates in real time as new games are analysed (ArchiveController
/// is the source of truth and refreshes on save).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';

class DashboardStats {
  const DashboardStats({
    required this.gamesAnalyzed,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.unknownResult,
    required this.totalBrilliants,
    required this.totalBlunders,
    required this.totalMistakes,
    required this.totalInaccuracies,
    required this.qualityDistribution,
    required this.accuracyTrend,
    required this.winRate,
    required this.averageAccuracy,
    required this.perspective,
  });

  factory DashboardStats.empty() => const DashboardStats(
        gamesAnalyzed: 0,
        wins: 0,
        losses: 0,
        draws: 0,
        unknownResult: 0,
        totalBrilliants: 0,
        totalBlunders: 0,
        totalMistakes: 0,
        totalInaccuracies: 0,
        qualityDistribution: {},
        accuracyTrend: [],
        winRate: 0,
        averageAccuracy: 0,
        perspective: null,
      );

  final int gamesAnalyzed;
  final int wins;
  final int losses;
  final int draws;
  final int unknownResult;
  final int totalBrilliants;
  final int totalBlunders;
  final int totalMistakes;
  final int totalInaccuracies;
  final Map<MoveQuality, int> qualityDistribution;

  /// Accuracy per game, oldest→newest. Used to paint the trend line.
  /// Accuracy is `100 - averageCpLoss` (averageCpLoss is already a
  /// Win% delta aggregate, so values come out in a 0..100 band).
  final List<double> accuracyTrend;

  /// 0..100. Computed only when [perspective] is set; otherwise 0.
  final double winRate;
  final double averageAccuracy;
  final String? perspective;

  bool get hasData => gamesAnalyzed > 0;
}

/// Games-per-page for the recent-games table at the bottom of the
/// dashboard. Kept small so the table stays above the fold on phones.
const int dashboardPageSize = 10;

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final archive = ref.watch(archiveControllerProvider);
  final account = ref.watch(accountControllerProvider).valueOrNull;
  return _buildStats(archive.games, account?.username);
});

DashboardStats _buildStats(List<ArchivedGame> games, String? perspective) {
  if (games.isEmpty) return DashboardStats.empty();
  // Oldest-first so the trend series reads left-to-right in time.
  final ordered = [...games]
    ..sort((a, b) => a.analyzedAt.compareTo(b.analyzedAt));

  int wins = 0, losses = 0, draws = 0, unknown = 0;
  int brilliants = 0, blunders = 0, mistakes = 0, inaccuracies = 0;
  final qualityTotals = <MoveQuality, int>{};
  final trend = <double>[];
  double accuracySum = 0;

  final me = perspective?.toLowerCase();
  for (final g in ordered) {
    brilliants += g.brilliantCount;
    blunders += g.blunderCount;
    mistakes += g.mistakeCount;
    inaccuracies += g.inaccuracyCount;
    for (final entry in g.qualityCounts.entries) {
      qualityTotals[entry.key] =
          (qualityTotals[entry.key] ?? 0) + entry.value;
    }
    // Accuracy clamps to a sensible band — a bad game doesn't have
    // negative accuracy, and a flawless one caps at 100.
    final acc = (100 - g.averageCpLoss).clamp(0, 100).toDouble();
    trend.add(acc);
    accuracySum += acc;

    if (me != null && me.isNotEmpty) {
      final whiteIsMe = g.white.toLowerCase() == me;
      final blackIsMe = g.black.toLowerCase() == me;
      if (!whiteIsMe && !blackIsMe) {
        unknown++;
        continue;
      }
      switch (g.result) {
        case '1-0':
          if (whiteIsMe) {
            wins++;
          } else {
            losses++;
          }
          break;
        case '0-1':
          if (blackIsMe) {
            wins++;
          } else {
            losses++;
          }
          break;
        case '1/2-1/2':
          draws++;
          break;
        default:
          unknown++;
      }
    } else {
      unknown++;
    }
  }

  final decided = wins + losses + draws;
  return DashboardStats(
    gamesAnalyzed: games.length,
    wins: wins,
    losses: losses,
    draws: draws,
    unknownResult: unknown,
    totalBrilliants: brilliants,
    totalBlunders: blunders,
    totalMistakes: mistakes,
    totalInaccuracies: inaccuracies,
    qualityDistribution: qualityTotals,
    accuracyTrend: trend,
    winRate: decided == 0 ? 0 : (wins / decided) * 100,
    averageAccuracy: accuracySum / games.length,
    perspective: perspective,
  );
}

/// Paginated recent-games table state. Bumping the page is a pure
/// controller operation; the view pulls a slice via [visibleGames].
class DashboardPageController extends Notifier<int> {
  @override
  int build() => 0;

  void next() => state = state + 1;
  void prev() => state = (state - 1).clamp(0, 999);
  void reset() => state = 0;
}

final dashboardPageProvider =
    NotifierProvider<DashboardPageController, int>(
        DashboardPageController.new);

final dashboardVisibleGamesProvider = Provider<List<ArchivedGame>>((ref) {
  final games = ref.watch(archiveControllerProvider).games;
  final page = ref.watch(dashboardPageProvider);
  // Newest first for the table — the trend chart uses oldest-first.
  final sorted = [...games]
    ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
  final start = page * dashboardPageSize;
  if (start >= sorted.length) return const [];
  final end = (start + dashboardPageSize).clamp(0, sorted.length);
  return sorted.sublist(start, end);
});
