/// Inline pill rendered at the trailing edge of a username text field.
///
/// States:
///   * idle (field empty / < 3 chars) — nothing rendered
///   * debouncing / loading — compact Apex checking pill
///   * exists — green verified pill
///   * missing — red/orange not-found pill
///   * unknown (network error) — nothing (stays neutral; honest)
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_loading.dart';

import '../../data/username_validator.dart';
import '../username_validation_controller.dart';

class UsernameValidationPill extends StatelessWidget {
  const UsernameValidationPill({super.key, required this.controller});

  final UsernameValidationController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UsernameValidationState>(
      valueListenable: controller,
      builder: (_, state, __) => _buildPill(state),
    );
  }

  Widget _buildPill(UsernameValidationState state) {
    if (state.isSpinning) {
      return const _Chip(
        color: ApexColors.sapphireBright,
        label: 'Checking',
        loading: true,
      );
    }
    if (state.existence == UsernameExistence.exists) {
      return const _Chip(
        color: ApexColors.best,
        icon: Icons.check_circle_rounded,
        label: 'Verified',
      );
    }
    if (state.existence == UsernameExistence.missing) {
      return const _Chip(
        color: ApexColors.mistake,
        icon: Icons.cancel_rounded,
        label: 'Not found',
      );
    }
    return const SizedBox.shrink();
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.color,
    required this.label,
    this.icon,
    this.loading = false,
  });

  final Color color;
  final IconData? icon;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.42), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  ApexPulseLoader(size: 12, color: color)
                else if (icon != null)
                  Icon(icon, color: color, size: 13),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
