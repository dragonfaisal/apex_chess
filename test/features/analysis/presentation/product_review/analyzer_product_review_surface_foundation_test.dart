import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_surface_foundation.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_timeline_foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapProductReviewSurfaceFoundationFromTimeline', () {
    test('clean timeline maps to complete surface foundation', () {
      final result = mapProductReviewSurfaceFoundationFromTimeline(_timeline());

      expect(result.surfaceComputed, isTrue);
      expect(result.surfaceReady, isTrue);
      expect(
        result.unavailableReason,
        AnalyzerNeutralReviewPreviewUnavailableReason.none,
      );
      expect(
        result.sourceTimelineId,
        'productReviewTimeline:productReviewSession:'
        'productReviewFoundation:phase38B:test:contract',
      );
      expect(result.planningAllowed, isTrue);
      expect(result.surfaceIsReadOnly, isTrue);
      expect(result.surfaceIsProductSafe, isTrue);
      expect(result.safeForPhase41A, isTrue);
      expect(
        result.nextRecommendation,
        analyzerProductReviewSurfaceFoundationNextRecommendation,
      );
    });

    test('header fields are generated', () {
      final result = mapProductReviewSurfaceFoundationFromTimeline(_timeline());

      expect(result.header.surfaceTitle, 'Review foundation');
      expect(result.header.readiness, 'ready');
      expect(
        result.header.scope,
        AnalyzerProductSafeReviewScope.singleMoveControlled,
      );
      expect(
        result.header.evidenceStrength,
        AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
      );
      expect(result.header.productSafeStatus, 'productSafe');
    });

    test('summary private count breakdown is preserved from timeline', () {
      final result = mapProductReviewSurfaceFoundationFromTimeline(
        _timeline(
          totalPrivateEntries: 12,
          positiveCandidateCount: 5,
          neutralCandidateCount: 4,
          negativeCandidateCount: 2,
          unavailableCount: 1,
          totalEntries: 3,
          neutralEntryCount: 2,
          blockedEntryCount: 1,
        ),
      );

      expect(result.summary.totalPrivateEntries, 12);
      expect(result.summary.positiveCandidateCount, 5);
      expect(result.summary.neutralCandidateCount, 4);
      expect(result.summary.negativeCandidateCount, 2);
      expect(result.summary.unavailableCount, 1);
      expect(result.summary.publicLabelsBlocked, isTrue);
      expect(result.summary.officialMetricsBlocked, isTrue);
      expect(result.summary.savedArchiveBlocked, isTrue);
    });

    test('blocked timeline does not fabricate private counts', () {
      final result = mapProductReviewSurfaceFoundationFromTimeline(
        _timeline(
          timelineReady: false,
          totalPrivateEntries: 0,
          positiveCandidateCount: 0,
          neutralCandidateCount: 0,
          negativeCandidateCount: 0,
          unavailableCount: 0,
          totalEntries: 1,
          neutralEntryCount: 0,
          blockedEntryCount: 1,
          entries: [
            _entry(
              entryKind: AnalyzerProductReviewTimelineEntryKind.unavailable,
              entryReady: false,
            ),
          ],
        ),
      );

      expect(result.surfaceReady, isFalse);
      expect(result.summary.totalPrivateEntries, 0);
      expect(result.summary.positiveCandidateCount, 0);
      expect(result.summary.neutralCandidateCount, 0);
      expect(result.summary.negativeCandidateCount, 0);
      expect(result.summary.unavailableCount, 0);
      expect(
        result.timelineEntries.single.entryKind,
        AnalyzerProductReviewTimelineEntryKind.unavailable,
      );
    });

    test('board preview remains blocked', () {
      final result = mapProductReviewSurfaceFoundationFromTimeline(_timeline());

      expect(result.board.boardPreviewAvailable, isFalse);
      expect(
        result.board.boardPreviewReason,
        AnalyzerProductReviewSurfaceBoardPreviewReason.uiRenderingBlocked,
      );
    });

    test('timeline entries are consumed safely', () {
      final result = mapProductReviewSurfaceFoundationFromTimeline(_timeline());

      expect(result.timelineEntries, hasLength(1));
      final entry = result.timelineEntries.single;
      expect(entry.entryId, 'timeline:entry:0');
      expect(
        entry.entryKind,
        AnalyzerProductReviewTimelineEntryKind.neutralSessionSummary,
      );
      expect(entry.entryReady, isTrue);
      expect(entry.entryIsInternalOnly, isTrue);
      expect(entry.entryContainsPublicLabel, isFalse);
      expect(entry.entryContainsOfficialMetric, isFalse);
    });

    test('UI rendering stays blocked', () {
      final result = mapProductReviewSurfaceFoundationFromTimeline(_timeline());

      expect(result.uiRenderingAllowed, isFalse);
      expect(result.surfaceIsUiOutput, isFalse);
    });

    test('saved analysis and archive stats stay blocked', () {
      final result = mapProductReviewSurfaceFoundationFromTimeline(_timeline());

      expect(result.savedAnalysisAllowed, isFalse);
      expect(result.archiveStatsAllowed, isFalse);
      expect(result.surfaceIsSavedAnalysis, isFalse);
    });

    test('public labels stay blocked', () {
      final result = mapProductReviewSurfaceFoundationFromTimeline(_timeline());

      expect(result.publicLabelsAllowed, isFalse);
      expect(result.surfaceContainsPublicLabels, isFalse);
      expect(result.timelineEntries.single.entryContainsPublicLabel, isFalse);
    });

    test('official metrics stay blocked', () {
      final result = mapProductReviewSurfaceFoundationFromTimeline(_timeline());

      expect(result.officialMetricsAllowed, isFalse);
      expect(result.surfaceContainsOfficialMetrics, isFalse);
      expect(
        result.timelineEntries.single.entryContainsOfficialMetric,
        isFalse,
      );
    });

    for (final entry
        in <String, AnalyzerProductReviewTimelineFoundation Function()>{
          'not computed': () => _timeline(timelineComputed: false),
          'not ready': () => _timeline(timelineReady: false),
          'planning blocked': () => _timeline(planningAllowed: false),
          'UI rendering allowed': () => _timeline(
            uiRenderingAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .uiRenderingAllowed,
          ),
          'saved analysis allowed': () => _timeline(
            savedAnalysisAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .savedAnalysisAllowed,
          ),
          'archive stats allowed': () => _timeline(
            archiveStatsAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .archiveStatsAllowed,
          ),
          'public labels allowed': () => _timeline(
            publicLabelsAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .publicLabelsAllowed,
          ),
          'official metrics allowed': () => _timeline(
            officialMetricsAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .officialMetricsAllowed,
          ),
          'not read-only': () => _timeline(timelineIsReadOnly: false),
          'not product-safe': () => _timeline(timelineIsProductSafe: false),
          'UI output': () => _timeline(timelineIsUiOutput: true),
          'saved analysis output': () =>
              _timeline(timelineIsSavedAnalysis: true),
          'persistence write': () =>
              _timeline(timelineIsPersistenceWrite: true),
          'contains public labels': () =>
              _timeline(timelineContainsPublicLabels: true),
          'contains official metrics': () =>
              _timeline(timelineContainsOfficialMetrics: true),
          'entry contains public label': () =>
              _timeline(entries: [_entry(entryContainsPublicLabel: true)]),
          'entry contains official metric': () =>
              _timeline(entries: [_entry(entryContainsOfficialMetric: true)]),
          'not safe for next step': () =>
              _timeline(safeForNextProductReviewStep: false),
        }.entries) {
      test('unsafe timeline fails closed: ${entry.key}', () {
        final result = mapProductReviewSurfaceFoundationFromTimeline(
          entry.value(),
        );

        _expectBlocked(result);
      });
    }

    test('safeForPhase41A true only for clean source', () {
      final clean = mapProductReviewSurfaceFoundationFromTimeline(_timeline());
      final dirtyUi = mapProductReviewSurfaceFoundationFromTimeline(
        _timeline(uiRenderingAllowed: true),
      );
      final dirtyPublic = mapProductReviewSurfaceFoundationFromTimeline(
        _timeline(publicLabelsAllowed: true),
      );
      final dirtyOfficial = mapProductReviewSurfaceFoundationFromTimeline(
        _timeline(officialMetricsAllowed: true),
      );

      expect(clean.safeForPhase41A, isTrue);
      expect(dirtyUi.safeForPhase41A, isFalse);
      expect(dirtyPublic.safeForPhase41A, isFalse);
      expect(dirtyOfficial.safeForPhase41A, isFalse);
    });

    test('forbidden labels and metrics are absent from source', () {
      final source = File(
        'lib/features/analysis/presentation/product_review/'
        'analyzer_product_review_surface_foundation.dart',
      ).readAsStringSync();

      expect(source, contains('AnalyzerProductReviewTimelineFoundation'));
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

AnalyzerProductReviewTimelineFoundation _timeline({
  bool timelineComputed = true,
  bool timelineReady = true,
  AnalyzerNeutralReviewPreviewUnavailableReason unavailableReason =
      AnalyzerNeutralReviewPreviewUnavailableReason.none,
  String sourceSessionId =
      'productReviewSession:productReviewFoundation:phase38B:test:contract',
  AnalyzerProductSafeReviewScope timelineScope =
      AnalyzerProductSafeReviewScope.singleMoveControlled,
  AnalyzerProductSafeReviewEvidenceStrength evidenceStrength =
      AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
  int totalPrivateEntries = 7,
  int positiveCandidateCount = 3,
  int neutralCandidateCount = 2,
  int negativeCandidateCount = 1,
  int unavailableCount = 1,
  int totalEntries = 1,
  int neutralEntryCount = 1,
  int blockedEntryCount = 0,
  List<AnalyzerProductReviewTimelineEntryFoundation>? entries,
  bool planningAllowed = true,
  bool uiRenderingAllowed = false,
  bool savedAnalysisAllowed = false,
  bool archiveStatsAllowed = false,
  bool publicLabelsAllowed = false,
  bool officialMetricsAllowed = false,
  bool timelineIsReadOnly = true,
  bool timelineIsProductSafe = true,
  bool timelineIsUiOutput = false,
  bool timelineIsSavedAnalysis = false,
  bool timelineIsPersistenceWrite = false,
  bool timelineContainsPublicLabels = false,
  bool timelineContainsOfficialMetrics = false,
  bool safeForNextProductReviewStep = true,
}) {
  return AnalyzerProductReviewTimelineFoundation(
    timelineComputed: timelineComputed,
    timelineReady: timelineReady,
    unavailableReason: unavailableReason,
    sourceSessionId: sourceSessionId,
    timelineScope: timelineScope,
    evidenceStrength: evidenceStrength,
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    totalEntries: totalEntries,
    neutralEntryCount: neutralEntryCount,
    blockedEntryCount: blockedEntryCount,
    entries: entries ?? [_entry()],
    planningAllowed: planningAllowed,
    uiRenderingAllowed: uiRenderingAllowed,
    savedAnalysisAllowed: savedAnalysisAllowed,
    archiveStatsAllowed: archiveStatsAllowed,
    publicLabelsAllowed: publicLabelsAllowed,
    officialMetricsAllowed: officialMetricsAllowed,
    timelineIsReadOnly: timelineIsReadOnly,
    timelineIsProductSafe: timelineIsProductSafe,
    timelineIsUiOutput: timelineIsUiOutput,
    timelineIsSavedAnalysis: timelineIsSavedAnalysis,
    timelineIsPersistenceWrite: timelineIsPersistenceWrite,
    timelineContainsPublicLabels: timelineContainsPublicLabels,
    timelineContainsOfficialMetrics: timelineContainsOfficialMetrics,
    safeForNextProductReviewStep: safeForNextProductReviewStep,
    nextRecommendation: safeForNextProductReviewStep
        ? analyzerProductReviewTimelineFoundationNextRecommendation
        : analyzerProductReviewTimelineFoundationFailureRecommendation,
  );
}

AnalyzerProductReviewTimelineEntryFoundation _entry({
  String entryId = 'timeline:entry:0',
  AnalyzerProductReviewTimelineEntryKind entryKind =
      AnalyzerProductReviewTimelineEntryKind.neutralSessionSummary,
  bool entryReady = true,
  bool entryIsInternalOnly = true,
  bool entryContainsPublicLabel = false,
  bool entryContainsOfficialMetric = false,
}) {
  return AnalyzerProductReviewTimelineEntryFoundation(
    entryId: entryId,
    entryKind: entryKind,
    entryReady: entryReady,
    entryIsInternalOnly: entryIsInternalOnly,
    entryContainsPublicLabel: entryContainsPublicLabel,
    entryContainsOfficialMetric: entryContainsOfficialMetric,
  );
}

void _expectBlocked(AnalyzerProductReviewSurfaceFoundation result) {
  expect(result.surfaceComputed, isFalse);
  expect(result.surfaceReady, isFalse);
  expect(result.header.readiness, 'unavailable');
  expect(result.header.productSafeStatus, 'blocked');
  expect(result.board.boardPreviewAvailable, isFalse);
  expect(result.summary.publicLabelsBlocked, isTrue);
  expect(result.summary.officialMetricsBlocked, isTrue);
  expect(result.summary.savedArchiveBlocked, isTrue);
  expect(result.summary.totalPrivateEntries, 7);
  expect(result.summary.positiveCandidateCount, 3);
  expect(result.summary.neutralCandidateCount, 2);
  expect(result.summary.negativeCandidateCount, 1);
  expect(result.summary.unavailableCount, 1);
  expect(result.planningAllowed, isFalse);
  expect(result.uiRenderingAllowed, isFalse);
  expect(result.savedAnalysisAllowed, isFalse);
  expect(result.archiveStatsAllowed, isFalse);
  expect(result.publicLabelsAllowed, isFalse);
  expect(result.officialMetricsAllowed, isFalse);
  expect(result.surfaceIsReadOnly, isTrue);
  expect(result.surfaceIsProductSafe, isFalse);
  expect(result.surfaceIsUiOutput, isFalse);
  expect(result.surfaceIsSavedAnalysis, isFalse);
  expect(result.surfaceContainsPublicLabels, isFalse);
  expect(result.surfaceContainsOfficialMetrics, isFalse);
  expect(result.safeForPhase41A, isFalse);
  expect(
    result.nextRecommendation,
    analyzerProductReviewSurfaceFoundationFailureRecommendation,
  );
}
