/// Global Dashboard — multi-chart analytics across the user's entire
/// archive. Corporate-analytics feel: hero KPI cards, accuracy trend,
/// move-quality distribution, result split, and a paginated recent-
/// games table. Everything reads from the local Hive archive — no
/// network, no engine, instant.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/archives/presentation/views/archive_screen.dart';
import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';
import 'package:apex_chess/features/profile_stats/presentation/controllers/profile_stats_controller.dart';
import 'package:apex_chess/features/global_dashboard/presentation/models/recent_scan_display.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_screen.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';
import 'package:apex_chess/shared_ui/widgets/apex_game_card.dart';
import 'package:apex_chess/shared_ui/widgets/apex_platform_badge.dart';
import 'package:apex_chess/shared_ui/widgets/apex_player_avatar.dart';
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
    final activeSource = ref.watch(dashboardSourceFilterProvider);
    final filterOnlyEmpty =
        !stats.hasData &&
        (activeFilter != ColorPerspective.all || activeSource != null);
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
          const SizedBox(height: 8),
          const _SourceFilterBar(),
          const SizedBox(height: 12),
          const _DashboardInlineNotice(),
          const SizedBox(height: 12),
          if (filterOnlyEmpty)
            _FilterEmptyNotice(filter: activeFilter, source: activeSource)
          else ...[
            _AnalyzedSectionLabel(stats: stats),
            const SizedBox(height: 10),
            _KpiRow(stats: stats),
            const SizedBox(height: 18),
            _AccuracyTrendCard(stats: stats),
            const SizedBox(height: 14),
            _MoveQualityBreakdownCard(stats: stats),
            const SizedBox(height: 14),
            _ResultSplitCard(stats: stats),
            const SizedBox(height: 14),
            const _OpeningStatsCard(),
            const SizedBox(height: 14),
            const _WeakSpotsCard(),
            const SizedBox(height: 18),
            const _RecentGamesTable(),
          ],
        ],
      ),
    );
  }
}

class _FilterEmptyNotice extends StatelessWidget {
  const _FilterEmptyNotice({required this.filter, required this.source});

  final ColorPerspective filter;
  final ArchiveSource? source;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      ColorPerspective.white => 'White',
      ColorPerspective.black => 'Black',
      ColorPerspective.all => 'All',
    };
    final sourceLabel = _dashboardSourceLabel(source);
    final scope = source == null ? label : '$label · $sourceLabel';
    final hint = source == null
        ? 'Switch to All to view your analyzed games.'
        : 'Switch filters to view your analyzed games.';
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
                  'No $scope reviews yet.',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
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

class _SourceFilterBar extends ConsumerWidget {
  const _SourceFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(dashboardSourceFilterProvider);
    return GlassPanel(
      padding: const EdgeInsets.all(4),
      accentColor: ApexColors.textSecondary,
      accentAlpha: 0.18,
      child: Row(
        children: [
          for (final source in const <ArchiveSource?>[
            null,
            ArchiveSource.chessCom,
            ArchiveSource.lichess,
            ArchiveSource.pgn,
          ])
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(dashboardSourceFilterProvider.notifier).state =
                      source;
                },
                child: Container(
                  key: ValueKey(
                    'dashboard_source_${source?.wire ?? 'all'}_${active == source ? 'selected' : 'normal'}',
                  ),
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: active == source
                        ? ApexColors.nebula.withValues(alpha: 0.82)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active == source
                          ? ApexColors.sapphireBright.withValues(alpha: 0.42)
                          : Colors.transparent,
                      width: 0.6,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _dashboardSourceLabel(source).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ApexTypography.bodyMedium.copyWith(
                      color: active == source
                          ? ApexColors.sapphireBright
                          : ApexColors.textTertiary,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
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

String _dashboardSourceLabel(ArchiveSource? source) => switch (source) {
  null => 'All sources',
  ArchiveSource.chessCom => 'Chess.com',
  ArchiveSource.lichess => 'Lichess',
  ArchiveSource.pgn => 'PGN',
};

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
            title: ApexCopy.publicAccount.toUpperCase(),
            subtitle: ApexCopy.synced,
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
                platform: PlayerIdentityPlatform.chessCom,
                selected: state.source == ProfileStatsSource.chessCom,
                onTap: () => notifier.setSource(ProfileStatsSource.chessCom),
              ),
              const SizedBox(width: 8),
              _SearchSourceChip(
                platform: PlayerIdentityPlatform.lichess,
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
            _SearchedPlayerDashboard(
              stats: state.result!,
              isConnectedAccount: state.isConnectedAccount,
            ),
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
    required this.platform,
    required this.selected,
    required this.onTap,
  });

  final PlayerIdentityPlatform platform;
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
          child: ApexPlatformBadge(
            platform: platform,
            compact: true,
            selected: selected,
          ),
        ),
      ),
    );
  }
}

