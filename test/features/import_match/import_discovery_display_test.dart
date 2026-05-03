import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/import_controller.dart';
import 'package:apex_chess/features/import_match/presentation/models/import_discovery_display.dart';
import 'package:apex_chess/shared_ui/identity/apex_identity_matcher.dart';
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
    expect(display.status, ImportDiscoveryStatus.foundLocalMatches);
  });

  test('search finds an opponent that is not in the first visible slice', () {
    final display = ImportDiscoveryDisplay.from(
      state: ImportState(
        hasFetched: true,
        games: [
          _game(id: 'visible-1', blackName: 'Alpha'),
          _game(id: 'visible-2', blackName: 'Beta'),
          _game(id: 'hidden', blackName: 'FarDownOpponent'),
        ],
      ),
      query: 'FarDown',
    );

    expect(display.games.single.id, 'hidden');
  });

  test('search ranks exact opponent above contains', () {
    final display = ImportDiscoveryDisplay.from(
      state: ImportState(
        hasFetched: true,
        games: [
          _game(id: 'contains', blackName: 'bestmagnolia'),
          _game(id: 'exact', blackName: 'magnolia'),
          _game(id: 'starts', blackName: 'magnoliachicken'),
        ],
      ),
      query: 'magnolia',
    );

    expect(display.games.map((g) => g.id), ['exact', 'starts', 'contains']);
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
    expect(
      ImportDiscoveryDisplay.from(
        state: state,
        query: 'chess.com',
      ).games.single.id,
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
    expect(display.status, ImportDiscoveryStatus.searchingOlderGames);
    expect(display.showSearchingOlder, isTrue);
    expect(display.showSearchOlderAction, isFalse);
  });

  test('older-game fetch merges results and reruns query', () {
    final before = ImportDiscoveryDisplay.from(
      state: ImportState(hasFetched: true, hasMore: true, games: [_game()]),
      query: 'olderdog',
      searchBaselineCount: 1,
    );
    final after = ImportDiscoveryDisplay.from(
      state: ImportState(
        hasFetched: true,
        games: [
          _game(),
          _game(id: 'older', blackName: 'olderdog'),
        ],
      ),
      query: 'olderdog',
      searchBaselineCount: 1,
    );

    expect(
      before.emptyState,
      ImportDiscoveryEmptyState.noLocalMatchCanSearchOlder,
    );
    expect(after.games.single.id, 'older');
    expect(after.status, ImportDiscoveryStatus.foundOlderMatches);
  });

  test('no-match only appears after older search path is exhausted', () {
    final withOlder = ImportDiscoveryDisplay.from(
      state: ImportState(hasFetched: true, hasMore: true, games: [_game()]),
      query: 'not-here',
    );
    final exhausted = ImportDiscoveryDisplay.from(
      state: ImportState(hasFetched: true, hasMore: false, games: [_game()]),
      query: 'not-here',
    );

    expect(
      withOlder.emptyState,
      ImportDiscoveryEmptyState.noLocalMatchCanSearchOlder,
    );
    expect(exhausted.emptyState, ImportDiscoveryEmptyState.noMatchingGames);
    expect(exhausted.status, ImportDiscoveryStatus.noMatchingGames);
  });

  test('service unavailable maps to service display state', () {
    final display = ImportDiscoveryDisplay.from(
      state: const ImportState(
        hasFetched: true,
        errorMessage: 'Chess.com unavailable',
      ),
      query: 'dog',
    );

    expect(display.status, ImportDiscoveryStatus.serviceUnavailable);
  });

  test('partial import search returns game matches, not confirmed profile', () {
    final display = ImportDiscoveryDisplay.from(
      state: ImportState(
        hasFetched: true,
        games: [
          _game(id: 'me', whiteName: 'ALFAISALpro', blackName: 'Opponent'),
        ],
      ),
      query: 'FAISAL',
    );
    final identity = const ApexIdentityMatcher().resolveOpponentQuery(
      query: 'FAISAL',
      platform: 'chess.com',
      connectedAccount: const ApexIdentityCandidate(
        handle: 'ALFAISALpro',
        platform: 'chess.com',
      ),
    );

    expect(display.games.single.id, 'me');
    expect(identity.isConfirmedOpponent, isFalse);
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
