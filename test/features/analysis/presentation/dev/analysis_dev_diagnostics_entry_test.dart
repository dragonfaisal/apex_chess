import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/presentation/dev/analysis_dev_diagnostics_entry.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalysisDevDiagnosticsEntryConfig', () {
    test('defaults to disabled from empty map', () {
      final config = AnalysisDevDiagnosticsEntryConfig.fromMap(const {});

      expect(config.enabled, isFalse);
    });

    test('explicit dev flag enables diagnostics entry', () {
      final config = AnalysisDevDiagnosticsEntryConfig.fromMap(const {
        AnalysisDevDiagnosticsEntryConfigKeys.enabled: 'true',
      });

      expect(config.enabled, isTrue);
    });
  });

  group('AnalysisDevDiagnosticsEntry', () {
    testWidgets('default render stays disabled', (tester) async {
      await tester.pumpWidget(_host(preview: _readyPreview()));

      expect(
        find.byKey(const ValueKey('analysis-dev-diagnostics-entry-disabled')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('analysis-dev-diagnostics-entry-enabled')),
        findsNothing,
      );
      expect(find.text('Developer diagnostics disabled'), findsOneWidget);
      expect(find.text('displayModelReady'), findsNothing);
      expect(find.text('totalPrivateEntries'), findsNothing);
    });

    testWidgets('enabled shell without model shows neutral empty state', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(config: const AnalysisDevDiagnosticsEntryConfig.enabled()),
      );

      expect(
        find.byKey(const ValueKey('analysis-dev-diagnostics-entry-enabled')),
        findsOneWidget,
      );
      expect(find.text('Developer diagnostics enabled'), findsOneWidget);
      expect(
        find.text('Developer diagnostics only. No review surface is active.'),
        findsOneWidget,
      );
      expect(find.text('neutralPreviewModel'), findsOneWidget);
      expect(find.text('not provided'), findsOneWidget);
      expect(find.textContaining('totalPrivateEntries'), findsNothing);
    });

    testWidgets('enabled shell with ready model shows neutral fields only', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          config: const AnalysisDevDiagnosticsEntryConfig.enabled(),
          preview: _readyPreview(),
        ),
      );

      expect(
        find.byKey(const ValueKey('analysis-dev-diagnostics-entry-enabled')),
        findsOneWidget,
      );
      expect(
        find.text('Developer diagnostics only. No review surface is active.'),
        findsOneWidget,
      );
      expect(find.text('Neutral preview display model'), findsOneWidget);
      expect(find.text('displayModelReady'), findsOneWidget);
      expect(find.text('true'), findsWidgets);
      expect(find.text('unavailableReason'), findsOneWidget);
      expect(find.text('none'), findsOneWidget);
      expect(find.text('planningAllowed'), findsOneWidget);
      expect(find.text('uiRenderingAllowed'), findsOneWidget);
      expect(find.text('savedAnalysisAllowed'), findsOneWidget);
      expect(find.text('archiveStatsAllowed'), findsOneWidget);
      expect(find.text('publicLabelsAllowed'), findsOneWidget);
      expect(find.text('officialMetricsAllowed'), findsOneWidget);
      expect(find.text('totalPrivateEntries'), findsOneWidget);
      expect(find.text('positiveCandidateCount'), findsOneWidget);
      expect(find.text('neutralCandidateCount'), findsOneWidget);
      expect(find.text('negativeCandidateCount'), findsOneWidget);
      expect(find.text('unavailableCount'), findsOneWidget);
    });

    testWidgets('enabled model keeps unsafe surfaces blocked', (tester) async {
      await tester.pumpWidget(
        _host(
          config: const AnalysisDevDiagnosticsEntryConfig.enabled(),
          preview: _readyPreview(),
        ),
      );

      expect(find.text('UI rendering'), findsOneWidget);
      expect(find.text('Public labels'), findsOneWidget);
      expect(find.text('Official metrics'), findsOneWidget);
      expect(find.text('Saved/archive'), findsOneWidget);
      expect(find.text('blocked'), findsWidgets);
      expect(find.text('uiRenderingAllowed'), findsOneWidget);
      expect(find.text('publicLabelsAllowed'), findsOneWidget);
      expect(find.text('officialMetricsAllowed'), findsOneWidget);
      expect(find.text('savedAnalysisAllowed'), findsOneWidget);
      expect(find.text('archiveStatsAllowed'), findsOneWidget);
      expect(find.text('false blocked'), findsWidgets);
    });

    testWidgets('forbidden labels and official metrics are absent', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          config: const AnalysisDevDiagnosticsEntryConfig.enabled(),
          preview: _readyPreview(),
        ),
      );

      for (final forbidden in [
        'Brilliant',
        'Great',
        'Best',
        'Excellent',
        'Good',
        'Book',
        'Inaccuracy',
        'Mistake',
        'Blunder',
        'CP-loss',
        'Win%',
        'Accuracy',
        'ACPL',
      ]) {
        expect(find.text(forbidden), findsNothing);
      }
      expect(find.textContaining('cpLoss'), findsNothing);
      expect(find.textContaining('winPercent'), findsNothing);
      expect(find.textContaining('accuracy'), findsNothing);
      expect(find.textContaining('acpl'), findsNothing);
    });

    test('entry source stays shell-only and forbidden-surface-free', () {
      final source = File(
        'lib/features/analysis/presentation/dev/'
        'analysis_dev_diagnostics_entry.dart',
      ).readAsStringSync();

      expect(source, contains('bool.fromEnvironment'));
      expect(source, contains(AnalysisDevDiagnosticsEntryConfigKeys.enabled));
      expect(source, contains('analyzer_neutral_review_preview_display_model'));
      expect(source, isNot(contains('analyzer_product_safe_review_gateway')));
      expect(source, isNot(contains('ReviewController')));
      expect(source, isNot(contains('ReviewScreen')));
      expect(source, isNot(contains('ReviewSummaryScreen')));
      expect(source, isNot(contains('HomeScreen')));
      expect(source, isNot(contains('Archive')));
      expect(source, isNot(contains('Hive')));
      expect(source, isNot(contains('backend')));
      expect(source, isNot(contains('http')));
    });

    test('main home and review paths do not expose the diagnostics entry', () {
      final mainSource = File('lib/main.dart').readAsStringSync();
      final homeSource = File(
        'lib/features/home/presentation/views/home_screen.dart',
      ).readAsStringSync();
      final reviewSource = File(
        'lib/features/pgn_review/presentation/views/review_screen.dart',
      ).readAsStringSync();
      final reviewSummarySource = File(
        'lib/features/pgn_review/presentation/views/review_summary_screen.dart',
      ).readAsStringSync();

      for (final source in [
        mainSource,
        homeSource,
        reviewSource,
        reviewSummarySource,
      ]) {
        expect(source, isNot(contains('AnalysisDevDiagnosticsEntry')));
        expect(
          source,
          isNot(contains(AnalysisDevDiagnosticsEntryConfigKeys.enabled)),
        );
      }
    });
  });
}

Widget _host({
  AnalysisDevDiagnosticsEntryConfig? config,
  AnalyzerNeutralReviewPreviewDisplayModel? preview,
}) {
  return MaterialApp(
    theme: ApexTheme.dark,
    home: AnalysisDevDiagnosticsEntry(config: config, preview: preview),
  );
}

AnalyzerNeutralReviewPreviewDisplayModel _readyPreview() {
  return const AnalyzerNeutralReviewPreviewDisplayModel(
    displayModelComputed: true,
    displayModelReady: true,
    unavailableReason: AnalyzerNeutralReviewPreviewUnavailableReason.none,
    planningAllowed: true,
    uiRenderingAllowed: false,
    savedAnalysisAllowed: false,
    archiveStatsAllowed: false,
    publicLabelsAllowed: false,
    officialMetricsAllowed: false,
    totalPrivateEntries: 7,
    positiveCandidateCount: 3,
    neutralCandidateCount: 2,
    negativeCandidateCount: 1,
    unavailableCount: 1,
    safeForPhase39C: true,
    nextRecommendation: 'planDevGatedNeutralPreviewSurface',
  );
}
