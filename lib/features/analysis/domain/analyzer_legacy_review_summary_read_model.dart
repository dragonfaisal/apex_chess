import 'dart:convert';

const analyzerLegacyReviewSummaryReadModelSource =
    'phase36ELegacyReviewSummaryReadModelMapper';
const analyzerLegacyReviewSummaryReadModelVersion = 'phase36E.v1';
const analyzerLegacyReviewSummaryReadModelNextRecommendation =
    'implementLegacyReviewEnvelopeReadModelWithoutPublicLabels';
const analyzerLegacyReviewSummaryReadModelFailureRecommendation =
    'fixLegacyReviewSummaryReadModelMapping';

class AnalyzerLegacyReviewSummaryReadModel {
  const AnalyzerLegacyReviewSummaryReadModel({
    required this.reviewSummaryId,
    required this.sourceTimelineCollectionId,
    required this.reviewSummarySource,
    required this.reviewSummaryVersion,
    required this.sourceEntryCount,
    required this.mappedEntryCount,
    required this.blockedEntryCount,
    required this.sourceTimelineCollectionComputed,
    required this.sourceTimelineCollectionIsDeveloperOnly,
    required this.sourceTimelineCollectionIsProductReview,
    required this.sourceTimelineCollectionIsSavedAnalysis,
    required this.sourceTimelineCollectionIsUiOutput,
    required this.sourceTimelineCollectionIsArchiveStatsOutput,
    required this.sourceTimelineCollectionIsFullGameAnalysis,
    required this.sourceTimelineCollectionIsProductTimeline,
    required this.reviewSummaryComputed,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.allEntriesSafe,
    required this.allEntriesSingleMoveOnly,
    required this.allEntriesPrivateSingleMoveDraft,
    required this.reviewSummaryIsPublic,
    required this.reviewSummaryIsProductReview,
    required this.reviewSummaryIsSavedAnalysis,
    required this.reviewSummaryIsOfficial,
    required this.reviewSummaryIsUiOutput,
    required this.reviewSummaryIsArchiveStatsOutput,
    required this.reviewSummaryIsFullGameAnalysis,
    required this.reviewSummaryIsProductTimeline,
    required this.reviewSummaryIsDeveloperOnly,
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
    required this.safeForPhase36F,
    required this.nextRecommendation,
  });

  final String reviewSummaryId;
  final String sourceTimelineCollectionId;
  final String reviewSummarySource;
  final String reviewSummaryVersion;
  final int sourceEntryCount;
  final int mappedEntryCount;
  final int blockedEntryCount;
  final bool sourceTimelineCollectionComputed;
  final bool sourceTimelineCollectionIsDeveloperOnly;
  final bool sourceTimelineCollectionIsProductReview;
  final bool sourceTimelineCollectionIsSavedAnalysis;
  final bool sourceTimelineCollectionIsUiOutput;
  final bool sourceTimelineCollectionIsArchiveStatsOutput;
  final bool sourceTimelineCollectionIsFullGameAnalysis;
  final bool sourceTimelineCollectionIsProductTimeline;
  final bool reviewSummaryComputed;
  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;
  final bool allEntriesSafe;
  final bool allEntriesSingleMoveOnly;
  final bool allEntriesPrivateSingleMoveDraft;
  final bool reviewSummaryIsPublic;
  final bool reviewSummaryIsProductReview;
  final bool reviewSummaryIsSavedAnalysis;
  final bool reviewSummaryIsOfficial;
  final bool reviewSummaryIsUiOutput;
  final bool reviewSummaryIsArchiveStatsOutput;
  final bool reviewSummaryIsFullGameAnalysis;
  final bool reviewSummaryIsProductTimeline;
  final bool reviewSummaryIsDeveloperOnly;
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
  final bool safeForPhase36F;
  final String nextRecommendation;

  Map<String, Object?> toJson() => {
    'reviewSummaryId': reviewSummaryId,
    'sourceTimelineCollectionId': sourceTimelineCollectionId,
    'reviewSummarySource': reviewSummarySource,
    'reviewSummaryVersion': reviewSummaryVersion,
    'sourceEntryCount': sourceEntryCount,
    'mappedEntryCount': mappedEntryCount,
    'blockedEntryCount': blockedEntryCount,
    'sourceTimelineCollectionComputed': sourceTimelineCollectionComputed,
    'sourceTimelineCollectionIsDeveloperOnly':
        sourceTimelineCollectionIsDeveloperOnly,
    'sourceTimelineCollectionIsProductReview':
        sourceTimelineCollectionIsProductReview,
    'sourceTimelineCollectionIsSavedAnalysis':
        sourceTimelineCollectionIsSavedAnalysis,
    'sourceTimelineCollectionIsUiOutput': sourceTimelineCollectionIsUiOutput,
    'sourceTimelineCollectionIsArchiveStatsOutput':
        sourceTimelineCollectionIsArchiveStatsOutput,
    'sourceTimelineCollectionIsFullGameAnalysis':
        sourceTimelineCollectionIsFullGameAnalysis,
    'sourceTimelineCollectionIsProductTimeline':
        sourceTimelineCollectionIsProductTimeline,
    'reviewSummaryComputed': reviewSummaryComputed,
    'totalPrivateEntries': totalPrivateEntries,
    'positiveCandidateCount': positiveCandidateCount,
    'neutralCandidateCount': neutralCandidateCount,
    'negativeCandidateCount': negativeCandidateCount,
    'unavailableCount': unavailableCount,
    'allEntriesSafe': allEntriesSafe,
    'allEntriesSingleMoveOnly': allEntriesSingleMoveOnly,
    'allEntriesPrivateSingleMoveDraft': allEntriesPrivateSingleMoveDraft,
    'reviewSummaryIsPublic': reviewSummaryIsPublic,
    'reviewSummaryIsProductReview': reviewSummaryIsProductReview,
    'reviewSummaryIsSavedAnalysis': reviewSummaryIsSavedAnalysis,
    'reviewSummaryIsOfficial': reviewSummaryIsOfficial,
    'reviewSummaryIsUiOutput': reviewSummaryIsUiOutput,
    'reviewSummaryIsArchiveStatsOutput': reviewSummaryIsArchiveStatsOutput,
    'reviewSummaryIsFullGameAnalysis': reviewSummaryIsFullGameAnalysis,
    'reviewSummaryIsProductTimeline': reviewSummaryIsProductTimeline,
    'reviewSummaryIsDeveloperOnly': reviewSummaryIsDeveloperOnly,
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
    'safeForPhase36F': safeForPhase36F,
    'nextRecommendation': nextRecommendation,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
