import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/data/archive_save_hook.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/mock_online_review_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_api_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/review_entry_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/review_summary.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen = '8/8/8/8/8/8/8/8 w - - 0 1';

void main() {
  test('submit request maps from canonical analysis request', () {
    final analysisRequest = AnalysisReviewRequest.fromPgn(
      pgn: _pgn,
      requestedMode: AnalysisReviewMode.onlineFast,
      requestedAt: DateTime.utc(2026, 5, 9),
    );
    final submit = OnlineReviewSubmitRequest.fromAnalysisRequest(
      analysisRequest,
      submittedAt: DateTime.utc(2026, 5, 9, 1),
    );

    expect(submit.gameKey, analysisRequest.canonicalGameKey);
    expect(submit.requestedMode, AnalysisReviewMode.onlineFast);
    expect(submit.analysisRequest.inputHash, analysisRequest.inputHash);
    expect(submit.submittedAt, DateTime.utc(2026, 5, 9, 1));
  });

  test('job statuses and failures map to safe copy', () {
    expect(OnlineReviewJobStatus.queued.safeLabel, 'Queued');
    expect(OnlineReviewJobStatus.running.safeLabel, 'Analyzing');
    expect(OnlineReviewJobStatus.completed.safeLabel, 'Ready');
    expect(OnlineReviewJobStatus.failed.safeLabel, 'Try again');

    const failure = OnlineReviewFailure(
      reason: AnalysisFailureReason.providerNotConfigured,
      providerCode: 'mock-disabled',
    );
    expect(failure.safeCopy, 'Online review unavailable');
  });

  test('completed job carries CanonicalAnalysisPayload', () {
    final payload = _payload(mode: AnalysisReviewMode.onlineDeep);
    final snapshot = OnlineReviewJobSnapshot(
      jobId: 'job-1',
      gameKey: payload.canonicalGameKey,
      requestedMode: AnalysisReviewMode.onlineDeep,
      status: OnlineReviewJobStatus.completed,
      submittedAt: DateTime.utc(2026, 5, 9),
      updatedAt: DateTime.utc(2026, 5, 9, 1),
      result: OnlineReviewJobResult(payload: payload),
    );

    final result = snapshot.toAnalysisResult();

    expect(result.status, AnalysisProviderStatus.completed);
    expect(result.mode, AnalysisReviewMode.onlineDeep);
    expect(result.payload!.canonicalGameKey, payload.canonicalGameKey);
    expect(result.payload!.hasTimeline, isTrue);
  });

  test('failed job carries safe failure reason', () {
    final snapshot = OnlineReviewJobSnapshot(
      jobId: 'job-2',
      gameKey: 'game-key',
      requestedMode: AnalysisReviewMode.onlineFast,
      status: OnlineReviewJobStatus.failed,
      submittedAt: DateTime.utc(2026, 5, 9),
      updatedAt: DateTime.utc(2026, 5, 9, 1),
      failure: const OnlineReviewFailure(
        reason: AnalysisFailureReason.serviceUnavailable,
      ),
    );

    final result = snapshot.toAnalysisResult();

    expect(result.status, AnalysisProviderStatus.failed);
    expect(result.failureReason, AnalysisFailureReason.serviceUnavailable);
    expect(snapshot.safeStatusCopy, 'Provider unavailable');
  });

  test('cache lookup hit miss and failure map safely', () {
    final payload = _payload(mode: AnalysisReviewMode.onlineFast);
    final hit = OnlineReviewCacheLookupResponse.hit(
      gameKey: payload.canonicalGameKey,
      requestedMode: AnalysisReviewMode.onlineFast,
      payload: payload,
    );
    final miss = OnlineReviewCacheLookupResponse.miss(
      gameKey: payload.canonicalGameKey,
      requestedMode: AnalysisReviewMode.onlineFast,
    );
    final failed = OnlineReviewCacheLookupResponse.failed(
      gameKey: payload.canonicalGameKey,
      requestedMode: AnalysisReviewMode.onlineFast,
      failure: const OnlineReviewFailure(
        reason: AnalysisFailureReason.serviceUnavailable,
      ),
    );

    expect(hit.toAnalysisResult()!.status, AnalysisProviderStatus.cachedHit);
    expect(miss.toAnalysisResult(), isNull);
    expect(miss.safeStatusCopy, 'Not cached');
    expect(
      failed.toAnalysisResult()!.failureReason,
      AnalysisFailureReason.serviceUnavailable,
    );
    expect(failed.safeStatusCopy, 'Provider unavailable');
  });

  test('pipeline with disabled online provider returns unavailable', () async {
    final offline = _FakeOfflineProvider();
    final pipeline = GameReviewPipeline(
      fastProvider: OnlineReviewAnalysisProvider(
        onlineProvider: const DisabledOnlineReviewProvider(),
        profile: AnalysisProfile.fastReview,
      ),
      deepProvider: OnlineReviewAnalysisProvider(
        onlineProvider: const DisabledOnlineReviewProvider(),
        profile: AnalysisProfile.deepReview,
      ),
      offlineProvider: offline,
    );

    final result = await pipeline.analyzeContract(
      const GameReviewRequest(pgn: _pgn, profile: AnalysisProfile.fastReview),
    );

    expect(result.status, AnalysisProviderStatus.unavailable);
    expect(result.mode, AnalysisReviewMode.onlineFast);
    expect(result.failureReason, AnalysisFailureReason.providerNotConfigured);
    expect(offline.calls, 0);
  });

  test('mock onlineFast completes through queued and running states', () async {
    final mock = MockOnlineReviewProvider(mode: AnalysisReviewMode.onlineFast);
    final pipeline = _pipelineWith(fast: mock);

    final result = await pipeline.analyzeContract(
      const GameReviewRequest(
        pgn: _pgn,
        profile: AnalysisProfile.fastReview,
        userIsWhite: true,
      ),
    );

    expect(result.status, AnalysisProviderStatus.completed);
    expect(result.mode, AnalysisReviewMode.onlineFast);
    expect(result.providerKind, AnalysisProviderKind.onlineFast);
    expect(result.payload!.modeUsed, AnalysisReviewMode.onlineFast);
    expect(result.payload!.providerMetadata.providerId, 'mock_online_fast');
    expect(result.payload!.timeline!.analysisProfileId, 'fast_review');
    expect(mock.submitCount, 1);
    expect(mock.pollCount, 2);
  });

  test('mock onlineDeep completes with deep mode metadata', () async {
    final mock = MockOnlineReviewProvider(mode: AnalysisReviewMode.onlineDeep);
    final pipeline = _pipelineWith(deep: mock);

    final result = await pipeline.analyzeContract(
      const GameReviewRequest(pgn: _pgn, profile: AnalysisProfile.deepReview),
    );

    expect(result.status, AnalysisProviderStatus.completed);
    expect(result.mode, AnalysisReviewMode.onlineDeep);
    expect(result.payload!.providerMetadata.providerId, 'mock_online_deep');
    expect(result.payload!.providerMetadata.multipv, 3);
    expect(result.payload!.timeline!.analysisProfileId, 'deep_review');
  });

  test('mock provider failure maps to safe failure', () async {
    final mock = MockOnlineReviewProvider(
      mode: AnalysisReviewMode.onlineFast,
      jobScript: const [
        OnlineReviewJobStatus.queued,
        OnlineReviewJobStatus.failed,
      ],
      failureReason: AnalysisFailureReason.serviceUnavailable,
    );
    final pipeline = _pipelineWith(fast: mock);

    final result = await pipeline.analyzeContract(
      const GameReviewRequest(pgn: _pgn, profile: AnalysisProfile.fastReview),
    );

    expect(result.status, AnalysisProviderStatus.failed);
    expect(result.failureReason, AnalysisFailureReason.serviceUnavailable);
    expect(result.safeFailureCopy, 'Provider unavailable');
  });

  test('mock provider timeout maps safely', () async {
    final mock = MockOnlineReviewProvider(
      mode: AnalysisReviewMode.onlineFast,
      config: const OnlineReviewProviderConfig(
        providerId: 'mock_timeout',
        displayName: 'Mock Timeout',
        isConfigured: true,
        isMock: true,
        engineVersion: 'mock-online-review-v1',
        maxPollAttempts: 2,
      ),
      jobScript: const [
        OnlineReviewJobStatus.queued,
        OnlineReviewJobStatus.running,
        OnlineReviewJobStatus.running,
        OnlineReviewJobStatus.running,
      ],
    );
    final pipeline = _pipelineWith(fast: mock);

    final result = await pipeline.analyzeContract(
      const GameReviewRequest(pgn: _pgn, profile: AnalysisProfile.fastReview),
    );

    expect(result.status, AnalysisProviderStatus.failed);
    expect(result.failureReason, AnalysisFailureReason.timeout);
    expect(result.safeFailureCopy, 'Try again');
  });

  test(
    'mock cache hit returns cached payload without submitting job',
    () async {
      final cached = _payload(mode: AnalysisReviewMode.onlineDeep);
      final mock = MockOnlineReviewProvider(
        mode: AnalysisReviewMode.onlineDeep,
        cacheMode: MockOnlineReviewCacheMode.hit,
        cachedPayload: cached,
      );
      final pipeline = _pipelineWith(deep: mock);

      final result = await pipeline.analyzeContract(
        const GameReviewRequest(pgn: _pgn, profile: AnalysisProfile.deepReview),
      );

      expect(result.status, AnalysisProviderStatus.cachedHit);
      expect(result.payload!.canonicalGameKey, cached.canonicalGameKey);
      expect(mock.cacheLookupCount, 1);
      expect(mock.submitCount, 0);
    },
  );

  test('saved preview contract wins without starting online job', () {
    final mock = MockOnlineReviewProvider(mode: AnalysisReviewMode.onlineFast);
    final saved = _savedGame();

    final result = ReviewEntryContract.savedReviewResult(saved);

    expect(result.status, AnalysisProviderStatus.cachedHit);
    expect(result.payload!.canonicalGameKey, saved.canonicalGameKey);
    expect(mock.submitCount, 0);
  });

  test(
    'offline path remains available and does not use online provider',
    () async {
      final offline = _FakeOfflineProvider();
      final fast = MockOnlineReviewProvider(
        mode: AnalysisReviewMode.onlineFast,
      );
      final pipeline = GameReviewPipeline(
        fastProvider: OnlineReviewAnalysisProvider(
          onlineProvider: fast,
          profile: AnalysisProfile.fastReview,
        ),
        deepProvider: OnlineReviewAnalysisProvider(
          onlineProvider: MockOnlineReviewProvider(
            mode: AnalysisReviewMode.onlineDeep,
          ),
          profile: AnalysisProfile.deepReview,
        ),
        offlineProvider: offline,
      );

      final result = await pipeline.analyzeContract(
        const GameReviewRequest(
          pgn: _pgn,
          profile: AnalysisProfile.offlineReview,
        ),
      );

      expect(result.status, AnalysisProviderStatus.completed);
      expect(result.mode, AnalysisReviewMode.offlineLocal);
      expect(offline.calls, 1);
      expect(fast.submitCount, 0);
    },
  );
}

