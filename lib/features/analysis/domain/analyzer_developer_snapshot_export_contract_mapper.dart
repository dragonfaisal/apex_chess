import 'package:apex_chess/features/analysis/domain/analyzer_developer_review_envelope_snapshot.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_export_contract.dart';

AnalyzerDeveloperSnapshotExportContract
mapDeveloperReviewEnvelopeSnapshotToExportContract(
  AnalyzerDeveloperReviewEnvelopeSnapshot source,
) {
  const exportContractIsDeveloperOnly = true;
  const exportContractIsInMemoryOnly = true;
  const exportContractIsReadOnly = true;
  const exportContractIsPublic = false;
  const exportContractIsProductFeature = false;
  const exportContractIsSavedAnalysis = false;
  const exportContractIsPersistenceWrite = false;
  const exportContractIsFileWrite = false;
  const exportContractIsUiOutput = false;
  const exportContractIsArchiveStatsOutput = false;
  const exportContractIsBackendPayload = false;
  const exportContractIsOfficial = false;
  const payloadContainsPublicLabels = false;
  const payloadContainsOfficialMetrics = false;
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
  final sourceSafe = _isSafeSnapshot(source);
  final payloadCountsMatchSnapshot =
      source.snapshotCountsMatchSource &&
      source.totalPrivateEntries ==
          source.positiveCandidateCount +
              source.neutralCandidateCount +
              source.negativeCandidateCount +
              source.unavailableCount;
  final exportContractComputed =
      sourceSafe &&
      publicStringsClean &&
      payloadCountsMatchSnapshot &&
      exportContractIsDeveloperOnly &&
      exportContractIsInMemoryOnly &&
      exportContractIsReadOnly &&
      !exportContractIsPublic &&
      !exportContractIsProductFeature &&
      !exportContractIsSavedAnalysis &&
      !exportContractIsPersistenceWrite &&
      !exportContractIsFileWrite &&
      !exportContractIsUiOutput &&
      !exportContractIsArchiveStatsOutput &&
      !exportContractIsBackendPayload &&
      !exportContractIsOfficial &&
      !payloadContainsPublicLabels &&
      !payloadContainsOfficialMetrics;
  final mappingSucceeded =
      exportContractComputed &&
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

  return AnalyzerDeveloperSnapshotExportContract(
    exportContractId: mappingSucceeded
        ? _exportContractId(source)
        : 'phase36J:blocked:entries${source.totalPrivateEntries}',
    sourceSnapshotId: publicStringsClean
        ? source.snapshotId
        : 'phase36J:blockedSnapshot',
    sourceReviewEnvelopeId: publicStringsClean
        ? source.sourceReviewEnvelopeId
        : 'phase36J:blockedReviewEnvelope',
    sourceTimelineCollectionId: publicStringsClean
        ? source.sourceTimelineCollectionId
        : 'phase36J:blockedTimelineCollection',
    sourceReviewSummaryId: publicStringsClean
        ? source.sourceReviewSummaryId
        : 'phase36J:blockedReviewSummary',
    exportContractSource: analyzerDeveloperSnapshotExportContractSource,
    exportContractVersion: analyzerDeveloperSnapshotExportContractVersion,
    sourceSnapshotComputed: source.snapshotComputed,
    sourceSnapshotIsDeveloperOnly: source.snapshotIsDeveloperOnly,
    sourceSnapshotIsReadOnly: source.snapshotIsReadOnly,
    sourceSnapshotIsPublic: source.snapshotIsPublic,
    sourceSnapshotIsProductReview: source.snapshotIsProductReview,
    sourceSnapshotIsSavedAnalysis: source.snapshotIsSavedAnalysis,
    sourceSnapshotIsOfficial: source.snapshotIsOfficial,
    sourceSnapshotIsUiOutput: source.snapshotIsUiOutput,
    sourceSnapshotIsArchiveStatsOutput: source.snapshotIsArchiveStatsOutput,
    sourceSnapshotIsFullGameAnalysis: source.snapshotIsFullGameAnalysis,
    sourceSnapshotIsProductTimeline: source.snapshotIsProductTimeline,
    exportContractComputed: exportContractComputed,
    exportContractIsDeveloperOnly: exportContractIsDeveloperOnly,
    exportContractIsInMemoryOnly: exportContractIsInMemoryOnly,
    exportContractIsReadOnly: exportContractIsReadOnly,
    exportContractIsPublic: exportContractIsPublic,
    exportContractIsProductFeature: exportContractIsProductFeature,
    exportContractIsSavedAnalysis: exportContractIsSavedAnalysis,
    exportContractIsPersistenceWrite: exportContractIsPersistenceWrite,
    exportContractIsFileWrite: exportContractIsFileWrite,
    exportContractIsUiOutput: exportContractIsUiOutput,
    exportContractIsArchiveStatsOutput: exportContractIsArchiveStatsOutput,
    exportContractIsBackendPayload: exportContractIsBackendPayload,
    exportContractIsOfficial: exportContractIsOfficial,
    totalPrivateEntries: source.totalPrivateEntries,
    positiveCandidateCount: source.positiveCandidateCount,
    neutralCandidateCount: source.neutralCandidateCount,
    negativeCandidateCount: source.negativeCandidateCount,
    unavailableCount: source.unavailableCount,
    payloadCountsMatchSnapshot: payloadCountsMatchSnapshot,
    payloadContainsPublicLabels: payloadContainsPublicLabels,
    payloadContainsOfficialMetrics: payloadContainsOfficialMetrics,
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
            payloadCountsMatchSnapshot: payloadCountsMatchSnapshot,
            publicStringsClean: publicStringsClean,
          ),
    safeForPhase36K: mappingSucceeded,
    nextRecommendation: mappingSucceeded
        ? analyzerDeveloperSnapshotExportContractNextRecommendation
        : analyzerDeveloperSnapshotExportContractFailureRecommendation,
  );
}

