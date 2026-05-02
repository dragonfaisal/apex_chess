/// Classifies provider-specific failures without changing global network state.
library;

import 'package:apex_chess/core/network/connectivity_models.dart';
import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/features/profile_stats/data/profile_stats_service.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';

class ServiceHealthService {
  const ServiceHealthService();

  AppService serviceForGameSource(GameSource source) {
    return switch (source) {
      GameSource.chessCom => AppService.chessCom,
      GameSource.lichess => AppService.lichess,
    };
  }

  AppService serviceForProfileSource(ProfileStatsSource source) {
    return switch (source) {
      ProfileStatsSource.chessCom => AppService.chessCom,
      ProfileStatsSource.lichess => AppService.lichess,
    };
  }

  bool isServiceFailureMessage(String message) {
    final m = message.toLowerCase();
    return m.contains('could not reach') ||
        m.contains('took too long') ||
        m.contains('timed out') ||
        m.contains('timeout') ||
        m.contains('rate-limiting') ||
        m.contains('rate limit') ||
        m.contains('responded unexpectedly') ||
        m.contains('endpoint returned') ||
        m.contains('unavailable') ||
        m.contains('returned 5') ||
        m.contains('returned 4');
  }

  ServiceAvailability availabilityForMessage(String message) {
    final m = message.toLowerCase();
    if (m.contains('rate-limiting') || m.contains('rate limit')) {
      return ServiceAvailability.rateLimited;
    }
    if (m.contains('took too long') ||
        m.contains('timed out') ||
        m.contains('timeout')) {
      return ServiceAvailability.timeout;
    }
    return ServiceAvailability.unavailable;
  }

  String unavailableCopy(AppService service) {
    return switch (service) {
      AppService.chessCom => ApexCopy.chessComUnavailable,
      AppService.lichess => ApexCopy.lichessUnavailable,
      AppService.apexBackend => ApexCopy.profileUnavailable,
    };
  }
}
