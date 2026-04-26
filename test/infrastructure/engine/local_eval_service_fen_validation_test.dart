/// Regression tests for the FEN structural validator that guards
/// `LocalEvalService.evaluate` from forwarding malformed positions to
/// the native Stockfish UCI parser.
///
/// Bad FENs in the real app came from two paths:
///   1. The PGN parser emitting partial FENs at the boundary between
///      games when an import was interrupted.
///   2. UI controllers handing the engine an empty / sentinel string
///      ("", "8/8/8/8/8/8/8/8") on the very first eval of a Live Play
///      session before the board state was hydrated.
///
/// Either case used to abort the DartWorker thread (SIGABRT) — see the
/// production crash log. This test pins the contract of the validator
/// so the guard cannot silently regress.
library;

import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isStructurallyValidFenForTesting', () {
    test('accepts the standard initial position', () {
      expect(
        isStructurallyValidFenForTesting(
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        ),
        isTrue,
      );
    });

    test('accepts the validation FEN from the stabilization spec', () {
      expect(
        isStructurallyValidFenForTesting('8/8/8/8/8/8/2k5/1Q6 w - - 0 1'),
        isTrue,
      );
    });

    test('rejects empty / whitespace input', () {
      expect(isStructurallyValidFenForTesting(''), isFalse);
      expect(isStructurallyValidFenForTesting('   '), isFalse);
    });

    test('rejects FEN without a side-to-move field', () {
      expect(
        isStructurallyValidFenForTesting(
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR',
        ),
        isFalse,
      );
    });

    test('rejects FEN with a board section missing ranks', () {
      // 7 ranks instead of 8.
      expect(
        isStructurallyValidFenForTesting(
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP w KQkq - 0 1',
        ),
        isFalse,
      );
    });

    test('rejects FEN with a NUL byte', () {
      expect(
        isStructurallyValidFenForTesting(
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP\u0000/RNBQKBNR w KQkq - 0 1',
        ),
        isFalse,
      );
    });

    test('rejects FEN with an unrecognised side-to-move letter', () {
      expect(
        isStructurallyValidFenForTesting(
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR x KQkq - 0 1',
        ),
        isFalse,
      );
    });
  });
}
