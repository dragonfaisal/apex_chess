/// Hive-backed persistence for [MistakeDrill]. Mirrors the shape of
/// `ArchiveRepository`: a single `Box<String>` of JSON-encoded
/// documents keyed by drill id (== position FEN hash), so adding
/// optional fields never requires a schema migration.
library;

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../domain/mistake_drill.dart';

class MistakeVaultRepository {
  MistakeVaultRepository(this._box);

  static const String boxName = 'apex_mistake_vault';

  static Future<MistakeVaultRepository> open() async {
    final box = await Hive.openBox<String>(boxName);
    return MistakeVaultRepository(box);
  }

  final Box<String> _box;

  /// Upsert — same position seen in a new game updates the drill's
  /// provenance but preserves its SRS schedule. Callers that want a
  /// fresh schedule should [delete] first.
  Future<void> save(MistakeDrill drill) async {
    await _box.put(drill.id, jsonEncode(drill.toJson()));
  }

  /// Bulk-add on archive save. Dedupes by id; existing drills keep
  /// their Leitner box + nextDueAt (we're *reinforcing* that the
  /// position is still a weakness, not resetting progress).
  Future<void> saveAll(Iterable<MistakeDrill> drills) async {
    for (final d in drills) {
      final existing = find(d.id);
      if (existing != null) {
        // Keep the schedule; refresh provenance fields only.
        await save(d.copyWith(
          leitnerBox: existing.leitnerBox,
          nextDueAt: existing.nextDueAt,
          lastReviewedAt: existing.lastReviewedAt,
          reviewsCorrect: existing.reviewsCorrect,
          reviewsWrong: existing.reviewsWrong,
        ));
      } else {
        await save(d);
      }
    }
  }

  MistakeDrill? find(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    try {
      return MistakeDrill.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  List<MistakeDrill> loadAll() {
    final out = <MistakeDrill>[];
    for (final raw in _box.values) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        out.add(MistakeDrill.fromJson(j));
      } catch (_) {
        // Skip malformed records.
      }
    }
    return out;
  }

  /// Drills currently due — nextDueAt <= now. Sorted oldest-due
  /// first so the most overdue weakness comes up at the top of the
  /// Academy queue.
  List<MistakeDrill> dueNow([DateTime? now]) {
    final t = now ?? DateTime.now();
    final all = loadAll().where((d) => d.isDue(t)).toList();
    all.sort((a, b) => a.nextDueAt.compareTo(b.nextDueAt));
    return all;
  }

  Future<void> delete(String id) => _box.delete(id);
  Future<void> clear() => _box.clear();
}
