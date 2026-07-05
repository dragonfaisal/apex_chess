import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_summary_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_summary_read_model_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_collection_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapLegacyTimelineCollectionToReviewSummaryReadModel', () {
    test('maps a valid collection containing one positiveCandidate', () {
      final result = _map(_collection(entries: [_entry()]));

      expect(result.mappingSucceeded, isTrue);
      expect(result.reviewSummaryComputed, isTrue);
      expect(result.safeForPhase36F, isTrue);
      expect(result.totalPrivateEntries, 1);
      expect(result.positiveCandidateCount, 1);
      expect(result.neutralCandidateCount, 0);
      expect(result.negativeCandidateCount, 0);
      expect(result.unavailableCount, 0);
      expect(
        result.nextRecommendation,
        analyzerLegacyReviewSummaryReadModelNextRecommendation,
      );
    });

    test('maps mixed private bucket entries', () {
      final result = _map(
        _collection(
          entries: [
            _entry(bucket: AnalyzerPrivateDraftBucket.positiveCandidate),
            _entry(
              idSuffix: '1',
              orderKey: 1,
              bucket: AnalyzerPrivateDraftBucket.neutralCandidate,
            ),
            _entry(
              idSuffix: '2',
              orderKey: 2,
              bucket: AnalyzerPrivateDraftBucket.negativeCandidate,
            ),
            _entry(
              idSuffix: '3',
              orderKey: 3,
              bucket: AnalyzerPrivateDraftBucket.unavailable,
            ),
          ],
        ),
      );

      expect(result.mappingSucceeded, isTrue);
      expect(result.totalPrivateEntries, 4);
      expect(result.positiveCandidateCount, 1);
      expect(result.neutralCandidateCount, 1);
      expect(result.negativeCandidateCount, 1);
      expect(result.unavailableCount, 1);
    });

    test('bucket counts sum to totalPrivateEntries', () {
      final result = _map(
        _collection(
          entries: [
            _entry(bucket: AnalyzerPrivateDraftBucket.positiveCandidate),
            _entry(
              idSuffix: '1',
              orderKey: 1,
              bucket: AnalyzerPrivateDraftBucket.neutralCandidate,
            ),
          ],
        ),
      );

      final countSum =
          result.positiveCandidateCount +
          result.neutralCandidateCount +
          result.negativeCandidateCount +
          result.unavailableCount;

      expect(result.totalPrivateEntries, countSum);
      expect(result.totalPrivateEntries, 2);
    });

    test('fails closed for unsafe collection', () {
      final result = _map(_collection(mappingSucceeded: false));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36F, isFalse);
      expect(result.reviewSummaryComputed, isFalse);
    });

    test('fails closed for product-review collection', () {
      final result = _map(_collection(timelineCollectionIsProductReview: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36F, isFalse);
    });

    test('fails closed for saved-analysis collection', () {
      final result = _map(_collection(timelineCollectionIsSavedAnalysis: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36F, isFalse);
    });

    test('fails closed for UI-output collection', () {
      final result = _map(_collection(timelineCollectionIsUiOutput: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36F, isFalse);
    });

    test('fails closed for archive/stats collection', () {
      final result = _map(
        _collection(timelineCollectionIsArchiveStatsOutput: true),
      );

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36F, isFalse);
    });

    test('fails closed for full-game or product-timeline collection', () {
      final fullGame = _map(
        _collection(timelineCollectionIsFullGameAnalysis: true),
      );
      final productTimeline = _map(
        _collection(timelineCollectionIsProductTimeline: true),
      );

      expect(fullGame.mappingSucceeded, isFalse);
      expect(fullGame.safeForPhase36F, isFalse);
      expect(productTimeline.mappingSucceeded, isFalse);
      expect(productTimeline.safeForPhase36F, isFalse);
    });

    test('fails closed if entries are not all safe', () {
      final result = _map(_collection(allEntriesSafe: false));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36F, isFalse);
    });

    test('fails closed if unknown private bucket appears', () {
      final result = _map(
        _collection(entries: [_entry()]),
        allowedPrivateBuckets: const {
          AnalyzerPrivateDraftBucket.neutralCandidate,
          AnalyzerPrivateDraftBucket.negativeCandidate,
          AnalyzerPrivateDraftBucket.unavailable,
        },
      );

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36F, isFalse);
      expect(result.failureMessage, contains('unknown private draft bucket'));
    });

    test('keeps public label null', () {
      final result = _map(_collection(entries: [_entry()]));

      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('keeps official move quality null', () {
      final result = _map(_collection(entries: [_entry()]));

      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
    });

    test('keeps accuracy, ACPL, and Win% false', () {
      final result = _map(_collection(entries: [_entry()]));

      expect(result.officialWinPercentComputed, isFalse);
      expect(result.accuracyComputed, isFalse);
      expect(result.acplComputed, isFalse);
    });

    test('summary remains developer-only', () {
      final result = _map(_collection(entries: [_entry()]));

      expect(result.reviewSummaryIsDeveloperOnly, isTrue);
      expect(result.reviewSummaryIsPublic, isFalse);
      expect(result.reviewSummaryIsProductReview, isFalse);
      expect(result.reviewSummaryIsSavedAnalysis, isFalse);
      expect(result.reviewSummaryIsUiOutput, isFalse);
      expect(result.reviewSummaryIsArchiveStatsOutput, isFalse);
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
      final result = _map(_collection(entries: [_entry()]));
      final exposed = {
        result.publicLabel,
        result.officialMoveQuality,
        result.reviewSummaryId,
        result.reviewSummarySource,
      }.whereType<String>().toSet();

      expect(exposed.intersection(forbidden), isEmpty);
    });

    test(
      'fails closed and sanitizes source id if source leaks label string',
      () {
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
        final result = _map(
          _collection(timelineCollectionId: 'phase36D:Brilliant:count1'),
        );
        final exposed = {
          result.publicLabel,
          result.officialMoveQuality,
          result.reviewSummaryId,
          result.reviewSummarySource,
          result.sourceTimelineCollectionId,
        }.whereType<String>().toSet();

        expect(result.mappingSucceeded, isFalse);
        expect(result.safeForPhase36F, isFalse);
        expect(exposed.intersection(forbidden), isEmpty);
      },
    );

    test('safeForPhase36F is true only when all safety flags are clean', () {
      final clean = _map(_collection(entries: [_entry()]));
      final officialWinPercent = _map(
        _collection(officialWinPercentComputed: true),
      );
      final accuracy = _map(_collection(accuracyComputed: true));
      final acpl = _map(_collection(acplComputed: true));

      expect(clean.safeForPhase36F, isTrue);
      expect(officialWinPercent.safeForPhase36F, isFalse);
      expect(accuracy.safeForPhase36F, isFalse);
      expect(acpl.safeForPhase36F, isFalse);
    });
  });
}

