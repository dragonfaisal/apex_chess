import 'package:apex_chess/features/analysis/domain/analyzer_developer_debug_preview_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_debug_read_facade.dart';

AnalyzerDeveloperDebugPreviewContract
mapDeveloperSnapshotDebugReadFacadeToDebugPreviewContract(
  AnalyzerDeveloperSnapshotDebugReadFacade source,
) {
  const debugPreviewIsDeveloperOnly = true;
  const debugPreviewIsReadOnly = true;
  const debugPreviewIsPublic = false;
  const debugPreviewIsProductFeature = false;
  const debugPreviewIsUiOutput = false;
  const debugPreviewIsDebugUi = false;
  const debugPreviewIsSavedAnalysis = false;
  const debugPreviewIsPersistenceWrite = false;
  const debugPreviewIsFileWrite = false;
  const debugPreviewIsArchiveStatsOutput = false;
  const debugPreviewIsBackendPayload = false;
  const debugPreviewIsOfficial = false;
  const previewContainsPublicLabels = false;
  const previewContainsOfficialMetrics = false;
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
  const persistenceWritePerformed = false;
  const fileWritePerformed = false;
  const backendPayloadProduced = false;

  final publicStringsClean = !_containsForbiddenPublicString(source);
  final sourceSafe = _isSafeDebugFacade(source);
  final previewSummaryMatchesFacade =
      source.readableSummaryMatchesExport &&
      source.totalPrivateEntries ==
          source.positiveCandidateCount +
              source.neutralCandidateCount +
              source.negativeCandidateCount +
              source.unavailableCount;
  final debugPreviewComputed =
      sourceSafe &&
      publicStringsClean &&
      previewSummaryMatchesFacade &&
      debugPreviewIsDeveloperOnly &&
      debugPreviewIsReadOnly &&
      !debugPreviewIsPublic &&
      !debugPreviewIsProductFeature &&
      !debugPreviewIsUiOutput &&
      !debugPreviewIsDebugUi &&
      !debugPreviewIsSavedAnalysis &&
      !debugPreviewIsPersistenceWrite &&
      !debugPreviewIsFileWrite &&
      !debugPreviewIsArchiveStatsOutput &&
      !debugPreviewIsBackendPayload &&
      !debugPreviewIsOfficial &&
      !previewContainsPublicLabels &&
      !previewContainsOfficialMetrics;
  final mappingSucceeded =
      debugPreviewComputed &&
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
      !archiveStatsTouched &&
      !persistenceWritePerformed &&
      !fileWritePerformed &&
      !backendPayloadProduced;
  final sourceUnavailable =
      !source.mappingSucceeded ||
      !source.safeForPhase36M ||
      !source.debugFacadeComputed;

  return AnalyzerDeveloperDebugPreviewContract(
    debugPreviewContractId: mappingSucceeded
        ? _debugPreviewContractId(source)
        : 'phase36N:blocked:entries${source.totalPrivateEntries}',
    sourceDebugFacadeId: publicStringsClean
        ? source.debugFacadeId
        : 'phase36N:blockedDebugFacade',
    sourceExportContractId: publicStringsClean
        ? source.sourceExportContractId
        : 'phase36N:blockedExportContract',
    sourceSnapshotId: publicStringsClean
        ? source.sourceSnapshotId
        : 'phase36N:blockedSnapshot',
    sourceReviewEnvelopeId: publicStringsClean
        ? source.sourceReviewEnvelopeId
        : 'phase36N:blockedReviewEnvelope',
    debugPreviewSource: analyzerDeveloperDebugPreviewContractSource,
    debugPreviewVersion: analyzerDeveloperDebugPreviewContractVersion,
    sourceDebugFacadeComputed: source.debugFacadeComputed,
    sourceDebugFacadeIsDeveloperOnly: source.debugFacadeIsDeveloperOnly,
    sourceDebugFacadeIsReadOnly: source.debugFacadeIsReadOnly,
    sourceDebugFacadeIsPublic: source.debugFacadeIsPublic,
    sourceDebugFacadeIsProductFeature: source.debugFacadeIsProductFeature,
    sourceDebugFacadeIsUiOutput: source.debugFacadeIsUiOutput,
    sourceDebugFacadeIsSavedAnalysis: source.debugFacadeIsSavedAnalysis,
    sourceDebugFacadeIsPersistenceWrite: source.debugFacadeIsPersistenceWrite,
    sourceDebugFacadeIsFileWrite: source.debugFacadeIsFileWrite,
    sourceDebugFacadeIsArchiveStatsOutput:
        source.debugFacadeIsArchiveStatsOutput,
    sourceDebugFacadeIsBackendPayload: source.debugFacadeIsBackendPayload,
    sourceDebugFacadeIsOfficial: source.debugFacadeIsOfficial,
    debugPreviewComputed: debugPreviewComputed,
    debugPreviewIsDeveloperOnly: debugPreviewIsDeveloperOnly,
    debugPreviewIsReadOnly: debugPreviewIsReadOnly,
    debugPreviewIsPublic: debugPreviewIsPublic,
    debugPreviewIsProductFeature: debugPreviewIsProductFeature,
    debugPreviewIsUiOutput: debugPreviewIsUiOutput,
    debugPreviewIsDebugUi: debugPreviewIsDebugUi,
    debugPreviewIsSavedAnalysis: debugPreviewIsSavedAnalysis,
    debugPreviewIsPersistenceWrite: debugPreviewIsPersistenceWrite,
    debugPreviewIsFileWrite: debugPreviewIsFileWrite,
    debugPreviewIsArchiveStatsOutput: debugPreviewIsArchiveStatsOutput,
    debugPreviewIsBackendPayload: debugPreviewIsBackendPayload,
    debugPreviewIsOfficial: debugPreviewIsOfficial,
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    previewSummaryMatchesFacade: previewSummaryMatchesFacade,
    previewContainsPublicLabels: previewContainsPublicLabels,
    previewContainsOfficialMetrics: previewContainsOfficialMetrics,
    developerPreviewStatus: mappingSucceeded
        ? AnalyzerDeveloperDebugPreviewStatus.ready
        : AnalyzerDeveloperDebugPreviewStatus.unavailable,
    developerPreviewMessage: mappingSucceeded
        ? AnalyzerDeveloperDebugPreviewMessage.developerPreviewReady
        : sourceUnavailable
        ? AnalyzerDeveloperDebugPreviewMessage.sourceFacadeUnavailable
        : AnalyzerDeveloperDebugPreviewMessage.sourceFacadeUnsafe,
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
    persistenceWritePerformed: persistenceWritePerformed,
    fileWritePerformed: fileWritePerformed,
    backendPayloadProduced: backendPayloadProduced,
    mappingSucceeded: mappingSucceeded,
    failureMessage: mappingSucceeded
        ? null
        : _failureMessage(
            source: source,
            sourceSafe: sourceSafe,
            previewSummaryMatchesFacade: previewSummaryMatchesFacade,
            publicStringsClean: publicStringsClean,
          ),
    safeForPhase36O: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerDeveloperDebugPreviewContractNextRecommendation
        : analyzerDeveloperDebugPreviewContractFailureRecommendation,
  );
}

