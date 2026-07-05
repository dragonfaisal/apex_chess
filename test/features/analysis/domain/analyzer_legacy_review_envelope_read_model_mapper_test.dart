import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_envelope_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_envelope_read_model_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_summary_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_collection_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapLegacyCollectionAndSummaryToReviewEnvelopeReadModel', () {
    test('maps valid collection and summary', () {
      final collection = _collection();
      final summary = _summaryFor(collection);
      final result = _map(collection, summary);

      expect(result.mappingSucceeded, isTrue);
      expect(result.reviewEnvelopeComputed, isTrue);
      expect(result.safeForPhase36G, isTrue);
      expect(result.reviewEnvelopeContainsTimelineCollection, isTrue);
      expect(result.reviewEnvelopeContainsReviewSummary, isTrue);
      expect(result.reviewEnvelopeCountsMatchCollection, isTrue);
      expect(
        result.sourceTimelineCollectionId,
        collection.timelineCollectionId,
      );
      expect(result.sourceReviewSummaryId, summary.reviewSummaryId);
      expect(result.totalPrivateEntries, collection.mappedEntryCount);
      expect(
        result.nextRecommendation,
        analyzerLegacyReviewEnvelopeReadModelNextRecommendation,
      );
    });

    test('fails closed if collection is unsafe', () {
      final collection = _collection(mappingSucceeded: false);
      final result = _map(collection, _summaryFor(collection));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36G, isFalse);
      expect(result.reviewEnvelopeContainsTimelineCollection, isFalse);
    });

    test('fails closed if summary is unsafe', () {
      final collection = _collection();
      final result = _map(
        collection,
        _summaryFor(collection, mappingSucceeded: false),
      );

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36G, isFalse);
      expect(result.reviewEnvelopeContainsReviewSummary, isFalse);
    });

    test('fails closed if source IDs do not match', () {
      final collection = _collection();
      final result = _map(
        collection,
        _summaryFor(collection, sourceTimelineCollectionId: 'phase36D:other'),
      );

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36G, isFalse);
      expect(result.failureMessage, contains('source ID mismatch'));
    });

    test(
      'fails closed if totalPrivateEntries does not match mappedEntryCount',
      () {
        final collection = _collection();
        final result = _map(
          collection,
          _summaryFor(
            collection,
            totalPrivateEntries: 2,
            positiveCandidateCount: 2,
          ),
        );

        expect(result.mappingSucceeded, isFalse);
        expect(result.safeForPhase36G, isFalse);
        expect(result.reviewEnvelopeCountsMatchCollection, isFalse);
        expect(result.failureMessage, contains('collection count mismatch'));
      },
    );

    test('fails closed if bucket counts do not sum to totalPrivateEntries', () {
      final collection = _collection();
      final result = _map(
        collection,
        _summaryFor(
          collection,
          totalPrivateEntries: 1,
          positiveCandidateCount: 2,
        ),
      );

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36G, isFalse);
      expect(result.reviewEnvelopeCountsMatchCollection, isFalse);
      expect(result.failureMessage, contains('private bucket count mismatch'));
    });

    test('fails closed for product-review source', () {
      final collection = _collection(timelineCollectionIsProductReview: true);
      final result = _map(collection, _summaryFor(collection));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36G, isFalse);
    });

    test('fails closed for saved-analysis source', () {
      final collection = _collection(timelineCollectionIsSavedAnalysis: true);
      final result = _map(collection, _summaryFor(collection));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36G, isFalse);
    });

    test('fails closed for UI-output source', () {
      final collection = _collection(timelineCollectionIsUiOutput: true);
      final result = _map(collection, _summaryFor(collection));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36G, isFalse);
    });

    test('fails closed for archive/stats source', () {
      final collection = _collection(
        timelineCollectionIsArchiveStatsOutput: true,
      );
      final result = _map(collection, _summaryFor(collection));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36G, isFalse);
    });

    test('fails closed for full-game or product-timeline source', () {
      final fullGame = _collection(timelineCollectionIsFullGameAnalysis: true);
      final productTimeline = _collection(
        timelineCollectionIsProductTimeline: true,
      );
      final fullGameResult = _map(fullGame, _summaryFor(fullGame));
      final productTimelineResult = _map(
        productTimeline,
        _summaryFor(productTimeline),
      );

      expect(fullGameResult.mappingSucceeded, isFalse);
      expect(fullGameResult.safeForPhase36G, isFalse);
      expect(productTimelineResult.mappingSucceeded, isFalse);
      expect(productTimelineResult.safeForPhase36G, isFalse);
    });

    test('envelope remains developer-only', () {
      final result = _validResult();

      expect(result.reviewEnvelopeIsDeveloperOnly, isTrue);
      expect(result.reviewEnvelopeIsPublic, isFalse);
    });

    test('envelope is not product review', () {
      final result = _validResult();

      expect(result.reviewEnvelopeIsProductReview, isFalse);
    });

    test('envelope is not saved analysis', () {
      final result = _validResult();

      expect(result.reviewEnvelopeIsSavedAnalysis, isFalse);
      expect(result.savedAnalysisWritten, isFalse);
    });

    test('envelope is not UI output', () {
      final result = _validResult();

      expect(result.reviewEnvelopeIsUiOutput, isFalse);
      expect(result.uiOutputProduced, isFalse);
    });

    test('envelope is not archive or stats output', () {
      final result = _validResult();

      expect(result.reviewEnvelopeIsArchiveStatsOutput, isFalse);
      expect(result.archiveStatsTouched, isFalse);
    });

    test('keeps public label null', () {
      final result = _validResult();

      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('keeps official move quality null', () {
      final result = _validResult();

      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
    });

    test('keeps accuracy, ACPL, and Win% false', () {
      final result = _validResult();

      expect(result.officialWinPercentComputed, isFalse);
      expect(result.accuracyComputed, isFalse);
      expect(result.acplComputed, isFalse);
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
      final result = _validResult();
      final exposed = {
        result.publicLabel,
        result.officialMoveQuality,
        result.reviewEnvelopeId,
        result.reviewEnvelopeSource,
        result.sourceTimelineCollectionId,
        result.sourceReviewSummaryId,
      }.whereType<String>().toSet();

      expect(exposed.intersection(forbidden), isEmpty);
    });

    test(
      'fails closed and sanitizes source IDs on public label string leak',
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
        final collection = _collection(
          timelineCollectionId: 'phase36D:Brilliant:count1',
        );
        final result = _map(collection, _summaryFor(collection));
        final exposed = {
          result.publicLabel,
          result.officialMoveQuality,
          result.reviewEnvelopeId,
          result.reviewEnvelopeSource,
          result.sourceTimelineCollectionId,
          result.sourceReviewSummaryId,
        }.whereType<String>().toSet();

        expect(result.mappingSucceeded, isFalse);
        expect(result.safeForPhase36G, isFalse);
        expect(exposed.intersection(forbidden), isEmpty);
      },
    );

    test('safeForPhase36G is true only when all safety flags are clean', () {
      final clean = _validResult();
      final officialWinPercentCollection = _collection(
        officialWinPercentComputed: true,
      );
      final accuracySummaryCollection = _collection();
      final acplSummaryCollection = _collection();

      final officialWinPercent = _map(
        officialWinPercentCollection,
        _summaryFor(officialWinPercentCollection),
      );
      final accuracy = _map(
        accuracySummaryCollection,
        _summaryFor(accuracySummaryCollection, accuracyComputed: true),
      );
      final acpl = _map(
        acplSummaryCollection,
        _summaryFor(acplSummaryCollection, acplComputed: true),
      );

      expect(clean.safeForPhase36G, isTrue);
      expect(officialWinPercent.safeForPhase36G, isFalse);
      expect(accuracy.safeForPhase36G, isFalse);
      expect(acpl.safeForPhase36G, isFalse);
    });
  });
}

