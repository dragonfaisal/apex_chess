enum AnalyzerProductSafeReviewUnavailableReason {
  none('none'),
  sourceUnsafe('sourceUnsafe'),
  sourceUnavailable('sourceUnavailable'),
  unsupportedScope('unsupportedScope');

  const AnalyzerProductSafeReviewUnavailableReason(this.wire);

  final String wire;
}

enum AnalyzerProductSafeReviewScope {
  singleMoveControlled('singleMoveControlled');

  const AnalyzerProductSafeReviewScope(this.wire);

  final String wire;
}

enum AnalyzerProductSafeReviewEvidenceStrength {
  developerProofOnly('developerProofOnly'),
  productSafePending('productSafePending');

  const AnalyzerProductSafeReviewEvidenceStrength(this.wire);

  final String wire;
}

const analyzerProductSafeReviewContractSource =
    'phase38BProductSafeReviewContract';
const analyzerProductSafeReviewContractVersion = 'phase38B.v1';
const analyzerProductSafeReviewContractNextRecommendation =
    'planProductSafeReviewGatewayWithoutUi';
const analyzerProductSafeReviewContractFailureRecommendation =
    'fixProductSafeReviewContract';

class AnalyzerProductSafeReviewContract {
  const AnalyzerProductSafeReviewContract({
    required this.productSafeReviewContractId,
    required this.sourceConsumerResultId,
    required this.contractSource,
    required this.contractVersion,
    required this.contractComputed,
    required this.reviewReady,
    required this.reviewUnavailableReason,
    required this.reviewScope,
    required this.requestedDepth,
    required this.evidenceStrength,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.privateCountsAreInternalOnly,
    required this.contractIsProductSafe,
    required this.contractIsDeveloperEvidenceBacked,
    required this.contractIsReadOnly,
    required this.contractIsUiOutput,
    required this.contractIsProductUi,
    required this.contractIsSavedAnalysis,
    required this.contractIsPersistenceWrite,
    required this.contractIsFileWrite,
    required this.contractIsBackendPayload,
    required this.contractIsArchiveStatsOutput,
    required this.contractContainsPublicLabels,
    required this.contractContainsOfficialMetrics,
    required this.contractContainsUiPresentation,
    required this.publicLabelComputed,
    required this.publicLabel,
    required this.officialMoveQualityComputed,
    required this.officialMoveQuality,
    required this.officialCpLossComputed,
    required this.officialWinPercentComputed,
    required this.accuracyComputed,
    required this.acplComputed,
    required this.classificationComputed,
    required this.publicClassifierOutputComputed,
    required this.savedAnalysisWritten,
    required this.uiOutputProduced,
    required this.persistenceWritePerformed,
    required this.fileWritePerformed,
    required this.backendPayloadProduced,
    required this.archiveStatsTouched,
    required this.mappingSucceeded,
    required this.failureMessage,
    required this.safeForPhase38C,
    required this.safeForPhase38D,
    required this.nextRecommendation,
  });

  final String productSafeReviewContractId;
  final String sourceConsumerResultId;
  final String contractSource;
  final String contractVersion;

  final bool contractComputed;
  final bool reviewReady;
  final AnalyzerProductSafeReviewUnavailableReason reviewUnavailableReason;

  final AnalyzerProductSafeReviewScope reviewScope;
  final int requestedDepth;
  final AnalyzerProductSafeReviewEvidenceStrength evidenceStrength;

  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;
  final bool privateCountsAreInternalOnly;

  final bool contractIsProductSafe;
  final bool contractIsDeveloperEvidenceBacked;
  final bool contractIsReadOnly;
  final bool contractIsUiOutput;
  final bool contractIsProductUi;
  final bool contractIsSavedAnalysis;
  final bool contractIsPersistenceWrite;
  final bool contractIsFileWrite;
  final bool contractIsBackendPayload;
  final bool contractIsArchiveStatsOutput;
  final bool contractContainsPublicLabels;
  final bool contractContainsOfficialMetrics;
  final bool contractContainsUiPresentation;

  final bool publicLabelComputed;
  final String? publicLabel;
  final bool officialMoveQualityComputed;
  final String? officialMoveQuality;
  final bool officialCpLossComputed;
  final bool officialWinPercentComputed;
  final bool accuracyComputed;
  final bool acplComputed;
  final bool classificationComputed;
  final bool publicClassifierOutputComputed;

  final bool savedAnalysisWritten;
  final bool uiOutputProduced;
  final bool persistenceWritePerformed;
  final bool fileWritePerformed;
  final bool backendPayloadProduced;
  final bool archiveStatsTouched;

  final bool mappingSucceeded;
  final String? failureMessage;
  final bool safeForPhase38C;
  final bool safeForPhase38D;
  final String nextRecommendation;
}
