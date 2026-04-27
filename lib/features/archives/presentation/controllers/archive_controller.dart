/// Riverpod controller for the Archived Intel feature.
///
/// Exposes:
///   * [archiveRepositoryProvider]  — async handle to the Hive-backed
///     repository; `ref.watch` to react to init success/failure.
///   * [archiveControllerProvider]  — active list + current filter
///     settings. Holds decoded [ArchivedGame]s in memory for instant
///     filter/sort updates.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/analysis_timeline.dart';
import '../../../../core/domain/services/evaluation_analyzer.dart';
import '../../data/archive_repository.dart';
import '../../domain/archived_game.dart';

// ─── Filters ─────────────────────────────────────────────────────────

enum ArchiveSort {
  /// Newest analysis first (default).
  newest,
  oldest,
  mostBrilliants,
  mostBlunders,
  highestAccuracy,
}

enum ArchiveResultFilter { any, wins, losses, draws }

class ArchiveFilters {
  final ArchiveSort sort;
  final ArchiveResultFilter result;
  /// "me" player name used to interpret wins/losses. `null` disables
  /// the `result` filter (treated as `any`).
  final String? perspective;
  /// Only show games with at least this many brilliant moves.
  final int minBrilliants;

  const ArchiveFilters({
    this.sort = ArchiveSort.newest,
    this.result = ArchiveResultFilter.any,
    this.perspective,
    this.minBrilliants = 0,
  });

  ArchiveFilters copyWith({
    ArchiveSort? sort,
    ArchiveResultFilter? result,
    String? perspective,
    bool clearPerspective = false,
    int? minBrilliants,
  }) =>
      ArchiveFilters(
        sort: sort ?? this.sort,
        result: result ?? this.result,
        perspective:
            clearPerspective ? null : (perspective ?? this.perspective),
        minBrilliants: minBrilliants ?? this.minBrilliants,
      );
}

// ─── State ───────────────────────────────────────────────────────────

class ArchiveState {
  final List<ArchivedGame> games;
  final ArchiveFilters filters;
  final bool isLoading;
  final String? error;

  const ArchiveState({
    this.games = const [],
    this.filters = const ArchiveFilters(),
    this.isLoading = false,
    this.error,
  });

