/// Phase A move-classification brain.
///
/// Win% delta is the **primary** signal; cp-loss is a *safety net*
/// that softens (never escalates) the Win%-derived tier so a
/// flat-but-tiny cp drift in the wings of the sigmoid never reads
/// as Mistake / Blunder. All thresholds come from the published
/// Apex Chess spec (see `docs/specs/apex_chess_analysis_training_ux_spec.md`).
///
/// No code is copied from Lichess (AGPL) or Chesskit (AGPL) — only
/// the published math (Win% sigmoid) and the boundary numbers
/// (Δ Win% per tier) are used, both of which are public domain.
///
/// Thresholds (from spec § 3.3.2 + § 3.6):
///
///   ΔW < −20       ⇒ Blunder
///   −20 ≤ ΔW < −10 ⇒ Mistake
///   −10 ≤ ΔW < −5  ⇒ Inaccuracy
///   −5 ≤ ΔW < −2   ⇒ Good
///   ΔW ≥ −2        ⇒ Excellent (Best when matches engine #1)
///
/// Special tiers layer on top:
///
///   * **Book**       – caller's `isBook` flag is true *and* the
///                       drop is not severe (ΔW > −20).
///   * **Forced**     – only one of `multiPvWinPercents` is within
///                       5 pp of the best line; mover played that
///                       line; others drop > 20 pp.
///   * **Missed Win** – mover was winning (mover Win% > 70 before)
///                       and chose a line that drops the position
///                       to roughly equal/worse (mover Win% < 60
///                       after) **or** ΔW ≤ −20 from a winning
///                       position.
///   * **Great**      – ΔW > 10 *and* the move is a clear gap
///                       above the second-best line (≥ 10 pp), or
///                       the move flips the eval region (lost →
///                       equal, equal → winning).
///   * **Brilliant**  – sacrifice + non-recapture + near-best +
///                       ΔW ≥ −2 + mover-POV Win% post-move ≥ 50 +
///                       no alternative line trivially winning +
///                       not already crushing + does not allow
///                       opponent forced mate + caller asserts the
///                       ply is the *first* ply committing the
///                       sacrifice.
library;

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart'
    show MoveQuality, normalizeCastlingUci;
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';

/// Result of a single classification pass — a thin value type so the
/// classifier is testable in isolation.
class MoveClassification {
  const MoveClassification({
    required this.quality,
    required this.deltaW,
    required this.winPercentBefore,
    required this.winPercentAfter,
    required this.moverCpLoss,
    required this.message,
    this.engineBestMoveUci,
  });

  final MoveQuality quality;

  /// Mover-POV Win% delta across the played ply. Negative ⇒ mover
  /// worsened their position; positive ⇒ improved.
  final double deltaW;

  /// White-POV Win% before / after the played move. Stored as
  /// white-POV so a downstream graph can render the eval line
  /// directly.
  final double winPercentBefore;
  final double winPercentAfter;

  /// Mover-POV centipawn loss; `null` whenever either side of the
  /// comparison is a mate verdict.
  final int? moverCpLoss;

  /// Human-readable, terse explanation. Always single-line so the
  /// review card / move report can render without truncation
  /// surprises.
  final String message;

  /// Engine's #1 candidate UCI for the position before the move,
  /// stored verbatim so the UI can build a "better-move" arrow.
  final String? engineBestMoveUci;
}

/// Inputs collected by the analysis pipeline before classification
/// runs. A single struct so a) the parameter list does not balloon
/// and b) tests can construct synthetic positions cleanly.
class MoveClassificationInput {
  const MoveClassificationInput({
    required this.isWhiteMove,
    required this.prevWhiteCp,
    required this.prevWhiteMate,
    required this.currWhiteCp,
    required this.currWhiteMate,
    this.engineBestMoveUci,
    this.playedMoveUci,
    this.secondBestWhiteWinPercent,
    this.multiPvWhiteWinPercents,
    this.altLineWhiteWinPercent,
    this.isSacrifice = false,
    this.isTrivialRecapture = false,
    this.isFirstSacrificePly = true,
    this.isBook = false,
    this.openingName,
    this.ecoCode,
    this.suppressTrophyTiers = false,
  });

  /// Side that just made the played move.
  final bool isWhiteMove;

  /// Engine verdict (white-POV) of the position **before** the move.
  /// Mate score takes precedence over cp when present.
  final int? prevWhiteCp;
  final int? prevWhiteMate;

