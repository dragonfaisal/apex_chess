/// Move-quality evaluation — Lichess sigmoid Win% model, **plus** an
/// explicit centipawn-loss safety net and damping for the eval extremes.
///
/// Every classification in Apex Chess is derived from the Apex AI
/// Grandmaster's centipawn verdicts. We take the engine's CP (or mate)
/// before and after the played move, map each to Win% via the Lichess
/// sigmoid:
///
///   `W(cp) = 50 + 50 * (2 / (1 + exp(-0.00368208 * cp)) - 1)`
///
/// and classify the signed Win% drop `deltaW` (negative = bad for the
/// mover). The Win% delta drives the *primary* tier — but we then
/// **cap** it by the absolute centipawn loss the user (and modern chess
/// apps) expects, and **damp** it at the edges of the eval range so a
/// slightly-imprecise move in an already-lost or already-winning
/// position is not over-labelled.
///
/// Tier ladder (see [analyze] for the exact code):
///
/// | Tier        | deltaW (Win%) | Mover-POV CP loss cap |
/// |-------------|---------------|------------------------|
/// | Brilliant   | ≥ -2 & strict | ≤ 40 + sac + near-best |
/// | Great       | ≥ -2 & only   | matches engine #1      |
/// | Best        | ≥ -2          | matches engine #1      |
/// | Excellent   | > -0.5        | ≤ 60                   |
/// | Good        | -0.5 .. -2    | ≤ 120                  |
/// | Inaccuracy  | -2 .. -5      | ≤ 120                  |
/// | Mistake     | -5 .. -10     | ≤ 250                  |
/// | Blunder     | ≤ -10         | > 250                  |
///
/// Castling moves are UCI-normalised via [normalizeCastlingUci] so the
/// "was this the engine's #1?" check works whether the engine returns
/// `e1g1` (king-to-destination) or `e1h1` (king-captures-rook).
library;

import 'dart:math' as math;

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Move Quality Labels
// ─────────────────────────────────────────────────────────────────────────────

enum MoveQuality {
  brilliant('!!', 'Brilliant', ApexColors.brilliant, 'brilliant.svg'),
  great('!', 'Great Find', ApexColors.brilliant, 'great_find.svg'),
  best('★', 'Best Move', ApexColors.best, 'best.svg'),
  excellent('!', 'Excellent', ApexColors.great, 'excellent.svg'),
  good('', 'Solid', ApexColors.textSecondary, 'good.svg'),
  inaccuracy('?!', 'Inaccuracy', ApexColors.inaccuracy, 'inaccuracy.svg'),
  mistake('?', 'Mistake', ApexColors.mistake, 'mistake.svg'),
  blunder('??', 'Blunder', ApexColors.blunder, 'blunder.svg'),
  book('📖', 'Theory', ApexColors.book, 'book.svg');

  final String symbol;
  final String label;
  final Color color;
  final String svgFile;

  const MoveQuality(this.symbol, this.label, this.color, this.svgFile);

  String get svgAssetPath => 'assets/svg/$svgFile';
}

// ─────────────────────────────────────────────────────────────────────────────
// Analysis Result
// ─────────────────────────────────────────────────────────────────────────────

class MoveAnalysisResult {
  final MoveQuality quality;
  final double deltaW;
  final double winPercentBefore;
  final double winPercentAfter;
  final String message;
  final String? engineBestMove;

  const MoveAnalysisResult({
    required this.quality,
    required this.deltaW,
    required this.winPercentBefore,
    required this.winPercentAfter,
    required this.message,
    this.engineBestMove,
  });

