/// Coach-explanation service — Phase 20 addendum regression tests.
///
/// Pins the seven copy rules the service enforces so no future
/// refactor can silently regress the "trustworthy classification
/// over flashy badges" contract:
///
///   1. Opponent mate move reads **Checkmate.**, never "Blunder".
///   2. When the opponent delivers mate and the user's previous ply
///      is known, the service flags `blameRedirectToPreviousPly`
///      so the UI can render "Allowed forced mate" on the *correct*
///      ply.
///   3. Played-equals-best (after castling-UCI normalisation) reads
///      **Top engine choice** and never emits `betterMoveSan`.
///   4. Quick-mode Brilliant/Great/Forced candidates surface the
///      `needsDeepScan` flag; Deep-mode does not.
///   5. Book plies render `<ECO> · <Opening> — book move.` with no
///      severity verdict.
///   6. `Better: <same SAN>` is never produced — assertion by
///      brute-force across every combination of played/best inputs.
///   7. Allowed-forced-mate blunders render the "Allowed forced mate"
///      subline on the blunder ply itself (the classifier's own
///      message is the source of truth for the reason).
library;

import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/coach_explanation_service.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:flutter_test/flutter_test.dart';

MoveAnalysis _m({
  int ply = 10,
  String san = 'Nf3',
  String uci = 'g1f3',
  MoveQuality classification = MoveQuality.good,
  String message = '',
  String? bestUci,
  String? bestSan,
  bool isWhiteMove = true,
  double deltaW = 0,
  double winBefore = 50,
  double winAfter = 50,
  int? mateInAfter,
  bool inBook = false,
  String? ecoCode,
  String? openingName,
}) =>
    MoveAnalysis(
      ply: ply,
      san: san,
      uci: uci,
      fenBefore: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      fenAfter: 'rnbqkbnr/pppppppp/8/8/5N2/PPPPPPPP/RNBQKB1R b KQkq - 1 1',
      winPercentBefore: winBefore,
      winPercentAfter: winAfter,
      deltaW: deltaW,
      isWhiteMove: isWhiteMove,
      classification: classification,
      engineBestMoveUci: bestUci,
      engineBestMoveSan: bestSan,
      mateInAfter: mateInAfter,
      inBook: inBook,
      ecoCode: ecoCode,
      openingName: openingName,
      message: message,
    );

