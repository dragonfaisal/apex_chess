/// Material-trajectory helpers used by both analyzers (`local_game_analyzer`,
/// `cloud_game_analyzer`) to feed accurate `isFirstSacrificePly` /
/// `isTrivialRecapture` flags into [MoveClassifier].
///
/// Phase A integration audit (post-PR #18): the classifier itself implements
/// the spec's strict Brilliant gates, but the upstream pipelines were
/// hard-coding `isFirstSacrificePly = true` for every ply and never computing
/// `isTrivialRecapture`. That meant
///   * opponent's recapture of a sacrificed piece was eligible for Brilliant,
///   * the consolidating move two plies after a sac was eligible for Brilliant,
///   * a routine `NxN` trade ranked the same as a true exchange sacrifice.
///
/// This file fixes that by walking the *full* parsed move list once per
/// game and producing, for each ply:
///
///   * [SacrificeContext.isSacrifice]          — mover surrendered ≥ 3 piece
///                                                points and the opponent did
///                                                not immediately reclaim them;
///   * [SacrificeContext.isFirstSacrificePly]  — the mover was at material
///                                                parity (or better) entering
///                                                this ply, so the deficit
///                                                committed here is genuinely
///                                                new — not a follow-up to an
///                                                earlier sacrifice already
///                                                in flight;
///   * [SacrificeContext.isTrivialRecapture]   — the mover captured on the
///                                                exact square the opponent
///                                                just captured on, with no
///                                                net material change (or a
///                                                net gain) for the mover.
///
/// Engine-agnostic — every signal is derived purely from FEN strings + UCI
/// destination squares so the same data structure feeds both the on-device
/// pipeline and the cloud-eval pipeline without duplicating logic.
library;

import 'package:apex_chess/core/domain/services/position_heuristics.dart';

/// Per-ply sacrifice / recapture signal vector. Constructed by
/// [SacrificeTrajectory.analyze] and consumed by the analyzer pipelines.
class SacrificeContext {
  const SacrificeContext({
    required this.isSacrifice,
    required this.isFirstSacrificePly,
    required this.isTrivialRecapture,
  });

  /// Mover surrendered ≥ 3 piece points on this ply that the opponent's
  /// reply did not immediately win back. A `null` parse on either FEN
  /// makes this `false` so we never fabricate a sacrifice.
  final bool isSacrifice;

  /// True ⇔ the *mover-relative* material balance was ≥ 0 (parity or better)
  /// entering this ply. Once the mover is already a piece down, subsequent
  /// "sacrifices" are just throwing more material — never Brilliant.
  final bool isFirstSacrificePly;

  /// The opponent's previous ply was a capture on square *s*; the played
  /// move is a capture on the same square *s*; and the trade nets to ≥ 0
  /// material for the mover. Per spec § 3.6.6 such routine recaptures are
  /// never Brilliant.
  final bool isTrivialRecapture;

  /// A neutral context for plies the trajectory could not parse — defaults
  /// guarantee the classifier's Brilliant gate stays *closed* so we never
  /// award Brilliant on bad data.
  static const SacrificeContext unknown = SacrificeContext(
    isSacrifice: false,
    // Defaulting `isFirstSacrificePly` to `false` is the safe choice: when
    // we can't prove the mover is at parity entering the ply, the Brilliant
    // gate stays shut. The legacy default of `true` is exactly the bug we
    // are correcting here.
    isFirstSacrificePly: false,
    isTrivialRecapture: false,
  );
}

/// One row of the FEN list passed into [SacrificeTrajectory.analyze]. The
/// analyzer pipelines already build this as part of PGN parsing — we just
/// re-shape it so this file does not depend on `dartchess` directly.
class TrajectoryPly {
  const TrajectoryPly({
    required this.fenBefore,
    required this.fenAfter,
    required this.isWhiteMove,
    required this.targetSquare,
  });

  /// FEN of the position the mover faced.
  final String fenBefore;

  /// FEN after the played ply was made.
  final String fenAfter;

