/// Riverpod controller for the Import Match screen.
///
/// Holds the username / source selection, the loading / error state, and
/// the list of [ImportedGame]s returned by the active repository.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/features/import_match/data/chess_com_repository.dart';
import 'package:apex_chess/features/import_match/data/lichess_repository.dart';
import 'package:apex_chess/features/import_match/domain/imported_game.dart';

final chessComRepositoryProvider = Provider<ChessComRepository>((ref) {
  final repo = ChessComRepository();
  ref.onDispose(() {});
  return repo;
});

final lichessRepositoryProvider = Provider<LichessRepository>((ref) {
  return LichessRepository();
});

class ImportState {
  const ImportState({
    this.source = GameSource.chessCom,
    this.username = '',
    this.games = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasFetched = false,
  });

  final GameSource source;
  final String username;
  final List<ImportedGame> games;
  final bool isLoading;
  final String? errorMessage;
  final bool hasFetched;

  ImportState copyWith({
    GameSource? source,
    String? username,
    List<ImportedGame>? games,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? hasFetched,
  }) {
    return ImportState(
      source: source ?? this.source,
      username: username ?? this.username,
      games: games ?? this.games,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasFetched: hasFetched ?? this.hasFetched,
    );
  }
}

class ImportController extends Notifier<ImportState> {
  @override
  ImportState build() => const ImportState();

  void setSource(GameSource source) {
    state = state.copyWith(source: source);
  }

  void setUsername(String value) {
    state = state.copyWith(username: value, clearError: true);
  }

  Future<void> fetch() async {
    if (state.isLoading) return;
    final user = state.username.trim();
    if (user.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Enter a username first.',
        hasFetched: false,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      games: const [],
      hasFetched: false,
    );

    try {
      final games = switch (state.source) {
        GameSource.chessCom =>
          await ref.read(chessComRepositoryProvider).fetchRecentGames(user),
        GameSource.lichess =>
          await ref.read(lichessRepositoryProvider).fetchRecentGames(user),
      };
      state = state.copyWith(
        games: games,
        isLoading: false,
        hasFetched: true,
        clearError: true,
      );
    } on ImportException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.userMessage,
        hasFetched: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Try again.',
        hasFetched: true,
      );
    }
  }
}

final importControllerProvider =
    NotifierProvider<ImportController, ImportState>(ImportController.new);
