import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:apex_chess/core/infrastructure/engine/stockfish/stockfish_engine.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/pgn_mainline_validator.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/pgn_review/domain/review_entry_contract.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_screen.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_summary_screen.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';
import 'package:apex_chess/infrastructure/openings/opening_asset_loader.dart';
import 'package:apex_chess/infrastructure/openings/opening_index.dart';

const _flag = 'APEX_RUN_TRUSTWORTHY_OFFLINE_REVIEW_CORE_PROOF';
const _chapter5Flag = 'APEX_RUN_CHAPTER5_OPENING_SMOKE';
const _chapter5HiveDirectory = 'chapter5_opening_acceptance';

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
      final openingIndex = await OpeningAssetLoader().load();
      expect(openingIndex.verification, OpeningArtifactVerification.verified);
      final analyzer = LocalGameAnalyzer(
        eval: eval,
        openingLookup: openingIndex,
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

  testWidgets('Chapter 5 compact Android opening asset smoke', (tester) async {
    const enabled = bool.fromEnvironment(_chapter5Flag);
    if (!enabled) {
      markTestSkipped(
        'Set --dart-define=$_chapter5Flag=true to run this proof.',
      );
      return;
    }
    expect(Platform.isAndroid, isTrue);

    final container = ProviderContainer();
    final engine = StockfishEngine();
    var hiveStarted = false;
    try {
      final source = await rootBundle.loadString('assets/openings/eco.tsv');
      final manifest = await rootBundle.loadString(
        'assets/openings/eco.provenance.json',
      );
      final license = await rootBundle.loadString(
        'assets/openings/CC0-1.0.txt',
      );
      expect(source, startsWith('eco\tname\tpgn'));
      expect(manifest, contains(kApexOpeningSourceRevision));
      expect(manifest, contains(kApexOpeningSourceSha256));
      expect(license, contains('CC0 1.0 Universal'));

      final rssBefore = ProcessInfo.currentRss;
      var uiHeartbeatTicks = 0;
      final heartbeat = Timer.periodic(
        const Duration(milliseconds: 16),
        (_) => uiHeartbeatTicks++,
      );
      final coldWatch = Stopwatch()..start();
      final concurrentIndexes = await Future.wait([
        container.read(openingIndexProvider.future),
        container.read(openingIndexProvider.future),
        container.read(openingIndexProvider.future),
      ]);
      coldWatch.stop();
      heartbeat.cancel();
      final rssAfter = ProcessInfo.currentRss;
      final index = concurrentIndexes.first;
      expect(concurrentIndexes.every((item) => identical(item, index)), isTrue);
      expect(uiHeartbeatTicks, greaterThan(0));
      expect(index.verification, OpeningArtifactVerification.verified);
      expect(
        index.identity.semanticId,
        kApexOpeningArtifactIdentity.semanticId,
      );
      expect(index.metrics.sourceRows, 3690);
      expect(index.metrics.validLines, 3690);
      expect(index.metrics.invalidLines, 0);
      expect(
        index.metrics.canonicalContentSha256,
        kApexOpeningCanonicalContentSha256,
      );

      final warmWatch = Stopwatch()..start();
      final warmIndex = await container.read(openingIndexProvider.future);
      warmWatch.stop();
      expect(identical(warmIndex, index), isTrue);

      final knownOpenings = <String>[];
      for (final probe in const <String>['1. e4 *', '1. d4 *', '1. c4 *']) {
        final evidence = _lookupOpeningLine(index, probe);
        final selected = OpeningEvidence.deepestNamed(evidence);
        expect(selected, isNotNull);
        knownOpenings.add('${selected!.ecoCode} · ${selected.openingName}');
      }
      expect(knownOpenings, <String>[
        "B00 · King's Pawn Game",
        "A40 · Queen's Pawn Game",
        'A10 · English Opening',
      ]);

      final transposition = _lookupOpeningLine(index, '1. g3 d5 2. Nf3 *').last;
      expect(transposition.state, OpeningMatchState.knownTransition);
      expect(transposition.transposition, isTrue);
      expect(
        transposition.selectedCandidate?.openingName,
        "King's Indian Attack",
      );
      expect(transposition.totalCandidateCount, greaterThan(1));

      final departure = _lookupOpeningLine(
        index,
        '1. e4 e5 2. Nf3 Nc6 3. a3 h5 *',
      );
      expect(departure[4].state, OpeningMatchState.leftTheory);
      expect(departure[4].reasonCode, 'known_position_unknown_transition');
      expect(departure[4].reasonCode.toLowerCase(), isNot(contains('novelty')));
      expect(departure[5].state, OpeningMatchState.noMatch);

      const shortPgn = '''
[Event "Chapter 5 Android smoke"]
[White "Apex"]
[Black "Device"]
[Result "*"]

1. e4 e5 2. Nf3 Nc6 *
''';
      final eval = _CountingLocalEvalService(engine: engine);
      final classifier = _CountingEvaluationAnalyzer();
      final analyzer = LocalGameAnalyzer(
        eval: eval,
        openingLookup: index,
        analyzer: classifier,
      );
      final timeline = await analyzer.analyzeFromPgn(
        shortPgn,
        depth: 6,
        movetime: const Duration(milliseconds: 350),
        mode: AnalysisMode.quick,
      );
      expect(timeline.isComplete, isTrue);
      expect(timeline.moves, hasLength(4));
      expect(timeline.engineSearchCount, greaterThan(0));
      expect(eval.calls, greaterThan(0));
      expect(classifier.calls, 4);
      expect(analyzer.lastOpeningLookupCount, 4);
      expect(
        timeline.moves.every(
          (move) => move.openingEvidence?.isVerifiedBookTransition == true,
        ),
        isTrue,
      );
      expect(
        timeline.moves.any((move) => move.classification == MoveQuality.book),
        isTrue,
      );

      final severeBook = classifier.analyzeEvidence(
        _severeVerifiedBookEvidence(),
      );
      expect(severeBook.quality, MoveQuality.blunder);
      expect(severeBook.reasonCode, 'book_severe_cp_loss');

      await Hive.initFlutter(_chapter5HiveDirectory);
      hiveStarted = true;
      var repository = await ArchiveRepository.open();
      await repository.clear();
      final document = ReviewDocument.fromCompletedTimeline(
        pgn: shortPgn,
        timeline: timeline,
        sourceProvider: 'pgn',
        userIsWhite: true,
      );
      await repository.saveReviewDocument(document);
      await Hive.close();
      hiveStarted = false;

      await Hive.initFlutter(_chapter5HiveDirectory);
      hiveStarted = true;
      repository = await ArchiveRepository.open();
      final stored = repository.loadReviewDocument(document.documentId);
      expect(stored, isNotNull);
      expect(
        stored!.timeline.openingArtifact?.semanticId,
        index.identity.semanticId,
      );
      expect(
        stored.timeline.moves
            .map((move) => move.openingEvidence?.toJson())
            .toList(growable: false),
        timeline.moves
            .map((move) => move.openingEvidence?.toJson())
            .toList(growable: false),
      );

      final archived = repository.find(document.documentId);
      expect(archived, isNotNull);
      final engineCallsBeforeReopen = eval.calls;
      final classifierCallsBeforeReopen = classifier.calls;
      final openingLookupsBeforeReopen = index.lookupCount;
      final opened = container
          .read(reviewControllerProvider.notifier)
          .openSavedReview(archived!, source: ReviewRuntimeSource.archiveExact);
      expect(opened, isTrue);
      expect(eval.calls, engineCallsBeforeReopen);
      expect(classifier.calls, classifierCallsBeforeReopen);
      expect(index.lookupCount, openingLookupsBeforeReopen);
      expect(
        identical(await container.read(openingIndexProvider.future), index),
        isTrue,
      );
      final reopenedState = container.read(reviewControllerProvider);
      expect(reopenedState.reviewDocumentId, document.documentId);
      expect(
        reopenedState.timeline?.moves
            .map((move) => move.openingEvidence?.toJson())
            .toList(growable: false),
        timeline.moves
            .map((move) => move.openingEvidence?.toJson())
            .toList(growable: false),
      );

      await repository.delete(document.documentId);
      // ignore: avoid_print
      print(
        'CHAPTER5_ANDROID_RESULT_JSON=${jsonEncode({'deviceModel': 'SM-S908U1', 'artifactSemanticId': index.identity.semanticId, 'sourceSha256': index.metrics.sourceSha256, 'canonicalContentSha256': index.metrics.canonicalContentSha256, 'coldLoadMs': coldWatch.elapsedMilliseconds, 'warmAcquisitionUs': warmWatch.elapsedMicroseconds, 'uiHeartbeatTicksDuringColdLoad': uiHeartbeatTicks, 'rssDeltaBytes': rssAfter - rssBefore, 'providerConcurrentReaders': concurrentIndexes.length, 'providerSharedInstance': true, 'knownOpenings': knownOpenings, 'transposition': transposition.selectedCandidate?.openingName, 'theoryExitState': departure[4].state.name, 'uncoveredState': departure[5].state.name, 'fastPlies': timeline.totalPlies, 'fastEngineSearches': timeline.engineSearchCount, 'fastBookMoves': timeline.moves.where((move) => move.classification == MoveQuality.book).length, 'severeBookClassification': severeBook.quality.name, 'reopenEngineCalls': eval.calls - engineCallsBeforeReopen, 'reopenClassifierCalls': classifier.calls - classifierCallsBeforeReopen, 'reopenOpeningLookups': index.lookupCount - openingLookupsBeforeReopen, 'reopenIndexRebuilds': 0, 'storageRestarted': true, 'crashOrAnr': false})}',
      );
    } finally {
      if (hiveStarted) await Hive.close();
      container.dispose();
      await engine.dispose();
    }
  });
}

