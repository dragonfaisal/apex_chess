library;

import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';

const int kPlayerAnalyticsPolicyVersion = 2;
const int kPlayerAnalyticsSchemaVersion = 1;

enum PlayerAnalyticsCoverageState {
  complete,
  partial,
  insufficient,
  unavailable,
}

enum PlayerAnalyticsExclusionReason {
  corruptOrUnavailable,
  incompleteDocument,
  invalidGameId,
  unknownPlayerSide,
  duplicateGameVariant,
  incompatibleClassificationPolicy,
  missingClassificationEvidence,
  missingInsightEvidence,
  missingOpeningEvidence,
}

enum PlayerAnalyticsTrendState {
  improving,
  stable,
  declining,
  insufficientEvidence,
}

enum CoachingPriorityCategory {
  materialSafety,
  tacticalConversion,
  mateAwareness,
  sacrificeDiscipline,
  tacticalRecognition,
  defenderAwareness,
  openingTransitions,
  defensiveResources,
}

enum CoachingPrioritySuppressionCode {
  noEligibleEvidence,
  incompatibleEvidence,
  insufficientDenominator,
  belowEventThreshold,
  belowGameThreshold,
  overlappingPublishedPriority,
  maximumThreeLimit,
}

class PlayerAnalyticsPolicy {
  const PlayerAnalyticsPolicy({
    this.policyVersion = kPlayerAnalyticsPolicyVersion,
    this.schemaVersion = kPlayerAnalyticsSchemaVersion,
    this.recentWindowGames = 10,
    this.minimumTrendGamesPerWindow = 5,
    this.minimumTrendMovesPerWindow = 20,
    this.minimumPriorityEvents = 2,
    this.minimumPriorityGames = 2,
    this.minimumStrengthGames = 5,
    this.trendAbsoluteRateThreshold = 0.5,
    this.trendRelativeThreshold = 0.10,
  });

  final int policyVersion;
  final int schemaVersion;
  final int recentWindowGames;
  final int minimumTrendGamesPerWindow;
  final int minimumTrendMovesPerWindow;
  final int minimumPriorityEvents;
  final int minimumPriorityGames;
  final int minimumStrengthGames;
  final double trendAbsoluteRateThreshold;
  final double trendRelativeThreshold;

  Map<String, Object> toJson() => {
    'policyVersion': policyVersion,
    'schemaVersion': schemaVersion,
    'recentWindowGames': recentWindowGames,
    'minimumTrendGamesPerWindow': minimumTrendGamesPerWindow,
    'minimumTrendMovesPerWindow': minimumTrendMovesPerWindow,
    'minimumPriorityEvents': minimumPriorityEvents,
    'minimumPriorityGames': minimumPriorityGames,
    'minimumStrengthGames': minimumStrengthGames,
    'trendAbsoluteRateThreshold': trendAbsoluteRateThreshold,
    'trendRelativeThreshold': trendRelativeThreshold,
  };
}

class PlayerAnalyticsExclusion {
  const PlayerAnalyticsExclusion({
    required this.reason,
    required this.detail,
    this.gameId,
    this.variantId,
    this.documentId,
  });

  final PlayerAnalyticsExclusionReason reason;
  final String detail;
  final String? gameId;
  final String? variantId;
  final String? documentId;

  Map<String, Object?> toJson() => {
    'reason': reason.name,
    'detail': detail,
    'gameId': gameId,
    'variantId': variantId,
    'documentId': documentId,
  };
}

class CanonicalAnalyzedGame {
  const CanonicalAnalyzedGame({
    required this.document,
    required this.analysisDigest,
    required this.playerIsWhite,
    required this.orderTimestamp,
    required this.selectionReason,
    required this.excludedVariantIds,
  });

  final ReviewDocument document;
  final String analysisDigest;
  final bool playerIsWhite;
  final DateTime orderTimestamp;
  final String selectionReason;
  final List<String> excludedVariantIds;

  String get gameId => document.game.gameId.value;
  String get variantId => document.variantId.value;
  String get documentId => document.documentId;

