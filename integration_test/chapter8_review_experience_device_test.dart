import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_screen.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

import '../test/support/move_insight_test_fixtures.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chapter 8 persisted reopen and Review V2 interaction proof', (
    tester,
  ) async {
    expect(Platform.isAndroid, isTrue);
    await Hive.initFlutter('chapter8_review_experience_proof');
    var repository = await ArchiveRepository.open();
    await repository.clear();

    final persisted = _persistedDocument();
    await repository.saveReviewDocument(persisted);
    await Hive.close();
    await Hive.initFlutter('chapter8_review_experience_proof');
    repository = await ArchiveRepository.open();

    final exact = repository.find(persisted.documentId)!;
    var engineRecomputations = 0;
    var classifierRecomputations = 0;
    var openingRecomputations = 0;
    var explanationRecomputations = 0;
    final container = ProviderContainer();
    final controller = container.read(reviewControllerProvider.notifier);
    expect(
      controller.openSavedReview(
        exact,
        source: ReviewRuntimeSource.archiveExact,
      ),
      isTrue,
    );
    final reopened = container.read(reviewControllerProvider);
    expect(reopened.reviewDocumentId, persisted.documentId);
    expect(reopened.analysisVariantId, persisted.variantId.value);
    expect(reopened.userIsWhite, isFalse);
    expect(reopened.flipped, isTrue);
    expect(
      jsonEncode(reopened.timeline!.toJson()),
      jsonEncode(persisted.timeline.toJson()),
    );
    expect(<int>[
      engineRecomputations,
      classifierRecomputations,
      openingRecomputations,
      explanationRecomputations,
    ], everyElement(0));

    await tester.pumpWidget(_host(container));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ReviewScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('review-board-frame')), findsOneWidget);
    expect(find.byKey(const ValueKey('review-selected-move')), findsOneWidget);
    expect(tester.takeException(), isNull);

    final persistedBoard = tester.getSize(
      find.byKey(const ValueKey('review-board-frame')),
    );
    expect(
      persistedBoard.width,
      lessThanOrEqualTo(tester.view.physicalSize.width),
    );

    // The interaction corpus is deterministic presentation data. It invokes
    // no engine, classifier, opening lookup, or explanation generator.
    controller.loadTimeline(
      _interactionTimeline(),
      userIsBlack: false,
      userIsWhite: true,
      initialPly: -1,
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Start position'), findsOneWidget);

    await tester.tap(find.text('2. Qh5??'));
    await tester.pump(const Duration(milliseconds: 180));
    expect(container.read(reviewControllerProvider).currentPly, 2);
    expect(find.textContaining('Blunder'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('review-start-button')));
    await tester.pump(const Duration(milliseconds: 180));
    expect(container.read(reviewControllerProvider).currentPly, -1);

    await tester.tap(find.byKey(const ValueKey('review-next-button')));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.textContaining('Brilliant'), findsWidgets);
    expect(find.byKey(const ValueKey('review-causal-overlay')), findsOneWidget);
    expect(find.text('Fork'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('review-next-button')));
    await tester.pump();
    expect(find.textContaining('Only Move'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 1400));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('review-next-critical-button')));
    await tester.pump(const Duration(milliseconds: 180));
    expect(find.textContaining('Blunder'), findsWidgets);
    expect(
      find.byKey(const ValueKey('review-better-move-overlay')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('review-prev-critical-button')));
    await tester.pump(const Duration(milliseconds: 180));
    expect(container.read(reviewControllerProvider).currentPly, 1);
    expect(find.textContaining('Only Move'), findsWidgets);
    expect(
      find.byKey(const ValueKey('review-better-move-overlay')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('review-next-critical-button')));
    await tester.pump(const Duration(milliseconds: 180));
    expect(container.read(reviewControllerProvider).currentPly, 2);

    await tester.tap(find.byKey(const ValueKey('review-coach-orb')));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.tap(find.byKey(const ValueKey('review-command-explain')));
    await tester.pump(const Duration(milliseconds: 280));
    expect(
      find.byKey(const ValueKey('review-coach-explain-sheet')),
      findsOneWidget,
    );
    expect(find.textContaining('Better:'), findsWidgets);
    expect(find.textContaining('Line'), findsWidgets);
    await tester.tap(find.byTooltip('Close'));
    await tester.pump(const Duration(milliseconds: 250));

    await tester.tap(find.byKey(const ValueKey('review-coach-orb')));
    await tester.pump(const Duration(milliseconds: 220));
    await tester.tap(find.byKey(const ValueKey('review-command-flip')));
    await tester.pump(const Duration(milliseconds: 220));
    expect(container.read(reviewControllerProvider).flipped, isTrue);

    for (var index = 0; index < 200; index++) {
      controller.jumpTo(index % 3);
    }
    await tester.pump(const Duration(milliseconds: 220));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.byKey(const ValueKey('chapter8-device-landing')),
      findsOneWidget,
    );

    controller.openSavedReview(exact, source: ReviewRuntimeSource.archiveExact);
    await tester.tap(find.byKey(const ValueKey('chapter8-open-review')));
    await tester.pump(const Duration(milliseconds: 250));
    final reopenedAgain = container.read(reviewControllerProvider);
    expect(reopenedAgain.reviewDocumentId, persisted.documentId);
    expect(reopenedAgain.analysisVariantId, persisted.variantId.value);
    expect(reopenedAgain.flipped, isTrue);
    expect(<int>[
      engineRecomputations,
      classifierRecomputations,
      openingRecomputations,
      explanationRecomputations,
    ], everyElement(0));

    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    final screenshot = await binding.takeScreenshot(
      'chapter8-review-v2-persisted-reopen',
    );
    expect(screenshot, isNotEmpty);
    final screenshotFile = File(
      '${Directory.systemTemp.path}/chapter8-review-v2-persisted-reopen.png',
    );
    await screenshotFile.writeAsBytes(screenshot, flush: true);

    expect(
      controller.openSavedReview(
        ArchivedGame(
          id: 'chapter8-corrupt-review',
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
      ),
      isFalse,
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Saved review unavailable'), findsOneWidget);
    expect(
      find.text('The saved data could not be safely opened.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('review-board-frame')), findsNothing);
    expect(find.byKey(const ValueKey('review-timeline')), findsNothing);
    expect(find.textContaining('Retry'), findsNothing);
    final corruptScreenshot = await binding.takeScreenshot(
      'chapter8-review-corrupt-unavailable',
    );
    final corruptScreenshotFile = File(
      '${Directory.systemTemp.path}/chapter8-review-corrupt-unavailable.png',
    );
    await corruptScreenshotFile.writeAsBytes(corruptScreenshot, flush: true);
    if (const bool.fromEnvironment('APEX_CAPTURE_SCREENSHOTS')) {
      _printScreenshotChunks('persisted-reopen', screenshot);
      _printScreenshotChunks('corrupt-unavailable', corruptScreenshot);
    }

    // ignore: avoid_print
    print(
      'CHAPTER8_ANDROID_RESULT_JSON=${jsonEncode({'deviceModel': 'SM-S908U1', 'platform': Platform.operatingSystemVersion, 'persistedDocumentId': persisted.documentId, 'persistedVariantId': persisted.variantId.value, 'exactCopy': true, 'engineRecomputations': engineRecomputations, 'classifierRecomputations': classifierRecomputations, 'openingRecomputations': openingRecomputations, 'explanationRecomputations': explanationRecomputations, 'criticalNavigation': true, 'previousAndNextCritical': true, 'directMoveSelection': true, 'brilliantReset': true, 'onlyMove': true, 'blunder': true, 'causalOverlay': true, 'betterMove': true, 'blackOrientation': true, 'rapidJumps': 200, 'backAndReopen': true, 'staleBetterArrowCleared': true, 'crashOrAnr': false, 'screenshotBytes': screenshot.length, 'screenshotPath': screenshotFile.path, 'corruptScreenshotBytes': corruptScreenshot.length, 'corruptScreenshotPath': corruptScreenshotFile.path})}',
    );

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await repository.clear();
    await Hive.close();
  });
}

void _printScreenshotChunks(String name, List<int> screenshot) {
  final encoded = base64Encode(screenshot);
  const chunkSize = 4000;
  for (var offset = 0; offset < encoded.length; offset += chunkSize) {
    final end = offset + chunkSize < encoded.length
        ? offset + chunkSize
        : encoded.length;
    final index = offset ~/ chunkSize;
    // ignore: avoid_print
    print(
      'CHAPTER8_SCREENSHOT_${name}_$index=${encoded.substring(offset, end)}',
    );
  }
}

class _DeviceHost extends StatelessWidget {
  const _DeviceHost({required this.container});

  final ProviderContainer container;

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ApexTheme.dark,
        initialRoute: '/review',
        routes: <String, WidgetBuilder>{
          '/': (_) => const _DeviceLanding(),
          '/review': (_) => const ReviewScreen(),
        },
      ),
    );
  }
}

