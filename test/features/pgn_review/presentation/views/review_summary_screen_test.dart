/// Widget smoke test for [ReviewSummaryScreen] — Phase 20.1 § 3.
///
/// Pins:
///   * Screen renders all five blocks (result header, accuracy row,
///     counts strip, highlights, phase breakdown) when a timeline is
///     loaded.
///   * "Re-analyze Deep" CTA appears only for Quick-mode timelines.
///   * The empty-state path ("No analysis loaded") shows when no
///     timeline is present.
library;

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

MoveAnalysis _m({
  required int ply,
  required bool isWhite,
  required MoveQuality cls,
  double deltaW = 0,
  String san = 'Nf3',
}) =>
    MoveAnalysis(
      ply: ply,
      san: san,
      uci: 'g1f3',
      fenBefore: '',
      fenAfter: '',
      winPercentBefore: 50,
      winPercentAfter: 50 + deltaW,
      deltaW: deltaW,
      isWhiteMove: isWhite,
      classification: cls,
      message: '',
    );

AnalysisTimeline _timeline() => AnalysisTimeline(
      moves: [
        _m(ply: 0, isWhite: true, cls: MoveQuality.best),
        _m(ply: 1, isWhite: false, cls: MoveQuality.best),
        _m(
            ply: 2,
            isWhite: true,
            cls: MoveQuality.blunder,
            deltaW: -40,
            san: 'Nxf7??'),
        _m(ply: 3, isWhite: false, cls: MoveQuality.best),
      ],
      startingFen:
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      headers: const {'Result': '1-0'},
      winPercentages: const [50, 50, 10, 10],
    );

Widget _host(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: child),
  );
}

void main() {
  testWidgets('Empty state renders when no timeline is loaded',
      (tester) async {
    await tester.pumpWidget(_host(const ReviewSummaryScreen()));
    await tester.pumpAndSettle();
    expect(find.text('No analysis loaded.'), findsOneWidget);
  });

  testWidgets('Renders accuracy + counts + highlights when a timeline is loaded',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(reviewControllerProvider.notifier).loadTimeline(
          _timeline(),
          userIsBlack: false,
          mode: AnalysisMode.deep,
          userIsWhite: true,
        );

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ReviewSummaryScreen()),
    ));
    await tester.pumpAndSettle();

    // Result header.
    expect(find.text('You won'), findsOneWidget);
    // Accuracy pair.
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('OPPONENT'), findsOneWidget);
    // Counts block title.
    expect(find.text('COUNTS'), findsOneWidget);
    // Key moments block.
    expect(find.text('KEY MOMENTS'), findsOneWidget);
    // Phase breakdown block.
    expect(find.text('PHASE PERFORMANCE'), findsOneWidget);
    // Primary CTA — scroll into view first, the summary is a long
    // ListView.
    final reviewCta = find.text('Review Moves');
    await tester.scrollUntilVisible(reviewCta, 200);
    expect(reviewCta, findsOneWidget);
  });

  testWidgets('Re-analyze Deep CTA appears only in Quick mode', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(reviewControllerProvider.notifier).loadTimeline(
          _timeline(),
          userIsBlack: false,
          mode: AnalysisMode.quick,
          userIsWhite: true,
        );

    bool called = false;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: ReviewSummaryScreen(
          onReanalyzeDeep: () async => called = true,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final cta = find.text('Re-analyze Deep');
    await tester.scrollUntilVisible(cta, 200);
    expect(cta, findsOneWidget);
    await tester.tap(cta);
    await tester.pumpAndSettle();
    expect(called, isTrue);
  });

  testWidgets('Re-analyze Deep hidden in Deep mode', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(reviewControllerProvider.notifier).loadTimeline(
          _timeline(),
          userIsBlack: false,
          mode: AnalysisMode.deep,
          userIsWhite: true,
        );

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: ReviewSummaryScreen(
          onReanalyzeDeep: () async {},
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Re-analyze Deep'), findsNothing);
  });
}
