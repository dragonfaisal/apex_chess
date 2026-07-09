import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_foundation_view_model.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_session_foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapProductReviewSessionFoundationFromFoundation', () {
    test('clean foundation view model maps to ready review session', () {
      final result = mapProductReviewSessionFoundationFromFoundation(
        _foundation(),
      );

      expect(result.sessionComputed, isTrue);
      expect(result.sessionReady, isTrue);
      expect(
        result.unavailableReason,
        AnalyzerNeutralReviewPreviewUnavailableReason.none,
      );
      expect(
        result.sourceFoundationViewModelId,
        'productReviewFoundation:phase38B:test:contract',
      );
      expect(
        result.sessionScope,
        AnalyzerProductSafeReviewScope.singleMoveControlled,
      );
      expect(
        result.evidenceStrength,
        AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
      );
      expect(result.sessionIsReadOnly, isTrue);
      expect(result.sessionIsProductSafe, isTrue);
      expect(result.safeForNextProductReviewStep, isTrue);
      expect(
        result.nextRecommendation,
        analyzerProductReviewSessionFoundationNextRecommendation,
      );
    });

    test('counts are copied exactly', () {
      final result = mapProductReviewSessionFoundationFromFoundation(
        _foundation(
          totalPrivateEntries: 12,
          positiveCandidateCount: 5,
          neutralCandidateCount: 4,
          negativeCandidateCount: 2,
          unavailableCount: 1,
        ),
      );

      expect(result.totalPrivateEntries, 12);
      expect(result.positiveCandidateCount, 5);
      expect(result.neutralCandidateCount, 4);
      expect(result.negativeCandidateCount, 2);
      expect(result.unavailableCount, 1);
    });

    test('planning is allowed but UI rendering stays blocked', () {
      final result = mapProductReviewSessionFoundationFromFoundation(
        _foundation(),
      );

      expect(result.planningAllowed, isTrue);
      expect(result.uiRenderingAllowed, isFalse);
      expect(result.sessionIsUiOutput, isFalse);
    });

    test('saved analysis and archive stats stay blocked', () {
      final result = mapProductReviewSessionFoundationFromFoundation(
        _foundation(),
      );

      expect(result.savedAnalysisAllowed, isFalse);
      expect(result.archiveStatsAllowed, isFalse);
      expect(result.sessionIsSavedAnalysis, isFalse);
      expect(result.sessionIsPersistenceWrite, isFalse);
      expect(result.sessionIsArchiveStatsOutput, isFalse);
    });

    test('public labels stay blocked', () {
      final result = mapProductReviewSessionFoundationFromFoundation(
        _foundation(),
      );

      expect(result.publicLabelsAllowed, isFalse);
      expect(result.sessionContainsPublicLabels, isFalse);
    });

    test('official metrics stay blocked', () {
      final result = mapProductReviewSessionFoundationFromFoundation(
        _foundation(),
      );

      expect(result.officialMetricsAllowed, isFalse);
      expect(result.sessionContainsOfficialMetrics, isFalse);
    });

    for (final entry
        in <String, AnalyzerProductReviewFoundationViewModel Function()>{
          'not computed': () => _foundation(foundationComputed: false),
          'not ready': () => _foundation(foundationReadyForPlanning: false),
          'planning blocked': () => _foundation(planningAllowed: false),
          'UI rendering allowed': () => _foundation(
            uiRenderingAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .uiRenderingAllowed,
          ),
          'saved analysis allowed': () => _foundation(
            savedAnalysisAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .savedAnalysisAllowed,
          ),
          'archive stats allowed': () => _foundation(
            archiveStatsAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .archiveStatsAllowed,
          ),
          'public labels allowed': () => _foundation(
            publicLabelsAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .publicLabelsAllowed,
          ),
          'official metrics allowed': () => _foundation(
            officialMetricsAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .officialMetricsAllowed,
          ),
          'private counts not internal': () =>
              _foundation(privateCountsAreInternalOnly: false),
          'foundation contains public labels': () =>
              _foundation(foundationContainsPublicLabels: true),
          'foundation contains official metrics': () =>
              _foundation(foundationContainsOfficialMetrics: true),
          'not safe for next step': () => _foundation(safeForPhase40B: false),
        }.entries) {
      test('unsafe source fails closed: ${entry.key}', () {
        final result = mapProductReviewSessionFoundationFromFoundation(
          entry.value(),
        );

        _expectBlocked(result);
      });
    }

    test('safeForNextProductReviewStep is true only for clean source', () {
      final clean = mapProductReviewSessionFoundationFromFoundation(
        _foundation(),
      );
      final dirtyUi = mapProductReviewSessionFoundationFromFoundation(
        _foundation(uiRenderingAllowed: true),
      );
      final dirtyPublic = mapProductReviewSessionFoundationFromFoundation(
        _foundation(publicLabelsAllowed: true),
      );
      final dirtyOfficial = mapProductReviewSessionFoundationFromFoundation(
        _foundation(officialMetricsAllowed: true),
      );

      expect(clean.safeForNextProductReviewStep, isTrue);
      expect(dirtyUi.safeForNextProductReviewStep, isFalse);
      expect(dirtyPublic.safeForNextProductReviewStep, isFalse);
      expect(dirtyOfficial.safeForNextProductReviewStep, isFalse);
    });

    test('no forbidden labels or metrics are emitted from source', () {
      final source = File(
        'lib/features/analysis/presentation/product_review/'
        'analyzer_product_review_session_foundation.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('ReviewController')));
      expect(source, isNot(contains('ReviewScreen')));
      expect(source, isNot(contains('HomeScreen')));
      expect(source, isNot(contains('MoveQuality')));
      for (final forbidden in [
        'Brilliant',
        'Great Move',
        'Best',
        'Excellent',
        'Good',
        'Inaccuracy',
        'Mistake',
        'Blunder',
        'CP-loss',
        'Win%',
        'Accuracy',
        'ACPL',
        'coach',
        'explanation',
        'savedAnalysisId',
        'archiveId',
        'backend',
        'Hive',
      ]) {
        expect(source, isNot(contains(forbidden)));
      }
    });
  });
}