  /// Engine verdict (white-POV) of the position **after** the move.
  final int? currWhiteCp;
  final int? currWhiteMate;

  /// Engine's #1 candidate from the previous position (UCI). When
  /// the played UCI matches this, the move is at least Best.
  final String? engineBestMoveUci;
  final String? playedMoveUci;

  /// White-POV Win% of the engine's #2 line at the previous
  /// position. Used by the Great gate so we can compare PV1 vs PV2.
  final double? secondBestWhiteWinPercent;

  /// MultiPV white-POV Win% list (PV1, PV2, …). Used by the Forced
  /// gate (only one line stays within 5 pp of the best, others drop
  /// > 20 pp).
  final List<double>? multiPvWhiteWinPercents;

  /// White-POV Win% of the *best non-sacrificial* alternative from
  /// the previous position. Used by the Brilliant gate so a "win
  /// more" sacrifice (where a non-sac line is already trivially
  /// winning) can be excluded.
  final double? altLineWhiteWinPercent;

  /// Caller asserts the played move surrendered ≥ minor-piece
  /// material. The classifier never invents sacrifices on its own.
  final bool isSacrifice;

  /// Caller asserts the move is a routine recapture (e.g. opponent
  /// played NxN, mover played NxN). Trivial recaptures can never
  /// be Brilliant per spec § 3.6.6.
  final bool isTrivialRecapture;

  /// Caller asserts the played ply is the **first** ply that
  /// commits the sacrificial material deficit. Without this gate
  /// the analyser would label every consolidating move that
  /// follows the sac as Brilliant, which is wrong (spec § 3.6.6.4).
  final bool isFirstSacrificePly;

  /// Caller flagged the position as inside an opening-book line.
  /// When true the default classification is Book/Theory unless a
  /// severe engine drop overrides it.
  final bool isBook;

  /// Optional opening metadata for the result message.
  final String? openingName;
  final String? ecoCode;

  /// When `true`, the classifier skips the Brilliant / Great / Forced
  /// short-circuits and routes straight to the Win% / cp-loss ladder.
  ///
  /// Used by Quick scans (D14, single PV) — those scans cannot honestly
  /// verify a Brilliant / Great / Forced claim (the spec requires
  /// deeper search + MultiPV for all three, § 3.6.2/4/6). Surfacing
  /// a trophy tier off a shallow search misleads the user, so Quick
  /// mode emits only Blunder / Mistake / Inaccuracy / Good / Excellent /
  /// Best / Book / MissedWin.
  final bool suppressTrophyTiers;
}

class MoveClassifier {
  const MoveClassifier({
    WinPercentCalculator winCalc = const WinPercentCalculator(),
    MoverPerspective perspective = const MoverPerspective(),
  }) : _win = winCalc,
       _persp = perspective;

  final WinPercentCalculator _win;
  final MoverPerspective _persp;

  // ── Spec thresholds (§ 3.3.2 / § 3.6) ────────────────────────────────
  // Pulled out as static consts so tests can reference them by name
  // and reviewers can audit a single place when the spec moves.

  /// ΔW > this ⇒ Excellent / Best — within the noise band.
  static const double dwExcellent = -2.0;

  /// ΔW (−2..−5] ⇒ Good / Slightly worse.
  static const double dwGood = -5.0;

  /// ΔW (−5..−10] ⇒ Inaccuracy.
  static const double dwInaccuracy = -10.0;

  /// ΔW (−10..−20] ⇒ Mistake.
  static const double dwMistake = -20.0;
  // ΔW < −20 ⇒ Blunder.

  /// Mover-POV Win% above which a position counts as "winning" — used
  /// by the Missed Win gate (§ 3.6.5).
  static const double winningCutoff = 70.0;

  /// Mover-POV Win% below which a position counts as "equal/worse"
  /// after a Missed Win.
  static const double equalCeiling = 60.0;

  /// "Already crushing" cutoff used by the Brilliant guard
  /// (§ 3.6.6.3). 90 pp matches the spec.
  static const double crushingCutoff = 90.0;

  /// "Trivially winning" Win% threshold for the alternative-line
  /// guard (§ 3.6.6.2) — White ≥ 97 / Black ≤ 3.
  static const double triviallyWinning = 97.0;

  /// Brilliant cp-loss cap. The spec asks for "no significant Win%
  /// loss"; in practice we bound the cp-loss too so a 200 cp swing
  /// never reads as Brilliant even when ΔW happens to land in the
  /// noise band.
  static const int brilliantCpLossCap = 40;

