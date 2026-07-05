import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_envelope_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_summary_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_collection_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model.dart';

AnalyzerLegacyReviewEnvelopeReadModel
mapLegacyCollectionAndSummaryToReviewEnvelopeReadModel({
  required AnalyzerLegacyTimelineCollectionReadModel collection,
  required AnalyzerLegacyReviewSummaryReadModel summary,
}) {
  const reviewEnvelopeIsPublic = false;
  const reviewEnvelopeIsProductReview = false;
  const reviewEnvelopeIsSavedAnalysis = false;
  const reviewEnvelopeIsOfficial = false;
  const reviewEnvelopeIsUiOutput = false;
  const reviewEnvelopeIsArchiveStatsOutput = false;
  const reviewEnvelopeIsFullGameAnalysis = false;
  const reviewEnvelopeIsProductTimeline = false;
  const reviewEnvelopeIsDeveloperOnly = true;
  const publicLabelComputed = false;
  const String? publicLabel = null;
  const officialMoveQualityComputed = false;
  const String? officialMoveQuality = null;
  const officialCpLossComputed = false;
  const officialWinPercentComputed = false;
  const accuracyComputed = false;
  const acplComputed = false;
  const classificationComputed = false;
  const publicClassifierOutputComputed = false;
  const savedAnalysisWritten = false;
  const uiOutputProduced = false;
  const archiveStatsTouched = false;

  final publicStringsClean = !_containsForbiddenPublicString(
    collection: collection,
    summary: summary,
  );
  final collectionSafe = _isSafeCollection(collection);
  final summarySafe = _isSafeSummary(summary);
  final sourceIdsMatch =
      publicStringsClean &&
      summary.sourceTimelineCollectionId == collection.timelineCollectionId;
  final bucketCountsSumToTotal =
      summary.totalPrivateEntries ==
      summary.positiveCandidateCount +
          summary.neutralCandidateCount +
          summary.negativeCandidateCount +
          summary.unavailableCount;
  final countsMatchCollection =
      summary.totalPrivateEntries == collection.mappedEntryCount &&
      summary.sourceEntryCount == collection.sourceEntryCount &&
      summary.mappedEntryCount == collection.mappedEntryCount &&
      summary.blockedEntryCount == collection.blockedEntryCount;
  final reviewEnvelopeContainsTimelineCollection =
      collectionSafe && publicStringsClean;
  final reviewEnvelopeContainsReviewSummary = summarySafe && publicStringsClean;
  final reviewEnvelopeCountsMatchCollection =
      countsMatchCollection && bucketCountsSumToTotal;
  final reviewEnvelopeComputed =
      reviewEnvelopeContainsTimelineCollection &&
      reviewEnvelopeContainsReviewSummary &&
      sourceIdsMatch &&
      reviewEnvelopeCountsMatchCollection &&
      !reviewEnvelopeIsPublic &&
      !reviewEnvelopeIsProductReview &&
      !reviewEnvelopeIsSavedAnalysis &&
      !reviewEnvelopeIsOfficial &&
      !reviewEnvelopeIsUiOutput &&
      !reviewEnvelopeIsArchiveStatsOutput &&
      !reviewEnvelopeIsFullGameAnalysis &&
      !reviewEnvelopeIsProductTimeline &&
      reviewEnvelopeIsDeveloperOnly;
  final mappingSucceeded =
      reviewEnvelopeComputed &&
      !publicLabelComputed &&
      publicLabel == null &&
      !officialMoveQualityComputed &&
      officialMoveQuality == null &&
      !officialCpLossComputed &&
      !officialWinPercentComputed &&
      !accuracyComputed &&
      !acplComputed &&
      !classificationComputed &&
      !publicClassifierOutputComputed &&
      !savedAnalysisWritten &&
      !uiOutputProduced &&
      !archiveStatsTouched;

  return AnalyzerLegacyReviewEnvelopeReadModel(
    reviewEnvelopeId: mappingSucceeded
        ? _reviewEnvelopeId(collection, summary)
        : 'phase36F:blocked:sourceEntries${collection.sourceEntryCount}',
    sourceTimelineCollectionId: publicStringsClean
        ? collection.timelineCollectionId
        : 'phase36F:blockedTimelineCollection',
    sourceReviewSummaryId: publicStringsClean
        ? summary.reviewSummaryId
        : 'phase36F:blockedReviewSummary',
    reviewEnvelopeSource: analyzerLegacyReviewEnvelopeReadModelSource,
    reviewEnvelopeVersion: analyzerLegacyReviewEnvelopeReadModelVersion,
    sourceTimelineCollectionComputed: collection.timelineCollectionComputed,
    sourceEntryCount: collection.sourceEntryCount,
    mappedEntryCount: collection.mappedEntryCount,
    blockedEntryCount: collection.blockedEntryCount,
    timelineCollectionIsDeveloperOnly:
        collection.timelineCollectionIsDeveloperOnly,
    timelineCollectionIsProductReview:
        collection.timelineCollectionIsProductReview,
    timelineCollectionIsSavedAnalysis:
        collection.timelineCollectionIsSavedAnalysis,
    timelineCollectionIsUiOutput: collection.timelineCollectionIsUiOutput,
    timelineCollectionIsArchiveStatsOutput:
        collection.timelineCollectionIsArchiveStatsOutput,
    timelineCollectionIsFullGameAnalysis:
        collection.timelineCollectionIsFullGameAnalysis,
    timelineCollectionIsProductTimeline:
        collection.timelineCollectionIsProductTimeline,
    sourceReviewSummaryComputed: summary.reviewSummaryComputed,
    totalPrivateEntries: summary.totalPrivateEntries,
    positiveCandidateCount: summary.positiveCandidateCount,
    neutralCandidateCount: summary.neutralCandidateCount,
    negativeCandidateCount: summary.negativeCandidateCount,
    unavailableCount: summary.unavailableCount,
    reviewSummaryIsDeveloperOnly: summary.reviewSummaryIsDeveloperOnly,
    reviewSummaryIsProductReview: summary.reviewSummaryIsProductReview,
    reviewSummaryIsSavedAnalysis: summary.reviewSummaryIsSavedAnalysis,
    reviewSummaryIsUiOutput: summary.reviewSummaryIsUiOutput,
    reviewSummaryIsArchiveStatsOutput:
        summary.reviewSummaryIsArchiveStatsOutput,
    reviewSummaryIsFullGameAnalysis: summary.reviewSummaryIsFullGameAnalysis,
    reviewSummaryIsProductTimeline: summary.reviewSummaryIsProductTimeline,
    reviewEnvelopeComputed: reviewEnvelopeComputed,
    reviewEnvelopeContainsTimelineCollection:
        reviewEnvelopeContainsTimelineCollection,
    reviewEnvelopeContainsReviewSummary: reviewEnvelopeContainsReviewSummary,
    reviewEnvelopeCountsMatchCollection: reviewEnvelopeCountsMatchCollection,
    reviewEnvelopeIsPublic: reviewEnvelopeIsPublic,
    reviewEnvelopeIsProductReview: reviewEnvelopeIsProductReview,
    reviewEnvelopeIsSavedAnalysis: reviewEnvelopeIsSavedAnalysis,
    reviewEnvelopeIsOfficial: reviewEnvelopeIsOfficial,
    reviewEnvelopeIsUiOutput: reviewEnvelopeIsUiOutput,
    reviewEnvelopeIsArchiveStatsOutput: reviewEnvelopeIsArchiveStatsOutput,
    reviewEnvelopeIsFullGameAnalysis: reviewEnvelopeIsFullGameAnalysis,
    reviewEnvelopeIsProductTimeline: reviewEnvelopeIsProductTimeline,
    reviewEnvelopeIsDeveloperOnly: reviewEnvelopeIsDeveloperOnly,
    publicLabelComputed: publicLabelComputed,
    publicLabel: publicLabel,
    officialMoveQualityComputed: officialMoveQualityComputed,
    officialMoveQuality: officialMoveQuality,
    officialCpLossComputed: officialCpLossComputed,
    officialWinPercentComputed: officialWinPercentComputed,
    accuracyComputed: accuracyComputed,
    acplComputed: acplComputed,
    classificationComputed: classificationComputed,
    publicClassifierOutputComputed: publicClassifierOutputComputed,
    savedAnalysisWritten: savedAnalysisWritten,
    uiOutputProduced: uiOutputProduced,
    archiveStatsTouched: archiveStatsTouched,
    mappingSucceeded: mappingSucceeded,
    failureMessage: mappingSucceeded
        ? null
        : _failureMessage(
            collection: collection,
            summary: summary,
            collectionSafe: collectionSafe,
            summarySafe: summarySafe,
            sourceIdsMatch: sourceIdsMatch,
            countsMatchCollection: countsMatchCollection,
            bucketCountsSumToTotal: bucketCountsSumToTotal,
            publicStringsClean: publicStringsClean,
          ),
    safeForPhase36G: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerLegacyReviewEnvelopeReadModelNextRecommendation
        : analyzerLegacyReviewEnvelopeReadModelFailureRecommendation,
  );
}

