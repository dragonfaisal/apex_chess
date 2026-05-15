/// Presentation-facing actions for future Online Review product screens.
///
/// This facade keeps future widgets from reaching through to controller
/// internals directly while preserving controller-owned retry rules.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/features/pgn_review/application/online_review_product_controller.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';

class OnlineReviewProductActions {
  const OnlineReviewProductActions({
    required Future<void> Function(ApexOnlineReviewRequest request) submit,
    required OnlineReviewProductControllerState Function() readState,
    required void Function() reset,
  }) : _submit = submit,
       _readState = readState,
       _reset = reset;

  final Future<void> Function(ApexOnlineReviewRequest request) _submit;
  final OnlineReviewProductControllerState Function() _readState;
  final void Function() _reset;

  Future<void> submit(ApexOnlineReviewRequest request) {
    return _submit(request);
  }

  Future<void> retryLastRequest() async {
    final state = _readState();
    final lastRequest = state.lastRequest;
    if (!state.canRetry || lastRequest == null) return;

    await _submit(lastRequest);
  }

  void reset() {
    _reset();
  }
}

final onlineReviewProductActionsProvider = Provider<OnlineReviewProductActions>(
  (ref) {
    return OnlineReviewProductActions(
      submit: (request) {
        return ref
            .read(onlineReviewProductControllerProvider.notifier)
            .submit(request);
      },
      readState: () => ref.read(onlineReviewProductControllerProvider),
      reset: () {
        ref.read(onlineReviewProductControllerProvider.notifier).reset();
      },
    );
  },
);