AnalyzerLegacyReviewSummaryReadModel _map(
  AnalyzerLegacyTimelineCollectionReadModel collection, {
  Set<AnalyzerPrivateDraftBucket> allowedPrivateBuckets =
      analyzerLegacyReviewSummaryAllowedPrivateBuckets,
}) {
  return mapLegacyTimelineCollectionToReviewSummaryReadModel(
    collection,
    allowedPrivateBuckets: allowedPrivateBuckets,
  );
}

AnalyzerLegacyTimelineCollectionReadModel _collection({
  List<AnalyzerLegacyTimelineEntryReadModel>? entries,
  String? timelineCollectionId,
  bool mappingSucceeded = true,
  bool safeForPhase36E = true,
  bool timelineCollectionComputed = true,
  bool timelineCollectionIsPublic = false,
  bool timelineCollectionIsProductReview = false,
  bool timelineCollectionIsSavedAnalysis = false,
  bool timelineCollectionIsOfficial = false,
  bool timelineCollectionIsUiOutput = false,
  bool timelineCollectionIsArchiveStatsOutput = false,
  bool timelineCollectionIsFullGameAnalysis = false,
  bool timelineCollectionIsProductTimeline = false,
  bool timelineCollectionIsDeveloperOnly = true,
  bool allEntriesAreSingleMoveOnly = true,
  bool allEntriesArePrivateSingleMoveDraft = true,
  bool? allEntriesSafe,
  bool entriesSortedByOrderKey = true,
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
  final sourceEntries = entries ?? [_entry()];

  return AnalyzerLegacyTimelineCollectionReadModel(
    timelineCollectionId:
        timelineCollectionId ??
        'phase36D:e2e4:e2e3:white:count${sourceEntries.length}',
    timelineCollectionSource: analyzerLegacyTimelineCollectionReadModelSource,
    timelineCollectionVersion: analyzerLegacyTimelineCollectionReadModelVersion,
    sourceEntryCount: sourceEntries.length,
    mappedEntryCount: sourceEntries.length,
    blockedEntryCount: 0,
    timelineCollectionComputed: timelineCollectionComputed,
    timelineCollectionIsPublic: timelineCollectionIsPublic,
    timelineCollectionIsProductReview: timelineCollectionIsProductReview,
    timelineCollectionIsSavedAnalysis: timelineCollectionIsSavedAnalysis,
    timelineCollectionIsOfficial: timelineCollectionIsOfficial,
    timelineCollectionIsUiOutput: timelineCollectionIsUiOutput,
    timelineCollectionIsArchiveStatsOutput:
        timelineCollectionIsArchiveStatsOutput,
    timelineCollectionIsFullGameAnalysis: timelineCollectionIsFullGameAnalysis,
    timelineCollectionIsProductTimeline: timelineCollectionIsProductTimeline,
    timelineCollectionIsDeveloperOnly: timelineCollectionIsDeveloperOnly,
    entries: sourceEntries,
    entryIds: sourceEntries
        .map((entry) => entry.timelineEntryId)
        .toList(growable: false),
    allEntriesAreSingleMoveOnly: allEntriesAreSingleMoveOnly,
    allEntriesArePrivateSingleMoveDraft: allEntriesArePrivateSingleMoveDraft,
    allEntriesSafe: allEntriesSafe ?? true,
    entriesSortedByOrderKey: entriesSortedByOrderKey,
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
    failureMessage: mappingSucceeded ? null : 'blocked fake collection',
    safeForPhase36E: safeForPhase36E,
    nextRecommendation: safeForPhase36E
        ? analyzerLegacyTimelineCollectionReadModelNextRecommendation
        : analyzerLegacyTimelineCollectionReadModelFailureRecommendation,
  );
}

AnalyzerLegacyTimelineEntryReadModel _entry({
  int orderKey = 0,
  String idSuffix = '0',
  AnalyzerPrivateDraftBucket bucket =
      AnalyzerPrivateDraftBucket.positiveCandidate,
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
    privateDraftBucket: bucket,
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
    failureMessage: mappingSucceeded ? null : 'blocked fake entry',
    safeForPhase36D: safeForPhase36D,
    nextRecommendation: safeForPhase36D
        ? analyzerLegacyTimelineEntryReadModelNextRecommendation
        : analyzerLegacyTimelineEntryReadModelFailureRecommendation,
  );
}
