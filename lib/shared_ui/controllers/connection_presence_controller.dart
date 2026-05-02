/// UI-only connection presence for small status dots and snackbars.
///
/// This is deliberately lightweight: screens mark failed/successful fetches,
/// and the shell reflects that state. It is not a network monitor.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ApexConnectionStatus { online, offline, syncing }

class ApexConnectionPresence {
  const ApexConnectionPresence({
    this.status = ApexConnectionStatus.online,
    this.hadIssue = false,
    this.lastMessage,
  });

  final ApexConnectionStatus status;
  final bool hadIssue;
  final String? lastMessage;

  bool get isOffline => status == ApexConnectionStatus.offline;
  bool get isSyncing => status == ApexConnectionStatus.syncing;

  ApexConnectionPresence copyWith({
    ApexConnectionStatus? status,
    bool? hadIssue,
    String? lastMessage,
  }) {
    return ApexConnectionPresence(
      status: status ?? this.status,
      hadIssue: hadIssue ?? this.hadIssue,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}

class ConnectionPresenceController extends Notifier<ApexConnectionPresence> {
  @override
  ApexConnectionPresence build() => const ApexConnectionPresence();

  void markSyncing() {
    if (state.isOffline) return;
    state = state.copyWith(status: ApexConnectionStatus.syncing);
  }

  void markOffline([String? message]) {
    if (state.isOffline && state.lastMessage == message) return;
    state = ApexConnectionPresence(
      status: ApexConnectionStatus.offline,
      hadIssue: true,
      lastMessage: message,
    );
  }

  /// Returns true when callers should show a one-shot recovery message.
  bool markSynced() {
    final shouldNotify = state.hadIssue || state.isOffline;
    state = const ApexConnectionPresence(
      status: ApexConnectionStatus.online,
      hadIssue: false,
    );
    return shouldNotify;
  }
}

final connectionPresenceProvider =
    NotifierProvider<ConnectionPresenceController, ApexConnectionPresence>(
      ConnectionPresenceController.new,
    );
