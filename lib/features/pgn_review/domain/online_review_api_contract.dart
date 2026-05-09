/// Online review API contract for the future Apex backend.
///
/// These are pure Dart DTO/domain models. They describe POST /review,
/// GET /review/{jobId}, and GET /review/cache/{gameKey} without adding
/// HTTP, secrets, or a real backend implementation.
library;

import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';

class OnlineReviewProviderConfig {
  const OnlineReviewProviderConfig({
    required this.providerId,
    required this.displayName,
    this.isConfigured = false,
    this.isMock = false,
    this.engineVersion = 'online-unconfigured',
    this.maxPollAttempts = 6,
    this.baseUrl,
    this.apiKey,
    this.requestTimeout = const Duration(seconds: 10),
    this.pollInterval = Duration.zero,
    this.overallTimeout = const Duration(seconds: 45),
  });

  final String providerId;
  final String displayName;
  final bool isConfigured;
  final bool isMock;
  final String engineVersion;
  final int maxPollAttempts;
  final String? baseUrl;
  final String? apiKey;
  final Duration requestTimeout;
  final Duration pollInterval;
  final Duration overallTimeout;

  bool get hasApiKey => apiKey != null && apiKey!.trim().isNotEmpty;

  static const unavailable = OnlineReviewProviderConfig(
    providerId: 'online_unconfigured',
    displayName: 'Online Review',
  );

  factory OnlineReviewProviderConfig.fromEnvironment(AnalysisReviewMode mode) {
    const baseUrl = String.fromEnvironment('APEX_ONLINE_REVIEW_BASE_URL');
    const apiKey = String.fromEnvironment('APEX_ONLINE_REVIEW_API_KEY');
    const requestTimeoutMs = int.fromEnvironment(
      'APEX_ONLINE_REVIEW_REQUEST_TIMEOUT_MS',
      defaultValue: 10000,
    );
    const pollIntervalMs = int.fromEnvironment(
      'APEX_ONLINE_REVIEW_POLL_INTERVAL_MS',
      defaultValue: 500,
    );
    const overallTimeoutMs = int.fromEnvironment(
      'APEX_ONLINE_REVIEW_OVERALL_TIMEOUT_MS',
      defaultValue: 45000,
    );
    const maxPollAttempts = int.fromEnvironment(
      'APEX_ONLINE_REVIEW_MAX_POLL_ATTEMPTS',
      defaultValue: 60,
    );
    final configured = baseUrl.trim().isNotEmpty;
    return OnlineReviewProviderConfig(
      providerId: mode == AnalysisReviewMode.onlineFast
          ? 'apex_backend_online_fast'
          : 'apex_backend_online_deep',
      displayName: mode == AnalysisReviewMode.onlineFast
          ? 'Apex Online Fast'
          : 'Apex Online Deep',
      isConfigured: configured,
      engineVersion: configured ? 'apex-backend-http' : 'online-unconfigured',
      maxPollAttempts: maxPollAttempts,
      baseUrl: configured ? baseUrl : null,
      apiKey: apiKey.trim().isEmpty ? null : apiKey,
      requestTimeout: Duration(milliseconds: requestTimeoutMs),
      pollInterval: Duration(milliseconds: pollIntervalMs),
      overallTimeout: Duration(milliseconds: overallTimeoutMs),
    );
  }
}

class OnlineReviewSubmitRequest {
  const OnlineReviewSubmitRequest({
    required this.analysisRequest,
    required this.gameKey,
    required this.requestedMode,
    required this.submittedAt,
  });

  final AnalysisReviewRequest analysisRequest;
  final String gameKey;
  final AnalysisReviewMode requestedMode;
  final DateTime submittedAt;

  factory OnlineReviewSubmitRequest.fromAnalysisRequest(
    AnalysisReviewRequest request, {
    DateTime? submittedAt,
  }) {
    return OnlineReviewSubmitRequest(
      analysisRequest: request,
      gameKey: request.canonicalGameKey,
      requestedMode: request.requestedMode,
      submittedAt: (submittedAt ?? DateTime.now()).toUtc(),
    );
  }
}

class OnlineReviewSubmitResponse {
  const OnlineReviewSubmitResponse({
    required this.gameKey,
    required this.requestedMode,
    required this.status,
    required this.submittedAt,
    required this.updatedAt,
    this.jobId,
    this.result,
    this.failure,
    this.providerMetadata = const AnalysisProviderMetadata(),
  });

