import 'dart:io';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_use_case.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_adapter.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const request = ApexOnlineReviewRequest(
    pgn: '1. e4 *',
    mode: ApexOnlineReviewMode.onlineFast,
  );

  group('Online Review product repository providers', () {
    test(
      'default graph resolves disabled repository without touching HTTP',
      () async {
        final client = _RecordingHttpClient(
          (_, _, _, _) async =>
              _fixtureResponse('success/success_fast_minimal.json'),
        );
        final container = ProviderContainer(
          overrides: [
            onlineReviewProductHttpClientProvider.overrideWithValue(client),
          ],
        );
        addTearDown(container.dispose);

        final repository = container.read(
          onlineReviewProductRepositoryProvider,
        );
        final result = await repository.analyze(request);

        expect(repository, isA<OnlineReviewProductRepository>());
        expect(result.isSuccess, isFalse);
        expect(result.failure!.code, 'onlineReviewDisabled');
        expect(result.failure!.source, 'disabled');
        expect(client.calls, 0);
      },
    );

    test(
      'explicit HTTP override uses fake client and explicit baseUri',
      () async {
        final client = _RecordingHttpClient(
          (_, _, _, _) async =>
              _fixtureResponse('success/success_fast_minimal.json'),
        );
        final container = ProviderContainer(
          overrides: [
            onlineReviewRepositoryConfigProvider.overrideWithValue(
              OnlineReviewRepositoryConfig.http(
                baseUri: Uri.parse('https://example.test'),
              ),
            ),
            onlineReviewProductHttpClientProvider.overrideWithValue(client),
          ],
        );
        addTearDown(container.dispose);

        final repository = container.read(
          onlineReviewProductRepositoryProvider,
        );
        final result = await repository.analyze(request);

        expect(result.isSuccess, isTrue);
        expect(result.review, isA<ApexOnlineReview>());
        expect(client.calls, 1);
        expect(
          client.lastUri,
          Uri.parse('https://example.test/analysis/dev/online-review-product'),
        );
      },
    );

    test('HTTP override without baseUri stays safely disabled', () async {
      final client = _RecordingHttpClient(
        (_, _, _, _) async =>
            _fixtureResponse('success/success_fast_minimal.json'),
      );
      final container = ProviderContainer(
        overrides: [
          onlineReviewRepositoryConfigProvider.overrideWithValue(
            OnlineReviewRepositoryConfig.http(baseUri: null),
          ),
          onlineReviewProductHttpClientProvider.overrideWithValue(client),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(onlineReviewProductRepositoryProvider);
      final result = await repository.analyze(request);

      expect(result.isSuccess, isFalse);
      expect(result.failure!.code, 'onlineReviewHttpNotConfigured');
      expect(result.failure!.source, 'disabled');
      expect(client.calls, 0);
    });

    test('repository provider can be overridden directly', () async {
      final container = ProviderContainer(
        overrides: [
          onlineReviewProductRepositoryProvider.overrideWithValue(
            const _FakeOnlineReviewProductRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(onlineReviewProductRepositoryProvider)
          .analyze(request);

      expect(result.isSuccess, isTrue);
      expect(result.review!.mode, ApexOnlineReviewMode.onlineFast);
      expect(result.review!.summary.totalPlies, 0);
    });

    test('adapter and HTTP client providers are overrideable', () async {
      final adapter = const OnlineReviewProductAdapter();
      final client = _RecordingHttpClient(
        (_, _, _, _) async =>
            _fixtureResponse('success/success_fast_minimal.json'),
      );
      final container = ProviderContainer(
        overrides: [
          onlineReviewRepositoryConfigProvider.overrideWithValue(
            OnlineReviewRepositoryConfig.http(
              baseUri: Uri.parse('https://example.test'),
            ),
          ),
          onlineReviewProductAdapterProvider.overrideWithValue(adapter),
          onlineReviewProductHttpClientProvider.overrideWithValue(client),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(onlineReviewProductRepositoryProvider)
          .analyze(request);

      expect(container.read(onlineReviewProductAdapterProvider), same(adapter));
      expect(
        container.read(onlineReviewProductHttpClientProvider),
        same(client),
      );
      expect(result.isSuccess, isTrue);
    });
  });

  group('Online Review product use-case provider', () {
    test('default graph resolves disabled use-case behavior', () async {
      final client = _RecordingHttpClient(
        (_, _, _, _) async =>
            _fixtureResponse('success/success_fast_minimal.json'),
      );
      final container = ProviderContainer(
        overrides: [
          onlineReviewProductHttpClientProvider.overrideWithValue(client),
        ],
      );
      addTearDown(container.dispose);

      final useCase = container.read(onlineReviewProductUseCaseProvider);
      final result = await useCase.analyze(request);

      expect(useCase, isA<OnlineReviewProductUseCase>());
      expect(result.isFailure, isTrue);
      expect(result.failure!.code, 'onlineReviewDisabled');
      expect(result.failure!.source, 'disabled');
      expect(client.calls, 0);
    });

    test('repository override flows through the use-case provider', () async {
      final container = ProviderContainer(
        overrides: [
          onlineReviewProductRepositoryProvider.overrideWithValue(
            const _FakeOnlineReviewProductRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(onlineReviewProductUseCaseProvider)
          .analyze(request);

      expect(result.isSuccess, isTrue);
      expect(result.review!.mode, ApexOnlineReviewMode.onlineFast);
      expect(result.review!.summary.totalPlies, 0);
    });
  });

  group('Provider registration boundaries', () {
    test('DI file stays UI-free, backend-path free, and domain-facing', () {
      final source = File('lib/app/di/providers.dart').readAsStringSync();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('C:\\apex_chess_backend')));
      expect(source, contains('onlineReviewProductRepositoryProvider'));
      expect(source, contains('onlineReviewProductUseCaseProvider'));
      expect(source, contains('Provider<OnlineReviewProductRepository>'));
      expect(source, contains('Provider<OnlineReviewProductUseCase>'));
      expect(
        source,
        isNot(contains('Provider<OnlineReviewProductResponseDto>')),
      );
    });

    test(
      'existing review pipeline does not consume the new product seam yet',
      () {
        final source = File('lib/app/di/providers.dart').readAsStringSync();
        final pipelineStart = source.indexOf(
          'final reviewAnalysisPipelineProvider',
        );
        final pipelineSource = source.substring(pipelineStart);

        expect(
          pipelineSource,
          isNot(contains('onlineReviewProductRepositoryProvider')),
        );
        expect(
          pipelineSource,
          isNot(contains('onlineReviewProductUseCaseProvider')),
        );
        expect(pipelineSource, contains('LocalOfflineReviewProvider'));
      },
    );
  });
}

class _FakeOnlineReviewProductRepository
    implements OnlineReviewProductRepository {
  const _FakeOnlineReviewProductRepository();

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) async {
    return ApexOnlineReviewRepositoryResult.success(
      ApexOnlineReview(
        contractVersion: 'online-review-product-v1',
        mode: request.mode,
        status: ApexReviewStatus.completed,
        summary: ApexOnlineReviewSummary(
          totalPlies: 0,
          analyzedMoves: 0,
          failedMoves: 0,
          qualityCounts: const {},
          bestMoveCount: 0,
          inaccuracyCount: 0,
          mistakeCount: 0,
          blunderCount: 0,
          criticalMoveCount: 0,
        ),
        moves: const [],
        providerInfo: ApexReviewProviderInfo(
          provider: 'fake',
          engine: 'none',
          analysisVersion: 'test',
          classifierVersion: 'test',
          productContractVersion: 'online-review-product-v1',
          mode: request.mode,
          targetDepthTier: 'test',
          isExecutionHintOnly: true,
        ),
      ),
    );
  }
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

  @override
  Future<ApexHttpResponse> postJson(
    Uri uri, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    calls++;
    lastUri = uri;
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