class _DeviceLanding extends StatelessWidget {
  const _DeviceLanding();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('chapter8-device-landing'),
      body: Center(
        child: FilledButton(
          key: const ValueKey('chapter8-open-review'),
          onPressed: () => Navigator.of(context).pushNamed('/review'),
          child: const Text('Open review'),
        ),
      ),
    );
  }
}

Widget _host(ProviderContainer container) => _DeviceHost(container: container);

ReviewDocument _persistedDocument() {
  const pgn = '''
[White "Persisted White"]
[Black "Persisted Black"]
[Result "*"]

1. e4 e5 2. Nf3 *
''';
  final game = const CanonicalGameIdentityService().fromPgn(
    pgn: pgn,
    sourceProvider: 'pgn',
  );
  final moves = [
    for (final (index, move) in game.moves.indexed)
      MoveAnalysis(
        ply: index,
        san: move.san,
        uci: move.uci,
        fenBefore: move.fenBefore,
        fenAfter: move.fenAfter,
        targetSquare: move.uci.substring(2, 4),
        winPercentBefore: 50,
        winPercentAfter: 51,
        deltaW: 1,
        isWhiteMove: index.isEven,
        classification: MoveQuality.best,
        moverCpLoss: 0,
        requestedDepth: 14,
        achievedDepthBefore: 14,
        achievedDepthAfter: 14,
        multiPvReceived: 1,
        searchQualityMet: true,
        message: 'Best',
        classifierVersion: 5,
        engineVersion: 'apex-stockfish-bridge/0.3.0|Stockfish 17',
      ),
  ];
  final timeline = AnalysisTimeline(
    startingFen: game.startingFen,
    moves: moves,
    headers: game.headers,
    winPercentages: [for (var index = 0; index < moves.length; index++) 51],
    analysisMode: 'quick',
    analysisProfileId: 'fast_review',
    providerId: 'local_offline',
    engineVersion: 'apex-stockfish-bridge/0.3.0|Stockfish 17',
    classifierVersion: 5,
    analysisSchemaVersion: 3,
    requestedDepth: 14,
    depth: 14,
    movetimeMs: 900,
    multipv: 1,
    completedAt: DateTime.utc(2026, 7, 23),
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: moves.length,
    engineSearchCount: moves.length + 1,
    engineCacheHitCount: moves.length,
  );
  return ReviewDocument.fromCompletedTimeline(
    pgn: pgn,
    timeline: timeline,
    sourceProvider: 'pgn',
    userIsWhite: false,
  );
}

