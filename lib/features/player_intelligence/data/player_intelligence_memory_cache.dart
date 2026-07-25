library;

import 'package:apex_chess/features/player_intelligence/domain/player_analytics_models.dart';

/// Replaceable session cache for derived analytics snapshots.
///
/// The archive remains the only persistence authority. A process restart or
/// any source-token change forces a fresh derivation from ReviewDocuments.
class PlayerIntelligenceMemoryCache {
  PlayerIntelligenceMemoryCache({this.maximumEntries = 4});

  final int maximumEntries;
  final Map<String, PlayerAnalyticsSnapshot> _entries = {};

  PlayerAnalyticsSnapshot? read(String sourceToken) {
    final snapshot = _entries.remove(sourceToken);
    if (snapshot == null) return null;
    _entries[sourceToken] = snapshot;
    return snapshot;
  }

  void write(String sourceToken, PlayerAnalyticsSnapshot snapshot) {
    _entries.remove(sourceToken);
    _entries[sourceToken] = snapshot;
    while (_entries.length > maximumEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void clear() => _entries.clear();
}
