import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_summary_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_collection_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';

const analyzerLegacyReviewSummaryAllowedPrivateBuckets =
    <AnalyzerPrivateDraftBucket>{
      AnalyzerPrivateDraftBucket.positiveCandidate,
      AnalyzerPrivateDraftBucket.neutralCandidate,
      AnalyzerPrivateDraftBucket.negativeCandidate,
      AnalyzerPrivateDraftBucket.unavailable,
    };

AnalyzerLegacyReviewSummaryReadModel
mapLegacyTimelineCollectionToReviewSummaryReadModel(
  AnalyzerLegacyTimelineCollectionReadModel source, {
  Set<AnalyzerPrivateDraftBucket> allowedPrivateBuckets =
      analyzerLegacyReviewSummaryAllowedPrivateBuckets,
}) {
  const reviewSummaryIsPublic = false;
  const reviewSummaryIsProductReview = false;
  const reviewSummaryIsSavedAnalysis = false;
  const reviewSummaryIsOfficial = false;
  const reviewSummaryIsUiOutput = false;
  const reviewSummaryIsArchiveStatsOutput = false;
  const reviewSummaryIsFullGameAnalysis = false;
  const reviewSummaryIsProductTimeline = false;
  const reviewSummaryIsDeveloperOnly = true;
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

  final sourceSafe = _isSafeCollection(source);
  final knownPrivateBuckets = source.entries.every(
    (entry) => allowedPrivateBuckets.contains(entry.privateDraftBucket),
  );
  final publicStringsClean = !_containsForbiddenPublicString(source);
  final counts = sourceSafe && knownPrivateBuckets && publicStringsClean
      ? _privateBucketCounts(source)
      : const _PrivateBucketCounts();
  final countsSumToTotal =
      counts.total ==
      counts.positive + counts.neutral + counts.negative + counts.unavailable;
  final reviewSummaryComputed =
      sourceSafe &&
      knownPrivateBuckets &&
      publicStringsClean &&
      counts.total == source.mappedEntryCount &&
      countsSumToTotal &&
      !reviewSummaryIsPublic &&
      !reviewSummaryIsProductReview &&
      !reviewSummaryIsSavedAnalysis &&
      !reviewSummaryIsOfficial &&
      !reviewSummaryIsUiOutput &&
      !reviewSummaryIsArchiveStatsOutput &&
      !reviewSummaryIsFullGameAnalysis &&
      !reviewSummaryIsProductTimeline &&
      reviewSummaryIsDeveloperOnly;
  final mappingSucceeded =
      reviewSummaryComputed &&
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

  return AnalyzerLegacyReviewSummaryReadModel(
    reviewSummaryId: mappingSucceeded
        ? _reviewSummaryId(source, counts.total)
        : 'phase36E:blocked:sourceEntries${source.sourceEntryCount}',
    sourceTimelineCollectionId: publicStringsClean
        ? source.timelineCollectionId
        : 'phase36E:blockedSourceCollection',
    reviewSummarySource: analyzerLegacyReviewSummaryReadModelSource,
    reviewSummaryVersion: analyzerLegacyReviewSummaryReadModelVersion,
    sourceEntryCount: source.sourceEntryCount,
    mappedEntryCount: source.mappedEntryCount,
    blockedEntryCount: source.blockedEntryCount,
    sourceTimelineCollectionComputed: source.timelineCollectionComputed,
    sourceTimelineCollectionIsDeveloperOnly:
        source.timelineCollectionIsDeveloperOnly,
    sourceTimelineCollectionIsProductReview:
        source.timelineCollectionIsProductReview,
    sourceTimelineCollectionIsSavedAnalysis:
        source.timelineCollectionIsSavedAnalysis,
    sourceTimelineCollectionIsUiOutput: source.timelineCollectionIsUiOutput,
    sourceTimelineCollectionIsArchiveStatsOutput:
        source.timelineCollectionIsArchiveStatsOutput,
    sourceTimelineCollectionIsFullGameAnalysis:
        source.timelineCollectionIsFullGameAnalysis,
    sourceTimelineCollectionIsProductTimeline:
        source.timelineCollectionIsProductTimeline,
    reviewSummaryComputed: reviewSummaryComputed,
    totalPrivateEntries: counts.total,
    positiveCandidateCount: counts.positive,
    neutralCandidateCount: counts.neutral,
    negativeCandidateCount: counts.negative,
    unavailableCount: counts.unavailable,
    allEntriesSafe: source.allEntriesSafe,
    allEntriesSingleMoveOnly: source.allEntriesAreSingleMoveOnly,
    allEntriesPrivateSingleMoveDraft:
        source.allEntriesArePrivateSingleMoveDraft,
    reviewSummaryIsPublic: reviewSummaryIsPublic,
    reviewSummaryIsProductReview: reviewSummaryIsProductReview,
    reviewSummaryIsSavedAnalysis: reviewSummaryIsSavedAnalysis,
    reviewSummaryIsOfficial: reviewSummaryIsOfficial,
    reviewSummaryIsUiOutput: reviewSummaryIsUiOutput,
    reviewSummaryIsArchiveStatsOutput: reviewSummaryIsArchiveStatsOutput,
    reviewSummaryIsFullGameAnalysis: reviewSummaryIsFullGameAnalysis,
    reviewSummaryIsProductTimeline: reviewSummaryIsProductTimeline,
    reviewSummaryIsDeveloperOnly: reviewSummaryIsDeveloperOnly,
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
            source: source,
            knownPrivateBuckets: knownPrivateBuckets,
            publicStringsClean: publicStringsClean,
          ),
    safeForPhase36F: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerLegacyReviewSummaryReadModelNextRecommendation
        : analyzerLegacyReviewSummaryReadModelFailureRecommendation,
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
      source.entries.every(
        (entry) =>
            entry.mappingSucceeded &&
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
            !entry.archiveStatsTouched,
      );
}

