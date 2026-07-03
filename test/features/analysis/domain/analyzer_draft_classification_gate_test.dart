import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_move_quality_draft_evidence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluateAnalyzerDraftClassificationGate', () {
    test('is eligible when draft evidence exists and flags are internal', () {
      final result = _evaluate(_draftEvidence());

      expect(result.draftClassificationGateComputed, isTrue);
      expect(
        result.evidenceStructurallyEligibleForFutureClassification,
        isTrue,
      );
      expect(result.evidenceHasBeforeAfterCp, isTrue);
      expect(result.evidenceHasCandidateComparison, isTrue);
      expect(result.evidenceHasExpectedPoints, isTrue);
      expect(result.evidenceIsDeveloperOnly, isTrue);
      expect(
        result.gateRecommendation,
        AnalyzerDraftClassificationGateRecommendation
            .eligibleForFutureDraftClassifier,
      );
      expect(result.safeForPhase35N, isTrue);
      expect(
        result.nextRecommendation,
        analyzerDraftClassificationGateNextRecommendation,
      );
    });

    test('is not eligible when CP delta is missing', () {
      final result = _evaluate(
        _draftEvidence(cpDeltaComputed: false, moverPerspectiveDeltaCp: null),
      );

      expect(result.evidenceHasBeforeAfterCp, isFalse);
      expect(
        result.gateRecommendation,
        AnalyzerDraftClassificationGateRecommendation
            .notEligibleMissingEvidence,
      );
      expect(result.safeForPhase35N, isFalse);
    });

    test('is not eligible when CP loss candidate is missing', () {
      final result = _evaluate(
        _draftEvidence(
          cpLossCandidateComputed: false,
          moverPerspectiveCpLossCandidate: null,
          cpLossCandidateDirection: null,
        ),
      );

      expect(result.evidenceHasCandidateComparison, isFalse);
      expect(
        result.gateRecommendation,
        AnalyzerDraftClassificationGateRecommendation
            .notEligibleMissingEvidence,
      );
      expect(result.safeForPhase35N, isFalse);
    });

    test('is not eligible when expected points are missing', () {
      final result = _evaluate(
        _draftEvidence(
          expectedPointsComputed: false,
          playedExpectedPointsDelta: null,
          candidateVsPlayedExpectedPointsDelta: null,
        ),
      );

      expect(result.evidenceHasExpectedPoints, isFalse);
      expect(
        result.gateRecommendation,
        AnalyzerDraftClassificationGateRecommendation
            .notEligibleMissingEvidence,
      );
      expect(result.safeForPhase35N, isFalse);
    });

    test('blocks public draft evidence', () {
      final result = _evaluate(_draftEvidence(draftEvidenceIsPublic: true));

      expect(result.evidenceIsDeveloperOnly, isFalse);
      expect(
        result.gateRecommendation,
        AnalyzerDraftClassificationGateRecommendation
            .blockedBecauseEvidenceIsPublic,
      );
      expect(result.safeForPhase35N, isFalse);
    });

    test('blocks official move quality evidence', () {
      final result = _evaluate(
        _draftEvidence(draftEvidenceIsOfficialMoveQuality: true),
      );

      expect(result.evidenceIsDeveloperOnly, isFalse);
      expect(
        result.gateRecommendation,
        AnalyzerDraftClassificationGateRecommendation
            .blockedBecauseEvidenceIsOfficialMoveQuality,
      );
      expect(result.safeForPhase35N, isFalse);
    });

    test('blocks draft evidence that is already classifier output', () {
      final result = _evaluate(
        _draftEvidence(draftEvidenceIsClassifierOutput: true),
      );

      expect(result.evidenceIsDeveloperOnly, isFalse);
      expect(
        result.gateRecommendation,
        AnalyzerDraftClassificationGateRecommendation
            .blockedBecauseEvidenceIsClassifierOutput,
      );
      expect(result.classifierOutputComputed, isFalse);
      expect(result.safeForPhase35N, isFalse);
    });

    test('blocks if publicLabelComputed is true', () {
      final result = _evaluate(_draftEvidence(publicLabelComputed: true));

      expect(
        result.gateRecommendation,
        AnalyzerDraftClassificationGateRecommendation
            .blockedBecauseEvidenceIsPublic,
      );
      expect(result.publicLabelComputed, isTrue);
      expect(result.publicLabel, isNull);
      expect(result.safeForPhase35N, isFalse);
    });

    test('blocks if official metrics are already computed', () {
      final result = _evaluate(_draftEvidence(officialCpLossComputed: true));

      expect(
        result.gateRecommendation,
        AnalyzerDraftClassificationGateRecommendation
            .blockedBecauseOfficialMetricsAlreadyComputed,
      );
      expect(result.officialCpLossComputed, isTrue);
      expect(result.safeForPhase35N, isFalse);
    });

    test('keeps public and official move-quality values null', () {
      final result = _evaluate(_draftEvidence());

      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
    });

    test('keeps classification and classifier output uncomputed', () {
      final result = _evaluate(_draftEvidence());

      expect(result.classificationComputed, isFalse);
      expect(result.classifierOutputComputed, isFalse);
      expect(result.draftClassificationGateProbeSucceeded, isTrue);
    });
  });
}

