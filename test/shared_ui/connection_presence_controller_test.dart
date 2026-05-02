import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'connectivity presence changes state on simulated offline/online',
    () async {
      var online = true;
      final container = ProviderContainer(
        overrides: [
          connectionReachabilityProbeProvider.overrideWithValue(
            () async => online,
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(connectionPresenceProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      online = false;
      await controller.refresh();
      final offline = container.read(connectionPresenceProvider);
      expect(offline.status, ApexConnectionStatus.offline);
      expect(offline.toastMessage, ApexCopy.offline);
      expect(offline.toastDetail, ApexCopy.showingSavedData);

      final offlineToastId = offline.toastId;
      await controller.refresh();
      expect(
        container.read(connectionPresenceProvider).toastId,
        offlineToastId,
      );

      online = true;
      await controller.refresh();
      final restored = container.read(connectionPresenceProvider);
      expect(restored.status, ApexConnectionStatus.online);
      expect(restored.toastMessage, ApexCopy.backOnline);
      expect(restored.toastId, greaterThan(offlineToastId));
    },
  );
}
