import 'dart:convert';

const analyzerDeveloperReviewEnvelopeSnapshotSource =
    'phase36HDeveloperReviewEnvelopeSnapshotBridge';
const analyzerDeveloperReviewEnvelopeSnapshotVersion = 'phase36H.v1';
const analyzerDeveloperReviewEnvelopeSnapshotNextRecommendation =
    'implementDeveloperOnlyReviewEnvelopeSnapshotGoldenCasesWithoutPublicLabels';
const analyzerDeveloperReviewEnvelopeSnapshotFailureRecommendation =
    'fixDeveloperReviewEnvelopeSnapshotBridge';

class AnalyzerDeveloperReviewEnvelopeSnapshot {
  const AnalyzerDeveloperReviewEnvelopeSnapshot({
    required this.snapshotId,
    required this.sourceReviewEnvelopeId,
    required this.sourceTimelineCollectionId,
    required this.sourceReviewSummaryId,
    required this.snapshotSource,
    required this.snapshotVersion,
    required this.sourceReviewEnvelopeComputed,
    required this.sourceReviewEnvelopeIsDeveloperOnly,
    required this.sourceReviewEnvelopeIsPublic,
    required this.sourceReviewEnvelopeIsProductReview,
    required this.sourceReviewEnvelopeIsSavedAnalysis,
    required this.sourceReviewEnvelopeIsOfficial,
    required this.sourceReviewEnvelopeIsUiOutput,
    required this.sourceReviewEnvelopeIsArchiveStatsOutput,
    required this.sourceReviewEnvelopeIsFullGameAnalysis,
    required this.sourceReviewEnvelopeIsProductTimeline,
    required this.snapshotComputed,
    required this.snapshotIsDeveloperOnly,
    required this.snapshotIsReadOnly,
    required this.snapshotIsPublic,
    required this.snapshotIsProductReview,
    required this.snapshotIsSavedAnalysis,
    required this.snapshotIsOfficial,
    required this.snapshotIsUiOutput,
    required this.snapshotIsArchiveStatsOutput,
    required this.snapshotIsFullGameAnalysis,
    required this.snapshotIsProductTimeline,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.snapshotCountsMatchSource,
    required this.snapshotContainsPublicLabels,
    required this.snapshotContainsOfficialMetrics,
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
    required this.archiveStatsTouched,
    required this.mappingSucceeded,
    required this.failureMessage,
    required this.safeForPhase36I,
    required this.nextRecommendation,
  });

  final String snapshotId;
  final String sourceReviewEnvelopeId;
  final String sourceTimelineCollectionId;
  final String sourceReviewSummaryId;
  final String snapshotSource;
  final String snapshotVersion;
  final bool sourceReviewEnvelopeComputed;
  final bool sourceReviewEnvelopeIsDeveloperOnly;
  final bool sourceReviewEnvelopeIsPublic;
  final bool sourceReviewEnvelopeIsProductReview;
  final bool sourceReviewEnvelopeIsSavedAnalysis;
  final bool sourceReviewEnvelopeIsOfficial;
  final bool sourceReviewEnvelopeIsUiOutput;
  final bool sourceReviewEnvelopeIsArchiveStatsOutput;
  final bool sourceReviewEnvelopeIsFullGameAnalysis;
  final bool sourceReviewEnvelopeIsProductTimeline;
  final bool snapshotComputed;
  final bool snapshotIsDeveloperOnly;
  final bool snapshotIsReadOnly;
  final bool snapshotIsPublic;
  final bool snapshotIsProductReview;
  final bool snapshotIsSavedAnalysis;
  final bool snapshotIsOfficial;
  final bool snapshotIsUiOutput;
  final bool snapshotIsArchiveStatsOutput;
  final bool snapshotIsFullGameAnalysis;
  final bool snapshotIsProductTimeline;
  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;
  final bool snapshotCountsMatchSource;
  final bool snapshotContainsPublicLabels;
  final bool snapshotContainsOfficialMetrics;
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
  final bool archiveStatsTouched;
  final bool mappingSucceeded;
  final String? failureMessage;
  final bool safeForPhase36I;
  final String nextRecommendation;