bool _isSafeDebugFacade(AnalyzerDeveloperSnapshotDebugReadFacade source) {
  return source.mappingSucceeded &&
      source.safeForPhase36M &&
      source.debugFacadeComputed &&
      source.debugFacadeIsDeveloperOnly &&
      source.debugFacadeIsReadOnly &&
      !source.debugFacadeIsPublic &&
      !source.debugFacadeIsProductFeature &&
      !source.debugFacadeIsUiOutput &&
      !source.debugFacadeIsSavedAnalysis &&
      !source.debugFacadeIsPersistenceWrite &&
      !source.debugFacadeIsFileWrite &&
      !source.debugFacadeIsArchiveStatsOutput &&
      !source.debugFacadeIsBackendPayload &&
      !source.debugFacadeIsOfficial &&
      source.readableSummaryMatchesExport &&
      !source.readableSummaryContainsPublicLabels &&
      !source.readableSummaryContainsOfficialMetrics &&
      source.developerReadStatus ==
          AnalyzerDeveloperSnapshotDebugReadStatus.ready &&
      source.developerReadMessage ==
          AnalyzerDeveloperSnapshotDebugReadMessage.developerSnapshotReady &&
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
      !source.persistenceWritePerformed &&
      !source.fileWritePerformed &&
      !source.backendPayloadProduced;
}

