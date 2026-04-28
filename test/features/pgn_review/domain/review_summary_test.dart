/// Unit tests for [ReviewSummaryService] — Phase 20.1 summary screen
/// contract.
///
/// Pins:
///   * Per-colour accuracy is computed from the correct side's plies.
///   * Counts match the timeline's classification distribution (Phase
///     A audit § 4: "counts match timeline exactly").
///   * Phase boundaries are stable (opening < 20, middlegame < 60,
///     endgame 60+).
///   * Biggest mistake is the user's most-negative-deltaW ply; best
///     user move prefers Brilliant / Great when present.
///   * Opening label composes ECO + name from the first annotated
///     ply, falling back to PGN headers.
library;

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/pgn_review/domain/review_summary.dart';
import 'package:flutter_test/flutter_test.dart';

MoveAnalysis _m({
  required int ply,
  required bool isWhite,
  required MoveQuality cls,
  double deltaW = 0,
  String san = 'Nf3',
  String? eco,
  String? openingName,
  String message = '',
}) =>
    MoveAnalysis(
      ply: ply,
      san: san,
      uci: 'g1f3',
      fenBefore: '',
      fenAfter: '',
      winPercentBefore: 50,
      winPercentAfter: 50 + deltaW,
      deltaW: deltaW,
      isWhiteMove: isWhite,
      classification: cls,
      ecoCode: eco,
      openingName: openingName,
      message: message,
    );

AnalysisTimeline _timeline(
  List<MoveAnalysis> moves, {
  Map<String, String> headers = const {},
}) =>
    AnalysisTimeline(
      moves: moves,
      startingFen:
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      headers: headers,
      winPercentages: [for (final m in moves) m.winPercentAfter],
    );

