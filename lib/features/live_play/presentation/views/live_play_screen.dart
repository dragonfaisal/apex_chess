/// Live Play Screen — Apex AI Analyst edition.
///
/// Interactive board backed by the on-device Stockfish engine via
/// [LocalEvalService]. No network activity.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_chess_board.dart';
import 'package:apex_chess/shared_ui/widgets/apex_eval_bar.dart';
import 'package:apex_chess/shared_ui/widgets/brilliant_glow.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';
import '../controllers/live_play_controller.dart';

class LivePlayScreen extends ConsumerWidget {
  const LivePlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(livePlayProvider);
    final eval = s.evaluation;

    final isBrilliant =
        s.moveAnalysis?.quality == MoveQuality.brilliant;

    return Scaffold(
      appBar: _buildAppBar(context, ref, s),
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          // The screen was previously built with an `Expanded`-wrapped
          // board inside a plain `Column`. Once the CoachDashboard gained
          // the SVG badge + two-line copy its intrinsic height crossed
          // the point where `EvalBar + Dashboard + footer + paddings`
          // exceeded the viewport on ≤360 dp phones — at which point
          // `Expanded` gets 0 height but the non-flex children still
          // paint at their natural size, yielding the Axis.vertical
          // RenderFlex overflow tape under the board.
          //
          // This now mirrors `ReviewScreen`: a `LayoutBuilder` computes
          // a board size bounded by both the viewport width and a
          // fraction of the viewport height, and the whole column sits
          // inside a `SingleChildScrollView` so that if the content
          // ever does exceed the viewport (landscape, very small
          // phones, accessibility text scale) it becomes scrollable
          // instead of overflowing.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxBoardHeight =
                  (constraints.maxHeight * 0.62).clamp(240.0, 560.0);
              final boardSize =
                  (constraints.maxWidth - 24).clamp(240.0, maxBoardHeight);
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      ApexEvalBar(
                        scoreCp: eval?.scoreCp,
                        mateIn: eval?.mateIn,
                        depth: eval?.depth ?? 0,
                        isSearching: s.isEvaluating,
                        errorMessage: s.evalErrorMessage,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: SizedBox(
                          width: boardSize,
                          height: boardSize,
                          child: ApexChessBoard(
                            fen: s.currentFen,
                            selectedSquare: s.selectedSquare,
                            legalMoveSquares: s.legalMoves,
                            lastMove: s.lastMove,
                            isCheck: s.isCheck,
                            lastMoveQuality: s.moveAnalysis?.quality,
                            onSquareTapped: (square) {
                              ref
                                  .read(livePlayProvider.notifier)
                                  .onSquareTapped(square);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      BrilliantGlow(
                        visible: isBrilliant,
                        child: _CoachDashboard(
                          moveAnalysis: s.moveAnalysis,
                          isCheckmate: s.isCheckmate,
                          isStalemate: s.isStalemate,
                          isDraw: s.isDraw,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.memory_rounded,
                                color: ApexColors.sapphire
                                    .withValues(alpha: 0.55),
                                size: 14),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                eval != null
                                    ? '${ApexCopy.depthLabel} ${eval.depth}'
                                    : ApexCopy.liveEngineFooter,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ApexTypography.bodyMedium.copyWith(
                                    color: ApexColors.textTertiary,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, LivePlayState s) {
    return AppBar(
      backgroundColor: ApexColors.darkSurface,
      elevation: 0, scrolledUnderElevation: 0, toolbarHeight: 56,
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: ApexColors.textSecondary),
              onPressed: () => Navigator.of(context).pop())
          : null,
      title: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.auto_awesome,
            color: ApexColors.sapphireBright.withValues(alpha: 0.85), size: 20),
        const SizedBox(width: 8),
        Text(ApexCopy.appTitle,
            style: ApexTypography.titleMedium.copyWith(
              color: ApexColors.textPrimary, letterSpacing: 3,
              fontWeight: FontWeight.w700)),
      ]),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => ref.read(livePlayProvider.notifier).resetGame(),
          icon: const Icon(Icons.restart_alt_rounded,
              color: ApexColors.textTertiary, size: 22),
          tooltip: 'New game'),
        if (s.evalError != null)
          IconButton(
            onPressed: () => ref.read(livePlayProvider.notifier).refreshEval(),
            icon: const Icon(Icons.refresh_rounded,
                color: ApexColors.electricBlue, size: 22),
            tooltip: 'Retry cloud eval'),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coach Dashboard
// ─────────────────────────────────────────────────────────────────────────────

class _CoachDashboard extends StatelessWidget {
  final MoveAnalysisResult? moveAnalysis;
  final bool isCheckmate;
  final bool isStalemate;
  final bool isDraw;

  const _CoachDashboard({
    this.moveAnalysis,
    required this.isCheckmate,
    required this.isStalemate,
    required this.isDraw,
  });

  @override
  Widget build(BuildContext context) {
    final accent = moveAnalysis?.quality.color ?? ApexColors.sapphire;
    return GlassPanel(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      borderRadius: 16,
      accentColor: accent,
      accentAlpha: moveAnalysis != null ? 0.45 : 0.28,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isCheckmate) {
      return _statusRow('♚', 'CHECKMATE', ApexColors.sapphireBright);
    }
    if (isStalemate) return _statusRow('½', 'STALEMATE', ApexColors.textTertiary);
    if (isDraw) return _statusRow('½', 'DRAW', ApexColors.textTertiary);

    if (moveAnalysis != null) {
      final ma = moveAnalysis!;
      return Row(children: [
        Container(
          width: 44, height: 44, alignment: Alignment.center,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ma.quality.color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ma.quality.color.withAlpha(60), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: ma.quality.color.withAlpha(60),
                blurRadius: 10,
                spreadRadius: -2,
              ),
            ],
          ),
          // Premium SVG badge (assets/svg/<quality>.svg) — replaces the
          // old text symbol so Live Play matches the Review board.
          child: SvgPicture.asset(ma.quality.svgAssetPath, fit: BoxFit.contain),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ma.quality.label,
                style: ApexTypography.titleMedium.copyWith(
                    color: ma.quality.color, fontSize: 15)),
            const SizedBox(height: 2),
            Text(ma.message,
                style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        )),
      ]);
    }

    return Row(children: [
      Icon(Icons.auto_awesome,
          color: ApexColors.sapphireBright.withValues(alpha: 0.55), size: 24),
      const SizedBox(width: 12),
      // Wrap in `Expanded` so the brand + prompt string ellipsises on
      // narrow screens instead of forcing a horizontal RenderFlex
      // overflow inside the Coach Dashboard's glass panel.
      Expanded(
        child: Text(
          '${ApexCopy.engineBrand} — play a move to begin',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: ApexTypography.bodyMedium
              .copyWith(color: ApexColors.textTertiary),
        ),
      ),
    ]);
  }

  Widget _statusRow(String icon, String text, Color color) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(icon, style: TextStyle(fontSize: 22, color: color)),
      const SizedBox(width: 10),
      Text(text, style: ApexTypography.labelLarge.copyWith(
          color: color, letterSpacing: 4, fontSize: 16)),
    ]);
  }
}
