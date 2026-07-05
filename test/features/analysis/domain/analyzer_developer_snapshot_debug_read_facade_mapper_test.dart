import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_debug_read_facade.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_debug_read_facade_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_export_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapDeveloperSnapshotExportContractToDebugReadFacade', () {
    test('facade mapping succeeds with valid fake export contract', () {
      final result = _map(_export());

      expect(result.mappingSucceeded, isTrue);
      expect(result.debugFacadeComputed, isTrue);
      expect(result.safeForPhase36M, isTrue);
      expect(result.developerReadStatus.wire, 'ready');
      expect(result.developerReadMessage.wire, 'developerSnapshotReady');
      expect(
        result.nextRecommendation,
        analyzerDeveloperSnapshotDebugReadFacadeNextRecommendation,
      );
    });

    test('facade copies safe IDs from export', () {
      final source = _export(
        exportContractId: 'phase36J:phase36H:safe:inMemory',
        sourceSnapshotId: 'phase36H:safe-snapshot',
        sourceReviewEnvelopeId: 'phase36F:safe-envelope',
      );
      final result = _map(source);

      expect(result.mappingSucceeded, isTrue);
      expect(result.sourceExportContractId, source.exportContractId);
      expect(result.sourceSnapshotId, source.sourceSnapshotId);
      expect(result.sourceReviewEnvelopeId, source.sourceReviewEnvelopeId);
    });

    test('facade copies safe private counts from export', () {
      final source = _export(
        totalPrivateEntries: 4,
        positiveCandidateCount: 1,
        neutralCandidateCount: 1,
        negativeCandidateCount: 1,
        unavailableCount: 1,
      );
      final result = _map(source);

      expect(result.mappingSucceeded, isTrue);
      expect(result.totalPrivateEntries, 4);
      expect(result.positiveCandidateCount, 1);
      expect(result.neutralCandidateCount, 1);
      expect(result.negativeCandidateCount, 1);
      expect(result.unavailableCount, 1);
      expect(result.readableSummaryMatchesExport, isTrue);
    });

    test('facade fails closed if export is public', () {
      final result = _map(_export(exportContractIsPublic: true));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsPublic, isTrue);
    });

    test('facade fails closed if export is official', () {
      final result = _map(_export(exportContractIsOfficial: true));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsOfficial, isTrue);
    });

    test('facade fails closed if export is product feature', () {
      final result = _map(_export(exportContractIsProductFeature: true));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsProductFeature, isTrue);
    });

    test('facade fails closed if export is saved analysis', () {
      final result = _map(_export(exportContractIsSavedAnalysis: true));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsSavedAnalysis, isTrue);
    });

    test('facade fails closed if export is persistence write', () {
      final result = _map(_export(exportContractIsPersistenceWrite: true));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsPersistenceWrite, isTrue);
      expect(result.persistenceWritePerformed, isFalse);
    });

    test('facade fails closed if export is file write', () {
      final result = _map(_export(exportContractIsFileWrite: true));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsFileWrite, isTrue);
      expect(result.fileWritePerformed, isFalse);
    });

    test('facade fails closed if export is UI output', () {
      final result = _map(_export(exportContractIsUiOutput: true));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsUiOutput, isTrue);
      expect(result.uiOutputProduced, isFalse);
    });

    test('facade fails closed if export is archive/stats output', () {
      final result = _map(_export(exportContractIsArchiveStatsOutput: true));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsArchiveStatsOutput, isTrue);
      expect(result.archiveStatsTouched, isFalse);
    });

    test('facade fails closed if export is backend payload', () {
      final result = _map(_export(exportContractIsBackendPayload: true));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsBackendPayload, isTrue);
      expect(result.backendPayloadProduced, isFalse);
    });

    test('facade fails closed if export is not developer-only', () {
      final result = _map(_export(exportContractIsDeveloperOnly: false));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsDeveloperOnly, isFalse);
    });

    test('facade fails closed if export is not in-memory-only', () {
      final result = _map(_export(exportContractIsInMemoryOnly: false));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsInMemoryOnly, isFalse);
    });

    test('facade fails closed if export is not read-only', () {
      final result = _map(_export(exportContractIsReadOnly: false));

      _expectBlockedFacade(result);
      expect(result.sourceExportContractIsReadOnly, isFalse);
    });

    test('facade fails closed if payload count match flag is false', () {
      final result = _map(_export(payloadCountsMatchSnapshot: false));

      _expectBlockedFacade(result);
      expect(result.readableSummaryMatchesExport, isFalse);
      expect(result.failureMessage, contains('count mismatch'));
    });

    test('facade fails closed if payload contains public labels', () {
      final result = _map(_export(payloadContainsPublicLabels: true));

      _expectBlockedFacade(result);
      expect(result.readableSummaryContainsPublicLabels, isFalse);
    });

    test('facade fails closed if payload contains official metrics', () {
      final result = _map(_export(payloadContainsOfficialMetrics: true));

      _expectBlockedFacade(result);
      expect(result.readableSummaryContainsOfficialMetrics, isFalse);
    });

    test('facade fails closed if public label is computed', () {
      final result = _map(_export(publicLabelComputed: true));

      _expectBlockedFacade(result);
      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('facade fails closed if official metric is computed', () {
      final result = _map(_export(officialCpLossComputed: true));

      _expectBlockedFacade(result);
      expect(result.officialCpLossComputed, isFalse);
    });

    test('facade remains read-only', () {
      final result = _validFacade();

      expect(result.debugFacadeIsReadOnly, isTrue);
      expect(result.debugFacadeIsPersistenceWrite, isFalse);
      expect(result.debugFacadeIsFileWrite, isFalse);
      expect(result.savedAnalysisWritten, isFalse);
      expect(result.uiOutputProduced, isFalse);
      expect(result.archiveStatsTouched, isFalse);
    });

    test('facade remains developer-only', () {
      final result = _validFacade();

      expect(result.debugFacadeIsDeveloperOnly, isTrue);
      expect(result.debugFacadeIsPublic, isFalse);
      expect(result.debugFacadeIsProductFeature, isFalse);
      expect(result.debugFacadeIsOfficial, isFalse);
    });

    test(
      'facade performs no persistence/file/backend/UI/archive side effects',
      () {
        final result = _validFacade();

        expect(result.savedAnalysisWritten, isFalse);
        expect(result.uiOutputProduced, isFalse);
        expect(result.archiveStatsTouched, isFalse);
        expect(result.persistenceWritePerformed, isFalse);
        expect(result.fileWritePerformed, isFalse);
        expect(result.backendPayloadProduced, isFalse);
        expect(result.debugFacadeIsUiOutput, isFalse);
        expect(result.debugFacadeIsArchiveStatsOutput, isFalse);
        expect(result.debugFacadeIsBackendPayload, isFalse);
      },
    );

    test('public label remains null', () {
      final result = _validFacade();

      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
      expect(result.readableSummaryContainsPublicLabels, isFalse);
    });

    test('official move quality remains null', () {
      final result = _validFacade();

      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
      expect(result.readableSummaryContainsOfficialMetrics, isFalse);
    });

    test('accuracy, ACPL, and Win% remain false', () {
      final result = _validFacade();

      expect(result.officialWinPercentComputed, isFalse);
      expect(result.accuracyComputed, isFalse);
      expect(result.acplComputed, isFalse);
      expect(result.classificationComputed, isFalse);
      expect(result.publicClassifierOutputComputed, isFalse);
    });

    test('public label strings are banned from exposed fields', () {
      final clean = _validFacade();
      final leaked = _map(
        _export(exportContractId: 'phase36J:Brilliant:blocked'),
      );

      _expectForbiddenStringsAbsent(clean);
      _expectForbiddenStringsAbsent(leaked);
      expect(leaked.mappingSucceeded, isFalse);
      expect(leaked.safeForPhase36M, isFalse);
      expect(leaked.sourceExportContractId, 'phase36L:blockedExportContract');
    });

    test('safeForPhase36M true only when all safety flags are clean', () {
      final clean = _validFacade();
      final publicLabel = _map(_export(publicLabelComputed: true));
      final officialWinPercent = _map(
        _export(officialWinPercentComputed: true),
      );
      final fileWrite = _map(_export(fileWritePerformed: true));

      expect(clean.safeForPhase36M, isTrue);
      expect(publicLabel.safeForPhase36M, isFalse);
      expect(officialWinPercent.safeForPhase36M, isFalse);
      expect(fileWrite.safeForPhase36M, isFalse);
    });
  });
}

