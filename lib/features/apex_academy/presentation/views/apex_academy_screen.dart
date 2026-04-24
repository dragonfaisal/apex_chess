/// Apex Academy — spaced-repetition drill UI.
///
/// Pulls the day's due [MistakeDrill]s from the Vault and walks the
/// user through a multiple-choice "find the best move" session.
/// Streak + XP ring + daily goal gauge live in the header. Aesthetic
/// goal: Duolingo-grade rhythm with the Royal Deep Space palette.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/features/apex_academy/data/academy_stats_repository.dart';
import 'package:apex_chess/features/mistake_vault/domain/mistake_drill.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_chess_board.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

import '../controllers/academy_controller.dart';

class ApexAcademyScreen extends ConsumerWidget {
  const ApexAcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(academyControllerProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: Column(
            children: [
              _AppBar(),
              _StatsHeader(stats: state.stats),
              Expanded(
                child: state.current == null
                    ? _DoneState(stats: state.stats)
                    : _DrillView(state: state),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: ApexColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              ApexCopy.academyTitle,
              textAlign: TextAlign.center,
              style: ApexTypography.titleMedium.copyWith(
                color: ApexColors.textPrimary,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.stats});
  final AcademyStats stats;

  @override
  Widget build(BuildContext context) {
    final progress =
        (stats.drillsToday / AcademyStatsRepository.dailyDrillGoal)
            .clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
      child: GlassPanel(
        accentColor: ApexColors.emerald,
        accentAlpha: 0.35,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            _StreakPill(streak: stats.streakDays),
            const SizedBox(width: 14),
            Expanded(child: _DailyGoal(progress: progress, stats: stats)),
            const SizedBox(width: 14),
            _XpBadge(xp: stats.totalXp),
          ],
        ),
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final active = streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active
              ? ApexColors.ruby.withValues(alpha: 0.6)
              : ApexColors.subtleBorder,
          width: 1.2,
        ),
        color: active
            ? ApexColors.ruby.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active
                ? Icons.local_fire_department_rounded
                : Icons.local_fire_department_outlined,
            size: 18,
            color: active
                ? ApexColors.ruby
                : ApexColors.textTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: ApexTypography.titleMedium.copyWith(
              color: ApexColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoal extends StatelessWidget {
  const _DailyGoal({required this.progress, required this.stats});
  final double progress;
  final AcademyStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'DAILY QUEST',
          style: ApexTypography.bodyMedium.copyWith(
            color: ApexColors.textTertiary,
            fontSize: 10,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: ApexColors.cosmicDust,
                  valueColor: const AlwaysStoppedAnimation(
                      ApexColors.emeraldBright),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${stats.drillsToday}/${AcademyStatsRepository.dailyDrillGoal}',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textPrimary,
                fontSize: 11,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            ApexColors.sapphireDeep.withValues(alpha: 0.35),
            ApexColors.emeraldDeep.withValues(alpha: 0.35),
          ],
        ),
        border: Border.all(
            color: ApexColors.emerald.withValues(alpha: 0.45), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded,
              size: 18, color: ApexColors.emeraldBright),
          const SizedBox(width: 4),
          Text(
            '$xp XP',
            style: ApexTypography.titleMedium.copyWith(
              color: ApexColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneState extends StatelessWidget {
  const _DoneState({required this.stats});
  final AcademyStats stats;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_rounded,
                size: 72, color: ApexColors.emerald.withValues(alpha: 0.75)),
            const SizedBox(height: 16),
            Text(
              stats.drillsToday == 0
                  ? ApexCopy.academyEmpty
                  : ApexCopy.academyDone,
              textAlign: TextAlign.center,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textSecondary,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrillView extends ConsumerWidget {
  const _DrillView({required this.state});
  final AcademyState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drill = state.current!.drill;
    final options = state.current!.options;
    final correctIndex = state.current!.correctIndex;
    final answered = state.lastResultCorrect != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DrillHeader(drill: drill, remaining: state.remainingInQueue),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, box) {
              // Cap the board so it never eats the screen vertically on tall
              // phones; on wider screens we let AspectRatio take over.
              final maxBoard = math.min(box.maxWidth, 420.0);
              return Center(
                child: SizedBox(
                  width: maxBoard,
                  child: ApexChessBoard(
                    fen: drill.fenBefore,
                    flipped: !drill.isWhiteToMove,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _OptionsGrid(
            options: options,
            correctIndex: correctIndex,
            answered: answered,
            selectedUci: state.lastAnswerUci,
            onSelect: (uci) async {
              if (answered) return;
              await ref.read(academyControllerProvider.notifier).submit(uci);
            },
          ),
          if (answered) ...[
            const SizedBox(height: 14),
            _ResultPanel(
              correct: state.lastResultCorrect!,
              bestSan: options[correctIndex].san,
              onNext: () =>
                  ref.read(academyControllerProvider.notifier).next(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DrillHeader extends StatelessWidget {
  const _DrillHeader({required this.drill, required this.remaining});
  final MistakeDrill drill;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              drill.isWhiteToMove
                  ? 'WHITE TO MOVE — FIND THE BEST MOVE'
                  : 'BLACK TO MOVE — FIND THE BEST MOVE',
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textPrimary,
                fontSize: 12,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (drill.openingName != null)
              Text(
                '${drill.ecoCode ?? ''} ${drill.openingName ?? ''}'.trim(),
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ApexColors.sapphire.withValues(alpha: 0.15),
            border: Border.all(
                color: ApexColors.sapphire.withValues(alpha: 0.45),
                width: 0.9),
          ),
          child: Text(
            '$remaining left',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.sapphireBright,
              fontSize: 10.5,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionsGrid extends StatelessWidget {
  const _OptionsGrid({
    required this.options,
    required this.correctIndex,
    required this.answered,
    required this.selectedUci,
    required this.onSelect,
  });

  final List<DrillOption> options;
  final int correctIndex;
  final bool answered;
  final String? selectedUci;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3.2,
      children: List.generate(options.length, (i) {
        final opt = options[i];
        final isCorrect = i == correctIndex;
        final isPicked = opt.uci == selectedUci;
        Color? borderColor;
        Color? glow;
        if (answered) {
          if (isCorrect) {
            borderColor = ApexColors.emerald;
            glow = ApexColors.emerald;
          } else if (isPicked) {
            borderColor = ApexColors.ruby;
            glow = ApexColors.ruby;
          } else {
            borderColor = ApexColors.subtleBorder;
          }
        } else {
          borderColor = ApexColors.subtleBorder;
        }
        return _OptionButton(
          san: opt.san,
          borderColor: borderColor,
          glow: glow,
          enabled: !answered,
          onTap: () => onSelect(opt.uci),
        );
      }),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.san,
    required this.borderColor,
    required this.glow,
    required this.enabled,
    required this.onTap,
  });

  final String san;
  final Color borderColor;
  final Color? glow;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final g = glow;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: ApexColors.cosmicDust.withValues(alpha: 0.6),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: g == null
                ? null
                : [
                    BoxShadow(
                      color: g.withValues(alpha: 0.45),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: Text(
            san,
            style: ApexTypography.headlineMedium.copyWith(
              color: ApexColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.correct,
    required this.bestSan,
    required this.onNext,
  });

  final bool correct;
  final String bestSan;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final accent = correct ? ApexColors.emerald : ApexColors.ruby;
    return GlassPanel(
      accentColor: accent,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Row(
        children: [
          Icon(
              correct
                  ? Icons.check_circle_outline_rounded
                  : Icons.highlight_off_rounded,
              color: accent,
              size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct ? ApexCopy.academyCorrect : ApexCopy.academyWrongHeader,
                  style: ApexTypography.titleMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (!correct)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Best was $bestSan.',
                      style: ApexTypography.bodyMedium.copyWith(
                        color: ApexColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: accent,
              side: BorderSide(
                  color: accent.withValues(alpha: 0.55), width: 1),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
            ),
            onPressed: onNext,
            child: const Text('NEXT'),
          ),
        ],
      ),
    );
  }
}
