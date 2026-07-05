import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_debug_read_facade.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_export_contract.dart';

AnalyzerDeveloperSnapshotDebugReadFacade
mapDeveloperSnapshotExportContractToDebugReadFacade(
  AnalyzerDeveloperSnapshotExportContract source,
) {
  const debugFacadeIsDeveloperOnly = true;
  const debugFacadeIsReadOnly = true;
  const debugFacadeIsPublic = false;
  const debugFacadeIsProductFeature = false;
  const debugFacadeIsUiOutput = false;
  const debugFacadeIsSavedAnalysis = false;
  const debugFacadeIsPersistenceWrite = false;
  const debugFacadeIsFileWrite = false;
  const debugFacadeIsArchiveStatsOutput = false;
  const debugFacadeIsBackendPayload = false;
  const debugFacadeIsOfficial = false;
  const readableSummaryContainsPublicLabels = false;
  const readableSummaryContainsOfficialMetrics = false;
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
  final sourceSafe = _isSafeExportContract(source);
  final readableSummaryMatchesExport =
      source.payloadCountsMatchSnapshot &&
      source.totalPrivateEntries ==
          source.positiveCandidateCount +
              source.neutralCandidateCount +
              source.negativeCandidateCount +
              source.unavailableCount;
  final debugFacadeComputed =
      sourceSafe &&
      publicStringsClean &&
      readableSummaryMatchesExport &&
      debugFacadeIsDeveloperOnly &&
      debugFacadeIsReadOnly &&
      !debugFacadeIsPublic &&
      !debugFacadeIsProductFeature &&
      !debugFacadeIsUiOutput &&
      !debugFacadeIsSavedAnalysis &&
      !debugFacadeIsPersistenceWrite &&
      !debugFacadeIsFileWrite &&
      !debugFacadeIsArchiveStatsOutput &&
      !debugFacadeIsBackendPayload &&
      !debugFacadeIsOfficial &&
      !readableSummaryContainsPublicLabels &&
      !readableSummaryContainsOfficialMetrics;
  final mappingSucceeded =
      debugFacadeComputed &&
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
      !source.safeForPhase36K ||
      !source.exportContractComputed;

  return AnalyzerDeveloperSnapshotDebugReadFacade(
    debugFacadeId: mappingSucceeded
        ? _debugFacadeId(source)
        : 'phase36L:blocked:entries${source.totalPrivateEntries}',
    sourceExportContractId: publicStringsClean
        ? source.exportContractId
        : 'phase36L:blockedExportContract',
    sourceSnapshotId: publicStringsClean
        ? source.sourceSnapshotId
        : 'phase36L:blockedSnapshot',
    sourceReviewEnvelopeId: publicStringsClean
        ? source.sourceReviewEnvelopeId
        : 'phase36L:blockedReviewEnvelope',
    debugFacadeSource: analyzerDeveloperSnapshotDebugReadFacadeSource,
    debugFacadeVersion: analyzerDeveloperSnapshotDebugReadFacadeVersion,
    sourceExportContractComputed: source.exportContractComputed,
    sourceExportContractIsDeveloperOnly: source.exportContractIsDeveloperOnly,
    sourceExportContractIsInMemoryOnly: source.exportContractIsInMemoryOnly,
    sourceExportContractIsReadOnly: source.exportContractIsReadOnly,
    sourceExportContractIsPublic: source.exportContractIsPublic,
    sourceExportContractIsProductFeature: source.exportContractIsProductFeature,
    sourceExportContractIsSavedAnalysis: source.exportContractIsSavedAnalysis,
    sourceExportContractIsPersistenceWrite:
        source.exportContractIsPersistenceWrite,
    sourceExportContractIsFileWrite: source.exportContractIsFileWrite,
    sourceExportContractIsUiOutput: source.exportContractIsUiOutput,
    sourceExportContractIsArchiveStatsOutput:
        source.exportContractIsArchiveStatsOutput,
    sourceExportContractIsBackendPayload: source.exportContractIsBackendPayload,
    sourceExportContractIsOfficial: source.exportContractIsOfficial,
    debugFacadeComputed: debugFacadeComputed,
    debugFacadeIsDeveloperOnly: debugFacadeIsDeveloperOnly,
    debugFacadeIsReadOnly: debugFacadeIsReadOnly,
    debugFacadeIsPublic: debugFacadeIsPublic,
    debugFacadeIsProductFeature: debugFacadeIsProductFeature,
    debugFacadeIsUiOutput: debugFacadeIsUiOutput,
    debugFacadeIsSavedAnalysis: debugFacadeIsSavedAnalysis,
    debugFacadeIsPersistenceWrite: debugFacadeIsPersistenceWrite,
    debugFacadeIsFileWrite: debugFacadeIsFileWrite,
    debugFacadeIsArchiveStatsOutput: debugFacadeIsArchiveStatsOutput,
    debugFacadeIsBackendPayload: debugFacadeIsBackendPayload,
    debugFacadeIsOfficial: debugFacadeIsOfficial,
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    readableSummaryMatchesExport: readableSummaryMatchesExport,
    readableSummaryContainsPublicLabels: readableSummaryContainsPublicLabels,
    readableSummaryContainsOfficialMetrics:
        readableSummaryContainsOfficialMetrics,
    developerReadStatus: mappingSucceeded
        ? AnalyzerDeveloperSnapshotDebugReadStatus.ready
        : AnalyzerDeveloperSnapshotDebugReadStatus.unavailable,
    developerReadMessage: mappingSucceeded
        ? AnalyzerDeveloperSnapshotDebugReadMessage.developerSnapshotReady
        : sourceUnavailable
        ? AnalyzerDeveloperSnapshotDebugReadMessage.sourceExportUnavailable
        : AnalyzerDeveloperSnapshotDebugReadMessage.sourceExportUnsafe,
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
            readableSummaryMatchesExport: readableSummaryMatchesExport,
            publicStringsClean: publicStringsClean,
          ),
    safeForPhase36M: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerDeveloperSnapshotDebugReadFacadeNextRecommendation
        : analyzerDeveloperSnapshotDebugReadFacadeFailureRecommendation,
  );
}

