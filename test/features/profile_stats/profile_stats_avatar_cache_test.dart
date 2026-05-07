import 'package:apex_chess/features/account/data/account_repository.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';
import 'package:apex_chess/features/profile_stats/presentation/controllers/profile_stats_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'live profile stats cache public avatar without extra build fetch',
    () async {
      SharedPreferences.setMockInitialValues({
        'apex.account.source': AccountSource.chessCom.wire,
        'apex.account.username': 'ApexUser',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = AccountRepository(prefs: prefs);
      final service = _AvatarStatsService();
      final container = ProviderContainer(
        overrides: [
          accountRepositoryProvider.overrideWithValue(repo),
          profileStatsServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      await container.read(accountControllerProvider.future);
      final stats = await container.read(liveProfileStatsProvider.future);
      final cached = await container.read(accountAvatarUrlProvider.future);

      expect(stats?.avatarUrl, 'https://example.com/avatar.png');
      expect(cached, 'https://example.com/avatar.png');
      expect(service.calls, 1);
    },
  );
}

class _AvatarStatsService extends ProfileStatsService {
  int calls = 0;

  @override
  Future<ProfileStats> fetch({
    required ProfileStatsSource source,
    required String username,
  }) async {
    calls++;
    return ProfileStats(
      source: source,
      username: username,
      displayName: username,
      avatarUrl: 'https://example.com/avatar.png',
      buckets: const [],
    );
  }

  @override
  void dispose() {}
}
