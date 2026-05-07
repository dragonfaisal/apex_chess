/// Lightweight recent-activity state for the dynamic Home hero.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apex_chess/shared_ui/copy/apex_copy.dart';

enum HomeHeroType {
  firstUse,
  latestImport,
  pgnReady,
  latestLive,
  retry,
  genericStart,
}

enum HomeActivityLifecycle {
  available,
  inProgress,
  completed,
  stale,
  unavailable,
}

enum HomeActivityKind {
  firstUse,
  pgn,
  importGame,
  review,
  live,
  opponentScan,
  retry,
}

enum HomeActionIntent {
  importGames,
  pastePgn,
  opponentInsights,
  live,
  retry,
  openArchive,
}

extension HomeActionIntentPolicy on HomeActionIntent {
  bool get mutatesActivityOnTap => false;
}

class HomeActivityState {
  const HomeActivityState({
    this.kind = HomeActivityKind.firstUse,
    this.lifecycle = HomeActivityLifecycle.available,
    this.updatedAt,
  });

  final HomeActivityKind kind;
  final HomeActivityLifecycle lifecycle;
  final DateTime? updatedAt;

  bool get hasActivity => kind != HomeActivityKind.firstUse;
  bool get isActionable =>
      lifecycle == HomeActivityLifecycle.available ||
      lifecycle == HomeActivityLifecycle.inProgress;
}

class HomeHeroDisplay {
  const HomeHeroDisplay({
    required this.type,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.icon,
    required this.actionIntent,
    required this.priority,
    required this.isStale,
    this.lastUpdated,
  });

  final HomeHeroType type;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String cta;
  final IconData icon;
  final HomeActionIntent actionIntent;
  final DateTime? lastUpdated;
  final int priority;
  final bool isStale;

  bool get isLiveRelated => type == HomeHeroType.latestLive;

  static HomeHeroDisplay fromActivity(
    HomeActivityState activity, {
    bool isOffline = false,
    bool hasActiveReview = false,
    DateTime? now,
  }) {
    final referenceNow = now ?? DateTime.now();
    final isStale =
        activity.lifecycle == HomeActivityLifecycle.stale ||
        _isStale(activity, referenceNow);
    if (isOffline && activity.kind == HomeActivityKind.retry) {
      return HomeHeroDisplay(
        type: HomeHeroType.retry,
        eyebrow: 'OFFLINE',
        title: ApexCopy.tryAgain,
        subtitle: ApexCopy.tryAgainOnline,
        cta: ApexCopy.tryAgain,
        icon: Icons.refresh_rounded,
        actionIntent: HomeActionIntent.retry,
        lastUpdated: activity.updatedAt,
        priority: 100,
        isStale: false,
      );
    }
    if (!activity.isActionable || isStale) {
      return genericStart(lastUpdated: activity.updatedAt);
    }
    return switch (activity.kind) {
      HomeActivityKind.pgn => HomeHeroDisplay(
        type: HomeHeroType.pgnReady,
        eyebrow: 'PGN',
        title: 'PGN Ready',
        subtitle: 'Start review',
        cta: 'Start',
        icon: Icons.article_outlined,
        actionIntent: HomeActionIntent.pastePgn,
        lastUpdated: activity.updatedAt,
        priority: 70,
        isStale: false,
      ),
      HomeActivityKind.importGame => HomeHeroDisplay(
        type: HomeHeroType.latestImport,
        eyebrow: 'LAST IMPORT',
        title: 'Latest Import',
        subtitle: 'Open import',
        cta: 'Open',
        icon: Icons.cloud_download_rounded,
        actionIntent: HomeActionIntent.importGames,
        lastUpdated: activity.updatedAt,
        priority: 72,
        isStale: false,
      ),
      HomeActivityKind.review => genericStart(lastUpdated: activity.updatedAt),
      HomeActivityKind.live => HomeHeroDisplay(
        type: HomeHeroType.latestLive,
        eyebrow: 'LIVE',
        title: 'Live',
        subtitle: 'Play with feedback',
        cta: 'Play',
        icon: Icons.sports_esports_rounded,
        actionIntent: HomeActionIntent.live,
        lastUpdated: activity.updatedAt,
        priority: 60,
        isStale: false,
      ),
      HomeActivityKind.opponentScan => genericStart(
        lastUpdated: activity.updatedAt,
      ),
      HomeActivityKind.retry => HomeHeroDisplay(
        type: HomeHeroType.retry,
        eyebrow: 'RETRY',
        title: ApexCopy.tryAgain,
        subtitle: 'Check the connection and continue.',
        cta: ApexCopy.tryAgain,
        icon: Icons.refresh_rounded,
        actionIntent: HomeActionIntent.retry,
        lastUpdated: activity.updatedAt,
        priority: 50,
        isStale: false,
      ),
      HomeActivityKind.firstUse => genericStart(),
    };
  }

  static HomeHeroDisplay genericStart({DateTime? lastUpdated}) {
    return HomeHeroDisplay(
      type: HomeHeroType.genericStart,
      eyebrow: 'APEX REVIEW',
      title: 'Start Review',
      subtitle: 'Import · Paste PGN · Live',
      cta: 'Start',
      icon: Icons.auto_graph_rounded,
      actionIntent: HomeActionIntent.importGames,
      lastUpdated: lastUpdated,
      priority: 10,
      isStale: lastUpdated != null,
    );
  }

