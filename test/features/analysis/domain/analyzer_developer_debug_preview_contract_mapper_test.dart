import 'package:apex_chess/features/analysis/domain/analyzer_developer_debug_preview_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_debug_preview_contract_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_debug_read_facade.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapDeveloperSnapshotDebugReadFacadeToDebugPreviewContract', () {
    test('preview mapping succeeds with valid fake debug facade', () {
      final result = _map(_facade());

      expect(result.mappingSucceeded, isTrue);
      expect(result.debugPreviewComputed, isTrue);
      expect(result.safeForPhase36O, isTrue);
      expect(result.developerPreviewStatus.wire, 'ready');
      expect(result.developerPreviewMessage.wire, 'developerPreviewReady');
      expect(
        result.nextRecommendation,
        analyzerDeveloperDebugPreviewContractNextRecommendation,
      );
    });

    test('preview copies safe IDs from facade', () {
      final source = _facade(
        debugFacadeId: 'phase36L:phase36J:safe:debugRead',
        sourceExportContractId: 'phase36J:safe-export',
        sourceSnapshotId: 'phase36H:safe-snapshot',
        sourceReviewEnvelopeId: 'phase36F:safe-envelope',
      );
      final result = _map(source);

      expect(result.mappingSucceeded, isTrue);
      expect(result.sourceDebugFacadeId, source.debugFacadeId);
      expect(result.sourceExportContractId, source.sourceExportContractId);
      expect(result.sourceSnapshotId, source.sourceSnapshotId);
      expect(result.sourceReviewEnvelopeId, source.sourceReviewEnvelopeId);
    });

    test('preview copies safe private counts from facade', () {
      final source = _facade(
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
      expect(result.previewSummaryMatchesFacade, isTrue);
    });

    test('preview fails closed if facade is public', () {
      final result = _map(_facade(debugFacadeIsPublic: true));

      _expectBlockedPreview(result);
      expect(result.sourceDebugFacadeIsPublic, isTrue);
    });

    test('preview fails closed if facade is official', () {
      final result = _map(_facade(debugFacadeIsOfficial: true));

      _expectBlockedPreview(result);
      expect(result.sourceDebugFacadeIsOfficial, isTrue);
    });

    test('preview fails closed if facade is product feature', () {
      final result = _map(_facade(debugFacadeIsProductFeature: true));

      _expectBlockedPreview(result);
      expect(result.sourceDebugFacadeIsProductFeature, isTrue);
    });

    test('preview fails closed if facade is saved analysis', () {
      final result = _map(_facade(debugFacadeIsSavedAnalysis: true));

      _expectBlockedPreview(result);
      expect(result.sourceDebugFacadeIsSavedAnalysis, isTrue);
    });

    test('preview fails closed if facade is persistence write', () {
      final result = _map(_facade(debugFacadeIsPersistenceWrite: true));

      _expectBlockedPreview(result);
      expect(result.sourceDebugFacadeIsPersistenceWrite, isTrue);
      expect(result.persistenceWritePerformed, isFalse);
    });

    test('preview fails closed if facade is file write', () {
      final result = _map(_facade(debugFacadeIsFileWrite: true));

      _expectBlockedPreview(result);
      expect(result.sourceDebugFacadeIsFileWrite, isTrue);
      expect(result.fileWritePerformed, isFalse);
    });

    test('preview fails closed if facade is UI output', () {
      final result = _map(_facade(debugFacadeIsUiOutput: true));

      _expectBlockedPreview(result);
      expect(result.sourceDebugFacadeIsUiOutput, isTrue);
      expect(result.uiOutputProduced, isFalse);
    });

    test('preview fails closed if facade is archive/stats output', () {
      final result = _map(_facade(debugFacadeIsArchiveStatsOutput: true));

      _expectBlockedPreview(result);
      expect(result.sourceDebugFacadeIsArchiveStatsOutput, isTrue);
      expect(result.archiveStatsTouched, isFalse);
    });

    test('preview fails closed if facade is backend payload', () {
      final result = _map(_facade(debugFacadeIsBackendPayload: true));

      _expectBlockedPreview(result);
      expect(result.sourceDebugFacadeIsBackendPayload, isTrue);
      expect(result.backendPayloadProduced, isFalse);
    });

    test('preview fails closed if facade is not developer-only', () {
      final result = _map(_facade(debugFacadeIsDeveloperOnly: false));

      _expectBlockedPreview(result);
      expect(result.sourceDebugFacadeIsDeveloperOnly, isFalse);
    });

    test('preview fails closed if facade is not read-only', () {
      final result = _map(_facade(debugFacadeIsReadOnly: false));

      _expectBlockedPreview(result);
      expect(result.sourceDebugFacadeIsReadOnly, isFalse);
    });

    test('preview fails closed if readable summary match flag is false', () {
      final result = _map(_facade(readableSummaryMatchesExport: false));

      _expectBlockedPreview(result);
      expect(result.previewSummaryMatchesFacade, isFalse);
      expect(result.failureMessage, contains('summary mismatch'));
    });

    test('preview fails closed if readable summary contains public labels', () {
      final result = _map(_facade(readableSummaryContainsPublicLabels: true));

      _expectBlockedPreview(result);
      expect(result.previewContainsPublicLabels, isFalse);
    });

    test(
      'preview fails closed if readable summary contains official metrics',
      () {
        final result = _map(
          _facade(readableSummaryContainsOfficialMetrics: true),
        );

        _expectBlockedPreview(result);
        expect(result.previewContainsOfficialMetrics, isFalse);
      },
    );

    test('preview fails closed if developer read status is unavailable', () {
      final result = _map(
        _facade(
          developerReadStatus:
              AnalyzerDeveloperSnapshotDebugReadStatus.unavailable,
          developerReadMessage:
              AnalyzerDeveloperSnapshotDebugReadMessage.sourceExportUnsafe,
        ),
      );

      _expectBlockedPreview(result);
      expect(result.developerPreviewStatus.wire, 'unavailable');
      expect(result.developerPreviewMessage.wire, 'sourceFacadeUnsafe');
    });

    test('preview fails closed if public label is computed', () {
      final result = _map(_facade(publicLabelComputed: true));

      _expectBlockedPreview(result);
      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('preview fails closed if official metric is computed', () {
      final result = _map(_facade(officialCpLossComputed: true));

      _expectBlockedPreview(result);
      expect(result.officialCpLossComputed, isFalse);
    });

    test('preview remains read-only', () {
      final result = _validPreview();

      expect(result.debugPreviewIsReadOnly, isTrue);
      expect(result.debugPreviewIsPersistenceWrite, isFalse);
      expect(result.debugPreviewIsFileWrite, isFalse);
      expect(result.savedAnalysisWritten, isFalse);
      expect(result.uiOutputProduced, isFalse);
      expect(result.archiveStatsTouched, isFalse);
    });

    test('preview remains developer-only', () {
      final result = _validPreview();

      expect(result.debugPreviewIsDeveloperOnly, isTrue);
      expect(result.debugPreviewIsPublic, isFalse);
      expect(result.debugPreviewIsProductFeature, isFalse);
      expect(result.debugPreviewIsOfficial, isFalse);
    });

    test('preview is not debug UI', () {
      final result = _validPreview();

      expect(result.debugPreviewIsDebugUi, isFalse);
      expect(result.debugPreviewIsUiOutput, isFalse);
      expect(result.uiOutputProduced, isFalse);
    });

    test(
      'preview performs no persistence/file/backend/UI/archive side effects',
      () {
        final result = _validPreview();

        expect(result.savedAnalysisWritten, isFalse);
        expect(result.uiOutputProduced, isFalse);
        expect(result.archiveStatsTouched, isFalse);
        expect(result.persistenceWritePerformed, isFalse);
        expect(result.fileWritePerformed, isFalse);
        expect(result.backendPayloadProduced, isFalse);
        expect(result.debugPreviewIsUiOutput, isFalse);
        expect(result.debugPreviewIsArchiveStatsOutput, isFalse);
        expect(result.debugPreviewIsBackendPayload, isFalse);
      },
    );

    test('public label remains null', () {
      final result = _validPreview();

      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
      expect(result.previewContainsPublicLabels, isFalse);
    });

    test('official move quality remains null', () {
      final result = _validPreview();

      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
      expect(result.previewContainsOfficialMetrics, isFalse);
    });

    test('accuracy, ACPL, and Win% remain false', () {
      final result = _validPreview();

      expect(result.officialWinPercentComputed, isFalse);
      expect(result.accuracyComputed, isFalse);
      expect(result.acplComputed, isFalse);
      expect(result.classificationComputed, isFalse);
      expect(result.publicClassifierOutputComputed, isFalse);
    });

    test('public label strings are banned from exposed fields', () {
      final clean = _validPreview();
      final leaked = _map(_facade(debugFacadeId: 'phase36L:Brilliant:blocked'));

      _expectForbiddenStringsAbsent(clean);
      _expectForbiddenStringsAbsent(leaked);
      expect(leaked.mappingSucceeded, isFalse);
      expect(leaked.safeForPhase36O, isFalse);
      expect(leaked.sourceDebugFacadeId, 'phase36N:blockedDebugFacade');
    });

    test('safeForPhase36O true only when all safety flags are clean', () {
      final clean = _validPreview();
      final publicLabel = _map(_facade(publicLabelComputed: true));
      final officialWinPercent = _map(
        _facade(officialWinPercentComputed: true),
      );
      final fileWrite = _map(_facade(fileWritePerformed: true));

      expect(clean.safeForPhase36O, isTrue);
      expect(publicLabel.safeForPhase36O, isFalse);
      expect(officialWinPercent.safeForPhase36O, isFalse);
      expect(fileWrite.safeForPhase36O, isFalse);
    });
  });
}

AnalyzerDeveloperDebugPreviewContract _map(
  AnalyzerDeveloperSnapshotDebugReadFacade source,
) {
  return mapDeveloperSnapshotDebugReadFacadeToDebugPreviewContract(source);
}

AnalyzerDeveloperDebugPreviewContract _validPreview() => _map(_facade());

AnalyzerDeveloperSnapshotDebugReadFacade _facade({
  String debugFacadeId = 'phase36L:phase36J:safe-export:debugRead',
  String sourceExportContractId = 'phase36J:safe-export',
  String sourceSnapshotId = 'phase36H:safe-snapshot',
  String sourceReviewEnvelopeId = 'phase36F:safe-envelope',
  bool sourceExportContractComputed = true,
  bool sourceExportContractIsDeveloperOnly = true,
  bool sourceExportContractIsInMemoryOnly = true,
  bool sourceExportContractIsReadOnly = true,
  bool sourceExportContractIsPublic = false,
  bool sourceExportContractIsProductFeature = false,
  bool sourceExportContractIsSavedAnalysis = false,
  bool sourceExportContractIsPersistenceWrite = false,
  bool sourceExportContractIsFileWrite = false,
  bool sourceExportContractIsUiOutput = false,
  bool sourceExportContractIsArchiveStatsOutput = false,
  bool sourceExportContractIsBackendPayload = false,
  bool sourceExportContractIsOfficial = false,
  bool debugFacadeComputed = true,
  bool debugFacadeIsDeveloperOnly = true,
  bool debugFacadeIsReadOnly = true,
  bool debugFacadeIsPublic = false,
  bool debugFacadeIsProductFeature = false,
  bool debugFacadeIsUiOutput = false,
  bool debugFacadeIsSavedAnalysis = false,
  bool debugFacadeIsPersistenceWrite = false,
  bool debugFacadeIsFileWrite = false,
  bool debugFacadeIsArchiveStatsOutput = false,
  bool debugFacadeIsBackendPayload = false,
  bool debugFacadeIsOfficial = false,
  int totalPrivateEntries = 1,
  int positiveCandidateCount = 1,
  int neutralCandidateCount = 0,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  bool readableSummaryMatchesExport = true,
  bool readableSummaryContainsPublicLabels = false,
  bool readableSummaryContainsOfficialMetrics = false,
  AnalyzerDeveloperSnapshotDebugReadStatus developerReadStatus =
      AnalyzerDeveloperSnapshotDebugReadStatus.ready,
  AnalyzerDeveloperSnapshotDebugReadMessage developerReadMessage =
      AnalyzerDeveloperSnapshotDebugReadMessage.developerSnapshotReady,
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
  bool safeForPhase36M = true,
}) {
  return AnalyzerDeveloperSnapshotDebugReadFacade(
    debugFacadeId: debugFacadeId,
    sourceExportContractId: sourceExportContractId,
    sourceSnapshotId: sourceSnapshotId,
    sourceReviewEnvelopeId: sourceReviewEnvelopeId,
    debugFacadeSource: analyzerDeveloperSnapshotDebugReadFacadeSource,
    debugFacadeVersion: analyzerDeveloperSnapshotDebugReadFacadeVersion,
    sourceExportContractComputed: sourceExportContractComputed,
    sourceExportContractIsDeveloperOnly: sourceExportContractIsDeveloperOnly,
    sourceExportContractIsInMemoryOnly: sourceExportContractIsInMemoryOnly,
    sourceExportContractIsReadOnly: sourceExportContractIsReadOnly,
    sourceExportContractIsPublic: sourceExportContractIsPublic,
    sourceExportContractIsProductFeature: sourceExportContractIsProductFeature,
    sourceExportContractIsSavedAnalysis: sourceExportContractIsSavedAnalysis,
    sourceExportContractIsPersistenceWrite:
        sourceExportContractIsPersistenceWrite,
    sourceExportContractIsFileWrite: sourceExportContractIsFileWrite,
    sourceExportContractIsUiOutput: sourceExportContractIsUiOutput,
    sourceExportContractIsArchiveStatsOutput:
        sourceExportContractIsArchiveStatsOutput,
    sourceExportContractIsBackendPayload: sourceExportContractIsBackendPayload,
    sourceExportContractIsOfficial: sourceExportContractIsOfficial,
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
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    readableSummaryMatchesExport: readableSummaryMatchesExport,
    readableSummaryContainsPublicLabels: readableSummaryContainsPublicLabels,
    readableSummaryContainsOfficialMetrics:
        readableSummaryContainsOfficialMetrics,
    developerReadStatus: developerReadStatus,
    developerReadMessage: developerReadMessage,
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
    failureMessage: mappingSucceeded ? null : 'blocked fake facade',
    safeForPhase36M: safeForPhase36M,
    nextRecommendation: safeForPhase36M
        ? analyzerDeveloperSnapshotDebugReadFacadeNextRecommendation
        : analyzerDeveloperSnapshotDebugReadFacadeFailureRecommendation,
  );
}

void _expectBlockedPreview(
  AnalyzerDeveloperDebugPreviewContract result, {
  String? reason,
}) {
  expect(result.mappingSucceeded, isFalse, reason: reason);
  expect(result.debugPreviewComputed, isFalse, reason: reason);
  expect(result.safeForPhase36O, isFalse, reason: reason);
  expect(result.developerPreviewStatus.wire, 'unavailable', reason: reason);
  expect(result.failureMessage, isNotNull, reason: reason);
  _expectNoPublicOfficialOrSideEffectOutput(result);
  _expectNoProductOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectNoPublicOfficialOrSideEffectOutput(
  AnalyzerDeveloperDebugPreviewContract result,
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

void _expectNoProductOutput(AnalyzerDeveloperDebugPreviewContract result) {
  expect(result.debugPreviewIsPublic, isFalse);
  expect(result.debugPreviewIsProductFeature, isFalse);
  expect(result.debugPreviewIsUiOutput, isFalse);
  expect(result.debugPreviewIsDebugUi, isFalse);
  expect(result.debugPreviewIsSavedAnalysis, isFalse);
  expect(result.debugPreviewIsPersistenceWrite, isFalse);
  expect(result.debugPreviewIsFileWrite, isFalse);
  expect(result.debugPreviewIsArchiveStatsOutput, isFalse);
  expect(result.debugPreviewIsBackendPayload, isFalse);
  expect(result.debugPreviewIsOfficial, isFalse);
}

void _expectForbiddenStringsAbsent(
  AnalyzerDeveloperDebugPreviewContract result,
) {
  final exposed = <String?>{
    result.debugPreviewContractId,
    result.debugPreviewSource,
    result.sourceDebugFacadeId,
    result.sourceExportContractId,
    result.sourceSnapshotId,
    result.sourceReviewEnvelopeId,
    result.publicLabel,
    result.officialMoveQuality,
    result.developerPreviewStatus.wire,
    result.developerPreviewMessage.wire,
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