AnalyzerDraftClassificationGateResult _evaluate(
  AnalyzerMoveQualityDraftEvidenceResult draftEvidence,
) {
  return evaluateAnalyzerDraftClassificationGate(
    request: const AnalyzerDraftClassificationGateRequest.controlled(),
    draftEvidence: draftEvidence,
  );
}

AnalyzerMoveQualityDraftEvidenceResult _draftEvidence({
  bool moveQualityDraftEvidenceProbeSucceeded = true,
  bool draftEvidenceComputed = true,
  bool cpDeltaComputed = true,
  bool cpLossCandidateComputed = true,
  bool expectedPointsComputed = true,
  bool expectedPointsModelIsOfficial = false,
  bool draftEvidenceIsPublic = false,
  bool draftEvidenceIsOfficialMoveQuality = false,
  bool draftEvidenceIsClassifierOutput = false,
  bool publicLabelComputed = false,
  bool officialMoveQualityComputed = false,
  bool officialCpLossComputed = false,
  bool officialWinPercentComputed = false,
  bool accuracyComputed = false,
  bool acplComputed = false,
  bool classificationComputed = false,
  int? moverPerspectiveDeltaCp = 134,
  int? moverPerspectiveCpLossCandidate = 22,
  String? cpLossCandidateDirection = 'candidateBetter',
  double? playedExpectedPointsDelta = 0.08345318067060026,
  double? candidateVsPlayedExpectedPointsDelta = 0.013510591960867124,
}) {
  return AnalyzerMoveQualityDraftEvidenceResult(
    playedMoveUci: analyzerMoveQualityDraftEvidencePlayedMoveUci,
    candidateMoveUci: analyzerMoveQualityDraftEvidenceCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerMoveQualityDraftEvidenceDepth,
    evidenceSource: analyzerMoveQualityDraftEvidenceSource,
    evidenceModelName: analyzerMoveQualityDraftEvidenceModelName,
    evidenceModelVersion: analyzerMoveQualityDraftEvidenceModelVersion,
    beforeMoverPerspectiveCp: -39,
    playedAfterMoverPerspectiveCp: 95,
    candidateAfterMoverPerspectiveCp: 117,
    moverPerspectiveDeltaCp: moverPerspectiveDeltaCp,
    moverPerspectiveCpLossCandidate: moverPerspectiveCpLossCandidate,
    cpDeltaComputed: cpDeltaComputed,
    cpLossCandidateComputed: cpLossCandidateComputed,
    cpLossCandidateDirection: cpLossCandidateDirection,
    expectedPointsModelName: analyzerExpectedPointsModelName,
    expectedPointsModelVersion: analyzerExpectedPointsModelVersion,
    expectedPointsModelIsOfficial: expectedPointsModelIsOfficial,
    beforeExpectedPoints: 0.47564429123179275,
    playedAfterExpectedPoints: 0.559097471902393,
    candidateAfterExpectedPoints: 0.5726080638632601,
    playedExpectedPointsDelta: playedExpectedPointsDelta,
    candidateVsPlayedExpectedPointsDelta: candidateVsPlayedExpectedPointsDelta,
    expectedPointsComputed: expectedPointsComputed,
    draftEvidenceComputed: draftEvidenceComputed,
    draftEvidenceIsPublic: draftEvidenceIsPublic,
    draftEvidenceIsOfficialMoveQuality: draftEvidenceIsOfficialMoveQuality,
    draftEvidenceIsClassifierOutput: draftEvidenceIsClassifierOutput,
    publicLabelComputed: publicLabelComputed,
    officialMoveQualityComputed: officialMoveQualityComputed,
    officialCpLossComputed: officialCpLossComputed,
    officialWinPercentComputed: officialWinPercentComputed,
    accuracyComputed: accuracyComputed,
    acplComputed: acplComputed,
    classificationComputed: classificationComputed,
    moveQualityDraftEvidenceProbeSucceeded:
        moveQualityDraftEvidenceProbeSucceeded,
    failureMessage: null,
    safeForPhase35M: moveQualityDraftEvidenceProbeSucceeded,
    nextRecommendation: moveQualityDraftEvidenceProbeSucceeded
        ? analyzerMoveQualityDraftEvidenceNextRecommendation
        : analyzerMoveQualityDraftEvidenceFailureRecommendation,
    blockers: const [],
    warnings: const [],
  );
}