  /// Forced-move tolerance: every non-mover MultiPV line must drop
  /// at least this far below the best line (§ 3.6.2).
  static const double forcedDropPp = 20.0;

  /// Forced-move best-line tolerance: the mover's line must stay
  /// within this much of the best line.
  static const double forcedTolerancePp = 5.0;

  /// Great gate: PV1 must beat PV2 by at least this much (§ 3.6.4).
  static const double greatPv1MinusPv2Pp = 10.0;

  /// Classify a single ply.
  MoveClassification classify(MoveClassificationInput in_) {
    final whiteWinBefore = _win.forCp(
      cp: in_.prevWhiteCp,
      mate: in_.prevWhiteMate,
    );
    final whiteWinAfter = _win.forCp(
      cp: in_.currWhiteCp,
      mate: in_.currWhiteMate,
    );

    final deltaW = _persp.deltaW(
      whiteWinBefore: whiteWinBefore,
      whiteWinAfter: whiteWinAfter,
      isWhiteMove: in_.isWhiteMove,
    );

    final moverWinBefore = _persp.moverWinPercent(
      whiteWinBefore,
      isWhiteMove: in_.isWhiteMove,
    );
    final moverWinAfter = _persp.moverWinPercent(
      whiteWinAfter,
      isWhiteMove: in_.isWhiteMove,
    );

    final cpLossMover = _persp.cpLoss(
      whiteCpBefore: in_.prevWhiteCp,
      whiteCpAfter: in_.currWhiteCp,
      mateBefore: in_.prevWhiteMate,
      mateAfter: in_.currWhiteMate,
      isWhiteMove: in_.isWhiteMove,
    );

    final moverForcesMate = _persp.moverForcesMate(
      in_.currWhiteMate,
      isWhiteMove: in_.isWhiteMove,
    );
    // Defensive guard against a `mate == 0` leaking through from the
    // engine layer. Stockfish reports `mate 0` from side-to-move POV on
    // a checkmate-on-the-board position; if the caller forgot to resolve
    // that from dartchess it could arrive here ambiguous. Treat `0` as
    // "mate has already been delivered" — neither mover-forces-mate nor
    // opponent-forces-mate — so the classifier falls through to the
    // normal Win% / cp-loss ladder instead of mis-firing Blunder on a
    // mate-delivering ply. Analyzer pipelines should pre-synthesise a
    // signed ±1 mate and never emit raw `0`; this guard is belt-and-
    // braces.
    final opponentForcesMate =
        in_.currWhiteMate != null && in_.currWhiteMate != 0 && !moverForcesMate;

    final wasEngineBestMove = _isEngineBest(
      engine: in_.engineBestMoveUci,
      played: in_.playedMoveUci,
    );

    MoveClassification finish(MoveQuality q, String message) =>
        MoveClassification(
          quality: q,
          deltaW: deltaW,
          winPercentBefore: whiteWinBefore,
          winPercentAfter: whiteWinAfter,
          moverCpLoss: cpLossMover,
          message: message,
          engineBestMoveUci: in_.engineBestMoveUci,
        );

    // ── Mate-against-mover short-circuit ──────────────────────────────
    // Spec § 3.4: a move that yields a forced mate against the mover
    // is a Blunder, regardless of cp. Done up-front so the Brilliant /
    // Great / Missed Win gates below cannot mis-fire on it.
    if (opponentForcesMate) {
      return finish(MoveQuality.blunder, 'Blunder — allows forced mate.');
    }

    // ── Book / Theory ─────────────────────────────────────────────────
    // Spec § 3.6.3: book moves stay tagged as Book unless the engine
    // shows a severe drop (ΔW < −20 ⇒ Blunder). We let the severe
    // drop fall through to the Win% ladder so the user sees the
    // actual blunder verdict.
    if (in_.isBook && deltaW > dwMistake) {
      final headline = in_.ecoCode != null && in_.openingName != null
          ? '${in_.ecoCode} • ${in_.openingName}'
          : in_.openingName ?? 'Opening theory.';
      return finish(MoveQuality.book, headline);
    }

    // ── Brilliant (very strict — § 3.6.6) ─────────────────────────────
    // Quick scans (D14, single PV) cannot honestly verify a Brilliant
    // claim — skipped when `suppressTrophyTiers` is set (spec § 3.6.6
    // requires MultiPV + alt-line Win% to gate Brilliant).
    if (!in_.suppressTrophyTiers) {
      final brilliantQ = _classifyBrilliant(
        in_: in_,
        deltaW: deltaW,
        moverWinBefore: moverWinBefore,
        moverWinAfter: moverWinAfter,
        cpLossMover: cpLossMover,
        moverForcesMate: moverForcesMate,
        wasEngineBestMove: wasEngineBestMove,
      );
      if (brilliantQ != null) {
        return finish(
          MoveQuality.brilliant,
          'Brilliant sacrifice — Apex AI confirms the attack.',
        );
      }
    }

    // ── Missed Win (§ 3.6.5) ──────────────────────────────────────────
    // Mover was winning *before* (mover Win% > 70) and the played
    // move drops the position to equal/worse. We surface this even
    // when ΔW would otherwise read as Inaccuracy or Mistake — the
    // tag is more informative for training.
    final missedWin = _classifyMissedWin(
      bestMoverWinBefore: _bestMoverWinBeforeFromPv(
        in_,
        fallback: moverWinBefore,
      ),
      moverWinAfter: moverWinAfter,
      deltaW: deltaW,
      hasMultiPvEvidence: (in_.multiPvWhiteWinPercents?.length ?? 0) >= 2,
      prevMoverMate: _persp.moverForcesMate(
        in_.prevWhiteMate,
        isWhiteMove: in_.isWhiteMove,
      ),
      currMoverMate: moverForcesMate,
    );
    if (missedWin != null) return finish(missedWin, 'Missed a winning line.');

    // ── Forced (§ 3.6.2) ──────────────────────────────────────────────
    // Requires MultiPV to prove every alternative line drops > 20 pp.
    // Quick scans (single PV) cannot honour this gate honestly.
    if (!in_.suppressTrophyTiers) {
      final forced = _classifyForced(
        in_: in_,
        deltaW: deltaW,
        wasEngineBestMove: wasEngineBestMove,
      );
      if (forced != null) {
        return finish(MoveQuality.forced, 'Forced — only move that holds.');
      }

      // ── Great (§ 3.6.4) ─────────────────────────────────────────────
      final great = _classifyGreat(
        in_: in_,
        deltaW: deltaW,
        whiteWinAfter: whiteWinAfter,
        moverWinBefore: moverWinBefore,
        moverWinAfter: moverWinAfter,
        wasEngineBestMove: wasEngineBestMove,
      );
      if (great != null) {
        return finish(MoveQuality.great, 'Great find — pivotal move.');
      }
    }

    // ── Best ──────────────────────────────────────────────────────────
    if (wasEngineBestMove && deltaW >= dwExcellent) {
      return finish(MoveQuality.best, "Best — Apex AI's #1 choice.");
    }

    // ── Win%-derived primary tier (§ 3.3.2) ──────────────────────────
    var primary = _fromWinDelta(deltaW);

    // ── cp-loss safety net ────────────────────────────────────────────
    // ONLY softens — never escalates. A flat-but-tiny cp drift in the
    // wings of the sigmoid (e.g. losing 30 cp in an already-resigned
    // position) must not read as Mistake/Blunder.
    final softened = _safetyNet(primary, cpLossMover);
    primary = softened;

    // ── Damping at the eval extremes (§ 3.4 + spec § 3.6.1) ──────────
    // (a) Already-lost on the mover side: a single ply is not the
    //     move that lost the game — at most a Mistake.
    // (b) Already-winning drift while still up: small advantage drift
    //     should not read as Blunder.
    final wasAlreadyLost = moverWinBefore <= 10.0;
    final winningDrift =
        moverWinBefore >= 90.0 &&
        moverWinAfter >= 60.0 &&
        (cpLossMover == null || cpLossMover < 250);
    if ((wasAlreadyLost || winningDrift) && primary == MoveQuality.blunder) {
      primary = MoveQuality.mistake;
    }

    return finish(primary, _messageFor(primary, deltaW, cpLossMover));
  }

