import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_collection_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_collection_read_model_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapLegacyTimelineEntriesToCollectionReadModel', () {
    test('maps one valid fake Phase 36C entry', () {
      final result = _map([_entry()]);

      expect(result.mappingSucceeded, isTrue);
      expect(result.timelineCollectionComputed, isTrue);
      expect(result.safeForPhase36E, isTrue);
      expect(result.timelineCollectionId, 'phase36D:e2e4:e2e3:white:count1');
      expect(result.sourceEntryCount, 1);
      expect(result.mappedEntryCount, 1);
      expect(result.blockedEntryCount, 0);
      expect(result.entryIds, ['phase36C:e2e4:e2e3:white:depth1:0']);
      expect(
        result.nextRecommendation,
        analyzerLegacyTimelineCollectionReadModelNextRecommendation,
      );
    });

    test('maps multiple valid fake Phase 36C entries', () {
      final result = _map([
        _entry(orderKey: 1, idSuffix: '1'),
        _entry(orderKey: 0, idSuffix: '0'),
      ]);

      expect(result.mappingSucceeded, isTrue);
      expect(result.sourceEntryCount, 2);
      expect(result.mappedEntryCount, 2);
      expect(result.blockedEntryCount, 0);
      expect(result.entries.length, 2);
    });

    test('sorts entries deterministically by timelineEntryOrderKey', () {
      final result = _map([
        _entry(orderKey: 2, idSuffix: '2'),
        _entry(orderKey: 0, idSuffix: '0'),
        _entry(orderKey: 1, idSuffix: '1'),
      ]);

      expect(result.entriesSortedByOrderKey, isTrue);
      expect(result.entryIds, [
        'phase36C:e2e4:e2e3:white:depth1:0',
        'phase36C:e2e4:e2e3:white:depth1:1',
        'phase36C:e2e4:e2e3:white:depth1:2',
      ]);
    });

    test('fails closed for empty list', () {
      final result = _map(const []);

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36E, isFalse);
      expect(result.timelineCollectionComputed, isFalse);
      expect(result.sourceEntryCount, 0);
      expect(result.mappedEntryCount, 0);
      expect(result.failureMessage, contains('requires at least one'));
    });

    test('fails closed if any entry is public', () {
      final result = _map([_entry(sourceReadModelIsPublic: true)]);

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36E, isFalse);
    });

    test('fails closed if any entry is official', () {
      final result = _map([_entry(sourceReadModelIsOfficial: true)]);

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36E, isFalse);
    });

    test('fails closed if any entry is product timeline', () {
      final result = _map([_entry(timelineEntryIsProductTimeline: true)]);

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36E, isFalse);
    });

    test('fails closed if any entry is full-game timeline', () {
      final result = _map([_entry(timelineEntryIsFullGameTimeline: true)]);

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36E, isFalse);
    });

    test('fails closed if any entry is saved analysis', () {
      final result = _map([_entry(sourceReadModelIsSavedAnalysis: true)]);

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36E, isFalse);
    });

    test('fails closed if any entry produced UI output', () {
      final result = _map([_entry(timelineEntryIsUiOutput: true)]);

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36E, isFalse);
    });

    test('fails closed if any entry touched archive or stats', () {
      final result = _map([_entry(sourceReadModelIsArchiveStatsOutput: true)]);

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36E, isFalse);
    });

    test('fails closed if any entry produced public label data', () {
      final result = _map([
        _entry(publicLabelComputed: true, publicLabel: 'Brilliant'),
      ]);

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36E, isFalse);
      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
      expect(result.entries, isEmpty);
    });

    test('collection remains developer-only', () {
      final result = _map([_entry()]);

      expect(result.timelineCollectionIsDeveloperOnly, isTrue);
      expect(result.timelineCollectionIsPublic, isFalse);
    });

    test('collection is not product review', () {
      final result = _map([_entry()]);

      expect(result.timelineCollectionIsProductReview, isFalse);
      expect(result.timelineCollectionIsProductTimeline, isFalse);
    });

    test('collection is not UI output', () {
      final result = _map([_entry()]);

      expect(result.timelineCollectionIsUiOutput, isFalse);
      expect(result.uiOutputProduced, isFalse);
    });

    test('collection is not archive or stats output', () {
      final result = _map([_entry()]);

      expect(result.timelineCollectionIsArchiveStatsOutput, isFalse);
      expect(result.archiveStatsTouched, isFalse);
    });

    test('keeps public label null', () {
      final result = _map([_entry()]);

      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('keeps official move quality null and official metrics false', () {
      final result = _map([_entry()]);

      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
      expect(result.officialCpLossComputed, isFalse);
      expect(result.officialWinPercentComputed, isFalse);
      expect(result.accuracyComputed, isFalse);
      expect(result.acplComputed, isFalse);
      expect(result.classificationComputed, isFalse);
      expect(result.publicClassifierOutputComputed, isFalse);
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
      final result = _map([_entry()]);
      final exposed = {
        result.publicLabel,
        result.officialMoveQuality,
        result.timelineCollectionId,
        result.timelineCollectionSource,
        ...result.entryIds,
        for (final entry in result.entries) entry.privateDraftBucket.wire,
        for (final entry in result.entries) entry.privateDraftReasonCode.wire,
        for (final entry in result.entries)
          entry.privateDraftConfidenceTier.wire,
        for (final entry in result.entries) entry.timelineEntryKind.wire,
      }.whereType<String>().toSet();

      expect(exposed.intersection(forbidden), isEmpty);
    });

    test('safeForPhase36E is true only when all safety flags are clean', () {
      final clean = _map([_entry()]);
      final officialCpLoss = _map([_entry(officialCpLossComputed: true)]);
      final officialWinPercent = _map([
        _entry(officialWinPercentComputed: true),
      ]);
      final publicClassifier = _map([
        _entry(publicClassifierOutputComputed: true),
      ]);

      expect(clean.safeForPhase36E, isTrue);
      expect(officialCpLoss.safeForPhase36E, isFalse);
      expect(officialWinPercent.safeForPhase36E, isFalse);
      expect(publicClassifier.safeForPhase36E, isFalse);
    });
  });
}

