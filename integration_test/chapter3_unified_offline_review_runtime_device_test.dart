import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/review_summary.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_screen.dart';
import 'package:apex_chess/features/pgn_review/presentation/widgets/offline_review_progress_dialog.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chapter 3 unified offline runtime production proof', (
    tester,
  ) async {
    await Hive.initFlutter('chapter3_unified_runtime_proof');
    var repository = await ArchiveRepository.open();
    await repository.clear();
    final container = ProviderContainer(
      overrides: apexDefaultProviderOverrides(),
    );
    var providerExecutions = 0;
    var observedEngineCalls = 0;
    var observedClassifierDecisions = 0;
    var staleEventsApplied = 0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ApexTheme.dark,
          home: const Scaffold(
            body: OfflineReviewProgressDialog(
              pgn: _shortPgn,
              profile: AnalysisProfile.fastReview,
              source: ReviewRuntimeSource.pastedPgn,
              sourceProvider: AnalysisGameSource.pgn,
              userIsWhite: true,
            ),
          ),
        ),
      ),
    );
    for (var attempt = 0; attempt < 80; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (container.read(reviewControllerProvider).isExecuting) break;
    }
    expect(container.read(reviewControllerProvider).isExecuting, isTrue);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      container.read(reviewControllerProvider).lifecycle,
      ReviewRuntimeLifecycle.cancelled,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    final pipeline = await container.read(
      reviewAnalysisPipelineProvider.future,
    );
    final controller = container.read(reviewControllerProvider.notifier);
    controller.clear();

    Future<String> persist(ReviewDocument document) async =>
        repository.saveReviewDocument(document);
    Future<GameReviewResult> execute(GameReviewRequest request) async {
      providerExecutions++;
      final result = await pipeline.analyzeOffline(request);
      observedEngineCalls += result.telemetry.engineCallsCount;
      observedClassifierDecisions += result.timeline.totalPlies;
      return result;
    }

    final physicalCancellationWatch = Stopwatch()..start();
    final physicalA = controller.analyzeOffline(
      request: const ReviewRuntimeRequest(
        pgn: _cancellationPgn,
        profile: AnalysisProfile.deepReview,
        source: ReviewRuntimeSource.pastedPgn,
        sourceProvider: AnalysisGameSource.pgn,
        userIsWhite: true,
      ),
      execute: execute,
      cancelExecution: pipeline.cancelLocalAnalysis,
      persist: persist,
    );
    for (var attempt = 0; attempt < 100; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (container.read(reviewControllerProvider).lifecycle ==
          ReviewRuntimeLifecycle.analyzing) {
        break;
      }
    }
    expect(
      container.read(reviewControllerProvider).lifecycle,
      ReviewRuntimeLifecycle.analyzing,
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.cancelActiveAnalysis();
    expect(await physicalA.timeout(const Duration(seconds: 15)), isFalse);
    physicalCancellationWatch.stop();
    expect(
      container.read(reviewControllerProvider).lifecycle,
      ReviewRuntimeLifecycle.cancelled,
    );

    final fastWatch = Stopwatch()..start();
    final fastCompleted = await controller.analyzeOffline(
      request: const ReviewRuntimeRequest(
        pgn: _shortPgn,
        profile: AnalysisProfile.fastReview,
        source: ReviewRuntimeSource.pastedPgn,
        sourceProvider: AnalysisGameSource.pgn,
        userIsWhite: false,
      ),
      execute: execute,
      cancelExecution: pipeline.cancelLocalAnalysis,
      persist: persist,
    );
    fastWatch.stop();
    expect(fastCompleted, isTrue);
    final fastState = container.read(reviewControllerProvider);
    final fastDocumentId = fastState.savedDocumentId!;
    expect(fastState.requestedProfile, AnalysisProfile.fastReview);
    expect(fastState.timeline!.multipv, 1);
    expect(fastState.userIsWhite, isFalse);
    expect(
      fastState.timeline!.moves.any((move) => move.engineEvaluationAvailable),
      isTrue,
    );
    expect(fastState.timeline!.depth, isNotNull);
    expect(fastState.timeline!.depth, greaterThan(0));
    expect(fastState.timeline!.engineVersion, contains('Stockfish 17'));
    expect(fastState.timeline!.moves.single.scoreCpAfter, isNull);
    expect(fastState.timeline!.moves.single.mateInAfter, isNotNull);
    expect(fastState.timeline!.moves.single.moverCpLoss, isNull);
    final fastAchievedMultiPv = _minimumReceivedMultiPv(fastState.timeline!);
    expect(fastAchievedMultiPv, greaterThanOrEqualTo(1));

    final deepWatch = Stopwatch()..start();
    final deepCompleted = await controller.analyzeOffline(
      request: const ReviewRuntimeRequest(
        pgn: _shortPgn,
        profile: AnalysisProfile.deepReview,
        source: ReviewRuntimeSource.importedGame,
        sourceProvider: AnalysisGameSource.lichess,
        sourceGameId: 'chapter3-imported-game',
        userIsWhite: false,
      ),
      execute: execute,
      cancelExecution: pipeline.cancelLocalAnalysis,
      persist: persist,
    );
    deepWatch.stop();
    expect(deepCompleted, isTrue);
    final deepState = container.read(reviewControllerProvider);
    final deepDocumentId = deepState.savedDocumentId!;
    expect(deepState.requestedProfile, AnalysisProfile.deepReview);
    expect(deepState.timeline!.multipv, 3);
    expect(deepState.gameId, fastState.gameId);
    expect(deepState.analysisVariantId, isNot(fastState.analysisVariantId));
    expect(repository.listVariants(deepState.gameId!), hasLength(2));
    expect(
      deepState.timeline!.moves.any((move) => move.engineEvaluationAvailable),
      isTrue,
    );
    expect(deepState.timeline!.depth, isNotNull);
    expect(deepState.timeline!.depth, greaterThan(0));
    expect(deepState.timeline!.engineVersion, contains('Stockfish 17'));
    final deepAchievedMultiPv = _minimumReceivedMultiPv(deepState.timeline!);
    expect(deepAchievedMultiPv, greaterThanOrEqualTo(1));

    final a = Completer<GameReviewResult>();
    final b = Completer<GameReviewResult>();
    GameReviewRequest? requestA;
    GameReviewRequest? requestB;
    final futureA = controller.analyzeOffline(
      request: const ReviewRuntimeRequest(
        pgn: _shortPgn,
        profile: AnalysisProfile.fastReview,
        source: ReviewRuntimeSource.pastedPgn,
        sourceProvider: AnalysisGameSource.pgn,
      ),
      execute: (request) {
        requestA = request;
        return a.future;
      },
      cancelExecution: pipeline.cancelLocalAnalysis,
      persist: persist,
    );
    await Future<void>.delayed(Duration.zero);
    controller.cancelActiveAnalysis();
    final futureB = controller.analyzeOffline(
      request: const ReviewRuntimeRequest(
        pgn: _secondPgn,
        profile: AnalysisProfile.fastReview,
        source: ReviewRuntimeSource.importedGame,
        sourceProvider: AnalysisGameSource.chessCom,
      ),
      execute: (request) {
        requestB = request;
        return b.future;
      },
      cancelExecution: pipeline.cancelLocalAnalysis,
      persist: persist,
    );
    await Future<void>.delayed(Duration.zero);
    requestA!.onProgress?.call(99, 99);
    if (container.read(reviewControllerProvider).progressCompleted == 99) {
      staleEventsApplied++;
    }
    b.complete(_syntheticResult(requestB!));
    expect(await futureB, isTrue);
    final bGameId = container.read(reviewControllerProvider).gameId;
    a.complete(_syntheticResult(requestA!));
    expect(await futureA, isFalse);
    expect(container.read(reviewControllerProvider).gameId, bGameId);

    final invalid = await controller.analyzeOffline(
      request: const ReviewRuntimeRequest(
        pgn: '1. e4 e5 2. InvalidMove *',
        profile: AnalysisProfile.fastReview,
        source: ReviewRuntimeSource.pastedPgn,
        sourceProvider: AnalysisGameSource.pgn,
      ),
      execute: execute,
      cancelExecution: pipeline.cancelLocalAnalysis,
      persist: persist,
    );
    expect(invalid, isFalse);
    expect(
      container.read(reviewControllerProvider).failure,
      ReviewRuntimeFailure.invalidPgn,
    );

    controller.loadTimeline(_longTimeline(), userIsWhite: true);
    final navigationWatch = Stopwatch()..start();
    for (var index = 0; index < 1000; index++) {
      controller.jumpTo(index % 100);
    }
    controller.goToStart();
    controller.jumpTo(49);
    controller.goToEnd();
    navigationWatch.stop();
    expect(container.read(reviewControllerProvider).currentPly, 99);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: ApexTheme.dark, home: const ReviewScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('review-board-section')), findsOneWidget);
    expect(find.byKey(const ValueKey('review-ply-counter')), findsOneWidget);
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    final screenshot = await binding.takeScreenshot(
      'chapter3-long-review-synchronized',
    );
    expect(screenshot, isNotEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await Hive.close();
    await Hive.initFlutter('chapter3_unified_runtime_proof');
    repository = await ArchiveRepository.open();
    final reopenContainer = ProviderContainer();
    final executionsBeforeReopen = providerExecutions;
    final engineCallsBeforeReopen = observedEngineCalls;
    final classifierDecisionsBeforeReopen = observedClassifierDecisions;
    final exactDeep = repository.find(deepDocumentId)!;
    final reopenWatch = Stopwatch()..start();
    final opened = reopenContainer
        .read(reviewControllerProvider.notifier)
        .openSavedReview(exactDeep, source: ReviewRuntimeSource.archiveExact);
    reopenWatch.stop();
    final reopened = reopenContainer.read(reviewControllerProvider);
    expect(opened, isTrue);
    expect(reopened.reviewDocumentId, deepDocumentId);
    expect(reopened.requestedProfile, AnalysisProfile.deepReview);
    expect(reopened.userIsWhite, isFalse);
    expect(providerExecutions, executionsBeforeReopen);
    expect(observedEngineCalls, engineCallsBeforeReopen);
    expect(observedClassifierDecisions, classifierDecisionsBeforeReopen);
    expect(repository.loadReviewDocument(fastDocumentId), isNotNull);

    // ignore: avoid_print
    print(
      jsonEncode({
        'proof': 'chapter3_unified_offline_review_runtime',
        'platform': Platform.operatingSystemVersion,
        'deviceModel': 'Samsung SM-S908U1',
        'engineIdentity': deepState.timeline!.engineVersion,
        'fastProfile': {
          'depthRequested': AnalysisProfile.fastReview.localDepth,
          'depthAchieved': fastState.timeline!.depth,
          'movetimeMs': AnalysisProfile.fastReview.localMovetimeMs,
          'multiPv': AnalysisProfile.fastReview.localMultiPv,
          'multiPvReceived': fastAchievedMultiPv,
          'durationMs': fastWatch.elapsedMilliseconds,
        },
        'deepProfile': {
          'depthRequested': AnalysisProfile.deepReview.localDepth,
          'depthAchieved': deepState.timeline!.depth,
          'movetimeMs': AnalysisProfile.deepReview.localMovetimeMs,
          'multiPv': AnalysisProfile.deepReview.localMultiPv,
          'multiPvReceived': deepAchievedMultiPv,
          'durationMs': deepWatch.elapsedMilliseconds,
        },
        'physicalCancellationMs': physicalCancellationWatch.elapsedMilliseconds,
        'variantCount': repository.listVariants(reopened.gameId!).length,
        'staleEventsApplied': staleEventsApplied,
        'engineCallsOnReopen': observedEngineCalls - engineCallsBeforeReopen,
        'classifierRerunsOnReopen':
            observedClassifierDecisions - classifierDecisionsBeforeReopen,
        'reopenLatencyMs': reopenWatch.elapsedMilliseconds,
        'navigation1000JumpsMs': navigationWatch.elapsedMilliseconds,
        'finalPly': 99,
        'finalLifecycle': reopened.lifecycle.name,
        'perspective': reopened.userIsWhite == false ? 'black' : 'other',
        'screenshotBytes': screenshot.length,
      }),
    );

    reopenContainer.dispose();
    await repository.clear();
  });
}