  Map<String, Object?> toManifestJson() => {
    'gameId': gameId,
    'analysisVariantId': variantId,
    'reviewDocumentId': documentId,
    'analysisDigest': analysisDigest,
    'reviewDocumentSchema': document.schemaVersion,
    'analysisSchema': document.timeline.analysisSchemaVersion,
    'classifierVersion': document.timeline.classifierVersion,
    'openingPolicyVersion': document.timeline.openingBookVersion,
    'playerSide': playerIsWhite ? 'white' : 'black',
    'orderTimestamp': orderTimestamp.toUtc().toIso8601String(),
    'selectionReason': selectionReason,
    'excludedVariantIds': excludedVariantIds,
  };
}

class PlayerAnalyticsManifest {
  const PlayerAnalyticsManifest({
    required this.policyVersion,
    required this.schemaVersion,
    required this.playerIdentityScope,
    required this.selectedGames,
    required this.exclusions,
    required this.snapshotId,
    required this.canonicalMaterial,
  });

  final int policyVersion;
  final int schemaVersion;
  final String playerIdentityScope;
  final List<CanonicalAnalyzedGame> selectedGames;
  final List<PlayerAnalyticsExclusion> exclusions;
  final String snapshotId;
  final String canonicalMaterial;

  Map<String, Object?> toJson() => {
    'policyVersion': policyVersion,
    'schemaVersion': schemaVersion,
    'playerIdentityScope': playerIdentityScope,
    'snapshotId': snapshotId,
    'selectedGames': selectedGames
        .map((game) => game.toManifestJson())
        .toList(growable: false),
    'exclusions': exclusions
        .map((exclusion) => exclusion.toJson())
        .toList(growable: false),
  };
}

class PlayerMetric {
  const PlayerMetric({
    required this.metricId,
    required this.displayLabel,
    required this.numerator,
    required this.denominator,
    required this.eligibleGameCount,
    required this.excludedGameCount,
    required this.excludedMoveCount,
    required this.coverage,
    required this.policyVersion,
    this.suppressionReason,
    this.comparison,
  });

  final String metricId;
  final String displayLabel;
  final double numerator;
  final int denominator;
  final int eligibleGameCount;
  final int excludedGameCount;
  final int excludedMoveCount;
  final PlayerAnalyticsCoverageState coverage;
  final int policyVersion;
  final String? suppressionReason;
  final PlayerMetricComparison? comparison;

  double? get rate => denominator == 0 ? null : (numerator / denominator) * 100;

  Map<String, Object?> toJson() => {
    'metricId': metricId,
    'displayLabel': displayLabel,
    'numerator': numerator,
    'denominator': denominator,
    'eligibleGameCount': eligibleGameCount,
    'excludedGameCount': excludedGameCount,
    'excludedMoveCount': excludedMoveCount,
    'coverage': coverage.name,
    'policyVersion': policyVersion,
    'rate': rate,
    'suppressionReason': suppressionReason,
    'comparison': comparison?.toJson(),
  };
}

class PlayerMetricComparison {
  const PlayerMetricComparison({
    required this.previousValue,
    required this.recentValue,
    required this.absoluteDelta,
    required this.relativeDelta,
    required this.previousGameCount,
    required this.recentGameCount,
    required this.previousDenominator,
    required this.recentDenominator,
  });

  final double previousValue;
  final double recentValue;
  final double absoluteDelta;
  final double? relativeDelta;
  final int previousGameCount;
  final int recentGameCount;
  final int previousDenominator;
  final int recentDenominator;

  Map<String, Object?> toJson() => {
    'previousValue': previousValue,
    'recentValue': recentValue,
    'absoluteDelta': absoluteDelta,
    'relativeDelta': relativeDelta,
    'previousGameCount': previousGameCount,
    'recentGameCount': recentGameCount,
    'previousDenominator': previousDenominator,
    'recentDenominator': recentDenominator,
  };
}

class PlayerAnalyticsExample {
  const PlayerAnalyticsExample({
    required this.gameId,
    required this.variantId,
    required this.documentId,
    required this.ply,
    required this.classification,
    required this.orderTimestamp,
    this.claimType,
    this.mechanism,
    this.persistedSentence,
  });

  final String gameId;
  final String variantId;
  final String documentId;
  final int ply;
  final MoveQuality classification;
  final DateTime orderTimestamp;
  final MoveInsightClaimType? claimType;
  final MoveInsightMechanismType? mechanism;
  final String? persistedSentence;

  String get identity => '$documentId:$ply';

