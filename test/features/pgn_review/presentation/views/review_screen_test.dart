import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_screen.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/move_insight_test_fixtures.dart';

const _startFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

MoveAnalysis _move({
  required int ply,
  required bool isWhite,
  required String san,
  required String uci,
  MoveQuality quality = MoveQuality.good,
  int? scoreCpAfter,
  String? bestUci,
  String? bestSan,
  List<EngineLine> engineLines = const <EngineLine>[],
  String coachExplanation = '',
  MoveInsight? insight,
}) {
  return MoveAnalysis(
    ply: ply,
    san: san,
    uci: uci,
    fenBefore: _startFen,
    fenAfter: _startFen,
    targetSquare: uci.substring(2, 4),
    winPercentBefore: 50,
    winPercentAfter: 50,
    deltaW: 0,
    isWhiteMove: isWhite,
    classification: quality,
    message: '',
    scoreCpAfter: scoreCpAfter,
    engineBestMoveUci: bestUci,
    engineBestMoveSan: bestSan,
    engineLines: engineLines,
    coachExplanation: coachExplanation,
    insight: insight,
  );
}

AnalysisTimeline _timeline({
  String white = 'ALFAISALproWithVeryLongTournamentHandle',
  String black = 'magnoliachickenhatdogWithVeryLongSuffix',
  String thirdSan = 'Qh5??',
  bool includeFirstInsight = true,
  String firstOpeningName = "King's Pawn Game",
  MoveInsight? firstInsight,
}) {
  return AnalysisTimeline(
    moves: [
      _move(
        ply: 0,
        isWhite: true,
        san: 'e4',
        uci: 'e2e4',
        quality: MoveQuality.best,
        scoreCpAfter: 24,
        coachExplanation: 'Spoofed legacy explanation.',
        insight: includeFirstInsight
            ? firstInsight ?? testBookInsight(name: firstOpeningName)
            : null,
      ),
      _move(
        ply: 1,
        isWhite: false,
        san: 'e5',
        uci: 'e7e5',
        quality: MoveQuality.inaccuracy,
        scoreCpAfter: 45,
        bestUci: 'c7c5',
        bestSan: 'c5',
        coachExplanation: 'Spoofed legacy explanation.',
        insight: testMaterialDropInsight(
          reply: 'Nc6',
          betterMove: 'c5',
          pieceRole: 'pawn',
        ),
        engineLines: const [
          EngineLine(
            rank: 1,
            moveSan: 'c5 Nf3',
            depth: 18,
            whiteWinPercent: 52,
          ),
        ],
      ),
      _move(
        ply: 2,
        isWhite: true,
        san: thirdSan,
        uci: 'd1h5',
        quality: MoveQuality.blunder,
        scoreCpAfter: -180,
        bestUci: 'g1f3',
        bestSan: 'Nf3',
        coachExplanation: 'Spoofed legacy explanation.',
        insight: testMaterialDropInsight(
          reply: 'Nf6',
          betterMove: 'Nf3',
          pieceRole: 'queen',
        ),
      ),
    ],
    startingFen: _startFen,
    headers: {
      'White': white,
      'Black': black,
      'WhiteElo': '860',
      'BlackElo': '851',
      'Result': '1-0',
    },
    winPercentages: const [50, 54, 31],
    explanationPolicyVersion: kApexExplanationPolicyVersion,
    explanationClaimSchemaVersion: kApexExplanationClaimSchemaVersion,
    explanationRendererVersion: kApexExplanationRendererVersion,
    analysisSchemaVersion: kApexAnalysisSchemaVersion,
  );
}

Widget _host(
  ProviderContainer container, {
  double textScale = 1,
  TextDirection direction = TextDirection.ltr,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: ApexTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: Directionality(textDirection: direction, child: child!),
      ),
      home: const ReviewScreen(),
    ),
  );
}

