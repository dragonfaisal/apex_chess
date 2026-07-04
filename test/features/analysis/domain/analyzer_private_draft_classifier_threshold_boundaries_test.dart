import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('private draft classifier threshold boundaries', () {
    test('positive boundary includes loss candidate 35', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 1,
        moverPerspectiveCpLossCandidate: 35,
      );

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.positiveCandidate,
        reason:
            AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
        confidence: AnalyzerPrivateDraftConfidenceTier.low,
      );
    });

    test('positive boundary excludes loss candidate 36', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 1,
        moverPerspectiveCpLossCandidate: 36,
      );

      expect(
        result.privateDraftBucket,
        isNot(AnalyzerPrivateDraftBucket.positiveCandidate),
      );
      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.neutralCandidate,
        reason:
            AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
        confidence: AnalyzerPrivateDraftConfidenceTier.low,
      );
    });

    test('zero delta does not enter positive boundary', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 0,
        moverPerspectiveCpLossCandidate: 35,
      );

      expect(
        result.privateDraftBucket,
        isNot(AnalyzerPrivateDraftBucket.positiveCandidate),
      );
      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.neutralCandidate,
        reason:
            AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
        confidence: AnalyzerPrivateDraftConfidenceTier.low,
      );
    });

    test('worsened-delta precedence makes delta -20 negative', () {
      final result = _classify(
        moverPerspectiveDeltaCp: -20,
        moverPerspectiveCpLossCandidate: 60,
      );

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.negativeCandidate,
        reason: AnalyzerPrivateDraftReasonCode.worsenedAgainstCandidate,
        confidence: AnalyzerPrivateDraftConfidenceTier.low,
      );
    });

    test('delta -21 is not positive or neutral', () {
      final result = _classify(
        moverPerspectiveDeltaCp: -21,
        moverPerspectiveCpLossCandidate: 60,
      );

      expect(
        result.privateDraftBucket,
        isNot(AnalyzerPrivateDraftBucket.positiveCandidate),
      );
      expect(
        result.privateDraftBucket,
        isNot(AnalyzerPrivateDraftBucket.neutralCandidate),
      );
      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.negativeCandidate,
        reason: AnalyzerPrivateDraftReasonCode.worsenedAgainstCandidate,
        confidence: AnalyzerPrivateDraftConfidenceTier.low,
      );
    });

    test('neutral boundary includes delta 0 and loss candidate 60', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 0,
        moverPerspectiveCpLossCandidate: 60,
      );

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.neutralCandidate,
        reason:
            AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
        confidence: AnalyzerPrivateDraftConfidenceTier.low,
      );
    });

    test('neutral boundary includes delta 10 and loss candidate 60', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 10,
        moverPerspectiveCpLossCandidate: 60,
      );

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.neutralCandidate,
        reason:
            AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
        confidence: AnalyzerPrivateDraftConfidenceTier.low,
      );
    });

    test('neutral boundary excludes loss candidate 61 with small delta', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 0,
        moverPerspectiveCpLossCandidate: 61,
      );

      expect(
        result.privateDraftBucket,
        isNot(AnalyzerPrivateDraftBucket.neutralCandidate),
      );
      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.unavailable,
        reason: AnalyzerPrivateDraftReasonCode.missingEvidence,
        confidence: AnalyzerPrivateDraftConfidenceTier.unavailable,
        computed: false,
        safeForNextPhase: false,
      );
    });

    test('negative boundary includes delta -1', () {
      final result = _classify(
        moverPerspectiveDeltaCp: -1,
        moverPerspectiveCpLossCandidate: 1,
      );

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.negativeCandidate,
        reason: AnalyzerPrivateDraftReasonCode.worsenedAgainstCandidate,
        confidence: AnalyzerPrivateDraftConfidenceTier.low,
      );
    });

    test('severe candidate advantage starts at loss candidate 121', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 30,
        moverPerspectiveCpLossCandidate: 121,
      );

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.negativeCandidate,
        reason: AnalyzerPrivateDraftReasonCode.worsenedAgainstCandidate,
        confidence: AnalyzerPrivateDraftConfidenceTier.low,
      );
    });

    test('loss candidate 120 alone does not trigger severe advantage', () {
      final result = _classify(
        moverPerspectiveDeltaCp: 30,
        moverPerspectiveCpLossCandidate: 120,
      );

      expect(
        result.privateDraftBucket,
        isNot(AnalyzerPrivateDraftBucket.negativeCandidate),
      );
      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.unavailable,
        reason: AnalyzerPrivateDraftReasonCode.missingEvidence,
        confidence: AnalyzerPrivateDraftConfidenceTier.unavailable,
        computed: false,
        safeForNextPhase: false,
      );
    });

    test('gate blocked takes precedence over numeric evidence', () {
      final result = _classify(
        gateSucceeded: false,
        gateRecommendation: AnalyzerDraftClassificationGateRecommendation
            .notEligibleMissingEvidence,
        structurallyEligible: false,
        moverPerspectiveDeltaCp: 134,
        moverPerspectiveCpLossCandidate: 22,
      );

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.unavailable,
        reason: AnalyzerPrivateDraftReasonCode.gateBlocked,
        confidence: AnalyzerPrivateDraftConfidenceTier.unavailable,
        computed: false,
        safeForNextPhase: false,
      );
    });

    test('negative precedence beats positive numeric boundary', () {
      final result = _classify(
        moverPerspectiveDeltaCp: -1,
        moverPerspectiveCpLossCandidate: 35,
      );

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.negativeCandidate,
        reason: AnalyzerPrivateDraftReasonCode.worsenedAgainstCandidate,
        confidence: AnalyzerPrivateDraftConfidenceTier.low,
      );
    });

    test('missing mover perspective delta fails closed', () {
      final result = _classify(moverPerspectiveDeltaCp: null);

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.unavailable,
        reason: AnalyzerPrivateDraftReasonCode.missingEvidence,
        confidence: AnalyzerPrivateDraftConfidenceTier.unavailable,
        computed: false,
        safeForNextPhase: false,
      );
    });

    test('missing loss candidate fails closed', () {
      final result = _classify(moverPerspectiveCpLossCandidate: null);

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.unavailable,
        reason: AnalyzerPrivateDraftReasonCode.missingEvidence,
        confidence: AnalyzerPrivateDraftConfidenceTier.unavailable,
        computed: false,
        safeForNextPhase: false,
      );
    });

    test(
      'missing expected-points comparison does not crash and fails closed',
      () {
        final result = _classify(candidateVsPlayedExpectedPointsDelta: null);

        _expectPrivateDraft(
          result,
          bucket: AnalyzerPrivateDraftBucket.unavailable,
          reason: AnalyzerPrivateDraftReasonCode.missingEvidence,
          confidence: AnalyzerPrivateDraftConfidenceTier.unavailable,
          computed: false,
          safeForNextPhase: false,
        );
      },
    );

    test('non-eligible gate recommendation fails closed', () {
      final result = _classify(
        gateRecommendation: AnalyzerDraftClassificationGateRecommendation
            .blockedBecauseOfficialMetricsAlreadyComputed,
      );

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.unavailable,
        reason: AnalyzerPrivateDraftReasonCode.gateBlocked,
        confidence: AnalyzerPrivateDraftConfidenceTier.unavailable,
        computed: false,
        safeForNextPhase: false,
      );
    });

    test('non-developer-only evidence fails closed', () {
      final result = _classify(evidenceIsDeveloperOnly: false);

      _expectPrivateDraft(
        result,
        bucket: AnalyzerPrivateDraftBucket.unavailable,
        reason: AnalyzerPrivateDraftReasonCode.gateBlocked,
        confidence: AnalyzerPrivateDraftConfidenceTier.unavailable,
        computed: false,
        safeForNextPhase: false,
      );
    });

    test('public label hard ban covers private output fields', () {
      final result = _classify();
      final privateValues = <String?>[
        result.privateDraftBucket.wire,
        result.privateDraftReasonCode.wire,
        result.privateDraftConfidenceTier.wire,
        result.publicLabel,
        result.officialMoveQuality,
      ].whereType<String>().toSet();

      expect(
        AnalyzerPrivateDraftBucket.values.map((bucket) => bucket.wire).toSet(),
        {
          'positiveCandidate',
          'neutralCandidate',
          'negativeCandidate',
          'unavailable',
        },
      );
      expect(privateValues.intersection(_forbiddenPublicStrings), isEmpty);
      _expectNoPublicOrOfficialOutputs(result);
    });
  });
}