String _debugPreviewContractId(
  AnalyzerDeveloperSnapshotDebugReadFacade source,
) {
  return ['phase36N', source.debugFacadeId, 'preview'].join(':');
}

String _failureMessage({
  required AnalyzerDeveloperSnapshotDebugReadFacade source,
  required bool sourceSafe,
  required bool previewSummaryMatchesFacade,
  required bool publicStringsClean,
}) {
  if (!publicStringsClean) {
    return 'Developer debug preview contract blocked a public label string.';
  }
  if (!source.mappingSucceeded ||
      !source.safeForPhase36M ||
      !source.debugFacadeComputed) {
    return 'Developer debug preview contract source facade is unavailable.';
  }
  if (!source.debugFacadeIsDeveloperOnly) {
    return 'Developer debug preview contract source facade is not developer-only.';
  }
  if (!source.debugFacadeIsReadOnly) {
    return 'Developer debug preview contract source facade is not read-only.';
  }
  if (source.debugFacadeIsPublic || source.publicLabelComputed) {
    return 'Developer debug preview contract source facade exposed public label data.';
  }
  if (source.debugFacadeIsProductFeature) {
    return 'Developer debug preview contract source facade is a product feature.';
  }
  if (source.debugFacadeIsSavedAnalysis || source.savedAnalysisWritten) {
    return 'Developer debug preview contract source facade touched saved analysis.';
  }
  if (source.debugFacadeIsPersistenceWrite ||
      source.persistenceWritePerformed) {
    return 'Developer debug preview contract source facade performed persistence write.';
  }
  if (source.debugFacadeIsFileWrite || source.fileWritePerformed) {
    return 'Developer debug preview contract source facade performed file write.';
  }
  if (source.debugFacadeIsUiOutput || source.uiOutputProduced) {
    return 'Developer debug preview contract source facade produced UI output.';
  }
  if (source.debugFacadeIsArchiveStatsOutput || source.archiveStatsTouched) {
    return 'Developer debug preview contract source facade touched archive or stats.';
  }
  if (source.debugFacadeIsBackendPayload || source.backendPayloadProduced) {
    return 'Developer debug preview contract source facade produced backend payload.';
  }
  if (source.debugFacadeIsOfficial ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return 'Developer debug preview contract source facade exposed official metric data.';
  }
  if (!source.readableSummaryMatchesExport || !previewSummaryMatchesFacade) {
    return 'Developer debug preview contract blocked a source summary mismatch.';
  }
  if (source.readableSummaryContainsPublicLabels ||
      source.publicLabel != null) {
    return 'Developer debug preview contract source facade contains public labels.';
  }
  if (source.readableSummaryContainsOfficialMetrics) {
    return 'Developer debug preview contract source facade contains official metrics.';
  }
  if (source.developerReadStatus !=
          AnalyzerDeveloperSnapshotDebugReadStatus.ready ||
      source.developerReadMessage !=
          AnalyzerDeveloperSnapshotDebugReadMessage.developerSnapshotReady) {
    return 'Developer debug preview contract source facade is not ready.';
  }
  if (!sourceSafe) {
    return 'Developer debug preview contract source facade is unsafe.';
  }
  return 'Developer debug preview contract mapping did not succeed.';
}

bool _containsForbiddenPublicString(
  AnalyzerDeveloperSnapshotDebugReadFacade source,
) {
  final values = <String?>[
    source.publicLabel,
    source.officialMoveQuality,
    source.debugFacadeId,
    source.sourceExportContractId,
    source.sourceSnapshotId,
    source.sourceReviewEnvelopeId,
    analyzerDeveloperDebugPreviewContractSource,
    AnalyzerDeveloperDebugPreviewStatus.ready.wire,
    AnalyzerDeveloperDebugPreviewStatus.unavailable.wire,
    AnalyzerDeveloperDebugPreviewMessage.developerPreviewReady.wire,
    AnalyzerDeveloperDebugPreviewMessage.sourceFacadeUnsafe.wire,
    AnalyzerDeveloperDebugPreviewMessage.sourceFacadeUnavailable.wire,
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
