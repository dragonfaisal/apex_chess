import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';

const analyzerProductSafeReviewGatewayNextRecommendation =
    'inspectReviewUiForProductSafeGatewayConsumption';
const analyzerProductSafeReviewGatewayFailureRecommendation =
    'fixProductSafeReviewGatewayBoundary';

enum AnalyzerProductSafeReviewGatewayReason {
  productSafeContractReady('productSafeContractReady'),
  sourceUnavailable('sourceUnavailable'),
  sourceUnsafe('sourceUnsafe'),
  uiOutputBlocked('uiOutputBlocked'),
  savedAnalysisBlocked('savedAnalysisBlocked'),
  archiveStatsBlocked('archiveStatsBlocked'),
  publicLabelsBlocked('publicLabelsBlocked'),
  officialMetricsBlocked('officialMetricsBlocked'),
  sideEffectsBlocked('sideEffectsBlocked');

  const AnalyzerProductSafeReviewGatewayReason(this.wire);

  final String wire;
}

class AnalyzerProductSafeReviewGatewayDecision {
  const AnalyzerProductSafeReviewGatewayDecision({
    required this.gatewayComputed,
    required this.gatewayAllowsProductReviewPlanning,
    required this.gatewayAllowsUiRendering,
    required this.gatewayAllowsSavedAnalysis,
    required this.gatewayAllowsArchiveStats,
    required this.gatewayAllowsPublicLabels,
    required this.gatewayAllowsOfficialMetrics,
    required this.gatewayReason,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.sourceContractId,
    required this.safeForPhase38E,
    required this.nextRecommendation,
  });

  final bool gatewayComputed;
  final bool gatewayAllowsProductReviewPlanning;
  final bool gatewayAllowsUiRendering;
  final bool gatewayAllowsSavedAnalysis;
  final bool gatewayAllowsArchiveStats;
  final bool gatewayAllowsPublicLabels;
  final bool gatewayAllowsOfficialMetrics;
  final AnalyzerProductSafeReviewGatewayReason gatewayReason;
  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;
  final String sourceContractId;
  final bool safeForPhase38E;
  final String nextRecommendation;
}

AnalyzerProductSafeReviewGatewayDecision evaluateProductSafeReviewGateway(
  AnalyzerProductSafeReviewContract source,
) {
  final sourceClean = _isCleanProductSafeContract(source);

  return AnalyzerProductSafeReviewGatewayDecision(
    gatewayComputed: sourceClean,
    gatewayAllowsProductReviewPlanning: sourceClean,
    gatewayAllowsUiRendering: false,
    gatewayAllowsSavedAnalysis: false,
    gatewayAllowsArchiveStats: false,
    gatewayAllowsPublicLabels: false,
    gatewayAllowsOfficialMetrics: false,
    gatewayReason: sourceClean
        ? AnalyzerProductSafeReviewGatewayReason.productSafeContractReady
        : _blockedReason(source),
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    sourceContractId: source.productSafeReviewContractId,
    safeForPhase38E: sourceClean,
    nextRecommendation: sourceClean
        ? analyzerProductSafeReviewGatewayNextRecommendation
        : analyzerProductSafeReviewGatewayFailureRecommendation,
  );
}

bool _isCleanProductSafeContract(AnalyzerProductSafeReviewContract source) {
  return source.mappingSucceeded &&
      source.contractComputed &&
      source.reviewReady &&
      source.reviewUnavailableReason ==
          AnalyzerProductSafeReviewUnavailableReason.none &&
      source.reviewScope ==
          AnalyzerProductSafeReviewScope.singleMoveControlled &&
      source.evidenceStrength ==
          AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly &&
      source.privateCountsAreInternalOnly &&
      source.contractIsProductSafe &&
      source.contractIsDeveloperEvidenceBacked &&
      source.contractIsReadOnly &&
      !source.contractIsUiOutput &&
      !source.contractIsProductUi &&
      !source.contractIsSavedAnalysis &&
      !source.contractIsPersistenceWrite &&
      !source.contractIsFileWrite &&
      !source.contractIsBackendPayload &&
      !source.contractIsArchiveStatsOutput &&
      !source.contractContainsPublicLabels &&
      !source.contractContainsOfficialMetrics &&
      !source.contractContainsUiPresentation &&
      !source.publicLabelComputed &&
      source.publicLabel == null &&
      !source.officialMoveQualityComputed &&
      source.officialMoveQuality == null &&
      !source.officialCpLossComputed &&
      !source.officialWinPercentComputed &&
      !source.accuracyComputed &&
      !source.acplComputed &&
      !source.classificationComputed &&
      !source.publicClassifierOutputComputed &&
      !source.savedAnalysisWritten &&
      !source.uiOutputProduced &&
      !source.persistenceWritePerformed &&
      !source.fileWritePerformed &&
      !source.backendPayloadProduced &&
      !source.archiveStatsTouched &&
      source.safeForPhase38D;
}

AnalyzerProductSafeReviewGatewayReason _blockedReason(
  AnalyzerProductSafeReviewContract source,
) {
  if (!source.contractComputed ||
      !source.reviewReady ||
      source.reviewUnavailableReason !=
          AnalyzerProductSafeReviewUnavailableReason.none) {
    return source.reviewUnavailableReason ==
            AnalyzerProductSafeReviewUnavailableReason.sourceUnavailable
        ? AnalyzerProductSafeReviewGatewayReason.sourceUnavailable
        : AnalyzerProductSafeReviewGatewayReason.sourceUnsafe;
  }
  if (source.contractIsUiOutput ||
      source.contractIsProductUi ||
      source.contractContainsUiPresentation ||
      source.uiOutputProduced) {
    return AnalyzerProductSafeReviewGatewayReason.uiOutputBlocked;
  }
  if (source.contractIsSavedAnalysis || source.savedAnalysisWritten) {
    return AnalyzerProductSafeReviewGatewayReason.savedAnalysisBlocked;
  }
  if (source.contractIsArchiveStatsOutput || source.archiveStatsTouched) {
    return AnalyzerProductSafeReviewGatewayReason.archiveStatsBlocked;
  }
  if (source.contractContainsPublicLabels ||
      source.publicLabelComputed ||
      source.publicLabel != null) {
    return AnalyzerProductSafeReviewGatewayReason.publicLabelsBlocked;
  }
  if (source.contractContainsOfficialMetrics ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return AnalyzerProductSafeReviewGatewayReason.officialMetricsBlocked;
  }
  if (source.contractIsPersistenceWrite ||
      source.contractIsFileWrite ||
      source.contractIsBackendPayload ||
      source.persistenceWritePerformed ||
      source.fileWritePerformed ||
      source.backendPayloadProduced) {
    return AnalyzerProductSafeReviewGatewayReason.sideEffectsBlocked;
  }
  return AnalyzerProductSafeReviewGatewayReason.sourceUnsafe;
}
