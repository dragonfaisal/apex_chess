/// Home Screen — Apex Chess "Deep Space Cinematic" edition.
///
/// Three entry points driven by the on-device Apex AI Analyst:
///   * ENTER LIVE MATCH     — opens the interactive board with live eval.
///   * IMPORT LIVE MATCH    — pulls Chess.com / Lichess games over HTTP.
///   * QUANTUM DEPTH SCAN   — imports a raw PGN and analyses every ply.
///
/// Layout is wrapped in a [SingleChildScrollView] so the content never
/// overflows on compact screens (previously caused the
/// "RenderFlex overflowed by 67 pixels" warning at this screen).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/account/presentation/views/connect_account_screen.dart';
import 'package:apex_chess/features/apex_academy/presentation/views/apex_academy_screen.dart';
import 'package:apex_chess/features/archives/data/archive_save_hook.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/views/archive_screen.dart';
import 'package:apex_chess/features/global_dashboard/presentation/views/global_dashboard_screen.dart';
import 'package:apex_chess/features/import_match/presentation/views/import_match_screen.dart';
import 'package:apex_chess/features/live_play/presentation/views/live_play_screen.dart';
import 'package:apex_chess/features/mistake_vault/data/mistake_vault_save_hook.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/views/review_screen.dart';
import 'package:apex_chess/features/profile_scanner/presentation/views/profile_scanner_screen.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';
import 'package:apex_chess/shared_ui/widgets/quantum_shatter_loader.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountControllerProvider).valueOrNull;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Guarantee the column can scroll when it doesn't fit — this
              // is the fix for the RenderFlex overflow on small devices.
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          _AccountStrip(account: account),
                          const SizedBox(height: 18),
                          const _HeroBadge(),
                          const SizedBox(height: 16),
                          Text(
                            ApexCopy.appTitle,
                            textAlign: TextAlign.center,
                            style: ApexTypography.displayLarge.copyWith(
                              letterSpacing: 6,
                              fontSize: 36,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ApexCopy.tagline,
                            textAlign: TextAlign.center,
                            style: ApexTypography.bodyMedium.copyWith(
                              color: ApexColors.sapphireBright
                                  .withValues(alpha: 0.72),
                              letterSpacing: 2,
                            ),
                          ),
                          const Spacer(),
                          _PrimaryAction(
                            label: ApexCopy.playLive,
                            icon: Icons.play_arrow_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const LivePlayScreen()),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _SecondaryAction(
                            label: ApexCopy.importMatch,
                            icon: Icons.cloud_download_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ImportMatchScreen()),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _SecondaryAction(
                            label: ApexCopy.analyzeGame,
                            icon: Icons.auto_graph_rounded,
                            onTap: () => _showPgnDialog(context, ref),
                          ),
                          const SizedBox(height: 14),
                          _SecondaryAction(
                            label: ApexCopy.archivesTitle,
                            icon: Icons.inventory_2_outlined,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ArchiveScreen()),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _SecondaryAction(
                            label: ApexCopy.scannerTitle,
                            icon: Icons.radar_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ProfileScannerScreen()),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _SecondaryAction(
                            label: ApexCopy.dashboardTitle,
                            icon: Icons.insights_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const GlobalDashboardScreen()),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _SecondaryAction(
                            label: ApexCopy.academyTitle,
                            icon: Icons.school_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ApexAcademyScreen()),
                            ),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            ApexCopy.liveEngineFooter,
                            textAlign: TextAlign.center,
                            style: ApexTypography.bodyMedium.copyWith(
                              color: ApexColors.textTertiary,
                              fontSize: 11,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
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

  void _showPgnDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierColor: ApexColors.spaceVoid.withValues(alpha: 0.72),
      builder: (ctx) => Dialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: GlassPanel.dialog(
          accentColor: ApexColors.sapphire,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_graph_rounded,
                      color: ApexColors.sapphire, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    ApexCopy.pgnDialogTitle,
                    style: ApexTypography.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 8,
                style: ApexTypography.bodyMedium.copyWith(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                  color: ApexColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: ApexCopy.pgnDialogHint,
                  hintStyle: ApexTypography.bodyMedium
                      .copyWith(color: ApexColors.textTertiary),
                  filled: true,
                  fillColor: ApexColors.deepSpace.withValues(alpha: 0.55),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: ApexColors.subtleBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: ApexColors.subtleBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: ApexColors.sapphire
                            .withValues(alpha: 0.55)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _PrimaryAction(
                label: ApexCopy.pgnDialogCta,
                icon: Icons.flash_on_rounded,
                onTap: () {
                  final pgn = controller.text.trim();
                  if (pgn.isEmpty) return;
                  Navigator.of(ctx).pop();
                  _startLocalAnalysis(context, ref, pgn);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLocalAnalysis(BuildContext context, WidgetRef ref, String pgn) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: ApexColors.spaceVoid.withValues(alpha: 0.72),
      builder: (_) => _LocalAnalysisProgressDialog(pgn: pgn),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Buttons
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 58,
          decoration: BoxDecoration(
            gradient: ApexGradients.sapphire,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ApexColors.sapphire.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: -6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: ApexColors.textPrimary, size: 22),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: ApexTypography.labelLarge.copyWith(
                    color: ApexColors.textPrimary,
                    letterSpacing: 2,
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

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      margin: null,
      borderRadius: 16,
      accentAlpha: 0.25,
      fillAlpha: 0.42,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 56,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      color: ApexColors.sapphireBright, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: ApexTypography.labelLarge.copyWith(
                      color: ApexColors.sapphireBright,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero badge
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ApexGradients.sapphireRuby,
          boxShadow: [
            BoxShadow(
              color: ApexColors.sapphire.withValues(alpha: 0.45),
              blurRadius: 36,
              spreadRadius: -6,
            ),
          ],
        ),
        child: const Icon(Icons.auto_awesome,
            color: Colors.white, size: 32),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quantum Depth Scan progress dialog — backed by LocalGameAnalyzer.
// ─────────────────────────────────────────────────────────────────────────────

class _LocalAnalysisProgressDialog extends ConsumerStatefulWidget {
  const _LocalAnalysisProgressDialog({required this.pgn});
  final String pgn;

  @override
  ConsumerState<_LocalAnalysisProgressDialog> createState() =>
      _LocalAnalysisProgressDialogState();
}

class _LocalAnalysisProgressDialogState
    extends ConsumerState<_LocalAnalysisProgressDialog> {
  int _completed = 0;
  int _total = 1;
  bool _done = false;
  // Guards the post-frame navigation callback so it is enqueued at most once,
  // even if build() runs multiple times before the callback fires. Without
  // this, an ancestor rebuild between `_done = true` and the next frame would
  // queue a second pop→push pair and tear down the freshly-pushed review.
  bool _navigated = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    try {
      final analyzer = ref.read(gameAnalyzerProvider);
      final timeline = await analyzer.analyzeFromPgn(
        widget.pgn,
        onProgress: (c, t) {
          if (mounted) setState(() { _completed = c; _total = t; });
        },
      );
      if (mounted) {
        ref.read(reviewControllerProvider.notifier).loadTimeline(timeline);
        // Archive save is awaited so we have the id to hand the
        // Mistake Vault hook; both are still best-effort and never
        // block the review flow on failure.
        final archiveId = await saveAnalysisToArchive(
          ref: ref,
          timeline: timeline,
          pgn: widget.pgn,
          depth: 14,
          source: ArchiveSource.pgn,
        );
        if (archiveId != null) {
          unawaited(saveMistakeDrillsFromTimeline(
            ref: ref,
            timeline: timeline,
            archiveId: archiveId,
            // PGN upload path — unknown which colour the user
            // played, so ingest both sides’ mistakes.
            userIsWhite: null,
          ));
        }
        if (!mounted) return;
        setState(() => _done = true);
      }
    } on LocalAnalysisException catch (e) {
      if (mounted) setState(() => _error = e.userMessage);
    } catch (e) {
      if (mounted) setState(() => _error = ApexCopy.analysisFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReviewScreen()),
        );
      });
    }

    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: GlassPanel.dialog(
        accentColor:
            _error == null ? ApexColors.sapphire : ApexColors.ruby,
        child: _error != null ? _errorContent() : _progressContent(),
      ),
    );
  }

  Widget _progressContent() {
    final progress = _total > 0 ? _completed / _total : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on_rounded,
                color: ApexColors.sapphireBright, size: 20),
            const SizedBox(width: 10),
            Text(ApexCopy.scanHeader(14),
                style: ApexTypography.titleMedium),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const QuantumShatterLoader(size: 220),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: ApexTypography.displayLarge.copyWith(
                      fontSize: 38,
                      color: ApexColors.sapphireBright,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'QUANTUM SCAN',
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textTertiary,
                      fontSize: 10,
                      letterSpacing: 3.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: ApexColors.subtleBorder,
            valueColor:
                const AlwaysStoppedAnimation(ApexColors.sapphireBright),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$_completed / $_total plies analysed',
          style: ApexTypography.bodyMedium
              .copyWith(color: ApexColors.textTertiary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _errorContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: ApexColors.ruby, size: 22),
            const SizedBox(width: 10),
            Text('Quantum Scan Error',
                style: ApexTypography.titleMedium
                    .copyWith(color: ApexColors.ruby)),
          ],
        ),
        const SizedBox(height: 12),
        Text(_error!, style: ApexTypography.bodyLarge),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK',
                style: TextStyle(color: ApexColors.sapphire)),
          ),
        ),
      ],
    );
  }
}

// ── Account strip (top of home) ─────────────────────────────────────────
//
// Connected state: shows the source label + handle next to a "Switch
// account" text button that re-opens onboarding.
// Disconnected state: compact "Connect account" CTA that opens the
// same onboarding screen.

class _AccountStrip extends ConsumerWidget {
  const _AccountStrip({required this.account});
  final ApexAccount? account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (account == null) {
      return Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: ApexColors.emerald,
            side: BorderSide(
                color: ApexColors.emerald.withValues(alpha: 0.55), width: 1),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ConnectAccountScreen())),
          icon: const Icon(Icons.link_rounded, size: 16),
          label: const Text('CONNECT ACCOUNT'),
        ),
      );
    }
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ApexColors.emerald.withValues(alpha: 0.12),
            border: Border.all(
                color: ApexColors.emerald.withValues(alpha: 0.4), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded,
                  size: 14, color: ApexColors.emeraldBright),
              const SizedBox(width: 6),
              Text(
                '${account!.source.wire.toUpperCase()} · ${account!.username}',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textPrimary,
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ConnectAccountScreen())),
          style: TextButton.styleFrom(
            foregroundColor: ApexColors.textSecondary,
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          child: Text(
            'Switch',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
