/// Live Play Screen — Cloud-Only edition.
///
/// Interactive board with cloud-based evaluation.
/// Shows graceful errors when offline or rate-limited.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_chess_board.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import '../controllers/live_play_controller.dart';

class LivePlayScreen extends ConsumerWidget {
  const LivePlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(livePlayProvider);
    final eval = s.evaluation;

    return Scaffold(
      backgroundColor: ApexColors.darkSurface,
      appBar: _buildAppBar(context, ref, s),
      body: SafeArea(
        child: Column(
          children: [
            _CloudEvalBar(
              scoreCp: eval?.scoreCp,
              mateIn: eval?.mateIn,
              depth: eval?.depth ?? 0,
              isSearching: s.isEvaluating,
              errorMessage: s.evalErrorMessage,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ApexChessBoard(
                fen: s.currentFen,
                selectedSquare: s.selectedSquare,
                legalMoveSquares: s.legalMoves,
                lastMove: s.lastMove,
                isCheck: s.isCheck,
                lastMoveQuality: s.moveAnalysis?.quality,
                onSquareTapped: (square) {
                  ref.read(livePlayProvider.notifier).onSquareTapped(square);
                },
              ),
            ),
            const SizedBox(height: 12),
            _CoachDashboard(
              moveAnalysis: s.moveAnalysis,
              isCheckmate: s.isCheckmate,
              isStalemate: s.isStalemate,
              isDraw: s.isDraw,
            ),
            const Spacer(),
            // Cloud-first badge.
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_rounded,
                      color: ApexColors.electricBlue.withAlpha(120), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    eval != null
                        ? 'Cloud Depth ${eval.depth}'
                        : 'Lichess Cloud Eval',
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
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
            color: ApexColors.electricBlue.withAlpha(180), size: 20),
        const SizedBox(width: 8),
        Text('APEX CHESS',
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
// Cloud Eval Bar (replaces local engine eval bar)
// ─────────────────────────────────────────────────────────────────────────────

class _CloudEvalBar extends StatelessWidget {
  final int? scoreCp;
  final int? mateIn;
  final int depth;
  final bool isSearching;
  final String? errorMessage;

  const _CloudEvalBar({
    this.scoreCp, this.mateIn,
    required this.depth, required this.isSearching,
    this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: ApexColors.elevatedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorMessage != null
              ? ApexColors.mistake.withAlpha(60)
              : ApexColors.subtleBorder,
          width: 0.5)),
      child: Row(children: [
        Container(
          width: 72, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _scoreBadgeColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(11.5),
              bottomLeft: Radius.circular(11.5))),
          child: errorMessage != null
              ? Icon(Icons.cloud_off_rounded,
                  color: ApexColors.mistake.withAlpha(180), size: 20)
              : Text(_scoreText,
                  style: ApexTypography.monoEval.copyWith(
                      color: _scoreTextColor, fontSize: 16)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: errorMessage != null
              ? Text(errorMessage!,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.mistake.withAlpha(200), fontSize: 11),
                  maxLines: 1, overflow: TextOverflow.ellipsis)
              : Text(depth > 0 ? 'Cloud D$depth' : '—',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary,
                    fontFamily: 'JetBrains Mono', fontSize: 12)),
        ),
        if (isSearching)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2,
                  color: ApexColors.electricBlue.withAlpha(180)))),
      ]),
    );
  }

  String get _scoreText {
    if (mateIn != null) return 'M${mateIn!.abs()}';
    if (scoreCp == null) return '—';
    final pawns = scoreCp! / 100;
    final sign = pawns >= 0 ? '+' : '';
    return '$sign${pawns.toStringAsFixed(1)}';
  }

  Color get _scoreBadgeColor {
    if (errorMessage != null) return ApexColors.cardSurface;
    if (mateIn != null) return mateIn! > 0 ? Colors.white : ApexColors.trueBlack;
    if (scoreCp == null) return ApexColors.cardSurface;
    return scoreCp! >= 0 ? Colors.white : ApexColors.trueBlack;
  }

  Color get _scoreTextColor {
    if (mateIn != null) return mateIn! > 0 ? ApexColors.trueBlack : Colors.white;
    if (scoreCp == null) return ApexColors.textTertiary;
    return scoreCp! >= 0 ? ApexColors.trueBlack : Colors.white;
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
              border: Border.all(color: _borderColor, width: 0.8),
              boxShadow: [
                BoxShadow(color: _glowColor, blurRadius: 20, spreadRadius: -4),
              ]),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Color get _borderColor => moveAnalysis != null
      ? moveAnalysis!.quality.color.withAlpha(60)
      : ApexColors.electricBlue.withAlpha(30);

  Color get _glowColor => moveAnalysis != null
      ? moveAnalysis!.quality.color.withAlpha(15)
      : ApexColors.electricBlue.withAlpha(8);

  Widget _buildContent() {
    if (isCheckmate) return _statusRow('♚', 'CHECKMATE', ApexColors.electricBlue);
    if (isStalemate) return _statusRow('½', 'STALEMATE', ApexColors.textTertiary);
    if (isDraw) return _statusRow('½', 'DRAW', ApexColors.textTertiary);

    if (moveAnalysis != null) {
      final ma = moveAnalysis!;
      return Row(children: [
        Container(
          width: 44, height: 44, alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ma.quality.color.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ma.quality.color.withAlpha(60), width: 0.5)),
          child: Text(
            ma.quality.symbol.isEmpty ? '✓' : ma.quality.symbol,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: ma.quality.color)),
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
      Icon(Icons.cloud_rounded,
          color: ApexColors.electricBlue.withAlpha(120), size: 24),
      const SizedBox(width: 12),
      Text('Cloud Coach — play a move to begin',
          style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary)),
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
