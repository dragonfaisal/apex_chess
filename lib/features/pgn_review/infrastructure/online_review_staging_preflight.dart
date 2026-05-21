/// Dormant staging transport preflight contract for Online Review.
///
/// The preflight contract is gated by staging readiness before any transport
/// call. It does not send analysis requests, carry PGN/user/engine data, read
/// environment values, register providers, or activate Online Review.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/core/network/api_headers.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';

const onlineReviewStagingPreflightContractVersion =
    'online-review-staging-preflight-v1';
const onlineReviewStagingPreflightSupportedProductContract =
    'online-review-product-v1';
const onlineReviewStagingPreflightEndpointPath =
    '/analysis/dev/online-review-product/preflight';

enum OnlineReviewStagingPreflightStatus {
  disabled,
  notReady,
  readyToAttempt,
  success,
  failed,
  blocked,
}

enum OnlineReviewStagingPreflightFailureCode {
  readinessNotReady,
  missingBaseUri,
  httpNotAllowed,
  unsafeBaseUri,
  smokeReportFailed,
  networkError,
  timeout,
  httpStatus,
  invalidJson,
  contractMismatch,
  unexpected,
}

class OnlineReviewStagingPreflightRequest {
  const OnlineReviewStagingPreflightRequest({
    required this.readiness,
    required this.mode,
    this.timeout,
  });

  factory OnlineReviewStagingPreflightRequest.fromReadiness(
    OnlineReviewStagingBackendReadiness readiness, {
    Duration? timeout,
  }) {
    return OnlineReviewStagingPreflightRequest(
      readiness: readiness,
      mode: readiness.runtimeMode,
      timeout: timeout,
    );
  }

  final OnlineReviewStagingBackendReadiness readiness;
  final OnlineReviewRuntimeMode mode;
  final Duration? timeout;
}

class OnlineReviewStagingPreflightResponse {
  OnlineReviewStagingPreflightResponse({
    required this.contractVersion,
    required this.status,
    required this.ok,
    this.backendName,
    this.backendVersion,
    this.supportedProductContract,
    this.serverTime,
    List<String> warnings = const [],
  }) : warnings = List.unmodifiable(warnings);

  final String contractVersion;
  final OnlineReviewStagingPreflightStatus status;
  final bool ok;
  final String? backendName;
  final String? backendVersion;
  final String? supportedProductContract;
  final String? serverTime;
  final List<String> warnings;
}

class OnlineReviewStagingPreflightResult {
  const OnlineReviewStagingPreflightResult({
    required this.status,
    this.response,
    this.failure,
  });

  final OnlineReviewStagingPreflightStatus status;
  final OnlineReviewStagingPreflightResponse? response;
  final OnlineReviewStagingPreflightFailure? failure;

  bool get isSuccess =>
      status == OnlineReviewStagingPreflightStatus.success &&
      response?.ok == true &&
      failure == null;

  bool get canAttemptAnalysis => isSuccess;
}

class OnlineReviewStagingPreflightFailure {
  const OnlineReviewStagingPreflightFailure({
    required this.code,
    required this.message,
    required this.isRetryable,
    required this.source,
  });

  final OnlineReviewStagingPreflightFailureCode code;
  final String message;
  final bool isRetryable;
  final String source;
}

abstract class OnlineReviewStagingPreflightClient {
  const OnlineReviewStagingPreflightClient();

  Future<OnlineReviewStagingPreflightResult> check(
    OnlineReviewStagingBackendReadiness readiness,
  );
}

