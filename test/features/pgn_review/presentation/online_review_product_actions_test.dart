import 'dart:async';
import 'dart:io';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_controller.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_use_case.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/presentation/models/online_review_product_view_model.dart';
import 'package:apex_chess/features/pgn_review/presentation/online_review_product_actions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('onlineReviewProductActionsProvider', () {
    test('resolves from the provider graph', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(onlineReviewProductActionsProvider),
        isA<OnlineReviewProductActions>(),
      );
    });

    test('submit drives success and updates the derived view model', () async {
      final repository = _RecordingRepository(
        (_) async => ApexOnlineReviewRepositoryResult.success(
          _review(totalPlies: 1, analyzedMoves: 1),
        ),
      );
      final container = _containerFor(repository);
      addTearDown(container.dispose);

      await container
          .read(onlineReviewProductActionsProvider)
          .submit(_request());

      final state = container.read(onlineReviewProductControllerProvider);
      final viewModel = container.read(onlineReviewProductViewModelProvider);
      expect(repository.calls, 1);
      expect(state.status, OnlineReviewProductControllerStatus.success);
      expect(viewModel.status, OnlineReviewProductViewStatus.success);
      expect(viewModel.summary!.totalPlies, 1);
      expect(viewModel.showSummary, isTrue);
    });

    test(
      'submit keeps the default graph safely disabled without HTTP',
      () async {
        final httpClient = _RecordingHttpClient();
        final container = ProviderContainer(
          overrides: [
            onlineReviewProductHttpClientProvider.overrideWithValue(httpClient),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(onlineReviewProductActionsProvider)
            .submit(_request());

        final state = container.read(onlineReviewProductControllerProvider);
        final viewModel = container.read(onlineReviewProductViewModelProvider);
        expect(state.status, OnlineReviewProductControllerStatus.failure);
        expect(state.failure!.code, 'onlineReviewDisabled');
        expect(viewModel.messageKey, 'onlineReview.failure.disabled');
        expect(httpClient.calls, 0);
      },
    );

    test('reset returns controller state and view model to idle', () async {
      final container = _containerFor(
        _RecordingRepository(
          (_) async => ApexOnlineReviewRepositoryResult.success(_review()),
        ),
      );
      addTearDown(container.dispose);
      final actions = container.read(onlineReviewProductActionsProvider);

      await actions.submit(_request());
      actions.reset();

      expect(
        container.read(onlineReviewProductControllerProvider).status,
        OnlineReviewProductControllerStatus.idle,
      );
      expect(
        container.read(onlineReviewProductViewModelProvider).status,
        OnlineReviewProductViewStatus.idle,
      );
    });

    test('retryLastRequest is a no-op before any request', () async {
      final repository = _RecordingRepository(
        (_) async => ApexOnlineReviewRepositoryResult.success(_review()),
      );
      final container = _containerFor(repository);
      addTearDown(container.dispose);

      await container
          .read(onlineReviewProductActionsProvider)
          .retryLastRequest();

      expect(repository.calls, 0);
      expect(
        container.read(onlineReviewProductControllerProvider).status,
        OnlineReviewProductControllerStatus.idle,
      );
    });

    test(
      'retryLastRequest is a no-op after non-retryable validation failure',
      () async {
        final repository = _RecordingRepository(
          (_) async => ApexOnlineReviewRepositoryResult.success(_review()),
        );
        final container = _containerFor(repository);
        addTearDown(container.dispose);
        final actions = container.read(onlineReviewProductActionsProvider);

        await actions.submit(_request(pgn: '   '));
        await actions.retryLastRequest();

        final state = container.read(onlineReviewProductControllerProvider);
        expect(repository.calls, 0);
        expect(state.status, OnlineReviewProductControllerStatus.failure);
        expect(state.failure!.code, 'emptyPgn');
        expect(state.canRetry, isFalse);
      },
    );

    test('retryLastRequest is a no-op for disabled failures', () async {
      final httpClient = _RecordingHttpClient();
      final container = ProviderContainer(
        overrides: [
          onlineReviewProductHttpClientProvider.overrideWithValue(httpClient),
        ],
      );
      addTearDown(container.dispose);
      final actions = container.read(onlineReviewProductActionsProvider);

      await actions.submit(_request());
      await actions.retryLastRequest();

      final state = container.read(onlineReviewProductControllerProvider);
      expect(state.status, OnlineReviewProductControllerStatus.failure);
      expect(state.failure!.code, 'onlineReviewDisabled');
      expect(state.canRetry, isFalse);
      expect(httpClient.calls, 0);
    });

    test('retryLastRequest re-submits retryable failures', () async {
      final repository = _SequenceRepository(
        first: (_) async => const ApexOnlineReviewRepositoryResult.failure(
          ApexOnlineReviewRepositoryFailure(
            code: 'timeout',
            message: 'Request timed out',
            isRetryable: true,
            source: 'network',
          ),
        ),
        next: (_) async => ApexOnlineReviewRepositoryResult.success(
          _review(totalPlies: 2, analyzedMoves: 2),
        ),
      );
      final container = _containerFor(repository);
      addTearDown(container.dispose);
      final actions = container.read(onlineReviewProductActionsProvider);

      await actions.submit(_request());
      expect(
        container.read(onlineReviewProductViewModelProvider).canRetry,
        isTrue,
      );

      await actions.retryLastRequest();

      final state = container.read(onlineReviewProductControllerProvider);
      final viewModel = container.read(onlineReviewProductViewModelProvider);
      expect(repository.calls, 2);
      expect(state.status, OnlineReviewProductControllerStatus.success);
      expect(viewModel.status, OnlineReviewProductViewStatus.success);
      expect(viewModel.summary!.totalPlies, 2);
    });

    test(
      'retryLastRequest does not trigger duplicate submits while loading',
      () async {
        final repository = _RetryThenPendingRepository();
        final container = _containerFor(repository);
        addTearDown(container.dispose);
        final actions = container.read(onlineReviewProductActionsProvider);

        await actions.submit(_request());

        final retryFuture = actions.retryLastRequest();
        await Future<void>.delayed(Duration.zero);
        expect(repository.calls, 2);
        expect(
          container.read(onlineReviewProductControllerProvider).status,
          OnlineReviewProductControllerStatus.loading,
        );

        await actions.retryLastRequest();
        expect(repository.calls, 2);

        repository.completeRetry(
          ApexOnlineReviewRepositoryResult.success(_review()),
        );
        await retryFuture;
        expect(
          container.read(onlineReviewProductControllerProvider).status,
          OnlineReviewProductControllerStatus.success,
        );
      },
    );
  });

  group('onlineReviewProductActionsProvider guardrails', () {
    test('actions source stays narrow and presentation-safe', () {
      final source = File(
        'lib/features/pgn_review/presentation/'
        'online_review_product_actions.dart',
      ).readAsStringSync();

      expect(source, contains('onlineReviewProductActionsProvider'));
      expect(source, contains('state.canRetry'));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('apex_http_client.dart')));
      expect(source, isNot(contains('http_online_review_product_repository')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('C:\\apex_chess_backend')));
    });

    test('active review pipeline does not consume the actions seam yet', () {
      final providers = File('lib/app/di/providers.dart').readAsStringSync();
      final pipelineStart = providers.indexOf(
        'final reviewAnalysisPipelineProvider',
      );
      final pipelineSource = providers.substring(pipelineStart);

      expect(
        pipelineSource,
        isNot(contains('onlineReviewProductActionsProvider')),
      );
      expect(pipelineSource, contains('LocalOfflineReviewProvider'));
    });
  });
}

