import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_config_scenarios.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_preflight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewStagingPreflight readiness gating', () {
    test(
      'disabled readiness returns disabled and does not call HTTP',
      () async {
        final client = _RecordingHttpClient.unused();
        final preflight = _preflight(client);

        final result = await preflight.check(
          _readiness(OnlineReviewStagingConfigScenarioId.defaultDisabled),
        );

        expect(result.status, OnlineReviewStagingPreflightStatus.disabled);
        expect(result.isSuccess, isFalse);
        expect(result.canAttemptAnalysis, isFalse);
        expect(
          result.failure!.code,
          OnlineReviewStagingPreflightFailureCode.readinessNotReady,
        );
        expect(client.callCount, 0);
      },
    );

    test('missing base URI blocks and does not call HTTP', () async {
      final client = _RecordingHttpClient.unused();
      final preflight = _preflight(client);

      final result = await preflight.check(
        _readiness(OnlineReviewStagingConfigScenarioId.stagingMissingBaseUri),
      );

      expect(result.status, OnlineReviewStagingPreflightStatus.notReady);
      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.missingBaseUri,
      );
      expect(result.canAttemptAnalysis, isFalse);
      expect(client.callCount, 0);
    });

    test('HTTP not allowed blocks and does not call HTTP', () async {
      final client = _RecordingHttpClient.unused();
      final preflight = _preflight(client);

      final result = await preflight.check(
        _readiness(OnlineReviewStagingConfigScenarioId.stagingHttpNotAllowed),
      );

      expect(result.status, OnlineReviewStagingPreflightStatus.notReady);
      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.httpNotAllowed,
      );
      expect(result.canAttemptAnalysis, isFalse);
      expect(client.callCount, 0);
    });

    test('public preview readiness blocks and does not call HTTP', () async {
      final client = _RecordingHttpClient.unused();
      final preflight = _preflight(client);

      final result = await preflight.check(
        _readiness(OnlineReviewStagingConfigScenarioId.publicPreviewBlocked),
      );

      expect(result.status, OnlineReviewStagingPreflightStatus.blocked);
      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.readinessNotReady,
      );
      expect(result.canAttemptAnalysis, isFalse);
      expect(client.callCount, 0);
    });

    test('readiness gate exposes readyToAttempt for staging/internal only', () {
      final stagingGate = onlineReviewStagingPreflightReadinessGate(
        _readiness(OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady),
      );
      final internalGate = onlineReviewStagingPreflightReadinessGate(
        _readiness(
          OnlineReviewStagingConfigScenarioId.internalTesterPlaceholderReady,
        ),
      );

      expect(
        stagingGate.status,
        OnlineReviewStagingPreflightStatus.readyToAttempt,
      );
      expect(
        internalGate.status,
        OnlineReviewStagingPreflightStatus.readyToAttempt,
      );
      expect(stagingGate.canAttemptAnalysis, isFalse);
      expect(internalGate.canAttemptAnalysis, isFalse);
    });
  });

  group('OnlineReviewStagingPreflight transport mapping', () {
    test(
      'staging placeholder-ready can attempt preflight with fake client',
      () async {
        final client = _RecordingHttpClient.success();
        final preflight = _preflight(client);

        final result = await preflight.check(
          _readiness(
            OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady,
          ),
        );

        expect(result.status, OnlineReviewStagingPreflightStatus.success);
        expect(result.isSuccess, isTrue);
        expect(result.canAttemptAnalysis, isTrue);
        expect(client.callCount, 1);
        expect(
          client.lastUri,
          Uri.parse(
            'https://staging-api.example.test/analysis/dev/'
            'online-review-product/preflight',
          ),
        );
        expect(client.lastHeaders!['Accept'], 'application/json');
        expect(client.lastHeaders!['Content-Type'], 'application/json');
        expect(
          client.lastBody!['contractVersion'],
          onlineReviewStagingPreflightContractVersion,
        );
        expect(client.lastBody!['mode'], 'staging');
        expect(client.lastBody!.keys, isNot(contains('pgn')));
        expect(client.lastBody!.keys, isNot(contains('userId')));
        expect(client.lastBody!.keys, isNot(contains('engineLine')));
      },
    );

    test('internal tester placeholder-ready can attempt preflight', () async {
      final client = _RecordingHttpClient.success();
      final preflight = _preflight(client);

      final result = await preflight.check(
        _readiness(
          OnlineReviewStagingConfigScenarioId.internalTesterPlaceholderReady,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.canAttemptAnalysis, isTrue);
      expect(client.lastBody!['mode'], 'internalTester');
    });

    test(
      'successful JSON maps to response and unlocks analysis attempt',
      () async {
        final result = await _preflight(_RecordingHttpClient.success()).check(
          _readiness(
            OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady,
          ),
        );

        expect(
          result.response!.contractVersion,
          onlineReviewStagingPreflightContractVersion,
        );
        expect(result.response!.ok, isTrue);
        expect(result.response!.backendName, 'Apex Online Review');
        expect(result.response!.backendVersion, 'test-placeholder');
        expect(
          result.response!.supportedProductContract,
          onlineReviewStagingPreflightSupportedProductContract,
        );
        expect(result.response!.serverTime, '2026-01-01T00:00:00Z');
        expect(result.response!.warnings, isEmpty);
        expect(result.failure, isNull);
        expect(result.canAttemptAnalysis, isTrue);
      },
    );

    test('supportedProductContract must match product contract', () async {
      final client = _RecordingHttpClient.withBody({
        ..._successJson(),
        'supportedProductContract': 'other-contract',
      });
      final result = await _preflight(client).check(
        _readiness(OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady),
      );

      expect(result.isSuccess, isFalse);
      expect(result.canAttemptAnalysis, isFalse);
      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.contractMismatch,
      );
    });

    test('wrong preflight contractVersion maps to contractMismatch', () async {
      final client = _RecordingHttpClient.withBody({
        ..._successJson(),
        'contractVersion': 'wrong-contract',
      });
      final result = await _preflight(client).check(
        _readiness(OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady),
      );

      expect(result.status, OnlineReviewStagingPreflightStatus.failed);
      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.contractMismatch,
      );
      expect(result.canAttemptAnalysis, isFalse);
    });

    test('ok=false maps to failed safe result', () async {
      final client = _RecordingHttpClient.withBody({
        ..._successJson(),
        'ok': false,
      });
      final result = await _preflight(client).check(
        _readiness(OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady),
      );

      expect(result.status, OnlineReviewStagingPreflightStatus.failed);
      expect(result.response!.ok, isFalse);
      expect(result.failure!.source, 'backend');
      expect(result.failure!.message, isNot(contains('pgn')));
      expect(result.canAttemptAnalysis, isFalse);
    });

    test('non-2xx maps safely without raw body leakage', () async {
      final client = _RecordingHttpClient.response(
        const ApexHttpResponse(
          statusCode: 503,
          body:
              'stack trace with token=abc pgn=1. e4 engineLine and '
              'https://staging-api.example.test/internal',
        ),
      );

      final result = await _preflight(client).check(
        _readiness(OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady),
      );

      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.httpStatus,
      );
      expect(result.failure!.isRetryable, isTrue);
      expect(result.failure!.message, contains('HTTP 503'));
      expect(result.failure!.message, isNot(contains('stack trace')));
      expect(result.failure!.message, isNot(contains('token')));
      expect(result.failure!.message, isNot(contains('pgn')));
      expect(result.failure!.message, isNot(contains('engineLine')));
      expect(result.failure!.message, isNot(contains('https://')));
    });

    test('invalid JSON maps to invalidJson', () async {
      final client = _RecordingHttpClient.response(
        const ApexHttpResponse(statusCode: 200, body: '{ not json'),
      );

      final result = await _preflight(client).check(
        _readiness(OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady),
      );

      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.invalidJson,
      );
      expect(result.failure!.source, 'parsing');
    });

    test('network exception maps to retryable networkError', () async {
      final client = _RecordingHttpClient.throwing(
        const ApexHttpNetworkException('connection refused'),
      );

      final result = await _preflight(client).check(
        _readiness(OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady),
      );

      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.networkError,
      );
      expect(result.failure!.isRetryable, isTrue);
      expect(result.failure!.source, 'network');
    });

    test('timeout maps to retryable timeout', () async {
      final client = _RecordingHttpClient.throwing(TimeoutException('slow'));

      final result = await _preflight(client).check(
        _readiness(OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady),
      );

      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.timeout,
      );
      expect(result.failure!.isRetryable, isTrue);
      expect(result.failure!.source, 'network');
    });

    test('result and failure do not store full URL details', () async {
      final result =
          await _preflight(
            _RecordingHttpClient.response(
              const ApexHttpResponse(
                statusCode: 500,
                body: 'body contains https://staging-api.example.test/private',
              ),
            ),
          ).check(
            _readiness(
              OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady,
            ),
          );
      final text = _resultText(result).toLowerCase();

      expect(text, isNot(contains('https://')));
      expect(text, isNot(contains('/private')));
      expect(text, isNot(contains('token')));
      expect(text, isNot(contains('pgn')));
      expect(text, isNot(contains('engine')));
    });
  });

  group('OnlineReviewStagingPreflight source guardrails', () {
    test('preflight source stays dormant and boundary-safe', () {
      const loopbackHost =
          'local'
          'host';
      const loopbackIp =
          '127.0.'
          '0.1';
      const emulatorHost =
          '10.0.'
          '2.2';
      const productionHostHint =
          'api.'
          'apex';
      const apiKeyHint =
          'apex_online_review_'
          'api_key';
      const privateValueToken =
          'sec'
          'ret';
      final source = _preflightSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('ProviderContainer')));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('review_draft')));
      expect(source, isNot(contains('governance')));
      expect(source, isNot(contains('reanalysis')));
      expect(source, isNot(contains(loopbackHost)));
      expect(source, isNot(contains(loopbackIp)));
      expect(source, isNot(contains(emulatorHost)));
      expect(source, isNot(contains(productionHostHint)));
      expect(source, isNot(contains(apiKeyHint)));
      expect(source.toLowerCase(), isNot(contains(privateValueToken)));
    });

    test('preflight is not registered in default app paths', () {
      final providers = File('lib/app/di/providers.dart').readAsStringSync();
      final productRepository = File(
        'lib/features/pgn_review/infrastructure/'
        'http_online_review_product_repository.dart',
      ).readAsStringSync();

      expect(providers, isNot(contains('OnlineReviewStagingPreflight')));
      expect(
        productRepository,
        isNot(contains('OnlineReviewStagingPreflight')),
      );
      expect(productRepository, isNot(contains('preflight')));
    });

    test('contract docs and PR checklist mention dormant preflight safety', () {
      final docs = File(
        'docs/ONLINE_REVIEW_FLUTTER_CONTRACT.md',
      ).readAsStringSync();
      final prTemplate = File(
        '.github/PULL_REQUEST_TEMPLATE.md',
      ).readAsStringSync();

      expect(docs, contains('### Staging transport preflight'));
      expect(docs, contains(onlineReviewStagingPreflightContractVersion));
      expect(
        docs,
        contains(onlineReviewStagingPreflightSupportedProductContract),
      );
      expect(docs, contains(onlineReviewStagingPreflightEndpointPath));
      expect(docs, contains('not called by default'));
      expect(docs, contains('fake-client tested only'));
      expect(prTemplate, contains('staging preflight transport'));
      expect(prTemplate, contains('kept default HTTP'));
      expect(prTemplate, contains('disabled'));
    });
  });
}

