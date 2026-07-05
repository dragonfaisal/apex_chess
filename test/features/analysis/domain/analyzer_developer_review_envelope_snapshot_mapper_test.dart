import 'package:apex_chess/features/analysis/domain/analyzer_developer_review_envelope_snapshot.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_review_envelope_snapshot_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_legacy_review_envelope_read_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapLegacyReviewEnvelopeToDeveloperReviewEnvelopeSnapshot', () {
    test('snapshot mapping succeeds with valid fake envelope', () {
      final result = _map(_envelope());

      expect(result.mappingSucceeded, isTrue);
      expect(result.snapshotComputed, isTrue);
      expect(result.safeForPhase36I, isTrue);
      expect(result.sourceReviewEnvelopeComputed, isTrue);
      expect(result.sourceReviewEnvelopeIsDeveloperOnly, isTrue);
      expect(
        result.nextRecommendation,
        analyzerDeveloperReviewEnvelopeSnapshotNextRecommendation,
      );
    });

    test('snapshot copies safe summary counts from envelope', () {
      final result = _map(
        _envelope(
          sourceEntryCount: 4,
          totalPrivateEntries: 4,
          mappedEntryCount: 4,
          positiveCandidateCount: 1,
          neutralCandidateCount: 1,
          negativeCandidateCount: 1,
          unavailableCount: 1,
        ),
      );

      expect(result.mappingSucceeded, isTrue);
      expect(result.totalPrivateEntries, 4);
      expect(result.positiveCandidateCount, 1);
      expect(result.neutralCandidateCount, 1);
      expect(result.negativeCandidateCount, 1);
      expect(result.unavailableCount, 1);
      expect(result.snapshotCountsMatchSource, isTrue);
    });

    test('snapshot fails closed if envelope is public', () {
      final result = _map(_envelope(reviewEnvelopeIsPublic: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36I, isFalse);
      expect(result.sourceReviewEnvelopeIsPublic, isTrue);
    });

    test('snapshot fails closed if envelope is official', () {
      final result = _map(_envelope(reviewEnvelopeIsOfficial: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36I, isFalse);
      expect(result.sourceReviewEnvelopeIsOfficial, isTrue);
    });

    test('snapshot fails closed if envelope is product review', () {
      final result = _map(_envelope(reviewEnvelopeIsProductReview: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36I, isFalse);
      expect(result.sourceReviewEnvelopeIsProductReview, isTrue);
    });

    test('snapshot fails closed if envelope is saved analysis', () {
      final result = _map(_envelope(reviewEnvelopeIsSavedAnalysis: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36I, isFalse);
      expect(result.sourceReviewEnvelopeIsSavedAnalysis, isTrue);
    });

    test('snapshot fails closed if envelope is UI output', () {
      final result = _map(_envelope(reviewEnvelopeIsUiOutput: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36I, isFalse);
      expect(result.sourceReviewEnvelopeIsUiOutput, isTrue);
    });

    test('snapshot fails closed if envelope is archive/stats output', () {
      final result = _map(_envelope(reviewEnvelopeIsArchiveStatsOutput: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36I, isFalse);
      expect(result.sourceReviewEnvelopeIsArchiveStatsOutput, isTrue);
    });

    test('snapshot fails closed if envelope is full-game/product timeline', () {
      final fullGame = _map(_envelope(reviewEnvelopeIsFullGameAnalysis: true));
      final productTimeline = _map(
        _envelope(reviewEnvelopeIsProductTimeline: true),
      );

      expect(fullGame.mappingSucceeded, isFalse);
      expect(fullGame.safeForPhase36I, isFalse);
      expect(productTimeline.mappingSucceeded, isFalse);
      expect(productTimeline.safeForPhase36I, isFalse);
    });

    test('snapshot fails closed if envelope is not developer-only', () {
      final result = _map(_envelope(reviewEnvelopeIsDeveloperOnly: false));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36I, isFalse);
      expect(result.sourceReviewEnvelopeIsDeveloperOnly, isFalse);
    });

    test('snapshot fails closed if counts do not match', () {
      final result = _map(
        _envelope(
          reviewEnvelopeCountsMatchCollection: false,
          totalPrivateEntries: 2,
          mappedEntryCount: 1,
          positiveCandidateCount: 1,
        ),
      );

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36I, isFalse);
      expect(result.snapshotCountsMatchSource, isFalse);
      expect(result.failureMessage, contains('count mismatch'));
    });

    test('snapshot fails closed if public label is computed', () {
      final result = _map(_envelope(publicLabelComputed: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36I, isFalse);
      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('snapshot fails closed if official metric is computed', () {
      final result = _map(_envelope(officialCpLossComputed: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36I, isFalse);
      expect(result.snapshotContainsOfficialMetrics, isFalse);
      expect(result.officialCpLossComputed, isFalse);
    });

    test('snapshot remains read-only', () {
      final result = _validSnapshot();

      expect(result.snapshotIsReadOnly, isTrue);
      expect(result.savedAnalysisWritten, isFalse);
      expect(result.uiOutputProduced, isFalse);
      expect(result.archiveStatsTouched, isFalse);
    });

    test('snapshot remains developer-only', () {
      final result = _validSnapshot();

      expect(result.snapshotIsDeveloperOnly, isTrue);
      expect(result.snapshotIsPublic, isFalse);
      expect(result.snapshotIsProductReview, isFalse);
    });

    test('public label remains null', () {
      final result = _validSnapshot();

      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
      expect(result.snapshotContainsPublicLabels, isFalse);
    });

    test('official move quality remains null', () {
      final result = _validSnapshot();

      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
    });

    test('accuracy, ACPL, and Win% remain false', () {
      final result = _validSnapshot();

      expect(result.officialWinPercentComputed, isFalse);
      expect(result.accuracyComputed, isFalse);
      expect(result.acplComputed, isFalse);
      expect(result.classificationComputed, isFalse);
      expect(result.publicClassifierOutputComputed, isFalse);
    });

    test('public label strings are banned from exposed fields', () {
      final clean = _validSnapshot();
      final leaked = _map(
        _envelope(reviewEnvelopeId: 'phase36F:Brilliant:blocked'),
      );

      _expectForbiddenStringsAbsent(clean);
      _expectForbiddenStringsAbsent(leaked);
      expect(leaked.mappingSucceeded, isFalse);
      expect(leaked.safeForPhase36I, isFalse);
      expect(leaked.sourceReviewEnvelopeId, 'phase36H:blockedReviewEnvelope');
    });

    test('safeForPhase36I true only when all safety flags are clean', () {
      final clean = _validSnapshot();
      final publicLabel = _map(_envelope(publicLabelComputed: true));
      final officialWinPercent = _map(
        _envelope(officialWinPercentComputed: true),
      );
      final saved = _map(_envelope(savedAnalysisWritten: true));

      expect(clean.safeForPhase36I, isTrue);
      expect(publicLabel.safeForPhase36I, isFalse);
      expect(officialWinPercent.safeForPhase36I, isFalse);
      expect(saved.safeForPhase36I, isFalse);
    });
  });
}

AnalyzerDeveloperReviewEnvelopeSnapshot _map(
  AnalyzerLegacyReviewEnvelopeReadModel source,
) {
  return mapLegacyReviewEnvelopeToDeveloperReviewEnvelopeSnapshot(source);
}

AnalyzerDeveloperReviewEnvelopeSnapshot _validSnapshot() => _map(_envelope());

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
