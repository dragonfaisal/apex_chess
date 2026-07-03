import 'package:apex_chess/infrastructure/engine/local_raw_eval_perspective.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_eval_perspective_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizer = LocalRawEvalPerspectiveNormalizer();

  group('LocalRawEvalPerspectiveNormalizer', () {
    test('white to move, cp +50', () {
      final result = normalizer.normalizeRawEvidence(
        requestedFen: _fenWithSide('w'),
        requestedDepth: 1,
        rawScoreType: 'cp',
        rawScoreCp: 50,
        rawScoreMate: null,
      );

      expect(result.normalizationSucceeded, isTrue);
      expect(result.sideToMove, LocalRawEvalSideToMove.white);
      expect(result.whitePerspectiveCp, 50);
      expect(result.blackPerspectiveCp, -50);
      expect(result.playerPerspectiveCpWhite, result.whitePerspectiveCp);
      expect(result.playerPerspectiveCpBlack, result.blackPerspectiveCp);
    });

    test('white to move, cp -50', () {
      final result = normalizer.normalizeRawEvidence(
        requestedFen: _fenWithSide('w'),
        requestedDepth: 1,
        rawScoreType: 'cp',
        rawScoreCp: -50,
        rawScoreMate: null,
      );

      expect(result.normalizationSucceeded, isTrue);
      expect(result.whitePerspectiveCp, -50);
      expect(result.blackPerspectiveCp, 50);
      expect(result.playerPerspectiveCpWhite, result.whitePerspectiveCp);
      expect(result.playerPerspectiveCpBlack, result.blackPerspectiveCp);
    });

    test('black to move, cp +50', () {
      final result = normalizer.normalizeRawEvidence(
        requestedFen: _fenWithSide('b'),
        requestedDepth: 1,
        rawScoreType: 'cp',
        rawScoreCp: 50,
        rawScoreMate: null,
      );

      expect(result.normalizationSucceeded, isTrue);
      expect(result.sideToMove, LocalRawEvalSideToMove.black);
      expect(result.whitePerspectiveCp, -50);
      expect(result.blackPerspectiveCp, 50);
      expect(result.playerPerspectiveCpWhite, result.whitePerspectiveCp);
      expect(result.playerPerspectiveCpBlack, result.blackPerspectiveCp);
    });

    test('black to move, cp -50', () {
      final result = normalizer.normalizeRawEvidence(
        requestedFen: _fenWithSide('b'),
        requestedDepth: 1,
        rawScoreType: 'cp',
        rawScoreCp: -50,
        rawScoreMate: null,
      );

      expect(result.normalizationSucceeded, isTrue);
      expect(result.whitePerspectiveCp, 50);
      expect(result.blackPerspectiveCp, -50);
      expect(result.playerPerspectiveCpWhite, result.whitePerspectiveCp);
      expect(result.playerPerspectiveCpBlack, result.blackPerspectiveCp);
    });

    test('white to move, mate +3', () {
      final result = normalizer.normalizeRawEvidence(
        requestedFen: _fenWithSide('w'),
        requestedDepth: 1,
        rawScoreType: 'mate',
        rawScoreCp: null,
        rawScoreMate: 3,
      );

      expect(result.normalizationSucceeded, isTrue);
      expect(result.sideToMove, LocalRawEvalSideToMove.white);
      expect(result.whitePerspectiveMate, 3);
      expect(result.blackPerspectiveMate, -3);
      expect(result.whitePerspectiveCp, isNull);
      expect(result.blackPerspectiveCp, isNull);
      expect(result.playerPerspectiveMateWhite, result.whitePerspectiveMate);
      expect(result.playerPerspectiveMateBlack, result.blackPerspectiveMate);
    });

    test('black to move, mate +3', () {
      final result = normalizer.normalizeRawEvidence(
        requestedFen: _fenWithSide('b'),
        requestedDepth: 1,
        rawScoreType: 'mate',
        rawScoreCp: null,
        rawScoreMate: 3,
      );

      expect(result.normalizationSucceeded, isTrue);
      expect(result.sideToMove, LocalRawEvalSideToMove.black);
      expect(result.whitePerspectiveMate, -3);
      expect(result.blackPerspectiveMate, 3);
      expect(result.whitePerspectiveCp, isNull);
      expect(result.blackPerspectiveCp, isNull);
      expect(result.playerPerspectiveMateWhite, result.whitePerspectiveMate);
      expect(result.playerPerspectiveMateBlack, result.blackPerspectiveMate);
    });

    test('invalid FEN side token fails closed', () {
      final result = normalizer.normalizeRawEvidence(
        requestedFen: _fenWithSide('x'),
        requestedDepth: 1,
        rawScoreType: 'cp',
        rawScoreCp: 50,
        rawScoreMate: null,
      );

      expect(result.normalizationSucceeded, isFalse);
      expect(result.safeForPhase35G, isFalse);
      expect(
        result.nextRecommendation,
        localRawEvalPerspectiveFailureRecommendation,
      );
      expect(result.failureMessage, contains('must be w or b'));
    });

    test('missing FEN side token fails closed', () {
      final result = normalizer.normalizeRawEvidence(
        requestedFen: '8/8/8/8/8/8/8/8',
        requestedDepth: 1,
        rawScoreType: 'cp',
        rawScoreCp: 50,
        rawScoreMate: null,
      );

      expect(result.normalizationSucceeded, isFalse);
      expect(result.safeForPhase35G, isFalse);
      expect(
        result.nextRecommendation,
        localRawEvalPerspectiveFailureRecommendation,
      );
      expect(result.failureMessage, contains('missing'));
    });
  });
}

String _fenWithSide(String sideToken) {
  return 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR '
      '$sideToken KQkq - 0 1';
}
