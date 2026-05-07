/// Shared player-side marker used by identity surfaces.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

enum ApexSideMarkerSide {
  white('White'),
  black('Black'),
  unknown('Side');

  const ApexSideMarkerSide(this.label);
  final String label;
}

@immutable
class ApexSideMarkerDisplay {
  const ApexSideMarkerDisplay({
    required this.side,
    required this.label,
    required this.semanticLabel,
    required this.keySuffix,
  });

  factory ApexSideMarkerDisplay.fromSide(ApexSideMarkerSide side) {
    return switch (side) {
      ApexSideMarkerSide.white => const ApexSideMarkerDisplay(
        side: ApexSideMarkerSide.white,
        label: 'White',
        semanticLabel: 'White side',
        keySuffix: 'white',
      ),
      ApexSideMarkerSide.black => const ApexSideMarkerDisplay(
        side: ApexSideMarkerSide.black,
        label: 'Black',
        semanticLabel: 'Black side',
        keySuffix: 'black',
      ),
      ApexSideMarkerSide.unknown => const ApexSideMarkerDisplay(
        side: ApexSideMarkerSide.unknown,
        label: 'Side',
        semanticLabel: 'Unknown side',
        keySuffix: 'unknown',
      ),
    };
  }

  final ApexSideMarkerSide side;
  final String label;
  final String semanticLabel;
  final String keySuffix;

  bool get isKnown => side != ApexSideMarkerSide.unknown;
}

class ApexSideMarker extends StatelessWidget {
  const ApexSideMarker({
    super.key,
    required this.side,
    this.size = 16,
    this.showLabel = false,
    this.keyPrefix,
  });

  final ApexSideMarkerSide side;
  final double size;
  final bool showLabel;
  final String? keyPrefix;

  @override
  Widget build(BuildContext context) {
    final display = ApexSideMarkerDisplay.fromSide(side);
    final marker = Semantics(
      label: display.semanticLabel,
      child: Container(
        key: keyPrefix == null
            ? ValueKey('apex-${display.keySuffix}-side-marker')
            : ValueKey('$keyPrefix-${display.keySuffix}-side-marker'),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _gradient(display.side),
          border: Border.all(color: _stroke(display.side), width: 0.85),
          boxShadow: [
            BoxShadow(
              color: _glow(display.side),
              blurRadius: size * 0.62,
              spreadRadius: -size * 0.24,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: size * 0.34,
            height: size * 0.34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _core(display.side),
            ),
          ),
        ),
      ),
    );

    if (!showLabel) return marker;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        marker,
        const SizedBox(width: 5),
        Text(
          display.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ApexTypography.bodyMedium.copyWith(
            color: ApexColors.textTertiary,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }

  static Gradient _gradient(ApexSideMarkerSide side) {
    return switch (side) {
      ApexSideMarkerSide.white => const RadialGradient(
        center: Alignment(-0.36, -0.42),
        radius: 0.92,
        colors: [Colors.white, Color(0xFFE5EEFF), Color(0xFFBFD4FF)],
        stops: [0, 0.64, 1],
      ),
      ApexSideMarkerSide.black => const RadialGradient(
        center: Alignment(-0.34, -0.44),
        radius: 0.96,
        colors: [Color(0xFF32405F), Color(0xFF111A2E), Color(0xFF050814)],
        stops: [0, 0.58, 1],
      ),
      ApexSideMarkerSide.unknown => RadialGradient(
        center: const Alignment(-0.34, -0.44),
        radius: 0.96,
        colors: [
          ApexColors.textTertiary.withValues(alpha: 0.72),
          ApexColors.nebula,
          ApexColors.deepSpace,
        ],
        stops: const [0, 0.62, 1],
      ),
    };
  }

  static Color _stroke(ApexSideMarkerSide side) {
    return switch (side) {
      ApexSideMarkerSide.white => Colors.white.withValues(alpha: 0.84),
      ApexSideMarkerSide.black => ApexColors.sapphireBright.withValues(
        alpha: 0.44,
      ),
      ApexSideMarkerSide.unknown => ApexColors.stardustLine.withValues(
        alpha: 0.74,
      ),
    };
  }

  static Color _glow(ApexSideMarkerSide side) {
    return switch (side) {
      ApexSideMarkerSide.white => Colors.white.withValues(alpha: 0.30),
      ApexSideMarkerSide.black => ApexColors.sapphireBright.withValues(
        alpha: 0.22,
      ),
      ApexSideMarkerSide.unknown => ApexColors.textTertiary.withValues(
        alpha: 0.16,
      ),
    };
  }

  static Color _core(ApexSideMarkerSide side) {
    return switch (side) {
      ApexSideMarkerSide.white => Colors.white.withValues(alpha: 0.88),
      ApexSideMarkerSide.black => ApexColors.sapphireBright.withValues(
        alpha: 0.44,
      ),
      ApexSideMarkerSide.unknown => ApexColors.textSecondary.withValues(
        alpha: 0.42,
      ),
    };
  }
}