AnalyzerProductReviewFoundationViewModel _foundation({
  bool foundationComputed = true,
  bool foundationReadyForPlanning = true,
  AnalyzerNeutralReviewPreviewUnavailableReason unavailableReason =
      AnalyzerNeutralReviewPreviewUnavailableReason.none,
  String sourceContractId = 'phase38B:test:contract',
  AnalyzerProductSafeReviewScope reviewScope =
      AnalyzerProductSafeReviewScope.singleMoveControlled,
  AnalyzerProductSafeReviewEvidenceStrength evidenceStrength =
      AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
  bool planningAllowed = true,
  bool uiRenderingAllowed = false,
  bool savedAnalysisAllowed = false,
  bool archiveStatsAllowed = false,
  bool publicLabelsAllowed = false,
  bool officialMetricsAllowed = false,
  int totalPrivateEntries = 7,
  int positiveCandidateCount = 3,
  int neutralCandidateCount = 2,
  int negativeCandidateCount = 1,
  int unavailableCount = 1,
  bool privateCountsAreInternalOnly = true,
  bool foundationContainsPublicLabels = false,
  bool foundationContainsOfficialMetrics = false,
  bool safeForPhase40B = true,
}) {
  return AnalyzerProductReviewFoundationViewModel(
    foundationComputed: foundationComputed,
    foundationReadyForPlanning: foundationReadyForPlanning,
    unavailableReason: unavailableReason,
    sourceContractId: sourceContractId,
    reviewScope: reviewScope,
    evidenceStrength: evidenceStrength,
    title: 'Review foundation',
    statusText: foundationReadyForPlanning
        ? 'Ready for product review planning'
        : 'Product review foundation unavailable',
    planningAllowed: planningAllowed,
    uiRenderingAllowed: uiRenderingAllowed,
    savedAnalysisAllowed: savedAnalysisAllowed,
    archiveStatsAllowed: archiveStatsAllowed,
    publicLabelsAllowed: publicLabelsAllowed,
    officialMetricsAllowed: officialMetricsAllowed,
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    privateCountsAreInternalOnly: privateCountsAreInternalOnly,
    foundationContainsPublicLabels: foundationContainsPublicLabels,
    foundationContainsOfficialMetrics: foundationContainsOfficialMetrics,
    safeForPhase40B: safeForPhase40B,
    nextRecommendation: foundationReadyForPlanning
        ? analyzerProductReviewFoundationNextRecommendation
        : analyzerProductReviewFoundationFailureRecommendation,
  );
}

void _expectBlocked(AnalyzerProductReviewSessionFoundation result) {
  expect(result.sessionComputed, isFalse);
  expect(result.sessionReady, isFalse);
  expect(result.planningAllowed, isFalse);
  expect(result.uiRenderingAllowed, isFalse);
  expect(result.savedAnalysisAllowed, isFalse);
  expect(result.archiveStatsAllowed, isFalse);
  expect(result.publicLabelsAllowed, isFalse);
  expect(result.officialMetricsAllowed, isFalse);
  expect(result.sessionIsReadOnly, isTrue);
  expect(result.sessionIsProductSafe, isFalse);
  expect(result.sessionIsUiOutput, isFalse);
  expect(result.sessionIsSavedAnalysis, isFalse);
  expect(result.sessionIsPersistenceWrite, isFalse);
  expect(result.sessionIsArchiveStatsOutput, isFalse);
  expect(result.sessionContainsPublicLabels, isFalse);
  expect(result.sessionContainsOfficialMetrics, isFalse);
  expect(result.safeForNextProductReviewStep, isFalse);
  expect(
    result.nextRecommendation,
    analyzerProductReviewSessionFoundationFailureRecommendation,
  );
}
