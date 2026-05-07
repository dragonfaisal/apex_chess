import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('Chess.com public avatar maps into identity display', () async {
    final calls = <String>[];
    final service = ProfileStatsService(
      client: MockClient((request) async {
        calls.add(request.url.path);
        if (request.url.path.endsWith('/stats')) {
          return http.Response(
            '{"chess_blitz":{"last":{"rating":1500},"record":{"win":2,"loss":1,"draw":0}}}',
            200,
          );
        }
        return http.Response(
          '{"username":"ApexUser","avatar":"https://images.chesscomfiles.com/avatar.png"}',
          200,
        );
      }),
    );
    addTearDown(service.dispose);

    final stats = await service.fetchStrict(
      source: ProfileStatsSource.chessCom,
      username: 'ApexUser',
    );
    final identity = PlayerIdentityDisplay.connected(
      username: stats.displayName,
      platform: PlayerIdentityPlatform.chessCom,
      avatarUrl: stats.avatarUrl,
    );

    expect(stats.avatarUrl, 'https://images.chesscomfiles.com/avatar.png');
    expect(identity.avatarUrl, stats.avatarUrl);
    expect(calls, ['/pub/player/apexuser/stats', '/pub/player/apexuser']);
  });

  test('missing Chess.com avatar keeps fallback identity', () async {
    final service = ProfileStatsService(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/stats')) {
          return http.Response(
            '{"chess_blitz":{"last":{"rating":1500},"record":{"win":2,"loss":1,"draw":0}}}',
            200,
          );
        }
        return http.Response('{"username":"ApexUser"}', 200);
      }),
    );
    addTearDown(service.dispose);

    final stats = await service.fetchStrict(
      source: ProfileStatsSource.chessCom,
      username: 'ApexUser',
    );
    final identity = PlayerIdentityDisplay.connected(
      username: stats.displayName,
      platform: PlayerIdentityPlatform.chessCom,
      avatarUrl: stats.avatarUrl,
    );

    expect(stats.avatarUrl, isNull);
    expect(identity.avatarUrl, isNull);
    expect(identity.fallbackInitial, 'A');
  });

  test('Lichess public profile image is carried when present', () async {
    final service = ProfileStatsService(
      client: MockClient((request) async {
        return http.Response(
          '{"username":"ApexUser","profile":{"image":"https://lichess1.org/avatar.png"},"perfs":{"blitz":{"rating":1700}},"count":{"win":3,"loss":1,"draw":2}}',
          200,
        );
      }),
    );
    addTearDown(service.dispose);

    final stats = await service.fetchStrict(
      source: ProfileStatsSource.lichess,
      username: 'ApexUser',
    );

    expect(stats.avatarUrl, 'https://lichess1.org/avatar.png');
  });

  test('invalid public avatar URL is ignored', () async {
    final service = ProfileStatsService(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/stats')) {
          return http.Response(
            '{"chess_blitz":{"last":{"rating":1500},"record":{"win":2,"loss":1,"draw":0}}}',
            200,
          );
        }
        return http.Response(
          '{"username":"ApexUser","avatar":"avatar.png"}',
          200,
        );
      }),
    );
    addTearDown(service.dispose);

    final stats = await service.fetchStrict(
      source: ProfileStatsSource.chessCom,
      username: 'ApexUser',
    );

    expect(stats.avatarUrl, isNull);
  });
}
