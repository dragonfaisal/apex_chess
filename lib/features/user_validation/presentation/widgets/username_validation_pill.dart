/// Inline pill rendered at the trailing edge of a username text field.
///
/// States:
///   * idle (field empty / < 2 chars) — nothing rendered
///   * debouncing / loading — 14px amber spinner
///   * exists — green check pill
///   * missing — red X pill
///   * unknown (network error) — nothing (stays neutral; honest)
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

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
      return const Padding(
        padding: EdgeInsets.only(right: 12),
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 1.6,
            valueColor: AlwaysStoppedAnimation<Color>(ApexColors.textTertiary),
          ),
        ),
      );
    }
    if (state.existence == UsernameExistence.exists) {
      return const _Chip(
        color: Color(0xFF10B981),
        icon: Icons.check_circle_rounded,
        label: 'verified',
      );
    }
    if (state.existence == UsernameExistence.missing) {
      return const _Chip(
        color: Color(0xFFEF4444),
        icon: Icons.cancel_rounded,
        label: 'not found',
      );
    }
    return const SizedBox.shrink();
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
