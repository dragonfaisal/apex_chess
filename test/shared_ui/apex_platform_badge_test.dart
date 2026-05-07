import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_platform_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each platform maps to the correct label', () {
    expect(
      ApexPlatformBadgeDisplay.fromPlatform(
        PlayerIdentityPlatform.chessCom,
      ).label,
      'Chess.com',
    );
    expect(
      ApexPlatformBadgeDisplay.fromPlatform(
        PlayerIdentityPlatform.lichess,
      ).label,
      'Lichess',
    );
    expect(
      ApexPlatformBadgeDisplay.fromPlatform(PlayerIdentityPlatform.pgn).label,
      'PGN',
    );
  });

  test('unknown platform is safe', () {
    final display = ApexPlatformBadgeDisplay.fromPlatform(
      PlayerIdentityPlatform.unknown,
    );

    expect(display.label, 'Unknown');
    expect(display.shortLabel, 'Profile');
  });

  testWidgets('connected account shows selected platform badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ApexTheme.dark,
        home: const Center(
          child: ApexPlatformBadge(
            platform: PlayerIdentityPlatform.chessCom,
            selected: true,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('apex-platform-chessCom-badge')),
      findsOneWidget,
    );
    expect(find.text('Chess.com'), findsOneWidget);
  });
}