  factory MoveAnalysisResult.none() => const MoveAnalysisResult(
        quality: MoveQuality.good,
        deltaW: 0,
        winPercentBefore: 50,
        winPercentAfter: 50,
        message: 'Awaiting analysis…',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Castling UCI normaliser
// ─────────────────────────────────────────────────────────────────────────────

/// Rewrites king-captures-rook UCI (Lichess / Chess960 convention) to the
/// standard FIDE destination square so the string comparison between
/// `engineBestMoveUci` and `playedMoveUci` works regardless of which
/// dialect either side emits. Non-castling UCIs pass through unchanged.
///
///   * `e1h1` → `e1g1` (White short)
///   * `e1a1` → `e1c1` (White long)
///   * `e8h8` → `e8g8` (Black short)
///   * `e8a8` → `e8c8` (Black long)
String normalizeCastlingUci(String uci) {
  if (uci.length < 4) return uci;
  final head = uci.substring(0, 4);
  switch (head) {
    case 'e1h1':
      return 'e1g1${uci.substring(4)}';
    case 'e1a1':
      return 'e1c1${uci.substring(4)}';
    case 'e8h8':
      return 'e8g8${uci.substring(4)}';
    case 'e8a8':
      return 'e8c8${uci.substring(4)}';
    default:
      return uci;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Analyzer (strict Lichess Sigmoid Model)
// ─────────────────────────────────────────────────────────────────────────────

class EvaluationAnalyzer {
  const EvaluationAnalyzer();

  /// Maps a Stockfish centipawn (or mate) verdict to White-perspective
  /// Win% in [0, 100]. Mate-in-N collapses to 0/100 for the losing/winning
  /// side respectively.
  static double calculateWinPercentage({int? cp, int? mate}) {
    if (mate != null) return mate > 0 ? 100.0 : 0.0;
    if (cp == null) return 50.0;
    final clamped = cp.clamp(-1000, 1000);
    final w = 2.0 / (1.0 + math.exp(-0.00368208 * clamped)) - 1.0;
    return 50.0 + 50.0 * w;
  }

  /// Classifies a single ply.
  ///
  /// * [prevCp] / [prevMate]  — engine verdict of the position *before*
  ///   the played move (from White's POV).
  /// * [currCp] / [currMate]  — engine verdict *after* the played move.
  /// * [engineBestMoveUci]    — the engine's #1 candidate for the
  ///   position before; used to award the **Best** tier when the player
  ///   chose it. Castling UCIs are normalised so `e1h1` == `e1g1`.
  /// * [isSacrifice]          — caller asserts that the move surrendered
  ///   material of at least a minor piece without immediate recapture.
  ///   Only then can the move be classified **Brilliant** — the analyser
  ///   never invents sacrifices on its own.
  MoveAnalysisResult analyze({
    required int? prevCp,
    int? prevMate,
    required int? currCp,
    int? currMate,
    required bool isWhiteMove,
    String? engineBestMoveUci,
    String? playedMoveUci,
    bool isSacrifice = false,
    bool isOnlyWinningMove = false,
  }) {
    final wPrev = calculateWinPercentage(cp: prevCp, mate: prevMate);
    final wCurr = calculateWinPercentage(cp: currCp, mate: currMate);
    final s = isWhiteMove ? 1.0 : -1.0;
    final deltaW = (wCurr - wPrev) * s;

    // Mover-POV Win% (independent of side) — used by damping rules so
    // "already winning / already lost" reads the same for Black and
    // White.
    final moverWinPrev = isWhiteMove ? wPrev : 100.0 - wPrev;
    final moverWinCurr = isWhiteMove ? wCurr : 100.0 - wCurr;

    // Mover-POV centipawn loss. `null` whenever either side of the
    // comparison is a mate verdict — mate-in-N can't be expressed in cp
    // and we don't want to guess.
    int? cpLossMover;
    if (prevCp != null &&
        currCp != null &&
        prevMate == null &&
        currMate == null) {
      final movPrev = isWhiteMove ? prevCp : -prevCp;
      final movCurr = isWhiteMove ? currCp : -currCp;
      cpLossMover = movPrev - movCurr;
    }

    // Normalise both sides of the comparison: the engine may return
    // `e1g1` (destination) while the SAN-parsed played UCI can be
    // `e1h1` (king-captures-rook). Without this the Best tier silently
    // never fires on castling moves.
    final normPlayed =
        playedMoveUci == null ? null : normalizeCastlingUci(playedMoveUci);
    final normEngine = engineBestMoveUci == null
        ? null
        : normalizeCastlingUci(engineBestMoveUci);
    final wasEngineBestMove = normEngine != null &&
        normPlayed != null &&
        normEngine == normPlayed;

    MoveAnalysisResult result(MoveQuality q, String msg) =>
        MoveAnalysisResult(
          quality: q,
          deltaW: deltaW,
          winPercentBefore: wPrev,
          winPercentAfter: wCurr,
          message: msg,
          engineBestMove: engineBestMoveUci,
        );

    // ── Brilliant (strict gate) ────────────────────────────────────────
    //
    // The previous gate was just `isSacrifice && deltaW ≥ -2`, which
    // fired on every recaptured-back gambit and on every flashy sac
    // played from an already-winning position. Per Phase 6 spec, ALL of
    // the following must hold for Brilliant to fire:
    //
    //   1. caller flagged a real sacrifice (≥ minor piece, no recapture
    //      in the opponent's reply — see [PositionHeuristics])
    //   2. deltaW within noise (≥ -2 pp) — the move did not noticeably
    //      reduce the Win%
    //   3. mover-POV cp loss ≤ 40 (the engine *itself* still rates the
    //      played move as nearly its #1 — random sacrifices that swing
    //      the eval by half a pawn or more are NOT brilliant)
    //   4. the played move IS the engine's #1, OR it forces a mate-in-N
    //   5. the mover was NOT already crushing (mover Win% ≥ 90),
    //      *unless* the line is a forced mate (sacrificing while +6 just
    //      to look fancy is at most "Best", never Brilliant)
    if (isSacrifice && deltaW >= -2.0) {
      final cpOk = cpLossMover == null || cpLossMover <= 40;
      final nearBest = wasEngineBestMove || currMate != null;
      // Already-crushing guard. Spec'd at +5.0 pawns of mover-POV cp
      // (the Lichess sigmoid maps that to ≈ 86 Win%, which is below
      // the 90 % threshold we'd otherwise want, so we use the cp
      // value directly when it's available and fall back to the
      // Win% reading when it isn't).
      final moverCpPrev = (prevCp == null || prevMate != null)
          ? null
          : (isWhiteMove ? prevCp : -prevCp);
      final wasAlreadyCrushing = moverWinPrev >= 90.0 ||
          (moverCpPrev != null && moverCpPrev >= 500);
      final winningShowmanship =
          wasAlreadyCrushing && currMate == null;
      if (cpOk && nearBest && !winningShowmanship) {
        return result(
          MoveQuality.brilliant,
          'Brilliant sacrifice — Apex AI confirms the attack.',
        );
      }
      // Fall through. The downstream tiers will assign the correct
      // (non-Brilliant) classification — typically Best when the move
      // matched engine #1, otherwise Excellent / Good.
    }

    // Only-winning-move (Great Find !). Caller asserts the engine's #2
    // line drops by ≥12 Win% relative to #1, so this move is *forced*.
    if (isOnlyWinningMove && wasEngineBestMove && deltaW >= -2.0) {
      return result(
        MoveQuality.great,
        'Great find — the only move that holds the win.',
      );
    }

    // Best — the engine's #1 reply, in the noise band.
    if (wasEngineBestMove && deltaW >= -2.0) {
      return result(
        MoveQuality.best,
        "Best move — Apex AI's #1 choice.",
      );
    }

    // ── Win%-derived primary tier ──────────────────────────────────────
    MoveQuality fromWinDelta() {
      if (deltaW <= -10.0) return MoveQuality.blunder;
      if (deltaW <= -5.0) return MoveQuality.mistake;
      if (deltaW <= -2.0) return MoveQuality.inaccuracy;
      if (deltaW < -0.5) return MoveQuality.good;
      return MoveQuality.excellent;
    }

    // ── Centipawn-loss safety net ──────────────────────────────────────
    //
    // Phase 6 spec maps cp loss directly onto tiers:
    //   loss ≤ 30  → Best/Excellent
    //   loss ≤ 60  → Excellent
    //   loss ≤ 120 → Inaccuracy
    //   loss ≤ 250 → Mistake
    //   loss > 250 → Blunder
    //
    // The sigmoid Win% deltas already match this in the middle of the
    // eval range, but in the wings (|cp| ≳ 800) the sigmoid is flat and
    // small absolute mistakes register as deltaW ≈ 0. We use the cp
    // ladder as a *cap* on the chosen tier in both directions: a tier
    // assigned by Win% is replaced by the cp-based tier when the cp
    // tier is *less severe*, so a flat-but-tiny cp loss never reads as
    // Mistake / Blunder.
    MoveQuality? cpFloor;
    if (cpLossMover != null) {
      if (cpLossMover <= 60) {
        cpFloor = MoveQuality.excellent;
      } else if (cpLossMover <= 120) {
        cpFloor = MoveQuality.inaccuracy;
      } else if (cpLossMover <= 250) {
        cpFloor = MoveQuality.mistake;
      } else {
        cpFloor = MoveQuality.blunder;
      }
    }

    int severity(MoveQuality q) => switch (q) {
          MoveQuality.brilliant => 0,
          MoveQuality.great => 0,
          MoveQuality.best => 0,
          MoveQuality.book => 0,
          MoveQuality.excellent => 1,
          MoveQuality.good => 2,
          MoveQuality.inaccuracy => 3,
          MoveQuality.mistake => 4,
          MoveQuality.blunder => 5,
        };

    var picked = fromWinDelta();
    if (cpFloor != null && severity(cpFloor) < severity(picked)) {
      picked = cpFloor;
    }

    // ── Damping at the eval extremes ───────────────────────────────────
    //
    // (a) Already-lost (mover Win% ≤ 10): a single ply is not the move
    //     that lost the game — at most a Mistake.
    // (b) Already-winning drift (mover Win% ≥ 90 before, still ≥ 60
    //     after, cp loss < 250): small advantage drift while still up
    //     should not read as Blunder.
    final wasAlreadyLost = moverWinPrev <= 10.0;
    final winningDrift = moverWinPrev >= 90.0 &&
        moverWinCurr >= 60.0 &&
        (cpLossMover == null || cpLossMover < 250);
    if ((wasAlreadyLost || winningDrift) &&
        picked == MoveQuality.blunder) {
      picked = MoveQuality.mistake;
    }

    final cpLossPretty =
        cpLossMover == null ? '' : ' (≈ ${(cpLossMover / 100).toStringAsFixed(2)} pawns)';

    switch (picked) {
      case MoveQuality.blunder:
        return result(
          picked,
          'Blunder — ${deltaW.abs().toStringAsFixed(1)}% Win% surrendered$cpLossPretty.',
        );
      case MoveQuality.mistake:
        return result(
          picked,
          'Mistake — ${deltaW.abs().toStringAsFixed(1)}% Win% lost$cpLossPretty.',
        );
      case MoveQuality.inaccuracy:
        return result(
          picked,
          'Inaccuracy — ${deltaW.abs().toStringAsFixed(1)}% better move existed.',
        );
      case MoveQuality.good:
        return result(
          picked,
          'Solid — within tolerance of the best line.',
        );
      case MoveQuality.excellent:
      case MoveQuality.best:
      case MoveQuality.brilliant:
      case MoveQuality.great:
      case MoveQuality.book:
        return result(
          MoveQuality.excellent,
          'Excellent — effectively engine-grade.',
        );
    }
  }
}
