/// Floating Apex glass toast helper.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
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

class ApexToastDisplay {
  const ApexToastDisplay({required this.label, required this.color});

  final String label;
  final Color color;

  factory ApexToastDisplay.from({
    required String message,
    String? detail,
    ApexGlassToastType type = ApexGlassToastType.info,
    Color? color,
  }) {
    final label = detail == ApexCopy.showingSavedData ? detail! : message;
    return ApexToastDisplay(color: color ?? _toastColor(type), label: label);
  }

  bool get isOneLine => !label.contains('\n') && label.length <= 28;
}

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
    screenWidth: MediaQuery.sizeOf(context).width,
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
  double? screenWidth,
  required String message,
  String? detail,
  ApexGlassToastType type = ApexGlassToastType.info,
  Color? color,
  Duration duration = const Duration(milliseconds: 2300),
}) {
  final key = '$message|${detail ?? ''}|$type';
  if (!_globalToastDeduper.shouldShow(key, DateTime.now())) return;

  final display = ApexToastDisplay.from(
    message: message,
    detail: detail,
    type: type,
    color: color,
  );
  final accent = display.color;
  final width = _toastWidth(screenWidth);
  final sideMargin = screenWidth == null
      ? 40.0
      : math.max(24.0, (screenWidth - width) / 2);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        dismissDirection: DismissDirection.down,
        margin: EdgeInsets.fromLTRB(sideMargin, 0, sideMargin, bottomMargin),
        padding: EdgeInsets.zero,
        content: GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderRadius: 999,
          blur: 18,
          accentColor: accent,
          accentAlpha: 0.10,
          fillAlpha: 0.66,
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
                  display.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ApexTypography.bodyMedium.copyWith(
                    color: ApexColors.textPrimary,
                    fontSize: 11.5,
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

double _toastWidth(double? screenWidth) {
  if (screenWidth == null) return 280;
  final available = math.max(0.0, screenWidth - 48);
  return math.min(280.0, math.max(168.0, available));
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