GameReviewPipeline _pipelineWith({
  MockOnlineReviewProvider? fast,
  MockOnlineReviewProvider? deep,
}) {
  return GameReviewPipeline(
    fastProvider: OnlineReviewAnalysisProvider(
      onlineProvider:
          fast ?? MockOnlineReviewProvider(mode: AnalysisReviewMode.onlineFast),
      profile: AnalysisProfile.fastReview,
    ),
    deepProvider: OnlineReviewAnalysisProvider(
      onlineProvider:
          deep ?? MockOnlineReviewProvider(mode: AnalysisReviewMode.onlineDeep),
      profile: AnalysisProfile.deepReview,
    ),
    offlineProvider: _FakeOfflineProvider(),
  );
}

class _FakeOfflineProvider extends ReviewAnalysisProvider {
  int calls = 0;

  @override
  String get providerId => 'local_offline';

  @override
  String get engineVersion => 'fake-local';

  @override
  bool get isConfigured => true;

  @override
  Future<GameReviewResult> analyzeGame(GameReviewRequest request) async {
    calls++;
    final metadata = metadataFor(request);
    final timeline =
        _timeline(
          analysisProfileId: 'offline_review',
          providerId: providerId,
          engineVersion: engineVersion,
        ).copyWith(
          depth: metadata.depth,
          movetimeMs: metadata.movetimeMs,
          multipv: metadata.multipv,
          completedAt: metadata.completedAt,
          pgnHash: metadata.pgnHash,
          cacheKey: metadata.cacheKey,
        );
    final payload = CanonicalAnalysisPayload.fromTimeline(
      timeline: timeline,
      pgn: request.pgn,
      source: AnalysisGameSource.fromPgn(request.pgn),
      modeUsed: AnalysisReviewMode.offlineLocal,
      providerKind: AnalysisProviderKind.offlineLocal,
      userIsWhite: request.userIsWhite,
      providerMetadata: metadata.toContractMetadata(),
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
      analysisResult: AnalysisReviewResult.completed(payload),
    );
  }
}

