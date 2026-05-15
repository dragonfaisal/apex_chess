import 'dart:async';
import 'dart:io';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_controller.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_use_case.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewProductController state', () {
    test('starts idle with no result or failure', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(onlineReviewProductControllerProvider);

      expect(state.status, OnlineReviewProductControllerStatus.idle);
      expect(state.review, isNull);
      expect(state.failure, isNull);
      expect(state.lastRequest, isNull);
      expect(state.isLoading, isFalse);
      expect(state.hasResult, isFalse);
      expect(state.hasFailure, isFalse);
      expect(state.canSubmit, isTrue);
      expect(state.canRetry, isFalse);
    });

    test('moves idle to loading to success and preserves request', () async {
      final request = _request();
      final review = _review(mode: request.mode);
      final repository = _PendingRepository();
      final container = _containerFor(
        OnlineReviewProductUseCase(repository: repository),
      );
      addTearDown(container.dispose);
      final controller = container.read(
        onlineReviewProductControllerProvider.notifier,
      );

      final future = controller.submit(request);
      await Future<void>.delayed(Duration.zero);

      final loading = container.read(onlineReviewProductControllerProvider);
      expect(loading.status, OnlineReviewProductControllerStatus.loading);
      expect(loading.isLoading, isTrue);
      expect(loading.lastRequest, same(request));
      expect(loading.review, isNull);
      expect(loading.failure, isNull);

      repository.complete(ApexOnlineReviewRepositoryResult.success(review));
      await future;

      final success = container.read(onlineReviewProductControllerProvider);
      expect(success.status, OnlineReviewProductControllerStatus.success);
      expect(success.review, same(review));
      expect(success.failure, isNull);
      expect(success.lastRequest, same(request));
      expect(success.hasResult, isTrue);
      expect(success.canSubmit, isTrue);
    });

    test('maps use-case failure into controller failure state', () async {
      final request = _request();
      final failedReview = _review(
        mode: request.mode,
        status: ApexReviewStatus.failed,
        failure: const ApexReviewFailure(
          code: 'invalidPgn',
          message: 'Invalid PGN',
        ),
      );
      final repository = _RecordingRepository(
        (_) async => ApexOnlineReviewRepositoryResult.failure(
          const ApexOnlineReviewRepositoryFailure(
            code: 'invalidPgn',
            message: 'Invalid PGN',
            isRetryable: false,
            source: 'backend',
          ),
          review: failedReview,
        ),
      );
      final container = _containerFor(
        OnlineReviewProductUseCase(repository: repository),
      );
      addTearDown(container.dispose);

      await container
          .read(onlineReviewProductControllerProvider.notifier)
          .submit(request);

      final state = container.read(onlineReviewProductControllerProvider);
      expect(state.status, OnlineReviewProductControllerStatus.failure);
      expect(state.review, same(failedReview));
      expect(state.failure!.code, 'invalidPgn');
      expect(state.failure!.message, 'Invalid PGN');
      expect(state.failure!.source, 'backend');
      expect(state.lastRequest, same(request));
      expect(state.hasFailure, isTrue);
      expect(state.canRetry, isFalse);
    });

    test(
      'blank PGN ends in validation failure without repository call',
      () async {
        final repository = _RecordingRepository(
          (_) async => ApexOnlineReviewRepositoryResult.success(
            _review(mode: ApexOnlineReviewMode.onlineFast),
          ),
        );
        final container = _containerFor(
          OnlineReviewProductUseCase(repository: repository),
        );
        addTearDown(container.dispose);

        await container
            .read(onlineReviewProductControllerProvider.notifier)
            .submit(
              ApexOnlineReviewRequest(
                pgn: '   ',
                mode: ApexOnlineReviewMode.onlineFast,
              ),
            );

        final state = container.read(onlineReviewProductControllerProvider);
        expect(repository.calls, 0);
        expect(state.status, OnlineReviewProductControllerStatus.failure);
        expect(state.failure!.code, 'emptyPgn');
        expect(state.failure!.source, 'validation');
        expect(state.failure!.validation, isTrue);
        expect(state.canRetry, isFalse);
      },
    );

    test(
      'retry readiness only follows retryable failures with requests',
      () async {
        final retryableContainer = _containerFor(
          OnlineReviewProductUseCase(
            repository: _RecordingRepository(
              (_) async => const ApexOnlineReviewRepositoryResult.failure(
                ApexOnlineReviewRepositoryFailure(
                  code: 'timeout',
                  message: 'Request timed out',
                  isRetryable: true,
                  source: 'network',
                ),
              ),
            ),
          ),
        );
        addTearDown(retryableContainer.dispose);

        await retryableContainer
            .read(onlineReviewProductControllerProvider.notifier)
            .submit(_request());

        final retryable = retryableContainer.read(
          onlineReviewProductControllerProvider,
        );
        expect(retryable.canRetry, isTrue);
        expect(retryable.lastRequest, isNotNull);

        final validationContainer = _containerFor(
          OnlineReviewProductUseCase(
            repository: _RecordingRepository(
              (_) async => ApexOnlineReviewRepositoryResult.success(
                _review(mode: ApexOnlineReviewMode.onlineFast),
              ),
            ),
          ),
        );
        addTearDown(validationContainer.dispose);

        await validationContainer
            .read(onlineReviewProductControllerProvider.notifier)
            .submit(
              ApexOnlineReviewRequest(
                pgn: '',
                mode: ApexOnlineReviewMode.onlineFast,
              ),
            );

        expect(
          validationContainer
              .read(onlineReviewProductControllerProvider)
              .canRetry,
          isFalse,
        );
      },
    );
  });

  group('OnlineReviewProductController lifecycle', () {
    test('reset clears both success and failure states', () async {
      final successContainer = _containerFor(
        OnlineReviewProductUseCase(
          repository: _RecordingRepository(
            (_) async => ApexOnlineReviewRepositoryResult.success(
              _review(mode: ApexOnlineReviewMode.onlineFast),
            ),
          ),
        ),
      );
      addTearDown(successContainer.dispose);
      final successController = successContainer.read(
        onlineReviewProductControllerProvider.notifier,
      );
      await successController.submit(_request());
      successController.reset();
      expect(
        successContainer.read(onlineReviewProductControllerProvider).status,
        OnlineReviewProductControllerStatus.idle,
      );

      final failureContainer = _containerFor(
        OnlineReviewProductUseCase(
          repository: _RecordingRepository(
            (_) async => const ApexOnlineReviewRepositoryResult.failure(
              ApexOnlineReviewRepositoryFailure(
                code: 'timeout',
                message: 'Request timed out',
                isRetryable: true,
                source: 'network',
              ),
            ),
          ),
        ),
      );
      addTearDown(failureContainer.dispose);
      final failureController = failureContainer.read(
        onlineReviewProductControllerProvider.notifier,
      );
      await failureController.submit(_request());
      failureController.reset();
      expect(
        failureContainer.read(onlineReviewProductControllerProvider).status,
        OnlineReviewProductControllerStatus.idle,
      );
    });

    test(
      'reset during loading discards late results deterministically',
      () async {
        final request = _request();
        final repository = _PendingRepository();
        final container = _containerFor(
          OnlineReviewProductUseCase(repository: repository),
        );
        addTearDown(container.dispose);
        final controller = container.read(
          onlineReviewProductControllerProvider.notifier,
        );

        final future = controller.submit(request);
        await Future<void>.delayed(Duration.zero);
        controller.reset();

        repository.complete(
          ApexOnlineReviewRepositoryResult.success(_review(mode: request.mode)),
        );
        await future;

        final state = container.read(onlineReviewProductControllerProvider);
        expect(state.status, OnlineReviewProductControllerStatus.idle);
        expect(state.review, isNull);
        expect(state.failure, isNull);
        expect(state.lastRequest, isNull);
      },
    );

    test('duplicate submit while loading is ignored', () async {
      final firstRequest = _request();
      final secondRequest = _request(
        pgn: '1. d4 *',
        mode: ApexOnlineReviewMode.onlineDeep,
      );
      final repository = _PendingRepository();
      final container = _containerFor(
        OnlineReviewProductUseCase(repository: repository),
      );
      addTearDown(container.dispose);
      final controller = container.read(
        onlineReviewProductControllerProvider.notifier,
      );

      final first = controller.submit(firstRequest);
      await Future<void>.delayed(Duration.zero);
      await controller.submit(secondRequest);

      expect(repository.calls, 1);
      expect(
        container.read(onlineReviewProductControllerProvider).lastRequest,
        same(firstRequest),
      );

      repository.complete(
        ApexOnlineReviewRepositoryResult.success(
          _review(mode: firstRequest.mode),
        ),
      );
      await first;

      final state = container.read(onlineReviewProductControllerProvider);
      expect(state.status, OnlineReviewProductControllerStatus.success);
      expect(state.lastRequest, same(firstRequest));
      expect(state.review!.mode, ApexOnlineReviewMode.onlineFast);
    });

    test('controller catches unexpected use-case throws safely', () async {
      final container = ProviderContainer(
        overrides: [
          onlineReviewProductUseCaseProvider.overrideWithValue(
            const _ThrowingUseCase(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(onlineReviewProductControllerProvider.notifier)
          .submit(_request());

      final state = container.read(onlineReviewProductControllerProvider);
      expect(state.status, OnlineReviewProductControllerStatus.failure);
      expect(state.failure!.code, 'onlineReviewControllerUnexpectedError');
      expect(state.failure!.source, 'unknown');
      expect(state.failure!.isRetryable, isFalse);
    });
  });

  group('OnlineReviewProductController provider behavior', () {
    test('default DI path resolves disabled failure without HTTP', () async {
      final httpClient = _RecordingHttpClient();
      final container = ProviderContainer(
        overrides: [
          onlineReviewProductHttpClientProvider.overrideWithValue(httpClient),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(onlineReviewProductControllerProvider.notifier)
          .submit(_request());

      final state = container.read(onlineReviewProductControllerProvider);
      expect(state.status, OnlineReviewProductControllerStatus.failure);
      expect(state.failure!.code, 'onlineReviewDisabled');
      expect(state.failure!.source, 'disabled');
      expect(httpClient.calls, 0);
    });

    test('use-case provider override can drive success and failure', () async {
      final successContainer = _containerFor(
        OnlineReviewProductUseCase(
          repository: _RecordingRepository(
            (_) async => ApexOnlineReviewRepositoryResult.success(
              _review(mode: ApexOnlineReviewMode.onlineFast),
            ),
          ),
        ),
      );
      addTearDown(successContainer.dispose);

      await successContainer
          .read(onlineReviewProductControllerProvider.notifier)
          .submit(_request());
      expect(
        successContainer.read(onlineReviewProductControllerProvider).status,
        OnlineReviewProductControllerStatus.success,
      );

      final failureContainer = _containerFor(
        OnlineReviewProductUseCase(
          repository: _RecordingRepository(
            (_) async => const ApexOnlineReviewRepositoryResult.failure(
              ApexOnlineReviewRepositoryFailure(
                code: 'networkError',
                message: 'Network unavailable',
                isRetryable: true,
                source: 'network',
              ),
            ),
          ),
        ),
      );
      addTearDown(failureContainer.dispose);

      await failureContainer
          .read(onlineReviewProductControllerProvider.notifier)
          .submit(_request());
      expect(
        failureContainer.read(onlineReviewProductControllerProvider).status,
        OnlineReviewProductControllerStatus.failure,
      );
      expect(
        failureContainer
            .read(onlineReviewProductControllerProvider)
            .failure!
            .code,
        'networkError',
      );
    });
  });

  group('OnlineReviewProductController boundaries', () {
    test(
      'controller stays DTO-free, HTTP-free, UI-free, and backend-path free',
      () {
        final source = File(
          'lib/features/pgn_review/application/online_review_product_controller.dart',
        ).readAsStringSync();

        expect(source, contains('OnlineReviewProductControllerState'));
        expect(source, contains('NotifierProvider'));
        expect(source, isNot(contains('OnlineReviewProductResponseDto')));
        expect(source, isNot(contains('online_review_product_dto.dart')));
        expect(source, isNot(contains('apex_http_client.dart')));
        expect(source, isNot(contains('package:http')));
        expect(source, isNot(contains('package:dio')));
        expect(source, isNot(contains('package:flutter/material.dart')));
        expect(source, isNot(contains('package:flutter/widgets.dart')));
        expect(source, isNot(contains('C:\\apex_chess_backend')));
      },
    );

    test('active review pipeline does not consume the controller seam yet', () {
      final providers = File('lib/app/di/providers.dart').readAsStringSync();
      final pipelineStart = providers.indexOf(
        'final reviewAnalysisPipelineProvider',
      );
      final pipelineSource = providers.substring(pipelineStart);

      expect(
        pipelineSource,
        isNot(contains('onlineReviewProductControllerProvider')),
      );
      expect(pipelineSource, contains('LocalOfflineReviewProvider'));
    });
  });
}

ProviderContainer _containerFor(OnlineReviewProductUseCase useCase) {
  return ProviderContainer(
    overrides: [onlineReviewProductUseCaseProvider.overrideWithValue(useCase)],
  );
}

ApexOnlineReviewRequest _request({
  String pgn = '1. e4 *',
  ApexOnlineReviewMode mode = ApexOnlineReviewMode.onlineFast,
}) {
  return ApexOnlineReviewRequest(pgn: pgn, mode: mode);
}

class _RecordingRepository implements OnlineReviewProductRepository {
  _RecordingRepository(this._handler);

  final Future<ApexOnlineReviewRepositoryResult> Function(
    ApexOnlineReviewRequest request,
  )
  _handler;

  int calls = 0;

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) {
    calls++;
    return _handler(request);
  }
}

class _PendingRepository implements OnlineReviewProductRepository {
  final _completer = Completer<ApexOnlineReviewRepositoryResult>();

  int calls = 0;

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) {
    calls++;
    return _completer.future;
  }

  void complete(ApexOnlineReviewRepositoryResult result) {
    _completer.complete(result);
  }
}

class _ThrowingUseCase extends OnlineReviewProductUseCase {
  const _ThrowingUseCase() : super(repository: const _NoopRepository());

  @override
  Future<OnlineReviewProductUseCaseResult> analyze(
    ApexOnlineReviewRequest request,
  ) async {
    throw StateError('boom');
  }
}

class _NoopRepository implements OnlineReviewProductRepository {
  const _NoopRepository();

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) async {
    return const ApexOnlineReviewRepositoryResult.failure(
      ApexOnlineReviewRepositoryFailure(
        code: 'unused',
        message: 'unused',
        isRetryable: false,
        source: 'test',
      ),
    );
  }
}

class _RecordingHttpClient extends ApexHttpClient {
  int calls = 0;

  @override
  Future<ApexHttpResponse> postJson(
    Uri uri, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    calls++;
    return const ApexHttpResponse(statusCode: 500, body: '{}');
  }
}

ApexOnlineReview _review({
  required ApexOnlineReviewMode mode,
  ApexReviewStatus status = ApexReviewStatus.completed,
  ApexReviewFailure? failure,
}) {
  return ApexOnlineReview(
    contractVersion: 'online-review-product-v1',
    mode: mode,
    status: status,
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
      mode: mode,
      targetDepthTier: 'test',
      isExecutionHintOnly: true,
    ),
    failure: failure,
  );
}
