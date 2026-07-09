import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_foundation_view_model.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_session_foundation.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_surface_foundation.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_timeline_foundation.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/product_review_surface_preview_dev_widget.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductReviewSurfacePreviewDevWidget', () {
    testWidgets('disabled preview shows safe unavailable state', (
      tester,
    ) async {
      await tester.pumpWidget(_host(surface: _SurfaceFixture.ready()));

      expect(
        find.byKey(
          const ValueKey('product-review-surface-preview-dev-disabled'),
        ),
        findsOneWidget,
      );
      expect(find.text('Apex Review Preview'), findsOneWidget);
      expect(find.text('Preview disabled'), findsOneWidget);
      expect(find.text('Internal preview is not enabled.'), findsOneWidget);
      expect(
        find.text('The isolated surface has no normal app entry point.'),
        findsOneWidget,
      );
      expect(find.text('previewSurface'), findsOneWidget);
      expect(find.text('not active'), findsOneWidget);
      expect(find.text('surfaceReady'), findsNothing);
      expect(find.text('totalPrivateEntries'), findsNothing);
    });

    testWidgets('ready surface renders allowed sections', (tester) async {
      await tester.pumpWidget(
        _host(surface: _SurfaceFixture.fromCleanContractChain(), enabled: true),
      );

      expect(
        find.byKey(const ValueKey('product-review-surface-preview-dev-ready')),
        findsOneWidget,
      );
      expect(find.text('Apex Review Preview'), findsOneWidget);
      expect(find.text('Review preview foundation'), findsOneWidget);
      expect(
        find.text('Internal, read-only surface for review planning.'),
        findsOneWidget,
      );
      expect(find.text('Readiness'), findsOneWidget);
      expect(
        find.text('Planning state from the product-safe surface foundation.'),
        findsOneWidget,
      );
      expect(find.text('Ready for planning'), findsOneWidget);
      expect(
        find.text(
          'Read-only evidence is available; rendering remains blocked.',
        ),
        findsOneWidget,
      );
      expect(find.text('Internal counts'), findsOneWidget);
      expect(
        find.text(
          'Private candidate breakdown preserved from the review chain.',
        ),
        findsOneWidget,
      );
      expect(find.text('Board preview'), findsOneWidget);
      expect(find.text('Timeline entries'), findsOneWidget);
      expect(find.text('Guardrails'), findsOneWidget);
      expect(find.text('surfaceReady'), findsOneWidget);
      expect(find.text('none'), findsOneWidget);
      expect(find.text('Review foundation'), findsOneWidget);
      expect(find.text('singleMoveControlled'), findsOneWidget);
      expect(find.text('developerProofOnly'), findsOneWidget);
      expect(find.text('productSafe'), findsOneWidget);
      expect(find.text('totalPrivateEntries'), findsOneWidget);
      expect(find.text('positiveCandidateCount'), findsOneWidget);
      expect(find.text('neutralCandidateCount'), findsOneWidget);
      expect(find.text('negativeCandidateCount'), findsOneWidget);
      expect(find.text('unavailableCount'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(2));
    });

    testWidgets('blocked surface renders safe unavailable state', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(surface: _SurfaceFixture.blocked(), enabled: true),
      );

      expect(
        find.byKey(
          const ValueKey('product-review-surface-preview-dev-unavailable'),
        ),
        findsOneWidget,
      );
      expect(find.text('surfaceReady'), findsOneWidget);
      expect(find.text('false'), findsWidgets);
      expect(find.text('unavailableReason'), findsOneWidget);
      expect(find.text('sourceUnsafe'), findsOneWidget);
      expect(find.text('readiness'), findsOneWidget);
      expect(find.text('unavailable'), findsWidgets);
      expect(find.text('Surface unavailable'), findsOneWidget);
      expect(
        find.text('The preview is blocked until the source surface is safe.'),
        findsOneWidget,
      );
      expect(find.text('productSafeStatus'), findsOneWidget);
      expect(find.text('blocked'), findsWidgets);
      expect(find.text('unavailable'), findsWidgets);
    });

    testWidgets('mixed internal counts render exactly', (tester) async {
      await tester.pumpWidget(
        _host(surface: _SurfaceFixture.mixedCounts(), enabled: true),
      );

      expect(find.text('totalPrivateEntries'), findsOneWidget);
      expect(find.text('positiveCandidateCount'), findsOneWidget);
      expect(find.text('neutralCandidateCount'), findsOneWidget);
      expect(find.text('negativeCandidateCount'), findsOneWidget);
      expect(find.text('unavailableCount'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsWidgets);
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('board preview remains blocked', (tester) async {
      await tester.pumpWidget(
        _host(surface: _SurfaceFixture.ready(), enabled: true),
      );

      expect(find.text('Board preview'), findsOneWidget);
      expect(find.text('boardPreviewAvailable'), findsOneWidget);
      expect(find.text('boardPreviewReason'), findsOneWidget);
      expect(find.text('uiRenderingBlocked'), findsOneWidget);
      expect(find.text('blocked'), findsWidgets);
    });

    testWidgets('timeline entries render safely', (tester) async {
      await tester.pumpWidget(
        _host(surface: _SurfaceFixture.multipleEntries(), enabled: true),
      );

      expect(find.text('Timeline entries'), findsOneWidget);
      expect(
        find.text('Internal-only entry shape for future review consumption.'),
        findsOneWidget,
      );
      expect(find.text('Entry 1'), findsOneWidget);
      expect(find.text('Entry 2'), findsOneWidget);
      expect(find.text('timelineEntryKind'), findsNWidgets(2));
      expect(find.text('neutralSessionSummary'), findsOneWidget);
      expect(find.text('unavailable'), findsWidgets);
      expect(find.text('entryReady'), findsNWidgets(2));
      expect(find.text('entryInternalOnly'), findsNWidgets(2));
      expect(find.text('entryPublicLabelGuard'), findsNWidgets(2));
      expect(find.text('entryOfficialMetricGuard'), findsNWidgets(2));
      expect(find.text('blocked'), findsWidgets);
    });

    testWidgets('guardrails render blocked statuses', (tester) async {
      await tester.pumpWidget(
        _host(surface: _SurfaceFixture.ready(), enabled: true),
      );

      expect(find.text('UI rendering'), findsOneWidget);
      expect(find.text('Public labels'), findsOneWidget);
      expect(find.text('Official metrics'), findsOneWidget);
      expect(find.text('Saved/archive'), findsOneWidget);
      expect(find.text('blocked'), findsWidgets);
      expect(find.text('allowed'), findsNothing);
    });

    testWidgets('unsafe source guardrails fail closed in preview', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(surface: _SurfaceFixture.unsafeSource(), enabled: true),
      );

      expect(find.text('blocked by preview'), findsWidgets);
      expect(find.text('allowed'), findsNothing);
      expect(find.text('UI rendering'), findsOneWidget);
      expect(find.text('Public labels'), findsOneWidget);
      expect(find.text('Official metrics'), findsOneWidget);
      expect(find.text('Saved/archive'), findsOneWidget);
    });

    testWidgets(
      'forbidden labels official metrics and engine details are absent',
      (tester) async {
        await tester.pumpWidget(
          _host(surface: _SurfaceFixture.mixedCounts(), enabled: true),
        );

        for (final forbidden in _forbiddenDisplayText) {
          expect(find.text(forbidden), findsNothing);
        }
        expect(find.textContaining('cpLoss'), findsNothing);
        expect(find.textContaining('winPercent'), findsNothing);
        expect(find.textContaining('accuracy'), findsNothing);
        expect(find.textContaining('acpl'), findsNothing);
        expect(find.textContaining('raw UCI'), findsNothing);
        expect(find.textContaining('PV'), findsNothing);
        expect(find.textContaining('savedAnalysisId'), findsNothing);
        expect(find.textContaining('archiveId'), findsNothing);
        expect(find.textContaining('backend'), findsNothing);
        expect(find.textContaining('persistence'), findsNothing);
      },
    );

    test('preview source stays isolated from normal review paths', () {
      final source = File(
        'lib/features/analysis/presentation/product_review/'
        'product_review_surface_preview_dev_widget.dart',
      ).readAsStringSync();
      final mainSource = File('lib/main.dart').readAsStringSync();
      final homeSource = File(
        'lib/features/home/presentation/views/home_screen.dart',
      ).readAsStringSync();
      final reviewSource = File(
        'lib/features/pgn_review/presentation/views/review_screen.dart',
      ).readAsStringSync();

      expect(source, contains('AnalyzerProductReviewSurfaceFoundation'));
      expect(
        source,
        isNot(contains('AnalyzerProductSafeReviewGatewayDecision')),
      );
      expect(source, isNot(contains('AnalyzerProductReviewSessionFoundation')));
      expect(
        source,
        isNot(contains('AnalyzerProductReviewTimelineFoundation')),
      );
      expect(source, isNot(contains('ReviewController')));
      expect(source, isNot(contains('ReviewScreen')));
      expect(source, isNot(contains('HomeScreen')));
      expect(source, isNot(contains('MoveQuality')));
      expect(source, isNot(contains('savedAnalysisId')));
      expect(source, isNot(contains('archiveId')));

      for (final appSource in [mainSource, homeSource, reviewSource]) {
        expect(
          appSource,
          isNot(contains('ProductReviewSurfacePreviewDevWidget')),
        );
      }
    });

    test('preview source does not contain forbidden public-label terms', () {
      final source = File(
        'lib/features/analysis/presentation/product_review/'
        'product_review_surface_preview_dev_widget.dart',
      ).readAsStringSync();

      for (final forbidden in _forbiddenSourceText) {
        expect(source, isNot(contains(forbidden)));
      }
    });
  });
}

