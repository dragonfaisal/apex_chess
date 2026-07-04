import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('private draft classifier golden cases', () {
    test('positive improved candidate slightly better', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 134,
        moverPerspectiveCpLossCandidate: 22,
        candidateVsPlayedExpectedPointsDelta: 0.0135,
      );

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
      expect(result.privateDraftClassifierComputed, isTrue);
      expect(result.safeForPhase35O, isTrue);
      _expectNoPublicOutputs(result);
    });

    test('positive improved candidate similar', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 80,
        moverPerspectiveCpLossCandidate: 0,
        candidateVsPlayedExpectedPointsDelta: 0,
      );

      expect(
        result.privateDraftBucket,
        AnalyzerPrivateDraftBucket.positiveCandidate,
      );
      expect(
        result.privateDraftReasonCode,
        AnalyzerPrivateDraftReasonCode.improvedAndCandidateSimilar,
      );
      expect(
        result.privateDraftConfidenceTier,
        AnalyzerPrivateDraftConfidenceTier.low,
      );
      expect(result.privateDraftClassifierComputed, isTrue);
      expect(result.safeForPhase35O, isTrue);
      _expectNoPublicOutputs(result);
    });

    test('neutral tiny delta', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 10,
        moverPerspectiveCpLossCandidate: 60,
        candidateVsPlayedExpectedPointsDelta: 0.02,
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
      expect(result.privateDraftClassifierComputed, isTrue);
      expect(result.safeForPhase35O, isTrue);
      _expectNoPublicOutputs(result);
    });

    test('negative worsened', () {
      final result = _classify(
        moverPerspectiveDeltaCp: -25,
        moverPerspectiveCpLossCandidate: 30,
        candidateVsPlayedExpectedPointsDelta: 0.03,
      );

      expect(
        result.privateDraftBucket,
        AnalyzerPrivateDraftBucket.negativeCandidate,
      );
      expect(
        result.privateDraftReasonCode,
        AnalyzerPrivateDraftReasonCode.worsenedAgainstCandidate,
      );
      expect(
        result.privateDraftConfidenceTier,
        AnalyzerPrivateDraftConfidenceTier.low,
      );
      expect(result.privateDraftClassifierComputed, isTrue);
      expect(result.safeForPhase35O, isTrue);
      _expectNoPublicOutputs(result);
    });

    test('negative large candidate advantage', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 30,
        moverPerspectiveCpLossCandidate: 121,
        candidateVsPlayedExpectedPointsDelta: 0.18,
      );

      expect(
        result.privateDraftBucket,
        AnalyzerPrivateDraftBucket.negativeCandidate,
      );
      expect(
        result.privateDraftReasonCode,
        AnalyzerPrivateDraftReasonCode.worsenedAgainstCandidate,
      );
      expect(
        result.privateDraftConfidenceTier,
        AnalyzerPrivateDraftConfidenceTier.low,
      );
      expect(result.privateDraftClassifierComputed, isTrue);
      expect(result.safeForPhase35O, isTrue);
      _expectNoPublicOutputs(result);
    });

    test('unavailable gate blocked', () {
      final result = _classify(
        gateSucceeded: false,
        structurallyEligible: false,
        gateRecommendation: AnalyzerDraftClassificationGateRecommendation
            .notEligibleMissingEvidence,
        failureMessage: 'gate blocked',
      );

      expect(result.privateDraftBucket, AnalyzerPrivateDraftBucket.unavailable);
      expect(
        result.privateDraftReasonCode,
        AnalyzerPrivateDraftReasonCode.gateBlocked,
      );
      expect(
        result.privateDraftConfidenceTier,
        AnalyzerPrivateDraftConfidenceTier.unavailable,
      );
      expect(result.privateDraftClassifierComputed, isFalse);
      expect(result.safeForPhase35O, isFalse);
      _expectNoPublicOutputs(result);
    });

    test('unavailable missing evidence', () {
      final result = _classify(
        moverPerspectiveDeltaCp: null,
        moverPerspectiveCpLossCandidate: 22,
        candidateVsPlayedExpectedPointsDelta: 0.0135,
      );

      expect(result.privateDraftBucket, AnalyzerPrivateDraftBucket.unavailable);
      expect(
        result.privateDraftReasonCode,
        AnalyzerPrivateDraftReasonCode.missingEvidence,
      );
      expect(
        result.privateDraftConfidenceTier,
        AnalyzerPrivateDraftConfidenceTier.unavailable,
      );
      expect(result.privateDraftClassifierComputed, isFalse);
      expect(result.safeForPhase35O, isFalse);
      _expectNoPublicOutputs(result);
    });

    test('public label string guard', () {
      final privateBucketValues = AnalyzerPrivateDraftBucket.values
          .map((bucket) => bucket.wire)
          .toSet();

      expect(privateBucketValues, {
        'positiveCandidate',
        'neutralCandidate',
        'negativeCandidate',
        'unavailable',
      });
      expect(privateBucketValues.intersection(_publicLabelStrings), isEmpty);
    });
  });
}

const _publicLabelStrings = <String>{
  'Brilliant',
  'Great',
  'Best',
  'Excellent',
  'Good',
  'Book',
  'Inaccuracy',
  'Mistake',
  'Miss',
  'Blunder',
  'Checkmate',
};

