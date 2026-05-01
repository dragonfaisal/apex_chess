import 'package:apex_chess/features/global_dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:apex_chess/features/global_dashboard/presentation/views/global_dashboard_screen.dart';
import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';
import 'package:apex_chess/features/profile_stats/presentation/controllers/profile_stats_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Stats empty state is calm and has no large CTA button', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardStatsProvider.overrideWithValue(DashboardStats.empty()),
          liveProfileStatsProvider.overrideWith((ref) async {
            return ProfileStats.unknown(
              source: ProfileStatsSource.chessCom,
              username: 'ApexUser',
            );
          }),
        ],
        child: const MaterialApp(home: GlobalDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No analyzed stats yet.'), findsOneWidget);
    expect(find.text('Review games to build your dashboard.'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });
}
