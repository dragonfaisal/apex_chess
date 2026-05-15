/// App-facing Online Review operation above the repository boundary.
///
/// Future state/UI layers should depend on this small application seam rather
/// than on transport DTOs or repository implementation details.
library;

import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';

class OnlineReviewProductUseCase {
  const OnlineReviewProductUseCase({
    required OnlineReviewProductRepository repository,
  }) : _repository = repository;

  final OnlineReviewProductRepository _repository;

  Future<OnlineReviewProductUseCaseResult> analyze(
    ApexOnlineReviewRequest request,
  ) async {
    if (request.pgn.trim().isEmpty) {
      return const OnlineReviewProductUseCaseResult.failure(
        OnlineReviewProductUseCaseFailure(
          code: 'emptyPgn',
          message: 'PGN is required for online review',
          isRetryable: false,
          source: 'validation',
          validation: true,
        ),
      );
    }

    try {
      final repositoryResult = await _repository.analyze(request);
      if (repositoryResult.isSuccess && repositoryResult.review != null) {
        return OnlineReviewProductUseCaseResult.success(
          repositoryResult.review!,
        );
      }

      final repositoryFailure = repositoryResult.failure;
      if (repositoryFailure != null) {
        return OnlineReviewProductUseCaseResult.failure(
          OnlineReviewProductUseCaseFailure(
            code: repositoryFailure.code,
            message: repositoryFailure.message,
            isRetryable: repositoryFailure.isRetryable,
            source: repositoryFailure.source,
            validation: false,
          ),
          review: repositoryResult.review,
        );
      }
    } catch (_) {
      return _unexpectedFailure();
    }

    return _unexpectedFailure();
  }

  static OnlineReviewProductUseCaseResult _unexpectedFailure() {
    return const OnlineReviewProductUseCaseResult.failure(
      OnlineReviewProductUseCaseFailure(
        code: 'onlineReviewUnexpectedError',
        message: 'Online review request failed unexpectedly',
        isRetryable: false,
        source: 'unknown',
        validation: false,
      ),
    );
  }
}

class OnlineReviewProductUseCaseResult {
  const OnlineReviewProductUseCaseResult._({this.review, this.failure})
    : assert(review != null || failure != null);

  const OnlineReviewProductUseCaseResult.success(ApexOnlineReview review)
    : this._(review: review);

  const OnlineReviewProductUseCaseResult.failure(
    OnlineReviewProductUseCaseFailure failure, {
    ApexOnlineReview? review,
  }) : this._(review: review, failure: failure);

  final ApexOnlineReview? review;
  final OnlineReviewProductUseCaseFailure? failure;

  bool get isSuccess => review != null && failure == null;

  bool get isFailure => !isSuccess;
}

class OnlineReviewProductUseCaseFailure {
  const OnlineReviewProductUseCaseFailure({
    required this.code,
    required this.message,
    required this.isRetryable,
    required this.source,
    required this.validation,
  });

  final String code;
  final String message;
  final bool isRetryable;
  final String source;
  final bool validation;
}
