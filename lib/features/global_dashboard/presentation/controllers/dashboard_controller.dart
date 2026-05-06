/// Aggregates the ArchivedGame list into the numbers, buckets, and
/// series the Global Dashboard screen renders.
///
/// Pure view-model logic — no I/O, no engine — so the dashboard
/// updates in real time as new games are analysed (ArchiveController
/// is the source of truth and refreshes on save).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_quality_display.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';
import 'package:apex_chess/features/profile_stats/presentation/controllers/profile_stats_controller.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/identity/apex_identity_matcher.dart';

/// Which side the user wants to inspect. Drives every derived stat on
/// the Stats dashboard so the pie, trend, and opening table all respect
/// the same filter toggle.
enum ColorPerspective { all, white, black }

/// Single row in the opening-performance table. Sorted by frequency first,
/// then score rate so common useful lines stay visible.
class OpeningStats {
  const OpeningStats({
    required this.name,
    required this.eco,
    required this.wins,
    required this.losses,
    required this.draws,
  });

  final String name;
  final String? eco;
  final int wins;
  final int losses;
  final int draws;

  int get total => wins + losses + draws;
  double get winRate => total == 0 ? 0 : (wins / total) * 100;
  double get scoreRate => total == 0 ? 0 : ((wins + draws * 0.5) / total) * 100;
  double get lossRate => total == 0 ? 0 : (losses / total) * 100;
}

class StatsArchiveFilterIntent {
  const StatsArchiveFilterIntent({
    this.result = ArchiveResultFilter.any,
    this.color = ArchiveColorFilter.any,
    this.quality = ArchiveQualityFilter.any,
    this.search = '',
    this.sort = ArchiveSort.newest,
    this.minBrilliants = 0,
  });

  factory StatsArchiveFilterIntent.result(ArchiveResultFilter result) =>
      StatsArchiveFilterIntent(result: result);

  factory StatsArchiveFilterIntent.side(ColorPerspective perspective) =>
      StatsArchiveFilterIntent(
        color: perspective == ColorPerspective.white
            ? ArchiveColorFilter.white
            : ArchiveColorFilter.black,
      );

  factory StatsArchiveFilterIntent.quality(ArchiveQualityFilter quality) =>
      StatsArchiveFilterIntent(
        quality: quality,
        sort: quality == ArchiveQualityFilter.blunder
            ? ArchiveSort.mostBlunders
            : quality == ArchiveQualityFilter.brilliant
            ? ArchiveSort.mostBrilliants
            : ArchiveSort.newest,
        minBrilliants: quality == ArchiveQualityFilter.brilliant ? 1 : 0,
      );

  factory StatsArchiveFilterIntent.opening(OpeningStats opening) =>
      StatsArchiveFilterIntent(
        search: (opening.eco?.trim().isNotEmpty == true
            ? opening.eco!.trim()
            : opening.name),
      );

  final ArchiveResultFilter result;
  final ArchiveColorFilter color;
  final ArchiveQualityFilter quality;
  final String search;
  final ArchiveSort sort;
  final int minBrilliants;

  ArchiveFilters toArchiveFilters({
    String? perspective,
    ColorPerspective scope = ColorPerspective.all,
  }) {
    final scopedColor = color == ArchiveColorFilter.any
        ? switch (scope) {
            ColorPerspective.white => ArchiveColorFilter.white,
            ColorPerspective.black => ArchiveColorFilter.black,
            ColorPerspective.all => ArchiveColorFilter.any,
          }
        : color;
    final needsPerspective =
        result != ArchiveResultFilter.any ||
        scopedColor != ArchiveColorFilter.any;
    return ArchiveFilters(
      result: result,
      perspective: needsPerspective ? perspective : null,
      color: scopedColor,
      quality: quality,
      search: search,
      sort: sort,
      minBrilliants: minBrilliants,
    );
  }
}

class DashboardKpiDisplay {
  const DashboardKpiDisplay({
    required this.label,
    required this.value,
    required this.count,
    this.intent,
    this.emptyNotice,
  });

  final String label;
  final String value;
  final int count;
  final StatsArchiveFilterIntent? intent;
  final String? emptyNotice;

