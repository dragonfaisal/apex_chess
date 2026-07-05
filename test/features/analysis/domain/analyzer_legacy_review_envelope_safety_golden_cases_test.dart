import 'package:apex_chess/features/analysis/domain/analyzer_before_after_raw_eval.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_envelope_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_envelope_read_model_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_summary_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_collection_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_timeline_entry_read_model.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_private_draft_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 36G review envelope safety golden cases', () {
    test('clean one-entry envelope stays developer-only and safe', () {
      final collection = _collection();
      final summary = _summaryFor(collection);
      final result = _map(collection, summary);

      _expectCleanEnvelope(result);
      expect(result.sourceEntryCount, 1);
      expect(result.mappedEntryCount, 1);
      expect(result.totalPrivateEntries, 1);
      expect(result.positiveCandidateCount, 1);
      expect(_safeForPhase36H(result), isTrue);
    });

    test('clean mixed-bucket envelope preserves private bucket counts', () {
      final collection = _collection(
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
      );
      final summary = _summaryFor(
        collection,
        totalPrivateEntries: 4,
        positiveCandidateCount: 1,
        neutralCandidateCount: 1,
        negativeCandidateCount: 1,
        unavailableCount: 1,
      );
      final result = _map(collection, summary);

      _expectCleanEnvelope(result);
      expect(result.totalPrivateEntries, 4);
      expect(result.positiveCandidateCount, 1);
      expect(result.neutralCandidateCount, 1);
      expect(result.negativeCandidateCount, 1);
      expect(result.unavailableCount, 1);
      expect(_bucketCountSum(result), result.totalPrivateEntries);
      expect(_safeForPhase36H(result), isTrue);
    });

    test('blocks source identity mismatch with exact failure reason', () {
      final collection = _collection();
      final result = _map(
        collection,
        _summaryFor(collection, sourceTimelineCollectionId: 'phase36D:other'),
      );

      _expectBlocked(result);
      expect(result.failureMessage, contains('source ID mismatch'));
    });

    test('blocks total count mismatch without public or official output', () {
      final collection = _collection();
      final result = _map(
        collection,
        _summaryFor(
          collection,
          totalPrivateEntries: 2,
          positiveCandidateCount: 2,
        ),
      );

      _expectBlocked(result);
      expect(result.reviewEnvelopeCountsMatchCollection, isFalse);
      expect(result.failureMessage, contains('collection count mismatch'));
      _expectNoPublicOrOfficialOutput(result);
    });

    test('blocks bucket count mismatch without public or official output', () {
      final collection = _collection();
      final result = _map(
        collection,
        _summaryFor(
          collection,
          totalPrivateEntries: 1,
          positiveCandidateCount: 2,
        ),
      );

      _expectBlocked(result);
      expect(result.reviewEnvelopeCountsMatchCollection, isFalse);
      expect(result.failureMessage, contains('private bucket count mismatch'));
      _expectNoPublicOrOfficialOutput(result);
    });

    test('blocks unsafe collection variants', () {
      final variants = <String, AnalyzerLegacyTimelineCollectionReadModel>{
        'public': _collection(timelineCollectionIsPublic: true),
        'official': _collection(timelineCollectionIsOfficial: true),
        'product review': _collection(timelineCollectionIsProductReview: true),
        'saved analysis': _collection(timelineCollectionIsSavedAnalysis: true),
        'UI output': _collection(timelineCollectionIsUiOutput: true),
        'archive/stats': _collection(
          timelineCollectionIsArchiveStatsOutput: true,
        ),
        'full-game analysis': _collection(
          timelineCollectionIsFullGameAnalysis: true,
        ),
        'product timeline': _collection(
          timelineCollectionIsProductTimeline: true,
        ),
        'not developer-only': _collection(
          timelineCollectionIsDeveloperOnly: false,
        ),
        'unsafe entries': _collection(allEntriesSafe: false),
        'public label leakage': _collection(
          publicLabelComputed: true,
          publicLabel: 'Brilliant',
        ),
      };

      for (final entry in variants.entries) {
        final result = _map(entry.value, _summaryFor(entry.value));

        _expectBlocked(result, reason: entry.key);
      }
    });

    test('blocks unsafe summary variants', () {
      final collection = _collection();
      final variants = <String, AnalyzerLegacyReviewSummaryReadModel>{
        'public': _summaryFor(collection, reviewSummaryIsPublic: true),
        'official': _summaryFor(collection, reviewSummaryIsOfficial: true),
        'product review': _summaryFor(
          collection,
          reviewSummaryIsProductReview: true,
        ),
        'saved analysis': _summaryFor(
          collection,
          reviewSummaryIsSavedAnalysis: true,
        ),
        'UI output': _summaryFor(collection, reviewSummaryIsUiOutput: true),
        'archive/stats': _summaryFor(
          collection,
          reviewSummaryIsArchiveStatsOutput: true,
        ),
        'full-game analysis': _summaryFor(
          collection,
          reviewSummaryIsFullGameAnalysis: true,
        ),
        'product timeline': _summaryFor(
          collection,
          reviewSummaryIsProductTimeline: true,
        ),
        'not developer-only': _summaryFor(
          collection,
          reviewSummaryIsDeveloperOnly: false,
        ),
        'public label leakage': _summaryFor(
          collection,
          publicLabelComputed: true,
          publicLabel: 'Brilliant',
        ),
        'official metrics': _summaryFor(
          collection,
          officialCpLossComputed: true,
        ),
        'Win% computed': _summaryFor(
          collection,
          officialWinPercentComputed: true,
        ),
        'accuracy computed': _summaryFor(collection, accuracyComputed: true),
        'ACPL computed': _summaryFor(collection, acplComputed: true),
      };

      for (final entry in variants.entries) {
        final result = _map(collection, entry.value);

        _expectBlocked(result, reason: entry.key);
      }
    });

    test('public-label hard ban covers exposed envelope and source fields', () {
      final clean = _map(_collection(), _summaryFor(_collection()));
      final collectionLeak = _collection(
        timelineCollectionId: 'phase36D:Brilliant:count1',
      );
      final collectionLeakResult = _map(
        collectionLeak,
        _summaryFor(collectionLeak),
      );
      final summaryLeakCollection = _collection();
      final summaryLeakResult = _map(
        summaryLeakCollection,
        _summaryFor(
          summaryLeakCollection,
          reviewSummaryId: 'phase36E:Great:total1',
        ),
      );

      _expectForbiddenStringsAbsent(clean);
      _expectForbiddenStringsAbsent(collectionLeakResult);
      _expectForbiddenStringsAbsent(summaryLeakResult);
      _expectBlocked(collectionLeakResult);
      _expectBlocked(summaryLeakResult);
    });

    test('official metrics hard ban holds for valid envelopes', () {
      final oneEntry = _map(_collection(), _summaryFor(_collection()));
      final mixedCollection = _collection(
        entries: [
          _entry(bucket: AnalyzerPrivateDraftBucket.positiveCandidate),
          _entry(
            idSuffix: '1',
            orderKey: 1,
            bucket: AnalyzerPrivateDraftBucket.neutralCandidate,
          ),
        ],
      );
      final mixed = _map(
        mixedCollection,
        _summaryFor(
          mixedCollection,
          totalPrivateEntries: 2,
          positiveCandidateCount: 1,
          neutralCandidateCount: 1,
        ),
      );

      _expectCleanEnvelope(oneEntry);
      _expectCleanEnvelope(mixed);
      _expectNoPublicOrOfficialOutput(oneEntry);
      _expectNoPublicOrOfficialOutput(mixed);
    });

    test('product-output hard ban holds for valid envelopes', () {
      final result = _map(_collection(), _summaryFor(_collection()));

      _expectCleanEnvelope(result);
      expect(result.reviewEnvelopeIsPublic, isFalse);
      expect(result.reviewEnvelopeIsProductReview, isFalse);
      expect(result.reviewEnvelopeIsSavedAnalysis, isFalse);
      expect(result.reviewEnvelopeIsOfficial, isFalse);
      expect(result.reviewEnvelopeIsUiOutput, isFalse);
      expect(result.reviewEnvelopeIsArchiveStatsOutput, isFalse);
      expect(result.reviewEnvelopeIsFullGameAnalysis, isFalse);
      expect(result.reviewEnvelopeIsProductTimeline, isFalse);
      expect(result.reviewEnvelopeIsDeveloperOnly, isTrue);
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

void _expectCleanEnvelope(AnalyzerLegacyReviewEnvelopeReadModel result) {
  expect(result.mappingSucceeded, isTrue);
  expect(result.reviewEnvelopeComputed, isTrue);
  expect(result.reviewEnvelopeContainsTimelineCollection, isTrue);
  expect(result.reviewEnvelopeContainsReviewSummary, isTrue);
  expect(result.reviewEnvelopeCountsMatchCollection, isTrue);
  expect(result.reviewEnvelopeIsDeveloperOnly, isTrue);
  expect(result.safeForPhase36G, isTrue);
  _expectNoPublicOrOfficialOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectBlocked(
  AnalyzerLegacyReviewEnvelopeReadModel result, {
  String? reason,
}) {
  expect(result.mappingSucceeded, isFalse, reason: reason);
  expect(result.reviewEnvelopeComputed, isFalse, reason: reason);
  expect(result.safeForPhase36G, isFalse, reason: reason);
  expect(result.failureMessage, isNotNull, reason: reason);
  _expectNoPublicOrOfficialOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectNoPublicOrOfficialOutput(
  AnalyzerLegacyReviewEnvelopeReadModel result,
) {
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
  expect(result.savedAnalysisWritten, isFalse);
  expect(result.uiOutputProduced, isFalse);
  expect(result.archiveStatsTouched, isFalse);
}

void _expectForbiddenStringsAbsent(
  AnalyzerLegacyReviewEnvelopeReadModel result,
) {
  final exposed = <String?>{
    result.reviewEnvelopeId,
    result.reviewEnvelopeSource,
    result.sourceTimelineCollectionId,
    result.sourceReviewSummaryId,
    result.publicLabel,
    result.officialMoveQuality,
  }.whereType<String>();

  for (final value in exposed) {
    for (final forbidden in _forbiddenPublicLabelStrings) {
      expect(value.contains(forbidden), isFalse, reason: value);
    }
  }
}

bool _safeForPhase36H(AnalyzerLegacyReviewEnvelopeReadModel result) {
  return result.mappingSucceeded &&
      result.safeForPhase36G &&
      result.reviewEnvelopeComputed &&
      result.reviewEnvelopeIsDeveloperOnly &&
      !result.reviewEnvelopeIsPublic &&
      !result.reviewEnvelopeIsProductReview &&
      !result.reviewEnvelopeIsSavedAnalysis &&
      !result.reviewEnvelopeIsOfficial &&
      !result.reviewEnvelopeIsUiOutput &&
      !result.reviewEnvelopeIsArchiveStatsOutput &&
      !result.reviewEnvelopeIsFullGameAnalysis &&
      !result.reviewEnvelopeIsProductTimeline &&
      !result.publicLabelComputed &&
      result.publicLabel == null &&
      !result.officialMoveQualityComputed &&
      result.officialMoveQuality == null &&
      !result.officialCpLossComputed &&
      !result.officialWinPercentComputed &&
      !result.accuracyComputed &&
      !result.acplComputed &&
      !result.classificationComputed &&
      !result.publicClassifierOutputComputed &&
      !result.savedAnalysisWritten &&
      !result.uiOutputProduced &&
      !result.archiveStatsTouched;
}

int _bucketCountSum(AnalyzerLegacyReviewEnvelopeReadModel result) {
  return result.positiveCandidateCount +
      result.neutralCandidateCount +
      result.negativeCandidateCount +
      result.unavailableCount;
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

const _forbiddenPublicLabelStrings = {
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