Widget _host({
  required AnalyzerProductReviewSurfaceFoundation surface,
  bool enabled = false,
}) {
  return MaterialApp(
    theme: ApexTheme.dark,
    home: ProductReviewSurfacePreviewDevWidget(
      surface: surface,
      enabled: enabled,
    ),
  );
}

abstract final class _SurfaceFixture {
  static AnalyzerProductReviewSurfaceFoundation fromCleanContractChain() {
    final foundation = mapProductReviewFoundationViewModelFromContract(
      _contract(),
    );
    final session = mapProductReviewSessionFoundationFromFoundation(foundation);
    final timeline = mapProductReviewTimelineFoundationFromSession(session);
    return mapProductReviewSurfaceFoundationFromTimeline(timeline);
  }

  static AnalyzerProductReviewSurfaceFoundation ready() {
    return _surface();
  }

  static AnalyzerProductReviewSurfaceFoundation mixedCounts() {
    return _surface(
      totalPrivateEntries: 8,
      positiveCandidateCount: 3,
      neutralCandidateCount: 2,
      negativeCandidateCount: 1,
      unavailableCount: 2,
    );
  }

  static AnalyzerProductReviewSurfaceFoundation multipleEntries() {
    return _surface(
      totalPrivateEntries: 2,
      neutralCandidateCount: 1,
      unavailableCount: 1,
      timelineEntries: const [
        AnalyzerProductReviewSurfaceTimelineEntryFoundation(
          entryId: 'timeline:entry:0',
          entryKind:
              AnalyzerProductReviewTimelineEntryKind.neutralSessionSummary,
          entryReady: true,
          entryIsInternalOnly: true,
          entryContainsPublicLabel: false,
          entryContainsOfficialMetric: false,
        ),
        AnalyzerProductReviewSurfaceTimelineEntryFoundation(
          entryId: 'timeline:entry:1',
          entryKind: AnalyzerProductReviewTimelineEntryKind.unavailable,
          entryReady: false,
          entryIsInternalOnly: true,
          entryContainsPublicLabel: false,
          entryContainsOfficialMetric: false,
        ),
      ],
    );
  }

