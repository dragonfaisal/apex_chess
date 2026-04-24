/// Riverpod controller for the Mistake Vault.
///
/// Exposes the full vault + a "due now" slice, and the two SRS
/// mutations driving Apex Academy review sessions:
///
///   * [markCorrect] — promote the drill to the next Leitner box and
///     push nextDueAt forward by that box's cooldown.
///   * [markWrong] — demote to the fresh box and schedule for
///     tomorrow; also increments the wrong-review counter so streaks
///     and weakness insights can key off it.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/mistake_vault_repository.dart';
import '../../domain/mistake_drill.dart';

final mistakeVaultRepositoryProvider =
    FutureProvider<MistakeVaultRepository>((ref) async {
  // Open the box lazily rather than at `main()` time so users who
  // never run an analysis never pay the Hive file-open cost.
  final box = await Hive.openBox<String>(MistakeVaultRepository.boxName);
  return MistakeVaultRepository(box);
});

class MistakeVaultState {
  const MistakeVaultState({
    this.all = const [],
    this.due = const [],
    this.isReady = false,
  });

  final List<MistakeDrill> all;
  final List<MistakeDrill> due;
  final bool isReady;

  MistakeVaultState copyWith({
    List<MistakeDrill>? all,
    List<MistakeDrill>? due,
    bool? isReady,
  }) =>
      MistakeVaultState(
        all: all ?? this.all,
        due: due ?? this.due,
        isReady: isReady ?? this.isReady,
      );
}

final mistakeVaultControllerProvider =
    NotifierProvider<MistakeVaultController, MistakeVaultState>(
  MistakeVaultController.new,
);

class MistakeVaultController extends Notifier<MistakeVaultState> {
  @override
  MistakeVaultState build() {
    // Eagerly refresh as soon as the box is ready. Consumers that
    // need a synchronous snapshot can watch the state directly.
    ref.listen<AsyncValue<MistakeVaultRepository>>(
      mistakeVaultRepositoryProvider,
      (_, next) {
        next.whenData((_) => _refresh());
      },
      fireImmediately: true,
    );
    return const MistakeVaultState();
  }

  MistakeVaultRepository? get _repoSync =>
      ref.read(mistakeVaultRepositoryProvider).valueOrNull;

  Future<MistakeVaultRepository> _repo() async =>
      _repoSync ?? await ref.read(mistakeVaultRepositoryProvider.future);

  void _refresh() {
    final repo = _repoSync;
    if (repo == null) return;
    final all = repo.loadAll();
    final due = repo.dueNow();
    state = state.copyWith(all: all, due: due, isReady: true);
  }

  Future<void> ingest(Iterable<MistakeDrill> drills) async {
    final repo = await _repo();
    await repo.saveAll(drills);
    _refresh();
  }

  Future<void> markCorrect(MistakeDrill drill) async {
    final now = DateTime.now();
    final nextBox = drill.leitnerBox.next;
    final updated = drill.copyWith(
      leitnerBox: nextBox,
      nextDueAt: now.add(nextBox.cooldown),
      lastReviewedAt: now,
      reviewsCorrect: drill.reviewsCorrect + 1,
    );
    final repo = await _repo();
    await repo.save(updated);
    _refresh();
  }

  Future<void> markWrong(MistakeDrill drill) async {
    final now = DateTime.now();
    final updated = drill.copyWith(
      leitnerBox: LeitnerBox.fresh,
      nextDueAt: now.add(LeitnerBox.fresh.cooldown),
      lastReviewedAt: now,
      reviewsWrong: drill.reviewsWrong + 1,
    );
    final repo = await _repo();
    await repo.save(updated);
    _refresh();
  }

  Future<void> clear() async {
    final repo = await _repo();
    await repo.clear();
    _refresh();
  }
}
