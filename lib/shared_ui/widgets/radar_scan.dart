/// Rotating radar-scan animation shown behind analysis-progress dialogs.
///
/// Pure-Flutter [CustomPainter] — no third-party dependencies. Designed to
/// drop into a `Stack` as a full-bleed background while the LocalGameAnalyzer
/// crunches through plies. The sweep beam, concentric range rings, and
/// faint crosshair are painted from a single `AnimationController` that
/// ticks independently of the host dialog's state so progress updates
/// don't jitter the beam.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

class RadarScan extends StatefulWidget {
  const RadarScan({
    super.key,
    this.size = 260,
    this.color = ApexColors.sapphireBright,
    this.rotationDuration = const Duration(milliseconds: 2800),
    this.ringCount = 4,
  });

  final double size;
  final Color color;
  final Duration rotationDuration;
  final int ringCount;

  @override
  State<RadarScan> createState() => _RadarScanState();
}

class _RadarScanState extends State<RadarScan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return CustomPaint(
              painter: _RadarPainter(
                sweep: _controller.value * math.pi * 2,
                color: widget.color,
                ringCount: widget.ringCount,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.sweep,
    required this.color,
    required this.ringCount,
  });

  final double sweep;
  final Color color;
  final int ringCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    // Faint base disc so the ring ladder reads against the space-canvas
    // background even when the sweep isn't over that arc.
    final discPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.06),
          color.withValues(alpha: 0.00),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, discPaint);

    // Concentric range rings — hairline strokes, increasing radius.
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = color.withValues(alpha: 0.18);
    for (var i = 1; i <= ringCount; i++) {
      canvas.drawCircle(center, radius * (i / ringCount), ringPaint);
    }

    // Crosshair — horizontal + vertical diameter at 10% opacity.
    final crosshairPaint = Paint()
      ..strokeWidth = 0.7
      ..color = color.withValues(alpha: 0.12);
    canvas.drawLine(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        crosshairPaint);
    canvas.drawLine(
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius),
        crosshairPaint);

    // Sweep beam: a ~40° wedge whose alpha fades from leading edge
    // (opaque) to trailing edge (transparent). A SweepGradient centred
    // on the beam angle reproduces the classic radar scan look without
    // emitting an actual path stroke per frame.
    const beamWidth = math.pi / 4; // 45° wedge
    final beamRect = Rect.fromCircle(center: center, radius: radius);
    final beamPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2 + sweep - beamWidth,
        endAngle: -math.pi / 2 + sweep,
        tileMode: TileMode.clamp,
        colors: [
          color.withValues(alpha: 0.00),
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.55),
        ],
        stops: const [0.0, 0.85, 1.0],
      ).createShader(beamRect);
    canvas.drawCircle(center, radius, beamPaint);

    // Bright leading edge — a thin filled triangle giving the beam its
    // recognisable "blip" silhouette.
    final leadingAngle = -math.pi / 2 + sweep;
    final leadPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
        center.dx + radius * math.cos(leadingAngle),
        center.dy + radius * math.sin(leadingAngle),
      );
    final leadPaint = Paint()
      ..strokeWidth = 1.4
      ..color = color.withValues(alpha: 0.85);
    canvas.drawPath(leadPath, leadPaint);

    // Central hub — tiny solid dot.
    canvas.drawCircle(
      center,
      2.4,
      Paint()..color = color.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.sweep != sweep ||
      oldDelegate.color != color ||
      oldDelegate.ringCount != ringCount;
}
