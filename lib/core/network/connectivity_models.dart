/// App-wide connectivity and service-health state.
library;

enum NetworkAvailability {
  unknown,
  online,
  unstable,
  offline,
  captiveOrBlocked,
}

enum ServiceAvailability {
  unknown,
  available,
  unavailable,
  rateLimited,
  timeout,
}

enum SyncStatus { idle, checking, syncing, synced, failed }

enum AppService { chessCom, lichess, apexBackend }

class ConnectivitySnapshot {
  const ConnectivitySnapshot({
    this.network = NetworkAvailability.unknown,
    this.services = const <AppService, ServiceAvailability>{},
    this.sync = SyncStatus.idle,
    this.lastCheckedAt,
    this.lastOnlineAt,
    this.lastOfflineAt,
    this.lastTransitionAt,
    this.lastStableNetwork,
    this.consecutiveSuccesses = 0,
    this.consecutiveFailures = 0,
    this.hasUsableCachedData = false,
  });

  final NetworkAvailability network;
  final Map<AppService, ServiceAvailability> services;
  final SyncStatus sync;
  final DateTime? lastCheckedAt;
  final DateTime? lastOnlineAt;
  final DateTime? lastOfflineAt;
  final DateTime? lastTransitionAt;
  final NetworkAvailability? lastStableNetwork;
  final int consecutiveSuccesses;
  final int consecutiveFailures;
  final bool hasUsableCachedData;

  bool get isOnline => network == NetworkAvailability.online;
  bool get isOffline => network == NetworkAvailability.offline;
  bool get isUnstable => network == NetworkAvailability.unstable;
  bool get isCaptiveOrBlocked =>
      network == NetworkAvailability.captiveOrBlocked;
  bool get isChecking =>
      sync == SyncStatus.checking || sync == SyncStatus.syncing;

  bool get hasServiceIssue => services.values.any(
    (status) =>
        status == ServiceAvailability.unavailable ||
        status == ServiceAvailability.rateLimited ||
        status == ServiceAvailability.timeout,
  );

  ServiceAvailability serviceStatus(AppService service) =>
      services[service] ?? ServiceAvailability.unknown;

  ConnectivitySnapshot copyWith({
    NetworkAvailability? network,
    Map<AppService, ServiceAvailability>? services,
    SyncStatus? sync,
    DateTime? lastCheckedAt,
    DateTime? lastOnlineAt,
    DateTime? lastOfflineAt,
    DateTime? lastTransitionAt,
    NetworkAvailability? lastStableNetwork,
    int? consecutiveSuccesses,
    int? consecutiveFailures,
    bool? hasUsableCachedData,
  }) {
    return ConnectivitySnapshot(
      network: network ?? this.network,
      services: services ?? this.services,
      sync: sync ?? this.sync,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastOnlineAt: lastOnlineAt ?? this.lastOnlineAt,
      lastOfflineAt: lastOfflineAt ?? this.lastOfflineAt,
      lastTransitionAt: lastTransitionAt ?? this.lastTransitionAt,
      lastStableNetwork: lastStableNetwork ?? this.lastStableNetwork,
      consecutiveSuccesses: consecutiveSuccesses ?? this.consecutiveSuccesses,
      consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
      hasUsableCachedData: hasUsableCachedData ?? this.hasUsableCachedData,
    );
  }

  ConnectivitySnapshot withService(
    AppService service,
    ServiceAvailability status, {
    NetworkAvailability? network,
    SyncStatus? sync,
    DateTime? checkedAt,
  }) {
    return copyWith(
      network: network,
      sync: sync,
      lastCheckedAt: checkedAt,
      services: <AppService, ServiceAvailability>{...services, service: status},
    );
  }
}
