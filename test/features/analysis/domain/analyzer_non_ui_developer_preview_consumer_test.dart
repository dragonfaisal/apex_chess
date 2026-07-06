import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_non_ui_developer_preview_consumer.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_read_only_developer_preview_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('consumeReadOnlyDeveloperPreviewAdapterResult', () {
    test('valid adapter maps to consumerReady true', () {
      final result = _consume(_adapter());

      expect(result.mappingSucceeded, isTrue);
      expect(result.consumerComputed, isTrue);
      expect(result.consumerReady, isTrue);
      expect(
        result.consumerUnavailableReason,
        AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason.none,
      );
      expect(result.safeForPhase37D, isTrue);
      expect(result.safeForPhase37E, isTrue);
      expect(
        result.nextRecommendation,
        analyzerNonUiDeveloperPreviewConsumerNextRecommendation,
      );
    });

    test('safe counts are copied exactly from adapter result', () {
      final source = _adapter(
        totalPrivateEntries: 13,
        positiveCandidateCount: 5,
        neutralCandidateCount: 4,
        negativeCandidateCount: 3,
        unavailableCount: 1,
      );
      final result = _consume(source);

      expect(result.mappingSucceeded, isTrue);
      expect(result.totalPrivateEntries, source.totalPrivateEntries);
      expect(result.positiveCandidateCount, source.positiveCandidateCount);
      expect(result.neutralCandidateCount, source.neutralCandidateCount);
      expect(result.negativeCandidateCount, source.negativeCandidateCount);
      expect(result.unavailableCount, source.unavailableCount);
    });

    test(
      'consumer imports only adapter boundary and does not call upstream',
      () {
        final source = File(
          'lib/features/analysis/domain/'
          'analyzer_non_ui_developer_preview_consumer.dart',
        ).readAsStringSync();

        expect(
          source,
          contains('analyzer_read_only_developer_preview_adapter.dart'),
        );
        expect(source, isNot(contains('analyzer_developer_debug_preview')));
        expect(source, isNot(contains('local_analyzer')));
        expect(source, isNot(contains('LegacyReintegration')));
        expect(source, isNot(contains('MoveClassifier')));
      },
    );

    for (final entry in <String, AnalyzerReadOnlyDeveloperPreviewAdapterResult>{
      'UI source': _adapter(adapterIsUiOutput: true),
      'product review source': _adapter(adapterIsProductReview: true),
      'saved analysis source': _adapter(adapterIsSavedAnalysis: true),
      'persistence source': _adapter(adapterIsPersistenceWrite: true),
      'backend source': _adapter(adapterIsBackendPayload: true),
      'archive stats source': _adapter(adapterIsArchiveStatsOutput: true),
    }.entries) {
      test('${entry.key} fails closed', () {
        final result = _consume(entry.value);

        _expectBlockedConsumer(result);
      });
    }

    test('non-ready adapter fails closed', () {
      final result = _consume(
        _adapter(
          mappingSucceeded: false,
          adapterComputed: false,
          previewReady: false,
          previewUnavailableReason:
              AnalyzerReadOnlyDeveloperPreviewUnavailableReason
                  .sourceUnavailable,
          safeForPhase37B: false,
        ),
      );

      _expectBlockedConsumer(result);
      expect(
        result.consumerUnavailableReason,
        AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason
            .sourceUnavailable,
      );
    });

    test('public label computed fails closed', () {
      final result = _consume(_adapter(publicLabelComputed: true));

      _expectBlockedConsumer(result);
      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
      expect(result.consumerContainsPublicLabels, isFalse);
    });

    test('public label non-null fails closed and is not emitted', () {
      final result = _consume(_adapter(publicLabel: 'Brilliant'));

      _expectBlockedConsumer(result);
      _expectForbiddenStringsAbsent(result);
    });

    test('public label string in adapter identity is sanitized', () {
      final result = _consume(
        _adapter(adapterResultId: 'phase36P:Great:blocked'),
      );

      _expectBlockedConsumer(result);
      expect(result.sourceAdapterResultId, 'phase37C:blockedAdapterResult');
      _expectForbiddenStringsAbsent(result);
    });

    test('official metric computed fails closed', () {
      final result = _consume(_adapter(officialCpLossComputed: true));

      _expectBlockedConsumer(result);
      expect(result.officialCpLossComputed, isFalse);
      expect(result.consumerContainsOfficialMetrics, isFalse);
    });

    test('official move quality non-null fails closed and is not emitted', () {
      final result = _consume(_adapter(officialMoveQuality: 'Best'));

      _expectBlockedConsumer(result);
      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
      _expectForbiddenStringsAbsent(result);
    });

    for (final entry in <String, AnalyzerReadOnlyDeveloperPreviewAdapterResult>{
      'saved analysis write': _adapter(savedAnalysisWritten: true),
      'UI output': _adapter(uiOutputProduced: true),
      'persistence write': _adapter(persistenceWritePerformed: true),
      'file write': _adapter(fileWritePerformed: true),
      'backend payload': _adapter(backendPayloadProduced: true),
      'archive stats touch': _adapter(archiveStatsTouched: true),
    }.entries) {
      test('${entry.key} side effect fails closed', () {
        final result = _consume(entry.value);

        _expectBlockedConsumer(result);
      });
    }

    test('consumer remains developer-only and read-only', () {
      final result = _consume(_adapter());

      expect(result.mappingSucceeded, isTrue);
      expect(result.consumerIsDeveloperOnly, isTrue);
      expect(result.consumerIsReadOnly, isTrue);
      expect(result.consumerIsUiOutput, isFalse);
      expect(result.consumerIsDebugUi, isFalse);
      expect(result.consumerIsProductReview, isFalse);
    });

    test(
      'consumer is not UI debug UI product review or persistence output',
      () {
        final result = _consume(_adapter());

        expect(result.consumerIsUiOutput, isFalse);
        expect(result.consumerIsDebugUi, isFalse);
        expect(result.consumerIsProductReview, isFalse);
        expect(result.consumerIsSavedAnalysis, isFalse);
        expect(result.consumerIsPersistenceWrite, isFalse);
        expect(result.consumerIsFileWrite, isFalse);
        expect(result.consumerIsBackendPayload, isFalse);
        expect(result.consumerIsArchiveStatsOutput, isFalse);
        expect(result.savedAnalysisWritten, isFalse);
        expect(result.uiOutputProduced, isFalse);
        expect(result.persistenceWritePerformed, isFalse);
        expect(result.fileWritePerformed, isFalse);
        expect(result.backendPayloadProduced, isFalse);
        expect(result.archiveStatsTouched, isFalse);
      },
    );

    test('consumer never emits public label or official move quality', () {
      final result = _consume(_adapter());

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

    test('safeForPhase37D true only for clean source', () {
      final clean = _consume(_adapter());
      final dirtyProduct = _consume(_adapter(adapterIsProductReview: true));
      final dirtyOfficial = _consume(
        _adapter(officialWinPercentComputed: true),
      );
      final dirtySideEffect = _consume(_adapter(fileWritePerformed: true));

      expect(clean.safeForPhase37D, isTrue);
      expect(dirtyProduct.safeForPhase37D, isFalse);
      expect(dirtyOfficial.safeForPhase37D, isFalse);
      expect(dirtySideEffect.safeForPhase37D, isFalse);
    });

    test('safeForPhase37E true only for clean source', () {
      final clean = _consume(_adapter());
      final dirtyProduct = _consume(_adapter(adapterIsProductReview: true));
      final dirtyOfficial = _consume(
        _adapter(officialWinPercentComputed: true),
      );
      final dirtySideEffect = _consume(_adapter(fileWritePerformed: true));

      expect(clean.safeForPhase37E, isTrue);
      expect(dirtyProduct.safeForPhase37E, isFalse);
      expect(dirtyOfficial.safeForPhase37E, isFalse);
      expect(dirtySideEffect.safeForPhase37E, isFalse);
    });
  });
}

AnalyzerNonUiDeveloperPreviewConsumerResult _consume(
  AnalyzerReadOnlyDeveloperPreviewAdapterResult source,
) {
  return consumeReadOnlyDeveloperPreviewAdapterResult(source);
}

AnalyzerReadOnlyDeveloperPreviewAdapterResult _adapter({
  String adapterResultId = 'phase36P:safe:readOnlyDeveloperPreview',
  String sourceDebugPreviewContractId = 'phase36N:safe:debugPreview',
  String adapterSource = analyzerReadOnlyDeveloperPreviewAdapterSource,
  String adapterVersion = analyzerReadOnlyDeveloperPreviewAdapterVersion,
  bool adapterComputed = true,
  bool previewReady = true,
  AnalyzerReadOnlyDeveloperPreviewUnavailableReason previewUnavailableReason =
      AnalyzerReadOnlyDeveloperPreviewUnavailableReason.none,
  int totalPrivateEntries = 1,
  int positiveCandidateCount = 1,
  int neutralCandidateCount = 0,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  bool adapterIsDeveloperOnly = true,
  bool adapterIsReadOnly = true,
  bool adapterIsUiOutput = false,
  bool adapterIsProductReview = false,
  bool adapterIsSavedAnalysis = false,
  bool adapterIsPersistenceWrite = false,
  bool adapterIsBackendPayload = false,
  bool adapterIsArchiveStatsOutput = false,
  bool adapterContainsPublicLabels = false,
  bool adapterContainsOfficialMetrics = false,
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
  bool persistenceWritePerformed = false,
  bool fileWritePerformed = false,
  bool backendPayloadProduced = false,
  bool archiveStatsTouched = false,
  bool mappingSucceeded = true,
  String? failureMessage,
  bool safeForPhase37A = true,
  bool safeForPhase37B = true,
  String nextRecommendation =
      analyzerReadOnlyDeveloperPreviewAdapterNextRecommendation,
}) {
  return AnalyzerReadOnlyDeveloperPreviewAdapterResult(
    adapterResultId: adapterResultId,
    sourceDebugPreviewContractId: sourceDebugPreviewContractId,
    adapterSource: adapterSource,
    adapterVersion: adapterVersion,
    adapterComputed: adapterComputed,
    previewReady: previewReady,
    previewUnavailableReason: previewUnavailableReason,
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
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
    failureMessage: failureMessage,
    safeForPhase37A: safeForPhase37A,
    safeForPhase37B: safeForPhase37B,
    nextRecommendation: nextRecommendation,
  );
}

void _expectBlockedConsumer(
  AnalyzerNonUiDeveloperPreviewConsumerResult result,
) {
  expect(result.mappingSucceeded, isFalse);
  expect(result.consumerComputed, isFalse);
  expect(result.consumerReady, isFalse);
  expect(result.safeForPhase37D, isFalse);
  expect(result.safeForPhase37E, isFalse);
  expect(
    result.nextRecommendation,
    analyzerNonUiDeveloperPreviewConsumerFailureRecommendation,
  );
  expect(
    result.consumerUnavailableReason,
    isNot(AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason.none),
  );
  expect(result.failureMessage, isNotNull);
  _expectNoPublicOfficialOrSideEffectOutput(result);
  _expectNoProductOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectNoPublicOfficialOrSideEffectOutput(
  AnalyzerNonUiDeveloperPreviewConsumerResult result,
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
  AnalyzerNonUiDeveloperPreviewConsumerResult result,
) {
  expect(result.consumerIsUiOutput, isFalse);
  expect(result.consumerIsDebugUi, isFalse);
  expect(result.consumerIsProductReview, isFalse);
  expect(result.consumerIsSavedAnalysis, isFalse);
  expect(result.consumerIsPersistenceWrite, isFalse);
  expect(result.consumerIsFileWrite, isFalse);
  expect(result.consumerIsBackendPayload, isFalse);
  expect(result.consumerIsArchiveStatsOutput, isFalse);
  expect(result.consumerContainsPublicLabels, isFalse);
  expect(result.consumerContainsOfficialMetrics, isFalse);
}

void _expectForbiddenStringsAbsent(
  AnalyzerNonUiDeveloperPreviewConsumerResult result,
) {
  final exposed = <String?>{
    result.consumerResultId,
    result.sourceAdapterResultId,
    result.consumerSource,
    result.consumerUnavailableReason.wire,
    result.publicLabel,
    result.officialMoveQuality,
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