class _SearchedPlayerDashboard extends ConsumerWidget {
  const _SearchedPlayerDashboard({
    required this.stats,
    required this.isConnectedAccount,
  });

  final ProfileStats stats;
  final bool isConnectedAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = PlayerIdentityDisplay.fromRaw(
      username: stats.displayName,
      platform: stats.source.identityPlatform,
      rating: _firstRating(stats),
      avatarUrl: stats.avatarUrl,
      isConnectedUser: isConnectedAccount,
      status: PlayerIdentitySourceStatus.publicProfile,
    );
    final localStats = buildDashboardStatsForTesting(
      ref.watch(archiveControllerProvider).games,
      perspective: stats.username,
    );
    if (!stats.hasData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isConnectedAccount) ...[
            const _SmallNotice(
              icon: Icons.verified_user_outlined,
              title: ApexCopy.connectedAccountNotice,
              subtitle: ApexCopy.publicAccount,
            ),
            const SizedBox(height: 8),
          ],
          const _SmallNotice(
            icon: Icons.info_outline_rounded,
            title: ApexCopy.dashboardNoPublicData,
            subtitle: ApexCopy.dashboardNoGamesFound,
          ),
          const SizedBox(height: 8),
          _SearchedApexStats(stats: localStats),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isConnectedAccount) ...[
          const _SmallNotice(
            icon: Icons.verified_user_outlined,
            title: ApexCopy.connectedAccountNotice,
            subtitle: ApexCopy.publicAccount,
          ),
          const SizedBox(height: 8),
        ],
        _SearchedPlayerIdentity(identity: identity),
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
          ApexCopy.publicAccount,
          textAlign: TextAlign.center,
          style: ApexTypography.bodyMedium.copyWith(
            color: ApexColors.textTertiary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        _SearchedApexStats(stats: localStats),
      ],
    );
  }
}

class _SearchedPlayerIdentity extends StatelessWidget {
  const _SearchedPlayerIdentity({required this.identity});

  final PlayerIdentityDisplay identity;

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
          ApexPlayerAvatar(
            identity: identity,
            size: ApexPlayerAvatarSize.medium,
            showPlatformBadge: true,
            showConnectedBadge: identity.isConnectedUser,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${identity.displayUsername}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    ApexPlatformBadge(
                      platform: identity.platform,
                      compact: true,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        [
                          ApexCopy.publicAccount,
                          if (identity.hasKnownRating) identity.rating!,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ApexTypography.bodyMedium.copyWith(
                          color: ApexColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (identity.isConnectedUser)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: _IdentityYouChip(),
            ),
        ],
      ),
    );
  }
}

class _IdentityYouChip extends StatelessWidget {
  const _IdentityYouChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: ApexColors.sapphire.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ApexColors.sapphireBright.withValues(alpha: 0.42),
          width: 0.5,
        ),
      ),
      child: Text(
        'YOU',
        style: ApexTypography.labelLarge.copyWith(
          color: ApexColors.sapphireBright,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

String? _firstRating(ProfileStats stats) {
  for (final bucket in stats.buckets) {
    final rating = bucket.rating;
    if (rating != null) return '$rating';
  }
  return null;
}

extension on ProfileStatsSource {
  PlayerIdentityPlatform get identityPlatform {
    return switch (this) {
      ProfileStatsSource.chessCom => PlayerIdentityPlatform.chessCom,
      ProfileStatsSource.lichess => PlayerIdentityPlatform.lichess,
    };
  }
}

void _openStatsArchiveIntent(
  BuildContext context,
  WidgetRef ref,
  StatsArchiveFilterIntent intent, {
  int? count,
  String? emptyNotice,
}) {
  if (count != null && count <= 0 && emptyNotice != null) {
    ref.read(dashboardInlineNoticeProvider.notifier).state = emptyNotice;
    return;
  }
  final perspective = ref.read(dashboardStatsProvider).perspective;
  final scope = ref.read(dashboardColorFilterProvider);
  final source = ref.read(dashboardSourceFilterProvider);
  ref.read(dashboardInlineNoticeProvider.notifier).state = null;
  final filters = intent.toArchiveFilters(
    perspective: perspective,
    scope: scope,
  );
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ArchiveScreen(
        initialFilters: source == null
            ? filters
            : filters.copyWith(source: source),
      ),
    ),
  );
}

