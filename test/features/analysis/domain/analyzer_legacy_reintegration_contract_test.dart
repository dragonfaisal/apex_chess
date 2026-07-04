import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_draft_classification_gate.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_expected_points.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_single_move_draft_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('evaluateAnalyzerLegacyReintegration', () {
    test('succeeds with a valid fake Phase 35Q result', () {
      final result = _evaluate(_phase35Q());

      expect(result.legacyReintegrationComputed, isTrue);
      expect(result.legacyReintegrationProbeSucceeded, isTrue);
      expect(result.safeForPhase36B, isTrue);
      expect(
        result.legacyReintegrationResultId,
        'phase36A:e2e4:e2e3:white:depth1',
      );
      expect(
        result.phase35QAnalysisResultId,
        'phase35Q:e2e4:e2e3:white:depth1',
      );
      expect(result.privateSingleMoveDraftAnalysisComputed, isTrue);
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
        analyzerLegacyReintegrationNextRecommendation,
      );
    });

    test('fails closed if Phase 35Q result is public', () {
      final result = _evaluate(
        _phase35Q(privateSingleMoveDraftAnalysisIsPublic: true),
      );

      expect(result.legacyReintegrationComputed, isFalse);
      expect(result.safeForPhase36B, isFalse);
      expect(
        result.nextRecommendation,
        analyzerLegacyReintegrationFailureRecommendation,
      );
    });

    test('fails closed if Phase 35Q result is official', () {
      final result = _evaluate(
        _phase35Q(privateSingleMoveDraftAnalysisIsOfficial: true),
      );

      expect(result.legacyReintegrationComputed, isFalse);
      expect(result.safeForPhase36B, isFalse);
    });

    test('fails closed if Phase 35Q wrote saved analysis', () {
      final result = _evaluate(_phase35Q(savedAnalysisWritten: true));

      expect(result.legacyReintegrationComputed, isFalse);
      expect(result.safeForPhase36B, isFalse);
    });

    test('fails closed if Phase 35Q produced UI output', () {
      final result = _evaluate(_phase35Q(uiOutputProduced: true));

      expect(result.legacyReintegrationComputed, isFalse);
      expect(result.safeForPhase36B, isFalse);
    });

    test('keeps public label null', () {
      final result = _evaluate(_phase35Q());

      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('keeps official move quality null', () {
      final result = _evaluate(_phase35Q());

      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
    });

    test('keeps product, saved, UI, and archive stats flags false', () {
      final result = _evaluate(_phase35Q());

      expect(result.legacyReintegrationIsPublic, isFalse);
      expect(result.legacyReintegrationIsProductReview, isFalse);
      expect(result.legacyReintegrationIsSavedAnalysis, isFalse);
      expect(result.legacyReintegrationIsOfficial, isFalse);
      expect(result.legacyPublicLabelProduced, isFalse);
      expect(result.legacyOfficialMoveQualityProduced, isFalse);
      expect(result.legacySavedAnalysisWritten, isFalse);
      expect(result.legacyUiOutputProduced, isFalse);
      expect(result.legacyArchiveStatsTouched, isFalse);
    });

    test('blocks leaked public label strings', () {
      final result = _evaluate(_phase35Q(publicLabel: 'Brilliant'));

      expect(result.legacyReintegrationComputed, isFalse);
      expect(result.safeForPhase36B, isFalse);
      expect(
        result.blockers,
        contains('Public label string appeared in legacy reintegration.'),
      );
    });

    test('public label strings are banned from exposed private fields', () {
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
        _evaluate(_phase35Q()).legacyReintegrationResultId,
      };

      expect(privateValues.intersection(forbidden), isEmpty);
    });

    test('safeForPhase36B is true only when all safety flags are clean', () {
      final clean = _evaluate(_phase35Q());
      final officialCpLoss = _evaluate(_phase35Q(officialCpLossComputed: true));
      final publicClassifier = _evaluate(
        _phase35Q(publicClassifierOutputComputed: true),
      );
      final nonNullOfficialMoveQuality = _evaluate(
        _phase35Q(officialMoveQuality: 'internalLeak'),
      );

      expect(clean.safeForPhase36B, isTrue);
      expect(officialCpLoss.safeForPhase36B, isFalse);
      expect(publicClassifier.safeForPhase36B, isFalse);
      expect(nonNullOfficialMoveQuality.safeForPhase36B, isFalse);
    });
  });
}

