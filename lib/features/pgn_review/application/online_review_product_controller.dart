/// Non-UI async state controller for future Online Review product flows.
///
/// This layer owns request-state transitions above the application use-case so
/// future widgets can consume a stable state model without knowing repository
/// or transport details.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_use_case.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';

enum OnlineReviewProductControllerStatus { idle, loading, success, failure }

class OnlineReviewProductControllerState {
  const OnlineReviewProductControllerState._({
    required this.status,
    this.review,
    this.failure,
    this.lastRequest,
  });

  const OnlineReviewProductControllerState.idle()
    : this._(status: OnlineReviewProductControllerStatus.idle);

  const OnlineReviewProductControllerState.loading(
    ApexOnlineReviewRequest request,
  ) : this._(
        status: OnlineReviewProductControllerStatus.loading,
        lastRequest: request,
      );

  const OnlineReviewProductControllerState.success(
    ApexOnlineReview review,
    ApexOnlineReviewRequest request,
  ) : this._(
        status: OnlineReviewProductControllerStatus.success,
        review: review,
        lastRequest: request,
      );

  const OnlineReviewProductControllerState.failure(
    OnlineReviewProductUseCaseFailure failure,
    ApexOnlineReviewRequest request, {
    ApexOnlineReview? review,
  }) : this._(
         status: OnlineReviewProductControllerStatus.failure,
         review: review,
         failure: failure,
         lastRequest: request,
       );

  final OnlineReviewProductControllerStatus status;
  final ApexOnlineReview? review;
  final OnlineReviewProductUseCaseFailure? failure;
  final ApexOnlineReviewRequest? lastRequest;

  bool get isLoading => status == OnlineReviewProductControllerStatus.loading;

  bool get hasResult => review != null;

  bool get hasFailure => failure != null;

  bool get canSubmit => !isLoading;

  bool get canRetry =>
      status == OnlineReviewProductControllerStatus.failure &&
      failure?.isRetryable == true &&
      failure?.validation != true &&
      lastRequest != null;
}

class OnlineReviewProductController
    extends Notifier<OnlineReviewProductControllerState> {
  int _generation = 0;

  @override
  OnlineReviewProductControllerState build() {
    return const OnlineReviewProductControllerState.idle();
  }

  Future<void> submit(ApexOnlineReviewRequest request) async {
    if (state.isLoading) return;

    final generation = ++_generation;
    state = OnlineReviewProductControllerState.loading(request);

    try {
      final result = await ref
          .read(onlineReviewProductUseCaseProvider)
          .analyze(request);
      if (generation != _generation) return;

      if (result.isSuccess && result.review != null) {
        state = OnlineReviewProductControllerState.success(
          result.review!,
          request,
        );
        return;
      }

      final failure = result.failure;
      if (failure != null) {
        state = OnlineReviewProductControllerState.failure(
          failure,
          request,
          review: result.review,
        );
        return;
      }
    } catch (_) {
      if (generation != _generation) return;
      state = OnlineReviewProductControllerState.failure(
        _controllerUnexpectedFailure,
        request,
      );
      return;
    }

    if (generation == _generation) {
      state = OnlineReviewProductControllerState.failure(
        _controllerUnexpectedFailure,
        request,
      );
    }
  }

  void reset() {
    _generation++;
    state = const OnlineReviewProductControllerState.idle();
  }
}

const _controllerUnexpectedFailure = OnlineReviewProductUseCaseFailure(
  code: 'onlineReviewControllerUnexpectedError',
  message: 'Online review controller failed unexpectedly',
  isRetryable: false,
  source: 'unknown',
  validation: false,
);

final onlineReviewProductControllerProvider =
    NotifierProvider<
      OnlineReviewProductController,
      OnlineReviewProductControllerState
    >(OnlineReviewProductController.new);
