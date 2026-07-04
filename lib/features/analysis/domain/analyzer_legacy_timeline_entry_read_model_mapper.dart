import 'package:apex_chess/features/analysis/domain/analyzer_legacy_move_result_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';

AnalyzerLegacyTimelineEntryReadModel
mapLegacyMoveResultToTimelineEntryReadModel(
  AnalyzerLegacyMoveResultReadModel source,
) {
  const timelineEntryIsFullGameTimeline = false;
  const timelineEntryIsProductTimeline = false;
  const timelineEntryIsUiOutput = false;
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

  final timelineEntryId = _timelineEntryId(source);
  final publicStringsClean = !_containsForbiddenPublicString(
    source,
    timelineEntryId,
  );
  final sourceSafe =
      source.mappingSucceeded &&
      source.safeForPhase36C &&
      source.readModelComputed &&
      !source.readModelIsPublic &&
      !source.readModelIsProductReview &&
      !source.readModelIsSavedAnalysis &&
      !source.readModelIsOfficial &&
      !source.readModelIsUiOutput &&
      !source.readModelIsArchiveStatsOutput &&
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
      source.privateDraftBucket != AnalyzerPrivateDraftBucket.unavailable;
  final timelineEntryComputed = sourceSafe && publicStringsClean;
  final timelineEntryIsSingleMoveOnly = timelineEntryComputed;
  final mappingSucceeded =
      timelineEntryComputed &&
      timelineEntryIsSingleMoveOnly &&
      !timelineEntryIsFullGameTimeline &&
      !timelineEntryIsProductTimeline &&
      !timelineEntryIsUiOutput &&
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

  return AnalyzerLegacyTimelineEntryReadModel(
    timelineEntryId: timelineEntryId,
    sourceReadModelId: source.readModelId,
    legacyReintegrationResultId: source.legacyReintegrationResultId,
    phase35QAnalysisResultId: source.phase35QAnalysisResultId,
    playedMoveUci: source.playedMoveUci,
    candidateMoveUci: source.candidateMoveUci,
    moverColor: source.moverColor,
    requestedDepth: source.requestedDepth,
    timelineEntrySource: analyzerLegacyTimelineEntryReadModelSource,
    timelineEntryVersion: analyzerLegacyTimelineEntryReadModelVersion,
    timelineEntryComputed: timelineEntryComputed,
    timelineEntryKind: timelineEntryComputed
        ? AnalyzerLegacyTimelineEntryKind.privateSingleMoveDraft
        : AnalyzerLegacyTimelineEntryKind.unavailable,
    timelineEntryOrderKey: timelineEntryComputed ? 0 : -1,
    timelineEntryIsSingleMoveOnly: timelineEntryIsSingleMoveOnly,
    timelineEntryIsFullGameTimeline: timelineEntryIsFullGameTimeline,
    timelineEntryIsProductTimeline: timelineEntryIsProductTimeline,
    timelineEntryIsUiOutput: timelineEntryIsUiOutput,
    privateDraftBucket: sourceSafe
        ? source.privateDraftBucket
        : AnalyzerPrivateDraftBucket.unavailable,
    privateDraftReasonCode: sourceSafe
        ? source.privateDraftReasonCode
        : AnalyzerPrivateDraftReasonCode.gateBlocked,
    privateDraftConfidenceTier: sourceSafe
        ? source.privateDraftConfidenceTier
        : AnalyzerPrivateDraftConfidenceTier.unavailable,
    sourceReadModelComputed: source.readModelComputed,
    sourceReadModelIsPublic: source.readModelIsPublic,
    sourceReadModelIsProductReview: source.readModelIsProductReview,
    sourceReadModelIsSavedAnalysis: source.readModelIsSavedAnalysis,
    sourceReadModelIsOfficial: source.readModelIsOfficial,
    sourceReadModelIsUiOutput: source.readModelIsUiOutput,
    sourceReadModelIsArchiveStatsOutput: source.readModelIsArchiveStatsOutput,
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
    failureMessage: mappingSucceeded ? null : _failureMessage(source),
    safeForPhase36D: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerLegacyTimelineEntryReadModelNextRecommendation
        : analyzerLegacyTimelineEntryReadModelFailureRecommendation,
  );
}

String _timelineEntryId(AnalyzerLegacyMoveResultReadModel source) {
  return [
    'phase36C',
    source.playedMoveUci,
    source.candidateMoveUci,
    source.moverColor.wire,
    'depth${source.requestedDepth}',
  ].join(':');
}

String _failureMessage(AnalyzerLegacyMoveResultReadModel source) {
  if (!source.mappingSucceeded) {
    return 'Legacy move result read model source did not succeed.';
  }
  if (!source.safeForPhase36C || !source.readModelComputed) {
    return 'Legacy move result read model source is not safe for timeline mapping.';
  }
  if (source.readModelIsPublic ||
      source.publicLabelComputed ||
      source.publicLabel != null) {
    return 'Legacy move result read model source exposed public label data.';
  }
  if (source.readModelIsOfficial ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return 'Legacy move result read model source exposed official metric data.';
  }
  if (source.readModelIsProductReview) {
    return 'Legacy move result read model source is product review output.';
  }
  if (source.readModelIsSavedAnalysis || source.savedAnalysisWritten) {
    return 'Legacy move result read model source touched saved analysis.';
  }
  if (source.readModelIsUiOutput || source.uiOutputProduced) {
    return 'Legacy move result read model source produced UI output.';
  }
  if (source.readModelIsArchiveStatsOutput || source.archiveStatsTouched) {
    return 'Legacy move result read model source touched archive or stats.';
  }
  if (_containsForbiddenPublicString(source, _timelineEntryId(source))) {
    return 'Legacy timeline entry read model blocked a public label string.';
  }
  return 'Legacy timeline entry read-model mapping did not succeed.';
}

bool _containsForbiddenPublicString(
  AnalyzerLegacyMoveResultReadModel source,
  String timelineEntryId,
) {
  final values = <String?>[
    source.publicLabel,
    source.officialMoveQuality,
    source.privateDraftBucket.wire,
    source.privateDraftReasonCode.wire,
    source.privateDraftConfidenceTier.wire,
    timelineEntryId,
    AnalyzerLegacyTimelineEntryKind.privateSingleMoveDraft.wire,
    AnalyzerLegacyTimelineEntryKind.unavailable.wire,
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
