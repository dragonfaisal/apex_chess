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

class ImportDiscoveryDisplay {
  const ImportDiscoveryDisplay({
    required this.games,
    required this.isFiltering,
    required this.emptyState,
  });

  final List<ImportedGame> games;
  final bool isFiltering;
  final ImportDiscoveryEmptyState emptyState;

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
  }) {
    final normalized = query.trim();
    final isFiltering = normalized.isNotEmpty;
    if (!state.hasFetched) {
      return const ImportDiscoveryDisplay(
        games: [],
        isFiltering: false,
        emptyState: ImportDiscoveryEmptyState.notFetched,
      );
    }
    if (state.games.isEmpty) {
      return const ImportDiscoveryDisplay(
        games: [],
        isFiltering: false,
        emptyState: ImportDiscoveryEmptyState.noGames,
      );
    }
    if (!isFiltering) {
      return ImportDiscoveryDisplay(
        games: state.games,
        isFiltering: false,
        emptyState: ImportDiscoveryEmptyState.none,
      );
    }

    final ranked =
        [
          for (final game in state.games)
            if (game.localFilterRank(normalized) !=
                ImportedGameDiscoveryIndex.noLocalFilterMatch)
              MapEntry(game.localFilterRank(normalized), game),
        ]..sort((a, b) {
          final score = a.key.compareTo(b.key);
          if (score != 0) return score;
          return b.value.playedAt.compareTo(a.value.playedAt);
        });
    final matches = ranked.map((entry) => entry.value).toList(growable: false);
    if (matches.isNotEmpty) {
      return ImportDiscoveryDisplay(
        games: matches,
        isFiltering: true,
        emptyState: ImportDiscoveryEmptyState.none,
      );
    }
    if (state.isLoadingMore) {
      return const ImportDiscoveryDisplay(
        games: [],
        isFiltering: true,
        emptyState: ImportDiscoveryEmptyState.searchingOlderGames,
      );
    }
    if (state.hasMore) {
      return const ImportDiscoveryDisplay(
        games: [],
        isFiltering: true,
        emptyState: ImportDiscoveryEmptyState.noLocalMatchCanSearchOlder,
      );
    }
    return const ImportDiscoveryDisplay(
      games: [],
      isFiltering: true,
      emptyState: ImportDiscoveryEmptyState.noMatchingGames,
    );
  }
}

extension ImportedGameDiscoveryIndex on ImportedGame {
  static const int noLocalFilterMatch = 1 << 30;

  int localFilterRank(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return 0;
    final fields = <_DiscoveryField>[
      _DiscoveryField(opponentName, 0),
      _DiscoveryField(whiteName, 4),
      _DiscoveryField(blackName, 4),
      _DiscoveryField(eco, 8),
      _DiscoveryField(openingName, 10),
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

class _DiscoveryField {
  const _DiscoveryField(this.value, this.weight);

  final String? value;
  final int weight;
}
