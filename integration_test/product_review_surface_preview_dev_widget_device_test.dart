import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_product_safe_review_contract.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_foundation_view_model.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_session_foundation.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_surface_foundation.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_timeline_foundation.dart';
import 'package:apex_chess/features/analysis/presentation/product_review/product_review_surface_preview_dev_widget.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android product review surface preview dev widget proof', (
    tester,
  ) async {
    if (!Platform.isAndroid) {
      markTestSkipped('Run this proof on an Android device or emulator.');
      return;
    }

    final surface = _readySurface();
    await tester.pumpWidget(
      MaterialApp(
        theme: ApexTheme.dark,
        home: ProductReviewSurfacePreviewDevWidget(
          surface: surface,
          enabled: true,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('product-review-surface-preview-dev-ready')),
      findsOneWidget,
    );
    expect(find.text('Apex Review Preview'), findsOneWidget);
    expect(find.text('Product review surface'), findsOneWidget);
    expect(
      find.text('Developer-only preview. Normal review UI is not active.'),
      findsOneWidget,
    );
    expect(find.text('Readiness'), findsOneWidget);
    expect(find.text('Internal counts'), findsOneWidget);
    expect(find.text('Board preview'), findsOneWidget);
    expect(find.text('Timeline entries'), findsOneWidget);
    expect(find.text('Guardrails'), findsOneWidget);
    expect(find.text('surfaceReady'), findsOneWidget);
    expect(find.text('Review foundation'), findsOneWidget);
    expect(find.text('singleMoveControlled'), findsOneWidget);
    expect(find.text('developerProofOnly'), findsOneWidget);
    expect(find.text('totalPrivateEntries'), findsOneWidget);
    expect(find.text('neutralSessionSummary'), findsOneWidget);
    expect(find.text('boardPreviewAvailable'), findsOneWidget);
    expect(find.text('boardPreviewReason'), findsOneWidget);
    expect(find.text('uiRenderingBlocked'), findsOneWidget);
    expect(find.text('UI rendering'), findsOneWidget);
    expect(find.text('Public labels'), findsOneWidget);
    expect(find.text('Official metrics'), findsOneWidget);
    expect(find.text('Saved/archive'), findsOneWidget);
    expect(find.text('blocked'), findsWidgets);

    for (final forbidden in [
      'Brilliant',
      'Best',
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
    ]) {
      expect(find.text(forbidden), findsNothing);
    }
    expect(find.textContaining('cpLoss'), findsNothing);
    expect(find.textContaining('winPercent'), findsNothing);
    expect(find.textContaining('accuracy'), findsNothing);
    expect(find.textContaining('rawOutput'), findsNothing);

    // ignore: avoid_print
    print(
      'APEX_PRODUCT_REVIEW_SURFACE_PREVIEW_DEV_WIDGET_PROOF '
      'surfaceReady=${surface.surfaceReady} '
      'unavailableReason=${surface.unavailableReason.wire} '
      'surfaceTitle=${surface.header.surfaceTitle} '
      'readiness=${surface.header.readiness} '
      'scope=${surface.header.scope.wire} '
      'evidenceStrength=${surface.header.evidenceStrength.wire} '
      'productSafeStatus=${surface.header.productSafeStatus} '
      'totalPrivateEntries=${surface.summary.totalPrivateEntries} '
      'positiveCandidateCount=${surface.summary.positiveCandidateCount} '
      'neutralCandidateCount=${surface.summary.neutralCandidateCount} '
      'negativeCandidateCount=${surface.summary.negativeCandidateCount} '
      'unavailableCount=${surface.summary.unavailableCount} '
      'boardPreviewAvailable=${surface.board.boardPreviewAvailable} '
      'boardPreviewReason=${surface.board.boardPreviewReason.wire} '
      'timelineEntryKind=${surface.timelineEntries.single.entryKind.wire} '
      'uiRenderingAllowed=${surface.uiRenderingAllowed} '
      'savedAnalysisAllowed=${surface.savedAnalysisAllowed} '
      'archiveStatsAllowed=${surface.archiveStatsAllowed} '
      'publicLabelsAllowed=${surface.publicLabelsAllowed} '
      'officialMetricsAllowed=${surface.officialMetricsAllowed} '
      'safeForPhase41A=${surface.safeForPhase41A}',
    );
  });
}

AnalyzerProductReviewSurfaceFoundation _readySurface() {
  final foundation = mapProductReviewFoundationViewModelFromContract(
    _contract(),
  );
  final session = mapProductReviewSessionFoundationFromFoundation(foundation);
  final timeline = mapProductReviewTimelineFoundationFromSession(session);
  return mapProductReviewSurfaceFoundationFromTimeline(timeline);
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
