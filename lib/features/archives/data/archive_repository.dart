/// Hive-backed persistence for [ArchivedGame].
///
/// Single box (`apex_archived_games`) storing `Map<dynamic, dynamic>`
/// JSON documents keyed by [ArchivedGame.id]. A [Box<Map>] is
/// intentionally used over a `Box<ArchivedGame>` + TypeAdapter to keep
/// the schema forward-compatible — adding a new optional field never
/// requires a registry bump or a migration.
///
/// Initialisation order is documented at the `ensureInitialized`
/// call site (`main.dart`): Hive MUST be flutter-initialised and the
/// box opened before the first controller read, otherwise the
/// provider will return an error state.
library;

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../domain/archived_game.dart';

class ArchiveRepository {
  ArchiveRepository(this._box);

  static const String boxName = 'apex_archived_games';

  /// Open the backing box. Safe to call multiple times — Hive caches
  /// open boxes. Returns a ready-to-use repository.
  static Future<ArchiveRepository> open() async {
    final box = await Hive.openBox<String>(boxName);
    return ArchiveRepository(box);
  }

  final Box<String> _box;

  /// Upsert by id — a re-analysis of the same PGN at a new depth
  /// overwrites the earlier record rather than duplicating it.
  Future<void> save(ArchivedGame game) async {
    await _box.put(game.id, jsonEncode(game.toJson()));
  }

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();

  /// Entire archive, newest-analyzed first. This is cheap — the Hive
  /// box is an in-memory `LinkedHashMap` after open, so decoding all
  /// values on every read is fine for the expected scale (<500 games).
  List<ArchivedGame> loadAll() {
    final out = <ArchivedGame>[];
    for (final raw in _box.values) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        out.add(ArchivedGame.fromJson(j));
      } catch (_) {
        // Skip malformed records rather than crash the whole screen —
        // this can happen if a future schema change adds a required
        // field and an old record predates it. A healing migration
        // would overwrite it on next save.
      }
    }
    out.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
    return out;
  }

  ArchivedGame? find(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    try {
      return ArchivedGame.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