  bool get isActionable => intent != null;
}

class ResultSplitSegment {
  const ResultSplitSegment({
    required this.label,
    required this.count,
    required this.fraction,
    required this.intent,
    required this.emptyNotice,
  });

  final String label;
  final int count;
  final double fraction;
  final StatsArchiveFilterIntent intent;
  final String emptyNotice;
}

class ResultSplitDisplay {
  const ResultSplitDisplay({required this.total, required this.segments});

  final int total;
  final List<ResultSplitSegment> segments;

  bool get hasGames => total > 0;
}

enum AccuracyTrendState { empty, partial, ready }

class AccuracyTrendDisplay {
  const AccuracyTrendDisplay({required this.state, required this.points});

  final AccuracyTrendState state;
  final List<double> points;

  bool get canChart => state == AccuracyTrendState.ready;
}

class MoveQualityBreakdownItem {
  const MoveQualityBreakdownItem({
    required this.label,
    required this.count,
    required this.percent,
    required this.reviewLabel,
    this.intent,
  });

  final String label;
  final int count;
  final double percent;
  final ReviewMoveLabel reviewLabel;
  final StatsArchiveFilterIntent? intent;
}

class MoveQualityBreakdownDisplay {
  const MoveQualityBreakdownDisplay({required this.items, required this.total});

  final List<MoveQualityBreakdownItem> items;
  final int total;

  bool get hasMoves => total > 0;
}

class WeakSpotDisplay {
  const WeakSpotDisplay({
    required this.title,
    required this.subtitle,
    this.intent,
    this.count = 0,
  });

  final String title;
  final String subtitle;
  final StatsArchiveFilterIntent? intent;
  final int count;
}

/// Active color filter for the dashboard. Persisted across the session
/// only — a fresh app launch starts on [ColorPerspective.all].
final dashboardColorFilterProvider = StateProvider<ColorPerspective>(
  (_) => ColorPerspective.all,
);

final dashboardInlineNoticeProvider = StateProvider<String?>((_) => null);

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
    required this.totalMisses,
    required this.averageAcpl,
    required this.qualityDistribution,
    required this.moveQualityBreakdown,
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
    totalMisses: 0,
    averageAcpl: 0,
    qualityDistribution: {},
    moveQualityBreakdown: {},
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
  final int totalMisses;
  final double averageAcpl;
  final Map<MoveQuality, int> qualityDistribution;
  final Map<ReviewMoveLabel, int> moveQualityBreakdown;

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

class DashboardPlayerSearchState {
  const DashboardPlayerSearchState({
    this.source = ProfileStatsSource.chessCom,
    this.username = '',
    this.isLoading = false,
    this.result,
    this.error,
    this.hasSearched = false,
    this.isConnectedAccount = false,
  });

  final ProfileStatsSource source;
  final String username;
  final bool isLoading;
  final ProfileStats? result;
  final String? error;
  final bool hasSearched;
  final bool isConnectedAccount;

  DashboardPlayerSearchState copyWith({
    ProfileStatsSource? source,
    String? username,
    bool? isLoading,
    ProfileStats? result,
    String? error,
    bool clearResult = false,
    bool clearError = false,
    bool? hasSearched,
    bool? isConnectedAccount,
  }) {
    return DashboardPlayerSearchState(
      source: source ?? this.source,
      username: username ?? this.username,
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      hasSearched: hasSearched ?? this.hasSearched,
      isConnectedAccount: isConnectedAccount ?? this.isConnectedAccount,
    );
  }
}