class _SearchedApexStats extends StatelessWidget {
  const _SearchedApexStats({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    if (!stats.hasData) {
      return const _SmallNotice(
        icon: Icons.analytics_outlined,
        title: 'Apex Analyzed Stats',
        subtitle: 'No analyzed games',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SmallNotice(
          icon: Icons.analytics_outlined,
          title: 'Apex Analyzed Stats',
          subtitle: 'Local reviews',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _SmallStat(
                label: 'GAMES',
                value: '${stats.gamesAnalyzed}',
                color: ApexColors.sapphireBright,
              ),
            ),
            Expanded(
              child: _SmallStat(
                label: 'AVG',
                value: '${stats.averageAccuracy.toStringAsFixed(0)}%',
                color: ApexColors.emeraldBright,
              ),
            ),
            Expanded(
              child: _SmallStat(
                label: 'WON',
                value: '${stats.wins}',
                color: ApexColors.emeraldBright,
              ),
            ),
            Expanded(
              child: _SmallStat(
                label: 'LOST',
                value: '${stats.losses}',
                color: ApexColors.ruby,
              ),
            ),
          ],
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
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      accentColor: ApexColors.sapphireBright,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'OPENING PERFORMANCE',
            subtitle: 'Top lines by frequency',
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
          ],
        ],
      ),
    );
  }
}

class _OpeningRow extends ConsumerWidget {
  const _OpeningRow({required this.stats});
  final OpeningStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _openStatsArchiveIntent(
          context,
          ref,
          StatsArchiveFilterIntent.opening(stats),
          count: stats.total,
          emptyNotice: 'No matching games',
        ),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
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
                  '${stats.scoreRate.toStringAsFixed(0)}%',
                  textAlign: TextAlign.right,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: stats.scoreRate >= 50
                        ? ApexColors.emeraldBright
                        : ApexColors.ruby,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final cards = buildDashboardKpis(stats)
        .map(
          (kpi) => _KpiCard(
            label: kpi.label,
            value: kpi.value,
            accent: _kpiAccent(kpi.label),
            icon: _kpiIcon(kpi.label),
            onTap: kpi.intent == null
                ? null
                : () => _openStatsArchiveIntent(
                    context,
                    ref,
                    kpi.intent!,
                    count: kpi.count,
                    emptyNotice: kpi.emptyNotice,
                  ),
          ),
        )
        .toList();
    return LayoutBuilder(
      builder: (context, box) {
        final crossAxisCount = box.maxWidth >= 720 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: crossAxisCount == 3 ? 1.55 : 1.45,
          children: cards,
        );
      },
    );
  }

  Color _kpiAccent(String label) => switch (label) {
    'Wins' => ApexColors.emerald,
    'Losses' => ApexColors.ruby,
    'Draws' => ApexColors.inaccuracy,
    'Brilliants' => ApexColors.brilliant,
    'Misses' => ApexColors.mistake,
    'Blunders' => ApexColors.blunder,
    'Avg Accuracy' => ApexColors.emerald,
    'Avg ACPL' => ApexColors.sapphireBright,
    _ => ApexColors.sapphire,
  };

  IconData _kpiIcon(String label) => switch (label) {
    'Wins' => Icons.check_circle_outline_rounded,
    'Losses' => Icons.cancel_outlined,
    'Draws' => Icons.balance_rounded,
    'Brilliants' => Icons.auto_awesome_rounded,
    'Misses' => Icons.report_gmailerrorred_rounded,
    'Blunders' => Icons.error_outline_rounded,
    'Avg Accuracy' => Icons.auto_graph_rounded,
    'Avg ACPL' => Icons.speed_rounded,
    _ => Icons.analytics_rounded,
  };
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
    final display = buildAccuracyTrendDisplay(stats);
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      accentColor: ApexColors.emerald,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'ACCURACY TREND',
            subtitle: 'Higher is better',
            accent: ApexColors.emerald,
          ),
          const SizedBox(height: 10),
          if (!display.canChart)
            _SmallNotice(
              icon: Icons.auto_graph_rounded,
              title: display.state == AccuracyTrendState.empty
                  ? 'No games yet'
                  : 'More games needed',
              subtitle: display.state == AccuracyTrendState.empty
                  ? 'Review a game to build stats'
                  : 'One game logged',
            )
          else
            SizedBox(height: 160, child: LineChart(_data(display.points))),
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

// ── Move quality breakdown ─────────────────────────────────────────────

