import 'dart:convert';

const analyzerLegacyReviewEnvelopeReadModelSource =
    'phase36FLegacyReviewEnvelopeReadModelMapper';
const analyzerLegacyReviewEnvelopeReadModelVersion = 'phase36F.v1';
const analyzerLegacyReviewEnvelopeReadModelNextRecommendation =
    'implementLegacyReviewEnvelopeSafetyGoldenCasesWithoutPublicLabels';
const analyzerLegacyReviewEnvelopeReadModelFailureRecommendation =
    'fixLegacyReviewEnvelopeReadModelMapping';

class AnalyzerLegacyReviewEnvelopeReadModel {
  const AnalyzerLegacyReviewEnvelopeReadModel({
    required this.reviewEnvelopeId,
    required this.sourceTimelineCollectionId,
    required this.sourceReviewSummaryId,
    required this.reviewEnvelopeSource,
    required this.reviewEnvelopeVersion,
    required this.sourceTimelineCollectionComputed,
    required this.sourceEntryCount,
    required this.mappedEntryCount,
    required this.blockedEntryCount,
    required this.timelineCollectionIsDeveloperOnly,
    required this.timelineCollectionIsProductReview,
    required this.timelineCollectionIsSavedAnalysis,
    required this.timelineCollectionIsUiOutput,
    required this.timelineCollectionIsArchiveStatsOutput,
    required this.timelineCollectionIsFullGameAnalysis,
    required this.timelineCollectionIsProductTimeline,
    required this.sourceReviewSummaryComputed,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.reviewSummaryIsDeveloperOnly,
    required this.reviewSummaryIsProductReview,
    required this.reviewSummaryIsSavedAnalysis,
    required this.reviewSummaryIsUiOutput,
    required this.reviewSummaryIsArchiveStatsOutput,
    required this.reviewSummaryIsFullGameAnalysis,
    required this.reviewSummaryIsProductTimeline,
    required this.reviewEnvelopeComputed,
    required this.reviewEnvelopeContainsTimelineCollection,
    required this.reviewEnvelopeContainsReviewSummary,
    required this.reviewEnvelopeCountsMatchCollection,
    required this.reviewEnvelopeIsPublic,
    required this.reviewEnvelopeIsProductReview,
    required this.reviewEnvelopeIsSavedAnalysis,
    required this.reviewEnvelopeIsOfficial,
    required this.reviewEnvelopeIsUiOutput,
    required this.reviewEnvelopeIsArchiveStatsOutput,
    required this.reviewEnvelopeIsFullGameAnalysis,
    required this.reviewEnvelopeIsProductTimeline,
    required this.reviewEnvelopeIsDeveloperOnly,
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
    required this.safeForPhase36G,
    required this.nextRecommendation,
  });

  final String reviewEnvelopeId;
  final String sourceTimelineCollectionId;
  final String sourceReviewSummaryId;
  final String reviewEnvelopeSource;
  final String reviewEnvelopeVersion;
  final bool sourceTimelineCollectionComputed;
  final int sourceEntryCount;
  final int mappedEntryCount;
  final int blockedEntryCount;
  final bool timelineCollectionIsDeveloperOnly;
  final bool timelineCollectionIsProductReview;
  final bool timelineCollectionIsSavedAnalysis;
  final bool timelineCollectionIsUiOutput;
  final bool timelineCollectionIsArchiveStatsOutput;
  final bool timelineCollectionIsFullGameAnalysis;
  final bool timelineCollectionIsProductTimeline;
  final bool sourceReviewSummaryComputed;
  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;
  final bool reviewSummaryIsDeveloperOnly;
  final bool reviewSummaryIsProductReview;
  final bool reviewSummaryIsSavedAnalysis;
  final bool reviewSummaryIsUiOutput;
  final bool reviewSummaryIsArchiveStatsOutput;
  final bool reviewSummaryIsFullGameAnalysis;
  final bool reviewSummaryIsProductTimeline;
  final bool reviewEnvelopeComputed;
  final bool reviewEnvelopeContainsTimelineCollection;
  final bool reviewEnvelopeContainsReviewSummary;
  final bool reviewEnvelopeCountsMatchCollection;
  final bool reviewEnvelopeIsPublic;
  final bool reviewEnvelopeIsProductReview;
  final bool reviewEnvelopeIsSavedAnalysis;
  final bool reviewEnvelopeIsOfficial;
  final bool reviewEnvelopeIsUiOutput;
  final bool reviewEnvelopeIsArchiveStatsOutput;
  final bool reviewEnvelopeIsFullGameAnalysis;
  final bool reviewEnvelopeIsProductTimeline;
  final bool reviewEnvelopeIsDeveloperOnly;
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
  final bool safeForPhase36G;
  final String nextRecommendation;

