import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:apex_chess/core/infrastructure/engine/stockfish/stockfish_engine.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/review_entry_contract.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_screen.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_summary_screen.dart';
import 'package:apex_chess/infrastructure/engine/eco_book.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';

const _flag = 'APEX_RUN_TRUSTWORTHY_OFFLINE_REVIEW_CORE_PROOF';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('real Android offline review, save, and reopen proof', (
    tester,
  ) async {
    const enabled = bool.fromEnvironment(_flag);
    if (!enabled) {
      markTestSkipped('Set --dart-define=$_flag=true to run this proof.');
      return;
    }
    expect(Platform.isAndroid, isTrue);

    const pgn = '''
[Event "Chapter 1 Android proof"]
[White "Apex"]
[Black "Device"]
[Result "*"]

1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *
''';
    final engine = StockfishEngine();
    final stopwatch = Stopwatch()..start();
    try {
      final eval = LocalEvalService(engine: engine);
      final analyzer = LocalGameAnalyzer(
        eval: eval,
        book: EcoBook.fromTsv('eco\tname\tpgn\n'),
      );
      final timeline = await analyzer.analyzeFromPgn(
        pgn,
        depth: 8,
        movetime: const Duration(milliseconds: 450),
        mode: AnalysisMode.quick,
      );
      stopwatch.stop();

      expect(timeline.isComplete, isTrue);
      expect(timeline.moves, hasLength(6));
      expect(
        timeline.moves.every((move) => move.engineEvaluationAvailable),
        isTrue,
      );
      expect(timeline.engineVersion.toLowerCase(), isNot(contains('stub')));
      expect(timeline.engineVersion.toLowerCase(), isNot(contains('unknown')));
      expect(timeline.engineSearchCount, greaterThan(0));
      expect(timeline.depth, greaterThan(0));
      expect(
        timeline.moves.any(
          (move) =>
              move.classification == MoveQuality.brilliant ||
              move.classification == MoveQuality.great ||
              move.classification == MoveQuality.forced,
        ),
        isFalse,
      );

      final (realMultiPv, realMultiPvError) = await eval.evaluate(
        timeline.startingFen,
        depth: 8,
        movetime: const Duration(milliseconds: 450),
        multiPv: 3,
      );
      expect(realMultiPvError, isNull);
      expect(realMultiPv, isNotNull);
      expect(realMultiPv!.targetDepthReached, isTrue);
      expect(realMultiPv.multiPvComplete, isTrue);
      expect(realMultiPv.engineLines, hasLength(3));
      expect(realMultiPv.engineLines.map((line) => line.depth).toSet(), {
        realMultiPv.depth,
      });
      expect(
        realMultiPv.engineLines.map((line) => line.moveUci).toSet(),
        hasLength(3),
      );
      expect(realMultiPv.bestMoveUci, realMultiPv.engineLines.first.moveUci);

      await Hive.initFlutter('chapter1_android_proof');
      final repository = await ArchiveRepository.open();
      final game = ArchivedGame.fromTimeline(
        timeline: timeline,
        id: 'chapter1-${DateTime.now().microsecondsSinceEpoch}',
        source: ArchiveSource.pgn,
        depth: timeline.depth ?? 0,
        pgn: pgn,
        analysisMode: AnalysisMode.quick,
      );
      await repository.save(game);
      final reopened = repository.find(game.id);
      expect(reopened, isNotNull);
      expect(ReviewEntryContract.canOpenCachedReview(reopened!), isTrue);
      expect(reopened.cachedTimeline!.moves.length, timeline.moves.length);
      expect(reopened.cachedTimeline!.qualityCounts, timeline.qualityCounts);
      await repository.delete(game.id);

      const exportedPgn = '''
[Event "Live Chess"]
[Site "Chess.com"]
[Date "2026.07.11"]
[White "Apex"]
[Black "Opponent"]
[Result "1-0"]

1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. O-O Nf6 5. d3 d6
6. c3 O-O 7. Re1 a6 8. Bb3 Ba7 9. h3 h6 10. Nbd2 Re8
11. Nf1 Be6 12. Bc2 d5 13. exd5 Bxd5 14. Ng3 Qd7 15. Be3 Bxe3 1-0
''';
      final exported = await analyzer.analyzeFromPgn(
        exportedPgn,
        depth: 6,
        movetime: const Duration(milliseconds: 220),
        mode: AnalysisMode.quick,
      );
      expect(exported.isComplete, isTrue);
      expect(exported.moves, hasLength(30));
      expect(exported.moves.any((move) => move.isWhiteMove), isTrue);
      expect(exported.moves.any((move) => !move.isWhiteMove), isTrue);
      for (final move in exported.moves) {
        final expectedDelta = const MoverPerspective().deltaW(
          whiteWinBefore: move.winPercentBefore,
          whiteWinAfter: move.winPercentAfter,
          isWhiteMove: move.isWhiteMove,
        );
        expect(move.deltaW, closeTo(expectedDelta, 1e-9));
        expect(move.moverCpLoss, anyOf(isNull, greaterThanOrEqualTo(0)));
      }

      const specialPgns = <String, String>{
        'castling': '1. e4 e5 2. Nf3 Nc6 3. Bc4 Nf6 4. O-O *',
        'enPassant': '1. e4 a6 2. e5 d5 3. exd6 *',
        'promotion':
            '[SetUp "1"]\n'
            '[FEN "7k/P7/8/8/8/8/8/7K w - - 0 1"]\n\n'
            '1. a8=Q+ *',
      };
      final specialMoves = <String, String>{};
      for (final entry in specialPgns.entries) {
        final special = await analyzer.analyzeFromPgn(
          entry.value,
          depth: 5,
          movetime: const Duration(milliseconds: 160),
          mode: AnalysisMode.quick,
        );
        expect(special.isComplete, isTrue);
        specialMoves[entry.key] = special.moves.last.uci;
      }
      expect(specialMoves['castling'], 'e1g1');
      expect(specialMoves['enPassant'], 'e5d6');
      expect(specialMoves['promotion'], 'a7a8q');

      const invalidId = 'chapter1-invalid-middle';
      await repository.delete(invalidId);
      await expectLater(
        analyzer.analyzeFromPgn(
          '1. e4 e5 2. Nf3 Nc6 3. Banana a6 *',
          depth: 5,
          movetime: const Duration(milliseconds: 160),
          mode: AnalysisMode.quick,
        ),
        throwsA(
          isA<LocalAnalysisException>().having(
            (error) => error.failure,
            'failure',
            LocalAnalysisFailure.invalidPgn,
          ),
        ),
      );
      expect(repository.find(invalidId), isNull);

      final exportedId =
          'chapter1-exported-${DateTime.now().microsecondsSinceEpoch}';
      final exportedGame = ArchivedGame.fromTimeline(
        timeline: exported,
        id: exportedId,
        source: ArchiveSource.chessCom,
        depth: exported.depth ?? 0,
        pgn: exportedPgn,
        analysisMode: AnalysisMode.quick,
      );
      await repository.save(exportedGame);
      final exactReopen = repository.find(exportedId);
      expect(exactReopen, isNotNull);
      expect(ReviewEntryContract.canOpenCachedReview(exactReopen!), isTrue);
      expect(exactReopen.cachedTimeline!.toJson(), exported.toJson());

      final legacyJson =
          jsonDecode(jsonEncode(exportedGame.toJson())) as Map<String, dynamic>;
      const legacyId = 'chapter1-legacy-version';
      legacyJson['id'] = legacyId;
      legacyJson['classifierVersion'] = 1;
      legacyJson['tacticalVerifierVersion'] = 1;
      legacyJson['analysisSchemaVersion'] = 1;
      final legacyTimeline =
          legacyJson['cachedTimeline'] as Map<String, dynamic>;
      legacyTimeline['classifierVersion'] = 1;
      legacyTimeline['tacticalVerifierVersion'] = 1;
      legacyTimeline['analysisSchemaVersion'] = 1;
      legacyTimeline.remove('completionStatus');
      legacyTimeline.remove('expectedPlies');
      final legacy = ArchivedGame.fromJson(legacyJson);
      await repository.save(legacy);
      final recoveredLegacy = repository.find(legacyId);
      expect(recoveredLegacy, isNotNull);
      expect(recoveredLegacy!.isCacheCurrent, isFalse);
      expect(recoveredLegacy.brilliantCount, 0);
      expect(
        ReviewEntryIntent.savedReview(recoveredLegacy).destination,
        ReviewEntryDestination.archiveFallback,
      );
      expect(repository.loadAll().any((item) => item.id == legacyId), isTrue);

      final reanalyzedLegacy = ArchivedGame.fromTimeline(
        timeline: exported,
        id: legacyId,
        source: ArchiveSource.chessCom,
        depth: exported.depth ?? 0,
        pgn: exportedPgn,
        analysisMode: AnalysisMode.quick,
      );
      await repository.save(reanalyzedLegacy);
      final healedLegacy = repository.find(legacyId);
      expect(healedLegacy, isNotNull);
      expect(ReviewEntryContract.canOpenCachedReview(healedLegacy!), isTrue);
      expect(
        ReviewEntryIntent.savedReview(healedLegacy).destination,
        ReviewEntryDestination.summary,
      );

      final container = ProviderContainer();
      container
          .read(reviewControllerProvider.notifier)
          .loadTimeline(exported, mode: AnalysisMode.quick, userIsWhite: true);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ReviewSummaryScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ReviewSummaryScreen), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Start Review'),
        500,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Start Review'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ReviewScreen), findsOneWidget);
      final beforeNavigation = container
          .read(reviewControllerProvider)
          .currentFen;
      await tester.tap(find.byKey(const ValueKey('review-next-button')));
      await tester.pump(const Duration(milliseconds: 300));
      final afterNavigation = container.read(reviewControllerProvider);
      expect(afterNavigation.currentPly, 1);
      expect(afterNavigation.currentFen, exported.moves[1].fenAfter);
      expect(afterNavigation.currentFen, isNot(beforeNavigation));
      await binding.convertFlutterSurfaceToImage();
      await tester.pump();
      final screenshot = await binding.takeScreenshot(
        'chapter1-review-ui-after-next',
      );
      expect(screenshot, isNotEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();

      await repository.delete(exportedId);
      await repository.delete(legacyId);

      // ignore: avoid_print
      print(
        jsonEncode({
          'proof': 'trustworthy_offline_review_core',
          'platform': Platform.operatingSystemVersion,
          'engineIdentity': timeline.engineVersion,
          'requestedDepth': timeline.requestedDepth,
          'achievedDepthFloor': timeline.depth,
          'engineSearches': timeline.engineSearchCount,
          'cacheHits': timeline.engineCacheHitCount,
          'elapsedMs': stopwatch.elapsedMilliseconds,
          'plies': timeline.totalPlies,
          'cpLossSamples': timeline.cpLossEligibleCount,
          'savedReopen': true,
          'realMultiPvDepth': realMultiPv.depth,
          'realMultiPvRoots': realMultiPv.engineLines
              .map((line) => line.moveUci)
              .toList(growable: false),
          'exportedPlies': exported.totalPlies,
          'exportedRequestedDepth': exported.requestedDepth,
          'exportedAchievedDepthFloor': exported.depth,
          'exportedEngineSearches': exported.engineSearchCount,
          'exportedCacheHits': exported.engineCacheHitCount,
          'exportedClassifications': {
            for (final entry in exported.qualityCounts.entries)
              entry.key.name: entry.value,
          },
          'exportedUnavailableMoves': exported.moves
              .where((move) => !move.engineEvaluationAvailable)
              .length,
          'specialMoves': specialMoves,
          'invalidMiddleRejected': true,
          'legacyFallbackHealed': true,
          'reviewUiNavigation': true,
        }),
      );
    } finally {
      await Hive.close();
      await engine.dispose();
    }
  });
}
