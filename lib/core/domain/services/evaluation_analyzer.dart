/// Move quality evaluation — Lichess/Chesskit Sigmoid Model.
///
/// Implements the exact logistic Win% equation:
///   W = 50 + 50 * (2 / (1 + exp(-0.00368208 * cp)) - 1)
///
/// Move classification uses deltaW (signed Win% drop) with strict
/// Chesskit thresholds. EVERY move from ply 1 is evaluated.
library;

import 'dart:math' as math;

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Move Quality Labels
// ─────────────────────────────────────────────────────────────────────────────

enum MoveQuality {
  brilliant('!!', 'Brilliant', ApexColors.brilliant, 'brilliant.svg'),
  best('★', 'Best Move', ApexColors.best, 'best.svg'),
  excellent('!', 'Excellent', ApexColors.great, 'excellent.svg'),
  good('', 'Good', ApexColors.textSecondary, 'good.svg'),
  inaccuracy('?!', 'Inaccuracy', ApexColors.inaccuracy, 'inaccuracy.svg'),
  mistake('?', 'Mistake', ApexColors.mistake, 'mistake.svg'),
  blunder('??', 'Blunder', ApexColors.blunder, 'blunder.svg'),
  book('📖', 'Book', ApexColors.book, 'book.svg');

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
// Analyzer (Lichess Sigmoid Model)
// ─────────────────────────────────────────────────────────────────────────────

class EvaluationAnalyzer {
  const EvaluationAnalyzer();

  static double calculateWinPercentage({int? cp, int? mate}) {
    if (mate != null) return mate > 0 ? 100.0 : 0.0;
    if (cp == null) return 50.0;
    final clamped = cp.clamp(-1000, 1000);
    final w = 2.0 / (1.0 + math.exp(-0.00368208 * clamped)) - 1.0;
    return 50.0 + 50.0 * w;
  }

  MoveAnalysisResult analyze({
    required int? prevCp,
    int? prevMate,
    required int? currCp,
    int? currMate,
    required bool isWhiteMove,
    String? engineBestMoveUci,
    String? playedMoveUci,
    bool isSacrifice = false,
  }) {
    final wPrev = calculateWinPercentage(cp: prevCp, mate: prevMate);
    final wCurr = calculateWinPercentage(cp: currCp, mate: currMate);
    final s = isWhiteMove ? 1.0 : -1.0;
    final deltaW = (wCurr - wPrev) * s;

    final wasEngineBestMove = engineBestMoveUci != null &&
        playedMoveUci != null &&
        engineBestMoveUci == playedMoveUci;

    if (isSacrifice && deltaW >= -2.0) {
      return MoveAnalysisResult(
        quality: MoveQuality.brilliant, deltaW: deltaW,
        winPercentBefore: wPrev, winPercentAfter: wCurr,
        message: 'Brilliant sacrifice! The engine confirms this wins.',
        engineBestMove: engineBestMoveUci,
      );
    }

    if (wasEngineBestMove) {
      return MoveAnalysisResult(
        quality: MoveQuality.best, deltaW: deltaW,
        winPercentBefore: wPrev, winPercentAfter: wCurr,
        message: 'Best move — engine\'s #1 choice.',
        engineBestMove: engineBestMoveUci,
      );
    }

    if (deltaW < -20.0) {
      return MoveAnalysisResult(
        quality: MoveQuality.blunder, deltaW: deltaW,
        winPercentBefore: wPrev, winPercentAfter: wCurr,
        message: 'Blunder! ${deltaW.abs().toStringAsFixed(1)}% Win% lost.',
        engineBestMove: engineBestMoveUci,
      );
    }
    if (deltaW < -10.0) {
      return MoveAnalysisResult(
        quality: MoveQuality.mistake, deltaW: deltaW,
        winPercentBefore: wPrev, winPercentAfter: wCurr,
        message: 'Mistake — significant position loss.',
        engineBestMove: engineBestMoveUci,
      );
    }
    if (deltaW < -5.0) {
      return MoveAnalysisResult(
        quality: MoveQuality.inaccuracy, deltaW: deltaW,
        winPercentBefore: wPrev, winPercentAfter: wCurr,
        message: 'Inaccuracy — a better move existed.',
        engineBestMove: engineBestMoveUci,
      );
    }
    if (deltaW < -2.0) {
      return MoveAnalysisResult(
        quality: MoveQuality.good, deltaW: deltaW,
        winPercentBefore: wPrev, winPercentAfter: wCurr,
        message: 'Okay move — slight room for improvement.',
        engineBestMove: engineBestMoveUci,
      );
    }

    return MoveAnalysisResult(
      quality: MoveQuality.excellent, deltaW: deltaW,
      winPercentBefore: wPrev, winPercentAfter: wCurr,
      message: 'Excellent — near-engine accuracy.',
      engineBestMove: engineBestMoveUci,
    );
  }
}
