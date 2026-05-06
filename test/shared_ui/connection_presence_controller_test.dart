import 'package:apex_chess/core/network/connectivity_models.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('single failed probe does not produce Offline', () async {
    var network = NetworkAvailability.online;
    final container = _container(() async => network);
    addTearDown(container.dispose);

    final controller = container.read(connectionPresenceProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    network = NetworkAvailability.offline;
    await controller.refresh();

    final state = container.read(connectionPresenceProvider);
    expect(state.status, ApexConnectionStatus.unstable);
    expect(state.isOffline, isFalse);
    expect(state.toastMessage, isNull);
    expect(state.snapshot.consecutiveFailures, 1);
  });

  test('two consecutive confirmed failures produce Offline', () async {
    var network = NetworkAvailability.online;
    final container = _container(() async => network);
    addTearDown(container.dispose);

    final controller = container.read(connectionPresenceProvider.notifier);
    await Future<void>.delayed(Duration.zero);

    network = NetworkAvailability.offline;
    await controller.refresh();
    expect(container.read(connectionPresenceProvider).isOffline, isFalse);

    await controller.refresh();
    final state = container.read(connectionPresenceProvider);
    expect(state.status, ApexConnectionStatus.offline);
    expect(state.toastMessage, ApexCopy.offline);
    expect(state.snapshot.lastOfflineAt, isNotNull);
  });

  test('one success after Offline does not flicker immediately', () async {
    var network = NetworkAvailability.offline;
    final container = _container(() async => network);
    addTearDown(container.dispose);

    final controller = container.read(connectionPresenceProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.refresh();
    await controller.refresh();
    expect(container.read(connectionPresenceProvider).isOffline, isTrue);

    network = NetworkAvailability.online;
    await controller.refresh();

    final state = container.read(connectionPresenceProvider);
    expect(state.status, ApexConnectionStatus.offline);
    expect(state.toastMessage, isNull);
    expect(state.snapshot.consecutiveSuccesses, 1);
  });

  test('stable successes produce Back online once', () async {
    var network = NetworkAvailability.offline;
    final container = _container(() async => network);
    addTearDown(container.dispose);

    final controller = container.read(connectionPresenceProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.refresh();
    await controller.refresh();
    final offlineToast = container.read(connectionPresenceProvider).toastId;

    network = NetworkAvailability.online;
    await controller.refresh();
    expect(container.read(connectionPresenceProvider).toastId, offlineToast);

    await controller.refresh();
    final restored = container.read(connectionPresenceProvider);
    expect(restored.status, ApexConnectionStatus.online);
    expect(restored.toastMessage, ApexCopy.backOnline);
    expect(restored.toastId, greaterThan(offlineToast));

    final restoredToast = restored.toastId;
    await controller.refresh();
    expect(container.read(connectionPresenceProvider).toastId, restoredToast);
  });

  test(
    'Chess.com service failure with internet OK maps to serviceIssue',
    () async {
      final container = _container(() async => NetworkAvailability.online);
      addTearDown(container.dispose);

      final controller = container.read(connectionPresenceProvider.notifier);
      final message = await controller.resolveServiceFailure(
        service: AppService.chessCom,
        message: 'Chess.com endpoint returned 503.',
      );

      final state = container.read(connectionPresenceProvider);
      expect(message, ApexCopy.chessComUnavailable);
      expect(state.status, ApexConnectionStatus.serviceIssue);
      expect(state.isOffline, isFalse);
      expect(
        state.snapshot.serviceStatus(AppService.chessCom),
        ServiceAvailability.unavailable,
      );
    },
  );

  test('timeout maps to unstable or try again, not Offline', () async {
    var network = NetworkAvailability.unstable;
    final container = _container(() async => network);
    addTearDown(container.dispose);

    final controller = container.read(connectionPresenceProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.refresh();

    var state = container.read(connectionPresenceProvider);
    expect(state.status, ApexConnectionStatus.unstable);
    expect(state.isOffline, isFalse);
    expect(state.toastMessage, isNull);

    network = NetworkAvailability.online;
    final message = await controller.resolveServiceFailure(
      service: AppService.chessCom,
      message: 'Chess.com took too long to respond.',
      availability: ServiceAvailability.timeout,
      notify: true,
    );

    state = container.read(connectionPresenceProvider);
    expect(message, ApexCopy.tryAgain);
    expect(state.isOffline, isFalse);
    expect(state.toastMessage, ApexCopy.tryAgain);
  });

  test('repeated same state does not duplicate toast', () async {
    var network = NetworkAvailability.offline;
    final container = _container(() async => network);
    addTearDown(container.dispose);

    final controller = container.read(connectionPresenceProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.refresh();
    await controller.refresh();

    final offlineToast = container.read(connectionPresenceProvider).toastId;
    await controller.refresh();

    expect(container.read(connectionPresenceProvider).toastId, offlineToast);
  });

  test(
    'action-based failure does not immediately flip global state Offline',
    () async {
      var network = NetworkAvailability.online;
      final container = _container(() async => network);
      addTearDown(container.dispose);

      final controller = container.read(connectionPresenceProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      network = NetworkAvailability.offline;
      final allowed = await controller.ensureOnlineForAction();

      final state = container.read(connectionPresenceProvider);
      expect(allowed, isTrue);
      expect(state.status, ApexConnectionStatus.unstable);
      expect(state.isOffline, isFalse);
      expect(state.toastMessage, isNull);
    },
  );

  test(
    'cached data state shows Showing saved data on confirmed Offline',
    () async {
      var network = NetworkAvailability.online;
      final container = _container(() async => network);
      addTearDown(container.dispose);

      final controller = container.read(connectionPresenceProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      controller.markCachedDataAvailable(true);

      network = NetworkAvailability.offline;
      await controller.refresh();
      await controller.refresh();

      final state = container.read(connectionPresenceProvider);
      expect(state.isOffline, isTrue);
      expect(state.toastMessage, ApexCopy.offline);
      expect(state.toastDetail, ApexCopy.showingSavedData);
    },
  );

  test('captive or blocked network is distinct from Offline', () async {
    var network = NetworkAvailability.captiveOrBlocked;
    final container = _container(() async => network);
    addTearDown(container.dispose);
    final toastMessages = <String>[];
    final subscription = container.listen<ApexConnectionPresence>(
      connectionPresenceProvider,
      (previous, next) {
        if ((previous?.toastId ?? 0) != next.toastId &&
            next.toastMessage != null) {
          toastMessages.add(next.toastMessage!);
        }
      },
    );
    addTearDown(subscription.close);

    final controller = container.read(connectionPresenceProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    await controller.refresh();
    await controller.refresh();

    final state = container.read(connectionPresenceProvider);
    expect(state.status, ApexConnectionStatus.captiveOrBlocked);
    expect(state.isOffline, isFalse);
    expect(state.isNetworkBlocked, isTrue);
    expect(toastMessages, contains(ApexCopy.noConnection));
  });
}

ProviderContainer _container(ConnectionReachabilityProbe probe) {
  return ProviderContainer(
    overrides: [connectionReachabilityProbeProvider.overrideWithValue(probe)],
  );
}
