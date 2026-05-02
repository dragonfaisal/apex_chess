/// Compact Apex-styled snackbar helper.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

void showApexSnack(
  BuildContext context, {
  required String message,
  String? detail,
  Color color = ApexColors.sapphireBright,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          borderRadius: 14,
          blur: 16,
          accentColor: color,
          accentAlpha: 0.28,
          fillAlpha: 0.78,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  detail == null ? message : '$message · $detail',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
