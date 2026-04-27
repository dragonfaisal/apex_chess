/// Public façade over the Phase A move-classification brain.
///
/// All real classification logic lives in [MoveClassifier]
/// (lib/core/domain/services/move_classifier.dart) — this file
/// preserves the legacy `EvaluationAnalyzer.analyze(...)` API so the
/// existing analysis pipelines (`local_game_analyzer`,
/// `cloud_game_analyzer`) keep compiling unchanged while every
/// verdict is now derived from the same brain.
///
/// The brain implements the spec's Win%-as-primary / cp-loss-as-
/// safety-net model with strict gates for Brilliant, Great, Forced,
/// and Missed Win, plus mate-direction handling. See the spec at
/// `docs/specs/apex_chess_analysis_training_ux_spec.md` § 3 for the
/// exact thresholds.
///
/// Castling moves are UCI-normalised via [normalizeCastlingUci] so
/// the "was this the engine's #1?" check works whether the engine
/// returns `e1g1` (king-to-destination) or `e1h1` (king-captures-
/// rook).
library;

import 'package:apex_chess/core/domain/services/move_classifier.dart';
import 'package:apex_chess/core/domain/services/win_percent_calculator.dart';
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
  book('📖', 'Theory', ApexColors.book, 'book.svg'),
  // Phase A: research-backed extensions. Forced = only move that
  // holds; mover Win% drift is bounded but the move was the one
  // path forward (spec § 3.6.2). MissedWin = mover was winning,
  // played a line that drops the position to roughly equal/worse
  // (spec § 3.6.5). Both reuse existing palette entries to honour
  // the "no UI redesign" rule.
  forced('!', 'Forced', ApexColors.textSecondary, 'forced.svg'),
  missedWin('?!', 'Missed Win', ApexColors.mistake, 'missed_win.svg');

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
  const EvaluationAnalyzer({
    MoveClassifier classifier = const MoveClassifier(),
  }) : _classifier = classifier;

  final MoveClassifier _classifier;

  /// Static convenience used by older callers that need a Win% number
  /// without instantiating the classifier. Routes through
  /// [WinPercentCalculator] so the formula has a single source of
  /// truth.
  static double calculateWinPercentage({int? cp, int? mate}) =>
      const WinPercentCalculator().forCp(cp: cp, mate: mate);

  /// Legacy single-ply API — preserved verbatim so the existing
  /// analysis pipelines (`local_game_analyzer`, `cloud_game_analyzer`)
  /// keep compiling. New call-sites should drive [MoveClassifier]
  /// directly via [classifyDetailed], which exposes the full Phase A
  /// input surface (MultiPV, alt-line Win%, isBook, isTrivialRecapture,
  /// etc.).
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
    bool isBook = false,
    String? openingName,
    String? ecoCode,
    double? secondBestWhiteWinPercent,
    List<double>? multiPvWhiteWinPercents,
    double? altLineWhiteWinPercent,
    bool isTrivialRecapture = false,
    bool isFirstSacrificePly = true,
  }) {
    final detailed = classifyDetailed(
      prevCp: prevCp,
      prevMate: prevMate,
      currCp: currCp,
      currMate: currMate,
      isWhiteMove: isWhiteMove,
      engineBestMoveUci: engineBestMoveUci,
      playedMoveUci: playedMoveUci,
      isSacrifice: isSacrifice,
      isOnlyWinningMove: isOnlyWinningMove,
      isBook: isBook,
      openingName: openingName,
      ecoCode: ecoCode,
      secondBestWhiteWinPercent: secondBestWhiteWinPercent,
      multiPvWhiteWinPercents: multiPvWhiteWinPercents,
      altLineWhiteWinPercent: altLineWhiteWinPercent,
      isTrivialRecapture: isTrivialRecapture,
      isFirstSacrificePly: isFirstSacrificePly,
    );
    return MoveAnalysisResult(
      quality: detailed.quality,
      deltaW: detailed.deltaW,
      winPercentBefore: detailed.winPercentBefore,
      winPercentAfter: detailed.winPercentAfter,
      message: detailed.message,
      engineBestMove: detailed.engineBestMoveUci,
    );
  }

  /// Direct entry point for new call-sites — returns the full
  /// [MoveClassification] including mover-POV cp loss.
  MoveClassification classifyDetailed({
    required int? prevCp,
    int? prevMate,
    required int? currCp,
    int? currMate,
    required bool isWhiteMove,
    String? engineBestMoveUci,
    String? playedMoveUci,
    bool isSacrifice = false,
    bool isOnlyWinningMove = false,
    bool isBook = false,
    String? openingName,
    String? ecoCode,
    double? secondBestWhiteWinPercent,
    List<double>? multiPvWhiteWinPercents,
    double? altLineWhiteWinPercent,
    bool isTrivialRecapture = false,
    bool isFirstSacrificePly = true,
  }) {
    // Backward-compat: the old API took `isOnlyWinningMove` as a
    // boolean assertion that "this move is the *only* winning line".
    // We translate that into a synthetic 2-element MultiPV list when
    // the caller has not supplied a real one — the Forced gate then
    // recognises the move as forced.
    final pvList = multiPvWhiteWinPercents ??
        (isOnlyWinningMove
            ? <double>[
                const WinPercentCalculator().forCp(cp: currCp, mate: currMate),
                // Synthetic alt: drop ≥ 25 pp below the played line so
                // the Forced gate fires.
                const WinPercentCalculator()
                        .forCp(cp: currCp, mate: currMate) -
                    (isWhiteMove ? 25.0 : -25.0),
              ]
            : null);
    return _classifier.classify(MoveClassificationInput(
      isWhiteMove: isWhiteMove,
      prevWhiteCp: prevCp,
      prevWhiteMate: prevMate,
      currWhiteCp: currCp,
      currWhiteMate: currMate,
      engineBestMoveUci: engineBestMoveUci,
      playedMoveUci: playedMoveUci,
      isSacrifice: isSacrifice,
      isTrivialRecapture: isTrivialRecapture,
      isFirstSacrificePly: isFirstSacrificePly,
      isBook: isBook,
      openingName: openingName,
      ecoCode: ecoCode,
      secondBestWhiteWinPercent: secondBestWhiteWinPercent,
      multiPvWhiteWinPercents: pvList,
      altLineWhiteWinPercent: altLineWhiteWinPercent,
    ));
  }

}
