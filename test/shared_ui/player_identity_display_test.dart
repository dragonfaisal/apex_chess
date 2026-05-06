import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('connected user maps platform status and YOU identity', () {
    final identity = PlayerIdentityDisplay.connected(
      username: ' ALFAISALpro ',
      platform: PlayerIdentityPlatform.chessCom,
      rating: '1500',
    );

    expect(identity.displayUsername, 'ALFAISALpro');
    expect(identity.normalizedUsername, 'alfaisalpro');
    expect(identity.platformLabel, 'Chess.com');
    expect(identity.isConnectedUser, isTrue);
    expect(identity.isOpponent, isFalse);
    expect(identity.statusLabel, 'Connected');
    expect(identity.ratingLabel, '1500');
  });

  test('opponent stays separate from connected user', () {
    final identity = PlayerIdentityDisplay.fromRaw(
      username: 'RojoHijo',
      platform: PlayerIdentityPlatform.lichess,
      isOpponent: true,
      side: PlayerIdentitySide.black,
      result: PlayerIdentityResult.lost,
    );

    expect(identity.isOpponent, isTrue);
    expect(identity.isConnectedUser, isFalse);
    expect(identity.platformLabel, 'Lichess');
    expect(identity.sideLabel, 'Black');
    expect(identity.resultLabel, 'Lost');
  });

  test('missing avatar and unknown rating use safe fallbacks', () {
    final identity = PlayerIdentityDisplay.fromRaw(
      username: '  _Apex User ',
      platform: PlayerIdentityPlatform.pgn,
      avatarUrl: 'not-a-url',
      side: PlayerIdentitySide.white,
    );

    expect(identity.avatarUrl, isNull);
    expect(identity.fallbackInitial, 'A');
    expect(identity.ratingLabel, 'Rating unavailable');
    expect(identity.platformLabel, 'PGN');
  });

  test('empty username fallback remains side aware', () {
    final white = PlayerIdentityDisplay.fromRaw(
      username: '',
      side: PlayerIdentitySide.white,
    );
    final black = PlayerIdentityDisplay.fromRaw(
      username: '   ',
      side: PlayerIdentitySide.black,
    );

    expect(white.displayUsername, 'Unknown');
    expect(white.fallbackInitial, 'U');
    expect(black.displayUsername, 'Unknown');
    expect(black.fallbackInitial, 'U');
  });

  test('platform wire mapping handles supported providers', () {
    expect(
      PlayerIdentityPlatform.fromWire('chess.com'),
      PlayerIdentityPlatform.chessCom,
    );
    expect(
      PlayerIdentityPlatform.fromWire('lichess.org'),
      PlayerIdentityPlatform.lichess,
    );
    expect(PlayerIdentityPlatform.fromWire('pgn'), PlayerIdentityPlatform.pgn);
    expect(
      PlayerIdentityPlatform.fromWire('other'),
      PlayerIdentityPlatform.unknown,
    );
  });
}
