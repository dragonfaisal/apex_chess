import 'package:apex_chess/features/home/presentation/controllers/home_activity_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 5, 3, 12);

  ProviderContainer containerWithPrefs() {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('PGN activity maps to PGN Ready only after success', () async {
    final container = containerWithPrefs();
    await container.read(homeActivityControllerProvider.future);

    final initial = HomeHeroDisplay.fromActivity(
      container.read(homeActivityControllerProvider).value!,
      now: now,
    );
    expect(initial.title, 'Start Review');

    await container
        .read(homeActivityControllerProvider.notifier)
        .recordPgnReview();

    final activity = container.read(homeActivityControllerProvider).value!;
    final hero = HomeHeroDisplay.fromActivity(activity, now: DateTime.now());

    expect(activity.kind, HomeActivityKind.pgn);
    expect(activity.lifecycle, HomeActivityLifecycle.inProgress);
    expect(hero.type, HomeHeroType.pgnReady);
    expect(hero.title, 'PGN Ready');
    expect(hero.cta, 'Start');
    expect(hero.actionIntent, HomeActionIntent.pastePgn);
  });

  test('latest import maps to Latest Import only after success', () async {
    final container = containerWithPrefs();
    await container.read(homeActivityControllerProvider.future);

    await container
        .read(homeActivityControllerProvider.notifier)
        .recordImportReview();

    final activity = container.read(homeActivityControllerProvider).value!;
    final hero = HomeHeroDisplay.fromActivity(activity, now: DateTime.now());

    expect(activity.kind, HomeActivityKind.importGame);
    expect(activity.lifecycle, HomeActivityLifecycle.inProgress);
    expect(hero.type, HomeHeroType.latestImport);
    expect(hero.title, 'Latest Import');
    expect(hero.actionIntent, HomeActionIntent.importGames);
  });

  test('completed review does not keep Continue Review as primary hero', () {
    final hero = HomeHeroDisplay.fromActivity(
      HomeActivityState(
        kind: HomeActivityKind.review,
        lifecycle: HomeActivityLifecycle.completed,
        updatedAt: now,
      ),
      now: now,
      hasActiveReview: true,
    );

    expect(hero.type, HomeHeroType.genericStart);
    expect(hero.title, 'Start Review');
    expect(hero.title, isNot('Continue Review'));
  });

  test('completed review clears continuation hero in controller', () async {
    final container = containerWithPrefs();
    await container.read(homeActivityControllerProvider.future);

    await container
        .read(homeActivityControllerProvider.notifier)
        .markCompleted(HomeActivityKind.review);

    final hero = HomeHeroDisplay.fromActivity(
      container.read(homeActivityControllerProvider).value!,
      now: DateTime.now(),
      hasActiveReview: true,
    );

    expect(hero.title, 'Start Review');
    expect(hero.actionIntent, HomeActionIntent.importGames);
  });

  test('latest import becomes stale after use or completion', () {
    final hero = HomeHeroDisplay.fromActivity(
      HomeActivityState(
        kind: HomeActivityKind.importGame,
        lifecycle: HomeActivityLifecycle.completed,
        updatedAt: now,
      ),
      now: now,
    );

    expect(hero.type, HomeHeroType.genericStart);
    expect(hero.title, 'Start Review');
  });

  test('unavailable route does not show as primary hero', () {
    final hero = HomeHeroDisplay.fromActivity(
      HomeActivityState(
        kind: HomeActivityKind.importGame,
        lifecycle: HomeActivityLifecycle.unavailable,
        updatedAt: now,
      ),
      now: now,
    );

    expect(hero.type, HomeHeroType.genericStart);
    expect(hero.actionIntent, HomeActionIntent.importGames);
  });

  test('tapping Import does not mutate hero immediately', () {
    final activity = const HomeActivityState();
    final before = HomeHeroDisplay.fromActivity(activity, now: now);
    final importAction = buildHomeQuickActions(
      before,
    ).firstWhere((action) => action.intent == HomeActionIntent.importGames);

    expect(importAction.intent.mutatesActivityOnTap, isFalse);
    expect(importAction.label, 'Import Games');

    final after = HomeHeroDisplay.fromActivity(activity, now: now);
    expect(after.title, before.title);
    expect(after.type, before.type);
  });

  test('tapping Paste PGN does not mutate hero immediately', () {
    final activity = const HomeActivityState();
    final before = HomeHeroDisplay.fromActivity(activity, now: now);
    final pasteAction = buildHomeQuickActions(
      before,
    ).firstWhere((action) => action.intent == HomeActionIntent.pastePgn);

    expect(pasteAction.intent.mutatesActivityOnTap, isFalse);
    expect(pasteAction.label, 'Paste PGN');

    final after = HomeHeroDisplay.fromActivity(activity, now: now);
    expect(after.title, before.title);
    expect(after.type, before.type);
  });

  test('fixed hero labels do not contain ellipsis', () {
    final states = [
      const HomeActivityState(),
      HomeActivityState(kind: HomeActivityKind.importGame, updatedAt: now),
      HomeActivityState(kind: HomeActivityKind.pgn, updatedAt: now),
      HomeActivityState(kind: HomeActivityKind.live, updatedAt: now),
      HomeActivityState(kind: HomeActivityKind.retry, updatedAt: now),
      HomeActivityState(
        kind: HomeActivityKind.review,
        lifecycle: HomeActivityLifecycle.completed,
        updatedAt: now,
      ),
    ];

    for (final state in states) {
      final hero = HomeHeroDisplay.fromActivity(state, now: now);
      expect(hero.title, isNot(contains('...')));
      expect(hero.title, isNot(contains('Continue Review')));
      expect(hero.title, isNot(contains('Resume Review')));
      expect(hero.title.length, lessThanOrEqualTo(16));
    }
  });

  test('Home keeps Live quick action', () {
    final hero = HomeHeroDisplay.fromActivity(const HomeActivityState());
    final actions = buildHomeQuickActions(hero);

    expect(actions.map((a) => a.label), contains('Live'));
    expect(actions.map((a) => a.subtitle), contains('Play · feedback'));
    expect(
      actions.singleWhere((a) => a.label == 'Live').intent,
      HomeActionIntent.live,
    );
  });

  test('Home does not render Continue or Resume Review actions', () {
    final hero = HomeHeroDisplay.fromActivity(
      HomeActivityState(kind: HomeActivityKind.review, updatedAt: now),
      now: now,
      hasActiveReview: true,
    );
    final actions = buildHomeQuickActions(hero);
    final labels = [hero.title, ...actions.map((a) => a.label)];

    expect(labels, isNot(contains('Continue Review')));
    expect(labels, isNot(contains('Resume Review')));
  });

  test('smart opponent slot updates after entering Opponent Insights', () {
    final activity = HomeActivityState(
      kind: HomeActivityKind.opponentScan,
      updatedAt: now,
    );
    final hero = HomeHeroDisplay.fromActivity(activity, now: now);
    final actions = buildHomeQuickActions(hero, activity: activity);
    final opponent = actions.singleWhere(
      (a) => a.kind == HomeActivityKind.opponentScan,
    );

    expect(hero.title, 'Start Review');
    expect(opponent.label, 'Opponent Insights');
    expect(opponent.subtitle, 'Latest Scan');
    expect(opponent.intent, HomeActionIntent.opponentInsights);
  });

  test('completed review points to Archive, not Home continuation', () {
    final hero = HomeHeroDisplay.fromActivity(
      HomeActivityState(
        kind: HomeActivityKind.review,
        lifecycle: HomeActivityLifecycle.completed,
        updatedAt: now,
      ),
      now: now,
    );

    expect(hero.title, 'Start Review');
    expect(hero.actionIntent, HomeActionIntent.importGames);
  });

  test('Home display refreshes after activity changes on resume', () async {
    final container = containerWithPrefs();
    await container.read(homeActivityControllerProvider.future);

    final first = HomeHeroDisplay.fromActivity(
      container.read(homeActivityControllerProvider).value!,
      now: now,
    );
    await container.read(homeActivityControllerProvider.notifier).recordLive();
    final after = HomeHeroDisplay.fromActivity(
      container.read(homeActivityControllerProvider).value!,
      now: DateTime.now(),
    );

    expect(first.title, 'Start Review');
    expect(after.title, 'Live');
  });

  test('quick action routes stay deterministic after hero changes', () {
    final hero = HomeHeroDisplay.fromActivity(
      HomeActivityState(kind: HomeActivityKind.importGame, updatedAt: now),
      now: now,
    );
    final actions = buildHomeQuickActions(hero);

    expect(
      actions.singleWhere((a) => a.label == 'Paste PGN').intent,
      HomeActionIntent.pastePgn,
    );
    expect(
      actions.singleWhere((a) => a.label == 'Import Games').intent,
      HomeActionIntent.importGames,
    );
    expect(
      actions.singleWhere((a) => a.label == 'Opponent Insights').intent,
      HomeActionIntent.opponentInsights,
    );
    expect(
      actions.singleWhere((a) => a.label == 'Live').intent,
      HomeActionIntent.live,
    );
  });

  test('stale latest import does not override Paste PGN action', () {
    final hero = HomeHeroDisplay.fromActivity(
      HomeActivityState(
        kind: HomeActivityKind.importGame,
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      now: now,
    );
    final pasteAction = buildHomeQuickActions(
      hero,
    ).singleWhere((a) => a.label == 'Paste PGN');

    expect(hero.title, 'Start Review');
    expect(pasteAction.intent, HomeActionIntent.pastePgn);
  });

  test('stale review does not override any quick action', () {
    final hero = HomeHeroDisplay.fromActivity(
      HomeActivityState(
        kind: HomeActivityKind.review,
        updatedAt: now.subtract(const Duration(minutes: 1)),
      ),
      now: now,
      hasActiveReview: true,
    );
    final actions = buildHomeQuickActions(hero);

    expect(hero.title, 'Start Review');
    expect(actions.map((a) => a.intent), [
      HomeActionIntent.importGames,
      HomeActionIntent.pastePgn,
      HomeActionIntent.opponentInsights,
      HomeActionIntent.live,
    ]);
  });
}
