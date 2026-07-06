import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluateProductSafeReviewGateway', () {
    test('clean product-safe contract allows product review planning only', () {
      final result = _evaluate(_contract());

      expect(result.gatewayComputed, isTrue);
      expect(result.gatewayAllowsProductReviewPlanning, isTrue);
      expect(result.gatewayAllowsUiRendering, isFalse);
      expect(result.gatewayAllowsSavedAnalysis, isFalse);
      expect(result.gatewayAllowsArchiveStats, isFalse);
      expect(result.gatewayAllowsPublicLabels, isFalse);
      expect(result.gatewayAllowsOfficialMetrics, isFalse);
      expect(
        result.gatewayReason,
        AnalyzerProductSafeReviewGatewayReason.productSafeContractReady,
      );
      expect(result.safeForPhase38E, isTrue);
      expect(
        result.nextRecommendation,
        analyzerProductSafeReviewGatewayNextRecommendation,
      );
    });

    test('clean source does not allow UI rendering', () {
      final result = _evaluate(_contract());

      expect(result.gatewayComputed, isTrue);
      expect(result.gatewayAllowsUiRendering, isFalse);
    });

    test(
      'clean source does not allow saved archive labels or official metrics',
      () {
        final result = _evaluate(_contract());

        expect(result.gatewayComputed, isTrue);
        expect(result.gatewayAllowsSavedAnalysis, isFalse);
        expect(result.gatewayAllowsArchiveStats, isFalse);
        expect(result.gatewayAllowsPublicLabels, isFalse);
        expect(result.gatewayAllowsOfficialMetrics, isFalse);
      },
    );

    test('counts are copied exactly', () {
      final source = _contract(
        totalPrivateEntries: 9,
        positiveCandidateCount: 4,
        neutralCandidateCount: 3,
        negativeCandidateCount: 1,
        unavailableCount: 1,
      );
      final result = _evaluate(source);

      expect(result.gatewayComputed, isTrue);
      expect(result.totalPrivateEntries, source.totalPrivateEntries);
      expect(result.positiveCandidateCount, source.positiveCandidateCount);
      expect(result.neutralCandidateCount, source.neutralCandidateCount);
      expect(result.negativeCandidateCount, source.negativeCandidateCount);
      expect(result.unavailableCount, source.unavailableCount);
      expect(result.sourceContractId, source.productSafeReviewContractId);
    });

    test('gateway imports only product-safe review contract source', () {
      final source = File(
        'lib/features/analysis/domain/'
        'analyzer_product_safe_review_gateway.dart',
      ).readAsStringSync();

      expect(source, contains('analyzer_product_safe_review_contract.dart'));
      expect(source, isNot(contains('analyzer_non_ui_developer_preview')));
      expect(
        source,
        isNot(contains('analyzer_product_safe_review_contract_mapper')),
      );
      expect(source, isNot(contains('local_analyzer')));
      expect(source, isNot(contains('ReviewController')));
      expect(source, isNot(contains('ReviewScreen')));
      expect(source, isNot(contains('MoveClassifier')));
    });

    test('unsafe source fails closed', () {
      final result = _evaluate(
        _contract(
          contractComputed: false,
          reviewReady: false,
          reviewUnavailableReason:
              AnalyzerProductSafeReviewUnavailableReason.sourceUnavailable,
          mappingSucceeded: false,
          safeForPhase38D: false,
        ),
      );

      _expectBlockedGateway(result);
      expect(
        result.gatewayReason,
        AnalyzerProductSafeReviewGatewayReason.sourceUnavailable,
      );
    });

    for (final entry in <String, AnalyzerProductSafeReviewContract>{
      'public labels present': _contract(contractContainsPublicLabels: true),
      'public label computed': _contract(publicLabelComputed: true),
      'public label non-null': _contract(publicLabel: 'Brilliant'),
    }.entries) {
      test('${entry.key} fails closed', () {
        final result = _evaluate(entry.value);

        _expectBlockedGateway(result);
        expect(
          result.gatewayReason,
          AnalyzerProductSafeReviewGatewayReason.publicLabelsBlocked,
        );
      });
    }

    for (final entry in <String, AnalyzerProductSafeReviewContract>{
      'official metrics present': _contract(
        contractContainsOfficialMetrics: true,
      ),
      'official move quality computed': _contract(
        officialMoveQualityComputed: true,
      ),
      'official move quality non-null': _contract(officialMoveQuality: 'Best'),
      'official CP-loss computed': _contract(officialCpLossComputed: true),
      'official Win% computed': _contract(officialWinPercentComputed: true),
      'accuracy computed': _contract(accuracyComputed: true),
      'ACPL computed': _contract(acplComputed: true),
      'classification computed': _contract(classificationComputed: true),
      'public classifier output': _contract(
        publicClassifierOutputComputed: true,
      ),
    }.entries) {
      test('${entry.key} fails closed', () {
        final result = _evaluate(entry.value);

        _expectBlockedGateway(result);
        expect(
          result.gatewayReason,
          AnalyzerProductSafeReviewGatewayReason.officialMetricsBlocked,
        );
      });
    }

    for (final entry in <String, AnalyzerProductSafeReviewContract>{
      'UI output': _contract(contractIsUiOutput: true),
      'product UI': _contract(contractIsProductUi: true),
      'UI presentation': _contract(contractContainsUiPresentation: true),
      'persistence write': _contract(contractIsPersistenceWrite: true),
      'file write': _contract(contractIsFileWrite: true),
      'backend output': _contract(contractIsBackendPayload: true),
      'archive stats output': _contract(contractIsArchiveStatsOutput: true),
    }.entries) {
      test('${entry.key} flag fails closed', () {
        final result = _evaluate(entry.value);

        _expectBlockedGateway(result);
      });
    }

    for (final entry in <String, AnalyzerProductSafeReviewContract>{
      'saved analysis write': _contract(savedAnalysisWritten: true),
      'UI output side effect': _contract(uiOutputProduced: true),
      'persistence write side effect': _contract(
        persistenceWritePerformed: true,
      ),
      'file write side effect': _contract(fileWritePerformed: true),
      'backend output side effect': _contract(backendPayloadProduced: true),
      'archive stats touch': _contract(archiveStatsTouched: true),
    }.entries) {
      test('${entry.key} fails closed', () {
        final result = _evaluate(entry.value);

        _expectBlockedGateway(result);
      });
    }

    test('saved analysis source fails closed', () {
      final result = _evaluate(_contract(contractIsSavedAnalysis: true));

      _expectBlockedGateway(result);
      expect(
        result.gatewayReason,
        AnalyzerProductSafeReviewGatewayReason.savedAnalysisBlocked,
      );
    });

    test('archive stats source fails closed', () {
      final result = _evaluate(_contract(contractIsArchiveStatsOutput: true));

      _expectBlockedGateway(result);
      expect(
        result.gatewayReason,
        AnalyzerProductSafeReviewGatewayReason.archiveStatsBlocked,
      );
    });

    test('safeForPhase38E true only for clean source', () {
      final clean = _evaluate(_contract());
      final dirtySource = _evaluate(_contract(safeForPhase38D: false));
      final dirtyPublic = _evaluate(_contract(publicLabelComputed: true));
      final dirtyOfficial = _evaluate(_contract(officialCpLossComputed: true));
      final dirtySideEffect = _evaluate(_contract(fileWritePerformed: true));

      expect(clean.safeForPhase38E, isTrue);
      expect(dirtySource.safeForPhase38E, isFalse);
      expect(dirtyPublic.safeForPhase38E, isFalse);
      expect(dirtyOfficial.safeForPhase38E, isFalse);
      expect(dirtySideEffect.safeForPhase38E, isFalse);
    });
  });
}

