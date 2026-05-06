/// Display models for the move-by-move Review Board.
///
/// These classes adapt the already-computed review timeline into small UI
/// contracts. They do not run engine analysis or change classification data.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/coach_explanation_service.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_quality_display.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';

enum ReviewBoardSide { white, black }

class ReviewPlayerHeaderDisplay {
  const ReviewPlayerHeaderDisplay({
    required this.side,
    required this.username,
    required this.rating,
    required this.isUser,
    required this.result,
    required this.avatarUrl,
  });

  final ReviewBoardSide side;
  final String username;
  final String? rating;
  final bool isUser;
  final String? result;
  final String? avatarUrl;

  String get sideLabel => side == ReviewBoardSide.white ? 'White' : 'Black';

  PlayerIdentityDisplay get identity => PlayerIdentityDisplay.fromRaw(
    username: username,
    platform: PlayerIdentityPlatform.pgn,
    rating: rating,
    avatarUrl: avatarUrl,
    isConnectedUser: isUser,
    isOpponent: !isUser,
    side: side == ReviewBoardSide.white
        ? PlayerIdentitySide.white
        : PlayerIdentitySide.black,
    result: switch (result) {
      'Won' => PlayerIdentityResult.won,
      'Lost' => PlayerIdentityResult.lost,
      'Draw' => PlayerIdentityResult.draw,
      _ => PlayerIdentityResult.unknown,
    },
  );

