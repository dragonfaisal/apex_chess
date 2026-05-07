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
      statsLoader: () async => _stats(hasRatings: true),
      overrides: [
        connectionPresenceProvider.overrideWith(_OnlinePresenceController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('ApexUser'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('Chess.com'), findsOneWidget);
    expect(find.text(ApexCopy.connected), findsOneWidget);
    expect(find.text(ApexCopy.ratings.toUpperCase()), findsOneWidget);
    expect(find.text(ApexCopy.switchAccount.toUpperCase()), findsOneWidget);
    expect(find.text(ApexCopy.clearLocalData), findsOneWidget);
    expect(find.text('LOGOUT & WIPE LOCAL DATA'), findsNothing);
  });

  testWidgets('cached profile state renders saved data copy', (tester) async {
    final container = await _containerWithAccount(
      statsLoader: () async => _stats(hasRatings: false),
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

  testWidgets('offline cached avatar still displays safely', (tester) async {
    final container = await _containerWithAccount(
      statsLoader: () async => _stats(hasRatings: false),
      cachedAvatarUrl: 'https://example.com/avatar.png',
      overrides: [
        connectionPresenceProvider.overrideWith(_OfflinePresenceController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey('apex-avatar-network-apexuser')),
      findsOneWidget,
    );
    expect(find.text(ApexCopy.showingSavedData), findsOneWidget);
  });

  testWidgets('ratings unavailable state is calm', (tester) async {
    final container = await _containerWithAccount(
      statsLoader: () async => _stats(hasRatings: false),
      overrides: [
        connectionPresenceProvider.overrideWith(_OnlinePresenceController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text(ApexCopy.dashboardNoPublicData), findsOneWidget);
    expect(find.text(ApexCopy.tryAgain), findsNothing);
  });

  testWidgets('long username is safe in profile hero', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final container = await _containerWithAccount(
      username: 'VeryVeryLongConnectedUsernameThatShouldNotOverflowProfile',
      statsLoader: () async => _stats(
        hasRatings: false,
        username: 'VeryVeryLongConnectedUsernameThatShouldNotOverflowProfile',
      ),
      overrides: [
        connectionPresenceProvider.overrideWith(_OnlinePresenceController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(tester.takeException(), isNull);
  });

  testWidgets('profile build does not repeatedly fetch live stats', (
    tester,
  ) async {
    var fetches = 0;
    final container = await _containerWithAccount(
      statsLoader: () async {
        fetches++;
        return _stats(hasRatings: true);
      },
      overrides: [
        connectionPresenceProvider.overrideWith(_OnlinePresenceController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(_host(container));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpWidget(_host(container));
    await tester.pump();

    expect(fetches, 1);
  });
}

Future<ProviderContainer> _containerWithAccount({
  required Future<ProfileStats> Function() statsLoader,
  String username = 'ApexUser',
  String? cachedAvatarUrl,
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({
    'apex.account.source': AccountSource.chessCom.wire,
    'apex.account.username': username,
    'apex.account.onboarding_seen': true,
  });
  final prefs = await SharedPreferences.getInstance();
  final repo = AccountRepository(prefs: prefs);
  if (cachedAvatarUrl != null) {
    await repo.writeAvatarUrl(
      ApexAccount(source: AccountSource.chessCom, username: username),
      cachedAvatarUrl,
    );
  }
  final container = ProviderContainer(
    overrides: [
      accountRepositoryProvider.overrideWithValue(repo),
      liveProfileStatsProvider.overrideWith((ref) => statsLoader()),
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

ProfileStats _stats({required bool hasRatings, String username = 'ApexUser'}) {
  return ProfileStats(
    source: ProfileStatsSource.chessCom,
    username: username,
    displayName: username,
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
