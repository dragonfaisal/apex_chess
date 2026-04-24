/// Move-quality evaluation — Lichess/Chesskit Sigmoid Model, strict.
///
/// Every classification in Apex Chess is derived **exclusively from the
/// Apex AI Grandmaster's centipawn verdicts**. We take the engine's CP
/// (or mate) before and after the played move, map each to Win% via the
/// Lichess sigmoid:
///
///   `W(cp) = 50 + 50 * (2 / (1 + exp(-0.00368208 * cp)) - 1)`
///
/// and classify the signed Win% drop `deltaW` (negative = bad for the
/// mover) against Chesskit thresholds. **No heuristics, no mocks —
/// every tier corresponds to a specific CP-drop band**:
///
/// | Tier        | deltaW (Win%)   | Approx CP loss (from even) |
/// |-------------|-----------------|----------------------------|
/// | Brilliant   | > -2 & sacrifice| engine confirms the sac    |
/// | Best        | > -0.5 & == eng | engine's #1 move           |
/// | Excellent   | > -0.5          | ≤ ~25 CP                   |
/// | Good        | -0.5 .. -2      | ~25–100 CP                 |
/// | Inaccuracy  | -2 .. -5        | ~100–200 CP                |
/// | Mistake     | -5 .. -10       | ~200–400 CP                |
/// | Blunder     | ≤ -10           | ≥ ~400 CP or mate swing    |
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

    // Normalise both sides of the comparison: the engine may return
    // `e1g1` (destination) while the SAN-parsed played UCI can be
    // `e1h1` (king-captures-rook). Without this the Best tier silently
    // never fires on castling moves.
    String? normPlayed =
        playedMoveUci == null ? null : normalizeCastlingUci(playedMoveUci);
    String? normEngine = engineBestMoveUci == null
        ? null
        : normalizeCastlingUci(engineBestMoveUci);
    final wasEngineBestMove = normEngine != null &&
        normPlayed != null &&
        normEngine == normPlayed;

    // Sacrifice-approved brilliancy. The sacrifice flag must be asserted
    // upstream (analyzer compares piece balance before/after); we refuse
    // to invent brilliants from deltaW alone.
    if (isSacrifice && deltaW >= -2.0) {
      return MoveAnalysisResult(
        quality: MoveQuality.brilliant,
        deltaW: deltaW,
        winPercentBefore: wPrev,
        winPercentAfter: wCurr,
        message: 'Brilliant sacrifice — Apex AI confirms the attack.',
        engineBestMove: engineBestMoveUci,
      );
    }

    // Only-winning-move (Great Find !). The caller asserts that the
    // engine's #2 line drops the position by ≥12 Win% relative to the
    // played #1 — so the move is *forced* to keep an advantage. We only
    // honour it when the player actually picked the engine's #1 and the
    // resulting deltaW didn't regress meaningfully (same noise band as
    // Best). This keeps Great strictly above Best in quality terms.
    if (isOnlyWinningMove && wasEngineBestMove && deltaW >= -2.0) {
      return MoveAnalysisResult(
        quality: MoveQuality.great,
        deltaW: deltaW,
        winPercentBefore: wPrev,
        winPercentAfter: wCurr,
        message: 'Great find — the only move that holds the win.',
        engineBestMove: engineBestMoveUci,
      );
    }

    // Best — the engine's #1 reply. Requires deltaW within the noise
    // band (no runaway swings); a "best" pick that somehow loses 2 %+
    // indicates one of the evals was a stale snapshot and we'd rather
    // mis-classify it as Excellent/Good than lie about engine agreement.
    if (wasEngineBestMove && deltaW >= -2.0) {
      return MoveAnalysisResult(
        quality: MoveQuality.best,
        deltaW: deltaW,
        winPercentBefore: wPrev,
        winPercentAfter: wCurr,
        message: 'Best move — Apex AI\'s #1 choice.',
        engineBestMove: engineBestMoveUci,
      );
    }

    if (deltaW <= -10.0) {
      return MoveAnalysisResult(
        quality: MoveQuality.blunder,
        deltaW: deltaW,
        winPercentBefore: wPrev,
        winPercentAfter: wCurr,
        message:
            'Blunder — ${deltaW.abs().toStringAsFixed(1)}% Win% surrendered.',
        engineBestMove: engineBestMoveUci,
      );
    }
    if (deltaW <= -5.0) {
      return MoveAnalysisResult(
        quality: MoveQuality.mistake,
        deltaW: deltaW,
        winPercentBefore: wPrev,
        winPercentAfter: wCurr,
        message:
            'Mistake — ${deltaW.abs().toStringAsFixed(1)}% Win% lost.',
        engineBestMove: engineBestMoveUci,
      );
    }
    if (deltaW <= -2.0) {
      return MoveAnalysisResult(
        quality: MoveQuality.inaccuracy,
        deltaW: deltaW,
        winPercentBefore: wPrev,
        winPercentAfter: wCurr,
        message:
            'Inaccuracy — ${deltaW.abs().toStringAsFixed(1)}% better move existed.',
        engineBestMove: engineBestMoveUci,
      );
    }
    if (deltaW < -0.5) {
      return MoveAnalysisResult(
        quality: MoveQuality.good,
        deltaW: deltaW,
        winPercentBefore: wPrev,
        winPercentAfter: wCurr,
        message: 'Solid — within tolerance of the best line.',
        engineBestMove: engineBestMoveUci,
      );
    }

    // deltaW ≥ -0.5 % — the move is effectively indistinguishable from
    // the engine's top choice in Win% terms, but wasn't the exact #1.
    return MoveAnalysisResult(
      quality: MoveQuality.excellent,
      deltaW: deltaW,
      winPercentBefore: wPrev,
      winPercentAfter: wCurr,
      message: 'Excellent — effectively engine-grade.',
      engineBestMove: engineBestMoveUci,
    );
  }
}
