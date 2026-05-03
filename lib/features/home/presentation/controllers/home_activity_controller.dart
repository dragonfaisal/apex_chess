/// Lightweight recent-activity state for the dynamic Home hero.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apex_chess/shared_ui/copy/apex_copy.dart';

enum HomeActivityKind { firstUse, pgn, importGame, review, live, retry }

class HomeActivityState {
  const HomeActivityState({
    this.kind = HomeActivityKind.firstUse,
    this.updatedAt,
  });

  final HomeActivityKind kind;
  final DateTime? updatedAt;

  bool get hasActivity => kind != HomeActivityKind.firstUse;
}

class HomeHeroDisplay {
  const HomeHeroDisplay({
    required this.kind,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.cta,
  });

  final HomeActivityKind kind;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String cta;

  bool get isLiveRelated => kind == HomeActivityKind.live;

  static HomeHeroDisplay fromActivity(
    HomeActivityState activity, {
    bool isOffline = false,
  }) {
    if (isOffline) {
      return const HomeHeroDisplay(
        kind: HomeActivityKind.retry,
        eyebrow: 'OFFLINE',
        title: ApexCopy.tryAgain,
        subtitle: ApexCopy.tryAgainOnline,
        cta: ApexCopy.tryAgain,
      );
    }
    return switch (activity.kind) {
      HomeActivityKind.pgn => const HomeHeroDisplay(
        kind: HomeActivityKind.pgn,
        eyebrow: 'LAST PGN',
        title: 'Continue PGN Review',
        subtitle: 'Open the current review or paste a new PGN.',
        cta: 'Continue Review',
      ),
      HomeActivityKind.importGame => const HomeHeroDisplay(
        kind: HomeActivityKind.importGame,
        eyebrow: 'LAST IMPORT',
        title: 'Continue Imported Game',
        subtitle: 'Open the current review or import another game.',
        cta: 'Continue Review',
      ),
      HomeActivityKind.review => const HomeHeroDisplay(
        kind: HomeActivityKind.review,
        eyebrow: 'RECENT REVIEW',
        title: 'Continue Review',
        subtitle: 'Return to your latest reviewed game.',
        cta: 'Continue Review',
      ),
      HomeActivityKind.live => const HomeHeroDisplay(
        kind: HomeActivityKind.live,
        eyebrow: 'LIVE REVIEW',
        title: 'Resume Live Review',
        subtitle: 'Return to live board feedback.',
        cta: 'Resume',
      ),
      HomeActivityKind.retry => const HomeHeroDisplay(
        kind: HomeActivityKind.retry,
        eyebrow: 'RETRY',
        title: ApexCopy.tryAgain,
        subtitle: 'Check the connection and continue.',
        cta: ApexCopy.tryAgain,
      ),
      HomeActivityKind.firstUse => const HomeHeroDisplay(
        kind: HomeActivityKind.firstUse,
        eyebrow: 'APEX REVIEW',
        title: 'Start Review',
        subtitle: 'Import • Paste PGN • Live',
        cta: 'Start Review',
      ),
    };
  }
}

class HomeQuickActionDisplay {
  const HomeQuickActionDisplay({required this.label, required this.kind});

  final String label;
  final HomeActivityKind kind;
}

List<HomeQuickActionDisplay> buildHomeQuickActions(HomeHeroDisplay hero) {
  final smart = switch (hero.kind) {
    HomeActivityKind.pgn ||
    HomeActivityKind.importGame ||
    HomeActivityKind.review => const HomeQuickActionDisplay(
      label: 'Continue Review',
      kind: HomeActivityKind.review,
    ),
    HomeActivityKind.retry => const HomeQuickActionDisplay(
      label: ApexCopy.tryAgain,
      kind: HomeActivityKind.retry,
    ),
    HomeActivityKind.live => const HomeQuickActionDisplay(
      label: 'Recent Game',
      kind: HomeActivityKind.importGame,
    ),
    HomeActivityKind.firstUse => const HomeQuickActionDisplay(
      label: 'Recent Game',
      kind: HomeActivityKind.importGame,
    ),
  };

  return const [
    HomeQuickActionDisplay(
      label: 'Import Games',
      kind: HomeActivityKind.importGame,
    ),
    HomeQuickActionDisplay(label: 'Paste PGN', kind: HomeActivityKind.pgn),
    HomeQuickActionDisplay(
      label: 'Opponent Insights',
      kind: HomeActivityKind.firstUse,
    ),
  ].followedBy([smart]).toList(growable: false);
}

class HomeActivityController extends AsyncNotifier<HomeActivityState> {
  SharedPreferences? _prefs;

  static const _kindKey = 'apex.home.activity.kind';
  static const _updatedKey = 'apex.home.activity.updatedAt';

  @override
  Future<HomeActivityState> build() async {
    _prefs = await SharedPreferences.getInstance();
    final rawKind = _prefs?.getString(_kindKey);
    final rawUpdated = _prefs?.getString(_updatedKey);
    return HomeActivityState(
      kind: _kindFromWire(rawKind),
      updatedAt: rawUpdated == null ? null : DateTime.tryParse(rawUpdated),
    );
  }

  Future<void> record(HomeActivityKind kind) async {
    _prefs ??= await SharedPreferences.getInstance();
    final updated = HomeActivityState(kind: kind, updatedAt: DateTime.now());
    state = AsyncData(updated);
    await _prefs!.setString(_kindKey, kind.name);
    await _prefs!.setString(_updatedKey, updated.updatedAt!.toIso8601String());
  }

  Future<void> recordPgnReview() => record(HomeActivityKind.pgn);
  Future<void> recordImportReview() => record(HomeActivityKind.importGame);
  Future<void> recordReview() => record(HomeActivityKind.review);
  Future<void> recordLive() => record(HomeActivityKind.live);
  Future<void> recordRetry() => record(HomeActivityKind.retry);

  static HomeActivityKind _kindFromWire(String? raw) {
    return HomeActivityKind.values.firstWhere(
      (kind) => kind.name == raw,
      orElse: () => HomeActivityKind.firstUse,
    );
  }
}

final homeActivityControllerProvider =
    AsyncNotifierProvider<HomeActivityController, HomeActivityState>(
      HomeActivityController.new,
    );
