import 'package:apex_chess/features/home/presentation/controllers/home_activity_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('last PGN activity maps to Continue PGN Review', () {
    final hero = HomeHeroDisplay.fromActivity(
      HomeActivityState(kind: HomeActivityKind.pgn),
    );

    expect(hero.title, 'Continue PGN Review');
    expect(hero.cta, 'Continue Review');
  });

  test('last import activity maps to Continue Imported Game', () {
    final hero = HomeHeroDisplay.fromActivity(
      HomeActivityState(kind: HomeActivityKind.importGame),
    );

    expect(hero.title, 'Continue Imported Game');
    expect(hero.cta, 'Continue Review');
  });

  test('quick actions do not duplicate Live when hero is live-related', () {
    final hero = HomeHeroDisplay.fromActivity(
      HomeActivityState(kind: HomeActivityKind.live),
    );
    final actions = buildHomeQuickActions(hero);

    expect(hero.title, 'Resume Live Review');
    expect(actions.map((a) => a.label), isNot(contains('Live')));
  });
}
