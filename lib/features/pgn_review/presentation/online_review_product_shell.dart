/// Guarded UI composition shell for the future Online Review product flow.
///
/// The shell deliberately consumes only the presentation seams: a derived
/// view-model provider for reads and a narrow actions facade for writes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/presentation/models/online_review_product_view_model.dart';
import 'package:apex_chess/features/pgn_review/presentation/online_review_product_actions.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

class OnlineReviewProductShell extends ConsumerWidget {
  const OnlineReviewProductShell({
    super.key,
    required this.pgn,
    this.mode = ApexOnlineReviewMode.onlineFast,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(onlineReviewProductViewModelProvider);
    final actions = ref.read(onlineReviewProductActionsProvider);
    final hasPgn = pgn.trim().isNotEmpty;

    return DecoratedBox(
      key: const ValueKey('online-review-product-shell'),
      decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ApexSpacing.lg),
          child: GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ShellHeader(viewModel: viewModel, mode: mode),
                const SizedBox(height: ApexSpacing.lg),
                _ShellBody(viewModel: viewModel, hasPgn: hasPgn),
                if (viewModel.showSummary && viewModel.summary != null) ...[
                  const SizedBox(height: ApexSpacing.lg),
                  _SummarySection(summary: viewModel.summary!),
                ],
                if (viewModel.showMoves && viewModel.moves.isNotEmpty) ...[
                  const SizedBox(height: ApexSpacing.lg),
                  _MoveSection(moves: viewModel.moves),
                ],
                const SizedBox(height: ApexSpacing.lg),
                _ShellActions(
                  viewModel: viewModel,
                  hasPgn: hasPgn,
                  onSubmit: () => actions.submit(_request()),
                  onRetry: actions.retryLastRequest,
                  onReset: actions.reset,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ApexOnlineReviewRequest _request() {
    return ApexOnlineReviewRequest(
      pgn: pgn,
      mode: mode,
      maxPlies: maxPlies,
      includeDebug: includeDebug,
      requestedDepth: requestedDepth,
      requestedMultiPv: requestedMultiPv,
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({required this.viewModel, required this.mode});

  final OnlineReviewProductViewModel viewModel;
  final ApexOnlineReviewMode mode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _titleFor(viewModel.titleKey),
                key: const ValueKey('online-review-shell-title'),
                style: ApexTypography.headlineMedium.copyWith(
                  color: ApexColors.textPrimary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: ApexSpacing.xs),
              Text(
                'Guarded ${_modeLabel(mode)} composition shell',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: ApexSpacing.md),
        _ModeChip(label: _modeLabel(mode)),
      ],
    );
  }
}

class _ShellBody extends StatelessWidget {
  const _ShellBody({required this.viewModel, required this.hasPgn});

  final OnlineReviewProductViewModel viewModel;
  final bool hasPgn;

  @override
  Widget build(BuildContext context) {
    final message = _messageFor(viewModel.messageKey);

    return switch (viewModel.status) {
      OnlineReviewProductViewStatus.idle => _IdleBody(hasPgn: hasPgn),
      OnlineReviewProductViewStatus.loading => const _LoadingBody(),
      OnlineReviewProductViewStatus.success => const _SuccessBody(),
      OnlineReviewProductViewStatus.failure => _FailureBody(
        message: message ?? 'Review could not be completed.',
        severity: viewModel.notices.isEmpty
            ? OnlineReviewProductNoticeSeverity.error
            : viewModel.notices.first.severity,
      ),
    };
  }
}

class _IdleBody extends StatelessWidget {
  const _IdleBody({required this.hasPgn});

  final bool hasPgn;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('online-review-shell-idle'),
      padding: const EdgeInsets.all(ApexSpacing.md),
      decoration: _sectionDecoration(),
      child: Text(
        hasPgn
            ? 'Ready to request a guarded Online Review result.'
            : 'Provide a PGN before requesting review.',
        style: ApexTypography.bodyMedium.copyWith(
          color: ApexColors.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('online-review-shell-loading'),
      padding: const EdgeInsets.all(ApexSpacing.md),
      decoration: _sectionDecoration(),
      child: Row(
        children: [
          const ApexPulseLoader(size: 40),
          const SizedBox(width: ApexSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request in progress',
                  style: ApexTypography.titleMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: ApexSpacing.xs),
                Text(
                  'Waiting for the configured Online Review path to respond.',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('online-review-shell-success'),
      padding: const EdgeInsets.all(ApexSpacing.md),
      decoration: _sectionDecoration(
        accent: ApexColors.emeraldBright,
        accentAlpha: 0.22,
      ),
      child: Text(
        'Review result is ready.',
        style: ApexTypography.bodyMedium.copyWith(
          color: ApexColors.textSecondary,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _FailureBody extends StatelessWidget {
  const _FailureBody({required this.message, required this.severity});

  final String message;
  final OnlineReviewProductNoticeSeverity severity;

  @override
  Widget build(BuildContext context) {
    final accent = _noticeColor(severity);
    return Container(
      key: const ValueKey('online-review-shell-failure'),
      padding: const EdgeInsets.all(ApexSpacing.md),
      decoration: _sectionDecoration(accent: accent, accentAlpha: 0.22),
      child: Row(
        children: [
          Icon(_noticeIcon(severity), color: accent, size: 18),
          const SizedBox(width: ApexSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});

  final OnlineReviewProductSummaryViewModel summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('online-review-shell-summary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SUMMARY',
          style: ApexTypography.labelLarge.copyWith(
            color: ApexColors.textTertiary,
            fontSize: 10,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: ApexSpacing.sm),
        Wrap(
          spacing: ApexSpacing.sm,
          runSpacing: ApexSpacing.sm,
          children: [
            _MetricChip(label: 'Plies', value: '${summary.totalPlies}'),
            _MetricChip(label: 'Analyzed', value: '${summary.analyzedMoves}'),
            _MetricChip(label: 'Best', value: '${summary.bestMoveCount}'),
            _MetricChip(label: 'Mistakes', value: '${summary.mistakeCount}'),
            _MetricChip(label: 'Blunders', value: '${summary.blunderCount}'),
            _MetricChip(
              label: 'Critical',
              value: '${summary.criticalMoveCount}',
            ),
          ],
        ),
      ],
    );
  }
}

class _MoveSection extends StatelessWidget {
  const _MoveSection({required this.moves});

  final List<OnlineReviewProductMoveViewModel> moves;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('online-review-shell-moves'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MOVES',
          style: ApexTypography.labelLarge.copyWith(
            color: ApexColors.textTertiary,
            fontSize: 10,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: ApexSpacing.sm),
        for (final move in moves) ...[
          _MoveRow(move: move),
          if (move != moves.last) const SizedBox(height: ApexSpacing.sm),
        ],
      ],
    );
  }
}

class _MoveRow extends StatelessWidget {
  const _MoveRow({required this.move});

  final OnlineReviewProductMoveViewModel move;

  @override
  Widget build(BuildContext context) {
    final accent = _highlightColor(move.highlightLevel);
    final warningCount = move.warningCodes.length;
    return Container(
      key: ValueKey('online-review-shell-move-row-${move.ply}'),
      padding: const EdgeInsets.all(ApexSpacing.md),
      decoration: BoxDecoration(
        color: ApexColors.nebula.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(ApexRadius.card),
        border: Border.all(color: accent.withValues(alpha: 0.34), width: 0.7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 42,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: ApexSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${move.moveNumber}. ${_moveLabel(move)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ApexTypography.titleMedium.copyWith(
                          color: ApexColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: ApexSpacing.sm),
                    _MiniBadge(label: _qualityLabel(move.quality)),
                  ],
                ),
                const SizedBox(height: ApexSpacing.xs),
                Wrap(
                  spacing: ApexSpacing.xs,
                  runSpacing: ApexSpacing.xs,
                  children: [
                    _MiniBadge(label: _sideLabel(move.side)),
                    if (move.hasBetterMove)
                      const _MiniBadge(label: 'better move'),
                    if (move.hasEngineLine)
                      const _MiniBadge(label: 'engine line'),
                    if (move.hasMateWarning)
                      const _MiniBadge(label: 'mate warning'),
                    if (warningCount > 0)
                      _MiniBadge(
                        label:
                            '$warningCount warning${warningCount == 1 ? '' : 's'}',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellActions extends StatelessWidget {
  const _ShellActions({
    required this.viewModel,
    required this.hasPgn,
    required this.onSubmit,
    required this.onRetry,
    required this.onReset,
  });

  final OnlineReviewProductViewModel viewModel;
  final bool hasPgn;
  final VoidCallback onSubmit;
  final Future<void> Function() onRetry;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final primary = _primaryAction();
    final showSecondaryReset =
        viewModel.canReset &&
        viewModel.primaryAction != OnlineReviewProductPrimaryAction.reset;

    return Row(
      children: [
        if (primary != null) Expanded(child: primary),
        if (primary != null && showSecondaryReset)
          const SizedBox(width: ApexSpacing.sm),
        if (showSecondaryReset)
          Expanded(
            child: OutlinedButton.icon(
              key: const ValueKey('online-review-shell-reset'),
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Reset'),
            ),
          ),
      ],
    );
  }

  Widget? _primaryAction() {
    return switch (viewModel.primaryAction) {
      OnlineReviewProductPrimaryAction.none => null,
      OnlineReviewProductPrimaryAction.submit =>
        hasPgn
            ? ElevatedButton.icon(
                key: const ValueKey('online-review-shell-submit'),
                onPressed: viewModel.canSubmit ? onSubmit : null,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Analyze'),
              )
            : null,
      OnlineReviewProductPrimaryAction.retry => ElevatedButton.icon(
        key: const ValueKey('online-review-shell-retry'),
        onPressed: viewModel.canRetry ? () => onRetry() : null,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Retry'),
      ),
      OnlineReviewProductPrimaryAction.reset => OutlinedButton.icon(
        key: const ValueKey('online-review-shell-reset'),
        onPressed: viewModel.canReset ? onReset : null,
        icon: const Icon(Icons.restart_alt_rounded),
        label: const Text('Reset'),
      ),
    };
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 88),
      padding: const EdgeInsets.symmetric(
        horizontal: ApexSpacing.md,
        vertical: ApexSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: ApexColors.nebula.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(ApexRadius.card),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: ApexTypography.monoEval.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: ApexSpacing.xs),
          Text(
            label,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ApexColors.sapphire.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ApexRadius.chip),
        border: Border.all(
          color: ApexColors.sapphireBright.withValues(alpha: 0.24),
          width: 0.6,
        ),
      ),
      child: Text(
        label,
        style: ApexTypography.bodyMedium.copyWith(
          color: ApexColors.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ApexColors.sapphire.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ApexRadius.chip),
        border: Border.all(
          color: ApexColors.sapphireBright.withValues(alpha: 0.28),
          width: 0.6,
        ),
      ),
      child: Text(
        label,
        style: ApexTypography.labelLarge.copyWith(
          color: ApexColors.sapphireBright,
          fontSize: 11,
        ),
      ),
    );
  }
}

BoxDecoration _sectionDecoration({
  Color accent = ApexColors.sapphireBright,
  double accentAlpha = 0.16,
}) {
  return BoxDecoration(
    color: ApexColors.nebula.withValues(alpha: 0.58),
    borderRadius: BorderRadius.circular(ApexRadius.card),
    border: Border.all(
      color: accent.withValues(alpha: accentAlpha),
      width: 0.7,
    ),
  );
}

String _titleFor(String key) {
  return switch (key) {
    'onlineReview.loading.title' => 'Online Review',
    'onlineReview.success.title' => 'Online Review ready',
    'onlineReview.failure.title' => 'Online Review',
    _ => 'Online Review',
  };
}

String? _messageFor(String? key) {
  return switch (key) {
    null => null,
    'onlineReview.failure.validation.emptyPgn' =>
      'Add a PGN before requesting review.',
    'onlineReview.failure.disabled' =>
      'Online Review is currently disabled in this app graph.',
    'onlineReview.failure.timeout' => 'The review request timed out.',
    'onlineReview.failure.network' => 'Could not reach the review service.',
    'onlineReview.failure.invalidPgn' => 'The PGN could not be reviewed.',
    'onlineReview.failure.contract' => 'The review response could not be read.',
    _ => 'Review could not be completed.',
  };
}

String _modeLabel(ApexOnlineReviewMode mode) {
  return switch (mode) {
    ApexOnlineReviewMode.onlineFast => 'Online Fast',
    ApexOnlineReviewMode.onlineDeep => 'Online Deep',
    ApexOnlineReviewMode.dev => 'Dev',
  };
}

String _qualityLabel(ApexMoveQuality quality) {
  return switch (quality) {
    ApexMoveQuality.best => 'Best',
    ApexMoveQuality.excellent => 'Excellent',
    ApexMoveQuality.good => 'Good',
    ApexMoveQuality.inaccuracy => 'Inaccuracy',
    ApexMoveQuality.mistake => 'Mistake',
    ApexMoveQuality.blunder => 'Blunder',
    ApexMoveQuality.unclassified => 'Unclassified',
  };
}

String _moveLabel(OnlineReviewProductMoveViewModel move) {
  return move.san ?? move.uci ?? 'Unknown move';
}

String _sideLabel(String side) {
  return switch (side) {
    'white' => 'White',
    'black' => 'Black',
    _ => side,
  };
}

Color _highlightColor(OnlineReviewProductMoveHighlightLevel level) {
  return switch (level) {
    OnlineReviewProductMoveHighlightLevel.none => ApexColors.subtleBorder,
    OnlineReviewProductMoveHighlightLevel.low => ApexColors.sapphireBright,
    OnlineReviewProductMoveHighlightLevel.medium => ApexColors.inaccuracy,
    OnlineReviewProductMoveHighlightLevel.high => ApexColors.mistake,
    OnlineReviewProductMoveHighlightLevel.critical => ApexColors.rubyBright,
  };
}

Color _noticeColor(OnlineReviewProductNoticeSeverity severity) {
  return switch (severity) {
    OnlineReviewProductNoticeSeverity.info => ApexColors.sapphireBright,
    OnlineReviewProductNoticeSeverity.warning => ApexColors.inaccuracy,
    OnlineReviewProductNoticeSeverity.error => ApexColors.rubyBright,
  };
}

IconData _noticeIcon(OnlineReviewProductNoticeSeverity severity) {
  return switch (severity) {
    OnlineReviewProductNoticeSeverity.info => Icons.info_outline_rounded,
    OnlineReviewProductNoticeSeverity.warning => Icons.warning_amber_rounded,
    OnlineReviewProductNoticeSeverity.error => Icons.error_outline_rounded,
  };
}
