import 'package:apex_chess/features/analysis/presentation/product_review/analyzer_product_review_surface_foundation.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';

class ProductReviewSurfacePreviewDevWidget extends StatelessWidget {
  const ProductReviewSurfacePreviewDevWidget({
    super.key,
    required this.surface,
    this.enabled = false,
  });

  final AnalyzerProductReviewSurfaceFoundation surface;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return enabled
        ? _ProductReviewSurfacePreviewEnabled(surface: surface)
        : const _ProductReviewSurfacePreviewDisabled();
  }
}

class _ProductReviewSurfacePreviewDisabled extends StatelessWidget {
  const _ProductReviewSurfacePreviewDisabled();

  @override
  Widget build(BuildContext context) {
    return const _PreviewShell(
      key: ValueKey('product-review-surface-preview-dev-disabled'),
      eyebrow: 'Apex Review Preview',
      title: 'Preview disabled',
      message: 'Internal preview is not enabled.',
      child: _SectionCard(
        title: 'Preview state',
        description: 'The isolated surface has no normal app entry point.',
        child: _PreviewRow(label: 'previewSurface', value: 'not active'),
      ),
    );
  }
}

class _ProductReviewSurfacePreviewEnabled extends StatelessWidget {
  const _ProductReviewSurfacePreviewEnabled({required this.surface});

  final AnalyzerProductReviewSurfaceFoundation surface;

  @override
  Widget build(BuildContext context) {
    return _PreviewShell(
      key: ValueKey(
        surface.surfaceReady
            ? 'product-review-surface-preview-dev-ready'
            : 'product-review-surface-preview-dev-unavailable',
      ),
      eyebrow: 'Apex Review Preview',
      title: 'Review preview foundation',
      message: 'Internal, read-only surface for review planning.',
      child: _ProductReviewSurfaceContent(surface: surface),
    );
  }
}

class _ProductReviewSurfaceContent extends StatelessWidget {
  const _ProductReviewSurfaceContent({required this.surface});

  final AnalyzerProductReviewSurfaceFoundation surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReadinessCard(surface: surface),
        const SizedBox(height: ApexSpacing.md),
        _SummaryCard(summary: surface.summary),
        const SizedBox(height: ApexSpacing.md),
        _BoardPreviewCard(board: surface.board),
        const SizedBox(height: ApexSpacing.md),
        _TimelineCard(entries: surface.timelineEntries),
        const SizedBox(height: ApexSpacing.md),
        _GuardrailCard(surface: surface),
      ],
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.surface});

  final AnalyzerProductReviewSurfaceFoundation surface;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Readiness',
      description: 'Planning state from the product-safe surface foundation.',
      trailing: _StatusPill(
        label: surface.surfaceReady ? 'ready' : 'unavailable',
        emphasized: surface.surfaceReady,
      ),
      child: Column(
        children: [
          _ReadinessBanner(surface: surface),
          const SizedBox(height: ApexSpacing.sm),
          _PreviewRow(
            label: 'surfaceReady',
            value: surface.surfaceReady.toString(),
          ),
          _PreviewRow(
            label: 'unavailableReason',
            value: surface.unavailableReason.wire,
          ),
          _PreviewRow(label: 'title', value: surface.header.surfaceTitle),
          _PreviewRow(label: 'readiness', value: surface.header.readiness),
          _PreviewRow(label: 'scope', value: surface.header.scope.wire),
          _PreviewRow(
            label: 'evidenceStrength',
            value: surface.header.evidenceStrength.wire,
          ),
          _PreviewRow(
            label: 'productSafeStatus',
            value: surface.header.productSafeStatus,
          ),
        ],
      ),
    );
  }
}

class _ReadinessBanner extends StatelessWidget {
  const _ReadinessBanner({required this.surface});

  final AnalyzerProductReviewSurfaceFoundation surface;