  final String? jobId;
  final String gameKey;
  final AnalysisReviewMode requestedMode;
  final OnlineReviewJobStatus status;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final OnlineReviewJobResult? result;
  final OnlineReviewFailure? failure;
  final AnalysisProviderMetadata providerMetadata;

  bool get accepted => jobId != null && failure == null;

  factory OnlineReviewSubmitResponse.accepted({
    required String jobId,
    required String gameKey,
    required AnalysisReviewMode requestedMode,
    required OnlineReviewJobStatus status,
    DateTime? submittedAt,
    DateTime? updatedAt,
    AnalysisProviderMetadata providerMetadata =
        const AnalysisProviderMetadata(),
  }) {
    final now = (submittedAt ?? DateTime.now()).toUtc();
    return OnlineReviewSubmitResponse(
      jobId: jobId,
      gameKey: gameKey,
      requestedMode: requestedMode,
      status: status,
      submittedAt: now,
      updatedAt: (updatedAt ?? now).toUtc(),
      providerMetadata: providerMetadata,
    );
  }

  factory OnlineReviewSubmitResponse.rejected({
    required String gameKey,
    required AnalysisReviewMode requestedMode,
    required OnlineReviewFailure failure,
    DateTime? submittedAt,
  }) {
    final now = (submittedAt ?? DateTime.now()).toUtc();
    return OnlineReviewSubmitResponse(
      gameKey: gameKey,
      requestedMode: requestedMode,
      status: OnlineReviewJobStatus.failed,
      submittedAt: now,
      updatedAt: now,
      failure: failure,
    );
  }
}

enum OnlineReviewJobStatus {
  queued,
  running,
  completed,
  failed,
  cancelled,
  expired;

  bool get isTerminal =>
      this == OnlineReviewJobStatus.completed ||
      this == OnlineReviewJobStatus.failed ||
      this == OnlineReviewJobStatus.cancelled ||
      this == OnlineReviewJobStatus.expired;

  String get safeLabel => switch (this) {
    OnlineReviewJobStatus.queued => 'Queued',
    OnlineReviewJobStatus.running => 'Analyzing',
    OnlineReviewJobStatus.completed => 'Ready',
    OnlineReviewJobStatus.failed => 'Try again',
    OnlineReviewJobStatus.cancelled => 'Review cancelled',
    OnlineReviewJobStatus.expired => 'Try again',
  };
}

class OnlineReviewJobSnapshot {
  const OnlineReviewJobSnapshot({
    required this.jobId,
    required this.gameKey,
    required this.requestedMode,
    required this.status,
    required this.submittedAt,
    required this.updatedAt,
    this.progress,
    this.result,
    this.failure,
    this.providerMetadata = const AnalysisProviderMetadata(),
  });

  final String jobId;
  final String gameKey;
  final AnalysisReviewMode requestedMode;
  final OnlineReviewJobStatus status;
  final double? progress;
  final DateTime submittedAt;
  final DateTime updatedAt;
  final OnlineReviewJobResult? result;
  final OnlineReviewFailure? failure;
  final AnalysisProviderMetadata providerMetadata;

  String get safeStatusCopy => failure?.safeCopy ?? status.safeLabel;

  AnalysisReviewResult toAnalysisResult() {
    final payload = result?.payload;
    if (status == OnlineReviewJobStatus.completed && payload != null) {
      return AnalysisReviewResult.completed(payload, requestedAt: submittedAt);
    }
    if (status == OnlineReviewJobStatus.cancelled) {
      return AnalysisReviewResult.cancelled(
        mode: requestedMode,
        providerKind: requestedMode.providerKind,
        requestedAt: submittedAt,
      );
    }
    return AnalysisReviewResult.failed(
      mode: requestedMode,
      providerKind: requestedMode.providerKind,
      reason: failure?.reason ?? _failureReasonForStatus(status),
      requestedAt: submittedAt,
      completedAt: updatedAt,
    );
  }
}

class OnlineReviewJobResult {
  const OnlineReviewJobResult({
    required this.payload,
    this.providerMetadata = const AnalysisProviderMetadata(),
  });

  final CanonicalAnalysisPayload payload;
  final AnalysisProviderMetadata providerMetadata;
}

class OnlineReviewFailure {
  const OnlineReviewFailure({
    required this.reason,
    this.providerCode,
    this.retryable = true,
  });

  final AnalysisFailureReason reason;
  final String? providerCode;
  final bool retryable;

  String get safeCopy => reason.safeCopy;
}