HttpOnlineReviewStagingPreflightClient _preflight(_RecordingHttpClient client) {
  return HttpOnlineReviewStagingPreflightClient(
    baseUri: Uri.parse('https://staging-api.example.test'),
    httpClient: client,
    timeout: const Duration(seconds: 2),
  );
}

OnlineReviewStagingBackendReadiness _readiness(
  OnlineReviewStagingConfigScenarioId id,
) {
  return buildOnlineReviewStagingReadinessReportForScenario(
    scenarioById(id),
  ).readiness;
}

Map<String, Object?> _successJson() {
  return {
    'contractVersion': onlineReviewStagingPreflightContractVersion,
    'ok': true,
    'backendName': 'Apex Online Review',
    'backendVersion': 'test-placeholder',
    'supportedProductContract':
        onlineReviewStagingPreflightSupportedProductContract,
    'serverTime': '2026-01-01T00:00:00Z',
    'warnings': <String>[],
  };
}

String _resultText(OnlineReviewStagingPreflightResult result) {
  return [
    result.status.name,
    result.response?.contractVersion,
    result.response?.backendName,
    result.response?.backendVersion,
    result.response?.supportedProductContract,
    result.response?.serverTime,
    result.response?.warnings.join(','),
    result.failure?.code.name,
    result.failure?.message,
    result.failure?.source,
  ].whereType<String>().join(' ');
}

