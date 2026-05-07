/// Archived game — the persistent record of a completed review.
///
/// Designed to be cheap to store (single JSON document per game,
/// <5 KB) and rich enough to drive the Archive list view and filters
/// without re-hitting the original Chess.com / Lichess PGN
/// endpoint. Re-opening an archived game loads the raw PGN from this
/// record and re-plays the analysis pipeline locally.
library;

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/services/analysis_cache_key.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/game_identity_service.dart';
import 'package:apex_chess/core/domain/services/move_quality_display.dart';

/// Bumped on every classifier-behaviour change so cached timelines
/// produced by an older brain are recomputed instead of silently
/// surfaced as stale verdicts. Persisted alongside each archived game
/// in [ArchivedGame.classifierVersion]; the archive UI uses this to
/// decide whether the [ArchivedGame.cachedTimeline] is reusable.
///
///   * `1` — Phase 6 brain (pre-PR-#18, no Forced/MissedWin tiers).
///   * `2` — Phase A brain (PR #18, Win%-Δ primary, strict Brilliant).
///   * `3` — Phase A integration (post-#18 audit): trajectory-driven
///            `isFirstSacrificePly` / `isTrivialRecapture`, opening-
///            phase fallback, archive counts derived from timeline.
///   * `4` — Deep tactical verifier: candidate-only low/high depth
///            verification, delayed sacrifice/mating-net metadata, and
///            PV1 invariant.
const int kClassifierVersion = kApexClassifierVersion;

/// Analysis mode used when the timeline was produced. Stored so a Fast
/// Review does not masquerade as a Deep Review when listed alongside it.
enum AnalysisMode {
  quick('quick'),
  deep('deep');

  const AnalysisMode(this.wire);
  final String wire;

  static AnalysisMode fromWire(String? s) =>
      values.firstWhere((v) => v.wire == s, orElse: () => AnalysisMode.deep);
}

/// Source of the original game. Keep stable — persisted as a string
/// in the Hive box so renames would silently invalidate old records.
enum ArchiveSource {
  chessCom('chess.com'),
  lichess('lichess'),
  pgn('pgn');

  const ArchiveSource(this.wire);
  final String wire;

  static ArchiveSource fromWire(String s) =>
      values.firstWhere((v) => v.wire == s, orElse: () => ArchiveSource.pgn);

  static ArchiveSource fromPgnSite(String? site) {
    final value = site?.trim().toLowerCase();
    if (value == null || value.isEmpty) return ArchiveSource.pgn;
    if (value.contains('chess.com')) return ArchiveSource.chessCom;
    if (value.contains('lichess.org')) return ArchiveSource.lichess;
    return ArchiveSource.pgn;
  }
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

  /// 14 (Fast Review) or 22 (Deep Review). Surfaced in the list as a tag.
  final int depth;

  /// Raw PGN — required to rebuild the board on re-open.
  final String pgn;

  /// Classifier version this record was produced under. The archive
  /// list uses this together with [kClassifierVersion] to decide if
  /// the cached timeline can be re-used or must be recomputed before
  /// any UI numbers are shown.
  final int classifierVersion;

  /// Quick or Deep analysis mode — Quick suppresses Brilliant / Great
  /// / Forced gating since they require deep verification + MultiPV.
  final AnalysisMode analysisMode;

  /// Product-level profile/provider provenance.
  final String analysisProfileId;
  final String providerId;
  final String? pgnHash;
  final String? cacheKey;
  final int tacticalVerifierVersion;
  final int openingBookVersion;
  final int analysisSchemaVersion;
  final String? timeControl;

  /// Per-classification counts. **Derived from the cached timeline**
  /// (when present) via [qualityCountsLive] so the counts can never
  /// drift from the actual classifications on disk — the
  /// integration-audit fix that closes the "archive shows Brilliants
  /// that don't exist in the timeline" regression.
  final Map<MoveQuality, int> qualityCounts;

  /// White-perspective average centipawn loss (for accuracy column).
  final double averageCpLoss;
  final int totalPlies;
  final String? openingName;
  final String? ecoCode;