class OnlineReviewCacheLookupRequest {
  const OnlineReviewCacheLookupRequest({
    required this.gameKey,
    required this.requestedMode,
    this.analysisRequest,
  });

  final String gameKey;
  final AnalysisReviewMode requestedMode;
  final AnalysisReviewRequest? analysisRequest;
}

enum OnlineReviewCacheLookupStatus {
  hit,
  miss,
  unavailable,
  failed;

  String get safeLabel => switch (this) {
    OnlineReviewCacheLookupStatus.hit => 'Ready',
    OnlineReviewCacheLookupStatus.miss => 'Not cached',
    OnlineReviewCacheLookupStatus.unavailable => 'Online review unavailable',
    OnlineReviewCacheLookupStatus.failed => 'Try again',
  };
}

class OnlineReviewCacheLookupResponse {
  const OnlineReviewCacheLookupResponse({
    required this.status,
    required this.gameKey,
    required this.requestedMode,
    this.payload,
    this.failure,
  });

  final OnlineReviewCacheLookupStatus status;
  final String gameKey;
  final AnalysisReviewMode requestedMode;
  final CanonicalAnalysisPayload? payload;
  final OnlineReviewFailure? failure;

  bool get isHit => status == OnlineReviewCacheLookupStatus.hit;

  bool get isMiss => status == OnlineReviewCacheLookupStatus.miss;

  String get safeStatusCopy => failure?.safeCopy ?? status.safeLabel;

  AnalysisReviewResult? toAnalysisResult() {
    if (isHit && payload != null) {
      return AnalysisReviewResult.cachedHit(payload!);
    }
    if (status == OnlineReviewCacheLookupStatus.unavailable) {
      return AnalysisReviewResult.unavailable(
        mode: requestedMode,
        providerKind: AnalysisProviderKind.unavailable,
        reason: failure?.reason ?? AnalysisFailureReason.providerNotConfigured,
      );
    }
    if (status == OnlineReviewCacheLookupStatus.failed) {
      return AnalysisReviewResult.failed(
        mode: requestedMode,
        providerKind: requestedMode.providerKind,
        reason: failure?.reason ?? AnalysisFailureReason.serviceUnavailable,
      );
    }
    return null;
  }

  factory OnlineReviewCacheLookupResponse.hit({
    required String gameKey,
    required AnalysisReviewMode requestedMode,
    required CanonicalAnalysisPayload payload,
  }) {
    return OnlineReviewCacheLookupResponse(
      status: OnlineReviewCacheLookupStatus.hit,
      gameKey: gameKey,
      requestedMode: requestedMode,
      payload: payload,
    );
  }

  factory OnlineReviewCacheLookupResponse.miss({
    required String gameKey,
    required AnalysisReviewMode requestedMode,
  }) {
    return OnlineReviewCacheLookupResponse(
      status: OnlineReviewCacheLookupStatus.miss,
      gameKey: gameKey,
      requestedMode: requestedMode,
    );
  }

  factory OnlineReviewCacheLookupResponse.unavailable({
    required String gameKey,
    required AnalysisReviewMode requestedMode,
    OnlineReviewFailure? failure,
  }) {
    return OnlineReviewCacheLookupResponse(
      status: OnlineReviewCacheLookupStatus.unavailable,
      gameKey: gameKey,
      requestedMode: requestedMode,
      failure:
          failure ??
          const OnlineReviewFailure(
            reason: AnalysisFailureReason.providerNotConfigured,
          ),
    );
  }

  factory OnlineReviewCacheLookupResponse.failed({
    required String gameKey,
    required AnalysisReviewMode requestedMode,
    required OnlineReviewFailure failure,
  }) {
    return OnlineReviewCacheLookupResponse(
      status: OnlineReviewCacheLookupStatus.failed,
      gameKey: gameKey,
      requestedMode: requestedMode,
      failure: failure,
    );
  }
}

AnalysisFailureReason _failureReasonForStatus(OnlineReviewJobStatus status) {
  return switch (status) {
    OnlineReviewJobStatus.cancelled => AnalysisFailureReason.cancelled,
    OnlineReviewJobStatus.expired => AnalysisFailureReason.timeout,
    OnlineReviewJobStatus.failed => AnalysisFailureReason.serviceUnavailable,
    OnlineReviewJobStatus.queued ||
    OnlineReviewJobStatus.running => AnalysisFailureReason.timeout,
    OnlineReviewJobStatus.completed => AnalysisFailureReason.unknown,
  };
}
