import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/presentation/widgets/already_reviewed_dialog.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'already-reviewed dialog shows Preview Analyze anyway and close',
    (tester) async {
      AlreadyReviewedAction? action;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  action = await showAlreadyReviewedDialog(
                    context: context,
                    savedReview: _game(mode: AnalysisMode.quick),
                    requestedProfile: AnalysisProfile.deepReview,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('already-reviewed-dialog')),
        findsOneWidget,
      );
      expect(find.text('Already reviewed'), findsOneWidget);
      expect(find.text('Saved mode: Fast'), findsOneWidget);
      expect(find.text('Selected: Deep'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Analyze anyway'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('already-reviewed-close')),
        findsOneWidget,
      );
      expect(find.byType(ApexLoadingScaffold), findsNothing);

      await tester.tap(find.byKey(const ValueKey('already-reviewed-preview')));
      await tester.pumpAndSettle();

      expect(action, AlreadyReviewedAction.preview);
    },
  );

  testWidgets('already-reviewed dialog can close without analysis', (
    tester,
  ) async {
    AlreadyReviewedAction? action = AlreadyReviewedAction.analyzeAnyway;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                action = await showAlreadyReviewedDialog(
                  context: context,
                  savedReview: _game(mode: AnalysisMode.deep),
                  requestedProfile: AnalysisProfile.deepReview,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('already-reviewed-close')));
    await tester.pumpAndSettle();

    expect(action, isNull);
    expect(find.byKey(const ValueKey('already-reviewed-dialog')), findsNothing);
  });
}

ArchivedGame _game({required AnalysisMode mode}) {
  return ArchivedGame(
    id: mode == AnalysisMode.quick ? 'fast' : 'deep',
    source: ArchiveSource.pgn,
    white: 'Alpha',
    black: 'Beta',
    result: '1-0',
    analyzedAt: DateTime(2026, 5, 1),
    depth: mode == AnalysisMode.quick ? 14 : 22,
    pgn: '1. e4 *',
    qualityCounts: const {},
    averageCpLoss: 12,
    totalPlies: 2,
    analysisMode: mode,
    analysisProfileId: mode == AnalysisMode.quick
        ? 'fast_review'
        : 'deep_review',
  );
}
