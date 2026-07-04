import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluateAnalyzerPrivateDraftClassifier', () {
    test('returns positiveCandidate for improved delta and small gap', () {
      final result = _evaluate(
        _gate(
          moverPerspectiveDeltaCp: 134,
          moverPerspectiveCpLossCandidate: 22,
        ),
      );

      expect(result.privateDraftClassifierComputed, isTrue);
      expect(
        result.privateDraftBucket,
        AnalyzerPrivateDraftBucket.positiveCandidate,
      );
      expect(
        result.privateDraftReasonCode,
        AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
      );
      expect(
        result.privateDraftConfidenceTier,
        AnalyzerPrivateDraftConfidenceTier.low,
      );
      expect(result.safeForPhase35O, isTrue);
      expect(
        result.nextRecommendation,
        analyzerPrivateDraftClassifierNextRecommendation,
      );
    });

    test('returns neutralCandidate for tiny delta and small gap', () {
      final result = _evaluate(
        _gate(moverPerspectiveDeltaCp: 0, moverPerspectiveCpLossCandidate: 30),
      );

      expect(
        result.privateDraftBucket,
        AnalyzerPrivateDraftBucket.neutralCandidate,
      );
      expect(
        result.privateDraftReasonCode,
        AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
      );
      expect(
        result.privateDraftConfidenceTier,
        AnalyzerPrivateDraftConfidenceTier.low,
      );
    });

    test('returns negativeCandidate for worsened delta', () {
      final result = _evaluate(
        _gate(moverPerspectiveDeltaCp: -1, moverPerspectiveCpLossCandidate: 20),
      );

      expect(
        result.privateDraftBucket,
        AnalyzerPrivateDraftBucket.negativeCandidate,
      );
      expect(
        result.privateDraftReasonCode,
        AnalyzerPrivateDraftReasonCode.worsenedAgainstCandidate,
      );
    });

    test('returns negativeCandidate for large candidate gap', () {
      final result = _evaluate(
        _gate(
          moverPerspectiveDeltaCp: 50,
          moverPerspectiveCpLossCandidate: 121,
        ),
      );

      expect(
        result.privateDraftBucket,
        AnalyzerPrivateDraftBucket.negativeCandidate,
      );
      expect(
        result.privateDraftReasonCode,
        AnalyzerPrivateDraftReasonCode.worsenedAgainstCandidate,
      );
    });

    test('returns unavailable when gate is blocked', () {
      final result = _evaluate(
        _gate(
          draftClassificationGateProbeSucceeded: false,
          evidenceStructurallyEligibleForFutureClassification: false,
          gateRecommendation: AnalyzerDraftClassificationGateRecommendation
              .notEligibleMissingEvidence,
          failureMessage: 'gate blocked',
        ),
      );

      expect(result.privateDraftClassifierComputed, isFalse);
      expect(result.privateDraftBucket, AnalyzerPrivateDraftBucket.unavailable);
      expect(
        result.privateDraftReasonCode,
        AnalyzerPrivateDraftReasonCode.gateBlocked,
      );
      expect(
        result.privateDraftConfidenceTier,
        AnalyzerPrivateDraftConfidenceTier.unavailable,
      );
      expect(result.safeForPhase35O, isFalse);
    });

    test('returns unavailable when evidence is missing', () {
      final result = _evaluate(_gate(moverPerspectiveDeltaCp: null));

      expect(result.privateDraftClassifierComputed, isFalse);
      expect(result.privateDraftBucket, AnalyzerPrivateDraftBucket.unavailable);
      expect(
        result.privateDraftReasonCode,
        AnalyzerPrivateDraftReasonCode.missingEvidence,
      );
      expect(result.safeForPhase35O, isFalse);
    });

    test('private classifier is not public', () {
      final result = _evaluate(_gate());

      expect(result.privateDraftClassifierIsPublic, isFalse);
      expect(result.publicClassifierOutputComputed, isFalse);
    });

    test('private classifier is not official move quality', () {
      final result = _evaluate(_gate());

      expect(result.privateDraftClassifierIsOfficialMoveQuality, isFalse);
      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
    });

    test('private classifier is not a public label', () {
      final result = _evaluate(_gate());

      expect(result.privateDraftClassifierIsPublicLabel, isFalse);
      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('official metrics remain uncomputed', () {
      final result = _evaluate(_gate());

      expect(result.officialCpLossComputed, isFalse);
      expect(result.officialWinPercentComputed, isFalse);
      expect(result.accuracyComputed, isFalse);
      expect(result.acplComputed, isFalse);
      expect(result.classificationComputed, isFalse);
    });

    test('private bucket values stay limited to private vocabulary', () {
      final values = AnalyzerPrivateDraftBucket.values
          .map((bucket) => bucket.wire)
          .toSet();

      expect(values, {
        'positiveCandidate',
        'neutralCandidate',
        'negativeCandidate',
        'unavailable',
      });
      for (final value in values) {
        expect(value.contains('Label'), isFalse);
        expect(value.contains('Quality'), isFalse);
        expect(value.contains('official'), isFalse);
      }
    });
  });
}

