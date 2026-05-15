/// App-domain models for the Apex Online Review product contract.
///
/// These are the models future providers/state/UI should consume. They are
/// intentionally separate from transport DTOs and do not model backend
/// review-draft internals.
library;

enum ApexOnlineReviewMode {
  onlineFast('onlineFast'),
  onlineDeep('onlineDeep'),
  dev('dev');

  const ApexOnlineReviewMode(this.wire);

  final String wire;
}

enum ApexReviewStatus {
  completed('completed'),
  partial('partial'),
  failed('failed');

  const ApexReviewStatus(this.wire);

  final String wire;
}

enum ApexMoveQuality {
  best('best'),
  excellent('excellent'),
  good('good'),
  inaccuracy('inaccuracy'),
  mistake('mistake'),
  blunder('blunder'),
  unclassified('unclassified');

  const ApexMoveQuality(this.wire);

  final String wire;
}

enum ApexReviewConfidence {
  high('high'),
  medium('medium'),
  low('low'),
  unknown('unknown');

  const ApexReviewConfidence(this.wire);

  final String wire;
}

enum ApexCriticalityLevel {
  none('none'),
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const ApexCriticalityLevel(this.wire);

  final String wire;
}

class ApexOnlineReview {
  ApexOnlineReview({
    required this.contractVersion,
    required this.mode,
    required this.status,
    required this.summary,
    required Iterable<ApexReviewedMove> moves,
    required this.providerInfo,
    this.gameKey,
    this.headers,
    this.debugInfo,
    this.failure,
  }) : moves = List.unmodifiable(moves);

  final String contractVersion;
  final String? gameKey;
  final ApexOnlineReviewMode mode;
  final ApexReviewStatus status;
  final ApexReviewHeaders? headers;
  final ApexOnlineReviewSummary summary;
  final List<ApexReviewedMove> moves;
  final ApexReviewProviderInfo providerInfo;
  final ApexReviewDebugInfo? debugInfo;
  final ApexReviewFailure? failure;

  bool get isSuccess => status == ApexReviewStatus.completed && failure == null;

  bool get isPartial => status == ApexReviewStatus.partial;

  bool get isFailed => status == ApexReviewStatus.failed || failure != null;

  bool get hasDebug => debugInfo != null;
}

class ApexReviewHeaders {
  const ApexReviewHeaders({
    this.event,
    this.site,
    this.date,
    this.round,
    this.white,
    this.black,
    this.whiteElo,
    this.blackElo,
    this.result,
    this.eco,
    this.opening,
  });

  final String? event;
  final String? site;
  final String? date;
  final String? round;
  final String? white;
  final String? black;
  final String? whiteElo;
  final String? blackElo;
  final String? result;
  final String? eco;
  final String? opening;

  bool get hasPlayers => white != null || black != null;
}

class ApexOnlineReviewSummary {
  ApexOnlineReviewSummary({
    required this.totalPlies,
    required this.analyzedMoves,
    required this.failedMoves,
    required Map<String, int> qualityCounts,
    required this.bestMoveCount,
    required this.inaccuracyCount,
    required this.mistakeCount,
    required this.blunderCount,
    required this.criticalMoveCount,
    this.averageCpLoss,
    this.averageExpectedPointsLoss,
    this.maxCpLoss,
    this.maxExpectedPointsLoss,
    this.accuracy,
    this.acpl,
  }) : qualityCounts = Map.unmodifiable(qualityCounts);

  final int totalPlies;
  final int analyzedMoves;
  final int failedMoves;
  final Map<String, int> qualityCounts;
  final int bestMoveCount;
  final int inaccuracyCount;
  final int mistakeCount;
  final int blunderCount;
  final int criticalMoveCount;
  final double? averageCpLoss;
  final double? averageExpectedPointsLoss;
  final int? maxCpLoss;
  final double? maxExpectedPointsLoss;
  final double? accuracy;
  final double? acpl;
}

class ApexReviewedMove {
  ApexReviewedMove({
    required this.ply,
    required this.moveNumber,
    required this.side,
    required this.quality,
    required this.confidence,
    required this.criticalityLevel,
    required this.isCritical,
    required this.isTacticalCandidate,
    required this.hasMateWarning,
    required Iterable<String> warnings,
    this.san,
    this.uci,
    this.cpLoss,
    this.expectedPointsLoss,
    this.beforeFen,
    this.afterFen,
    this.engineBestMove,
    this.playedMatchesEngineBest,
    this.betterMove,
    this.engineLine,
  }) : warnings = List.unmodifiable(warnings);

