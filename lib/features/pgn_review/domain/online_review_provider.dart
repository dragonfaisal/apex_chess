/// Online review provider interface and ReviewAnalysisProvider adapter.
///
/// This file does not perform HTTP. It defines the contract future backend
/// clients must satisfy and adapts typed online job results back into the
/// existing review pipeline.
library;

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_api_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/review_summary.dart';

abstract class OnlineReviewProvider {
  const OnlineReviewProvider();

  OnlineReviewProviderConfig get config;

  Future<OnlineReviewSubmitResponse> submitReview(
    OnlineReviewSubmitRequest request,
  );

  Future<OnlineReviewJobSnapshot> getJob(String jobId);

  Future<OnlineReviewCacheLookupResponse> getCachedReview(
    OnlineReviewCacheLookupRequest request,
  );

  Future<OnlineReviewJobSnapshot> cancelJob(String jobId);
}

class DisabledOnlineReviewProvider extends OnlineReviewProvider {
  const DisabledOnlineReviewProvider({
    this.config = OnlineReviewProviderConfig.unavailable,
  });

  @override
  final OnlineReviewProviderConfig config;

  @override
  Future<OnlineReviewSubmitResponse> submitReview(
    OnlineReviewSubmitRequest request,
  ) async {
    return OnlineReviewSubmitResponse.rejected(
      gameKey: request.gameKey,
      requestedMode: request.requestedMode,
      failure: const OnlineReviewFailure(
        reason: AnalysisFailureReason.providerNotConfigured,
      ),
      submittedAt: request.submittedAt,
    );
  }

  @override
  Future<OnlineReviewJobSnapshot> getJob(String jobId) async {
    final now = DateTime.now().toUtc();
    return OnlineReviewJobSnapshot(
      jobId: jobId,
      gameKey: '',
      requestedMode: AnalysisReviewMode.onlineFast,
      status: OnlineReviewJobStatus.failed,
      submittedAt: now,
      updatedAt: now,
      failure: const OnlineReviewFailure(
        reason: AnalysisFailureReason.providerNotConfigured,
      ),
    );
  }

  @override
  Future<OnlineReviewCacheLookupResponse> getCachedReview(
    OnlineReviewCacheLookupRequest request,
  ) async {
    return OnlineReviewCacheLookupResponse.unavailable(
      gameKey: request.gameKey,
      requestedMode: request.requestedMode,
    );
  }

  @override
  Future<OnlineReviewJobSnapshot> cancelJob(String jobId) async {
    return getJob(jobId);
  }
}

class OnlineReviewAnalysisProvider extends ReviewAnalysisProvider {
  const OnlineReviewAnalysisProvider({
    required this.onlineProvider,
    required this.profile,
  });

  final OnlineReviewProvider onlineProvider;
  final AnalysisProfile profile;

  @override
  String get providerId => onlineProvider.config.providerId;

  @override
  String get engineVersion => onlineProvider.config.engineVersion;

  @override
  bool get isConfigured => onlineProvider.config.isConfigured;

  @override
  Future<AnalysisReviewResult?> analyzeContractRequest(
    GameReviewRequest request,
  ) async {
    final mode = AnalysisReviewMode.fromProfile(profile);
    if (!isConfigured) {
      return AnalysisReviewResult.unavailable(
        mode: mode,
        providerKind: AnalysisProviderKind.unavailable,
        reason: AnalysisFailureReason.providerNotConfigured,
      );
    }

    final analysisRequest = request.toContract();
    final cached = await onlineProvider.getCachedReview(
      OnlineReviewCacheLookupRequest(
        gameKey: analysisRequest.canonicalGameKey,
        requestedMode: mode,
      ),
    );
    final cachedResult = cached.toAnalysisResult();
    if (cachedResult != null) return cachedResult;

    final submit = await onlineProvider.submitReview(
      OnlineReviewSubmitRequest.fromAnalysisRequest(analysisRequest),
    );
    if (!submit.accepted || submit.jobId == null) {
      return AnalysisReviewResult.unavailable(
        mode: mode,
        providerKind: AnalysisProviderKind.unavailable,
        reason:
            submit.failure?.reason ??
            AnalysisFailureReason.providerNotConfigured,
      );
    }

    var snapshot = OnlineReviewJobSnapshot(
      jobId: submit.jobId!,
      gameKey: submit.gameKey,
      requestedMode: submit.requestedMode,
      status: submit.status,
      submittedAt: submit.submittedAt,
      updatedAt: submit.updatedAt,
      result: submit.result,
      failure: submit.failure,
      providerMetadata: submit.providerMetadata,
    );
    if (snapshot.status.isTerminal) return snapshot.toAnalysisResult();

    for (var i = 0; i < onlineProvider.config.maxPollAttempts; i++) {
      snapshot = await onlineProvider.getJob(submit.jobId!);
      if (snapshot.status.isTerminal) {
        return snapshot.toAnalysisResult();
      }
    }

    return AnalysisReviewResult.failed(
      mode: mode,
      providerKind: mode.providerKind,
      reason: AnalysisFailureReason.timeout,
      requestedAt: submit.submittedAt,
      completedAt: snapshot.updatedAt,
    );
  }

  @override
  Future<GameReviewResult> analyzeGame(GameReviewRequest request) async {
    final contract = await analyzeContractRequest(request);
    final payload = contract?.payload;
    final timeline = payload?.timeline;
    if (contract == null ||
        !contract.isSuccess ||
        payload == null ||
        timeline == null ||
        timeline.moves.isEmpty) {
      throw ReviewProviderUnavailableException(
        contract?.safeFailureCopy ?? 'Online review unavailable',
      );
    }

    final metadata = metadataFor(request);
    final tacticalVerifications = timeline.moves
        .where((m) => m.tacticalVerdict.candidateVerified)
        .length;
    return GameReviewResult(
      timeline: timeline,
      summary: const ReviewSummaryService().compute(
        timeline: timeline,
        userIsWhite: request.userIsWhite,
      ),
      metadata: metadata,
      telemetry: AnalysisTelemetry(
        totalAnalysisMs: 0,
        cacheHit: contract.status == AnalysisProviderStatus.cachedHit,
        providerId: providerId,
        profileId: request.profile.id.wire,
        positionsAnalyzed: timeline.totalPlies + 1,
        candidateVerificationsCount: tacticalVerifications,
        averageDepthReached: (metadata.depth).toDouble(),
        engineCallsCount: 0,
      ),
      fromCache: contract.status == AnalysisProviderStatus.cachedHit,
      analysisResult: contract,
    );
  }
}
