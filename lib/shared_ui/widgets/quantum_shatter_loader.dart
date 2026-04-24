/// Phase-4 loading animation — "Shattering Emerald" + "Crackling Electric Neon".
///
/// Replaces the prior [RadarScan] across every analysis / fetch waiting state.
/// Rendered from a single [CustomPainter] so it drops into any dialog or
/// overlay without pulling a Lottie/Rive asset. Three independent rhythms
/// compose the effect:
///
///   * **pulse** (1600 ms) — breathes the core and shard opacity.
///   * **orbit** (4200 ms) — rotates the shard ring around the centre.
///   * **crackle** (340 ms) — retriggers a deterministic pseudo-random
///     jitter seed so the electric arcs look alive without allocating
///     new `Random`s per frame.
///
/// Keep the widget sized (default 260 px); the painter draws inside that
/// square and never leaks past it.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

class QuantumShatterLoader extends StatefulWidget {
  const QuantumShatterLoader({
    super.key,
    this.size = 260,
    this.core = ApexColors.emerald,
    this.rim = ApexColors.emeraldBright,
    this.arc = ApexColors.aurora,
    this.shardCount = 10,
    this.arcCount = 5,
  });

  final double size;
  final Color core;
  final Color rim;
  final Color arc;
  final int shardCount;
  final int arcCount;

  @override
  State<QuantumShatterLoader> createState() => _QuantumShatterLoaderState();
}

class _QuantumShatterLoaderState extends State<QuantumShatterLoader>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _orbit;
  late final AnimationController _crackle;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
    // Fast retrigger so the crackle pattern hops frequently — each cycle
    // reseeds the jitter table the painter consults, producing the
    // "alive" electric feel without any real randomness per paint().
    _crackle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    )..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _orbit.dispose();
    _crackle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulse, _orbit, _crackle]),
          builder: (_, __) {
            return CustomPaint(
              painter: _ShatterPainter(
                pulse: Curves.easeInOutSine.transform(_pulse.value),
                orbit: _orbit.value * math.pi * 2,
                crackleSeed: (_crackle.value * 1e6).floor(),
                core: widget.core,
                rim: widget.rim,
                arc: widget.arc,
                shardCount: widget.shardCount,
                arcCount: widget.arcCount,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShatterPainter extends CustomPainter {
  _ShatterPainter({
    required this.pulse,
    required this.orbit,
    required this.crackleSeed,
    required this.core,
    required this.rim,
    required this.arc,
    required this.shardCount,
    required this.arcCount,
  });

  /// 0..1, sinusoidal breathing factor.
  final double pulse;
  /// Orbit angle in radians (monotonically increasing mod 2π).
  final double orbit;
  /// Jitter seed — the painter consults a deterministic LCG to avoid
  /// per-frame allocation of [Random].
  final int crackleSeed;
  final Color core;
  final Color rim;
  final Color arc;
  final int shardCount;
  final int arcCount;

  // Cheap linear-congruential jitter: `next(seed) = seed * 1103515245 + 12345`.
  // Good enough for visual noise, zero allocations.
  static int _next(int s) => (s * 1103515245 + 12345) & 0x7fffffff;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    _paintOuterGlow(canvas, center, r);
    _paintArcs(canvas, center, r);
    _paintShards(canvas, center, r);
    _paintCore(canvas, center, r);
  }

  void _paintOuterGlow(Canvas canvas, Offset c, double r) {
    // Soft radial halo that breathes with [pulse]. No stroke — the alpha
    // envelope is what reads, not a ring.
    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          core.withValues(alpha: 0.18 + 0.14 * pulse),
          core.withValues(alpha: 0.00),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, halo);
  }

  void _paintArcs(Canvas canvas, Offset c, double r) {
    // Electric arcs: jagged polylines from ~0.25r → ~0.95r at [arcCount]
    // angles, offset by the orbit phase. Each arc's joints are jittered
    // using the LCG chain; stable within a frame, different next frame.
    var seed = crackleSeed == 0 ? 1 : crackleSeed;
    final paintArc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = arc.withValues(alpha: 0.65 + 0.25 * pulse);
    final paintArcGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..color = arc.withValues(alpha: 0.22 + 0.18 * pulse);

    for (var i = 0; i < arcCount; i++) {
      final baseAngle = orbit + (i * math.pi * 2 / arcCount);
      final start = c + Offset(
        math.cos(baseAngle) * r * 0.25,
        math.sin(baseAngle) * r * 0.25,
      );

      final path = Path()..moveTo(start.dx, start.dy);
      const segments = 6;
      for (var s = 1; s <= segments; s++) {
        seed = _next(seed);
        final jitter = ((seed % 1000) / 1000 - 0.5) * 0.22; // ±0.11 rad
        final segAngle = baseAngle + jitter;
        final segR = r * (0.25 + (0.70 * s / segments));
        final p = c + Offset(
          math.cos(segAngle) * segR,
          math.sin(segAngle) * segR,
        );
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paintArcGlow); // bloom
      canvas.drawPath(path, paintArc);     // crisp core
    }
  }

  void _paintShards(Canvas canvas, Offset c, double r) {
    // Orbiting emerald shards — small rotated squares at two radii so the
    // ring looks layered. Alpha breathes on the inverse pulse so the
    // outer ring dims while the inner glows, giving a parallax feel.
    for (var i = 0; i < shardCount; i++) {
      final ringInner = i.isEven;
      final angle = orbit * (ringInner ? 1.0 : -0.7) +
          (i * math.pi * 2 / shardCount);
      final shardR = r * (ringInner ? 0.55 : 0.82);
      final shardSize = r * (ringInner ? 0.065 : 0.045);
      final pos = c + Offset(
        math.cos(angle) * shardR,
        math.sin(angle) * shardR,
      );

      final alpha = ringInner
          ? 0.55 + 0.35 * pulse
          : 0.35 + 0.45 * (1 - pulse);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle + orbit * 2);

      // Bloom pass — blurred, bigger, low alpha.
      final bloom = Paint()
        ..color = rim.withValues(alpha: alpha * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: shardSize * 2.2, height: shardSize * 2.2),
        bloom,
      );

      // Crisp emerald shard — rotated square reads as a diamond.
      final shard = Paint()
        ..shader = LinearGradient(
          colors: [rim.withValues(alpha: alpha), core.withValues(alpha: alpha)],
        ).createShader(
          Rect.fromCenter(center: Offset.zero, width: shardSize * 2, height: shardSize * 2),
        );
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: shardSize * 1.6, height: shardSize * 1.6),
        shard,
      );
      canvas.restore();
    }
  }

  void _paintCore(Canvas canvas, Offset c, double r) {
    // Bright pulsing nucleus — layered blur + crisp centre dot.
    final coreR = r * (0.10 + 0.04 * pulse);
    final bloom = Paint()
      ..color = rim.withValues(alpha: 0.45 + 0.35 * pulse)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + 6 * pulse);
    canvas.drawCircle(c, coreR * 1.6, bloom);

    final nucleus = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          rim.withValues(alpha: 0.85),
          core.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: coreR));
    canvas.drawCircle(c, coreR, nucleus);
  }

  @override
  bool shouldRepaint(_ShatterPainter old) =>
      old.pulse != pulse ||
      old.orbit != orbit ||
      old.crackleSeed != crackleSeed ||
      old.core != core ||
      old.rim != rim ||
      old.arc != arc;
}
