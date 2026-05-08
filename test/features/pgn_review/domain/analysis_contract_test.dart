import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/data/archive_save_hook.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/global_dashboard/presentation/models/recent_scan_display.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/review_entry_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/review_summary.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen = '8/8/8/8/8/8/8/8 w - - 0 1';

void main() {
  test('request model normalizes source, mode, user side, and game key', () {
    final fast = AnalysisReviewRequest.fromPgn(
      pgn: _pgn,
      requestedMode: AnalysisReviewMode.onlineFast,
      requestedAt: DateTime.utc(2026, 5, 8, 10),
      userHandle: 'alpha',
    );
    final deep = AnalysisReviewRequest.fromPgn(
      pgn: _pgn.replaceAll('\n', '\r\n'),
      requestedMode: AnalysisReviewMode.onlineDeep,
      requestedAt: DateTime.utc(2026, 5, 9, 10),
      userHandle: 'alpha',
    );

    expect(fast.source, AnalysisGameSource.chessCom);
    expect(fast.inputType, AnalysisInputType.pgn);
    expect(fast.requestedMode, AnalysisReviewMode.onlineFast);
    expect(deep.requestedMode, AnalysisReviewMode.onlineDeep);
    expect(fast.userIsWhite, isTrue);
    expect(fast.sourceId, contains('chess.com'));
    expect(fast.inputHash, deep.inputHash);
    expect(fast.canonicalGameKey, deep.canonicalGameKey);
  });

  test('move-list requests hash normalized moves without optional crashes', () {
    final request = AnalysisReviewRequest.fromMoves(
      moves: const [' e4 ', '', 'e5', 'Nf3'],
      requestedMode: AnalysisReviewMode.offlineLocal,
      white: 'Alpha',
      black: 'Beta',
    );

    expect(request.inputType, AnalysisInputType.moves);
    expect(request.normalizedMoveList, const ['e4', 'e5', 'Nf3']);
    expect(request.normalizedPgn, isNull);
    expect(request.canonicalGameKey, contains('alpha'));
  });

  test('provider status and failure copy are explicit and safe', () {
    final unavailable = AnalysisReviewResult.unavailable(
      mode: AnalysisReviewMode.onlineFast,
      providerKind: AnalysisProviderKind.onlineFast,
      reason: AnalysisFailureReason.providerNotConfigured,
    );

    expect(unavailable.status, AnalysisProviderStatus.unavailable);
    expect(unavailable.isUnavailable, isTrue);
    expect(unavailable.safeFailureCopy, ApexCopy.onlineReviewUnavailable);
    expect(
      ApexCopy.analysisFailure(AnalysisFailureReason.invalidPgn),
      ApexCopy.invalidPgn,
    );
    expect(
      ApexCopy.analysisFailure(AnalysisFailureReason.serviceUnavailable),
      ApexCopy.providerUnavailable,
    );
  });

  test('saved review maps to cached cachedHit contract result', () {
    final game = _savedGame(analysisMode: AnalysisMode.quick);
    final result = ReviewEntryContract.savedReviewResult(
      game,
      userIsWhite: true,
    );

    expect(result.status, AnalysisProviderStatus.cachedHit);
    expect(result.mode, AnalysisReviewMode.cached);
    expect(result.providerKind, AnalysisProviderKind.cached);
    expect(result.payload!.canonicalGameKey, game.canonicalGameKey);
    expect(result.payload!.reviewModeLabel, 'Fast');
    expect(result.payload!.hasTimeline, isTrue);
    expect(result.payload!.userIsWhite, isTrue);
  });

  test('missing saved review maps to safe unavailable result', () {
    final result = ReviewEntryContract.savedReviewResult(null);

    expect(result.status, AnalysisProviderStatus.unavailable);
    expect(result.failureReason, AnalysisFailureReason.savedReviewMissing);
    expect(result.safeFailureCopy, ApexCopy.savedReviewUnavailable);
  });

  test('offline local review maps to completed offlineLocal result', () async {
    final offline = _FakeProvider('local_offline');
    final pipeline = GameReviewPipeline(
      fastProvider: const OnlineFastReviewProvider(),
      deepProvider: const OnlineDeepReviewProvider(),
      offlineProvider: offline,
    );

    final result = await pipeline.analyzeContract(
      const GameReviewRequest(
        pgn: _pgn,
        profile: AnalysisProfile.offlineReview,
        userIsWhite: true,
      ),
    );

    expect(offline.calls, 1);
    expect(result.status, AnalysisProviderStatus.completed);
    expect(result.mode, AnalysisReviewMode.offlineLocal);
    expect(result.providerKind, AnalysisProviderKind.offlineLocal);
    expect(result.payload!.hasTimeline, isTrue);
    expect(result.payload!.white.name, 'Alpha');
  });

  test(
    'online Fast and Deep remain unavailable without local fallback',
    () async {
      final offline = _FakeProvider('local_offline');
      final pipeline = GameReviewPipeline(
        fastProvider: const OnlineFastReviewProvider(),
        deepProvider: const OnlineDeepReviewProvider(),
        offlineProvider: offline,
      );

      final fast = await pipeline.analyzeContract(
        const GameReviewRequest(pgn: _pgn, profile: AnalysisProfile.fastReview),
      );
      final deep = await pipeline.analyzeContract(
        const GameReviewRequest(pgn: _pgn, profile: AnalysisProfile.deepReview),
      );

      expect(fast.status, AnalysisProviderStatus.unavailable);
      expect(fast.mode, AnalysisReviewMode.onlineFast);
      expect(fast.failureReason, AnalysisFailureReason.providerNotConfigured);
      expect(deep.status, AnalysisProviderStatus.unavailable);
      expect(deep.mode, AnalysisReviewMode.onlineDeep);
      expect(deep.failureReason, AnalysisFailureReason.providerNotConfigured);
      expect(offline.calls, 0);
    },
  );

  test(
    'canonical payload opens review controller without timeline remapping',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final game = _savedGame(analysisMode: AnalysisMode.deep);
      final payload = CanonicalAnalysisPayload.fromArchivedGame(
        game,
        userIsWhite: false,
      );

      container
          .read(reviewControllerProvider.notifier)
          .loadPayload(payload, userIsBlack: true);

      final state = container.read(reviewControllerProvider);
      expect(state.timeline!.headers['White'], 'Alpha');
      expect(state.flipped, isTrue);
      expect(state.userIsWhite, isFalse);
      expect(state.mode, AnalysisMode.deep);
      expect(state.currentPly, 0);
    },
  );

  test(
    'archive adapter saves canonical payload identity and display fields',
    () {
      final payload = CanonicalAnalysisPayload.fromTimeline(
        timeline: _timeline(analysisProfileId: 'offline_review'),
        pgn: _pgn,
        source: AnalysisGameSource.chessCom,
        modeUsed: AnalysisReviewMode.offlineLocal,
        providerKind: AnalysisProviderKind.offlineLocal,
        playedAt: DateTime.utc(2026, 5, 7),
        timeControl: '3 min',
      );
      final game = archivedGameFromAnalysisPayload(
        payload,
        depth: 18,
        analysisMode: AnalysisMode.deep,
      );

      expect(game.id, payload.canonicalGameKey);
      expect(game.source, ArchiveSource.chessCom);
      expect(game.white, 'Alpha');
      expect(game.black, 'Beta');
      expect(game.result, '1-0');
      expect(game.timeControl, '3 min');
      expect(game.cachedTimeline, isNotNull);
    },
  );

  test('stats recent scan adapter uses canonical payload fields', () {
    final game = _savedGame(analysisMode: AnalysisMode.quick);
    final payload = CanonicalAnalysisPayload.fromArchivedGame(game);
    final display = RecentScanDisplay.fromPayload(
      payload,
      game: game,
      perspective: 'Alpha',
    );

    expect(display.card.primaryMeta, '99% · Fast');
    expect(display.card.moveCountLabel, '1 moves');
    expect(display.card.secondaryMeta, contains('Chess.com'));
    expect(display.subtitle, '99% · Fast · 1 moves');
  });

  test('canonical key is stable across modes and distinct across games', () {
    final fast = AnalysisReviewRequest.fromPgn(
      pgn: _pgn,
      requestedMode: AnalysisReviewMode.onlineFast,
    );
    final deep = AnalysisReviewRequest.fromPgn(
      pgn: _pgn,
      requestedMode: AnalysisReviewMode.onlineDeep,
    );
    final different = AnalysisReviewRequest.fromPgn(
      pgn: _differentPgn,
      requestedMode: AnalysisReviewMode.onlineFast,
    );
    final fastGame = _savedGame(analysisMode: AnalysisMode.quick);
    final deepGame = _savedGame(analysisMode: AnalysisMode.deep);

    expect(fast.canonicalGameKey, deep.canonicalGameKey);
    expect(fast.canonicalGameKey, isNot(different.canonicalGameKey));
    expect(ArchivedGame.collapseCanonical([fastGame, deepGame]), hasLength(1));
  });
}