bool _isSafeCollection(AnalyzerLegacyTimelineCollectionReadModel source) {
  return source.mappingSucceeded &&
      source.safeForPhase36E &&
      source.timelineCollectionComputed &&
      source.timelineCollectionIsDeveloperOnly &&
      !source.timelineCollectionIsPublic &&
      !source.timelineCollectionIsProductReview &&
      !source.timelineCollectionIsSavedAnalysis &&
      !source.timelineCollectionIsOfficial &&
      !source.timelineCollectionIsUiOutput &&
      !source.timelineCollectionIsArchiveStatsOutput &&
      !source.timelineCollectionIsFullGameAnalysis &&
      !source.timelineCollectionIsProductTimeline &&
      source.entries.isNotEmpty &&
      source.sourceEntryCount == source.entries.length &&
      source.mappedEntryCount == source.entries.length &&
      source.blockedEntryCount == 0 &&
      source.allEntriesSafe &&
      source.allEntriesAreSingleMoveOnly &&
      source.allEntriesArePrivateSingleMoveDraft &&
      source.entriesSortedByOrderKey &&
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
      !source.archiveStatsTouched &&
      source.entries.every(_isSafeTimelineEntry);
}

bool _isSafeTimelineEntry(AnalyzerLegacyTimelineEntryReadModel entry) {
  return entry.mappingSucceeded &&
      entry.safeForPhase36D &&
      entry.timelineEntryComputed &&
      entry.timelineEntryKind ==
          AnalyzerLegacyTimelineEntryKind.privateSingleMoveDraft &&
      entry.timelineEntryIsSingleMoveOnly &&
      !entry.timelineEntryIsFullGameTimeline &&
      !entry.timelineEntryIsProductTimeline &&
      !entry.timelineEntryIsUiOutput &&
      entry.sourceReadModelComputed &&
      !entry.sourceReadModelIsPublic &&
      !entry.sourceReadModelIsProductReview &&
      !entry.sourceReadModelIsSavedAnalysis &&
      !entry.sourceReadModelIsOfficial &&
      !entry.sourceReadModelIsUiOutput &&
      !entry.sourceReadModelIsArchiveStatsOutput &&
      !entry.publicLabelComputed &&
      entry.publicLabel == null &&
      !entry.officialMoveQualityComputed &&
      entry.officialMoveQuality == null &&
      !entry.officialCpLossComputed &&
      !entry.officialWinPercentComputed &&
      !entry.accuracyComputed &&
      !entry.acplComputed &&
      !entry.classificationComputed &&
      !entry.publicClassifierOutputComputed &&
      !entry.savedAnalysisWritten &&
      !entry.uiOutputProduced &&
      !entry.archiveStatsTouched;
}

