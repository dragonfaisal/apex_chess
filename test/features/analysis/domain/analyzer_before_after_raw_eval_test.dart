import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_raw_eval_result.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_single_fen_raw_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_before_after_raw_eval_probe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalAnalyzerBeforeAfterRawEvalProbe', () {
    test(
      'white mover maps before and after to white perspective fields',
      () async {
        final probe = _probe(
          before: _result(
            fen: analyzerBeforeAfterRawEvalControlledBeforeFen,
            sideToMove: AnalyzerFenSideToMove.white,
            rawScoreCp: -39,
            whitePerspectiveCp: -39,
            blackPerspectiveCp: 39,
            bestMove: 'e2e3',
          ),
          after: _result(
            fen: analyzerBeforeAfterRawEvalControlledAfterFen,
            sideToMove: AnalyzerFenSideToMove.black,
            rawScoreCp: 30,
            whitePerspectiveCp: -30,
            blackPerspectiveCp: 30,
            bestMove: 'c7c5',
          ),
        );

        final result = await probe.run(
          const AnalyzerBeforeAfterRawEvalRequest.controlled(),
        );

        expect(result.beforeAfterRawEvalSucceeded, isTrue);
        expect(result.moverColor, AnalyzerMoverColor.white);
        expect(
          result.moverPerspectiveBeforeCp,
          result.beforeWhitePerspectiveCp,
        );
        expect(result.moverPerspectiveAfterCp, result.afterWhitePerspectiveCp);
        expect(result.moverPerspectiveBeforeCp, -39);
        expect(result.moverPerspectiveAfterCp, -30);
        expect(result.safeForPhase35I, isTrue);
        expect(
          result.nextRecommendation,
          analyzerBeforeAfterRawEvalNextRecommendation,
        );
      },
    );

    test(
      'black mover maps before and after to black perspective fields',
      () async {
        final probe = _probe(
          before: _result(
            fen: analyzerBeforeAfterRawEvalControlledBeforeFen,
            sideToMove: AnalyzerFenSideToMove.white,
            rawScoreCp: -39,
            whitePerspectiveCp: -39,
            blackPerspectiveCp: 39,
            bestMove: 'e2e3',
            requestedPlayerColor: AnalyzerRequestedPlayerColor.black,
          ),
          after: _result(
            fen: analyzerBeforeAfterRawEvalControlledAfterFen,
            sideToMove: AnalyzerFenSideToMove.black,
            rawScoreCp: 30,
            whitePerspectiveCp: -30,
            blackPerspectiveCp: 30,
            bestMove: 'c7c5',
            requestedPlayerColor: AnalyzerRequestedPlayerColor.black,
          ),
        );

        final result = await probe.run(
          const AnalyzerBeforeAfterRawEvalRequest.controlled(
            moverColor: AnalyzerMoverColor.black,
          ),
        );

        expect(result.beforeAfterRawEvalSucceeded, isTrue);
        expect(result.moverColor, AnalyzerMoverColor.black);
        expect(
          result.moverPerspectiveBeforeCp,
          result.beforeBlackPerspectiveCp,
        );
        expect(result.moverPerspectiveAfterCp, result.afterBlackPerspectiveCp);
        expect(result.moverPerspectiveBeforeCp, 39);
        expect(result.moverPerspectiveAfterCp, 30);
        expect(result.safeForPhase35I, isTrue);
      },
    );

    test('fails closed if before eval fails', () async {
      final probe = _probe(
        before: _failedResult(
          fen: analyzerBeforeAfterRawEvalControlledBeforeFen,
          failureMessage: 'before failed',
        ),
        after: _result(
          fen: analyzerBeforeAfterRawEvalControlledAfterFen,
          sideToMove: AnalyzerFenSideToMove.black,
          rawScoreCp: 30,
          whitePerspectiveCp: -30,
          blackPerspectiveCp: 30,
          bestMove: 'c7c5',
        ),
      );

      final result = await probe.run(
        const AnalyzerBeforeAfterRawEvalRequest.controlled(),
      );

      expect(result.beforeEvalSucceeded, isFalse);
      expect(result.afterEvalSucceeded, isTrue);
      expect(result.beforeAfterRawEvalSucceeded, isFalse);
      expect(result.safeForPhase35I, isFalse);
      expect(
        result.nextRecommendation,
        analyzerBeforeAfterRawEvalFailureRecommendation,
      );
      expect(result.failureMessage, contains('Before eval failed'));
    });

    test('fails closed if after eval fails', () async {
      final probe = _probe(
        before: _result(
          fen: analyzerBeforeAfterRawEvalControlledBeforeFen,
          sideToMove: AnalyzerFenSideToMove.white,
          rawScoreCp: -39,
          whitePerspectiveCp: -39,
          blackPerspectiveCp: 39,
          bestMove: 'e2e3',
        ),
        after: _failedResult(
          fen: analyzerBeforeAfterRawEvalControlledAfterFen,
          failureMessage: 'after failed',
        ),
      );

      final result = await probe.run(
        const AnalyzerBeforeAfterRawEvalRequest.controlled(),
      );

      expect(result.beforeEvalSucceeded, isTrue);
      expect(result.afterEvalSucceeded, isFalse);
      expect(result.beforeAfterRawEvalSucceeded, isFalse);
      expect(result.safeForPhase35I, isFalse);
      expect(result.failureMessage, contains('After eval failed'));
    });

    test('does not compute delta, CP-loss, Win%, or classification', () async {
      final probe = _probe(
        before: _result(
          fen: analyzerBeforeAfterRawEvalControlledBeforeFen,
          sideToMove: AnalyzerFenSideToMove.white,
          rawScoreCp: -39,
          whitePerspectiveCp: -39,
          blackPerspectiveCp: 39,
          bestMove: 'e2e3',
        ),
        after: _result(
          fen: analyzerBeforeAfterRawEvalControlledAfterFen,
          sideToMove: AnalyzerFenSideToMove.black,
          rawScoreCp: 30,
          whitePerspectiveCp: -30,
          blackPerspectiveCp: 30,
          bestMove: 'c7c5',
        ),
      );

      final result = await probe.run(
        const AnalyzerBeforeAfterRawEvalRequest.controlled(),
      );
      final json = result.toJson();

      expect(result.deltaComputed, isFalse);
      expect(result.cpLossComputed, isFalse);
      expect(result.winPercentComputed, isFalse);
      expect(result.classificationComputed, isFalse);
      for (final forbiddenField in _forbiddenFields) {
        expect(json.containsKey(forbiddenField), isFalse);
      }
    });
  });
}

