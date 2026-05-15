import 'dart:async';
import 'dart:io';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_controller.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_use_case.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/presentation/models/online_review_product_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('onlineReviewProductViewModelProvider', () {
    test('starts idle without touching HTTP', () {
      final client = _RecordingHttpClient();
      final container = ProviderContainer(
        overrides: [
          onlineReviewProductHttpClientProvider.overrideWithValue(client),
        ],
      );
      addTearDown(container.dispose);

      final viewModel = container.read(onlineReviewProductViewModelProvider);

      expect(viewModel.status, OnlineReviewProductViewStatus.idle);
      expect(viewModel.canSubmit, isTrue);
      expect(viewModel.showSummary, isFalse);
      expect(viewModel.showMoves, isFalse);
      expect(client.calls, 0);
    });

    test('maps success after controller submit', () async {
      final request = _request();
      final container = _containerFor(
        OnlineReviewProductUseCase(
          repository: _RecordingRepository(
            (_) async => ApexOnlineReviewRepositoryResult.success(
              _review(
                moves: [
                  _move(
                    ply: 0,
                    quality: ApexMoveQuality.best,
                    warnings: const ['futureWarning'],
                  ),
                ],
                summary: _summary(totalPlies: 1, analyzedMoves: 1),
              ),
            ),
          ),
        ),
      );
      addTearDown(container.dispose);

      await container
          .read(onlineReviewProductControllerProvider.notifier)
          .submit(request);

      final viewModel = container.read(onlineReviewProductViewModelProvider);
      expect(viewModel.status, OnlineReviewProductViewStatus.success);
      expect(viewModel.showSummary, isTrue);
      expect(viewModel.showMoves, isTrue);
      expect(viewModel.summary!.totalPlies, 1);
      expect(viewModel.moves, hasLength(1));
      expect(viewModel.moves.single.warningCodes, ['futureWarning']);
    });

    test('maps disabled and retryable failures through the provider', () async {
      final disabledContainer = ProviderContainer();
      addTearDown(disabledContainer.dispose);
      await disabledContainer
          .read(onlineReviewProductControllerProvider.notifier)
          .submit(_request());

      final disabled = disabledContainer.read(
        onlineReviewProductViewModelProvider,
      );
      expect(disabled.status, OnlineReviewProductViewStatus.failure);
      expect(disabled.messageKey, 'onlineReview.failure.disabled');
      expect(disabled.primaryAction, OnlineReviewProductPrimaryAction.reset);
      expect(disabled.canRetry, isFalse);

      final retryContainer = _containerFor(
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
      addTearDown(retryContainer.dispose);
      await retryContainer
          .read(onlineReviewProductControllerProvider.notifier)
          .submit(_request());

      final retryable = retryContainer.read(
        onlineReviewProductViewModelProvider,
      );
      expect(retryable.status, OnlineReviewProductViewStatus.failure);
      expect(retryable.messageKey, 'onlineReview.failure.timeout');
      expect(retryable.canRetry, isTrue);
      expect(retryable.primaryAction, OnlineReviewProductPrimaryAction.retry);
    });

    test(
      'maps loading while submit is pending, then reset back to idle',
      () async {
        final repository = _PendingRepository();
        final container = _containerFor(
          OnlineReviewProductUseCase(repository: repository),
        );
        addTearDown(container.dispose);
        final controller = container.read(
          onlineReviewProductControllerProvider.notifier,
        );

        final submitFuture = controller.submit(_request());
        await Future<void>.delayed(Duration.zero);

        final loading = container.read(onlineReviewProductViewModelProvider);
        expect(loading.status, OnlineReviewProductViewStatus.loading);
        expect(loading.isLoading, isTrue);
        expect(loading.canSubmit, isFalse);

        controller.reset();
        final reset = container.read(onlineReviewProductViewModelProvider);
        expect(reset.status, OnlineReviewProductViewStatus.idle);
        expect(reset.canSubmit, isTrue);

        repository.complete(
          ApexOnlineReviewRepositoryResult.success(_review()),
        );
        await submitFuture;
        expect(
          container.read(onlineReviewProductViewModelProvider).status,
          OnlineReviewProductViewStatus.idle,
        );
      },
    );

    test('mapper provider can be overridden deterministically', () {
      final container = ProviderContainer(
        overrides: [
          onlineReviewProductViewModelMapperProvider.overrideWithValue(
            const _ForcedFailureMapper(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final viewModel = container.read(onlineReviewProductViewModelProvider);

      expect(viewModel.status, OnlineReviewProductViewStatus.failure);
      expect(viewModel.messageKey, 'test.forced.failure');
      expect(viewModel.showFailure, isTrue);
    });
  });

  group('onlineReviewProductViewModelProvider guardrails', () {
    test('provider source stays presentation-only and side-effect free', () {
      final source = File(
        'lib/features/pgn_review/presentation/models/'
        'online_review_product_view_model.dart',
      ).readAsStringSync();

      expect(source, contains('onlineReviewProductViewModelProvider'));
      expect(
        source,
        contains('ref.watch(onlineReviewProductControllerProvider)'),
      );
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('apex_http_client.dart')));
      expect(source, isNot(contains('http_online_review_product_repository')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('C:\\apex_chess_backend')));
      expect(source, isNot(contains('.submit(')));
    });
  });
}

ProviderContainer _containerFor(OnlineReviewProductUseCase useCase) {
  return ProviderContainer(
    overrides: [onlineReviewProductUseCaseProvider.overrideWithValue(useCase)],
  );
}

ApexOnlineReviewRequest _request() {
  return const ApexOnlineReviewRequest(
    pgn: '1. e4 *',
    mode: ApexOnlineReviewMode.onlineFast,
  );
}

class _ForcedFailureMapper extends OnlineReviewProductViewModelMapper {
  const _ForcedFailureMapper();

  @override
  OnlineReviewProductViewModel fromControllerState(
    OnlineReviewProductControllerState state,
  ) {
    return OnlineReviewProductViewModel(
      status: OnlineReviewProductViewStatus.failure,
      titleKey: 'test.forced.title',
      messageKey: 'test.forced.failure',
      isLoading: false,
      canSubmit: false,
      canRetry: false,
      canReset: false,
      showSummary: false,
      showMoves: false,
      showFailure: true,
      primaryAction: OnlineReviewProductPrimaryAction.none,
    );
  }
}

class _RecordingRepository implements OnlineReviewProductRepository {
  _RecordingRepository(this._handler);

  final Future<ApexOnlineReviewRepositoryResult> Function(
    ApexOnlineReviewRequest request,
  )
  _handler;

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) {
    return _handler(request);
  }
}

class _PendingRepository implements OnlineReviewProductRepository {
  final _completer = Completer<ApexOnlineReviewRepositoryResult>();

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) {
    return _completer.future;
  }

  void complete(ApexOnlineReviewRepositoryResult result) {
    _completer.complete(result);
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
  ApexOnlineReviewSummary? summary,
  List<ApexReviewedMove> moves = const [],
}) {
  return ApexOnlineReview(
    contractVersion: 'online-review-product-v1',
    mode: ApexOnlineReviewMode.onlineFast,
    status: ApexReviewStatus.completed,
    summary: summary ?? _summary(),
    moves: moves,
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

ApexOnlineReviewSummary _summary({int totalPlies = 0, int analyzedMoves = 0}) {
  return ApexOnlineReviewSummary(
    totalPlies: totalPlies,
    analyzedMoves: analyzedMoves,
    failedMoves: 0,
    qualityCounts: const {},
    bestMoveCount: 0,
    inaccuracyCount: 0,
    mistakeCount: 0,
    blunderCount: 0,
    criticalMoveCount: 0,
  );
}

ApexReviewedMove _move({
  required int ply,
  required ApexMoveQuality quality,
  List<String> warnings = const [],
}) {
  return ApexReviewedMove(
    ply: ply,
    moveNumber: (ply ~/ 2) + 1,
    side: ply.isEven ? 'white' : 'black',
    san: ply.isEven ? 'e4' : 'e5',
    uci: ply.isEven ? 'e2e4' : 'e7e5',
    quality: quality,
    confidence: ApexReviewConfidence.high,
    criticalityLevel: ApexCriticalityLevel.none,
    isCritical: false,
    isTacticalCandidate: false,
    hasMateWarning: false,
    warnings: warnings,
  );
}
