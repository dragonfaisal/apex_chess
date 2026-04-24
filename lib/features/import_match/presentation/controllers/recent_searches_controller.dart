/// Recent username searches, persisted across app launches.
///
/// Stored per source (Chess.com / Lichess) in `shared_preferences` as a
/// simple JSON-encoded list of strings, MRU first. Bounded to [_maxEntries]
/// so the dropdown never scrolls.
library;

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:apex_chess/features/import_match/domain/imported_game.dart';

const int _maxEntries = 8;
const String _keyChessCom = 'apex.recentSearches.chessCom';
const String _keyLichess = 'apex.recentSearches.lichess';

class RecentSearchesState {
  const RecentSearchesState({
    this.chessCom = const [],
    this.lichess = const [],
  });

  final List<String> chessCom;
  final List<String> lichess;

  List<String> forSource(GameSource source) => switch (source) {
        GameSource.chessCom => chessCom,
        GameSource.lichess => lichess,
      };

  RecentSearchesState copyWith({
    List<String>? chessCom,
    List<String>? lichess,
  }) =>
      RecentSearchesState(
        chessCom: chessCom ?? this.chessCom,
        lichess: lichess ?? this.lichess,
      );
}

class RecentSearchesController extends AsyncNotifier<RecentSearchesState> {
  SharedPreferences? _prefs;

  @override
  Future<RecentSearchesState> build() async {
    _prefs = await SharedPreferences.getInstance();
    return RecentSearchesState(
      chessCom: _readList(_keyChessCom),
      lichess: _readList(_keyLichess),
    );
  }

  List<String> _readList(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.whereType<String>().take(_maxEntries).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeList(String key, List<String> list) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(key, jsonEncode(list));
  }

  /// Push a successful search to the front of the MRU list for [source].
  /// Case-insensitive de-dup so "Hikaru" and "hikaru" collapse.
  Future<void> record(GameSource source, String username) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return;
    final current = state.valueOrNull ?? const RecentSearchesState();
    final existing = source == GameSource.chessCom
        ? current.chessCom
        : current.lichess;
    final deduped = [
      trimmed,
      ...existing.where((u) => u.toLowerCase() != trimmed.toLowerCase()),
    ].take(_maxEntries).toList();

    final updated = source == GameSource.chessCom
        ? current.copyWith(chessCom: deduped)
        : current.copyWith(lichess: deduped);
    state = AsyncData(updated);

    await _writeList(
      source == GameSource.chessCom ? _keyChessCom : _keyLichess,
      deduped,
    );
  }

  Future<void> remove(GameSource source, String username) async {
    final current = state.valueOrNull ?? const RecentSearchesState();
    final existing = source == GameSource.chessCom
        ? current.chessCom
        : current.lichess;
    final filtered =
        existing.where((u) => u.toLowerCase() != username.toLowerCase()).toList();
    final updated = source == GameSource.chessCom
        ? current.copyWith(chessCom: filtered)
        : current.copyWith(lichess: filtered);
    state = AsyncData(updated);
    await _writeList(
      source == GameSource.chessCom ? _keyChessCom : _keyLichess,
      filtered,
    );
  }

  Future<void> clear(GameSource source) async {
    final current = state.valueOrNull ?? const RecentSearchesState();
    final updated = source == GameSource.chessCom
        ? current.copyWith(chessCom: const [])
        : current.copyWith(lichess: const []);
    state = AsyncData(updated);
    await _writeList(
      source == GameSource.chessCom ? _keyChessCom : _keyLichess,
      const [],
    );
  }
}

final recentSearchesProvider = AsyncNotifierProvider<RecentSearchesController,
    RecentSearchesState>(RecentSearchesController.new);
