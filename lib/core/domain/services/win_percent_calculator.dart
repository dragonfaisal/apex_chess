/// Lichess-style centipawn → Win% mapping, isolated as its own unit.
///
/// Phase A spec (§ 3.1.1):
///
///   1. Clamp `cp` to `[-1000, 1000]` to avoid numerical extremes
///      and keep the curve continuous with Lichess.
///   2. Apply the symmetric logistic:
///
///        Win% = 50 + 50 · (2 / (1 + exp(-0.00368208 · cp)) − 1)
///
///   3. Mate scores collapse to extremes:
///        mate +N (side to move delivers mate) ⇒ 100%
///        mate −N (side to move is being mated) ⇒ 0%
///
/// The output is **always white-POV** when `cp` and `mate` are given
/// in white-POV. Mover-POV transforms live in [MoverPerspective] —
/// keep this class side-agnostic so a single source of truth feeds
/// every downstream analyser.
///
/// No code is copied from Lichess (AGPL) or Chesskit (AGPL); this is
/// an original Dart implementation of the published math.
library;

import 'dart:math' as math;

class WinPercentCalculator {
  const WinPercentCalculator();

  /// Mid-game neutral Win% used by [forCp] when both `cp` and `mate`
  /// are null. Exposed as a constant so callers can recognise the
  /// "no signal" return value without re-deriving it.
  static const double neutral = 50.0;

  /// The Lichess sigmoid coefficient. Matches the value documented
  /// at https://lichess.org/page/accuracy.
  static const double k = 0.00368208;

  /// Clamp window applied to centipawn input, in centipawns.
  static const int clampMin = -1000;
  static const int clampMax = 1000;

  /// Maps a Stockfish white-POV verdict to white-POV Win% in [0, 100].
  ///
  /// `mate` takes precedence over `cp` when both are supplied —
  /// Stockfish only ever returns *one* of the two for a given line.
  /// `mate > 0` means white is delivering mate (Win% = 100); `mate
  /// < 0` means white is being mated (Win% = 0).
  ///
  /// `cp == null && mate == null` returns [neutral] (50.0). Callers
  /// that care about the "no eval yet" case should branch on the
  /// raw inputs before calling.
  double forCp({int? cp, int? mate}) {
    if (mate != null) {
      if (mate == 0) {
        // Stockfish never emits `score mate 0`, but if a malformed
        // upstream message reaches us we treat it as immediate loss
        // for the side to move (consistent with Lichess'
        // `Mate(0)` semantics in lila/modules/analyse).
        return 0.0;
      }
      return mate > 0 ? 100.0 : 0.0;
    }
    if (cp == null) return neutral;
    final clamped = cp.clamp(clampMin, clampMax);
    final w = 2.0 / (1.0 + math.exp(-k * clamped)) - 1.0;
    return 50.0 + 50.0 * w;
  }
}

/// Pure perspective math — stateless helpers that convert between
/// white-POV (the canonical engine view) and mover-POV (the
/// classifier's input).
///
/// Keeping this in its own class makes the perspective contract
/// **explicit**: every conversion is named and unit-tested, so a
/// future regression like "Black moves classified as White" cannot
/// silently slip in.
class MoverPerspective {
  const MoverPerspective();

  /// Sign multiplier applied to white-POV deltas to convert them to
  /// mover-POV. Spec § 3.2: `s = +1` for White, `s = -1` for Black.
  double sign({required bool isWhiteMove}) => isWhiteMove ? 1.0 : -1.0;

  /// Convert a white-POV Win% into a mover-POV Win%.
  ///
  ///   * White moves: mover-POV equals white-POV.
  ///   * Black moves: mover-POV is the complement (100 − white-POV)
  ///     so an "85% white" position reads as "15% black-POV".
  double moverWinPercent(double whiteWin, {required bool isWhiteMove}) =>
      isWhiteMove ? whiteWin : 100.0 - whiteWin;

  /// Convert a white-POV centipawn evaluation to mover-POV cp.
  /// Black flips the sign — losing 200 cp from White's POV is gaining
  /// 200 cp from Black's POV.
  int moverCp(int whiteCp, {required bool isWhiteMove}) =>
      isWhiteMove ? whiteCp : -whiteCp;

  /// Mover-POV Win% delta for a single ply: `(W_curr − W_prev) · s`.
  /// Negative values indicate the mover worsened their winning
  /// chances. This is the **primary** classification signal per
  /// spec § 3.2 / § 3.3.2.
  double deltaW({
    required double whiteWinBefore,
    required double whiteWinAfter,
    required bool isWhiteMove,
  }) =>
      (whiteWinAfter - whiteWinBefore) * sign(isWhiteMove: isWhiteMove);

  /// Mover-POV cp loss across a ply, when both sides of the
  /// comparison are CP-based (mate verdicts return null — mate-in-N
  /// can't be expressed as cp loss without an arbitrary cap).
  ///
  /// Positive return = mover lost cp; negative = mover gained cp.
  int? cpLoss({
    int? whiteCpBefore,
    int? whiteCpAfter,
    int? mateBefore,
    int? mateAfter,
    required bool isWhiteMove,
  }) {
    if (whiteCpBefore == null ||
        whiteCpAfter == null ||
        mateBefore != null ||
        mateAfter != null) {
      return null;
    }
    final movPrev = moverCp(whiteCpBefore, isWhiteMove: isWhiteMove);
    final movCurr = moverCp(whiteCpAfter, isWhiteMove: isWhiteMove);
    return movPrev - movCurr;
  }

  /// `true` when the mate verdict is *favourable* for the mover —
  /// i.e. the mover is the side delivering mate.
  ///
  /// Stockfish reports mate from the white-POV: `mate > 0` ⇒ White
  /// mates, `mate < 0` ⇒ Black mates. We translate via [isWhiteMove]
  /// so the predicate is symmetric for both colours.
  bool moverForcesMate(int? mate, {required bool isWhiteMove}) {
    if (mate == null) return false;
    return isWhiteMove ? mate > 0 : mate < 0;
  }
}
