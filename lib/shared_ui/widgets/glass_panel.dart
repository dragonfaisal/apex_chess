/// Frosted-glass container used across cards, dialogs, and persistent panels.
///
/// The widget layers:
///   1. A [BackdropFilter] with a Gaussian blur for the "frosted" effect.
///   2. A semi-opaque fill that respects the deep-space palette.
///   3. A gradient border that reads as rim-light from the top-left.
///
/// Use [GlassPanel.dialog] for modal dialogs (ensures an outer [ClipRRect]
/// so the blur is scoped to the dialog bounds and does not bleed across the
/// scrim).
library;

import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 18,
    this.blur = 18,
    this.accentColor,
    this.accentAlpha = 0.35,
    this.fillAlpha = 0.55,
    this.showGlow = false,
    this.glowIntensity = 0.18,
  });

  /// Dialog-tuned preset: fat blur, tighter padding.
  const GlassPanel.dialog({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.margin,
    this.borderRadius = 22,
    this.accentColor,
    this.accentAlpha = 0.4,
  })  : blur = 24,
        fillAlpha = 0.62,
        showGlow = true,
        glowIntensity = 0.22;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;

  /// Optional rim-light accent. Defaults to sapphire.
  final Color? accentColor;

  /// Alpha applied to the accent when building the border gradient.
  final double accentAlpha;

  /// Alpha applied to the cosmicDust fill behind the blur.
  final double fillAlpha;

  /// Whether to render an outer soft glow (use sparingly).
  final bool showGlow;
  final double glowIntensity;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? ApexColors.sapphire;
    final borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        accent.withValues(alpha: accentAlpha),
        ApexColors.stardustLine.withValues(alpha: 0.12),
      ],
    );

    Widget panel = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: ApexColors.cosmicDust.withValues(alpha: fillAlpha),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );

    // Gradient border overlay — draw a thin painted stroke on top so the
    // rim-light sits above the BackdropFilter.
    panel = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: GradientBoxBorder(gradient: borderGradient, width: 0.8),
      ),
      child: panel,
    );

    if (showGlow) {
      panel = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: glowIntensity),
              blurRadius: 28,
              spreadRadius: -6,
            ),
          ],
        ),
        child: panel,
      );
    }

    if (margin != null) {
      panel = Padding(padding: margin!, child: panel);
    }
    return panel;
  }
}

/// Lightweight gradient border painter — Flutter does not ship a
/// first-party [BoxBorder] that supports gradients, so we roll a thin one
/// that only covers our rounded-rectangle use case.
class GradientBoxBorder extends BoxBorder {
  const GradientBoxBorder({required this.gradient, this.width = 1.0});

  final Gradient gradient;
  final double width;

  @override
  BorderSide get bottom => BorderSide.none;
  @override
  BorderSide get top => BorderSide.none;

  @override
  bool get isUniform => true;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  ShapeBorder scale(double t) =>
      GradientBoxBorder(gradient: gradient, width: width * t);

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint = Paint()
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);

    if (borderRadius != null && shape == BoxShape.rectangle) {
      final rrect = borderRadius.toRRect(rect).deflate(width / 2);
      canvas.drawRRect(rrect, paint);
    } else if (shape == BoxShape.circle) {
      canvas.drawCircle(rect.center, rect.shortestSide / 2 - width / 2, paint);
    } else {
      canvas.drawRect(rect.deflate(width / 2), paint);
    }
  }
}