ProviderContainer _containerFor(OnlineReviewProductRepository repository) {
  return ProviderContainer(
    overrides: [
      onlineReviewProductUseCaseProvider.overrideWithValue(
        OnlineReviewProductUseCase(repository: repository),
      ),
    ],
  );
}

ApexOnlineReviewRequest _request({String pgn = '1. e4 *'}) {
  return ApexOnlineReviewRequest(
    pgn: pgn,
    mode: ApexOnlineReviewMode.onlineFast,
  );
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

class _SequenceRepository implements OnlineReviewProductRepository {
  _SequenceRepository({required this.first, required this.next});

  final Future<ApexOnlineReviewRepositoryResult> Function(
    ApexOnlineReviewRequest request,
  )
  first;
  final Future<ApexOnlineReviewRepositoryResult> Function(
    ApexOnlineReviewRequest request,
  )
  next;

  int calls = 0;

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) {
    calls++;
    return calls == 1 ? first(request) : next(request);
  }
}

class _RetryThenPendingRepository implements OnlineReviewProductRepository {
  final _retryCompleter = Completer<ApexOnlineReviewRepositoryResult>();

  int calls = 0;

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) {
    calls++;
    if (calls == 1) {
      return Future.value(
        const ApexOnlineReviewRepositoryResult.failure(
          ApexOnlineReviewRepositoryFailure(
            code: 'networkError',
            message: 'Network unavailable',
            isRetryable: true,
            source: 'network',
          ),
        ),
      );
    }
    return _retryCompleter.future;
  }

  void completeRetry(ApexOnlineReviewRepositoryResult result) {
    _retryCompleter.complete(result);
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

ApexOnlineReview _review({int totalPlies = 0, int analyzedMoves = 0}) {
  return ApexOnlineReview(
    contractVersion: 'online-review-product-v1',
    mode: ApexOnlineReviewMode.onlineFast,
    status: ApexReviewStatus.completed,
    summary: ApexOnlineReviewSummary(
      totalPlies: totalPlies,
      analyzedMoves: analyzedMoves,
      failedMoves: 0,
      qualityCounts: const {},
      bestMoveCount: 0,
      inaccuracyCount: 0,
      mistakeCount: 0,
      blunderCount: 0,
      criticalMoveCount: 0,
    ),
    moves: const [],
    providerInfo: const ApexReviewProviderInfo(
      provider: 'fake',
      engine: 'none',
      analysisVersion: 'test',
      classifierVersion: 'test',
      productContractVersion: 'online-review-product-v1',
      mode: ApexOnlineReviewMode.onlineFast,
      targetDepthTier: 'test',
      isExecutionHintOnly: true,
    ),
  );
}
