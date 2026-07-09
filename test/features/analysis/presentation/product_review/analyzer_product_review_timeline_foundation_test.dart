import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_session_foundation.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_timeline_foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapProductReviewTimelineFoundationFromSession', () {
    test('clean session maps to ready timeline', () {
      final result = mapProductReviewTimelineFoundationFromSession(_session());

      expect(result.timelineComputed, isTrue);
      expect(result.timelineReady, isTrue);
      expect(
        result.unavailableReason,
        AnalyzerNeutralReviewPreviewUnavailableReason.none,
      );
      expect(
        result.sourceSessionId,
        'productReviewSession:productReviewFoundation:phase38B:test:contract',
      );
      expect(
        result.timelineScope,
        AnalyzerProductSafeReviewScope.singleMoveControlled,
      );
      expect(
        result.evidenceStrength,
        AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
      );
      expect(result.timelineIsReadOnly, isTrue);
      expect(result.timelineIsProductSafe, isTrue);
      expect(result.safeForNextProductReviewStep, isTrue);
      expect(
        result.nextRecommendation,
        analyzerProductReviewTimelineFoundationNextRecommendation,
      );
    });

    test('one neutral timeline entry is produced', () {
      final result = mapProductReviewTimelineFoundationFromSession(_session());

      expect(result.totalEntries, 1);
      expect(result.neutralEntryCount, 1);
      expect(result.blockedEntryCount, 0);
      expect(result.entries, hasLength(1));
      final entry = result.entries.single;
      expect(
        entry.entryId,
        'productReviewSession:productReviewFoundation:'
        'phase38B:test:contract:entry:0',
      );
      expect(
        entry.entryKind,
        AnalyzerProductReviewTimelineEntryKind.neutralSessionSummary,
      );
      expect(entry.entryReady, isTrue);
      expect(entry.entryIsInternalOnly, isTrue);
      expect(entry.entryContainsPublicLabel, isFalse);
      expect(entry.entryContainsOfficialMetric, isFalse);
    });

    test('session private count breakdown is preserved', () {
      final result = mapProductReviewTimelineFoundationFromSession(
        _session(
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

    test('blocked source does not fabricate private counts', () {
      final result = mapProductReviewTimelineFoundationFromSession(
        _session(
          sessionReady: false,
          totalPrivateEntries: 0,
          positiveCandidateCount: 0,
          neutralCandidateCount: 0,
          negativeCandidateCount: 0,
          unavailableCount: 0,
        ),
      );

      expect(result.timelineReady, isFalse);
      expect(result.totalPrivateEntries, 0);
      expect(result.positiveCandidateCount, 0);
      expect(result.neutralCandidateCount, 0);
      expect(result.negativeCandidateCount, 0);
      expect(result.unavailableCount, 0);
      expect(result.totalEntries, 1);
      expect(result.blockedEntryCount, 1);
    });

    test('planning is allowed but UI rendering stays blocked', () {
      final result = mapProductReviewTimelineFoundationFromSession(_session());

      expect(result.planningAllowed, isTrue);
      expect(result.uiRenderingAllowed, isFalse);
      expect(result.timelineIsUiOutput, isFalse);
    });

    test('saved analysis and archive stats stay blocked', () {
      final result = mapProductReviewTimelineFoundationFromSession(_session());

      expect(result.savedAnalysisAllowed, isFalse);
      expect(result.archiveStatsAllowed, isFalse);
      expect(result.timelineIsSavedAnalysis, isFalse);
      expect(result.timelineIsPersistenceWrite, isFalse);
    });

    test('public labels stay blocked', () {
      final result = mapProductReviewTimelineFoundationFromSession(_session());

      expect(result.publicLabelsAllowed, isFalse);
      expect(result.timelineContainsPublicLabels, isFalse);
      expect(result.entries.single.entryContainsPublicLabel, isFalse);
    });

    test('official metrics stay blocked', () {
      final result = mapProductReviewTimelineFoundationFromSession(_session());

      expect(result.officialMetricsAllowed, isFalse);
      expect(result.timelineContainsOfficialMetrics, isFalse);
      expect(result.entries.single.entryContainsOfficialMetric, isFalse);
    });

    for (final entry
        in <String, AnalyzerProductReviewSessionFoundation Function()>{
          'not computed': () => _session(sessionComputed: false),
          'not ready': () => _session(sessionReady: false),
          'planning blocked': () => _session(planningAllowed: false),
          'UI rendering allowed': () => _session(
            uiRenderingAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .uiRenderingAllowed,
          ),
          'saved analysis allowed': () => _session(
            savedAnalysisAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .savedAnalysisAllowed,
          ),
          'archive stats allowed': () => _session(
            archiveStatsAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .archiveStatsAllowed,
          ),
          'public labels allowed': () => _session(
            publicLabelsAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .publicLabelsAllowed,
          ),
          'official metrics allowed': () => _session(
            officialMetricsAllowed: true,
            unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason
                .officialMetricsAllowed,
          ),
          'not read-only': () => _session(sessionIsReadOnly: false),
          'not product-safe': () => _session(sessionIsProductSafe: false),
          'UI output': () => _session(sessionIsUiOutput: true),
          'saved analysis output': () => _session(sessionIsSavedAnalysis: true),
          'persistence write': () => _session(sessionIsPersistenceWrite: true),
          'archive stats output': () =>
              _session(sessionIsArchiveStatsOutput: true),
          'contains public labels': () =>
              _session(sessionContainsPublicLabels: true),
          'contains official metrics': () =>
              _session(sessionContainsOfficialMetrics: true),
          'not safe for next step': () =>
              _session(safeForNextProductReviewStep: false),
        }.entries) {
      test('unsafe source fails closed: ${entry.key}', () {
        final result = mapProductReviewTimelineFoundationFromSession(
          entry.value(),
        );

        _expectBlocked(result);
      });
    }

    test('safeForNextProductReviewStep is true only for clean source', () {
      final clean = mapProductReviewTimelineFoundationFromSession(_session());
      final dirtyUi = mapProductReviewTimelineFoundationFromSession(
        _session(uiRenderingAllowed: true),
      );
      final dirtyPublic = mapProductReviewTimelineFoundationFromSession(
        _session(publicLabelsAllowed: true),
      );
      final dirtyOfficial = mapProductReviewTimelineFoundationFromSession(
        _session(officialMetricsAllowed: true),
      );

      expect(clean.safeForNextProductReviewStep, isTrue);
      expect(dirtyUi.safeForNextProductReviewStep, isFalse);
      expect(dirtyPublic.safeForNextProductReviewStep, isFalse);
      expect(dirtyOfficial.safeForNextProductReviewStep, isFalse);
    });

    test('forbidden labels and metrics are absent from source', () {
      final source = File(
        'lib/features/analysis/presentation/product_review/'
        'analyzer_product_review_timeline_foundation.dart',
      ).readAsStringSync();

      expect(source, contains('AnalyzerProductReviewSessionFoundation'));
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

AnalyzerProductReviewSessionFoundation _session({
  bool sessionComputed = true,
  bool sessionReady = true,
  AnalyzerNeutralReviewPreviewUnavailableReason unavailableReason =
      AnalyzerNeutralReviewPreviewUnavailableReason.none,
  String sourceFoundationViewModelId =
      'productReviewFoundation:phase38B:test:contract',
  AnalyzerProductSafeReviewScope sessionScope =
      AnalyzerProductSafeReviewScope.singleMoveControlled,
  AnalyzerProductSafeReviewEvidenceStrength evidenceStrength =
      AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
  int totalPrivateEntries = 7,
  int positiveCandidateCount = 3,
  int neutralCandidateCount = 2,
  int negativeCandidateCount = 1,
  int unavailableCount = 1,
  bool planningAllowed = true,
  bool uiRenderingAllowed = false,
  bool savedAnalysisAllowed = false,
  bool archiveStatsAllowed = false,
  bool publicLabelsAllowed = false,
  bool officialMetricsAllowed = false,
  bool sessionIsReadOnly = true,
  bool sessionIsProductSafe = true,
  bool sessionIsUiOutput = false,
  bool sessionIsSavedAnalysis = false,
  bool sessionIsPersistenceWrite = false,
  bool sessionIsArchiveStatsOutput = false,
  bool sessionContainsPublicLabels = false,
  bool sessionContainsOfficialMetrics = false,
  bool safeForNextProductReviewStep = true,
}) {
  return AnalyzerProductReviewSessionFoundation(
    sessionComputed: sessionComputed,
    sessionReady: sessionReady,
    unavailableReason: unavailableReason,
    sourceFoundationViewModelId: sourceFoundationViewModelId,
    sessionScope: sessionScope,
    evidenceStrength: evidenceStrength,
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    planningAllowed: planningAllowed,
    uiRenderingAllowed: uiRenderingAllowed,
    savedAnalysisAllowed: savedAnalysisAllowed,
    archiveStatsAllowed: archiveStatsAllowed,
    publicLabelsAllowed: publicLabelsAllowed,
    officialMetricsAllowed: officialMetricsAllowed,
    sessionIsReadOnly: sessionIsReadOnly,
    sessionIsProductSafe: sessionIsProductSafe,
    sessionIsUiOutput: sessionIsUiOutput,
    sessionIsSavedAnalysis: sessionIsSavedAnalysis,
    sessionIsPersistenceWrite: sessionIsPersistenceWrite,
    sessionIsArchiveStatsOutput: sessionIsArchiveStatsOutput,
    sessionContainsPublicLabels: sessionContainsPublicLabels,
    sessionContainsOfficialMetrics: sessionContainsOfficialMetrics,
    safeForNextProductReviewStep: safeForNextProductReviewStep,
    nextRecommendation: safeForNextProductReviewStep
        ? analyzerProductReviewSessionFoundationNextRecommendation
        : analyzerProductReviewSessionFoundationFailureRecommendation,
  );
}

void _expectBlocked(AnalyzerProductReviewTimelineFoundation result) {
  expect(result.timelineComputed, isFalse);
  expect(result.timelineReady, isFalse);
  expect(result.totalEntries, 1);
  expect(result.neutralEntryCount, 0);
  expect(result.blockedEntryCount, 1);
  expect(result.totalPrivateEntries, 7);
  expect(result.positiveCandidateCount, 3);
  expect(result.neutralCandidateCount, 2);
  expect(result.negativeCandidateCount, 1);
  expect(result.unavailableCount, 1);
  expect(result.entries, hasLength(1));
  expect(
    result.entries.single.entryKind,
    AnalyzerProductReviewTimelineEntryKind.unavailable,
  );
  expect(result.entries.single.entryReady, isFalse);
  expect(result.entries.single.entryIsInternalOnly, isTrue);
  expect(result.entries.single.entryContainsPublicLabel, isFalse);
  expect(result.entries.single.entryContainsOfficialMetric, isFalse);
  expect(result.planningAllowed, isFalse);
  expect(result.uiRenderingAllowed, isFalse);
  expect(result.savedAnalysisAllowed, isFalse);
  expect(result.archiveStatsAllowed, isFalse);
  expect(result.publicLabelsAllowed, isFalse);
  expect(result.officialMetricsAllowed, isFalse);
  expect(result.timelineIsReadOnly, isTrue);
  expect(result.timelineIsProductSafe, isFalse);
  expect(result.timelineIsUiOutput, isFalse);
  expect(result.timelineIsSavedAnalysis, isFalse);
  expect(result.timelineIsPersistenceWrite, isFalse);
  expect(result.timelineContainsPublicLabels, isFalse);
  expect(result.timelineContainsOfficialMetrics, isFalse);
  expect(result.safeForNextProductReviewStep, isFalse);
  expect(
    result.nextRecommendation,
    analyzerProductReviewTimelineFoundationFailureRecommendation,
  );
}