  @override
  Widget build(BuildContext context) {
    final ready = surface.surfaceReady;
    return Semantics(
      label: ready
          ? 'Review preview ready for planning'
          : 'Review preview unavailable',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ready
              ? ApexColors.sapphire.withValues(alpha: 0.12)
              : ApexColors.nebula.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ready
                ? ApexColors.sapphireBright.withValues(alpha: 0.38)
                : ApexColors.subtleBorder,
            width: 0.7,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ApexSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ready ? 'Ready for planning' : 'Surface unavailable',
                style: ApexTypography.titleMedium.copyWith(
                  color: ApexColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: ApexSpacing.xs),
              Text(
                ready
                    ? 'Read-only evidence is available; rendering remains blocked.'
                    : 'The preview is blocked until the source surface is safe.',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final AnalyzerProductReviewSummaryFoundation summary;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Internal counts',
      description:
          'Private candidate breakdown preserved from the review chain.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: ApexSpacing.sm,
            runSpacing: ApexSpacing.sm,
            children: [
              _CountTile(
                label: 'totalPrivateEntries',
                value: summary.totalPrivateEntries,
              ),
              _CountTile(
                label: 'positiveCandidateCount',
                value: summary.positiveCandidateCount,
              ),
              _CountTile(
                label: 'neutralCandidateCount',
                value: summary.neutralCandidateCount,
              ),
              _CountTile(
                label: 'negativeCandidateCount',
                value: summary.negativeCandidateCount,
              ),
              _CountTile(
                label: 'unavailableCount',
                value: summary.unavailableCount,
              ),
            ],
          ),
          const SizedBox(height: ApexSpacing.sm),
          _PreviewRow(
            label: 'public labels guard',
            value: _blockedValue(summary.publicLabelsBlocked),
          ),
          _PreviewRow(
            label: 'official metrics guard',
            value: _blockedValue(summary.officialMetricsBlocked),
          ),
          _PreviewRow(
            label: 'saved/archive guard',
            value: _blockedValue(summary.savedArchiveBlocked),
          ),
        ],
      ),
    );
  }
}

class _BoardPreviewCard extends StatelessWidget {
  const _BoardPreviewCard({required this.board});

  final AnalyzerProductReviewBoardSafeFoundation board;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Board preview',
      description: 'Board rendering is intentionally blocked in this preview.',
      trailing: const _StatusPill(label: 'blocked'),
      child: Column(
        children: [
          _PreviewRow(
            label: 'boardPreviewAvailable',
            value: board.boardPreviewAvailable.toString(),
          ),
          _PreviewRow(
            label: 'boardPreviewReason',
            value: board.boardPreviewReason.wire,
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.entries});

  final List<AnalyzerProductReviewSurfaceTimelineEntryFoundation> entries;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Timeline entries',
      description: 'Internal-only entry shape for future review consumption.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (entries.isEmpty)
            const _TimelineEmptyState()
          else
            for (final indexed in entries.indexed)
              _TimelineEntryRow(index: indexed.$1, entry: indexed.$2),
        ],
      ),
    );
  }
}

class _TimelineEmptyState extends StatelessWidget {
  const _TimelineEmptyState();

  @override
  Widget build(BuildContext context) {
    return const _PreviewRow(label: 'timelineEntryKind', value: 'none');
  }
}

class _TimelineEntryRow extends StatelessWidget {
  const _TimelineEntryRow({required this.index, required this.entry});

