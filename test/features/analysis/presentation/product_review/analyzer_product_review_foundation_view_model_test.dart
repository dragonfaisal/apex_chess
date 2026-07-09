import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_gateway.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_foundation_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapProductReviewFoundationViewModelFromGateway', () {
    test('clean gateway maps to planning-ready foundation', () {
      final result = mapProductReviewFoundationViewModelFromGateway(_gateway());

      expect(result.foundationComputed, isTrue);
      expect(result.foundationReadyForPlanning, isTrue);
      expect(
        result.unavailableReason,
        AnalyzerNeutralReviewPreviewUnavailableReason.none,
      );
      expect(result.title, 'Review foundation');
      expect(result.statusText, 'Ready for product review planning');
      expect(
        result.reviewScope,
        AnalyzerProductSafeReviewScope.singleMoveControlled,
      );
      expect(
        result.evidenceStrength,
        AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
      );
      expect(result.planningAllowed, isTrue);
      expect(result.safeForPhase40B, isTrue);
      expect(
        result.nextRecommendation,
        analyzerProductReviewFoundationNextRecommendation,
      );
    });

    test('copies neutral private counts exactly', () {
      final result = mapProductReviewFoundationViewModelFromGateway(
        _gateway(
          totalPrivateEntries: 9,
          positiveCandidateCount: 4,
          neutralCandidateCount: 3,
          negativeCandidateCount: 1,
          unavailableCount: 1,
        ),
      );

      expect(result.totalPrivateEntries, 9);
      expect(result.positiveCandidateCount, 4);
      expect(result.neutralCandidateCount, 3);
      expect(result.negativeCandidateCount, 1);
      expect(result.unavailableCount, 1);
      expect(result.privateCountsAreInternalOnly, isTrue);
    });

    test('keeps product UI saved archive labels and metrics blocked', () {
      final result = mapProductReviewFoundationViewModelFromGateway(_gateway());

      expect(result.uiRenderingAllowed, isFalse);
      expect(result.savedAnalysisAllowed, isFalse);
      expect(result.archiveStatsAllowed, isFalse);
      expect(result.publicLabelsAllowed, isFalse);
      expect(result.officialMetricsAllowed, isFalse);
      expect(result.foundationContainsPublicLabels, isFalse);
      expect(result.foundationContainsOfficialMetrics, isFalse);
    });

    test('fails closed when gateway is not computed', () {
      final result = mapProductReviewFoundationViewModelFromGateway(
        _gateway(
          gatewayComputed: false,
          gatewayAllowsProductReviewPlanning: false,
          gatewayReason: AnalyzerProductSafeReviewGatewayReason.sourceUnsafe,
          safeForPhase38E: false,
        ),
      );

      _expectBlocked(result);
      expect(
        result.unavailableReason,
        AnalyzerNeutralReviewPreviewUnavailableReason.gatewayNotComputed,
      );
    });

    for (final entry
        in <String, AnalyzerProductSafeReviewGatewayDecision Function()>{
          'UI rendering': () => _gateway(gatewayAllowsUiRendering: true),
          'saved analysis': () => _gateway(gatewayAllowsSavedAnalysis: true),
          'archive stats': () => _gateway(gatewayAllowsArchiveStats: true),
          'public labels': () => _gateway(gatewayAllowsPublicLabels: true),
          'official metrics': () =>
              _gateway(gatewayAllowsOfficialMetrics: true),
          'unsafe phase gate': () => _gateway(safeForPhase38E: false),
        }.entries) {
      test('fails closed when ${entry.key} is allowed or unsafe', () {
        final result = mapProductReviewFoundationViewModelFromGateway(
          entry.value(),
        );

        _expectBlocked(result);
      });
    }

    test('safeForPhase40B is true only for clean gateway', () {
      final clean = mapProductReviewFoundationViewModelFromGateway(_gateway());
      final dirtyUi = mapProductReviewFoundationViewModelFromGateway(
        _gateway(gatewayAllowsUiRendering: true),
      );
      final dirtyPublic = mapProductReviewFoundationViewModelFromGateway(
        _gateway(gatewayAllowsPublicLabels: true),
      );
      final dirtyOfficial = mapProductReviewFoundationViewModelFromGateway(
        _gateway(gatewayAllowsOfficialMetrics: true),
      );

      expect(clean.safeForPhase40B, isTrue);
      expect(dirtyUi.safeForPhase40B, isFalse);
      expect(dirtyPublic.safeForPhase40B, isFalse);
      expect(dirtyOfficial.safeForPhase40B, isFalse);
    });
  });

  group('mapProductReviewFoundationViewModelFromContract', () {
    test(
      'composes the existing product-safe gateway from a clean contract',
      () {
        final result = mapProductReviewFoundationViewModelFromContract(
          _contract(),
        );

        expect(result.foundationComputed, isTrue);
        expect(result.foundationReadyForPlanning, isTrue);
        expect(result.sourceContractId, 'phase38B:test:contract');
        expect(
          result.reviewScope,
          AnalyzerProductSafeReviewScope.singleMoveControlled,
        );
        expect(
          result.evidenceStrength,
          AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
        );
        expect(result.totalPrivateEntries, 7);
        expect(result.positiveCandidateCount, 3);
        expect(result.neutralCandidateCount, 2);
        expect(result.negativeCandidateCount, 1);
        expect(result.unavailableCount, 1);
        expect(result.safeForPhase40B, isTrue);
      },
    );

    test(
      'fails closed through gateway when contract exposes public labels',
      () {
        final result = mapProductReviewFoundationViewModelFromContract(
          _contract(publicLabelComputed: true),
        );

        _expectBlocked(result);
        expect(
          result.unavailableReason,
          AnalyzerNeutralReviewPreviewUnavailableReason.gatewayNotComputed,
        );
      },
    );
  });

  group('source boundary', () {
    test(
      'uses existing gateway and neutral mapper without review UI imports',
      () {
        final source = File(
          'lib/features/analysis/presentation/product_review/'
          'analyzer_product_review_foundation_view_model.dart',
        ).readAsStringSync();

        expect(source, contains('evaluateProductSafeReviewGateway'));
        expect(
          source,
          contains('mapNeutralReviewPreviewDisplayModelFromGateway'),
        );
        expect(source, isNot(contains('ReviewController')));
        expect(source, isNot(contains('ReviewScreen')));
        expect(source, isNot(contains('ReviewSummaryScreen')));
        expect(source, isNot(contains('HomeScreen')));
        expect(source, isNot(contains('MoveQuality')));
        expect(source, isNot(contains('savedAnalysisId')));
        expect(source, isNot(contains('archiveId')));
        expect(source, isNot(contains('backend')));
        expect(source, isNot(contains('Hive')));
      },
    );
  });
}