  // ─── Tier helpers ────────────────────────────────────────────────────

  MoveQuality _fromWinDelta(double deltaW) {
    if (deltaW < dwMistake) return MoveQuality.blunder;
    if (deltaW < dwInaccuracy) return MoveQuality.mistake;
    if (deltaW < dwGood) return MoveQuality.inaccuracy;
    if (deltaW < dwExcellent) return MoveQuality.good;
    return MoveQuality.excellent;
  }

  MoveQuality _safetyNet(MoveQuality picked, int? cpLossMover) {
    if (cpLossMover == null) return picked;
    MoveQuality cap;
    if (cpLossMover <= 30) {
      cap = MoveQuality.excellent;
    } else if (cpLossMover <= 60) {
      cap = MoveQuality.excellent;
    } else if (cpLossMover <= 120) {
      cap = MoveQuality.inaccuracy;
    } else if (cpLossMover <= 250) {
      cap = MoveQuality.mistake;
    } else {
      cap = MoveQuality.blunder;
    }
    return _severity(cap) < _severity(picked) ? cap : picked;
  }

  int _severity(MoveQuality q) => switch (q) {
    MoveQuality.brilliant => 0,
    MoveQuality.great => 0,
    MoveQuality.best => 0,
    MoveQuality.book => 0,
    MoveQuality.forced => 1,
    MoveQuality.excellent => 2,
    MoveQuality.good => 3,
    MoveQuality.inaccuracy => 4,
    MoveQuality.missedWin => 4,
    MoveQuality.mistake => 5,
    MoveQuality.blunder => 6,
  };

