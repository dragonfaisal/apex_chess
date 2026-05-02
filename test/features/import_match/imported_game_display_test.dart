import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/features/import_match/presentation/controllers/import_controller.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';

void main() {
  ImportedGame game({
    required GameResult result,
    required PlayerColor? userColor,
    String? openingName,
    String? eco,
    String? timeControl,
  }) {
    return ImportedGame(
      id: 'g1',
      source: GameSource.chessCom,
      whiteName: 'ApexUser',
      blackName: 'RojoHijo',
      whiteRating: 1500,
      blackRating: 1510,
      result: result,
      playedAt: DateTime(2026, 4, 20),
      timeControl: timeControl ?? '180',
      moveCount: 42,
      pgn: '1. e4 *',
      openingName: openingName,
      eco: eco,
      userColor: userColor,
    );
  }

  test('import result text uses user perspective first', () {
    expect(
      game(
        result: GameResult.whiteWon,
        userColor: PlayerColor.white,
      ).perspectiveHeadline,
      'You won vs RojoHijo',
    );
    expect(
      game(
        result: GameResult.whiteWon,
        userColor: PlayerColor.black,
      ).perspectiveHeadline,
      'You lost vs ApexUser',
    );
    expect(
      game(
        result: GameResult.draw,
        userColor: PlayerColor.white,
      ).perspectiveHeadline,
      'Draw vs RojoHijo',
    );
  });

  test('unknown imported perspective does not say You won or You lost', () {
    final text = game(
      result: GameResult.blackWon,
      userColor: null,
    ).perspectiveHeadline;
    expect(text, 'Black won');
    expect(text, isNot(contains('You won')));
    expect(text, isNot(contains('You lost')));
  });

  test('loaded-games filter matches opponent name', () {
    final imported = game(
      result: GameResult.whiteWon,
      userColor: PlayerColor.white,
    );

    expect(imported.matchesLocalFilter('RojoHijo'), isTrue);
    expect(imported.matchesLocalFilter('someone else'), isFalse);
  });

  test(
    'loaded-games filter matches opening, ECO, result, and time control',
    () {
      final imported = game(
        result: GameResult.blackWon,
        userColor: PlayerColor.white,
        openingName: 'Philidor Defense',
        eco: 'C41',
        timeControl: '3 min',
      );

      expect(imported.matchesLocalFilter('Philidor'), isTrue);
      expect(imported.matchesLocalFilter('C41'), isTrue);
      expect(imported.matchesLocalFilter('lost'), isTrue);
      expect(imported.matchesLocalFilter('3 min'), isTrue);
    },
  );

  test('import card title stays perspective-first without score noise', () {
    final imported = game(
      result: GameResult.blackWon,
      userColor: PlayerColor.white,
    );

    expect(imported.perspectiveHeadline, 'You lost vs RojoHijo');
    expect(imported.perspectiveHeadline, isNot(contains('1-0')));
    expect(imported.perspectiveHeadline, isNot(contains('0-1')));
    expect(
      '${imported.resultLabel} Lost',
      isNot(equals(imported.perspectiveHeadline)),
    );
  });

  test('official result stays secondary to the import card headline', () {
    final imported = game(
      result: GameResult.whiteWon,
      userColor: PlayerColor.white,
    );

    expect(imported.perspectiveHeadline, 'You won vs RojoHijo');
    expect(imported.secondaryResultText, 'White won · 1-0');
    expect(imported.perspectiveHeadline, isNot(imported.secondaryResultText));
    expect(imported.perspectiveHeadline, isNot(contains('White won')));
  });

  test('import offline empty state copy is calm and single-message', () {
    const state = ImportState(errorMessage: ApexCopy.offline, hasFetched: true);

    expect(
      state.emptyErrorMessage,
      '${ApexCopy.offline}\n${ApexCopy.tryAgainOnline}',
    );
    expect(state.emptyErrorMessage, isNot(contains('Could not reach')));
  });

  test('import service unavailable copy is not global offline copy', () {
    const state = ImportState(
      errorMessage: ApexCopy.chessComUnavailable,
      hasFetched: true,
    );

    expect(state.emptyErrorMessage, ApexCopy.chessComUnavailable);
    expect(state.emptyErrorMessage, isNot(contains(ApexCopy.offline)));
  });
}
