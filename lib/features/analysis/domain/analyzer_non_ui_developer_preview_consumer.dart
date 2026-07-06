import 'package:apex_chess/features/analysis/domain/analyzer_read_only_developer_preview_adapter.dart';

const analyzerNonUiDeveloperPreviewConsumerSource =
    'phase37CNonUiDeveloperPreviewConsumer';
const analyzerNonUiDeveloperPreviewConsumerVersion = 'phase37C.v1';
const analyzerNonUiDeveloperPreviewConsumerNextRecommendation =
    'planDeveloperOnlyProbeHarnessOrDiagnosticsBoundary';
const analyzerNonUiDeveloperPreviewConsumerFailureRecommendation =
    'fixNonUiDeveloperPreviewConsumerBoundary';

enum AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason {
  none('none'),
  sourceUnsafe('sourceUnsafe'),
  sourceUnavailable('sourceUnavailable');

  const AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason(this.wire);

  final String wire;
}

class AnalyzerNonUiDeveloperPreviewConsumerResult {
  const AnalyzerNonUiDeveloperPreviewConsumerResult({
    required this.consumerResultId,
    required this.sourceAdapterResultId,
    required this.consumerSource,
    required this.consumerVersion,
    required this.consumerComputed,
    required this.consumerReady,
    required this.consumerUnavailableReason,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.consumerIsDeveloperOnly,
    required this.consumerIsReadOnly,
    required this.consumerIsUiOutput,
    required this.consumerIsDebugUi,
    required this.consumerIsProductReview,
    required this.consumerIsSavedAnalysis,
    required this.consumerIsPersistenceWrite,
    required this.consumerIsFileWrite,
    required this.consumerIsBackendPayload,
    required this.consumerIsArchiveStatsOutput,
    required this.consumerContainsPublicLabels,
    required this.consumerContainsOfficialMetrics,
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
    required this.persistenceWritePerformed,
    required this.fileWritePerformed,
    required this.backendPayloadProduced,
    required this.archiveStatsTouched,
    required this.mappingSucceeded,
    required this.failureMessage,
    required this.safeForPhase37D,
    required this.safeForPhase37E,
    required this.nextRecommendation,
  });

  final String consumerResultId;
  final String sourceAdapterResultId;
  final String consumerSource;
  final String consumerVersion;
  final bool consumerComputed;
  final bool consumerReady;
  final AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason
  consumerUnavailableReason;
  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;
  final bool consumerIsDeveloperOnly;
  final bool consumerIsReadOnly;
  final bool consumerIsUiOutput;
  final bool consumerIsDebugUi;
  final bool consumerIsProductReview;
  final bool consumerIsSavedAnalysis;
  final bool consumerIsPersistenceWrite;
  final bool consumerIsFileWrite;
  final bool consumerIsBackendPayload;
  final bool consumerIsArchiveStatsOutput;
  final bool consumerContainsPublicLabels;
  final bool consumerContainsOfficialMetrics;
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
  final bool persistenceWritePerformed;
  final bool fileWritePerformed;
  final bool backendPayloadProduced;
  final bool archiveStatsTouched;
  final bool mappingSucceeded;
  final String? failureMessage;
  final bool safeForPhase37D;
  final bool safeForPhase37E;
  final String nextRecommendation;
}