String _preflightSource() {
  return File(
    'lib/features/pgn_review/infrastructure/'
    'online_review_staging_preflight.dart',
  ).readAsStringSync();
}

class _RecordingHttpClient extends ApexHttpClient {
  _RecordingHttpClient(this._handler);

  factory _RecordingHttpClient.unused() {
    return _RecordingHttpClient((_, _, _, _) {
      fail('HTTP client should not be called before readiness passes.');
    });
  }

  factory _RecordingHttpClient.success() {
    return _RecordingHttpClient.withBody(_successJson());
  }

  factory _RecordingHttpClient.withBody(Map<String, Object?> body) {
    return _RecordingHttpClient.response(
      ApexHttpResponse(statusCode: 200, body: jsonEncode(body)),
    );
  }

  factory _RecordingHttpClient.response(ApexHttpResponse response) {
    return _RecordingHttpClient((_, _, _, _) async => response);
  }

  factory _RecordingHttpClient.throwing(Object error) {
    return _RecordingHttpClient((_, _, _, _) async => throw error);
  }

  final Future<ApexHttpResponse> Function(
    Uri uri,
    Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  )
  _handler;

  int callCount = 0;
  Uri? lastUri;
  Map<String, Object?>? lastBody;
  Map<String, String>? lastHeaders;
  Duration? lastTimeout;

  @override
  Future<ApexHttpResponse> postJson(
    Uri uri, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    callCount += 1;
    lastUri = uri;
    lastBody = Map.unmodifiable(body);
    lastHeaders = headers == null ? null : Map.unmodifiable(headers);
    lastTimeout = timeout;
    return _handler(uri, body, headers, timeout);
  }
}