void main() {
  const svc = ReviewSummaryService();

  group('Counts match timeline exactly', () {
    test('Every classification tier is tallied independently', () {
      final t = _timeline([
        _m(ply: 0, isWhite: true, cls: MoveQuality.best),
        _m(ply: 1, isWhite: false, cls: MoveQuality.best),
        _m(ply: 2, isWhite: true, cls: MoveQuality.blunder, deltaW: -30),
        _m(ply: 3, isWhite: false, cls: MoveQuality.brilliant, deltaW: 5),
        _m(ply: 4, isWhite: true, cls: MoveQuality.book),
        _m(ply: 5, isWhite: false, cls: MoveQuality.forced),
        _m(ply: 6, isWhite: true, cls: MoveQuality.mistake, deltaW: -12),
        _m(ply: 7, isWhite: false, cls: MoveQuality.missedWin, deltaW: -20),
      ]);
      final s = svc.compute(timeline: t, userIsWhite: true);
      expect(s.counts.best, 2);
      expect(s.counts.blunder, 1);
      expect(s.counts.brilliant, 1);
      expect(s.counts.book, 1);
      expect(s.counts.forced, 1);
      expect(s.counts.mistake, 1);
      expect(s.counts.missedWin, 1);
      expect(s.counts.totalClassified, 8);
    });

    test(
        'Per-player split: user (White) and opponent (Black) counts add up '
        'to global totals', () {
      // Phase 20.1 device feedback § 4 — the summary screen now splits
      // counts per side. The legacy aggregate fields stay in lockstep
      // with `user.X + opponent.X` so archive cards (which read the
      // aggregates) never drift from the per-player view.
      final t = _timeline([
        _m(ply: 0, isWhite: true, cls: MoveQuality.best), // user
        _m(ply: 1, isWhite: false, cls: MoveQuality.blunder, deltaW: -30), // opp
        _m(ply: 2, isWhite: true, cls: MoveQuality.mistake, deltaW: -12), // user
        _m(ply: 3, isWhite: false, cls: MoveQuality.best), // opp
        _m(ply: 4, isWhite: true, cls: MoveQuality.brilliant, deltaW: 5), // user
        _m(ply: 5, isWhite: false, cls: MoveQuality.brilliant, deltaW: 5), // opp
      ]);
      final s = svc.compute(timeline: t, userIsWhite: true);
      // User = White
      expect(s.counts.user.best, 1);
      expect(s.counts.user.mistake, 1);
      expect(s.counts.user.brilliant, 1);
      expect(s.counts.user.blunder, 0);
      // Opponent = Black
      expect(s.counts.opponent.best, 1);
      expect(s.counts.opponent.blunder, 1);
      expect(s.counts.opponent.brilliant, 1);
      expect(s.counts.opponent.mistake, 0);
      // Aggregate equals user + opponent
      expect(s.counts.best, s.counts.user.best + s.counts.opponent.best);
      expect(s.counts.blunder,
          s.counts.user.blunder + s.counts.opponent.blunder);
      expect(s.counts.brilliant,
          s.counts.user.brilliant + s.counts.opponent.brilliant);
    });

    test(
        'Per-player split: when userIsWhite is null, splits stay empty '
        'and aggregate is preserved', () {
      // PGN paste with no side selector leaves userIsWhite=null.
      // We must still produce aggregates; the per-player split is
      // empty so the summary screen falls back to the legacy strip.
      final t = _timeline([
        _m(ply: 0, isWhite: true, cls: MoveQuality.best),
        _m(ply: 1, isWhite: false, cls: MoveQuality.blunder, deltaW: -30),
      ]);
      final s = svc.compute(timeline: t, userIsWhite: null);
      expect(s.counts.best, 1);
      expect(s.counts.blunder, 1);
      expect(s.counts.user.total, 0);
      expect(s.counts.opponent.total, 0);
    });
  });

  group('Accuracy per colour', () {
    test('User = White sees only White plies in accuracy', () {
      // White plies are all quiet best moves; Black plies are all
      // blunders. User=White should read near 100%; opponent=Black
      // should read a much lower number.
      final t = _timeline([
        for (int ply = 0; ply < 10; ply++)
          _m(
            ply: ply,
            isWhite: ply.isEven,
            cls: ply.isEven ? MoveQuality.best : MoveQuality.blunder,
            deltaW: ply.isEven ? 0 : -30,
          ),
      ]);
      final s = svc.compute(timeline: t, userIsWhite: true);
      expect(s.userAccuracyPct, greaterThan(95));
      expect(s.opponentAccuracyPct, lessThan(40));
    });

    test('User = Black flips the split', () {
      final t = _timeline([
        for (int ply = 0; ply < 10; ply++)
          _m(
            ply: ply,
            isWhite: ply.isEven,
            cls: ply.isEven ? MoveQuality.blunder : MoveQuality.best,
            deltaW: ply.isEven ? -30 : 0,
          ),
      ]);
      final s = svc.compute(timeline: t, userIsWhite: false);
      expect(s.userAccuracyPct, greaterThan(95));
      expect(s.opponentAccuracyPct, lessThan(40));
    });

    test('Unknown colour averages both sides', () {
      final t = _timeline([
        _m(ply: 0, isWhite: true, cls: MoveQuality.best),
        _m(ply: 1, isWhite: false, cls: MoveQuality.blunder, deltaW: -30),
      ]);
      final s = svc.compute(timeline: t, userIsWhite: null);
      // Symmetric — user==opponent since we can't tell them apart.
      expect(s.userAccuracyPct, s.opponentAccuracyPct);
    });
  });

  group('Phase boundaries', () {
    test('Opening / middlegame / endgame plies are bucketed correctly', () {
      final t = _timeline([
        // Opening: plies 0, 2 (user = White, even plies)
        _m(ply: 0, isWhite: true, cls: MoveQuality.best),
        _m(ply: 2, isWhite: true, cls: MoveQuality.best),
        // Middlegame: plies 20, 22, 24
        _m(ply: 20, isWhite: true, cls: MoveQuality.mistake, deltaW: -12),
        _m(ply: 22, isWhite: true, cls: MoveQuality.mistake, deltaW: -12),
        _m(ply: 24, isWhite: true, cls: MoveQuality.mistake, deltaW: -12),
        // Endgame: plies 60, 62
        _m(ply: 60, isWhite: true, cls: MoveQuality.blunder, deltaW: -30),
        _m(ply: 62, isWhite: true, cls: MoveQuality.blunder, deltaW: -30),
      ]);
      final s = svc.compute(timeline: t, userIsWhite: true);
      final opening = s.phases.firstWhere((p) => p.phase == GamePhase.opening);
      final middlegame =
          s.phases.firstWhere((p) => p.phase == GamePhase.middlegame);
      final endgame = s.phases.firstWhere((p) => p.phase == GamePhase.endgame);
      expect(opening.plies, 2);
      expect(middlegame.plies, 3);
      expect(endgame.plies, 2);
      // Endgame has the biggest average cp-loss → weakest phase.
      expect(s.weakestPhase?.phase, GamePhase.endgame);
    });

    test('weakestPhase is null on empty timeline', () {
      final t = _timeline(const []);
      final s = svc.compute(timeline: t, userIsWhite: true);
      expect(s.weakestPhase, isNull);
    });
  });

  group('Highlights', () {
    test('Biggest mistake = user\'s most negative deltaW', () {
      final t = _timeline([
        _m(ply: 0, isWhite: true, cls: MoveQuality.best, deltaW: 0),
        _m(ply: 2, isWhite: true, cls: MoveQuality.mistake, deltaW: -12),
        // User's worst ply — most negative deltaW.
        _m(
            ply: 4,
            isWhite: true,
            cls: MoveQuality.blunder,
            deltaW: -42,
            san: 'Nxf7??'),
        _m(ply: 6, isWhite: true, cls: MoveQuality.good, deltaW: 0),
        // Opponent blunder should NOT be picked up as user's mistake.
        _m(
            ply: 7,
            isWhite: false,
            cls: MoveQuality.blunder,
            deltaW: -50,
            san: 'Kh8??'),
      ]);
      final s = svc.compute(timeline: t, userIsWhite: true);
      expect(s.highlights.biggestMistake?.san, 'Nxf7??');
    });

    test('Best move prefers Brilliant over raw deltaW', () {
      final t = _timeline([
        _m(
            ply: 0,
            isWhite: true,
            cls: MoveQuality.best,
            deltaW: 30,
            san: 'Nf3'),
        // Slightly smaller deltaW but Brilliant → should be preferred.
        _m(
            ply: 2,
            isWhite: true,
            cls: MoveQuality.brilliant,
            deltaW: 20,
            san: 'Qxh7!!'),
      ]);
      final s = svc.compute(timeline: t, userIsWhite: true);
      expect(s.highlights.bestUserMove?.san, 'Qxh7!!');
    });

    test('No user mistakes → biggestMistake is null', () {
      final t = _timeline([
        _m(ply: 0, isWhite: true, cls: MoveQuality.best, deltaW: 0),
        _m(ply: 2, isWhite: true, cls: MoveQuality.best, deltaW: 0),
      ]);
      final s = svc.compute(timeline: t, userIsWhite: true);
      expect(s.highlights.biggestMistake, isNull);
    });
  });

  group('Opening label', () {
    test('Composes ECO + name from first annotated ply', () {
      final t = _timeline([
        _m(
            ply: 0,
            isWhite: true,
            cls: MoveQuality.book,
            eco: 'B90',
            openingName: 'Sicilian Defense: Najdorf'),
        _m(ply: 1, isWhite: false, cls: MoveQuality.book),
      ]);
      final s = svc.compute(timeline: t, userIsWhite: true);
      expect(s.openingLabel, 'B90 · Sicilian Defense: Najdorf');
    });

    test('Falls back to PGN headers when no ply annotates', () {
      final t = _timeline(
        [_m(ply: 0, isWhite: true, cls: MoveQuality.best)],
        headers: {'ECO': 'C65', 'Opening': 'Ruy Lopez'},
      );
      final s = svc.compute(timeline: t, userIsWhite: true);
      expect(s.openingLabel, 'C65 · Ruy Lopez');
    });

    test('Null when neither plies nor headers carry ECO/name', () {
      final t = _timeline([
        _m(ply: 0, isWhite: true, cls: MoveQuality.best),
      ]);
      final s = svc.compute(timeline: t, userIsWhite: true);
      expect(s.openingLabel, isNull);
    });
  });

  group('Result propagation', () {
    test('Result from headers is surfaced as-is', () {
      final t = _timeline(
        [_m(ply: 0, isWhite: true, cls: MoveQuality.best)],
        headers: {'Result': '1-0'},
      );
      final s = svc.compute(timeline: t, userIsWhite: true);
      expect(s.result, '1-0');
    });
  });
}
