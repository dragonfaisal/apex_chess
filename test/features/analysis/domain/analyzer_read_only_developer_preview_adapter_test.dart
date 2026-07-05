import 'package:apex_chess/features/analysis/domain/analyzer_developer_debug_preview_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_read_only_developer_preview_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('adaptDeveloperDebugPreviewContractToReadOnlyDeveloperPreview', () {
    test('valid contract maps to previewReady true', () {
      final result = _adapt(_contract());

      expect(result.mappingSucceeded, isTrue);
      expect(result.adapterComputed, isTrue);
      expect(result.previewReady, isTrue);
      expect(
        result.previewUnavailableReason,
        AnalyzerReadOnlyDeveloperPreviewUnavailableReason.none,
      );
      expect(result.safeForPhase37A, isTrue);
      expect(result.safeForPhase37B, isTrue);
      expect(
        result.nextRecommendation,
        analyzerReadOnlyDeveloperPreviewAdapterNextRecommendation,
      );
    });

    test('safe counts are copied exactly from source contract', () {
      final source = _contract(
        totalPrivateEntries: 8,
        positiveCandidateCount: 2,
        neutralCandidateCount: 3,
        negativeCandidateCount: 1,
        unavailableCount: 2,
      );
      final result = _adapt(source);

      expect(result.mappingSucceeded, isTrue);
      expect(result.totalPrivateEntries, source.totalPrivateEntries);
      expect(result.positiveCandidateCount, source.positiveCandidateCount);
      expect(result.neutralCandidateCount, source.neutralCandidateCount);
      expect(result.negativeCandidateCount, source.negativeCandidateCount);
      expect(result.unavailableCount, source.unavailableCount);
    });

    test('adapter consumes only debug preview contract identity', () {
      final source = _contract(debugPreviewContractId: 'phase36N:contract:one');
      final result = _adapt(source);

      expect(result.mappingSucceeded, isTrue);
      expect(
        result.sourceDebugPreviewContractId,
        source.debugPreviewContractId,
      );
      expect(result.adapterResultId, contains(source.debugPreviewContractId));
    });

    for (final entry in <String, AnalyzerDeveloperDebugPreviewContract>{
      'public': _contract(debugPreviewIsPublic: true),
      'product': _contract(debugPreviewIsProductFeature: true),
      'UI': _contract(debugPreviewIsUiOutput: true),
      'debug UI': _contract(debugPreviewIsDebugUi: true),
      'saved analysis': _contract(debugPreviewIsSavedAnalysis: true),
      'persistence': _contract(debugPreviewIsPersistenceWrite: true),
      'backend': _contract(debugPreviewIsBackendPayload: true),
      'archive/stats': _contract(debugPreviewIsArchiveStatsOutput: true),
    }.entries) {
      test('${entry.key} source fails closed', () {
        final result = _adapt(entry.value);

        _expectBlockedAdapter(result);
      });
    }

    test('source facade safety flags also fail closed', () {
      final result = _adapt(_contract(sourceDebugFacadeIsPublic: true));

      _expectBlockedAdapter(result);
      expect(result.failureMessage, contains('public label data'));
    });

    test('non-ready developer status fails closed', () {
      final result = _adapt(
        _contract(
          developerPreviewStatus:
              AnalyzerDeveloperDebugPreviewStatus.unavailable,
          developerPreviewMessage:
              AnalyzerDeveloperDebugPreviewMessage.sourceFacadeUnavailable,
        ),
      );

      _expectBlockedAdapter(result);
      expect(
        result.previewUnavailableReason,
        AnalyzerReadOnlyDeveloperPreviewUnavailableReason.sourceUnavailable,
      );
      expect(result.failureMessage, contains('not ready'));
    });

    test('source summary mismatch fails closed without recounting', () {
      final result = _adapt(_contract(previewSummaryMatchesFacade: false));

      _expectBlockedAdapter(result);
      expect(
        result.previewUnavailableReason,
        AnalyzerReadOnlyDeveloperPreviewUnavailableReason.sourceUnsafe,
      );
      expect(result.failureMessage, contains('summary mismatch'));
    });

    test('public label computed fails closed', () {
      final result = _adapt(_contract(publicLabelComputed: true));

      _expectBlockedAdapter(result);
      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
      expect(result.adapterContainsPublicLabels, isFalse);
    });

    test(
      'public label string in source identity fails closed and is sanitized',
      () {
        final result = _adapt(
          _contract(debugPreviewContractId: 'phase36N:Brilliant:blocked'),
        );

        _expectBlockedAdapter(result);
        expect(
          result.sourceDebugPreviewContractId,
          'phase36P:blockedDebugPreviewContract',
        );
        _expectForbiddenStringsAbsent(result);
      },
    );

    test('official metric computed fails closed', () {
      final result = _adapt(_contract(officialCpLossComputed: true));

      _expectBlockedAdapter(result);
      expect(result.officialCpLossComputed, isFalse);
      expect(result.adapterContainsOfficialMetrics, isFalse);
    });

    test('official move quality remains null even if source is dirty', () {
      final result = _adapt(_contract(officialMoveQuality: 'Best'));

      _expectBlockedAdapter(result);
      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
    });

    for (final entry in <String, AnalyzerDeveloperDebugPreviewContract>{
      'saved analysis write': _contract(savedAnalysisWritten: true),
      'UI output': _contract(uiOutputProduced: true),
      'persistence write': _contract(persistenceWritePerformed: true),
      'file write': _contract(fileWritePerformed: true),
      'backend payload': _contract(backendPayloadProduced: true),
      'archive stats touch': _contract(archiveStatsTouched: true),
    }.entries) {
      test('${entry.key} side effect fails closed', () {
        final result = _adapt(entry.value);

        _expectBlockedAdapter(result);
      });
    }

    test('adapter remains developer-only and read-only', () {
      final result = _adapt(_contract());

      expect(result.mappingSucceeded, isTrue);
      expect(result.adapterIsDeveloperOnly, isTrue);
      expect(result.adapterIsReadOnly, isTrue);
      expect(result.adapterIsUiOutput, isFalse);
      expect(result.adapterIsProductReview, isFalse);
      expect(result.adapterIsSavedAnalysis, isFalse);
      expect(result.adapterIsPersistenceWrite, isFalse);
      expect(result.adapterIsBackendPayload, isFalse);
      expect(result.adapterIsArchiveStatsOutput, isFalse);
    });

    test('adapter never emits public label or official move quality', () {
      final result = _adapt(_contract());

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
      _expectForbiddenStringsAbsent(result);
    });

    test(
      'adapter produces no UI/product/saved/persistence/backend/archive output',
      () {
        final result = _adapt(_contract());

        expect(result.adapterIsUiOutput, isFalse);
        expect(result.adapterIsProductReview, isFalse);
        expect(result.adapterIsSavedAnalysis, isFalse);
        expect(result.adapterIsPersistenceWrite, isFalse);
        expect(result.adapterIsBackendPayload, isFalse);
        expect(result.adapterIsArchiveStatsOutput, isFalse);
        expect(result.savedAnalysisWritten, isFalse);
        expect(result.uiOutputProduced, isFalse);
        expect(result.persistenceWritePerformed, isFalse);
        expect(result.fileWritePerformed, isFalse);
        expect(result.backendPayloadProduced, isFalse);
        expect(result.archiveStatsTouched, isFalse);
      },
    );

    test('safeForPhase37A true only for clean source', () {
      final clean = _adapt(_contract());
      final dirtyPublic = _adapt(_contract(debugPreviewIsPublic: true));
      final dirtyOfficial = _adapt(_contract(officialWinPercentComputed: true));
      final dirtySideEffect = _adapt(_contract(fileWritePerformed: true));

      expect(clean.safeForPhase37A, isTrue);
      expect(dirtyPublic.safeForPhase37A, isFalse);
      expect(dirtyOfficial.safeForPhase37A, isFalse);
      expect(dirtySideEffect.safeForPhase37A, isFalse);
    });

    test('safeForPhase37B true only for clean source', () {
      final clean = _adapt(_contract());
      final dirtyPublic = _adapt(_contract(debugPreviewIsPublic: true));
      final dirtyOfficial = _adapt(_contract(officialWinPercentComputed: true));
      final dirtySideEffect = _adapt(_contract(fileWritePerformed: true));

      expect(clean.safeForPhase37B, isTrue);
      expect(dirtyPublic.safeForPhase37B, isFalse);
      expect(dirtyOfficial.safeForPhase37B, isFalse);
      expect(dirtySideEffect.safeForPhase37B, isFalse);
    });
  });
}

