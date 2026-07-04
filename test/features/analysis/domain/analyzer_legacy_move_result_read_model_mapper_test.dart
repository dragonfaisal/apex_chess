import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_move_result_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_move_result_read_model_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_reintegration_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapLegacyReintegrationToMoveResultReadModel', () {
    test('maps a valid fake Phase 36A result', () {
      final result = _map(_source());

      expect(result.mappingSucceeded, isTrue);
      expect(result.readModelComputed, isTrue);
      expect(result.safeForPhase36C, isTrue);
      expect(result.readModelId, 'phase36B:e2e4:e2e3:white:depth1');
      expect(
        result.legacyReintegrationResultId,
        'phase36A:e2e4:e2e3:white:depth1',
      );
      expect(
        result.phase35QAnalysisResultId,
        'phase35Q:e2e4:e2e3:white:depth1',
      );
      expect(result.sourceLegacyReintegrationComputed, isTrue);
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
        analyzerLegacyMoveResultReadModelNextRecommendation,
      );
    });

    test('fails closed if source is public', () {
      final result = _map(_source(legacyReintegrationIsPublic: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36C, isFalse);
    });

    test('fails closed if source is official', () {
      final result = _map(_source(legacyReintegrationIsOfficial: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36C, isFalse);
    });

    test('fails closed if source is product review output', () {
      final result = _map(_source(legacyReintegrationIsProductReview: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36C, isFalse);
    });

    test('fails closed if source is saved analysis output', () {
      final result = _map(_source(legacyReintegrationIsSavedAnalysis: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36C, isFalse);
    });

    test('fails closed if source produced UI output', () {
      final result = _map(_source(legacyUiOutputProduced: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36C, isFalse);
    });

    test('fails closed if source touched archive or stats', () {
      final result = _map(_source(legacyArchiveStatsTouched: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36C, isFalse);
    });

    test('fails closed if source produced public label data', () {
      final result = _map(
        _source(
          legacyPublicLabelProduced: true,
          publicLabelComputed: true,
          publicLabel: 'Brilliant',
        ),
      );

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36C, isFalse);
      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('keeps public label null', () {
      final result = _map(_source());

      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('keeps official move quality null', () {
      final result = _map(_source());

      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
    });

    test('keeps product, saved, UI, and archive flags false', () {
      final result = _map(_source());

      expect(result.readModelIsPublic, isFalse);
      expect(result.readModelIsProductReview, isFalse);
      expect(result.readModelIsSavedAnalysis, isFalse);
      expect(result.readModelIsOfficial, isFalse);
      expect(result.readModelIsUiOutput, isFalse);
      expect(result.readModelIsArchiveStatsOutput, isFalse);
      expect(result.savedAnalysisWritten, isFalse);
      expect(result.uiOutputProduced, isFalse);
      expect(result.archiveStatsTouched, isFalse);
    });

    test('public label strings are banned from exposed fields', () {
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
      final result = _map(_source());
      final exposed = {
        result.publicLabel,
        result.officialMoveQuality,
        result.privateDraftBucket.wire,
        result.privateDraftReasonCode.wire,
        result.privateDraftConfidenceTier.wire,
        result.readModelId,
      }.whereType<String>().toSet();

      expect(exposed.intersection(forbidden), isEmpty);
    });

    test('safeForPhase36C is true only when all safety flags are clean', () {
      final clean = _map(_source());
      final officialCpLoss = _map(_source(officialCpLossComputed: true));
      final officialWinPercent = _map(
        _source(officialWinPercentComputed: true),
      );
      final publicClassifier = _map(
        _source(publicClassifierOutputComputed: true),
      );

      expect(clean.safeForPhase36C, isTrue);
      expect(officialCpLoss.safeForPhase36C, isFalse);
      expect(officialWinPercent.safeForPhase36C, isFalse);
      expect(publicClassifier.safeForPhase36C, isFalse);
    });
  });
}

AnalyzerLegacyMoveResultReadModel _map(
  AnalyzerLegacyReintegrationResult source,
) {
  return mapLegacyReintegrationToMoveResultReadModel(source);
}

AnalyzerLegacyReintegrationResult _source({
  bool legacyReintegrationComputed = true,
  bool legacyReintegrationIsPublic = false,
  bool legacyReintegrationIsProductReview = false,
  bool legacyReintegrationIsSavedAnalysis = false,
  bool legacyReintegrationIsOfficial = false,
  bool legacyPublicLabelProduced = false,
  bool legacyOfficialMoveQualityProduced = false,
  bool legacySavedAnalysisWritten = false,
  bool legacyUiOutputProduced = false,
  bool legacyArchiveStatsTouched = false,
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
  bool legacyReintegrationProbeSucceeded = true,
  bool safeForPhase36B = true,
}) {
  return AnalyzerLegacyReintegrationResult(
    legacyReintegrationResultId: 'phase36A:e2e4:e2e3:white:depth1',
    playedMoveUci: analyzerLegacyReintegrationPlayedMoveUci,
    candidateMoveUci: analyzerLegacyReintegrationCandidateMoveUci,
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: analyzerLegacyReintegrationDepth,
    reintegrationSource: analyzerLegacyReintegrationSource,
    reintegrationModelName: analyzerLegacyReintegrationModelName,
    reintegrationModelVersion: analyzerLegacyReintegrationModelVersion,
    phase35QAnalysisResultId: 'phase35Q:e2e4:e2e3:white:depth1',
    privateSingleMoveDraftAnalysisComputed: true,
    privateDraftBucket: AnalyzerPrivateDraftBucket.positiveCandidate,
    privateDraftReasonCode:
        AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
    privateDraftConfidenceTier: AnalyzerPrivateDraftConfidenceTier.low,
    legacyReintegrationComputed: legacyReintegrationComputed,
    legacyReintegrationIsPublic: legacyReintegrationIsPublic,
    legacyReintegrationIsProductReview: legacyReintegrationIsProductReview,
    legacyReintegrationIsSavedAnalysis: legacyReintegrationIsSavedAnalysis,
    legacyReintegrationIsOfficial: legacyReintegrationIsOfficial,
    legacyPublicLabelProduced: legacyPublicLabelProduced,
    legacyOfficialMoveQualityProduced: legacyOfficialMoveQualityProduced,
    legacySavedAnalysisWritten: legacySavedAnalysisWritten,
    legacyUiOutputProduced: legacyUiOutputProduced,
    legacyArchiveStatsTouched: legacyArchiveStatsTouched,
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
    legacyReintegrationProbeSucceeded: legacyReintegrationProbeSucceeded,
    failureMessage: null,
    safeForPhase36B: safeForPhase36B,
    nextRecommendation: safeForPhase36B
        ? analyzerLegacyReintegrationNextRecommendation
        : analyzerLegacyReintegrationFailureRecommendation,
    blockers: const [],
    warnings: const [],
  );
}
