/// Mock/dev-only online review provider.
///
/// This simulates backend job/cache behavior for tests and local wiring. It
/// does not call the engine, network, paid services, or production APIs.
library;

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_api_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_provider.dart';

enum MockOnlineReviewCacheMode { hit, miss, unavailable, failed }

class MockOnlineReviewProvider extends OnlineReviewProvider {
  MockOnlineReviewProvider({
    required this.mode,
    this.cacheMode = MockOnlineReviewCacheMode.miss,
    this.cachedPayload,
    this.jobScript = const [
      OnlineReviewJobStatus.queued,
      OnlineReviewJobStatus.running,
      OnlineReviewJobStatus.completed,
    ],
    this.failureReason = AnalysisFailureReason.serviceUnavailable,
    OnlineReviewProviderConfig? config,
  }) : config =
           config ??
           OnlineReviewProviderConfig(
             providerId: mode == AnalysisReviewMode.onlineFast
                 ? 'mock_online_fast'
                 : 'mock_online_deep',
             displayName: mode == AnalysisReviewMode.onlineFast
                 ? 'Mock Online Fast'
                 : 'Mock Online Deep',
             isConfigured: true,
             isMock: true,
             engineVersion: 'mock-online-review-v1',
             maxPollAttempts: 6,
           );

  final AnalysisReviewMode mode;
  final MockOnlineReviewCacheMode cacheMode;
  final CanonicalAnalysisPayload? cachedPayload;
  final List<OnlineReviewJobStatus> jobScript;
  final AnalysisFailureReason failureReason;

  @override
  final OnlineReviewProviderConfig config;

  final Map<String, _MockOnlineJob> _jobs = {};
  int _jobCounter = 0;

  int submitCount = 0;
  int cacheLookupCount = 0;
  int pollCount = 0;

  @override
  Future<OnlineReviewCacheLookupResponse> getCachedReview(
    OnlineReviewCacheLookupRequest request,
  ) async {
    cacheLookupCount++;
    return switch (cacheMode) {
      MockOnlineReviewCacheMode.hit => OnlineReviewCacheLookupResponse.hit(
        gameKey: request.gameKey,
        requestedMode: request.requestedMode,
        payload:
            cachedPayload ??
            _mockPayloadForRequest(
              request: null,
              gameKey: request.gameKey,
              mode: request.requestedMode,
            ),
      ),
      MockOnlineReviewCacheMode.miss => OnlineReviewCacheLookupResponse.miss(
        gameKey: request.gameKey,
        requestedMode: request.requestedMode,
      ),
      MockOnlineReviewCacheMode.unavailable =>
        OnlineReviewCacheLookupResponse.unavailable(
          gameKey: request.gameKey,
          requestedMode: request.requestedMode,
        ),
      MockOnlineReviewCacheMode.failed =>
        OnlineReviewCacheLookupResponse.failed(
          gameKey: request.gameKey,
          requestedMode: request.requestedMode,
          failure: OnlineReviewFailure(reason: failureReason),
        ),
    };
  }

  @override
  Future<OnlineReviewSubmitResponse> submitReview(
    OnlineReviewSubmitRequest request,
  ) async {
    submitCount++;
    if (!config.isConfigured) {
      return OnlineReviewSubmitResponse.rejected(
        gameKey: request.gameKey,
        requestedMode: request.requestedMode,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.providerNotConfigured,
        ),
        submittedAt: request.submittedAt,
      );
    }

    final script = jobScript.isEmpty
        ? const [OnlineReviewJobStatus.completed]
        : jobScript;
    final jobId = 'mock-job-${++_jobCounter}';
    final job = _MockOnlineJob(
      jobId: jobId,
      request: request,
      script: script,
      failureReason: failureReason,
      providerMetadata: _providerMetadataFor(request.requestedMode),
    );
    _jobs[jobId] = job;
    return OnlineReviewSubmitResponse.accepted(
      jobId: jobId,
      gameKey: request.gameKey,
      requestedMode: request.requestedMode,
      status: script.first,
      submittedAt: request.submittedAt,
      providerMetadata: job.providerMetadata,
    );
  }

  @override
  Future<OnlineReviewJobSnapshot> getJob(String jobId) async {
    pollCount++;
    final job = _jobs[jobId];
    if (job == null) {
      final now = DateTime.now().toUtc();
      return OnlineReviewJobSnapshot(
        jobId: jobId,
        gameKey: '',
        requestedMode: mode,
        status: OnlineReviewJobStatus.failed,
        submittedAt: now,
        updatedAt: now,
        failure: const OnlineReviewFailure(
          reason: AnalysisFailureReason.serviceUnavailable,
        ),
      );
    }
    job.advance();
    return job.snapshot();
  }

  @override
  Future<OnlineReviewJobSnapshot> cancelJob(String jobId) async {
    final job = _jobs[jobId];
    if (job == null) return getJob(jobId);
    job.cancelled = true;
    return job.snapshot();
  }

  AnalysisProviderMetadata _providerMetadataFor(AnalysisReviewMode mode) {
    return AnalysisProviderMetadata(
      analysisProfileId: mode == AnalysisReviewMode.onlineFast
          ? 'fast_review'
          : 'deep_review',
      providerId: config.providerId,
      engineVersion: config.engineVersion,
      classifierVersion: kApexClassifierVersion,
      tacticalVerifierVersion: kApexTacticalVerifierVersion,
      openingBookVersion: kApexOpeningBookVersion,
      depth: mode == AnalysisReviewMode.onlineFast ? 12 : 20,
      movetimeMs: 0,
      multipv: mode == AnalysisReviewMode.onlineFast ? 1 : 3,
      candidateVerificationEnabled: mode == AnalysisReviewMode.onlineDeep,
      pgnHash: null,
      cacheKey: null,
    );
  }
}

