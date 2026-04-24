/// Riverpod controller for the Apex Opponent Forensics screen.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/import_controller.dart';

import '../../data/profile_scanner_service.dart';
import '../../domain/profile_scan_result.dart';

class ProfileScannerState {
  final bool isLoading;
  final String? error;
  final ProfileScanResult? result;
  final ScanProgress? progress;
  final bool wasCancelled;

  const ProfileScannerState({
    this.isLoading = false,
    this.error,
    this.result,
    this.progress,
    this.wasCancelled = false,
  });

  ProfileScannerState copyWith({
    bool? isLoading,
    String? error,
    ProfileScanResult? result,
    ScanProgress? progress,
    bool? wasCancelled,
    bool clearError = false,
    bool clearResult = false,
    bool clearProgress = false,
  }) =>
      ProfileScannerState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        result: clearResult ? null : (result ?? this.result),
        progress: clearProgress ? null : (progress ?? this.progress),
        wasCancelled: wasCancelled ?? this.wasCancelled,
      );
}

final profileScannerServiceProvider =
    Provider<ProfileScannerService>((ref) => ProfileScannerService(
          chessCom: ref.read(chessComRepositoryProvider),
          lichess: ref.read(lichessRepositoryProvider),
          analyzer: ref.read(gameAnalyzerProvider),
        ));

class ProfileScannerController extends Notifier<ProfileScannerState> {
  ScanCancellation? _cancellation;

  @override
  ProfileScannerState build() => const ProfileScannerState();

  Future<void> scan({
    required String username,
    required String source,
    int sampleSize = 5,
  }) async {
    _cancellation = ScanCancellation();
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearResult: true,
      clearProgress: true,
      wasCancelled: false,
    );
    try {
      final svc = ref.read(profileScannerServiceProvider);
      final result = await svc.scan(
        username: username,
        source: source,
        sampleSize: sampleSize,
        cancellation: _cancellation,
        onProgress: (p) {
          // Progress can outlive dispose() — no-op if the notifier
          // has been torn down.
          state = state.copyWith(progress: p);
        },
      );
      state = state.copyWith(
        isLoading: false,
        result: result,
        clearProgress: true,
      );
    } on ScanCancelledException {
      state = state.copyWith(
        isLoading: false,
        wasCancelled: true,
        clearProgress: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Scan failed: $e',
        clearProgress: true,
      );
    } finally {
      _cancellation = null;
    }
  }

  void cancel() {
    _cancellation?.cancel();
  }

  void reset() => state = const ProfileScannerState();
}

final profileScannerControllerProvider =
    NotifierProvider<ProfileScannerController, ProfileScannerState>(
  ProfileScannerController.new,
);
