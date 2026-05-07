import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/models/archived_game_card_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Chess.com PGN site maps to Chess.com', () {
    expect(
      ArchiveSource.fromPgnSite('https://www.chess.com/game/live/123'),
      ArchiveSource.chessCom,
    );
    expect(
      ArchiveSource.fromPgnSite('https://chess.com/analysis/game/live/123'),
      ArchiveSource.chessCom,
    );
  });

  test('Lichess PGN site maps to Lichess', () {
    expect(
      ArchiveSource.fromPgnSite('https://lichess.org/abcdefgh'),
      ArchiveSource.lichess,
    );
  });

  test('missing or unknown PGN site maps to PGN', () {
    expect(ArchiveSource.fromPgnSite(null), ArchiveSource.pgn);
    expect(ArchiveSource.fromPgnSite('https://example.com'), ArchiveSource.pgn);
  });

  test('PGN source appears once at card level', () {
    final model = _game(source: ArchiveSource.pgn).toApexGameCardDisplay();

    expect(model.secondaryMeta, contains('PGN'));
    expect(model.white.identity.platform.name, 'pgn');
    expect(model.black.identity.platform.name, 'pgn');
  });
}

ArchivedGame _game({required ArchiveSource source}) {
  return ArchivedGame(
    id: 'pgn',
    source: source,
    white: 'WhitePlayer',
    black: 'BlackPlayer',
    result: '1-0',
    analyzedAt: DateTime(2026, 5, 7),
    depth: 18,
    pgn: '1. e4 *',
    qualityCounts: const {},
    averageCpLoss: 22,
    totalPlies: 30,
  );
}
