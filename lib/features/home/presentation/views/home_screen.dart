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
import 'package:apex_chess/features/pgn_review/presentation/views/review_summary_screen.dart';
import 'package:apex_chess/features/profile/presentation/views/profile_screen.dart';
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
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        _AccountStrip(account: account),
                        const SizedBox(height: 22),
                        Text(
                          ApexCopy.appTitle,
                          textAlign: TextAlign.center,
                          style: ApexTypography.displayLarge.copyWith(
                            letterSpacing: 6,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ApexCopy.tagline,
                          textAlign: TextAlign.center,
                          style: ApexTypography.bodyMedium.copyWith(
                            color: ApexColors.sapphireBright
                                .withValues(alpha: 0.72),
                            letterSpacing: 2,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _HeroPlayCard(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const LivePlayScreen()),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _HomeTileGrid(
                          children: [
                            _TileCard(
                              title: ApexCopy.importMatch,
                              subtitle: 'Chess.com · Lichess',
                              icon: Icons.cloud_download_rounded,
                              accent: ApexColors.sapphire,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ImportMatchScreen(),
                                ),
                              ),
                            ),
                            _TileCard(
                              title: ApexCopy.analyzeGame,
                              subtitle: 'Paste PGN · instant scan',
                              icon: Icons.auto_graph_rounded,
                              accent: ApexColors.aurora,
                              onTap: () => _showPgnDialog(context, ref),
                            ),
                            _TileCard(
                              title: ApexCopy.dashboardTitle,
                              subtitle: 'Ratings · trend · openings',
                              icon: Icons.insights_rounded,
                              accent: ApexColors.emerald,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const GlobalDashboardScreen(),
                                ),
                              ),
                            ),
                            _TileCard(
                              title: ApexCopy.scannerTitle,
                              subtitle: 'Fair-play radar',
                              icon: Icons.radar_rounded,
                              accent: ApexColors.ruby,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ProfileScannerScreen(),
                                ),
                              ),
                            ),
                            _TileCard(
                              title: ApexCopy.academyTitle,
                              subtitle: 'Weakness drills',
                              icon: Icons.school_rounded,
                              accent: ApexColors.emeraldBright,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ApexAcademyScreen(),
                                ),
                              ),
                            ),
                            _TileCard(
                              title: ApexCopy.archivesTitle,
                              subtitle: 'Quantum scan vault',
                              icon: Icons.inventory_2_outlined,
                              accent: ApexColors.sapphireBright,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ArchiveScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
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
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPgnDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_PgnPasteResult>(
      context: context,
      barrierColor: ApexColors.spaceVoid.withValues(alpha: 0.72),
      builder: (_) => const _PgnPasteDialog(),
    );
    if (result == null) return;
    if (!context.mounted) return;
    _startLocalAnalysis(context, ref, result);
  }

  void _startLocalAnalysis(
      BuildContext context, WidgetRef ref, _PgnPasteResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: ApexColors.spaceVoid.withValues(alpha: 0.72),
      builder: (_) => _LocalAnalysisProgressDialog(
        pgn: result.pgn,
        mode: result.mode,
        userIsWhite: result.userIsWhite,
        userHandle: result.userHandle,
      ),
    );
  }
}

/// Result of the PGN paste dialog — captures the text, user-side
/// preference, and analysis depth so the progress dialog + archive
/// record know what the user asked for.
///
/// Phase A audit § 3: the original dialog had a single "Run Scan" CTA
/// with no colour or mode input, which forced every PGN paste to run
/// through the default D14 analyzer with `userIsWhite = null`. That
/// produced misleading archives where White-as-user and Black-as-user
/// games were indistinguishable, and Quick scans silently claimed
/// Brilliants.
class _PgnPasteResult {
  const _PgnPasteResult({
    required this.pgn,
    required this.mode,
    required this.userIsWhite,
    required this.userHandle,
  });
  final String pgn;
  final AnalysisMode mode;

  /// `true` → user played White, `false` → Black, `null` → unknown
  /// (ingest both sides' mistakes into the Vault; no board auto-flip).
  final bool? userIsWhite;

  /// Optional handle the user typed. Not wired into the archive
  /// metadata yet, but threaded down so future enhancements can plug
  /// into it without reshaping the dialog API.
  final String? userHandle;
}

/// PGN paste dialog with side selector, optional handle, and split
/// Quick / Deep analyse buttons. See [_PgnPasteResult] for why each
/// field is needed.
class _PgnPasteDialog extends StatefulWidget {
  const _PgnPasteDialog();

  @override
  State<_PgnPasteDialog> createState() => _PgnPasteDialogState();
}

