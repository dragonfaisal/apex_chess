library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

class ApexPulseLoader extends StatefulWidget {
  const ApexPulseLoader({super.key, this.size = 84, this.color});

  final double size;
  final Color? color;

  @override
  State<ApexPulseLoader> createState() => _ApexPulseLoaderState();
}

class _ApexPulseLoaderState extends State<ApexPulseLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.86, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _opacity = Tween<double>(begin: 0.55, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? ApexColors.aurora;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.95),
                    color.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.48, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: widget.size * 0.45,
                    spreadRadius: -widget.size * 0.18,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: widget.size * 0.28,
                  height: widget.size * 0.28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ApexColors.textPrimary.withValues(alpha: 0.86),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ApexLoadingScaffold extends StatefulWidget {
  const ApexLoadingScaffold({
    super.key,
    required this.title,
    this.messages = const <String>[
      'Fetching recent games...',
      'Reading PGN...',
      'Checking opening...',
      'Building review...',
      'Analyzing tactics...',
      'Saving review...',
    ],
    this.progressMessage,
    this.progress,
    this.compact = false,
  });

  final String title;
  final List<String> messages;
  final String? progressMessage;
  final double? progress;
  final bool compact;

  @override
  State<ApexLoadingScaffold> createState() => _ApexLoadingScaffoldState();
}

class _ApexLoadingScaffoldState extends State<ApexLoadingScaffold> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.messages.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % widget.messages.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.messages.isEmpty ? '' : widget.messages[_index];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ApexSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ApexPulseLoader(size: widget.compact ? 64 : 92),
            const SizedBox(height: ApexSpacing.lg),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: ApexTypography.titleMedium.copyWith(
                color: ApexColors.textPrimary,
                fontSize: widget.compact ? 14 : 16,
              ),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: ApexSpacing.sm),
              AnimatedSwitcher(
                duration: ApexMotion.normal,
                child: Text(
                  message,
                  key: ValueKey(message),
                  textAlign: TextAlign.center,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            if (widget.progress != null) ...[
              const SizedBox(height: ApexSpacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: widget.progress!.clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: ApexColors.nebula,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    ApexColors.sapphireBright,
                  ),
                ),
              ),
            ],
            if (widget.progressMessage != null) ...[
              const SizedBox(height: ApexSpacing.sm),
              Text(
                widget.progressMessage!,
                textAlign: TextAlign.center,
                style: ApexTypography.bodyMedium.copyWith(
                  color: ApexColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ApexSkeletonCard extends StatefulWidget {
  const ApexSkeletonCard({
    super.key,
    this.height = 92,
    this.margin = const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
  });

  final double height;
  final EdgeInsetsGeometry margin;

  @override
  State<ApexSkeletonCard> createState() => _ApexSkeletonCardState();
}

class _ApexSkeletonCardState extends State<ApexSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          height: widget.height,
          margin: widget.margin,
          padding: const EdgeInsets.all(ApexSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: ApexRadius.cardBorder,
            border: Border.all(color: ApexColors.subtleBorder, width: 0.6),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * t, -0.4),
              end: Alignment(1.0 + 2.0 * t, 0.4),
              colors: [
                ApexColors.nebula.withValues(alpha: 0.50),
                ApexColors.sapphire.withValues(alpha: 0.10),
                ApexColors.nebula.withValues(alpha: 0.50),
              ],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _SkeletonLine(widthFactor: 0.68),
              SizedBox(height: ApexSpacing.md),
              _SkeletonLine(widthFactor: 0.42),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: ApexColors.textTertiary.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class ApexEmptyStateCard extends StatelessWidget {
  const ApexEmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.accent = ApexColors.sapphireBright,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Color accent;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ApexSpacing.xl),
      decoration: BoxDecoration(
        color: ApexColors.nebula.withValues(alpha: 0.52),
        borderRadius: ApexRadius.cardBorder,
        border: Border.all(color: ApexColors.subtleBorder, width: 0.6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: accent.withValues(alpha: 0.88)),
          const SizedBox(height: ApexSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: ApexTypography.titleMedium.copyWith(
              color: ApexColors.textPrimary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: ApexSpacing.sm),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: ApexTypography.bodyMedium.copyWith(
                color: ApexColors.textTertiary,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: ApexSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}

class ApexSectionHeader extends StatelessWidget {
  const ApexSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ApexTypography.titleMedium.copyWith(
                  color: ApexColors.textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class ApexStatKpiCard extends StatelessWidget {
  const ApexStatKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent = ApexColors.sapphireBright,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ApexSpacing.md),
      decoration: BoxDecoration(
        color: ApexColors.nebula.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(ApexRadius.card),
        border: Border.all(color: accent.withValues(alpha: 0.24), width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(height: ApexSpacing.sm),
          Text(
            value,
            style: ApexTypography.headlineMedium.copyWith(
              color: ApexColors.textPrimary,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: ApexSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ApexTypography.bodyMedium.copyWith(
              color: ApexColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
