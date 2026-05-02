/// UI-only connection presence for small status dots and glass toasts.
///
/// This is deliberately lightweight: screens still mark failed/successful
/// fetches, and this controller adds a small reachability probe so the shell
/// can react while the app is open. It does not own any backend behavior.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/shared_ui/copy/apex_copy.dart';

enum ApexConnectionStatus { online, offline, syncing }

class ApexConnectionPresence {
  const ApexConnectionPresence({
    this.status = ApexConnectionStatus.online,
    this.hadIssue = false,
    this.lastMessage,
    this.toastId = 0,
    this.toastMessage,
    this.toastDetail,
  });

  final ApexConnectionStatus status;
  final bool hadIssue;
  final String? lastMessage;
  final int toastId;
  final String? toastMessage;
  final String? toastDetail;

  bool get isOffline => status == ApexConnectionStatus.offline;
  bool get isSyncing => status == ApexConnectionStatus.syncing;

  ApexConnectionPresence copyWith({
    ApexConnectionStatus? status,
    bool? hadIssue,
    String? lastMessage,
    int? toastId,
    String? toastMessage,
    String? toastDetail,
  }) {
    return ApexConnectionPresence(
      status: status ?? this.status,
      hadIssue: hadIssue ?? this.hadIssue,
      lastMessage: lastMessage ?? this.lastMessage,
      toastId: toastId ?? this.toastId,
      toastMessage: toastMessage ?? this.toastMessage,
      toastDetail: toastDetail ?? this.toastDetail,
    );
  }
}

typedef ConnectionReachabilityProbe = Future<bool> Function();

Future<bool> _defaultReachabilityProbe() async {
  try {
    final result = await InternetAddress.lookup(
      'one.one.one.one',
    ).timeout(const Duration(seconds: 2));
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

final connectionReachabilityProbeProvider =
    Provider<ConnectionReachabilityProbe>((_) => _defaultReachabilityProbe);

class ConnectionPresenceController extends Notifier<ApexConnectionPresence> {
  static const pollInterval = Duration(seconds: 5);

  Timer? _timer;
  bool _checking = false;

  @override
  ApexConnectionPresence build() {
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) {
      unawaited(refresh(notify: true));
    });
    ref.onDispose(() => _timer?.cancel());
    unawaited(refresh(notify: false));
    return const ApexConnectionPresence();
  }

  Future<void> refresh({bool notify = true}) async {
    if (_checking) return;
    _checking = true;
    try {
      final online = await ref.read(connectionReachabilityProbeProvider)();
      if (online) {
        markSynced(notify: notify);
      } else {
        markOffline(
          ApexCopy.offline,
          detail: ApexCopy.showingSavedData,
          notify: notify,
        );
      }
    } finally {
      _checking = false;
    }
  }

  void markSyncing() {
    if (state.isOffline) return;
    state = state.copyWith(status: ApexConnectionStatus.syncing);
  }

  void markOffline(String? message, {String? detail, bool notify = false}) {
    final wasOffline = state.isOffline;
    if (wasOffline && state.lastMessage == message && !notify) return;
    final shouldNotify = notify && !wasOffline;
    state = ApexConnectionPresence(
      status: ApexConnectionStatus.offline,
      hadIssue: true,
      lastMessage: message,
      toastId: shouldNotify ? state.toastId + 1 : state.toastId,
      toastMessage: shouldNotify ? (message ?? ApexCopy.noConnection) : null,
      toastDetail: shouldNotify ? detail : null,
    );
  }

  /// Returns true when callers should show a one-shot recovery message.
  bool markSynced({bool notify = false}) {
    final shouldNotify = state.hadIssue || state.isOffline;
    state =
        const ApexConnectionPresence(
          status: ApexConnectionStatus.online,
          hadIssue: false,
        ).copyWith(
          toastId: notify && shouldNotify ? state.toastId + 1 : state.toastId,
          toastMessage: notify && shouldNotify ? ApexCopy.backOnline : null,
        );
    return shouldNotify;
  }
}

final connectionPresenceProvider =
    NotifierProvider<ConnectionPresenceController, ApexConnectionPresence>(
      ConnectionPresenceController.new,
    );
