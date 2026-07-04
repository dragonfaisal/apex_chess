import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_move_result_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapLegacyMoveResultToTimelineEntryReadModel', () {
    test('maps a valid fake Phase 36B read model', () {
      final result = _map(_source());

      expect(result.mappingSucceeded, isTrue);
      expect(result.timelineEntryComputed, isTrue);
      expect(result.safeForPhase36D, isTrue);
      expect(result.timelineEntryId, 'phase36C:e2e4:e2e3:white:depth1');
      expect(result.sourceReadModelId, 'phase36B:e2e4:e2e3:white:depth1');
      expect(
        result.legacyReintegrationResultId,
        'phase36A:e2e4:e2e3:white:depth1',
      );
      expect(
        result.phase35QAnalysisResultId,
        'phase35Q:e2e4:e2e3:white:depth1',
      );
      expect(
        result.timelineEntryKind,
        AnalyzerLegacyTimelineEntryKind.privateSingleMoveDraft,
      );
      expect(result.timelineEntryOrderKey, 0);
      expect(result.sourceReadModelComputed, isTrue);
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
        analyzerLegacyTimelineEntryReadModelNextRecommendation,
      );
    });

    test('fails closed if source is public', () {
      final result = _map(_source(readModelIsPublic: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36D, isFalse);
    });

    test('fails closed if source is official', () {
      final result = _map(_source(readModelIsOfficial: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36D, isFalse);
    });

    test('fails closed if source is product review', () {
      final result = _map(_source(readModelIsProductReview: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36D, isFalse);
    });

    test('fails closed if source is saved analysis', () {
      final result = _map(_source(readModelIsSavedAnalysis: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36D, isFalse);
    });

    test('fails closed if source produced UI output', () {
      final result = _map(_source(readModelIsUiOutput: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36D, isFalse);
    });

    test('fails closed if source touched archive or stats', () {
      final result = _map(_source(readModelIsArchiveStatsOutput: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36D, isFalse);
    });

    test('fails closed if source produced public label data', () {
      final result = _map(
        _source(publicLabelComputed: true, publicLabel: 'Brilliant'),
      );

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36D, isFalse);
      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('keeps timeline entry single-move only for valid mapping', () {
      final result = _map(_source());

      expect(result.timelineEntryIsSingleMoveOnly, isTrue);
      expect(
        result.timelineEntryKind,
        AnalyzerLegacyTimelineEntryKind.privateSingleMoveDraft,
      );
    });

    test('does not create a full-game timeline', () {
      final result = _map(_source());

      expect(result.timelineEntryIsFullGameTimeline, isFalse);
    });

    test('does not create a product timeline', () {
      final result = _map(_source());

      expect(result.timelineEntryIsProductTimeline, isFalse);
    });

    test('does not create UI output', () {
      final result = _map(_source());

      expect(result.timelineEntryIsUiOutput, isFalse);
      expect(result.uiOutputProduced, isFalse);
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

      expect(result.timelineEntryIsProductTimeline, isFalse);
      expect(result.timelineEntryIsUiOutput, isFalse);
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
        result.timelineEntryId,
        result.timelineEntryKind.wire,
      }.whereType<String>().toSet();

      expect(exposed.intersection(forbidden), isEmpty);
    });

    test('safeForPhase36D is true only when all safety flags are clean', () {
      final clean = _map(_source());
      final officialCpLoss = _map(_source(officialCpLossComputed: true));
      final officialWinPercent = _map(
        _source(officialWinPercentComputed: true),
      );
      final publicClassifier = _map(
        _source(publicClassifierOutputComputed: true),
      );

      expect(clean.safeForPhase36D, isTrue);
      expect(officialCpLoss.safeForPhase36D, isFalse);
      expect(officialWinPercent.safeForPhase36D, isFalse);
      expect(publicClassifier.safeForPhase36D, isFalse);
    });
  });
}

AnalyzerLegacyTimelineEntryReadModel _map(
  AnalyzerLegacyMoveResultReadModel source,
) {
  return mapLegacyMoveResultToTimelineEntryReadModel(source);
}

AnalyzerLegacyMoveResultReadModel _source({
  bool readModelComputed = true,
  bool readModelIsPublic = false,
  bool readModelIsProductReview = false,
  bool readModelIsSavedAnalysis = false,
  bool readModelIsOfficial = false,
  bool readModelIsUiOutput = false,
  bool readModelIsArchiveStatsOutput = false,
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
  bool archiveStatsTouched = false,
  bool mappingSucceeded = true,
  bool safeForPhase36C = true,
}) {
  return AnalyzerLegacyMoveResultReadModel(
    readModelId: 'phase36B:e2e4:e2e3:white:depth1',
    legacyReintegrationResultId: 'phase36A:e2e4:e2e3:white:depth1',
    phase35QAnalysisResultId: 'phase35Q:e2e4:e2e3:white:depth1',
    playedMoveUci: 'e2e4',
    candidateMoveUci: 'e2e3',
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: 1,
    readModelSource: analyzerLegacyMoveResultReadModelSource,
    readModelVersion: analyzerLegacyMoveResultReadModelVersion,
    privateDraftBucket: AnalyzerPrivateDraftBucket.positiveCandidate,
    privateDraftReasonCode:
        AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
    privateDraftConfidenceTier: AnalyzerPrivateDraftConfidenceTier.low,
    sourceLegacyReintegrationComputed: true,
    readModelComputed: readModelComputed,
    readModelIsPublic: readModelIsPublic,
    readModelIsProductReview: readModelIsProductReview,
    readModelIsSavedAnalysis: readModelIsSavedAnalysis,
    readModelIsOfficial: readModelIsOfficial,
    readModelIsUiOutput: readModelIsUiOutput,
    readModelIsArchiveStatsOutput: readModelIsArchiveStatsOutput,
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
    archiveStatsTouched: archiveStatsTouched,
    mappingSucceeded: mappingSucceeded,
    failureMessage: null,
    safeForPhase36C: safeForPhase36C,
    nextRecommendation: safeForPhase36C
        ? analyzerLegacyMoveResultReadModelNextRecommendation
        : analyzerLegacyMoveResultReadModelFailureRecommendation,
  );
}
