import 'package:apex_chess/features/analysis/domain/analyzer_developer_review_envelope_snapshot.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_export_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_export_contract_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapDeveloperReviewEnvelopeSnapshotToExportContract', () {
    test('export mapping succeeds with valid fake snapshot', () {
      final result = _map(_snapshot());

      expect(result.mappingSucceeded, isTrue);
      expect(result.exportContractComputed, isTrue);
      expect(result.safeForPhase36K, isTrue);
      expect(
        result.nextRecommendation,
        analyzerDeveloperSnapshotExportContractNextRecommendation,
      );
    });

    test('export copies safe IDs from snapshot', () {
      final source = _snapshot(
        snapshotId: 'phase36H:phase36F:safe:snapshot',
        sourceReviewEnvelopeId: 'phase36F:safe-envelope',
        sourceTimelineCollectionId: 'phase36D:safe-collection',
        sourceReviewSummaryId: 'phase36E:safe-summary',
      );
      final result = _map(source);

      expect(result.mappingSucceeded, isTrue);
      expect(result.sourceSnapshotId, source.snapshotId);
      expect(result.sourceReviewEnvelopeId, source.sourceReviewEnvelopeId);
      expect(
        result.sourceTimelineCollectionId,
        source.sourceTimelineCollectionId,
      );
      expect(result.sourceReviewSummaryId, source.sourceReviewSummaryId);
    });

    test('export copies safe private counts from snapshot', () {
      final source = _snapshot(
        totalPrivateEntries: 4,
        positiveCandidateCount: 1,
        neutralCandidateCount: 1,
        negativeCandidateCount: 1,
        unavailableCount: 1,
      );
      final result = _map(source);

      expect(result.mappingSucceeded, isTrue);
      expect(result.totalPrivateEntries, 4);
      expect(result.positiveCandidateCount, 1);
      expect(result.neutralCandidateCount, 1);
      expect(result.negativeCandidateCount, 1);
      expect(result.unavailableCount, 1);
      expect(result.payloadCountsMatchSnapshot, isTrue);
    });

    test('export fails closed if snapshot is public', () {
      final result = _map(_snapshot(snapshotIsPublic: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.sourceSnapshotIsPublic, isTrue);
    });

    test('export fails closed if snapshot is official', () {
      final result = _map(_snapshot(snapshotIsOfficial: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.sourceSnapshotIsOfficial, isTrue);
    });

    test('export fails closed if snapshot is product review', () {
      final result = _map(_snapshot(snapshotIsProductReview: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.sourceSnapshotIsProductReview, isTrue);
    });

    test('export fails closed if snapshot is saved analysis', () {
      final result = _map(_snapshot(snapshotIsSavedAnalysis: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.sourceSnapshotIsSavedAnalysis, isTrue);
    });

    test('export fails closed if snapshot is UI output', () {
      final result = _map(_snapshot(snapshotIsUiOutput: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.sourceSnapshotIsUiOutput, isTrue);
    });

    test('export fails closed if snapshot is archive/stats output', () {
      final result = _map(_snapshot(snapshotIsArchiveStatsOutput: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.sourceSnapshotIsArchiveStatsOutput, isTrue);
    });

    test('export fails closed if snapshot is full-game/product timeline', () {
      final fullGame = _map(_snapshot(snapshotIsFullGameAnalysis: true));
      final productTimeline = _map(_snapshot(snapshotIsProductTimeline: true));

      expect(fullGame.mappingSucceeded, isFalse);
      expect(fullGame.safeForPhase36K, isFalse);
      expect(productTimeline.mappingSucceeded, isFalse);
      expect(productTimeline.safeForPhase36K, isFalse);
    });

    test('export fails closed if snapshot is not developer-only', () {
      final result = _map(_snapshot(snapshotIsDeveloperOnly: false));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.sourceSnapshotIsDeveloperOnly, isFalse);
    });

    test('export fails closed if snapshot is not read-only', () {
      final result = _map(_snapshot(snapshotIsReadOnly: false));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.sourceSnapshotIsReadOnly, isFalse);
    });

    test('export fails closed if snapshot count match flag is false', () {
      final result = _map(_snapshot(snapshotCountsMatchSource: false));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.payloadCountsMatchSnapshot, isFalse);
      expect(result.failureMessage, contains('count mismatch'));
    });

    test('export fails closed if snapshot contains public labels', () {
      final result = _map(_snapshot(snapshotContainsPublicLabels: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.payloadContainsPublicLabels, isFalse);
    });

    test('export fails closed if snapshot contains official metrics', () {
      final result = _map(_snapshot(snapshotContainsOfficialMetrics: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.payloadContainsOfficialMetrics, isFalse);
    });

    test('export fails closed if public label is computed', () {
      final result = _map(_snapshot(publicLabelComputed: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
    });

    test('export fails closed if official metric is computed', () {
      final result = _map(_snapshot(officialCpLossComputed: true));

      expect(result.mappingSucceeded, isFalse);
      expect(result.safeForPhase36K, isFalse);
      expect(result.officialCpLossComputed, isFalse);
    });

    test('export remains in-memory-only', () {
      final result = _validExport();

      expect(result.exportContractIsInMemoryOnly, isTrue);
      expect(result.exportContractIsPersistenceWrite, isFalse);
      expect(result.exportContractIsFileWrite, isFalse);
      expect(result.exportContractIsBackendPayload, isFalse);
    });

    test('export remains read-only', () {
      final result = _validExport();

      expect(result.exportContractIsReadOnly, isTrue);
      expect(result.savedAnalysisWritten, isFalse);
      expect(result.uiOutputProduced, isFalse);
      expect(result.archiveStatsTouched, isFalse);
    });

    test(
      'export performs no persistence/file/backend/UI/archive side effects',
      () {
        final result = _validExport();

        expect(result.savedAnalysisWritten, isFalse);
        expect(result.uiOutputProduced, isFalse);
        expect(result.archiveStatsTouched, isFalse);
        expect(result.persistenceWritePerformed, isFalse);
        expect(result.fileWritePerformed, isFalse);
        expect(result.backendPayloadProduced, isFalse);
        expect(result.exportContractIsUiOutput, isFalse);
        expect(result.exportContractIsArchiveStatsOutput, isFalse);
      },
    );

    test('public label remains null', () {
      final result = _validExport();

      expect(result.publicLabelComputed, isFalse);
      expect(result.publicLabel, isNull);
      expect(result.payloadContainsPublicLabels, isFalse);
    });

    test('official move quality remains null', () {
      final result = _validExport();

      expect(result.officialMoveQualityComputed, isFalse);
      expect(result.officialMoveQuality, isNull);
    });

    test('accuracy, ACPL, and Win% remain false', () {
      final result = _validExport();

      expect(result.officialWinPercentComputed, isFalse);
      expect(result.accuracyComputed, isFalse);
      expect(result.acplComputed, isFalse);
      expect(result.classificationComputed, isFalse);
      expect(result.publicClassifierOutputComputed, isFalse);
    });

    test('public label strings are banned from exposed fields', () {
      final clean = _validExport();
      final leaked = _map(_snapshot(snapshotId: 'phase36H:Brilliant:blocked'));

      _expectForbiddenStringsAbsent(clean);
      _expectForbiddenStringsAbsent(leaked);
      expect(leaked.mappingSucceeded, isFalse);
      expect(leaked.safeForPhase36K, isFalse);
      expect(leaked.sourceSnapshotId, 'phase36J:blockedSnapshot');
    });

    test('safeForPhase36K true only when all safety flags are clean', () {
      final clean = _validExport();
      final publicLabel = _map(_snapshot(publicLabelComputed: true));
      final officialWinPercent = _map(
        _snapshot(officialWinPercentComputed: true),
      );
      final saved = _map(_snapshot(savedAnalysisWritten: true));

      expect(clean.safeForPhase36K, isTrue);
      expect(publicLabel.safeForPhase36K, isFalse);
      expect(officialWinPercent.safeForPhase36K, isFalse);
      expect(saved.safeForPhase36K, isFalse);
    });
  });
}

AnalyzerDeveloperSnapshotExportContract _map(
  AnalyzerDeveloperReviewEnvelopeSnapshot source,
) {
  return mapDeveloperReviewEnvelopeSnapshotToExportContract(source);
}

AnalyzerDeveloperSnapshotExportContract _validExport() => _map(_snapshot());

AnalyzerDeveloperReviewEnvelopeSnapshot _snapshot({
  String snapshotId = 'phase36H:phase36F:safe-envelope:snapshot',
  String sourceReviewEnvelopeId = 'phase36F:safe-envelope',
  String sourceTimelineCollectionId = 'phase36D:safe-collection',
  String sourceReviewSummaryId = 'phase36E:safe-summary',
  bool sourceReviewEnvelopeComputed = true,
  bool sourceReviewEnvelopeIsDeveloperOnly = true,
  bool sourceReviewEnvelopeIsPublic = false,
  bool sourceReviewEnvelopeIsProductReview = false,
  bool sourceReviewEnvelopeIsSavedAnalysis = false,
  bool sourceReviewEnvelopeIsOfficial = false,
  bool sourceReviewEnvelopeIsUiOutput = false,
  bool sourceReviewEnvelopeIsArchiveStatsOutput = false,
  bool sourceReviewEnvelopeIsFullGameAnalysis = false,
  bool sourceReviewEnvelopeIsProductTimeline = false,
  bool snapshotComputed = true,
  bool snapshotIsDeveloperOnly = true,
  bool snapshotIsReadOnly = true,
  bool snapshotIsPublic = false,
  bool snapshotIsProductReview = false,
  bool snapshotIsSavedAnalysis = false,
  bool snapshotIsOfficial = false,
  bool snapshotIsUiOutput = false,
  bool snapshotIsArchiveStatsOutput = false,
  bool snapshotIsFullGameAnalysis = false,
  bool snapshotIsProductTimeline = false,
  int totalPrivateEntries = 1,
  int positiveCandidateCount = 1,
  int neutralCandidateCount = 0,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  bool snapshotCountsMatchSource = true,
  bool snapshotContainsPublicLabels = false,
  bool snapshotContainsOfficialMetrics = false,
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
  bool safeForPhase36I = true,
}) {
  return AnalyzerDeveloperReviewEnvelopeSnapshot(
    snapshotId: snapshotId,
    sourceReviewEnvelopeId: sourceReviewEnvelopeId,
    sourceTimelineCollectionId: sourceTimelineCollectionId,
    sourceReviewSummaryId: sourceReviewSummaryId,
    snapshotSource: analyzerDeveloperReviewEnvelopeSnapshotSource,
    snapshotVersion: analyzerDeveloperReviewEnvelopeSnapshotVersion,
    sourceReviewEnvelopeComputed: sourceReviewEnvelopeComputed,
    sourceReviewEnvelopeIsDeveloperOnly: sourceReviewEnvelopeIsDeveloperOnly,
    sourceReviewEnvelopeIsPublic: sourceReviewEnvelopeIsPublic,
    sourceReviewEnvelopeIsProductReview: sourceReviewEnvelopeIsProductReview,
    sourceReviewEnvelopeIsSavedAnalysis: sourceReviewEnvelopeIsSavedAnalysis,
    sourceReviewEnvelopeIsOfficial: sourceReviewEnvelopeIsOfficial,
    sourceReviewEnvelopeIsUiOutput: sourceReviewEnvelopeIsUiOutput,
    sourceReviewEnvelopeIsArchiveStatsOutput:
        sourceReviewEnvelopeIsArchiveStatsOutput,
    sourceReviewEnvelopeIsFullGameAnalysis:
        sourceReviewEnvelopeIsFullGameAnalysis,
    sourceReviewEnvelopeIsProductTimeline:
        sourceReviewEnvelopeIsProductTimeline,
    snapshotComputed: snapshotComputed,
    snapshotIsDeveloperOnly: snapshotIsDeveloperOnly,
    snapshotIsReadOnly: snapshotIsReadOnly,
    snapshotIsPublic: snapshotIsPublic,
    snapshotIsProductReview: snapshotIsProductReview,
    snapshotIsSavedAnalysis: snapshotIsSavedAnalysis,
    snapshotIsOfficial: snapshotIsOfficial,
    snapshotIsUiOutput: snapshotIsUiOutput,
    snapshotIsArchiveStatsOutput: snapshotIsArchiveStatsOutput,
    snapshotIsFullGameAnalysis: snapshotIsFullGameAnalysis,
    snapshotIsProductTimeline: snapshotIsProductTimeline,
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    snapshotCountsMatchSource: snapshotCountsMatchSource,
    snapshotContainsPublicLabels: snapshotContainsPublicLabels,
    snapshotContainsOfficialMetrics: snapshotContainsOfficialMetrics,
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
    failureMessage: mappingSucceeded ? null : 'blocked fake snapshot',
    safeForPhase36I: safeForPhase36I,
    nextRecommendation: safeForPhase36I
        ? analyzerDeveloperReviewEnvelopeSnapshotNextRecommendation
        : analyzerDeveloperReviewEnvelopeSnapshotFailureRecommendation,
  );
}

void _expectForbiddenStringsAbsent(
  AnalyzerDeveloperSnapshotExportContract result,
) {
  final exposed = <String?>{
    result.exportContractId,
    result.exportContractSource,
    result.sourceSnapshotId,
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
