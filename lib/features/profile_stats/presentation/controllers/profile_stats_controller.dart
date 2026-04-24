/// Reactive provider layer for [ProfileStatsService].
///
/// The Grandmaster Analytics dashboard reads
/// [liveProfileStatsProvider] to paint the Profile Stats card; it
/// resolves automatically once the active [AccountController] has a
/// verified handle + source, and re-fires whenever the user switches
/// account.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/features/account/domain/apex_account.dart';
import 'package:apex_chess/features/account/presentation/controllers/account_controller.dart';
import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';

/// Singleton [ProfileStatsService] — cheap HTTP client we keep warm.
final profileStatsServiceProvider =
    Provider<ProfileStatsService>((ref) {
  final service = ProfileStatsService();
  ref.onDispose(service.dispose);
  return service;
});

/// Live stats for the active account, or `null` if no handle is
/// verified yet. Returns [ProfileStats.unknown] on network failure so
/// the UI can render a "no live data yet" state without throwing.
final liveProfileStatsProvider = FutureProvider<ProfileStats?>((ref) async {
  final account = ref.watch(accountControllerProvider).valueOrNull;
  if (account == null || account.username.isEmpty) return null;
  final service = ref.watch(profileStatsServiceProvider);
  final source = switch (account.source) {
    AccountSource.chessCom => ProfileStatsSource.chessCom,
    AccountSource.lichess => ProfileStatsSource.lichess,
  };
  return service.fetch(source: source, username: account.username);
});