  static AnalyzerProductReviewSurfaceFoundation blocked() {
    return _surface(
      surfaceComputed: false,
      surfaceReady: false,
      unavailableReason:
          AnalyzerNeutralReviewPreviewUnavailableReason.sourceUnsafe,
      productSafeStatus: 'blocked',
      readiness: 'unavailable',
      totalPrivateEntries: 0,
      neutralCandidateCount: 0,
      unavailableCount: 1,
      boardPreviewReason:
          AnalyzerProductReviewSurfaceBoardPreviewReason.sourceUnavailable,
      planningAllowed: false,
      surfaceIsProductSafe: false,
      safeForPhase41A: false,
      nextRecommendation:
          analyzerProductReviewSurfaceFoundationFailureRecommendation,
      timelineEntries: const [
        AnalyzerProductReviewSurfaceTimelineEntryFoundation(
          entryId: 'timeline:entry:blocked',
          entryKind: AnalyzerProductReviewTimelineEntryKind.unavailable,
          entryReady: false,
          entryIsInternalOnly: true,
          entryContainsPublicLabel: false,
          entryContainsOfficialMetric: false,
        ),
      ],
    );
  }

  static AnalyzerProductReviewSurfaceFoundation unsafeSource() {
    return _surface(
      surfaceComputed: false,
      surfaceReady: false,
      unavailableReason:
          AnalyzerNeutralReviewPreviewUnavailableReason.uiRenderingAllowed,
      productSafeStatus: 'blocked',
      readiness: 'unavailable',
      uiRenderingAllowed: true,
      savedAnalysisAllowed: true,
      archiveStatsAllowed: true,
      publicLabelsAllowed: true,
      officialMetricsAllowed: true,
      surfaceIsProductSafe: false,
      safeForPhase41A: false,
      nextRecommendation:
          analyzerProductReviewSurfaceFoundationFailureRecommendation,
    );
  }
}

