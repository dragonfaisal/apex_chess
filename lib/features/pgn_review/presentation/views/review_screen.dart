/// Premium move-by-move review board.
///
/// The screen renders existing review data only: board state, move quality,
/// coach copy, eval, and navigation all come from [ReviewController].
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_audio_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/models/review_board_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_chess_board.dart';
import 'package:apex_chess/shared_ui/widgets/brilliant_glow.dart';

bool shouldShowBetterMoveArrowForTesting(MoveAnalysis? move) =>
    ReviewBoardDisplayModel.shouldShowBetterMoveArrow(move);

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewControllerProvider);
    ref.watch(reviewAudioProvider);

    final timeline = state.timeline;
    if (timeline == null) {
      return Scaffold(
        backgroundColor: ApexColors.darkSurface,
        appBar: _buildAppBar(context),
        body: const Center(
          child: Text(
            'No analysis loaded.',
            style: TextStyle(color: ApexColors.textTertiary),
          ),
        ),
      );
    }

    final controller = ref.read(reviewControllerProvider.notifier);
    final display = ReviewBoardDisplayModel.fromTimeline(
      timeline,
      currentPly: state.currentPly,
      flipped: state.flipped,
      mode: state.mode,
      userIsWhite: state.userIsWhite,
    );

    return Scaffold(
      appBar: _buildAppBar(context, display),
      bottomNavigationBar: _ReviewActionBar(
        display: display,
        onPrevious: controller.prev,
        onNext: controller.next,
        onScrub: controller.jumpTo,
        onMoves: () => _showMoveList(context, controller.jumpTo),
        onExplain: () => _showCoachExplain(context),
        onBetter: display.insight.betterMove == null
            ? null
            : () => _showBestMove(context, display),
        onLine: () => _showLineSheet(context),
        onFlip: controller.toggleFlip,
        onSummary: () => Navigator.of(context).maybePop(),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final boardMaxFromHeight = constraints.maxHeight * 0.47;
              final boardSize = (constraints.maxWidth - 74)
                  .clamp(240.0, boardMaxFromHeight.clamp(260.0, 520.0))
                  .toDouble();

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PlayerHeader(
                      key: const ValueKey('review-top-player-header'),
                      player: display.topPlayer,
                      compact: true,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: SizedBox(
                        width: boardSize + 38,
                        child: _BoardWithEval(display: display),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PlayerHeader(
                      key: const ValueKey('review-bottom-player-header'),
                      player: display.bottomPlayer,
                    ),
                    const SizedBox(height: 10),
                    _CoachInsightPanel(display: display),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context, [
    ReviewBoardDisplayModel? display,
  ]) {
    final title = display == null
        ? 'Review'
        : '${display.bottomPlayer.username} vs ${display.topPlayer.username}';
    return AppBar(
      backgroundColor: ApexColors.darkSurface,
      elevation: 0,
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Review',
            style: ApexTypography.titleMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 15,
            ),
          ),
          if (display != null)
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({super.key, required this.player, this.compact = false});

  final ReviewPlayerHeaderDisplay player;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: compact ? 7 : 8,
          ),
          decoration: BoxDecoration(
            color: ApexColors.cardSurface.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ApexColors.stardustLine.withValues(alpha: 0.62),
              width: 0.6,
            ),
          ),
          child: Row(
            children: [
              _PlayerAvatar(player: player),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      player.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ApexTypography.titleMedium.copyWith(
                        color: ApexColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        player.sideLabel,
                        if (player.rating != null) player.rating!,
                      ].join(' · '),
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
              if (player.isUser) const _MiniChip(label: 'YOU'),
              if (player.result != null) ...[
                const SizedBox(width: 6),
                _MiniChip(label: player.result!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({required this.player});

  final ReviewPlayerHeaderDisplay player;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = player.avatarUrl;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: player.side == ReviewBoardSide.white
            ? const LinearGradient(colors: [Colors.white, Color(0xFFBFD7FF)])
            : const LinearGradient(
                colors: [ApexColors.nebula, ApexColors.trueBlack],
              ),
        border: Border.all(
          color: player.isUser
              ? ApexColors.sapphireBright.withValues(alpha: 0.75)
              : ApexColors.subtleBorder,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl == null
          ? Center(
              child: Text(
                player.initial,
                style: ApexTypography.labelLarge.copyWith(
                  color: player.side == ReviewBoardSide.white
                      ? ApexColors.trueBlack
                      : ApexColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            )
          : Image.network(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  player.initial,
                  style: ApexTypography.labelLarge.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: ApexColors.sapphire.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ApexColors.sapphireBright.withValues(alpha: 0.42),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: ApexTypography.labelLarge.copyWith(
          color: ApexColors.sapphireBright,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _BoardWithEval extends StatelessWidget {
  const _BoardWithEval({required this.display});

  final ReviewBoardDisplayModel display;

  @override
  Widget build(BuildContext context) {
    final currentMove = display.currentMove;
    return Row(
      key: const ValueKey('review-board-section'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _VerticalEvalBar(display: display.eval, flipped: display.flipped),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: ApexColors.nebula.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _boardAccent(display).withValues(alpha: 0.42),
                    width: 0.9,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _boardAccent(display).withValues(alpha: 0.16),
                      blurRadius: 24,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: BrilliantGlow(
                  visible: currentMove?.classification == MoveQuality.brilliant,
                  child: ApexChessBoard(
                    fen: display.currentFen,
                    flipped: display.flipped,
                    lastMove: display.lastMove,
                    selectedSquare: display.selectedSquare,
                    lastMoveQuality: currentMove?.classification,
                    betterMove: display.bestMoveArrow,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _boardAccent(ReviewBoardDisplayModel display) {
    return display.currentMove == null
        ? ApexColors.sapphire
        : display.insight.quality.color;
  }
}

class _VerticalEvalBar extends StatelessWidget {
  const _VerticalEvalBar({required this.display, required this.flipped});

  final ReviewEvalDisplay display;
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 248,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: ApexColors.trueBlack.withValues(alpha: 0.92),
            border: Border.all(
              color: ApexColors.subtleBorder.withValues(alpha: 0.8),
              width: 0.6,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: display.whiteShare),
                  duration: ApexMotion.normal,
                  curve: ApexMotion.standard,
                  builder: (context, share, _) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final height = constraints.maxHeight * share;
                        return Align(
                          alignment: flipped
                              ? Alignment.topCenter
                              : Alignment.bottomCenter,
                          child: SizedBox(
                            height: height,
                            width: constraints.maxWidth,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.96),
                                    Colors.white.withValues(alpha: 0.68),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                top: 123.5,
                child: Divider(height: 1, color: ApexColors.sapphireDeep),
              ),
              Align(
                alignment: Alignment.center,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: ApexColors.nebula.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      display.label,
                      maxLines: 1,
                      style: ApexTypography.monoEval.copyWith(
                        color: display.isEqual
                            ? ApexColors.textSecondary
                            : display.whiteBetter
                            ? Colors.white
                            : ApexColors.textPrimary,
                        fontSize: 11,
                      ),
                    ),
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

class _CoachInsightPanel extends StatelessWidget {
  const _CoachInsightPanel({required this.display});

  final ReviewBoardDisplayModel display;

  @override
  Widget build(BuildContext context) {
    final insight = display.insight;
    return ClipRRect(
      key: const ValueKey('review-coach-insight'),
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: ApexMotion.normal,
          curve: ApexMotion.standard,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: ApexColors.cardSurface.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: insight.quality.color.withValues(alpha: 0.42),
              width: 0.7,
            ),
          ),
          child: AnimatedSwitcher(
            duration: ApexMotion.fast,
            child: Column(
              key: ValueKey('insight-${display.currentPly}'),
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _QualityChip(display: insight.quality),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${insight.moveLabel} ${insight.san}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ApexTypography.titleMedium.copyWith(
                          color: ApexColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  insight.explanation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (insight.betterMove != null) ...[
                  const SizedBox(height: 8),
                  _InlineHint(
                    icon: Icons.north_east_rounded,
                    label: 'Better',
                    value: insight.betterMove!,
                    color: ApexColors.sapphireBright,
                  ),
                ],
                if (insight.engineLinePreview != null) ...[
                  const SizedBox(height: 6),
                  _InlineHint(
                    icon: Icons.timeline_rounded,
                    label: 'Line',
                    value: insight.engineLinePreview!,
                    color: ApexColors.textTertiary,
                  ),
                ],
                if (insight.needsDeepScan) ...[
                  const SizedBox(height: 6),
                  _InlineHint(
                    icon: Icons.radar_rounded,
                    label: 'Deep',
                    value: 'Review suggested',
                    color: ApexColors.inaccuracy,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QualityChip extends StatelessWidget {
  const _QualityChip({required this.display});

  final ReviewMoveQualityChipDisplay display;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: display.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: display.color.withValues(alpha: 0.5)),
      ),
      child: Text(
        display.marker.isEmpty
            ? display.label
            : '${display.label} ${display.marker}',
        style: ApexTypography.labelLarge.copyWith(
          color: display.color,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _InlineHint extends StatelessWidget {
  const _InlineHint({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(
          label,
          style: ApexTypography.labelLarge.copyWith(color: color, fontSize: 11),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _MoveTimelineScrubber extends StatefulWidget {
  const _MoveTimelineScrubber({
    super.key,
    required this.items,
    required this.activePly,
    required this.onTapPly,
  });

  final List<ReviewTimelinePlyDisplay> items;
  final int activePly;
  final ValueChanged<int> onTapPly;

  @override
  State<_MoveTimelineScrubber> createState() => _MoveTimelineScrubberState();
}

class _MoveTimelineScrubberState extends State<_MoveTimelineScrubber> {
  final _controller = ScrollController();

  @override
  void didUpdateWidget(covariant _MoveTimelineScrubber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activePly != widget.activePly) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollToActive() {
    if (!_controller.hasClients || widget.items.isEmpty) return;
    final target = (widget.activePly * 76.0).clamp(
      0.0,
      _controller.position.maxScrollExtent,
    );
    _controller.animateTo(
      target,
      duration: ApexMotion.normal,
      curve: ApexMotion.standard,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 54,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return _TimelinePill(
            item: item,
            onTap: () => widget.onTapPly(item.ply),
          );
        },
      ),
    );
  }
}

class _TimelinePill extends StatelessWidget {
  const _TimelinePill({required this.item, required this.onTap});

  final ReviewTimelinePlyDisplay item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: ApexMotion.fast,
          width: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: item.isActive
                ? item.color.withValues(alpha: 0.18)
                : ApexColors.nebula.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.isActive
                  ? item.color.withValues(alpha: 0.65)
                  : ApexColors.subtleBorder.withValues(alpha: 0.62),
              width: 0.7,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ApexTypography.bodyMedium.copyWith(
                  color: item.isActive ? item.color : ApexColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.marker.isEmpty ? 'Move' : item.marker,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewActionBar extends StatelessWidget {
  const _ReviewActionBar({
    required this.display,
    required this.onPrevious,
    required this.onNext,
    required this.onScrub,
    required this.onMoves,
    required this.onExplain,
    required this.onBetter,
    required this.onLine,
    required this.onFlip,
    required this.onSummary,
  });

  final ReviewBoardDisplayModel display;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onScrub;
  final VoidCallback onMoves;
  final VoidCallback onExplain;
  final VoidCallback? onBetter;
  final VoidCallback onLine;
  final VoidCallback onFlip;
  final VoidCallback onSummary;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey('review-nav-controls'),
      color: ApexColors.nebula.withValues(alpha: 0.96),
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MoveTimelineScrubber(
                key: const ValueKey('review-timeline'),
                items: display.timeline,
                activePly: display.currentPly,
                onTapPly: onScrub,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(
                    width: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _ActionIcon(
                        key: const ValueKey('review-move-list-button'),
                        tooltip: 'Moves',
                        icon: Icons.format_list_bulleted_rounded,
                        onPressed: onMoves,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionIcon(
                            key: const ValueKey('review-prev-button'),
                            tooltip: 'Previous',
                            icon: Icons.chevron_left_rounded,
                            onPressed: display.canGoPrevious
                                ? onPrevious
                                : null,
                            accent: ApexColors.sapphireBright,
                          ),
                          SizedBox(
                            width: 72,
                            child: Text(
                              '${display.currentPly + 1} / ${display.totalPlies}',
                              key: const ValueKey('review-ply-counter'),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: ApexTypography.monoEval.copyWith(
                                color: ApexColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          _ActionIcon(
                            key: const ValueKey('review-next-button'),
                            tooltip: 'Next',
                            icon: Icons.chevron_right_rounded,
                            onPressed: display.canGoNext ? onNext : null,
                            accent: ApexColors.sapphireBright,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _CoachCommandOrb(
                        onExplain: onExplain,
                        onBetter: onBetter,
                        onLine: onLine,
                        onFlip: onFlip,
                        onSummary: onSummary,
                      ),
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
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.accent = ApexColors.textSecondary,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: const EdgeInsets.all(6),
        icon: Icon(icon),
        color: accent,
        disabledColor: ApexColors.textTertiary.withValues(alpha: 0.38),
        onPressed: onPressed,
      ),
    );
  }
}

class _CoachCommandOrb extends StatefulWidget {
  const _CoachCommandOrb({
    required this.onExplain,
    required this.onBetter,
    required this.onLine,
    required this.onFlip,
    required this.onSummary,
  });

  final VoidCallback onExplain;
  final VoidCallback? onBetter;
  final VoidCallback onLine;
  final VoidCallback onFlip;
  final VoidCallback onSummary;

  @override
  State<_CoachCommandOrb> createState() => _CoachCommandOrbState();
}

class _CoachCommandOrbState extends State<_CoachCommandOrb> {
  OverlayEntry? _entry;

  bool get _isOpen => _entry != null;

  @override
  void didUpdateWidget(covariant _CoachCommandOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_entry == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entry?.markNeedsBuild();
    });
  }

  @override
  void dispose() {
    _removeMenu(notify: false);
    super.dispose();
  }

  void _toggleMenu() => _isOpen ? _closeMenu() : _openMenu();

  void _openMenu() {
    final overlay = Overlay.of(context);
    _entry = OverlayEntry(
      builder: (overlayContext) {
        final bottom = MediaQuery.paddingOf(overlayContext).bottom + 108;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                key: const ValueKey('review-command-outside-dismiss'),
                behavior: HitTestBehavior.translucent,
                onTap: _closeMenu,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              right: 12,
              bottom: bottom,
              child: _CoachCommandMenu(
                onExplain: () => _runCommand(widget.onExplain),
                onBetter: widget.onBetter == null
                    ? null
                    : () => _runCommand(widget.onBetter!),
                onLine: () => _runCommand(widget.onLine),
                onFlip: () => _runCommand(widget.onFlip),
                onSummary: () => _runCommand(widget.onSummary),
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(_entry!);
    setState(() {});
  }

  void _closeMenu() {
    _removeMenu();
  }

  void _removeMenu({bool notify = true}) {
    final entry = _entry;
    if (entry == null) return;
    _entry = null;
    entry.remove();
    if (notify && mounted) setState(() {});
  }

  void _runCommand(VoidCallback command) {
    _closeMenu();
    command();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isOpen ? 1.04 : 1,
      duration: ApexMotion.fast,
      curve: ApexMotion.standard,
      child: Tooltip(
        message: 'Coach',
        child: InkResponse(
          key: const ValueKey('review-coach-orb'),
          onTap: _toggleMenu,
          radius: 24,
          child: AnimatedContainer(
            duration: ApexMotion.fast,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ApexColors.cardSurface.withValues(alpha: 0.92),
              border: Border.all(
                color: ApexColors.sapphireBright.withValues(
                  alpha: _isOpen ? 0.85 : 0.36,
                ),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: ApexColors.sapphireBright.withValues(
                    alpha: _isOpen ? 0.28 : 0.08,
                  ),
                  blurRadius: _isOpen ? 18 : 10,
                  spreadRadius: _isOpen ? -2 : -6,
                ),
              ],
            ),
            child: Icon(
              Icons.psychology_alt_rounded,
              color: _isOpen
                  ? ApexColors.sapphireBright
                  : ApexColors.textSecondary,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class _CoachCommandMenu extends StatelessWidget {
  const _CoachCommandMenu({
    required this.onExplain,
    required this.onBetter,
    required this.onLine,
    required this.onFlip,
    required this.onSummary,
  });

  final VoidCallback onExplain;
  final VoidCallback? onBetter;
  final VoidCallback onLine;
  final VoidCallback onFlip;
  final VoidCallback onSummary;

  @override
  Widget build(BuildContext context) {
    final actions = <_CoachCommandAction>[
      _CoachCommandAction(
        label: 'Explain',
        icon: Icons.chat_bubble_outline_rounded,
        onTap: onExplain,
      ),
      if (onBetter != null)
        _CoachCommandAction(
          label: 'Better',
          icon: Icons.north_east_rounded,
          onTap: onBetter!,
        ),
      _CoachCommandAction(
        label: 'Line',
        icon: Icons.timeline_rounded,
        onTap: onLine,
      ),
      _CoachCommandAction(
        label: 'Flip',
        icon: Icons.screen_rotation_alt_rounded,
        onTap: onFlip,
      ),
      _CoachCommandAction(
        label: 'Summary',
        icon: Icons.analytics_outlined,
        onTap: onSummary,
      ),
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: ApexMotion.normal,
      curve: ApexMotion.standard,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: Transform.scale(
              scale: 0.96 + (0.04 * value),
              alignment: Alignment.bottomRight,
              child: child,
            ),
          ),
        );
      },
      child: Material(
        key: const ValueKey('review-coach-command-menu'),
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 152,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: ApexColors.cardSurface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ApexColors.sapphireBright.withValues(alpha: 0.36),
                  width: 0.7,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ApexColors.sapphireBright.withValues(alpha: 0.13),
                    blurRadius: 20,
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final action in actions)
                    _CoachCommandButton(action: action),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoachCommandAction {
  const _CoachCommandAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _CoachCommandButton extends StatelessWidget {
  const _CoachCommandButton({required this.action});

  final _CoachCommandAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: ValueKey('review-command-${action.label.toLowerCase()}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Icon(action.icon, color: ApexColors.sapphireBright, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

void _showBestMove(BuildContext context, ReviewBoardDisplayModel display) {
  final best = display.insight.betterMove;
  if (best == null) return;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Better',
            style: ApexTypography.titleMedium.copyWith(
              color: ApexColors.sapphireBright,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            best,
            style: ApexTypography.headlineMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 24,
            ),
          ),
        ],
      ),
    ),
  );
}

void _showCoachExplain(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CoachExplainSheet(),
  );
}

void _showLineSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LineSheet(),
  );
}

void _showMoveList(BuildContext context, ValueChanged<int> onTapPly) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MoveListSheet(
      onTapPly: (ply) {
        onTapPly(ply);
      },
    ),
  );
}

class _CoachExplainSheet extends ConsumerWidget {
  const _CoachExplainSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = _displayFromReviewState(
      ref.watch(reviewControllerProvider),
    );
    final insight = display?.insight;
    return _GlassSheet(
      child: Column(
        key: const ValueKey('review-coach-explain-sheet'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Coach',
                style: ApexTypography.titleMedium.copyWith(
                  color: ApexColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (display == null || insight == null)
            Text(
              'No deeper explanation available for this move.',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 13,
              ),
            )
          else ...[
            Row(
              children: [
                _QualityChip(display: insight.quality),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${insight.moveLabel} ${insight.san}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ApexTypography.titleMedium.copyWith(
                      color: ApexColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              insight.coachDetail,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 13,
              ),
            ),
            if (insight.betterMove != null) ...[
              const SizedBox(height: 12),
              _InlineHint(
                icon: Icons.north_east_rounded,
                label: 'Better',
                value: 'Better was ${insight.betterMove}.',
                color: ApexColors.sapphireBright,
              ),
            ],
            if (insight.engineLinePreview != null) ...[
              const SizedBox(height: 8),
              _InlineHint(
                icon: Icons.timeline_rounded,
                label: 'Line',
                value: insight.engineLinePreview!,
                color: ApexColors.textTertiary,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _LineSheet extends ConsumerWidget {
  const _LineSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = _displayFromReviewState(
      ref.watch(reviewControllerProvider),
    );
    final insight = display?.insight;
    return _GlassSheet(
      child: Column(
        key: const ValueKey('review-line-sheet'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Line',
                style: ApexTypography.titleMedium.copyWith(
                  color: ApexColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (insight?.engineLinePreview != null)
            _SheetLinePreview(
              label: 'Line',
              value: insight!.engineLinePreview!,
              color: ApexColors.sapphireBright,
            )
          else
            Text(
              'No line available.',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 13,
              ),
            ),
          if (insight?.betterMove != null) ...[
            const SizedBox(height: 8),
            _SheetLinePreview(
              label: 'Better',
              value: insight!.betterMove!,
              color: ApexColors.sapphireBright,
            ),
          ],
        ],
      ),
    );
  }
}

class _MoveListSheet extends ConsumerWidget {
  const _MoveListSheet({required this.onTapPly});

  final ValueChanged<int> onTapPly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = _displayFromReviewState(
      ref.watch(reviewControllerProvider),
    );
    return _GlassSheet(
      child: ConstrainedBox(
        key: const ValueKey('review-move-list-sheet'),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.62,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Moves',
                  style: ApexTypography.titleMedium.copyWith(
                    color: ApexColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (display?.insight.engineLinePreview != null) ...[
              _SheetLinePreview(
                label: 'Current line',
                value: display!.insight.engineLinePreview!,
                color: ApexColors.textTertiary,
              ),
              const SizedBox(height: 8),
            ],
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: display?.timeline.length ?? 0,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = display!.timeline[index];
                  return _MoveListRow(
                    item: item,
                    onTap: () => onTapPly(item.ply),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ReviewBoardDisplayModel? _displayFromReviewState(ReviewState state) {
  final timeline = state.timeline;
  if (timeline == null) return null;
  return ReviewBoardDisplayModel.fromTimeline(
    timeline,
    currentPly: state.currentPly,
    flipped: state.flipped,
    mode: state.mode,
    userIsWhite: state.userIsWhite,
  );
}

class _SheetLinePreview extends StatelessWidget {
  const _SheetLinePreview({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ApexColors.nebula.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ApexColors.subtleBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: ApexTypography.labelLarge.copyWith(
              color: color,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoveListRow extends StatelessWidget {
  const _MoveListRow({required this.item, required this.onTap});

  final ReviewTimelinePlyDisplay item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          key: item.isActive
              ? ValueKey('review-move-row-active-${item.ply}')
              : ValueKey('review-move-row-${item.ply}'),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: item.isActive
                ? item.color.withValues(alpha: 0.16)
                : ApexColors.nebula.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: item.isActive
                  ? item.color.withValues(alpha: 0.55)
                  : ApexColors.subtleBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  item.marker.isEmpty ? 'Move' : item.marker,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: item.color,
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
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

class _GlassSheet extends StatelessWidget {
  const _GlassSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ApexColors.cardSurface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: ApexColors.stardustLine.withValues(alpha: 0.72),
                  width: 0.7,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