  Map<String, Object?> toJson() => {
    'reviewEnvelopeId': reviewEnvelopeId,
    'sourceTimelineCollectionId': sourceTimelineCollectionId,
    'sourceReviewSummaryId': sourceReviewSummaryId,
    'reviewEnvelopeSource': reviewEnvelopeSource,
    'reviewEnvelopeVersion': reviewEnvelopeVersion,
    'sourceTimelineCollectionComputed': sourceTimelineCollectionComputed,
    'sourceEntryCount': sourceEntryCount,
    'mappedEntryCount': mappedEntryCount,
    'blockedEntryCount': blockedEntryCount,
    'timelineCollectionIsDeveloperOnly': timelineCollectionIsDeveloperOnly,
    'timelineCollectionIsProductReview': timelineCollectionIsProductReview,
    'timelineCollectionIsSavedAnalysis': timelineCollectionIsSavedAnalysis,
    'timelineCollectionIsUiOutput': timelineCollectionIsUiOutput,
    'timelineCollectionIsArchiveStatsOutput':
        timelineCollectionIsArchiveStatsOutput,
    'timelineCollectionIsFullGameAnalysis':
        timelineCollectionIsFullGameAnalysis,
    'timelineCollectionIsProductTimeline': timelineCollectionIsProductTimeline,
    'sourceReviewSummaryComputed': sourceReviewSummaryComputed,
    'totalPrivateEntries': totalPrivateEntries,
    'positiveCandidateCount': positiveCandidateCount,
    'neutralCandidateCount': neutralCandidateCount,
    'negativeCandidateCount': negativeCandidateCount,
    'unavailableCount': unavailableCount,
    'reviewSummaryIsDeveloperOnly': reviewSummaryIsDeveloperOnly,
    'reviewSummaryIsProductReview': reviewSummaryIsProductReview,
    'reviewSummaryIsSavedAnalysis': reviewSummaryIsSavedAnalysis,
    'reviewSummaryIsUiOutput': reviewSummaryIsUiOutput,
    'reviewSummaryIsArchiveStatsOutput': reviewSummaryIsArchiveStatsOutput,
    'reviewSummaryIsFullGameAnalysis': reviewSummaryIsFullGameAnalysis,
    'reviewSummaryIsProductTimeline': reviewSummaryIsProductTimeline,
    'reviewEnvelopeComputed': reviewEnvelopeComputed,
    'reviewEnvelopeContainsTimelineCollection':
        reviewEnvelopeContainsTimelineCollection,
    'reviewEnvelopeContainsReviewSummary': reviewEnvelopeContainsReviewSummary,
    'reviewEnvelopeCountsMatchCollection': reviewEnvelopeCountsMatchCollection,
    'reviewEnvelopeIsPublic': reviewEnvelopeIsPublic,
    'reviewEnvelopeIsProductReview': reviewEnvelopeIsProductReview,
    'reviewEnvelopeIsSavedAnalysis': reviewEnvelopeIsSavedAnalysis,
    'reviewEnvelopeIsOfficial': reviewEnvelopeIsOfficial,
    'reviewEnvelopeIsUiOutput': reviewEnvelopeIsUiOutput,
    'reviewEnvelopeIsArchiveStatsOutput': reviewEnvelopeIsArchiveStatsOutput,
    'reviewEnvelopeIsFullGameAnalysis': reviewEnvelopeIsFullGameAnalysis,
    'reviewEnvelopeIsProductTimeline': reviewEnvelopeIsProductTimeline,
    'reviewEnvelopeIsDeveloperOnly': reviewEnvelopeIsDeveloperOnly,
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
    'safeForPhase36G': safeForPhase36G,
    'nextRecommendation': nextRecommendation,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
