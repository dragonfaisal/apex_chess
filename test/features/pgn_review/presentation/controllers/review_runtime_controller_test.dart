import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/domain/review_identity.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/review_summary.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';

void main() {
  test(
    'successful local execution owns identity, timeline, and one save',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(reviewControllerProvider.notifier);
      var saves = 0;

      final completed = await controller.analyzeOffline(
        request: _request(_pgnA, AnalysisProfile.fastReview),
        execute: (request) async => _result(request),
        cancelExecution: () {},
        persist: (document) async {
          saves++;
          return document.documentId;
        },
      );
      final state = container.read(reviewControllerProvider);

      expect(completed, isTrue);
      expect(state.lifecycle, ReviewRuntimeLifecycle.completed);
      expect(state.saveState, ReviewSaveState.saved);
      expect(state.requestedProfile, AnalysisProfile.fastReview);
      expect(state.mode, AnalysisMode.quick);
      expect(state.gameId, isNotEmpty);
      expect(state.analysisVariantId, isNotEmpty);
      expect(state.reviewDocumentId, state.savedDocumentId);
      expect(state.timeline, same(state.canonicalDocument!.timeline));
      expect(saves, 1);
    },
  );

  test(
    'pasted and imported equivalent PGNs share game and variant identity',
    () async {
      final pasted = ProviderContainer();
      final imported = ProviderContainer();
      addTearDown(pasted.dispose);
      addTearDown(imported.dispose);
      Future<String> save(ReviewDocument document) async => document.documentId;

      await pasted
          .read(reviewControllerProvider.notifier)
          .analyzeOffline(
            request: _request(_pgnA, AnalysisProfile.deepReview),
            execute: (request) async => _result(request),
            cancelExecution: () {},
            persist: save,
          );
      await imported
          .read(reviewControllerProvider.notifier)
          .analyzeOffline(
            request: ReviewRuntimeRequest(
              pgn: _pgnADecorated,
              profile: AnalysisProfile.deepReview,
              source: ReviewRuntimeSource.importedGame,
              sourceProvider: AnalysisGameSource.lichess,
              sourceGameId: 'remote-1',
              userIsWhite: true,
            ),
            execute: (request) async => _result(request),
            cancelExecution: () {},
            persist: save,
          );

      expect(
        imported.read(reviewControllerProvider).gameId,
        pasted.read(reviewControllerProvider).gameId,
      );
      expect(
        imported.read(reviewControllerProvider).analysisVariantId,
        pasted.read(reviewControllerProvider).analysisVariantId,
      );
    },
  );

  test('invalid PGN fails before execution and cannot save', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    var executions = 0;
    var saves = 0;

    final completed = await container
        .read(reviewControllerProvider.notifier)
        .analyzeOffline(
          request: _request(
            '1. e4 e5 2. InvalidMove *',
            AnalysisProfile.fastReview,
          ),
          execute: (request) async {
            executions++;
            return _result(request);
          },
          cancelExecution: () {},
          persist: (document) async {
            saves++;
            return document.documentId;
          },
        );

    expect(completed, isFalse);
    expect(executions, 0);
    expect(saves, 0);
    expect(
      container.read(reviewControllerProvider).failure,
      ReviewRuntimeFailure.invalidPgn,
    );
  });

  test(
    'timeout and incomplete evidence remain failed and unsaveable',
    () async {
      for (final failure in ['timeout', 'partial']) {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        var saves = 0;
        final controller = container.read(reviewControllerProvider.notifier);
        final completed = await controller.analyzeOffline(
          request: _request(_pgnA, AnalysisProfile.fastReview),
          execute: (request) async {
            if (failure == 'timeout') throw TimeoutException('controlled');
            final valid = _result(request);
            return _copyResult(
              valid,
              valid.timeline.copyWith(
                completionStatus: AnalysisCompletionStatus.incomplete,
              ),
            );
          },
          cancelExecution: () {},
          persist: (document) async {
            saves++;
            return document.documentId;
          },
        );
        expect(completed, isFalse);
        expect(saves, 0);
        expect(container.read(reviewControllerProvider).timeline, isNull);
        expect(
          container.read(reviewControllerProvider).failure,
          failure == 'timeout'
              ? ReviewRuntimeFailure.timeout
              : ReviewRuntimeFailure.incompleteEvidence,
        );
      }
    },
  );

  test('cancel A then analyze B ignores late A progress and result', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(reviewControllerProvider.notifier);
    final a = Completer<GameReviewResult>();
    final b = Completer<GameReviewResult>();
    GameReviewRequest? requestA;
    GameReviewRequest? requestB;
    var physicalCancels = 0;
    final saved = <ReviewDocument>[];

    final futureA = controller.analyzeOffline(
      request: _request(_pgnA, AnalysisProfile.fastReview),
      execute: (request) {
        requestA = request;
        return a.future;
      },
      cancelExecution: () => physicalCancels++,
      persist: (document) async {
        saved.add(document);
        return document.documentId;
      },
    );
    await Future<void>.delayed(Duration.zero);
    requestA!.onProgress?.call(1, 3);

    final futureB = controller.analyzeOffline(
      request: _request(_pgnB, AnalysisProfile.deepReview),
      execute: (request) {
        requestB = request;
        return b.future;
      },
      cancelExecution: () => physicalCancels++,
      persist: (document) async {
        saved.add(document);
        return document.documentId;
      },
    );
    await Future<void>.delayed(Duration.zero);
    requestA!.onProgress?.call(99, 99);
    requestB!.onProgress?.call(1, 2);
    b.complete(_result(requestB!));
    expect(await futureB, isTrue);
    final authoritativeB = container.read(reviewControllerProvider);

    a.complete(_result(requestA!));
    expect(await futureA, isFalse);
    final finalState = container.read(reviewControllerProvider);

    expect(physicalCancels, 1);
    expect(finalState.executionId, authoritativeB.executionId);
    expect(finalState.gameId, authoritativeB.gameId);
    expect(finalState.requestedProfile, AnalysisProfile.deepReview);
    expect(finalState.timeline!.headers['White'], 'Gamma');
    expect(saved, hasLength(1));
  });

  test(
    'repeated cancel is idempotent and leaves no trusted timeline',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(reviewControllerProvider.notifier);
      final result = Completer<GameReviewResult>();
      GameReviewRequest? captured;
      var cancels = 0;

      final future = controller.analyzeOffline(
        request: _request(_pgnA, AnalysisProfile.fastReview),
        execute: (request) {
          captured = request;
          return result.future;
        },
        cancelExecution: () => cancels++,
        persist: (document) async => document.documentId,
      );
      await Future<void>.delayed(Duration.zero);
      controller.cancelActiveAnalysis();
      controller.cancelActiveAnalysis();
      result.complete(_result(captured!));

      expect(await future, isFalse);
      expect(cancels, 1);
      expect(
        container.read(reviewControllerProvider).lifecycle,
        ReviewRuntimeLifecycle.cancelled,
      );
      expect(container.read(reviewControllerProvider).timeline, isNull);
    },
  );

  test(
    'old dialog ownership cannot cancel a newer or completed execution',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(reviewControllerProvider.notifier);
      final a = Completer<GameReviewResult>();
      final b = Completer<GameReviewResult>();
      GameReviewRequest? requestA;
      GameReviewRequest? requestB;
      var cancelsA = 0;
      var cancelsB = 0;

      final futureA = controller.analyzeOffline(
        request: _request(_pgnA, AnalysisProfile.fastReview),
        execute: (request) {
          requestA = request;
          return a.future;
        },
        cancelExecution: () => cancelsA++,
        persist: (document) async => document.documentId,
      );
      await Future<void>.delayed(Duration.zero);
      final executionA = container.read(reviewControllerProvider).executionId;

      final futureB = controller.analyzeOffline(
        request: _request(_pgnB, AnalysisProfile.deepReview),
        execute: (request) {
          requestB = request;
          return b.future;
        },
        cancelExecution: () => cancelsB++,
        persist: (document) async => document.documentId,
      );
      await Future<void>.delayed(Duration.zero);
      final executionB = container.read(reviewControllerProvider).executionId;

      expect(cancelsA, 1);
      expect(controller.cancelExecutionIfOwned(executionA), isFalse);
      expect(cancelsB, 0);
      expect(container.read(reviewControllerProvider).executionId, executionB);
      expect(container.read(reviewControllerProvider).isExecuting, isTrue);

      b.complete(_result(requestB!));
      expect(await futureB, isTrue);
      expect(controller.cancelExecutionIfOwned(executionB), isFalse);
      expect(cancelsB, 0);

      a.complete(_result(requestA!));
      expect(await futureA, isFalse);
      expect(container.read(reviewControllerProvider).executionId, executionB);
      expect(
        container.read(reviewControllerProvider).isTrustedComplete,
        isTrue,
      );
    },
  );

  test('double save attempt shares the completed save operation', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(reviewControllerProvider.notifier);
    var saves = 0;
    Future<String> persist(ReviewDocument document) async {
      saves++;
      return document.documentId;
    }

    await controller.analyzeOffline(
      request: _request(_pgnA, AnalysisProfile.fastReview),
      execute: (request) async => _result(request),
      cancelExecution: () {},
      persist: persist,
    );

    final ids = await Future.wait([
      controller.saveCurrent(persist),
      controller.saveCurrent(persist),
    ]);
    expect(ids[0], ids[1]);
    expect(saves, 1);
  });

  test('save failure is explicit and retry reuses trusted document', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(reviewControllerProvider.notifier);
    await controller.analyzeOffline(
      request: _request(_pgnA, AnalysisProfile.fastReview),
      execute: (request) async => _result(request),
      cancelExecution: () {},
      persist: (document) async => throw StateError('controlled save failure'),
    );
    expect(container.read(reviewControllerProvider).isTrustedComplete, isTrue);
    expect(
      container.read(reviewControllerProvider).saveState,
      ReviewSaveState.failed,
    );

    final id = await controller.saveCurrent(
      (document) async => document.documentId,
    );
    expect(id, isNotNull);
    expect(
      container.read(reviewControllerProvider).saveState,
      ReviewSaveState.saved,
    );
    expect(
      container.read(reviewControllerProvider).failure,
      ReviewRuntimeFailure.none,
    );
  });

  test(
    'exact canonical reopen preserves perspective and performs no execution',
    () async {
      final analyzed = ProviderContainer();
      final reopened = ProviderContainer();
      addTearDown(analyzed.dispose);
      addTearDown(reopened.dispose);
      await analyzed
          .read(reviewControllerProvider.notifier)
          .analyzeOffline(
            request: _request(
              _pgnA,
              AnalysisProfile.deepReview,
              userIsWhite: false,
            ),
            execute: (request) async => _result(request),
            cancelExecution: () {},
            persist: (document) async => document.documentId,
          );
      final document = analyzed
          .read(reviewControllerProvider)
          .canonicalDocument!;
      final archived = _archiveFromDocument(document);

      final reopenWatch = Stopwatch()..start();
      final opened = reopened
          .read(reviewControllerProvider.notifier)
          .openSavedReview(
            archived,
            source: ReviewRuntimeSource.archiveExact,
            legacyUserIsWhite: true,
          );
      reopenWatch.stop();
      final state = reopened.read(reviewControllerProvider);

      expect(opened, isTrue);
      expect(state.reviewDocumentId, document.documentId);
      expect(state.analysisVariantId, document.variantId.value);
      expect(state.userIsWhite, isFalse);
      expect(state.flipped, isTrue);
      expect(state.engineIdentity, contains('Stockfish 17'));
      debugPrint(
        'CHAPTER3_REOPEN_PERF latencyUs=${reopenWatch.elapsedMicroseconds} '
        'engineCalls=0 classifierCalls=0',
      );
    },
  );

  test(
    'missing exact review fails explicitly without sibling substitution',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final missing = ArchivedGame(
        id: 'missing-exact-document',
        source: ArchiveSource.pgn,
        white: 'Alpha',
        black: 'Beta',
        result: '*',
        analyzedAt: DateTime.utc(2026),
        depth: 18,
        pgn: '',
        qualityCounts: const {},
        averageCpLoss: 0,
        totalPlies: 0,
        recordKind: ArchivedRecordKind.canonicalDocument,
        canonicalGameId: 'game',
        analysisVariantId: 'variant',
        canonicalIndexVerified: true,
      );

      final opened = container
          .read(reviewControllerProvider.notifier)
          .openSavedReview(missing, source: ReviewRuntimeSource.archiveExact);

      expect(opened, isFalse);
      expect(
        container.read(reviewControllerProvider).failure,
        ReviewRuntimeFailure.savedReviewMissing,
      );
      expect(container.read(reviewControllerProvider).timeline, isNull);
    },
  );

  test(
    'navigation supports start, rapid jumps, and bounded long-game latency',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(reviewControllerProvider.notifier);
      final timeline = _result(
        GameReviewRequest(pgn: _longPgn, profile: AnalysisProfile.fastReview),
      ).timeline;
      controller.loadTimeline(timeline, userIsWhite: true);

      final watch = Stopwatch()..start();
      for (var index = 0; index < 10000; index++) {
        controller.jumpTo(index % timeline.totalPlies);
      }
      controller.goToStart();
      watch.stop();
      debugPrint(
        'CHAPTER3_NAV_PERF plies=${timeline.totalPlies} jumps=10000 '
        'elapsedUs=${watch.elapsedMicroseconds}',
      );

      expect(container.read(reviewControllerProvider).currentPly, -1);
      expect(
        container.read(reviewControllerProvider).currentFen,
        timeline.startingFen,
      );
      controller.next();
      expect(container.read(reviewControllerProvider).currentPly, 0);
      controller.goToEnd();
      expect(
        container.read(reviewControllerProvider).currentPly,
        timeline.totalPlies - 1,
      );
      expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
    },
  );

  test('provider disposal requests physical cancellation', () async {
    final container = ProviderContainer();
    final controller = container.read(reviewControllerProvider.notifier);
    final pending = Completer<GameReviewResult>();
    var cancels = 0;
    unawaited(
      controller.analyzeOffline(
        request: _request(_pgnA, AnalysisProfile.fastReview),
        execute: (request) => pending.future,
        cancelExecution: () => cancels++,
        persist: (document) async => document.documentId,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    container.dispose();

    expect(cancels, 1);
  });
}

ReviewRuntimeRequest _request(
  String pgn,
  AnalysisProfile profile, {
  bool? userIsWhite = true,
}) => ReviewRuntimeRequest(
  pgn: pgn,
  profile: profile,
  source: ReviewRuntimeSource.pastedPgn,
  sourceProvider: AnalysisGameSource.pgn,
  userIsWhite: userIsWhite,
);

GameReviewResult _result(GameReviewRequest request) {
  final game = const CanonicalGameIdentityService().fromPgn(
    pgn: request.pgn,
    sourceProvider: 'pgn',
  );
  final profile = request.profile;
  final timeline = AnalysisTimeline(
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
          winPercentAfter: 51,
          deltaW: 1,
          isWhiteMove: index.isEven,
          classification: MoveQuality.best,
          moverCpLoss: 0,
          scoreCpAfter: 10,
          requestedDepth: profile.localDepth,
          achievedDepthBefore: profile.localDepth,
          achievedDepthAfter: profile.localDepth,
          multiPvReceived: profile.localMultiPv,
          searchQualityMet: true,
          engineLines: [
            for (var rank = 0; rank < profile.localMultiPv; rank++)
              EngineLine(
                rank: rank + 1,
                moveUci: const ['e2e4', 'd2d4', 'g1f3'][rank],
                scoreCp: 10 - rank,
                depth: profile.localDepth,
                whiteWinPercent: 51,
              ),
          ],
          message: 'Best',
          coachExplanation: 'Maintains the evaluated position.',
          analysisMode: profile.id == AnalysisProfileId.fastReview
              ? 'quick'
              : 'deep',
          engineVersion: _engine,
        ),
    ],
    headers: game.headers,
    winPercentages: [for (final _ in game.moves) 51],
    analysisMode: profile.id == AnalysisProfileId.fastReview ? 'quick' : 'deep',
    analysisProfileId: profile.id.wire,
    providerId: 'local_offline',
    engineVersion: _engine,
    requestedDepth: profile.localDepth,
    depth: profile.localDepth,
    movetimeMs: profile.localMovetimeMs,
    multipv: profile.localMultiPv,
    candidateVerificationEnabled: profile.candidateVerificationEnabled,
    completedAt: DateTime.utc(2026, 7, 12),
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: game.moves.length,
    engineSearchCount: game.moves.length + 1,
    engineCacheHitCount: game.moves.length,
  );
  final metadata = AnalysisRunMetadata(
    analysisProfileId: profile.id.wire,
    providerId: 'local_offline',
    engineVersion: _engine,
    classifierVersion: timeline.classifierVersion,
    tacticalVerifierVersion: timeline.tacticalVerifierVersion,
    openingBookVersion: timeline.openingBookVersion,
    depth: profile.localDepth,
    movetimeMs: profile.localMovetimeMs,
    multipv: profile.localMultiPv,
    candidateVerificationEnabled: profile.candidateVerificationEnabled,
    completedAt: timeline.completedAt!,
    pgnHash: 'test-hash',
    cacheKey: 'test-cache-${profile.id.wire}',
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
      profileId: profile.id.wire,
      positionsAnalyzed: timeline.engineSearchCount,
      candidateVerificationsCount: 0,
      averageDepthReached: profile.localDepth.toDouble(),
      engineCallsCount: timeline.engineSearchCount,
    ),
    fromCache: false,
  );
}