CanonicalAnalysisPayload _payload({required AnalysisReviewMode mode}) {
  final timeline = _timeline(
    analysisProfileId: mode == AnalysisReviewMode.onlineFast
        ? 'fast_review'
        : 'deep_review',
    providerId: mode == AnalysisReviewMode.onlineFast
        ? 'mock_online_fast'
        : 'mock_online_deep',
    engineVersion: 'mock-online-review-v1',
  );
  final request = AnalysisReviewRequest.fromPgn(pgn: _pgn, requestedMode: mode);
  return CanonicalAnalysisPayload.fromTimeline(
    timeline: timeline,
    pgn: _pgn,
    source: AnalysisGameSource.chessCom,
    modeUsed: mode,
    providerKind: mode.providerKind,
    providerMetadata: AnalysisProviderMetadata.fromTimeline(timeline),
  ).copyWithGameKeyForTest(request.canonicalGameKey);
}

ArchivedGame _savedGame() {
  final timeline = _timeline(
    analysisProfileId: 'fast_review',
    providerId: 'mock_online_fast',
    engineVersion: 'mock-online-review-v1',
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
    analyzedAt: DateTime.utc(2026, 5, 9),
    depth: 14,
    pgn: _pgn,
    qualityCounts: timeline.qualityCounts,
    averageCpLoss: timeline.averageCpLoss,
    totalPlies: timeline.totalPlies,
    analysisMode: AnalysisMode.quick,
    pgnHash: archiveIdForPgn(_pgn),
    cachedTimeline: timeline,
  );
}