Widget _corruptReviewHost(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: ApexTheme.dark,
      initialRoute: '/review',
      routes: <String, WidgetBuilder>{
        '/': (_) => const Scaffold(
          body: Center(
            child: Text(
              'Archive',
              key: ValueKey('corrupt-review-back-destination'),
            ),
          ),
        ),
        '/review': (_) => const ReviewScreen(),
      },
    ),
  );
}

Future<void> _pumpReview(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('review screen renders board headers controls and timeline', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(_timeline(), userIsWhite: true);

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);

    expect(find.byKey(const ValueKey('review-board-section')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('review-top-player-header')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('review-bottom-player-header')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('review-nav-controls')), findsOneWidget);
    expect(find.byKey(const ValueKey('review-prev-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('review-next-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('review-ply-counter')), findsOneWidget);
    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.byKey(const ValueKey('review-coach-insight')), findsOneWidget);
    expect(find.byKey(const ValueKey('review-timeline')), findsOneWidget);
    expect(find.text('Full Move Report'), findsNothing);
    expect(find.byKey(const ValueKey('review-command-summary')), findsNothing);
    expect(find.byKey(const ValueKey('review-command-flip')), findsNothing);
    expect(find.byIcon(Icons.analytics_outlined), findsNothing);
    expect(find.byIcon(Icons.screen_rotation_alt_rounded), findsNothing);
  });

  testWidgets('timeline tap and next previous update active ply', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 920);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(_timeline(), userIsWhite: true);

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);

    await tester.tap(
      find.ancestor(of: find.text('1... e5'), matching: find.byType(InkWell)),
    );
    await _pumpReview(tester);
    expect(container.read(reviewControllerProvider).currentPly, 1);

    await tester.tap(find.byKey(const ValueKey('review-next-button')));
    await _pumpReview(tester);
    expect(container.read(reviewControllerProvider).currentPly, 2);

    await tester.tap(find.byKey(const ValueKey('review-prev-button')));
    await _pumpReview(tester);
    expect(container.read(reviewControllerProvider).currentPly, 1);
  });

  testWidgets('start end and critical controls select authoritative ply', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(_timeline(), userIsWhite: true);

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);

    await tester.tap(find.byKey(const ValueKey('review-next-critical-button')));
    await _pumpReview(tester);
    expect(container.read(reviewControllerProvider).currentPly, 1);

    await tester.tap(find.byKey(const ValueKey('review-next-critical-button')));
    await _pumpReview(tester);
    expect(container.read(reviewControllerProvider).currentPly, 2);

    await tester.tap(find.byKey(const ValueKey('review-prev-critical-button')));
    await _pumpReview(tester);
    expect(container.read(reviewControllerProvider).currentPly, 1);

    await tester.tap(find.byKey(const ValueKey('review-end-button')));
    await _pumpReview(tester);
    expect(container.read(reviewControllerProvider).currentPly, 2);

    await tester.tap(find.byKey(const ValueKey('review-start-button')));
    await _pumpReview(tester);
    expect(container.read(reviewControllerProvider).currentPly, -1);
    expect(find.text('Start position'), findsOneWidget);
  });

  testWidgets('selected move remains visible when insight is absent', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(_timeline(includeFirstInsight: false), userIsWhite: true);

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);

    expect(find.byKey(const ValueKey('review-selected-move')), findsOneWidget);
    expect(find.text('1. e4'), findsWidgets);
    expect(find.byKey(const ValueKey('review-coach-insight')), findsNothing);
  });

  testWidgets('coach command orb opens closes and contains secondary actions', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(_timeline(), userIsWhite: true);

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);

    expect(
      find.byKey(const ValueKey('review-coach-command-menu')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('review-command-better')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('review-coach-orb')));
    await _pumpReview(tester);

    expect(
      find.byKey(const ValueKey('review-coach-command-menu')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('review-command-explain')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('review-command-line')), findsNothing);
    expect(find.byKey(const ValueKey('review-command-flip')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('review-command-summary')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('review-command-better')), findsNothing);

    await tester.tapAt(const Offset(8, 8));
    await _pumpReview(tester);

    expect(
      find.byKey(const ValueKey('review-coach-command-menu')),
      findsNothing,
    );
  });

  testWidgets(
    'coach command context and explain sheet update with active ply',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(reviewControllerProvider.notifier)
          .loadTimeline(_timeline(), userIsWhite: true);

      await tester.pumpWidget(_host(container));
      await _pumpReview(tester);

      await tester.tap(find.byKey(const ValueKey('review-coach-orb')));
      await _pumpReview(tester);
      expect(find.byKey(const ValueKey('review-command-better')), findsNothing);

      container.read(reviewControllerProvider.notifier).jumpTo(1);
      await _pumpReview(tester);
      expect(
        find.byKey(const ValueKey('review-command-better')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('review-command-explain')));
      await _pumpReview(tester);

      final sheet = find.byKey(const ValueKey('review-coach-explain-sheet'));
      expect(sheet, findsOneWidget);
      expect(
        find.descendant(of: sheet, matching: find.text('Move insight')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('1... e5')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(
            'The opponent’s best reply prevents recovery of the material.',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Better Move')),
        findsNothing,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Better: c5')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text('Stronger continuation.'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Nc6 Kf1 Qxa2')),
        findsOneWidget,
      );

      container.read(reviewControllerProvider.notifier).jumpTo(2);
      await _pumpReview(tester);

      expect(
        find.descendant(of: sheet, matching: find.text('2. Qh5??')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(
            'The opponent’s best reply prevents recovery of the material.',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.text('Better: Nf3')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text('Avoids the worst of the danger.'),
        ),
        findsNothing,
      );
    },
  );

  testWidgets('collapsed insight stays concise while details remain expanded', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(_timeline(), userIsWhite: true);

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);

    expect(
      find.byKey(const ValueKey('review-coach-better-move')),
      findsNothing,
    );
    expect(
      find.text("This follows B00 · King's Pawn Game theory."),
      findsOneWidget,
    );
    expect(find.textContaining('Better:'), findsNothing);

    container.read(reviewControllerProvider.notifier).jumpTo(1);
    await _pumpReview(tester);

    expect(
      find.byKey(const ValueKey('review-coach-better-move')),
      findsNothing,
    );
    expect(find.text('After Nc6, the pawn is lost.'), findsOneWidget);
    expect(find.text('Better: c5'), findsNothing);
    expect(find.text('Stronger continuation.'), findsNothing);
    expect(
      find.byKey(const ValueKey('review-coach-line-detail')),
      findsNothing,
    );
    expect(find.text('Nc6 Kf1 Qxa2'), findsNothing);

    container.read(reviewControllerProvider.notifier).jumpTo(2);
    await _pumpReview(tester);

    expect(find.text('After Nf6, the queen is lost.'), findsOneWidget);
    expect(find.text('Better: Nf3'), findsNothing);
    expect(find.text('Avoids the worst of the danger.'), findsNothing);
    expect(find.text('Better: c5'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('review-coach-orb')));
    await _pumpReview(tester);
    expect(find.byKey(const ValueKey('review-command-line')), findsNothing);
  });

  testWidgets('move list sheet is ordered compact and tracks active ply', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(_timeline(), userIsWhite: true);

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);

    await tester.tap(find.byKey(const ValueKey('review-move-list-button')));
    await _pumpReview(tester);

    final sheet = find.byKey(const ValueKey('review-move-list-sheet'));
    expect(sheet, findsOneWidget);
    expect(
      find.descendant(of: sheet, matching: find.text('Moves')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('review-move-row-active-0')),
      findsOneWidget,
    );
    expect(
      tester
          .getTopLeft(find.descendant(of: sheet, matching: find.text('1. e4')))
          .dy,
      lessThan(
        tester
            .getTopLeft(
              find.descendant(of: sheet, matching: find.text('1... e5')),
            )
            .dy,
      ),
    );

    await tester.tap(find.byKey(const ValueKey('review-move-row-1')));
    await _pumpReview(tester);

    expect(container.read(reviewControllerProvider).currentPly, 1);
    expect(sheet, findsOneWidget);
    expect(
      find.byKey(const ValueKey('review-move-row-active-1')),
      findsOneWidget,
    );

    container.read(reviewControllerProvider.notifier).jumpTo(2);
    await _pumpReview(tester);

    expect(
      find.byKey(const ValueKey('review-move-row-active-2')),
      findsOneWidget,
    );
  });

  testWidgets('narrow Android layout does not overflow with long names', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(
          _timeline(thirdSan: 'Qxd8+VeryLongSANThatShouldTruncate??'),
          userIsWhite: true,
        );

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('review-board-section')), findsOneWidget);
    expect(find.byKey(const ValueKey('review-board-frame')), findsOneWidget);
    expect(find.byKey(const ValueKey('review-eval-bar')), findsOneWidget);
    expect(find.byKey(const ValueKey('review-eval-label')), findsOneWidget);

    final boardFrameSize = tester.getSize(
      find.byKey(const ValueKey('review-board-frame')),
    );
    final evalBarSize = tester.getSize(
      find.byKey(const ValueKey('review-eval-bar')),
    );
    final evalLabelSize = tester.getSize(
      find.byKey(const ValueKey('review-eval-label')),
    );
    final topHeaderSize = tester.getSize(
      find.byKey(const ValueKey('review-top-player-header')),
    );
    final bottomHeaderSize = tester.getSize(
      find.byKey(const ValueKey('review-bottom-player-header')),
    );

    expect(boardFrameSize.width, greaterThan(318));
    expect(boardFrameSize.height, greaterThan(318));
    expect(evalBarSize.width, lessThanOrEqualTo(18));
    expect(evalLabelSize.width, greaterThan(0));
    expect(evalLabelSize.height, greaterThan(0));
    expect(topHeaderSize.height, lessThanOrEqualTo(42));
    expect(bottomHeaderSize.height, lessThanOrEqualTo(44));

    final evalLabel = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('review-eval-label')),
        matching: find.byType(Text),
      ),
    );
    expect(evalLabel.data, isNotEmpty);
    expect(evalLabel.data, contains('%'));
    expect(
      find.text("This follows B00 · King's Pawn Game theory."),
      findsOneWidget,
    );

    container.read(reviewControllerProvider.notifier).jumpTo(1);
    await _pumpReview(tester);
    expect(
      find.byKey(const ValueKey('review-coach-better-move')),
      findsNothing,
    );

    container.read(reviewControllerProvider.notifier).toggleFlip();
    await _pumpReview(tester);
    expect(find.byKey(const ValueKey('review-board-section')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('very small Android layout keeps board readable', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(
          _timeline(thirdSan: 'Qxd8+VeryLongSANThatShouldTruncate??'),
          userIsWhite: true,
        );

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('review-board-section')), findsOneWidget);
    expect(find.byKey(const ValueKey('review-coach-insight')), findsOneWidget);

    final boardFrameSize = tester.getSize(
      find.byKey(const ValueKey('review-board-frame')),
    );
    final evalBarSize = tester.getSize(
      find.byKey(const ValueKey('review-eval-bar')),
    );

    expect(boardFrameSize.width, greaterThanOrEqualTo(276));
    expect(boardFrameSize.height, greaterThanOrEqualTo(276));
    expect(evalBarSize.width, lessThanOrEqualTo(18));
  });

  testWidgets('advanced causal copy stays compact at 320px and 360px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(
          _timeline(firstInsight: testForkInsight()),
          userIsWhite: true,
        );

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);
    expect(
      find.text(
        'The knight forks the king and queen, so the queen cannot be saved.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(360, 800);
    await tester.pump();
    await _pumpReview(tester);
    await tester.tap(find.byKey(const ValueKey('review-coach-orb')));
    await _pumpReview(tester);
    await tester.tap(find.byKey(const ValueKey('review-command-explain')));
    await _pumpReview(tester);
    expect(
      find.byKey(const ValueKey('review-coach-explain-sheet')),
      findsOneWidget,
    );
    expect(
      find.text('One move creates two immediate threats.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing persisted insight omits the card and explain action', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(_timeline(includeFirstInsight: false), userIsWhite: true);

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);

    expect(find.byKey(const ValueKey('review-coach-insight')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('review-coach-orb')));
    await _pumpReview(tester);
    expect(find.byKey(const ValueKey('review-command-explain')), findsNothing);
  });

  testWidgets('same-ply replacement cannot retain a stale insight artifact', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(reviewControllerProvider.notifier);
    notifier.loadTimeline(_timeline(), userIsWhite: true);

    await tester.pumpWidget(_host(container));
    await _pumpReview(tester);
    expect(
      find.text("This follows B00 · King's Pawn Game theory."),
      findsOneWidget,
    );

    notifier.loadTimeline(
      _timeline(firstOpeningName: 'Apex Replacement Line'),
      userIsWhite: true,
    );
    await _pumpReview(tester);

    expect(
      find.text("This follows B00 · King's Pawn Game theory."),
      findsNothing,
    );
    expect(
      find.text('This follows B00 · Apex Replacement Line theory.'),
      findsOneWidget,
    );
  });

  testWidgets('large text and RTL keep collapsed and expanded insight stable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(_timeline(), userIsWhite: false);

    await tester.pumpWidget(
      _host(container, textScale: 1.8, direction: TextDirection.rtl),
    );
    await _pumpReview(tester);
    container.read(reviewControllerProvider.notifier).jumpTo(1);
    await _pumpReview(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('review-coach-orb')));
    await _pumpReview(tester);
    await tester.tap(find.byKey(const ValueKey('review-command-explain')));
    await _pumpReview(tester);

    expect(
      find.byKey(const ValueKey('review-coach-explain-sheet')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'corrupt saved review is truthful empty semantic and back-navigable',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final semantics = tester.ensureSemantics();
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final opened = container
          .read(reviewControllerProvider.notifier)
          .openSavedReview(
            ArchivedGame(
              id: 'corrupt-review',
              source: ArchiveSource.pgn,
              white: '',
              black: '',
              result: '*',
              analyzedAt: DateTime.utc(2026, 7, 24),
              depth: 0,
              pgn: '',
              qualityCounts: const {},
              averageCpLoss: 0,
              totalPlies: 0,
              recordKind: ArchivedRecordKind.unavailable,
              unavailableReason: 'quarantined-corrupt-value',
            ),
            source: ReviewRuntimeSource.archiveExact,
          );
      expect(opened, isFalse);

      await tester.pumpWidget(_corruptReviewHost(container));
      await tester.pumpAndSettle();

      expect(find.text('Saved review unavailable'), findsOneWidget);
      expect(
        find.text('The saved data could not be safely opened.'),
        findsOneWidget,
      );
      final unavailableSemantics = tester.getSemantics(
        find.byKey(const ValueKey('review-unavailable-semantics')),
      );
      expect(unavailableSemantics.label, contains('Saved review unavailable'));
      expect(
        unavailableSemantics.label,
        contains('The saved data could not be safely opened.'),
      );
      expect(find.byKey(const ValueKey('review-board-frame')), findsNothing);
      expect(find.byKey(const ValueKey('review-timeline')), findsNothing);
      expect(find.byKey(const ValueKey('review-coach-insight')), findsNothing);
      expect(find.textContaining('Retry'), findsNothing);
      expect(find.textContaining('analysis'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('corrupt-review-back-destination')),
        findsOneWidget,
      );
      semantics.dispose();
    },
  );
}
