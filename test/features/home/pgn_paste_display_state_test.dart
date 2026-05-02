import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/services/game_identity_service.dart';
import 'package:apex_chess/features/home/presentation/pgn_paste_display_state.dart';
import 'package:apex_chess/infrastructure/engine/eco_book.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';

void main() {
  const identity = GameIdentityService();

  test('PGN paste input auto-collapse is enabled after valid PGN parse', () {
    const pgn = '''
[Event "Rated blitz game"]
[White "ApexUser"]
[Black "RojoHijo"]
[Result "1-0"]

1. e4 e5 2. Nf3 Nc6 1-0
''';
    final preview = identity.parsePgn(pgn, userHandle: 'ApexUser');

    expect(
      PgnPasteDisplayState.shouldCollapseInput(pgn: pgn, identity: preview),
      isTrue,
    );
  });

  test('PGN paste input stays expanded when parsing has no moves', () {
    const pgn = '[White "ApexUser"]';
    final preview = identity.parsePgn(pgn, userHandle: 'ApexUser');

    expect(
      PgnPasteDisplayState.shouldCollapseInput(pgn: pgn, identity: preview),
      isFalse,
    );
  });

  test('PGN side copy uses played-side wording', () {
    expect(PgnPasteDisplayState.sideLabel(true), 'You played White');
    expect(PgnPasteDisplayState.sideLabel(false), 'You played Black');
    expect(
      PgnPasteDisplayState.sideLabel(true),
      isNot(contains('Detected perspective')),
    );
    expect(PgnPasteDisplayState.sideLabel(false), isNot(contains('You:')));
  });

  test('PGN opening lookup returns a known opening from local ECO data', () {
    const pgn = '''
1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *
''';
    final preview = identity.parsePgn(pgn);
    final book = EcoBook.fromTsv(
      'eco\tname\tpgn\nC60\tRuy Lopez\t1. e4 e5 2. Nf3 Nc6 3. Bb5\n',
    );

    expect(
      PgnPasteDisplayState.openingLabel(
        pgn: pgn,
        identity: preview,
        ecoBook: book,
      ),
      'C60 · Ruy Lopez',
    );
  });

  test('PGN unknown opening returns fallback copy', () {
    const pgn = '1. h4 h5 2. Rh3 Rh6 *';
    final preview = identity.parsePgn(pgn);
    final book = EcoBook.fromTsv('eco\tname\tpgn\n');

    expect(
      PgnPasteDisplayState.openingLabel(
        pgn: pgn,
        identity: preview,
        ecoBook: book,
      ),
      ApexCopy.openingNotDetected,
    );
  });
}
