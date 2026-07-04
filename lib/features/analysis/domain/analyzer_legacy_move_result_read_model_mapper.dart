import 'package:apex_chess/features/analysis/domain/analyzer_legacy_move_result_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';

AnalyzerLegacyMoveResultReadModel mapLegacyReintegrationToMoveResultReadModel(
  AnalyzerLegacyReintegrationResult source,
) {
  const readModelIsPublic = false;
  const readModelIsProductReview = false;
  const readModelIsSavedAnalysis = false;
  const readModelIsOfficial = false;
  const readModelIsUiOutput = false;
  const readModelIsArchiveStatsOutput = false;
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

  final readModelId = _readModelId(source);
  final publicStringsClean = !_containsForbiddenPublicString(
    source,
    readModelId,
  );
  final sourceSafe =
      source.legacyReintegrationProbeSucceeded &&
      source.safeForPhase36B &&
      source.legacyReintegrationComputed &&
      !source.legacyReintegrationIsPublic &&
      !source.legacyReintegrationIsProductReview &&
      !source.legacyReintegrationIsSavedAnalysis &&
      !source.legacyReintegrationIsOfficial &&
      !source.legacyPublicLabelProduced &&
      !source.legacyOfficialMoveQualityProduced &&
      !source.legacySavedAnalysisWritten &&
      !source.legacyUiOutputProduced &&
      !source.legacyArchiveStatsTouched &&
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
      source.privateDraftBucket != AnalyzerPrivateDraftBucket.unavailable;
  final readModelComputed = sourceSafe && publicStringsClean;
  final mappingSucceeded =
      readModelComputed &&
      !readModelIsPublic &&
      !readModelIsProductReview &&
      !readModelIsSavedAnalysis &&
      !readModelIsOfficial &&
      !readModelIsUiOutput &&
      !readModelIsArchiveStatsOutput &&
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

  return AnalyzerLegacyMoveResultReadModel(
    readModelId: readModelId,
    legacyReintegrationResultId: source.legacyReintegrationResultId,
    phase35QAnalysisResultId: source.phase35QAnalysisResultId,
    playedMoveUci: source.playedMoveUci,
    candidateMoveUci: source.candidateMoveUci,
    moverColor: source.moverColor,
    requestedDepth: source.requestedDepth,
    readModelSource: analyzerLegacyMoveResultReadModelSource,
    readModelVersion: analyzerLegacyMoveResultReadModelVersion,
    privateDraftBucket: sourceSafe
        ? source.privateDraftBucket
        : AnalyzerPrivateDraftBucket.unavailable,
    privateDraftReasonCode: sourceSafe
        ? source.privateDraftReasonCode
        : AnalyzerPrivateDraftReasonCode.gateBlocked,
    privateDraftConfidenceTier: sourceSafe
        ? source.privateDraftConfidenceTier
        : AnalyzerPrivateDraftConfidenceTier.unavailable,
    sourceLegacyReintegrationComputed: source.legacyReintegrationComputed,
    readModelComputed: readModelComputed,
    readModelIsPublic: readModelIsPublic,
    readModelIsProductReview: readModelIsProductReview,
    readModelIsSavedAnalysis: readModelIsSavedAnalysis,
    readModelIsOfficial: readModelIsOfficial,
    readModelIsUiOutput: readModelIsUiOutput,
    readModelIsArchiveStatsOutput: readModelIsArchiveStatsOutput,
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
    safeForPhase36C: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerLegacyMoveResultReadModelNextRecommendation
        : analyzerLegacyMoveResultReadModelFailureRecommendation,
  );
}

String _readModelId(AnalyzerLegacyReintegrationResult source) {
  return [
    'phase36B',
    source.playedMoveUci,
    source.candidateMoveUci,
    source.moverColor.wire,
    'depth${source.requestedDepth}',
  ].join(':');
}

String _failureMessage(AnalyzerLegacyReintegrationResult source) {
  if (!source.legacyReintegrationProbeSucceeded) {
    return 'Legacy reintegration source did not succeed.';
  }
  if (!source.safeForPhase36B || !source.legacyReintegrationComputed) {
    return 'Legacy reintegration source is not safe for read-model mapping.';
  }
  if (source.legacyReintegrationIsPublic ||
      source.legacyPublicLabelProduced ||
      source.publicLabelComputed ||
      source.publicLabel != null) {
    return 'Legacy reintegration source exposed public label data.';
  }
  if (source.legacyReintegrationIsOfficial ||
      source.legacyOfficialMoveQualityProduced ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return 'Legacy reintegration source exposed official metric data.';
  }
  if (source.legacyReintegrationIsProductReview) {
    return 'Legacy reintegration source is product review output.';
  }
  if (source.legacyReintegrationIsSavedAnalysis ||
      source.legacySavedAnalysisWritten) {
    return 'Legacy reintegration source touched saved analysis.';
  }
  if (source.legacyUiOutputProduced) {
    return 'Legacy reintegration source produced UI output.';
  }
  if (source.legacyArchiveStatsTouched) {
    return 'Legacy reintegration source touched archive or stats.';
  }
  if (_containsForbiddenPublicString(source, _readModelId(source))) {
    return 'Legacy move result read model blocked a public label string.';
  }
  return 'Legacy move result read-model mapping did not succeed.';
}

bool _containsForbiddenPublicString(
  AnalyzerLegacyReintegrationResult source,
  String readModelId,
) {
  final values = <String?>[
    source.publicLabel,
    source.officialMoveQuality,
    source.privateDraftBucket.wire,
    source.privateDraftReasonCode.wire,
    source.privateDraftConfidenceTier.wire,
    readModelId,
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
