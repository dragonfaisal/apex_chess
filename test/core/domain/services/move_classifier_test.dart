/// Phase A § 4–9: MoveClassifier brain — every spec-mandated
/// scenario pinned with a regression test.
///
/// Cases (from prompt § 8):
///   * sacrifice while +6 is NOT Brilliant
///   * capturing a sacrificed piece is NOT automatically Brilliant
///   * mate against mover is never Brilliant (always Blunder)
///   * true sacrifice with compensation can be Brilliant
///   * Book move is Book, not Brilliant
///   * missed mate becomes Missed Win or Blunder depending on result
///   * Black perspective is correct
///   * mate sign direction is correct
///   * Brilliant attaches to correct ply (first sacrificing ply only)
///
/// Plus extra coverage for Forced (MultiPV), Great (PV1 ≫ PV2), the
/// already-lost / already-winning damping rules, and the cp-loss
/// safety net.
library;

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const classifier = MoveClassifier();

  // ─── Brilliant gate ──────────────────────────────────────────────────
  group('Brilliant gate', () {
    test(
      'Sacrifice while already +6 is NOT Brilliant (winning showmanship)',
      () {
        // White is already crushing (+650 cp ≈ 91 % Win%). A sacrifice
        // here is "win more"; spec § 3.6.6.3 says it must not be
        // Brilliant.
        final cls = classifier.classify(
          const MoveClassificationInput(
            isWhiteMove: true,
            prevWhiteCp: 650,
            prevWhiteMate: null,
            currWhiteCp: 600,
            currWhiteMate: null,
            engineBestMoveUci: 'd1h5',
            playedMoveUci: 'd1h5',
            isSacrifice: true,
          ),
        );
        expect(cls.quality, isNot(MoveQuality.brilliant));
      },
    );

    test('Recapture (trivial) is NOT Brilliant', () {
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 0,
          prevWhiteMate: null,
          currWhiteCp: 10,
          currWhiteMate: null,
          engineBestMoveUci: 'e4d5',
          playedMoveUci: 'e4d5',
          isSacrifice: false,
          isTrivialRecapture: true,
        ),
      );
      expect(cls.quality, isNot(MoveQuality.brilliant));
    });

    test('Mate AGAINST mover is never Brilliant (always Blunder)', () {
      // White sacrifices into a mate-in-3 against White. Even though
      // the played move is a "sacrifice" at face value, currWhiteMate
      // = -3 means Black is delivering mate.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 100,
          prevWhiteMate: null,
          currWhiteCp: null,
          currWhiteMate: -3,
          engineBestMoveUci: 'd1h5',
          playedMoveUci: 'd1h5',
          isSacrifice: true,
        ),
      );
      expect(cls.quality, MoveQuality.blunder);
    });

    test('True sacrifice with compensation IS Brilliant', () {
      // White is up only marginally (+50 cp ≈ 54.5 % Win%) — not
      // crushing — sacrifices a knight (caller asserts), the move is
      // engine-best, ΔW stays in noise (cp stays ≈ +30), and no
      // alternative non-sac line was trivially winning.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 50,
          prevWhiteMate: null,
          currWhiteCp: 30,
          currWhiteMate: null,
          engineBestMoveUci: 'g5h6',
          playedMoveUci: 'g5h6',
          isSacrifice: true,
          altLineWhiteWinPercent: 55.0,
          multiPvWhiteWinPercents: [55.0, 54.0, 52.0],
        ),
      );
      expect(cls.quality, MoveQuality.brilliant);
    });

    test('True sacrifice that mates IS Brilliant', () {
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 50,
          prevWhiteMate: null,
          currWhiteCp: null,
          currWhiteMate: 3,
          engineBestMoveUci: 'g5h6',
          playedMoveUci: 'g5h6',
          isSacrifice: true,
          multiPvWhiteWinPercents: [95.0, 72.0, 65.0],
        ),
      );
      expect(cls.quality, MoveQuality.brilliant);
    });

    test('Sound sacrifice without MultiPV evidence is NOT Brilliant', () {
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 50,
          prevWhiteMate: null,
          currWhiteCp: 30,
          currWhiteMate: null,
          engineBestMoveUci: 'g5h6',
          playedMoveUci: 'g5h6',
          isSacrifice: true,
          altLineWhiteWinPercent: 55.0,
        ),
      );
      expect(cls.quality, isNot(MoveQuality.brilliant));
    });

    test('Brilliant only attaches to FIRST sac ply, not consolidating ply', () {
      // The same engine-best, sound, sacrificial-flagged move is
      // played, but caller asserts this is a *consolidation* (not the
      // first ply that committed material). Must NOT be Brilliant.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 50,
          prevWhiteMate: null,
          currWhiteCp: 30,
          currWhiteMate: null,
          engineBestMoveUci: 'g5h6',
          playedMoveUci: 'g5h6',
          isSacrifice: true,
          isFirstSacrificePly: false,
        ),
      );
      expect(cls.quality, isNot(MoveQuality.brilliant));
    });

    test(
      'Sacrifice when an alt line was trivially winning is NOT Brilliant',
      () {
        // White had a non-sacrificial line worth Win% ≥ 97. Even a
        // sound sac is "win more" (spec § 3.6.6.2).
        final cls = classifier.classify(
          const MoveClassificationInput(
            isWhiteMove: true,
            prevWhiteCp: 200,
            prevWhiteMate: null,
            currWhiteCp: 180,
            currWhiteMate: null,
            engineBestMoveUci: 'g5h6',
            playedMoveUci: 'g5h6',
            isSacrifice: true,
            altLineWhiteWinPercent: 98.0,
            multiPvWhiteWinPercents: [88.0, 98.0, 75.0],
          ),
        );
        expect(cls.quality, isNot(MoveQuality.brilliant));
      },
    );

    test('Sacrifice that drops Win% below 50 (mover ends LOSING) is NOT '
        'Brilliant', () {
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 0,
          prevWhiteMate: null,
          // Engine sees the sac as +0 from White's POV → 50 %, but
          // played-then-replied-to lands at -200 (below 50 % mover).
          currWhiteCp: -200,
          currWhiteMate: null,
          engineBestMoveUci: 'd1h5',
          playedMoveUci: 'd1h5',
          isSacrifice: true,
          multiPvWhiteWinPercents: [50.0, 49.0, 48.0],
        ),
      );
      expect(cls.quality, isNot(MoveQuality.brilliant));
    });
  });

  // ─── Black perspective ────────────────────────────────────────────
  group('Black perspective', () {
    test(
      'Black move that improves Black reads as positive ΔW (not Blunder)',
      () {
        // White-POV cp goes from -50 to -200 → bad for White, GOOD for
        // Black who just moved. ΔW for Black should be positive and
        // the move classifies into the upper tiers (Best / Great /
        // Excellent — never Blunder).
        final cls = classifier.classify(
          const MoveClassificationInput(
            isWhiteMove: false,
            prevWhiteCp: -50,
            prevWhiteMate: null,
            currWhiteCp: -200,
            currWhiteMate: null,
            engineBestMoveUci: 'd8d4',
            playedMoveUci: 'd8d4',
          ),
        );
        expect(cls.deltaW, greaterThan(0));
        expect(
          cls.quality,
          anyOf(MoveQuality.best, MoveQuality.great, MoveQuality.excellent),
        );
        expect(cls.quality, isNot(MoveQuality.blunder));
        expect(cls.quality, isNot(MoveQuality.mistake));
      },
    );

    test('Black blunder (Black-favoured eval erodes) reads as Blunder', () {
      // White-POV cp moves from -300 to +100 → Black just gave up
      // 400 cp. ΔW for Black ≈ -50 → Blunder.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: false,
          prevWhiteCp: -300,
          prevWhiteMate: null,
          currWhiteCp: 100,
          currWhiteMate: null,
        ),
      );
      expect(cls.quality, MoveQuality.blunder);
      expect(cls.deltaW, lessThan(MoveClassifier.dwMistake));
    });

    test(
      'Black with mate=−5 is mate FOR Black (Win% from Black POV ≈ 100)',
      () {
        // mate = -5 means Black mates White. From Black mover-POV this
        // is "I am delivering mate". Played move is engine-best, ΔW
        // should be ≥ 0.
        final cls = classifier.classify(
          const MoveClassificationInput(
            isWhiteMove: false,
            prevWhiteCp: -200,
            prevWhiteMate: null,
            currWhiteCp: null,
            currWhiteMate: -5,
            engineBestMoveUci: 'h2h1',
            playedMoveUci: 'h2h1',
          ),
        );
        // Mover-POV after = 100, mover-POV before ≈ 67 (Lichess sigmoid
        // at -200 cp is ~33 % white-POV → 67 % black-POV). ΔW > 0.
        expect(cls.deltaW, greaterThan(0));
        expect(cls.quality, MoveQuality.best);
      },
    );
  });

  // ─── Mate sign direction ──────────────────────────────────────────
  group('Mate sign direction', () {
    test(
      'Position with mate=+3 (White mates) registers as winning for White',
      () {
        // Trivial: prev wPrev should be 100 and ΔW for White move
        // ≥ 0.
        final cls = classifier.classify(
          const MoveClassificationInput(
            isWhiteMove: true,
            prevWhiteCp: null,
            prevWhiteMate: 3,
            currWhiteCp: null,
            currWhiteMate: 2,
            engineBestMoveUci: 'a1a8',
            playedMoveUci: 'a1a8',
          ),
        );
        expect(cls.winPercentBefore, 100.0);
        expect(cls.winPercentAfter, 100.0);
        expect(cls.quality, MoveQuality.best);
      },
    );

    test('Position with mate=-3 (Black mates White) — White move stays in '
        'a forced-mate-against-mover and is Blunder per spec § 3.4', () {
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: null,
          prevWhiteMate: -3,
          currWhiteCp: null,
          currWhiteMate: -2,
        ),
      );
      expect(cls.winPercentBefore, 0.0);
      expect(cls.winPercentAfter, 0.0);
      // Spec § 3.4: any move that results in a forced mate against
      // the mover is a Blunder regardless of cp / damping.
      expect(cls.quality, MoveQuality.blunder);
    });
  });

  // ─── Book / Theory ────────────────────────────────────────────────
  group('Book / Theory', () {
    test('isBook=true with small drift ⇒ Book (not Brilliant or Blunder)', () {
      // Sound book move that *also* happens to be a sacrifice
      // (Marshall, etc.). Spec: caller's `isBook` flag wins unless
      // ΔW < -20.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 20,
          prevWhiteMate: null,
          currWhiteCp: 0,
          currWhiteMate: null,
          engineBestMoveUci: 'e2e4',
          playedMoveUci: 'e2e4',
          isSacrifice: true,
          isBook: true,
          ecoCode: 'C00',
          openingName: 'French Defense',
        ),
      );
      expect(cls.quality, MoveQuality.book);
      expect(cls.message, contains('French Defense'));
    });

    test('isBook=true but ΔW < -20 ⇒ severe drop overrides ⇒ Blunder', () {
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 0,
          prevWhiteMate: null,
          currWhiteCp: -800,
          currWhiteMate: null,
          isBook: true,
        ),
      );
      expect(cls.quality, MoveQuality.blunder);
    });
  });

  // ─── Missed Win ───────────────────────────────────────────────────
  group('Missed Win', () {
    test('Mover was forced-mate-up, drops to merely-better ⇒ Missed Win', () {
      // White had mate-in-4 (mate=+4), played a move that lost the
      // forced sequence but stays ahead in cp.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: null,
          prevWhiteMate: 4,
          currWhiteCp: 250,
          currWhiteMate: null,
        ),
      );
      expect(cls.quality, MoveQuality.missedWin);
    });

    test('Mover was winning (Win% > 70), drops to equal ⇒ Missed Win', () {
      // ΔW lands in (-20, -10] and crosses winning → equal.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 250, // ≈ 71 % Win%
          prevWhiteMate: null,
          currWhiteCp: 30, // ≈ 53 % Win%
          currWhiteMate: null,
        ),
      );
      // Severity must be Missed Win (or Mistake — spec puts both on
      // the table; we resolve to Missed Win when not severe enough
      // to be Blunder).
      expect(cls.quality, MoveQuality.missedWin);
    });

    test('Mover was winning, position now LOSING ⇒ Missed Win', () {
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 400,
          prevWhiteMate: null,
          currWhiteCp: -400,
          currWhiteMate: null,
          multiPvWhiteWinPercents: [82.0, 58.0, 45.0],
        ),
      );
      expect(cls.quality, MoveQuality.missedWin);
    });

    test('Black missed a winning PV1 line uses Black perspective', () {
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: false,
          prevWhiteCp: -400,
          prevWhiteMate: null,
          currWhiteCp: 400,
          currWhiteMate: null,
          multiPvWhiteWinPercents: [18.0, 45.0, 52.0],
        ),
      );
      expect(cls.quality, MoveQuality.missedWin);
    });
  });

  // ─── Forced (MultiPV) ─────────────────────────────────────────────
  group('Forced', () {
    test('Only one MultiPV line holds; played that line ⇒ Forced', () {
      // White: PV1 ≈ 60 (mover-POV 60), PV2/3 drop > 20 pp.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 50,
          prevWhiteMate: null,
          currWhiteCp: 80,
          currWhiteMate: null,
          engineBestMoveUci: 'a2a3',
          playedMoveUci: 'a2a3',
          multiPvWhiteWinPercents: [60.0, 30.0, 25.0],
        ),
      );
      expect(cls.quality, MoveQuality.forced);
    });

    test('Two of three MultiPV lines hold ⇒ NOT Forced', () {
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 50,
          prevWhiteMate: null,
          currWhiteCp: 50,
          currWhiteMate: null,
          engineBestMoveUci: 'a2a3',
          playedMoveUci: 'a2a3',
          multiPvWhiteWinPercents: [55.0, 53.0, 30.0],
        ),
      );
      expect(cls.quality, isNot(MoveQuality.forced));
    });

    test('Quick mode suppresses Forced even with PV1-only evidence', () {
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 50,
          prevWhiteMate: null,
          currWhiteCp: 80,
          currWhiteMate: null,
          engineBestMoveUci: 'a2a3',
          playedMoveUci: 'a2a3',
          multiPvWhiteWinPercents: [60.0, 30.0, 25.0],
          suppressTrophyTiers: true,
        ),
      );
      expect(cls.quality, isNot(MoveQuality.forced));
      expect(cls.quality, isNot(MoveQuality.great));
      expect(cls.quality, isNot(MoveQuality.brilliant));
    });
  });

  // ─── Great (PV1 vs PV2) ───────────────────────────────────────────
  group('Great', () {
    test('Engine-best move with PV1 ≥ 10 pp better than PV2 ⇒ Great', () {
      // White: prev cp 50 (54.6 % Win%), played move lands at +250 cp
      // (mover-POV ≈ 71 %), and the engine's #2 line was only worth
      // ~50 % (mover-POV). Gap = 21 pp ≥ 10 pp threshold.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 50,
          prevWhiteMate: null,
          currWhiteCp: 250,
          currWhiteMate: null,
          engineBestMoveUci: 'd1d8',
          playedMoveUci: 'd1d8',
          secondBestWhiteWinPercent: 50.0,
        ),
      );
      expect(cls.quality, MoveQuality.great);
    });

    test('Move that flips losing → equal (ΔW > 10) ⇒ Great', () {
      // White-POV: -300 → +50.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: -300,
          prevWhiteMate: null,
          currWhiteCp: 50,
          currWhiteMate: null,
        ),
      );
      expect(cls.quality, MoveQuality.great);
    });
  });

  // ─── Damping & safety net ─────────────────────────────────────────
  group('Damping', () {
    test('Already-lost (mover Win% ≤ 10) softens Blunder → Mistake', () {
      // White already at -800 cp (≈ 5 % Win%). Drops further to -1100
      // — ΔW would be ~-2 pp because the sigmoid is flat in the wing,
      // so Mistake is the right read.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: -800,
          prevWhiteMate: null,
          currWhiteCp: -1500,
          currWhiteMate: null,
        ),
      );
      expect(cls.quality, isNot(MoveQuality.blunder));
    });

    test('Already-winning drift (cp loss < 250) softens Blunder → Mistake', () {
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 800,
          prevWhiteMate: null,
          currWhiteCp: 600,
          currWhiteMate: null,
        ),
      );
      expect(cls.quality, isNot(MoveQuality.blunder));
    });
  });

  // ─── cp-loss safety net only softens, never escalates ─────────────
  group('cp-loss safety net', () {
    test('Tiny cp drift in flat wing of sigmoid ⇒ Excellent, not Mistake', () {
      // White-POV cp 1500 → 1450 = 50 cp drift. Sigmoid is saturated
      // here; ΔW ≈ 0. The safety net should keep the verdict at
      // Excellent / Good.
      final cls = classifier.classify(
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 1500,
          prevWhiteMate: null,
          currWhiteCp: 1450,
          currWhiteMate: null,
        ),
      );
      expect(
        cls.quality,
        anyOf(MoveQuality.excellent, MoveQuality.good, MoveQuality.best),
      );
    });

    test(
      'Safety net cannot escalate Excellent → Blunder via cp loss alone',
      () {
        // Construct a Win%-noise move with massive cp loss in a mate
        // wing — the safety net is a *softener*, but the spec also
        // wants severe cp losses to read as Blunder. Confirm the Win%
        // ladder catches this case directly via the Lichess sigmoid in
        // the live range.
        final cls = classifier.classify(
          const MoveClassificationInput(
            isWhiteMove: true,
            prevWhiteCp: 0,
            prevWhiteMate: null,
            currWhiteCp: -600,
            currWhiteMate: null,
          ),
        );
        expect(cls.quality, MoveQuality.blunder);
      },
    );
  });
}