AnalyzerReadOnlyDeveloperPreviewAdapterResult _adapt(
  AnalyzerDeveloperDebugPreviewContract source,
) {
  return adaptDeveloperDebugPreviewContractToReadOnlyDeveloperPreview(source);
}

AnalyzerDeveloperDebugPreviewContract _contract({
  String debugPreviewContractId = 'phase36N:phase36L:safe:preview',
  String sourceDebugFacadeId = 'phase36L:safe-facade',
  String sourceExportContractId = 'phase36J:safe-export',
  String sourceSnapshotId = 'phase36H:safe-snapshot',
  String sourceReviewEnvelopeId = 'phase36F:safe-envelope',
  bool sourceDebugFacadeComputed = true,
  bool sourceDebugFacadeIsDeveloperOnly = true,
  bool sourceDebugFacadeIsReadOnly = true,
  bool sourceDebugFacadeIsPublic = false,
  bool sourceDebugFacadeIsProductFeature = false,
  bool sourceDebugFacadeIsUiOutput = false,
  bool sourceDebugFacadeIsSavedAnalysis = false,
  bool sourceDebugFacadeIsPersistenceWrite = false,
  bool sourceDebugFacadeIsFileWrite = false,
  bool sourceDebugFacadeIsArchiveStatsOutput = false,
  bool sourceDebugFacadeIsBackendPayload = false,
  bool sourceDebugFacadeIsOfficial = false,
  bool debugPreviewComputed = true,
  bool debugPreviewIsDeveloperOnly = true,
  bool debugPreviewIsReadOnly = true,
  bool debugPreviewIsPublic = false,
  bool debugPreviewIsProductFeature = false,
  bool debugPreviewIsUiOutput = false,
  bool debugPreviewIsDebugUi = false,
  bool debugPreviewIsSavedAnalysis = false,
  bool debugPreviewIsPersistenceWrite = false,
  bool debugPreviewIsFileWrite = false,
  bool debugPreviewIsArchiveStatsOutput = false,
  bool debugPreviewIsBackendPayload = false,
  bool debugPreviewIsOfficial = false,
  int totalPrivateEntries = 1,
  int positiveCandidateCount = 1,
  int neutralCandidateCount = 0,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  bool previewSummaryMatchesFacade = true,
  bool previewContainsPublicLabels = false,
  bool previewContainsOfficialMetrics = false,
  AnalyzerDeveloperDebugPreviewStatus developerPreviewStatus =
      AnalyzerDeveloperDebugPreviewStatus.ready,
  AnalyzerDeveloperDebugPreviewMessage developerPreviewMessage =
      AnalyzerDeveloperDebugPreviewMessage.developerPreviewReady,
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
  bool safeForPhase36O = true,
}) {
  return AnalyzerDeveloperDebugPreviewContract(
    debugPreviewContractId: debugPreviewContractId,
    sourceDebugFacadeId: sourceDebugFacadeId,
    sourceExportContractId: sourceExportContractId,
    sourceSnapshotId: sourceSnapshotId,
    sourceReviewEnvelopeId: sourceReviewEnvelopeId,
    debugPreviewSource: analyzerDeveloperDebugPreviewContractSource,
    debugPreviewVersion: analyzerDeveloperDebugPreviewContractVersion,
    sourceDebugFacadeComputed: sourceDebugFacadeComputed,
    sourceDebugFacadeIsDeveloperOnly: sourceDebugFacadeIsDeveloperOnly,
    sourceDebugFacadeIsReadOnly: sourceDebugFacadeIsReadOnly,
    sourceDebugFacadeIsPublic: sourceDebugFacadeIsPublic,
    sourceDebugFacadeIsProductFeature: sourceDebugFacadeIsProductFeature,
    sourceDebugFacadeIsUiOutput: sourceDebugFacadeIsUiOutput,
    sourceDebugFacadeIsSavedAnalysis: sourceDebugFacadeIsSavedAnalysis,
    sourceDebugFacadeIsPersistenceWrite: sourceDebugFacadeIsPersistenceWrite,
    sourceDebugFacadeIsFileWrite: sourceDebugFacadeIsFileWrite,
    sourceDebugFacadeIsArchiveStatsOutput:
        sourceDebugFacadeIsArchiveStatsOutput,
    sourceDebugFacadeIsBackendPayload: sourceDebugFacadeIsBackendPayload,
    sourceDebugFacadeIsOfficial: sourceDebugFacadeIsOfficial,
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
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    previewSummaryMatchesFacade: previewSummaryMatchesFacade,
    previewContainsPublicLabels: previewContainsPublicLabels,
    previewContainsOfficialMetrics: previewContainsOfficialMetrics,
    developerPreviewStatus: developerPreviewStatus,
    developerPreviewMessage: developerPreviewMessage,
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
    failureMessage: mappingSucceeded ? null : 'blocked fake contract',
    safeForPhase36O: safeForPhase36O,
    nextRecommendation: safeForPhase36O
        ? analyzerDeveloperDebugPreviewContractNextRecommendation
        : analyzerDeveloperDebugPreviewContractFailureRecommendation,
  );
}

