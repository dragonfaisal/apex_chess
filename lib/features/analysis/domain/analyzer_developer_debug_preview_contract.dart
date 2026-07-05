import 'dart:convert';

const analyzerDeveloperDebugPreviewContractSource =
    'phase36NDeveloperDebugPreviewContractMapper';
const analyzerDeveloperDebugPreviewContractVersion = 'phase36N.v1';
const analyzerDeveloperDebugPreviewContractNextRecommendation =
    'implementDeveloperOnlyDebugPreviewSafetyGoldenCasesWithoutUi';
const analyzerDeveloperDebugPreviewContractFailureRecommendation =
    'fixDeveloperDebugPreviewContract';

enum AnalyzerDeveloperDebugPreviewStatus {
  ready('ready'),
  unavailable('unavailable');

  const AnalyzerDeveloperDebugPreviewStatus(this.wire);

  final String wire;
}

enum AnalyzerDeveloperDebugPreviewMessage {
  developerPreviewReady('developerPreviewReady'),
  sourceFacadeUnsafe('sourceFacadeUnsafe'),
  sourceFacadeUnavailable('sourceFacadeUnavailable');

  const AnalyzerDeveloperDebugPreviewMessage(this.wire);

  final String wire;
}

class AnalyzerDeveloperDebugPreviewContract {
  const AnalyzerDeveloperDebugPreviewContract({
    required this.debugPreviewContractId,
    required this.sourceDebugFacadeId,
    required this.sourceExportContractId,
    required this.sourceSnapshotId,
    required this.sourceReviewEnvelopeId,
    required this.debugPreviewSource,
    required this.debugPreviewVersion,
    required this.sourceDebugFacadeComputed,
    required this.sourceDebugFacadeIsDeveloperOnly,
    required this.sourceDebugFacadeIsReadOnly,
    required this.sourceDebugFacadeIsPublic,
    required this.sourceDebugFacadeIsProductFeature,
    required this.sourceDebugFacadeIsUiOutput,
    required this.sourceDebugFacadeIsSavedAnalysis,
    required this.sourceDebugFacadeIsPersistenceWrite,
    required this.sourceDebugFacadeIsFileWrite,
    required this.sourceDebugFacadeIsArchiveStatsOutput,
    required this.sourceDebugFacadeIsBackendPayload,
    required this.sourceDebugFacadeIsOfficial,
    required this.debugPreviewComputed,
    required this.debugPreviewIsDeveloperOnly,
    required this.debugPreviewIsReadOnly,
    required this.debugPreviewIsPublic,
    required this.debugPreviewIsProductFeature,
    required this.debugPreviewIsUiOutput,
    required this.debugPreviewIsDebugUi,
    required this.debugPreviewIsSavedAnalysis,
    required this.debugPreviewIsPersistenceWrite,
    required this.debugPreviewIsFileWrite,
    required this.debugPreviewIsArchiveStatsOutput,
    required this.debugPreviewIsBackendPayload,
    required this.debugPreviewIsOfficial,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.previewSummaryMatchesFacade,
    required this.previewContainsPublicLabels,
    required this.previewContainsOfficialMetrics,
    required this.developerPreviewStatus,
    required this.developerPreviewMessage,
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
    required this.persistenceWritePerformed,
    required this.fileWritePerformed,
    required this.backendPayloadProduced,
    required this.mappingSucceeded,
    required this.failureMessage,
    required this.safeForPhase36O,
    required this.nextRecommendation,
  });

  final String debugPreviewContractId;
  final String sourceDebugFacadeId;
  final String sourceExportContractId;
  final String sourceSnapshotId;
  final String sourceReviewEnvelopeId;
  final String debugPreviewSource;
  final String debugPreviewVersion;
  final bool sourceDebugFacadeComputed;
  final bool sourceDebugFacadeIsDeveloperOnly;
  final bool sourceDebugFacadeIsReadOnly;
  final bool sourceDebugFacadeIsPublic;
  final bool sourceDebugFacadeIsProductFeature;
  final bool sourceDebugFacadeIsUiOutput;
  final bool sourceDebugFacadeIsSavedAnalysis;
  final bool sourceDebugFacadeIsPersistenceWrite;
  final bool sourceDebugFacadeIsFileWrite;
  final bool sourceDebugFacadeIsArchiveStatsOutput;
  final bool sourceDebugFacadeIsBackendPayload;
  final bool sourceDebugFacadeIsOfficial;
  final bool debugPreviewComputed;
  final bool debugPreviewIsDeveloperOnly;
  final bool debugPreviewIsReadOnly;
  final bool debugPreviewIsPublic;
  final bool debugPreviewIsProductFeature;
  final bool debugPreviewIsUiOutput;
  final bool debugPreviewIsDebugUi;
  final bool debugPreviewIsSavedAnalysis;
  final bool debugPreviewIsPersistenceWrite;
  final bool debugPreviewIsFileWrite;
  final bool debugPreviewIsArchiveStatsOutput;
  final bool debugPreviewIsBackendPayload;
  final bool debugPreviewIsOfficial;
  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;
  final bool previewSummaryMatchesFacade;
  final bool previewContainsPublicLabels;
  final bool previewContainsOfficialMetrics;
  final AnalyzerDeveloperDebugPreviewStatus developerPreviewStatus;
  final AnalyzerDeveloperDebugPreviewMessage developerPreviewMessage;
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
  final bool persistenceWritePerformed;
  final bool fileWritePerformed;
  final bool backendPayloadProduced;
  final bool mappingSucceeded;
  final String? failureMessage;
  final bool safeForPhase36O;
  final String nextRecommendation;

