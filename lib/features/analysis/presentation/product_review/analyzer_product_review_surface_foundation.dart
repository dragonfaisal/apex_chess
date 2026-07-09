import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_timeline_foundation.dart';

const analyzerProductReviewSurfaceFoundationNextRecommendation =
    'planDevOnlyProductReviewSurfacePreview';
const analyzerProductReviewSurfaceFoundationFailureRecommendation =
    'fixProductReviewSurfaceFoundationBoundary';

enum AnalyzerProductReviewSurfaceBoardPreviewReason {
  productSafeTimelineReady('productSafeTimelineReady'),
  sourceUnavailable('sourceUnavailable'),
  uiRenderingBlocked('uiRenderingBlocked');

  const AnalyzerProductReviewSurfaceBoardPreviewReason(this.wire);

  final String wire;
}

class AnalyzerProductReviewHeaderFoundation {
  const AnalyzerProductReviewHeaderFoundation({
    required this.surfaceTitle,
    required this.readiness,
    required this.scope,
    required this.evidenceStrength,
    required this.productSafeStatus,
  });

  final String surfaceTitle;
  final String readiness;
  final AnalyzerProductSafeReviewScope scope;
  final AnalyzerProductSafeReviewEvidenceStrength evidenceStrength;
  final String productSafeStatus;
}

class AnalyzerProductReviewSummaryFoundation {
  const AnalyzerProductReviewSummaryFoundation({
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.publicLabelsBlocked,
    required this.officialMetricsBlocked,
    required this.savedArchiveBlocked,
  });

  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;
  final bool publicLabelsBlocked;
  final bool officialMetricsBlocked;
  final bool savedArchiveBlocked;
}

class AnalyzerProductReviewBoardSafeFoundation {
  const AnalyzerProductReviewBoardSafeFoundation({
    required this.boardPreviewAvailable,
    required this.boardPreviewReason,
  });

  final bool boardPreviewAvailable;
  final AnalyzerProductReviewSurfaceBoardPreviewReason boardPreviewReason;
}