  Map<String, Object?> toJson() => {
    'gameId': gameId,
    'analysisVariantId': variantId,
    'reviewDocumentId': documentId,
    'ply': ply,
    'classification': classification.name,
    'claimType': claimType?.name,
    'mechanism': mechanism?.name,
    'persistedSentence': persistedSentence,
    'orderTimestamp': orderTimestamp.toUtc().toIso8601String(),
  };
}

class PlayerEventSummary {
  const PlayerEventSummary({
    required this.eventId,
    required this.displayLabel,
    required this.positiveCount,
    required this.negativeCount,
    required this.eligibleGameCount,
    required this.eligibleMoveCount,
    required this.coverage,
    required this.examples,
  });

  final String eventId;
  final String displayLabel;
  final int positiveCount;
  final int negativeCount;
  final int eligibleGameCount;
  final int eligibleMoveCount;
  final PlayerAnalyticsCoverageState coverage;
  final List<PlayerAnalyticsExample> examples;

  int get totalCount => positiveCount + negativeCount;

  Map<String, Object?> toJson() => {
    'eventId': eventId,
    'displayLabel': displayLabel,
    'positiveCount': positiveCount,
    'negativeCount': negativeCount,
    'eligibleGameCount': eligibleGameCount,
    'eligibleMoveCount': eligibleMoveCount,
    'coverage': coverage.name,
    'examples': examples.map((example) => example.toJson()).toList(),
  };
}

class PlayerOpeningSummary {
  const PlayerOpeningSummary({
    required this.openingId,
    required this.eco,
    required this.name,
    required this.gameCount,
    required this.verifiedTheoryMoveCount,
    required this.leavingTheorySamples,
    required this.medianLeavingTheoryPly,
    required this.criticalErrorsAfterTheory,
    required this.examples,
  });

  final String openingId;
  final String eco;
  final String name;
  final int gameCount;
  final int verifiedTheoryMoveCount;
  final int leavingTheorySamples;
  final double? medianLeavingTheoryPly;
  final int criticalErrorsAfterTheory;
  final List<PlayerAnalyticsExample> examples;

  Map<String, Object?> toJson() => {
    'openingId': openingId,
    'eco': eco,
    'name': name,
    'gameCount': gameCount,
    'verifiedTheoryMoveCount': verifiedTheoryMoveCount,
    'leavingTheorySamples': leavingTheorySamples,
    'medianLeavingTheoryPly': medianLeavingTheoryPly,
    'criticalErrorsAfterTheory': criticalErrorsAfterTheory,
    'examples': examples.map((example) => example.toJson()).toList(),
  };
}

class PlayerTrend {
  const PlayerTrend({
    required this.state,
    required this.metricId,
    required this.windowLabel,
    required this.previousValue,
    required this.recentValue,
    required this.absoluteDelta,
    required this.relativeDelta,
    required this.previousGameCount,
    required this.recentGameCount,
    required this.previousMoveCount,
    required this.recentMoveCount,
    required this.coverage,
    this.suppressionReason,
  });

  final PlayerAnalyticsTrendState state;
  final String metricId;
  final String windowLabel;
  final double? previousValue;
  final double? recentValue;
  final double? absoluteDelta;
  final double? relativeDelta;
  final int previousGameCount;
  final int recentGameCount;
  final int previousMoveCount;
  final int recentMoveCount;
  final PlayerAnalyticsCoverageState coverage;
  final String? suppressionReason;

  Map<String, Object?> toJson() => {
    'state': state.name,
    'metricId': metricId,
    'windowLabel': windowLabel,
    'previousValue': previousValue,
    'recentValue': recentValue,
    'absoluteDelta': absoluteDelta,
    'relativeDelta': relativeDelta,
    'previousGameCount': previousGameCount,
    'recentGameCount': recentGameCount,
    'previousMoveCount': previousMoveCount,
    'recentMoveCount': recentMoveCount,
    'coverage': coverage.name,
    'suppressionReason': suppressionReason,
  };
}

class CoachingPriorityRank {
  const CoachingPriorityRank({
    required this.severity,
    required this.frequency,
    required this.recency,
    required this.specificity,
  });

  final int severity;
  final int frequency;
  final int recency;
  final int specificity;

  Map<String, Object> toJson() => {
    'severity': severity,
    'frequency': frequency,
    'recency': recency,
    'specificity': specificity,
  };
}

class CoachingPriority {
  const CoachingPriority({
    required this.priorityId,
    required this.category,
    required this.title,
    required this.action,
    required this.eventCount,
    required this.eligibleDenominator,
    required this.gameCount,
    required this.coverage,
    required this.rank,
    required this.examples,
  });