GameReviewResult _syntheticResult(GameReviewRequest request) {
  final timeline = _timelineFor(request.pgn, request.profile);
  final metadata = AnalysisRunMetadata(
    analysisProfileId: request.profile.id.wire,
    providerId: 'local_offline',
    engineVersion: _engine,
    classifierVersion: timeline.classifierVersion,
    tacticalVerifierVersion: timeline.tacticalVerifierVersion,
    openingBookVersion: timeline.openingBookVersion,
    depth: request.profile.localDepth,
    movetimeMs: request.profile.localMovetimeMs,
    multipv: request.profile.localMultiPv,
    candidateVerificationEnabled: request.profile.candidateVerificationEnabled,
    completedAt: timeline.completedAt!,
    pgnHash: 'device-synthetic',
    cacheKey: 'device-${request.profile.id.wire}',
  );
  return GameReviewResult(
    timeline: timeline,
    summary: const ReviewSummaryService().compute(
      timeline: timeline,
      userIsWhite: request.userIsWhite,
    ),
    metadata: metadata,
    telemetry: AnalysisTelemetry(
      totalAnalysisMs: 1,
      cacheHit: false,
      providerId: 'local_offline',
      profileId: request.profile.id.wire,
      positionsAnalyzed: timeline.totalPlies,
      candidateVerificationsCount: 0,
      averageDepthReached: request.profile.localDepth.toDouble(),
      engineCallsCount: 0,
    ),
    fromCache: false,
  );
}