class _MoveQualityBreakdownCard extends ConsumerWidget {
  const _MoveQualityBreakdownCard({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = buildMoveQualityBreakdownDisplay(stats);
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      accentColor: ApexColors.sapphire,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'MOVE QUALITY',
            subtitle: 'All public labels',
            accent: ApexColors.sapphire,
          ),
          const SizedBox(height: 12),
          if (!display.hasMoves)
            const _SmallNotice(
              icon: Icons.category_outlined,
              title: 'No games yet',
              subtitle: 'Review a game to build stats',
            )
          else
            Column(
              children: [
                for (final item in display.items)
                  _MoveQualityRow(
                    item: item,
                    onTap: item.intent == null
                        ? null
                        : () => _openStatsArchiveIntent(
                            context,
                            ref,
                            item.intent!,
                            count: item.count,
                            emptyNotice: 'No ${item.label} reviews yet',
                          ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MoveQualityRow extends StatelessWidget {
  const _MoveQualityRow({required this.item, this.onTap});

  final MoveQualityBreakdownItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = item.reviewLabel.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              SizedBox(
                width: 86,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: item.percent,
                    color: color,
                    backgroundColor: ApexColors.stardustLine.withValues(
                      alpha: 0.24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 34,
                child: Text(
                  '${item.count}',
                  textAlign: TextAlign.right,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 11.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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

// ── Result split ───────────────────────────────────────────────────────

class _ResultSplitCard extends ConsumerWidget {
  const _ResultSplitCard({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPerspective =
        stats.perspective != null && stats.perspective!.isNotEmpty;
    final display = buildResultSplitDisplay(stats);
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
                : 'Connect account for W/L/D',
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
          else if (!display.hasGames)
            const _SmallNotice(
              icon: Icons.pie_chart_outline_rounded,
              title: 'No games yet',
              subtitle: 'Review a game to build stats',
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 14,
                child: Row(
                  children: [
                    for (final segment in display.segments)
                      Expanded(
                        flex: (segment.fraction * 1000).round().clamp(1, 1000),
                        child: Container(color: _resultColor(segment.label)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < display.segments.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _ResultShortcut(
                    label: display.segments[i].label,
                    count: display.segments[i].count,
                    color: _resultColor(display.segments[i].label),
                    onTap: () => _openStatsArchiveIntent(
                      context,
                      ref,
                      display.segments[i].intent,
                      count: display.segments[i].count,
                      emptyNotice: display.segments[i].emptyNotice,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _resultColor(String label) => switch (label) {
    'Won' => ApexColors.emerald,
    'Draw' => ApexColors.inaccuracy,
    'Lost' => ApexColors.ruby,
    _ => ApexColors.sapphire,
  };
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

// ── Weak spots ─────────────────────────────────────────────────────────

class _WeakSpotsCard extends ConsumerWidget {
  const _WeakSpotsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spots = ref.watch(dashboardWeakSpotsProvider);
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      accentColor: ApexColors.mistake,
      accentAlpha: 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHeader(
            title: 'WEAK SPOTS',
            subtitle: 'Review next',
            accent: ApexColors.mistake,
          ),
          const SizedBox(height: 10),
          for (final spot in spots) _WeakSpotRow(spot: spot),
        ],
      ),
    );
  }
}

class _WeakSpotRow extends ConsumerWidget {
  const _WeakSpotRow({required this.spot});

  final WeakSpotDisplay spot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: spot.intent == null
            ? null
            : () => _openStatsArchiveIntent(
                context,
                ref,
                spot.intent!,
                count: spot.count > 0 ? spot.count : null,
              ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: ApexColors.nebula.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ApexColors.stardustLine.withValues(alpha: 0.22),
              width: 0.6,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: ApexColors.mistake.withValues(alpha: 0.90),
                size: 17,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ApexTypography.bodyMedium.copyWith(
                        color: ApexColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      spot.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ApexTypography.bodyMedium.copyWith(
                        color: ApexColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (spot.intent != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: ApexColors.textTertiary,
                  size: 18,
                ),
            ],
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

class _RecentRow extends ConsumerWidget {
  const _RecentRow({required this.game, required this.perspective});
  final ArchivedGame game;
  final String? perspective;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = RecentScanDisplay.fromGame(game, perspective: perspective);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ApexGameCard(
        model: display.card,
        dense: true,
        enableHaptic: false,
        onTap: () => _openRecentScan(context, ref),
      ),
    );
  }

  void _openRecentScan(BuildContext context, WidgetRef ref) {
    final cached = game.cachedTimeline;
    final userIsBlack = game.userIsBlackFor(perspective);
    final userIsWhite = userIsBlack == null ? null : !userIsBlack;
    if (game.isCacheCurrent && cached != null && cached.moves.isNotEmpty) {
      ref
          .read(reviewControllerProvider.notifier)
          .loadTimeline(
            cached,
            userIsBlack: userIsBlack ?? false,
            mode: game.analysisMode,
            userIsWhite: userIsWhite,
          );
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const ReviewScreen()));
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArchiveScreen(
          initialFilters: ArchiveFilters(
            search: game.ecoCode?.trim().isNotEmpty == true
                ? game.ecoCode!.trim()
                : (game.openingName ?? game.black),
          ),
        ),
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
