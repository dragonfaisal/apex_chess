/// Riverpod controller for the Opponent Insights screen.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/features/import_match/domain/imported_game.dart'
    show GameSource, ImportException;
import 'package:apex_chess/features/import_match/presentation/controllers/import_controller.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/recent_searches_controller.dart';
import 'package:apex_chess/shared_ui/controllers/connection_presence_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';

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
  }) => ProfileScannerState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    result: clearResult ? null : (result ?? this.result),
    progress: clearProgress ? null : (progress ?? this.progress),
    wasCancelled: wasCancelled ?? this.wasCancelled,
  );
}

final profileScannerServiceProvider = Provider<ProfileScannerService>(
  (ref) => ProfileScannerService(
    chessCom: ref.read(chessComRepositoryProvider),
    lichess: ref.read(lichessRepositoryProvider),
    // Forensics fans out to dozens of opponent games at once, so
    // we burn local Stockfish CPU instead of hammering Lichess
    // Cloud Eval (which would rate-limit the user-facing review).
    analyzer: ref.read(localGameAnalyzerProvider),
  ),
);

class ProfileScannerController extends Notifier<ProfileScannerState> {
  ScanCancellation? _cancellation;
  int _generation = 0;

  @override
  ProfileScannerState build() => const ProfileScannerState();

  Future<void> scan({
    required String username,
    required String source,
    int sampleSize = 5,
  }) async {
    final gen = ++_generation;
    final cancellation = ScanCancellation();
    _cancellation = cancellation;
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
        cancellation: cancellation,
        onProgress: (p) {
          if (gen != _generation || cancellation.isCancelled) return;
          state = state.copyWith(progress: p);
        },
      );
      if (gen != _generation || cancellation.isCancelled) return;
      await ref
          .read(recentSearchesProvider.notifier)
          .record(_gameSourceFor(source), username);
      ref.read(connectionPresenceProvider.notifier).markSynced();
      state = state.copyWith(
        isLoading: false,
        result: result,
        clearProgress: true,
      );
    } on ScanCancelledException {
      if (gen != _generation) return;
      state = state.copyWith(
        isLoading: false,
        wasCancelled: true,
        clearProgress: true,
      );
    } on ImportException catch (e) {
      if (gen != _generation || cancellation.isCancelled) return;
      // Show the human-friendly message the repository already
      // tailored, not Dart's `Exception: ...` toString().
      final connectionIssue = _looksLikeConnectionIssue(e.userMessage);
      if (connectionIssue) {
        ref
            .read(connectionPresenceProvider.notifier)
            .markOffline(ApexCopy.noConnection);
      }
      state = state.copyWith(
        isLoading: false,
        error: connectionIssue ? ApexCopy.noConnection : e.userMessage,
        clearProgress: true,
      );
    } catch (e) {
      if (gen != _generation || cancellation.isCancelled) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Scan failed: $e',
        clearProgress: true,
      );
    } finally {
      if (gen == _generation) {
        _cancellation = null;
      }
    }
  }

  void cancel() {
    _cancellation?.cancel();
    _cancellation = null;
    _generation++;
    if (!state.isLoading) {
      state = state.copyWith(wasCancelled: true, clearProgress: true);
      return;
    }
    state = state.copyWith(
      isLoading: false,
      wasCancelled: true,
      clearProgress: true,
    );
  }

  void reset() => state = const ProfileScannerState();
}

bool _looksLikeConnectionIssue(String message) {
  final m = message.toLowerCase();
  return m.contains('could not reach') ||
      m.contains('connection') ||
      m.contains('timed out') ||
      m.contains('network');
}

GameSource _gameSourceFor(String source) {
  return source.trim().toLowerCase() == 'lichess'
      ? GameSource.lichess
      : GameSource.chessCom;
}

final profileScannerControllerProvider =
    NotifierProvider<ProfileScannerController, ProfileScannerState>(
      ProfileScannerController.new,
    );
