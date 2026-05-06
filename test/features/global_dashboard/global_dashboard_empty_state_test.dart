import 'package:apex_chess/features/global_dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:apex_chess/features/global_dashboard/presentation/views/global_dashboard_screen.dart';
import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';
import 'package:apex_chess/features/profile_stats/presentation/controllers/profile_stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

DashboardStats _stats({int games = 2}) {
  return DashboardStats(
    gamesAnalyzed: games,
    wins: 1,
    losses: 1,
    draws: 0,
    unknownResult: 0,
    totalBrilliants: 0,
    totalBlunders: 1,
    totalMistakes: 0,
    totalInaccuracies: 0,
    totalMisses: 0,
    averageAcpl: 15,
    qualityDistribution: const {},
    moveQualityBreakdown: const {},
    accuracyTrend: const [82, 88],
    winRate: 50,
    averageAccuracy: 85,
    perspective: 'ApexUser',
  );
}

Future<void> _pumpStats(
  WidgetTester tester, {
  required DashboardStats activeStats,
  required DashboardStats allStats,
  ColorPerspective filter = ColorPerspective.all,
}) async {
  final container = ProviderContainer(
    overrides: [
      dashboardStatsProvider.overrideWithValue(activeStats),
      dashboardAllStatsProvider.overrideWithValue(allStats),
      liveProfileStatsProvider.overrideWith((ref) async {
        return ProfileStats.unknown(
          source: ProfileStatsSource.chessCom,
          username: 'ApexUser',
        );
      }),
    ],
  );
  addTearDown(container.dispose);
  container.read(dashboardColorFilterProvider.notifier).state = filter;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: GlobalDashboardScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Stats empty state is calm and has no large CTA button', (
    tester,
  ) async {
    await _pumpStats(
      tester,
      activeStats: DashboardStats.empty(),
      allStats: DashboardStats.empty(),
    );

    expect(find.text('No analyzed stats yet.'), findsOneWidget);
    expect(find.text('Review games to build your dashboard.'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('White filter empty state stays inline when All has games', (
    tester,
  ) async {
    await _pumpStats(
      tester,
      activeStats: DashboardStats.empty(),
      allStats: _stats(),
      filter: ColorPerspective.white,
    );

    expect(find.text('No White reviews yet.'), findsOneWidget);
    expect(
      find.text('Switch to All to view your analyzed games.'),
      findsOneWidget,
    );
    expect(find.text('No analyzed stats yet.'), findsNothing);
    expect(find.text('ALL'), findsOneWidget);
    expect(find.text('WHITE'), findsOneWidget);
    expect(find.text('BLACK'), findsOneWidget);
  });

  testWidgets('Black filter empty state stays inline when All has games', (
    tester,
  ) async {
    await _pumpStats(
      tester,
      activeStats: DashboardStats.empty(),
      allStats: _stats(),
      filter: ColorPerspective.black,
    );

    expect(find.text('No Black reviews yet.'), findsOneWidget);
    expect(find.text('No analyzed stats yet.'), findsNothing);
    expect(find.text('ALL'), findsOneWidget);
  });
}
