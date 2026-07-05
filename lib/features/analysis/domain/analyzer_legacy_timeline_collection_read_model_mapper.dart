import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_collection_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';

AnalyzerLegacyTimelineCollectionReadModel
mapLegacyTimelineEntriesToCollectionReadModel(
  List<AnalyzerLegacyTimelineEntryReadModel> sourceEntries,
) {
  const timelineCollectionIsPublic = false;
  const timelineCollectionIsProductReview = false;
  const timelineCollectionIsSavedAnalysis = false;
  const timelineCollectionIsOfficial = false;
  const timelineCollectionIsUiOutput = false;
  const timelineCollectionIsArchiveStatsOutput = false;
  const timelineCollectionIsFullGameAnalysis = false;
  const timelineCollectionIsProductTimeline = false;
  const timelineCollectionIsDeveloperOnly = true;
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

  final sourceEntryCount = sourceEntries.length;
  final sourceHasEntries = sourceEntries.isNotEmpty;
  final sourceEntriesSafe =
      sourceHasEntries &&
      sourceEntries.every(_isSafeEntry) &&
      !_containsForbiddenPublicString(sourceEntries);
  final sortedEntries = sourceEntriesSafe
      ? (List<AnalyzerLegacyTimelineEntryReadModel>.of(sourceEntries)
          ..sort(_compareEntries))
      : <AnalyzerLegacyTimelineEntryReadModel>[];
  final entryIds = sortedEntries
      .map((entry) => entry.timelineEntryId)
      .toList(growable: false);
  final allEntriesAreSingleMoveOnly =
      sourceEntriesSafe &&
      sortedEntries.every((entry) => entry.timelineEntryIsSingleMoveOnly);
  final allEntriesArePrivateSingleMoveDraft =
      sourceEntriesSafe &&
      sortedEntries.every(
        (entry) =>
            entry.timelineEntryKind ==
            AnalyzerLegacyTimelineEntryKind.privateSingleMoveDraft,
      );
  final entriesSortedByOrderKey =
      sourceEntriesSafe && _isSortedByOrderKey(sortedEntries);
  final allEntriesSafe =
      sourceEntriesSafe &&
      allEntriesAreSingleMoveOnly &&
      allEntriesArePrivateSingleMoveDraft &&
      entriesSortedByOrderKey;
  final timelineCollectionComputed =
      allEntriesSafe &&
      !timelineCollectionIsPublic &&
      !timelineCollectionIsProductReview &&
      !timelineCollectionIsSavedAnalysis &&
      !timelineCollectionIsOfficial &&
      !timelineCollectionIsUiOutput &&
      !timelineCollectionIsArchiveStatsOutput &&
      !timelineCollectionIsFullGameAnalysis &&
      !timelineCollectionIsProductTimeline &&
      timelineCollectionIsDeveloperOnly;
  final mappingSucceeded =
      timelineCollectionComputed &&
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

  return AnalyzerLegacyTimelineCollectionReadModel(
    timelineCollectionId: _collectionId(sortedEntries, sourceEntryCount),
    timelineCollectionSource: analyzerLegacyTimelineCollectionReadModelSource,
    timelineCollectionVersion: analyzerLegacyTimelineCollectionReadModelVersion,
    sourceEntryCount: sourceEntryCount,
    mappedEntryCount: sortedEntries.length,
    blockedEntryCount: sourceEntryCount - sortedEntries.length,
    timelineCollectionComputed: timelineCollectionComputed,
    timelineCollectionIsPublic: timelineCollectionIsPublic,
    timelineCollectionIsProductReview: timelineCollectionIsProductReview,
    timelineCollectionIsSavedAnalysis: timelineCollectionIsSavedAnalysis,
    timelineCollectionIsOfficial: timelineCollectionIsOfficial,
    timelineCollectionIsUiOutput: timelineCollectionIsUiOutput,
    timelineCollectionIsArchiveStatsOutput:
        timelineCollectionIsArchiveStatsOutput,
    timelineCollectionIsFullGameAnalysis: timelineCollectionIsFullGameAnalysis,
    timelineCollectionIsProductTimeline: timelineCollectionIsProductTimeline,
    timelineCollectionIsDeveloperOnly: timelineCollectionIsDeveloperOnly,
    entries: List.unmodifiable(sortedEntries),
    entryIds: List.unmodifiable(entryIds),
    allEntriesAreSingleMoveOnly: allEntriesAreSingleMoveOnly,
    allEntriesArePrivateSingleMoveDraft: allEntriesArePrivateSingleMoveDraft,
    allEntriesSafe: allEntriesSafe,
    entriesSortedByOrderKey: entriesSortedByOrderKey,
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
    failureMessage: mappingSucceeded ? null : _failureMessage(sourceEntries),
    safeForPhase36E: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerLegacyTimelineCollectionReadModelNextRecommendation
        : analyzerLegacyTimelineCollectionReadModelFailureRecommendation,
  );
}