  final String priorityId;
  final CoachingPriorityCategory category;
  final String title;
  final String action;
  final int eventCount;
  final int eligibleDenominator;
  final int gameCount;
  final PlayerAnalyticsCoverageState coverage;
  final CoachingPriorityRank rank;
  final List<PlayerAnalyticsExample> examples;

  Map<String, Object?> toJson() => {
    'priorityId': priorityId,
    'category': category.name,
    'title': title,
    'action': action,
    'eventCount': eventCount,
    'eligibleDenominator': eligibleDenominator,
    'gameCount': gameCount,
    'coverage': coverage.name,
    'rank': rank.toJson(),
    'examples': examples.map((example) => example.toJson()).toList(),
  };
}

class SuppressedCoachingPriority {
  const SuppressedCoachingPriority({
    required this.priorityId,
    required this.code,
    required this.reason,
    required this.eventCount,
    required this.gameCount,
    required this.eligibleDenominator,
    required this.rank,
  });

  final String priorityId;
  final CoachingPrioritySuppressionCode code;
  final String reason;
  final int eventCount;
  final int gameCount;
  final int eligibleDenominator;
  final CoachingPriorityRank rank;

  Map<String, Object?> toJson() => {
    'priorityId': priorityId,
    'code': code.name,
    'reason': reason,
    'eventCount': eventCount,
    'gameCount': gameCount,
    'eligibleDenominator': eligibleDenominator,
    'rank': rank.toJson(),
  };
}

class SupportedPlayerStrength {
  const SupportedPlayerStrength({
    required this.strengthId,
    required this.title,
    required this.evidenceCount,
    required this.gameCount,
    required this.denominator,
  });

  final String strengthId;
  final String title;
  final int evidenceCount;
  final int gameCount;
  final int denominator;

  Map<String, Object> toJson() => {
    'strengthId': strengthId,
    'title': title,
    'evidenceCount': evidenceCount,
    'gameCount': gameCount,
    'denominator': denominator,
  };
}

class PlayerAnalyticsPerformance {
  const PlayerAnalyticsPerformance({
    this.manifestMicros = 0,
    this.selectionMicros = 0,
    this.aggregationMicros = 0,
    this.priorityMicros = 0,
    this.projectionMicros = 0,
    this.cacheHit = false,
    this.inputBytes = 0,
  });

  final int manifestMicros;
  final int selectionMicros;
  final int aggregationMicros;
  final int priorityMicros;
  final int projectionMicros;
  final bool cacheHit;
  final int inputBytes;

  PlayerAnalyticsPerformance copyWith({
    int? projectionMicros,
    bool? cacheHit,
  }) => PlayerAnalyticsPerformance(
    manifestMicros: manifestMicros,
    selectionMicros: selectionMicros,
    aggregationMicros: aggregationMicros,
    priorityMicros: priorityMicros,
    projectionMicros: projectionMicros ?? this.projectionMicros,
    cacheHit: cacheHit ?? this.cacheHit,
    inputBytes: inputBytes,
  );

  Map<String, Object> toJson() => {
    'manifestMicros': manifestMicros,
    'selectionMicros': selectionMicros,
    'aggregationMicros': aggregationMicros,
    'priorityMicros': priorityMicros,
    'projectionMicros': projectionMicros,
    'cacheHit': cacheHit,
    'inputBytes': inputBytes,
  };
}

class PlayerAnalyticsSnapshot {
  const PlayerAnalyticsSnapshot({
    required this.manifest,
    required this.distinctSavedGames,
    required this.canonicalAnalyzedGames,
    required this.knownSideGames,
    required this.totalPlayerMoves,
    required this.classificationEligibleMoves,
    required this.insightEligibleMoves,
    required this.openingEligibleGames,
    required this.classificationDistribution,
    required this.criticalErrorMetrics,
    required this.mateEvents,
    required this.materialEvents,
    required this.tacticalMechanisms,
    required this.openings,
    required this.trend,
    required this.priorities,
    required this.suppressedPriorities,
    required this.reviewQueue,
    required this.coverage,
    required this.windowLabel,
    required this.performance,
    this.strength,
  });

