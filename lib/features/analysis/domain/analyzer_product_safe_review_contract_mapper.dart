import 'package:apex_chess/features/analysis/domain/analyzer_non_ui_developer_preview_consumer.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';

AnalyzerProductSafeReviewContract mapProductSafeReviewContractFromConsumer(
  AnalyzerNonUiDeveloperPreviewConsumerResult source,
) {
  const contractIsReadOnly = true;
  const contractIsUiOutput = false;
  const contractIsProductUi = false;
  const contractIsSavedAnalysis = false;
  const contractIsPersistenceWrite = false;
  const contractIsFileWrite = false;
  const contractIsBackendPayload = false;
  const contractIsArchiveStatsOutput = false;
  const contractContainsPublicLabels = false;
  const contractContainsOfficialMetrics = false;
  const contractContainsUiPresentation = false;
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

  final publicStringsClean = !_containsForbiddenContractString(source);
  final scopeSupported = _sourceScopeSupported(source);
  final sourceSafe = _isSafeSource(source) && publicStringsClean;
  final contractComputed =
      sourceSafe &&
      scopeSupported &&
      contractIsReadOnly &&
      !contractIsUiOutput &&
      !contractIsProductUi &&
      !contractIsSavedAnalysis &&
      !contractIsPersistenceWrite &&
      !contractIsFileWrite &&
      !contractIsBackendPayload &&
      !contractIsArchiveStatsOutput &&
      !contractContainsPublicLabels &&
      !contractContainsOfficialMetrics &&
      !contractContainsUiPresentation;
  final mappingSucceeded =
      contractComputed &&
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

  return AnalyzerProductSafeReviewContract(
    productSafeReviewContractId: mappingSucceeded
        ? _contractId(source)
        : 'phase38B:blocked:productSafeReviewContract',
    sourceConsumerResultId: publicStringsClean
        ? source.consumerResultId
        : 'phase38B:blockedConsumerResult',
    contractSource: analyzerProductSafeReviewContractSource,
    contractVersion: analyzerProductSafeReviewContractVersion,
    contractComputed: contractComputed,
    reviewReady: mappingSucceeded,
    reviewUnavailableReason: mappingSucceeded
        ? AnalyzerProductSafeReviewUnavailableReason.none
        : _blockedReason(source, scopeSupported: scopeSupported),
    reviewScope: AnalyzerProductSafeReviewScope.singleMoveControlled,
    requestedDepth: 1,
    evidenceStrength: mappingSucceeded
        ? AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly
        : AnalyzerProductSafeReviewEvidenceStrength.productSafePending,
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    privateCountsAreInternalOnly: mappingSucceeded,
    contractIsProductSafe: mappingSucceeded,
    contractIsDeveloperEvidenceBacked: mappingSucceeded,
    contractIsReadOnly: contractIsReadOnly,
    contractIsUiOutput: contractIsUiOutput,
    contractIsProductUi: contractIsProductUi,
    contractIsSavedAnalysis: contractIsSavedAnalysis,
    contractIsPersistenceWrite: contractIsPersistenceWrite,
    contractIsFileWrite: contractIsFileWrite,
    contractIsBackendPayload: contractIsBackendPayload,
    contractIsArchiveStatsOutput: contractIsArchiveStatsOutput,
    contractContainsPublicLabels: contractContainsPublicLabels,
    contractContainsOfficialMetrics: contractContainsOfficialMetrics,
    contractContainsUiPresentation: contractContainsUiPresentation,
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
            scopeSupported: scopeSupported,
          ),
    safeForPhase38C: mappingSucceeded,
    safeForPhase38D: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerProductSafeReviewContractNextRecommendation
        : analyzerProductSafeReviewContractFailureRecommendation,
  );
}

bool _isSafeSource(AnalyzerNonUiDeveloperPreviewConsumerResult source) {
  return source.mappingSucceeded &&
      source.consumerComputed &&
      source.consumerReady &&
      source.consumerUnavailableReason ==
          AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason.none &&
      source.consumerIsDeveloperOnly &&
      source.consumerIsReadOnly &&
      !source.consumerIsUiOutput &&
      !source.consumerIsDebugUi &&
      !source.consumerIsProductReview &&
      !source.consumerIsSavedAnalysis &&
      !source.consumerIsPersistenceWrite &&
      !source.consumerIsFileWrite &&
      !source.consumerIsBackendPayload &&
      !source.consumerIsArchiveStatsOutput &&
      !source.consumerContainsPublicLabels &&
      !source.consumerContainsOfficialMetrics &&
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
      source.safeForPhase37D &&
      source.safeForPhase37E;
}

