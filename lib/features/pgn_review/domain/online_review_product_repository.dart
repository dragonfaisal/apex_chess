/// App-facing repository contract for the Online Review product boundary.
///
/// This seam is intentionally transport-free: callers submit domain requests
/// and receive domain review data plus a repository-safe failure envelope.
library;

import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';

class ApexOnlineReviewRequest {
  const ApexOnlineReviewRequest({
    required this.pgn,
    required this.mode,
    this.maxPlies,
    this.includeDebug = false,
    this.requestedDepth,
    this.requestedMultiPv,
  });

  final String pgn;
  final ApexOnlineReviewMode mode;
  final int? maxPlies;
  final bool includeDebug;
  final int? requestedDepth;
  final int? requestedMultiPv;
}

class ApexOnlineReviewRepositoryResult {
  const ApexOnlineReviewRepositoryResult._({this.review, this.failure})
    : assert(review != null || failure != null);

  const ApexOnlineReviewRepositoryResult.success(ApexOnlineReview review)
    : this._(review: review);

  const ApexOnlineReviewRepositoryResult.failure(
    ApexOnlineReviewRepositoryFailure failure, {
    ApexOnlineReview? review,
  }) : this._(review: review, failure: failure);

  final ApexOnlineReview? review;
  final ApexOnlineReviewRepositoryFailure? failure;

  bool get isSuccess => review != null && failure == null;

  bool get isFailure => !isSuccess;
}

class ApexOnlineReviewRepositoryFailure {
  const ApexOnlineReviewRepositoryFailure({
    required this.code,
    required this.message,
    required this.isRetryable,
    required this.source,
  });

  final String code;
  final String message;
  final bool isRetryable;
  final String source;
}

abstract class OnlineReviewProductRepository {
  const OnlineReviewProductRepository();

  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  );
}