const _forbiddenFields = <String>[
  'label',
  'moveLabel',
  'moveQuality',
  'winPercent',
  'whiteWinPercent',
  'blackWinPercent',
  'cpLoss',
  'accuracy',
  'acpl',
  'book',
  'openingPhase',
  'explanation',
];

LocalAnalyzerBeforeAfterRawEvalProbe _probe({
  required AnalyzerRawEvalResult before,
  required AnalyzerRawEvalResult after,
}) {
  return LocalAnalyzerBeforeAfterRawEvalProbe(
    singleFenRunner: (request, {timeout = const Duration(seconds: 5)}) async {
      if (request.fen == analyzerBeforeAfterRawEvalControlledBeforeFen) {
        return before;
      }
      if (request.fen == analyzerBeforeAfterRawEvalControlledAfterFen) {
        return after;
      }
      throw StateError('Unexpected FEN: ${request.fen}');
    },
  );
}

AnalyzerRawEvalResult _result({
  required String fen,
  required AnalyzerFenSideToMove sideToMove,
  required int rawScoreCp,
  required int whitePerspectiveCp,
  required int blackPerspectiveCp,
  required String bestMove,
  AnalyzerRequestedPlayerColor requestedPlayerColor =
      AnalyzerRequestedPlayerColor.white,
}) {
  final playerPerspectiveCp = switch (requestedPlayerColor) {
    AnalyzerRequestedPlayerColor.white => whitePerspectiveCp,
    AnalyzerRequestedPlayerColor.black => blackPerspectiveCp,
  };
  return AnalyzerRawEvalResult(
    fen: fen,
    requestedDepth: analyzerBeforeAfterRawEvalDepth,
    requestedPlayerColor: requestedPlayerColor,
    engineSource: 'fakeLocalStockfishUci',
    bridgeSource: 'fakeLocalSearchEvalProbe',
    rawScoreType: 'cp',
    rawScoreCp: rawScoreCp,
    rawScoreMate: null,
    rawScorePerspective: 'sideToMove',
    sideToMove: sideToMove,
    whitePerspectiveCp: whitePerspectiveCp,
    blackPerspectiveCp: blackPerspectiveCp,
    whitePerspectiveMate: null,
    blackPerspectiveMate: null,
    playerPerspectiveCp: playerPerspectiveCp,
    playerPerspectiveMate: null,
    bestMove: bestMove,
    bestMoveReceived: true,
    infoDepthSeen: analyzerBeforeAfterRawEvalDepth,
    engineSucceeded: true,
    perspectiveNormalizationSucceeded: true,
    analyzerRawEvalSucceeded: true,
    failureMessage: null,
    safeForPhase35H: true,
    nextRecommendation: analyzerRawEvalNextRecommendation,
    blockers: const [],
    warnings: const [],
  );
}

AnalyzerRawEvalResult _failedResult({
  required String fen,
  required String failureMessage,
}) {
  return AnalyzerRawEvalResult(
    fen: fen,
    requestedDepth: analyzerBeforeAfterRawEvalDepth,
    requestedPlayerColor: AnalyzerRequestedPlayerColor.white,
    engineSource: 'fakeLocalStockfishUci',
    bridgeSource: 'fakeLocalSearchEvalProbe',
    rawScoreType: null,
    rawScoreCp: null,
    rawScoreMate: null,
    rawScorePerspective: 'sideToMove',
    sideToMove: null,
    whitePerspectiveCp: null,
    blackPerspectiveCp: null,
    whitePerspectiveMate: null,
    blackPerspectiveMate: null,
    playerPerspectiveCp: null,
    playerPerspectiveMate: null,
    bestMove: null,
    bestMoveReceived: false,
    infoDepthSeen: null,
    engineSucceeded: false,
    perspectiveNormalizationSucceeded: false,
    analyzerRawEvalSucceeded: false,
    failureMessage: failureMessage,
    safeForPhase35H: false,
    nextRecommendation: analyzerRawEvalFailureRecommendation,
    blockers: const ['fake analyzer raw eval failed'],
    warnings: const [],
  );
}
