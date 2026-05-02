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

enum ApexConnectionStatus { online, offline, syncing }

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
    if (snapshot.isChecking ||
        snapshot.network == NetworkAvailability.unknown) {
      return ApexConnectionStatus.syncing;
    }
    if (snapshot.network == NetworkAvailability.offline ||
        snapshot.network == NetworkAvailability.captive) {
      return ApexConnectionStatus.offline;
    }
    return ApexConnectionStatus.online;
  }

  bool get isOffline => status == ApexConnectionStatus.offline;
  bool get isSyncing => status == ApexConnectionStatus.syncing;
  bool get hasServiceIssue =>
      snapshot.network == NetworkAvailability.online &&
      snapshot.hasServiceIssue;

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

  Timer? _timer;
  Future<void>? _activeCheck;

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
    return state.snapshot.network == NetworkAvailability.online;
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
    if (state.snapshot.network != NetworkAvailability.online) {
      markOffline(
        ApexCopy.offline,
        detail: state.snapshot.hasUsableCachedData
            ? ApexCopy.showingSavedData
            : null,
        notify: notify,
      );
      return ApexCopy.offline;
    }
    markServiceStatus(
      service,
      resolvedAvailability,
      message: health.unavailableCopy(service),
      notify: notify,
    );
    return health.unavailableCopy(service);
  }

  Future<void> _runReachabilityCheck({required bool notify}) async {
    final previous = state.snapshot.network;
    final checkedAt = DateTime.now();
    final network = await ref.read(connectionReachabilityProbeProvider)();
    if (network == NetworkAvailability.online) {
      _markNetworkOnline(
        checkedAt: checkedAt,
        notify: notify && previous == NetworkAvailability.offline,
      );
      return;
    }
    if (network == NetworkAvailability.captive) {
      _markNetworkOffline(
        checkedAt: checkedAt,
        network: NetworkAvailability.captive,
        message: ApexCopy.noConnection,
        notify: notify && previous != NetworkAvailability.captive,
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
    final wasOffline = state.snapshot.network == NetworkAvailability.offline;
    final snapshot = state.snapshot
        .withService(
          service,
          ServiceAvailability.available,
          network: NetworkAvailability.online,
          sync: SyncStatus.synced,
          checkedAt: checkedAt,
        )
        .copyWith(lastOnlineAt: checkedAt);
    state = state.copyWith(
      snapshot: snapshot,
      hadIssue: false,
      clearLastMessage: true,
      toastId: notify && wasOffline ? state.toastId + 1 : state.toastId,
      toastMessage: notify && wasOffline ? ApexCopy.backOnline : null,
    );
  }

  void markServiceStatus(
    AppService service,
    ServiceAvailability availability, {
    String? message,
    bool notify = false,
  }) {
    final checkedAt = DateTime.now();
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
        .copyWith(lastOnlineAt: checkedAt);
    state = state.copyWith(
      snapshot: snapshot,
      hadIssue: false,
      lastMessage: message,
      toastId: notify && message != null ? state.toastId + 1 : state.toastId,
      toastMessage: notify ? message : null,
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
    final wasOffline = state.snapshot.network == NetworkAvailability.offline;
    _markNetworkOnline(checkedAt: DateTime.now(), notify: notify && wasOffline);
    return wasOffline;
  }

  void _markNetworkOnline({required DateTime checkedAt, required bool notify}) {
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
        services: services,
      ),
      hadIssue: false,
      clearLastMessage: true,
      toastId: notify ? state.toastId + 1 : state.toastId,
      toastMessage: notify ? ApexCopy.backOnline : null,
    );
  }

  void _markNetworkOffline({
    required DateTime checkedAt,
    NetworkAvailability network = NetworkAvailability.offline,
    required String message,
    String? detail,
    required bool notify,
  }) {
    final wasOffline = state.snapshot.network == NetworkAvailability.offline;
    state = state.copyWith(
      snapshot: state.snapshot.copyWith(
        network: network,
        sync: SyncStatus.failed,
        lastCheckedAt: checkedAt,
        lastOfflineAt: checkedAt,
      ),
      hadIssue: true,
      lastMessage: message,
      toastId: notify && !wasOffline ? state.toastId + 1 : state.toastId,
      toastMessage: notify && !wasOffline ? message : null,
      toastDetail: notify && !wasOffline ? detail : null,
    );
  }
}

final connectionPresenceProvider =
    NotifierProvider<ConnectionPresenceController, ApexConnectionPresence>(
      ConnectionPresenceController.new,
    );