int _compareEntries(
  AnalyzerLegacyTimelineEntryReadModel a,
  AnalyzerLegacyTimelineEntryReadModel b,
) {
  final byOrder = a.timelineEntryOrderKey.compareTo(b.timelineEntryOrderKey);
  if (byOrder != 0) return byOrder;
  return a.timelineEntryId.compareTo(b.timelineEntryId);
}

bool _isSortedByOrderKey(List<AnalyzerLegacyTimelineEntryReadModel> entries) {
  for (var i = 1; i < entries.length; i++) {
    if (_compareEntries(entries[i - 1], entries[i]) > 0) return false;
  }
  return true;
}

bool _isSafeEntry(AnalyzerLegacyTimelineEntryReadModel entry) {
  return entry.mappingSucceeded &&
      entry.safeForPhase36D &&
      entry.timelineEntryComputed &&
      entry.timelineEntryKind ==
          AnalyzerLegacyTimelineEntryKind.privateSingleMoveDraft &&
      entry.timelineEntryIsSingleMoveOnly &&
      !entry.timelineEntryIsFullGameTimeline &&
      !entry.timelineEntryIsProductTimeline &&
      !entry.timelineEntryIsUiOutput &&
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
      !entry.archiveStatsTouched &&
      entry.privateDraftBucket != AnalyzerPrivateDraftBucket.unavailable;
}

String _collectionId(
  List<AnalyzerLegacyTimelineEntryReadModel> sortedEntries,
  int sourceEntryCount,
) {
  if (sortedEntries.isEmpty) return 'phase36D:blocked:count$sourceEntryCount';
  final first = sortedEntries.first;
  return [
    'phase36D',
    first.playedMoveUci,
    first.candidateMoveUci,
    first.moverColor.wire,
    'count${sortedEntries.length}',
  ].join(':');
}

String _failureMessage(List<AnalyzerLegacyTimelineEntryReadModel> entries) {
  if (entries.isEmpty) {
    return 'Legacy timeline collection requires at least one safe entry.';
  }
  if (_containsForbiddenPublicString(entries)) {
    return 'Legacy timeline collection blocked a public label string.';
  }
  if (entries.any(
    (entry) => !entry.mappingSucceeded || !entry.safeForPhase36D,
  )) {
    return 'A legacy timeline entry source did not succeed.';
  }
  if (entries.any(
    (entry) =>
        entry.timelineEntryIsFullGameTimeline ||
        entry.timelineEntryIsProductTimeline ||
        entry.timelineEntryIsUiOutput,
  )) {
    return 'A legacy timeline entry exposed full-game, product, or UI output.';
  }
  if (entries.any(
    (entry) =>
        entry.sourceReadModelIsPublic ||
        entry.publicLabelComputed ||
        entry.publicLabel != null,
  )) {
    return 'A legacy timeline entry exposed public label data.';
  }
  if (entries.any(
    (entry) =>
        entry.sourceReadModelIsOfficial ||
        entry.officialMoveQualityComputed ||
        entry.officialMoveQuality != null ||
        entry.officialCpLossComputed ||
        entry.officialWinPercentComputed ||
        entry.accuracyComputed ||
        entry.acplComputed ||
        entry.classificationComputed ||
        entry.publicClassifierOutputComputed,
  )) {
    return 'A legacy timeline entry exposed official metric data.';
  }
  if (entries.any(
    (entry) =>
        entry.sourceReadModelIsSavedAnalysis || entry.savedAnalysisWritten,
  )) {
    return 'A legacy timeline entry touched saved analysis.';
  }
  if (entries.any(
    (entry) =>
        entry.sourceReadModelIsArchiveStatsOutput || entry.archiveStatsTouched,
  )) {
    return 'A legacy timeline entry touched archive or stats.';
  }
  return 'Legacy timeline collection read-model mapping did not succeed.';
}

bool _containsForbiddenPublicString(
  List<AnalyzerLegacyTimelineEntryReadModel> entries,
) {
  final values = <String?>[
    analyzerLegacyTimelineCollectionReadModelSource,
    ...entries.map((entry) => entry.publicLabel),
    ...entries.map((entry) => entry.officialMoveQuality),
    ...entries.map((entry) => entry.timelineEntryId),
    ...entries.map((entry) => entry.privateDraftBucket.wire),
    ...entries.map((entry) => entry.privateDraftReasonCode.wire),
    ...entries.map((entry) => entry.privateDraftConfidenceTier.wire),
    ...entries.map((entry) => entry.timelineEntryKind.wire),
  ].whereType<String>();
  return values.any(_forbiddenPublicStrings.contains);
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