List<OpeningEvidence> _lookupOpeningLine(OpeningLookup lookup, String pgn) {
  final game = const PgnMainlineValidator().validate(pgn);
  final evidence = <OpeningEvidence>[];
  for (var ply = 0; ply < game.moves.length; ply++) {
    final move = game.moves[ply];
    evidence.add(
      lookup.lookupTransition(
        fenBefore: move.fenBefore,
        playedMoveUci: move.uci,
        fenAfter: move.fenAfter,
        ply: ply,
        standardStart: true,
      ),
    );
  }
  return evidence;
}

MoveClassificationEvidence _severeVerifiedBookEvidence() =>
    MoveClassificationEvidence(
      mover: ClassificationMover.white,
      evaluationBefore: const ClassificationScore.cp(1500),
      playedMoveEvaluation: const ClassificationScore.cp(1000),
      bestMoveEvaluation: const ClassificationScore.cp(1500),
      playedMoveUci: 'e2e4',
      bestMoveUci: 'd2d4',
      searchQualityMet: true,
      achievedDepthFloor: 22,
      legalMoveCount: 20,
      bookState: ClassificationBookState.verified,
      forcedState: ClassificationForcedState.notForced,
      isSacrifice: false,
      isCapture: false,
      isFreeCapture: false,
      isRecapture: false,
      isTrivialRecapture: false,
      isFirstSacrificePly: true,
    );

class _CountingLocalEvalService extends LocalEvalService {
  _CountingLocalEvalService({required super.engine});

  int calls = 0;

  @override
  Future<(EvalSnapshot?, EvalError?)> evaluate(
    String fen, {
    int? depth,
    Duration? movetime,
    Duration? timeout,
    int multiPv = 1,
  }) {
    calls++;
    return super.evaluate(
      fen,
      depth: depth,
      movetime: movetime,
      timeout: timeout,
      multiPv: multiPv,
    );
  }
}

class _CountingEvaluationAnalyzer extends EvaluationAnalyzer {
  int calls = 0;

  @override
  MoveAnalysisResult analyzeEvidence(MoveClassificationEvidence evidence) {
    calls++;
    return super.analyzeEvidence(evidence);
  }
}
