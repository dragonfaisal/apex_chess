import 'package:apex_chess/core/network/connectivity_models.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_profile_avatar_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('profile button renders avatar fallback and opens profile', (
    tester,
  ) async {
    var tapped = false;
    final identity = PlayerIdentityDisplay.connected(
      username: 'ApexUser',
      platform: PlayerIdentityPlatform.chessCom,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ApexTheme.dark,
        home: Center(
          child: ApexProfileAvatarButton(
            identity: identity,
            presence: const ApexConnectionPresence(
              snapshot: ConnectivitySnapshot(
                network: NetworkAvailability.online,
              ),
            ),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('apex-profile-avatar-button')),
      findsOneWidget,
    );
    expect(find.text('A'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('apex-profile-avatar-button')));
    expect(tapped, isTrue);
  });

  testWidgets('profile button renders cached avatar URL safely', (
    tester,
  ) async {
    final identity = PlayerIdentityDisplay.connected(
      username: 'ApexUser',
      platform: PlayerIdentityPlatform.lichess,
      avatarUrl: 'https://example.com/avatar.png',
      isCached: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ApexTheme.dark,
        home: Center(
          child: ApexProfileAvatarButton(
            identity: identity,
            presence: const ApexConnectionPresence(
              snapshot: ConnectivitySnapshot(
                network: NetworkAvailability.offline,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('apex-avatar-network-apexuser')),
      findsOneWidget,
    );
  });
}