bool _isSafeSummary(AnalyzerLegacyReviewSummaryReadModel source) {
  return source.mappingSucceeded &&
      source.safeForPhase36F &&
      source.reviewSummaryComputed &&
      source.reviewSummaryIsDeveloperOnly &&
      !source.reviewSummaryIsPublic &&
      !source.reviewSummaryIsProductReview &&
      !source.reviewSummaryIsSavedAnalysis &&
      !source.reviewSummaryIsOfficial &&
      !source.reviewSummaryIsUiOutput &&
      !source.reviewSummaryIsArchiveStatsOutput &&
      !source.reviewSummaryIsFullGameAnalysis &&
      !source.reviewSummaryIsProductTimeline &&
      source.sourceTimelineCollectionComputed &&
      source.sourceTimelineCollectionIsDeveloperOnly &&
      !source.sourceTimelineCollectionIsProductReview &&
      !source.sourceTimelineCollectionIsSavedAnalysis &&
      !source.sourceTimelineCollectionIsUiOutput &&
      !source.sourceTimelineCollectionIsArchiveStatsOutput &&
      !source.sourceTimelineCollectionIsFullGameAnalysis &&
      !source.sourceTimelineCollectionIsProductTimeline &&
      source.allEntriesSafe &&
      source.allEntriesSingleMoveOnly &&
      source.allEntriesPrivateSingleMoveDraft &&
      source.totalPrivateEntries ==
          source.positiveCandidateCount +
              source.neutralCandidateCount +
              source.negativeCandidateCount +
              source.unavailableCount &&
      source.totalPrivateEntries == source.mappedEntryCount &&
      source.blockedEntryCount == 0 &&
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
      !source.archiveStatsTouched;
}

