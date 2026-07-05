import 'package:apex_chess/features/analysis/domain/analyzer_developer_review_envelope_snapshot.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_review_envelope_snapshot_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_envelope_read_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 36I developer review envelope snapshot safety golden cases', () {
    test('clean one-entry snapshot stays developer-only and read-only', () {
      final result = _map(_envelope());

      _expectCleanSnapshot(result);
      expect(result.sourceReviewEnvelopeComputed, isTrue);
      expect(result.sourceReviewEnvelopeIsDeveloperOnly, isTrue);
      expect(result.totalPrivateEntries, 1);
      expect(result.positiveCandidateCount, 1);
      expect(result.snapshotCountsMatchSource, isTrue);
      expect(_safeForPhase36J(result), isTrue);
    });

    test('clean mixed-count snapshot copies private counts from envelope', () {
      final source = _envelope(
        sourceEntryCount: 4,
        mappedEntryCount: 4,
        totalPrivateEntries: 4,
        positiveCandidateCount: 1,
        neutralCandidateCount: 1,
        negativeCandidateCount: 1,
        unavailableCount: 1,
      );
      final result = _map(source);

      _expectCleanSnapshot(result);
      expect(result.totalPrivateEntries, source.totalPrivateEntries);
      expect(result.positiveCandidateCount, source.positiveCandidateCount);
      expect(result.neutralCandidateCount, source.neutralCandidateCount);
      expect(result.negativeCandidateCount, source.negativeCandidateCount);
      expect(result.unavailableCount, source.unavailableCount);
      expect(_snapshotBucketCountSum(result), source.totalPrivateEntries);
      expect(result.snapshotCountsMatchSource, isTrue);
      expect(_safeForPhase36J(result), isTrue);
    });

    test('blocks unsafe envelope variants', () {
      final variants = <String, AnalyzerLegacyReviewEnvelopeReadModel>{
        'public': _envelope(reviewEnvelopeIsPublic: true),
        'official': _envelope(reviewEnvelopeIsOfficial: true),
        'product review': _envelope(reviewEnvelopeIsProductReview: true),
        'saved analysis': _envelope(reviewEnvelopeIsSavedAnalysis: true),
        'UI output': _envelope(reviewEnvelopeIsUiOutput: true),
        'archive/stats': _envelope(reviewEnvelopeIsArchiveStatsOutput: true),
        'full-game analysis': _envelope(reviewEnvelopeIsFullGameAnalysis: true),
        'product timeline': _envelope(reviewEnvelopeIsProductTimeline: true),
        'not developer-only': _envelope(reviewEnvelopeIsDeveloperOnly: false),
        'count match flag false': _envelope(
          reviewEnvelopeCountsMatchCollection: false,
        ),
      };

      for (final entry in variants.entries) {
        _expectBlockedSnapshot(_map(entry.value), reason: entry.key);
      }
    });

    test('blocks public and official computation variants', () {
      final variants = <String, AnalyzerLegacyReviewEnvelopeReadModel>{
        'publicLabelComputed': _envelope(publicLabelComputed: true),
        'publicLabel': _envelope(publicLabel: 'internal-public-label-leak'),
        'officialMoveQualityComputed': _envelope(
          officialMoveQualityComputed: true,
        ),
        'officialMoveQuality': _envelope(
          officialMoveQuality: 'internal-official-quality-leak',
        ),
        'officialCpLossComputed': _envelope(officialCpLossComputed: true),
        'officialWinPercentComputed': _envelope(
          officialWinPercentComputed: true,
        ),
        'accuracyComputed': _envelope(accuracyComputed: true),
        'acplComputed': _envelope(acplComputed: true),
        'classificationComputed': _envelope(classificationComputed: true),
        'publicClassifierOutputComputed': _envelope(
          publicClassifierOutputComputed: true,
        ),
      };

      for (final entry in variants.entries) {
        _expectBlockedSnapshot(_map(entry.value), reason: entry.key);
      }
    });

    test('blocks side-effect variants', () {
      final variants = <String, AnalyzerLegacyReviewEnvelopeReadModel>{
        'savedAnalysisWritten': _envelope(savedAnalysisWritten: true),
        'uiOutputProduced': _envelope(uiOutputProduced: true),
        'archiveStatsTouched': _envelope(archiveStatsTouched: true),
      };

      for (final entry in variants.entries) {
        _expectBlockedSnapshot(_map(entry.value), reason: entry.key);
      }
    });

    test('read-only hard ban holds for valid snapshots', () {
      final oneEntry = _map(_envelope());
      final mixed = _map(
        _envelope(
          sourceEntryCount: 4,
          mappedEntryCount: 4,
          totalPrivateEntries: 4,
          positiveCandidateCount: 1,
          neutralCandidateCount: 1,
          negativeCandidateCount: 1,
          unavailableCount: 1,
        ),
      );

      _expectCleanSnapshot(oneEntry);
      _expectCleanSnapshot(mixed);
      expect(oneEntry.snapshotIsReadOnly, isTrue);
      expect(mixed.snapshotIsReadOnly, isTrue);
      expect(oneEntry.savedAnalysisWritten, isFalse);
      expect(oneEntry.uiOutputProduced, isFalse);
      expect(oneEntry.archiveStatsTouched, isFalse);
      expect(mixed.savedAnalysisWritten, isFalse);
      expect(mixed.uiOutputProduced, isFalse);
      expect(mixed.archiveStatsTouched, isFalse);
    });

    test('public-label hard ban covers exposed snapshot fields', () {
      final clean = _map(_envelope());
      _expectForbiddenStringsAbsent(clean);

      for (final forbidden in _forbiddenPublicLabelStrings) {
        final leaked = _map(
          _envelope(reviewEnvelopeId: 'phase36F:$forbidden:blocked'),
        );

        _expectBlockedSnapshot(leaked, reason: forbidden);
        _expectForbiddenStringsAbsent(leaked);
      }
    });

    test('official metrics hard ban holds for valid snapshots', () {
      final oneEntry = _map(_envelope());
      final mixed = _map(
        _envelope(
          sourceEntryCount: 4,
          mappedEntryCount: 4,
          totalPrivateEntries: 4,
          positiveCandidateCount: 1,
          neutralCandidateCount: 1,
          negativeCandidateCount: 1,
          unavailableCount: 1,
        ),
      );

      _expectCleanSnapshot(oneEntry);
      _expectCleanSnapshot(mixed);
      _expectNoPublicOrOfficialOutput(oneEntry);
      _expectNoPublicOrOfficialOutput(mixed);
    });

    test('product-output hard ban holds for valid snapshots', () {
      final result = _map(_envelope());

      _expectCleanSnapshot(result);
      expect(result.snapshotIsPublic, isFalse);
      expect(result.snapshotIsProductReview, isFalse);
      expect(result.snapshotIsSavedAnalysis, isFalse);
      expect(result.snapshotIsOfficial, isFalse);
      expect(result.snapshotIsUiOutput, isFalse);
      expect(result.snapshotIsArchiveStatsOutput, isFalse);
      expect(result.snapshotIsFullGameAnalysis, isFalse);
      expect(result.snapshotIsProductTimeline, isFalse);
      expect(result.snapshotIsDeveloperOnly, isTrue);
      expect(result.snapshotIsReadOnly, isTrue);
    });
  });
}