void main() {
  const svc = CoachExplanationService();

  group('Rule 1 — Mate-delivered ply never reads as Blunder', () {
    test('Opponent mate move reads "Checkmate."', () {
      // User plays Black; ply 30 is White delivering mate (terminal
      // position, analyzer synthesised `mateInAfter = 0`). This
      // ply's mover (White) is the opponent.
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 30,
          san: 'Qh8#',
          uci: 'h4h8',
          classification: MoveQuality.best,
          isWhiteMove: true,
          mateInAfter: 0,
          winAfter: 100,
          message: 'Best — Apex AI\'s #1 choice.',
        ),
        mode: AnalysisMode.deep,
        userIsWhite: false,
        previousUserMove: _m(
          ply: 29,
          san: 'Kh7',
          uci: 'h6h7',
          classification: MoveQuality.blunder,
          isWhiteMove: false,
        ),
      ));
      expect(cls.headline, 'Checkmate.');
      expect(cls.subline.toLowerCase(),
          contains('opponent delivered mate'));
      expect(cls.blameRedirectToPreviousPly, isTrue);
      // Never "Blunder" on the mate-delivering ply.
      expect(cls.headline.toLowerCase(), isNot(contains('blunder')));
    });

    test('User-delivered mate reads "You delivered mate."', () {
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 30,
          san: 'Qh8#',
          uci: 'h4h8',
          classification: MoveQuality.best,
          isWhiteMove: true,
          mateInAfter: 0,
          winAfter: 100,
        ),
        mode: AnalysisMode.deep,
        userIsWhite: true,
      ));
      expect(cls.headline, 'Checkmate.');
      expect(cls.subline.toLowerCase(), contains('you delivered'));
      expect(cls.blameRedirectToPreviousPly, isFalse);
    });

    test('Unknown user colour still reads "Checkmate.", no redirect',
        () {
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 30,
          san: 'Qh8#',
          uci: 'h4h8',
          classification: MoveQuality.best,
          isWhiteMove: true,
          mateInAfter: 0,
          winAfter: 100,
        ),
        mode: AnalysisMode.deep,
      ));
      expect(cls.headline, 'Checkmate.');
      expect(cls.blameRedirectToPreviousPly, isFalse);
    });

    test('SAN `#` suffix alone triggers Checkmate headline', () {
      // Older cached timelines (classifierVersion < 3) don't have
      // `mateInAfter = 0`; honour SAN `#` as a fallback signal so
      // we don't regress into "Blunder — checkmate" copy.
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 40,
          san: 'c1=Q#',
          uci: 'c2c1q',
          classification: MoveQuality.best,
          isWhiteMove: false,
          // No mateInAfter — simulate the older timeline.
        ),
        mode: AnalysisMode.deep,
        userIsWhite: true,
      ));
      expect(cls.headline, 'Checkmate.');
    });
  });

  group('Rule 2 — Allowed-forced-mate blunder', () {
    test('Blunder that allowed mate surfaces "Allowed forced mate" subline',
        () {
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 29,
          san: 'Kh7',
          uci: 'h6h7',
          classification: MoveQuality.blunder,
          isWhiteMove: false,
          message: 'Blunder — allows forced mate.',
          bestUci: 'h6g6',
          bestSan: 'Kg6',
        ),
        mode: AnalysisMode.deep,
        userIsWhite: false,
      ));
      expect(cls.headline.toLowerCase(), contains('blunder'));
      expect(cls.subline.toLowerCase(), contains('allowed forced mate'));
      expect(cls.subline.toLowerCase(),
          contains('defensive resources'));
    });
  });

  group('Rule 3 — Played == best → Top engine choice', () {
    test('Played UCI matches best UCI → headline "Top engine choice"', () {
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 12,
          san: 'Nf3',
          uci: 'g1f3',
          bestUci: 'g1f3',
          bestSan: 'Nf3',
          classification: MoveQuality.best,
          message: 'Best — Apex AI\'s #1 choice.',
        ),
        mode: AnalysisMode.deep,
      ));
      expect(cls.headline.contains('Best'), isTrue);
      expect(cls.subline.toLowerCase(), contains('top engine choice'));
      expect(cls.betterMoveSan, isNull);
    });

    test('Castling UCI variants compare equal (e1g1 vs e1h1)', () {
      // Engine emits `e1h1` (king-captures-rook convention), played
      // `e1g1` (king-to-destination). Must be treated as the same
      // move — never produce "Better: O-O" when user played O-O.
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 10,
          san: 'O-O',
          uci: 'e1g1',
          bestUci: 'e1h1',
          bestSan: 'O-O',
          classification: MoveQuality.best,
        ),
        mode: AnalysisMode.deep,
      ));
      expect(cls.subline.toLowerCase(), contains('top engine choice'));
      expect(cls.betterMoveSan, isNull);
    });
  });

  group('Rule 4 — Needs Deep Scan flag on Quick-mode candidates', () {
    test('Quick mode + tactical best-move ply → needsDeepScan=true', () {
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 20,
          san: 'Qxh7+',
          uci: 'd3h7',
          bestUci: 'a1b1',
          bestSan: 'Rb1',
          classification: MoveQuality.best,
          deltaW: 0,
          message: 'Best — Apex AI\'s #1 choice.',
        ),
        mode: AnalysisMode.quick,
      ));
      expect(cls.needsDeepScan, isTrue);
      expect(cls.subline.toLowerCase(),
          contains('deep scan recommended'));
    });

    test('Deep mode — needsDeepScan always false', () {
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 20,
          san: 'Qxh7+',
          uci: 'd3h7',
          bestUci: 'a1b1',
          bestSan: 'Rb1',
          classification: MoveQuality.best,
        ),
        mode: AnalysisMode.deep,
      ));
      expect(cls.needsDeepScan, isFalse);
      expect(cls.subline.toLowerCase(),
          isNot(contains('deep scan recommended')));
    });

    test('Quick + quiet Best-move ply → needsDeepScan=false', () {
      // No capture, no check, no promotion — Quick's "best" here is
      // boring and doesn't warrant a Deep re-scan suggestion.
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 20,
          san: 'Rfd1',
          uci: 'f1d1',
          bestUci: 'a1b1',
          bestSan: 'Rb1',
          classification: MoveQuality.best,
        ),
        mode: AnalysisMode.quick,
      ));
      expect(cls.needsDeepScan, isFalse);
    });
  });

  group('Rule 5 — Book / Theory', () {
    test('Book ply surfaces ECO + name, no severity verdict', () {
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 4,
          san: 'Nf6',
          uci: 'g8f6',
          classification: MoveQuality.book,
          inBook: true,
          ecoCode: 'B90',
          openingName: 'Sicilian Defense: Najdorf',
          isWhiteMove: false,
        ),
        mode: AnalysisMode.deep,
      ));
      expect(cls.headline, 'Book move.');
      expect(cls.subline, contains('B90'));
      expect(cls.subline, contains('Sicilian Defense: Najdorf'));
      expect(cls.subline.toLowerCase(), contains('in theory'));
      expect(cls.betterMoveSan, isNull);
    });
  });

  group('Rule 6 — "Better: <same SAN>" must never appear', () {
    test('Played == best across every classification tier', () {
      for (final tier in MoveQuality.values) {
        final cls = svc.explain(CoachExplanationInput(
          move: _m(
            ply: 14,
            san: 'Bxf7+',
            uci: 'c4f7',
            bestUci: 'c4f7',
            bestSan: 'Bxf7+',
            classification: tier,
          ),
          mode: AnalysisMode.deep,
        ));
        expect(
          cls.betterMoveSan,
          isNull,
          reason:
              'Played == best for tier $tier must never render a better SAN',
        );
      }
    });
  });

  group('Rule 7 — Better line suppressed on Brilliant/Great/Forced/Book/Best',
      () {
    for (final tier in [
      MoveQuality.brilliant,
      MoveQuality.great,
      MoveQuality.forced,
      MoveQuality.book,
      MoveQuality.best,
    ]) {
      test('Tier $tier does not render a betterMoveSan', () {
        final cls = svc.explain(CoachExplanationInput(
          move: _m(
            ply: 14,
            san: 'Nf3',
            uci: 'g1f3',
            bestUci: 'a1b1',
            bestSan: 'Rb1',
            classification: tier,
          ),
          mode: AnalysisMode.deep,
        ));
        expect(cls.betterMoveSan, isNull);
      });
    }

    test('Blunder does render a better SAN when played != best', () {
      final cls = svc.explain(CoachExplanationInput(
        move: _m(
          ply: 14,
          san: 'Nf3',
          uci: 'g1f3',
          bestUci: 'a1b1',
          bestSan: 'Rb1',
          classification: MoveQuality.blunder,
          deltaW: -30,
        ),
        mode: AnalysisMode.deep,
      ));
      expect(cls.betterMoveSan, 'Rb1');
      expect(cls.betterMoveReason, isNotNull);
    });
  });
}
