import 'dart:convert';

const analyzerDeveloperSnapshotDebugReadFacadeSource =
    'phase36LDeveloperSnapshotDebugReadFacadeMapper';
const analyzerDeveloperSnapshotDebugReadFacadeVersion = 'phase36L.v1';
const analyzerDeveloperSnapshotDebugReadFacadeNextRecommendation =
    'implementDeveloperOnlySnapshotDebugReadFacadeSafetyGoldenCasesWithoutUi';
const analyzerDeveloperSnapshotDebugReadFacadeFailureRecommendation =
    'fixDeveloperSnapshotDebugReadFacade';

enum AnalyzerDeveloperSnapshotDebugReadStatus {
  ready('ready'),
  unavailable('unavailable');

  const AnalyzerDeveloperSnapshotDebugReadStatus(this.wire);

  final String wire;
}

enum AnalyzerDeveloperSnapshotDebugReadMessage {
  developerSnapshotReady('developerSnapshotReady'),
  sourceExportUnsafe('sourceExportUnsafe'),
  sourceExportUnavailable('sourceExportUnavailable');

  const AnalyzerDeveloperSnapshotDebugReadMessage(this.wire);

  final String wire;
}

class AnalyzerDeveloperSnapshotDebugReadFacade {
  const AnalyzerDeveloperSnapshotDebugReadFacade({
    required this.debugFacadeId,
    required this.sourceExportContractId,
    required this.sourceSnapshotId,
    required this.sourceReviewEnvelopeId,
    required this.debugFacadeSource,
    required this.debugFacadeVersion,
    required this.sourceExportContractComputed,
    required this.sourceExportContractIsDeveloperOnly,
    required this.sourceExportContractIsInMemoryOnly,
    required this.sourceExportContractIsReadOnly,
    required this.sourceExportContractIsPublic,
    required this.sourceExportContractIsProductFeature,
    required this.sourceExportContractIsSavedAnalysis,
    required this.sourceExportContractIsPersistenceWrite,
    required this.sourceExportContractIsFileWrite,
    required this.sourceExportContractIsUiOutput,
    required this.sourceExportContractIsArchiveStatsOutput,
    required this.sourceExportContractIsBackendPayload,
    required this.sourceExportContractIsOfficial,
    required this.debugFacadeComputed,
    required this.debugFacadeIsDeveloperOnly,
    required this.debugFacadeIsReadOnly,
    required this.debugFacadeIsPublic,
    required this.debugFacadeIsProductFeature,
    required this.debugFacadeIsUiOutput,
    required this.debugFacadeIsSavedAnalysis,
    required this.debugFacadeIsPersistenceWrite,
    required this.debugFacadeIsFileWrite,
    required this.debugFacadeIsArchiveStatsOutput,
    required this.debugFacadeIsBackendPayload,
    required this.debugFacadeIsOfficial,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.readableSummaryMatchesExport,
    required this.readableSummaryContainsPublicLabels,
    required this.readableSummaryContainsOfficialMetrics,
    required this.developerReadStatus,
    required this.developerReadMessage,
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
    required this.safeForPhase36M,
    required this.nextRecommendation,
  });

  final String debugFacadeId;
  final String sourceExportContractId;
  final String sourceSnapshotId;
  final String sourceReviewEnvelopeId;
  final String debugFacadeSource;
  final String debugFacadeVersion;
  final bool sourceExportContractComputed;
  final bool sourceExportContractIsDeveloperOnly;
  final bool sourceExportContractIsInMemoryOnly;
  final bool sourceExportContractIsReadOnly;
  final bool sourceExportContractIsPublic;
  final bool sourceExportContractIsProductFeature;
  final bool sourceExportContractIsSavedAnalysis;
  final bool sourceExportContractIsPersistenceWrite;
  final bool sourceExportContractIsFileWrite;
  final bool sourceExportContractIsUiOutput;
  final bool sourceExportContractIsArchiveStatsOutput;
  final bool sourceExportContractIsBackendPayload;
  final bool sourceExportContractIsOfficial;
  final bool debugFacadeComputed;
  final bool debugFacadeIsDeveloperOnly;
  final bool debugFacadeIsReadOnly;
  final bool debugFacadeIsPublic;
  final bool debugFacadeIsProductFeature;
  final bool debugFacadeIsUiOutput;
  final bool debugFacadeIsSavedAnalysis;
  final bool debugFacadeIsPersistenceWrite;
  final bool debugFacadeIsFileWrite;
  final bool debugFacadeIsArchiveStatsOutput;
  final bool debugFacadeIsBackendPayload;
  final bool debugFacadeIsOfficial;
  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;
  final bool readableSummaryMatchesExport;
  final bool readableSummaryContainsPublicLabels;
  final bool readableSummaryContainsOfficialMetrics;
  final AnalyzerDeveloperSnapshotDebugReadStatus developerReadStatus;
  final AnalyzerDeveloperSnapshotDebugReadMessage developerReadMessage;
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
  final bool safeForPhase36M;
  final String nextRecommendation;

