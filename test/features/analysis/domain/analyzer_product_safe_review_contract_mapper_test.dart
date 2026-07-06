import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_non_ui_developer_preview_consumer.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapProductSafeReviewContractFromConsumer', () {
    test('valid consumer maps to reviewReady true', () {
      final result = _map(_consumer());

      expect(result.mappingSucceeded, isTrue);
      expect(result.contractComputed, isTrue);
      expect(result.reviewReady, isTrue);
      expect(
        result.reviewUnavailableReason,
        AnalyzerProductSafeReviewUnavailableReason.none,
      );
      expect(result.contractIsProductSafe, isTrue);
      expect(result.contractIsDeveloperEvidenceBacked, isTrue);
      expect(result.safeForPhase38C, isTrue);
      expect(result.safeForPhase38D, isTrue);
      expect(
        result.nextRecommendation,
        analyzerProductSafeReviewContractNextRecommendation,
      );
    });

    test('safe counts are copied exactly from consumer result', () {
      final source = _consumer(
        totalPrivateEntries: 13,
        positiveCandidateCount: 5,
        neutralCandidateCount: 4,
        negativeCandidateCount: 3,
        unavailableCount: 1,
      );
      final result = _map(source);

      expect(result.mappingSucceeded, isTrue);
      expect(result.totalPrivateEntries, source.totalPrivateEntries);
      expect(result.positiveCandidateCount, source.positiveCandidateCount);
      expect(result.neutralCandidateCount, source.neutralCandidateCount);
      expect(result.negativeCandidateCount, source.negativeCandidateCount);
      expect(result.unavailableCount, source.unavailableCount);
    });

    test('private counts are internal only', () {
      final result = _map(_consumer());

      expect(result.mappingSucceeded, isTrue);
      expect(result.privateCountsAreInternalOnly, isTrue);
      expect(result.contractContainsPublicLabels, isFalse);
      expect(result.contractContainsOfficialMetrics, isFalse);
    });

    test('review scope is singleMoveControlled', () {
      final result = _map(_consumer());

      expect(result.mappingSucceeded, isTrue);
      expect(
        result.reviewScope,
        AnalyzerProductSafeReviewScope.singleMoveControlled,
      );
    });

    test('evidence strength is developerProofOnly for clean source', () {
      final result = _map(_consumer());

      expect(result.mappingSucceeded, isTrue);
      expect(
        result.evidenceStrength,
        AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
      );
      expect(result.requestedDepth, 1);
    });

    test('contract imports only the non-UI consumer and contract model', () {
      final source = File(
        'lib/features/analysis/domain/'
        'analyzer_product_safe_review_contract_mapper.dart',
      ).readAsStringSync();

      expect(
        source,
        contains('analyzer_non_ui_developer_preview_consumer.dart'),
      );
      expect(source, contains('analyzer_product_safe_review_contract.dart'));
      expect(source, isNot(contains('analyzer_developer_debug_preview')));
      expect(source, isNot(contains('debug_read_facade')));
      expect(source, isNot(contains('snapshot')));
      expect(source, isNot(contains('LegacyReintegration')));
      expect(source, isNot(contains('MoveClassifier')));
      expect(source, isNot(contains('LocalGameAnalyzer')));
      expect(source, isNot(contains('CloudGameAnalyzer')));
    });

    test('non-ready consumer fails closed', () {
      final result = _map(
        _consumer(
          mappingSucceeded: false,
          consumerComputed: false,
          consumerReady: false,
          consumerUnavailableReason:
              AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason
                  .sourceUnavailable,
          safeForPhase37D: false,
          safeForPhase37E: false,
        ),
      );

      _expectBlockedContract(result);
      expect(
        result.reviewUnavailableReason,
        AnalyzerProductSafeReviewUnavailableReason.sourceUnavailable,
      );
    });

    for (final entry in <String, AnalyzerNonUiDeveloperPreviewConsumerResult>{
      'UI source': _consumer(consumerIsUiOutput: true),
      'debug UI source': _consumer(consumerIsDebugUi: true),
      'product review source': _consumer(consumerIsProductReview: true),
      'saved analysis source': _consumer(consumerIsSavedAnalysis: true),
      'persistence source': _consumer(consumerIsPersistenceWrite: true),
      'file source': _consumer(consumerIsFileWrite: true),
      'backend source': _consumer(consumerIsBackendPayload: true),
      'archive stats source': _consumer(consumerIsArchiveStatsOutput: true),
    }.entries) {
      test('${entry.key} fails closed', () {
        final result = _map(entry.value);

        _expectBlockedContract(result);
      });
    }

    test('public label computed fails closed', () {
      final result = _map(_consumer(publicLabelComputed: true));

      _expectBlockedContract(result);
      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
      expect(result.contractContainsPublicLabels, isFalse);
    });

    test('public label non-null fails closed and is not emitted', () {
      final result = _map(_consumer(publicLabel: 'Brilliant'));

      _expectBlockedContract(result);
      _expectForbiddenStringsAbsent(result);
    });

    test('public label string in consumer identity is sanitized', () {
      final result = _map(_consumer(consumerResultId: 'phase37D:Great:bad'));

      _expectBlockedContract(result);
      expect(result.sourceConsumerResultId, 'phase38B:blockedConsumerResult');
      _expectForbiddenStringsAbsent(result);
    });

    test('official metric computed fails closed', () {
      final result = _map(_consumer(officialWinPercentComputed: true));

      _expectBlockedContract(result);
      expect(result.officialWinPercentComputed, isFalse);
      expect(result.contractContainsOfficialMetrics, isFalse);
    });

    test('official move quality non-null fails closed and is not emitted', () {
      final result = _map(_consumer(officialMoveQuality: 'Best'));

      _expectBlockedContract(result);
      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
      _expectForbiddenStringsAbsent(result);
    });

    for (final entry in <String, AnalyzerNonUiDeveloperPreviewConsumerResult>{
      'saved analysis write': _consumer(savedAnalysisWritten: true),
      'UI output': _consumer(uiOutputProduced: true),
      'persistence write': _consumer(persistenceWritePerformed: true),
      'file write': _consumer(fileWritePerformed: true),
      'backend payload': _consumer(backendPayloadProduced: true),
      'archive stats touch': _consumer(archiveStatsTouched: true),
    }.entries) {
      test('${entry.key} side effect fails closed', () {
        final result = _map(entry.value);

        _expectBlockedContract(result);
      });
    }

    test('unsupported private count scope fails closed', () {
      final result = _map(
        _consumer(
          totalPrivateEntries: 3,
          positiveCandidateCount: 1,
          neutralCandidateCount: 0,
          negativeCandidateCount: 0,
          unavailableCount: 0,
        ),
      );

      _expectBlockedContract(result);
      expect(
        result.reviewUnavailableReason,
        AnalyzerProductSafeReviewUnavailableReason.unsupportedScope,
      );
    });

    test('contract never emits public label or official move quality', () {
      final result = _map(_consumer());

      expect(result.mappingSucceeded, isTrue);
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

    test('contract contains no UI presentation', () {
      final result = _map(_consumer());

      expect(result.mappingSucceeded, isTrue);
      expect(result.contractIsUiOutput, isFalse);
      expect(result.contractIsProductUi, isFalse);
      expect(result.contractContainsUiPresentation, isFalse);
      expect(result.uiOutputProduced, isFalse);
    });

    test('contract remains read-only', () {
      final result = _map(_consumer());

      expect(result.mappingSucceeded, isTrue);
      expect(result.contractIsReadOnly, isTrue);
      expect(result.contractIsPersistenceWrite, isFalse);
      expect(result.contractIsFileWrite, isFalse);
      expect(result.persistenceWritePerformed, isFalse);
      expect(result.fileWritePerformed, isFalse);
    });

    test('contract does not represent saved analysis', () {
      final result = _map(_consumer());

      expect(result.mappingSucceeded, isTrue);
      expect(result.contractIsSavedAnalysis, isFalse);
      expect(result.savedAnalysisWritten, isFalse);
    });

    test('contract does not represent archive or stats output', () {
      final result = _map(_consumer());

      expect(result.mappingSucceeded, isTrue);
      expect(result.contractIsArchiveStatsOutput, isFalse);
      expect(result.archiveStatsTouched, isFalse);
    });

    test('safeForPhase38C and safeForPhase38D true only for clean source', () {
      final clean = _map(_consumer());
      final dirtyProduct = _map(_consumer(consumerIsProductReview: true));
      final dirtyOfficial = _map(_consumer(officialCpLossComputed: true));
      final dirtySideEffect = _map(_consumer(fileWritePerformed: true));

      expect(clean.safeForPhase38C, isTrue);
      expect(clean.safeForPhase38D, isTrue);
      expect(dirtyProduct.safeForPhase38C, isFalse);
      expect(dirtyProduct.safeForPhase38D, isFalse);
      expect(dirtyOfficial.safeForPhase38C, isFalse);
      expect(dirtyOfficial.safeForPhase38D, isFalse);
      expect(dirtySideEffect.safeForPhase38C, isFalse);
      expect(dirtySideEffect.safeForPhase38D, isFalse);
    });
  });
}