AnalyzerProductSafeReviewGatewayDecision _gateway({
  bool gatewayComputed = true,
  bool gatewayAllowsProductReviewPlanning = true,
  bool gatewayAllowsUiRendering = false,
  bool gatewayAllowsSavedAnalysis = false,
  bool gatewayAllowsArchiveStats = false,
  bool gatewayAllowsPublicLabels = false,
  bool gatewayAllowsOfficialMetrics = false,
  AnalyzerProductSafeReviewGatewayReason gatewayReason =
      AnalyzerProductSafeReviewGatewayReason.productSafeContractReady,
  int totalPrivateEntries = 7,
  int positiveCandidateCount = 3,
  int neutralCandidateCount = 2,
  int negativeCandidateCount = 1,
  int unavailableCount = 1,
  String sourceContractId = 'phase38B:test:contract',
  bool safeForPhase38E = true,
  String nextRecommendation =
      analyzerProductSafeReviewGatewayNextRecommendation,
}) {
  return AnalyzerProductSafeReviewGatewayDecision(
    gatewayComputed: gatewayComputed,
    gatewayAllowsProductReviewPlanning: gatewayAllowsProductReviewPlanning,
    gatewayAllowsUiRendering: gatewayAllowsUiRendering,
    gatewayAllowsSavedAnalysis: gatewayAllowsSavedAnalysis,
    gatewayAllowsArchiveStats: gatewayAllowsArchiveStats,
    gatewayAllowsPublicLabels: gatewayAllowsPublicLabels,
    gatewayAllowsOfficialMetrics: gatewayAllowsOfficialMetrics,
    gatewayReason: gatewayReason,
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    sourceContractId: sourceContractId,
    safeForPhase38E: safeForPhase38E,
    nextRecommendation: nextRecommendation,
  );
}