const _forbiddenPublicStrings = <String>{
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
  bool evidenceIsDeveloperOnly = true,
  AnalyzerDraftClassificationGateRecommendation gateRecommendation =
      AnalyzerDraftClassificationGateRecommendation
          .eligibleForFutureDraftClassifier,
  int? moverPerspectiveDeltaCp = 134,
  int? moverPerspectiveCpLossCandidate = 22,
  double? candidateVsPlayedExpectedPointsDelta = 0.0135,
}) {
  return evaluateAnalyzerPrivateDraftClassifier(
    request: const AnalyzerPrivateDraftClassifierRequest.controlled(),
    gate: _gate(
      gateSucceeded: gateSucceeded,
      structurallyEligible: structurallyEligible,
      evidenceIsDeveloperOnly: evidenceIsDeveloperOnly,
      gateRecommendation: gateRecommendation,
      moverPerspectiveDeltaCp: moverPerspectiveDeltaCp,
      moverPerspectiveCpLossCandidate: moverPerspectiveCpLossCandidate,
      candidateVsPlayedExpectedPointsDelta:
          candidateVsPlayedExpectedPointsDelta,
    ),
  );
}

AnalyzerDraftClassificationGateResult _gate({
  required bool gateSucceeded,
  required bool structurallyEligible,
  required bool evidenceIsDeveloperOnly,
  required AnalyzerDraftClassificationGateRecommendation gateRecommendation,
  required int? moverPerspectiveDeltaCp,
  required int? moverPerspectiveCpLossCandidate,
  required double? candidateVsPlayedExpectedPointsDelta,
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
    draftClassificationGateProbeSucceeded: gateSucceeded,
    failureMessage: gateSucceeded ? null : 'gate blocked',
    safeForPhase35N:
        gateSucceeded &&
        structurallyEligible &&
        evidenceIsDeveloperOnly &&
        evidencePresent,
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

void _expectPrivateDraft(
  AnalyzerPrivateDraftClassifierResult result, {
  required AnalyzerPrivateDraftBucket bucket,
  required AnalyzerPrivateDraftReasonCode reason,
  required AnalyzerPrivateDraftConfidenceTier confidence,
  bool computed = true,
  bool safeForNextPhase = true,
}) {
  expect(result.privateDraftBucket, bucket);
  expect(result.privateDraftReasonCode, reason);
  expect(result.privateDraftConfidenceTier, confidence);
  expect(result.privateDraftClassifierComputed, computed);
  expect(result.safeForPhase35O, safeForNextPhase);
  _expectNoPublicOrOfficialOutputs(result);
}

void _expectNoPublicOrOfficialOutputs(
  AnalyzerPrivateDraftClassifierResult result,
) {
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
