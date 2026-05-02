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
          snapshot: ConnectivitySnapshot(
            network: NetworkAvailability.online,
            services: {AppService.chessCom: ServiceAvailability.unavailable},
          ),
        ),
      ),
      ConnectivityPresenceTone.serviceIssue,
    );
  });
}
