/// Archived game — the persistent record of a completed Quantum Scan.
///
/// Designed to be cheap to store (single JSON document per game,
/// <5 KB) and rich enough to drive the Archived Intel list view and
/// filters without re-hitting the original Chess.com / Lichess PGN
/// endpoint. Re-opening an archived game loads the raw PGN from this
/// record and re-plays the analysis pipeline locally.
library;

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';

/// Source of the original game. Keep stable — persisted as a string
/// in the Hive box so renames would silently invalidate old records.
enum ArchiveSource {
  chessCom('chess.com'),
  lichess('lichess'),
  pgn('pgn');

  const ArchiveSource(this.wire);
  final String wire;

  static ArchiveSource fromWire(String s) => values.firstWhere(
        (v) => v.wire == s,
        orElse: () => ArchiveSource.pgn,
      );
}

/// Immutable, serialisable record of one analyzed game.
class ArchivedGame {
  /// Stable identifier — SHA1 of the normalized PGN. Avoids storing
  /// the same game twice if a user re-analyses it at a different
  /// depth (the *latest* analysis overwrites the earlier one).
  final String id;
  final ArchiveSource source;
  final String white;
  final String black;
  final String? whiteRating;
  final String? blackRating;
  /// '1-0' | '0-1' | '1/2-1/2' | '*'
  final String result;
  final DateTime? playedAt;
  final DateTime analyzedAt;
  /// 14 (Fast) or 22 (Quantum). Surfaced in the list as a pill.
  final int depth;
  /// Raw PGN — required to rebuild the board on re-open.
  final String pgn;
  /// Per-classification counts, for filter UI and at-a-glance stats.
  final Map<MoveQuality, int> qualityCounts;
  /// White-perspective average centipawn loss (for accuracy column).
  final double averageCpLoss;
  final int totalPlies;
  final String? openingName;
  final String? ecoCode;

  /// Optional cached full timeline. When present, re-opening the game
  /// from the Archived Intel screen skips the engine entirely and
  /// rebuilds the review state from this snapshot — that's how Phase 6
  /// "open saved report instantly" works in practice.
  ///
  /// Older records persisted before this field existed simply leave it
  /// `null` and fall through to the legacy re-analysis path; the schema
  /// is forward-compatible.
  final AnalysisTimeline? cachedTimeline;

  const ArchivedGame({
    required this.id,
    required this.source,
    required this.white,
    required this.black,
    this.whiteRating,
    this.blackRating,
    required this.result,
    this.playedAt,
    required this.analyzedAt,
    required this.depth,
    required this.pgn,
    required this.qualityCounts,
    required this.averageCpLoss,
    required this.totalPlies,
    this.openingName,
    this.ecoCode,
    this.cachedTimeline,
  });

  int get brilliantCount =>
      qualityCounts[MoveQuality.brilliant] ?? 0;
  int get blunderCount => qualityCounts[MoveQuality.blunder] ?? 0;
  int get mistakeCount => qualityCounts[MoveQuality.mistake] ?? 0;
  int get inaccuracyCount =>
      qualityCounts[MoveQuality.inaccuracy] ?? 0;

  // ── Serialisation ──────────────────────────────────────────────
  // Hive can persist `Map<String, dynamic>` directly via its default
  // adapters, which avoids pulling in `hive_generator` / build_runner
  // and keeps the schema readable when someone inspects the box.

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source.wire,
        'white': white,
        'black': black,
        'whiteRating': whiteRating,
        'blackRating': blackRating,
        'result': result,
        'playedAt': playedAt?.toIso8601String(),
        'analyzedAt': analyzedAt.toIso8601String(),
        'depth': depth,
        'pgn': pgn,
        'qualityCounts': {
          for (final e in qualityCounts.entries) e.key.name: e.value,
        },
        'averageCpLoss': averageCpLoss,
        'totalPlies': totalPlies,
        'openingName': openingName,
        'ecoCode': ecoCode,
        if (cachedTimeline != null) 'cachedTimeline': cachedTimeline!.toJson(),
      };

  factory ArchivedGame.fromJson(Map<dynamic, dynamic> j) {
    final counts = (j['qualityCounts'] as Map?) ?? const {};
    return ArchivedGame(
      id: j['id'] as String,
      source: ArchiveSource.fromWire(j['source'] as String),
      white: j['white'] as String,
      black: j['black'] as String,
      whiteRating: j['whiteRating'] as String?,
      blackRating: j['blackRating'] as String?,
      result: j['result'] as String,
      playedAt: j['playedAt'] == null
          ? null
          : DateTime.tryParse(j['playedAt'] as String),
      analyzedAt:
          DateTime.parse(j['analyzedAt'] as String),
      depth: (j['depth'] as num).toInt(),
      pgn: j['pgn'] as String,
      qualityCounts: {
        for (final k in MoveQuality.values)
          if (counts[k.name] != null)
            k: (counts[k.name] as num).toInt(),
      },
      averageCpLoss: (j['averageCpLoss'] as num).toDouble(),
      totalPlies: (j['totalPlies'] as num).toInt(),
      openingName: j['openingName'] as String?,
      ecoCode: j['ecoCode'] as String?,
      cachedTimeline: j['cachedTimeline'] is Map
          ? AnalysisTimeline.fromJson(j['cachedTimeline'] as Map)
          : null,
    );
  }

  /// Build an [ArchivedGame] from a freshly-completed [AnalysisTimeline]
  /// and a small bag of metadata the analyser doesn't track itself.
  factory ArchivedGame.fromTimeline({
    required AnalysisTimeline timeline,
    required String id,
    required ArchiveSource source,
    required int depth,
    required String pgn,
    DateTime? playedAt,
  }) {
    final h = timeline.headers;
    return ArchivedGame(
      id: id,
      source: source,
      white: h['White'] ?? 'White',
      black: h['Black'] ?? 'Black',
      whiteRating: h['WhiteElo'],
      blackRating: h['BlackElo'],
      result: h['Result'] ?? '*',
      playedAt: playedAt ?? _tryParseDate(h['UTCDate'] ?? h['Date']),
      analyzedAt: DateTime.now(),
      depth: depth,
      pgn: pgn,
      qualityCounts: timeline.qualityCounts,
      averageCpLoss: timeline.averageCpLoss,
      totalPlies: timeline.totalPlies,
      openingName: h['Opening'],
      ecoCode: h['ECO'],
      cachedTimeline: timeline,
    );
  }

  static DateTime? _tryParseDate(String? raw) {
    if (raw == null) return null;
    // PGN standard uses "YYYY.MM.DD"; Chess.com uses "YYYY-MM-DD".
    final normalized = raw.replaceAll('.', '-').replaceAll('?', '1');
    return DateTime.tryParse(normalized);
  }
}