class AnalyzerProductReviewSurfaceTimelineEntryFoundation {
  const AnalyzerProductReviewSurfaceTimelineEntryFoundation({
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

class AnalyzerProductReviewSurfaceFoundation {
  const AnalyzerProductReviewSurfaceFoundation({
    required this.surfaceComputed,
    required this.surfaceReady,
    required this.unavailableReason,
    required this.sourceTimelineId,
    required this.header,
    required this.summary,
    required this.board,
    required this.timelineEntries,
    required this.planningAllowed,
    required this.uiRenderingAllowed,
    required this.savedAnalysisAllowed,
    required this.archiveStatsAllowed,
    required this.publicLabelsAllowed,
    required this.officialMetricsAllowed,
    required this.surfaceIsReadOnly,
    required this.surfaceIsProductSafe,
    required this.surfaceIsUiOutput,
    required this.surfaceIsSavedAnalysis,
    required this.surfaceContainsPublicLabels,
    required this.surfaceContainsOfficialMetrics,
    required this.safeForPhase41A,
    required this.nextRecommendation,
  });

  final bool surfaceComputed;
  final bool surfaceReady;
  final AnalyzerNeutralReviewPreviewUnavailableReason unavailableReason;
  final String sourceTimelineId;

  final AnalyzerProductReviewHeaderFoundation header;
  final AnalyzerProductReviewSummaryFoundation summary;
  final AnalyzerProductReviewBoardSafeFoundation board;
  final List<AnalyzerProductReviewSurfaceTimelineEntryFoundation>
  timelineEntries;

  final bool planningAllowed;
  final bool uiRenderingAllowed;
  final bool savedAnalysisAllowed;
  final bool archiveStatsAllowed;
  final bool publicLabelsAllowed;
  final bool officialMetricsAllowed;

  final bool surfaceIsReadOnly;
  final bool surfaceIsProductSafe;
  final bool surfaceIsUiOutput;
  final bool surfaceIsSavedAnalysis;
  final bool surfaceContainsPublicLabels;
  final bool surfaceContainsOfficialMetrics;

  final bool safeForPhase41A;
  final String nextRecommendation;
}

AnalyzerProductReviewSurfaceFoundation
mapProductReviewSurfaceFoundationFromTimeline(
  AnalyzerProductReviewTimelineFoundation source,
) {
  const surfaceIsReadOnly = true;
  const surfaceIsUiOutput = false;
  const surfaceIsSavedAnalysis = false;
  const surfaceContainsPublicLabels = false;
  const surfaceContainsOfficialMetrics = false;

  final entries = _timelineEntries(source);
  final entriesSafe =
      entries.isNotEmpty &&
      entries.every(
        (entry) =>
            entry.entryIsInternalOnly &&
            !entry.entryContainsPublicLabel &&
            !entry.entryContainsOfficialMetric,
      );
  final sourceClean =
      source.timelineComputed &&
      source.timelineReady &&
      source.unavailableReason ==
          AnalyzerNeutralReviewPreviewUnavailableReason.none &&
      source.planningAllowed &&
      !source.uiRenderingAllowed &&
      !source.savedAnalysisAllowed &&
      !source.archiveStatsAllowed &&
      !source.publicLabelsAllowed &&
      !source.officialMetricsAllowed &&
      source.timelineIsReadOnly &&
      source.timelineIsProductSafe &&
      !source.timelineIsUiOutput &&
      !source.timelineIsSavedAnalysis &&
      !source.timelineIsPersistenceWrite &&
      !source.timelineContainsPublicLabels &&
      !source.timelineContainsOfficialMetrics &&
      source.safeForNextProductReviewStep &&
      entriesSafe;

  final surfaceReady =
      sourceClean &&
      surfaceIsReadOnly &&
      !surfaceIsUiOutput &&
      !surfaceIsSavedAnalysis &&
      !surfaceContainsPublicLabels &&
      !surfaceContainsOfficialMetrics;

  return AnalyzerProductReviewSurfaceFoundation(
    surfaceComputed: surfaceReady,
    surfaceReady: surfaceReady,
    unavailableReason: source.unavailableReason,
    sourceTimelineId: _sourceTimelineId(source),
    header: _header(source, surfaceReady: surfaceReady),
    summary: _summary(source),
    board: _board(source, surfaceReady: surfaceReady),
    timelineEntries: entries,
    planningAllowed: surfaceReady,
    uiRenderingAllowed: false,
    savedAnalysisAllowed: false,
    archiveStatsAllowed: false,
    publicLabelsAllowed: false,
    officialMetricsAllowed: false,
    surfaceIsReadOnly: surfaceIsReadOnly,
    surfaceIsProductSafe: surfaceReady,
    surfaceIsUiOutput: surfaceIsUiOutput,
    surfaceIsSavedAnalysis: surfaceIsSavedAnalysis,
    surfaceContainsPublicLabels: surfaceContainsPublicLabels,
    surfaceContainsOfficialMetrics: surfaceContainsOfficialMetrics,
    safeForPhase41A: surfaceReady,
    nextRecommendation: surfaceReady
        ? analyzerProductReviewSurfaceFoundationNextRecommendation
        : analyzerProductReviewSurfaceFoundationFailureRecommendation,
  );
}

AnalyzerProductReviewHeaderFoundation _header(
  AnalyzerProductReviewTimelineFoundation source, {
  required bool surfaceReady,
}) {
  return AnalyzerProductReviewHeaderFoundation(
    surfaceTitle: 'Review foundation',
    readiness: surfaceReady ? 'ready' : 'unavailable',
    scope: source.timelineScope,
    evidenceStrength: source.evidenceStrength,
    productSafeStatus: surfaceReady ? 'productSafe' : 'blocked',
  );
}

AnalyzerProductReviewSummaryFoundation _summary(
  AnalyzerProductReviewTimelineFoundation source,
) {
  return AnalyzerProductReviewSummaryFoundation(
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    publicLabelsBlocked: true,
    officialMetricsBlocked: true,
    savedArchiveBlocked: true,
  );
}

AnalyzerProductReviewBoardSafeFoundation _board(
  AnalyzerProductReviewTimelineFoundation source, {
  required bool surfaceReady,
}) {
  return AnalyzerProductReviewBoardSafeFoundation(
    boardPreviewAvailable: false,
    boardPreviewReason: surfaceReady
        ? AnalyzerProductReviewSurfaceBoardPreviewReason.uiRenderingBlocked
        : source.unavailableReason ==
              AnalyzerNeutralReviewPreviewUnavailableReason.sourceUnsafe
        ? AnalyzerProductReviewSurfaceBoardPreviewReason.sourceUnavailable
        : AnalyzerProductReviewSurfaceBoardPreviewReason.uiRenderingBlocked,
  );
}

List<AnalyzerProductReviewSurfaceTimelineEntryFoundation> _timelineEntries(
  AnalyzerProductReviewTimelineFoundation source,
) {
  return List<AnalyzerProductReviewSurfaceTimelineEntryFoundation>.unmodifiable(
    source.entries.map(
      (entry) => AnalyzerProductReviewSurfaceTimelineEntryFoundation(
        entryId: entry.entryId,
        entryKind: entry.entryKind,
        entryReady: entry.entryReady,
        entryIsInternalOnly: entry.entryIsInternalOnly,
        entryContainsPublicLabel: entry.entryContainsPublicLabel,
        entryContainsOfficialMetric: entry.entryContainsOfficialMetric,
      ),
    ),
  );
}

String _sourceTimelineId(AnalyzerProductReviewTimelineFoundation source) {
  return 'productReviewTimeline:${source.sourceSessionId}';
}