AnalyzerProductSafeReviewGatewayDecision _evaluate(
  AnalyzerProductSafeReviewContract source,
) {
  return evaluateProductSafeReviewGateway(source);
}

AnalyzerProductSafeReviewContract _contract({
  String productSafeReviewContractId = 'phase38B:safe:productSafeReview',
  String sourceConsumerResultId = 'phase37D:safe:nonUiConsumer',
  String contractSource = analyzerProductSafeReviewContractSource,
  String contractVersion = analyzerProductSafeReviewContractVersion,
  bool contractComputed = true,
  bool reviewReady = true,
  AnalyzerProductSafeReviewUnavailableReason reviewUnavailableReason =
      AnalyzerProductSafeReviewUnavailableReason.none,
  AnalyzerProductSafeReviewScope reviewScope =
      AnalyzerProductSafeReviewScope.singleMoveControlled,
  int requestedDepth = 1,
  AnalyzerProductSafeReviewEvidenceStrength evidenceStrength =
      AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
  int totalPrivateEntries = 1,
  int positiveCandidateCount = 1,
  int neutralCandidateCount = 0,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  bool privateCountsAreInternalOnly = true,
  bool contractIsProductSafe = true,
  bool contractIsDeveloperEvidenceBacked = true,
  bool contractIsReadOnly = true,
  bool contractIsUiOutput = false,
  bool contractIsProductUi = false,
  bool contractIsSavedAnalysis = false,
  bool contractIsPersistenceWrite = false,
  bool contractIsFileWrite = false,
  bool contractIsBackendPayload = false,
  bool contractIsArchiveStatsOutput = false,
  bool contractContainsPublicLabels = false,
  bool contractContainsOfficialMetrics = false,
  bool contractContainsUiPresentation = false,
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
  bool safeForPhase38C = true,
  bool safeForPhase38D = true,
  String nextRecommendation =
      analyzerProductSafeReviewContractNextRecommendation,
}) {
  return AnalyzerProductSafeReviewContract(
    productSafeReviewContractId: productSafeReviewContractId,
    sourceConsumerResultId: sourceConsumerResultId,
    contractSource: contractSource,
    contractVersion: contractVersion,
    contractComputed: contractComputed,
    reviewReady: reviewReady,
    reviewUnavailableReason: reviewUnavailableReason,
    reviewScope: reviewScope,
    requestedDepth: requestedDepth,
    evidenceStrength: evidenceStrength,
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    privateCountsAreInternalOnly: privateCountsAreInternalOnly,
    contractIsProductSafe: contractIsProductSafe,
    contractIsDeveloperEvidenceBacked: contractIsDeveloperEvidenceBacked,
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
    failureMessage: failureMessage,
    safeForPhase38C: safeForPhase38C,
    safeForPhase38D: safeForPhase38D,
    nextRecommendation: nextRecommendation,
  );
}

void _expectBlockedGateway(AnalyzerProductSafeReviewGatewayDecision result) {
  expect(result.gatewayComputed, isFalse);
  expect(result.gatewayAllowsProductReviewPlanning, isFalse);
  expect(result.gatewayAllowsUiRendering, isFalse);
  expect(result.gatewayAllowsSavedAnalysis, isFalse);
  expect(result.gatewayAllowsArchiveStats, isFalse);
  expect(result.gatewayAllowsPublicLabels, isFalse);
  expect(result.gatewayAllowsOfficialMetrics, isFalse);
  expect(result.safeForPhase38E, isFalse);
  expect(
    result.nextRecommendation,
    analyzerProductSafeReviewGatewayFailureRecommendation,
  );
  expect(
    result.gatewayReason,
    isNot(AnalyzerProductSafeReviewGatewayReason.productSafeContractReady),
  );
}
