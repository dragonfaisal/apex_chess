import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/services/game_identity_service.dart';
import 'package:apex_chess/features/home/presentation/pgn_paste_display_state.dart';

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
}