  ArchiveState copyWith({
    List<ArchivedGame>? games,
    ArchiveFilters? filters,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      ArchiveState(
        games: games ?? this.games,
        filters: filters ?? this.filters,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  /// Filtered + sorted view of [games]. Computed on every read —
  /// cheap for the expected scale and removes the cache-invalidation
  /// surface area.
  List<ArchivedGame> get visible {
    final out = <ArchivedGame>[];
    for (final g in games) {
      if (g.brilliantCount < filters.minBrilliants) continue;
      if (filters.result != ArchiveResultFilter.any &&
          filters.perspective != null) {
        final me = filters.perspective!.toLowerCase();
        final whiteIsMe = g.white.toLowerCase() == me;
        final blackIsMe = g.black.toLowerCase() == me;
        if (!whiteIsMe && !blackIsMe) continue;
        final r = g.result;
        final won = (whiteIsMe && r == '1-0') ||
            (blackIsMe && r == '0-1');
        final lost = (whiteIsMe && r == '0-1') ||
            (blackIsMe && r == '1-0');
        final drew = r == '1/2-1/2';
        switch (filters.result) {
          case ArchiveResultFilter.wins:
            if (!won) continue;
            break;
          case ArchiveResultFilter.losses:
            if (!lost) continue;
            break;
          case ArchiveResultFilter.draws:
            if (!drew) continue;
            break;
          case ArchiveResultFilter.any:
            break;
        }
      }
      out.add(g);
    }
    switch (filters.sort) {
      case ArchiveSort.newest:
        out.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
        break;
      case ArchiveSort.oldest:
        out.sort((a, b) => a.analyzedAt.compareTo(b.analyzedAt));
        break;
      case ArchiveSort.mostBrilliants:
        out.sort((a, b) =>
            b.brilliantCount.compareTo(a.brilliantCount));
        break;
      case ArchiveSort.mostBlunders:
        out.sort(
            (a, b) => b.blunderCount.compareTo(a.blunderCount));
        break;
      case ArchiveSort.highestAccuracy:
        out.sort(
            (a, b) => a.averageCpLoss.compareTo(b.averageCpLoss));
        break;
    }
    return out;
  }

  int get totalBrilliants =>
      games.fold(0, (s, g) => s + g.brilliantCount);
  int get totalBlunders =>
      games.fold(0, (s, g) => s + g.blunderCount);
}

// ─── Providers ───────────────────────────────────────────────────────

final archiveRepositoryProvider =
    FutureProvider<ArchiveRepository>((ref) => ArchiveRepository.open());

class ArchiveController extends Notifier<ArchiveState> {
  @override
  ArchiveState build() {
    _reload();
    return const ArchiveState(isLoading: true);
  }

  Future<void> _reload() async {
    try {
      final repo = await ref.read(archiveRepositoryProvider.future);
      final all = repo.loadAll();
      state = state.copyWith(
        games: all,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not open archive: $e',
      );
    }
  }

  Future<void> refresh() => _reload();

  Future<void> save(ArchivedGame g) async {
    final repo = await ref.read(archiveRepositoryProvider.future);
    await repo.save(g);
    await _reload();
  }

  Future<void> remove(String id) async {
    final repo = await ref.read(archiveRepositoryProvider.future);
    await repo.delete(id);
    await _reload();
  }

  Future<void> clearAll() async {
    final repo = await ref.read(archiveRepositoryProvider.future);
    await repo.clear();
    await _reload();
  }

  /// Persist a freshly-recomputed [AnalysisTimeline] back onto the
  /// existing record so subsequent re-opens are instant. No-op if the
  /// id is missing from the in-memory list (the user may have deleted
  /// the record while analysis was running).
  Future<void> updateCachedTimeline(
    String id,
    AnalysisTimeline timeline,
  ) async {
    final repo = await ref.read(archiveRepositoryProvider.future);
    final existing = repo.find(id);
    if (existing == null) return;
    final updated = ArchivedGame(
      id: existing.id,
      source: existing.source,
      white: existing.white,
      black: existing.black,
      whiteRating: existing.whiteRating,
      blackRating: existing.blackRating,
      result: existing.result,
      playedAt: existing.playedAt,
      analyzedAt: existing.analyzedAt,
      depth: existing.depth,
      pgn: existing.pgn,
      qualityCounts: existing.qualityCounts,
      averageCpLoss: existing.averageCpLoss,
      totalPlies: existing.totalPlies,
      openingName: existing.openingName,
      ecoCode: existing.ecoCode,
      cachedTimeline: timeline,
    );
    await repo.save(updated);
    await _reload();
  }

  void setSort(ArchiveSort sort) {
    state = state.copyWith(filters: state.filters.copyWith(sort: sort));
  }

  void setResultFilter(
      ArchiveResultFilter result, String? perspective) {
    state = state.copyWith(
      filters: state.filters.copyWith(
        result: result,
        perspective: perspective,
        clearPerspective: perspective == null,
      ),
    );
  }

  void setMinBrilliants(int n) {
    state = state.copyWith(
      filters: state.filters.copyWith(minBrilliants: n.clamp(0, 99)),
    );
  }

  /// Exposed purely for tests / debug — returns the raw quality
  /// counts across the entire archive.
  Map<MoveQuality, int> get aggregateCounts {
    final out = <MoveQuality, int>{};
    for (final g in state.games) {
      g.qualityCounts.forEach((k, v) {
        out[k] = (out[k] ?? 0) + v;
      });
    }
    return out;
  }
}

final archiveControllerProvider =
    NotifierProvider<ArchiveController, ArchiveState>(
        ArchiveController.new);