AnalyzerProductSafeReviewContract _map(
  AnalyzerNonUiDeveloperPreviewConsumerResult source,
) {
  return mapProductSafeReviewContractFromConsumer(source);
}

AnalyzerNonUiDeveloperPreviewConsumerResult _consumer({
  String consumerResultId = 'phase37D:safe:nonUiConsumer',
  String sourceAdapterResultId = 'phase37A:safe:adapter',
  String consumerSource = analyzerNonUiDeveloperPreviewConsumerSource,
  String consumerVersion = analyzerNonUiDeveloperPreviewConsumerVersion,
  bool consumerComputed = true,
  bool consumerReady = true,
  AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason
      consumerUnavailableReason =
      AnalyzerNonUiDeveloperPreviewConsumerUnavailableReason.none,
  int totalPrivateEntries = 1,
  int positiveCandidateCount = 1,
  int neutralCandidateCount = 0,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  bool consumerIsDeveloperOnly = true,
  bool consumerIsReadOnly = true,
  bool consumerIsUiOutput = false,
  bool consumerIsDebugUi = false,
  bool consumerIsProductReview = false,
  bool consumerIsSavedAnalysis = false,
  bool consumerIsPersistenceWrite = false,
  bool consumerIsFileWrite = false,
  bool consumerIsBackendPayload = false,
  bool consumerIsArchiveStatsOutput = false,
  bool consumerContainsPublicLabels = false,
  bool consumerContainsOfficialMetrics = false,
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
  bool safeForPhase37D = true,
  bool safeForPhase37E = true,
  String nextRecommendation =
      analyzerNonUiDeveloperPreviewConsumerNextRecommendation,
}) {
  return AnalyzerNonUiDeveloperPreviewConsumerResult(
    consumerResultId: consumerResultId,
    sourceAdapterResultId: sourceAdapterResultId,
    consumerSource: consumerSource,
    consumerVersion: consumerVersion,
    consumerComputed: consumerComputed,
    consumerReady: consumerReady,
    consumerUnavailableReason: consumerUnavailableReason,
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    consumerIsDeveloperOnly: consumerIsDeveloperOnly,
    consumerIsReadOnly: consumerIsReadOnly,
    consumerIsUiOutput: consumerIsUiOutput,
    consumerIsDebugUi: consumerIsDebugUi,
    consumerIsProductReview: consumerIsProductReview,
    consumerIsSavedAnalysis: consumerIsSavedAnalysis,
    consumerIsPersistenceWrite: consumerIsPersistenceWrite,
    consumerIsFileWrite: consumerIsFileWrite,
    consumerIsBackendPayload: consumerIsBackendPayload,
    consumerIsArchiveStatsOutput: consumerIsArchiveStatsOutput,
    consumerContainsPublicLabels: consumerContainsPublicLabels,
    consumerContainsOfficialMetrics: consumerContainsOfficialMetrics,
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
    safeForPhase37D: safeForPhase37D,
    safeForPhase37E: safeForPhase37E,
    nextRecommendation: nextRecommendation,
  );
}