bool _sourceScopeSupported(AnalyzerNonUiDeveloperPreviewConsumerResult source) {
  if (source.totalPrivateEntries < 0 ||
      source.positiveCandidateCount < 0 ||
      source.neutralCandidateCount < 0 ||
      source.negativeCandidateCount < 0 ||
      source.unavailableCount < 0) {
    return false;
  }
  return source.totalPrivateEntries ==
      source.positiveCandidateCount +
          source.neutralCandidateCount +
          source.negativeCandidateCount +
          source.unavailableCount;
}

AnalyzerProductSafeReviewUnavailableReason _blockedReason(
  AnalyzerNonUiDeveloperPreviewConsumerResult source, {
  required bool scopeSupported,
}) {
  if (!scopeSupported) {
    return AnalyzerProductSafeReviewUnavailableReason.unsupportedScope;
  }
  if (source.consumerUnavailableReason ==
      AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason
          .sourceUnavailable) {
    return AnalyzerProductSafeReviewUnavailableReason.sourceUnavailable;
  }
  if (!source.mappingSucceeded ||
      !source.consumerComputed ||
      !source.consumerReady ||
      !source.safeForPhase37E) {
    return source.consumerUnavailableReason ==
            AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason.sourceUnsafe
        ? AnalyzerProductSafeReviewUnavailableReason.sourceUnsafe
        : AnalyzerProductSafeReviewUnavailableReason.sourceUnavailable;
  }
  return AnalyzerProductSafeReviewUnavailableReason.sourceUnsafe;
}

String _contractId(AnalyzerNonUiDeveloperPreviewConsumerResult source) {
  return ['phase38B', source.consumerResultId, 'productSafeReview'].join(':');
}

String _failureMessage({
  required AnalyzerNonUiDeveloperPreviewConsumerResult source,
  required bool publicStringsClean,
  required bool scopeSupported,
}) {
  if (!scopeSupported) {
    return 'Product-safe review contract blocked unsupported source scope.';
  }
  if (!publicStringsClean ||
      source.consumerContainsPublicLabels ||
      source.publicLabelComputed ||
      source.publicLabel != null) {
    return 'Product-safe review contract blocked public label data.';
  }
  if (!source.mappingSucceeded ||
      !source.consumerComputed ||
      !source.consumerReady ||
      source.consumerUnavailableReason !=
          AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason.none ||
      !source.safeForPhase37E) {
    return 'Product-safe review contract source consumer is unavailable.';
  }
  if (!source.consumerIsDeveloperOnly) {
    return 'Product-safe review contract source is not developer evidence.';
  }
  if (!source.consumerIsReadOnly) {
    return 'Product-safe review contract source is not read-only.';
  }
  if (source.consumerIsUiOutput ||
      source.consumerIsDebugUi ||
      source.uiOutputProduced) {
    return 'Product-safe review contract source produced UI output.';
  }
  if (source.consumerIsProductReview) {
    return 'Product-safe review contract source is product review output.';
  }
  if (source.consumerIsSavedAnalysis || source.savedAnalysisWritten) {
    return 'Product-safe review contract source touched saved analysis.';
  }
  if (source.consumerIsPersistenceWrite ||
      source.persistenceWritePerformed ||
      source.fileWritePerformed) {
    return 'Product-safe review contract source performed writes.';
  }
  if (source.consumerIsBackendPayload || source.backendPayloadProduced) {
    return 'Product-safe review contract source produced backend output.';
  }
  if (source.consumerIsArchiveStatsOutput || source.archiveStatsTouched) {
    return 'Product-safe review contract source touched archive or stats.';
  }
  if (source.consumerContainsOfficialMetrics ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return 'Product-safe review contract blocked official metric data.';
  }
  return 'Product-safe review contract source consumer is unsafe.';
}

bool _containsForbiddenContractString(
  AnalyzerNonUiDeveloperPreviewConsumerResult source,
) {
  final values = <String?>[
    source.consumerResultId,
    source.sourceAdapterResultId,
    source.consumerSource,
    source.publicLabel,
    source.officialMoveQuality,
    source.consumerUnavailableReason.wire,
    source.nextRecommendation,
  ].whereType<String>();
  return values.any(_containsForbiddenOutputString);
}

bool _containsForbiddenOutputString(String value) {
  return _forbiddenOutputStrings.any(value.contains);
}

const _forbiddenOutputStrings = <String>{
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
  'MoveQuality',
  'savedAnalysisId',
  'archiveId',
  'badge',
  'icon',
  'color',
  'route',
  'endpoint',
  'payload',
  'explanation',
  'coach',
  'raw UCI',
  'raw PV',
  'stdout',
  'stderr',
};
