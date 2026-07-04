import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_single_move_draft_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluateAnalyzerPrivateSingleMoveDraftAnalysis', () {
    test('packages a valid private classifier result', () {
      final result = _evaluate(_privateClassifier());

      expect(result.privateSingleMoveDraftAnalysisComputed, isTrue);
      expect(result.safeForPhase36A, isTrue);
      expect(result.analysisResultId, 'phase35Q:e2e4:e2e3:white:depth1');
      expect(result.playedMoveUci, 'e2e4');
      expect(result.candidateMoveUci, 'e2e3');
      expect(result.moverColor, AnalyzerMoverColor.white);
      expect(result.requestedDepth, 1);
      expect(result.beforeMoverPerspectiveCp, -39);
      expect(result.playedAfterMoverPerspectiveCp, 95);
      expect(result.candidateAfterMoverPerspectiveCp, 117);
      expect(result.moverPerspectiveDeltaCp, 134);
      expect(result.moverPerspectiveCpLossCandidate, 22);
      expect(result.cpDeltaComputed, isTrue);
      expect(result.cpLossCandidateComputed, isTrue);
      expect(result.expectedPointsComputed, isTrue);
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
      expect(
        result.nextRecommendation,
        analyzerPrivateSingleMoveDraftAnalysisNextRecommendation,
      );
    });

    test('fails closed when private classifier is unavailable', () {
      final result = _evaluate(
        _privateClassifier(
          privateDraftClassifierProbeSucceeded: false,
          safeForPhase35O: false,
          privateDraftClassifierComputed: false,
          privateDraftBucket: AnalyzerPrivateDraftBucket.unavailable,
          privateDraftReasonCode: AnalyzerPrivateDraftReasonCode.gateBlocked,
          privateDraftConfidenceTier:
              AnalyzerPrivateDraftConfidenceTier.unavailable,
          failureMessage: 'private classifier unavailable',
          blockers: const ['private classifier unavailable'],
        ),
      );

      expect(result.privateSingleMoveDraftAnalysisComputed, isFalse);
      expect(result.privateSingleMoveDraftAnalysisProbeSucceeded, isFalse);
      expect(result.safeForPhase36A, isFalse);
      expect(
        result.nextRecommendation,
        analyzerPrivateSingleMoveDraftAnalysisFailureRecommendation,
      );
      expect(result.failureMessage, 'private classifier unavailable');
    });

    test('keeps public label null', () {
      final result = _evaluate(_privateClassifier());

      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('keeps official move quality null', () {
      final result = _evaluate(_privateClassifier());

      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
    });

    test('keeps product, saved analysis, and UI flags false', () {
      final result = _evaluate(_privateClassifier());

      expect(result.privateSingleMoveDraftAnalysisIsPublic, isFalse);
      expect(result.privateSingleMoveDraftAnalysisIsProductReview, isFalse);
      expect(result.privateSingleMoveDraftAnalysisIsSavedAnalysis, isFalse);
      expect(result.privateSingleMoveDraftAnalysisIsOfficial, isFalse);
      expect(result.savedAnalysisWritten, isFalse);
      expect(result.uiOutputProduced, isFalse);
    });

    test('blocks leaked public label strings', () {
      final result = _evaluate(_privateClassifier(publicLabel: 'Brilliant'));

      expect(result.privateSingleMoveDraftAnalysisComputed, isFalse);
      expect(result.safeForPhase36A, isFalse);
      expect(
        result.blockers,
        contains('Public label string appeared in private draft analysis.'),
      );
    });

    test('private vocabulary does not contain public label strings', () {
      const forbidden = {
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
      final privateValues = {
        ...AnalyzerPrivateDraftBucket.values.map((value) => value.wire),
        ...AnalyzerPrivateDraftReasonCode.values.map((value) => value.wire),
        ...AnalyzerPrivateDraftConfidenceTier.values.map((value) => value.wire),
      };

      expect(privateValues.intersection(forbidden), isEmpty);
    });

    test('safeForPhase36A is false when a safety flag is dirty', () {
      final publicClassifier = _evaluate(
        _privateClassifier(privateDraftClassifierIsPublic: true),
      );
      final nonNullPublicLabel = _evaluate(
        _privateClassifier(publicLabel: 'internalLeak'),
      );
      final officialMoveQuality = _evaluate(
        _privateClassifier(officialMoveQualityComputed: true),
      );
      final officialExpectedPoints = _evaluate(
        _privateClassifier(expectedPointsModelIsOfficial: true),
      );

      expect(publicClassifier.safeForPhase36A, isFalse);
      expect(nonNullPublicLabel.safeForPhase36A, isFalse);
      expect(officialMoveQuality.safeForPhase36A, isFalse);
      expect(officialExpectedPoints.safeForPhase36A, isFalse);
    });
  });
}

AnalyzerPrivateSingleMoveDraftAnalysisResult _evaluate(
  AnalyzerPrivateDraftClassifierResult privateClassifier,
) {
  return evaluateAnalyzerPrivateSingleMoveDraftAnalysis(
    request: const AnalyzerPrivateSingleMoveDraftAnalysisRequest.controlled(),
    privateClassifier: privateClassifier,
  );
}

