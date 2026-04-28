/// Chess.com-style summary screen shown after analysis completes,
/// **before** the detailed move-by-move review.
///
/// Phase 20.1 § 3 contract: every number rendered here comes from a
/// real data source (the [AnalysisTimeline] loaded on the
/// [reviewControllerProvider]). There are no "fake" statistics — the
/// summary is pure derivation.
///
/// Layout:
///   ┌─ Result / opening / mode header
///   ├─ Accuracy pair (You / Opponent)
///   ├─ Counts strip (Best / Excellent / Mistake / Blunder / …)
///   ├─ Highlights (key turning point, biggest mistake, best move)
///   ├─ Phase breakdown (opening / middle / endgame with weakness tag)
///   └─ CTA row: Review Moves · Save · Add to Academy · Re-analyze Deep
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/review_summary.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

import '../controllers/review_controller.dart';
import 'review_screen.dart';

/// Optional hook the caller can install to trigger a Deep re-analysis
/// when the summary was generated from a Quick scan. Called when the
/// user taps the "Re-analyze Deep" CTA. When `null`, the CTA is
/// hidden.
typedef OnReanalyzeDeep = Future<void> Function();

/// Optional hook for the "Save Game" CTA. `null` → hidden (most
/// in-app flows already save on analysis completion, so this is only
/// surfaced when the caller explicitly wires it).
typedef OnSaveGame = Future<void> Function();

/// Optional hook for "Add Mistakes to Academy". `null` → hidden.
typedef OnAddMistakesToAcademy = Future<void> Function();

class ReviewSummaryScreen extends ConsumerWidget {
  const ReviewSummaryScreen({
    super.key,
    this.onReanalyzeDeep,
    this.onSaveGame,
    this.onAddMistakesToAcademy,
  });