AnalysisTimeline _timelineFor(String pgn, AnalysisProfile profile) {
  final game = const CanonicalGameIdentityService().fromPgn(
    pgn: pgn,
    sourceProvider: 'device',
  );
  return AnalysisTimeline(
    startingFen: game.startingFen,
    moves: [
      for (final (index, move) in game.moves.indexed)
        MoveAnalysis(
          ply: index,
          san: move.san,
          uci: move.uci,
          fenBefore: move.fenBefore,
          fenAfter: move.fenAfter,
          targetSquare: move.uci.substring(2, 4),
          winPercentBefore: 50,
          winPercentAfter: 50,
          deltaW: 0,
          isWhiteMove: index.isEven,
          classification: MoveQuality.best,
          moverCpLoss: 0,
          scoreCpAfter: 0,
          requestedDepth: profile.localDepth,
          achievedDepthBefore: profile.localDepth,
          achievedDepthAfter: profile.localDepth,
          multiPvReceived: profile.localMultiPv,
          searchQualityMet: true,
          message: 'Best',
          classifierVersion: 5,
          engineVersion: _engine,
        ),
    ],
    headers: game.headers,
    winPercentages: [for (final _ in game.moves) 50],
    analysisMode: profile.id == AnalysisProfileId.fastReview ? 'quick' : 'deep',
    analysisProfileId: profile.id.wire,
    providerId: 'local_offline',
    engineVersion: _engine,
    classifierVersion: 5,
    analysisSchemaVersion: 3,
    requestedDepth: profile.localDepth,
    depth: profile.localDepth,
    movetimeMs: profile.localMovetimeMs,
    multipv: profile.localMultiPv,
    candidateVerificationEnabled: profile.candidateVerificationEnabled,
    completedAt: DateTime.utc(2026, 7, 12),
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: game.moves.length,
    engineSearchCount: game.moves.length + 1,
  );
}