String _reviewEnvelopeId(
  AnalyzerLegacyTimelineCollectionReadModel collection,
  AnalyzerLegacyReviewSummaryReadModel summary,
) {
  return [
    'phase36F',
    collection.timelineCollectionId,
    summary.reviewSummaryId,
  ].join(':');
}

String _failureMessage({
  required AnalyzerLegacyTimelineCollectionReadModel collection,
  required AnalyzerLegacyReviewSummaryReadModel summary,
  required bool collectionSafe,
  required bool summarySafe,
  required bool sourceIdsMatch,
  required bool countsMatchCollection,
  required bool bucketCountsSumToTotal,
  required bool publicStringsClean,
}) {
  if (!publicStringsClean) {
    return 'Legacy review envelope blocked a public label string.';
  }
  if (!collectionSafe) {
    return _collectionFailureMessage(collection);
  }
  if (!sourceIdsMatch) {
    return 'Legacy review envelope blocked a source ID mismatch.';
  }
  if (!countsMatchCollection) {
    return 'Legacy review envelope blocked a collection count mismatch.';
  }
  if (!bucketCountsSumToTotal) {
    return 'Legacy review envelope blocked a private bucket count mismatch.';
  }
  if (!summarySafe) {
    return _summaryFailureMessage(summary);
  }
  return 'Legacy review envelope read-model mapping did not succeed.';
}

String _collectionFailureMessage(
  AnalyzerLegacyTimelineCollectionReadModel source,
) {
  if (!source.mappingSucceeded || !source.safeForPhase36E) {
    return 'Legacy timeline collection source did not succeed.';
  }
  if (source.timelineCollectionIsProductReview) {
    return 'Legacy timeline collection source is product review output.';
  }
  if (source.timelineCollectionIsSavedAnalysis || source.savedAnalysisWritten) {
    return 'Legacy timeline collection source touched saved analysis.';
  }
  if (source.timelineCollectionIsUiOutput || source.uiOutputProduced) {
    return 'Legacy timeline collection source produced UI output.';
  }
  if (source.timelineCollectionIsArchiveStatsOutput ||
      source.archiveStatsTouched) {
    return 'Legacy timeline collection source touched archive or stats.';
  }
  if (source.timelineCollectionIsFullGameAnalysis ||
      source.timelineCollectionIsProductTimeline) {
    return 'Legacy timeline collection source exposed full-game or product timeline output.';
  }
  if (source.timelineCollectionIsPublic ||
      source.publicLabelComputed ||
      source.publicLabel != null) {
    return 'Legacy timeline collection source exposed public label data.';
  }
  if (source.timelineCollectionIsOfficial ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return 'Legacy timeline collection source exposed official metric data.';
  }
  if (!source.allEntriesSafe ||
      !source.allEntriesAreSingleMoveOnly ||
      !source.allEntriesArePrivateSingleMoveDraft) {
    return 'Legacy timeline collection entries are not all safe private single-move drafts.';
  }
  return 'Legacy timeline collection source is unsafe for envelope mapping.';
}

