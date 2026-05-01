import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/deep_tactical_verdict.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_quality_display.dart';

void main() {
  MoveAnalysis move(
    MoveQuality quality, {
    String san = 'Nf3',
    String reasonCode = 'test',
    DeepTacticalVerdict tacticalVerdict = DeepTacticalVerdict.none,
  }) {
    return MoveAnalysis(
      ply: 0,
      san: san,
      uci: 'g1f3',
      fenBefore: 'start',
      fenAfter: 'after',
      winPercentBefore: 50,
      winPercentAfter: 50,
      deltaW: 0,
      isWhiteMove: true,
      classification: quality,
      reasonCode: reasonCode,
      tacticalVerdict: tacticalVerdict,
      message: '',
    );
  }

  test('clean display labels map internal names', () {
    expect(
      MoveQualityDisplay.labelForMove(move(MoveQuality.good)),
      ReviewMoveLabel.good,
    );
    expect(
      MoveQualityDisplay.labelForMove(move(MoveQuality.book)),
      ReviewMoveLabel.book,
    );
    expect(
      MoveQualityDisplay.labelForMove(move(MoveQuality.missedWin)),
      ReviewMoveLabel.miss,
    );
    expect(
      MoveQualityDisplay.labelForMove(move(MoveQuality.best, san: 'Qh7#')),
      ReviewMoveLabel.checkmate,
    );
  });

  test('forced maps to Great only when outcome-changing', () {
    expect(
      MoveQualityDisplay.labelForMove(
        move(MoveQuality.forced, reasonCode: 'ordinary_pv1'),
      ),
      ReviewMoveLabel.best,
    );
    expect(
      MoveQualityDisplay.labelForMove(
        move(MoveQuality.forced, reasonCode: 'only_move_avoids_mate'),
      ),
      ReviewMoveLabel.great,
    );
  });
}