AnalyzerDeveloperSnapshotDebugReadFacade _map(
  AnalyzerDeveloperSnapshotExportContract source,
) {
  return mapDeveloperSnapshotExportContractToDebugReadFacade(source);
}

AnalyzerDeveloperSnapshotDebugReadFacade _validFacade() => _map(_export());

AnalyzerDeveloperSnapshotExportContract _export({
  String exportContractId = 'phase36J:phase36H:safe-snapshot:inMemory',
  String sourceSnapshotId = 'phase36H:safe-snapshot',
  String sourceReviewEnvelopeId = 'phase36F:safe-envelope',
  String sourceTimelineCollectionId = 'phase36D:safe-collection',
  String sourceReviewSummaryId = 'phase36E:safe-summary',
  bool sourceSnapshotComputed = true,
  bool sourceSnapshotIsDeveloperOnly = true,
  bool sourceSnapshotIsReadOnly = true,
  bool sourceSnapshotIsPublic = false,
  bool sourceSnapshotIsProductReview = false,
  bool sourceSnapshotIsSavedAnalysis = false,
  bool sourceSnapshotIsOfficial = false,
  bool sourceSnapshotIsUiOutput = false,
  bool sourceSnapshotIsArchiveStatsOutput = false,
  bool sourceSnapshotIsFullGameAnalysis = false,
  bool sourceSnapshotIsProductTimeline = false,
  bool exportContractComputed = true,
  bool exportContractIsDeveloperOnly = true,
  bool exportContractIsInMemoryOnly = true,
  bool exportContractIsReadOnly = true,
  bool exportContractIsPublic = false,
  bool exportContractIsProductFeature = false,
  bool exportContractIsSavedAnalysis = false,
  bool exportContractIsPersistenceWrite = false,
  bool exportContractIsFileWrite = false,
  bool exportContractIsUiOutput = false,
  bool exportContractIsArchiveStatsOutput = false,
  bool exportContractIsBackendPayload = false,
  bool exportContractIsOfficial = false,
  int totalPrivateEntries = 1,
  int positiveCandidateCount = 1,
  int neutralCandidateCount = 0,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  bool payloadCountsMatchSnapshot = true,
  bool payloadContainsPublicLabels = false,
  bool payloadContainsOfficialMetrics = false,
  bool publicLabelComputed = false,
  String? publicLabel,
  bool officialMoveQualityComputed = false,
  String? officialMoveQuality,
  bool officialCpLossComputed = false,
  bool officialWinPercentComputed = false,
  bool accuracyComputed = false,
  bool acplComputed = false,
  bool classificationComputed = false,
  bool publicClassifierOutputComputed = false,
  bool savedAnalysisWritten = false,
  bool uiOutputProduced = false,
  bool archiveStatsTouched = false,
  bool persistenceWritePerformed = false,
  bool fileWritePerformed = false,
  bool backendPayloadProduced = false,
  bool mappingSucceeded = true,
  bool safeForPhase36K = true,
}) {
  return AnalyzerDeveloperSnapshotExportContract(
    exportContractId: exportContractId,
    sourceSnapshotId: sourceSnapshotId,
    sourceReviewEnvelopeId: sourceReviewEnvelopeId,
    sourceTimelineCollectionId: sourceTimelineCollectionId,
    sourceReviewSummaryId: sourceReviewSummaryId,
    exportContractSource: analyzerDeveloperSnapshotExportContractSource,
    exportContractVersion: analyzerDeveloperSnapshotExportContractVersion,
    sourceSnapshotComputed: sourceSnapshotComputed,
    sourceSnapshotIsDeveloperOnly: sourceSnapshotIsDeveloperOnly,
    sourceSnapshotIsReadOnly: sourceSnapshotIsReadOnly,
    sourceSnapshotIsPublic: sourceSnapshotIsPublic,
    sourceSnapshotIsProductReview: sourceSnapshotIsProductReview,
    sourceSnapshotIsSavedAnalysis: sourceSnapshotIsSavedAnalysis,
    sourceSnapshotIsOfficial: sourceSnapshotIsOfficial,
    sourceSnapshotIsUiOutput: sourceSnapshotIsUiOutput,
    sourceSnapshotIsArchiveStatsOutput: sourceSnapshotIsArchiveStatsOutput,
    sourceSnapshotIsFullGameAnalysis: sourceSnapshotIsFullGameAnalysis,
    sourceSnapshotIsProductTimeline: sourceSnapshotIsProductTimeline,
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
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
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
    failureMessage: mappingSucceeded ? null : 'blocked fake export',
    safeForPhase36K: safeForPhase36K,
    nextRecommendation: safeForPhase36K
        ? analyzerDeveloperSnapshotExportContractNextRecommendation
        : analyzerDeveloperSnapshotExportContractFailureRecommendation,
  );
}

