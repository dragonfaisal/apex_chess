import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/services/game_identity_service.dart';

void main() {
  const service = GameIdentityService();

  const pgn = '''
[White "DrePlayerNZ"]
[Black "ALFAISALpro"]
[WhiteElo "559"]
[BlackElo "553"]
[Result "0-1"]
[Date "2025.10.21"]
[TimeControl "180"]
[Opening "Queen's Pawn Game"]
1. Nf3 Nf6 2. d4 d5 0-1
''';

  test('PGN Black handle auto-detects userColor black', () {
    final id = service.parsePgn(pgn, userHandle: ' alfaisalPRO ');
    expect(id.userIsWhite, isFalse);
    expect(
      service.resultLabel(id.result, userIsWhite: id.userIsWhite),
      'You won',
    );
  });

  test('connected handle matching trims spaces and ignores case', () {
    final id = service.parsePgn(pgn, userHandle: '  AlFaIsAlPrO  ');
    expect(id.userIsWhite, isFalse);
  });

  test('PGN White handle auto-detects userColor white', () {
    final id = service.parsePgn(pgn, userHandle: 'dreplayernz');
    expect(id.userIsWhite, isTrue);
    expect(id.whiteRating, '559');
    expect(id.blackRating, '553');
    expect(id.timeControl, '180');
    expect(id.opening, "Queen's Pawn Game");
  });

  test('unknown user does not show You won or You lost', () {
    final id = service.parsePgn(pgn, userHandle: 'someone_else');
    expect(id.userIsWhite, isNull);
    expect(
      service.resultLabel(id.result, userIsWhite: id.userIsWhite),
      'Black won',
    );
  });
}