AnalyzerLegacyTimelineCollectionReadModel _map(
  List<AnalyzerLegacyTimelineEntryReadModel> entries,
) {
  return mapLegacyTimelineEntriesToCollectionReadModel(entries);
}

AnalyzerLegacyTimelineEntryReadModel _entry({
  int orderKey = 0,
  String idSuffix = '0',
  bool mappingSucceeded = true,
  bool safeForPhase36D = true,
  bool timelineEntryComputed = true,
  AnalyzerLegacyTimelineEntryKind timelineEntryKind =
      AnalyzerLegacyTimelineEntryKind.privateSingleMoveDraft,
  bool timelineEntryIsSingleMoveOnly = true,
  bool timelineEntryIsFullGameTimeline = false,
  bool timelineEntryIsProductTimeline = false,
  bool timelineEntryIsUiOutput = false,
  bool sourceReadModelIsPublic = false,
  bool sourceReadModelIsProductReview = false,
  bool sourceReadModelIsSavedAnalysis = false,
  bool sourceReadModelIsOfficial = false,
  bool sourceReadModelIsUiOutput = false,
  bool sourceReadModelIsArchiveStatsOutput = false,
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
}) {
  return AnalyzerLegacyTimelineEntryReadModel(
    timelineEntryId: 'phase36C:e2e4:e2e3:white:depth1:$idSuffix',
    sourceReadModelId: 'phase36B:e2e4:e2e3:white:depth1:$idSuffix',
    legacyReintegrationResultId: 'phase36A:e2e4:e2e3:white:depth1:$idSuffix',
    phase35QAnalysisResultId: 'phase35Q:e2e4:e2e3:white:depth1:$idSuffix',
    playedMoveUci: 'e2e4',
    candidateMoveUci: 'e2e3',
    moverColor: AnalyzerMoverColor.white,
    requestedDepth: 1,
    timelineEntrySource: analyzerLegacyTimelineEntryReadModelSource,
    timelineEntryVersion: analyzerLegacyTimelineEntryReadModelVersion,
    timelineEntryComputed: timelineEntryComputed,
    timelineEntryKind: timelineEntryKind,
    timelineEntryOrderKey: orderKey,
    timelineEntryIsSingleMoveOnly: timelineEntryIsSingleMoveOnly,
    timelineEntryIsFullGameTimeline: timelineEntryIsFullGameTimeline,
    timelineEntryIsProductTimeline: timelineEntryIsProductTimeline,
    timelineEntryIsUiOutput: timelineEntryIsUiOutput,
    privateDraftBucket: AnalyzerPrivateDraftBucket.positiveCandidate,
    privateDraftReasonCode:
        AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
    privateDraftConfidenceTier: AnalyzerPrivateDraftConfidenceTier.low,
    sourceReadModelComputed: true,
    sourceReadModelIsPublic: sourceReadModelIsPublic,
    sourceReadModelIsProductReview: sourceReadModelIsProductReview,
    sourceReadModelIsSavedAnalysis: sourceReadModelIsSavedAnalysis,
    sourceReadModelIsOfficial: sourceReadModelIsOfficial,
    sourceReadModelIsUiOutput: sourceReadModelIsUiOutput,
    sourceReadModelIsArchiveStatsOutput: sourceReadModelIsArchiveStatsOutput,
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
    safeForPhase36D: safeForPhase36D,
    nextRecommendation: safeForPhase36D
        ? analyzerLegacyTimelineEntryReadModelNextRecommendation
        : analyzerLegacyTimelineEntryReadModelFailureRecommendation,
  );
}
