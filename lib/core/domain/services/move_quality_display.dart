/// User-facing move-quality labels.
///
/// Internal classifier categories remain available for debugging, but product
/// screens should use this mapper so labels stay clean and consistent.
library;

import 'package:flutter/material.dart';

import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';

enum ReviewMoveLabel {
  brilliant('Brilliant', ApexColors.brilliant),
  great('Great', ApexColors.great),
  onlyMove('Only Move', ApexColors.best),
  forced('Forced', ApexColors.textSecondary),
  best('Best', ApexColors.best),
  excellent('Excellent', ApexColors.excellent),
  good('Good', ApexColors.good),
  book('Book', ApexColors.book),
  inaccuracy('Inaccuracy', ApexColors.inaccuracy),
  mistake('Mistake', ApexColors.mistake),
  miss('Miss', ApexColors.miss),
  blunder('Blunder', ApexColors.blunder),
  unavailable('Unavailable', ApexColors.textSecondary),
  checkmate('Checkmate', ApexColors.checkmate);

  const ReviewMoveLabel(this.label, this.color);
  final String label;
  final Color color;
}

class MoveQualityDisplay {
  const MoveQualityDisplay._();

  static const countOrder = <ReviewMoveLabel>[
    ReviewMoveLabel.brilliant,
    ReviewMoveLabel.great,
    ReviewMoveLabel.onlyMove,
    ReviewMoveLabel.forced,
    ReviewMoveLabel.best,
    ReviewMoveLabel.excellent,
    ReviewMoveLabel.good,
    ReviewMoveLabel.book,
    ReviewMoveLabel.inaccuracy,
    ReviewMoveLabel.mistake,
    ReviewMoveLabel.miss,
    ReviewMoveLabel.blunder,
    ReviewMoveLabel.unavailable,
  ];

  static ReviewMoveLabel labelForMove(MoveAnalysis move) {
    if (_deliveredMate(move)) return ReviewMoveLabel.checkmate;
    return labelForQuality(move.classification, move: move);
  }

  static ReviewMoveLabel countBucketForMove(MoveAnalysis move) {
    final visible = labelForMove(move);
    if (visible == ReviewMoveLabel.checkmate) {
      return labelForQuality(move.classification, move: move);
    }
    return visible;
  }

  static ReviewMoveLabel labelForQuality(
    MoveQuality quality, {
    MoveAnalysis? move,
  }) {
    switch (quality) {
      case MoveQuality.brilliant:
        return ReviewMoveLabel.brilliant;
      case MoveQuality.great:
        return ReviewMoveLabel.great;
      case MoveQuality.onlyMove:
        return ReviewMoveLabel.onlyMove;
      case MoveQuality.forced:
        return ReviewMoveLabel.forced;
      case MoveQuality.best:
        return ReviewMoveLabel.best;
      case MoveQuality.excellent:
        return ReviewMoveLabel.excellent;
      case MoveQuality.good:
        return ReviewMoveLabel.good;
      case MoveQuality.book:
        return ReviewMoveLabel.book;
      case MoveQuality.inaccuracy:
        return ReviewMoveLabel.inaccuracy;
      case MoveQuality.mistake:
        return ReviewMoveLabel.mistake;
      case MoveQuality.blunder:
        return ReviewMoveLabel.blunder;
      case MoveQuality.missedWin:
        return ReviewMoveLabel.miss;
      case MoveQuality.unavailable:
        return ReviewMoveLabel.unavailable;
    }
  }

  static String labelTextForMove(MoveAnalysis move) => labelForMove(move).label;

  static String labelTextForQuality(
    MoveQuality quality, {
    MoveAnalysis? move,
  }) => labelForQuality(quality, move: move).label;

  static MoveQuality iconQualityForMove(MoveAnalysis move) =>
      iconQualityForLabel(labelForMove(move));

  static MoveQuality iconQualityForLabel(ReviewMoveLabel label) {
    switch (label) {
      case ReviewMoveLabel.brilliant:
      case ReviewMoveLabel.checkmate:
        return MoveQuality.brilliant;
      case ReviewMoveLabel.great:
        return MoveQuality.great;
      case ReviewMoveLabel.onlyMove:
        return MoveQuality.onlyMove;
      case ReviewMoveLabel.forced:
        return MoveQuality.forced;
      case ReviewMoveLabel.best:
        return MoveQuality.best;
      case ReviewMoveLabel.excellent:
        return MoveQuality.excellent;
      case ReviewMoveLabel.good:
        return MoveQuality.good;
      case ReviewMoveLabel.book:
        return MoveQuality.book;
      case ReviewMoveLabel.inaccuracy:
        return MoveQuality.inaccuracy;
      case ReviewMoveLabel.mistake:
        return MoveQuality.mistake;
      case ReviewMoveLabel.miss:
        return MoveQuality.missedWin;
      case ReviewMoveLabel.blunder:
        return MoveQuality.blunder;
      case ReviewMoveLabel.unavailable:
        return MoveQuality.unavailable;
    }
  }

  static bool _deliveredMate(MoveAnalysis move) {
    if (!move.san.contains('#')) return false;
    final mate = move.mateInAfter;
    if (mate == null) return true;
    return move.isWhiteMove ? mate > 0 : mate < 0;
  }
}