AnalyzerLegacyReviewEnvelopeReadModel _map(
  AnalyzerLegacyTimelineCollectionReadModel collection,
  AnalyzerLegacyReviewSummaryReadModel summary,
) {
  return mapLegacyCollectionAndSummaryToReviewEnvelopeReadModel(
    collection: collection,
    summary: summary,
  );
}

AnalyzerLegacyReviewEnvelopeReadModel _validResult() {
  final collection = _collection();
  return _map(collection, _summaryFor(collection));
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
  bool allEntriesSafe = true,
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
    allEntriesSafe: allEntriesSafe,
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

AnalyzerLegacyReviewSummaryReadModel _summaryFor(
  AnalyzerLegacyTimelineCollectionReadModel collection, {
  String? reviewSummaryId,
  String? sourceTimelineCollectionId,
  bool mappingSucceeded = true,
  bool safeForPhase36F = true,
  bool reviewSummaryComputed = true,
  int? totalPrivateEntries,
  int? positiveCandidateCount,
  int neutralCandidateCount = 0,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  bool sourceTimelineCollectionComputed = true,
  bool sourceTimelineCollectionIsDeveloperOnly = true,
  bool sourceTimelineCollectionIsProductReview = false,
  bool sourceTimelineCollectionIsSavedAnalysis = false,
  bool sourceTimelineCollectionIsUiOutput = false,
  bool sourceTimelineCollectionIsArchiveStatsOutput = false,
  bool sourceTimelineCollectionIsFullGameAnalysis = false,
  bool sourceTimelineCollectionIsProductTimeline = false,
  bool allEntriesSafe = true,
  bool allEntriesSingleMoveOnly = true,
  bool allEntriesPrivateSingleMoveDraft = true,
  bool reviewSummaryIsPublic = false,
  bool reviewSummaryIsProductReview = false,
  bool reviewSummaryIsSavedAnalysis = false,
  bool reviewSummaryIsOfficial = false,
  bool reviewSummaryIsUiOutput = false,
  bool reviewSummaryIsArchiveStatsOutput = false,
  bool reviewSummaryIsFullGameAnalysis = false,
  bool reviewSummaryIsProductTimeline = false,
  bool reviewSummaryIsDeveloperOnly = true,
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
  final total = totalPrivateEntries ?? collection.mappedEntryCount;
  final positive = positiveCandidateCount ?? total;

  return AnalyzerLegacyReviewSummaryReadModel(
    reviewSummaryId:
        reviewSummaryId ??
        'phase36E:${collection.timelineCollectionId}:total$total',
    sourceTimelineCollectionId:
        sourceTimelineCollectionId ?? collection.timelineCollectionId,
    reviewSummarySource: analyzerLegacyReviewSummaryReadModelSource,
    reviewSummaryVersion: analyzerLegacyReviewSummaryReadModelVersion,
    sourceEntryCount: collection.sourceEntryCount,
    mappedEntryCount: collection.mappedEntryCount,
    blockedEntryCount: collection.blockedEntryCount,
    sourceTimelineCollectionComputed: sourceTimelineCollectionComputed,
    sourceTimelineCollectionIsDeveloperOnly:
        sourceTimelineCollectionIsDeveloperOnly,
    sourceTimelineCollectionIsProductReview:
        sourceTimelineCollectionIsProductReview,
    sourceTimelineCollectionIsSavedAnalysis:
        sourceTimelineCollectionIsSavedAnalysis,
    sourceTimelineCollectionIsUiOutput: sourceTimelineCollectionIsUiOutput,
    sourceTimelineCollectionIsArchiveStatsOutput:
        sourceTimelineCollectionIsArchiveStatsOutput,
    sourceTimelineCollectionIsFullGameAnalysis:
        sourceTimelineCollectionIsFullGameAnalysis,
    sourceTimelineCollectionIsProductTimeline:
        sourceTimelineCollectionIsProductTimeline,
    reviewSummaryComputed: reviewSummaryComputed,
    totalPrivateEntries: total,
    positiveCandidateCount: positive,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    allEntriesSafe: allEntriesSafe,
    allEntriesSingleMoveOnly: allEntriesSingleMoveOnly,
    allEntriesPrivateSingleMoveDraft: allEntriesPrivateSingleMoveDraft,
    reviewSummaryIsPublic: reviewSummaryIsPublic,
    reviewSummaryIsProductReview: reviewSummaryIsProductReview,
    reviewSummaryIsSavedAnalysis: reviewSummaryIsSavedAnalysis,
    reviewSummaryIsOfficial: reviewSummaryIsOfficial,
    reviewSummaryIsUiOutput: reviewSummaryIsUiOutput,
    reviewSummaryIsArchiveStatsOutput: reviewSummaryIsArchiveStatsOutput,
    reviewSummaryIsFullGameAnalysis: reviewSummaryIsFullGameAnalysis,
    reviewSummaryIsProductTimeline: reviewSummaryIsProductTimeline,
    reviewSummaryIsDeveloperOnly: reviewSummaryIsDeveloperOnly,
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
    failureMessage: mappingSucceeded ? null : 'blocked fake summary',
    safeForPhase36F: safeForPhase36F,
    nextRecommendation: safeForPhase36F
        ? analyzerLegacyReviewSummaryReadModelNextRecommendation
        : analyzerLegacyReviewSummaryReadModelFailureRecommendation,
  );
}

AnalyzerLegacyTimelineEntryReadModel _entry({
  int orderKey = 0,
  String idSuffix = '0',
  AnalyzerPrivateDraftBucket bucket =
      AnalyzerPrivateDraftBucket.positiveCandidate,
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
    timelineEntryComputed: true,
    timelineEntryKind: AnalyzerLegacyTimelineEntryKind.privateSingleMoveDraft,
    timelineEntryOrderKey: orderKey,
    timelineEntryIsSingleMoveOnly: true,
    timelineEntryIsFullGameTimeline: false,
    timelineEntryIsProductTimeline: false,
    timelineEntryIsUiOutput: false,
    privateDraftBucket: bucket,
    privateDraftReasonCode:
        AnalyzerPrivateDraftReasonCode.improvedButCandidateSlightlyBetter,
    privateDraftConfidenceTier: AnalyzerPrivateDraftConfidenceTier.low,
    sourceReadModelComputed: true,
    sourceReadModelIsPublic: false,
    sourceReadModelIsProductReview: false,
    sourceReadModelIsSavedAnalysis: false,
    sourceReadModelIsOfficial: false,
    sourceReadModelIsUiOutput: false,
    sourceReadModelIsArchiveStatsOutput: false,
    publicLabelComputed: false,
    publicLabel: null,
    officialMoveQualityComputed: false,
    officialMoveQuality: null,
    officialCpLossComputed: false,
    officialWinPercentComputed: false,
    accuracyComputed: false,
    acplComputed: false,
    classificationComputed: false,
    publicClassifierOutputComputed: false,
    savedAnalysisWritten: false,
    uiOutputProduced: false,
    archiveStatsTouched: false,
    mappingSucceeded: true,
    failureMessage: null,
    safeForPhase36D: true,
    nextRecommendation: analyzerLegacyTimelineEntryReadModelNextRecommendation,
  );
}