  /// Optional cached full timeline. When present, re-opening the game
  /// from the Archive screen rebuilds the review state from this
  /// snapshot instead of running analysis again.
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
    this.classifierVersion = kClassifierVersion,
    this.analysisMode = AnalysisMode.deep,
    String? analysisProfileId,
    this.providerId = 'local_offline',
    this.pgnHash,
    this.cacheKey,
    this.tacticalVerifierVersion = kApexTacticalVerifierVersion,
    this.openingBookVersion = kApexOpeningBookVersion,
    this.analysisSchemaVersion = kApexAnalysisSchemaVersion,
    this.timeControl,
  }) : analysisProfileId =
           analysisProfileId ??
           (analysisMode == AnalysisMode.quick ? 'fast_review' : 'deep_review');

  /// True when the cached timeline was produced under the *current*
  /// classifier brain. The archive list uses this to decide whether
  /// re-opening can use the cache or must trigger a re-scan.
  bool get isCacheCurrent =>
      classifierVersion == kClassifierVersion &&
      tacticalVerifierVersion == kApexTacticalVerifierVersion &&
      openingBookVersion == kApexOpeningBookVersion &&
      analysisSchemaVersion == kApexAnalysisSchemaVersion &&
      cachedTimeline != null &&
      cachedTimeline!.classifierVersion == kClassifierVersion &&
      cachedTimeline!.tacticalVerifierVersion == kApexTacticalVerifierVersion &&
      cachedTimeline!.openingBookVersion == kApexOpeningBookVersion &&
      cachedTimeline!.analysisSchemaVersion == kApexAnalysisSchemaVersion &&
      (cacheKey == null || cachedTimeline!.cacheKey == cacheKey);

  AnalysisProfile get analysisProfile =>
      AnalysisProfile.fromWire(analysisProfileId);

  /// Live quality counts — derived from the cached timeline when
  /// present, falling back to the persisted `qualityCounts` map for
  /// older records that pre-date the Phase A integration audit.
  Map<MoveQuality, int> get qualityCountsLive {
    final tl = cachedTimeline;
    if (tl != null) return tl.qualityCounts;
    return qualityCounts;
  }

  // All count getters route through [qualityCountsLive] so they reflect
  // the *actual* classifications stored in the timeline. The legacy
  // [qualityCounts] map is still persisted for backward compatibility
  // with records that pre-date the cached-timeline schema.
  int get brilliantCount => qualityCountsLive[MoveQuality.brilliant] ?? 0;
  int get greatCount => displayCount(ReviewMoveLabel.great);
  int get blunderCount => qualityCountsLive[MoveQuality.blunder] ?? 0;
  int get mistakeCount => qualityCountsLive[MoveQuality.mistake] ?? 0;
  int get inaccuracyCount => qualityCountsLive[MoveQuality.inaccuracy] ?? 0;
  int get missedWinCount => qualityCountsLive[MoveQuality.missedWin] ?? 0;
  int get missCount => displayCount(ReviewMoveLabel.miss);

  Map<ReviewMoveLabel, int> get displayQualityCountsLive {
    final tl = cachedTimeline;
    if (tl != null) {
      final out = <ReviewMoveLabel, int>{};
      for (final move in tl.moves) {
        final bucket = MoveQualityDisplay.countBucketForMove(move);
        out[bucket] = (out[bucket] ?? 0) + 1;
      }
      return out;
    }
    final out = <ReviewMoveLabel, int>{};
    for (final entry in qualityCounts.entries) {
      final bucket = MoveQualityDisplay.labelForQuality(entry.key);
      out[bucket] = (out[bucket] ?? 0) + entry.value;
    }
    return out;
  }

  int displayCount(ReviewMoveLabel label) =>
      displayQualityCountsLive[label] ?? 0;

  String get sourceLabel => switch (source) {
    ArchiveSource.chessCom => 'Chess.com',
    ArchiveSource.lichess => 'Lichess',
    ArchiveSource.pgn => 'PGN',
  };

  String get reviewModeLabel => switch (analysisProfileId) {
    'fast_review' => 'Fast',
    'offline_review' => 'Offline',
    _ => 'Deep',
  };

  String get canonicalGameKey => canonicalKeyFor(
    pgn: pgn,
    pgnHash: pgnHash,
    white: white,
    black: black,
    result: result,
    playedAt: playedAt,
  );

  static String canonicalKeyFor({
    required String pgn,
    String? pgnHash,
    required String white,
    required String black,
    required String result,
    DateTime? playedAt,
  }) {
    final tags = const GameIdentityService().parseTags(pgn);
    final site = _cleanKeyPart(tags['Site']);
    final date = _cleanKeyPart(
      playedAt?.toIso8601String().split('T').first ??
          tags['UTCDate'] ??
          tags['Date'],
    );
    final hash = _cleanKeyPart(pgnHash) ?? stablePgnHash(pgn);
    return [
      'game',
      hash,
      _cleanKeyPart(white) ?? 'white',
      _cleanKeyPart(black) ?? 'black',
      _cleanKeyPart(result) ?? '*',
      if (date != null) date,
      if (site != null) site,
    ].join('|');
  }

  static List<ArchivedGame> collapseCanonical(Iterable<ArchivedGame> games) {
    final byKey = <String, ArchivedGame>{};
    for (final game in games) {
      final key = game.canonicalGameKey;
      final existing = byKey[key];
      if (existing == null || game.isPreferredVisibleRecordOver(existing)) {
        byKey[key] = game;
      }
    }
    final out = byKey.values.toList()
      ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
    return out;
  }

  bool isPreferredVisibleRecordOver(ArchivedGame other) {
    final modeCompare = _modeRank.compareTo(other._modeRank);
    if (modeCompare != 0) return modeCompare > 0;
    final cacheCompare = _cacheRank.compareTo(other._cacheRank);
    if (cacheCompare != 0) return cacheCompare > 0;
    final sourceCompare = _sourceRank.compareTo(other._sourceRank);
    if (sourceCompare != 0) return sourceCompare > 0;
    final depthCompare = depth.compareTo(other.depth);
    if (depthCompare != 0) return depthCompare > 0;
    final plyCompare = totalPlies.compareTo(other.totalPlies);
    if (plyCompare != 0) return plyCompare > 0;
    return analyzedAt.isAfter(other.analyzedAt);
  }

  int get _modeRank {
    final profile = analysisProfileId.trim();
    if (profile == 'deep_review') return 3;
    if (profile == 'offline_review') return 2;
    if (profile == 'fast_review') return 1;
    return analysisMode == AnalysisMode.deep ? 3 : 1;
  }

  int get _cacheRank => isCacheCurrent ? 2 : (cachedTimeline == null ? 0 : 1);

  int get _sourceRank => switch (source) {
    ArchiveSource.chessCom || ArchiveSource.lichess => 2,
    ArchiveSource.pgn => 1,
  };

  bool? userIsBlackFor(String? userHandle) {
    final me = userHandle?.trim().toLowerCase();
    if (me == null || me.isEmpty) return null;
    if (black.trim().toLowerCase() == me) return true;
    if (white.trim().toLowerCase() == me) return false;
    return null;
  }

  String? opponentFor(String? userHandle) {
    final userIsBlack = userIsBlackFor(userHandle);
    if (userIsBlack == null) return null;
    return userIsBlack ? white : black;
  }

  String resultHeadline({String? userHandle}) {
    final userIsBlack = userIsBlackFor(userHandle);
    if (userIsBlack == null) {
      return switch (result) {
        '1-0' => 'White won',
        '0-1' => 'Black won',
        '1/2-1/2' => 'Draw',
        _ => result,
      };
    }
    final opponent = opponentFor(userHandle) ?? (userIsBlack ? white : black);
    if (result == '1/2-1/2') return 'Draw vs $opponent';
    final won =
        (!userIsBlack && result == '1-0') || (userIsBlack && result == '0-1');
    return won ? 'You won vs $opponent' : 'You lost vs $opponent';
  }

  String get secondaryResultText {
    return switch (result) {
      '1-0' => 'White won · 1-0',
      '0-1' => 'Black won · 0-1',
      '1/2-1/2' => 'Draw · 1/2-1/2',
      _ => 'Result unavailable',
    };
  }

  String get relativePlayedAt {
    final date = playedAt ?? analyzedAt;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  String get openingLine {
    final parts = <String>[
      if (ecoCode != null && ecoCode!.isNotEmpty) ecoCode!,
      openingName ?? 'Opening not detected',
    ];
    return parts.join(' ');
  }

  String get compactQualityLine {
    return [
      'Brilliant $brilliantCount',
      'Great $greatCount',
      'Miss $missCount',
      'Blunder $blunderCount',
    ].join(' • ');
  }

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
    'classifierVersion': classifierVersion,
    'analysisMode': analysisMode.wire,
    'analysisProfileId': analysisProfileId,
    'providerId': providerId,
    'pgnHash': pgnHash,
    'cacheKey': cacheKey,
    'tacticalVerifierVersion': tacticalVerifierVersion,
    'openingBookVersion': openingBookVersion,
    'analysisSchemaVersion': analysisSchemaVersion,
    'timeControl': timeControl,
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
      analyzedAt: DateTime.parse(j['analyzedAt'] as String),
      depth: (j['depth'] as num).toInt(),
      pgn: j['pgn'] as String,
      qualityCounts: {
        for (final k in MoveQuality.values)
          if (counts[k.name] != null) k: (counts[k.name] as num).toInt(),
      },
      averageCpLoss: (j['averageCpLoss'] as num).toDouble(),
      totalPlies: (j['totalPlies'] as num).toInt(),
      openingName: j['openingName'] as String?,
      ecoCode: j['ecoCode'] as String?,
      cachedTimeline: j['cachedTimeline'] is Map
          ? AnalysisTimeline.fromJson(j['cachedTimeline'] as Map)
          : null,
      // Old records without a stored version are treated as v1 so the
      // archive UI can offer to re-scan them. Old records without an
      // explicit mode default to `deep` since pre-audit scans always
      // ran the full ladder.
      classifierVersion: (j['classifierVersion'] as num?)?.toInt() ?? 1,
      analysisMode: AnalysisMode.fromWire(j['analysisMode'] as String?),
      analysisProfileId: j['analysisProfileId'] as String?,
      providerId: j['providerId'] as String? ?? 'local_offline',
      pgnHash: j['pgnHash'] as String?,
      cacheKey: j['cacheKey'] as String?,
      tacticalVerifierVersion:
          (j['tacticalVerifierVersion'] as num?)?.toInt() ?? 1,
      openingBookVersion: (j['openingBookVersion'] as num?)?.toInt() ?? 1,
      analysisSchemaVersion: (j['analysisSchemaVersion'] as num?)?.toInt() ?? 1,
      timeControl: j['timeControl'] as String?,
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
    AnalysisMode analysisMode = AnalysisMode.deep,
    String? timeControl,
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
      classifierVersion: kClassifierVersion,
      analysisMode: analysisMode,
      analysisProfileId: timeline.analysisProfileId,
      providerId: timeline.providerId,
      pgnHash: timeline.pgnHash,
      cacheKey: timeline.cacheKey,
      tacticalVerifierVersion: timeline.tacticalVerifierVersion,
      openingBookVersion: timeline.openingBookVersion,
      analysisSchemaVersion: timeline.analysisSchemaVersion,
      timeControl: timeControl ?? h['TimeControl'],
    );
  }

  static DateTime? _tryParseDate(String? raw) {
    if (raw == null) return null;
    // PGN standard uses "YYYY.MM.DD"; Chess.com uses "YYYY-MM-DD".
    final normalized = raw.replaceAll('.', '-').replaceAll('?', '1');
    return DateTime.tryParse(normalized);
  }

  static String? _cleanKeyPart(String? raw) {
    final trimmed = raw?.trim().toLowerCase();
    if (trimmed == null || trimmed.isEmpty || trimmed == '?') return null;
    return trimmed.replaceAll(RegExp(r'\s+'), ' ');
  }
}
