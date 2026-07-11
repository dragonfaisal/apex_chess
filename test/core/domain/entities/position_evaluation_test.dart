import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/position_evaluation.dart';

void main() {
  const fen = '8/8/8/8/8/8/4K3/7k w - - 0 1';

  test('binds a usable score to the exact FEN and explicit White POV', () {
    const evaluation = PositionEvaluation(
      scoreCp: 25,
      depth: 18,
      positionFen: fen,
      requestedDepth: 18,
    );

    expect(evaluation.isUsableFor(fen), isTrue);
    expect(evaluation.targetDepthReached, isTrue);
    expect(evaluation.perspective, EvaluationPerspective.white);
  });

  test('rejects missing, ambiguous, mate-zero, and wrong-FEN scores', () {
    const missing = PositionEvaluation(depth: 18, positionFen: fen);
    const ambiguous = PositionEvaluation(
      scoreCp: 0,
      mateIn: 2,
      depth: 18,
      positionFen: fen,
    );
    const mateZero = PositionEvaluation(mateIn: 0, depth: 18, positionFen: fen);

    expect(missing.isUsableFor(fen), isFalse);
    expect(ambiguous.isUsableFor(fen), isFalse);
    expect(mateZero.isUsableFor(fen), isFalse);
    expect(
      const PositionEvaluation(
        scoreCp: 0,
        depth: 18,
        positionFen: fen,
      ).isUsableFor('wrong'),
      isFalse,
    );
  });
}