  String get initial {
    final trimmed = username.trim();
    if (trimmed.isEmpty) return side == ReviewBoardSide.white ? 'W' : 'B';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  static ReviewPlayerHeaderDisplay white(
    AnalysisTimeline timeline, {
    required bool? userIsWhite,
  }) {
    final headers = timeline.headers;
    return ReviewPlayerHeaderDisplay(
      side: ReviewBoardSide.white,
      username: _cleanName(headers['White'], fallback: 'White'),
      rating: _cleanOptional(headers['WhiteElo']),
      isUser: userIsWhite == true,
      result: _resultForSide(headers['Result'], ReviewBoardSide.white),
      avatarUrl: _cleanOptional(
        headers['WhiteAvatar'] ?? headers['WhiteAvatarUrl'],
      ),
    );
  }

  static ReviewPlayerHeaderDisplay black(
    AnalysisTimeline timeline, {
    required bool? userIsWhite,
  }) {
    final headers = timeline.headers;
    return ReviewPlayerHeaderDisplay(
      side: ReviewBoardSide.black,
      username: _cleanName(headers['Black'], fallback: 'Black'),
      rating: _cleanOptional(headers['BlackElo']),
      isUser: userIsWhite == false,
      result: _resultForSide(headers['Result'], ReviewBoardSide.black),
      avatarUrl: _cleanOptional(
        headers['BlackAvatar'] ?? headers['BlackAvatarUrl'],
      ),
    );
  }

  static ReviewPlayerHeaderDisplay top(
    AnalysisTimeline timeline, {
    required bool flipped,
    required bool? userIsWhite,
  }) {
    return flipped
        ? white(timeline, userIsWhite: userIsWhite)
        : black(timeline, userIsWhite: userIsWhite);
  }

  static ReviewPlayerHeaderDisplay bottom(
    AnalysisTimeline timeline, {
    required bool flipped,
    required bool? userIsWhite,
  }) {
    return flipped
        ? black(timeline, userIsWhite: userIsWhite)
        : white(timeline, userIsWhite: userIsWhite);
  }

  static String _cleanName(String? raw, {required String fallback}) {
    final trimmed = raw?.trim();
    return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
  }

  static String? _cleanOptional(String? raw) {
    final trimmed = raw?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static String? _resultForSide(String? raw, ReviewBoardSide side) {
    return switch (raw) {
      '1-0' => side == ReviewBoardSide.white ? 'Won' : 'Lost',
      '0-1' => side == ReviewBoardSide.black ? 'Won' : 'Lost',
      '1/2-1/2' => 'Draw',
      _ => null,
    };
  }
}

class ReviewEvalDisplay {
  const ReviewEvalDisplay({
    required this.whiteShare,
    required this.label,
    required this.advantageLabel,
    required this.isKnown,
  });

  /// White share of the vertical bar, 0..1.
  final double whiteShare;
  final String label;
  final String advantageLabel;
  final bool isKnown;

  bool get whiteBetter => whiteShare > 0.54;
  bool get blackBetter => whiteShare < 0.46;
  bool get isEqual => !whiteBetter && !blackBetter;

  factory ReviewEvalDisplay.fromMove(MoveAnalysis? move) {
    if (move == null) {
      return const ReviewEvalDisplay(
        whiteShare: 0.5,
        label: '-',
        advantageLabel: 'Equal',
        isKnown: false,
      );
    }

    final mate = move.mateInAfter;
    if (mate != null) {
      final whiteShare = mate > 0 ? 1.0 : 0.0;
      return ReviewEvalDisplay(
        whiteShare: whiteShare,
        label: 'M${mate.abs()}',
        advantageLabel: mate > 0 ? 'White' : 'Black',
        isKnown: true,
      );
    }

    final cp = move.scoreCpAfter;
    final rawShare = cp != null
        ? _shareFromCentipawns(cp)
        : (move.winPercentAfter / 100).clamp(0.0, 1.0);
    final share = _stabilize(rawShare);
    final label = cp == null ? _winLabel(move.winPercentAfter) : _cpLabel(cp);
    return ReviewEvalDisplay(
      whiteShare: share,
      label: label,
      advantageLabel: share > 0.54
          ? 'White'
          : share < 0.46
          ? 'Black'
          : 'Equal',
      isKnown: cp != null || move.winPercentAfter != 50,
    );
  }

  static double _shareFromCentipawns(int cp) {
    final clamped = cp.clamp(-1000, 1000).toDouble();
    final w = 2.0 / (1.0 + _expApprox(-0.00368208 * clamped)) - 1.0;
    return ((50 + 50 * w) / 100).clamp(0.0, 1.0);
  }

  static double _stabilize(double value) {
    return ((value.clamp(0.0, 1.0) * 50).round() / 50).clamp(0.0, 1.0);
  }

  static double _expApprox(double x) {
    var y = 1.0 + x / 1024.0;
    for (var i = 0; i < 10; i++) {
      y = y * y;
    }
    return y;
  }

  static String _cpLabel(int cp) {
    if (cp.abs() < 15) return 'Equal';
    final pawns = (cp / 100).clamp(-99.9, 99.9);
    final sign = pawns >= 0 ? '+' : '';
    return '$sign${pawns.toStringAsFixed(1)}';
  }

  static String _winLabel(double winPercent) {
    if ((winPercent - 50).abs() < 2) return 'Equal';
    return '${winPercent.round()}%';
  }
}

class ReviewMoveQualityChipDisplay {
  const ReviewMoveQualityChipDisplay({
    required this.label,
    required this.color,
    required this.marker,
  });

  final String label;
  final Color color;
  final String marker;

  factory ReviewMoveQualityChipDisplay.fromMove(MoveAnalysis move) {
    final label = MoveQualityDisplay.labelForMove(move);
    return ReviewMoveQualityChipDisplay.fromLabel(label);
  }

  factory ReviewMoveQualityChipDisplay.fromLabel(ReviewMoveLabel label) {
    return ReviewMoveQualityChipDisplay(
      label: label.label,
      color: label.color,
      marker: markerForLabel(label),
    );
  }

  static String markerForLabel(ReviewMoveLabel label) {
    return switch (label) {
      ReviewMoveLabel.brilliant => '!!',
      ReviewMoveLabel.great => '!',
      ReviewMoveLabel.best => '*',
      ReviewMoveLabel.excellent => '+',
      ReviewMoveLabel.good => '',
      ReviewMoveLabel.book => 'Book',
      ReviewMoveLabel.inaccuracy => '?!',
      ReviewMoveLabel.mistake || ReviewMoveLabel.miss => '?',
      ReviewMoveLabel.blunder => '??',
      ReviewMoveLabel.checkmate => '#',
    };
  }
}

class ReviewCoachInsightDisplay {
  const ReviewCoachInsightDisplay({
    required this.moveLabel,
    required this.san,
    required this.explanation,
    required this.coachDetail,
    required this.quality,
    this.betterMove,
    this.engineLinePreview,
    this.needsDeepScan = false,
  });

  final String moveLabel;
  final String san;
  final String explanation;
  final String coachDetail;
  final ReviewMoveQualityChipDisplay quality;
  final String? betterMove;
  final String? engineLinePreview;
  final bool needsDeepScan;

  factory ReviewCoachInsightDisplay.empty() {
    return const ReviewCoachInsightDisplay(
      moveLabel: 'Review',
      san: 'Move',
      explanation: 'Choose a move.',
      coachDetail: 'No deeper explanation available for this move.',
      quality: ReviewMoveQualityChipDisplay(
        label: 'Move',
        color: Color(0xFF4FC3FF),
        marker: '',
      ),
    );
  }

  factory ReviewCoachInsightDisplay.fromMove(
    MoveAnalysis? move, {
    required AnalysisTimeline? timeline,
    required AnalysisMode mode,
    required bool? userIsWhite,
  }) {
    if (move == null) return ReviewCoachInsightDisplay.empty();
    final explanation = const CoachExplanationService().explain(
      CoachExplanationInput(
        move: move,
        mode: mode,
        userIsWhite: userIsWhite,
        previousUserMove: _previousUserMove(
          move,
          timeline: timeline,
          userIsWhite: userIsWhite,
        ),
      ),
    );
    final quality = ReviewMoveQualityChipDisplay.fromMove(move);
    return ReviewCoachInsightDisplay(
      moveLabel: _moveNumberLabel(move.ply),
      san: move.san.isEmpty ? 'Move' : move.san,
      explanation: _shortExplanation(
        explanation.subline,
        fallback: _fallbackForQuality(MoveQualityDisplay.labelForMove(move)),
      ),
      coachDetail: _coachDetailFor(move),
      quality: quality,
      betterMove: explanation.betterMoveSan ?? _safeBetterMove(move),
      engineLinePreview: _linePreview(move),
      needsDeepScan: explanation.needsDeepScan,
    );
  }

  static MoveAnalysis? _previousUserMove(
    MoveAnalysis move, {
    required AnalysisTimeline? timeline,
    required bool? userIsWhite,
  }) {
    if (timeline == null || userIsWhite == null) return null;
    for (var i = move.ply - 1; i >= 0; i--) {
      final prior = timeline[i];
      if (prior != null && prior.isWhiteMove == userIsWhite) return prior;
    }
    return null;
  }

  static String? _safeBetterMove(MoveAnalysis move) {
    if (!ReviewBoardDisplayModel.shouldShowBetterMoveArrow(move)) return null;
    return move.engineBestMoveSan;
  }

  static String? _linePreview(MoveAnalysis move) {
    if (move.engineLines.isEmpty) return null;
    final firstLine = move.engineLines.first;
    final san = firstLine.moveSan ?? firstLine.pvMoves.take(3).join(' ');
    final trimmed = san.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _shortExplanation(String raw, {required String fallback}) {
    var text = raw.trim();
    if (text.isEmpty) return fallback;
    if (_containsDebugTerm(text)) return fallback;
    final firstSentence = text.split(RegExp(r'(?<=[.!?])\s+')).first.trim();
    if (firstSentence.isNotEmpty) text = firstSentence;
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    if (text.length <= 86) return text;
    return '${text.substring(0, 83).trimRight()}...';
  }

  static bool _containsDebugTerm(String text) {
    final lower = text.toLowerCase();
    return lower.contains('stockfish') ||
        lower.contains(' pv') ||
        lower.contains('centipawn') ||
        lower.contains('debug');
  }

  static String _fallbackForQuality(ReviewMoveLabel label) {
    return switch (label) {
      ReviewMoveLabel.brilliant => 'Finds a rare resource.',
      ReviewMoveLabel.great => 'Finds the key idea.',
      ReviewMoveLabel.best => 'Keeps the advantage.',
      ReviewMoveLabel.excellent => 'Strong and accurate.',
      ReviewMoveLabel.good => 'Keeps the position playable.',
      ReviewMoveLabel.book => 'Known opening move.',
      ReviewMoveLabel.inaccuracy => 'Drifts from the best line.',
      ReviewMoveLabel.mistake => 'A stronger move was available.',
      ReviewMoveLabel.miss => 'Missed a stronger tactic.',
      ReviewMoveLabel.blunder => 'Gives the opponent a decisive chance.',
      ReviewMoveLabel.checkmate => 'Checkmate.',
    };
  }

  static String _coachDetailFor(MoveAnalysis move) {
    final label = MoveQualityDisplay.labelForMove(move);
    if (move.classification == MoveQuality.book || move.inBook) {
      return 'Book move in the opening.';
    }
    return switch (label) {
      ReviewMoveLabel.brilliant => 'This move finds a rare resource.',
      ReviewMoveLabel.great => 'This move finds the key idea.',
      ReviewMoveLabel.best => 'This move keeps the advantage.',
      ReviewMoveLabel.excellent =>
        'This move keeps the position under control.',
      ReviewMoveLabel.good => 'This move keeps the game playable.',
      ReviewMoveLabel.book => 'Book move in the opening.',
      ReviewMoveLabel.inaccuracy => 'This move misses a stronger continuation.',
      ReviewMoveLabel.mistake => 'A stronger move was available.',
      ReviewMoveLabel.miss => 'This move misses a stronger tactic.',
      ReviewMoveLabel.blunder => 'This gives the opponent a clear chance.',
      ReviewMoveLabel.checkmate => 'Checkmate.',
    };
  }

  static String _moveNumberLabel(int ply) =>
      '${(ply ~/ 2) + 1}${ply.isEven ? '.' : '...'}';
}

class ReviewTimelinePlyDisplay {
  const ReviewTimelinePlyDisplay({
    required this.ply,
    required this.label,
    required this.marker,
    required this.color,
    required this.isActive,
  });

  final int ply;
  final String label;
  final String marker;
  final Color color;
  final bool isActive;

  factory ReviewTimelinePlyDisplay.fromMove(
    MoveAnalysis move, {
    required int activePly,
  }) {
    final label = move.isWhiteMove
        ? '${(move.ply ~/ 2) + 1}. ${move.san}'
        : '${(move.ply ~/ 2) + 1}... ${move.san}';
    final quality = ReviewMoveQualityChipDisplay.fromMove(move);
    return ReviewTimelinePlyDisplay(
      ply: move.ply,
      label: label,
      marker: quality.marker,
      color: quality.color,
      isActive: move.ply == activePly,
    );
  }

  static List<ReviewTimelinePlyDisplay> fromTimeline(
    AnalysisTimeline timeline, {
    required int activePly,
  }) {
    return [
      for (final move in timeline.moves)
        ReviewTimelinePlyDisplay.fromMove(move, activePly: activePly),
    ];
  }
}

class ReviewBoardDisplayModel {
  const ReviewBoardDisplayModel({
    required this.currentFen,
    required this.currentMove,
    required this.currentPly,
    required this.totalPlies,
    required this.flipped,
    required this.topPlayer,
    required this.bottomPlayer,
    required this.eval,
    required this.insight,
    required this.timeline,
    this.lastMove,
    this.selectedSquare,
    this.bestMoveArrow,
  });

  final String currentFen;
  final MoveAnalysis? currentMove;
  final int currentPly;
  final int totalPlies;
  final bool flipped;
  final ReviewPlayerHeaderDisplay topPlayer;
  final ReviewPlayerHeaderDisplay bottomPlayer;
  final ReviewEvalDisplay eval;
  final ReviewCoachInsightDisplay insight;
  final List<ReviewTimelinePlyDisplay> timeline;
  final (String, String)? lastMove;
  final String? selectedSquare;
  final (String, String)? bestMoveArrow;

  bool get canGoPrevious => currentPly > 0;
  bool get canGoNext => currentPly < totalPlies - 1;
  bool get hasBestMove => currentMove?.engineBestMoveSan != null;

  factory ReviewBoardDisplayModel.fromTimeline(
    AnalysisTimeline timeline, {
    required int currentPly,
    required bool flipped,
    required AnalysisMode mode,
    required bool? userIsWhite,
  }) {
    final safePly = timeline.moves.isEmpty
        ? -1
        : currentPly.clamp(0, timeline.totalPlies - 1).toInt();
    final move = timeline[safePly];
    final lastMove = _lastMoveFromUci(move?.uci);
    return ReviewBoardDisplayModel(
      currentFen: move?.fenAfter ?? timeline.startingFen,
      currentMove: move,
      currentPly: safePly,
      totalPlies: timeline.totalPlies,
      flipped: flipped,
      topPlayer: ReviewPlayerHeaderDisplay.top(
        timeline,
        flipped: flipped,
        userIsWhite: userIsWhite,
      ),
      bottomPlayer: ReviewPlayerHeaderDisplay.bottom(
        timeline,
        flipped: flipped,
        userIsWhite: userIsWhite,
      ),
      eval: ReviewEvalDisplay.fromMove(move),
      insight: ReviewCoachInsightDisplay.fromMove(
        move,
        timeline: timeline,
        mode: mode,
        userIsWhite: userIsWhite,
      ),
      timeline: ReviewTimelinePlyDisplay.fromTimeline(
        timeline,
        activePly: safePly,
      ),
      lastMove: lastMove,
      selectedSquare: move?.targetSquare.isNotEmpty == true
          ? move!.targetSquare
          : lastMove?.$2,
      bestMoveArrow: shouldShowBetterMoveArrow(move)
          ? _arrowFromUci(move?.engineBestMoveUci)
          : null,
    );
  }

  static bool shouldShowBetterMoveArrow(MoveAnalysis? move) {
    if (move == null) return false;
    if (move.engineBestMoveUci == null) return false;
    if (_playedEqualsBest(move) || move.playedEqualsPv1) return false;
    return switch (move.classification) {
      MoveQuality.brilliant ||
      MoveQuality.great ||
      MoveQuality.best ||
      MoveQuality.book ||
      MoveQuality.forced => false,
      MoveQuality.excellent || MoveQuality.good => false,
      MoveQuality.inaccuracy ||
      MoveQuality.mistake ||
      MoveQuality.missedWin ||
      MoveQuality.blunder => true,
    };
  }

  static (String, String)? _lastMoveFromUci(String? uci) {
    if (uci == null || uci.length < 4) return null;
    final normalized = normalizeCastlingUci(uci);
    if (normalized.length < 4) return null;
    return (normalized.substring(0, 2), normalized.substring(2, 4));
  }

  static (String, String)? _arrowFromUci(String? uci) {
    if (uci == null || uci.length < 4) return null;
    final normalized = normalizeCastlingUci(uci);
    if (normalized.length < 4) return null;
    return (normalized.substring(0, 2), normalized.substring(2, 4));
  }

  static bool _playedEqualsBest(MoveAnalysis move) {
    final best = move.engineBestMoveUci;
    final played = move.uci;
    if (best == null || played.isEmpty) return false;
    return normalizeCastlingUci(best) == normalizeCastlingUci(played);
  }
}
