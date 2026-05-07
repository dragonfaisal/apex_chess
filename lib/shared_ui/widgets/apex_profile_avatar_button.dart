/// Avatar-first profile button with connection status ring/dot.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/controllers/connectivity_presence_display.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_player_avatar.dart';

class ApexProfileAvatarButton extends StatelessWidget {
  const ApexProfileAvatarButton({
    super.key,
    required this.identity,
    required this.presence,
    this.onTap,
    this.size = 42,
    this.tooltip,
  });

  final PlayerIdentityDisplay identity;
  final ApexConnectionPresence presence;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final model = ConnectivityPresenceBadgeModel.fromPresence(presence);
    final button = Semantics(
      label: '${identity.displayUsername} profile, ${model.label}',
      button: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            key: const ValueKey('apex-profile-avatar-button'),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ApexColors.elevatedSurface.withValues(alpha: 0.58),
              border: Border.all(
                color: model.accent.withValues(alpha: 0.34),
                width: 0.9,
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
                  SizedBox(
                    width: size - 2,
                    height: size - 2,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      value: 0.72,
                      color: model.accent.withValues(alpha: 0.78),
                      backgroundColor: model.accent.withValues(alpha: 0.08),
                    ),
                  )
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: size - 5,
                    height: size - 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: model.accent.withValues(alpha: 0.24),
                        width: 1,
                      ),
                    ),
                  ),
                ApexPlayerAvatar(identity: identity),
                Positioned(
                  right: size * 0.04,
                  bottom: size * 0.06,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: size * 0.22,
                    height: size * 0.22,
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

    final message = tooltip;
    if (message == null) return button;
    return Tooltip(message: message, child: button);
  }
}