  static bool _isStale(HomeActivityState activity, DateTime now) {
    if (!activity.hasActivity) return false;
    final updated = activity.updatedAt;
    if (updated == null) return true;
    final threshold = switch (activity.kind) {
      HomeActivityKind.importGame => const Duration(minutes: 20),
      HomeActivityKind.pgn => const Duration(minutes: 20),
      HomeActivityKind.review => Duration.zero,
      HomeActivityKind.live => const Duration(hours: 4),
      HomeActivityKind.opponentScan => const Duration(minutes: 30),
      HomeActivityKind.retry => const Duration(minutes: 20),
      HomeActivityKind.firstUse => const Duration(days: 999),
    };
    return now.difference(updated) > threshold;
  }
}

class HomeQuickActionDisplay {
  const HomeQuickActionDisplay({
    required this.label,
    required this.subtitle,
    required this.intent,
    required this.kind,
  });

  final String label;
  final String subtitle;
  final HomeActionIntent intent;
  final HomeActivityKind kind;
}

List<HomeQuickActionDisplay> buildHomeQuickActions(
  HomeHeroDisplay hero, {
  HomeActivityState activity = const HomeActivityState(),
}) {
  final opponentSubtitle =
      activity.kind == HomeActivityKind.opponentScan && activity.isActionable
      ? 'Latest Scan'
      : 'Profile review';
  return [
    HomeQuickActionDisplay(
      label: 'Import Games',
      subtitle: 'Chess.com · Lichess',
      intent: HomeActionIntent.importGames,
      kind: HomeActivityKind.importGame,
    ),
    HomeQuickActionDisplay(
      label: 'Paste PGN',
      subtitle: 'Instant review',
      intent: HomeActionIntent.pastePgn,
      kind: HomeActivityKind.pgn,
    ),
    HomeQuickActionDisplay(
      label: 'Opponent Insights',
      subtitle: opponentSubtitle,
      intent: HomeActionIntent.opponentInsights,
      kind: HomeActivityKind.opponentScan,
    ),
    const HomeQuickActionDisplay(
      label: 'Live',
      subtitle: 'Play · feedback',
      intent: HomeActionIntent.live,
      kind: HomeActivityKind.live,
    ),
  ];
}

class HomeActivityController extends AsyncNotifier<HomeActivityState> {
  SharedPreferences? _prefs;

  static const _kindKey = 'apex.home.activity.kind';
  static const _lifecycleKey = 'apex.home.activity.lifecycle';
  static const _updatedKey = 'apex.home.activity.updatedAt';

  @override
  Future<HomeActivityState> build() async {
    _prefs = await SharedPreferences.getInstance();
    final rawKind = _prefs?.getString(_kindKey);
    final rawLifecycle = _prefs?.getString(_lifecycleKey);
    final rawUpdated = _prefs?.getString(_updatedKey);
    return HomeActivityState(
      kind: _kindFromWire(rawKind),
      lifecycle: _lifecycleFromWire(rawLifecycle),
      updatedAt: rawUpdated == null ? null : DateTime.tryParse(rawUpdated),
    );
  }

  Future<void> record(
    HomeActivityKind kind, {
    HomeActivityLifecycle lifecycle = HomeActivityLifecycle.available,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();
    final updated = HomeActivityState(
      kind: kind,
      lifecycle: lifecycle,
      updatedAt: DateTime.now(),
    );
    state = AsyncData(updated);
    await _prefs!.setString(_kindKey, kind.name);
    await _prefs!.setString(_lifecycleKey, lifecycle.name);
    await _prefs!.setString(_updatedKey, updated.updatedAt!.toIso8601String());
  }

  /// Record only after the PGN review exists. Tapping Paste PGN must not
  /// mutate Home into a fake "ready" state before analysis succeeds.
  Future<void> recordPgnReview() => markCompleted(HomeActivityKind.pgn);

  /// Record only after the imported review exists. Card taps open analysis but
  /// do not mutate the Home hero until a review has been produced.
  Future<void> recordImportReview() =>
      markCompleted(HomeActivityKind.importGame);

  Future<void> recordReview() => record(
    HomeActivityKind.review,
    lifecycle: HomeActivityLifecycle.completed,
  );

  Future<void> recordLive() => record(HomeActivityKind.live);

  Future<void> recordOpponentScan() => record(HomeActivityKind.opponentScan);

  Future<void> recordRetry() => record(HomeActivityKind.retry);

  Future<void> markCompleted(HomeActivityKind kind) async {
    await record(kind, lifecycle: HomeActivityLifecycle.completed);
  }

  Future<void> markUnavailableIfCurrent(HomeActivityKind kind) async {
    final current = state.valueOrNull;
    if (current?.kind != kind ||
        current?.lifecycle == HomeActivityLifecycle.completed) {
      return;
    }
    await record(kind, lifecycle: HomeActivityLifecycle.unavailable);
  }

  static HomeActivityKind _kindFromWire(String? raw) {
    return HomeActivityKind.values.firstWhere(
      (kind) => kind.name == raw,
      orElse: () => HomeActivityKind.firstUse,
    );
  }

  static HomeActivityLifecycle _lifecycleFromWire(String? raw) {
    return HomeActivityLifecycle.values.firstWhere(
      (lifecycle) => lifecycle.name == raw,
      orElse: () => HomeActivityLifecycle.available,
    );
  }
}

final homeActivityControllerProvider =
    AsyncNotifierProvider<HomeActivityController, HomeActivityState>(
      HomeActivityController.new,
    );
