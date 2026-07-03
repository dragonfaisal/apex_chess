import 'package:apex_chess/features/analysis/domain/analyzer_raw_eval_result.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_single_fen_raw_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_single_fen_raw_eval_adapter.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_engine_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_raw_eval_perspective.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalAnalyzerSingleFenRawEvalAdapter', () {
    test('maps white requested player to whitePerspectiveCp', () async {
      final adapter = _adapter(
        rawEval: _rawEval(),
        perspective: _perspective(
          whitePerspectiveCp: -39,
          blackPerspectiveCp: 39,
        ),
      );

      final result = await adapter.evaluate(
        const AnalyzerSingleFenRawEvalRequest.controlled(),
      );

      expect(result.analyzerRawEvalSucceeded, isTrue);
      expect(result.requestedPlayerColor, AnalyzerRequestedPlayerColor.white);
      expect(result.whitePerspectiveCp, -39);
      expect(result.blackPerspectiveCp, 39);
      expect(result.playerPerspectiveCp, result.whitePerspectiveCp);
      expect(result.playerPerspectiveMate, isNull);
      expect(result.safeForPhase35H, isTrue);
      expect(result.nextRecommendation, analyzerRawEvalNextRecommendation);
    });

    test('maps black requested player to blackPerspectiveCp', () async {
      final adapter = _adapter(
        rawEval: _rawEval(),
        perspective: _perspective(
          whitePerspectiveCp: -39,
          blackPerspectiveCp: 39,
        ),
      );

      final result = await adapter.evaluate(
        const AnalyzerSingleFenRawEvalRequest.controlled(
          requestedPlayerColor: AnalyzerRequestedPlayerColor.black,
        ),
      );

      expect(result.analyzerRawEvalSucceeded, isTrue);
      expect(result.requestedPlayerColor, AnalyzerRequestedPlayerColor.black);
      expect(result.playerPerspectiveCp, result.blackPerspectiveCp);
      expect(result.playerPerspectiveCp, 39);
      expect(result.playerPerspectiveMate, isNull);
      expect(result.safeForPhase35H, isTrue);
    });

    test('fails closed when raw eval bridge fails', () async {
      final adapter = _adapter(rawEval: _failedRawEval());

      final result = await adapter.evaluate(
        const AnalyzerSingleFenRawEvalRequest.controlled(),
      );

      expect(result.engineSucceeded, isFalse);
      expect(result.perspectiveNormalizationSucceeded, isFalse);
      expect(result.analyzerRawEvalSucceeded, isFalse);
      expect(result.safeForPhase35H, isFalse);
      expect(result.nextRecommendation, analyzerRawEvalFailureRecommendation);
      expect(result.failureMessage, isNotNull);
    });

    test('fails closed when perspective normalization fails', () async {
      final adapter = _adapter(
        rawEval: _rawEval(),
        perspective: _failedPerspective(),
      );

      final result = await adapter.evaluate(
        const AnalyzerSingleFenRawEvalRequest.controlled(),
      );

      expect(result.engineSucceeded, isTrue);
      expect(result.perspectiveNormalizationSucceeded, isFalse);
      expect(result.analyzerRawEvalSucceeded, isFalse);
      expect(result.safeForPhase35H, isFalse);
      expect(result.nextRecommendation, analyzerRawEvalFailureRecommendation);
      expect(result.failureMessage, contains('normalization failed'));
    });

    test(
      'result does not contain classifier or product metric fields',
      () async {
        final adapter = _adapter(
          rawEval: _rawEval(),
          perspective: _perspective(
            whitePerspectiveCp: -39,
            blackPerspectiveCp: 39,
          ),
        );

        final result = await adapter.evaluate(
          const AnalyzerSingleFenRawEvalRequest.controlled(),
        );
        final json = result.toJson();

        for (final forbiddenField in _forbiddenFields) {
          expect(json.containsKey(forbiddenField), isFalse);
        }
      },
    );
  });
}

const _forbiddenFields = <String>[
  'label',
  'classification',
  'moveQuality',
  'winPercent',
  'whiteWinPercent',
  'cpLoss',
  'accuracy',
  'acpl',
  'book',
  'openingPhase',
  'explanation',
];

LocalAnalyzerSingleFenRawEvalAdapter _adapter({
  required LocalRawEngineEval rawEval,
  LocalRawEvalPerspective? perspective,
}) {
  return LocalAnalyzerSingleFenRawEvalAdapter(
    rawEvalLoader:
        ({
          required String requestedFen,
          required int requestedDepth,
          required Duration timeout,
        }) async => rawEval,
    perspectiveNormalizer: perspective == null ? null : (_) => perspective,
  );
}

