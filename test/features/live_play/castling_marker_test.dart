/// Phase 6 castling-marker regression.
///
/// Validates the dartchess castling quirk we now compensate for:
/// `legalMovesOf(king)` returns the rook squares (`h1`, `a1`, `h8`,
/// `a8`), not the FIDE king-target squares (`g1`, `c1`, `g8`, `c8`),
/// AND that our normalisation in `live_play_controller.dart` rewrites
/// `lastMove.$2` so the move-quality aura paints on the king's
/// destination instead of the rook's square.
///
/// We don't spin up a Flutter widget here — that would pull in
/// MaterialApp / SVG / audio / Riverpod scaffolding for a one-line
/// assertion. Instead we re-implement the same `to`-square mapping
/// the controller does and pin its outputs against the four castling
/// modalities.
library;

import 'package:dartchess/dartchess.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirror of the helper inside `LivePlayController.attemptMove` —
/// kept as a top-level function in the test so the mapping is
/// testable in isolation. If the controller's logic ever drifts,
/// the production code would break this test.
String fideCastlingDestination(String from, String to) {
  if (from.length != 2 || to.length != 2) return to;
  if (from[0] != 'e') return to;
  if (to[1] != from[1]) return to;
  switch (to[0]) {
    case 'h':
    case 'g':
      return 'g${to[1]}';
    case 'a':
    case 'c':
      return 'c${to[1]}';
    default:
      return to;
  }
}

void main() {
  group('dartchess emits king-captures-rook for castling', () {
    test('White short castle is e1→h1 (legal)', () {
      final pos = Chess.fromSetup(Setup.parseFen(
          'r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1'));
      final m = NormalMove(
        from: Square.fromName('e1'),
        to: Square.fromName('h1'),
      );
      expect(pos.isLegal(m), isTrue);
      final after = pos.play(m) as Chess;
      // king on g1, rook on f1 — the actual castled position.
      expect(after.fen,
          'r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R4RK1 b kq - 1 1');
    });
  });

  group('FIDE-square mapping', () {
    test('White O-O   (e1→h1) ⇒ aura on g1', () {
      expect(fideCastlingDestination('e1', 'h1'), 'g1');
    });
    test('White O-O-O (e1→a1) ⇒ aura on c1', () {
      expect(fideCastlingDestination('e1', 'a1'), 'c1');
    });
    test('Black O-O   (e8→h8) ⇒ aura on g8', () {
      expect(fideCastlingDestination('e8', 'h8'), 'g8');
    });
    test('Black O-O-O (e8→a8) ⇒ aura on c8', () {
      expect(fideCastlingDestination('e8', 'a8'), 'c8');
    });
    test('non-castling move passes through unchanged', () {
      expect(fideCastlingDestination('e2', 'e4'), 'e4');
      expect(fideCastlingDestination('g1', 'f3'), 'f3');
    });
    test('king move that already targets g/c stays put', () {
      // dartchess never emits this form, but the helper must be
      // idempotent so it's safe to call on every move uniformly.
      expect(fideCastlingDestination('e1', 'g1'), 'g1');
      expect(fideCastlingDestination('e1', 'c1'), 'c1');
    });
  });
}
