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

  test('Only Move and Forced remain distinct stored public labels', () {
    expect(
      MoveQualityDisplay.labelForMove(
        move(MoveQuality.forced, reasonCode: 'ordinary_pv1'),
      ),
      ReviewMoveLabel.forced,
    );
    expect(
      MoveQualityDisplay.labelForMove(
        move(MoveQuality.onlyMove, reasonCode: 'only_move_avoids_mate'),
      ),
      ReviewMoveLabel.onlyMove,
    );
  });

  test('public labels expose factual forced tiers without reconstruction', () {
    final labels = MoveQualityDisplay.countOrder.map((e) => e.label).toList();
    expect(labels, containsAll(['Miss', 'Mistake', 'Only Move', 'Forced']));
    expect(labels, isNot(contains('Solid')));
    expect(labels, isNot(contains('Theory')));
    expect(MoveQualityDisplay.labelTextForQuality(MoveQuality.good), 'Good');
    expect(MoveQualityDisplay.labelTextForQuality(MoveQuality.book), 'Book');
    expect(
      MoveQualityDisplay.labelTextForQuality(MoveQuality.missedWin),
      'Miss',
    );
  });
}