  Map<String, Object?> toJson() => {
    'debugPreviewContractId': debugPreviewContractId,
    'sourceDebugFacadeId': sourceDebugFacadeId,
    'sourceExportContractId': sourceExportContractId,
    'sourceSnapshotId': sourceSnapshotId,
    'sourceReviewEnvelopeId': sourceReviewEnvelopeId,
    'debugPreviewSource': debugPreviewSource,
    'debugPreviewVersion': debugPreviewVersion,
    'sourceDebugFacadeComputed': sourceDebugFacadeComputed,
    'sourceDebugFacadeIsDeveloperOnly': sourceDebugFacadeIsDeveloperOnly,
    'sourceDebugFacadeIsReadOnly': sourceDebugFacadeIsReadOnly,
    'sourceDebugFacadeIsPublic': sourceDebugFacadeIsPublic,
    'sourceDebugFacadeIsProductFeature': sourceDebugFacadeIsProductFeature,
    'sourceDebugFacadeIsUiOutput': sourceDebugFacadeIsUiOutput,
    'sourceDebugFacadeIsSavedAnalysis': sourceDebugFacadeIsSavedAnalysis,
    'sourceDebugFacadeIsPersistenceWrite': sourceDebugFacadeIsPersistenceWrite,
    'sourceDebugFacadeIsFileWrite': sourceDebugFacadeIsFileWrite,
    'sourceDebugFacadeIsArchiveStatsOutput':
        sourceDebugFacadeIsArchiveStatsOutput,
    'sourceDebugFacadeIsBackendPayload': sourceDebugFacadeIsBackendPayload,
    'sourceDebugFacadeIsOfficial': sourceDebugFacadeIsOfficial,
    'debugPreviewComputed': debugPreviewComputed,
    'debugPreviewIsDeveloperOnly': debugPreviewIsDeveloperOnly,
    'debugPreviewIsReadOnly': debugPreviewIsReadOnly,
    'debugPreviewIsPublic': debugPreviewIsPublic,
    'debugPreviewIsProductFeature': debugPreviewIsProductFeature,
    'debugPreviewIsUiOutput': debugPreviewIsUiOutput,
    'debugPreviewIsDebugUi': debugPreviewIsDebugUi,
    'debugPreviewIsSavedAnalysis': debugPreviewIsSavedAnalysis,
    'debugPreviewIsPersistenceWrite': debugPreviewIsPersistenceWrite,
    'debugPreviewIsFileWrite': debugPreviewIsFileWrite,
    'debugPreviewIsArchiveStatsOutput': debugPreviewIsArchiveStatsOutput,
    'debugPreviewIsBackendPayload': debugPreviewIsBackendPayload,
    'debugPreviewIsOfficial': debugPreviewIsOfficial,
    'totalPrivateEntries': totalPrivateEntries,
    'positiveCandidateCount': positiveCandidateCount,
    'neutralCandidateCount': neutralCandidateCount,
    'negativeCandidateCount': negativeCandidateCount,
    'unavailableCount': unavailableCount,
    'previewSummaryMatchesFacade': previewSummaryMatchesFacade,
    'previewContainsPublicLabels': previewContainsPublicLabels,
    'previewContainsOfficialMetrics': previewContainsOfficialMetrics,
    'developerPreviewStatus': developerPreviewStatus.wire,
    'developerPreviewMessage': developerPreviewMessage.wire,
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
    'persistenceWritePerformed': persistenceWritePerformed,
    'fileWritePerformed': fileWritePerformed,
    'backendPayloadProduced': backendPayloadProduced,
    'mappingSucceeded': mappingSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase36O': safeForPhase36O,
    'nextRecommendation': nextRecommendation,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
