/// Phase A integration audit — `SacrificeTrajectory` regression tests.
///
/// The Brilliant gate in [MoveClassifier] depends on three boolean
/// signals (`isSacrifice`, `isFirstSacrificePly`, `isTrivialRecapture`)
/// that PR #18 left to caller-supplied defaults. These tests pin the
/// behaviour of the new trajectory walker so future changes to material
/// scoring or recapture detection cannot silently regress real-game
/// review quality.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/services/sacrifice_trajectory.dart';

void main() {
  group('SacrificeTrajectory.analyze', () {
    test('returns one context per ply', () {
      final out = SacrificeTrajectory.analyze(const []);
      expect(out, isEmpty);

      final pliesA = [
        const TrajectoryPly(
          fenBefore:
              'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          fenAfter:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          isWhiteMove: true,
          targetSquare: 'e4',
        ),
      ];
      expect(SacrificeTrajectory.analyze(pliesA), hasLength(1));
    });

    test('routine NxN recapture is flagged as trivial recapture', () {
      // Italian opening fragment: 3...Nc6 (no capture) → 4.Nxe5? Nxe5
      // — a textbook recapture. The mover-perspective trade is square
      // material so the Brilliant gate must close.
      final plies = [
        // White plays Nxe5 — captures Black's pawn on e5.
        const TrajectoryPly(
          fenBefore:
              'r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 2 4',
          fenAfter:
              'r1bqkbnr/pppp1ppp/2n5/4N3/2B1P3/8/PPPP1PPP/RNBQK2R b KQkq - 0 4',
          isWhiteMove: true,
          targetSquare: 'e5',
        ),
        // Black plays Nxe5 — recaptures on the same square.
        const TrajectoryPly(
          fenBefore:
              'r1bqkbnr/pppp1ppp/2n5/4N3/2B1P3/8/PPPP1PPP/RNBQK2R b KQkq - 0 4',
          fenAfter:
              'r1bqkbnr/pppp1ppp/8/4n3/2B1P3/8/PPPP1PPP/RNBQK2R w KQkq - 0 5',
          isWhiteMove: false,
          targetSquare: 'e5',
        ),
      ];
      final ctx = SacrificeTrajectory.analyze(plies);
      expect(ctx[1].isTrivialRecapture, isTrue,
          reason: 'Black recaptures on e5; round-trip is square-for-square');
    });

    test('first non-recapture move on a fresh square is not trivial recapture',
        () {
      // Two consecutive non-capture moves — neither targets the other's
      // square. Trivial-recapture must remain false even though they
      // are sequential plies.
      final plies = [
        const TrajectoryPly(
          fenBefore:
              'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          fenAfter:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          isWhiteMove: true,
          targetSquare: 'e4',
        ),
        const TrajectoryPly(
          fenBefore:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          fenAfter:
              'rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2',
          isWhiteMove: false,
          targetSquare: 'c5',
        ),
      ];
      final ctx = SacrificeTrajectory.analyze(plies);
      expect(ctx[0].isTrivialRecapture, isFalse);
      expect(ctx[1].isTrivialRecapture, isFalse);
    });

    test('mover already a piece down: subsequent sac is NOT first-sac-ply',
        () {
      // Synthetic: White is already missing a knight (deficit = -3 from
      // White's POV). Whatever White plays next can't be Brilliant —
      // they're consolidating after an earlier sac, not committing one.
      final plies = [
        // White already down a knight, plays a quiet developing move.
        const TrajectoryPly(
          fenBefore:
              'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/8/PPPP1PPP/RNBQKB1R w KQkq - 0 4',
          fenAfter:
              'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/3P4/PPP2PPP/RNBQKB1R b KQkq - 0 4',
          isWhiteMove: true,
          targetSquare: 'd3',
        ),
      ];
      final ctx = SacrificeTrajectory.analyze(plies);
      // White's mover-perspective entering balance is roughly -3 (a knight
      // down). isFirstSacrificePly closes once the mover is already in
      // deficit ≥ 2.
      expect(ctx[0].isFirstSacrificePly, isFalse,
          reason:
              'mover already a piece down — any later sac is consolidation');
    });

    test(
        'mover at parity entering ply: ply IS first-sacrifice candidate', () {
      final plies = [
        // Standard starting position, White plays a pawn move. Mover is
        // at parity (balance == 0), so the gate stays open for any
        // sacrifice this ply commits.
        const TrajectoryPly(
          fenBefore:
              'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          fenAfter:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          isWhiteMove: true,
          targetSquare: 'e4',
        ),
      ];
      final ctx = SacrificeTrajectory.analyze(plies);
      expect(ctx[0].isFirstSacrificePly, isTrue);
    });

    test('parser failure on either FEN ⇒ unknown context (gate stays shut)',
        () {
      final plies = [
        const TrajectoryPly(
          fenBefore: 'this-is-not-a-fen',
          fenAfter:
              'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          isWhiteMove: true,
          targetSquare: 'e4',
        ),
      ];
      final ctx = SacrificeTrajectory.analyze(plies);
      expect(ctx[0].isFirstSacrificePly, isFalse);
      expect(ctx[0].isSacrifice, isFalse);
      expect(ctx[0].isTrivialRecapture, isFalse);
    });
  });
}
