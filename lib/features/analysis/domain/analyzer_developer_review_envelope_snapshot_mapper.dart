import 'package:apex_chess/features/analysis/domain/analyzer_developer_review_envelope_snapshot.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_envelope_read_model.dart';

AnalyzerDeveloperReviewEnvelopeSnapshot
mapLegacyReviewEnvelopeToDeveloperReviewEnvelopeSnapshot(
  AnalyzerLegacyReviewEnvelopeReadModel source,
) {
  const snapshotIsDeveloperOnly = true;
  const snapshotIsReadOnly = true;
  const snapshotIsPublic = false;
  const snapshotIsProductReview = false;
  const snapshotIsSavedAnalysis = false;
  const snapshotIsOfficial = false;
  const snapshotIsUiOutput = false;
  const snapshotIsArchiveStatsOutput = false;
  const snapshotIsFullGameAnalysis = false;
  const snapshotIsProductTimeline = false;
  const snapshotContainsPublicLabels = false;
  const snapshotContainsOfficialMetrics = false;
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

  final publicStringsClean = !_containsForbiddenPublicString(source);
  final sourceSafe = _isSafeEnvelope(source);
  final snapshotCountsMatchSource =
      source.reviewEnvelopeCountsMatchCollection &&
      source.blockedEntryCount == 0 &&
      source.sourceEntryCount == source.mappedEntryCount &&
      source.totalPrivateEntries == source.mappedEntryCount &&
      source.totalPrivateEntries ==
          source.positiveCandidateCount +
              source.neutralCandidateCount +
              source.negativeCandidateCount +
              source.unavailableCount;
  final snapshotComputed =
      sourceSafe &&
      publicStringsClean &&
      snapshotCountsMatchSource &&
      snapshotIsDeveloperOnly &&
      snapshotIsReadOnly &&
      !snapshotIsPublic &&
      !snapshotIsProductReview &&
      !snapshotIsSavedAnalysis &&
      !snapshotIsOfficial &&
      !snapshotIsUiOutput &&
      !snapshotIsArchiveStatsOutput &&
      !snapshotIsFullGameAnalysis &&
      !snapshotIsProductTimeline &&
      !snapshotContainsPublicLabels &&
      !snapshotContainsOfficialMetrics;
  final mappingSucceeded =
      snapshotComputed &&
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

  return AnalyzerDeveloperReviewEnvelopeSnapshot(
    snapshotId: mappingSucceeded
        ? _snapshotId(source)
        : 'phase36H:blocked:sourceEntries${source.sourceEntryCount}',
    sourceReviewEnvelopeId: publicStringsClean
        ? source.reviewEnvelopeId
        : 'phase36H:blockedReviewEnvelope',
    sourceTimelineCollectionId: publicStringsClean
        ? source.sourceTimelineCollectionId
        : 'phase36H:blockedTimelineCollection',
    sourceReviewSummaryId: publicStringsClean
        ? source.sourceReviewSummaryId
        : 'phase36H:blockedReviewSummary',
    snapshotSource: analyzerDeveloperReviewEnvelopeSnapshotSource,
    snapshotVersion: analyzerDeveloperReviewEnvelopeSnapshotVersion,
    sourceReviewEnvelopeComputed: source.reviewEnvelopeComputed,
    sourceReviewEnvelopeIsDeveloperOnly: source.reviewEnvelopeIsDeveloperOnly,
    sourceReviewEnvelopeIsPublic: source.reviewEnvelopeIsPublic,
    sourceReviewEnvelopeIsProductReview: source.reviewEnvelopeIsProductReview,
    sourceReviewEnvelopeIsSavedAnalysis: source.reviewEnvelopeIsSavedAnalysis,
    sourceReviewEnvelopeIsOfficial: source.reviewEnvelopeIsOfficial,
    sourceReviewEnvelopeIsUiOutput: source.reviewEnvelopeIsUiOutput,
    sourceReviewEnvelopeIsArchiveStatsOutput:
        source.reviewEnvelopeIsArchiveStatsOutput,
    sourceReviewEnvelopeIsFullGameAnalysis:
        source.reviewEnvelopeIsFullGameAnalysis,
    sourceReviewEnvelopeIsProductTimeline:
        source.reviewEnvelopeIsProductTimeline,
    snapshotComputed: snapshotComputed,
    snapshotIsDeveloperOnly: snapshotIsDeveloperOnly,
    snapshotIsReadOnly: snapshotIsReadOnly,
    snapshotIsPublic: snapshotIsPublic,
    snapshotIsProductReview: snapshotIsProductReview,
    snapshotIsSavedAnalysis: snapshotIsSavedAnalysis,
    snapshotIsOfficial: snapshotIsOfficial,
    snapshotIsUiOutput: snapshotIsUiOutput,
    snapshotIsArchiveStatsOutput: snapshotIsArchiveStatsOutput,
    snapshotIsFullGameAnalysis: snapshotIsFullGameAnalysis,
    snapshotIsProductTimeline: snapshotIsProductTimeline,
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    snapshotCountsMatchSource: snapshotCountsMatchSource,
    snapshotContainsPublicLabels: snapshotContainsPublicLabels,
    snapshotContainsOfficialMetrics: snapshotContainsOfficialMetrics,
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
            sourceSafe: sourceSafe,
            snapshotCountsMatchSource: snapshotCountsMatchSource,
            publicStringsClean: publicStringsClean,
          ),
    safeForPhase36I: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerDeveloperReviewEnvelopeSnapshotNextRecommendation
        : analyzerDeveloperReviewEnvelopeSnapshotFailureRecommendation,
  );
}

