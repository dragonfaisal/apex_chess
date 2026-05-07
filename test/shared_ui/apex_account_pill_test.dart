import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_account_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home pill renders compact identity', (tester) async {
    final identity = PlayerIdentityDisplay.connected(
      username: 'ApexUser',
      platform: PlayerIdentityPlatform.chessCom,
    );

    await tester.pumpWidget(_host(ApexAccountPill(identity: identity)));

    expect(
      find.byKey(const ValueKey('apex-home-account-pill')),
      findsOneWidget,
    );
    expect(find.text('ApexUser'), findsOneWidget);
    expect(find.text('Chess.com'), findsOneWidget);
    expect(find.text('A'), findsNothing);
  });

  testWidgets('long username truncates safely on narrow width', (tester) async {
    final identity = PlayerIdentityDisplay.connected(
      username: 'VeryVeryLongConnectedUsernameThatShouldTruncate',
      platform: PlayerIdentityPlatform.lichess,
    );

    await tester.pumpWidget(
      _host(SizedBox(width: 210, child: ApexAccountPill(identity: identity))),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Lichess'), findsOneWidget);
  });

  testWidgets('offline cached state keeps layout stable', (tester) async {
    final identity = PlayerIdentityDisplay.connected(
      username: 'ApexUser',
      platform: PlayerIdentityPlatform.chessCom,
      isCached: true,
    );

    await tester.pumpWidget(_host(ApexAccountPill(identity: identity)));

    expect(
      find.byKey(const ValueKey('apex-home-account-pill')),
      findsOneWidget,
    );
    expect(find.text('ApexUser'), findsOneWidget);
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: ApexTheme.dark,
    home: Center(child: child),
  );
}