class _PgnPasteDialogState extends State<_PgnPasteDialog> {
  final _pgnController = TextEditingController();
  final _handleController = TextEditingController();
  // `null` == "unknown" — the default preserves the legacy PGN-paste
  // behaviour (both sides' mistakes ingested, no board flip).
  bool? _userIsWhite;

  @override
  void dispose() {
    _pgnController.dispose();
    _handleController.dispose();
    super.dispose();
  }

  void _pop(AnalysisMode mode) {
    final pgn = _pgnController.text.trim();
    if (pgn.isEmpty) return;
    final handle = _handleController.text.trim();
    Navigator.of(context).pop(_PgnPasteResult(
      pgn: pgn,
      mode: mode,
      userIsWhite: _userIsWhite,
      userHandle: handle.isEmpty ? null : handle,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: GlassPanel.dialog(
        accentColor: ApexColors.sapphire,
        child: SingleChildScrollView(
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
              const SizedBox(height: 14),
              TextField(
                controller: _pgnController,
                maxLines: 6,
                style: ApexTypography.bodyMedium.copyWith(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                  color: ApexColors.textPrimary,
                ),
                decoration: _dialogField(
                  hint: ApexCopy.pgnDialogHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _handleController,
                style: ApexTypography.bodyMedium.copyWith(
                  fontSize: 12,
                  color: ApexColors.textPrimary,
                ),
                decoration: _dialogField(
                  hint: 'Your handle (optional)',
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'You played as',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 11,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              _SideSelector(
                value: _userIsWhite,
                onChanged: (v) => setState(() => _userIsWhite = v),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DialogPrimaryAction(
                      label: 'QUICK (D14)',
                      icon: Icons.flash_on_rounded,
                      onTap: () => _pop(AnalysisMode.quick),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DialogPrimaryAction(
                      label: 'DEEP (D22)',
                      icon: Icons.auto_awesome_rounded,
                      onTap: () => _pop(AnalysisMode.deep),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dialogField({required String hint}) => InputDecoration(
        hintText: hint,
        hintStyle: ApexTypography.bodyMedium
            .copyWith(color: ApexColors.textTertiary),
        filled: true,
        fillColor: ApexColors.deepSpace.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ApexColors.subtleBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ApexColors.subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: ApexColors.sapphire.withValues(alpha: 0.55)),
        ),
      );
}

/// Three-way segmented selector: White / Black / Unknown. Used by the
/// PGN paste dialog to capture which colour the user played; the value
/// is threaded through to the analyzer (board auto-flip) and the
/// Mistake Vault hook (colour-filtered ingest).
class _SideSelector extends StatelessWidget {
  const _SideSelector({required this.value, required this.onChanged});
  final bool? value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SideChip(
            label: 'White',
            selected: value == true,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SideChip(
            label: 'Black',
            selected: value == false,
            onTap: () => onChanged(false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SideChip(
            label: 'Unknown',
            selected: value == null,
            onTap: () => onChanged(null),
          ),
        ),
      ],
    );
  }
}

class _SideChip extends StatelessWidget {
  const _SideChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? ApexColors.sapphire.withValues(alpha: 0.22)
                : ApexColors.elevatedSurface.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? ApexColors.sapphire.withValues(alpha: 0.55)
                  : ApexColors.subtleBorder,
              width: 0.6,
            ),
          ),
          child: Text(
            label,
            style: ApexTypography.labelLarge.copyWith(
              color: selected
                  ? ApexColors.textPrimary
                  : ApexColors.textSecondary,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogPrimaryAction extends StatelessWidget {
  const _DialogPrimaryAction({
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
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: ApexGradients.sapphire,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: ApexColors.textPrimary, size: 20),
                const SizedBox(width: 10),
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

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard tiles — fixed two-column entries, each with its own accent theme.
// ─────────────────────────────────────────────────────────────────────────────

class _HeroPlayCard extends StatelessWidget {
  const _HeroPlayCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          height: 128,
          decoration: BoxDecoration(
            gradient: ApexGradients.sapphireRuby,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: ApexColors.sapphire.withValues(alpha: 0.35),
                blurRadius: 32,
                spreadRadius: -8,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(22, 16, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIVE ENGINE ROOM',
                      style: ApexTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ApexCopy.playLive,
                      style: ApexTypography.displayLarge.copyWith(
                        fontSize: 22,
                        letterSpacing: 1.6,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duel the engine · live eval · instant verdict',
                      style: ApexTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTileGrid extends StatelessWidget {
  const _HomeTileGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(
                width: tileWidth,
                height: 132,
                child: child,
              ),
          ],
        );
      },
    );
  }
}

class _TileCard extends StatelessWidget {
  const _TileCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      margin: null,
      borderRadius: 16,
      accentColor: accent,
      accentAlpha: 0.32,
      fillAlpha: 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: SizedBox(
              height: 104,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 18),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ApexTypography.labelLarge.copyWith(
                          color: ApexColors.textPrimary,
                          letterSpacing: 1.1,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ApexTypography.bodyMedium.copyWith(
                          color: ApexColors.textTertiary,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
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
// Quantum Depth Scan progress dialog — backed by LocalGameAnalyzer.
// ─────────────────────────────────────────────────────────────────────────────

class _LocalAnalysisProgressDialog extends ConsumerStatefulWidget {
  const _LocalAnalysisProgressDialog({
    required this.pgn,
    this.mode = AnalysisMode.quick,
    this.userIsWhite,
    this.userHandle,
  });
  final String pgn;
  final AnalysisMode mode;

  /// `true` → user played White, `false` → Black, `null` → unknown.
  /// When non-null the review board auto-flips for Black users and the
  /// Mistake Vault hook only ingests that colour's plies.
  final bool? userIsWhite;

  /// Optional handle the user typed on the paste dialog. Reserved for
  /// future archive-metadata enhancements; currently unused by this
  /// dialog.
  final String? userHandle;

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
      // Phase A audit § 3: PGN paste now carries an explicit Quick/Deep
      // choice and a user-side preference. Depth is derived from the
      // mode (14 vs 22); the mode flag is what actually gates trophy
      // tiers in the classifier.
      final depth = widget.mode == AnalysisMode.quick ? 14 : 22;
      final timeline = await analyzer.analyzeFromPgn(
        widget.pgn,
        depth: depth,
        mode: widget.mode,
        onProgress: (c, t) {
          if (mounted) setState(() { _completed = c; _total = t; });
        },
      );
      if (mounted) {
        ref.read(reviewControllerProvider.notifier).loadTimeline(
              timeline,
              // Auto-flip the board if the user told us they played
              // Black. Unknown-side PGNs keep White at the bottom.
              userIsBlack: widget.userIsWhite == false,
              // Phase 20.1: thread the analysis mode and the user's
              // colour so the coach card can attribute "Allowed
              // forced mate" correctly and surface the "Needs Deep
              // Scan" chip on Quick-mode ambiguous plies.
              mode: widget.mode,
              userIsWhite: widget.userIsWhite,
            );
        // Archive save is awaited so we have the id to hand the
        // Mistake Vault hook; both are still best-effort and never
        // block the review flow on failure.
        final archiveId = await saveAnalysisToArchive(
          ref: ref,
          timeline: timeline,
          pgn: widget.pgn,
          depth: depth,
          source: ArchiveSource.pgn,
          analysisMode: widget.mode,
        );
        if (archiveId != null) {
          unawaited(saveMistakeDrillsFromTimeline(
            ref: ref,
            timeline: timeline,
            archiveId: archiveId,
            // When the user specified a colour on the paste dialog, only
            // that side's mistakes flow into the Vault. Unknown-side
            // paste keeps the legacy both-sides behaviour.
            userIsWhite: widget.userIsWhite,
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
        // Phase 20.1 § 3: land on the ReviewSummaryScreen first so the
        // user gets accuracy + counts + phase breakdown + CTAs before
        // jumping into move-by-move review. The summary screen's
        // "Review Moves" CTA pushes ReviewScreen itself.
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReviewSummaryScreen()),
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
          // Pop back to home once the connect / skip resolves so the
          // user doesn't get stuck on the connect screen with no
          // forward navigation. ConnectAccountScreen.onComplete is the
          // sole signal it watches before doing anything navigation-y.
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (innerCtx) => ConnectAccountScreen(
                    onComplete: () => Navigator.of(innerCtx).pop(),
                  ))),
          icon: const Icon(Icons.link_rounded, size: 16),
          label: const Text('CONNECT ACCOUNT'),
        ),
      );
    }
    return Row(
      children: [
        // Verified-handle chip — also tappable as a quick portal to the
        // dedicated Profile screen (live ratings + logout cascade).
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const ProfileScreen())),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ApexColors.emerald.withValues(alpha: 0.12),
                border: Border.all(
                    color: ApexColors.emerald.withValues(alpha: 0.4),
                    width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded,
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
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Profile',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const ProfileScreen())),
          icon: const Icon(Icons.account_circle_outlined,
              size: 22, color: ApexColors.sapphireBright),
        ),
      ],
    );
  }
}
