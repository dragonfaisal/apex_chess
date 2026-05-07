import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_quality_display.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/global_dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Stats aggregation maps totals and color scopes', () {
    final games = [
      _game(
        id: 'w1',
        white: 'ApexUser',
        black: 'OpponentA',
        result: '1-0',
        acpl: 12,
        qualities: const {MoveQuality.brilliant: 1, MoveQuality.blunder: 1},
      ),
      _game(
        id: 'b1',
        white: 'OpponentB',
        black: 'ApexUser',
        result: '1-0',
        acpl: 30,
        qualities: const {MoveQuality.missedWin: 2, MoveQuality.mistake: 1},
      ),
      _game(
        id: 'b2',
        white: 'OpponentC',
        black: 'ApexUser',
        result: '1/2-1/2',
        acpl: 20,
      ),
    ];

    final all = buildDashboardStatsForTesting(games, perspective: 'ApexUser');
    final white = buildDashboardStatsForTesting(
      games,
      perspective: 'ApexUser',
      filter: ColorPerspective.white,
    );
    final black = buildDashboardStatsForTesting(
      games,
      perspective: 'ApexUser',
      filter: ColorPerspective.black,
    );

    expect(all.gamesAnalyzed, 3);
    expect(all.wins, 1);
    expect(all.losses, 1);
    expect(all.draws, 1);
    expect(all.totalBrilliants, 1);
    expect(all.totalMisses, 2);
    expect(all.totalBlunders, 1);
    expect(all.averageAcpl, closeTo(20.666, 0.01));
    expect(white.gamesAnalyzed, 1);
    expect(white.wins, 1);
    expect(black.gamesAnalyzed, 2);
    expect(black.losses, 1);
    expect(black.draws, 1);
  });

  test('KPI and result split create archive filter intents', () {
    final stats = buildDashboardStatsForTesting([
      _game(id: 'w1', result: '1-0'),
      _game(id: 'l1', result: '0-1', qualities: const {MoveQuality.blunder: 2}),
    ], perspective: 'ApexUser');

    final kpis = buildDashboardKpis(stats);
    final losses = kpis.singleWhere((k) => k.label == 'Losses');
    final blunders = kpis.singleWhere((k) => k.label == 'Blunders');

    expect(
      losses.intent!.toArchiveFilters(perspective: 'ApexUser').result,
      ArchiveResultFilter.losses,
    );
    expect(
      blunders.intent!.toArchiveFilters().quality,
      ArchiveQualityFilter.blunder,
    );

    final split = buildResultSplitDisplay(stats);
    expect(split.total, 2);
    expect(split.segments.map((s) => s.label), ['Won', 'Draw', 'Lost']);
    expect(split.segments.first.fraction, 0.5);
    expect(
      split.segments.last.intent
          .toArchiveFilters(perspective: 'ApexUser')
          .result,
      ArchiveResultFilter.losses,
    );
  });

  test('Stats White scope plus Wins creates side and result filters', () {
    final stats = buildDashboardStatsForTesting(
      [_game(id: 'w1', white: 'ApexUser', black: 'Opponent', result: '1-0')],
      perspective: 'ApexUser',
      filter: ColorPerspective.white,
    );

    final wins = buildDashboardKpis(
      stats,
    ).singleWhere((k) => k.label == 'Wins');
    final filters = wins.intent!.toArchiveFilters(
      perspective: 'ApexUser',
      scope: ColorPerspective.white,
    );

    expect(filters.color, ArchiveColorFilter.white);
    expect(filters.result, ArchiveResultFilter.wins);
    expect(filters.perspective, 'ApexUser');
  });

  test('Stats Black scope plus Losses creates side and result filters', () {
    final stats = buildDashboardStatsForTesting(
      [_game(id: 'b1', white: 'Opponent', black: 'ApexUser', result: '1-0')],
      perspective: 'ApexUser',
      filter: ColorPerspective.black,
    );

    final losses = buildDashboardKpis(
      stats,
    ).singleWhere((k) => k.label == 'Losses');
    final filters = losses.intent!.toArchiveFilters(
      perspective: 'ApexUser',
      scope: ColorPerspective.black,
    );

    expect(filters.color, ArchiveColorFilter.black);
    expect(filters.result, ArchiveResultFilter.losses);
    expect(filters.perspective, 'ApexUser');
  });

  test('Stats White scope plus Blunders preserves side and quality', () {
    final stats = buildDashboardStatsForTesting(
      [
        _game(
          id: 'w1',
          white: 'ApexUser',
          black: 'Opponent',
          qualities: const {MoveQuality.blunder: 2},
        ),
      ],
      perspective: 'ApexUser',
      filter: ColorPerspective.white,
    );

    final blunders = buildDashboardKpis(
      stats,
    ).singleWhere((k) => k.label == 'Blunders');
    final filters = blunders.intent!.toArchiveFilters(
      perspective: 'ApexUser',
      scope: ColorPerspective.white,
    );

    expect(filters.color, ArchiveColorFilter.white);
    expect(filters.quality, ArchiveQualityFilter.blunder);
    expect(filters.perspective, 'ApexUser');
  });

  test('Opening archive intent preserves Black scope and opening query', () {
    const opening = OpeningStats(
      name: 'Giuoco Piano',
      eco: 'C50',
      wins: 0,
      losses: 1,
      draws: 0,
    );

    final filters = StatsArchiveFilterIntent.opening(
      opening,
    ).toArchiveFilters(perspective: 'ApexUser', scope: ColorPerspective.black);

    expect(filters.color, ArchiveColorFilter.black);
    expect(filters.search, 'C50');
    expect(filters.perspective, 'ApexUser');
  });

  test('Accuracy trend handles empty, one, and many games', () {
    expect(
      buildAccuracyTrendDisplay(DashboardStats.empty()).state,
      AccuracyTrendState.empty,
    );

    final one = buildDashboardStatsForTesting([_game(id: 'one')]);
    expect(buildAccuracyTrendDisplay(one).state, AccuracyTrendState.partial);

    final many = buildDashboardStatsForTesting([
      _game(id: 'one', analyzedAt: DateTime(2026, 5, 1), acpl: 30),
      _game(id: 'two', analyzedAt: DateTime(2026, 5, 2), acpl: 10),
    ]);
    final trend = buildAccuracyTrendDisplay(many);
    expect(trend.state, AccuracyTrendState.ready);
    expect(trend.points, [70, 90]);
  });

  test('Move quality breakdown renders all 10 public labels', () {
    final stats = buildDashboardStatsForTesting([
      _game(
        id: 'q1',
        qualities: const {
          MoveQuality.brilliant: 1,
          MoveQuality.great: 2,
          MoveQuality.best: 3,
          MoveQuality.excellent: 4,
          MoveQuality.good: 5,
          MoveQuality.book: 6,
          MoveQuality.inaccuracy: 7,
          MoveQuality.mistake: 8,
          MoveQuality.missedWin: 9,
          MoveQuality.blunder: 10,
          MoveQuality.forced: 11,
        },
      ),
    ]);

    final display = buildMoveQualityBreakdownDisplay(stats);
    expect(display.items.map((i) => i.label), [
      'Brilliant',
      'Great',
      'Best',
      'Excellent',
      'Good',
      'Book',
      'Inaccuracy',
      'Mistake',
      'Miss',
      'Blunder',
    ]);
    expect(display.items.any((i) => i.label == 'forced'), isFalse);
    expect(display.items.singleWhere((i) => i.label == 'Miss').count, 9);
    expect(display.items.singleWhere((i) => i.label == 'Mistake').count, 8);
    expect(
      display.items
          .singleWhere((i) => i.reviewLabel == ReviewMoveLabel.blunder)
          .intent!
          .toArchiveFilters()
          .quality,
      ArchiveQualityFilter.blunder,
    );
  });

  test('Opening performance aggregates known and unknown openings', () {
    final openings = buildOpeningStatsForTesting([
      _game(
        id: 'c45a',
        black: 'OpponentA',
        opening: 'Scotch Game',
        eco: 'C45',
        result: '1-0',
      ),
      _game(
        id: 'c45b',
        black: 'OpponentB',
        opening: 'Scotch Game',
        eco: 'C45',
        result: '0-1',
      ),
      _game(id: 'unknown', black: 'OpponentC', opening: null, eco: null),
    ], perspective: 'ApexUser');

    final scotch = openings.first;
    expect(scotch.eco, 'C45');
    expect(scotch.name, 'Scotch Game');
    expect(scotch.total, 2);
    expect(scotch.scoreRate, 50);
    expect(openings.last.name, 'Opening not detected');
    expect(
      StatsArchiveFilterIntent.opening(scotch).toArchiveFilters().search,
      'C45',
    );
  });

  test('Weak spots handle no games, side weakness, and opening weakness', () {
    expect(
      buildWeakSpotsForTesting(const []).single.title,
      'More games needed',
    );

    final spots = buildWeakSpotsForTesting([
      _game(
        id: 'white-1',
        white: 'ApexUser',
        black: 'OpponentA',
        result: '1-0',
        acpl: 8,
      ),
      _game(
        id: 'white-2',
        white: 'ApexUser',
        black: 'OpponentB',
        result: '1-0',
        acpl: 10,
      ),
      _game(
        id: 'black-1',
        white: 'OpponentC',
        black: 'ApexUser',
        result: '1-0',
        acpl: 35,
        opening: 'Giuoco Piano',
        eco: 'C50',
      ),
      _game(
        id: 'black-2',
        white: 'OpponentD',
        black: 'ApexUser',
        result: '1-0',
        acpl: 40,
        opening: 'Giuoco Piano',
        eco: 'C50',
      ),
    ], perspective: 'ApexUser');

    expect(spots.map((s) => s.title), contains('Black needs review'));
    expect(spots.map((s) => s.title), contains('C50 needs review'));
  });

  test('Recent scans pagination helpers expose usable next state', () {
    final games = [
      for (var i = 0; i < 12; i++)
        _game(id: 'g$i', analyzedAt: DateTime(2026, 5, i + 1)),
    ];

    final firstPage = dashboardVisibleGamesForTesting(games);

    expect(firstPage.length, dashboardPageSize);
    expect(dashboardHasNextPageForTesting(0, games.length), isTrue);
    expect(dashboardHasNextPageForTesting(1, games.length), isFalse);
  });

  test('Stats source filter distinguishes analyzed games by source', () {
    final games = [
      _game(id: 'chess', source: ArchiveSource.chessCom),
      _game(id: 'lichess', source: ArchiveSource.lichess),
      _game(id: 'pgn', source: ArchiveSource.pgn),
    ];

    expect(
      buildDashboardStatsForTesting(
        games,
        source: ArchiveSource.chessCom,
      ).gamesAnalyzed,
      1,
    );
    expect(
      buildDashboardStatsForTesting(
        games,
        source: ArchiveSource.lichess,
      ).gamesAnalyzed,
      1,
    );
    expect(
      buildDashboardStatsForTesting(
        games,
        source: ArchiveSource.pgn,
      ).gamesAnalyzed,
      1,
    );
  });

  test('Stats source filter combines with color filter using AND logic', () {
    final games = [
      _game(id: 'match', source: ArchiveSource.lichess, white: 'ApexUser'),
      _game(
        id: 'wrong-source',
        source: ArchiveSource.chessCom,
        white: 'ApexUser',
      ),
      _game(
        id: 'wrong-side',
        source: ArchiveSource.lichess,
        white: 'Opponent',
        black: 'ApexUser',
      ),
    ];

    final stats = buildDashboardStatsForTesting(
      games,
      perspective: 'ApexUser',
      filter: ColorPerspective.white,
      source: ArchiveSource.lichess,
    );

    expect(stats.gamesAnalyzed, 1);
  });

  test('Stats Recent Scans collapses duplicate saved reviews by game key', () {
    const pgn = '''
[Event "Duplicate"]
[White "ApexUser"]
[Black "Opponent"]
[Result "1-0"]

1. e4 e5 *
''';
    final games = [
      _game(
        id: 'fast',
        pgn: pgn,
        acpl: 30,
        analyzedAt: DateTime(2026, 5, 1),
        analysisMode: AnalysisMode.quick,
        analysisProfileId: 'fast_review',
      ),
      _game(
        id: 'deep',
        pgn: pgn,
        acpl: 12,
        analyzedAt: DateTime(2026, 5, 2),
        analysisMode: AnalysisMode.deep,
        analysisProfileId: 'deep_review',
      ),
    ];

    final stats = buildDashboardStatsForTesting(games, perspective: 'ApexUser');
    final recent = dashboardVisibleGamesForTesting(
      games,
      perspective: 'ApexUser',
    );

    expect(stats.gamesAnalyzed, 1);
    expect(recent, hasLength(1));
    expect(recent.single.id, 'deep');
    expect(recent.single.reviewModeLabel, 'Deep');
  });

  test('Player search state separates public profile from Apex stats', () {
    const public = ProfileStats(
      source: ProfileStatsSource.chessCom,
      username: 'ALFAISALpro',
      displayName: 'ALFAISALpro',
      buckets: [
        RatingBucket(
          label: 'Blitz',
          rating: 1200,
          wins: 10,
          losses: 8,
          draws: 2,
        ),
      ],
    );
    const state = DashboardPlayerSearchState(
      username: 'ALFAISALpro',
      result: public,
      hasSearched: true,
      isConnectedAccount: true,
    );
    final local = buildDashboardStatsForTesting([
      _game(id: 'local', white: 'ALFAISALpro', black: 'Opponent'),
    ], perspective: public.username);

    expect(state.isConnectedAccount, isTrue);
    expect(ApexCopy.connectedAccountNotice, 'This is your account');
    expect(public.totalGames, 20);
    expect(local.gamesAnalyzed, 1);
    expect(local.perspective, public.username);
  });
}

ArchivedGame _game({
  required String id,
  String white = 'ApexUser',
  String black = 'Opponent',
  String result = '1-0',
  double acpl = 15,
  DateTime? analyzedAt,
  String? opening = 'Scotch Game',
  String? eco = 'C45',
  Map<MoveQuality, int> qualities = const {},
  ArchiveSource source = ArchiveSource.chessCom,
  String? pgn,
  AnalysisMode analysisMode = AnalysisMode.deep,
  String? analysisProfileId,
}) {
  return ArchivedGame(
    id: id,
    source: source,
    white: white,
    black: black,
    result: result,
    analyzedAt: analyzedAt ?? DateTime(2026, 5, 1),
    depth: 18,
    pgn:
        pgn ??
        '''
[Event "$id"]
[White "$white"]
[Black "$black"]
[Result "$result"]

1. e4 *
''',
    qualityCounts: qualities,
    averageCpLoss: acpl,
    totalPlies: 40,
    openingName: opening,
    ecoCode: eco,
    analysisMode: analysisMode,
    analysisProfileId: analysisProfileId,
  );
}
