/// App-wide connectivity presence for status dots, service health, and toasts.
///
/// The network state is intentionally separate from Chess.com/Lichess health:
/// a provider failure must not mark the whole device offline.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/network/connectivity_models.dart';
import 'package:apex_chess/core/network/connectivity_service.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/controllers/service_health_service.dart';

enum ApexConnectionStatus {
  unknown,
  online,
  checking,
  unstable,
  serviceIssue,
  captiveOrBlocked,
  offline,
}

class ApexConnectionPresence {
  const ApexConnectionPresence({
    this.snapshot = const ConnectivitySnapshot(),
    this.hadIssue = false,
    this.lastMessage,
    this.toastId = 0,
    this.toastMessage,
    this.toastDetail,
  });

  final ConnectivitySnapshot snapshot;
  final bool hadIssue;
  final String? lastMessage;
  final int toastId;
  final String? toastMessage;
  final String? toastDetail;

  ApexConnectionStatus get status {
    if (snapshot.network == NetworkAvailability.offline) {
      return ApexConnectionStatus.offline;
    }
    if (snapshot.network == NetworkAvailability.captiveOrBlocked) {
      return ApexConnectionStatus.captiveOrBlocked;
    }
    if (snapshot.network == NetworkAvailability.unstable) {
      return ApexConnectionStatus.unstable;
    }
    if (snapshot.isChecking) return ApexConnectionStatus.checking;
    if (snapshot.network == NetworkAvailability.unknown) {
      return ApexConnectionStatus.unknown;
    }
    if (snapshot.hasServiceIssue) return ApexConnectionStatus.serviceIssue;
    return ApexConnectionStatus.online;
  }

  bool get isOffline => status == ApexConnectionStatus.offline;
  bool get isCaptiveOrBlocked =>
      status == ApexConnectionStatus.captiveOrBlocked;
  bool get isNetworkBlocked => isOffline || isCaptiveOrBlocked;
  bool get isSyncing => status == ApexConnectionStatus.checking;
  bool get isUnstable => status == ApexConnectionStatus.unstable;
  bool get hasServiceIssue => status == ApexConnectionStatus.serviceIssue;

  ApexConnectionPresence copyWith({
    ConnectivitySnapshot? snapshot,
    bool? hadIssue,
    String? lastMessage,
    bool clearLastMessage = false,
    int? toastId,
    String? toastMessage,
    String? toastDetail,
  }) {
    return ApexConnectionPresence(
      snapshot: snapshot ?? this.snapshot,
      hadIssue: hadIssue ?? this.hadIssue,
      lastMessage: clearLastMessage ? null : (lastMessage ?? this.lastMessage),
      toastId: toastId ?? this.toastId,
      toastMessage: toastMessage,
      toastDetail: toastDetail,
    );
  }
}

typedef ConnectionReachabilityProbe = Future<NetworkAvailability> Function();

final connectivityServiceProvider = Provider<ConnectivityService>(
  (_) => ConnectivityService(),
);

final serviceHealthServiceProvider = Provider<ServiceHealthService>(
  (_) => const ServiceHealthService(),
);

final connectionReachabilityProbeProvider =
    Provider<ConnectionReachabilityProbe>(
      (ref) => ref.read(connectivityServiceProvider).checkInternet,
    );

class ConnectionPresenceController extends Notifier<ApexConnectionPresence> {
  static const pollInterval = Duration(seconds: 3);
  static const failureThreshold = 2;
  static const recoveryThreshold = 2;
  static const toastCooldown = Duration(seconds: 4);

  Timer? _timer;
  Future<void>? _activeCheck;
  int _consecutiveFailures = 0;
  int _consecutiveSuccesses = 0;
  DateTime? _lastToastAt;
  String? _lastToastMessage;