  Map<String, Object?> toJson() => {
    'debugFacadeId': debugFacadeId,
    'sourceExportContractId': sourceExportContractId,
    'sourceSnapshotId': sourceSnapshotId,
    'sourceReviewEnvelopeId': sourceReviewEnvelopeId,
    'debugFacadeSource': debugFacadeSource,
    'debugFacadeVersion': debugFacadeVersion,
    'sourceExportContractComputed': sourceExportContractComputed,
    'sourceExportContractIsDeveloperOnly': sourceExportContractIsDeveloperOnly,
    'sourceExportContractIsInMemoryOnly': sourceExportContractIsInMemoryOnly,
    'sourceExportContractIsReadOnly': sourceExportContractIsReadOnly,
    'sourceExportContractIsPublic': sourceExportContractIsPublic,
    'sourceExportContractIsProductFeature':
        sourceExportContractIsProductFeature,
    'sourceExportContractIsSavedAnalysis': sourceExportContractIsSavedAnalysis,
    'sourceExportContractIsPersistenceWrite':
        sourceExportContractIsPersistenceWrite,
    'sourceExportContractIsFileWrite': sourceExportContractIsFileWrite,
    'sourceExportContractIsUiOutput': sourceExportContractIsUiOutput,
    'sourceExportContractIsArchiveStatsOutput':
        sourceExportContractIsArchiveStatsOutput,
    'sourceExportContractIsBackendPayload':
        sourceExportContractIsBackendPayload,
    'sourceExportContractIsOfficial': sourceExportContractIsOfficial,
    'debugFacadeComputed': debugFacadeComputed,
    'debugFacadeIsDeveloperOnly': debugFacadeIsDeveloperOnly,
    'debugFacadeIsReadOnly': debugFacadeIsReadOnly,
    'debugFacadeIsPublic': debugFacadeIsPublic,
    'debugFacadeIsProductFeature': debugFacadeIsProductFeature,
    'debugFacadeIsUiOutput': debugFacadeIsUiOutput,
    'debugFacadeIsSavedAnalysis': debugFacadeIsSavedAnalysis,
    'debugFacadeIsPersistenceWrite': debugFacadeIsPersistenceWrite,
    'debugFacadeIsFileWrite': debugFacadeIsFileWrite,
    'debugFacadeIsArchiveStatsOutput': debugFacadeIsArchiveStatsOutput,
    'debugFacadeIsBackendPayload': debugFacadeIsBackendPayload,
    'debugFacadeIsOfficial': debugFacadeIsOfficial,
    'totalPrivateEntries': totalPrivateEntries,
    'positiveCandidateCount': positiveCandidateCount,
    'neutralCandidateCount': neutralCandidateCount,
    'negativeCandidateCount': negativeCandidateCount,
    'unavailableCount': unavailableCount,
    'readableSummaryMatchesExport': readableSummaryMatchesExport,
    'readableSummaryContainsPublicLabels': readableSummaryContainsPublicLabels,
    'readableSummaryContainsOfficialMetrics':
        readableSummaryContainsOfficialMetrics,
    'developerReadStatus': developerReadStatus.wire,
    'developerReadMessage': developerReadMessage.wire,
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
    'safeForPhase36M': safeForPhase36M,
    'nextRecommendation': nextRecommendation,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
