/// Shared production surface for every on-device review execution.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_summary_screen.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

typedef OfflineReviewCompletion =
    FutureOr<void> Function(WidgetRef ref, ReviewState state);

class OfflineReviewProgressDialog extends ConsumerStatefulWidget {
  const OfflineReviewProgressDialog({
    super.key,
    required this.pgn,
    required this.profile,
    required this.source,
    required this.sourceProvider,
    this.sourceGameId,
    this.playedAt,
    this.timeControl,
    this.userIsWhite,
    this.userHandle,
    this.onCompleted,
  });

  final String pgn;
  final AnalysisProfile profile;
  final ReviewRuntimeSource source;
  final AnalysisGameSource sourceProvider;
  final String? sourceGameId;
  final DateTime? playedAt;
  final String? timeControl;
  final bool? userIsWhite;
  final String? userHandle;
  final OfflineReviewCompletion? onCompleted;

  @override
  ConsumerState<OfflineReviewProgressDialog> createState() =>
      _OfflineReviewProgressDialogState();
}

class _OfflineReviewProgressDialogState
    extends ConsumerState<OfflineReviewProgressDialog>
    with WidgetsBindingObserver {
  late final ReviewController _reviewController;
  int? _ownedExecutionId;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _reviewController = ref.read(reviewControllerProvider.notifier);
    WidgetsBinding.instance.addObserver(this);
    unawaited(_run());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _cancelOwnedExecution();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelOwnedExecution();
    super.dispose();
  }

  Future<void> _run() async {
    final pipeline = await ref.read(reviewAnalysisPipelineProvider.future);
    if (!mounted) return;
    final controller = ref.read(reviewControllerProvider.notifier);
    final future = controller.analyzeOffline(
      request: ReviewRuntimeRequest(
        pgn: widget.pgn,
        profile: widget.profile,
        source: widget.source,
        sourceProvider: widget.sourceProvider,
        sourceGameId: widget.sourceGameId,
        playedAt: widget.playedAt,
        timeControl: widget.timeControl,
        userIsWhite: widget.userIsWhite,
        userHandle: widget.userHandle,
      ),
      execute: pipeline.analyzeOffline,
      cancelExecution: pipeline.cancelLocalAnalysis,
      persist: ref.read(archiveControllerProvider.notifier).saveReviewDocument,
    );
    _ownedExecutionId = ref.read(reviewControllerProvider).executionId;
    final completed = await future;
    if (!mounted || !completed || _navigating) return;
    final finished = ref.read(reviewControllerProvider);
    if (finished.executionId != _ownedExecutionId ||
        !finished.isTrustedComplete) {
      return;
    }
    if (finished.saveState == ReviewSaveState.failed) return;
    await widget.onCompleted?.call(ref, finished);
    if (!mounted) return;
    _navigating = true;
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ReviewSummaryScreen()),
    );
  }

  void _cancelOwnedExecution() {
    final owned = _ownedExecutionId;
    if (owned == null) return;
    _reviewController.cancelExecutionIfOwned(owned);
  }

  @override
  Widget build(BuildContext context) {
    final runtime = ref.watch(reviewControllerProvider);
    final ownsState = runtime.executionId == _ownedExecutionId;
    final lifecycle = ownsState
        ? runtime.lifecycle
        : ReviewRuntimeLifecycle.preparing;
    return PopScope(
      canPop: !runtime.isExecuting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _cancelOwnedExecution();
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: GlassPanel.dialog(
          accentColor: lifecycle == ReviewRuntimeLifecycle.failed
              ? ApexColors.ruby
              : ApexColors.sapphire,
          child:
              lifecycle == ReviewRuntimeLifecycle.failed ||
                  lifecycle == ReviewRuntimeLifecycle.cancelled ||
                  runtime.saveState == ReviewSaveState.failed
              ? _terminalContent(runtime)
              : _progressContent(runtime),
        ),
      ),
    );
  }

  Widget _progressContent(ReviewState runtime) {
    final stage = switch (runtime.lifecycle) {
      ReviewRuntimeLifecycle.validating => 'Validating the complete mainline',
      ReviewRuntimeLifecycle.preparing => 'Preparing local analysis',
      ReviewRuntimeLifecycle.analyzing => 'Analyzing positions on this device',
      ReviewRuntimeLifecycle.cancelling => 'Stopping analysis safely',
      ReviewRuntimeLifecycle.completed => 'Saving the trusted review',
      _ => 'Preparing review',
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ApexLoadingScaffold(
          title: widget.profile.label,
          messages: [stage],
          progress: runtime.progress,
          progressMessage: runtime.progressTotal > 0
              ? '${runtime.progressCompleted} / ${runtime.progressTotal} plies'
              : stage,
          compact: true,
        ),
        if (runtime.isExecuting) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              key: const ValueKey('offline-review-cancel'),
              onPressed: _cancelOwnedExecution,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Cancel'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _terminalContent(ReviewState runtime) {
    final cancelled = runtime.lifecycle == ReviewRuntimeLifecycle.cancelled;
    final saveFailed = runtime.saveState == ReviewSaveState.failed;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          cancelled
              ? Icons.stop_circle_outlined
              : saveFailed
              ? Icons.save_as_outlined
              : Icons.error_outline_rounded,
          color: cancelled ? ApexColors.textSecondary : ApexColors.ruby,
          size: 28,
        ),
        const SizedBox(height: 12),
        Text(
          cancelled
              ? 'Analysis cancelled'
              : saveFailed
              ? 'Review completed'
              : 'Review unavailable',
          style: ApexTypography.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          runtime.error ?? 'Could not complete the review.',
          style: ApexTypography.bodyMedium.copyWith(
            color: ApexColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            const SizedBox(width: 8),
            if (saveFailed) ...[
              TextButton(
                key: const ValueKey('offline-review-open-unsaved'),
                onPressed: _openCompletedReview,
                child: const Text('Open review'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const ValueKey('offline-review-retry-save'),
                onPressed: _retrySave,
                child: const Text('Retry save'),
              ),
            ] else
              FilledButton(
                key: const ValueKey('offline-review-retry'),
                onPressed: _run,
                child: const Text('Retry'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _retrySave() async {
    final id = await ref
        .read(reviewControllerProvider.notifier)
        .saveCurrent(
          ref.read(archiveControllerProvider.notifier).saveReviewDocument,
        );
    if (!mounted || id == null) return;
    await _openCompletedReview();
  }

  Future<void> _openCompletedReview() async {
    if (_navigating) return;
    final finished = ref.read(reviewControllerProvider);
    if (!finished.isTrustedComplete) return;
    await widget.onCompleted?.call(ref, finished);
    if (!mounted) return;
    _navigating = true;
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ReviewSummaryScreen()),
    );
  }
}