bool _isSafeEnvelope(AnalyzerLegacyReviewEnvelopeReadModel source) {
  return source.mappingSucceeded &&
      source.safeForPhase36G &&
      source.reviewEnvelopeComputed &&
      source.reviewEnvelopeContainsTimelineCollection &&
      source.reviewEnvelopeContainsReviewSummary &&
      source.reviewEnvelopeCountsMatchCollection &&
      source.reviewEnvelopeIsDeveloperOnly &&
      !source.reviewEnvelopeIsPublic &&
      !source.reviewEnvelopeIsProductReview &&
      !source.reviewEnvelopeIsSavedAnalysis &&
      !source.reviewEnvelopeIsOfficial &&
      !source.reviewEnvelopeIsUiOutput &&
      !source.reviewEnvelopeIsArchiveStatsOutput &&
      !source.reviewEnvelopeIsFullGameAnalysis &&
      !source.reviewEnvelopeIsProductTimeline &&
      source.timelineCollectionIsDeveloperOnly &&
      !source.timelineCollectionIsProductReview &&
      !source.timelineCollectionIsSavedAnalysis &&
      !source.timelineCollectionIsUiOutput &&
      !source.timelineCollectionIsArchiveStatsOutput &&
      !source.timelineCollectionIsFullGameAnalysis &&
      !source.timelineCollectionIsProductTimeline &&
      source.reviewSummaryIsDeveloperOnly &&
      !source.reviewSummaryIsProductReview &&
      !source.reviewSummaryIsSavedAnalysis &&
      !source.reviewSummaryIsUiOutput &&
      !source.reviewSummaryIsArchiveStatsOutput &&
      !source.reviewSummaryIsFullGameAnalysis &&
      !source.reviewSummaryIsProductTimeline &&
      source.sourceTimelineCollectionComputed &&
      source.sourceReviewSummaryComputed &&
      source.blockedEntryCount == 0 &&
      source.sourceEntryCount == source.mappedEntryCount &&
      source.totalPrivateEntries == source.mappedEntryCount &&
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

String _snapshotId(AnalyzerLegacyReviewEnvelopeReadModel source) {
  return ['phase36H', source.reviewEnvelopeId, 'snapshot'].join(':');
}

String _failureMessage({
  required AnalyzerLegacyReviewEnvelopeReadModel source,
  required bool sourceSafe,
  required bool snapshotCountsMatchSource,
  required bool publicStringsClean,
}) {
  if (!publicStringsClean) {
    return 'Developer review envelope snapshot blocked a public label string.';
  }
  if (!source.mappingSucceeded ||
      !source.safeForPhase36G ||
      !source.reviewEnvelopeComputed) {
    return 'Developer review envelope snapshot source did not succeed.';
  }
  if (!source.reviewEnvelopeIsDeveloperOnly) {
    return 'Developer review envelope snapshot source is not developer-only.';
  }
  if (source.reviewEnvelopeIsProductReview) {
    return 'Developer review envelope snapshot source is product review output.';
  }
  if (source.reviewEnvelopeIsSavedAnalysis || source.savedAnalysisWritten) {
    return 'Developer review envelope snapshot source touched saved analysis.';
  }
  if (source.reviewEnvelopeIsUiOutput || source.uiOutputProduced) {
    return 'Developer review envelope snapshot source produced UI output.';
  }
  if (source.reviewEnvelopeIsArchiveStatsOutput || source.archiveStatsTouched) {
    return 'Developer review envelope snapshot source touched archive or stats.';
  }
  if (source.reviewEnvelopeIsFullGameAnalysis ||
      source.reviewEnvelopeIsProductTimeline) {
    return 'Developer review envelope snapshot source exposed full-game or product timeline output.';
  }
  if (source.reviewEnvelopeIsPublic ||
      source.publicLabelComputed ||
      source.publicLabel != null) {
    return 'Developer review envelope snapshot source exposed public label data.';
  }
  if (source.reviewEnvelopeIsOfficial ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return 'Developer review envelope snapshot source exposed official metric data.';
  }
  if (!snapshotCountsMatchSource) {
    return 'Developer review envelope snapshot blocked a source count mismatch.';
  }
  if (!sourceSafe) {
    return 'Developer review envelope snapshot source is unsafe.';
  }
  return 'Developer review envelope snapshot mapping did not succeed.';
}

bool _containsForbiddenPublicString(
  AnalyzerLegacyReviewEnvelopeReadModel source,
) {
  final values = <String?>[
    source.publicLabel,
    source.officialMoveQuality,
    source.reviewEnvelopeId,
    source.sourceTimelineCollectionId,
    source.sourceReviewSummaryId,
    analyzerDeveloperReviewEnvelopeSnapshotSource,
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
