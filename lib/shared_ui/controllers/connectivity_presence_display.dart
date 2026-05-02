/// Display mapping for the account/profile connectivity dot.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

enum ConnectivityPresenceTone { online, offline, checking, serviceIssue }

class ConnectivityPresenceDisplay {
  const ConnectivityPresenceDisplay._();

  static ConnectivityPresenceTone toneFor(ApexConnectionPresence presence) {
    if (presence.isSyncing) return ConnectivityPresenceTone.checking;
    if (presence.isOffline) return ConnectivityPresenceTone.offline;
    if (presence.hasServiceIssue) return ConnectivityPresenceTone.serviceIssue;
    return ConnectivityPresenceTone.online;
  }

  static Color colorFor(ApexConnectionPresence presence) {
    return switch (toneFor(presence)) {
      ConnectivityPresenceTone.online => ApexColors.emeraldBright,
      ConnectivityPresenceTone.offline => ApexColors.ruby,
      ConnectivityPresenceTone.checking => ApexColors.aurora,
      ConnectivityPresenceTone.serviceIssue => ApexColors.inaccuracy,
    };
  }
}
