/// Per-quality neon vapor aura rendered on the target square of the last move.
///
/// Four qualities get a breathing aura; everything else renders nothing.
///
///   * **Brilliant** — ruby → aurora (sapphire/cyan) gradient.
///   * **Best Move** — emerald glow.
///   * **Excellent / Great Move** — electric blue neon.
///   * **Blunder** — crimson warning aura.
///
/// The widget is sized to its parent (caller places it inside a
/// [Positioned] scoped to a single square) so the glow can never bleed
/// across square boundaries. A single [AnimationController] drives a
/// slow sinusoidal breathing envelope (1.8 s period); alpha never
/// reaches full 1.0 so the underlying piece stays readable.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

/// Returns `null` when the quality should not emit an aura (good,
/// inaccuracy, mistake, book). The four highlight qualities map to a
/// `(inner, outer)` color pair that composes the radial gradient.
({Color inner, Color outer})? _palette(MoveQuality quality) {
  switch (quality) {
    case MoveQuality.brilliant:
      // Ruby + cyan — the "wow" combo specified for brilliant moves.
      return (inner: ApexColors.aurora, outer: ApexColors.ruby);
    case MoveQuality.best:
      return (inner: ApexColors.emeraldBright, outer: ApexColors.emerald);
    case MoveQuality.excellent:
      return (
        inner: ApexColors.sapphireBright,
        outer: ApexColors.electricNeon,
      );
    case MoveQuality.blunder:
      return (inner: ApexColors.rubyBright, outer: ApexColors.rubyDeep);
    // Everything else is not flashy enough to warrant a neon halo.
    case MoveQuality.good:
    case MoveQuality.inaccuracy:
    case MoveQuality.mistake:
    case MoveQuality.book:
      return null;
  }
}

class MoveQualityAura extends StatefulWidget {
  const MoveQualityAura({
    super.key,
    required this.quality,
  });

  final MoveQuality quality;

  @override
  State<MoveQualityAura> createState() => _MoveQualityAuraState();
}

class _MoveQualityAuraState extends State<MoveQualityAura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette(widget.quality);
    if (palette == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _breath,
        builder: (context, _) {
          // Ease-in-out sine so the breath doesn't feel mechanical.
          final t = Curves.easeInOutSine.transform(_breath.value);
          final peak = 0.35 + 0.35 * t; // 0.35..0.70
          final mid = 0.18 + 0.18 * t;  // 0.18..0.36
          return DecoratedBox(
            decoration: BoxDecoration(
              // Inset the gradient so the rim hugs the square without
              // any hard edge — feels vapor-like rather than painted.
              gradient: RadialGradient(
                radius: 0.70,
                colors: [
                  palette.inner.withValues(alpha: peak),
                  palette.outer.withValues(alpha: mid),
                  palette.outer.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}
