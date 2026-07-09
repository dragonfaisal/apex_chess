import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_foundation_view_model.dart';

const analyzerProductReviewSessionFoundationNextRecommendation =
    'planProductReviewTimelineFoundation';
const analyzerProductReviewSessionFoundationFailureRecommendation =
    'fixProductReviewSessionFoundationBoundary';

class AnalyzerProductReviewSessionFoundation {
  const AnalyzerProductReviewSessionFoundation({
    required this.sessionComputed,
    required this.sessionReady,
    required this.unavailableReason,
    required this.sourceFoundationViewModelId,
    required this.sessionScope,
    required this.evidenceStrength,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.planningAllowed,
    required this.uiRenderingAllowed,
    required this.savedAnalysisAllowed,
    required this.archiveStatsAllowed,
    required this.publicLabelsAllowed,
    required this.officialMetricsAllowed,
    required this.sessionIsReadOnly,
    required this.sessionIsProductSafe,
    required this.sessionIsUiOutput,
    required this.sessionIsSavedAnalysis,
    required this.sessionIsPersistenceWrite,
    required this.sessionIsArchiveStatsOutput,
    required this.sessionContainsPublicLabels,
    required this.sessionContainsOfficialMetrics,
    required this.safeForNextProductReviewStep,
    required this.nextRecommendation,
  });

  final bool sessionComputed;
  final bool sessionReady;
  final AnalyzerNeutralReviewPreviewUnavailableReason unavailableReason;
  final String sourceFoundationViewModelId;

  final AnalyzerProductSafeReviewScope sessionScope;
  final AnalyzerProductSafeReviewEvidenceStrength evidenceStrength;

  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;

  final bool planningAllowed;
  final bool uiRenderingAllowed;
  final bool savedAnalysisAllowed;
  final bool archiveStatsAllowed;
  final bool publicLabelsAllowed;
  final bool officialMetricsAllowed;

  final bool sessionIsReadOnly;
  final bool sessionIsProductSafe;
  final bool sessionIsUiOutput;
  final bool sessionIsSavedAnalysis;
  final bool sessionIsPersistenceWrite;
  final bool sessionIsArchiveStatsOutput;
  final bool sessionContainsPublicLabels;
  final bool sessionContainsOfficialMetrics;

  final bool safeForNextProductReviewStep;
  final String nextRecommendation;
}

AnalyzerProductReviewSessionFoundation
mapProductReviewSessionFoundationFromFoundation(
  AnalyzerProductReviewFoundationViewModel source,
) {
  const sessionIsReadOnly = true;
  const sessionIsUiOutput = false;
  const sessionIsSavedAnalysis = false;
  const sessionIsPersistenceWrite = false;
  const sessionIsArchiveStatsOutput = false;
  const sessionContainsPublicLabels = false;
  const sessionContainsOfficialMetrics = false;

  final sourceClean =
      source.foundationComputed &&
      source.foundationReadyForPlanning &&
      source.unavailableReason ==
          AnalyzerNeutralReviewPreviewUnavailableReason.none &&
      source.planningAllowed &&
      !source.uiRenderingAllowed &&
      !source.savedAnalysisAllowed &&
      !source.archiveStatsAllowed &&
      !source.publicLabelsAllowed &&
      !source.officialMetricsAllowed &&
      source.privateCountsAreInternalOnly &&
      !source.foundationContainsPublicLabels &&
      !source.foundationContainsOfficialMetrics &&
      source.safeForPhase40B;

  final sessionReady =
      sourceClean &&
      sessionIsReadOnly &&
      !sessionIsUiOutput &&
      !sessionIsSavedAnalysis &&
      !sessionIsPersistenceWrite &&
      !sessionIsArchiveStatsOutput &&
      !sessionContainsPublicLabels &&
      !sessionContainsOfficialMetrics;

  return AnalyzerProductReviewSessionFoundation(
    sessionComputed: sessionReady,
    sessionReady: sessionReady,
    unavailableReason: source.unavailableReason,
    sourceFoundationViewModelId: _sourceFoundationViewModelId(source),
    sessionScope: source.reviewScope,
    evidenceStrength: source.evidenceStrength,
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    planningAllowed: sessionReady,
    uiRenderingAllowed: false,
    savedAnalysisAllowed: false,
    archiveStatsAllowed: false,
    publicLabelsAllowed: false,
    officialMetricsAllowed: false,
    sessionIsReadOnly: sessionIsReadOnly,
    sessionIsProductSafe: sessionReady,
    sessionIsUiOutput: sessionIsUiOutput,
    sessionIsSavedAnalysis: sessionIsSavedAnalysis,
    sessionIsPersistenceWrite: sessionIsPersistenceWrite,
    sessionIsArchiveStatsOutput: sessionIsArchiveStatsOutput,
    sessionContainsPublicLabels: sessionContainsPublicLabels,
    sessionContainsOfficialMetrics: sessionContainsOfficialMetrics,
    safeForNextProductReviewStep: sessionReady,
    nextRecommendation: sessionReady
        ? analyzerProductReviewSessionFoundationNextRecommendation
        : analyzerProductReviewSessionFoundationFailureRecommendation,
  );
}

String _sourceFoundationViewModelId(
  AnalyzerProductReviewFoundationViewModel source,
) {
  return 'productReviewFoundation:${source.sourceContractId}';
}