AnalysisTimeline _timeline({
  required String analysisProfileId,
  required String providerId,
  required String engineVersion,
}) {
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
        classification: MoveQuality.good,
        message: 'Good',
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
      'Site': 'https://www.chess.com/game/live/999',
      'White': 'Alpha',
      'Black': 'Beta',
      'Result': '1-0',
      'ECO': 'A00',
      'Opening': 'Mock Review Line',
    },
    winPercentages: const [52, 50],
    analysisMode: analysisProfileId == 'fast_review' ? 'quick' : 'deep',
    analysisProfileId: analysisProfileId,
    providerId: providerId,
    engineVersion: engineVersion,
    classifierVersion: kApexClassifierVersion,
    tacticalVerifierVersion: kApexTacticalVerifierVersion,
    openingBookVersion: kApexOpeningBookVersion,
    analysisSchemaVersion: kApexAnalysisSchemaVersion,
    pgnHash: archiveIdForPgn(_pgn),
  );
}

extension on CanonicalAnalysisPayload {
  CanonicalAnalysisPayload copyWithGameKeyForTest(String canonicalGameKey) {
    return CanonicalAnalysisPayload(
      canonicalGameKey: canonicalGameKey,
      modeUsed: modeUsed,
      providerKind: providerKind,
      status: status,
      source: source,
      inputHash: inputHash,
      pgn: pgn,
      sourceId: sourceId,
      white: white,
      black: black,
      userIsWhite: userIsWhite,
      result: result,
      playedAt: playedAt,
      openingName: openingName,
      ecoCode: ecoCode,
      averageCpLoss: averageCpLoss,
      averageCpLossWhite: averageCpLossWhite,
      averageCpLossBlack: averageCpLossBlack,
      qualityCounts: qualityCounts,
      totalPlies: totalPlies,
      timeline: timeline,
      createdAt: createdAt,
      updatedAt: updatedAt,
      timeControl: timeControl,
      providerMetadata: providerMetadata,
    );
  }
}

const _pgn = '''
[Site "https://www.chess.com/game/live/999"]
[White "Alpha"]
[Black "Beta"]
[Result "1-0"]

1. e4 e5 *
''';
