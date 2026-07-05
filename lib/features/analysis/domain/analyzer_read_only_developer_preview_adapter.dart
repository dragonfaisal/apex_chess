import 'dart:convert';

import 'package:apex_chess/features/analysis/domain/analyzer_developer_debug_preview_contract.dart';

const analyzerReadOnlyDeveloperPreviewAdapterSource =
    'phase36PReadOnlyDeveloperPreviewAdapter';
const analyzerReadOnlyDeveloperPreviewAdapterVersion = 'phase36P.v1';
const analyzerReadOnlyDeveloperPreviewAdapterNextRecommendation =
    'implementReadOnlyDeveloperPreviewConsumptionPlan';
const analyzerReadOnlyDeveloperPreviewAdapterFailureRecommendation =
    'fixReadOnlyDeveloperPreviewAdapterBoundary';

enum AnalyzerReadOnlyDeveloperPreviewUnavailableReason {
  none('none'),
  sourceUnsafe('sourceUnsafe'),
  sourceUnavailable('sourceUnavailable');

  const AnalyzerReadOnlyDeveloperPreviewUnavailableReason(this.wire);

  final String wire;
}

class AnalyzerReadOnlyDeveloperPreviewAdapterResult {
  const AnalyzerReadOnlyDeveloperPreviewAdapterResult({
    required this.adapterResultId,
    required this.sourceDebugPreviewContractId,
    required this.adapterSource,
    required this.adapterVersion,
    required this.adapterComputed,
    required this.previewReady,
    required this.previewUnavailableReason,
    required this.totalPrivateEntries,
    required this.positiveCandidateCount,
    required this.neutralCandidateCount,
    required this.negativeCandidateCount,
    required this.unavailableCount,
    required this.adapterIsDeveloperOnly,
    required this.adapterIsReadOnly,
    required this.adapterIsUiOutput,
    required this.adapterIsProductReview,
    required this.adapterIsSavedAnalysis,
    required this.adapterIsPersistenceWrite,
    required this.adapterIsBackendPayload,
    required this.adapterIsArchiveStatsOutput,
    required this.adapterContainsPublicLabels,
    required this.adapterContainsOfficialMetrics,
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
    required this.safeForPhase37A,
    required this.safeForPhase37B,
    required this.nextRecommendation,
  });

  final String adapterResultId;
  final String sourceDebugPreviewContractId;
  final String adapterSource;
  final String adapterVersion;
  final bool adapterComputed;
  final bool previewReady;
  final AnalyzerReadOnlyDeveloperPreviewUnavailableReason
  previewUnavailableReason;
  final int totalPrivateEntries;
  final int positiveCandidateCount;
  final int neutralCandidateCount;
  final int negativeCandidateCount;
  final int unavailableCount;
  final bool adapterIsDeveloperOnly;
  final bool adapterIsReadOnly;
  final bool adapterIsUiOutput;
  final bool adapterIsProductReview;
  final bool adapterIsSavedAnalysis;
  final bool adapterIsPersistenceWrite;
  final bool adapterIsBackendPayload;
  final bool adapterIsArchiveStatsOutput;
  final bool adapterContainsPublicLabels;
  final bool adapterContainsOfficialMetrics;
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
  final bool safeForPhase37A;
  final bool safeForPhase37B;
  final String nextRecommendation;

