/// Phase 6 regressions for [EvaluationAnalyzer].
///
/// Pins the four hard-spec'd rules from the user's Phase 6 brief:
///
///   1. Brilliant must NOT fire when the player was already winning
///      (eval_before ≥ +5.0) unless the line is a forced mate.
///   2. Brilliant must NOT fire when the cp-loss exceeds 40.
///   3. Cp-loss thresholds (Best ≤30, Excellent ≤60, Inaccuracy ≤120,
///      Mistake ≤250, Blunder >250) cap the Win%-derived tier.
///   4. Already-lost / already-winning damping never lets a single
///      ply read as Blunder when the position was already decided.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';

void main() {
  final analyzer = EvaluationAnalyzer();

  group('Brilliant gating', () {
    test('does NOT award Brilliant when already winning (+5.0)', () {
      // Sacrifice executed from +500 cp ("already winning") that
      // does not lead to a forced mate must not be Brilliant — pre-
      // Phase 6 this fired as long as deltaW was within noise.
      final r = analyzer.analyze(
        prevCp: 500,
        currCp: 480,
        isWhiteMove: true,
        engineBestMoveUci: 'a1a2',
        playedMoveUci: 'a1a2',
        isSacrifice: true,
      );
      expect(r.quality, isNot(MoveQuality.brilliant));
      // 20 cp loss + still engine #1 → Best.
      expect(r.quality, MoveQuality.best);
    });

    test('awards Brilliant when winning AND forces mate', () {
      final r = analyzer.analyze(
        prevCp: 600,
        currCp: null,
        currMate: 3,
        isWhiteMove: true,
        engineBestMoveUci: 'd1h5',
        playedMoveUci: 'd1h5',
        isSacrifice: true,
      );
      expect(r.quality, MoveQuality.brilliant);
    });

    test('does NOT award Brilliant when cp-loss exceeds 40', () {
      // Sacrifice that drops 80 cp must never be Brilliant per spec.
      final r = analyzer.analyze(
        prevCp: 30,
        currCp: -50,
        isWhiteMove: true,
        engineBestMoveUci: 'd1h5',
        playedMoveUci: 'd1h5',
        isSacrifice: true,
      );
      expect(r.quality, isNot(MoveQuality.brilliant));
    });

    test('awards Brilliant when balanced + sacrifice + engine-best', () {
      // Equal-ish position, real sacrifice, played the engine's #1,
      // cp-loss within 40 → Brilliant.
      final r = analyzer.analyze(
        prevCp: 20,
        currCp: 10,
        isWhiteMove: true,
        engineBestMoveUci: 'b2b4',
        playedMoveUci: 'b2b4',
        isSacrifice: true,
      );
      expect(r.quality, MoveQuality.brilliant);
    });
  });

  group('Cp-loss safety net', () {
    test('caps to Excellent when cp-loss ≤ 60', () {
      // Win% sigmoid in the wings of -800 cp barely changes for a
      // 50 cp slip — pre-Phase 6 this could read as Inaccuracy via
      // `deltaW ≤ -2`. The cp-floor now caps at Excellent.
      final r = analyzer.analyze(
        prevCp: -800,
        currCp: -850,
        isWhiteMove: true,
      );
      expect(r.quality, MoveQuality.excellent);
    });

    test('caps to Inaccuracy when cp-loss ≤ 120', () {
      final r = analyzer.analyze(
        prevCp: 0,
        currCp: -100,
        isWhiteMove: true,
      );
      expect(r.quality,
          isIn([MoveQuality.inaccuracy, MoveQuality.good]));
      // Either tier is acceptable per spec — the key is *not*
      // Mistake / Blunder.
      expect(r.quality, isNot(MoveQuality.mistake));
      expect(r.quality, isNot(MoveQuality.blunder));
    });

    test('Blunder requires cp-loss > 250', () {
      // 150 cp loss should never read as Blunder, even if Win% says
      // so. Concretely a slip from +0 → -150 lands in Mistake.
      final r = analyzer.analyze(
        prevCp: 0,
        currCp: -150,
        isWhiteMove: true,
      );
      expect(r.quality, isNot(MoveQuality.blunder));
    });

    test('Blunder fires when cp-loss > 250 AND Win% drops', () {
      final r = analyzer.analyze(
        prevCp: 100,
        currCp: -300,
        isWhiteMove: true,
      );
      expect(r.quality, MoveQuality.blunder);
    });
  });

  group('Damping rules', () {
    test('already-lost: never Blunder on a single ply', () {
      // Mover Win% before is ~5% (-1200 cp); a -300 cp slip should
      // not promote a single ply to Blunder.
      final r = analyzer.analyze(
        prevCp: -1200,
        currCp: -1500,
        isWhiteMove: true,
      );
      expect(r.quality, isNot(MoveQuality.blunder));
    });

    test('already-winning drift: Mistake at worst, not Blunder', () {
      // From +800 to +600 — still winning. Pre-Phase 6 the Win%
      // sigmoid + cp-loss combo could land here as Blunder, which
      // misrepresents an inaccuracy that gives back small advantage.
      final r = analyzer.analyze(
        prevCp: 800,
        currCp: 600,
        isWhiteMove: true,
      );
      expect(r.quality, isNot(MoveQuality.blunder));
    });
  });

  group('Castling UCI normalisation (engine-best matching)', () {
    test('Best fires on e1g1 played vs e1h1 engine', () {
      final r = analyzer.analyze(
        prevCp: 0,
        currCp: 0,
        isWhiteMove: true,
        engineBestMoveUci: 'e1h1', // king-captures-rook (dartchess form)
        playedMoveUci: 'e1g1', // king-target form
      );
      expect(r.quality, MoveQuality.best);
    });
  });
}
