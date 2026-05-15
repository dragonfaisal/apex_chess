/// HTTP implementation of the Online Review product repository boundary.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/core/network/api_headers.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_adapter.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_dto.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';

class HttpOnlineReviewProductRepository
    implements OnlineReviewProductRepository {
  HttpOnlineReviewProductRepository({
    required Uri baseUri,
    required ApexHttpClient httpClient,
    OnlineReviewProductAdapter adapter = const OnlineReviewProductAdapter(),
    this.timeout = const Duration(seconds: 10),
    Map<String, String> headers = const {},
  }) : _baseUri = baseUri,
       _httpClient = httpClient,
       _adapter = adapter,
       _headers = Map.unmodifiable({
         ...apexJsonHeaders,
         'Content-Type': 'application/json',
         ...headers,
       });

  final Uri _baseUri;
  final ApexHttpClient _httpClient;
  final OnlineReviewProductAdapter _adapter;
  final Duration timeout;
  final Map<String, String> _headers;

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) async {
    late final ApexHttpResponse response;
    try {
      response = await _httpClient.postJson(
        _endpointUri(),
        body: _requestBody(request),
        headers: _headers,
        timeout: timeout,
      );
    } on TimeoutException {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'timeout',
          message: 'Online review request timed out',
          isRetryable: true,
          source: 'network',
        ),
      );
    } on ApexHttpNetworkException {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'networkError',
          message: 'Online review request could not reach the server',
          isRetryable: true,
          source: 'network',
        ),
      );
    } on SocketException {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'networkError',
          message: 'Online review request could not reach the server',
          isRetryable: true,
          source: 'network',
        ),
      );
    } catch (_) {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'unknown',
          message: 'Online review request failed unexpectedly',
          isRetryable: false,
          source: 'unknown',
        ),
      );
    }

    if (!response.isSuccessStatusCode) {
      return ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'httpStatus',
          message: 'Online review request failed (HTTP ${response.statusCode})',
          isRetryable: _isRetryableStatus(response.statusCode),
          source: 'http',
        ),
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'invalidJson',
          message: 'Online review response was not valid JSON',
          isRetryable: false,
          source: 'parsing',
        ),
      );
    }

    if (decoded is! Map) {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'contractParseError',
          message: 'Online review response did not match the contract',
          isRetryable: false,
          source: 'parsing',
        ),
      );
    }

    try {
      final dto = OnlineReviewProductResponseDto.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
      final review = _adapter.fromDto(dto);
      if (dto.isFailure || review.failure != null) {
        final failure = review.failure;
        return ApexOnlineReviewRepositoryResult.failure(
          ApexOnlineReviewRepositoryFailure(
            code: failure?.code ?? 'onlineReviewFailed',
            message: failure?.message ?? 'Online review failed',
            isRetryable: false,
            source: 'backend',
          ),
          review: review,
        );
      }
      return ApexOnlineReviewRepositoryResult.success(review);
    } on FormatException {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'contractParseError',
          message: 'Online review response did not match the contract',
          isRetryable: false,
          source: 'parsing',
        ),
      );
    } catch (_) {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'unknown',
          message: 'Online review response failed unexpectedly',
          isRetryable: false,
          source: 'unknown',
        ),
      );
    }
  }

  Map<String, Object?> _requestBody(ApexOnlineReviewRequest request) {
    return {
      'pgn': request.pgn,
      'mode': request.mode.wire,
      if (request.requestedDepth != null) 'depth': request.requestedDepth,
      if (request.requestedMultiPv != null) 'multipv': request.requestedMultiPv,
      if (request.maxPlies != null) 'maxPlies': request.maxPlies,
      'includeDebug': request.includeDebug,
      'movetimeMs': null,
      'stopOnError': false,
    };
  }

  Uri _endpointUri() {
    return _baseUri.replace(
      pathSegments: [
        ..._baseUri.pathSegments.where((segment) => segment.isNotEmpty),
        'analysis',
        'dev',
        'online-review-product',
      ],
    );
  }

  bool _isRetryableStatus(int statusCode) {
    return statusCode == 408 || statusCode == 429 || statusCode >= 500;
  }
}
