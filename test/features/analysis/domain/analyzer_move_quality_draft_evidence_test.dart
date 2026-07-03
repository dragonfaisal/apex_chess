import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_move_quality_draft_evidence.dart';
import 'package:apex_chess/infrastructure/engine/local_analyzer_move_quality_draft_evidence_probe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalAnalyzerMoveQualityDraftEvidenceProbe', () {
    test('computes draft evidence when source evidence exists', () async {
      final probe = _probe(_expectedPoints());

      final result = await probe.run(
        const AnalyzerMoveQualityDraftEvidenceRequest.controlled(),
      );

      expect(result.moveQualityDraftEvidenceProbeSucceeded, isTrue);
      expect(result.draftEvidenceComputed, isTrue);
      expect(result.beforeMoverPerspectiveCp, -39);
      expect(result.playedAfterMoverPerspectiveCp, 95);
      expect(result.candidateAfterMoverPerspectiveCp, 117);
      expect(result.expectedPointsComputed, isTrue);
      expect(result.safeForPhase35M, isTrue);
      expect(
        result.nextRecommendation,
        analyzerMoveQualityDraftEvidenceNextRecommendation,
      );
    });

    test('draft evidence remains internal and non-official', () async {
      final probe = _probe(_expectedPoints());

      final result = await probe.run(
        const AnalyzerMoveQualityDraftEvidenceRequest.controlled(),
      );

      expect(result.draftEvidenceIsPublic, isFalse);
      expect(result.draftEvidenceIsOfficialMoveQuality, isFalse);
      expect(result.draftEvidenceIsClassifierOutput, isFalse);
      expect(result.publicLabelComputed, isFalse);
      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialCpLossComputed, isFalse);
      expect(result.officialWinPercentComputed, isFalse);
      expect(result.accuracyComputed, isFalse);
      expect(result.acplComputed, isFalse);
      expect(result.classificationComputed, isFalse);
    });

    test('fails closed when expected-points evidence is missing', () async {
      final probe = _probe(
        _expectedPoints(
          expectedPointsComputed: false,
          beforeExpectedPoints: null,
          sourceSucceeded: false,
        ),
      );

      final result = await probe.run(
        const AnalyzerMoveQualityDraftEvidenceRequest.controlled(),
      );

      expect(result.moveQualityDraftEvidenceProbeSucceeded, isFalse);
      expect(result.draftEvidenceComputed, isFalse);
      expect(result.safeForPhase35M, isFalse);
      expect(result.failureMessage, isNotNull);
      expect(
        result.nextRecommendation,
        analyzerMoveQualityDraftEvidenceFailureRecommendation,
      );
    });

    test('result does not expose public label fields', () async {
      final probe = _probe(_expectedPoints());

      final result = await probe.run(
        const AnalyzerMoveQualityDraftEvidenceRequest.controlled(),
      );
      final json = result.toJson();

      for (final forbiddenField in _forbiddenFields) {
        expect(json.containsKey(forbiddenField), isFalse);
      }
    });
  });
}

const _forbiddenFields = <String>[
  'label',
  'publicLabel',
  'moveLabel',
  'classificationLabel',
  'badge',
  'icon',
  'brilliant',
  'great',
  'best',
  'mistake',
  'blunder',
  'explanation',
  'savedAnalysis',
];

LocalAnalyzerMoveQualityDraftEvidenceProbe _probe(
  AnalyzerExpectedPointsDeltaResult result,
) {
  return LocalAnalyzerMoveQualityDraftEvidenceProbe(
    expectedPointsRunner:
        (
          AnalyzerExpectedPointsDeltaRequest request, {
          Duration timeout = const Duration(seconds: 5),
        }) async => result,
  );
}

AnalyzerExpectedPointsDeltaResult _expectedPoints({
  bool sourceSucceeded = true,
  bool expectedPointsComputed = true,
  double? beforeExpectedPoints = 0.47564429123179275,
}) {
  return AnalyzerExpectedPointsDeltaResult(
    beforeFen: analyzerExpectedPointsBeforeFen,
    playedAfterFen: analyzerExpectedPointsPlayedAfterFen,
    candidateAfterFen: analyzerExpectedPointsCandidateAfterFen,
    playedMoveUci: analyzerExpectedPointsPlayedMoveUci,
    candidateMoveUci: analyzerExpectedPointsCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerExpectedPointsDepth,
    cpLossCandidateProbeSucceeded: sourceSucceeded,
    beforeMoverPerspectiveCp: -39,
    playedAfterMoverPerspectiveCp: 95,
    candidateAfterMoverPerspectiveCp: 117,
    moverPerspectiveDeltaCp: 134,
    moverPerspectiveCpLossCandidate: 22,
    beforeExpectedPoints: beforeExpectedPoints,
    playedAfterExpectedPoints: expectedPointsComputed
        ? 0.559097471902393
        : null,
    candidateAfterExpectedPoints: expectedPointsComputed
        ? 0.5726080638632601
        : null,
    playedExpectedPointsDelta: expectedPointsComputed
        ? 0.08345318067060026
        : null,
    candidateVsPlayedExpectedPointsDelta: expectedPointsComputed
        ? 0.013510591960867124
        : null,
    expectedPointsComputed: expectedPointsComputed,
    expectedPointsModelName: analyzerExpectedPointsModelName,
    expectedPointsModelVersion: analyzerExpectedPointsModelVersion,
    expectedPointsModelIsOfficial: analyzerExpectedPointsModelIsOfficial,
    officialWinPercentComputed: false,
    officialCpLossComputed: false,
    classificationComputed: false,
    moveQualityComputed: false,
    accuracyComputed: false,
    acplComputed: false,
    expectedPointsDeltaProbeSucceeded: sourceSucceeded,
    failureMessage: sourceSucceeded ? null : 'expected-points failed',
    safeForPhase35L: sourceSucceeded,
    nextRecommendation: sourceSucceeded
        ? analyzerExpectedPointsNextRecommendation
        : analyzerExpectedPointsFailureRecommendation,
    blockers: sourceSucceeded ? const [] : const ['expected-points failed'],
    warnings: const [],
  );
}
