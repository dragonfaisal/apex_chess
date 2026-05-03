import 'dart:async';

import 'package:apex_chess/core/network/connectivity_models.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'connectivity presence changes state on simulated offline/online',
    () async {
      var network = NetworkAvailability.online;
      final container = ProviderContainer(
        overrides: [
          connectionReachabilityProbeProvider.overrideWithValue(
            () async => network,
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(connectionPresenceProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      network = NetworkAvailability.offline;
      await controller.refresh();
      final unstable = container.read(connectionPresenceProvider);
      expect(unstable.status, isNot(ApexConnectionStatus.offline));
      expect(unstable.toastMessage, isNull);

      await controller.refresh();
      final offline = container.read(connectionPresenceProvider);
      expect(offline.status, ApexConnectionStatus.offline);
      expect(offline.toastMessage, ApexCopy.offline);
      expect(offline.toastDetail, isNull);

      final offlineToastId = offline.toastId;
      await controller.refresh();
      expect(
        container.read(connectionPresenceProvider).toastId,
        offlineToastId,
      );

      network = NetworkAvailability.online;
      await controller.refresh();
      final restored = container.read(connectionPresenceProvider);
      expect(restored.status, ApexConnectionStatus.online);
      expect(restored.toastMessage, ApexCopy.backOnline);
      expect(restored.toastId, greaterThan(offlineToastId));

      final restoredToastId = restored.toastId;
      await controller.refresh();
      expect(
        container.read(connectionPresenceProvider).toastId,
        restoredToastId,
      );
    },
  );

  test(
    'checkNow marks syncing before user-action reachability result',
    () async {
      var calls = 0;
      final secondProbe = Completer<NetworkAvailability>();
      final container = ProviderContainer(
        overrides: [
          connectionReachabilityProbeProvider.overrideWithValue(() {
            calls++;
            if (calls == 1) {
              return Future<NetworkAvailability>.value(
                NetworkAvailability.online,
              );
            }
            return secondProbe.future;
          }),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(connectionPresenceProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final pending = controller.checkNow();
      expect(
        container.read(connectionPresenceProvider).status,
        ApexConnectionStatus.syncing,
      );

      secondProbe.complete(NetworkAvailability.offline);
      await pending;

      expect(
        container.read(connectionPresenceProvider).status,
        isNot(ApexConnectionStatus.offline),
      );
      expect(container.read(connectionPresenceProvider).toastMessage, isNull);
    },
  );

  test(
    'consecutive failures show Offline after hysteresis threshold',
    () async {
      var network = NetworkAvailability.online;
      final container = ProviderContainer(
        overrides: [
          connectionReachabilityProbeProvider.overrideWithValue(
            () async => network,
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(connectionPresenceProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      network = NetworkAvailability.offline;
      await controller.refresh();
      expect(container.read(connectionPresenceProvider).isOffline, isFalse);
      await controller.refresh();
      expect(container.read(connectionPresenceProvider).isOffline, isTrue);
      expect(
        container.read(connectionPresenceProvider).toastMessage,
        ApexCopy.offline,
      );
    },
  );

  test('recovered connection shows Back online once', () async {
    var network = NetworkAvailability.online;
    final container = ProviderContainer(
      overrides: [
        connectionReachabilityProbeProvider.overrideWithValue(
          () async => network,
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(connectionPresenceProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    network = NetworkAvailability.offline;
    await controller.refresh();
    await controller.refresh();

    final offlineToast = container.read(connectionPresenceProvider).toastId;
    network = NetworkAvailability.online;
    await controller.refresh();
    final restored = container.read(connectionPresenceProvider);
    expect(restored.toastMessage, ApexCopy.backOnline);
    expect(restored.toastId, greaterThan(offlineToast));

    final restoredToast = restored.toastId;
    await controller.refresh();
    expect(container.read(connectionPresenceProvider).toastId, restoredToast);
  });

  test('service failure while internet works does not set global offline', () {
    final container = ProviderContainer(
      overrides: [
        connectionReachabilityProbeProvider.overrideWithValue(
          () async => NetworkAvailability.online,
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(connectionPresenceProvider.notifier);
    controller.markServiceStatus(
      AppService.chessCom,
      ServiceAvailability.unavailable,
      message: ApexCopy.chessComUnavailable,
    );

    final state = container.read(connectionPresenceProvider);
    expect(state.snapshot.network, NetworkAvailability.online);
    expect(state.status, ApexConnectionStatus.online);
    expect(
      state.snapshot.serviceStatus(AppService.chessCom),
      ServiceAvailability.unavailable,
    );
    expect(state.isOffline, isFalse);
  });

  test('lichess failure while internet works does not set global offline', () {
    final container = ProviderContainer(
      overrides: [
        connectionReachabilityProbeProvider.overrideWithValue(
          () async => NetworkAvailability.online,
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(connectionPresenceProvider.notifier);
    controller.markServiceStatus(
      AppService.lichess,
      ServiceAvailability.timeout,
      message: ApexCopy.lichessUnavailable,
    );

    final state = container.read(connectionPresenceProvider);
    expect(state.snapshot.network, NetworkAvailability.online);
    expect(state.status, ApexConnectionStatus.online);
    expect(
      state.snapshot.serviceStatus(AppService.lichess),
      ServiceAvailability.timeout,
    );
    expect(state.isOffline, isFalse);
  });

  test('service timeout is not labeled device offline', () {
    final container = ProviderContainer(
      overrides: [
        connectionReachabilityProbeProvider.overrideWithValue(
          () async => NetworkAvailability.online,
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(connectionPresenceProvider.notifier);
    controller.markServiceStatus(
      AppService.chessCom,
      ServiceAvailability.timeout,
      message: ApexCopy.chessComUnavailable,
      notify: true,
    );

    final state = container.read(connectionPresenceProvider);
    expect(state.isOffline, isFalse);
    expect(state.toastMessage, ApexCopy.chessComUnavailable);
  });

  test(
    'resolveServiceFailure checks internet before marking offline',
    () async {
      var network = NetworkAvailability.online;
      final container = ProviderContainer(
        overrides: [
          connectionReachabilityProbeProvider.overrideWithValue(
            () async => network,
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(connectionPresenceProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      final serviceMessage = await controller.resolveServiceFailure(
        service: AppService.chessCom,
        message: 'Could not reach Chess.com. Check your connection.',
      );
      expect(serviceMessage, ApexCopy.chessComUnavailable);
      expect(
        container.read(connectionPresenceProvider).snapshot.network,
        NetworkAvailability.online,
      );

      network = NetworkAvailability.offline;
      final offlineMessage = await controller.resolveServiceFailure(
        service: AppService.chessCom,
        message: 'Could not reach Chess.com. Check your connection.',
      );
      expect(offlineMessage, ApexCopy.chessComUnavailable);
      expect(
        container.read(connectionPresenceProvider).snapshot.network,
        NetworkAvailability.online,
      );
    },
  );
}