LocalRawEngineEval _rawEval() {
  return const LocalRawEngineEval(
    requestedFen: analyzerSingleFenRawEvalControlledFen,
    requestedDepth: analyzerSingleFenRawEvalDepth,
    engineSource: localRawEngineEvalEngineSource,
    bridgeSource: localRawEngineEvalBridgeSource,
    handshakeSucceeded: true,
    fenInputSucceeded: true,
    searchSucceeded: true,
    bestMove: 'e2e3',
    bestMoveReceived: true,
    infoDepthSeen: 1,
    rawScoreSeen: true,
    scoreType: 'cp',
    scoreCp: -39,
    scoreMate: null,
    rawScoreValue: -39,
    timedOut: false,
    failedToLaunch: false,
    failureMessage: null,
    sanitizedOutputPreview: [],
    rawOutputLineCount: 34,
    safeForAnalyzerAdapterPhase: true,
    nextRecommendation: localRawEngineEvalNextRecommendation,
    blockers: [],
    warnings: [],
  );
}

LocalRawEngineEval _failedRawEval() {
  return const LocalRawEngineEval(
    requestedFen: analyzerSingleFenRawEvalControlledFen,
    requestedDepth: analyzerSingleFenRawEvalDepth,
    engineSource: localRawEngineEvalEngineSource,
    bridgeSource: localRawEngineEvalBridgeSource,
    handshakeSucceeded: false,
    fenInputSucceeded: false,
    searchSucceeded: false,
    bestMove: null,
    bestMoveReceived: false,
    infoDepthSeen: null,
    rawScoreSeen: false,
    scoreType: null,
    scoreCp: null,
    scoreMate: null,
    rawScoreValue: null,
    timedOut: false,
    failedToLaunch: true,
    failureMessage: 'raw eval bridge failed',
    sanitizedOutputPreview: [],
    rawOutputLineCount: 0,
    safeForAnalyzerAdapterPhase: false,
    nextRecommendation: localRawEngineEvalFailureRecommendation,
    blockers: ['Raw eval bridge failed.'],
    warnings: [],
  );
}

LocalRawEvalPerspective _perspective({
  required int whitePerspectiveCp,
  required int blackPerspectiveCp,
}) {
  return LocalRawEvalPerspective(
    requestedFen: analyzerSingleFenRawEvalControlledFen,
    requestedDepth: analyzerSingleFenRawEvalDepth,
    sideToMove: LocalRawEvalSideToMove.white,
    rawScoreType: 'cp',
    rawScoreCp: whitePerspectiveCp,
    rawScoreMate: null,
    rawScorePerspective: localRawEvalPerspectiveScorePerspective,
    whitePerspectiveCp: whitePerspectiveCp,
    blackPerspectiveCp: blackPerspectiveCp,
    whitePerspectiveMate: null,
    blackPerspectiveMate: null,
    playerPerspectiveCpWhite: whitePerspectiveCp,
    playerPerspectiveCpBlack: blackPerspectiveCp,
    playerPerspectiveMateWhite: null,
    playerPerspectiveMateBlack: null,
    normalizationSucceeded: true,
    failureMessage: null,
    safeForPhase35G: true,
    nextRecommendation: localRawEvalPerspectiveNextRecommendation,
    blockers: const [],
    warnings: const [],
  );
}

LocalRawEvalPerspective _failedPerspective() {
  return const LocalRawEvalPerspective(
    requestedFen: analyzerSingleFenRawEvalControlledFen,
    requestedDepth: analyzerSingleFenRawEvalDepth,
    sideToMove: LocalRawEvalSideToMove.white,
    rawScoreType: 'cp',
    rawScoreCp: -39,
    rawScoreMate: null,
    rawScorePerspective: localRawEvalPerspectiveScorePerspective,
    whitePerspectiveCp: null,
    blackPerspectiveCp: null,
    whitePerspectiveMate: null,
    blackPerspectiveMate: null,
    playerPerspectiveCpWhite: null,
    playerPerspectiveCpBlack: null,
    playerPerspectiveMateWhite: null,
    playerPerspectiveMateBlack: null,
    normalizationSucceeded: false,
    failureMessage: 'normalization failed',
    safeForPhase35G: false,
    nextRecommendation: localRawEvalPerspectiveFailureRecommendation,
    blockers: ['Perspective normalization failed.'],
    warnings: [],
  );
}
