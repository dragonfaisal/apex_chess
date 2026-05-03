/// Display logic for Import Games discovery filtering.
library;

import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/import_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';

enum ImportDiscoveryEmptyState {
  none,
  notFetched,
  noGames,
  noLocalMatchCanSearchOlder,
  searchingOlderGames,
  noMatchingGames,
}

enum ImportDiscoveryStatus {
  idle,
  searching,
  searchingOlderGames,
  foundLocalMatches,
  foundOlderMatches,
  noMatchingGames,
  serviceUnavailable,
}

class ImportDiscoveryDisplay {
  const ImportDiscoveryDisplay({
    required this.games,
    required this.isFiltering,
    required this.emptyState,
    required this.status,
  });

  final List<ImportedGame> games;
  final bool isFiltering;
  final ImportDiscoveryEmptyState emptyState;
  final ImportDiscoveryStatus status;

  bool get showSearchOlderAction =>
      emptyState == ImportDiscoveryEmptyState.noLocalMatchCanSearchOlder;

  bool get showSearchingOlder =>
      emptyState == ImportDiscoveryEmptyState.searchingOlderGames;

  String get emptyLabel => switch (emptyState) {
    ImportDiscoveryEmptyState.notFetched =>
      'Search a player to show recent games.',
    ImportDiscoveryEmptyState.noGames => ApexCopy.importEmpty,
    ImportDiscoveryEmptyState.noLocalMatchCanSearchOlder => 'No local match',
    ImportDiscoveryEmptyState.searchingOlderGames =>
      ApexCopy.searchingOlderGames,
    ImportDiscoveryEmptyState.noMatchingGames => ApexCopy.noMatchingGames,
    ImportDiscoveryEmptyState.none => '',
  };

  static ImportDiscoveryDisplay from({
    required ImportState state,
    required String query,
    int? searchBaselineCount,
  }) {
    final normalized = query.trim();
    final isFiltering = normalized.isNotEmpty;
    if (state.errorMessage != null && state.games.isEmpty) {
      return const ImportDiscoveryDisplay(
        games: [],
        isFiltering: false,
        emptyState: ImportDiscoveryEmptyState.noGames,
        status: ImportDiscoveryStatus.serviceUnavailable,
      );
    }
    if (state.isLoading) {
      return const ImportDiscoveryDisplay(
        games: [],
        isFiltering: false,
        emptyState: ImportDiscoveryEmptyState.none,
        status: ImportDiscoveryStatus.searching,
      );
    }
    if (!state.hasFetched) {
      return const ImportDiscoveryDisplay(
        games: [],
        isFiltering: false,
        emptyState: ImportDiscoveryEmptyState.notFetched,
        status: ImportDiscoveryStatus.idle,
      );
    }
    if (state.games.isEmpty) {
      return const ImportDiscoveryDisplay(
        games: [],
        isFiltering: false,
        emptyState: ImportDiscoveryEmptyState.noGames,
        status: ImportDiscoveryStatus.noMatchingGames,
      );
    }
    if (!isFiltering) {
      return ImportDiscoveryDisplay(
        games: state.games,
        isFiltering: false,
        emptyState: ImportDiscoveryEmptyState.none,
        status: ImportDiscoveryStatus.idle,
      );
    }

    final ranked =
        [
          for (var i = 0; i < state.games.length; i++)
            if (state.games[i].localFilterRank(
                  normalized,
                  connectedHandle: state.username,
                ) !=
                ImportedGameDiscoveryIndex.noLocalFilterMatch)
              _RankedGame(
                rank: state.games[i].localFilterRank(
                  normalized,
                  connectedHandle: state.username,
                ),
                index: i,
                game: state.games[i],
              ),
        ]..sort((a, b) {
          final score = a.rank.compareTo(b.rank);
          if (score != 0) return score;
          return b.game.playedAt.compareTo(a.game.playedAt);
        });
    final matches = ranked.map((entry) => entry.game).toList(growable: false);
    if (matches.isNotEmpty) {
      final baseline = searchBaselineCount ?? state.games.length;
      final foundOlder = ranked.any((entry) => entry.index >= baseline);
      return ImportDiscoveryDisplay(
        games: matches,
        isFiltering: true,
        emptyState: ImportDiscoveryEmptyState.none,
        status: foundOlder
            ? ImportDiscoveryStatus.foundOlderMatches
            : ImportDiscoveryStatus.foundLocalMatches,
      );
    }
    if (state.isLoadingMore) {
      return const ImportDiscoveryDisplay(
        games: [],
        isFiltering: true,
        emptyState: ImportDiscoveryEmptyState.searchingOlderGames,
        status: ImportDiscoveryStatus.searchingOlderGames,
      );
    }
    if (state.hasMore) {
      return const ImportDiscoveryDisplay(
        games: [],
        isFiltering: true,
        emptyState: ImportDiscoveryEmptyState.noLocalMatchCanSearchOlder,
        status: ImportDiscoveryStatus.searching,
      );
    }
    return const ImportDiscoveryDisplay(
      games: [],
      isFiltering: true,
      emptyState: ImportDiscoveryEmptyState.noMatchingGames,
      status: ImportDiscoveryStatus.noMatchingGames,
    );
  }
}

extension ImportedGameDiscoveryIndex on ImportedGame {
  static const int noLocalFilterMatch = 1 << 30;

  int localFilterRank(String query, {String? connectedHandle}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return 0;
    final fields = <_DiscoveryField>[
      _DiscoveryField(opponentName, 0),
      _DiscoveryField(whiteName, 4),
      _DiscoveryField(blackName, 4),
      _DiscoveryField(connectedHandle, 6),
      _DiscoveryField(eco, 10),
      _DiscoveryField(openingName, 12),
      _DiscoveryField(userOutcomeLabel, 14),
      _DiscoveryField(sourceLabel, 18),
      _DiscoveryField(timeControl, 20),
      _DiscoveryField('$moveCount moves', 22),
      _DiscoveryField(moveCount.toString(), 24),
      _DiscoveryField(relativeTime, 26),
      _DiscoveryField(playedAt.toIso8601String(), 28),
    ];
    var best = noLocalFilterMatch;
    for (final field in fields) {
      final value = field.value?.trim().toLowerCase();
      if (value == null || value.isEmpty) continue;
      if (value == q) {
        best = best < field.weight ? best : field.weight;
      } else if (value.startsWith(q)) {
        final score = field.weight + 1;
        best = best < score ? best : score;
      } else if (value.contains(q)) {
        final score = field.weight + 3;
        best = best < score ? best : score;
      }
    }
    return best;
  }
}

class _RankedGame {
  const _RankedGame({
    required this.rank,
    required this.index,
    required this.game,
  });

  final int rank;
  final int index;
  final ImportedGame game;
}

class _DiscoveryField {
  const _DiscoveryField(this.value, this.weight);

  final String? value;
  final int weight;
}
