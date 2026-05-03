/// Reusable account/profile connection presence badge.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/controllers/connectivity_presence_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

class ApexConnectionPresenceBadge extends StatefulWidget {
  const ApexConnectionPresenceBadge({
    super.key,
    required this.presence,
    this.size = 38,
    this.onTap,
    this.tooltip,
  });

  final ApexConnectionPresence presence;
  final double size;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  State<ApexConnectionPresenceBadge> createState() =>
      _ApexConnectionPresenceBadgeState();
}

class _ApexConnectionPresenceBadgeState
    extends State<ApexConnectionPresenceBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant ApexConnectionPresenceBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    final model = ConnectivityPresenceBadgeModel.fromPresence(widget.presence);
    if (model.animateRing) {
      if (!_ringController.isAnimating) _ringController.repeat();
    } else {
      _ringController.stop();
      _ringController.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = ConnectivityPresenceBadgeModel.fromPresence(widget.presence);
    final badge = Semantics(
      label: model.label,
      button: widget.onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ApexColors.elevatedSurface.withValues(alpha: 0.58),
              border: Border.all(
                color: model.accent.withValues(alpha: 0.30),
                width: 0.8,
              ),
              boxShadow: [
                if (model.showHalo)
                  BoxShadow(
                    color: model.accent.withValues(alpha: 0.22),
                    blurRadius: 18,
                    spreadRadius: -7,
                  ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (model.animateRing)
                  RotationTransition(
                    turns: _ringController,
                    child: SizedBox(
                      width: widget.size - 3,
                      height: widget.size - 3,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        value: 0.72,
                        color: model.accent.withValues(alpha: 0.78),
                        backgroundColor: model.accent.withValues(alpha: 0.08),
                      ),
                    ),
                  )
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: widget.size - 5,
                    height: widget.size - 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: model.accent.withValues(alpha: 0.24),
                        width: 1,
                      ),
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: Icon(
                    model.icon,
                    key: ValueKey(model.tone),
                    size: widget.size * 0.58,
                    color: model.iconColor,
                  ),
                ),
                Positioned(
                  right: widget.size * 0.05,
                  bottom: widget.size * 0.08,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: widget.size * 0.22,
                    height: widget.size * 0.22,
                    decoration: BoxDecoration(
                      color: model.dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ApexColors.deepSpace,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: model.dotColor.withValues(alpha: 0.50),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final tooltip = widget.tooltip;
    if (tooltip == null) return badge;
    return Tooltip(message: tooltip, child: badge);
  }
}