String _summaryFailureMessage(AnalyzerLegacyReviewSummaryReadModel source) {
  if (!source.mappingSucceeded || !source.safeForPhase36F) {
    return 'Legacy review summary source did not succeed.';
  }
  if (source.reviewSummaryIsProductReview ||
      source.sourceTimelineCollectionIsProductReview) {
    return 'Legacy review summary source is product review output.';
  }
  if (source.reviewSummaryIsSavedAnalysis ||
      source.sourceTimelineCollectionIsSavedAnalysis ||
      source.savedAnalysisWritten) {
    return 'Legacy review summary source touched saved analysis.';
  }
  if (source.reviewSummaryIsUiOutput ||
      source.sourceTimelineCollectionIsUiOutput ||
      source.uiOutputProduced) {
    return 'Legacy review summary source produced UI output.';
  }
  if (source.reviewSummaryIsArchiveStatsOutput ||
      source.sourceTimelineCollectionIsArchiveStatsOutput ||
      source.archiveStatsTouched) {
    return 'Legacy review summary source touched archive or stats.';
  }
  if (source.reviewSummaryIsFullGameAnalysis ||
      source.reviewSummaryIsProductTimeline ||
      source.sourceTimelineCollectionIsFullGameAnalysis ||
      source.sourceTimelineCollectionIsProductTimeline) {
    return 'Legacy review summary source exposed full-game or product timeline output.';
  }
  if (source.reviewSummaryIsPublic ||
      source.publicLabelComputed ||
      source.publicLabel != null) {
    return 'Legacy review summary source exposed public label data.';
  }
  if (source.reviewSummaryIsOfficial ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return 'Legacy review summary source exposed official metric data.';
  }
  return 'Legacy review summary source is unsafe for envelope mapping.';
}

bool _containsForbiddenPublicString({
  required AnalyzerLegacyTimelineCollectionReadModel collection,
  required AnalyzerLegacyReviewSummaryReadModel summary,
}) {
  final values = <String?>[
    collection.publicLabel,
    collection.officialMoveQuality,
    collection.timelineCollectionId,
    collection.timelineCollectionSource,
    summary.publicLabel,
    summary.officialMoveQuality,
    summary.reviewSummaryId,
    summary.reviewSummarySource,
    summary.sourceTimelineCollectionId,
    analyzerLegacyReviewEnvelopeReadModelSource,
    ...collection.entryIds,
    ...collection.entries.map((entry) => entry.publicLabel),
    ...collection.entries.map((entry) => entry.officialMoveQuality),
    ...collection.entries.map((entry) => entry.timelineEntryId),
    ...collection.entries.map((entry) => entry.privateDraftBucket.wire),
    ...collection.entries.map((entry) => entry.privateDraftReasonCode.wire),
    ...collection.entries.map((entry) => entry.privateDraftConfidenceTier.wire),
    ...collection.entries.map((entry) => entry.timelineEntryKind.wire),
  ].whereType<String>();
  return values.any(_containsForbiddenPublicLabelString);
}

bool _containsForbiddenPublicLabelString(String value) {
  return _forbiddenPublicStrings.any(value.contains);
}

const _forbiddenPublicStrings = <String>{
  'Brilliant',
  'Great',
  'Best',
  'Excellent',
  'Good',
  'Book',
  'Inaccuracy',
  'Mistake',
  'Miss',
  'Blunder',
  'Checkmate',
};
