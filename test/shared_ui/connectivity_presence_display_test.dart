import 'package:apex_chess/core/network/connectivity_models.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/controllers/connectivity_presence_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile dot display maps central connectivity truthfully', () {
    expect(
      ConnectivityPresenceDisplay.toneFor(
        const ApexConnectionPresence(
          snapshot: ConnectivitySnapshot(network: NetworkAvailability.online),
        ),
      ),
      ConnectivityPresenceTone.online,
    );

    expect(
      ConnectivityPresenceDisplay.toneFor(
        const ApexConnectionPresence(
          snapshot: ConnectivitySnapshot(network: NetworkAvailability.offline),
        ),
      ),
      ConnectivityPresenceTone.offline,
    );

    expect(
      ConnectivityPresenceDisplay.toneFor(
        const ApexConnectionPresence(
          snapshot: ConnectivitySnapshot(sync: SyncStatus.checking),
        ),
      ),
      ConnectivityPresenceTone.checking,
    );

    expect(
      ConnectivityPresenceDisplay.toneFor(
        const ApexConnectionPresence(
          snapshot: ConnectivitySnapshot(network: NetworkAvailability.unstable),
        ),
      ),
      ConnectivityPresenceTone.unstable,
    );

    expect(
      ConnectivityPresenceDisplay.toneFor(
        const ApexConnectionPresence(
          snapshot: ConnectivitySnapshot(
            network: NetworkAvailability.online,
            services: {AppService.chessCom: ServiceAvailability.unavailable},
          ),
        ),
      ),
      ConnectivityPresenceTone.serviceIssue,
    );
  });

  test('stable online maps to online badge model', () {
    final model = ConnectivityPresenceBadgeModel.fromPresence(
      const ApexConnectionPresence(
        snapshot: ConnectivitySnapshot(network: NetworkAvailability.online),
      ),
    );

    expect(model.tone, ConnectivityPresenceTone.online);
    expect(model.label, 'Online');
    expect(model.showHalo, isTrue);
  });

  test('offline maps to coral offline badge', () {
    final model = ConnectivityPresenceBadgeModel.fromPresence(
      const ApexConnectionPresence(
        snapshot: ConnectivitySnapshot(network: NetworkAvailability.offline),
      ),
    );

    expect(model.tone, ConnectivityPresenceTone.offline);
    expect(model.isOffline, isTrue);
  });

  test('checking maps to syncing badge', () {
    final model = ConnectivityPresenceBadgeModel.fromPresence(
      const ApexConnectionPresence(
        snapshot: ConnectivitySnapshot(sync: SyncStatus.checking),
      ),
    );

    expect(model.tone, ConnectivityPresenceTone.checking);
    expect(model.animateRing, isTrue);
  });

  test('service unavailable is not device offline', () {
    final model = ConnectivityPresenceBadgeModel.fromPresence(
      const ApexConnectionPresence(
        snapshot: ConnectivitySnapshot(
          network: NetworkAvailability.online,
          services: {AppService.chessCom: ServiceAvailability.unavailable},
        ),
      ),
    );

    expect(model.tone, ConnectivityPresenceTone.serviceIssue);
    expect(model.isOffline, isFalse);
    expect(model.hasServiceIssue, isTrue);
  });

  test('captive or blocked network maps to separate badge tone', () {
    final model = ConnectivityPresenceBadgeModel.fromPresence(
      const ApexConnectionPresence(
        snapshot: ConnectivitySnapshot(
          network: NetworkAvailability.captiveOrBlocked,
        ),
      ),
    );

    expect(model.tone, ConnectivityPresenceTone.captiveOrBlocked);
    expect(model.isOffline, isFalse);
    expect(model.label, 'Network blocked');
  });

  test('profile badge does not treat transient checking as offline', () {
    final tone = ConnectivityPresenceDisplay.toneFor(
      const ApexConnectionPresence(
        snapshot: ConnectivitySnapshot(
          network: NetworkAvailability.online,
          sync: SyncStatus.checking,
        ),
      ),
    );

    expect(tone, ConnectivityPresenceTone.checking);
    expect(tone, isNot(ConnectivityPresenceTone.offline));
  });

  test('badge display model uses stable state, not raw probe result', () {
    final firstFailureModel = ConnectivityPresenceBadgeModel.fromPresence(
      const ApexConnectionPresence(
        snapshot: ConnectivitySnapshot(
          network: NetworkAvailability.unstable,
          consecutiveFailures: 1,
        ),
      ),
    );
    final confirmedOfflineModel = ConnectivityPresenceBadgeModel.fromPresence(
      const ApexConnectionPresence(
        snapshot: ConnectivitySnapshot(network: NetworkAvailability.offline),
      ),
    );

    expect(firstFailureModel.tone, ConnectivityPresenceTone.unstable);
    expect(firstFailureModel.tone, isNot(ConnectivityPresenceTone.offline));
    expect(confirmedOfflineModel.tone, ConnectivityPresenceTone.offline);
  });
}
