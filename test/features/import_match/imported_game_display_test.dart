import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/features/import_match/domain/imported_game.dart';

void main() {
  ImportedGame game({
    required GameResult result,
    required PlayerColor? userColor,
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
      timeControl: '180',
      moveCount: 42,
      pgn: '1. e4 *',
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
}