AnalyzerNonUiDeveloperPreviewConsumerResult
consumeReadOnlyDeveloperPreviewAdapterResult(
  AnalyzerReadOnlyDeveloperPreviewAdapterResult source,
) {
  const consumerIsDeveloperOnly = true;
  const consumerIsReadOnly = true;
  const consumerIsUiOutput = false;
  const consumerIsDebugUi = false;
  const consumerIsProductReview = false;
  const consumerIsSavedAnalysis = false;
  const consumerIsPersistenceWrite = false;
  const consumerIsFileWrite = false;
  const consumerIsBackendPayload = false;
  const consumerIsArchiveStatsOutput = false;
  const consumerContainsPublicLabels = false;
  const consumerContainsOfficialMetrics = false;
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
  const persistenceWritePerformed = false;
  const fileWritePerformed = false;
  const backendPayloadProduced = false;
  const archiveStatsTouched = false;

  final publicStringsClean = !_containsForbiddenPublicString(source);
  final sourceSafe = _isSafeSource(source) && publicStringsClean;
  final consumerComputed =
      sourceSafe &&
      consumerIsDeveloperOnly &&
      consumerIsReadOnly &&
      !consumerIsUiOutput &&
      !consumerIsDebugUi &&
      !consumerIsProductReview &&
      !consumerIsSavedAnalysis &&
      !consumerIsPersistenceWrite &&
      !consumerIsFileWrite &&
      !consumerIsBackendPayload &&
      !consumerIsArchiveStatsOutput &&
      !consumerContainsPublicLabels &&
      !consumerContainsOfficialMetrics;
  final mappingSucceeded =
      consumerComputed &&
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
      !persistenceWritePerformed &&
      !fileWritePerformed &&
      !backendPayloadProduced &&
      !archiveStatsTouched;

  return AnalyzerNonUiDeveloperPreviewConsumerResult(
    consumerResultId: mappingSucceeded
        ? _consumerResultId(source)
        : 'phase37C:blocked:nonUiDeveloperPreviewConsumer',
    sourceAdapterResultId: publicStringsClean
        ? source.adapterResultId
        : 'phase37C:blockedAdapterResult',
    consumerSource: analyzerNonUiDeveloperPreviewConsumerSource,
    consumerVersion: analyzerNonUiDeveloperPreviewConsumerVersion,
    consumerComputed: consumerComputed,
    consumerReady: mappingSucceeded,
    consumerUnavailableReason: mappingSucceeded
        ? AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason.none
        : _blockedReason(source),
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    consumerIsDeveloperOnly: consumerIsDeveloperOnly,
    consumerIsReadOnly: consumerIsReadOnly,
    consumerIsUiOutput: consumerIsUiOutput,
    consumerIsDebugUi: consumerIsDebugUi,
    consumerIsProductReview: consumerIsProductReview,
    consumerIsSavedAnalysis: consumerIsSavedAnalysis,
    consumerIsPersistenceWrite: consumerIsPersistenceWrite,
    consumerIsFileWrite: consumerIsFileWrite,
    consumerIsBackendPayload: consumerIsBackendPayload,
    consumerIsArchiveStatsOutput: consumerIsArchiveStatsOutput,
    consumerContainsPublicLabels: consumerContainsPublicLabels,
    consumerContainsOfficialMetrics: consumerContainsOfficialMetrics,
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
    persistenceWritePerformed: persistenceWritePerformed,
    fileWritePerformed: fileWritePerformed,
    backendPayloadProduced: backendPayloadProduced,
    archiveStatsTouched: archiveStatsTouched,
    mappingSucceeded: mappingSucceeded,
    failureMessage: mappingSucceeded
        ? null
        : _failureMessage(
            source: source,
            publicStringsClean: publicStringsClean,
          ),
    safeForPhase37D: mappingSucceeded,
    safeForPhase37E: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerNonUiDeveloperPreviewConsumerNextRecommendation
        : analyzerNonUiDeveloperPreviewConsumerFailureRecommendation,
  );
}

bool _isSafeSource(AnalyzerReadOnlyDeveloperPreviewAdapterResult source) {
  return source.mappingSucceeded &&
      source.adapterComputed &&
      source.previewReady &&
      source.previewUnavailableReason ==
          AnalyzerReadOnlyDeveloperPreviewUnavailableReason.none &&
      source.adapterIsDeveloperOnly &&
      source.adapterIsReadOnly &&
      !source.adapterIsUiOutput &&
      !source.adapterIsProductReview &&
      !source.adapterIsSavedAnalysis &&
      !source.adapterIsPersistenceWrite &&
      !source.adapterIsBackendPayload &&
      !source.adapterIsArchiveStatsOutput &&
      !source.adapterContainsPublicLabels &&
      !source.adapterContainsOfficialMetrics &&
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
      !source.persistenceWritePerformed &&
      !source.fileWritePerformed &&
      !source.backendPayloadProduced &&
      !source.archiveStatsTouched &&
      source.safeForPhase37B;
}

AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason _blockedReason(
  AnalyzerReadOnlyDeveloperPreviewAdapterResult source,
) {
  if (source.previewUnavailableReason ==
      AnalyzerReadOnlyDeveloperPreviewUnavailableReason.sourceUnavailable) {
    return AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason
        .sourceUnavailable;
  }
  if (!source.mappingSucceeded ||
      !source.adapterComputed ||
      !source.previewReady ||
      !source.safeForPhase37B) {
    return source.previewUnavailableReason ==
            AnalyzerReadOnlyDeveloperPreviewUnavailableReason.sourceUnsafe
        ? AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason.sourceUnsafe
        : AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason
              .sourceUnavailable;
  }
  return AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason.sourceUnsafe;
}

String _consumerResultId(AnalyzerReadOnlyDeveloperPreviewAdapterResult source) {
  return ['phase37C', source.adapterResultId, 'nonUiConsumer'].join(':');
}

String _failureMessage({
  required AnalyzerReadOnlyDeveloperPreviewAdapterResult source,
  required bool publicStringsClean,
}) {
  if (!publicStringsClean ||
      source.adapterContainsPublicLabels ||
      source.publicLabelComputed ||
      source.publicLabel != null) {
    return 'Non-UI developer preview consumer blocked public label data.';
  }
  if (!source.mappingSucceeded ||
      !source.adapterComputed ||
      !source.previewReady ||
      source.previewUnavailableReason !=
          AnalyzerReadOnlyDeveloperPreviewUnavailableReason.none ||
      !source.safeForPhase37B) {
    return 'Non-UI developer preview consumer source adapter is unavailable.';
  }
  if (!source.adapterIsDeveloperOnly) {
    return 'Non-UI developer preview consumer source is not developer-only.';
  }
  if (!source.adapterIsReadOnly) {
    return 'Non-UI developer preview consumer source is not read-only.';
  }
  if (source.adapterIsUiOutput || source.uiOutputProduced) {
    return 'Non-UI developer preview consumer source produced UI output.';
  }
  if (source.adapterIsProductReview) {
    return 'Non-UI developer preview consumer source is product review output.';
  }
  if (source.adapterIsSavedAnalysis || source.savedAnalysisWritten) {
    return 'Non-UI developer preview consumer source touched saved analysis.';
  }
  if (source.adapterIsPersistenceWrite || source.persistenceWritePerformed) {
    return 'Non-UI developer preview consumer source performed persistence write.';
  }
  if (source.fileWritePerformed) {
    return 'Non-UI developer preview consumer source performed file write.';
  }
  if (source.adapterIsBackendPayload || source.backendPayloadProduced) {
    return 'Non-UI developer preview consumer source produced backend payload.';
  }
  if (source.adapterIsArchiveStatsOutput || source.archiveStatsTouched) {
    return 'Non-UI developer preview consumer source touched archive or stats.';
  }
  if (source.adapterContainsOfficialMetrics ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return 'Non-UI developer preview consumer blocked official metric data.';
  }
  return 'Non-UI developer preview consumer source adapter is unsafe.';
}

bool _containsForbiddenPublicString(
  AnalyzerReadOnlyDeveloperPreviewAdapterResult source,
) {
  final values = <String?>[
    source.adapterResultId,
    source.sourceDebugPreviewContractId,
    source.adapterSource,
    source.publicLabel,
    source.officialMoveQuality,
    source.previewUnavailableReason.wire,
    source.nextRecommendation,
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