GameReviewResult _copyResult(
  GameReviewResult original,
  AnalysisTimeline timeline,
) => GameReviewResult(
  timeline: timeline,
  summary: original.summary,
  metadata: original.metadata,
  telemetry: original.telemetry,
  fromCache: original.fromCache,
  analysisResult: original.analysisResult,
);

ArchivedGame _archiveFromDocument(ReviewDocument document) => ArchivedGame(
  id: document.documentId,
  source: ArchiveSource.pgn,
  white: document.game.headers['White'] ?? 'White',
  black: document.game.headers['Black'] ?? 'Black',
  result: document.game.headers['Result'] ?? '*',
  analyzedAt: document.run.completedAt,
  depth: document.run.achievedDepth ?? 0,
  pgn: document.game.originalPgn,
  qualityCounts: document.classificationCounts,
  averageCpLoss: document.verifiedAcpl ?? 0,
  cpLossSampleCount: document.cpLossEligibleCount,
  totalPlies: document.timeline.totalPlies,
  cachedTimeline: document.timeline,
  classifierVersion: document.compatibility.classifierVersion,
  analysisMode: document.compatibility.profileId == 'fast_review'
      ? AnalysisMode.quick
      : AnalysisMode.deep,
  analysisProfileId: document.compatibility.profileId,
  providerId: document.compatibility.providerId,
  tacticalVerifierVersion: document.compatibility.tacticalVerifierVersion,
  openingBookVersion: document.compatibility.openingBookVersion,
  analysisSchemaVersion: document.compatibility.analysisSchemaVersion,
  recordKind: ArchivedRecordKind.canonicalDocument,
  canonicalGameId: document.game.gameId.value,
  analysisVariantId: document.variantId.value,
  analyzedUserIsWhite: document.userIsWhite,
  engineIdentity: document.compatibility.engine.declaredIdentity,
  canonicalIndexVerified: true,
);

const _engine = 'apex-stockfish-bridge/0.3.0|Stockfish 17';

const _pgnA = '''
[White "Alpha"]
[Black "Beta"]
[Result "*"]

1. e4 e5 2. Nf3 *
''';

const _pgnADecorated = '''
[Black "Renamed"]
[White "Someone"]
[Event "Imported"]

1. e4! {same game} e5 (1... c5) 2. Nf3 *
''';

const _pgnB = '''
[White "Gamma"]
[Black "Delta"]
[Result "*"]

1. d4 d5 *
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