AnalyzerPrivateDraftClassifierResult _privateClassifier({
  bool draftClassificationGateComputed = true,
  bool evidenceStructurallyEligibleForFutureClassification = true,
  bool evidenceIsDeveloperOnly = true,
  AnalyzerDraftClassificationGateRecommendation gateRecommendation =
      AnalyzerDraftClassificationGateRecommendation
          .eligibleForFutureDraftClassifier,
  int? beforeMoverPerspectiveCp = -39,
  int? playedAfterMoverPerspectiveCp = 95,
  int? candidateAfterMoverPerspectiveCp = 117,
  int? moverPerspectiveDeltaCp = 134,
  int? moverPerspectiveCpLossCandidate = 22,
  String? cpLossCandidateDirection = 'candidateBetter',
  String? expectedPointsModelName = analyzerExpectedPointsModelName,
  String? expectedPointsModelVersion = analyzerExpectedPointsModelVersion,
  bool expectedPointsModelIsOfficial = false,
  double? beforeExpectedPoints = 0.47564429123179275,
  double? playedAfterExpectedPoints = 0.559097471902393,
  double? candidateAfterExpectedPoints = 0.5726080638632601,
  double? playedExpectedPointsDelta = 0.08345318067060026,
  double? candidateVsPlayedExpectedPointsDelta = 0.013510591960867124,
  bool privateDraftClassifierComputed = true,
  AnalyzerPrivateDraftBucket privateDraftBucket =
      AnalyzerPrivateDraftBucket.positiveCandidate,
  AnalyzerPrivateDraftReasonCode privateDraftReasonCode =
      AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
  AnalyzerPrivateDraftConfidenceTier privateDraftConfidenceTier =
      AnalyzerPrivateDraftConfidenceTier.low,
  bool privateDraftClassifierIsPublic = false,
  bool privateDraftClassifierIsOfficialMoveQuality = false,
  bool privateDraftClassifierIsPublicLabel = false,
  bool publicLabelComputed = false,
  String? publicLabel,
  bool officialMoveQualityComputed = false,
  String? officialMoveQuality,
  bool officialCpLossComputed = false,
  bool officialWinPercentComputed = false,
  bool accuracyComputed = false,
  bool acplComputed = false,
  bool classificationComputed = false,
  bool publicClassifierOutputComputed = false,
  bool privateDraftClassifierProbeSucceeded = true,
  String? failureMessage,
  bool safeForPhase35O = true,
  String nextRecommendation = analyzerPrivateDraftClassifierNextRecommendation,
  List<String> blockers = const [],
  List<String> warnings = const [],
}) {
  return AnalyzerPrivateDraftClassifierResult(
    playedMoveUci: analyzerPrivateDraftClassifierPlayedMoveUci,
    candidateMoveUci: analyzerPrivateDraftClassifierCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerPrivateDraftClassifierDepth,
    privateClassifierSource: analyzerPrivateDraftClassifierSource,
    privateClassifierModelName: analyzerPrivateDraftClassifierModelName,
    privateClassifierModelVersion: analyzerPrivateDraftClassifierModelVersion,
    draftClassificationGateComputed: draftClassificationGateComputed,
    evidenceStructurallyEligibleForFutureClassification:
        evidenceStructurallyEligibleForFutureClassification,
    evidenceIsDeveloperOnly: evidenceIsDeveloperOnly,
    gateRecommendation: gateRecommendation,
    beforeMoverPerspectiveCp: beforeMoverPerspectiveCp,
    playedAfterMoverPerspectiveCp: playedAfterMoverPerspectiveCp,
    candidateAfterMoverPerspectiveCp: candidateAfterMoverPerspectiveCp,
    moverPerspectiveDeltaCp: moverPerspectiveDeltaCp,
    moverPerspectiveCpLossCandidate: moverPerspectiveCpLossCandidate,
    cpLossCandidateDirection: cpLossCandidateDirection,
    expectedPointsModelName: expectedPointsModelName,
    expectedPointsModelVersion: expectedPointsModelVersion,
    expectedPointsModelIsOfficial: expectedPointsModelIsOfficial,
    beforeExpectedPoints: beforeExpectedPoints,
    playedAfterExpectedPoints: playedAfterExpectedPoints,
    candidateAfterExpectedPoints: candidateAfterExpectedPoints,
    playedExpectedPointsDelta: playedExpectedPointsDelta,
    candidateVsPlayedExpectedPointsDelta: candidateVsPlayedExpectedPointsDelta,
    privateDraftClassifierComputed: privateDraftClassifierComputed,
    privateDraftBucket: privateDraftBucket,
    privateDraftReasonCode: privateDraftReasonCode,
    privateDraftConfidenceTier: privateDraftConfidenceTier,
    privateDraftClassifierIsPublic: privateDraftClassifierIsPublic,
    privateDraftClassifierIsOfficialMoveQuality:
        privateDraftClassifierIsOfficialMoveQuality,
    privateDraftClassifierIsPublicLabel: privateDraftClassifierIsPublicLabel,
    publicLabelComputed: publicLabelComputed,
    publicLabel: publicLabel,
    officialMoveQualityComputed: officialMoveQualityComputed,
    officialMoveQuality: officialMoveQuality,
    officialCpLossComputed: officialCpLossComputed,
    officialWinPercentComputed: officialWinPercentComputed,
    accuracyComputed: accuracyComputed,
    acplComputed: acplComputed,
    classificationComputed: classificationComputed,
    publicClassifierOutputComputed: publicClassifierOutputComputed,
    privateDraftClassifierProbeSucceeded: privateDraftClassifierProbeSucceeded,
    failureMessage: failureMessage,
    safeForPhase35O: safeForPhase35O,
    nextRecommendation: nextRecommendation,
    blockers: blockers,
    warnings: warnings,
  );
}
