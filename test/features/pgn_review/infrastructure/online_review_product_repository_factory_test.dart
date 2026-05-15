import 'dart:io';

import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/http_online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixture_online_review_product_repository.dart';

void main() {
  const request = ApexOnlineReviewRequest(
    pgn: '1. e4 *',
    mode: ApexOnlineReviewMode.onlineFast,
  );

  group('OnlineReviewRepositoryFactory selection', () {
    test(
      'disabled mode is the conservative default and never calls HTTP',
      () async {
        final client = _RecordingHttpClient(
          (_, _, _, _) async =>
              _fixtureResponse('success/success_fast_minimal.json'),
        );
        final repository = OnlineReviewRepositoryFactory.create(
          OnlineReviewRepositoryConfig.disabled(),
          httpClient: client,
        );

        final result = await repository.analyze(request);

        expect(repository, isA<DisabledOnlineReviewProductRepository>());
        expect(result.isSuccess, isFalse);
        expect(result.failure!.code, 'onlineReviewDisabled');
        expect(result.failure!.source, 'disabled');
        expect(result.failure!.isRetryable, isFalse);
        expect(client.calls, 0);
      },
    );

    test(
      'http mode with an explicit baseUri uses the injected client',
      () async {
        final client = _RecordingHttpClient(
          (_, _, _, _) async =>
              _fixtureResponse('success/success_fast_minimal.json'),
        );
        final repository = OnlineReviewRepositoryFactory.create(
          OnlineReviewRepositoryConfig.http(
            baseUri: Uri.parse('https://example.test'),
            timeout: const Duration(seconds: 4),
            extraHeaders: const {'X-Test': 'factory'},
          ),
          httpClient: client,
        );

        final result = await repository.analyze(request);

        expect(repository, isA<HttpOnlineReviewProductRepository>());
        expect(result.isSuccess, isTrue);
        expect(result.review, isA<ApexOnlineReview>());
        expect(client.calls, 1);
        expect(
          client.lastUri,
          Uri.parse('https://example.test/analysis/dev/online-review-product'),
        );
        expect(client.lastTimeout, const Duration(seconds: 4));
        expect(client.lastHeaders!['X-Test'], 'factory');
      },
    );

    test(
      'http mode without a baseUri degrades safely without network',
      () async {
        final client = _RecordingHttpClient(
          (_, _, _, _) async =>
              _fixtureResponse('success/success_fast_minimal.json'),
        );
        final repository = OnlineReviewRepositoryFactory.create(
          OnlineReviewRepositoryConfig.http(baseUri: null),
          httpClient: client,
        );

        final result = await repository.analyze(request);

        expect(repository, isA<DisabledOnlineReviewProductRepository>());
        expect(result.failure!.code, 'onlineReviewHttpNotConfigured');
        expect(result.failure!.source, 'disabled');
        expect(client.calls, 0);
      },
    );

    test(
      'fixture mode is explicit and supplied by test-only builder',
      () async {
        final repository = OnlineReviewRepositoryFactory.create(
          OnlineReviewRepositoryConfig.fixture(),
          fixtureBuilder: (adapter) =>
              FixtureOnlineReviewProductRepository(adapter: adapter),
        );

        final result = await repository.analyze(request);

        expect(repository, isA<FixtureOnlineReviewProductRepository>());
        expect(result.isSuccess, isTrue);
        expect(result.review!.mode, ApexOnlineReviewMode.onlineFast);
      },
    );

    test('fixture mode without a builder stays disabled by default', () async {
      final repository = OnlineReviewRepositoryFactory.create(
        OnlineReviewRepositoryConfig.fixture(),
      );

      final result = await repository.analyze(request);

      expect(repository, isA<DisabledOnlineReviewProductRepository>());
      expect(result.failure!.code, 'onlineReviewFixtureNotConfigured');
      expect(result.failure!.source, 'disabled');
    });
  });

  group('OnlineReviewRepositoryConfig safety', () {
    test('copies headers defensively and preserves timeout', () {
      final headers = {'X-Test': 'before'};
      final config = OnlineReviewRepositoryConfig.http(
        baseUri: Uri.parse('https://example.test'),
        timeout: const Duration(seconds: 6),
        extraHeaders: headers,
      );

      headers['X-Test'] = 'after';

      expect(config.mode, OnlineReviewRepositoryMode.http);
      expect(config.baseUri, Uri.parse('https://example.test'));
      expect(config.timeout, const Duration(seconds: 6));
      expect(config.extraHeaders, {'X-Test': 'before'});
      expect(
        () => config.extraHeaders['X-New'] = 'blocked',
        throwsUnsupportedError,
      );
    });

    test('selection behavior is deterministic for the same config', () {
      final config = OnlineReviewRepositoryConfig.http(
        baseUri: Uri.parse('https://example.test'),
      );
      final first = OnlineReviewRepositoryFactory.create(
        config,
        httpClient: _RecordingHttpClient(_neverCalled),
      );
      final second = OnlineReviewRepositoryFactory.create(
        config,
        httpClient: _RecordingHttpClient(_neverCalled),
      );

      expect(first.runtimeType, second.runtimeType);
      expect(config.mode, OnlineReviewRepositoryMode.http);
    });
  });

  group('OnlineReviewRepositoryFactory boundaries', () {
    test('factory stays UI-free, DTO-free, and backend-path free', () {
      final source = File(
        'lib/features/pgn_review/infrastructure/'
        'online_review_product_repository_factory.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('flutter_riverpod')));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('C:\\apex_chess_backend')));
    });

    test(
      'app provider graph does not activate the new repository boundary yet',
      () {
        final providers = File('lib/app/di/providers.dart').readAsStringSync();

        expect(
          providers,
          isNot(contains('online_review_product_repository_factory')),
        );
        expect(
          providers,
          isNot(contains('http_online_review_product_repository.dart')),
        );
      },
    );
  });
}

Future<ApexHttpResponse> _neverCalled(
  Uri uri,
  Map<String, Object?> body,
  Map<String, String>? headers,
  Duration? timeout,
) {
  throw StateError('This fake HTTP client should not be called');
}

class _RecordingHttpClient extends ApexHttpClient {
  _RecordingHttpClient(this._handler);

  final Future<ApexHttpResponse> Function(
    Uri uri,
    Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  )
  _handler;

  int calls = 0;
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
    calls++;
    lastUri = uri;
    lastBody = Map.unmodifiable(body);
    lastHeaders = headers == null ? null : Map.unmodifiable(headers);
    lastTimeout = timeout;
    return _handler(uri, body, headers, timeout);
  }
}

const _fixtureRoot = 'test/fixtures/online_review_product';

ApexHttpResponse _fixtureResponse(String path) {
  return ApexHttpResponse(
    statusCode: 200,
    body: File('$_fixtureRoot/$path').readAsStringSync(),
  );
}