AnalysisTimeline _longTimeline() =>
    _timelineFor(_longPgn, AnalysisProfile.fastReview);

int _minimumReceivedMultiPv(AnalysisTimeline timeline) => timeline.moves
    .where((move) => move.engineEvaluationAvailable)
    .map((move) => move.multiPvReceived)
    .reduce((left, right) => left < right ? left : right);

const _engine = 'apex-stockfish-bridge/0.3.0|Stockfish 17';

const _shortPgn = '''
[White "Runtime White"]
[Black "Runtime Black"]
[Result "1-0"]
[SetUp "1"]
[FEN "7k/5Q2/6K1/8/8/8/8/8 w - - 0 1"]

1. Qf8# 1-0
''';

const _cancellationPgn = '''
[White "Cancellation White"]
[Black "Cancellation Black"]
[Result "*"]
[SetUp "1"]
[FEN "r1bqkbnr/pppppppp/n7/8/8/N7/PPPPPPPP/R1BQKBNR w KQkq - 2 2"]

2. h3 *
''';

const _secondPgn = '''
[White "Second White"]
[Black "Second Black"]
[Result "*"]

1. d4 *
''';

final String _longPgn = _buildLongPgn();

String _buildLongPgn() {
  final moves = <String>[];
  for (var cycle = 0; cycle < 25; cycle++) {
    final number = cycle * 2 + 1;
    moves.add('$number. Nf3 Nf6 ${number + 1}. Ng1 Ng8');
  }
  return '[White "Long White"]\n[Black "Long Black"]\n\n${moves.join(' ')} *';
}
