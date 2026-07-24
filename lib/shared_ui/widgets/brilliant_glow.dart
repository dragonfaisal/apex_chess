/// Animated celebration halo that fires when a Brilliant (!!) is detected.
///
/// Wrap any widget in [BrilliantGlow] and flip [visible] when the
/// classifier emits a brilliant move. The glow pulses once through a
/// sapphire → aurora gradient, then fades.
///
/// Keep usage sparing — this is a hero moment, not a standing decoration.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

class BrilliantGlow extends StatefulWidget {
  const BrilliantGlow({
    super.key,
    required this.child,
    required this.visible,
    this.borderRadius = 18,
    this.reduceMotion = false,
  });

  final Widget child;

  /// A false-to-true transition triggers one bounded emphasis. Initial mount
  /// does not replay a historic Brilliant move.
  final bool visible;

  final double borderRadius;
  final bool reduceMotion;

  @override
  State<BrilliantGlow> createState() => _BrilliantGlowState();
}

class _BrilliantGlowState extends State<BrilliantGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didUpdateWidget(covariant BrilliantGlow old) {
    super.didUpdateWidget(old);
    if (!widget.visible || widget.reduceMotion) {
      _controller
        ..stop()
        ..reset();
    } else if (widget.visible && !old.visible && !widget.reduceMotion) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Envelope: fast rise → slow decay.
        final env = t < 0.25
            ? t / 0.25
            : Curves.easeOutCubic.transform(1 - (t - 0.25) / 0.75);
        final spread = 2 + 24 * env;
        final blur = 8 + 40 * env;

        return Stack(
          children: [
            // Outer halo — pulses sapphire → aurora.
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius + 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.lerp(
                          ApexColors.sapphire,
                          ApexColors.aurora,
                          t,
                        )!.withValues(alpha: 0.55 * env),
                        blurRadius: blur,
                        spreadRadius: spread,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Inner rim-light border that gets brighter at peak.
            if (env > 0.05)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      border: Border.all(
                        color: ApexColors.aurora.withValues(alpha: 0.6 * env),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}
