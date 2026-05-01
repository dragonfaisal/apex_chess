/// Full-game analysis timeline — the complete analysis result.
///
/// Contains an ordered list of [MoveAnalysis] for every ply,
/// plus a Win% array for the advantage chart.
/// All data is pre-computed (by backend or mock) and consumed
/// by the UI in O(1) per ply.
library;

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'move_analysis.dart';

class AnalysisTimeline {
  /// Ordered per-move analyses (index 0 = ply 0 = White's first move).
  final List<MoveAnalysis> moves;

  /// Starting FEN (usually standard initial position).
  final String startingFen;

  /// PGN headers (Event, White, Black, Date, Result, etc.)
  final Map<String, String> headers;

  /// Win% array (White's perspective) — one value per ply for the chart.
  final List<double> winPercentages;

  /// Shared analysis provenance. Individual moves also carry this data so
  /// partial exports remain self-describing.
  final String analysisMode;
  final int classifierVersion;
  final String engineVersion;
  final String analysisProfileId;
  final String providerId;
  final int tacticalVerifierVersion;
  final int openingBookVersion;
  final int analysisSchemaVersion;
  final int? depth;
  final int? movetimeMs;
  final int? multipv;
  final bool candidateVerificationEnabled;
  final DateTime? completedAt;
  final String? pgnHash;
  final String? cacheKey;
  final bool cacheHit;

  const AnalysisTimeline({
    required this.moves,
    required this.startingFen,
    required this.headers,
    required this.winPercentages,
    this.analysisMode = 'deep',
    this.classifierVersion = kApexClassifierVersion,
    this.engineVersion = 'unknown',
    String? analysisProfileId,
    this.providerId = 'local_offline',
    this.tacticalVerifierVersion = kApexTacticalVerifierVersion,
    this.openingBookVersion = kApexOpeningBookVersion,
    this.analysisSchemaVersion = kApexAnalysisSchemaVersion,
    this.depth,
    this.movetimeMs,
    this.multipv,
    this.candidateVerificationEnabled = false,
    this.completedAt,
    this.pgnHash,
    this.cacheKey,
    this.cacheHit = false,
  }) : analysisProfileId =
           analysisProfileId ??
           (analysisMode == 'quick' ? 'fast_review' : 'deep_review');

  /// Total number of plies.
  int get totalPlies => moves.length;

  /// O(1) access to a specific ply's analysis.
  MoveAnalysis? operator [](int ply) {
    if (ply < 0 || ply >= moves.length) return null;
    return moves[ply];
  }

  /// Count of each quality classification.
  Map<MoveQuality, int> get qualityCounts {
    final counts = <MoveQuality, int>{};
    for (final move in moves) {
      final q = move.classification;
      counts[q] = (counts[q] ?? 0) + 1;
    }
    return counts;
  }

  /// Average centipawn loss (for accuracy display).
  double get averageCpLoss {
    if (moves.isEmpty) return 0;
    double totalLoss = 0;
    for (final m in moves) {
      totalLoss += m.deltaW < 0 ? m.deltaW.abs() : 0;
    }
    return totalLoss / moves.length;
  }

  /// Average centipawn loss for plies played by the White side.
  ///
  /// Used by the archive card to surface per-colour accuracy. When the
  /// user knows which colour they played (imported Chess.com / Lichess
  /// game), we show "You: X ACPL · Opponent: Y ACPL" instead of the
  /// single aggregate number — the Phase A audit flagged the latter as
  /// misleading because it blends the user's accuracy with the
  /// opponent's.
  double get averageCpLossWhite => _acplForSide(isWhite: true);

  /// Average centipawn loss for plies played by the Black side.
  double get averageCpLossBlack => _acplForSide(isWhite: false);

  double _acplForSide({required bool isWhite}) {
    double total = 0;
    int count = 0;
    for (final m in moves) {
      if (m.isWhiteMove != isWhite) continue;
      count++;
      total += m.deltaW < 0 ? m.deltaW.abs() : 0;
    }
    return count == 0 ? 0 : total / count;
  }

  // ── Serialisation ──────────────────────────────────────────────
  // Persisted alongside [ArchivedGame] so the archive can re-open a
  // game **instantly** instead of replaying the entire engine
  // pipeline. Heavy fields (per-ply FEN strings) dominate the size,
  // but a typical 60-move game lands at ~15–25 KB JSON which is
  // trivial for Hive's `Box<String>` to hold.