bool _isSafeExportContract(AnalyzerDeveloperSnapshotExportContract source) {
  return source.mappingSucceeded &&
      source.safeForPhase36K &&
      source.exportContractComputed &&
      source.exportContractIsDeveloperOnly &&
      source.exportContractIsInMemoryOnly &&
      source.exportContractIsReadOnly &&
      !source.exportContractIsPublic &&
      !source.exportContractIsProductFeature &&
      !source.exportContractIsSavedAnalysis &&
      !source.exportContractIsPersistenceWrite &&
      !source.exportContractIsFileWrite &&
      !source.exportContractIsUiOutput &&
      !source.exportContractIsArchiveStatsOutput &&
      !source.exportContractIsBackendPayload &&
      !source.exportContractIsOfficial &&
      source.sourceSnapshotComputed &&
      source.sourceSnapshotIsDeveloperOnly &&
      source.sourceSnapshotIsReadOnly &&
      !source.sourceSnapshotIsPublic &&
      !source.sourceSnapshotIsProductReview &&
      !source.sourceSnapshotIsSavedAnalysis &&
      !source.sourceSnapshotIsOfficial &&
      !source.sourceSnapshotIsUiOutput &&
      !source.sourceSnapshotIsArchiveStatsOutput &&
      !source.sourceSnapshotIsFullGameAnalysis &&
      !source.sourceSnapshotIsProductTimeline &&
      source.payloadCountsMatchSnapshot &&
      !source.payloadContainsPublicLabels &&
      !source.payloadContainsOfficialMetrics &&
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

String _debugFacadeId(AnalyzerDeveloperSnapshotExportContract source) {
  return ['phase36L', source.exportContractId, 'debugRead'].join(':');
}

String _failureMessage({
  required AnalyzerDeveloperSnapshotExportContract source,
  required bool sourceSafe,
  required bool readableSummaryMatchesExport,
  required bool publicStringsClean,
}) {
  if (!publicStringsClean) {
    return 'Developer snapshot debug read facade blocked a public label string.';
  }
  if (!source.mappingSucceeded ||
      !source.safeForPhase36K ||
      !source.exportContractComputed) {
    return 'Developer snapshot debug read facade source export is unavailable.';
  }
  if (!source.exportContractIsDeveloperOnly) {
    return 'Developer snapshot debug read facade source export is not developer-only.';
  }
  if (!source.exportContractIsInMemoryOnly) {
    return 'Developer snapshot debug read facade source export is not in-memory-only.';
  }
  if (!source.exportContractIsReadOnly) {
    return 'Developer snapshot debug read facade source export is not read-only.';
  }
  if (source.exportContractIsPublic || source.publicLabelComputed) {
    return 'Developer snapshot debug read facade source export exposed public label data.';
  }
  if (source.exportContractIsProductFeature) {
    return 'Developer snapshot debug read facade source export is a product feature.';
  }
  if (source.exportContractIsSavedAnalysis || source.savedAnalysisWritten) {
    return 'Developer snapshot debug read facade source export touched saved analysis.';
  }
  if (source.exportContractIsPersistenceWrite ||
      source.persistenceWritePerformed) {
    return 'Developer snapshot debug read facade source export performed persistence write.';
  }
  if (source.exportContractIsFileWrite || source.fileWritePerformed) {
    return 'Developer snapshot debug read facade source export performed file write.';
  }
  if (source.exportContractIsUiOutput || source.uiOutputProduced) {
    return 'Developer snapshot debug read facade source export produced UI output.';
  }
  if (source.exportContractIsArchiveStatsOutput || source.archiveStatsTouched) {
    return 'Developer snapshot debug read facade source export touched archive or stats.';
  }
  if (source.exportContractIsBackendPayload || source.backendPayloadProduced) {
    return 'Developer snapshot debug read facade source export produced backend payload.';
  }
  if (source.exportContractIsOfficial ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return 'Developer snapshot debug read facade source export exposed official metric data.';
  }
  if (!source.payloadCountsMatchSnapshot || !readableSummaryMatchesExport) {
    return 'Developer snapshot debug read facade blocked a source count mismatch.';
  }
  if (source.payloadContainsPublicLabels || source.publicLabel != null) {
    return 'Developer snapshot debug read facade source export contains public labels.';
  }
  if (source.payloadContainsOfficialMetrics) {
    return 'Developer snapshot debug read facade source export contains official metrics.';
  }
  if (!sourceSafe) {
    return 'Developer snapshot debug read facade source export is unsafe.';
  }
  return 'Developer snapshot debug read facade mapping did not succeed.';
}

bool _containsForbiddenPublicString(
  AnalyzerDeveloperSnapshotExportContract source,
) {
  final values = <String?>[
    source.publicLabel,
    source.officialMoveQuality,
    source.exportContractId,
    source.sourceSnapshotId,
    source.sourceReviewEnvelopeId,
    analyzerDeveloperSnapshotDebugReadFacadeSource,
    AnalyzerDeveloperSnapshotDebugReadStatus.ready.wire,
    AnalyzerDeveloperSnapshotDebugReadStatus.unavailable.wire,
    AnalyzerDeveloperSnapshotDebugReadMessage.developerSnapshotReady.wire,
    AnalyzerDeveloperSnapshotDebugReadMessage.sourceExportUnsafe.wire,
    AnalyzerDeveloperSnapshotDebugReadMessage.sourceExportUnavailable.wire,
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
