/// App-wide connectivity and service-health state.
library;

enum NetworkAvailability { unknown, online, offline, captive }

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
    this.hasUsableCachedData = false,
  });

  final NetworkAvailability network;
  final Map<AppService, ServiceAvailability> services;
  final SyncStatus sync;
  final DateTime? lastCheckedAt;
  final DateTime? lastOnlineAt;
  final DateTime? lastOfflineAt;
  final bool hasUsableCachedData;

  bool get isOnline => network == NetworkAvailability.online;
  bool get isOffline => network == NetworkAvailability.offline;
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
    bool? hasUsableCachedData,
  }) {
    return ConnectivitySnapshot(
      network: network ?? this.network,
      services: services ?? this.services,
      sync: sync ?? this.sync,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastOnlineAt: lastOnlineAt ?? this.lastOnlineAt,
      lastOfflineAt: lastOfflineAt ?? this.lastOfflineAt,
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