AnalyzerProductSafeReviewContract _contract({
  bool publicLabelComputed = false,
  String? publicLabel,
}) {
  return AnalyzerProductSafeReviewContract(
    productSafeReviewContractId: 'phase38B:test:contract',
    sourceConsumerResultId: 'phase37C:test:consumer',
    contractSource: analyzerProductSafeReviewContractSource,
    contractVersion: analyzerProductSafeReviewContractVersion,
    contractComputed: true,
    reviewReady: true,
    reviewUnavailableReason: AnalyzerProductSafeReviewUnavailableReason.none,
    reviewScope: AnalyzerProductSafeReviewScope.singleMoveControlled,
    requestedDepth: 1,
    evidenceStrength:
        AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
    totalPrivateEntries: 7,
    positiveCandidateCount: 3,
    neutralCandidateCount: 2,
    negativeCandidateCount: 1,
    unavailableCount: 1,
    privateCountsAreInternalOnly: true,
    contractIsProductSafe: true,
    contractIsDeveloperEvidenceBacked: true,
    contractIsReadOnly: true,
    contractIsUiOutput: false,
    contractIsProductUi: false,
    contractIsSavedAnalysis: false,
    contractIsPersistenceWrite: false,
    contractIsFileWrite: false,
    contractIsBackendPayload: false,
    contractIsArchiveStatsOutput: false,
    contractContainsPublicLabels: publicLabelComputed || publicLabel != null,
    contractContainsOfficialMetrics: false,
    contractContainsUiPresentation: false,
    publicLabelComputed: publicLabelComputed,
    publicLabel: publicLabel,
    officialMoveQualityComputed: false,
    officialMoveQuality: null,
    officialCpLossComputed: false,
    officialWinPercentComputed: false,
    accuracyComputed: false,
    acplComputed: false,
    classificationComputed: false,
    publicClassifierOutputComputed: false,
    savedAnalysisWritten: false,
    uiOutputProduced: false,
    persistenceWritePerformed: false,
    fileWritePerformed: false,
    backendPayloadProduced: false,
    archiveStatsTouched: false,
    mappingSucceeded: true,
    failureMessage: null,
    safeForPhase38C: true,
    safeForPhase38D: true,
    nextRecommendation: analyzerProductSafeReviewContractNextRecommendation,
  );
}

void _expectBlocked(AnalyzerProductReviewFoundationViewModel result) {
  expect(result.foundationComputed, isFalse);
  expect(result.foundationReadyForPlanning, isFalse);
  expect(result.planningAllowed, isFalse);
  expect(result.uiRenderingAllowed, isFalse);
  expect(result.savedAnalysisAllowed, isFalse);
  expect(result.archiveStatsAllowed, isFalse);
  expect(result.publicLabelsAllowed, isFalse);
  expect(result.officialMetricsAllowed, isFalse);
  expect(result.privateCountsAreInternalOnly, isFalse);
  expect(result.foundationContainsPublicLabels, isFalse);
  expect(result.foundationContainsOfficialMetrics, isFalse);
  expect(result.safeForPhase40B, isFalse);
  expect(
    result.nextRecommendation,
    analyzerProductReviewFoundationFailureRecommendation,
  );
}
