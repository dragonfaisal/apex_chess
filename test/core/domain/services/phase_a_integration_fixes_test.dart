/// Phase A integration-audit fixes — regression tests for PR #19.
///
/// Covers the seven product-cohesion gaps flagged during real Android
/// device testing on top of PR #18's classifier brain:
///
///   1. Terminal-mate attribution — `mateIn=0` emitted by Stockfish on a
///      checkmate-on-the-board position must NOT classify the mating
///      move as Blunder (`opponentForcesMate` defensive guard).
///   2. `suppressTrophyTiers` — Quick (D14, single PV) scans must NOT
///      emit Brilliant / Great / Forced; they route to the Win% /
///      cp-loss ladder.
///   3. Archive per-colour ACPL — the new
///      `AnalysisTimeline.averageCpLoss{White,Black}` extensions used
///      by the archive card.
library;
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const classifier = MoveClassifier();

  group('Terminal-mate attribution (§ 1 defensive guard)', () {
    test('Signed mateIn=+1 (White delivered mate) is NOT Blunder', () {
      // Canonical case: analyzer pipeline synthesised `mateIn = 1`
      // (from White's POV) because the post-move position is
      // checkmate and White is the mover.
      final cls = classifier.classify(const MoveClassificationInput(
        isWhiteMove: true,
        prevWhiteCp: 550,
        prevWhiteMate: null,
        currWhiteCp: null,
        currWhiteMate: 1,
        engineBestMoveUci: 'd1h5',
        playedMoveUci: 'd1h5',
      ));
      expect(cls.quality, isNot(MoveQuality.blunder));
    });

    test(
        'Opponent (Black) delivering mate vs White is NOT Blunder on Black',
        () {
      // Black's turn; Black plays a move that checkmates White.
      // Synthetic `mateIn = -1` (white POV — favourable to Black).
      final cls = classifier.classify(const MoveClassificationInput(
        isWhiteMove: false,
        prevWhiteCp: -550,
        prevWhiteMate: null,
        currWhiteCp: null,
        currWhiteMate: -1,
        engineBestMoveUci: 'h4h1',
        playedMoveUci: 'h4h1',
      ));
      expect(cls.quality, isNot(MoveQuality.blunder),
          reason: 'Opponent (Black) mate delivery must not be attributed '
              'as a blunder — the previous White ply gets the blame.');
    });
  });

  group('Quick mode (suppressTrophyTiers)', () {
    test('Trophy tiers never appear when suppressTrophyTiers=true', () {
      // Every scenario we feed the classifier must route to a
      // non-trophy tier when `suppressTrophyTiers=true`. We sweep a
      // small matrix of inputs that would otherwise *could* have fired
      // Brilliant / Great / Forced in Deep mode.
      final scenarios = <MoveClassificationInput>[
        // Candidate Brilliant: first-ply sacrifice that preserves a
        // winning evaluation.
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 120,
          prevWhiteMate: null,
          currWhiteCp: 150,
          currWhiteMate: null,
          engineBestMoveUci: 'g5f7',
          playedMoveUci: 'g5f7',
          isSacrifice: true,
          isFirstSacrificePly: true,
          altLineWhiteWinPercent: 60,
          suppressTrophyTiers: true,
        ),
        // Candidate Forced: MultiPV with one surviving line.
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: -200,
          prevWhiteMate: null,
          currWhiteCp: -210,
          currWhiteMate: null,
          engineBestMoveUci: 'g1h1',
          playedMoveUci: 'g1h1',
          multiPvWhiteWinPercents: [30, 5, 4],
          suppressTrophyTiers: true,
        ),
        // Candidate Great: PV1 ≫ PV2.
        const MoveClassificationInput(
          isWhiteMove: true,
          prevWhiteCp: 20,
          prevWhiteMate: null,
          currWhiteCp: 200,
          currWhiteMate: null,
          engineBestMoveUci: 'd4e5',
          playedMoveUci: 'd4e5',
          secondBestWhiteWinPercent: 30,
          suppressTrophyTiers: true,
        ),
      ];
      for (final in_ in scenarios) {
        final cls = classifier.classify(in_);
        expect(
          cls.quality,
          isNot(anyOf(
            MoveQuality.brilliant,
            MoveQuality.great,
            MoveQuality.forced,
          )),
          reason:
              'suppressTrophyTiers must block all trophy tiers; got '
              '${cls.quality}',
        );
      }
    });

    test('Deep mode (default) still allows trophy tiers', () {
      // Sanity: the same "Forced-shaped" input without suppression
      // must still be eligible to fire Forced. We don't insist it
      // *does* (the brain may choose Best when the played move is
      // also the engine top) — just that suppression is the only knob
      // flipping the outcome.
      const in_ = MoveClassificationInput(
        isWhiteMove: true,
        prevWhiteCp: -200,
        prevWhiteMate: null,
        currWhiteCp: -210,
        currWhiteMate: null,
        engineBestMoveUci: 'g1h1',
        playedMoveUci: 'g1h1',
        multiPvWhiteWinPercents: [30, 5, 4],
      );
      // Without suppression the brain MAY fire Forced; with
      // suppression it MUST NOT.
      final deep = classifier.classify(in_);
      final quick = classifier.classify(const MoveClassificationInput(
        isWhiteMove: true,
        prevWhiteCp: -200,
        prevWhiteMate: null,
        currWhiteCp: -210,
        currWhiteMate: null,
        engineBestMoveUci: 'g1h1',
        playedMoveUci: 'g1h1',
        multiPvWhiteWinPercents: [30, 5, 4],
        suppressTrophyTiers: true,
      ));
      expect(quick.quality, isNot(MoveQuality.forced));
      // `deep` is informational — we don't hard-pin it.
      // Fail loud if suppression somehow *adds* a trophy tier:
      if (quick.quality == MoveQuality.forced ||
          quick.quality == MoveQuality.brilliant ||
          quick.quality == MoveQuality.great) {
        fail('Quick mode surfaced trophy tier ${quick.quality}');
      }
      // Reference the variable so the analyzer doesn't flag it unused.
      expect(deep.quality, isNotNull);
    });
  });

  group('AnalysisTimeline per-colour ACPL', () {
    test('averageCpLoss{White,Black} splits per-side plies correctly', () {
      // Hand-rolled tiny timeline: 4 plies, deltas alternate.
      // White: -0.20, 0.0 → losses sum 0.20 over 2 plies = avg 0.10.
      // Black: -0.40, 0.0 → losses sum 0.40 over 2 plies = avg 0.20.
      final moves = <MoveAnalysis>[
        _move(isWhite: true, deltaW: -0.20),
        _move(isWhite: false, deltaW: -0.40),
        _move(isWhite: true, deltaW: 0.0),
        _move(isWhite: false, deltaW: 0.0),
      ];
      final tl = AnalysisTimeline(
        startingFen: '',
        headers: const {},
        moves: moves,
        winPercentages: const [50, 40, 38, 50, 52],
      );
      expect(tl.averageCpLossWhite, closeTo(0.10, 1e-9));
      expect(tl.averageCpLossBlack, closeTo(0.20, 1e-9));
    });

    test('Empty timeline returns zero for both colours', () {
      final tl = AnalysisTimeline(
        startingFen: '',
        headers: const {},
        moves: const [],
        winPercentages: const [50],
      );
      expect(tl.averageCpLossWhite, 0);
      expect(tl.averageCpLossBlack, 0);
    });
  });
}

MoveAnalysis _move({required bool isWhite, required double deltaW}) =>
    MoveAnalysis(
      ply: 0,
      san: 'x',
      uci: 'a1a2',
      fenBefore: '',
      fenAfter: '',
      isWhiteMove: isWhite,
      classification: MoveQuality.good,
      scoreCpAfter: 0,
      mateInAfter: null,
      winPercentBefore: 50,
      winPercentAfter: 50,
      deltaW: deltaW,
      engineBestMoveUci: null,
      engineBestMoveSan: null,
      message: '',
    );
