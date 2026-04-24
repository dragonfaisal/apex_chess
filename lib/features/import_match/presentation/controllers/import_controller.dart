/// Riverpod controller for the Import Match screen.
///
/// Holds the username / source selection, the loading / error state, the
/// paginated list of [ImportedGame]s returned by the active repository,
/// and the pagination cursor.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:apex_chess/features/import_match/data/chess_com_repository.dart';
import 'package:apex_chess/features/import_match/data/lichess_repository.dart';
import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/recent_searches_controller.dart';

// Own the HTTP client at the provider layer so its connection pool is
// closed when the provider is invalidated. Repos take the client via
// constructor injection — they never create their own when run from the
// app (tests can still new one up inline).
final chessComRepositoryProvider = Provider<ChessComRepository>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return ChessComRepository(client: client);
});

final lichessRepositoryProvider = Provider<LichessRepository>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return LichessRepository(client: client);
});

class ImportState {
  const ImportState({
    this.source = GameSource.chessCom,
    this.username = '',
    this.games = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.hasFetched = false,
    this.cursor,
    this.hasMore = false,
  });

  final GameSource source;
  final String username;
  final List<ImportedGame> games;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasFetched;
  final String? cursor;
  final bool hasMore;

  ImportState copyWith({
    GameSource? source,
    String? username,
    List<ImportedGame>? games,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    bool? hasFetched,
    String? cursor,
    bool clearCursor = false,
    bool? hasMore,
  }) {
    return ImportState(
      source: source ?? this.source,
      username: username ?? this.username,
      games: games ?? this.games,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasFetched: hasFetched ?? this.hasFetched,
      cursor: clearCursor ? null : (cursor ?? this.cursor),
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ImportController extends Notifier<ImportState> {
  // Monotonic counter bumped on every `fetch()` and `setSource()` so a
  // long-running `fetchMore()` can detect that its response is stale
  // (the user started a new search, or switched source, mid-flight)
  // and discard the results rather than splicing them into the
  // unrelated new list. Without this guard two distinct profiles'
  // pages would be interleaved and the cursor would be cross-wired
  // between repositories.
  int _generation = 0;

  @override
  ImportState build() => const ImportState();

  void setSource(GameSource source) {
    // Switching source also invalidates any in-flight pagination —
    // the old cursor belongs to the old repository and would be
    // nonsensical to the new one.
    _generation++;
    state = state.copyWith(source: source);
  }

  void setUsername(String value) {
    state = state.copyWith(username: value, clearError: true);
  }

  Future<ImportPage> _fetchPage({String? cursor}) async {
    final user = state.username.trim();
    return switch (state.source) {
      GameSource.chessCom => await ref
          .read(chessComRepositoryProvider)
          .fetchPage(user, cursor: cursor),
      GameSource.lichess => await ref
          .read(lichessRepositoryProvider)
          .fetchPage(user, cursor: cursor),
    };
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

    _generation++;
    state = state.copyWith(
      isLoading: true,
      // Any in-flight fetchMore() is now stale; clear the footer
      // spinner so the UI reflects reality even before that future
      // resolves.
      isLoadingMore: false,
      clearError: true,
      games: const [],
      hasFetched: false,
      clearCursor: true,
      hasMore: false,
    );

    try {
      final page = await _fetchPage();
      state = state.copyWith(
        games: page.games,
        isLoading: false,
        hasFetched: true,
        clearError: true,
        cursor: page.cursor,
        clearCursor: page.cursor == null,
        hasMore: page.cursor != null,
      );
      // Record the successful lookup so the recent-searches dropdown
      // surfaces it next time the user taps the field.
      if (page.games.isNotEmpty) {
        await ref
            .read(recentSearchesProvider.notifier)
            .record(state.source, user);
      }
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

  /// Fetch the next page of games and append them to the existing list.
  /// Silent no-op when already loading, no cursor, or no results yet.
  Future<void> fetchMore() async {
    if (state.isLoading || state.isLoadingMore) return;
    if (!state.hasMore || state.cursor == null) return;

    // Snapshot the generation at call time. If `fetch()` (new search)
    // or `setSource()` (provider switch) runs before our `await`
    // returns, the generation will have advanced and we MUST discard
    // the result — otherwise we'd cross-wire the previous profile's
    // pages and cursor into the new profile's state.
    final gen = _generation;
    state = state.copyWith(isLoadingMore: true, clearError: true);

    try {
      final page = await _fetchPage(cursor: state.cursor);
      if (gen != _generation) return; // stale — a new search superseded us
      // De-dup by id in case an archive boundary repeated a game.
      final existingIds = state.games.map((g) => g.id).toSet();
      final appended = [
        ...state.games,
        ...page.games.where((g) => !existingIds.contains(g.id)),
      ];
      state = state.copyWith(
        games: appended,
        isLoadingMore: false,
        cursor: page.cursor,
        clearCursor: page.cursor == null,
        hasMore: page.cursor != null && page.games.isNotEmpty,
      );
    } on ImportException catch (e) {
      if (gen != _generation) return;
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.userMessage,
      );
    } catch (_) {
      if (gen != _generation) return;
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Could not load more games.',
      );
    }
  }
}

final importControllerProvider =
    NotifierProvider<ImportController, ImportState>(ImportController.new);