class _FakeProvider extends ReviewAnalysisProvider {
  _FakeProvider(this.providerId);

  @override
  final String providerId;

  int calls = 0;

  @override
  String get engineVersion => 'fake-engine';

  @override
  bool get isConfigured => true;

  @override
  Future<GameReviewResult> analyzeGame(GameReviewRequest request) async {
    calls++;
    final metadata = metadataFor(request);
    final timeline = _timeline(analysisProfileId: metadata.analysisProfileId)
        .copyWith(
          providerId: providerId,
          engineVersion: engineVersion,
          depth: metadata.depth,
          movetimeMs: metadata.movetimeMs,
          multipv: metadata.multipv,
          completedAt: metadata.completedAt,
          pgnHash: metadata.pgnHash,
          cacheKey: metadata.cacheKey,
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
        providerId: providerId,
        profileId: request.profile.id.wire,
        positionsAnalyzed: timeline.totalPlies + 1,
        candidateVerificationsCount: 0,
        averageDepthReached: metadata.depth.toDouble(),
        engineCallsCount: timeline.totalPlies + 1,
      ),
      fromCache: false,
    );
  }
}

ArchivedGame _savedGame({required AnalysisMode analysisMode}) {
  final timeline = _timeline(
    analysisProfileId: analysisMode == AnalysisMode.quick
        ? 'fast_review'
        : 'deep_review',
  );
  return ArchivedGame(
    id: ArchivedGame.canonicalKeyFor(
      pgn: _pgn,
      pgnHash: archiveIdForPgn(_pgn),
      white: 'Alpha',
      black: 'Beta',
      result: '1-0',
    ),
    source: ArchiveSource.chessCom,
    white: 'Alpha',
    black: 'Beta',
    result: '1-0',
    analyzedAt: DateTime.utc(2026, 5, 8),
    depth: analysisMode == AnalysisMode.quick ? 14 : 22,
    pgn: _pgn,
    qualityCounts: timeline.qualityCounts,
    averageCpLoss: timeline.averageCpLoss,
    totalPlies: timeline.totalPlies,
    analysisMode: analysisMode,
    pgnHash: archiveIdForPgn(_pgn),
    cachedTimeline: timeline,
  );
}