void _expectBlockedAdapter(
  AnalyzerReadOnlyDeveloperPreviewAdapterResult result,
) {
  expect(result.mappingSucceeded, isFalse);
  expect(result.adapterComputed, isFalse);
  expect(result.previewReady, isFalse);
  expect(result.safeForPhase37A, isFalse);
  expect(result.safeForPhase37B, isFalse);
  expect(
    result.nextRecommendation,
    analyzerReadOnlyDeveloperPreviewAdapterFailureRecommendation,
  );
  expect(
    result.previewUnavailableReason,
    isNot(AnalyzerReadOnlyDeveloperPreviewUnavailableReason.none),
  );
  expect(result.failureMessage, isNotNull);
  _expectNoPublicOfficialOrSideEffectOutput(result);
  _expectNoProductOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectNoPublicOfficialOrSideEffectOutput(
  AnalyzerReadOnlyDeveloperPreviewAdapterResult result,
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
  expect(result.persistenceWritePerformed, isFalse);
  expect(result.fileWritePerformed, isFalse);
  expect(result.backendPayloadProduced, isFalse);
  expect(result.archiveStatsTouched, isFalse);
}

void _expectNoProductOutput(
  AnalyzerReadOnlyDeveloperPreviewAdapterResult result,
) {
  expect(result.adapterIsUiOutput, isFalse);
  expect(result.adapterIsProductReview, isFalse);
  expect(result.adapterIsSavedAnalysis, isFalse);
  expect(result.adapterIsPersistenceWrite, isFalse);
  expect(result.adapterIsBackendPayload, isFalse);
  expect(result.adapterIsArchiveStatsOutput, isFalse);
  expect(result.adapterContainsPublicLabels, isFalse);
  expect(result.adapterContainsOfficialMetrics, isFalse);
}

void _expectForbiddenStringsAbsent(
  AnalyzerReadOnlyDeveloperPreviewAdapterResult result,
) {
  final exposed = <String?>{
    result.adapterResultId,
    result.sourceDebugPreviewContractId,
    result.adapterSource,
    result.publicLabel,
    result.officialMoveQuality,
    result.previewUnavailableReason.wire,
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