class HttpOnlineReviewStagingPreflightClient
    implements OnlineReviewStagingPreflightClient {
  HttpOnlineReviewStagingPreflightClient({
    required Uri baseUri,
    required ApexHttpClient httpClient,
    this.timeout = const Duration(seconds: 5),
    Map<String, String> headers = const {},
  }) : _baseUri = baseUri,
       _httpClient = httpClient,
       _headers = Map.unmodifiable({
         ...apexJsonHeaders,
         'Content-Type': 'application/json',
         ...headers,
       });

  final Uri _baseUri;
  final ApexHttpClient _httpClient;
  final Duration timeout;
  final Map<String, String> _headers;

  @override
  Future<OnlineReviewStagingPreflightResult> check(
    OnlineReviewStagingBackendReadiness readiness,
  ) async {
    final readinessResult = onlineReviewStagingPreflightReadinessGate(
      readiness,
    );
    if (readinessResult.status !=
        OnlineReviewStagingPreflightStatus.readyToAttempt) {
      return readinessResult;
    }

    late final ApexHttpResponse response;
    try {
      response = await _httpClient.postJson(
        _endpointUri(),
        body: _requestBody(readiness),
        headers: _headers,
        timeout: timeout,
      );
    } on TimeoutException {
      return _failureResult(
        status: OnlineReviewStagingPreflightStatus.failed,
        code: OnlineReviewStagingPreflightFailureCode.timeout,
        message: 'Online Review staging preflight timed out.',
        isRetryable: true,
        source: 'network',
      );
    } on ApexHttpNetworkException {
      return _failureResult(
        status: OnlineReviewStagingPreflightStatus.failed,
        code: OnlineReviewStagingPreflightFailureCode.networkError,
        message: 'Online Review staging preflight could not reach the server.',
        isRetryable: true,
        source: 'network',
      );
    } on SocketException {
      return _failureResult(
        status: OnlineReviewStagingPreflightStatus.failed,
        code: OnlineReviewStagingPreflightFailureCode.networkError,
        message: 'Online Review staging preflight could not reach the server.',
        isRetryable: true,
        source: 'network',
      );
    } catch (_) {
      return _failureResult(
        status: OnlineReviewStagingPreflightStatus.failed,
        code: OnlineReviewStagingPreflightFailureCode.unexpected,
        message: 'Online Review staging preflight failed unexpectedly.',
        isRetryable: false,
        source: 'unknown',
      );
    }

    if (!response.isSuccessStatusCode) {
      return _failureResult(
        status: OnlineReviewStagingPreflightStatus.failed,
        code: OnlineReviewStagingPreflightFailureCode.httpStatus,
        message:
            'Online Review staging preflight failed '
            '(HTTP ${response.statusCode}).',
        isRetryable: _isRetryableStatus(response.statusCode),
        source: 'http',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      return _failureResult(
        status: OnlineReviewStagingPreflightStatus.failed,
        code: OnlineReviewStagingPreflightFailureCode.invalidJson,
        message: 'Online Review staging preflight response was not JSON.',
        isRetryable: false,
        source: 'parsing',
      );
    }

    if (decoded is! Map) {
      return _contractMismatch();
    }

    return _resultFromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  Uri _endpointUri() {
    return _baseUri.replace(
      pathSegments: [
        ..._baseUri.pathSegments.where((segment) => segment.isNotEmpty),
        'analysis',
        'dev',
        'online-review-product',
        'preflight',
      ],
    );
  }

  Map<String, Object?> _requestBody(
    OnlineReviewStagingBackendReadiness readiness,
  ) {
    return {
      'contractVersion': onlineReviewStagingPreflightContractVersion,
      'mode': readiness.runtimeMode.name,
      'readinessVersion': readiness.version,
    };
  }
}

OnlineReviewStagingPreflightResult onlineReviewStagingPreflightReadinessGate(
  OnlineReviewStagingBackendReadiness readiness,
) {
  if (readiness.status == OnlineReviewStagingReadinessStatus.disabled) {
    return _failureResult(
      status: OnlineReviewStagingPreflightStatus.disabled,
      code: OnlineReviewStagingPreflightFailureCode.readinessNotReady,
      message: 'Online Review staging preflight is disabled.',
      isRetryable: false,
      source: 'readiness',
    );
  }
  if (!readiness.hasBaseUri) {
    return _failureResult(
      status: OnlineReviewStagingPreflightStatus.notReady,
      code: OnlineReviewStagingPreflightFailureCode.missingBaseUri,
      message: 'Online Review staging preflight requires a base URI.',
      isRetryable: false,
      source: 'readiness',
    );
  }
  if (!readiness.canUseHttp) {
    return _failureResult(
      status: OnlineReviewStagingPreflightStatus.notReady,
      code: OnlineReviewStagingPreflightFailureCode.httpNotAllowed,
      message: 'Online Review staging preflight requires the HTTP gate.',
      isRetryable: false,
      source: 'readiness',
    );
  }
  if (!readiness.smokeReportAllPassed ||
      !readiness.smokeReportHardSafetyPassed ||
      readiness.blockers.contains(
        OnlineReviewStagingReadinessBlocker.smokeReportFailed,
      ) ||
      readiness.blockers.contains(
        OnlineReviewStagingReadinessBlocker.hardSafetyFailed,
      )) {
    return _failureResult(
      status: OnlineReviewStagingPreflightStatus.blocked,
      code: OnlineReviewStagingPreflightFailureCode.smokeReportFailed,
      message: 'Online Review staging preflight requires passing smoke checks.',
      isRetryable: false,
      source: 'readiness',
    );
  }
  if (readiness.blockers.contains(
        OnlineReviewStagingReadinessBlocker.unsafeBaseUri,
      ) ||
      readiness.blockers.contains(
        OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed,
      ) ||
      readiness.blockers.contains(
        OnlineReviewStagingReadinessBlocker.realUrlNotAllowedInThisPhase,
      )) {
    return _failureResult(
      status: OnlineReviewStagingPreflightStatus.blocked,
      code: OnlineReviewStagingPreflightFailureCode.unsafeBaseUri,
      message: 'Online Review staging preflight requires a safe base URI.',
      isRetryable: false,
      source: 'readiness',
    );
  }
  if (!readiness.isStagingReady && !readiness.isInternalTesterReady) {
    return _failureResult(
      status: OnlineReviewStagingPreflightStatus.blocked,
      code: OnlineReviewStagingPreflightFailureCode.readinessNotReady,
      message:
          'Online Review staging preflight requires staging or internal '
          'tester readiness.',
      isRetryable: false,
      source: 'readiness',
    );
  }

  return const OnlineReviewStagingPreflightResult(
    status: OnlineReviewStagingPreflightStatus.readyToAttempt,
  );
}

OnlineReviewStagingPreflightResult _resultFromJson(Map<String, Object?> json) {
  final contractVersion = json['contractVersion'];
  final ok = json['ok'];
  final supportedProductContract = json['supportedProductContract'];
  final warnings = json['warnings'];

  if (contractVersion != onlineReviewStagingPreflightContractVersion ||
      supportedProductContract !=
          onlineReviewStagingPreflightSupportedProductContract ||
      ok is! bool ||
      (warnings != null &&
          (warnings is! List ||
              warnings.any((warning) => warning is! String)))) {
    return _contractMismatch();
  }
  final parsedWarnings = warnings == null
      ? const <String>[]
      : (warnings as List).cast<String>();

  final response = OnlineReviewStagingPreflightResponse(
    contractVersion: contractVersion.toString(),
    status: ok
        ? OnlineReviewStagingPreflightStatus.success
        : OnlineReviewStagingPreflightStatus.failed,
    ok: ok,
    backendName: _nullableString(json['backendName']),
    backendVersion: _nullableString(json['backendVersion']),
    supportedProductContract: supportedProductContract.toString(),
    serverTime: _nullableString(json['serverTime']),
    warnings: parsedWarnings,
  );

  if (!ok) {
    return OnlineReviewStagingPreflightResult(
      status: OnlineReviewStagingPreflightStatus.failed,
      response: response,
      failure: const OnlineReviewStagingPreflightFailure(
        code: OnlineReviewStagingPreflightFailureCode.unexpected,
        message:
            'Online Review staging preflight backend reported unavailable.',
        isRetryable: false,
        source: 'backend',
      ),
    );
  }

  return OnlineReviewStagingPreflightResult(
    status: OnlineReviewStagingPreflightStatus.success,
    response: response,
  );
}

OnlineReviewStagingPreflightResult _contractMismatch() {
  return _failureResult(
    status: OnlineReviewStagingPreflightStatus.failed,
    code: OnlineReviewStagingPreflightFailureCode.contractMismatch,
    message: 'Online Review staging preflight response did not match contract.',
    isRetryable: false,
    source: 'contract',
  );
}

OnlineReviewStagingPreflightResult _failureResult({
  required OnlineReviewStagingPreflightStatus status,
  required OnlineReviewStagingPreflightFailureCode code,
  required String message,
  required bool isRetryable,
  required String source,
}) {
  return OnlineReviewStagingPreflightResult(
    status: status,
    failure: OnlineReviewStagingPreflightFailure(
      code: code,
      message: message,
      isRetryable: isRetryable,
      source: source,
    ),
  );
}

String? _nullableString(Object? value) {
  return value is String && value.trim().isNotEmpty ? value : null;
}

bool _isRetryableStatus(int statusCode) {
  return statusCode == 408 || statusCode == 429 || statusCode >= 500;
}