  @override
  ApexConnectionPresence build() {
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) {
      unawaited(refresh(notify: true));
    });
    ref.onDispose(() => _timer?.cancel());
    unawaited(Future<void>.microtask(() => refresh(notify: false)));
    return const ApexConnectionPresence(
      snapshot: ConnectivitySnapshot(sync: SyncStatus.checking),
    );
  }

  Future<void> refresh({bool notify = true, bool showSyncing = false}) async {
    if (showSyncing) markChecking();
    final active = _activeCheck;
    if (active != null) return active;
    final check = _runReachabilityCheck(notify: notify);
    _activeCheck = check;
    try {
      await check;
    } finally {
      if (identical(_activeCheck, check)) _activeCheck = null;
    }
  }

  Future<void> checkNow({bool notify = true}) {
    return refresh(notify: notify, showSyncing: true);
  }

  Future<bool> ensureOnlineForAction({bool notify = true}) async {
    await checkNow(notify: notify);
    return !state.isNetworkBlocked;
  }

  Future<String> resolveServiceFailure({
    required AppService service,
    required String message,
    ServiceAvailability? availability,
    bool notify = false,
  }) async {
    final health = ref.read(serviceHealthServiceProvider);
    final resolvedAvailability =
        availability ?? health.availabilityForMessage(message);
    await refresh(notify: false, showSyncing: true);
    if (state.isOffline) {
      return ApexCopy.offline;
    }
    if (state.isCaptiveOrBlocked) {
      return ApexCopy.noConnection;
    }
    if (state.snapshot.network != NetworkAvailability.online) {
      _markNetworkUnstable(checkedAt: DateTime.now());
      return ApexCopy.tryAgain;
    }
    final userMessage = _serviceFailureCopy(
      health,
      service,
      resolvedAvailability,
    );
    markServiceStatus(
      service,
      resolvedAvailability,
      message: userMessage,
      notify: notify,
    );
    return userMessage;
  }

  Future<void> _runReachabilityCheck({required bool notify}) async {
    final previous = state.snapshot.network;
    final checkedAt = DateTime.now();
    final network = await ref.read(connectionReachabilityProbeProvider)();
    if (network == NetworkAvailability.online) {
      _consecutiveSuccesses++;
      _consecutiveFailures = 0;
      final wasBlocked =
          previous == NetworkAvailability.offline ||
          previous == NetworkAvailability.captiveOrBlocked;
      if (wasBlocked && _consecutiveSuccesses < recoveryThreshold) {
        _markRecoveryPending(checkedAt: checkedAt);
        return;
      }
      _markNetworkOnline(checkedAt: checkedAt, notify: notify && wasBlocked);
      return;
    }
    _consecutiveFailures++;
    _consecutiveSuccesses = 0;
    if (network == NetworkAvailability.unstable) {
      if (state.isNetworkBlocked) {
        _markRecoveryPending(checkedAt: checkedAt);
      } else {
        _markNetworkUnstable(checkedAt: checkedAt);
      }
      return;
    }
    if (_consecutiveFailures < failureThreshold) {
      _markNetworkUnstable(checkedAt: checkedAt);
      return;
    }
    if (network == NetworkAvailability.captiveOrBlocked) {
      _markNetworkOffline(
        checkedAt: checkedAt,
        network: NetworkAvailability.captiveOrBlocked,
        message: ApexCopy.noConnection,
        notify: notify && previous != NetworkAvailability.captiveOrBlocked,
      );
      return;
    }
    _markNetworkOffline(
      checkedAt: checkedAt,
      message: ApexCopy.offline,
      detail: state.snapshot.hasUsableCachedData
          ? ApexCopy.showingSavedData
          : null,
      notify: notify && previous != NetworkAvailability.offline,
    );
  }

  void markChecking() {
    state = state.copyWith(
      snapshot: state.snapshot.copyWith(sync: SyncStatus.checking),
      toastId: state.toastId,
    );
  }

  void markSyncing() {
    state = state.copyWith(
      snapshot: state.snapshot.copyWith(sync: SyncStatus.syncing),
      toastId: state.toastId,
    );
  }

  void markServiceAvailable(AppService service, {bool notify = false}) {
    final checkedAt = DateTime.now();
    final wasBlocked = state.isNetworkBlocked;
    final showToast =
        notify && wasBlocked && _canEmitToast(ApexCopy.backOnline, checkedAt);
    _consecutiveSuccesses = recoveryThreshold;
    _consecutiveFailures = 0;
    final snapshot = state.snapshot
        .withService(
          service,
          ServiceAvailability.available,
          network: NetworkAvailability.online,
          sync: SyncStatus.synced,
          checkedAt: checkedAt,
        )
        .copyWith(
          lastOnlineAt: checkedAt,
          lastTransitionAt: _transitionAt(
            NetworkAvailability.online,
            checkedAt,
          ),
          lastStableNetwork: NetworkAvailability.online,
          consecutiveSuccesses: _consecutiveSuccesses,
          consecutiveFailures: _consecutiveFailures,
        );
    state = state.copyWith(
      snapshot: snapshot,
      hadIssue: false,
      clearLastMessage: true,
      toastId: showToast ? state.toastId + 1 : state.toastId,
      toastMessage: showToast ? ApexCopy.backOnline : null,
    );
  }

  void markServiceStatus(
    AppService service,
    ServiceAvailability availability, {
    String? message,
    bool notify = false,
  }) {
    final checkedAt = DateTime.now();
    final showToast =
        notify && message != null && _canEmitToast(message, checkedAt);
    _consecutiveSuccesses = recoveryThreshold;
    _consecutiveFailures = 0;
    final snapshot = state.snapshot
        .withService(
          service,
          availability,
          network: NetworkAvailability.online,
          sync: availability == ServiceAvailability.available
              ? SyncStatus.synced
              : SyncStatus.failed,
          checkedAt: checkedAt,
        )
        .copyWith(
          lastOnlineAt: checkedAt,
          lastTransitionAt: _transitionAt(
            NetworkAvailability.online,
            checkedAt,
          ),
          lastStableNetwork: NetworkAvailability.online,
          consecutiveSuccesses: _consecutiveSuccesses,
          consecutiveFailures: _consecutiveFailures,
        );
    state = state.copyWith(
      snapshot: snapshot,
      hadIssue: availability != ServiceAvailability.available,
      lastMessage: message,
      toastId: showToast ? state.toastId + 1 : state.toastId,
      toastMessage: showToast ? message : null,
    );
  }

  void markOffline(String? message, {String? detail, bool notify = false}) {
    _markNetworkOffline(
      checkedAt: DateTime.now(),
      network: NetworkAvailability.offline,
      message: message ?? ApexCopy.offline,
      detail: detail,
      notify: notify,
    );
  }

  /// Returns true when callers should show a one-shot recovery message.
  bool markSynced({bool notify = false}) {
    final wasBlocked = state.isNetworkBlocked;
    _markNetworkOnline(checkedAt: DateTime.now(), notify: notify && wasBlocked);
    return wasBlocked;
  }

  void markCachedDataAvailable(bool available) {
    state = state.copyWith(
      snapshot: state.snapshot.copyWith(hasUsableCachedData: available),
      toastId: state.toastId,
    );
  }

  void _markNetworkOnline({required DateTime checkedAt, required bool notify}) {
    final showToast = notify && _canEmitToast(ApexCopy.backOnline, checkedAt);
    if (_consecutiveSuccesses < recoveryThreshold) {
      _consecutiveSuccesses = recoveryThreshold;
    }
    _consecutiveFailures = 0;
    final services = <AppService, ServiceAvailability>{
      for (final entry in state.snapshot.services.entries)
        entry.key: entry.value,
    };
    state = state.copyWith(
      snapshot: state.snapshot.copyWith(
        network: NetworkAvailability.online,
        sync: SyncStatus.synced,
        lastCheckedAt: checkedAt,
        lastOnlineAt: checkedAt,
        lastTransitionAt: _transitionAt(NetworkAvailability.online, checkedAt),
        lastStableNetwork: NetworkAvailability.online,
        consecutiveSuccesses: _consecutiveSuccesses,
        consecutiveFailures: _consecutiveFailures,
        services: services,
      ),
      hadIssue: false,
      clearLastMessage: true,
      toastId: showToast ? state.toastId + 1 : state.toastId,
      toastMessage: showToast ? ApexCopy.backOnline : null,
    );
  }

  void _markNetworkUnstable({required DateTime checkedAt}) {
    state = state.copyWith(
      snapshot: state.snapshot.copyWith(
        network: NetworkAvailability.unstable,
        sync: SyncStatus.failed,
        lastCheckedAt: checkedAt,
        consecutiveSuccesses: _consecutiveSuccesses,
        consecutiveFailures: _consecutiveFailures,
      ),
      toastId: state.toastId,
    );
  }

  void _markRecoveryPending({required DateTime checkedAt}) {
    state = state.copyWith(
      snapshot: state.snapshot.copyWith(
        sync: SyncStatus.checking,
        lastCheckedAt: checkedAt,
        consecutiveSuccesses: _consecutiveSuccesses,
        consecutiveFailures: _consecutiveFailures,
      ),
      toastId: state.toastId,
    );
  }

  void _markNetworkOffline({
    required DateTime checkedAt,
    NetworkAvailability network = NetworkAvailability.offline,
    required String message,
    String? detail,
    required bool notify,
  }) {
    if (_consecutiveFailures < failureThreshold) {
      _consecutiveFailures = failureThreshold;
    }
    _consecutiveSuccesses = 0;
    final wasBlocked = state.isNetworkBlocked;
    final showToast =
        notify && !wasBlocked && _canEmitToast(message, checkedAt);
    state = state.copyWith(
      snapshot: state.snapshot.copyWith(
        network: network,
        sync: SyncStatus.failed,
        lastCheckedAt: checkedAt,
        lastOfflineAt: checkedAt,
        lastTransitionAt: _transitionAt(network, checkedAt),
        lastStableNetwork: network,
        consecutiveSuccesses: _consecutiveSuccesses,
        consecutiveFailures: _consecutiveFailures,
      ),
      hadIssue: true,
      lastMessage: message,
      toastId: showToast ? state.toastId + 1 : state.toastId,
      toastMessage: showToast ? message : null,
      toastDetail: showToast ? detail : null,
    );
  }

  bool _canEmitToast(String message, DateTime now) {
    final lastAt = _lastToastAt;
    if (_lastToastMessage == message &&
        lastAt != null &&
        now.difference(lastAt) < toastCooldown) {
      return false;
    }
    _lastToastMessage = message;
    _lastToastAt = now;
    return true;
  }

  DateTime? _transitionAt(NetworkAvailability next, DateTime checkedAt) {
    return state.snapshot.network == next
        ? state.snapshot.lastTransitionAt
        : checkedAt;
  }

  String _serviceFailureCopy(
    ServiceHealthService health,
    AppService service,
    ServiceAvailability availability,
  ) {
    return switch (availability) {
      ServiceAvailability.timeout => ApexCopy.tryAgain,
      ServiceAvailability.available => ApexCopy.synced,
      ServiceAvailability.unknown ||
      ServiceAvailability.unavailable ||
      ServiceAvailability.rateLimited => health.unavailableCopy(service),
    };
  }
}

final connectionPresenceProvider =
    NotifierProvider<ConnectionPresenceController, ApexConnectionPresence>(
      ConnectionPresenceController.new,
    );