  final int ply;
  final int moveNumber;
  final String side;
  final String? san;
  final String? uci;
  final ApexMoveQuality quality;
  final ApexReviewConfidence confidence;
  final int? cpLoss;
  final double? expectedPointsLoss;
  final String? beforeFen;
  final String? afterFen;
  final String? engineBestMove;
  final bool? playedMatchesEngineBest;
  final ApexBetterMove? betterMove;
  final ApexEngineLine? engineLine;
  final ApexCriticalityLevel criticalityLevel;
  final bool isCritical;
  final bool isTacticalCandidate;
  final bool hasMateWarning;
  final List<String> warnings;

  bool get hasBetterMove => betterMove?.moveUci != null;

  bool get hasEngineLine => engineLine != null;

  bool get hasWarning => warnings.isNotEmpty;

  bool get isBadMove =>
      quality == ApexMoveQuality.inaccuracy ||
      quality == ApexMoveQuality.mistake ||
      quality == ApexMoveQuality.blunder;

  bool get isStrongMove =>
      quality == ApexMoveQuality.best ||
      quality == ApexMoveQuality.excellent ||
      quality == ApexMoveQuality.good;

  bool get shouldHighlight =>
      isCritical ||
      isTacticalCandidate ||
      hasMateWarning ||
      criticalityLevel == ApexCriticalityLevel.high ||
      criticalityLevel == ApexCriticalityLevel.critical ||
      warnings.contains('mateSensitive');
}

class ApexBetterMove {
  const ApexBetterMove({
    required this.source,
    required this.confidence,
    this.moveUci,
    this.san,
  });

  final String? moveUci;
  final String? san;
  final String source;
  final ApexReviewConfidence confidence;
}

class ApexEngineLine {
  ApexEngineLine({
    required Iterable<String> pv,
    required this.multiPvCount,
    this.depth,
    this.bestMoveUci,
    this.score,
  }) : pv = List.unmodifiable(pv);

  final int? depth;
  final String? bestMoveUci;
  final List<String> pv;
  final ApexEngineScore? score;
  final int multiPvCount;
}

class ApexEngineScore {
  const ApexEngineScore({
    required this.scoreType,
    this.value,
    this.whiteCentipawns,
    this.moverCentipawns,
    this.mate,
  });

  final String scoreType;
  final int? value;
  final int? whiteCentipawns;
  final int? moverCentipawns;
  final int? mate;
}

class ApexReviewProviderInfo {
  const ApexReviewProviderInfo({
    required this.provider,
    required this.engine,
    required this.analysisVersion,
    required this.classifierVersion,
    required this.productContractVersion,
    required this.mode,
    required this.targetDepthTier,
    required this.isExecutionHintOnly,
  });

  final String provider;
  final String engine;
  final String analysisVersion;
  final String classifierVersion;
  final String productContractVersion;
  final ApexOnlineReviewMode mode;
  final String targetDepthTier;
  final bool isExecutionHintOnly;
}

class ApexReviewDebugInfo {
  ApexReviewDebugInfo({
    required this.enabled,
    required this.sourceEndpoint,
    required Iterable<String> omittedInternalSections,
    this.internalGameKey,
    this.internalSafetySummary,
  }) : omittedInternalSections = List.unmodifiable(omittedInternalSections);

  final bool enabled;
  final String sourceEndpoint;
  final String? internalGameKey;
  final List<String> omittedInternalSections;
  final ApexReviewInternalSafetySummary? internalSafetySummary;
}

class ApexReviewInternalSafetySummary {
  const ApexReviewInternalSafetySummary({
    required this.reviewDraftOk,
    required this.moveCount,
    required this.failedMoves,
    required this.classifierVersion,
    required this.ledgerPersistent,
    required this.runtimeMigrationReady,
  });

  final bool reviewDraftOk;
  final int moveCount;
  final int failedMoves;
  final String classifierVersion;
  final bool ledgerPersistent;
  final bool runtimeMigrationReady;
}

class ApexReviewFailure {
  const ApexReviewFailure({required this.code, required this.message});

  final String code;
  final String message;
}
