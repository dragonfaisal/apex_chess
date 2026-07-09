import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_gateway.dart';

const analyzerProductReviewFoundationNextRecommendation =
    'planProductSafeReviewSurfaceWithoutPublicLabels';
const analyzerProductReviewFoundationFailureRecommendation =
    'fixProductReviewFoundationBoundary';

class AnalyzerProductReviewFoundationViewModel {
  const AnalyzerProductReviewFoundationViewModel({
    required this.foundationComputed,
    required this.foundationReadyForPlanning,
    required this.unavailableReason,
    required this.sourceContractId,
    required this.reviewScope,
    required this.evidenceStrength,
    required this.title,
    required this.statusText,
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
    required this.privateCountsAreInternalOnly,
    required this.foundationContainsPublicLabels,
    required this.foundationContainsOfficialMetrics,
    required this.safeForPhase40B,
    required this.nextRecommendation,
  });

  final bool foundationComputed;
  final bool foundationReadyForPlanning;
  final AnalyzerNeutralReviewPreviewUnavailableReason unavailableReason;
  final String sourceContractId;
  final AnalyzerProductSafeReviewScope reviewScope;
  final AnalyzerProductSafeReviewEvidenceStrength evidenceStrength;

  final String title;
  final String statusText;

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
  final bool privateCountsAreInternalOnly;

  final bool foundationContainsPublicLabels;
  final bool foundationContainsOfficialMetrics;

  final bool safeForPhase40B;
  final String nextRecommendation;
}

AnalyzerProductReviewFoundationViewModel
mapProductReviewFoundationViewModelFromContract(
  AnalyzerProductSafeReviewContract source,
) {
  return _mapProductReviewFoundationViewModelFromGateway(
    evaluateProductSafeReviewGateway(source),
    reviewScope: source.reviewScope,
    evidenceStrength: source.evidenceStrength,
  );
}

AnalyzerProductReviewFoundationViewModel
mapProductReviewFoundationViewModelFromGateway(
  AnalyzerProductSafeReviewGatewayDecision source,
) {
  return _mapProductReviewFoundationViewModelFromGateway(
    source,
    reviewScope: AnalyzerProductSafeReviewScope.singleMoveControlled,
    evidenceStrength:
        AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
  );
}

AnalyzerProductReviewFoundationViewModel
_mapProductReviewFoundationViewModelFromGateway(
  AnalyzerProductSafeReviewGatewayDecision source, {
  required AnalyzerProductSafeReviewScope reviewScope,
  required AnalyzerProductSafeReviewEvidenceStrength evidenceStrength,
}) {
  final preview = mapNeutralReviewPreviewDisplayModelFromGateway(source);
  final foundationReady =
      preview.displayModelComputed &&
      preview.displayModelReady &&
      preview.unavailableReason ==
          AnalyzerNeutralReviewPreviewUnavailableReason.none &&
      preview.planningAllowed &&
      !preview.uiRenderingAllowed &&
      !preview.savedAnalysisAllowed &&
      !preview.archiveStatsAllowed &&
      !preview.publicLabelsAllowed &&
      !preview.officialMetricsAllowed &&
      source.gatewayReason ==
          AnalyzerProductSafeReviewGatewayReason.productSafeContractReady &&
      source.safeForPhase38E;

  return AnalyzerProductReviewFoundationViewModel(
    foundationComputed: foundationReady,
    foundationReadyForPlanning: foundationReady,
    unavailableReason: preview.unavailableReason,
    sourceContractId: source.sourceContractId,
    reviewScope: reviewScope,
    evidenceStrength: evidenceStrength,
    title: 'Review foundation',
    statusText: foundationReady
        ? 'Ready for product review planning'
        : 'Product review foundation unavailable',
    planningAllowed: foundationReady,
    uiRenderingAllowed: false,
    savedAnalysisAllowed: false,
    archiveStatsAllowed: false,
    publicLabelsAllowed: false,
    officialMetricsAllowed: false,
    totalPrivateEntries: preview.totalPrivateEntries,
    positiveCandidateCount: preview.positiveCandidateCount,
    neutralCandidateCount: preview.neutralCandidateCount,
    negativeCandidateCount: preview.negativeCandidateCount,
    unavailableCount: preview.unavailableCount,
    privateCountsAreInternalOnly: foundationReady,
    foundationContainsPublicLabels: false,
    foundationContainsOfficialMetrics: false,
    safeForPhase40B: foundationReady,
    nextRecommendation: foundationReady
        ? analyzerProductReviewFoundationNextRecommendation
        : analyzerProductReviewFoundationFailureRecommendation,
  );
}