AnalysisTimeline _timeline({String analysisProfileId = 'fast_review'}) {
  return AnalysisTimeline(
    startingFen: _fen,
    moves: const [
      MoveAnalysis(
        ply: 0,
        san: 'e4',
        uci: 'e2e4',
        fenBefore: _fen,
        fenAfter: _fen,
        targetSquare: 'e4',
        winPercentBefore: 50,
        winPercentAfter: 52,
        deltaW: 2,
        isWhiteMove: true,
        classification: MoveQuality.best,
        message: 'Best',
      ),
      MoveAnalysis(
        ply: 1,
        san: 'e5',
        uci: 'e7e5',
        fenBefore: _fen,
        fenAfter: _fen,
        targetSquare: 'e5',
        winPercentBefore: 52,
        winPercentAfter: 50,
        deltaW: -2,
        isWhiteMove: false,
        classification: MoveQuality.good,
        message: 'Good',
      ),
    ],
    headers: const {
      'Site': 'https://www.chess.com/game/live/123',
      'White': 'Alpha',
      'Black': 'Beta',
      'Result': '1-0',
      'ECO': 'C20',
      'Opening': 'King Pawn',
    },
    winPercentages: const [52, 50],
    analysisMode: analysisProfileId == 'fast_review' ? 'quick' : 'deep',
    analysisProfileId: analysisProfileId,
    providerId: 'local_offline',
    engineVersion: 'fake-engine',
    classifierVersion: kApexClassifierVersion,
    tacticalVerifierVersion: kApexTacticalVerifierVersion,
    openingBookVersion: kApexOpeningBookVersion,
    analysisSchemaVersion: kApexAnalysisSchemaVersion,
    pgnHash: archiveIdForPgn(_pgn),
  );
}

const _pgn = '''
[Site "https://www.chess.com/game/live/123"]
[White "Alpha"]
[Black "Beta"]
[Result "1-0"]

1. e4 e5 *
''';

const _differentPgn = '''
[Site "https://www.chess.com/game/live/456"]
[White "Alpha"]
[Black "Beta"]
[Result "1-0"]

1. d4 d5 *
''';