class _MockOnlineJob {
  _MockOnlineJob({
    required this.jobId,
    required this.request,
    required this.script,
    required this.failureReason,
    required this.providerMetadata,
  });

  final String jobId;
  final OnlineReviewSubmitRequest request;
  final List<OnlineReviewJobStatus> script;
  final AnalysisFailureReason failureReason;
  final AnalysisProviderMetadata providerMetadata;

  int index = 0;
  bool cancelled = false;

  void advance() {
    if (index < script.length - 1) index++;
  }

  OnlineReviewJobSnapshot snapshot() {
    final status = cancelled ? OnlineReviewJobStatus.cancelled : script[index];
    final result = status == OnlineReviewJobStatus.completed
        ? OnlineReviewJobResult(
            payload: _mockPayloadForRequest(
              request: request.analysisRequest,
              gameKey: request.gameKey,
              mode: request.requestedMode,
              providerMetadata: providerMetadata,
            ),
            providerMetadata: providerMetadata,
          )
        : null;
    final failure = switch (status) {
      OnlineReviewJobStatus.failed => OnlineReviewFailure(
        reason: failureReason,
      ),
      OnlineReviewJobStatus.cancelled => const OnlineReviewFailure(
        reason: AnalysisFailureReason.cancelled,
        retryable: false,
      ),
      OnlineReviewJobStatus.expired => const OnlineReviewFailure(
        reason: AnalysisFailureReason.timeout,
      ),
      _ => null,
    };
    final progress = switch (status) {
      OnlineReviewJobStatus.queued => 0.1,
      OnlineReviewJobStatus.running => 0.55,
      OnlineReviewJobStatus.completed => 1,
      _ => null,
    };
    return OnlineReviewJobSnapshot(
      jobId: jobId,
      gameKey: request.gameKey,
      requestedMode: request.requestedMode,
      status: status,
      progress: progress?.toDouble(),
      submittedAt: request.submittedAt,
      updatedAt: DateTime.now().toUtc(),
      result: result,
      failure: failure,
      providerMetadata: providerMetadata,
    );
  }
}

CanonicalAnalysisPayload _mockPayloadForRequest({
  required AnalysisReviewRequest? request,
  required String gameKey,
  required AnalysisReviewMode mode,
  AnalysisProviderMetadata providerMetadata = const AnalysisProviderMetadata(),
}) {
  final white = request?.white.name ?? 'White';
  final black = request?.black.name ?? 'Black';
  final result = request?.result ?? '*';
  final pgn = request?.normalizedPgn ?? '1. e4 e5 *';
  final timeline = AnalysisTimeline(
    startingFen: _initialFen,
    moves: const [
      MoveAnalysis(
        ply: 0,
        san: 'e4',
        uci: 'e2e4',
        fenBefore: _initialFen,
        fenAfter: _initialFen,
        targetSquare: 'e4',
        winPercentBefore: 50,
        winPercentAfter: 52,
        deltaW: 2,
        isWhiteMove: true,
        classification: MoveQuality.good,
        message: 'Mock online review move',
      ),
      MoveAnalysis(
        ply: 1,
        san: 'e5',
        uci: 'e7e5',
        fenBefore: _initialFen,
        fenAfter: _initialFen,
        targetSquare: 'e5',
        winPercentBefore: 52,
        winPercentAfter: 50,
        deltaW: -2,
        isWhiteMove: false,
        classification: MoveQuality.good,
        message: 'Mock online review move',
      ),
    ],
    headers: {
      'White': white,
      'Black': black,
      'Result': result,
      'Opening': 'Mock Review Line',
      'ECO': 'A00',
    },
    winPercentages: const [52, 50],
    analysisMode: mode == AnalysisReviewMode.onlineFast ? 'quick' : 'deep',
    analysisProfileId: mode == AnalysisReviewMode.onlineFast
        ? 'fast_review'
        : 'deep_review',
    providerId: providerMetadata.providerId ?? 'mock_online',
    engineVersion: providerMetadata.engineVersion ?? 'mock-online-review-v1',
    classifierVersion: kApexClassifierVersion,
    tacticalVerifierVersion: kApexTacticalVerifierVersion,
    openingBookVersion: kApexOpeningBookVersion,
    analysisSchemaVersion: kApexAnalysisSchemaVersion,
    depth: providerMetadata.depth,
    movetimeMs: providerMetadata.movetimeMs,
    multipv: providerMetadata.multipv,
    candidateVerificationEnabled:
        providerMetadata.candidateVerificationEnabled ?? false,
    pgnHash: request?.inputHash,
  );
  return CanonicalAnalysisPayload(
    canonicalGameKey: gameKey,
    modeUsed: mode,
    providerKind: mode.providerKind,
    status: AnalysisProviderStatus.completed,
    source: request?.source ?? AnalysisGameSource.unknown,
    inputHash: request?.inputHash ?? gameKey,
    pgn: pgn,
    sourceId: request?.sourceId,
    white: AnalysisPlayerInfo.fromName(white),
    black: AnalysisPlayerInfo.fromName(black),
    userIsWhite: request?.userIsWhite,
    result: result,
    playedAt: request?.playedAt,
    openingName: 'Mock Review Line',
    ecoCode: 'A00',
    averageCpLoss: timeline.averageCpLoss,
    averageCpLossWhite: timeline.averageCpLossWhite,
    averageCpLossBlack: timeline.averageCpLossBlack,
    qualityCounts: timeline.qualityCounts,
    totalPlies: timeline.totalPlies,
    timeline: timeline,
    createdAt: DateTime.now().toUtc(),
    updatedAt: DateTime.now().toUtc(),
    providerMetadata: providerMetadata,
  );
}

const _initialFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