  Map<String, Object?> toJson() => {
    'adapterResultId': adapterResultId,
    'sourceDebugPreviewContractId': sourceDebugPreviewContractId,
    'adapterSource': adapterSource,
    'adapterVersion': adapterVersion,
    'adapterComputed': adapterComputed,
    'previewReady': previewReady,
    'previewUnavailableReason': previewUnavailableReason.wire,
    'totalPrivateEntries': totalPrivateEntries,
    'positiveCandidateCount': positiveCandidateCount,
    'neutralCandidateCount': neutralCandidateCount,
    'negativeCandidateCount': negativeCandidateCount,
    'unavailableCount': unavailableCount,
    'adapterIsDeveloperOnly': adapterIsDeveloperOnly,
    'adapterIsReadOnly': adapterIsReadOnly,
    'adapterIsUiOutput': adapterIsUiOutput,
    'adapterIsProductReview': adapterIsProductReview,
    'adapterIsSavedAnalysis': adapterIsSavedAnalysis,
    'adapterIsPersistenceWrite': adapterIsPersistenceWrite,
    'adapterIsBackendPayload': adapterIsBackendPayload,
    'adapterIsArchiveStatsOutput': adapterIsArchiveStatsOutput,
    'adapterContainsPublicLabels': adapterContainsPublicLabels,
    'adapterContainsOfficialMetrics': adapterContainsOfficialMetrics,
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
    'persistenceWritePerformed': persistenceWritePerformed,
    'fileWritePerformed': fileWritePerformed,
    'backendPayloadProduced': backendPayloadProduced,
    'archiveStatsTouched': archiveStatsTouched,
    'mappingSucceeded': mappingSucceeded,
    'failureMessage': failureMessage,
    'safeForPhase37A': safeForPhase37A,
    'safeForPhase37B': safeForPhase37B,
    'nextRecommendation': nextRecommendation,
  };

  String renderJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}

AnalyzerReadOnlyDeveloperPreviewAdapterResult
adaptDeveloperDebugPreviewContractToReadOnlyDeveloperPreview(
  AnalyzerDeveloperDebugPreviewContract source,
) {
  const adapterIsDeveloperOnly = true;
  const adapterIsReadOnly = true;
  const adapterIsUiOutput = false;
  const adapterIsProductReview = false;
  const adapterIsSavedAnalysis = false;
  const adapterIsPersistenceWrite = false;
  const adapterIsBackendPayload = false;
  const adapterIsArchiveStatsOutput = false;
  const adapterContainsPublicLabels = false;
  const adapterContainsOfficialMetrics = false;
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
  final adapterComputed =
      sourceSafe &&
      adapterIsDeveloperOnly &&
      adapterIsReadOnly &&
      !adapterIsUiOutput &&
      !adapterIsProductReview &&
      !adapterIsSavedAnalysis &&
      !adapterIsPersistenceWrite &&
      !adapterIsBackendPayload &&
      !adapterIsArchiveStatsOutput &&
      !adapterContainsPublicLabels &&
      !adapterContainsOfficialMetrics;
  final mappingSucceeded =
      adapterComputed &&
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
  final sourceUnavailable = _isUnavailableSource(source);

  return AnalyzerReadOnlyDeveloperPreviewAdapterResult(
    adapterResultId: mappingSucceeded
        ? _adapterResultId(source)
        : 'phase36P:blocked:readOnlyDeveloperPreview',
    sourceDebugPreviewContractId: publicStringsClean
        ? source.debugPreviewContractId
        : 'phase36P:blockedDebugPreviewContract',
    adapterSource: analyzerReadOnlyDeveloperPreviewAdapterSource,
    adapterVersion: analyzerReadOnlyDeveloperPreviewAdapterVersion,
    adapterComputed: adapterComputed,
    previewReady: mappingSucceeded,
    previewUnavailableReason: mappingSucceeded
        ? AnalyzerReadOnlyDeveloperPreviewUnavailableReason.none
        : sourceUnavailable
        ? AnalyzerReadOnlyDeveloperPreviewUnavailableReason.sourceUnavailable
        : AnalyzerReadOnlyDeveloperPreviewUnavailableReason.sourceUnsafe,
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    adapterIsDeveloperOnly: adapterIsDeveloperOnly,
    adapterIsReadOnly: adapterIsReadOnly,
    adapterIsUiOutput: adapterIsUiOutput,
    adapterIsProductReview: adapterIsProductReview,
    adapterIsSavedAnalysis: adapterIsSavedAnalysis,
    adapterIsPersistenceWrite: adapterIsPersistenceWrite,
    adapterIsBackendPayload: adapterIsBackendPayload,
    adapterIsArchiveStatsOutput: adapterIsArchiveStatsOutput,
    adapterContainsPublicLabels: adapterContainsPublicLabels,
    adapterContainsOfficialMetrics: adapterContainsOfficialMetrics,
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
            sourceSafe: sourceSafe,
          ),
    safeForPhase37A: mappingSucceeded,
    safeForPhase37B: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerReadOnlyDeveloperPreviewAdapterNextRecommendation
        : analyzerReadOnlyDeveloperPreviewAdapterFailureRecommendation,
  );
}

