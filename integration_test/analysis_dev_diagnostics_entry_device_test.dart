import 'dart:io';

import 'package:apex_chess/features/analysis/domain/analyzer_neutral_review_preview_display_model.dart';
import 'package:apex_chess/features/analysis/presentation/dev/analysis_dev_diagnostics_entry.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const analysisDevDiagnosticsEntryProofFlag =
    AnalysisDevDiagnosticsEntryConfigKeys.enabled;

bool isAnalysisDevDiagnosticsEntryProofEnabled({
  String flagValue = const String.fromEnvironment(
    analysisDevDiagnosticsEntryProofFlag,
  ),
}) {
  return flagValue.toLowerCase() == 'true';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opt-in Android analysis dev diagnostics entry proof', (
    tester,
  ) async {
    if (!isAnalysisDevDiagnosticsEntryProofEnabled()) {
      markTestSkipped(
        'Set --dart-define=$analysisDevDiagnosticsEntryProofFlag=true '
        'to run the Android analysis dev diagnostics entry proof.',
      );
      return;
    }

    if (!Platform.isAndroid) {
      markTestSkipped('Run this proof on an Android device or emulator.');
      return;
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: ApexTheme.dark,
        home: AnalysisDevDiagnosticsEntry(
          config: AnalysisDevDiagnosticsEntryConfig.fromEnvironment(),
          preview: _readyPreview(),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('analysis-dev-diagnostics-entry-enabled')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('analysis-dev-diagnostics-entry-disabled')),
      findsNothing,
    );

    expect(find.text('Developer diagnostics enabled'), findsOneWidget);
    expect(
      find.text('Developer diagnostics only. No review surface is active.'),
      findsOneWidget,
    );
    expect(find.text('Neutral preview display model'), findsOneWidget);
    expect(find.text('displayModelReady'), findsOneWidget);
    expect(find.text('unavailableReason'), findsOneWidget);
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
    expect(find.text('UI rendering'), findsOneWidget);
    expect(find.text('Public labels'), findsOneWidget);
    expect(find.text('Official metrics'), findsOneWidget);
    expect(find.text('Saved/archive'), findsOneWidget);
    expect(find.text('blocked'), findsWidgets);
    expect(find.text('false blocked'), findsWidgets);

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
      'engine raw score',
      'savedAnalysisId',
      'archiveId',
    ]) {
      expect(find.text(forbidden), findsNothing);
    }
    expect(find.textContaining('cpLoss'), findsNothing);
    expect(find.textContaining('winPercent'), findsNothing);
    expect(find.textContaining('accuracy'), findsNothing);
    expect(find.textContaining('acpl'), findsNothing);

    // ignore: avoid_print
    print(
      'APEX_ANALYSIS_DEV_DIAGNOSTICS_ENTRY_PROOF '
      'enabled=true '
      'displayModelReady=true '
      'planningAllowed=true '
      'uiRenderingAllowed=false '
      'savedAnalysisAllowed=false '
      'archiveStatsAllowed=false '
      'publicLabelsAllowed=false '
      'officialMetricsAllowed=false '
      'totalPrivateEntries=7 '
      'positiveCandidateCount=3 '
      'neutralCandidateCount=2 '
      'negativeCandidateCount=1 '
      'unavailableCount=1',
    );
  });
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
