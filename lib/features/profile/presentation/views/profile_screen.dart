/// Profile — connected account, live ratings, and the logout cascade.
///
/// The screen is read-only; all mutations live behind two buttons:
///   * **Switch account** — pushes the [ConnectAccountScreen] without
///     wiping anything (idempotent connect-or-replace).
///   * **Logout** — runs the [LogoutService] cascade (Hive + Prefs) and
///     pops back to the [ConnectAccountScreen] root via the gate. The
///     button is intentionally destructive-styled so users don't tap
///     it expecting a soft-disconnect.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/account/presentation/views/connect_account_screen.dart';
import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';
import 'package:apex_chess/features/profile_stats/presentation/controllers/profile_stats_controller.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountControllerProvider).valueOrNull;
    final statsAsync = ref.watch(liveProfileStatsProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'PROFILE',
                  style: ApexTypography.displayLarge.copyWith(
                    fontSize: 18,
                    letterSpacing: 4,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                sliver: SliverList.list(
                  children: [
                    _IdentityCard(account: account),
                    const SizedBox(height: 18),
                    if (account != null)
                      _StatsCard(statsAsync: statsAsync)
                    else
                      const _NotConnectedCard(),
                    const SizedBox(height: 22),
                    _ActionsCard(account: account),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Identity — username + provider chip + initials avatar
// ─────────────────────────────────────────────────────────────────────────────

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.account});
  final ApexAccount? account;

  @override
  Widget build(BuildContext context) {
    final connected = account != null;
    final accent = connected
        ? (account!.source == AccountSource.chessCom
            ? ApexColors.emerald
            : ApexColors.sapphireBright)
        : ApexColors.textTertiary;
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      accentColor: accent,
      accentAlpha: 0.45,
      showGlow: connected,
      child: Row(
        children: [
          _Avatar(
            seed: connected ? account!.username : '?',
            accent: accent,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  connected ? account!.username : 'No account connected',
                  style: ApexTypography.displayLarge.copyWith(
                    fontSize: 22,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: accent.withValues(alpha: 0.15),
                    border: Border.all(
                        color: accent.withValues(alpha: 0.45), width: 0.8),
                  ),
                  child: Text(
                    connected
                        ? account!.source.wire.toUpperCase()
                        : 'TAP CONNECT BELOW',
                    style: ApexTypography.bodyMedium.copyWith(
                      color: accent,
                      fontSize: 10.5,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.seed, required this.accent});
  final String seed;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(seed);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.85),
            accent.withValues(alpha: 0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.45),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: ApexTypography.displayLarge.copyWith(
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'[\s_\-]+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats card — live ratings + W/L/D + total games
// ─────────────────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.statsAsync});
  final AsyncValue<ProfileStats?> statsAsync;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(18),
      accentColor: ApexColors.sapphireBright,
      accentAlpha: 0.35,
      child: statsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: ApexColors.sapphireBright),
            ),
          ),
        ),
        error: (_, __) => const _StatsEmpty(
            message: 'Couldn\'t reach the rating service.'),
        data: (stats) {
          if (stats == null || !stats.hasData) {
            return const _StatsEmpty(
                message: 'No live ratings yet — play a few games to populate.');
          }
          return _StatsBody(stats: stats);
        },
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});
  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final ratingBuckets =
        stats.buckets.where((b) => b.rating != null).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bar_chart_rounded,
                color: ApexColors.sapphireBright, size: 18),
            const SizedBox(width: 8),
            Text(
              'LIVE RATINGS',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.sapphireBright,
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (ratingBuckets.isEmpty)
          Text(
            'No rated games on record yet.',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 12.5,
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ratingBuckets
                .map((b) => _RatingChip(bucket: b))
                .toList(),
          ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
                child: _StatCell(
                    label: 'GAMES', value: '${stats.totalGames}')),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCell(
                    label: 'WIN %',
                    value: '${stats.winRate.toStringAsFixed(1)}%',
                    accent: ApexColors.emerald)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCell(
                  label: 'WINS',
                  value: '${stats.totalWins}',
                  accent: ApexColors.emerald),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCell(
                  label: 'DRAWS',
                  value: '${stats.totalDraws}',
                  accent: ApexColors.textSecondary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCell(
                  label: 'LOSSES',
                  value: '${stats.totalLosses}',
                  accent: ApexColors.ruby),
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({required this.bucket});
  final RatingBucket bucket;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ApexColors.sapphireBright.withValues(alpha: 0.10),
        border: Border.all(
            color: ApexColors.sapphireBright.withValues(alpha: 0.35),
            width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bucket.label.toUpperCase(),
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.sapphireBright,
              fontSize: 9,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${bucket.rating}',
            style: ApexTypography.displayLarge.copyWith(
              fontSize: 18,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? ApexColors.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ApexColors.nebula.withValues(alpha: 0.4),
        border: Border.all(
            color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: ApexTypography.bodyMedium.copyWith(
              color: color.withValues(alpha: 0.85),
              fontSize: 9.5,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: ApexTypography.displayLarge.copyWith(
              fontSize: 16,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsEmpty extends StatelessWidget {
  const _StatsEmpty({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: ApexTypography.bodyMedium.copyWith(
            color: ApexColors.textTertiary,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _NotConnectedCard extends StatelessWidget {
  const _NotConnectedCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(18),
      accentColor: ApexColors.textTertiary,
      accentAlpha: 0.3,
      child: Center(
        child: Text(
          'Connect a Chess.com or Lichess handle to surface live ratings.',
          textAlign: TextAlign.center,
          style: ApexTypography.bodyMedium.copyWith(
            color: ApexColors.textSecondary,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Actions — Switch + Logout
// ─────────────────────────────────────────────────────────────────────────────

class _ActionsCard extends ConsumerWidget {
  const _ActionsCard({required this.account});
  final ApexAccount? account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ConnectAccountScreen(),
                ),
              ),
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: Text(account == null ? 'CONNECT ACCOUNT' : 'SWITCH ACCOUNT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ApexColors.sapphireBright,
                side: BorderSide(
                    color:
                        ApexColors.sapphireBright.withValues(alpha: 0.55),
                    width: 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: ApexTypography.bodyMedium.copyWith(
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (account != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context, ref),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('LOGOUT & WIPE LOCAL DATA'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ApexColors.ruby,
                  side: BorderSide(
                      color: ApexColors.ruby.withValues(alpha: 0.55),
                      width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: ApexTypography.bodyMedium.copyWith(
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Logout clears the connected account, archived games, mistake vault, and onboarding state from this device. The Chess.com / Lichess account itself is untouched.',
            textAlign: TextAlign.center,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ApexColors.nebula,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout?'),
        content: const Text(
          'This wipes archived games, mistake vault, ratings cache, and the connected handle from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: ApexColors.ruby),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(accountControllerProvider.notifier).logout();
    if (!context.mounted) return;
    // Pop everything back to the root gate. The gate watches
    // `onboardingSeenProvider` which we just invalidated, so it will
    // re-render the Connect Account screen automatically.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }
}
