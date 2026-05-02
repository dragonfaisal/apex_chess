/// Floating Apex glass toast helper.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/glass_panel.dart';

enum ApexGlassToastType { info, success, warning, cancelled }

class ApexToastDeduper {
  ApexToastDeduper({this.window = const Duration(milliseconds: 2400)});

  final Duration window;
  String? _lastKey;
  DateTime? _lastAt;

  bool shouldShow(String key, DateTime now) {
    final lastAt = _lastAt;
    if (_lastKey == key && lastAt != null && now.difference(lastAt) < window) {
      return false;
    }
    _lastKey = key;
    _lastAt = now;
    return true;
  }
}

final ApexToastDeduper _globalToastDeduper = ApexToastDeduper();

void showApexGlassToast(
  BuildContext context, {
  required String message,
  String? detail,
  ApexGlassToastType type = ApexGlassToastType.info,
  Color? color,
  Duration duration = const Duration(milliseconds: 2300),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  showApexGlassToastOnMessenger(
    messenger,
    bottomMargin: MediaQuery.paddingOf(context).bottom + 78,
    message: message,
    detail: detail,
    type: type,
    color: color,
    duration: duration,
  );
}

void showApexGlassToastOnMessenger(
  ScaffoldMessengerState messenger, {
  required double bottomMargin,
  required String message,
  String? detail,
  ApexGlassToastType type = ApexGlassToastType.info,
  Color? color,
  Duration duration = const Duration(milliseconds: 2300),
}) {
  final key = '$message|${detail ?? ''}|$type';
  if (!_globalToastDeduper.shouldShow(key, DateTime.now())) return;

  final accent = color ?? _toastColor(type);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        dismissDirection: DismissDirection.down,
        margin: EdgeInsets.fromLTRB(18, 0, 18, bottomMargin),
        padding: EdgeInsets.zero,
        content: GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          borderRadius: 18,
          blur: 18,
          accentColor: accent,
          accentAlpha: 0.24,
          fillAlpha: 0.74,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  detail == null ? message : '$message · $detail',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}

void showApexSnack(
  BuildContext context, {
  required String message,
  String? detail,
  Color color = ApexColors.sapphireBright,
}) {
  showApexGlassToast(context, message: message, detail: detail, color: color);
}

Color _toastColor(ApexGlassToastType type) => switch (type) {
  ApexGlassToastType.info => ApexColors.sapphireBright,
  ApexGlassToastType.success => ApexColors.emeraldBright,
  ApexGlassToastType.warning => ApexColors.ruby,
  ApexGlassToastType.cancelled => ApexColors.textTertiary,
};
