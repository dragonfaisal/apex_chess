import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_session_foundation.dart';

const analyzerProductReviewTimelineFoundationNextRecommendation =
    'planProductReviewBoardAndSummaryFoundation';
const analyzerProductReviewTimelineFoundationFailureRecommendation =
    'fixProductReviewTimelineFoundationBoundary';

enum AnalyzerProductReviewTimelineEntryKind {
  neutralSessionSummary('neutralSessionSummary'),
  unavailable('unavailable');

  const AnalyzerProductReviewTimelineEntryKind(this.wire);

  final String wire;
}

class AnalyzerProductReviewTimelineEntryFoundation {
  const AnalyzerProductReviewTimelineEntryFoundation({
    required this.entryId,
    required this.entryKind,
    required this.entryReady,
    required this.entryIsInternalOnly,
    required this.entryContainsPublicLabel,
    required this.entryContainsOfficialMetric,
  });

  final String entryId;
  final AnalyzerProductReviewTimelineEntryKind entryKind;
  final bool entryReady;
  final bool entryIsInternalOnly;
  final bool entryContainsPublicLabel;
  final bool entryContainsOfficialMetric;
}

class AnalyzerProductReviewTimelineFoundation {
  const AnalyzerProductReviewTimelineFoundation({
    required this.timelineComputed,
    required this.timelineReady,
    required this.unavailableReason,
    required this.sourceSessionId,
    required this.timelineScope,
    required this.evidenceStrength,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.totalEntries,
    required this.neutralEntryCount,
    required this.blockedEntryCount,
    required this.entries,
    required this.planningAllowed,
    required this.uiRenderingAllowed,
    required this.savedAnalysisAllowed,
    required this.archiveStatsAllowed,
    required this.publicLabelsAllowed,
    required this.officialMetricsAllowed,
    required this.timelineIsReadOnly,
    required this.timelineIsProductSafe,
    required this.timelineIsUiOutput,
    required this.timelineIsSavedAnalysis,
    required this.timelineIsPersistenceWrite,
    required this.timelineContainsPublicLabels,
    required this.timelineContainsOfficialMetrics,
    required this.safeForNextProductReviewStep,
    required this.nextRecommendation,
  });

  final bool timelineComputed;
  final bool timelineReady;
  final AnalyzerNeutralReviewPreviewUnavailableReason unavailableReason;
  final String sourceSessionId;

  final AnalyzerProductSafeReviewScope timelineScope;
  final AnalyzerProductSafeReviewEvidenceStrength evidenceStrength;

  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;

  final int totalEntries;
  final int neutralEntryCount;
  final int blockedEntryCount;
  final List<AnalyzerProductReviewTimelineEntryFoundation> entries;

  final bool planningAllowed;
  final bool uiRenderingAllowed;
  final bool savedAnalysisAllowed;
  final bool archiveStatsAllowed;
  final bool publicLabelsAllowed;
  final bool officialMetricsAllowed;

  final bool timelineIsReadOnly;
  final bool timelineIsProductSafe;
  final bool timelineIsUiOutput;
  final bool timelineIsSavedAnalysis;
  final bool timelineIsPersistenceWrite;
  final bool timelineContainsPublicLabels;
  final bool timelineContainsOfficialMetrics;

  final bool safeForNextProductReviewStep;
  final String nextRecommendation;
}

AnalyzerProductReviewTimelineFoundation
mapProductReviewTimelineFoundationFromSession(
  AnalyzerProductReviewSessionFoundation source,
) {
  const timelineIsReadOnly = true;
  const timelineIsUiOutput = false;
  const timelineIsSavedAnalysis = false;
  const timelineIsPersistenceWrite = false;
  const timelineContainsPublicLabels = false;
  const timelineContainsOfficialMetrics = false;

  final sourceClean =
      source.sessionComputed &&
      source.sessionReady &&
      source.unavailableReason ==
          AnalyzerNeutralReviewPreviewUnavailableReason.none &&
      source.planningAllowed &&
      !source.uiRenderingAllowed &&
      !source.savedAnalysisAllowed &&
      !source.archiveStatsAllowed &&
      !source.publicLabelsAllowed &&
      !source.officialMetricsAllowed &&
      source.sessionIsReadOnly &&
      source.sessionIsProductSafe &&
      !source.sessionIsUiOutput &&
      !source.sessionIsSavedAnalysis &&
      !source.sessionIsPersistenceWrite &&
      !source.sessionIsArchiveStatsOutput &&
      !source.sessionContainsPublicLabels &&
      !source.sessionContainsOfficialMetrics &&
      source.safeForNextProductReviewStep;

  final timelineReady =
      sourceClean &&
      timelineIsReadOnly &&
      !timelineIsUiOutput &&
      !timelineIsSavedAnalysis &&
      !timelineIsPersistenceWrite &&
      !timelineContainsPublicLabels &&
      !timelineContainsOfficialMetrics;
  final entries = <AnalyzerProductReviewTimelineEntryFoundation>[
    _entry(source, timelineReady: timelineReady),
  ];

  return AnalyzerProductReviewTimelineFoundation(
    timelineComputed: timelineReady,
    timelineReady: timelineReady,
    unavailableReason: source.unavailableReason,
    sourceSessionId: _sourceSessionId(source),
    timelineScope: source.sessionScope,
    evidenceStrength: source.evidenceStrength,
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    totalEntries: entries.length,
    neutralEntryCount: timelineReady ? 1 : 0,
    blockedEntryCount: timelineReady ? 0 : 1,
    entries: entries,
    planningAllowed: timelineReady,
    uiRenderingAllowed: false,
    savedAnalysisAllowed: false,
    archiveStatsAllowed: false,
    publicLabelsAllowed: false,
    officialMetricsAllowed: false,
    timelineIsReadOnly: timelineIsReadOnly,
    timelineIsProductSafe: timelineReady,
    timelineIsUiOutput: timelineIsUiOutput,
    timelineIsSavedAnalysis: timelineIsSavedAnalysis,
    timelineIsPersistenceWrite: timelineIsPersistenceWrite,
    timelineContainsPublicLabels: timelineContainsPublicLabels,
    timelineContainsOfficialMetrics: timelineContainsOfficialMetrics,
    safeForNextProductReviewStep: timelineReady,
    nextRecommendation: timelineReady
        ? analyzerProductReviewTimelineFoundationNextRecommendation
        : analyzerProductReviewTimelineFoundationFailureRecommendation,
  );
}

AnalyzerProductReviewTimelineEntryFoundation _entry(
  AnalyzerProductReviewSessionFoundation source, {
  required bool timelineReady,
}) {
  return AnalyzerProductReviewTimelineEntryFoundation(
    entryId: '${_sourceSessionId(source)}:entry:0',
    entryKind: timelineReady
        ? AnalyzerProductReviewTimelineEntryKind.neutralSessionSummary
        : AnalyzerProductReviewTimelineEntryKind.unavailable,
    entryReady: timelineReady,
    entryIsInternalOnly: true,
    entryContainsPublicLabel: false,
    entryContainsOfficialMetric: false,
  );
}

String _sourceSessionId(AnalyzerProductReviewSessionFoundation source) {
  return 'productReviewSession:${source.sourceFoundationViewModelId}';
}
