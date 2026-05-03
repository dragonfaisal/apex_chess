/// Global Dashboard — multi-chart analytics across the user's entire
/// archive. Corporate-analytics feel: hero KPI cards, accuracy trend,
/// move-quality distribution, result split, and a paginated recent-
/// games table. Everything reads from the local Hive archive — no
/// network, no engine, instant.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_quality_display.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/archives/presentation/views/archive_screen.dart';
import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';
import 'package:apex_chess/features/profile_stats/presentation/controllers/profile_stats_controller.dart';
import 'package:apex_chess/features/global_dashboard/presentation/models/recent_scan_display.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';
import 'package:apex_chess/shared_ui/widgets/apex_game_card.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

import '../controllers/dashboard_controller.dart';

class GlobalDashboardScreen extends ConsumerWidget {
  const GlobalDashboardScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(liveProfileStatsProvider, (previous, next) {
      final account = ref.read(accountControllerProvider).valueOrNull;
      if (account == null) return;
      next.whenData((stats) {
        if (stats == null) return;
        if (stats.hasData) {
          final service = ref
              .read(serviceHealthServiceProvider)
              .serviceForProfileSource(
                account.source == AccountSource.chessCom
                    ? ProfileStatsSource.chessCom
                    : ProfileStatsSource.lichess,
              );
          ref
              .read(connectionPresenceProvider.notifier)
              .markServiceAvailable(service);
        }
      });
    });
    final stats = ref.watch(dashboardStatsProvider);
    final allStats = ref.watch(dashboardAllStatsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: Column(
            children: [
              _AppBar(showBackButton: showBackButton),
              Expanded(
                child: RefreshIndicator(
                  color: ApexColors.sapphireBright,
                  backgroundColor: ApexColors.nebula,
                  onRefresh: () => _refreshStats(ref),
                  child: allStats.hasData
                      ? _DashboardBody(stats: stats)
                      : const _EmptyState(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _refreshStats(WidgetRef ref) async {
  await ref
      .read(connectionPresenceProvider.notifier)
      .refresh(showSyncing: true);
  await ref.read(archiveControllerProvider.notifier).refresh();
  try {
    final _ = await ref.refresh(liveProfileStatsProvider.future);
  } catch (_) {
    // The card already renders the service state; pull-to-refresh should
    // settle without surfacing a second error path.
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.showBackButton});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: ApexColors.textSecondary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              ApexCopy.dashboardTitle,
              textAlign: TextAlign.center,
              style: ApexTypography.titleMedium.copyWith(
                color: ApexColors.textPrimary,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProfileStatsCard(),
          const SizedBox(height: 14),
          const _PlayerSearchCard(),
          const SizedBox(height: 14),
          GlassPanel(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            accentColor: ApexColors.sapphire,
            accentAlpha: 0.18,
            child: Column(
              children: [
                Icon(
                  Icons.insights_rounded,
                  size: 44,
                  color: ApexColors.sapphire.withValues(alpha: 0.72),
                ),
                const SizedBox(height: 14),
                Text(
                  ApexCopy.dashboardEmptyTitle,
                  textAlign: TextAlign.center,
                  style: ApexTypography.titleMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ApexCopy.dashboardEmpty,
                  textAlign: TextAlign.center,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ApexCopy.dashboardEmptyHint,
                  textAlign: TextAlign.center,
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

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(dashboardColorFilterProvider);
    final filterOnlyEmpty =
        !stats.hasData && activeFilter != ColorPerspective.all;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ApexCopy.dashboardSubtitle,
            textAlign: TextAlign.center,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 12,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 16),
          const _ProfileStatsCard(),
          const SizedBox(height: 14),
          const _PlayerSearchCard(),
          const SizedBox(height: 14),
          const _ColorFilterBar(),
          const SizedBox(height: 12),
          const _DashboardInlineNotice(),
          const SizedBox(height: 12),
          if (filterOnlyEmpty)
            _FilterEmptyNotice(filter: activeFilter)
          else ...[
            _AnalyzedSectionLabel(stats: stats),
            const SizedBox(height: 10),
            _KpiRow(stats: stats),
            const SizedBox(height: 18),
            _AccuracyTrendCard(stats: stats),
            const SizedBox(height: 14),
            _QualityPieCard(stats: stats),
            const SizedBox(height: 14),
            _ResultSplitCard(stats: stats),
            const SizedBox(height: 14),
            const _OpeningStatsCard(),
            const SizedBox(height: 18),
            const _RecentGamesTable(),
          ],
        ],
      ),
    );
  }
}

class _FilterEmptyNotice extends StatelessWidget {
  const _FilterEmptyNotice({required this.filter});

  final ColorPerspective filter;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      ColorPerspective.white => 'White',
      ColorPerspective.black => 'Black',
      ColorPerspective.all => 'All',
    };
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      accentColor: ApexColors.sapphireBright,
      accentAlpha: 0.16,
      child: Row(
        children: [
          Icon(
            Icons.filter_alt_off_rounded,
            color: ApexColors.sapphireBright.withValues(alpha: 0.78),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No $label reviews yet.',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Switch to All to view your analyzed games.',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary,
                    fontSize: 11.5,
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

// ── Color filter ──────────────────────────────────────────────────────

class _ColorFilterBar extends ConsumerWidget {
  const _ColorFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(dashboardColorFilterProvider);
    return GlassPanel(
      padding: const EdgeInsets.all(4),
      accentColor: ApexColors.sapphire,
      child: Row(
        children: [
          for (final p in ColorPerspective.values)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(dashboardColorFilterProvider.notifier).state = p;
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: active == p ? ApexGradients.sapphire : null,
                    color: active == p ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    switch (p) {
                      ColorPerspective.all => 'ALL',
                      ColorPerspective.white => 'WHITE',
                      ColorPerspective.black => 'BLACK',
                    },
                    style: ApexTypography.bodyMedium.copyWith(
                      color: active == p
                          ? ApexColors.textPrimary
                          : ApexColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Profile Stats card ────────────────────────────────────────────────

class _ProfileStatsCard extends ConsumerWidget {
  const _ProfileStatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(liveProfileStatsProvider);
    final account = ref.watch(accountControllerProvider).valueOrNull;
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      accentColor: ApexColors.aurora,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: ApexCopy.dashboardPublicAccountStats.toUpperCase(),
            subtitle: 'Chess.com / Lichess public ratings.',
            accent: ApexColors.aurora,
          ),
          const SizedBox(height: 12),
          async.when(
            loading: () => _profileLoading(),
            error: (_, __) => _profileFallback(ApexCopy.noConnection),
            data: (stats) {
              if (stats == null) {
                return _profileFallback('Connect a handle');
              }
              if (!stats.hasData) {
                return _profileFallback(
                  '@${account?.username ?? stats.displayName}\n'
                  '${ApexCopy.showingSavedData}',
                );
              }
              return _profileBody(stats);
            },
          ),
        ],
      ),
    );
  }

  Widget _profileLoading() =>
      const ApexSkeletonCard(height: 76, margin: EdgeInsets.zero);

  Widget _profileFallback(String msg) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(
      msg,
      style: ApexTypography.bodyMedium.copyWith(
        color: ApexColors.textTertiary,
        fontSize: 12,
      ),
    ),
  );

  Widget _profileBody(ProfileStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '@${stats.displayName}',
          style: ApexTypography.titleMedium.copyWith(
            color: ApexColors.textPrimary,
            fontSize: 14,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final b in stats.buckets)
              Expanded(
                child: _RatingTile(label: b.label, rating: b.rating),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SmallStat(
                label: 'GAMES',
                value: '${stats.totalGames}',
                color: ApexColors.sapphireBright,
              ),
            ),
            Expanded(
              child: _SmallStat(
                label: 'WIN',
                value: '${stats.totalWins}',
                color: ApexColors.emeraldBright,
              ),
            ),
            Expanded(
              child: _SmallStat(
                label: 'LOSS',
                value: '${stats.totalLosses}',
                color: ApexColors.ruby,
              ),
            ),
            Expanded(
              child: _SmallStat(
                label: 'WIN%',
                value: '${stats.winRate.toStringAsFixed(1)}%',
                color: ApexColors.aurora,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayerSearchCard extends ConsumerStatefulWidget {
  const _PlayerSearchCard();

  @override
  ConsumerState<_PlayerSearchCard> createState() => _PlayerSearchCardState();
}

class _PlayerSearchCardState extends ConsumerState<_PlayerSearchCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(dashboardPlayerSearchProvider).username,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardPlayerSearchProvider);
    final notifier = ref.read(dashboardPlayerSearchProvider.notifier);
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      accentColor: ApexColors.sapphireBright,
      accentAlpha: 0.24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: ApexCopy.dashboardPlayerSearchTitle,
            subtitle: ApexCopy.dashboardPlayerSearchSubtitle,
            accent: ApexColors.sapphireBright,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SearchSourceChip(
                label: ApexCopy.importSourceChessCom,
                selected: state.source == ProfileStatsSource.chessCom,
                onTap: () => notifier.setSource(ProfileStatsSource.chessCom),
              ),
              const SizedBox(width: 8),
              _SearchSourceChip(
                label: ApexCopy.importSourceLichess,
                selected: state.source == ProfileStatsSource.lichess,
                onTap: () => notifier.setSource(ProfileStatsSource.lichess),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  cursorColor: ApexColors.sapphireBright,
                  autofillHints: const [],
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: (value) {
                    notifier.setUsername(value);
                    setState(() {});
                  },
                  onSubmitted: (_) => notifier.search(),
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: ApexCopy.dashboardPlayerSearchHint,
                    prefixIcon: const Icon(
                      Icons.person_search_rounded,
                      size: 17,
                      color: ApexColors.sapphireBright,
                    ),
                    suffixIcon: _controller.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: ApexCopy.clear,
                            onPressed: () {
                              _controller.clear();
                              notifier.setUsername('');
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 17,
                              color: ApexColors.textTertiary,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: state.isLoading ? null : notifier.search,
                child: Text(
                  state.isLoading ? ApexCopy.checking : ApexCopy.search,
                ),
              ),
            ],
          ),
          if (state.isLoading) ...[
            const SizedBox(height: 12),
            const ApexSkeletonCard(height: 70, margin: EdgeInsets.zero),
          ] else if (state.result != null) ...[
            const SizedBox(height: 12),
            _SearchedPlayerDashboard(stats: state.result!),
          ] else if (state.hasSearched) ...[
            const SizedBox(height: 12),
            _SmallNotice(
              icon: Icons.info_outline_rounded,
              title: state.error ?? ApexCopy.dashboardNoPublicData,
              subtitle: ApexCopy.dashboardNoGamesFound,
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchSourceChip extends StatelessWidget {
  const _SearchSourceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? ApexColors.sapphire.withValues(alpha: 0.18)
                : ApexColors.nebula.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? ApexColors.sapphireBright.withValues(alpha: 0.62)
                  : ApexColors.stardustLine.withValues(alpha: 0.32),
              width: 0.7,
            ),
          ),
          child: Text(
            label,
            style: ApexTypography.bodyMedium.copyWith(
              color: selected
                  ? ApexColors.sapphireBright
                  : ApexColors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchedPlayerDashboard extends StatelessWidget {
  const _SearchedPlayerDashboard({required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    if (!stats.hasData) {
      return const _SmallNotice(
        icon: Icons.info_outline_rounded,
        title: ApexCopy.dashboardNoPublicData,
        subtitle: ApexCopy.dashboardNoGamesFound,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SmallNotice(
          icon: Icons.account_circle_outlined,
          title: '@${stats.displayName}',
          subtitle: ApexCopy.dashboardAccountOverview,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final bucket in stats.buckets)
              Expanded(
                child: _RatingTile(label: bucket.label, rating: bucket.rating),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _SmallStat(
                label: 'GAMES',
                value: '${stats.totalGames}',
                color: ApexColors.sapphireBright,
              ),
            ),
            Expanded(
              child: _SmallStat(
                label: 'WINS',
                value: '${stats.totalWins}',
                color: ApexColors.emeraldBright,
              ),
            ),
            Expanded(
              child: _SmallStat(
                label: 'LOSSES',
                value: '${stats.totalLosses}',
                color: ApexColors.ruby,
              ),
            ),
            Expanded(
              child: _SmallStat(
                label: 'DRAWS',
                value: '${stats.totalDraws}',
                color: ApexColors.inaccuracy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          ApexCopy.dashboardPublicSections,
          textAlign: TextAlign.center,
          style: ApexTypography.bodyMedium.copyWith(
            color: ApexColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _DashboardInlineNotice extends ConsumerWidget {
  const _DashboardInlineNotice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(dashboardInlineNoticeProvider);
    if (notice == null) return const SizedBox.shrink();
    return _SmallNotice(
      icon: Icons.info_outline_rounded,
      title: notice,
      subtitle: null,
    );
  }
}

class _SmallNotice extends StatelessWidget {
  const _SmallNotice({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: ApexColors.nebula.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: ApexColors.sapphireBright),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingTile extends StatelessWidget {
  const _RatingTile({required this.label, required this.rating});

  final String label;
  final int? rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.6),
      ),
      child: Column(
        children: [
          Text(
            rating?.toString() ?? '—',
            style: ApexTypography.headlineMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 9,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStat extends StatelessWidget {
  const _SmallStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: ApexTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: ApexTypography.bodyMedium.copyWith(
            color: ApexColors.textTertiary,
            fontSize: 9,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ── Opening stats ────────────────────────────────────────────────────

class _OpeningStatsCard extends ConsumerWidget {
  const _OpeningStatsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openings = ref.watch(openingStatsProvider);
    final revisit = ref.watch(academyRevisitQueueProvider);
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      accentColor: ApexColors.sapphireBright,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'OPENING PERFORMANCE',
            subtitle:
                'Top lines by frequency — Apex Academy prioritises your weakest.',
            accent: ApexColors.sapphireBright,
          ),
          const SizedBox(height: 12),
          if (openings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Scan a few games to unlock opening analytics.',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            )
          else ...[
            for (final o in openings.take(6)) _OpeningRow(stats: o),
            if (revisit.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ApexColors.sapphireBright.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ApexColors.sapphireBright.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REVISIT QUEUE',
                      style: ApexTypography.bodyMedium.copyWith(
                        color: ApexColors.sapphireBright,
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (final o in revisit)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '• ${o.name} — ${o.lossRate.toStringAsFixed(0)}% loss · ${o.total} games',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ApexTypography.bodyMedium.copyWith(
                            color: ApexColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _OpeningRow extends StatelessWidget {
  const _OpeningRow({required this.stats});
  final OpeningStats stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${stats.eco ?? "—"} · ${stats.total} games',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          _OpeningBar(stats: stats),
          const SizedBox(width: 10),
          SizedBox(
            width: 46,
            child: Text(
              '${stats.winRate.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: ApexTypography.bodyMedium.copyWith(
                color: stats.winRate >= 50
                    ? ApexColors.emeraldBright
                    : ApexColors.ruby,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpeningBar extends StatelessWidget {
  const _OpeningBar({required this.stats});
  final OpeningStats stats;

  @override
  Widget build(BuildContext context) {
    final total = stats.total == 0 ? 1 : stats.total;
    final winFrac = stats.wins / total;
    final drawFrac = stats.draws / total;
    return SizedBox(
      width: 80,
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: [
            Expanded(
              flex: (winFrac * 100).round().clamp(0, 100),
              child: Container(color: ApexColors.emeraldBright),
            ),
            Expanded(
              flex: (drawFrac * 100).round().clamp(0, 100),
              child: Container(color: ApexColors.textTertiary),
            ),
            Expanded(
              flex: ((1 - winFrac - drawFrac) * 100).round().clamp(0, 100),
              child: Container(color: ApexColors.ruby),
            ),
          ],
        ),
      ),
    );
  }
}

// ── KPI row ────────────────────────────────────────────────────────────

class _KpiRow extends ConsumerWidget {
  const _KpiRow({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = <Widget>[
      _KpiCard(
        label: 'Games',
        value: '${stats.gamesAnalyzed}',
        accent: ApexColors.sapphire,
        icon: Icons.analytics_rounded,
        onTap: () => _openArchive(context, ref, const ArchiveFilters()),
      ),
      _KpiCard(
        label: 'Avg Accuracy',
        value: '${stats.averageAccuracy.toStringAsFixed(1)}%',
        accent: ApexColors.emerald,
        icon: Icons.auto_graph_rounded,
      ),
      _KpiCard(
        label: 'Brilliants',
        value: '${stats.totalBrilliants}',
        accent: ApexColors.aurora,
        icon: Icons.auto_awesome_rounded,
        onTap: () {
          if (stats.totalBrilliants <= 0) {
            ref.read(dashboardInlineNoticeProvider.notifier).state =
                'No Brilliant reviews yet';
            return;
          }
          _openArchive(context, ref, const ArchiveFilters(minBrilliants: 1));
        },
      ),
      _KpiCard(
        label: 'Blunders',
        value: '${stats.totalBlunders}',
        accent: ApexColors.ruby,
        icon: Icons.error_outline_rounded,
        onTap: () {
          if (stats.totalBlunders <= 0) {
            ref.read(dashboardInlineNoticeProvider.notifier).state =
                'No Blunder reviews yet';
            return;
          }
          _openArchive(
            context,
            ref,
            const ArchiveFilters(sort: ArchiveSort.mostBlunders),
          );
        },
      ),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        // Auto-wrap into 2×2 on narrow phones, 1×4 on tablets / desktop.
        final crossAxisCount = box.maxWidth >= 640 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: crossAxisCount == 4 ? 1.35 : 1.55,
          children: cards,
        );
      },
    );
  }

  void _openArchive(
    BuildContext context,
    WidgetRef ref,
    ArchiveFilters filters,
  ) {
    ref.read(dashboardInlineNoticeProvider.notifier).state = null;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArchiveScreen(initialFilters: filters),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      accentColor: accent,
      accentAlpha: 0.45,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ApexRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: accent),
              Text(
                value,
                style: ApexTypography.headlineMedium.copyWith(
                  color: ApexColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              Text(
                label.toUpperCase(),
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Accuracy trend ─────────────────────────────────────────────────────

class _AccuracyTrendCard extends StatelessWidget {
  const _AccuracyTrendCard({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      accentColor: ApexColors.emerald,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'ACCURACY TREND',
            subtitle: 'Higher is better — one point per analysed game.',
            accent: ApexColors.emerald,
          ),
          const SizedBox(height: 10),
          SizedBox(height: 160, child: LineChart(_data(stats.accuracyTrend))),
        ],
      ),
    );
  }

  LineChartData _data(List<double> trend) {
    final spots = <FlSpot>[];
    for (var i = 0; i < trend.length; i++) {
      spots.add(FlSpot(i.toDouble(), trend[i]));
    }
    final maxX = spots.isEmpty
        ? 1.0
        : (spots.length - 1).toDouble().clamp(1.0, double.infinity);
    return LineChartData(
      minY: 0,
      maxY: 100,
      minX: 0,
      maxX: maxX,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (value) => FlLine(
          color: ApexColors.stardustLine.withValues(alpha: 0.35),
          strokeWidth: 0.6,
          dashArray: const [4, 4],
        ),
      ),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => ApexColors.cosmicDust,
          getTooltipItems: (items) => items
              .map(
                (s) => LineTooltipItem(
                  '${s.y.toStringAsFixed(1)}%',
                  ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 11,
                  ),
                ),
              )
              .toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          barWidth: 2.4,
          color: ApexColors.emeraldBright,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ApexColors.emerald.withValues(alpha: 0.45),
                ApexColors.emerald.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quality pie ────────────────────────────────────────────────────────

class _QualityPieCard extends StatelessWidget {
  const _QualityPieCard({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final entries =
        stats.qualityDistribution.entries
            .where((e) => e.value > 0 && e.key != MoveQuality.book)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    final legendItems = entries
        .map(
          (e) => _LegendChip(
            color: _qualityColor(e.key),
            label: _qualityLabel(e.key),
            count: e.value,
            percent: total == 0 ? 0 : e.value / total,
          ),
        )
        .toList();

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      accentColor: ApexColors.sapphire,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'MOVE QUALITY',
            subtitle: 'Aggregate distribution across every ply scanned.',
            accent: ApexColors.sapphire,
          ),
          const SizedBox(height: 12),
          // ── Responsive: pie + legend-column side-by-side on ≥ 420 dp,
          // stacked (pie above, wrapping legend grid below) on narrower
          // phones. The old fixed-height Row with `flex: 6` on the
          // legend overflowed both vertically (7 chips / 170 dp) and
          // horizontally (label + count cramped into ~100 dp).
          LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 420;
              if (wide) {
                return SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 5, child: _buildPie(entries)),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 7,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: legendItems,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 170, child: _buildPie(entries)),
                  const SizedBox(height: 10),
                  // Two-column wrap keeps every chip inside the card even
                  // on 320 dp widths, and each chip is its own Intrinsic
                  // so the "· %" trailing figure never collides with the
                  // label.
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: legendItems
                        .map(
                          (chip) => SizedBox(
                            width: (box.maxWidth - 8) / 2,
                            child: chip,
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPie(List<MapEntry<MoveQuality, int>> entries) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 36,
        startDegreeOffset: -90,
        sections: entries.isEmpty
            ? []
            : entries
                  .map(
                    (e) => PieChartSectionData(
                      value: e.value.toDouble(),
                      color: _qualityColor(e.key),
                      radius: 42,
                      title: '',
                    ),
                  )
                  .toList(),
      ),
    );
  }

  Color _qualityColor(MoveQuality q) => switch (q) {
    MoveQuality.brilliant => ApexColors.brilliant,
    MoveQuality.great => ApexColors.brilliant,
    MoveQuality.best => ApexColors.best,
    MoveQuality.excellent => ApexColors.great,
    MoveQuality.good => ApexColors.sapphireDeep,
    MoveQuality.forced => ApexColors.textSecondary,
    MoveQuality.inaccuracy => ApexColors.inaccuracy,
    MoveQuality.missedWin => ApexColors.mistake,
    MoveQuality.mistake => ApexColors.mistake,
    MoveQuality.blunder => ApexColors.blunder,
    MoveQuality.book => ApexColors.book,
  };

  String _qualityLabel(MoveQuality q) => switch (q) {
    MoveQuality.forced => 'Best',
    _ => MoveQualityDisplay.labelTextForQuality(q),
  };
}

class _AnalyzedSectionLabel extends StatelessWidget {
  const _AnalyzedSectionLabel({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      accentColor: ApexColors.sapphireBright,
      child: Row(
        children: [
          const Icon(
            Icons.analytics_outlined,
            color: ApexColors.sapphireBright,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              stats.gamesAnalyzed < 5
                  ? 'APEX ANALYZED STATS • Preliminary stats'
                  : 'APEX ANALYZED STATS',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    required this.count,
    required this.percent,
  });

  final Color color;
  final String label;
  final int count;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ),
          Text(
            '$count · ${(percent * 100).toStringAsFixed(0)}%',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 11,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result split ───────────────────────────────────────────────────────

class _ResultSplitCard extends ConsumerWidget {
  const _ResultSplitCard({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPerspective =
        stats.perspective != null && stats.perspective!.isNotEmpty;
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      accentColor: ApexColors.ruby,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'RESULT SPLIT',
            subtitle: hasPerspective
                ? 'From @${stats.perspective!}.'
                : 'Connect an account to resolve W/L/D.',
            accent: ApexColors.ruby,
          ),
          const SizedBox(height: 14),
          if (!hasPerspective)
            Text(
              'Connect an account to show results.',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 11.5,
              ),
            )
          else ...[
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: [stats.wins, stats.draws, stats.losses]
                      .fold<int>(0, (m, v) => v > m ? v : m)
                      .toDouble()
                      .clamp(1, double.infinity),
                  barTouchData: BarTouchData(enabled: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, meta) {
                          final label = switch (v.toInt()) {
                            0 => 'Wins',
                            1 => 'Draws',
                            2 => 'Losses',
                            _ => '',
                          };
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label,
                              style: ApexTypography.bodyMedium.copyWith(
                                color: ApexColors.textTertiary,
                                fontSize: 10.5,
                                letterSpacing: 0.6,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    _bar(0, stats.wins.toDouble(), ApexColors.emerald),
                    _bar(1, stats.draws.toDouble(), ApexColors.sapphire),
                    _bar(2, stats.losses.toDouble(), ApexColors.ruby),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ResultShortcut(
                  label: 'Wins',
                  count: stats.wins,
                  color: ApexColors.emerald,
                  onTap: () => _openResultArchive(
                    context,
                    ref,
                    ArchiveResultFilter.wins,
                    stats.wins,
                    'No wins yet',
                  ),
                ),
                const SizedBox(width: 8),
                _ResultShortcut(
                  label: 'Draws',
                  count: stats.draws,
                  color: ApexColors.sapphire,
                  onTap: () => _openResultArchive(
                    context,
                    ref,
                    ArchiveResultFilter.draws,
                    stats.draws,
                    'No draws yet',
                  ),
                ),
                const SizedBox(width: 8),
                _ResultShortcut(
                  label: 'Losses',
                  count: stats.losses,
                  color: ApexColors.ruby,
                  onTap: () => _openResultArchive(
                    context,
                    ref,
                    ArchiveResultFilter.losses,
                    stats.losses,
                    'No losses yet',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) => BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        width: 28,
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [color.withValues(alpha: 0.55), color],
        ),
      ),
    ],
  );

  void _openResultArchive(
    BuildContext context,
    WidgetRef ref,
    ArchiveResultFilter result,
    int count,
    String emptyNotice,
  ) {
    if (count <= 0) {
      ref.read(dashboardInlineNoticeProvider.notifier).state = emptyNotice;
      return;
    }
    ref.read(dashboardInlineNoticeProvider.notifier).state = null;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArchiveScreen(
          initialFilters: ArchiveFilters(
            result: result,
            perspective: stats.perspective,
          ),
        ),
      ),
    );
  }
}

class _ResultShortcut extends StatelessWidget {
  const _ResultShortcut({
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.28),
              width: 0.5,
            ),
          ),
          child: Text(
            '$label $count',
            style: ApexTypography.bodyMedium.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Recent games table ─────────────────────────────────────────────────

class _RecentGamesTable extends ConsumerWidget {
  const _RecentGamesTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slice = ref.watch(dashboardVisibleGamesProvider);
    final page = ref.watch(dashboardPageProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final total = stats.gamesAnalyzed;
    final perspective = stats.perspective;
    final hasPrev = page > 0;
    final hasNext = (page + 1) * dashboardPageSize < total;

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      accentColor: ApexColors.sapphire,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'RECENT SCANS',
            subtitle: 'Page ${page + 1} • ${slice.length}/$total shown.',
            accent: ApexColors.sapphire,
          ),
          const SizedBox(height: 8),
          ...slice.map((g) => _RecentRow(game: g, perspective: perspective)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasPrev)
                IconButton(
                  tooltip: 'Previous',
                  onPressed: () =>
                      ref.read(dashboardPageProvider.notifier).prev(),
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: ApexColors.textSecondary,
                ),
              if (hasNext)
                IconButton(
                  tooltip: 'Next',
                  onPressed: () =>
                      ref.read(dashboardPageProvider.notifier).next(),
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: ApexColors.textSecondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.game, required this.perspective});
  final ArchivedGame game;
  final String? perspective;

  @override
  Widget build(BuildContext context) {
    final display = RecentScanDisplay.fromGame(game, perspective: perspective);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ApexGameCard(
        model: display.card,
        dense: true,
        enableHaptic: false,
      ),
    );
  }
}

// ── Shared bits ────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 6,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accent, accent.withValues(alpha: 0.2)],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ApexTypography.titleMedium.copyWith(
                  color: ApexColors.textPrimary,
                  letterSpacing: 2,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 10.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