  Map<String, Object?> toJson() => {
    'snapshotId': snapshotId,
    'sourceReviewEnvelopeId': sourceReviewEnvelopeId,
    'sourceTimelineCollectionId': sourceTimelineCollectionId,
    'sourceReviewSummaryId': sourceReviewSummaryId,
    'snapshotSource': snapshotSource,
    'snapshotVersion': snapshotVersion,
    'sourceReviewEnvelopeComputed': sourceReviewEnvelopeComputed,
    'sourceReviewEnvelopeIsDeveloperOnly': sourceReviewEnvelopeIsDeveloperOnly,
    'sourceReviewEnvelopeIsPublic': sourceReviewEnvelopeIsPublic,
    'sourceReviewEnvelopeIsProductReview': sourceReviewEnvelopeIsProductReview,
    'sourceReviewEnvelopeIsSavedAnalysis': sourceReviewEnvelopeIsSavedAnalysis,
    'sourceReviewEnvelopeIsOfficial': sourceReviewEnvelopeIsOfficial,
    'sourceReviewEnvelopeIsUiOutput': sourceReviewEnvelopeIsUiOutput,
    'sourceReviewEnvelopeIsArchiveStatsOutput':
        sourceReviewEnvelopeIsArchiveStatsOutput,
    'sourceReviewEnvelopeIsFullGameAnalysis':
        sourceReviewEnvelopeIsFullGameAnalysis,
    'sourceReviewEnvelopeIsProductTimeline':
        sourceReviewEnvelopeIsProductTimeline,
    'snapshotComputed': snapshotComputed,
    'snapshotIsDeveloperOnly': snapshotIsDeveloperOnly,
    'snapshotIsReadOnly': snapshotIsReadOnly,
    'snapshotIsPublic': snapshotIsPublic,
    'snapshotIsProductReview': snapshotIsProductReview,
    'snapshotIsSavedAnalysis': snapshotIsSavedAnalysis,
    'snapshotIsOfficial': snapshotIsOfficial,
    'snapshotIsUiOutput': snapshotIsUiOutput,
    'snapshotIsArchiveStatsOutput': snapshotIsArchiveStatsOutput,
    'snapshotIsFullGameAnalysis': snapshotIsFullGameAnalysis,
    'snapshotIsProductTimeline': snapshotIsProductTimeline,
    'totalPrivateEntries': totalPrivateEntries,
    'positiveCandidateCount': positiveCandidateCount,
    'neutralCandidateCount': neutralCandidateCount,
    'negativeCandidateCount': negativeCandidateCount,
    'unavailableCount': unavailableCount,
    'snapshotCountsMatchSource': snapshotCountsMatchSource,
    'snapshotContainsPublicLabels': snapshotContainsPublicLabels,
    'snapshotContainsOfficialMetrics': snapshotContainsOfficialMetrics,
    'publicLabelComputed': publicLabelComputed,
    'publicLabel': publicLabel,
    'officialMoveQualityComputed': officialMoveQualityComputed,
    'officialMoveQuality': officialMoveQuality,
    'officialCpLossComputed': officialCpLossComputed,
    'officialWinPercentComputed': officialWinPercentComputed,
    'accuracyComputed': accuracyComputed,
    'acplComputed': acplComputed,
    'classificationComputed': classificationComputed,
    'publicClassifierOutputComputed': publicClassifierOutputComputed,
    'savedAnalysisWritten': savedAnalysisWritten,
    'uiOutputProduced': uiOutputProduced,
    'archiveStatsTouched': archiveStatsTouched,
    'mappingSucceeded': mappingSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase36I': safeForPhase36I,
    'nextRecommendation': nextRecommendation,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