  final int index;
  final AnalyzerProductReviewSurfaceTimelineEntryFoundation entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: index == 0 ? 0 : ApexSpacing.sm),
      padding: const EdgeInsets.all(ApexSpacing.md),
      decoration: BoxDecoration(
        color: ApexColors.nebula.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ApexColors.stardustLine.withValues(alpha: 0.42),
          width: 0.7,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Entry ${index + 1}',
                  style: ApexTypography.titleMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              _StatusPill(
                label: entry.entryReady ? 'ready' : 'unavailable',
                emphasized: entry.entryReady,
              ),
            ],
          ),
          const SizedBox(height: ApexSpacing.sm),
          _PreviewRow(label: 'timelineEntryKind', value: entry.entryKind.wire),
          _PreviewRow(label: 'entryReady', value: entry.entryReady.toString()),
          _PreviewRow(
            label: 'entryInternalOnly',
            value: entry.entryIsInternalOnly.toString(),
          ),
          _PreviewRow(
            label: 'entryPublicLabelGuard',
            value: _blockedValue(!entry.entryContainsPublicLabel),
          ),
          _PreviewRow(
            label: 'entryOfficialMetricGuard',
            value: _blockedValue(!entry.entryContainsOfficialMetric),
          ),
        ],
      ),
    );
  }
}

class _GuardrailCard extends StatelessWidget {
  const _GuardrailCard({required this.surface});

  final AnalyzerProductReviewSurfaceFoundation surface;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Guardrails',
      description:
          'Unsafe product surfaces remain blocked at the preview edge.',
      child: Column(
        children: [
          _PreviewRow(
            label: 'UI rendering',
            value: _guardrailValue(surface.uiRenderingAllowed),
          ),
          _PreviewRow(
            label: 'Public labels',
            value: _guardrailValue(surface.publicLabelsAllowed),
          ),
          _PreviewRow(
            label: 'Official metrics',
            value: _guardrailValue(surface.officialMetricsAllowed),
          ),
          _PreviewRow(
            label: 'Saved/archive',
            value: _guardrailValue(
              surface.savedAnalysisAllowed || surface.archiveStatsAllowed,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewShell extends StatelessWidget {
  const _PreviewShell({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.message,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ApexColors.deepSpace,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Semantics(
                label: 'Apex product review developer preview',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(ApexSpacing.lg),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _PreviewHero(
                              eyebrow: eyebrow,
                              title: title,
                              message: message,
                            ),
                            const SizedBox(height: ApexSpacing.md),
                            child,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PreviewHero extends StatelessWidget {
  const _PreviewHero({
    required this.eyebrow,
    required this.title,
    required this.message,
  });

  final String eyebrow;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ApexColors.nebula.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ApexColors.sapphire.withValues(alpha: 0.35),
          width: 0.7,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ApexSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              eyebrow,
              style: ApexTypography.labelLarge.copyWith(
                color: ApexColors.sapphireBright,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: ApexSpacing.xs),
            Text(
              title,
              style: ApexTypography.headlineMedium.copyWith(
                color: ApexColors.textPrimary,
              ),
            ),
            const SizedBox(height: ApexSpacing.sm),
            Text(
              message,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.description,
    this.trailing,
  });

  final String title;
  final String? description;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: title,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ApexColors.cardSurface.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ApexColors.subtleBorder, width: 0.7),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ApexSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: ApexTypography.titleMedium.copyWith(
                        color: ApexColors.textPrimary,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: ApexSpacing.xs),
                Text(
                  description!,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: ApexSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, this.emphasized = false});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: emphasized
            ? ApexColors.sapphire.withValues(alpha: 0.16)
            : ApexColors.nebula.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: emphasized
              ? ApexColors.sapphireBright.withValues(alpha: 0.56)
              : ApexColors.subtleBorder,
          width: 0.7,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ApexSpacing.md,
          vertical: 6,
        ),
        child: Text(
          label,
          style: ApexTypography.bodyMedium.copyWith(
            color: emphasized
                ? ApexColors.sapphireBright
                : ApexColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      child: SizedBox(
        width: 156,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ApexColors.deepSpace.withValues(alpha: 0.44),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ApexColors.stardustLine.withValues(alpha: 0.48),
              width: 0.7,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ApexSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: ApexTypography.headlineMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 22,
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
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: ApexSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _guardrailValue(bool sourceAllowsUnsafeSurface) {
  return sourceAllowsUnsafeSurface ? 'blocked by preview' : 'blocked';
}

String _blockedValue(bool blocked) {
  return blocked ? 'blocked' : 'blocked by preview';
}
