/// Per-quality neon vapor aura rendered on the target square of the last move.
///
/// Trusted highlight qualities get one restrained static aura; everything
/// else renders nothing. Review motion is reserved for bounded state changes.
///
///   * **Brilliant** — ruby → aurora (sapphire/cyan) gradient.
///   * **Best Move** — emerald glow.
///   * **Excellent / Great Move** — electric blue neon.
///   * **Only Move** — restrained electric blue, distinct from Great.
///   * **Blunder** — crimson warning aura.
///
/// The widget is sized to its parent (caller places it inside a
/// [Positioned] scoped to a single square) so the glow can never bleed
/// across square boundaries. It is deliberately static so the underlying
/// piece stays readable without a permanent repeating ticker.
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
    case MoveQuality.great:
      // Great remains a high-trust tactical find.
      return (inner: ApexColors.aurora, outer: ApexColors.ruby);
    case MoveQuality.onlyMove:
      // Only Move is important but not a celebratory Brilliant/Great badge.
      return (inner: ApexColors.sapphireBright, outer: ApexColors.electricNeon);
    case MoveQuality.best:
      return (inner: ApexColors.emeraldBright, outer: ApexColors.emerald);
    case MoveQuality.excellent:
      return (inner: ApexColors.sapphireBright, outer: ApexColors.electricNeon);
    case MoveQuality.blunder:
      return (inner: ApexColors.rubyBright, outer: ApexColors.rubyDeep);
    case MoveQuality.missedWin:
      // Same warning aura as Blunder — Missed Win means the eval
      // dropped from winning to equal, which deserves a visible
      // ruby halo so the user spots it on the board.
      return (inner: ApexColors.rubyBright, outer: ApexColors.rubyDeep);
    // Everything else is not flashy enough to warrant a neon halo.
    case MoveQuality.good:
    case MoveQuality.inaccuracy:
    case MoveQuality.mistake:
    case MoveQuality.book:
    case MoveQuality.forced:
    case MoveQuality.unavailable:
      return null;
  }
}

class MoveQualityAura extends StatelessWidget {
  const MoveQualityAura({super.key, required this.quality});

  final MoveQuality quality;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(quality);
    if (palette == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 0.70,
            colors: [
              palette.inner.withValues(alpha: 0.42),
              palette.outer.withValues(alpha: 0.20),
              palette.outer.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
      ),
    );
  }
}
