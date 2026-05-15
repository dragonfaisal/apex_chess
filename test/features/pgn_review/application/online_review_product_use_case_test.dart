import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/online_review_product_use_case.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const request = ApexOnlineReviewRequest(
    pgn: '1. e4 *',
    mode: ApexOnlineReviewMode.onlineFast,
  );

  group('OnlineReviewProductUseCase', () {
    test('returns repository success as an application success', () async {
      final repository = _RecordingRepository(
        (_) async => ApexOnlineReviewRepositoryResult.success(
          _review(mode: ApexOnlineReviewMode.onlineFast),
        ),
      );
      final useCase = OnlineReviewProductUseCase(repository: repository);

      final result = await useCase.analyze(request);

      expect(repository.calls, 1);
      expect(result.isSuccess, isTrue);
      expect(result.failure, isNull);
      expect(result.review, isA<ApexOnlineReview>());
      expect(result.review!.mode, ApexOnlineReviewMode.onlineFast);
    });

    test('rejects empty PGN before calling the repository', () async {
      final repository = _RecordingRepository(
        (_) async => ApexOnlineReviewRepositoryResult.success(
          _review(mode: ApexOnlineReviewMode.onlineFast),
        ),
      );
      final useCase = OnlineReviewProductUseCase(repository: repository);

      final result = await useCase.analyze(
        const ApexOnlineReviewRequest(
          pgn: '   \n\t',
          mode: ApexOnlineReviewMode.onlineFast,
        ),
      );

      expect(repository.calls, 0);
      expect(result.isFailure, isTrue);
      expect(result.review, isNull);
      expect(result.failure!.code, 'emptyPgn');
      expect(result.failure!.source, 'validation');
      expect(result.failure!.validation, isTrue);
      expect(result.failure!.isRetryable, isFalse);
    });

    test('preserves disabled repository failures safely', () async {
      final repository = _RecordingRepository(
        (_) async => const ApexOnlineReviewRepositoryResult.failure(
          ApexOnlineReviewRepositoryFailure(
            code: 'onlineReviewDisabled',
            message: 'Online review repository is disabled',
            isRetryable: false,
            source: 'disabled',
          ),
        ),
      );
      final useCase = OnlineReviewProductUseCase(repository: repository);

      final result = await useCase.analyze(request);

      expect(result.isFailure, isTrue);
      expect(result.review, isNull);
      expect(result.failure!.code, 'onlineReviewDisabled');
      expect(result.failure!.message, 'Online review repository is disabled');
      expect(result.failure!.source, 'disabled');
      expect(result.failure!.validation, isFalse);
    });

    test(
      'preserves backend invalid PGN failures and failed review data',
      () async {
        final failedReview = _review(
          mode: ApexOnlineReviewMode.onlineFast,
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
        final useCase = OnlineReviewProductUseCase(repository: repository);

        final result = await useCase.analyze(request);

        expect(result.isFailure, isTrue);
        expect(result.review, same(failedReview));
        expect(result.review!.isFailed, isTrue);
        expect(result.failure!.code, 'invalidPgn');
        expect(result.failure!.message, 'Invalid PGN');
        expect(result.failure!.source, 'backend');
      },
    );

    test('preserves retryable repository failures', () async {
      final repository = _RecordingRepository(
        (_) async => const ApexOnlineReviewRepositoryResult.failure(
          ApexOnlineReviewRepositoryFailure(
            code: 'timeout',
            message: 'Request timed out',
            isRetryable: true,
            source: 'network',
          ),
        ),
      );
      final useCase = OnlineReviewProductUseCase(repository: repository);

      final result = await useCase.analyze(request);

      expect(result.isFailure, isTrue);
      expect(result.failure!.code, 'timeout');
      expect(result.failure!.isRetryable, isTrue);
      expect(result.failure!.source, 'network');
    });

    test(
      'converts unexpected repository exceptions into safe failures',
      () async {
        final repository = _ThrowingRepository();
        final useCase = OnlineReviewProductUseCase(repository: repository);

        final result = await useCase.analyze(request);

        expect(result.isFailure, isTrue);
        expect(result.review, isNull);
        expect(result.failure!.code, 'onlineReviewUnexpectedError');
        expect(
          result.failure!.message,
          'Online review request failed unexpectedly',
        );
        expect(result.failure!.source, 'unknown');
        expect(result.failure!.validation, isFalse);
        expect(result.failure!.isRetryable, isFalse);
      },
    );
  });

  group('OnlineReviewProductUseCase boundaries', () {
    test('public API stays application-facing and transport-free', () {
      final source = File(
        'lib/features/pgn_review/application/online_review_product_use_case.dart',
      ).readAsStringSync();

      expect(source, contains('Future<OnlineReviewProductUseCaseResult>'));
      expect(source, contains('final ApexOnlineReview? review;'));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('apex_http_client.dart')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('C:\\apex_chess_backend')));
    });
  });
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

class _ThrowingRepository implements OnlineReviewProductRepository {
  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) async {
    throw StateError('boom');
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
