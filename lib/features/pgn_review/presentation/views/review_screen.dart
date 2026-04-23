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

import '../../../../shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/shared_ui/widgets/apex_chess_board.dart';
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
                      _EvalBar(move: currentMove),
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
// Eval Bar
// ─────────────────────────────────────────────────────────────────────────────

class _EvalBar extends StatelessWidget {
  final MoveAnalysis? move;
  const _EvalBar({this.move});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ApexColors.elevatedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _badgeColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11.5),
                bottomLeft: Radius.circular(11.5),
              ),
            ),
            child: Text(
              _scoreText,
              style: ApexTypography.monoEval.copyWith(
                  color: _textColor, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          if (move != null) ...[
            Text(
              'Win ${move!.winPercentAfter.toStringAsFixed(1)}%',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
              ),
            ),
            const Spacer(),
            if (move!.openingName != null)
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ApexColors.book.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: ApexColors.book.withAlpha(40)),
                  ),
                  child: Text(
                    move!.openingName!,
                    style: TextStyle(
                      color: ApexColors.book,
                      fontSize: 11,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ),
              ),
          ] else ...[
            Text(
              'Starting position',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 12,
              ),
            ),
            const Spacer(),
          ],
        ],
      ),
    );
  }

  String get _scoreText {
    if (move == null) return '0.0';
    final cp = move!.scoreCpAfter;
    if (move!.mateInAfter != null) return 'M${move!.mateInAfter!.abs()}';
    if (cp == null) return '—';
    final pawns = cp / 100;
    final sign = pawns >= 0 ? '+' : '';
    return '$sign${pawns.toStringAsFixed(1)}';
  }

  Color get _badgeColor {
    if (move == null) return ApexColors.cardSurface;
    final cp = move!.scoreCpAfter ?? 0;
    return cp >= 0 ? Colors.white : ApexColors.trueBlack;
  }

  Color get _textColor {
    if (move == null) return ApexColors.textTertiary;
    final cp = move!.scoreCpAfter ?? 0;
    return cp >= 0 ? ApexColors.trueBlack : Colors.white;
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
      children: [
        // Quality badge
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: m.classification.color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: m.classification.color.withAlpha(60), width: 0.5),
          ),
          child: Text(
            m.classification.symbol.isEmpty ? '✓' : m.classification.symbol,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: m.classification.color,
            ),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (m.engineBestMoveSan != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Better: ${m.engineBestMoveSan}',
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: ApexColors.elevatedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded),
            color: ApexColors.textSecondary,
            onPressed: currentPly > -1 ? onStart : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 32),
            color: ApexColors.electricBlue,
            onPressed: currentPly > -1 ? onBack : null,
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: ApexColors.cardSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${currentPly + 1} / $totalPlies',
              style: ApexTypography.bodyMedium.copyWith(
                fontFamily: 'JetBrains Mono',
                color: ApexColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 32),
            color: ApexColors.electricBlue,
            onPressed: currentPly < totalPlies - 1 ? onForward : null,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next_rounded),
            color: ApexColors.textSecondary,
            onPressed: currentPly < totalPlies - 1 ? onEnd : null,
          ),
        ],
      ),
    );
  }
}
