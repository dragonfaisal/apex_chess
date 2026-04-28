/// PGN Review Screen — full game review with pre-computed analysis.
///
/// Displays:
///   - Board with SVG quality overlays
///   - Advantage chart (interactive — tap to jump)
///   - Coach dashboard with SAN + classification
///   - ◀▶ navigation controls
///
/// All data comes from in-memory [AnalysisTimeline] via [ReviewController].
/// ZERO network calls during navigation.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/coach_explanation_service.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/shared_ui/widgets/apex_chess_board.dart';
import 'package:apex_chess/shared_ui/widgets/apex_eval_bar.dart';
import 'package:apex_chess/shared_ui/widgets/brilliant_glow.dart';
import 'package:apex_chess/shared_ui/widgets/evaluation_chart.dart';
import '../controllers/review_controller.dart';
import '../controllers/review_audio_controller.dart';

/// `true` when the played move equals the engine's top line (after
/// castling normalisation — the engine may emit `e1h1` while dartchess
/// emits `e1g1` for the same king-side castle).
///
/// Used to suppress the "Better: &lt;same SAN&gt;" copy the Phase A audit
/// flagged on real devices, and to render a "Top engine choice"
/// chip instead.
bool _playedEqualsBest(MoveAnalysis m) {
  final best = m.engineBestMoveUci;
  final played = m.uci;
  if (best == null || played.isEmpty) return false;
  return normalizeCastlingUci(best) == normalizeCastlingUci(played);
}

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewControllerProvider);

    // Ensure audio controller is initialized (wired to navigation events).
    ref.watch(reviewAudioProvider);

    final timeline = state.timeline;
    if (timeline == null) {
      return Scaffold(
        backgroundColor: ApexColors.darkSurface,
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text('No analysis loaded.',
              style: TextStyle(color: ApexColors.textTertiary)),
        ),
      );
    }

    final currentMove = state.currentMove;
    final isBrilliant =
        currentMove?.classification == MoveQuality.brilliant;

    return Scaffold(
      appBar: _buildAppBar(
        context,
        timeline.headers,
        state.flipped,
        () => ref.read(reviewControllerProvider.notifier).toggleFlip(),
      ),
      // Phase A audit § 6: the nav controls + scrubber live in a fixed
      // bottom bar so the board stays visible while the user scrolls
      // through the Full Move Report. Previously tapping "Full Move
      // Report" scrolled the controls off-screen and the user had to
      // scroll back up to advance a move.
      bottomNavigationBar: _ReviewBottomBar(
        currentPly: state.currentPly,
        totalPlies: state.totalPlies,
        onStart: () =>
            ref.read(reviewControllerProvider.notifier).goToStart(),
        onBack: () =>
            ref.read(reviewControllerProvider.notifier).prev(),
        onForward: () =>
            ref.read(reviewControllerProvider.notifier).next(),
        onEnd: () => ref.read(reviewControllerProvider.notifier).goToEnd(),
        onScrub: (ply) =>
            ref.read(reviewControllerProvider.notifier).jumpTo(ply),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Constrain the board so it never exceeds the viewport on
              // landscape / desktop — previously it consumed full width and
              // pushed the chart + nav controls off-screen (RenderFlex
              // overflow by ~800px on wide windows).
              final maxBoardWidth =
                  (constraints.maxHeight * 0.55).clamp(240.0, 560.0);
              final boardSize =
                  (constraints.maxWidth - 24).clamp(240.0, maxBoardWidth);

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      ApexEvalBar(
                        scoreCp: currentMove?.scoreCpAfter,
                        mateIn: currentMove?.mateInAfter,
                        depth: 0,
                        openingLabel: currentMove?.openingName,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          width: boardSize,
                          child: BrilliantGlow(
                            visible: isBrilliant,
                            child: ApexChessBoard(
                              fen: state.currentFen,
                              flipped: state.flipped,
                              lastMove: state.lastMove,
                              lastMoveQuality: currentMove?.classification,
                              betterMove: _shouldShowArrow(currentMove)
                                  ? _arrowFromUci(
                                      currentMove?.engineBestMoveUci)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      EvaluationChart(
                        winPercentages: timeline.winPercentages,
                        selectedPly:
                            state.currentPly >= 0 ? state.currentPly : null,
                        onPlySelected: (ply) {
                          ref
                              .read(reviewControllerProvider.notifier)
                              .jumpTo(ply);
                        },
                      ),
                      const SizedBox(height: 10),
                      _CoachCard(
                        move: currentMove,
                        ply: state.currentPly,
                        timeline: timeline,
                        mode: state.mode,
                        userIsWhite: state.userIsWhite,
                      ),
                      const SizedBox(height: 12),
                      // Full Move Report is now collapsible — the board
                      // stays in sight and the user opts in to the long
                      // list when they want to scan the whole game.
                      _CollapsibleMoveReport(
                        timeline: timeline,
                        currentPly: state.currentPly,
                        onTapPly: (ply) => ref
                            .read(reviewControllerProvider.notifier)
                            .jumpTo(ply),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Show the better-move arrow only when the played move was strictly
  /// worse than the engine's top line. We never overlay an arrow on
  /// Best / Brilliant / Great / Book — pointing at the user's own
  /// move is meaningless guidance.
  static bool _shouldShowArrow(MoveAnalysis? m) {
    if (m == null) return false;
    if (m.engineBestMoveUci == null) return false;
    switch (m.classification) {
      case MoveQuality.brilliant:
      case MoveQuality.great:
      case MoveQuality.best:
      case MoveQuality.book:
        return false;
      case MoveQuality.forced:
        // Forced means there was no real alternative — pointing the
        // user at "the same move" is misleading.
        return false;
      case MoveQuality.excellent:
      case MoveQuality.good:
      case MoveQuality.inaccuracy:
      case MoveQuality.mistake:
      case MoveQuality.missedWin:
      case MoveQuality.blunder:
        return true;
    }
  }

  /// Decompose a UCI string (e.g. `f8e7`, `e1g1`, `e7e8q`) into the
  /// algebraic source/destination tuple consumed by [ApexChessBoard].
  /// Returns `null` for malformed input — the board widget treats that
  /// as "no arrow".
  static (String, String)? _arrowFromUci(String? uci) {
    if (uci == null) return null;
    final norm = normalizeCastlingUci(uci);
    if (norm.length < 4) return null;
    return (norm.substring(0, 2), norm.substring(2, 4));
  }



  PreferredSizeWidget _buildAppBar(
    BuildContext context, [
    Map<String, String>? headers,
    bool flipped = false,
    VoidCallback? onFlip,
  ]) {
    final white = headers?['White'] ?? 'White';
    final black = headers?['Black'] ?? 'Black';
    final event = headers?['Event'];

    return AppBar(
      backgroundColor: ApexColors.darkSurface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded,
            color: ApexColors.textSecondary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        children: [
          Text(
            '$white vs $black',
            style: ApexTypography.titleMedium.copyWith(
              color: ApexColors.textPrimary,
              letterSpacing: 1,
              fontSize: 14,
            ),
          ),
          if (event != null)
            Text(
              event,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 11,
              ),
            ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (onFlip != null)
          IconButton(
            tooltip: flipped
                ? 'Flip board (currently Black-at-bottom)'
                : 'Flip board (currently White-at-bottom)',
            icon: const Icon(Icons.flip_camera_android_rounded,
                color: ApexColors.textSecondary),
            onPressed: onFlip,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coach Card
// ─────────────────────────────────────────────────────────────────────────────

class _CoachCard extends StatelessWidget {
  final MoveAnalysis? move;
  final int ply;
  final AnalysisTimeline? timeline;
  final AnalysisMode mode;
  final bool? userIsWhite;

  const _CoachCard({
    this.move,
    required this.ply,
    this.timeline,
    this.mode = AnalysisMode.deep,
    this.userIsWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ApexColors.cardSurface.withAlpha(200),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: move != null
                    ? move!.classification.color.withAlpha(60)
                    : ApexColors.electricBlue.withAlpha(30),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: move != null
                      ? move!.classification.color.withAlpha(15)
                      : ApexColors.electricBlue.withAlpha(8),
                  blurRadius: 20,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: move != null ? _moveContent() : _emptyContent(),
          ),
        ),
      ),
    );
  }

  Widget _moveContent() {
    final m = move!;
    // All coach copy flows through the single service — UI is now a
    // pure renderer, no classification/copy branching in the widget
    // layer. Phase 20.1 addendum rules (never "Better: <same>", mate
    // reads "Checkmate.", Quick-mode "Needs Deep Scan") are enforced
    // authoritatively by [CoachExplanationService].
    const svc = CoachExplanationService();
    final explanation = svc.explain(CoachExplanationInput(
      move: m,
      mode: mode,
      userIsWhite: userIsWhite,
      previousUserMove: _previousUserMove(m),
    ));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Premium SVG quality badge — the asset encodes the color + icon;
        // we drop a soft glow behind it and the ring becomes a thin ring
        // in the tier's color so the card still reads at a glance.
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: m.classification.color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: m.classification.color.withAlpha(60), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: m.classification.color.withAlpha(60),
                blurRadius: 10,
                spreadRadius: -2,
              ),
            ],
          ),
          child: SvgPicture.asset(
            m.classification.svgAssetPath,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                explanation.headline,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ApexTypography.titleMedium.copyWith(
                  color: m.classification.color,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                explanation.subline,
                style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary, fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (explanation.betterMoveSan != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Better: ${explanation.betterMoveSan}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.electricBlue.withAlpha(180),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (explanation.betterMoveReason != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      explanation.betterMoveReason!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ApexTypography.bodyMedium.copyWith(
                        color: ApexColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
              if (explanation.needsDeepScan) ...[
                const SizedBox(height: 8),
                const _NeedsDeepScanChip(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Find the user's ply immediately preceding the current one — used
  /// by the coach service to redirect "Allowed forced mate" blame to
  /// the correct ply. Returns `null` when we don't know the user's
  /// colour (unknown-side PGN paste) or when [move] is itself the
  /// first ply of the game.
  MoveAnalysis? _previousUserMove(MoveAnalysis m) {
    if (userIsWhite == null) return null;
    final t = timeline;
    if (t == null) return null;
    for (var i = m.ply - 1; i >= 0; i--) {
      final prior = t.moves[i];
      if (prior.isWhiteMove == userIsWhite) return prior;
    }
    return null;
  }

  Widget _emptyContent() {
    return Row(
      children: [
        Icon(Icons.psychology_rounded,
            color: ApexColors.electricBlue.withAlpha(120), size: 24),
        const SizedBox(width: 12),
        Text(
          'Navigate to see analysis',
          style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary),
        ),
      ],
    );
  }
}

/// Small amber chip surfaced under the coach card when the current
/// classification depends on Quick-mode eval and Deep analysis should
/// re-verify it. Intentionally stateless / stand-alone so the Live
/// Play screen can reuse it for the post-move feedback banner in
/// Phase 20.3.
class _NeedsDeepScanChip extends StatelessWidget {
  const _NeedsDeepScanChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ApexColors.inaccuracy.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ApexColors.inaccuracy.withAlpha(120),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.radar_rounded,
            size: 14,
            color: ApexColors.inaccuracy.withAlpha(220),
          ),
          const SizedBox(width: 6),
          Text(
            'Needs Deep Scan',
            style: ApexTypography.labelLarge.copyWith(
              color: ApexColors.inaccuracy.withAlpha(220),
              fontSize: 10,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Controls
// ─────────────────────────────────────────────────────────────────────────────

class _NavControls extends StatelessWidget {
  final int currentPly;
  final int totalPlies;
  final VoidCallback onStart;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onEnd;

  const _NavControls({
    required this.currentPly,
    required this.totalPlies,
    required this.onStart,
    required this.onBack,
    required this.onForward,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    // Each IconButton's default hitbox is 48×48; paired with the
    // padded ply-counter chip, five children used to exceed ~280 dp
    // before hitting the spaceEvenly distribution, yielding the
    // infamous yellow/black tape on ≤ 360 dp phones. We now clamp
    // each icon button with tight visual density + a Flexible-wrapped
    // counter so the whole bar scales down to the narrowest layout.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: ApexColors.elevatedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Row(
        children: [
          _navIcon(
            icon: Icons.skip_previous_rounded,
            color: ApexColors.textSecondary,
            onPressed: currentPly > -1 ? onStart : null,
          ),
          _navIcon(
            icon: Icons.chevron_left_rounded,
            color: ApexColors.electricBlue,
            iconSize: 28,
            onPressed: currentPly > -1 ? onBack : null,
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ApexColors.cardSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${currentPly + 1} / $totalPlies',
                    maxLines: 1,
                    style: ApexTypography.bodyMedium.copyWith(
                      fontFamily: 'JetBrains Mono',
                      color: ApexColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _navIcon(
            icon: Icons.chevron_right_rounded,
            color: ApexColors.electricBlue,
            iconSize: 28,
            onPressed: currentPly < totalPlies - 1 ? onForward : null,
          ),
          _navIcon(
            icon: Icons.skip_next_rounded,
            color: ApexColors.textSecondary,
            onPressed: currentPly < totalPlies - 1 ? onEnd : null,
          ),
        ],
      ),
    );
  }

  Widget _navIcon({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    double iconSize = 22,
  }) {
    return IconButton(
      icon: Icon(icon),
      iconSize: iconSize,
      color: color,
      padding: const EdgeInsets.all(6),
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: onPressed,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review bottom bar — fixed scrubber + nav controls that stay on-screen
// even while the Full Move Report is expanded. Phase A audit § 6.
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewBottomBar extends StatelessWidget {
  const _ReviewBottomBar({
    required this.currentPly,
    required this.totalPlies,
    required this.onStart,
    required this.onBack,
    required this.onForward,
    required this.onEnd,
    required this.onScrub,
  });

  final int currentPly;
  final int totalPlies;
  final VoidCallback onStart;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onEnd;
  final ValueChanged<int> onScrub;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ApexColors.cardSurface,
      elevation: 4,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (totalPlies > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                child: Slider(
                  value: currentPly
                      .clamp(-1, totalPlies - 1)
                      .toDouble()
                      // Shift `-1` (starting position) to `0` for the
                      // slider so the track starts at the left edge.
                      .let((v) => v + 1),
                  min: 0,
                  max: totalPlies.toDouble(),
                  divisions: totalPlies,
                  label: currentPly < 0
                      ? 'Start'
                      : 'Move ${(currentPly ~/ 2) + 1}'
                          '${currentPly.isEven ? '' : '…'}',
                  activeColor: ApexColors.electricBlue,
                  inactiveColor:
                      ApexColors.subtleBorder.withValues(alpha: 0.6),
                  onChanged: (v) => onScrub(v.round() - 1),
                ),
              ),
            const SizedBox(height: 2),
            _NavControls(
              currentPly: currentPly,
              totalPlies: totalPlies,
              onStart: onStart,
              onBack: onBack,
              onForward: onForward,
              onEnd: onEnd,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Local extension so the Slider `value` expression above stays readable.
extension _IntLet on double {
  T let<T>(T Function(double) f) => f(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// Collapsible wrapper around the Full Move Report — defaults to
// collapsed so the board stays visible on initial load. Phase A audit § 6.
// ─────────────────────────────────────────────────────────────────────────────

class _CollapsibleMoveReport extends StatefulWidget {
  const _CollapsibleMoveReport({
    required this.timeline,
    required this.currentPly,
    required this.onTapPly,
  });

  final AnalysisTimeline timeline;
  final int currentPly;
  final ValueChanged<int> onTapPly;

  @override
  State<_CollapsibleMoveReport> createState() =>
      _CollapsibleMoveReportState();
}

class _CollapsibleMoveReportState extends State<_CollapsibleMoveReport> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: ApexColors.elevatedSurface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: ApexColors.subtleBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: ApexColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Full Move Report',
                      style: ApexTypography.labelLarge.copyWith(
                        color: ApexColors.textPrimary,
                        letterSpacing: 1.6,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.timeline.moves.length} plies',
                      style: ApexTypography.bodyMedium.copyWith(
                        color: ApexColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded)
              _MoveReportList(
                timeline: widget.timeline,
                currentPly: widget.currentPly,
                onTapPly: widget.onTapPly,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full Move Report — every ply, scrollable, tap to jump.
// ─────────────────────────────────────────────────────────────────────────────

/// A compact per-ply timeline laid out below the coach card.
///
/// Each ply renders the move number ("12.", "12..."), the SAN played,
/// the post-move evaluation (centipawns or mate), the classification
/// chip, and — when the engine disagreed with the played move — the
/// suggested better SAN. Tapping a row jumps the review controller to
/// that ply, so the list doubles as a navigation shortcut. The list
/// height is capped so the rest of the review screen (board, chart,
/// nav controls) stays on-screen on phones.
class _MoveReportList extends StatelessWidget {
  const _MoveReportList({
    required this.timeline,
    required this.currentPly,
    required this.onTapPly,
  });

  final AnalysisTimeline timeline;
  final int currentPly;
  final ValueChanged<int> onTapPly;

  @override
  Widget build(BuildContext context) {
    if (timeline.moves.isEmpty) return const SizedBox.shrink();
    final opening = _resolveOpening();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface.withAlpha(160),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ApexColors.subtleBorder.withAlpha(120),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, opening == null ? 8 : 4),
            child: Text(
              'Full Move Report',
              style: ApexTypography.titleMedium.copyWith(
                color: ApexColors.textPrimary,
                fontSize: 13,
                letterSpacing: 1.5,
              ),
            ),
          ),
          if (opening != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Text(
                opening,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.electricBlue.withAlpha(170),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          // Cap the height so the list scrolls inside its own viewport
          // instead of pushing nav controls below the fold on narrow
          // phones. 320 dp comfortably shows ~9 plies; the user
          // scrolls (or taps the chart) for the rest.
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              shrinkWrap: true,
              itemCount: timeline.moves.length,
              itemBuilder: (context, i) {
                final m = timeline.moves[i];
                return _MoveRow(
                  move: m,
                  isCurrent: i == currentPly,
                  onTap: () => onTapPly(i),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Compose the "ECO · Opening name" line shown under the report
  /// title. We take the first non-null pair from any move's analysis
  /// — the analyser annotates them on book moves only, so it's
  /// effectively whichever variation the game stayed in longest. Falls
  /// back to PGN headers when the engine never matched a book entry,
  /// and finally to the generic "Opening phase" string when the game
  /// diverged from theory before any ECO entry could match (Phase 6
  /// fallback for the first 8–12 plies).
  String? _resolveOpening() {
    String? eco;
    String? name;
    for (final m in timeline.moves) {
      eco ??= m.ecoCode;
      name ??= m.openingName;
      if (eco != null && name != null) break;
    }
    eco ??= timeline.headers['ECO'];
    name ??= timeline.headers['Opening'];
    if (eco != null && name != null) return '$eco · $name';
    if (name != null || eco != null) return name ?? eco;
    if (timeline.moves.length <= 12) return 'Opening phase';
    return null;
  }
}

class _MoveRow extends StatelessWidget {
  const _MoveRow({
    required this.move,
    required this.isCurrent,
    required this.onTap,
  });

  final MoveAnalysis move;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final moveNum = '${(move.ply ~/ 2) + 1}${move.ply % 2 == 0 ? "." : "..."}';
    final cls = move.classification;
    final evalText = _evalString(move);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isCurrent
                ? cls.color.withAlpha(28)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrent
                  ? cls.color.withAlpha(120)
                  : Colors.transparent,
              width: 0.7,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  moveNum,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary,
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                  ),
                ),
              ),
              Container(
                width: 22,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  cls.svgAssetPath,
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      move.san,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ApexTypography.bodyMedium.copyWith(
                        color: cls.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Phase A audit: only surface "Better: …" on plies
                    // that actually deviate from the engine's top line.
                    // When the played move equals best we stay silent
                    // here — the coach card above already says "Top
                    // engine choice" and a duplicate line in the move
                    // list adds no value.
                    if (move.engineBestMoveSan != null &&
                        cls != MoveQuality.best &&
                        cls != MoveQuality.brilliant &&
                        cls != MoveQuality.great &&
                        cls != MoveQuality.book &&
                        cls != MoveQuality.forced &&
                        !_playedEqualsBest(move))
                      Text(
                        'Better: ${move.engineBestMoveSan}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ApexTypography.bodyMedium.copyWith(
                          color:
                              ApexColors.electricBlue.withAlpha(150),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                evalText,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textSecondary,
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _evalString(MoveAnalysis m) {
    if (m.mateInAfter != null) {
      return 'M${m.mateInAfter!.abs()}';
    }
    final cp = m.scoreCpAfter;
    if (cp == null) return '—';
    final p = (cp / 100).toStringAsFixed(2);
    return cp >= 0 ? '+$p' : p;
  }
}