class DashboardPlayerSearchController
    extends Notifier<DashboardPlayerSearchState> {
  int _generation = 0;

  @override
  DashboardPlayerSearchState build() => const DashboardPlayerSearchState();

  void setSource(ProfileStatsSource source) {
    if (source == state.source) return;
    _generation++;
    state = state.copyWith(
      source: source,
      isLoading: false,
      clearError: true,
      clearResult: true,
      hasSearched: false,
      isConnectedAccount: false,
    );
  }

  void setUsername(String username) {
    state = state.copyWith(
      username: username,
      clearError: true,
      isConnectedAccount: false,
    );
  }

  Future<void> search() async {
    final username = state.username.trim();
    if (username.isEmpty) return;
    final account = ref.read(accountControllerProvider).valueOrNull;
    final identity = const ApexIdentityMatcher().resolveOpponentQuery(
      query: username,
      platform: state.source.name,
      connectedAccount: account == null
          ? null
          : ApexIdentityCandidate(
              handle: account.username,
              platform: account.source.wire == 'lichess'
                  ? ProfileStatsSource.lichess.name
                  : ProfileStatsSource.chessCom.name,
            ),
      excludeConnectedAccount: true,
    );
    if (identity.isAmbiguous) {
      state = state.copyWith(
        isLoading: false,
        error: identity.copy,
        clearResult: true,
        hasSearched: true,
        isConnectedAccount: false,
      );
      return;
    }
    final isConnectedAccount = identity.isConfirmedUser;
    final gen = ++_generation;
    final service = ref
        .read(serviceHealthServiceProvider)
        .serviceForProfileSource(state.source);
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearResult: true,
      hasSearched: true,
      isConnectedAccount: isConnectedAccount,
    );
    try {
      final online = await ref
          .read(connectionPresenceProvider.notifier)
          .ensureOnlineForAction();
      if (gen != _generation) return;
      if (!online) {
        state = state.copyWith(isLoading: false, error: ApexCopy.offline);
        return;
      }
      final result = await ref
          .read(profileStatsServiceProvider)
          .fetchStrict(source: state.source, username: username);
      if (gen != _generation) return;
      ref
          .read(connectionPresenceProvider.notifier)
          .markServiceAvailable(service);
      state = state.copyWith(isLoading: false, result: result);
    } on ProfileStatsException catch (e) {
      if (gen != _generation) return;
      final resolved = await ref
          .read(connectionPresenceProvider.notifier)
          .resolveServiceFailure(
            service: service,
            message: e.message,
            availability: e.availability,
          );
      if (gen != _generation) return;
      state = state.copyWith(isLoading: false, error: resolved);
    } catch (_) {
      if (gen != _generation) return;
      final resolved = await ref
          .read(connectionPresenceProvider.notifier)
          .resolveServiceFailure(
            service: service,
            message: ApexCopy.profileUnavailable,
          );
      if (gen != _generation) return;
      state = state.copyWith(isLoading: false, error: resolved);
    }
  }
}

final dashboardPlayerSearchProvider =
    NotifierProvider<
      DashboardPlayerSearchController,
      DashboardPlayerSearchState
    >(DashboardPlayerSearchController.new);

/// Games-per-page for the recent-games table at the bottom of the
/// dashboard. Kept small so the table stays above the fold on phones.
const int dashboardPageSize = 10;

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final archive = ref.watch(archiveControllerProvider);
  final account = ref.watch(accountControllerProvider).valueOrNull;
  final filter = ref.watch(dashboardColorFilterProvider);
  return _buildStats(archive.games, account?.username, filter);
});

/// Baseline stats with no color filter. The view uses this to separate
/// "no analyzed games anywhere" from "this specific color filter is
/// empty".
final dashboardAllStatsProvider = Provider<DashboardStats>((ref) {
  final archive = ref.watch(archiveControllerProvider);
  final account = ref.watch(accountControllerProvider).valueOrNull;
  return _buildStats(archive.games, account?.username, ColorPerspective.all);
});

/// Top openings for the active perspective. Sorted desc by total
/// games played so the most-seen lines live at the top.
final openingStatsProvider = Provider<List<OpeningStats>>((ref) {
  final games = ref.watch(archiveControllerProvider).games;
  final me = ref.watch(accountControllerProvider).valueOrNull?.username;
  final filter = ref.watch(dashboardColorFilterProvider);
  return _buildOpeningStats(games, me, filter);
});

final dashboardWeakSpotsProvider = Provider<List<WeakSpotDisplay>>((ref) {
  final games = ref.watch(archiveControllerProvider).games;
  final me = ref.watch(accountControllerProvider).valueOrNull?.username;
  final filter = ref.watch(dashboardColorFilterProvider);
  return _buildWeakSpots(games, me, filter);
});

