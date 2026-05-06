import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_player_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('missing avatar renders premium fallback initial', (
    tester,
  ) async {
    final identity = PlayerIdentityDisplay.fromRaw(
      username: 'ApexUser',
      platform: PlayerIdentityPlatform.chessCom,
    );

    await tester.pumpWidget(_host(ApexPlayerAvatar(identity: identity)));

    expect(find.text('A'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('avatar URL path renders network image widget', (tester) async {
    final identity = PlayerIdentityDisplay.fromRaw(
      username: 'ApexUser',
      platform: PlayerIdentityPlatform.chessCom,
      avatarUrl: 'https://example.com/avatar.png',
    );

    await tester.pumpWidget(_host(ApexPlayerAvatar(identity: identity)));

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('invalid avatar URL falls back before image load', (
    tester,
  ) async {
    final identity = PlayerIdentityDisplay.fromRaw(
      username: '',
      platform: PlayerIdentityPlatform.unknown,
      avatarUrl: 'avatar.png',
    );

    await tester.pumpWidget(_host(ApexPlayerAvatar(identity: identity)));

    expect(find.text('U'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('sizes and connected badge map correctly', (tester) async {
    final identity = PlayerIdentityDisplay.connected(
      username: 'ApexUser',
      platform: PlayerIdentityPlatform.lichess,
    );

    await tester.pumpWidget(
      _host(
        ApexPlayerAvatar(
          key: const ValueKey('avatar'),
          identity: identity,
          size: ApexPlayerAvatarSize.small,
          showConnectedBadge: true,
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SizedBox && widget.width == 26 && widget.height == 26,
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: ApexTheme.dark,
    home: Center(child: child),
  );
}