  final OnReanalyzeDeep? onReanalyzeDeep;
  final OnSaveGame? onSaveGame;
  final OnAddMistakesToAcademy? onAddMistakesToAcademy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewControllerProvider);
    final timeline = state.timeline;

    return Scaffold(
      backgroundColor: ApexColors.darkSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: ApexColors.textSecondary, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'GAME SUMMARY',
          style: ApexTypography.titleMedium.copyWith(
            letterSpacing: 3,
            fontSize: 13,
            color: ApexColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: timeline == null
          ? const Center(
              child: Text(
                'No analysis loaded.',
                style: TextStyle(color: ApexColors.textTertiary),
              ),
            )
          : _SummaryBody(
              summary: const ReviewSummaryService().compute(
                timeline: timeline,
                userIsWhite: state.userIsWhite,
              ),
              mode: state.mode,
              onReanalyzeDeep: onReanalyzeDeep,
              onSaveGame: onSaveGame,
              onAddMistakesToAcademy: onAddMistakesToAcademy,
            ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.summary,
    required this.mode,
    this.onReanalyzeDeep,
    this.onSaveGame,
    this.onAddMistakesToAcademy,
  });

  final ReviewSummary summary;
  final AnalysisMode mode;
  final OnReanalyzeDeep? onReanalyzeDeep;
  final OnSaveGame? onSaveGame;
  final OnAddMistakesToAcademy? onAddMistakesToAcademy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
          children: [
            _ResultHeader(summary: summary, mode: mode),
            const SizedBox(height: 16),
            _AccuracyRow(summary: summary),
            const SizedBox(height: 16),
            _CountsStrip(counts: summary.counts),
            const SizedBox(height: 16),
            _HighlightsBlock(summary: summary),
            const SizedBox(height: 16),
            _PhaseBlock(summary: summary),
            const SizedBox(height: 20),
            _CtaRow(
              isQuick: mode == AnalysisMode.quick,
              onReanalyzeDeep: onReanalyzeDeep,
              onSaveGame: onSaveGame,
              onAddMistakesToAcademy: onAddMistakesToAcademy,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result / opening header ────────────────────────────────────────

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.summary, required this.mode});

  final ReviewSummary summary;
  final AnalysisMode mode;

  @override
  Widget build(BuildContext context) {
    final resultLabel = _resultLabel(summary.result, summary.userIsWhite);
    final modeLabel = mode == AnalysisMode.quick ? 'QUICK' : 'DEEP';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  resultLabel,
                  style: ApexTypography.headlineMedium.copyWith(
                    fontSize: 22,
                    color: ApexColors.textPrimary,
                  ),
                ),
              ),
              _ModePill(label: modeLabel),
            ],
          ),
          if (summary.openingLabel != null) ...[
            const SizedBox(height: 6),
            Text(
              summary.openingLabel!,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.electricBlue.withAlpha(180),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${summary.totalPlies} plies analyzed',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static String _resultLabel(String? result, bool? userIsWhite) {
    if (result == null || result.isEmpty || result == '*') {
      return 'Game unfinished';
    }
    if (userIsWhite == null) {
      switch (result) {
        case '1-0':
          return 'White won';
        case '0-1':
          return 'Black won';
        case '1/2-1/2':
          return 'Draw';
        default:
          return result;
      }
    }
    final userWon =
        (userIsWhite && result == '1-0') || (!userIsWhite && result == '0-1');
    final userLost =
        (userIsWhite && result == '0-1') || (!userIsWhite && result == '1-0');
    if (result == '1/2-1/2') return 'Draw';
    if (userWon) return 'You won';
    if (userLost) return 'You lost';
    return result;
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isQuick = label == 'QUICK';
    final color = isQuick ? ApexColors.inaccuracy : ApexColors.electricBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(120), width: 0.6),
      ),
      child: Text(
        label,
        style: ApexTypography.labelLarge.copyWith(
          color: color.withAlpha(230),
          fontSize: 10,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

// ── Accuracy row ───────────────────────────────────────────────────

class _AccuracyRow extends StatelessWidget {
  const _AccuracyRow({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AccuracyCard(
            label: 'YOU',
            accuracy: summary.userAccuracyPct,
            acpl: summary.userAverageCpLoss,
            colorKnown: summary.userIsWhite != null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AccuracyCard(
            label: 'OPPONENT',
            accuracy: summary.opponentAccuracyPct,
            acpl: summary.opponentAverageCpLoss,
            colorKnown: summary.userIsWhite != null,
          ),
        ),
      ],
    );
  }
}

class _AccuracyCard extends StatelessWidget {
  const _AccuracyCard({
    required this.label,
    required this.accuracy,
    required this.acpl,
    required this.colorKnown,
  });

  final String label;
  final double accuracy;
  final double acpl;
  final bool colorKnown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ApexTypography.labelLarge.copyWith(
              fontSize: 10,
              letterSpacing: 1.6,
              color: ApexColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            colorKnown ? '${accuracy.toStringAsFixed(1)}%' : '—',
            style: ApexTypography.headlineMedium.copyWith(
              fontSize: 26,
              color: ApexColors.textPrimary,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'ACPL ${acpl.toStringAsFixed(1)}',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textSecondary,
              fontSize: 11,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Counts strip ───────────────────────────────────────────────────

class _CountsStrip extends StatelessWidget {
  const _CountsStrip({required this.counts});

  final ReviewCounts counts;

  @override
  Widget build(BuildContext context) {
    final rows = <(MoveQuality, int)>[
      (MoveQuality.brilliant, counts.brilliant),
      (MoveQuality.great, counts.great),
      (MoveQuality.best, counts.best),
      (MoveQuality.excellent, counts.excellent),
      (MoveQuality.good, counts.good),
      (MoveQuality.book, counts.book),
      (MoveQuality.inaccuracy, counts.inaccuracy),
      (MoveQuality.mistake, counts.mistake),
      (MoveQuality.missedWin, counts.missedWin),
      (MoveQuality.blunder, counts.blunder),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COUNTS',
            style: ApexTypography.labelLarge.copyWith(
              fontSize: 10,
              letterSpacing: 1.6,
              color: ApexColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: rows
                .where((e) => e.$2 > 0)
                .map((e) => _CountChip(tier: e.$1, count: e.$2))
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.tier, required this.count});

  final MoveQuality tier;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: tier.color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tier.color.withAlpha(110), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(tier.svgAssetPath, width: 14, height: 14),
          const SizedBox(width: 6),
          Text(
            '${tier.label} · $count',
            style: ApexTypography.bodyMedium.copyWith(
              color: tier.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Highlights ─────────────────────────────────────────────────────

class _HighlightsBlock extends StatelessWidget {
  const _HighlightsBlock({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final h = summary.highlights;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY MOMENTS',
            style: ApexTypography.labelLarge.copyWith(
              fontSize: 10,
              letterSpacing: 1.6,
              color: ApexColors.textTertiary,
            ),
          ),
          const SizedBox(height: 10),
          _HighlightRow(
            label: 'Turning point',
            move: h.keyTurningPoint,
            emptyCopy: 'No decisive swing — balanced game.',
          ),
          const SizedBox(height: 8),
          _HighlightRow(
            label: 'Biggest mistake',
            move: h.biggestMistake,
            emptyCopy: 'No mistakes from your side.',
          ),
          const SizedBox(height: 8),
          _HighlightRow(
            label: 'Best move',
            move: h.bestUserMove,
            emptyCopy: 'No standout best move — steady play.',
          ),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({
    required this.label,
    required this.move,
    required this.emptyCopy,
  });

  final String label;
  final MoveAnalysis? move;
  final String emptyCopy;

  @override
  Widget build(BuildContext context) {
    if (move == null) {
      return Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              emptyCopy,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }
    final m = move!;
    final moveNum = '${(m.ply ~/ 2) + 1}${m.ply.isEven ? '.' : '…'}';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(m.classification.svgAssetPath,
                      width: 14, height: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$moveNum ${m.san} — ${m.classification.label}',
                      style: ApexTypography.bodyMedium.copyWith(
                        color: m.classification.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (m.message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    m.message,
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Phase block ────────────────────────────────────────────────────

class _PhaseBlock extends StatelessWidget {
  const _PhaseBlock({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final weakest = summary.weakestPhase;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ApexColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ApexColors.subtleBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'PHASE PERFORMANCE',
                  style: ApexTypography.labelLarge.copyWith(
                    fontSize: 10,
                    letterSpacing: 1.6,
                    color: ApexColors.textTertiary,
                  ),
                ),
              ),
              if (weakest != null)
                Text(
                  'Weakest: ${_phaseLabel(weakest.phase)}',
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.mistake.withAlpha(220),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (final phase in summary.phases) ...[
            _PhaseRow(breakdown: phase, isWeakest: weakest?.phase == phase.phase),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  static String _phaseLabel(GamePhase p) {
    switch (p) {
      case GamePhase.opening:
        return 'Opening';
      case GamePhase.middlegame:
        return 'Middlegame';
      case GamePhase.endgame:
        return 'Endgame';
    }
  }
}

class _PhaseRow extends StatelessWidget {
  const _PhaseRow({required this.breakdown, required this.isWeakest});

  final PhaseBreakdown breakdown;
  final bool isWeakest;

  @override
  Widget build(BuildContext context) {
    final empty = breakdown.plies == 0;
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            _label(breakdown.phase),
            style: ApexTypography.bodyMedium.copyWith(
              color: isWeakest
                  ? ApexColors.mistake.withAlpha(220)
                  : ApexColors.textPrimary,
              fontSize: 12,
              fontWeight: isWeakest ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            empty
                ? '—'
                : '${breakdown.accuracyPct.toStringAsFixed(0)}% · ACPL '
                    '${breakdown.averageCpLoss.toStringAsFixed(1)} · '
                    '${breakdown.plies} plies',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textSecondary,
              fontSize: 11,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ),
      ],
    );
  }

  static String _label(GamePhase p) {
    switch (p) {
      case GamePhase.opening:
        return 'Opening';
      case GamePhase.middlegame:
        return 'Middlegame';
      case GamePhase.endgame:
        return 'Endgame';
    }
  }
}

// ── CTA row ────────────────────────────────────────────────────────

class _CtaRow extends StatelessWidget {
  const _CtaRow({
    required this.isQuick,
    this.onReanalyzeDeep,
    this.onSaveGame,
    this.onAddMistakesToAcademy,
  });

  final bool isQuick;
  final OnReanalyzeDeep? onReanalyzeDeep;
  final OnSaveGame? onSaveGame;
  final OnAddMistakesToAcademy? onAddMistakesToAcademy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReviewScreen()),
            );
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Review Moves'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ApexColors.electricBlue,
            foregroundColor: ApexColors.darkSurface,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        if (isQuick && onReanalyzeDeep != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => onReanalyzeDeep!.call(),
            icon: const Icon(Icons.radar_rounded),
            label: const Text('Re-analyze Deep'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ApexColors.inaccuracy,
              side: BorderSide(
                color: ApexColors.inaccuracy.withAlpha(180),
                width: 0.7,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
        if (onAddMistakesToAcademy != null) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => onAddMistakesToAcademy!.call(),
            icon: const Icon(Icons.school_rounded),
            label: const Text('Add Mistakes to Academy'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ApexColors.textPrimary,
              side: BorderSide(
                color: ApexColors.subtleBorder,
                width: 0.7,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
        if (onSaveGame != null) ...[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => onSaveGame!.call(),
            icon: const Icon(Icons.bookmark_add_rounded),
            label: const Text('Save Game'),
            style: TextButton.styleFrom(
              foregroundColor: ApexColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
