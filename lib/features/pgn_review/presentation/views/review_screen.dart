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
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/shared_ui/widgets/apex_chess_board.dart';
import 'package:apex_chess/shared_ui/widgets/apex_eval_bar.dart';
import 'package:apex_chess/shared_ui/widgets/brilliant_glow.dart';
import 'package:apex_chess/shared_ui/widgets/evaluation_chart.dart';
import '../controllers/review_controller.dart';
import '../controllers/review_audio_controller.dart';

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
      appBar: _buildAppBar(context, timeline.headers),
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
                              lastMove: state.lastMove,
                              lastMoveQuality: currentMove?.classification,
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
                      _CoachCard(move: currentMove, ply: state.currentPly),
                      const SizedBox(height: 16),
                      _NavControls(
                        currentPly: state.currentPly,
                        totalPlies: state.totalPlies,
                        onStart: () => ref
                            .read(reviewControllerProvider.notifier)
                            .goToStart(),
                        onBack: () => ref
                            .read(reviewControllerProvider.notifier)
                            .prev(),
                        onForward: () => ref
                            .read(reviewControllerProvider.notifier)
                            .next(),
                        onEnd: () => ref
                            .read(reviewControllerProvider.notifier)
                            .goToEnd(),
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

  PreferredSizeWidget _buildAppBar(BuildContext context,
      [Map<String, String>? headers]) {
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coach Card
// ─────────────────────────────────────────────────────────────────────────────

class _CoachCard extends StatelessWidget {
  final MoveAnalysis? move;
  final int ply;
  const _CoachCard({this.move, required this.ply});

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
    final moveNum = '${(ply ~/ 2) + 1}${ply % 2 == 0 ? "." : "..."}';

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
                '$moveNum ${m.san} — ${m.classification.label}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ApexTypography.titleMedium.copyWith(
                  color: m.classification.color,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                m.message,
                style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (m.engineBestMoveSan != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Better: ${m.engineBestMoveSan}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.electricBlue.withAlpha(160),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
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
