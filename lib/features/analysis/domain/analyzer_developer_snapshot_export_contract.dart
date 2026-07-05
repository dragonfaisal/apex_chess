import 'dart:convert';

const analyzerDeveloperSnapshotExportContractSource =
    'phase36JDeveloperSnapshotExportContractMapper';
const analyzerDeveloperSnapshotExportContractVersion = 'phase36J.v1';
const analyzerDeveloperSnapshotExportContractNextRecommendation =
    'implementDeveloperOnlySnapshotExportSafetyGoldenCasesWithoutPersistence';
const analyzerDeveloperSnapshotExportContractFailureRecommendation =
    'fixDeveloperSnapshotExportContract';

class AnalyzerDeveloperSnapshotExportContract {
  const AnalyzerDeveloperSnapshotExportContract({
    required this.exportContractId,
    required this.sourceSnapshotId,
    required this.sourceReviewEnvelopeId,
    required this.sourceTimelineCollectionId,
    required this.sourceReviewSummaryId,
    required this.exportContractSource,
    required this.exportContractVersion,
    required this.sourceSnapshotComputed,
    required this.sourceSnapshotIsDeveloperOnly,
    required this.sourceSnapshotIsReadOnly,
    required this.sourceSnapshotIsPublic,
    required this.sourceSnapshotIsProductReview,
    required this.sourceSnapshotIsSavedAnalysis,
    required this.sourceSnapshotIsOfficial,
    required this.sourceSnapshotIsUiOutput,
    required this.sourceSnapshotIsArchiveStatsOutput,
    required this.sourceSnapshotIsFullGameAnalysis,
    required this.sourceSnapshotIsProductTimeline,
    required this.exportContractComputed,
    required this.exportContractIsDeveloperOnly,
    required this.exportContractIsInMemoryOnly,
    required this.exportContractIsReadOnly,
    required this.exportContractIsPublic,
    required this.exportContractIsProductFeature,
    required this.exportContractIsSavedAnalysis,
    required this.exportContractIsPersistenceWrite,
    required this.exportContractIsFileWrite,
    required this.exportContractIsUiOutput,
    required this.exportContractIsArchiveStatsOutput,
    required this.exportContractIsBackendPayload,
    required this.exportContractIsOfficial,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.payloadCountsMatchSnapshot,
    required this.payloadContainsPublicLabels,
    required this.payloadContainsOfficialMetrics,
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
    required this.safeForPhase36K,
    required this.nextRecommendation,
  });

  final String exportContractId;
  final String sourceSnapshotId;
  final String sourceReviewEnvelopeId;
  final String sourceTimelineCollectionId;
  final String sourceReviewSummaryId;
  final String exportContractSource;
  final String exportContractVersion;
  final bool sourceSnapshotComputed;
  final bool sourceSnapshotIsDeveloperOnly;
  final bool sourceSnapshotIsReadOnly;
  final bool sourceSnapshotIsPublic;
  final bool sourceSnapshotIsProductReview;
  final bool sourceSnapshotIsSavedAnalysis;
  final bool sourceSnapshotIsOfficial;
  final bool sourceSnapshotIsUiOutput;
  final bool sourceSnapshotIsArchiveStatsOutput;
  final bool sourceSnapshotIsFullGameAnalysis;
  final bool sourceSnapshotIsProductTimeline;
  final bool exportContractComputed;
  final bool exportContractIsDeveloperOnly;
  final bool exportContractIsInMemoryOnly;
  final bool exportContractIsReadOnly;
  final bool exportContractIsPublic;
  final bool exportContractIsProductFeature;
  final bool exportContractIsSavedAnalysis;
  final bool exportContractIsPersistenceWrite;
  final bool exportContractIsFileWrite;
  final bool exportContractIsUiOutput;
  final bool exportContractIsArchiveStatsOutput;
  final bool exportContractIsBackendPayload;
  final bool exportContractIsOfficial;
  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;
  final bool payloadCountsMatchSnapshot;
  final bool payloadContainsPublicLabels;
  final bool payloadContainsOfficialMetrics;
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
  final bool safeForPhase36K;
  final String nextRecommendation;

  Map<String, Object?> toJson() => {
    'exportContractId': exportContractId,
    'sourceSnapshotId': sourceSnapshotId,
    'sourceReviewEnvelopeId': sourceReviewEnvelopeId,
    'sourceTimelineCollectionId': sourceTimelineCollectionId,
    'sourceReviewSummaryId': sourceReviewSummaryId,
    'exportContractSource': exportContractSource,
    'exportContractVersion': exportContractVersion,
    'sourceSnapshotComputed': sourceSnapshotComputed,
    'sourceSnapshotIsDeveloperOnly': sourceSnapshotIsDeveloperOnly,
    'sourceSnapshotIsReadOnly': sourceSnapshotIsReadOnly,
    'sourceSnapshotIsPublic': sourceSnapshotIsPublic,
    'sourceSnapshotIsProductReview': sourceSnapshotIsProductReview,
    'sourceSnapshotIsSavedAnalysis': sourceSnapshotIsSavedAnalysis,
    'sourceSnapshotIsOfficial': sourceSnapshotIsOfficial,
    'sourceSnapshotIsUiOutput': sourceSnapshotIsUiOutput,
    'sourceSnapshotIsArchiveStatsOutput': sourceSnapshotIsArchiveStatsOutput,
    'sourceSnapshotIsFullGameAnalysis': sourceSnapshotIsFullGameAnalysis,
    'sourceSnapshotIsProductTimeline': sourceSnapshotIsProductTimeline,
    'exportContractComputed': exportContractComputed,
    'exportContractIsDeveloperOnly': exportContractIsDeveloperOnly,
    'exportContractIsInMemoryOnly': exportContractIsInMemoryOnly,
    'exportContractIsReadOnly': exportContractIsReadOnly,
    'exportContractIsPublic': exportContractIsPublic,
    'exportContractIsProductFeature': exportContractIsProductFeature,
    'exportContractIsSavedAnalysis': exportContractIsSavedAnalysis,
    'exportContractIsPersistenceWrite': exportContractIsPersistenceWrite,
    'exportContractIsFileWrite': exportContractIsFileWrite,
    'exportContractIsUiOutput': exportContractIsUiOutput,
    'exportContractIsArchiveStatsOutput': exportContractIsArchiveStatsOutput,
    'exportContractIsBackendPayload': exportContractIsBackendPayload,
    'exportContractIsOfficial': exportContractIsOfficial,
    'totalPrivateEntries': totalPrivateEntries,
    'positiveCandidateCount': positiveCandidateCount,
    'neutralCandidateCount': neutralCandidateCount,
    'negativeCandidateCount': negativeCandidateCount,
    'unavailableCount': unavailableCount,
    'payloadCountsMatchSnapshot': payloadCountsMatchSnapshot,
    'payloadContainsPublicLabels': payloadContainsPublicLabels,
    'payloadContainsOfficialMetrics': payloadContainsOfficialMetrics,
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
    'safeForPhase36K': safeForPhase36K,
    'nextRecommendation': nextRecommendation,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