  final PlayerAnalyticsManifest manifest;
  final int distinctSavedGames;
  final int canonicalAnalyzedGames;
  final int knownSideGames;
  final int totalPlayerMoves;
  final int classificationEligibleMoves;
  final int insightEligibleMoves;
  final int openingEligibleGames;
  final Map<MoveQuality, PlayerMetric> classificationDistribution;
  final Map<String, PlayerMetric> criticalErrorMetrics;
  final Map<String, PlayerEventSummary> mateEvents;
  final Map<String, PlayerEventSummary> materialEvents;
  final Map<MoveInsightMechanismType, PlayerEventSummary> tacticalMechanisms;
  final List<PlayerOpeningSummary> openings;
  final PlayerTrend trend;
  final List<CoachingPriority> priorities;
  final List<SuppressedCoachingPriority> suppressedPriorities;
  final List<PlayerAnalyticsExample> reviewQueue;
  final PlayerAnalyticsCoverageState coverage;
  final String windowLabel;
  final PlayerAnalyticsPerformance performance;
  final SupportedPlayerStrength? strength;

  bool get hasData => canonicalAnalyzedGames > 0;

  PlayerAnalyticsSnapshot copyWith({
    List<CoachingPriority>? priorities,
    List<SuppressedCoachingPriority>? suppressedPriorities,
    List<PlayerAnalyticsExample>? reviewQueue,
    SupportedPlayerStrength? strength,
    bool clearStrength = false,
    PlayerAnalyticsPerformance? performance,
  }) => PlayerAnalyticsSnapshot(
    manifest: manifest,
    distinctSavedGames: distinctSavedGames,
    canonicalAnalyzedGames: canonicalAnalyzedGames,
    knownSideGames: knownSideGames,
    totalPlayerMoves: totalPlayerMoves,
    classificationEligibleMoves: classificationEligibleMoves,
    insightEligibleMoves: insightEligibleMoves,
    openingEligibleGames: openingEligibleGames,
    classificationDistribution: classificationDistribution,
    criticalErrorMetrics: criticalErrorMetrics,
    mateEvents: mateEvents,
    materialEvents: materialEvents,
    tacticalMechanisms: tacticalMechanisms,
    openings: openings,
    trend: trend,
    priorities: priorities ?? this.priorities,
    suppressedPriorities: suppressedPriorities ?? this.suppressedPriorities,
    reviewQueue: reviewQueue ?? this.reviewQueue,
    coverage: coverage,
    windowLabel: windowLabel,
    performance: performance ?? this.performance,
    strength: clearStrength ? null : (strength ?? this.strength),
  );

  Map<String, Object?> toJson() => {
    'snapshotId': manifest.snapshotId,
    'policyVersion': manifest.policyVersion,
    'schemaVersion': manifest.schemaVersion,
    'coverage': coverage.name,
    'windowLabel': windowLabel,
    'dataset': {
      'distinctSavedGames': distinctSavedGames,
      'canonicalAnalyzedGames': canonicalAnalyzedGames,
      'knownSideGames': knownSideGames,
      'totalPlayerMoves': totalPlayerMoves,
      'classificationEligibleMoves': classificationEligibleMoves,
      'insightEligibleMoves': insightEligibleMoves,
      'openingEligibleGames': openingEligibleGames,
      'excludedGames': manifest.exclusions.length,
    },
    'classificationDistribution': {
      for (final entry in classificationDistribution.entries)
        entry.key.name: entry.value.toJson(),
    },
    'criticalErrorMetrics': {
      for (final entry in criticalErrorMetrics.entries)
        entry.key: entry.value.toJson(),
    },
    'mateEvents': {
      for (final entry in mateEvents.entries) entry.key: entry.value.toJson(),
    },
    'materialEvents': {
      for (final entry in materialEvents.entries)
        entry.key: entry.value.toJson(),
    },
    'tacticalMechanisms': {
      for (final entry in tacticalMechanisms.entries)
        entry.key.name: entry.value.toJson(),
    },
    'openings': openings.map((opening) => opening.toJson()).toList(),
    'trend': trend.toJson(),
    'priorities': priorities.map((priority) => priority.toJson()).toList(),
    'suppressedPriorities': suppressedPriorities
        .map((priority) => priority.toJson())
        .toList(),
    'strength': strength?.toJson(),
    'reviewQueue': reviewQueue.map((example) => example.toJson()).toList(),
    'manifest': manifest.toJson(),
    'performance': performance.toJson(),
  };
}
