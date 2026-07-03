import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_cp_loss_candidate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_raw_eval_result.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_single_fen_raw_eval.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_cp_loss_candidate_probe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalAnalyzerCpLossCandidateProbe', () {
    test('candidate better computes positive loss candidate', () async {
      final probe = _probe(
        before: _result(fen: analyzerCpLossCandidateBeforeFen, playerCp: -39),
        playedAfter: _result(
          fen: analyzerCpLossCandidatePlayedAfterFen,
          playerCp: 95,
        ),
        candidateAfter: _result(
          fen: analyzerCpLossCandidateCandidateAfterFen,
          playerCp: 120,
        ),
      );

      final result = await probe.run(
        const AnalyzerCpLossCandidateRequest.controlled(),
      );

      expect(result.cpLossCandidateComputed, isTrue);
      expect(result.moverPerspectiveCpLossCandidate, 25);
      expect(
        result.cpLossCandidateDirection,
        AnalyzerCpLossCandidateDirection.candidateBetter,
      );
      expect(result.safeForPhase35K, isTrue);
      expect(
        result.nextRecommendation,
        analyzerCpLossCandidateNextRecommendation,
      );
    });

    test('played better preserves negative loss candidate', () async {
      final probe = _probe(
        before: _result(fen: analyzerCpLossCandidateBeforeFen, playerCp: -39),
        playedAfter: _result(
          fen: analyzerCpLossCandidatePlayedAfterFen,
          playerCp: 95,
        ),
        candidateAfter: _result(
          fen: analyzerCpLossCandidateCandidateAfterFen,
          playerCp: 80,
        ),
      );

      final result = await probe.run(
        const AnalyzerCpLossCandidateRequest.controlled(),
      );

      expect(result.cpLossCandidateComputed, isTrue);
      expect(result.moverPerspectiveCpLossCandidate, -15);
      expect(
        result.cpLossCandidateDirection,
        AnalyzerCpLossCandidateDirection.playedBetter,
      );
    });

    test('equal candidate computes zero loss candidate', () async {
      final probe = _probe(
        before: _result(fen: analyzerCpLossCandidateBeforeFen, playerCp: -39),
        playedAfter: _result(
          fen: analyzerCpLossCandidatePlayedAfterFen,
          playerCp: 95,
        ),
        candidateAfter: _result(
          fen: analyzerCpLossCandidateCandidateAfterFen,
          playerCp: 95,
        ),
      );

      final result = await probe.run(
        const AnalyzerCpLossCandidateRequest.controlled(),
      );

      expect(result.cpLossCandidateComputed, isTrue);
      expect(result.moverPerspectiveCpLossCandidate, 0);
      expect(
        result.cpLossCandidateDirection,
        AnalyzerCpLossCandidateDirection.equal,
      );
    });

    test('delta remains separate from loss candidate', () async {
      final probe = _probe(
        before: _result(fen: analyzerCpLossCandidateBeforeFen, playerCp: -39),
        playedAfter: _result(
          fen: analyzerCpLossCandidatePlayedAfterFen,
          playerCp: 95,
        ),
        candidateAfter: _result(
          fen: analyzerCpLossCandidateCandidateAfterFen,
          playerCp: 120,
        ),
      );

      final result = await probe.run(
        const AnalyzerCpLossCandidateRequest.controlled(),
      );

      expect(result.cpDeltaComputed, isTrue);
      expect(result.moverPerspectiveDeltaCp, 134);
      expect(result.moverPerspectiveCpLossCandidate, 25);
    });

    test('is unavailable when played CP is missing', () async {
      final probe = _probe(
        before: _result(fen: analyzerCpLossCandidateBeforeFen, playerCp: -39),
        playedAfter: _result(
          fen: analyzerCpLossCandidatePlayedAfterFen,
          playerCp: null,
          playerMate: 2,
        ),
        candidateAfter: _result(
          fen: analyzerCpLossCandidateCandidateAfterFen,
          playerCp: 120,
        ),
      );

      final result = await probe.run(
        const AnalyzerCpLossCandidateRequest.controlled(),
      );

      expect(result.cpLossCandidateComputed, isFalse);
      expect(result.moverPerspectiveCpLossCandidate, isNull);
      expect(
        result.cpLossCandidateDirection,
        AnalyzerCpLossCandidateDirection.unavailable,
      );
      expect(result.safeForPhase35K, isFalse);
      expect(result.failureMessage, contains('Played-after'));
    });

    test('is unavailable when candidate CP is missing', () async {
      final probe = _probe(
        before: _result(fen: analyzerCpLossCandidateBeforeFen, playerCp: -39),
        playedAfter: _result(
          fen: analyzerCpLossCandidatePlayedAfterFen,
          playerCp: 95,
        ),
        candidateAfter: _result(
          fen: analyzerCpLossCandidateCandidateAfterFen,
          playerCp: null,
          playerMate: 2,
        ),
      );

      final result = await probe.run(
        const AnalyzerCpLossCandidateRequest.controlled(),
      );

      expect(result.cpLossCandidateComputed, isFalse);
      expect(result.moverPerspectiveCpLossCandidate, isNull);
      expect(
        result.cpLossCandidateDirection,
        AnalyzerCpLossCandidateDirection.unavailable,
      );
      expect(result.safeForPhase35K, isFalse);
      expect(result.failureMessage, contains('Candidate-after'));
    });

    test('does not compute official product metrics or labels', () async {
      final probe = _probe(
        before: _result(fen: analyzerCpLossCandidateBeforeFen, playerCp: -39),
        playedAfter: _result(
          fen: analyzerCpLossCandidatePlayedAfterFen,
          playerCp: 95,
        ),
        candidateAfter: _result(
          fen: analyzerCpLossCandidateCandidateAfterFen,
          playerCp: 120,
        ),
      );

      final result = await probe.run(
        const AnalyzerCpLossCandidateRequest.controlled(),
      );
      final json = result.toJson();

      expect(result.officialCpLossComputed, isFalse);
      expect(result.winPercentComputed, isFalse);
      expect(result.classificationComputed, isFalse);
      expect(result.moveQualityComputed, isFalse);
      expect(result.accuracyComputed, isFalse);
      for (final forbiddenField in _forbiddenFields) {
        expect(json.containsKey(forbiddenField), isFalse);
      }
    });

    test('black mover uses supplied mover perspective fields', () async {
      final probe = _probe(
        before: _result(
          fen: analyzerCpLossCandidateBeforeFen,
          requestedPlayerColor: AnalyzerRequestedPlayerColor.black,
          whiteCp: -39,
          blackCp: 39,
          playerCp: 39,
        ),
        playedAfter: _result(
          fen: analyzerCpLossCandidatePlayedAfterFen,
          requestedPlayerColor: AnalyzerRequestedPlayerColor.black,
          whiteCp: 95,
          blackCp: -95,
          playerCp: -95,
        ),
        candidateAfter: _result(
          fen: analyzerCpLossCandidateCandidateAfterFen,
          requestedPlayerColor: AnalyzerRequestedPlayerColor.black,
          whiteCp: 120,
          blackCp: -120,
          playerCp: -120,
        ),
      );

      final result = await probe.run(
        const AnalyzerCpLossCandidateRequest.controlled(
          moverColor: AnalyzerMoverColor.black,
        ),
      );

      expect(result.moverColor, AnalyzerMoverColor.black);
      expect(result.beforeMoverPerspectiveCp, 39);
      expect(result.playedAfterMoverPerspectiveCp, -95);
      expect(result.candidateAfterMoverPerspectiveCp, -120);
      expect(result.moverPerspectiveDeltaCp, -134);
      expect(result.moverPerspectiveCpLossCandidate, -25);
      expect(
        result.cpLossCandidateDirection,
        AnalyzerCpLossCandidateDirection.playedBetter,
      );
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

LocalAnalyzerCpLossCandidateProbe _probe({
  required AnalyzerRawEvalResult before,
  required AnalyzerRawEvalResult playedAfter,
  required AnalyzerRawEvalResult candidateAfter,
}) {
  return LocalAnalyzerCpLossCandidateProbe(
    singleFenRunner: (request, {timeout = const Duration(seconds: 5)}) async {
      if (request.fen == analyzerCpLossCandidateBeforeFen) return before;
      if (request.fen == analyzerCpLossCandidatePlayedAfterFen) {
        return playedAfter;
      }
      if (request.fen == analyzerCpLossCandidateCandidateAfterFen) {
        return candidateAfter;
      }
      throw StateError('Unexpected FEN: ${request.fen}');
    },
  );
}

AnalyzerRawEvalResult _result({
  required String fen,
  required int? playerCp,
  int? playerMate,
  AnalyzerRequestedPlayerColor requestedPlayerColor =
      AnalyzerRequestedPlayerColor.white,
  int? whiteCp,
  int? blackCp,
}) {
  final effectiveWhiteCp =
      whiteCp ??
      switch (requestedPlayerColor) {
        AnalyzerRequestedPlayerColor.white => playerCp,
        AnalyzerRequestedPlayerColor.black =>
          playerCp == null ? null : -playerCp,
      };
  final effectiveBlackCp =
      blackCp ??
      switch (requestedPlayerColor) {
        AnalyzerRequestedPlayerColor.white =>
          effectiveWhiteCp == null ? null : -effectiveWhiteCp,
        AnalyzerRequestedPlayerColor.black => playerCp,
      };
  return AnalyzerRawEvalResult(
    fen: fen,
    requestedDepth: analyzerCpLossCandidateDepth,
    requestedPlayerColor: requestedPlayerColor,
    engineSource: 'fakeLocalStockfishUci',
    bridgeSource: 'fakeLocalSearchEvalProbe',
    rawScoreType: playerCp == null ? 'mate' : 'cp',
    rawScoreCp: playerCp,
    rawScoreMate: playerCp == null ? playerMate : null,
    rawScorePerspective: 'sideToMove',
    sideToMove: null,
    whitePerspectiveCp: effectiveWhiteCp,
    blackPerspectiveCp: effectiveBlackCp,
    whitePerspectiveMate:
        requestedPlayerColor == AnalyzerRequestedPlayerColor.white
        ? playerMate
        : null,
    blackPerspectiveMate:
        requestedPlayerColor == AnalyzerRequestedPlayerColor.black
        ? playerMate
        : null,
    playerPerspectiveCp: playerCp,
    playerPerspectiveMate: playerCp == null ? playerMate : null,
    bestMove: 'e2e3',
    bestMoveReceived: true,
    infoDepthSeen: analyzerCpLossCandidateDepth,
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