AnalyzerProductSafeReviewContract _contract() {
  return const AnalyzerProductSafeReviewContract(
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
    contractContainsPublicLabels: false,
    contractContainsOfficialMetrics: false,
    contractContainsUiPresentation: false,
    publicLabelComputed: false,
    publicLabel: null,
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

AnalyzerProductReviewSurfaceFoundation _surface({
  bool surfaceComputed = true,
  bool surfaceReady = true,
  AnalyzerNeutralReviewPreviewUnavailableReason unavailableReason =
      AnalyzerNeutralReviewPreviewUnavailableReason.none,
  String sourceTimelineId = 'productReviewTimeline:test:surface',
  String surfaceTitle = 'Review foundation',
  String readiness = 'ready',
  AnalyzerProductSafeReviewScope scope =
      AnalyzerProductSafeReviewScope.singleMoveControlled,
  AnalyzerProductSafeReviewEvidenceStrength evidenceStrength =
      AnalyzerProductSafeReviewEvidenceStrength.developerProofOnly,
  String productSafeStatus = 'productSafe',
  int totalPrivateEntries = 1,
  int positiveCandidateCount = 0,
  int neutralCandidateCount = 1,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  bool publicLabelsBlocked = true,
  bool officialMetricsBlocked = true,
  bool savedArchiveBlocked = true,
  bool boardPreviewAvailable = false,
  AnalyzerProductReviewSurfaceBoardPreviewReason boardPreviewReason =
      AnalyzerProductReviewSurfaceBoardPreviewReason.uiRenderingBlocked,
  List<AnalyzerProductReviewSurfaceTimelineEntryFoundation>? timelineEntries,
  bool planningAllowed = true,
  bool uiRenderingAllowed = false,
  bool savedAnalysisAllowed = false,
  bool archiveStatsAllowed = false,
  bool publicLabelsAllowed = false,
  bool officialMetricsAllowed = false,
  bool surfaceIsReadOnly = true,
  bool surfaceIsProductSafe = true,
  bool surfaceIsUiOutput = false,
  bool surfaceIsSavedAnalysis = false,
  bool surfaceContainsPublicLabels = false,
  bool surfaceContainsOfficialMetrics = false,
  bool safeForPhase41A = true,
  String nextRecommendation =
      analyzerProductReviewSurfaceFoundationNextRecommendation,
}) {
  return AnalyzerProductReviewSurfaceFoundation(
    surfaceComputed: surfaceComputed,
    surfaceReady: surfaceReady,
    unavailableReason: unavailableReason,
    sourceTimelineId: sourceTimelineId,
    header: AnalyzerProductReviewHeaderFoundation(
      surfaceTitle: surfaceTitle,
      readiness: readiness,
      scope: scope,
      evidenceStrength: evidenceStrength,
      productSafeStatus: productSafeStatus,
    ),
    summary: AnalyzerProductReviewSummaryFoundation(
      totalPrivateEntries: totalPrivateEntries,
      positiveCandidateCount: positiveCandidateCount,
      neutralCandidateCount: neutralCandidateCount,
      negativeCandidateCount: negativeCandidateCount,
      unavailableCount: unavailableCount,
      publicLabelsBlocked: publicLabelsBlocked,
      officialMetricsBlocked: officialMetricsBlocked,
      savedArchiveBlocked: savedArchiveBlocked,
    ),
    board: AnalyzerProductReviewBoardSafeFoundation(
      boardPreviewAvailable: boardPreviewAvailable,
      boardPreviewReason: boardPreviewReason,
    ),
    timelineEntries:
        timelineEntries ??
        const [
          AnalyzerProductReviewSurfaceTimelineEntryFoundation(
            entryId: 'timeline:entry:0',
            entryKind:
                AnalyzerProductReviewTimelineEntryKind.neutralSessionSummary,
            entryReady: true,
            entryIsInternalOnly: true,
            entryContainsPublicLabel: false,
            entryContainsOfficialMetric: false,
          ),
        ],
    planningAllowed: planningAllowed,
    uiRenderingAllowed: uiRenderingAllowed,
    savedAnalysisAllowed: savedAnalysisAllowed,
    archiveStatsAllowed: archiveStatsAllowed,
    publicLabelsAllowed: publicLabelsAllowed,
    officialMetricsAllowed: officialMetricsAllowed,
    surfaceIsReadOnly: surfaceIsReadOnly,
    surfaceIsProductSafe: surfaceIsProductSafe,
    surfaceIsUiOutput: surfaceIsUiOutput,
    surfaceIsSavedAnalysis: surfaceIsSavedAnalysis,
    surfaceContainsPublicLabels: surfaceContainsPublicLabels,
    surfaceContainsOfficialMetrics: surfaceContainsOfficialMetrics,
    safeForPhase41A: safeForPhase41A,
    nextRecommendation: nextRecommendation,
  );
}

const _forbiddenDisplayText = [
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
  'CP-loss',
  'Win%',
  'Accuracy',
  'ACPL',
  'engine score',
  'raw UCI',
  'savedAnalysisId',
  'archiveId',
];

const _forbiddenSourceText = [
  'Brilliant',
  'Great Move',
  'Best',
  'Excellent',
  'Good',
  'Inaccuracy',
  'Mistake',
  'Blunder',
  'MoveQuality',
  'CP-loss',
  'Win%',
  'Accuracy',
  'ACPL',
  'engine score',
  'raw UCI',
  'savedAnalysisId',
  'archiveId',
];
