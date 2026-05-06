/// Display mapping for the account/profile connectivity dot.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

enum ConnectivityPresenceTone {
  online,
  offline,
  checking,
  unstable,
  serviceIssue,
  captiveOrBlocked,
  unknown,
}

class ConnectivityPresenceBadgeModel {
  const ConnectivityPresenceBadgeModel({
    required this.tone,
    required this.label,
    required this.icon,
    required this.accent,
    required this.iconColor,
    required this.dotColor,
    required this.showHalo,
    required this.animateRing,
  });

  final ConnectivityPresenceTone tone;
  final String label;
  final IconData icon;
  final Color accent;
  final Color iconColor;
  final Color dotColor;
  final bool showHalo;
  final bool animateRing;

  bool get isOffline => tone == ConnectivityPresenceTone.offline;
  bool get hasServiceIssue => tone == ConnectivityPresenceTone.serviceIssue;

  factory ConnectivityPresenceBadgeModel.fromPresence(
    ApexConnectionPresence presence,
  ) {
    final tone = ConnectivityPresenceDisplay.toneFor(presence);
    return switch (tone) {
      ConnectivityPresenceTone.online => const ConnectivityPresenceBadgeModel(
        tone: ConnectivityPresenceTone.online,
        label: 'Online',
        icon: Icons.account_circle_rounded,
        accent: ApexColors.emeraldBright,
        iconColor: ApexColors.textPrimary,
        dotColor: ApexColors.emeraldBright,
        showHalo: true,
        animateRing: false,
      ),
      ConnectivityPresenceTone.offline => const ConnectivityPresenceBadgeModel(
        tone: ConnectivityPresenceTone.offline,
        label: 'Offline',
        icon: Icons.account_circle_outlined,
        accent: ApexColors.ruby,
        iconColor: ApexColors.textTertiary,
        dotColor: ApexColors.ruby,
        showHalo: true,
        animateRing: false,
      ),
      ConnectivityPresenceTone.captiveOrBlocked =>
        const ConnectivityPresenceBadgeModel(
          tone: ConnectivityPresenceTone.captiveOrBlocked,
          label: 'Network blocked',
          icon: Icons.account_circle_outlined,
          accent: ApexColors.mistake,
          iconColor: ApexColors.textTertiary,
          dotColor: ApexColors.mistake,
          showHalo: true,
          animateRing: false,
        ),
      ConnectivityPresenceTone.checking => const ConnectivityPresenceBadgeModel(
        tone: ConnectivityPresenceTone.checking,
        label: 'Checking',
        icon: Icons.account_circle_rounded,
        accent: ApexColors.aurora,
        iconColor: ApexColors.textPrimary,
        dotColor: ApexColors.aurora,
        showHalo: true,
        animateRing: true,
      ),
      ConnectivityPresenceTone.unstable => const ConnectivityPresenceBadgeModel(
        tone: ConnectivityPresenceTone.unstable,
        label: 'Unstable',
        icon: Icons.account_circle_rounded,
        accent: ApexColors.inaccuracy,
        iconColor: ApexColors.textSecondary,
        dotColor: ApexColors.inaccuracy,
        showHalo: true,
        animateRing: false,
      ),
      ConnectivityPresenceTone.serviceIssue =>
        const ConnectivityPresenceBadgeModel(
          tone: ConnectivityPresenceTone.serviceIssue,
          label: 'Service unavailable',
          icon: Icons.account_circle_rounded,
          accent: ApexColors.inaccuracy,
          iconColor: ApexColors.textSecondary,
          dotColor: ApexColors.inaccuracy,
          showHalo: true,
          animateRing: false,
        ),
      ConnectivityPresenceTone.unknown => const ConnectivityPresenceBadgeModel(
        tone: ConnectivityPresenceTone.unknown,
        label: 'Unknown',
        icon: Icons.account_circle_rounded,
        accent: ApexColors.sapphireBright,
        iconColor: ApexColors.textSecondary,
        dotColor: ApexColors.sapphireBright,
        showHalo: false,
        animateRing: false,
      ),
    };
  }
}

class ConnectivityPresenceDisplay {
  const ConnectivityPresenceDisplay._();

  static ConnectivityPresenceTone toneFor(ApexConnectionPresence presence) {
    return switch (presence.status) {
      ApexConnectionStatus.online => ConnectivityPresenceTone.online,
      ApexConnectionStatus.offline => ConnectivityPresenceTone.offline,
      ApexConnectionStatus.checking => ConnectivityPresenceTone.checking,
      ApexConnectionStatus.unstable => ConnectivityPresenceTone.unstable,
      ApexConnectionStatus.serviceIssue =>
        ConnectivityPresenceTone.serviceIssue,
      ApexConnectionStatus.captiveOrBlocked =>
        ConnectivityPresenceTone.captiveOrBlocked,
      ApexConnectionStatus.unknown => ConnectivityPresenceTone.unknown,
    };
  }

  static Color colorFor(ApexConnectionPresence presence) {
    return switch (toneFor(presence)) {
      ConnectivityPresenceTone.online => ApexColors.emeraldBright,
      ConnectivityPresenceTone.offline => ApexColors.ruby,
      ConnectivityPresenceTone.checking => ApexColors.aurora,
      ConnectivityPresenceTone.unstable => ApexColors.inaccuracy,
      ConnectivityPresenceTone.serviceIssue => ApexColors.inaccuracy,
      ConnectivityPresenceTone.captiveOrBlocked => ApexColors.mistake,
      ConnectivityPresenceTone.unknown => ApexColors.sapphireBright,
    };
  }
}
