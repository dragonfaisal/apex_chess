library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_screen.dart';
import 'package:apex_chess/features/player_intelligence/domain/player_analytics_models.dart';
import 'package:apex_chess/features/player_intelligence/presentation/controllers/player_intelligence_controller.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

class PlayerIntelligenceScreen extends ConsumerWidget {
  const PlayerIntelligenceScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(playerIntelligenceControllerProvider);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: Column(
            children: [
              _Header(showBackButton: showBackButton),
              Expanded(
                child: analytics.when(
                  loading: () => const _LoadingState(),
                  error: (error, stackTrace) => _ErrorState(
                    onRetry: () => ref
                        .read(playerIntelligenceControllerProvider.notifier)
                        .refresh(),
                  ),
                  data: (snapshot) => snapshot.hasData
                      ? _AnalyticsBody(
                          snapshot: snapshot,
                          onRefresh: () async {
                            ref
                                .read(
                                  playerIntelligenceControllerProvider.notifier,
                                )
                                .refresh();
                            await ref.read(
                              playerIntelligenceControllerProvider.future,
                            );
                          },
                          onOpenExample: (example) =>
                              _openExample(context, ref, example),
                        )
                      : _EmptyState(
                          exclusions: snapshot.manifest.exclusions.length,
                          onRefresh: () => ref
                              .read(
                                playerIntelligenceControllerProvider.notifier,
                              )
                              .refresh(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openExample(
    BuildContext context,
    WidgetRef ref,
    PlayerAnalyticsExample example,
  ) async {
    final game = await ref
        .read(archiveControllerProvider.notifier)
        .resolveExact(example.documentId);
    if (!context.mounted) return;
    if (game == null ||
        game.id != example.documentId ||
        game.canonicalGameId != example.gameId ||
        game.analysisVariantId != example.variantId ||
        !_matchesPersistedExample(game, example)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This saved review is no longer available.'),
        ),
      );
      return;
    }
    final opened = ref
        .read(reviewControllerProvider.notifier)
        .openSavedReview(
          game,
          source: ReviewRuntimeSource.archiveExact,
          initialPly: example.ply,
        );
    if (!opened || !context.mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ReviewScreen()));
  }

  bool _matchesPersistedExample(
    ArchivedGame game,
    PlayerAnalyticsExample example,
  ) {
    final timeline = game.cachedTimeline;
    if (timeline == null ||
        example.ply < 0 ||
        example.ply >= timeline.moves.length) {
      return false;
    }
    final move = timeline.moves[example.ply];
    final insight = move.insight;
    return move.classification == example.classification &&
        insight?.primaryClaim?.type == example.claimType &&
        insight?.primaryClaim?.mechanism == example.mechanism &&
        insight?.conciseText == example.persistedSentence;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.showBackButton});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                'Player Intelligence',
                textAlign: TextAlign.center,
                style: ApexTypography.headlineMedium,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({
    required this.snapshot,
    required this.onRefresh,
    required this.onOpenExample,
  });

  final PlayerAnalyticsSnapshot snapshot;
  final Future<void> Function() onRefresh;
  final ValueChanged<PlayerAnalyticsExample> onOpenExample;

  @override
  Widget build(BuildContext context) {
    final hasExcludedEvidence = snapshot.manifest.exclusions.isNotEmpty;
    final negativePatterns =
        [
            ...snapshot.materialEvents.values,
            ...snapshot.mateEvents.values,
            ...snapshot.tacticalMechanisms.values,
          ].where((event) => event.negativeCount > 0).toList()
          ..sort((a, b) => b.negativeCount.compareTo(a.negativeCount));
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: ApexColors.sapphireBright,
      backgroundColor: ApexColors.nebula,
      child: ListView(
        key: const Key('player-intelligence-scroll'),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _DatasetHero(snapshot: snapshot),
          if (hasExcludedEvidence) ...[
            const SizedBox(height: 12),
            _CoverageNotice(snapshot: snapshot),
          ],
          const SizedBox(height: 18),
          const _SectionTitle(
            title: 'Move profile',
            subtitle: 'Persisted classifier labels with explicit coverage.',
          ),
          const SizedBox(height: 10),
          _DistributionCard(snapshot: snapshot),
          const SizedBox(height: 18),
          const _SectionTitle(
            title: 'Critical error rate',
            subtitle:
                'Blunders, mistakes, and missed wins per 100 eligible moves.',
          ),
          const SizedBox(height: 10),
          _CriticalMetrics(snapshot: snapshot),
          const SizedBox(height: 18),
          const _SectionTitle(
            title: 'Trend',
            subtitle:
                'Equal, non-overlapping recent and previous game windows.',
          ),
          const SizedBox(height: 10),
          _TrendCard(trend: snapshot.trend),
          const SizedBox(height: 18),
          const _SectionTitle(
            title: 'Coaching priorities',
            subtitle: 'Up to three repeated patterns grounded in saved moves.',
          ),
          const SizedBox(height: 10),
          if (snapshot.priorities.isEmpty)
            const _TruthfulPlaceholder(
              key: Key('coaching-priorities-empty'),
              icon: Icons.fact_check_outlined,
              title: 'No priority is supported yet',
              body:
                  'A pattern needs repeated evidence across at least two saved games.',
            )
          else
            for (final priority in snapshot.priorities) ...[
              _PriorityCard(priority: priority, onOpenExample: onOpenExample),
              if (priority != snapshot.priorities.last)
                const SizedBox(height: 10),
            ],
          if (snapshot.reviewQueue.isNotEmpty) ...[
            const SizedBox(height: 18),
            const _SectionTitle(
              title: 'Review these moments',
              subtitle:
                  'A deterministic queue from the published priority evidence.',
            ),
            const SizedBox(height: 10),
            _ReviewQueueCard(
              examples: snapshot.reviewQueue,
              onOpenExample: onOpenExample,
            ),
          ],
          if (negativePatterns.isNotEmpty) ...[
            const SizedBox(height: 18),
            const _SectionTitle(
              title: 'Verified patterns',
              subtitle:
                  'Mechanisms persisted by the accepted insight contract.',
            ),
            const SizedBox(height: 10),
            _PatternCard(patterns: negativePatterns.take(6).toList()),
          ],
          const SizedBox(height: 18),
          const _SectionTitle(
            title: 'Opening transitions',
            subtitle: 'Only verified opening evidence is included.',
          ),
          const SizedBox(height: 10),
          if (snapshot.openings.isEmpty)
            const _TruthfulPlaceholder(
              key: Key('opening-evidence-empty'),
              icon: Icons.menu_book_outlined,
              title: 'No verified opening sample',
              body:
                  'Saved reviews without verified policy-v2 opening evidence are excluded.',
            )
          else
            _OpeningCard(openings: snapshot.openings.take(5).toList()),
          if (snapshot.strength != null) ...[
            const SizedBox(height: 18),
            const _SectionTitle(
              title: 'Supported strength',
              subtitle:
                  'Shown only when repeated positive evidence clears policy.',
            ),
            const SizedBox(height: 10),
            _StrengthCard(strength: snapshot.strength!),
          ],
          const SizedBox(height: 16),
          Text(
            'Snapshot ${snapshot.manifest.snapshotId.substring(0, 10)} · '
            'policy ${snapshot.manifest.policyVersion} · '
            '${snapshot.performance.cacheHit ? 'session cache' : 'derived locally'}',
            textAlign: TextAlign.center,
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

class _DatasetHero extends StatelessWidget {
  const _DatasetHero({required this.snapshot});

  final PlayerAnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      key: const Key('player-intelligence-summary'),
      accentColor: ApexColors.aurora,
      showGlow: true,
      glowIntensity: 0.10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: ApexColors.aurora.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: ApexColors.aurora,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${snapshot.canonicalAnalyzedGames} canonical games',
                      style: ApexTypography.titleMedium,
                    ),
                    Text(
                      '${snapshot.totalPlayerMoves} analyzed player moves',
                      style: ApexTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _EvidenceChip(
                label:
                    '${snapshot.classificationEligibleMoves} classifier-eligible',
              ),
              _EvidenceChip(
                label: '${snapshot.insightEligibleMoves} insight-eligible',
              ),
              _EvidenceChip(
                label: '${snapshot.openingEligibleGames} opening-eligible',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'One deterministic variant per GameId. Player side comes from the '
            'saved review and is never inferred from a username.',
            style: ApexTypography.bodyMedium.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CoverageNotice extends StatelessWidget {
  const _CoverageNotice({required this.snapshot});

  final PlayerAnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final excluded = snapshot.manifest.exclusions.length;
    return Semantics(
      label:
          'Partial evidence. $excluded records or sibling variants were excluded.',
      child: GlassPanel(
        key: const Key('player-intelligence-partial'),
        padding: const EdgeInsets.all(13),
        accentColor: ApexColors.inaccuracy,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: ApexColors.inaccuracy,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Partial evidence · $excluded exclusions. Unsupported, corrupt, '
                'unknown-side, or weaker sibling records do not enter metrics.',
                style: ApexTypography.bodyMedium.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({required this.snapshot});

  final PlayerAnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final entries = [
      for (final quality in MoveQuality.values)
        if (snapshot.classificationDistribution[quality] case final metric?)
          (quality, metric),
    ];
    return GlassPanel(
      key: const Key('classification-distribution'),
      child: Column(
        children: [
          for (final (quality, metric) in entries) ...[
            _MetricBar(quality: quality, metric: metric),
            if ((quality, metric) != entries.last) const SizedBox(height: 11),
          ],
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({required this.quality, required this.metric});

  final MoveQuality quality;
  final PlayerMetric metric;

  @override
  Widget build(BuildContext context) {
    final count = metric.numerator.round();
    final ratio = metric.denominator == 0
        ? 0.0
        : (count / metric.denominator).clamp(0.0, 1.0);
    return Semantics(
      label:
          '${quality.label}: $count of ${metric.denominator} eligible moves, '
          '${metric.rate?.toStringAsFixed(1) ?? 'unavailable'} percent',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  quality.label,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '$count / ${metric.denominator} · '
                  '${metric.rate?.toStringAsFixed(1) ?? '—'}%',
                  textAlign: TextAlign.end,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: ratio,
              color: quality.color,
              backgroundColor: ApexColors.subtleBorder,
            ),
          ),
        ],
      ),
    );
  }
}

class _CriticalMetrics extends StatelessWidget {
  const _CriticalMetrics({required this.snapshot});

  final PlayerAnalyticsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final metrics = snapshot.criticalErrorMetrics.values.toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 620
            ? (constraints.maxWidth - 20) / 3
            : constraints.maxWidth;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: cardWidth,
                child: _MetricValueCard(metric: metric),
              ),
          ],
        );
      },
    );
  }
}

class _MetricValueCard extends StatelessWidget {
  const _MetricValueCard({required this.metric});

  final PlayerMetric metric;

  @override
  Widget build(BuildContext context) {
    final value = metric.denominator == 0
        ? '—'
        : metric.metricId.contains('per-100')
        ? metric.rate!.toStringAsFixed(1)
        : metric.numerator.toStringAsFixed(
            metric.numerator == metric.numerator.roundToDouble() ? 0 : 1,
          );
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      accentColor: ApexColors.ruby,
      child: Semantics(
        label:
            '${metric.displayLabel}: $value, denominator ${metric.denominator}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: ApexTypography.headlineMedium.copyWith(
                color: ApexColors.rubyBright,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              metric.displayLabel,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textPrimary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Eligible denominator: ${metric.denominator}',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.trend});

  final PlayerTrend trend;

  @override
  Widget build(BuildContext context) {
    final (icon, color, title) = switch (trend.state) {
      PlayerAnalyticsTrendState.improving => (
        Icons.trending_down_rounded,
        ApexColors.emerald,
        'Improving',
      ),
      PlayerAnalyticsTrendState.declining => (
        Icons.trending_up_rounded,
        ApexColors.ruby,
        'Needs attention',
      ),
      PlayerAnalyticsTrendState.stable => (
        Icons.trending_flat_rounded,
        ApexColors.sapphireBright,
        'Stable',
      ),
      PlayerAnalyticsTrendState.insufficientEvidence => (
        Icons.hourglass_empty_rounded,
        ApexColors.textTertiary,
        'Not enough evidence',
      ),
    };
    return GlassPanel(
      key: const Key('player-intelligence-trend'),
      accentColor: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ApexTypography.titleMedium),
                const SizedBox(height: 4),
                if (trend.state ==
                    PlayerAnalyticsTrendState.insufficientEvidence)
                  Text(
                    trend.suppressionReason ??
                        'Two comparable windows are required.',
                    style: ApexTypography.bodyMedium.copyWith(fontSize: 12),
                  )
                else
                  Text(
                    '${_rate(trend.previousValue)} → '
                    '${_rate(trend.recentValue)} critical errors per 100 moves · '
                    '${trend.previousGameCount} vs ${trend.recentGameCount} games',
                    style: ApexTypography.bodyMedium.copyWith(fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _rate(double? value) => value?.toStringAsFixed(1) ?? '—';
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({required this.priority, required this.onOpenExample});

  final CoachingPriority priority;
  final ValueChanged<PlayerAnalyticsExample> onOpenExample;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      key: Key('coaching-priority-${priority.priorityId}'),
      accentColor: ApexColors.sapphireBright,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ApexColors.sapphire.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '${priority.rank.severity}',
                  style: ApexTypography.labelLarge.copyWith(
                    color: ApexColors.sapphireBright,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(priority.title, style: ApexTypography.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      '${priority.eventCount} events across '
                      '${priority.gameCount} games · denominator '
                      '${priority.eligibleDenominator}',
                      style: ApexTypography.bodyMedium.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            priority.action,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textPrimary,
            ),
          ),
          if (priority.examples.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < priority.examples.length; index++)
                  OutlinedButton.icon(
                    key: Key('priority-example-${priority.priorityId}-$index'),
                    onPressed: () => onOpenExample(priority.examples[index]),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: Text(
                      'Review move ${priority.examples[index].ply + 1}',
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PatternCard extends StatelessWidget {
  const _PatternCard({required this.patterns});

  final List<PlayerEventSummary> patterns;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        children: [
          for (final pattern in patterns) ...[
            Row(
              children: [
                const Icon(
                  Icons.adjust_rounded,
                  color: ApexColors.inaccuracy,
                  size: 17,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    pattern.displayLabel,
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${pattern.negativeCount} / ${pattern.eligibleMoveCount}',
                  style: ApexTypography.bodyMedium.copyWith(fontSize: 11),
                ),
              ],
            ),
            if (pattern != patterns.last) const Divider(height: 20),
          ],
        ],
      ),
    );
  }
}

class _ReviewQueueCard extends StatelessWidget {
  const _ReviewQueueCard({required this.examples, required this.onOpenExample});

  final List<PlayerAnalyticsExample> examples;
  final ValueChanged<PlayerAnalyticsExample> onOpenExample;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      key: const Key('player-intelligence-review-queue'),
      child: Column(
        children: [
          for (var index = 0; index < examples.length; index++) ...[
            Semantics(
              button: true,
              label:
                  'Open exact saved review at move ${examples[index].ply + 1}, '
                  '${examples[index].classification.label}',
              child: ListTile(
                key: Key('review-queue-example-$index'),
                contentPadding: EdgeInsets.zero,
                minTileHeight: 48,
                leading: Icon(
                  Icons.play_circle_outline_rounded,
                  color: examples[index].classification.color,
                ),
                title: Text(
                  '${examples[index].classification.label} · '
                  'move ${examples[index].ply + 1}',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                  ),
                ),
                subtitle: examples[index].persistedSentence == null
                    ? null
                    : Text(
                        examples[index].persistedSentence!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onOpenExample(examples[index]),
              ),
            ),
            if (index != examples.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _OpeningCard extends StatelessWidget {
  const _OpeningCard({required this.openings});

  final List<PlayerOpeningSummary> openings;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      key: const Key('opening-transition-card'),
      accentColor: ApexColors.book,
      child: Column(
        children: [
          for (final opening in openings) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 44,
                  child: Text(
                    opening.eco,
                    style: ApexTypography.labelLarge.copyWith(
                      color: ApexColors.book,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opening.name,
                        style: ApexTypography.bodyMedium.copyWith(
                          color: ApexColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${opening.gameCount} games · '
                        '${opening.verifiedTheoryMoveCount} verified theory moves'
                        '${opening.medianLeavingTheoryPly == null ? '' : ' · median exit ply ${opening.medianLeavingTheoryPly!.round()}'}',
                        style: ApexTypography.bodyMedium.copyWith(
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (opening != openings.last) const Divider(height: 20),
          ],
        ],
      ),
    );
  }
}

class _StrengthCard extends StatelessWidget {
  const _StrengthCard({required this.strength});

  final SupportedPlayerStrength strength;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accentColor: ApexColors.emerald,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_rounded,
            color: ApexColors.emerald,
            size: 25,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strength.title, style: ApexTypography.titleMedium),
                const SizedBox(height: 3),
                Text(
                  '${strength.evidenceCount} supported events across '
                  '${strength.gameCount} games · denominator '
                  '${strength.denominator}',
                  style: ApexTypography.bodyMedium.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: ApexTypography.titleMedium),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceChip extends StatelessWidget {
  const _EvidenceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: ApexColors.sapphire.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: ApexColors.sapphire.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: ApexTypography.bodyMedium.copyWith(
          color: ApexColors.sapphireBright,
          fontSize: 10.5,
        ),
      ),
    );
  }
}

class _TruthfulPlaceholder extends StatelessWidget {
  const _TruthfulPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ApexColors.textTertiary),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ApexTypography.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: ApexTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Building player intelligence from saved reviews',
        child: const CircularProgressIndicator(
          color: ApexColors.sapphireBright,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      key: const Key('player-intelligence-error'),
      icon: Icons.error_outline_rounded,
      title: 'Stats are unavailable',
      body:
          'Saved reviews could not be read safely. No estimate was substituted.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.exclusions, required this.onRefresh});

  final int exclusions;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      key: const Key('player-intelligence-empty'),
      icon: Icons.insights_outlined,
      title: 'No eligible saved reviews yet',
      body: exclusions == 0
          ? 'Complete a review with an explicit player side to build your stats.'
          : '$exclusions saved records were excluded because their evidence is '
                'legacy, incomplete, corrupt, or has no explicit player side.',
      actionLabel: 'Refresh',
      onAction: onRefresh,
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - 40).clamp(0, double.infinity),
          ),
          child: Center(
            child: GlassPanel(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: ApexColors.sapphireBright, size: 40),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: ApexTypography.titleMedium,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: ApexTypography.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: onAction, child: Text(actionLabel)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
