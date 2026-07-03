import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_cp_loss_candidate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_expected_points_delta_probe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProvisionalExpectedPointsConverter', () {
    const converter = ProvisionalExpectedPointsConverter();

    test('cp 0 maps near 0.5', () {
      expect(converter.convertCp(0), closeTo(0.5, 0.000001));
    });

    test('positive cp maps higher than 0.5', () {
      expect(converter.convertCp(100), greaterThan(0.5));
    });

    test('negative cp maps lower than 0.5', () {
      expect(converter.convertCp(-100), lessThan(0.5));
    });

    test('larger cp maps higher than smaller cp', () {
      expect(converter.convertCp(300), greaterThan(converter.convertCp(100)!));
    });

    test('output clamps to 0..1', () {
      expect(converter.convertCp(100000), inInclusiveRange(0.0, 1.0));
      expect(converter.convertCp(-100000), inInclusiveRange(0.0, 1.0));
    });
  });

  group('LocalAnalyzerExpectedPointsDeltaProbe', () {
    test('computes expected-points values and deltas', () async {
      final probe = _probe(
        _cpLossCandidate(beforeCp: -39, playedCp: 95, candidateCp: 117),
      );

      final result = await probe.run(
        const AnalyzerExpectedPointsDeltaRequest.controlled(),
      );

      expect(result.cpLossCandidateProbeSucceeded, isTrue);
      expect(result.expectedPointsComputed, isTrue);
      expect(result.beforeExpectedPoints, isNotNull);
      expect(result.playedAfterExpectedPoints, isNotNull);
      expect(result.candidateAfterExpectedPoints, isNotNull);
      expect(
        result.playedExpectedPointsDelta,
        closeTo(
          result.playedAfterExpectedPoints! - result.beforeExpectedPoints!,
          0.000001,
        ),
      );
      expect(
        result.candidateVsPlayedExpectedPointsDelta,
        closeTo(
          result.candidateAfterExpectedPoints! -
              result.playedAfterExpectedPoints!,
          0.000001,
        ),
      );
      expect(result.safeForPhase35L, isTrue);
      expect(
        result.nextRecommendation,
        analyzerExpectedPointsNextRecommendation,
      );
    });

    test('expectedPointsComputed false if CP is missing', () async {
      final probe = _probe(
        _cpLossCandidate(beforeCp: null, playedCp: 95, candidateCp: 117),
      );

      final result = await probe.run(
        const AnalyzerExpectedPointsDeltaRequest.controlled(),
      );

      expect(result.expectedPointsComputed, isFalse);
      expect(result.beforeExpectedPoints, isNull);
      expect(result.playedExpectedPointsDelta, isNull);
      expect(result.candidateVsPlayedExpectedPointsDelta, isNull);
      expect(result.safeForPhase35L, isFalse);
      expect(result.failureMessage, contains('Before'));
    });

    test('model and official metric flags remain non-official', () async {
      final probe = _probe(
        _cpLossCandidate(beforeCp: -39, playedCp: 95, candidateCp: 117),
      );

      final result = await probe.run(
        const AnalyzerExpectedPointsDeltaRequest.controlled(),
      );

      expect(result.expectedPointsModelIsOfficial, isFalse);
      expect(result.officialWinPercentComputed, isFalse);
      expect(result.officialCpLossComputed, isFalse);
      expect(result.classificationComputed, isFalse);
      expect(result.moveQualityComputed, isFalse);
      expect(result.accuracyComputed, isFalse);
      expect(result.acplComputed, isFalse);
    });
  });
}

LocalAnalyzerExpectedPointsDeltaProbe _probe(
  AnalyzerCpLossCandidateResult result,
) {
  return LocalAnalyzerExpectedPointsDeltaProbe(
    cpLossCandidateRunner:
        (
          AnalyzerCpLossCandidateRequest request, {
          Duration timeout = const Duration(seconds: 5),
        }) async => result,
  );
}

AnalyzerCpLossCandidateResult _cpLossCandidate({
  required int? beforeCp,
  required int? playedCp,
  required int? candidateCp,
}) {
  final success = beforeCp != null && playedCp != null && candidateCp != null;
  return AnalyzerCpLossCandidateResult(
    beforeFen: analyzerExpectedPointsBeforeFen,
    playedAfterFen: analyzerExpectedPointsPlayedAfterFen,
    candidateAfterFen: analyzerExpectedPointsCandidateAfterFen,
    playedMoveUci: analyzerExpectedPointsPlayedMoveUci,
    candidateMoveUci: analyzerExpectedPointsCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerExpectedPointsDepth,
    beforeEvalSucceeded: true,
    beforeMoverPerspectiveCp: beforeCp,
    beforeMoverPerspectiveMate: beforeCp == null ? 2 : null,
    beforeBestMove: 'e2e3',
    beforeBestMoveReceived: true,
    playedAfterEvalSucceeded: true,
    playedAfterMoverPerspectiveCp: playedCp,
    playedAfterMoverPerspectiveMate: playedCp == null ? 2 : null,
    playedAfterBestMove: 'e7e6',
    playedAfterBestMoveReceived: true,
    candidateAfterEvalSucceeded: true,
    candidateAfterMoverPerspectiveCp: candidateCp,
    candidateAfterMoverPerspectiveMate: candidateCp == null ? 2 : null,
    candidateAfterBestMove: 'e7e6',
    candidateAfterBestMoveReceived: true,
    cpDeltaComputed: beforeCp != null && playedCp != null,
    moverPerspectiveDeltaCp: beforeCp != null && playedCp != null
        ? playedCp - beforeCp
        : null,
    cpLossCandidateComputed: playedCp != null && candidateCp != null,
    moverPerspectiveCpLossCandidate: playedCp != null && candidateCp != null
        ? candidateCp - playedCp
        : null,
    cpLossCandidateDirection: success
        ? AnalyzerCpLossCandidateDirection.candidateBetter
        : AnalyzerCpLossCandidateDirection.unavailable,
    officialCpLossComputed: false,
    winPercentComputed: false,
    classificationComputed: false,
    moveQualityComputed: false,
    accuracyComputed: false,
    cpLossCandidateProbeSucceeded: success,
    failureMessage: success ? null : 'CP evidence unavailable.',
    safeForPhase35K: success,
    nextRecommendation: success
        ? analyzerCpLossCandidateNextRecommendation
        : analyzerCpLossCandidateFailureRecommendation,
    blockers: success ? const [] : const ['CP evidence unavailable.'],
    warnings: const [],
  );
}
