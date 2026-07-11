import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/services/pgn_mainline_validator.dart';

void main() {
  const validator = PgnMainlineValidator();

  test('reconstructs every legal mainline ply with exact contiguous FENs', () {
    final game = validator.validate('1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *');

    expect(game.moves, hasLength(6));
    for (var index = 1; index < game.moves.length; index++) {
      expect(game.moves[index].fenBefore, game.moves[index - 1].fenAfter);
    }
    expect(game.moves.first.uci, 'e2e4');
    expect(game.moves.last.uci, 'a7a6');
  });

  test('rejects unknown movetext instead of accepting a valid prefix', () {
    expect(
      () => validator.validate('1. e4 e5 2. Banana Nc6 *'),
      throwsA(isA<PgnValidationException>()),
    );
  });

  test('rejects empty and zero-move PGNs', () {
    expect(
      () => validator.validate(''),
      throwsA(isA<PgnValidationException>()),
    );
    expect(
      () => validator.validate('[Result "*"]\n\n*'),
      throwsA(isA<PgnValidationException>()),
    );
  });

  test('normalizes castling to the king destination square', () {
    final game = validator.validate(
      '1. e4 e5 2. Nf3 Nc6 3. Bc4 Nf6 4. O-O Be7 *',
    );

    expect(game.moves[6].uci, 'e1g1');
  });

  test('recognizes en passant as a capture', () {
    final game = validator.validate('1. e4 a6 2. e5 d5 3. exd6 *');

    expect(game.moves.last.uci, 'e5d6');
    expect(game.moves.last.isCapture, isTrue);
  });

  test('reconstructs promotion and preserves the promotion role', () {
    final game = validator.validate(
      '[SetUp "1"]\n'
      '[FEN "7k/P7/8/8/8/8/8/7K w - - 0 1"]\n\n'
      '1. a8=Q+ *',
    );

    expect(game.moves.single.uci, 'a7a8q');
  });

  test('marks a checkmated post-move position as terminal', () {
    final game = validator.validate('1. f3 e5 2. g4 Qh4# 0-1');

    expect(game.moves.last.terminalState, ValidatedTerminalState.checkmate);
  });

  test('accepts a representative Chess.com export with exact ply count', () {
    const pgn = '''
[Event "Live Chess"]
[Site "Chess.com"]
[Date "2026.07.11"]
[Round "-"]
[White "Apex"]
[Black "Opponent"]
[Result "1-0"]
[CurrentPosition "6k1/5ppp/8/8/8/8/5PPP/6K1 b - - 0 16"]
[Timezone "UTC"]
[ECO "C50"]

1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. O-O Nf6 5. d3 d6
6. c3 O-O 7. Re1 a6 8. Bb3 Ba7 9. h3 h6 10. Nbd2 Re8
11. Nf1 Be6 12. Bc2 d5 13. exd5 Bxd5 14. Ng3 Qd7 15. Be3 Bxe3 1-0
''';

    final game = validator.validate(pgn);

    expect(game.headers['Site'], 'Chess.com');
    expect(game.moves, hasLength(30));
    expect(game.moves[6].uci, 'e1g1');
    expect(game.moves[11].uci, 'e8g8');
  });

  test(
    'accepts a representative Lichess export with comments, NAGs, suffixes, and nested variations',
    () {
      const pgn = r'''
[Event "rated rapid game"]
[Site "https://lichess.org/example"]
[Date "2026.07.11"]
[White "Apex"]
[Black "Opponent"]
[Result "1/2-1/2"]
[UTCDate "2026.07.11"]
[UTCTime "10:00:00"]

1. e4! {[%clk 0:09:58] [%eval 0.18]} e5 $1
2. Nf3!? Nc6 (2... Nf6 {Petrov} (2... d6?!))
3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 1/2-1/2
''';

      final game = validator.validate(pgn);

      expect(game.headers['Site'], 'https://lichess.org/example');
      expect(game.moves, hasLength(10));
      expect(
        game.moves.map((move) => move.san),
        containsAll(['e4', 'Nf3', 'O-O']),
      );
    },
  );

  test(
    'accepts line breaks, extra whitespace, semicolon comments, and NAGs',
    () {
      final game = validator.validate(
        '  1. e4   e5\n\n2. Nf3   Nc6 ; mainline comment\n'
        r'3. Bb5 $1 a6 *',
      );

      expect(game.moves, hasLength(6));
      expect(game.moves.last.san, 'a6');
    },
  );

  test('supports setup FEN and all four legal promotion roles', () {
    for (final role in ['Q', 'R', 'B', 'N']) {
      final suffix = role == 'Q' || role == 'R' ? '+' : '';
      final game = validator.validate(
        '[SetUp "1"]\n'
        '[FEN "7k/P7/8/8/8/8/8/7K w - - 0 1"]\n\n'
        '1. a8=$role$suffix *',
      );

      expect(game.moves, hasLength(1));
      expect(game.moves.single.uci, 'a7a8${role.toLowerCase()}');
    }
  });

  test('marks a stalemated post-move position as terminal', () {
    final game = validator.validate(
      '[SetUp "1"]\n'
      '[FEN "k7/2Q5/2K5/8/8/8/8/8 w - - 0 1"]\n\n'
      '1. Qb6 *',
    );

    expect(game.moves.single.terminalState, ValidatedTerminalState.stalemate);
  });

  test('rejects invalid SAN as the first move', () {
    expect(
      () => validator.validate('1. Banana e5 *'),
      throwsA(isA<PgnValidationException>()),
    );
  });

  test('rejects invalid SAN in the middle of an otherwise valid game', () {
    expect(
      () => validator.validate('1. e4 e5 2. Nf3 Nc6 3. Banana a6 *'),
      throwsA(isA<PgnValidationException>()),
    );
  });

  test('rejects content after a valid prefix and result token', () {
    expect(
      () => validator.validate('1. e4 e5 1-0 2. Nf3 Nc6'),
      throwsA(isA<PgnValidationException>()),
    );
  });
}