void _expectBlockedFacade(
  AnalyzerDeveloperSnapshotDebugReadFacade result, {
  String? reason,
}) {
  expect(result.mappingSucceeded, isFalse, reason: reason);
  expect(result.debugFacadeComputed, isFalse, reason: reason);
  expect(result.safeForPhase36M, isFalse, reason: reason);
  expect(result.developerReadStatus.wire, 'unavailable', reason: reason);
  expect(result.failureMessage, isNotNull, reason: reason);
  _expectNoPublicOfficialOrSideEffectOutput(result);
  _expectNoProductOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectNoPublicOfficialOrSideEffectOutput(
  AnalyzerDeveloperSnapshotDebugReadFacade result,
) {
  expect(result.publicLabelComputed, isFalse);
  expect(result.publicLabel, isNull);
  expect(result.officialMoveQualityComputed, isFalse);
  expect(result.officialMoveQuality, isNull);
  expect(result.officialCpLossComputed, isFalse);
  expect(result.officialWinPercentComputed, isFalse);
  expect(result.accuracyComputed, isFalse);
  expect(result.acplComputed, isFalse);
  expect(result.classificationComputed, isFalse);
  expect(result.publicClassifierOutputComputed, isFalse);
  expect(result.savedAnalysisWritten, isFalse);
  expect(result.uiOutputProduced, isFalse);
  expect(result.archiveStatsTouched, isFalse);
  expect(result.persistenceWritePerformed, isFalse);
  expect(result.fileWritePerformed, isFalse);
  expect(result.backendPayloadProduced, isFalse);
}

void _expectNoProductOutput(AnalyzerDeveloperSnapshotDebugReadFacade result) {
  expect(result.debugFacadeIsPublic, isFalse);
  expect(result.debugFacadeIsProductFeature, isFalse);
  expect(result.debugFacadeIsSavedAnalysis, isFalse);
  expect(result.debugFacadeIsPersistenceWrite, isFalse);
  expect(result.debugFacadeIsFileWrite, isFalse);
  expect(result.debugFacadeIsUiOutput, isFalse);
  expect(result.debugFacadeIsArchiveStatsOutput, isFalse);
  expect(result.debugFacadeIsBackendPayload, isFalse);
  expect(result.debugFacadeIsOfficial, isFalse);
}

void _expectForbiddenStringsAbsent(
  AnalyzerDeveloperSnapshotDebugReadFacade result,
) {
  final exposed = <String?>{
    result.debugFacadeId,
    result.debugFacadeSource,
    result.sourceExportContractId,
    result.sourceSnapshotId,
    result.sourceReviewEnvelopeId,
    result.publicLabel,
    result.officialMoveQuality,
    result.developerReadStatus.wire,
    result.developerReadMessage.wire,
  }.whereType<String>();

  for (final value in exposed) {
    for (final forbidden in _forbiddenPublicLabelStrings) {
      expect(value.contains(forbidden), isFalse, reason: value);
    }
  }
}

const _forbiddenPublicLabelStrings = {
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
