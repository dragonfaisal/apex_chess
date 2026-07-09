import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_gateway.dart';

const analyzerNeutralReviewPreviewDisplayModelNextRecommendation =
    'planDevGatedNeutralPreviewSurface';
const analyzerNeutralReviewPreviewDisplayModelFailureRecommendation =
    'fixNeutralReviewPreviewDisplayModel';

enum AnalyzerNeutralReviewPreviewUnavailableReason {
  none('none'),
  gatewayNotComputed('gatewayNotComputed'),
  planningNotAllowed('planningNotAllowed'),
  uiRenderingAllowed('uiRenderingAllowed'),
  savedAnalysisAllowed('savedAnalysisAllowed'),
  archiveStatsAllowed('archiveStatsAllowed'),
  publicLabelsAllowed('publicLabelsAllowed'),
  officialMetricsAllowed('officialMetricsAllowed'),
  sourceUnsafe('sourceUnsafe');

  const AnalyzerNeutralReviewPreviewUnavailableReason(this.wire);

  final String wire;
}

class AnalyzerNeutralReviewPreviewDisplayModel {
  const AnalyzerNeutralReviewPreviewDisplayModel({
    required this.displayModelComputed,
    required this.displayModelReady,
    required this.unavailableReason,
    required this.planningAllowed,
    required this.uiRenderingAllowed,
    required this.savedAnalysisAllowed,
    required this.archiveStatsAllowed,
    required this.publicLabelsAllowed,
    required this.officialMetricsAllowed,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.safeForPhase39C,
    required this.nextRecommendation,
  });

  final bool displayModelComputed;
  final bool displayModelReady;
  final AnalyzerNeutralReviewPreviewUnavailableReason unavailableReason;

  final bool planningAllowed;
  final bool uiRenderingAllowed;
  final bool savedAnalysisAllowed;
  final bool archiveStatsAllowed;
  final bool publicLabelsAllowed;
  final bool officialMetricsAllowed;

  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;

  final bool safeForPhase39C;
  final String nextRecommendation;
}

AnalyzerNeutralReviewPreviewDisplayModel
mapNeutralReviewPreviewDisplayModelFromGateway(
  AnalyzerProductSafeReviewGatewayDecision source,
) {
  final unavailableReason = _unavailableReason(source);
  final sourceClean =
      unavailableReason == AnalyzerNeutralReviewPreviewUnavailableReason.none;

  return AnalyzerNeutralReviewPreviewDisplayModel(
    displayModelComputed: sourceClean,
    displayModelReady: sourceClean,
    unavailableReason: unavailableReason,
    planningAllowed: sourceClean,
    uiRenderingAllowed: false,
    savedAnalysisAllowed: false,
    archiveStatsAllowed: false,
    publicLabelsAllowed: false,
    officialMetricsAllowed: false,
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    safeForPhase39C: sourceClean,
    nextRecommendation: sourceClean
        ? analyzerNeutralReviewPreviewDisplayModelNextRecommendation
        : analyzerNeutralReviewPreviewDisplayModelFailureRecommendation,
  );
}

AnalyzerNeutralReviewPreviewUnavailableReason _unavailableReason(
  AnalyzerProductSafeReviewGatewayDecision source,
) {
  if (!source.gatewayComputed) {
    return AnalyzerNeutralReviewPreviewUnavailableReason.gatewayNotComputed;
  }
  if (!source.gatewayAllowsProductReviewPlanning) {
    return AnalyzerNeutralReviewPreviewUnavailableReason.planningNotAllowed;
  }
  if (source.gatewayAllowsUiRendering) {
    return AnalyzerNeutralReviewPreviewUnavailableReason.uiRenderingAllowed;
  }
  if (source.gatewayAllowsSavedAnalysis) {
    return AnalyzerNeutralReviewPreviewUnavailableReason.savedAnalysisAllowed;
  }
  if (source.gatewayAllowsArchiveStats) {
    return AnalyzerNeutralReviewPreviewUnavailableReason.archiveStatsAllowed;
  }
  if (source.gatewayAllowsPublicLabels) {
    return AnalyzerNeutralReviewPreviewUnavailableReason.publicLabelsAllowed;
  }
  if (source.gatewayAllowsOfficialMetrics) {
    return AnalyzerNeutralReviewPreviewUnavailableReason.officialMetricsAllowed;
  }
  if (!source.safeForPhase38E ||
      source.gatewayReason !=
          AnalyzerProductSafeReviewGatewayReason.productSafeContractReady) {
    return AnalyzerNeutralReviewPreviewUnavailableReason.sourceUnsafe;
  }
  return AnalyzerNeutralReviewPreviewUnavailableReason.none;
}