  // ─── Brilliant gate — strict, all six conditions must hold ────────

  MoveQuality? _classifyBrilliant({
    required MoveClassificationInput in_,
    required double deltaW,
    required double moverWinBefore,
    required double moverWinAfter,
    required int? cpLossMover,
    required bool moverForcesMate,
    required bool wasEngineBestMove,
  }) {
    if (!in_.isSacrifice) return null;
    if (in_.isTrivialRecapture) return null;
    if (!in_.isFirstSacrificePly) return null;
    if (in_.multiPvWhiteWinPercents == null ||
        in_.multiPvWhiteWinPercents!.length < 2) {
      return null;
    }

    // Soundness
    if (deltaW < -2.0) return null;
    if (cpLossMover != null && cpLossMover > brilliantCpLossCap) return null;
    if (!moverForcesMate && moverWinAfter < 50.0) return null;

    // Near-best (engine #1 OR favourable forced mate)
    if (!wasEngineBestMove && !moverForcesMate) return null;

    // Already-crushing guard (Win% AND cp variants) — favourable
    // forced mate overrides because mating from +6 is still a real
    // tactical resource.
    final moverCpBefore = in_.prevWhiteMate != null || in_.prevWhiteCp == null
        ? null
        : _persp.moverCp(in_.prevWhiteCp!, isWhiteMove: in_.isWhiteMove);
    final wasAlreadyCrushing =
        moverWinBefore >= crushingCutoff ||
        (moverCpBefore != null && moverCpBefore >= 500);
    if (wasAlreadyCrushing && !moverForcesMate) return null;

    // Alternative-line guard: if a non-sacrificial line was already
    // trivially winning, the sacrifice is "win more" — not Brilliant.
    if (in_.altLineWhiteWinPercent != null) {
      final altMover = _persp.moverWinPercent(
        in_.altLineWhiteWinPercent!,
        isWhiteMove: in_.isWhiteMove,
      );
      if (altMover >= triviallyWinning) return null;
    }

    return MoveQuality.brilliant;
  }

  // ─── Missed Win gate (§ 3.6.5) ────────────────────────────────────

  MoveQuality? _classifyMissedWin({
    required double bestMoverWinBefore,
    required double moverWinAfter,
    required double deltaW,
    required bool hasMultiPvEvidence,
    required bool prevMoverMate,
    required bool currMoverMate,
  }) {
    // Mover was *forced-mate-up* before but no longer after ⇒
    // Missed Win regardless of cp drift.
    if (prevMoverMate && !currMoverMate) {
      return MoveQuality.missedWin;
    }
    // Mover was clearly winning before; played move drops the
    // position to equal/worse — i.e. spec's "winning → equal/worse".
    if (bestMoverWinBefore > winningCutoff &&
        moverWinAfter < equalCeiling &&
        deltaW <= dwInaccuracy) {
      if (deltaW <= dwMistake && !hasMultiPvEvidence) {
        return null;
      }
      return MoveQuality.missedWin;
    }
    return null;
  }

  // ─── Forced gate (§ 3.6.2) ────────────────────────────────────────