AnalyzerPrivateDraftClassifierResult _evaluate(
  AnalyzerDraftClassificationGateResult gate,
) {
  return evaluateAnalyzerPrivateDraftClassifier(
    request: const AnalyzerPrivateDraftClassifierRequest.controlled(),
    gate: gate,
  );
}

AnalyzerDraftClassificationGateResult _gate({
  bool draftClassificationGateComputed = true,
  bool evidenceStructurallyEligibleForFutureClassification = true,
  bool evidenceIsDeveloperOnly = true,
  AnalyzerDraftClassificationGateRecommendation gateRecommendation =
      AnalyzerDraftClassificationGateRecommendation
          .eligibleForFutureDraftClassifier,
  bool draftClassificationGateProbeSucceeded = true,
  int? moverPerspectiveDeltaCp = 134,
  int? moverPerspectiveCpLossCandidate = 22,
  String? cpLossCandidateDirection = 'candidateBetter',
  double? playedExpectedPointsDelta = 0.08345318067060026,
  double? candidateVsPlayedExpectedPointsDelta = 0.013510591960867124,
  String? failureMessage,
}) {
  return AnalyzerDraftClassificationGateResult(
    playedMoveUci: analyzerDraftClassificationGatePlayedMoveUci,
    candidateMoveUci: analyzerDraftClassificationGateCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerDraftClassificationGateDepth,
    gateSource: analyzerDraftClassificationGateSource,
    gateModelName: analyzerDraftClassificationGateModelName,
    gateModelVersion: analyzerDraftClassificationGateModelVersion,
    draftEvidenceComputed: true,
    cpDeltaComputed: moverPerspectiveDeltaCp != null,
    cpLossCandidateComputed: moverPerspectiveCpLossCandidate != null,
    expectedPointsComputed: candidateVsPlayedExpectedPointsDelta != null,
    expectedPointsModelIsOfficial: false,
    draftEvidenceIsPublic: false,
    draftEvidenceIsOfficialMoveQuality: false,
    draftEvidenceIsClassifierOutput: false,
    moverPerspectiveDeltaCp: moverPerspectiveDeltaCp,
    moverPerspectiveCpLossCandidate: moverPerspectiveCpLossCandidate,
    cpLossCandidateDirection: cpLossCandidateDirection,
    playedExpectedPointsDelta: playedExpectedPointsDelta,
    candidateVsPlayedExpectedPointsDelta: candidateVsPlayedExpectedPointsDelta,
    draftClassificationGateComputed: draftClassificationGateComputed,
    evidenceStructurallyEligibleForFutureClassification:
        evidenceStructurallyEligibleForFutureClassification,
    evidenceHasBeforeAfterCp: moverPerspectiveDeltaCp != null,
    evidenceHasCandidateComparison: moverPerspectiveCpLossCandidate != null,
    evidenceHasExpectedPoints: candidateVsPlayedExpectedPointsDelta != null,
    evidenceIsDeveloperOnly: evidenceIsDeveloperOnly,
    gateRecommendation: gateRecommendation,
    publicLabelComputed: false,
    publicLabel: null,
    officialMoveQualityComputed: false,
    officialMoveQuality: null,
    officialCpLossComputed: false,
    officialWinPercentComputed: false,
    accuracyComputed: false,
    acplComputed: false,
    classificationComputed: false,
    classifierOutputComputed: false,
    draftClassificationGateProbeSucceeded:
        draftClassificationGateProbeSucceeded,
    failureMessage: failureMessage,
    safeForPhase35N: draftClassificationGateProbeSucceeded,
    nextRecommendation: draftClassificationGateProbeSucceeded
        ? analyzerDraftClassificationGateNextRecommendation
        : analyzerDraftClassificationGateFailureRecommendation,
    blockers: draftClassificationGateProbeSucceeded
        ? const []
        : const ['gate blocked'],
    warnings: const [],
  );
}
