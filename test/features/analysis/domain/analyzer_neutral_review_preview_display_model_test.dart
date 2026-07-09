import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapNeutralReviewPreviewDisplayModelFromGateway', () {
    test('clean gateway maps to ready display model', () {
      final result = _map(_decision());

      expect(result.displayModelComputed, isTrue);
      expect(result.displayModelReady, isTrue);
      expect(
        result.unavailableReason,
        AnalyzerNeutralReviewPreviewUnavailableReason.none,
      );
      expect(result.planningAllowed, isTrue);
      expect(result.uiRenderingAllowed, isFalse);
      expect(result.savedAnalysisAllowed, isFalse);
      expect(result.archiveStatsAllowed, isFalse);
      expect(result.publicLabelsAllowed, isFalse);
      expect(result.officialMetricsAllowed, isFalse);
      expect(result.safeForPhase39C, isTrue);
      expect(
        result.nextRecommendation,
        analyzerNeutralReviewPreviewDisplayModelNextRecommendation,
      );
    });

    test('counts are copied exactly', () {
      final source = _decision(
        totalPrivateEntries: 11,
        positiveCandidateCount: 5,
        neutralCandidateCount: 3,
        negativeCandidateCount: 2,
        unavailableCount: 1,
      );
      final result = _map(source);

      expect(result.totalPrivateEntries, source.totalPrivateEntries);
      expect(result.positiveCandidateCount, source.positiveCandidateCount);
      expect(result.neutralCandidateCount, source.neutralCandidateCount);
      expect(result.negativeCandidateCount, source.negativeCandidateCount);
      expect(result.unavailableCount, source.unavailableCount);
    });

    test('UI rendering stays blocked', () {
      final clean = _map(_decision());
      final unsafe = _map(_decision(gatewayAllowsUiRendering: true));

      expect(clean.uiRenderingAllowed, isFalse);
      _expectBlocked(
        unsafe,
        AnalyzerNeutralReviewPreviewUnavailableReason.uiRenderingAllowed,
      );
    });

    test('saved and archive access stay blocked', () {
      final clean = _map(_decision());
      final saved = _map(_decision(gatewayAllowsSavedAnalysis: true));
      final archive = _map(_decision(gatewayAllowsArchiveStats: true));

      expect(clean.savedAnalysisAllowed, isFalse);
      expect(clean.archiveStatsAllowed, isFalse);
      _expectBlocked(
        saved,
        AnalyzerNeutralReviewPreviewUnavailableReason.savedAnalysisAllowed,
      );
      _expectBlocked(
        archive,
        AnalyzerNeutralReviewPreviewUnavailableReason.archiveStatsAllowed,
      );
    });

    test('public labels stay blocked', () {
      final clean = _map(_decision());
      final unsafe = _map(_decision(gatewayAllowsPublicLabels: true));

      expect(clean.publicLabelsAllowed, isFalse);
      _expectBlocked(
        unsafe,
        AnalyzerNeutralReviewPreviewUnavailableReason.publicLabelsAllowed,
      );
    });

    test('official metrics stay blocked', () {
      final clean = _map(_decision());
      final unsafe = _map(_decision(gatewayAllowsOfficialMetrics: true));

      expect(clean.officialMetricsAllowed, isFalse);
      _expectBlocked(
        unsafe,
        AnalyzerNeutralReviewPreviewUnavailableReason.officialMetricsAllowed,
      );
    });

    for (final entry
        in <String, AnalyzerProductSafeReviewGatewayDecision Function()>{
          'gateway not computed': () => _decision(gatewayComputed: false),
          'planning not allowed': () =>
              _decision(gatewayAllowsProductReviewPlanning: false),
          'phase gate unsafe': () => _decision(safeForPhase38E: false),
          'unexpected gateway reason': () => _decision(
            gatewayReason: AnalyzerProductSafeReviewGatewayReason.sourceUnsafe,
          ),
        }.entries) {
      test('${entry.key} fails closed', () {
        final result = _map(entry.value());

        expect(result.displayModelComputed, isFalse);
        expect(result.displayModelReady, isFalse);
        expect(result.planningAllowed, isFalse);
        expect(result.safeForPhase39C, isFalse);
        expect(
          result.nextRecommendation,
          analyzerNeutralReviewPreviewDisplayModelFailureRecommendation,
        );
      });
    }

    test('safeForPhase39C true only for clean source', () {
      final clean = _map(_decision());
      final dirtySource = _map(_decision(gatewayComputed: false));
      final dirtyUi = _map(_decision(gatewayAllowsUiRendering: true));
      final dirtySaved = _map(_decision(gatewayAllowsSavedAnalysis: true));
      final dirtyPublic = _map(_decision(gatewayAllowsPublicLabels: true));
      final dirtyOfficial = _map(_decision(gatewayAllowsOfficialMetrics: true));

      expect(clean.safeForPhase39C, isTrue);
      expect(dirtySource.safeForPhase39C, isFalse);
      expect(dirtyUi.safeForPhase39C, isFalse);
      expect(dirtySaved.safeForPhase39C, isFalse);
      expect(dirtyPublic.safeForPhase39C, isFalse);
      expect(dirtyOfficial.safeForPhase39C, isFalse);
    });

    test('display model source does not import UI or classifier surfaces', () {
      final source = File(
        'lib/features/analysis/domain/'
        'analyzer_neutral_review_preview_display_model.dart',
      ).readAsStringSync();

      expect(source, contains('analyzer_product_safe_review_gateway.dart'));
      expect(source, isNot(contains('ReviewController')));
      expect(source, isNot(contains('ReviewScreen')));
      expect(source, isNot(contains('ReviewSummaryScreen')));
    });
  });
}

AnalyzerNeutralReviewPreviewDisplayModel _map(
  AnalyzerProductSafeReviewGatewayDecision source,
) {
  return mapNeutralReviewPreviewDisplayModelFromGateway(source);
}

AnalyzerProductSafeReviewGatewayDecision _decision({
  bool gatewayComputed = true,
  bool gatewayAllowsProductReviewPlanning = true,
  bool gatewayAllowsUiRendering = false,
  bool gatewayAllowsSavedAnalysis = false,
  bool gatewayAllowsArchiveStats = false,
  bool gatewayAllowsPublicLabels = false,
  bool gatewayAllowsOfficialMetrics = false,
  AnalyzerProductSafeReviewGatewayReason gatewayReason =
      AnalyzerProductSafeReviewGatewayReason.productSafeContractReady,
  int totalPrivateEntries = 1,
  int positiveCandidateCount = 1,
  int neutralCandidateCount = 0,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  String sourceContractId = 'phase38B:safe:productSafeReview',
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

void _expectBlocked(
  AnalyzerNeutralReviewPreviewDisplayModel result,
  AnalyzerNeutralReviewPreviewUnavailableReason reason,
) {
  expect(result.displayModelComputed, isFalse);
  expect(result.displayModelReady, isFalse);
  expect(result.unavailableReason, reason);
  expect(result.planningAllowed, isFalse);
  expect(result.uiRenderingAllowed, isFalse);
  expect(result.savedAnalysisAllowed, isFalse);
  expect(result.archiveStatsAllowed, isFalse);
  expect(result.publicLabelsAllowed, isFalse);
  expect(result.officialMetricsAllowed, isFalse);
  expect(result.safeForPhase39C, isFalse);
  expect(
    result.nextRecommendation,
    analyzerNeutralReviewPreviewDisplayModelFailureRecommendation,
  );
}
