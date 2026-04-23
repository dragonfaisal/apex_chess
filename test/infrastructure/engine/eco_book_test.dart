/// Unit tests for [EcoBook] — exercise TSV parsing, FEN derivation, and
/// FEN-prefix normalisation (position reached by different move orders
/// must still match the same book entry).
library;

import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/infrastructure/engine/eco_book.dart';

/// Convenience — derives the FEN after a short PGN via dartchess, matching
/// the same pipeline [EcoBook] uses internally. Tests should not hardcode
/// expected FENs because dartchess can update its stringifier and cause
/// brittle failures.
String _fenAfter(String pgn) {
  Position pos = Chess.initial;
  final tokens = pgn
      .replaceAll(RegExp(r'\d+\.(\.\.)?'), ' ')
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
  for (final san in tokens) {
    final move = pos.parseSan(san)!;
    pos = pos.play(move);
  }
  return pos.fen;
}

void main() {
  group('EcoBook', () {
    test('parses a simple TSV and looks up by FEN', () {
      const tsv = 'eco\tname\tpgn\nB00\tKing\'s Pawn Opening\t1. e4\n';
      final book = EcoBook.fromTsv(tsv);
      expect(book.size, 1);
      final fen = _fenAfter('1. e4');
      expect(book.contains(fen), isTrue);
      expect(book.lookup(fen)?.eco, 'B00');
      expect(book.lookup(fen)?.name, contains('King'));
    });

    test('normalises halfmove / fullmove counters', () {
      const tsv =
          'eco\tname\tpgn\nC40\tKing\'s Knight Opening\t1. e4 e5 2. Nf3\n';
      final book = EcoBook.fromTsv(tsv);
      // Same position with inflated counters — must still match.
      final fen = _fenAfter('1. e4 e5 2. Nf3');
      expect(book.contains(fen), isTrue);
      final parts = fen.split(' ');
      final mutated = '${parts.take(4).join(' ')} 99 99';
      expect(book.contains(mutated), isTrue);
    });

    test('silently skips malformed rows', () {
      const tsv =
          'eco\tname\tpgn\nX00\tbad\t1. Zz\nA00\tAmar Opening\t1. Nh3\n';
      final book = EcoBook.fromTsv(tsv);
      expect(book.size, 1); // only the valid row indexed
    });

    test('lookup returns null for a position not in the book', () {
      const tsv = 'eco\tname\tpgn\nA00\tAmar\t1. Nh3\n';
      final book = EcoBook.fromTsv(tsv);
      final start = Chess.initial.fen;
      expect(book.contains(start), isFalse);
      expect(book.lookup(start), isNull);
    });

    test('keeps the shortest / most general entry when positions collide',
        () {
      // Same position reached after 1. e4, indexed twice. The first row
      // should win.
      const tsv = 'eco\tname\tpgn\n'
          'B00\tKing\'s Pawn Opening\t1. e4\n'
          'B01\tShould Not Win\t1. e4\n';
      final book = EcoBook.fromTsv(tsv);
      final fen = _fenAfter('1. e4');
      expect(book.lookup(fen)?.eco, 'B00');
    });
  });
}
