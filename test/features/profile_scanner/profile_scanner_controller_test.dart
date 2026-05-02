import 'dart:async';

import 'package:apex_chess/features/profile_scanner/data/profile_scanner_service.dart';
import 'package:apex_chess/features/profile_scanner/domain/profile_scan_result.dart';
import 'package:apex_chess/features/profile_scanner/presentation/controllers/profile_scanner_controller.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/recent_searches_controller.dart';
import 'package:apex_chess/core/network/connectivity_models.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'Opponent Insights cancel stops loading and ignores late result',
    () async {
      final service = _SlowScannerService();
      final container = ProviderContainer(
        overrides: [
          profileScannerServiceProvider.overrideWithValue(service),
          connectionReachabilityProbeProvider.overrideWithValue(
            () async => NetworkAvailability.online,
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        profileScannerControllerProvider.notifier,
      );
      final scanFuture = controller.scan(
        username: 'ApexUser',
        source: 'chess.com',
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(profileScannerControllerProvider).isLoading,
        isTrue,
      );

      controller.cancel();
      controller.cancel();
      final cancelled = container.read(profileScannerControllerProvider);
      expect(cancelled.isLoading, isFalse);
      expect(cancelled.wasCancelled, isTrue);
      expect(service.cancellation?.isCancelled, isTrue);

      service.completer.complete(_result());
      await scanFuture;

      final afterLateResult = container.read(profileScannerControllerProvider);
      expect(afterLateResult.result, isNull);
      expect(afterLateResult.wasCancelled, isTrue);
      expect(afterLateResult.isLoading, isFalse);
    },
  );

  test(
    'Opponent Insights stores recent search after successful scan',
    () async {
      SharedPreferences.setMockInitialValues({});
      final service = _SlowScannerService();
      final container = ProviderContainer(
        overrides: [
          profileScannerServiceProvider.overrideWithValue(service),
          connectionReachabilityProbeProvider.overrideWithValue(
            () async => NetworkAvailability.online,
          ),
        ],
      );
      addTearDown(container.dispose);

      final scanFuture = container
          .read(profileScannerControllerProvider.notifier)
          .scan(username: 'ApexUser', source: 'chess.com');
      await Future<void>.delayed(Duration.zero);
      service.completer.complete(_result());
      await scanFuture;

      final recents = await container.read(recentSearchesProvider.future);
      expect(recents.chessCom, contains('ApexUser'));
    },
  );
}

ProfileScanResult _result() {
  return const ProfileScanResult(
    username: 'ApexUser',
    source: 'chess.com',
    sampleSize: 1,
    averageAccuracy: 88,
    averageEngineMatchRate: 0.42,
    averageRating: 1500,
    suspicionScore: 10,
    suspicion: SuspicionLevel.clean,
    verdict: 'Typical sample.',
    games: [],
  );
}

class _SlowScannerService implements ProfileScannerService {
  final completer = Completer<ProfileScanResult>();
  ScanCancellation? cancellation;

  @override
  Future<ProfileScanResult> scan({
    required String username,
    required String source,
    int sampleSize = 5,
    int depth = 14,
    ScanCancellation? cancellation,
    void Function(ScanProgress)? onProgress,
  }) {
    this.cancellation = cancellation;
    onProgress?.call(
      const ScanProgress(
        completed: 0,
        total: 1,
        currentPly: 0,
        currentPlyTotal: 1,
        currentGame: 'ApexUser vs RojoHijo',
      ),
    );
    return completer.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