bool _isSafeSnapshot(AnalyzerDeveloperReviewEnvelopeSnapshot source) {
  return source.mappingSucceeded &&
      source.safeForPhase36I &&
      source.snapshotComputed &&
      source.snapshotIsDeveloperOnly &&
      source.snapshotIsReadOnly &&
      !source.snapshotIsPublic &&
      !source.snapshotIsProductReview &&
      !source.snapshotIsSavedAnalysis &&
      !source.snapshotIsOfficial &&
      !source.snapshotIsUiOutput &&
      !source.snapshotIsArchiveStatsOutput &&
      !source.snapshotIsFullGameAnalysis &&
      !source.snapshotIsProductTimeline &&
      source.sourceReviewEnvelopeComputed &&
      source.sourceReviewEnvelopeIsDeveloperOnly &&
      !source.sourceReviewEnvelopeIsPublic &&
      !source.sourceReviewEnvelopeIsProductReview &&
      !source.sourceReviewEnvelopeIsSavedAnalysis &&
      !source.sourceReviewEnvelopeIsOfficial &&
      !source.sourceReviewEnvelopeIsUiOutput &&
      !source.sourceReviewEnvelopeIsArchiveStatsOutput &&
      !source.sourceReviewEnvelopeIsFullGameAnalysis &&
      !source.sourceReviewEnvelopeIsProductTimeline &&
      source.snapshotCountsMatchSource &&
      !source.snapshotContainsPublicLabels &&
      !source.snapshotContainsOfficialMetrics &&
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
      !source.archiveStatsTouched;
}

String _exportContractId(AnalyzerDeveloperReviewEnvelopeSnapshot source) {
  return ['phase36J', source.snapshotId, 'inMemory'].join(':');
}

String _failureMessage({
  required AnalyzerDeveloperReviewEnvelopeSnapshot source,
  required bool sourceSafe,
  required bool payloadCountsMatchSnapshot,
  required bool publicStringsClean,
}) {
  if (!publicStringsClean) {
    return 'Developer snapshot export contract blocked a public label string.';
  }
  if (!source.mappingSucceeded ||
      !source.safeForPhase36I ||
      !source.snapshotComputed) {
    return 'Developer snapshot export contract source did not succeed.';
  }
  if (!source.snapshotIsDeveloperOnly) {
    return 'Developer snapshot export contract source is not developer-only.';
  }
  if (!source.snapshotIsReadOnly) {
    return 'Developer snapshot export contract source is not read-only.';
  }
  if (source.snapshotIsProductReview) {
    return 'Developer snapshot export contract source is product review output.';
  }
  if (source.snapshotIsSavedAnalysis || source.savedAnalysisWritten) {
    return 'Developer snapshot export contract source touched saved analysis.';
  }
  if (source.snapshotIsUiOutput || source.uiOutputProduced) {
    return 'Developer snapshot export contract source produced UI output.';
  }
  if (source.snapshotIsArchiveStatsOutput || source.archiveStatsTouched) {
    return 'Developer snapshot export contract source touched archive or stats.';
  }
  if (source.snapshotIsFullGameAnalysis || source.snapshotIsProductTimeline) {
    return 'Developer snapshot export contract source exposed full-game or product timeline output.';
  }
  if (source.snapshotIsPublic ||
      source.snapshotContainsPublicLabels ||
      source.publicLabelComputed ||
      source.publicLabel != null) {
    return 'Developer snapshot export contract source exposed public label data.';
  }
  if (source.snapshotIsOfficial ||
      source.snapshotContainsOfficialMetrics ||
      source.officialMoveQualityComputed ||
      source.officialMoveQuality != null ||
      source.officialCpLossComputed ||
      source.officialWinPercentComputed ||
      source.accuracyComputed ||
      source.acplComputed ||
      source.classificationComputed ||
      source.publicClassifierOutputComputed) {
    return 'Developer snapshot export contract source exposed official metric data.';
  }
  if (!payloadCountsMatchSnapshot) {
    return 'Developer snapshot export contract blocked a source count mismatch.';
  }
  if (!sourceSafe) {
    return 'Developer snapshot export contract source is unsafe.';
  }
  return 'Developer snapshot export contract mapping did not succeed.';
}

bool _containsForbiddenPublicString(
  AnalyzerDeveloperReviewEnvelopeSnapshot source,
) {
  final values = <String?>[
    source.publicLabel,
    source.officialMoveQuality,
    source.snapshotId,
    source.sourceReviewEnvelopeId,
    source.sourceTimelineCollectionId,
    source.sourceReviewSummaryId,
    analyzerDeveloperSnapshotExportContractSource,
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