void _expectBlockedContract(AnalyzerProductSafeReviewContract result) {
  expect(result.mappingSucceeded, isFalse);
  expect(result.contractComputed, isFalse);
  expect(result.reviewReady, isFalse);
  expect(result.safeForPhase38C, isFalse);
  expect(result.safeForPhase38D, isFalse);
  expect(
    result.nextRecommendation,
    analyzerProductSafeReviewContractFailureRecommendation,
  );
  expect(
    result.reviewUnavailableReason,
    isNot(AnalyzerProductSafeReviewUnavailableReason.none),
  );
  expect(result.failureMessage, isNotNull);
  _expectNoPublicOfficialOrSideEffectOutput(result);
  _expectNoProductOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectNoPublicOfficialOrSideEffectOutput(
  AnalyzerProductSafeReviewContract result,
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

void _expectNoProductOutput(AnalyzerProductSafeReviewContract result) {
  expect(result.contractIsUiOutput, isFalse);
  expect(result.contractIsProductUi, isFalse);
  expect(result.contractIsSavedAnalysis, isFalse);
  expect(result.contractIsPersistenceWrite, isFalse);
  expect(result.contractIsFileWrite, isFalse);
  expect(result.contractIsBackendPayload, isFalse);
  expect(result.contractIsArchiveStatsOutput, isFalse);
  expect(result.contractContainsPublicLabels, isFalse);
  expect(result.contractContainsOfficialMetrics, isFalse);
  expect(result.contractContainsUiPresentation, isFalse);
}

void _expectForbiddenStringsAbsent(AnalyzerProductSafeReviewContract result) {
  final exposed = <String?>{
    result.productSafeReviewContractId,
    result.sourceConsumerResultId,
    result.contractSource,
    result.contractVersion,
    result.reviewUnavailableReason.wire,
    result.reviewScope.wire,
    result.evidenceStrength.wire,
    result.publicLabel,
    result.officialMoveQuality,
    result.failureMessage,
    result.nextRecommendation,
  }.whereType<String>();

  for (final value in exposed) {
    for (final forbidden in _forbiddenOutputStrings) {
      expect(value.contains(forbidden), isFalse, reason: value);
    }
  }
}

const _forbiddenOutputStrings = {
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
  'officialCpLoss',
  'officialWinPercent',
  'accuracy',
  'acpl',
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