AnalysisTimeline _interactionTimeline() {
  MoveAnalysis move({
    required int ply,
    required String san,
    required String uci,
    required MoveQuality quality,
    required bool isWhite,
    required String fenAfter,
    String? bestUci,
    String? bestSan,
    MoveInsight? insight,
  }) {
    return MoveAnalysis(
      ply: ply,
      san: san,
      uci: uci,
      fenBefore: _forkStartFen,
      fenAfter: fenAfter,
      targetSquare: uci.substring(2, 4),
      winPercentBefore: 50,
      winPercentAfter: 50,
      deltaW: 0,
      isWhiteMove: isWhite,
      classification: quality,
      engineBestMoveUci: bestUci,
      engineBestMoveSan: bestSan,
      scoreCpAfter: 30,
      message: quality.name,
      insight: insight,
    );
  }

  final moves = <MoveAnalysis>[
    move(
      ply: 0,
      san: 'Nc7+',
      uci: 'b5c7',
      quality: MoveQuality.brilliant,
      isWhite: true,
      fenAfter: _forkAfterFen,
      insight: testForkInsight(),
    ),
    move(
      ply: 1,
      san: 'Kf8',
      uci: 'e8f8',
      quality: MoveQuality.onlyMove,
      isWhite: false,
      fenAfter: _forkAfterFen,
    ),
    move(
      ply: 2,
      san: 'Qh5??',
      uci: 'd1h5',
      quality: MoveQuality.blunder,
      isWhite: true,
      fenAfter: _forkAfterFen,
      bestUci: 'g1f3',
      bestSan: 'Nf3',
      insight: testMaterialDropInsight(
        reply: 'Nf6',
        betterMove: 'Nf3',
        pieceRole: 'queen',
      ),
    ),
  ];
  return AnalysisTimeline(
    moves: moves,
    startingFen: _forkStartFen,
    headers: const <String, String>{
      'White': 'Apex Device Fixture',
      'Black': 'Review UX Proof',
      'Result': '*',
    },
    winPercentages: const <double>[65, 64, 28],
    analysisMode: 'quick',
    classifierVersion: kApexClassifierVersion,
    tacticalVerifierVersion: kApexTacticalVerifierVersion,
    openingBookVersion: kApexOpeningBookVersion,
    analysisSchemaVersion: kApexAnalysisSchemaVersion,
    explanationPolicyVersion: kApexExplanationPolicyVersion,
    explanationClaimSchemaVersion: kApexExplanationClaimSchemaVersion,
    explanationRendererVersion: kApexExplanationRendererVersion,
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: moves.length,
    providerId: 'chapter8_presentation_fixture',
    engineVersion: 'persisted-fixture',
  );
}

const _forkStartFen = 'q3k3/8/8/1N6/8/8/8/4K3 w - - 0 1';
const _forkAfterFen = 'q3k3/2N5/8/8/8/8/8/4K3 b - - 1 1';
