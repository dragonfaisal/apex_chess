/// Riverpod controller for the Apex Opponent Forensics screen.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/profile_scanner_service.dart';
import '../../domain/profile_scan_result.dart';

class ProfileScannerState {
  final bool isLoading;
  final String? error;
  final ProfileScanResult? result;

  const ProfileScannerState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  ProfileScannerState copyWith({
    bool? isLoading,
    String? error,
    ProfileScanResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) =>
      ProfileScannerState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        result: clearResult ? null : (result ?? this.result),
      );
}

final profileScannerServiceProvider =
    Provider<ProfileScannerService>((_) => ProfileScannerService());

class ProfileScannerController extends Notifier<ProfileScannerState> {
  @override
  ProfileScannerState build() => const ProfileScannerState();

  Future<void> scan({
    required String username,
    required String source,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearResult: true,
    );
    try {
      final svc = ref.read(profileScannerServiceProvider);
      final result = await svc.scan(username: username, source: source);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Scan failed: $e',
      );
    }
  }

  void reset() => state = const ProfileScannerState();
}

final profileScannerControllerProvider =
    NotifierProvider<ProfileScannerController, ProfileScannerState>(
  ProfileScannerController.new,
);
