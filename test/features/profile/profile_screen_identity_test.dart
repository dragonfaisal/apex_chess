import 'package:apex_chess/core/network/connectivity_models.dart';
import 'package:apex_chess/features/account/data/account_repository.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/profile/presentation/views/profile_screen.dart';
import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';
import 'package:apex_chess/features/profile_stats/presentation/controllers/profile_stats_controller.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('profile hero renders connected user and safe local actions', (
    tester,
  ) async {
    final container = await _containerWithAccount(
      stats: _stats(hasRatings: true),
      overrides: [
        connectionPresenceProvider.overrideWith(_OnlinePresenceController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('ApexUser'), findsOneWidget);
    expect(find.text('Chess.com'), findsOneWidget);
    expect(find.text(ApexCopy.connected), findsOneWidget);
    expect(find.text(ApexCopy.ratings.toUpperCase()), findsOneWidget);
    expect(find.text(ApexCopy.switchAccount.toUpperCase()), findsOneWidget);
    expect(find.text(ApexCopy.clearLocalData), findsOneWidget);
    expect(find.text('LOGOUT & WIPE LOCAL DATA'), findsNothing);
  });

  testWidgets('cached profile state renders saved data copy', (tester) async {
    final container = await _containerWithAccount(
      stats: _stats(hasRatings: false),
      overrides: [
        connectionPresenceProvider.overrideWith(_OfflinePresenceController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text(ApexCopy.showingSavedData), findsOneWidget);
    expect(find.text(ApexCopy.dashboardNoPublicData), findsOneWidget);
  });
}

Future<ProviderContainer> _containerWithAccount({
  required ProfileStats stats,
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({
    'apex.account.source': AccountSource.chessCom.wire,
    'apex.account.username': 'ApexUser',
    'apex.account.onboarding_seen': true,
  });
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      accountRepositoryProvider.overrideWithValue(
        AccountRepository(prefs: prefs),
      ),
      liveProfileStatsProvider.overrideWith((ref) async => stats),
      ...overrides,
    ],
  );
  await container.read(accountControllerProvider.future);
  return container;
}

Widget _host(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(theme: ApexTheme.dark, home: const ProfileScreen()),
  );
}

ProfileStats _stats({required bool hasRatings}) {
  return ProfileStats(
    source: ProfileStatsSource.chessCom,
    username: 'ApexUser',
    displayName: 'ApexUser',
    buckets: hasRatings
        ? const [
            RatingBucket(
              label: 'Blitz',
              rating: 1500,
              wins: 4,
              losses: 2,
              draws: 1,
            ),
          ]
        : const [],
  );
}

class _OfflinePresenceController extends ConnectionPresenceController {
  @override
  ApexConnectionPresence build() {
    return const ApexConnectionPresence(
      snapshot: ConnectivitySnapshot(network: NetworkAvailability.offline),
    );
  }
}

class _OnlinePresenceController extends ConnectionPresenceController {
  @override
  ApexConnectionPresence build() {
    return const ApexConnectionPresence(
      snapshot: ConnectivitySnapshot(
        network: NetworkAvailability.online,
        sync: SyncStatus.synced,
      ),
    );
  }
}