AnalyzerDeveloperReviewEnvelopeSnapshot _map(
  AnalyzerLegacyReviewEnvelopeReadModel source,
) {
  return mapLegacyReviewEnvelopeToDeveloperReviewEnvelopeSnapshot(source);
}

void _expectCleanSnapshot(AnalyzerDeveloperReviewEnvelopeSnapshot result) {
  expect(result.mappingSucceeded, isTrue);
  expect(result.snapshotComputed, isTrue);
  expect(result.snapshotIsDeveloperOnly, isTrue);
  expect(result.snapshotIsReadOnly, isTrue);
  expect(result.snapshotCountsMatchSource, isTrue);
  expect(result.snapshotContainsPublicLabels, isFalse);
  expect(result.snapshotContainsOfficialMetrics, isFalse);
  expect(result.safeForPhase36I, isTrue);
  _expectNoPublicOrOfficialOutput(result);
  _expectNoProductOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectBlockedSnapshot(
  AnalyzerDeveloperReviewEnvelopeSnapshot result, {
  String? reason,
}) {
  expect(result.mappingSucceeded, isFalse, reason: reason);
  expect(result.snapshotComputed, isFalse, reason: reason);
  expect(result.safeForPhase36I, isFalse, reason: reason);
  expect(result.failureMessage, isNotNull, reason: reason);
  _expectNoPublicOrOfficialOutput(result);
  _expectNoProductOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectNoPublicOrOfficialOutput(
  AnalyzerDeveloperReviewEnvelopeSnapshot result,
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

void _expectNoProductOutput(AnalyzerDeveloperReviewEnvelopeSnapshot result) {
  expect(result.snapshotIsPublic, isFalse);
  expect(result.snapshotIsProductReview, isFalse);
  expect(result.snapshotIsSavedAnalysis, isFalse);
  expect(result.snapshotIsOfficial, isFalse);
  expect(result.snapshotIsUiOutput, isFalse);
  expect(result.snapshotIsArchiveStatsOutput, isFalse);
  expect(result.snapshotIsFullGameAnalysis, isFalse);
  expect(result.snapshotIsProductTimeline, isFalse);
}

void _expectForbiddenStringsAbsent(
  AnalyzerDeveloperReviewEnvelopeSnapshot result,
) {
  final exposed = <String?>{
    result.snapshotId,
    result.snapshotSource,
    result.sourceReviewEnvelopeId,
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

bool _safeForPhase36J(AnalyzerDeveloperReviewEnvelopeSnapshot result) {
  return result.mappingSucceeded &&
      result.safeForPhase36I &&
      result.snapshotComputed &&
      result.snapshotIsDeveloperOnly &&
      result.snapshotIsReadOnly &&
      result.snapshotCountsMatchSource &&
      !result.snapshotContainsPublicLabels &&
      !result.snapshotContainsOfficialMetrics &&
      !result.snapshotIsPublic &&
      !result.snapshotIsProductReview &&
      !result.snapshotIsSavedAnalysis &&
      !result.snapshotIsOfficial &&
      !result.snapshotIsUiOutput &&
      !result.snapshotIsArchiveStatsOutput &&
      !result.snapshotIsFullGameAnalysis &&
      !result.snapshotIsProductTimeline &&
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

int _snapshotBucketCountSum(AnalyzerDeveloperReviewEnvelopeSnapshot result) {
  return result.positiveCandidateCount +
      result.neutralCandidateCount +
      result.negativeCandidateCount +
      result.unavailableCount;
}

AnalyzerLegacyReviewEnvelopeReadModel _envelope({
  String reviewEnvelopeId = 'phase36F:phase36D:e2e4:e2e3:white:count1',
  String sourceTimelineCollectionId = 'phase36D:e2e4:e2e3:white:count1',
  String sourceReviewSummaryId = 'phase36E:phase36D:e2e4:e2e3:white:total1',
  bool sourceTimelineCollectionComputed = true,
  int sourceEntryCount = 1,
  int mappedEntryCount = 1,
  int blockedEntryCount = 0,
  bool timelineCollectionIsDeveloperOnly = true,
  bool timelineCollectionIsProductReview = false,
  bool timelineCollectionIsSavedAnalysis = false,
  bool timelineCollectionIsUiOutput = false,
  bool timelineCollectionIsArchiveStatsOutput = false,
  bool timelineCollectionIsFullGameAnalysis = false,
  bool timelineCollectionIsProductTimeline = false,
  bool sourceReviewSummaryComputed = true,
  int totalPrivateEntries = 1,
  int positiveCandidateCount = 1,
  int neutralCandidateCount = 0,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  bool reviewSummaryIsDeveloperOnly = true,
  bool reviewSummaryIsProductReview = false,
  bool reviewSummaryIsSavedAnalysis = false,
  bool reviewSummaryIsUiOutput = false,
  bool reviewSummaryIsArchiveStatsOutput = false,
  bool reviewSummaryIsFullGameAnalysis = false,
  bool reviewSummaryIsProductTimeline = false,
  bool reviewEnvelopeComputed = true,
  bool reviewEnvelopeContainsTimelineCollection = true,
  bool reviewEnvelopeContainsReviewSummary = true,
  bool reviewEnvelopeCountsMatchCollection = true,
  bool reviewEnvelopeIsPublic = false,
  bool reviewEnvelopeIsProductReview = false,
  bool reviewEnvelopeIsSavedAnalysis = false,
  bool reviewEnvelopeIsOfficial = false,
  bool reviewEnvelopeIsUiOutput = false,
  bool reviewEnvelopeIsArchiveStatsOutput = false,
  bool reviewEnvelopeIsFullGameAnalysis = false,
  bool reviewEnvelopeIsProductTimeline = false,
  bool reviewEnvelopeIsDeveloperOnly = true,
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
  bool safeForPhase36G = true,
}) {
  return AnalyzerLegacyReviewEnvelopeReadModel(
    reviewEnvelopeId: reviewEnvelopeId,
    sourceTimelineCollectionId: sourceTimelineCollectionId,
    sourceReviewSummaryId: sourceReviewSummaryId,
    reviewEnvelopeSource: analyzerLegacyReviewEnvelopeReadModelSource,
    reviewEnvelopeVersion: analyzerLegacyReviewEnvelopeReadModelVersion,
    sourceTimelineCollectionComputed: sourceTimelineCollectionComputed,
    sourceEntryCount: sourceEntryCount,
    mappedEntryCount: mappedEntryCount,
    blockedEntryCount: blockedEntryCount,
    timelineCollectionIsDeveloperOnly: timelineCollectionIsDeveloperOnly,
    timelineCollectionIsProductReview: timelineCollectionIsProductReview,
    timelineCollectionIsSavedAnalysis: timelineCollectionIsSavedAnalysis,
    timelineCollectionIsUiOutput: timelineCollectionIsUiOutput,
    timelineCollectionIsArchiveStatsOutput:
        timelineCollectionIsArchiveStatsOutput,
    timelineCollectionIsFullGameAnalysis: timelineCollectionIsFullGameAnalysis,
    timelineCollectionIsProductTimeline: timelineCollectionIsProductTimeline,
    sourceReviewSummaryComputed: sourceReviewSummaryComputed,
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    reviewSummaryIsDeveloperOnly: reviewSummaryIsDeveloperOnly,
    reviewSummaryIsProductReview: reviewSummaryIsProductReview,
    reviewSummaryIsSavedAnalysis: reviewSummaryIsSavedAnalysis,
    reviewSummaryIsUiOutput: reviewSummaryIsUiOutput,
    reviewSummaryIsArchiveStatsOutput: reviewSummaryIsArchiveStatsOutput,
    reviewSummaryIsFullGameAnalysis: reviewSummaryIsFullGameAnalysis,
    reviewSummaryIsProductTimeline: reviewSummaryIsProductTimeline,
    reviewEnvelopeComputed: reviewEnvelopeComputed,
    reviewEnvelopeContainsTimelineCollection:
        reviewEnvelopeContainsTimelineCollection,
    reviewEnvelopeContainsReviewSummary: reviewEnvelopeContainsReviewSummary,
    reviewEnvelopeCountsMatchCollection: reviewEnvelopeCountsMatchCollection,
    reviewEnvelopeIsPublic: reviewEnvelopeIsPublic,
    reviewEnvelopeIsProductReview: reviewEnvelopeIsProductReview,
    reviewEnvelopeIsSavedAnalysis: reviewEnvelopeIsSavedAnalysis,
    reviewEnvelopeIsOfficial: reviewEnvelopeIsOfficial,
    reviewEnvelopeIsUiOutput: reviewEnvelopeIsUiOutput,
    reviewEnvelopeIsArchiveStatsOutput: reviewEnvelopeIsArchiveStatsOutput,
    reviewEnvelopeIsFullGameAnalysis: reviewEnvelopeIsFullGameAnalysis,
    reviewEnvelopeIsProductTimeline: reviewEnvelopeIsProductTimeline,
    reviewEnvelopeIsDeveloperOnly: reviewEnvelopeIsDeveloperOnly,
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
    failureMessage: mappingSucceeded ? null : 'blocked fake envelope',
    safeForPhase36G: safeForPhase36G,
    nextRecommendation: safeForPhase36G
        ? analyzerLegacyReviewEnvelopeReadModelNextRecommendation
        : analyzerLegacyReviewEnvelopeReadModelFailureRecommendation,
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
