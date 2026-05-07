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
    ImportDiscoveryEmptyState.noLocalMatchCanSearchOlder => 'No games found',
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
    return _bestLocalFilterMatch(
          query,
          connectedHandle: connectedHandle,
        )?.rank ??
        noLocalFilterMatch;
  }

  String? localFilterMatchLabel(String query, {String? connectedHandle}) {
    return _bestLocalFilterMatch(
      query,
      connectedHandle: connectedHandle,
    )?.label;
  }

  _LocalFilterMatch? _bestLocalFilterMatch(
    String query, {
    String? connectedHandle,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const _LocalFilterMatch(rank: 0);
    final fields = <_DiscoveryField>[
      _DiscoveryField(opponentName, 0, 'Opponent match'),
      _DiscoveryField(whiteName, 4, 'Player match'),
      _DiscoveryField(blackName, 4, 'Player match'),
      _DiscoveryField(connectedHandle, 6, 'Player match'),
      _DiscoveryField(eco, 10, 'ECO match'),
      _DiscoveryField(openingName, 12, 'Opening match'),
      _DiscoveryField(userOutcomeLabel, 14, 'Result match'),
      _DiscoveryField(sourceLabel, 18, 'Source match'),
      _DiscoveryField(timeControl, 20, 'Time match'),
      _DiscoveryField('$moveCount moves', 22, 'Move count match'),
      _DiscoveryField(moveCount.toString(), 24, 'Move count match'),
      _DiscoveryField(relativeTime, 26, 'Date match'),
      _DiscoveryField(playedAt.toIso8601String(), 28, 'Date match'),
    ];
    _LocalFilterMatch? best;
    for (final field in fields) {
      final value = field.value?.trim().toLowerCase();
      if (value == null || value.isEmpty) continue;
      if (value == q) {
        final match = _LocalFilterMatch(rank: field.weight, label: field.label);
        best = _betterMatch(best, match);
      } else if (value.startsWith(q)) {
        final match = _LocalFilterMatch(
          rank: field.weight + 1,
          label: field.label,
        );
        best = _betterMatch(best, match);
      } else if (value.contains(q)) {
        final match = _LocalFilterMatch(
          rank: field.weight + 3,
          label: field.label,
        );
        best = _betterMatch(best, match);
      }
    }
    return best;
  }
}

_LocalFilterMatch? _betterMatch(
  _LocalFilterMatch? current,
  _LocalFilterMatch candidate,
) {
  if (current == null) return candidate;
  return current.rank <= candidate.rank ? current : candidate;
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
  const _DiscoveryField(this.value, this.weight, this.label);

  final String? value;
  final int weight;
  final String label;
}

class _LocalFilterMatch {
  const _LocalFilterMatch({required this.rank, this.label});

  final int rank;
  final String? label;
}
