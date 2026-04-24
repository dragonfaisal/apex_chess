/// Apex Opponent Forensics — scaffold screen.
///
/// UI + dummy service only. The suspicion dial shape, copy, and
/// gradient spectrum are locked so that future versions swapping in
/// real accuracy math just replace the numbers.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';
import 'package:apex_chess/shared_ui/widgets/radar_scan.dart';

import '../../domain/profile_scan_result.dart';
import '../controllers/profile_scanner_controller.dart';

class ProfileScannerScreen extends ConsumerStatefulWidget {
  const ProfileScannerScreen({super.key});

  @override
  ConsumerState<ProfileScannerScreen> createState() =>
      _ProfileScannerScreenState();
}

class _ProfileScannerScreenState
    extends ConsumerState<ProfileScannerScreen> {
  final _controller = TextEditingController();
  String _source = 'chess.com';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    FocusScope.of(context).unfocus();
    await ref.read(profileScannerControllerProvider.notifier).scan(
          username: name,
          source: _source,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileScannerControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ApexGradients.spaceCanvas),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(onBack: () => Navigator.of(context).pop()),
                const SizedBox(height: 16),
                _InputCard(
                  controller: _controller,
                  source: _source,
                  onSourceChanged: (s) => setState(() => _source = s),
                  onSubmit: _scan,
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: 20),
                if (state.isLoading)
                  const _LoadingCard()
                else if (state.error != null)
                  _ErrorCard(message: state.error!)
                else if (state.result != null)
                  _ResultSection(result: state.result!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: ApexColors.textPrimary, size: 18),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ApexCopy.scannerTitle,
                  style: ApexTypography.headlineMedium
                      .copyWith(letterSpacing: 3)),
              const SizedBox(height: 2),
              Text(
                ApexCopy.scannerSubtitle,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Input card ────────────────────────────────────────────────────────

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.source,
    required this.onSourceChanged,
    required this.onSubmit,
    required this.isLoading,
  });

  final TextEditingController controller;
  final String source;
  final ValueChanged<String> onSourceChanged;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accentColor: ApexColors.sapphireBright,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SourceToggle(
                label: 'Chess.com',
                selected: source == 'chess.com',
                onTap: () => onSourceChanged('chess.com'),
              ),
              const SizedBox(width: 8),
              _SourceToggle(
                label: 'Lichess',
                selected: source == 'lichess',
                onTap: () => onSourceChanged('lichess'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            enabled: !isLoading,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSubmit(),
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              hintText: 'Opponent username',
              hintStyle: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
              ),
              prefixIcon: const Icon(Icons.person_search_rounded,
                  color: ApexColors.sapphireBright, size: 18),
              filled: true,
              fillColor: ApexColors.nebula.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ApexColors.stardustLine.withValues(alpha: 0.4),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: ApexColors.sapphireBright,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ApexColors.stardustLine.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: ApexColors.sapphireDeep,
                foregroundColor: ApexColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLoading
                    ? ApexCopy.scannerRunning
                    : ApexCopy.scannerCta,
                style: ApexTypography.labelLarge.copyWith(
                  color: ApexColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceToggle extends StatelessWidget {
  const _SourceToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? ApexColors.sapphireDeep.withValues(alpha: 0.35)
                : ApexColors.nebula.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? ApexColors.sapphireBright.withValues(alpha: 0.7)
                  : ApexColors.stardustLine.withValues(alpha: 0.3),
              width: selected ? 1.0 : 0.6,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: ApexTypography.bodyMedium.copyWith(
                color: selected
                    ? ApexColors.sapphireBright
                    : ApexColors.textTertiary,
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accentColor: ApexColors.aurora,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const SizedBox(
            height: 160,
            child: Center(child: RadarScan(size: 160)),
          ),
          const SizedBox(height: 12),
          Text(
            ApexCopy.scannerLoading,
            style: ApexTypography.titleMedium
                .copyWith(letterSpacing: 2, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Error ────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      accentColor: ApexColors.ruby,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: ApexColors.ruby, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: ApexTypography.bodyMedium
                  .copyWith(color: ApexColors.ruby),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result ───────────────────────────────────────────────────────────

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.result});
  final ProfileScanResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SuspicionCard(result: result),
        const SizedBox(height: 14),
        _SampleList(games: result.games),
      ],
    );
  }
}

class _SuspicionCard extends StatelessWidget {
  const _SuspicionCard({required this.result});
  final ProfileScanResult result;

  @override
  Widget build(BuildContext context) {
    final accent = _suspicionColor(result.suspicion);
    return GlassPanel(
      accentColor: accent,
      accentAlpha: 0.55,
      showGlow: true,
      glowIntensity: 0.22,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: Center(
              child: _SuspicionDial(
                accuracy: result.averageAccuracy,
                accent: accent,
                label: result.suspicion.label,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${result.username}  ·  ${result.source}  ·  ${result.sampleSize} games',
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result.verdict,
            textAlign: TextAlign.center,
            style: ApexTypography.bodyLarge
                .copyWith(color: ApexColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Color _suspicionColor(SuspicionLevel s) => switch (s) {
        SuspicionLevel.clean => ApexColors.great,
        SuspicionLevel.moderate => ApexColors.inaccuracy,
        SuspicionLevel.suspicious => ApexColors.ruby,
      };
}

class _SuspicionDial extends StatelessWidget {
  const _SuspicionDial({
    required this.accuracy,
    required this.accent,
    required this.label,
  });

  final double accuracy;
  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SuspicionDialPainter(
        accuracy: accuracy,
        accent: accent,
      ),
      child: SizedBox(
        width: 180,
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                accuracy.toStringAsFixed(1),
                style: ApexTypography.displayLarge.copyWith(
                  color: accent,
                  fontSize: 44,
                  letterSpacing: -1,
                ),
              ),
              Text(
                '% ACCURACY',
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textTertiary,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                style: ApexTypography.labelLarge.copyWith(
                  color: accent,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuspicionDialPainter extends CustomPainter {
  _SuspicionDialPainter({required this.accuracy, required this.accent});

  final double accuracy;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 8;

    // Background ring.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = ApexColors.stardustLine.withValues(alpha: 0.35),
    );

    // Progress arc (0–100 mapped to full rotation starting from 12 o'clock).
    final sweep = (accuracy / 100.0) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [accent.withValues(alpha: 0.4), accent],
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweep,
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        ),
    );
  }

  @override
  bool shouldRepaint(_SuspicionDialPainter old) =>
      old.accuracy != accuracy || old.accent != accent;
}

class _SampleList extends StatelessWidget {
  const _SampleList({required this.games});
  final List<GameAccuracy> games;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SAMPLE GAMES',
            style: ApexTypography.labelLarge.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          for (final g in games)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${g.white}  vs  ${g.black}',
                      style: ApexTypography.bodyMedium.copyWith(
                        color: ApexColors.textPrimary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    g.result,
                    style: ApexTypography.bodyMedium.copyWith(
                      color: ApexColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${g.accuracy.toStringAsFixed(1)}%',
                    style: ApexTypography.monoEval.copyWith(
                      color: ApexColors.sapphireBright,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