  Map<String, dynamic> toJson() => {
    'startingFen': startingFen,
    'headers': headers,
    'winPercentages': winPercentages,
    'analysisMode': analysisMode,
    'classifierVersion': classifierVersion,
    'engineVersion': engineVersion,
    'analysisProfileId': analysisProfileId,
    'providerId': providerId,
    'tacticalVerifierVersion': tacticalVerifierVersion,
    'openingBookVersion': openingBookVersion,
    'analysisSchemaVersion': analysisSchemaVersion,
    'depth': depth,
    'movetimeMs': movetimeMs,
    'multipv': multipv,
    'candidateVerificationEnabled': candidateVerificationEnabled,
    'completedAt': completedAt?.toIso8601String(),
    'pgnHash': pgnHash,
    'cacheKey': cacheKey,
    'cacheHit': cacheHit,
    'moves': moves.map((m) => m.toJson()).toList(growable: false),
  };

  AnalysisTimeline copyWith({
    List<MoveAnalysis>? moves,
    String? startingFen,
    Map<String, String>? headers,
    List<double>? winPercentages,
    String? analysisMode,
    int? classifierVersion,
    String? engineVersion,
    String? analysisProfileId,
    String? providerId,
    int? tacticalVerifierVersion,
    int? openingBookVersion,
    int? analysisSchemaVersion,
    int? depth,
    int? movetimeMs,
    int? multipv,
    bool? candidateVerificationEnabled,
    DateTime? completedAt,
    String? pgnHash,
    String? cacheKey,
    bool? cacheHit,
  }) {
    return AnalysisTimeline(
      moves: moves ?? this.moves,
      startingFen: startingFen ?? this.startingFen,
      headers: headers ?? this.headers,
      winPercentages: winPercentages ?? this.winPercentages,
      analysisMode: analysisMode ?? this.analysisMode,
      classifierVersion: classifierVersion ?? this.classifierVersion,
      engineVersion: engineVersion ?? this.engineVersion,
      analysisProfileId: analysisProfileId ?? this.analysisProfileId,
      providerId: providerId ?? this.providerId,
      tacticalVerifierVersion:
          tacticalVerifierVersion ?? this.tacticalVerifierVersion,
      openingBookVersion: openingBookVersion ?? this.openingBookVersion,
      analysisSchemaVersion:
          analysisSchemaVersion ?? this.analysisSchemaVersion,
      depth: depth ?? this.depth,
      movetimeMs: movetimeMs ?? this.movetimeMs,
      multipv: multipv ?? this.multipv,
      candidateVerificationEnabled:
          candidateVerificationEnabled ?? this.candidateVerificationEnabled,
      completedAt: completedAt ?? this.completedAt,
      pgnHash: pgnHash ?? this.pgnHash,
      cacheKey: cacheKey ?? this.cacheKey,
      cacheHit: cacheHit ?? this.cacheHit,
    );
  }

  factory AnalysisTimeline.fromJson(Map<dynamic, dynamic> j) {
    final headersRaw = (j['headers'] as Map?) ?? const {};
    final winsRaw = (j['winPercentages'] as List?) ?? const [];
    final movesRaw = (j['moves'] as List?) ?? const [];
    return AnalysisTimeline(
      startingFen: j['startingFen'] as String? ?? '',
      headers: {
        for (final e in headersRaw.entries)
          e.key.toString(): e.value?.toString() ?? '',
      },
      winPercentages: [for (final v in winsRaw) (v as num).toDouble()],
      analysisMode: j['analysisMode'] as String? ?? 'deep',
      classifierVersion: (j['classifierVersion'] as num?)?.toInt() ?? 1,
      engineVersion: j['engineVersion'] as String? ?? 'unknown',
      analysisProfileId: j['analysisProfileId'] as String?,
      providerId: j['providerId'] as String? ?? 'local_offline',
      tacticalVerifierVersion:
          (j['tacticalVerifierVersion'] as num?)?.toInt() ?? 1,
      openingBookVersion: (j['openingBookVersion'] as num?)?.toInt() ?? 1,
      analysisSchemaVersion: (j['analysisSchemaVersion'] as num?)?.toInt() ?? 1,
      depth: (j['depth'] as num?)?.toInt(),
      movetimeMs: (j['movetimeMs'] as num?)?.toInt(),
      multipv: (j['multipv'] as num?)?.toInt(),
      candidateVerificationEnabled:
          j['candidateVerificationEnabled'] as bool? ?? false,
      completedAt: j['completedAt'] == null
          ? null
          : DateTime.tryParse(j['completedAt'] as String),
      pgnHash: j['pgnHash'] as String?,
      cacheKey: j['cacheKey'] as String?,
      cacheHit: j['cacheHit'] as bool? ?? false,
      moves: [for (final m in movesRaw) MoveAnalysis.fromJson(m as Map)],
    );
  }
}