_PrivateBucketCounts _privateBucketCounts(
  AnalyzerLegacyTimelineCollectionReadModel source,
) {
  var positive = 0;
  var neutral = 0;
  var negative = 0;
  var unavailable = 0;

  for (final entry in source.entries) {
    switch (entry.privateDraftBucket) {
      case AnalyzerPrivateDraftBucket.positiveCandidate:
        positive++;
      case AnalyzerPrivateDraftBucket.neutralCandidate:
        neutral++;
      case AnalyzerPrivateDraftBucket.negativeCandidate:
        negative++;
      case AnalyzerPrivateDraftBucket.unavailable:
        unavailable++;
    }
  }

  return _PrivateBucketCounts(
    total: source.entries.length,
    positive: positive,
    neutral: neutral,
    negative: negative,
    unavailable: unavailable,
  );
}

String _reviewSummaryId(
  AnalyzerLegacyTimelineCollectionReadModel source,
  int totalPrivateEntries,
) {
  return [
    'phase36E',
    source.timelineCollectionId,
    'total$totalPrivateEntries',
  ].join(':');
}

String _failureMessage({
  required AnalyzerLegacyTimelineCollectionReadModel source,
  required bool knownPrivateBuckets,
  required bool publicStringsClean,
}) {
  if (!publicStringsClean) {
    return 'Legacy review summary blocked a public label string.';
  }
  if (!knownPrivateBuckets) {
    return 'Legacy review summary blocked an unknown private draft bucket.';
  }
  if (!source.mappingSucceeded || !source.safeForPhase36E) {
    return 'Legacy timeline collection source did not succeed.';
  }
  if (!source.timelineCollectionComputed ||
      !source.timelineCollectionIsDeveloperOnly) {
    return 'Legacy timeline collection source is not developer-only computed output.';
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
  if (source.entries.isEmpty ||
      source.sourceEntryCount != source.entries.length ||
      source.mappedEntryCount != source.entries.length ||
      source.blockedEntryCount != 0) {
    return 'Legacy timeline collection entry counts are not clean.';
  }
  return 'Legacy review summary read-model mapping did not succeed.';
}

bool _containsForbiddenPublicString(
  AnalyzerLegacyTimelineCollectionReadModel source,
) {
  final values = <String?>[
    source.publicLabel,
    source.officialMoveQuality,
    source.timelineCollectionId,
    source.timelineCollectionSource,
    analyzerLegacyReviewSummaryReadModelSource,
    ...source.entryIds,
    ...source.entries.map((entry) => entry.publicLabel),
    ...source.entries.map((entry) => entry.officialMoveQuality),
    ...source.entries.map((entry) => entry.timelineEntryId),
    ...source.entries.map((entry) => entry.privateDraftBucket.wire),
    ...source.entries.map((entry) => entry.privateDraftReasonCode.wire),
    ...source.entries.map((entry) => entry.privateDraftConfidenceTier.wire),
    ...source.entries.map((entry) => entry.timelineEntryKind.wire),
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

class _PrivateBucketCounts {
  const _PrivateBucketCounts({
    this.total = 0,
    this.positive = 0,
    this.neutral = 0,
    this.negative = 0,
    this.unavailable = 0,
  });

  final int total;
  final int positive;
  final int neutral;
  final int negative;
  final int unavailable;
}
