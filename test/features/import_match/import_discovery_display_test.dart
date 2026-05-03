import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/import_controller.dart';
import 'package:apex_chess/features/import_match/presentation/models/import_discovery_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('search finds opponent by partial username across loaded games', () {
    final display = ImportDiscoveryDisplay.from(
      state: ImportState(
        hasFetched: true,
        games: [
          _game(id: '1', blackName: 'FirstOpponent'),
          _game(id: '2', blackName: 'SecondOpponent'),
          _game(id: '3', blackName: 'magnoliachickenhatdog'),
        ],
      ),
      query: 'dog',
    );

    expect(display.games.map((g) => g.id), ['3']);
    expect(display.emptyState, ImportDiscoveryEmptyState.none);
  });

  test('search finds opening name, ECO, and result tone', () {
    final state = ImportState(
      hasFetched: true,
      games: [
        _game(
          id: 'scotch',
          openingName: 'Scotch Game',
          eco: 'C45',
          result: GameResult.blackWon,
          userColor: PlayerColor.white,
        ),
      ],
    );

    expect(
      ImportDiscoveryDisplay.from(
        state: state,
        query: 'scotch',
      ).games.single.id,
      'scotch',
    );
    expect(
      ImportDiscoveryDisplay.from(state: state, query: 'c45').games.single.id,
      'scotch',
    );
    expect(
      ImportDiscoveryDisplay.from(state: state, query: 'lost').games.single.id,
      'scotch',
    );
  });

  test(
    'no local match exposes Search older games only when more pages exist',
    () {
      final display = ImportDiscoveryDisplay.from(
        state: ImportState(hasFetched: true, hasMore: true, games: [_game()]),
        query: 'not-here',
      );

      expect(
        display.emptyState,
        ImportDiscoveryEmptyState.noLocalMatchCanSearchOlder,
      );
      expect(display.showSearchOlderAction, isTrue);
    },
  );

  test('loading more during search uses searching older games state', () {
    final display = ImportDiscoveryDisplay.from(
      state: ImportState(
        hasFetched: true,
        hasMore: true,
        isLoadingMore: true,
        games: [_game()],
      ),
      query: 'not-here',
    );

    expect(display.emptyState, ImportDiscoveryEmptyState.searchingOlderGames);
    expect(display.showSearchingOlder, isTrue);
    expect(display.showSearchOlderAction, isFalse);
  });
}

ImportedGame _game({
  String id = 'base',
  String whiteName = 'ALFAISALpro',
  String blackName = 'Opponent',
  String? openingName = 'Italian Game',
  String? eco = 'C50',
  GameResult result = GameResult.whiteWon,
  PlayerColor? userColor = PlayerColor.white,
}) {
  return ImportedGame(
    id: id,
    source: GameSource.chessCom,
    whiteName: whiteName,
    blackName: blackName,
    whiteRating: 860,
    blackRating: 851,
    result: result,
    playedAt: DateTime(2026, 4, 22),
    timeControl: '3 min',
    moveCount: 23,
    pgn: '1. e4 *',
    openingName: openingName,
    eco: eco,
    userColor: userColor,
  );
}