/// Whether [g] is from the user's perspective according to [filter].
/// Returns null when the game has no identifiable user side so the
/// caller can drop it from filtered views without double-counting.
bool? _gameMatchesColor({
  required ArchivedGame g,
  required String? me,
  required ColorPerspective filter,
}) {
  if (filter == ColorPerspective.all) return true;
  if (me == null || me.isEmpty) return null;
  final meL = me.toLowerCase();
  final whiteIsMe = g.white.toLowerCase() == meL;
  final blackIsMe = g.black.toLowerCase() == meL;
  if (!whiteIsMe && !blackIsMe) return null;
  return switch (filter) {
    ColorPerspective.white => whiteIsMe,
    ColorPerspective.black => blackIsMe,
    ColorPerspective.all => true,
  };
}

DashboardStats _buildStats(
  List<ArchivedGame> games,
  String? perspective,
  ColorPerspective filter,
) {
  if (games.isEmpty) return DashboardStats.empty();
  // Oldest-first so the trend series reads left-to-right in time.
  final ordered = [...games]
    ..sort((a, b) => a.analyzedAt.compareTo(b.analyzedAt));

  int wins = 0, losses = 0, draws = 0, unknown = 0;
  int brilliants = 0, blunders = 0, mistakes = 0, inaccuracies = 0, misses = 0;
  int countedGames = 0;
  final qualityTotals = <MoveQuality, int>{};
  final displayQualityTotals = <ReviewMoveLabel, int>{};
  final trend = <double>[];
  double accuracySum = 0;
  double acplSum = 0;

  final me = perspective?.toLowerCase();
  for (final g in ordered) {
    final match = _gameMatchesColor(g: g, me: me, filter: filter);
    if (match == null) continue; // handle-less game dropped under filter
    if (match == false) continue; // wrong color for the active filter

    countedGames++;
    brilliants += g.brilliantCount;
    blunders += g.blunderCount;
    mistakes += g.mistakeCount;
    inaccuracies += g.inaccuracyCount;
    misses += g.missCount;
    for (final entry in g.qualityCountsLive.entries) {
      qualityTotals[entry.key] = (qualityTotals[entry.key] ?? 0) + entry.value;
    }
    for (final entry in g.displayQualityCountsLive.entries) {
      displayQualityTotals[entry.key] =
          (displayQualityTotals[entry.key] ?? 0) + entry.value;
    }
    // Accuracy clamps to a sensible band — a bad game doesn't have
    // negative accuracy, and a flawless one caps at 100.
    final acc = (100 - g.averageCpLoss).clamp(0, 100).toDouble();
    trend.add(acc);
    accuracySum += acc;
    acplSum += g.averageCpLoss;

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

  if (countedGames == 0) return DashboardStats.empty();

  final decided = wins + losses + draws;
  return DashboardStats(
    gamesAnalyzed: countedGames,
    wins: wins,
    losses: losses,
    draws: draws,
    unknownResult: unknown,
    totalBrilliants: brilliants,
    totalBlunders: blunders,
    totalMistakes: mistakes,
    totalInaccuracies: inaccuracies,
    totalMisses: misses,
    averageAcpl: acplSum / countedGames,
    qualityDistribution: qualityTotals,
    moveQualityBreakdown: displayQualityTotals,
    accuracyTrend: trend,
    winRate: decided == 0 ? 0 : (wins / decided) * 100,
    averageAccuracy: accuracySum / countedGames,
    perspective: perspective,
  );
}

List<OpeningStats> _buildOpeningStats(
  List<ArchivedGame> games,
  String? me,
  ColorPerspective filter,
) {
  if (games.isEmpty) return const [];
  final buckets = <String, _OpeningAccum>{};
  final meL = me?.toLowerCase();
  for (final g in games) {
    final hasOpening = g.openingName?.trim().isNotEmpty == true;
    final name = hasOpening
        ? g.openingName!.trim()
        : ApexCopy.openingNotDetected;
    final key = hasOpening
        ? '${g.ecoCode ?? ''}|$name'
        : ApexCopy.openingNotDetected;
    final match = _gameMatchesColor(g: g, me: meL, filter: filter);
    if (match == null || match == false) continue;

    final bucket = buckets.putIfAbsent(
      key,
      () => _OpeningAccum(name: name, eco: g.ecoCode),
    );
    if (meL == null || meL.isEmpty) {
      bucket.draws++; // no perspective, treat each game neutrally
      continue;
    }
    final whiteIsMe = g.white.toLowerCase() == meL;
    final blackIsMe = g.black.toLowerCase() == meL;
    if (!whiteIsMe && !blackIsMe) continue;
    switch (g.result) {
      case '1-0':
        whiteIsMe ? bucket.wins++ : bucket.losses++;
      case '0-1':
        blackIsMe ? bucket.wins++ : bucket.losses++;
      case '1/2-1/2':
        bucket.draws++;
    }
  }
  final out =
      buckets.values
          .map(
            (b) => OpeningStats(
              name: b.name,
              eco: b.eco,
              wins: b.wins,
              losses: b.losses,
              draws: b.draws,
            ),
          )
          .toList()
        ..sort((a, b) {
          final aKnown = a.name != ApexCopy.openingNotDetected;
          final bKnown = b.name != ApexCopy.openingNotDetected;
          if (aKnown != bKnown) return aKnown ? -1 : 1;
          final totalCmp = b.total.compareTo(a.total);
          if (totalCmp != 0) return totalCmp;
          return b.scoreRate.compareTo(a.scoreRate);
        });
  return out;
}

class _OpeningAccum {
  _OpeningAccum({required this.name, required this.eco});
  final String name;
  final String? eco;
  int wins = 0;
  int losses = 0;
  int draws = 0;
}

List<DashboardKpiDisplay> buildDashboardKpis(DashboardStats stats) => [
  DashboardKpiDisplay(
    label: 'Games',
    value: '${stats.gamesAnalyzed}',
    count: stats.gamesAnalyzed,
    intent: const StatsArchiveFilterIntent(),
  ),
  DashboardKpiDisplay(
    label: 'Avg Accuracy',
    value: stats.hasData ? '${stats.averageAccuracy.toStringAsFixed(1)}%' : '—',
    count: stats.gamesAnalyzed,
  ),
  DashboardKpiDisplay(
    label: 'Wins',
    value: '${stats.wins}',
    count: stats.wins,
    intent: StatsArchiveFilterIntent.result(ArchiveResultFilter.wins),
    emptyNotice: 'No wins yet',
  ),
  DashboardKpiDisplay(
    label: 'Losses',
    value: '${stats.losses}',
    count: stats.losses,
    intent: StatsArchiveFilterIntent.result(ArchiveResultFilter.losses),
    emptyNotice: 'No losses yet',
  ),
  DashboardKpiDisplay(
    label: 'Draws',
    value: '${stats.draws}',
    count: stats.draws,
    intent: StatsArchiveFilterIntent.result(ArchiveResultFilter.draws),
    emptyNotice: 'No draws yet',
  ),
  DashboardKpiDisplay(
    label: 'Brilliants',
    value: '${stats.totalBrilliants}',
    count: stats.totalBrilliants,
    intent: StatsArchiveFilterIntent.quality(ArchiveQualityFilter.brilliant),
    emptyNotice: 'No Brilliant reviews yet',
  ),
  DashboardKpiDisplay(
    label: 'Misses',
    value: '${stats.totalMisses}',
    count: stats.totalMisses,
    intent: StatsArchiveFilterIntent.quality(ArchiveQualityFilter.miss),
    emptyNotice: 'No Miss reviews yet',
  ),
  DashboardKpiDisplay(
    label: 'Blunders',
    value: '${stats.totalBlunders}',
    count: stats.totalBlunders,
    intent: StatsArchiveFilterIntent.quality(ArchiveQualityFilter.blunder),
    emptyNotice: 'No Blunder reviews yet',
  ),
  DashboardKpiDisplay(
    label: 'Avg ACPL',
    value: stats.hasData ? stats.averageAcpl.toStringAsFixed(1) : '—',
    count: stats.gamesAnalyzed,
  ),
];

ResultSplitDisplay buildResultSplitDisplay(DashboardStats stats) {
  final total = stats.wins + stats.draws + stats.losses;
  double fraction(int count) => total == 0 ? 0 : count / total;
  return ResultSplitDisplay(
    total: total,
    segments: [
      ResultSplitSegment(
        label: 'Won',
        count: stats.wins,
        fraction: fraction(stats.wins),
        intent: StatsArchiveFilterIntent.result(ArchiveResultFilter.wins),
        emptyNotice: 'No wins yet',
      ),
      ResultSplitSegment(
        label: 'Draw',
        count: stats.draws,
        fraction: fraction(stats.draws),
        intent: StatsArchiveFilterIntent.result(ArchiveResultFilter.draws),
        emptyNotice: 'No draws yet',
      ),
      ResultSplitSegment(
        label: 'Lost',
        count: stats.losses,
        fraction: fraction(stats.losses),
        intent: StatsArchiveFilterIntent.result(ArchiveResultFilter.losses),
        emptyNotice: 'No losses yet',
      ),
    ],
  );
}

AccuracyTrendDisplay buildAccuracyTrendDisplay(DashboardStats stats) {
  if (stats.accuracyTrend.isEmpty) {
    return const AccuracyTrendDisplay(
      state: AccuracyTrendState.empty,
      points: [],
    );
  }
  if (stats.accuracyTrend.length == 1) {
    return AccuracyTrendDisplay(
      state: AccuracyTrendState.partial,
      points: stats.accuracyTrend,
    );
  }
  return AccuracyTrendDisplay(
    state: AccuracyTrendState.ready,
    points: stats.accuracyTrend,
  );
}

MoveQualityBreakdownDisplay buildMoveQualityBreakdownDisplay(
  DashboardStats stats,
) {
  final total = MoveQualityDisplay.countOrder.fold<int>(
    0,
    (sum, label) => sum + (stats.moveQualityBreakdown[label] ?? 0),
  );
  final items = [
    for (final label in MoveQualityDisplay.countOrder)
      MoveQualityBreakdownItem(
        label: label.label,
        count: stats.moveQualityBreakdown[label] ?? 0,
        percent: total == 0
            ? 0
            : (stats.moveQualityBreakdown[label] ?? 0) / total,
        reviewLabel: label,
        intent: switch (label) {
          ReviewMoveLabel.brilliant => StatsArchiveFilterIntent.quality(
            ArchiveQualityFilter.brilliant,
          ),
          ReviewMoveLabel.miss => StatsArchiveFilterIntent.quality(
            ArchiveQualityFilter.miss,
          ),
          ReviewMoveLabel.blunder => StatsArchiveFilterIntent.quality(
            ArchiveQualityFilter.blunder,
          ),
          _ => null,
        },
      ),
  ];
  return MoveQualityBreakdownDisplay(items: items, total: total);
}

List<WeakSpotDisplay> _buildWeakSpots(
  List<ArchivedGame> games,
  String? perspective,
  ColorPerspective filter,
) {
  final stats = _buildStats(games, perspective, filter);
  if (stats.gamesAnalyzed < 2) {
    return const [
      WeakSpotDisplay(title: 'More games needed', subtitle: 'Review next'),
    ];
  }

  final spots = <WeakSpotDisplay>[];
  if (stats.totalBlunders >= 2) {
    spots.add(
      WeakSpotDisplay(
        title: 'Blunders need review',
        subtitle: '${stats.totalBlunders} found',
        intent: StatsArchiveFilterIntent.quality(ArchiveQualityFilter.blunder),
        count: stats.totalBlunders,
      ),
    );
  }
  if (stats.totalMisses >= 2) {
    spots.add(
      WeakSpotDisplay(
        title: 'Misses need review',
        subtitle: '${stats.totalMisses} found',
        intent: StatsArchiveFilterIntent.quality(ArchiveQualityFilter.miss),
        count: stats.totalMisses,
      ),
    );
  }

  final openings = _buildOpeningStats(games, perspective, filter);
  OpeningStats? weakOpening;
  for (final opening in openings) {
    if (opening.total >= 2 && opening.lossRate >= 50) {
      weakOpening = opening;
      break;
    }
  }
  if (weakOpening != null) {
    spots.add(
      WeakSpotDisplay(
        title:
            '${weakOpening.eco?.trim().isNotEmpty == true ? weakOpening.eco : weakOpening.name} needs review',
        subtitle: 'Opening Performance',
        intent: StatsArchiveFilterIntent.opening(weakOpening),
        count: weakOpening.total,
      ),
    );
  }

  if (filter == ColorPerspective.all &&
      perspective?.trim().isNotEmpty == true) {
    final white = _buildStats(games, perspective, ColorPerspective.white);
    final black = _buildStats(games, perspective, ColorPerspective.black);
    if (white.gamesAnalyzed >= 2 && black.gamesAnalyzed >= 2) {
      final weakerSide = black.averageAccuracy + 4 < white.averageAccuracy
          ? ColorPerspective.black
          : white.averageAccuracy + 4 < black.averageAccuracy
          ? ColorPerspective.white
          : null;
      if (weakerSide != null) {
        spots.add(
          WeakSpotDisplay(
            title: weakerSide == ColorPerspective.black
                ? 'Black needs review'
                : 'White needs review',
            subtitle: 'Side results',
            intent: StatsArchiveFilterIntent.side(weakerSide),
          ),
        );
      }
    }
  }

  if (spots.isEmpty) {
    return const [
      WeakSpotDisplay(title: 'More games needed', subtitle: 'Review next'),
    ];
  }
  return spots.take(3).toList();
}

DashboardStats buildDashboardStatsForTesting(
  List<ArchivedGame> games, {
  String? perspective,
  ColorPerspective filter = ColorPerspective.all,
}) => _buildStats(games, perspective, filter);

List<OpeningStats> buildOpeningStatsForTesting(
  List<ArchivedGame> games, {
  String? perspective,
  ColorPerspective filter = ColorPerspective.all,
}) => _buildOpeningStats(games, perspective, filter);

List<WeakSpotDisplay> buildWeakSpotsForTesting(
  List<ArchivedGame> games, {
  String? perspective,
  ColorPerspective filter = ColorPerspective.all,
}) => _buildWeakSpots(games, perspective, filter);

List<ArchivedGame> dashboardVisibleGamesForTesting(
  List<ArchivedGame> games, {
  String? perspective,
  ColorPerspective filter = ColorPerspective.all,
  int page = 0,
}) {
  final me = perspective?.toLowerCase();
  final filtered = games.where((g) {
    final match = _gameMatchesColor(g: g, me: me, filter: filter);
    return match == true;
  }).toList();
  final sorted = [...filtered]
    ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
  final start = page * dashboardPageSize;
  if (start >= sorted.length) return const [];
  final end = (start + dashboardPageSize).clamp(0, sorted.length);
  return sorted.sublist(start, end);
}

bool dashboardHasNextPageForTesting(int page, int total) =>
    (page + 1) * dashboardPageSize < total;

/// Paginated recent-games table state. Bumping the page is a pure
/// controller operation; the view pulls a slice via [visibleGames].
class DashboardPageController extends Notifier<int> {
  @override
  int build() => 0;

  void next() => state = state + 1;
  void prev() => state = (state - 1).clamp(0, 999);
  void reset() => state = 0;
}

final dashboardPageProvider = NotifierProvider<DashboardPageController, int>(
  DashboardPageController.new,
);

final dashboardVisibleGamesProvider = Provider<List<ArchivedGame>>((ref) {
  final games = ref.watch(archiveControllerProvider).games;
  final account = ref.watch(accountControllerProvider).valueOrNull;
  final filter = ref.watch(dashboardColorFilterProvider);
  final page = ref.watch(dashboardPageProvider);
  return dashboardVisibleGamesForTesting(
    games,
    perspective: account?.username,
    filter: filter,
    page: page,
  );
});