  MoveQuality? _classifyForced({
    required MoveClassificationInput in_,
    required double deltaW,
    required bool wasEngineBestMove,
  }) {
    final pvs = in_.multiPvWhiteWinPercents;
    if (pvs == null || pvs.length < 3) return null;
    if (deltaW < dwGood) {
      return null; // capped at "Okay"; severe drops aren't forced
    }
    if (!wasEngineBestMove) return null;

    // Convert to mover-POV so the comparison is symmetric.
    final movPvs = pvs
        .map((w) => _persp.moverWinPercent(w, isWhiteMove: in_.isWhiteMove))
        .toList(growable: false);
    final best = movPvs.first;
    var withinTolerance = 0;
    var allOthersDrop = true;
    for (var i = 1; i < movPvs.length; i++) {
      final gap = best - movPvs[i];
      if (gap <= forcedTolerancePp) {
        withinTolerance += 1;
      }
      if (gap < forcedDropPp) {
        allOthersDrop = false;
      }
    }
    if (withinTolerance == 0 && allOthersDrop) {
      return MoveQuality.forced;
    }
    return null;
  }

  // ─── Great gate (§ 3.6.4) ─────────────────────────────────────────

  MoveQuality? _classifyGreat({
    required MoveClassificationInput in_,
    required double deltaW,
    required double whiteWinAfter,
    required double moverWinBefore,
    required double moverWinAfter,
    required bool wasEngineBestMove,
  }) {
    if (in_.isTrivialRecapture) return null;
    // Position after the move must not be clearly losing.
    if (moverWinAfter < 30.0) return null;

    // Variant A: ΔW > 10 *and* the move crosses an eval boundary.
    final crossedFromLosing = moverWinBefore < 30.0 && moverWinAfter >= 40.0;
    final crossedFromEqual =
        moverWinBefore < 60.0 &&
        moverWinBefore >= 40.0 &&
        moverWinAfter >= 60.0;
    if (deltaW > 10.0 && (crossedFromLosing || crossedFromEqual)) {
      return MoveQuality.great;
    }

    // Variant B: PV1 vs PV2 gap ≥ 10 pp (mover-POV) and the mover
    // actually played PV1.
    if (wasEngineBestMove &&
        deltaW >= dwExcellent &&
        _secondBestWhiteWinPercent(in_) != null) {
      final altMover = _persp.moverWinPercent(
        _secondBestWhiteWinPercent(in_)!,
        isWhiteMove: in_.isWhiteMove,
      );
      final gap = moverWinAfter - altMover;
      if (gap >= greatPv1MinusPv2Pp) {
        return MoveQuality.great;
      }
    }

    return null;
  }

  // ─── Misc helpers ─────────────────────────────────────────────────

  bool _isEngineBest({String? engine, String? played}) {
    if (engine == null || played == null) return false;
    return normalizeCastlingUci(engine) == normalizeCastlingUci(played);
  }

  double _bestMoverWinBeforeFromPv(
    MoveClassificationInput in_, {
    required double fallback,
  }) {
    final pvs = in_.multiPvWhiteWinPercents;
    if (pvs == null || pvs.isEmpty) return fallback;
    return _persp.moverWinPercent(pvs.first, isWhiteMove: in_.isWhiteMove);
  }

  double? _secondBestWhiteWinPercent(MoveClassificationInput in_) {
    if (in_.secondBestWhiteWinPercent != null) {
      return in_.secondBestWhiteWinPercent;
    }
    final pvs = in_.multiPvWhiteWinPercents;
    if (pvs == null || pvs.length < 2) return null;
    return pvs[1];
  }

  String _messageFor(MoveQuality q, double deltaW, int? cpLoss) {
    final cpStr = cpLoss == null
        ? ''
        : ' (≈ ${(cpLoss / 100).toStringAsFixed(2)} pawns)';
    final dwStr = deltaW.abs().toStringAsFixed(1);
    return switch (q) {
      MoveQuality.blunder => 'Blunder — $dwStr% Win% surrendered$cpStr.',
      MoveQuality.mistake => 'Mistake — $dwStr% Win% lost$cpStr.',
      MoveQuality.inaccuracy => 'Inaccuracy — $dwStr% better move existed.',
      MoveQuality.good => 'Solid — within tolerance of the best line.',
      MoveQuality.excellent => 'Excellent — effectively engine-grade.',
      MoveQuality.best => "Best — Apex AI's #1 choice.",
      MoveQuality.brilliant =>
        'Brilliant sacrifice — Apex AI confirms the attack.',
      MoveQuality.great => 'Great find — pivotal move.',
      MoveQuality.book => 'Opening theory.',
      MoveQuality.forced => 'Forced — only move that holds.',
      MoveQuality.missedWin => 'Missed a winning line.',
    };
  }
}