  /// Side that played the ply (`true` = White).
  final bool isWhiteMove;

  /// Algebraic destination square of the played move (e.g. `e4`, `g1`).
  /// Used to detect recaptures — the second leg of a trade lands on the
  /// same square as the first leg.
  final String targetSquare;
}

class SacrificeTrajectory {
  const SacrificeTrajectory._();

  /// Analyse [plies] and return one [SacrificeContext] per ply.
  ///
  /// Two-pass implementation:
  ///   1. For each ply, sample the *mover-perspective* material balance
  ///      after the opponent's reply (or after the played ply on the last
  ///      ply of the game). `isSacrifice` fires when the mover-perspective
  ///      delta is ≤ −3 piece points.
  ///   2. `isFirstSacrificePly` is derived from the *entering* mover-
  ///      perspective balance: ≥ 0 means the mover was at parity entering
  ///      this ply.
  ///   3. `isTrivialRecapture` is detected by checking whether the
  ///      previous ply landed on the same square *and* the local two-ply
  ///      material delta is ≥ 0 for the mover.
  static List<SacrificeContext> analyze(List<TrajectoryPly> plies) {
    final out = List<SacrificeContext>.filled(plies.length, SacrificeContext.unknown);
    for (var i = 0; i < plies.length; i++) {
      final p = plies[i];
      final balanceBefore = PositionHeuristics.materialBalanceFromFen(p.fenBefore);
      if (balanceBefore == null) {
        out[i] = SacrificeContext.unknown;
        continue;
      }
      final moverSign = p.isWhiteMove ? 1 : -1;

      // Resolve the post-reply balance: we want to know what stands once
      // the opponent's natural recapture (if any) has settled. Without
      // this, *any* capture by the mover that loses points to the
      // capturing piece's defender would register as a sacrifice.
      final next = i + 1 < plies.length ? plies[i + 1] : null;
      final referenceFen = next?.fenAfter ?? p.fenAfter;
      final balanceAfter =
          PositionHeuristics.materialBalanceFromFen(referenceFen);
      if (balanceAfter == null) {
        out[i] = SacrificeContext.unknown;
        continue;
      }

      final moverDelta = (balanceAfter - balanceBefore) * moverSign;
      final isSac = moverDelta <= -3;

      final moverEnteringBalance = balanceBefore * moverSign;
      // "First sacrifice" means: at the moment the mover commits to this
      // ply, no prior sacrifice deficit is already in flight. We're a touch
      // generous with the parity floor (−1) so a single hanging pawn does
      // not lock out every subsequent Brilliant candidate.
      final isFirst = moverEnteringBalance >= -1;

      // Trivial recapture: previous ply was a capture by the *opponent*
      // on the square the mover just captured on, and the two-ply local
      // material delta is non-negative for the mover. This is the
      // "they took, I took back" pattern that should never be Brilliant.
      bool trivialRecap = false;
      if (i >= 1) {
        final prev = plies[i - 1];
        final samesq = prev.targetSquare.isNotEmpty &&
            prev.targetSquare == p.targetSquare;
        if (samesq) {
          // Two plies ago is the position the *mover* faced before the
          // opponent's capture. Compute the round-trip material delta
          // from the mover's perspective; ≥ 0 ⇒ they're square or ahead
          // ⇒ trivial recapture.
          final moverBalanceBeforeOpp = i >= 2
              ? PositionHeuristics.materialBalanceFromFen(plies[i - 1].fenBefore)
              : balanceBefore;
          if (moverBalanceBeforeOpp != null) {
            final roundTrip = (balanceAfter - moverBalanceBeforeOpp) * moverSign;
            trivialRecap = roundTrip >= 0;
          } else {
            trivialRecap = true;
          }
        }
      }

      out[i] = SacrificeContext(
        isSacrifice: isSac,
        isFirstSacrificePly: isFirst,
        isTrivialRecapture: trivialRecap,
      );
    }
    return out;
  }
}