AnalyzerLegacyReintegrationResult _evaluate(
  AnalyzerPrivateSingleMoveDraftAnalysisResult phase35Q,
) {
  return evaluateAnalyzerLegacyReintegration(
    request: const AnalyzerLegacyReintegrationRequest.controlled(),
    phase35Q: phase35Q,
  );
}

AnalyzerPrivateSingleMoveDraftAnalysisResult _phase35Q({
  String analysisResultId = 'phase35Q:e2e4:e2e3:white:depth1',
  bool privateSingleMoveDraftAnalysisComputed = true,
  bool privateSingleMoveDraftAnalysisIsPublic = false,
  bool privateSingleMoveDraftAnalysisIsProductReview = false,
  bool privateSingleMoveDraftAnalysisIsSavedAnalysis = false,
  bool privateSingleMoveDraftAnalysisIsOfficial = false,
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
  bool savedAnalysisWritten = false,
  bool uiOutputProduced = false,
  bool privateSingleMoveDraftAnalysisProbeSucceeded = true,
  bool safeForPhase36A = true,
  String? failureMessage,
  List<String> blockers = const [],
  List<String> warnings = const [],
}) {
  return AnalyzerPrivateSingleMoveDraftAnalysisResult(
    analysisResultId: analysisResultId,
    playedMoveUci: analyzerPrivateSingleMoveDraftAnalysisPlayedMoveUci,
    candidateMoveUci: analyzerPrivateSingleMoveDraftAnalysisCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerPrivateSingleMoveDraftAnalysisDepth,
    analysisSource: analyzerPrivateSingleMoveDraftAnalysisSource,
    analysisModelName: analyzerPrivateSingleMoveDraftAnalysisModelName,
    analysisModelVersion: analyzerPrivateSingleMoveDraftAnalysisModelVersion,
    beforeMoverPerspectiveCp: -39,
    playedAfterMoverPerspectiveCp: 95,
    candidateAfterMoverPerspectiveCp: 117,
    moverPerspectiveDeltaCp: 134,
    moverPerspectiveCpLossCandidate: 22,
    cpDeltaComputed: true,
    cpLossCandidateComputed: true,
    cpLossCandidateDirection: 'candidateBetter',
    expectedPointsComputed: true,
    expectedPointsModelName: analyzerExpectedPointsModelName,
    expectedPointsModelVersion: analyzerExpectedPointsModelVersion,
    expectedPointsModelIsOfficial: false,
    beforeExpectedPoints: 0.47564429123179275,
    playedAfterExpectedPoints: 0.559097471902393,
    candidateAfterExpectedPoints: 0.5726080638632601,
    playedExpectedPointsDelta: 0.08345318067060026,
    candidateVsPlayedExpectedPointsDelta: 0.013510591960867124,
    draftClassificationGateComputed: true,
    evidenceStructurallyEligibleForFutureClassification: true,
    evidenceIsDeveloperOnly: true,
    gateRecommendation: AnalyzerDraftClassificationGateRecommendation
        .eligibleForFutureDraftClassifier,
    privateDraftClassifierComputed: true,
    privateDraftBucket: AnalyzerPrivateDraftBucket.positiveCandidate,
    privateDraftReasonCode:
        AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
    privateDraftConfidenceTier: AnalyzerPrivateDraftConfidenceTier.low,
    privateDraftClassifierIsPublic: false,
    privateDraftClassifierIsOfficialMoveQuality: false,
    privateDraftClassifierIsPublicLabel: false,
    privateSingleMoveDraftAnalysisComputed:
        privateSingleMoveDraftAnalysisComputed,
    privateSingleMoveDraftAnalysisIsPublic:
        privateSingleMoveDraftAnalysisIsPublic,
    privateSingleMoveDraftAnalysisIsProductReview:
        privateSingleMoveDraftAnalysisIsProductReview,
    privateSingleMoveDraftAnalysisIsSavedAnalysis:
        privateSingleMoveDraftAnalysisIsSavedAnalysis,
    privateSingleMoveDraftAnalysisIsOfficial:
        privateSingleMoveDraftAnalysisIsOfficial,
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
    savedAnalysisWritten: savedAnalysisWritten,
    uiOutputProduced: uiOutputProduced,
    privateSingleMoveDraftAnalysisProbeSucceeded:
        privateSingleMoveDraftAnalysisProbeSucceeded,
    failureMessage: failureMessage,
    safeForPhase36A: safeForPhase36A,
    nextRecommendation: safeForPhase36A
        ? analyzerPrivateSingleMoveDraftAnalysisNextRecommendation
        : analyzerPrivateSingleMoveDraftAnalysisFailureRecommendation,
    blockers: blockers,
    warnings: warnings,
  );
}