AnalyzerPrivateDraftClassifierResult _classify({
  bool gateSucceeded = true,
  bool structurallyEligible = true,
  AnalyzerDraftClassificationGateRecommendation gateRecommendation =
      AnalyzerDraftClassificationGateRecommendation
          .eligibleForFutureDraftClassifier,
  int? moverPerspectiveDeltaCp = 134,
  int? moverPerspectiveCpLossCandidate = 22,
  double? candidateVsPlayedExpectedPointsDelta = 0.013510591960867124,
  String? failureMessage,
}) {
  return evaluateAnalyzerPrivateDraftClassifier(
    request: const AnalyzerPrivateDraftClassifierRequest.controlled(),
    gate: _gate(
      gateSucceeded: gateSucceeded,
      structurallyEligible: structurallyEligible,
      gateRecommendation: gateRecommendation,
      moverPerspectiveDeltaCp: moverPerspectiveDeltaCp,
      moverPerspectiveCpLossCandidate: moverPerspectiveCpLossCandidate,
      candidateVsPlayedExpectedPointsDelta:
          candidateVsPlayedExpectedPointsDelta,
      failureMessage: failureMessage,
    ),
  );
}

AnalyzerDraftClassificationGateResult _gate({
  required bool gateSucceeded,
  required bool structurallyEligible,
  required AnalyzerDraftClassificationGateRecommendation gateRecommendation,
  required int? moverPerspectiveDeltaCp,
  required int? moverPerspectiveCpLossCandidate,
  required double? candidateVsPlayedExpectedPointsDelta,
  required String? failureMessage,
}) {
  final evidencePresent =
      moverPerspectiveDeltaCp != null &&
      moverPerspectiveCpLossCandidate != null &&
      candidateVsPlayedExpectedPointsDelta != null;

  return AnalyzerDraftClassificationGateResult(
    playedMoveUci: analyzerDraftClassificationGatePlayedMoveUci,
    candidateMoveUci: analyzerDraftClassificationGateCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerDraftClassificationGateDepth,
    gateSource: analyzerDraftClassificationGateSource,
    gateModelName: analyzerDraftClassificationGateModelName,
    gateModelVersion: analyzerDraftClassificationGateModelVersion,
    draftEvidenceComputed: evidencePresent,
    cpDeltaComputed: moverPerspectiveDeltaCp != null,
    cpLossCandidateComputed: moverPerspectiveCpLossCandidate != null,
    expectedPointsComputed: candidateVsPlayedExpectedPointsDelta != null,
    expectedPointsModelIsOfficial: false,
    draftEvidenceIsPublic: false,
    draftEvidenceIsOfficialMoveQuality: false,
    draftEvidenceIsClassifierOutput: false,
    moverPerspectiveDeltaCp: moverPerspectiveDeltaCp,
    moverPerspectiveCpLossCandidate: moverPerspectiveCpLossCandidate,
    cpLossCandidateDirection: _direction(moverPerspectiveCpLossCandidate),
    playedExpectedPointsDelta: 0.08,
    candidateVsPlayedExpectedPointsDelta: candidateVsPlayedExpectedPointsDelta,
    draftClassificationGateComputed: gateSucceeded,
    evidenceStructurallyEligibleForFutureClassification: structurallyEligible,
    evidenceHasBeforeAfterCp: moverPerspectiveDeltaCp != null,
    evidenceHasCandidateComparison: moverPerspectiveCpLossCandidate != null,
    evidenceHasExpectedPoints: candidateVsPlayedExpectedPointsDelta != null,
    evidenceIsDeveloperOnly: true,
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
    draftClassificationGateProbeSucceeded: gateSucceeded,
    failureMessage: failureMessage,
    safeForPhase35N: gateSucceeded && structurallyEligible && evidencePresent,
    nextRecommendation: gateSucceeded
        ? analyzerDraftClassificationGateNextRecommendation
        : analyzerDraftClassificationGateFailureRecommendation,
    blockers: gateSucceeded ? const [] : const ['gate blocked'],
    warnings: const [],
  );
}

String? _direction(int? value) {
  if (value == null) return null;
  if (value > 0) return 'candidateBetter';
  if (value < 0) return 'playedBetter';
  return 'equal';
}

void _expectNoPublicOutputs(AnalyzerPrivateDraftClassifierResult result) {
  expect(result.privateDraftClassifierIsPublic, isFalse);
  expect(result.privateDraftClassifierIsOfficialMoveQuality, isFalse);
  expect(result.privateDraftClassifierIsPublicLabel, isFalse);
  expect(result.publicLabelComputed, isFalse);
  expect(result.publicLabel, isNull);
  expect(result.officialMoveQualityComputed, isFalse);
  expect(result.officialMoveQuality, isNull);
  expect(result.officialCpLossComputed, isFalse);
  expect(result.officialWinPercentComputed, isFalse);
  expect(result.accuracyComputed, isFalse);
  expect(result.acplComputed, isFalse);
  expect(result.classificationComputed, isFalse);
  expect(result.publicClassifierOutputComputed, isFalse);
}