bool _isSafeSource(AnalyzerDeveloperDebugPreviewContract source) {
  return source.mappingSucceeded &&
      source.safeForPhase36O &&
      source.sourceDebugFacadeComputed &&
      source.sourceDebugFacadeIsDeveloperOnly &&
      source.sourceDebugFacadeIsReadOnly &&
      !source.sourceDebugFacadeIsPublic &&
      !source.sourceDebugFacadeIsProductFeature &&
      !source.sourceDebugFacadeIsUiOutput &&
      !source.sourceDebugFacadeIsSavedAnalysis &&
      !source.sourceDebugFacadeIsPersistenceWrite &&
      !source.sourceDebugFacadeIsFileWrite &&
      !source.sourceDebugFacadeIsArchiveStatsOutput &&
      !source.sourceDebugFacadeIsBackendPayload &&
      !source.sourceDebugFacadeIsOfficial &&
      source.debugPreviewComputed &&
      source.debugPreviewIsDeveloperOnly &&
      source.debugPreviewIsReadOnly &&
      !source.debugPreviewIsPublic &&
      !source.debugPreviewIsProductFeature &&
      !source.debugPreviewIsUiOutput &&
      !source.debugPreviewIsDebugUi &&
      !source.debugPreviewIsSavedAnalysis &&
      !source.debugPreviewIsPersistenceWrite &&
      !source.debugPreviewIsFileWrite &&
      !source.debugPreviewIsArchiveStatsOutput &&
      !source.debugPreviewIsBackendPayload &&
      !source.debugPreviewIsOfficial &&
      source.previewSummaryMatchesFacade &&
      !source.previewContainsPublicLabels &&
      !source.previewContainsOfficialMetrics &&
      source.developerPreviewStatus ==
          AnalyzerDeveloperDebugPreviewStatus.ready &&
      source.developerPreviewMessage ==
          AnalyzerDeveloperDebugPreviewMessage.developerPreviewReady &&
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

bool _isUnavailableSource(AnalyzerDeveloperDebugPreviewContract source) {
  return !source.mappingSucceeded ||
      !source.safeForPhase36O ||
      !source.debugPreviewComputed ||
      source.developerPreviewStatus !=
          AnalyzerDeveloperDebugPreviewStatus.ready ||
      source.developerPreviewMessage !=
          AnalyzerDeveloperDebugPreviewMessage.developerPreviewReady;
}

String _adapterResultId(AnalyzerDeveloperDebugPreviewContract source) {
  return [
    'phase36P',
    source.debugPreviewContractId,
    'readOnlyDeveloperPreview',
  ].join(':');
}

String _failureMessage({
  required AnalyzerDeveloperDebugPreviewContract source,
  required bool publicStringsClean,
  required bool sourceSafe,
}) {
  if (!publicStringsClean) {
    return 'Read-only developer preview adapter blocked a public label string.';
  }
  if (!source.mappingSucceeded ||
      !source.safeForPhase36O ||
      !source.debugPreviewComputed) {
    return 'Read-only developer preview adapter source contract is unavailable.';
  }
  if (!source.sourceDebugFacadeComputed) {
    return 'Read-only developer preview adapter source facade is unavailable.';
  }
  if (!source.debugPreviewIsDeveloperOnly ||
      !source.sourceDebugFacadeIsDeveloperOnly) {
    return 'Read-only developer preview adapter source is not developer-only.';
  }
  if (!source.debugPreviewIsReadOnly || !source.sourceDebugFacadeIsReadOnly) {
    return 'Read-only developer preview adapter source is not read-only.';
  }
  if (source.debugPreviewIsPublic ||
      source.sourceDebugFacadeIsPublic ||
      source.previewContainsPublicLabels ||
      source.publicLabelComputed ||
      source.publicLabel != null) {
    return 'Read-only developer preview adapter source exposed public label data.';
  }
  if (source.debugPreviewIsProductFeature ||
      source.sourceDebugFacadeIsProductFeature) {
    return 'Read-only developer preview adapter source is a product feature.';
  }
  if (source.debugPreviewIsUiOutput ||
      source.debugPreviewIsDebugUi ||
      source.sourceDebugFacadeIsUiOutput ||
      source.uiOutputProduced) {
    return 'Read-only developer preview adapter source produced UI output.';
  }
  if (source.debugPreviewIsSavedAnalysis ||
      source.sourceDebugFacadeIsSavedAnalysis ||
      source.savedAnalysisWritten) {
    return 'Read-only developer preview adapter source touched saved analysis.';
  }
  if (source.debugPreviewIsPersistenceWrite ||
      source.sourceDebugFacadeIsPersistenceWrite ||
      source.persistenceWritePerformed) {
    return 'Read-only developer preview adapter source performed persistence write.';
  }
  if (source.debugPreviewIsFileWrite ||
      source.sourceDebugFacadeIsFileWrite ||
      source.fileWritePerformed) {
    return 'Read-only developer preview adapter source performed file write.';
  }
  if (source.debugPreviewIsBackendPayload ||
      source.sourceDebugFacadeIsBackendPayload ||
      source.backendPayloadProduced) {
    return 'Read-only developer preview adapter source produced backend payload.';
  }
  if (source.debugPreviewIsArchiveStatsOutput ||
      source.sourceDebugFacadeIsArchiveStatsOutput ||
      source.archiveStatsTouched) {
    return 'Read-only developer preview adapter source touched archive or stats.';
  }
  if (source.debugPreviewIsOfficial ||
      source.sourceDebugFacadeIsOfficial ||
      source.previewContainsOfficialMetrics ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return 'Read-only developer preview adapter source exposed official metric data.';
  }
  if (!source.previewSummaryMatchesFacade) {
    return 'Read-only developer preview adapter source has a summary mismatch.';
  }
  if (source.developerPreviewStatus !=
          AnalyzerDeveloperDebugPreviewStatus.ready ||
      source.developerPreviewMessage !=
          AnalyzerDeveloperDebugPreviewMessage.developerPreviewReady) {
    return 'Read-only developer preview adapter source is not ready.';
  }
  if (!sourceSafe) {
    return 'Read-only developer preview adapter source is unsafe.';
  }
  return 'Read-only developer preview adapter mapping did not succeed.';
}

bool _containsForbiddenPublicString(
  AnalyzerDeveloperDebugPreviewContract source,
) {
  final values = <String?>[
    source.publicLabel,
    source.officialMoveQuality,
    source.debugPreviewContractId,
    source.sourceDebugFacadeId,
    source.sourceExportContractId,
    source.sourceSnapshotId,
    source.sourceReviewEnvelopeId,
    source.debugPreviewSource,
    analyzerReadOnlyDeveloperPreviewAdapterSource,
    AnalyzerReadOnlyDeveloperPreviewUnavailableReason.none.wire,
    AnalyzerReadOnlyDeveloperPreviewUnavailableReason.sourceUnsafe.wire,
    AnalyzerReadOnlyDeveloperPreviewUnavailableReason.sourceUnavailable.wire,
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
