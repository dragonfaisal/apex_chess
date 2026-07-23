/// Full-game analysis timeline — the complete analysis result.
///
/// Contains an ordered list of [MoveAnalysis] for every ply,
/// plus a Win% array for the advantage chart.
/// All data is pre-computed (by backend or mock) and consumed
/// by the UI in O(1) per ply.
library;

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'opening_evidence.dart';
import 'move_analysis.dart';

enum AnalysisCompletionStatus { complete, incomplete }

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
  final int explanationPolicyVersion;
  final int explanationClaimSchemaVersion;
  final int explanationRendererVersion;

  /// Exact semantic opening artifact expected by this run. Historic
  /// opening-v1 timelines omit both this and [openingArtifactVerification].
  final OpeningArtifactIdentity? openingArtifact;

  /// Runtime verification of the bytes used by this execution. This is
  /// deliberately excluded from AnalysisVariantId material.
  final OpeningArtifactVerification? openingArtifactVerification;
  final int analysisSchemaVersion;
  final int? depth;
  final int? requestedDepth;
  final int? movetimeMs;
  final int? multipv;
  final bool candidateVerificationEnabled;
  final DateTime? completedAt;
  final String? pgnHash;
  final String? cacheKey;
  final bool cacheHit;
  final AnalysisCompletionStatus completionStatus;
  final int? expectedPlies;
  final int engineSearchCount;
  final int engineCacheHitCount;

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
    this.openingBookVersion = kApexLegacyOpeningBookVersion,
    this.explanationPolicyVersion = 0,
    this.explanationClaimSchemaVersion = 0,
    this.explanationRendererVersion = 0,
    this.openingArtifact,
    this.openingArtifactVerification,
    this.analysisSchemaVersion = kApexLegacyAnalysisSchemaVersion,
    this.depth,
    this.requestedDepth,
    this.movetimeMs,
    this.multipv,
    this.candidateVerificationEnabled = false,
    this.completedAt,
    this.pgnHash,
    this.cacheKey,
    this.cacheHit = false,
    this.completionStatus = AnalysisCompletionStatus.incomplete,
    this.expectedPlies,
    this.engineSearchCount = 0,
    this.engineCacheHitCount = 0,
  }) : analysisProfileId =
           analysisProfileId ??
           (analysisMode == 'quick' ? 'fast_review' : 'deep_review');

  /// Total number of plies.
  int get totalPlies => moves.length;

  bool get isComplete =>
      completionStatus == AnalysisCompletionStatus.complete &&
      expectedPlies != null &&
      expectedPlies == moves.length &&
      moves.isNotEmpty;

  bool get hasCurrentExplanationContract =>
      analysisSchemaVersion == kApexAnalysisSchemaVersion &&
      explanationPolicyVersion == kApexExplanationPolicyVersion &&
      explanationClaimSchemaVersion == kApexExplanationClaimSchemaVersion &&
      explanationRendererVersion == kApexExplanationRendererVersion;

  bool get hasSupportedExplanationContract =>
      hasCurrentExplanationContract ||
      (analysisSchemaVersion == kApexLegacyInsightAnalysisSchemaVersion &&
          explanationPolicyVersion == kApexLegacyExplanationPolicyVersion &&
          explanationClaimSchemaVersion ==
              kApexLegacyExplanationClaimSchemaVersion &&
          (explanationRendererVersion ==
                  kApexLegacyExplanationRendererVersion ||
              explanationRendererVersion ==
                  kApexChapter6ExplanationRendererVersion));

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

  int get cpLossEligibleCount => moves
      .where(
        (move) =>
            move.engineEvaluationAvailable &&
            move.classification != MoveQuality.book &&
            move.moverCpLoss != null,
      )
      .length;

  int get cpLossEligibleCountWhite => _cpLossCountForSide(isWhite: true);
  int get cpLossEligibleCountBlack => _cpLossCountForSide(isWhite: false);

  bool get hasVerifiedCpLoss => cpLossEligibleCount > 0;

  /// Average mover-perspective centipawn loss over cp-scored, non-book plies.
  double get averageCpLoss {
    final eligible = moves.where(
      (move) =>
          move.engineEvaluationAvailable &&
          move.classification != MoveQuality.book &&
          move.moverCpLoss != null,
    );
    if (eligible.isEmpty) return 0;
    return eligible.fold<double>(
          0,
          (sum, move) => sum + move.moverCpLoss!.clamp(0, 100000).toDouble(),
        ) /
        eligible.length;
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
      if (m.isWhiteMove != isWhite ||
          !m.engineEvaluationAvailable ||
          m.classification == MoveQuality.book ||
          m.moverCpLoss == null) {
        continue;
      }
      count++;
      total += m.moverCpLoss!.clamp(0, 100000);
    }
    return count == 0 ? 0 : total / count;
  }

  int _cpLossCountForSide({required bool isWhite}) => moves
      .where(
        (move) =>
            move.isWhiteMove == isWhite &&
            move.engineEvaluationAvailable &&
            move.classification != MoveQuality.book &&
            move.moverCpLoss != null,
      )
      .length;

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
    if (explanationPolicyVersion > 0)
      'explanationPolicyVersion': explanationPolicyVersion,
    if (explanationClaimSchemaVersion > 0)
      'explanationClaimSchemaVersion': explanationClaimSchemaVersion,
    if (explanationRendererVersion > 0)
      'explanationRendererVersion': explanationRendererVersion,
    if (openingArtifact != null) 'openingArtifact': openingArtifact!.toJson(),
    if (openingArtifactVerification != null)
      'openingArtifactVerification': openingArtifactVerification!.name,
    'analysisSchemaVersion': analysisSchemaVersion,
    'depth': depth,
    'requestedDepth': requestedDepth,
    'movetimeMs': movetimeMs,
    'multipv': multipv,
    'candidateVerificationEnabled': candidateVerificationEnabled,
    'completedAt': completedAt?.toIso8601String(),
    'pgnHash': pgnHash,
    'cacheKey': cacheKey,
    'cacheHit': cacheHit,
    'completionStatus': completionStatus.name,
    'expectedPlies': expectedPlies,
    'engineSearchCount': engineSearchCount,
    'engineCacheHitCount': engineCacheHitCount,
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
    int? explanationPolicyVersion,
    int? explanationClaimSchemaVersion,
    int? explanationRendererVersion,
    OpeningArtifactIdentity? openingArtifact,
    OpeningArtifactVerification? openingArtifactVerification,
    int? analysisSchemaVersion,
    int? depth,
    int? requestedDepth,
    int? movetimeMs,
    int? multipv,
    bool? candidateVerificationEnabled,
    DateTime? completedAt,
    String? pgnHash,
    String? cacheKey,
    bool? cacheHit,
    AnalysisCompletionStatus? completionStatus,
    int? expectedPlies,
    int? engineSearchCount,
    int? engineCacheHitCount,
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
      explanationPolicyVersion:
          explanationPolicyVersion ?? this.explanationPolicyVersion,
      explanationClaimSchemaVersion:
          explanationClaimSchemaVersion ?? this.explanationClaimSchemaVersion,
      explanationRendererVersion:
          explanationRendererVersion ?? this.explanationRendererVersion,
      openingArtifact: openingArtifact ?? this.openingArtifact,
      openingArtifactVerification:
          openingArtifactVerification ?? this.openingArtifactVerification,
      analysisSchemaVersion:
          analysisSchemaVersion ?? this.analysisSchemaVersion,
      depth: depth ?? this.depth,
      requestedDepth: requestedDepth ?? this.requestedDepth,
      movetimeMs: movetimeMs ?? this.movetimeMs,
      multipv: multipv ?? this.multipv,
      candidateVerificationEnabled:
          candidateVerificationEnabled ?? this.candidateVerificationEnabled,
      completedAt: completedAt ?? this.completedAt,
      pgnHash: pgnHash ?? this.pgnHash,
      cacheKey: cacheKey ?? this.cacheKey,
      cacheHit: cacheHit ?? this.cacheHit,
      completionStatus: completionStatus ?? this.completionStatus,
      expectedPlies: expectedPlies ?? this.expectedPlies,
      engineSearchCount: engineSearchCount ?? this.engineSearchCount,
      engineCacheHitCount: engineCacheHitCount ?? this.engineCacheHitCount,
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
      openingBookVersion:
          (j['openingBookVersion'] as num?)?.toInt() ??
          kApexLegacyOpeningBookVersion,
      explanationPolicyVersion:
          (j['explanationPolicyVersion'] as num?)?.toInt() ?? 0,
      explanationClaimSchemaVersion:
          (j['explanationClaimSchemaVersion'] as num?)?.toInt() ?? 0,
      explanationRendererVersion:
          (j['explanationRendererVersion'] as num?)?.toInt() ?? 0,
      openingArtifact: j['openingArtifact'] is Map
          ? OpeningArtifactIdentity.fromJson(j['openingArtifact'] as Map)
          : null,
      openingArtifactVerification: _openingVerificationByName(
        j['openingArtifactVerification'],
      ),
      analysisSchemaVersion: (j['analysisSchemaVersion'] as num?)?.toInt() ?? 1,
      depth: (j['depth'] as num?)?.toInt(),
      requestedDepth: (j['requestedDepth'] as num?)?.toInt(),
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
      completionStatus: AnalysisCompletionStatus.values.firstWhere(
        (value) => value.name == j['completionStatus'],
        orElse: () => AnalysisCompletionStatus.incomplete,
      ),
      expectedPlies: (j['expectedPlies'] as num?)?.toInt(),
      engineSearchCount: (j['engineSearchCount'] as num?)?.toInt() ?? 0,
      engineCacheHitCount: (j['engineCacheHitCount'] as num?)?.toInt() ?? 0,
      moves: [for (final m in movesRaw) MoveAnalysis.fromJson(m as Map)],
    );
  }
}

OpeningArtifactVerification? _openingVerificationByName(Object? raw) {
  for (final value in OpeningArtifactVerification.values) {
    if (value.name == raw) return value;
  }
  return null;
}
