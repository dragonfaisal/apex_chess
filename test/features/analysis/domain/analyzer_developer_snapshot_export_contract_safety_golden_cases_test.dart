import 'package:apex_chess/features/analysis/domain/analyzer_developer_review_envelope_snapshot.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_export_contract.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_export_contract_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 36K developer snapshot export safety golden cases', () {
    test('clean one-entry export stays developer-only and in-memory', () {
      final result = _map(_snapshot());

      _expectCleanExport(result);
      expect(result.sourceSnapshotComputed, isTrue);
      expect(result.sourceSnapshotIsDeveloperOnly, isTrue);
      expect(result.sourceSnapshotIsReadOnly, isTrue);
      expect(result.totalPrivateEntries, 1);
      expect(result.positiveCandidateCount, 1);
      expect(result.payloadCountsMatchSnapshot, isTrue);
      expect(_safeForPhase36L(result), isTrue);
    });

    test('clean mixed-count export copies private counts from snapshot', () {
      final source = _snapshot(
        totalPrivateEntries: 4,
        positiveCandidateCount: 1,
        neutralCandidateCount: 1,
        negativeCandidateCount: 1,
        unavailableCount: 1,
      );
      final result = _map(source);

      _expectCleanExport(result);
      expect(result.totalPrivateEntries, source.totalPrivateEntries);
      expect(result.positiveCandidateCount, source.positiveCandidateCount);
      expect(result.neutralCandidateCount, source.neutralCandidateCount);
      expect(result.negativeCandidateCount, source.negativeCandidateCount);
      expect(result.unavailableCount, source.unavailableCount);
      expect(_exportBucketCountSum(result), source.totalPrivateEntries);
      expect(result.payloadCountsMatchSnapshot, isTrue);
      expect(_safeForPhase36L(result), isTrue);
    });

    test('blocks unsafe snapshot variants', () {
      final variants = <String, AnalyzerDeveloperReviewEnvelopeSnapshot>{
        'public': _snapshot(snapshotIsPublic: true),
        'official': _snapshot(snapshotIsOfficial: true),
        'product review': _snapshot(snapshotIsProductReview: true),
        'saved analysis': _snapshot(snapshotIsSavedAnalysis: true),
        'UI output': _snapshot(snapshotIsUiOutput: true),
        'archive/stats': _snapshot(snapshotIsArchiveStatsOutput: true),
        'full-game analysis': _snapshot(snapshotIsFullGameAnalysis: true),
        'product timeline': _snapshot(snapshotIsProductTimeline: true),
        'not developer-only': _snapshot(snapshotIsDeveloperOnly: false),
        'not read-only': _snapshot(snapshotIsReadOnly: false),
        'count match flag false': _snapshot(snapshotCountsMatchSource: false),
        'contains public labels': _snapshot(snapshotContainsPublicLabels: true),
        'contains official metrics': _snapshot(
          snapshotContainsOfficialMetrics: true,
        ),
      };

      for (final entry in variants.entries) {
        _expectBlockedExport(_map(entry.value), reason: entry.key);
      }
    });

    test('blocks public and official computation variants', () {
      final variants = <String, AnalyzerDeveloperReviewEnvelopeSnapshot>{
        'publicLabelComputed': _snapshot(publicLabelComputed: true),
        'publicLabel': _snapshot(publicLabel: 'internal-public-label-leak'),
        'officialMoveQualityComputed': _snapshot(
          officialMoveQualityComputed: true,
        ),
        'officialMoveQuality': _snapshot(
          officialMoveQuality: 'internal-official-quality-leak',
        ),
        'officialCpLossComputed': _snapshot(officialCpLossComputed: true),
        'officialWinPercentComputed': _snapshot(
          officialWinPercentComputed: true,
        ),
        'accuracyComputed': _snapshot(accuracyComputed: true),
        'acplComputed': _snapshot(acplComputed: true),
        'classificationComputed': _snapshot(classificationComputed: true),
        'publicClassifierOutputComputed': _snapshot(
          publicClassifierOutputComputed: true,
        ),
      };

      for (final entry in variants.entries) {
        _expectBlockedExport(_map(entry.value), reason: entry.key);
      }
    });

    test(
      'blocks side-effect variants and keeps impossible export effects false',
      () {
        final variants = <String, AnalyzerDeveloperReviewEnvelopeSnapshot>{
          'savedAnalysisWritten': _snapshot(savedAnalysisWritten: true),
          'uiOutputProduced': _snapshot(uiOutputProduced: true),
          'archiveStatsTouched': _snapshot(archiveStatsTouched: true),
        };

        for (final entry in variants.entries) {
          final result = _map(entry.value);

          _expectBlockedExport(result, reason: entry.key);
          expect(result.persistenceWritePerformed, isFalse);
          expect(result.fileWritePerformed, isFalse);
          expect(result.backendPayloadProduced, isFalse);
        }
      },
    );

    test('in-memory hard ban holds for valid exports', () {
      final oneEntry = _map(_snapshot());
      final mixed = _map(
        _snapshot(
          totalPrivateEntries: 4,
          positiveCandidateCount: 1,
          neutralCandidateCount: 1,
          negativeCandidateCount: 1,
          unavailableCount: 1,
        ),
      );

      _expectCleanExport(oneEntry);
      _expectCleanExport(mixed);
      expect(oneEntry.exportContractIsInMemoryOnly, isTrue);
      expect(mixed.exportContractIsInMemoryOnly, isTrue);
      expect(oneEntry.exportContractIsPersistenceWrite, isFalse);
      expect(oneEntry.exportContractIsFileWrite, isFalse);
      expect(oneEntry.exportContractIsBackendPayload, isFalse);
      expect(oneEntry.persistenceWritePerformed, isFalse);
      expect(oneEntry.fileWritePerformed, isFalse);
      expect(oneEntry.backendPayloadProduced, isFalse);
      expect(mixed.persistenceWritePerformed, isFalse);
      expect(mixed.fileWritePerformed, isFalse);
      expect(mixed.backendPayloadProduced, isFalse);
    });

    test('read-only hard ban holds for valid exports', () {
      final oneEntry = _map(_snapshot());
      final mixed = _map(
        _snapshot(
          totalPrivateEntries: 4,
          positiveCandidateCount: 1,
          neutralCandidateCount: 1,
          negativeCandidateCount: 1,
          unavailableCount: 1,
        ),
      );

      _expectCleanExport(oneEntry);
      _expectCleanExport(mixed);
      expect(oneEntry.exportContractIsReadOnly, isTrue);
      expect(mixed.exportContractIsReadOnly, isTrue);
      expect(oneEntry.savedAnalysisWritten, isFalse);
      expect(oneEntry.uiOutputProduced, isFalse);
      expect(oneEntry.archiveStatsTouched, isFalse);
      expect(oneEntry.persistenceWritePerformed, isFalse);
      expect(oneEntry.fileWritePerformed, isFalse);
      expect(oneEntry.backendPayloadProduced, isFalse);
      expect(mixed.savedAnalysisWritten, isFalse);
      expect(mixed.uiOutputProduced, isFalse);
      expect(mixed.archiveStatsTouched, isFalse);
    });

    test('public-label hard ban covers exposed export fields', () {
      final clean = _map(_snapshot());
      _expectForbiddenStringsAbsent(clean);

      for (final forbidden in _forbiddenPublicLabelStrings) {
        final leaked = _map(
          _snapshot(snapshotId: 'phase36H:$forbidden:blocked'),
        );

        _expectBlockedExport(leaked, reason: forbidden);
        _expectForbiddenStringsAbsent(leaked);
      }
    });

    test('official metrics hard ban holds for valid exports', () {
      final oneEntry = _map(_snapshot());
      final mixed = _map(
        _snapshot(
          totalPrivateEntries: 4,
          positiveCandidateCount: 1,
          neutralCandidateCount: 1,
          negativeCandidateCount: 1,
          unavailableCount: 1,
        ),
      );

      _expectCleanExport(oneEntry);
      _expectCleanExport(mixed);
      _expectNoPublicOfficialOrSideEffectOutput(oneEntry);
      _expectNoPublicOfficialOrSideEffectOutput(mixed);
    });

    test('product-output hard ban holds for valid exports', () {
      final result = _map(_snapshot());

      _expectCleanExport(result);
      expect(result.exportContractIsPublic, isFalse);
      expect(result.exportContractIsProductFeature, isFalse);
      expect(result.exportContractIsSavedAnalysis, isFalse);
      expect(result.exportContractIsPersistenceWrite, isFalse);
      expect(result.exportContractIsFileWrite, isFalse);
      expect(result.exportContractIsUiOutput, isFalse);
      expect(result.exportContractIsArchiveStatsOutput, isFalse);
      expect(result.exportContractIsBackendPayload, isFalse);
      expect(result.exportContractIsOfficial, isFalse);
      expect(result.exportContractIsDeveloperOnly, isTrue);
      expect(result.exportContractIsInMemoryOnly, isTrue);
      expect(result.exportContractIsReadOnly, isTrue);
    });
  });
}

AnalyzerDeveloperSnapshotExportContract _map(
  AnalyzerDeveloperReviewEnvelopeSnapshot source,
) {
  return mapDeveloperReviewEnvelopeSnapshotToExportContract(source);
}

void _expectCleanExport(AnalyzerDeveloperSnapshotExportContract result) {
  expect(result.mappingSucceeded, isTrue);
  expect(result.exportContractComputed, isTrue);
  expect(result.exportContractIsDeveloperOnly, isTrue);
  expect(result.exportContractIsInMemoryOnly, isTrue);
  expect(result.exportContractIsReadOnly, isTrue);
  expect(result.payloadCountsMatchSnapshot, isTrue);
  expect(result.payloadContainsPublicLabels, isFalse);
  expect(result.payloadContainsOfficialMetrics, isFalse);
  expect(result.safeForPhase36K, isTrue);
  _expectNoPublicOfficialOrSideEffectOutput(result);
  _expectNoProductOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectBlockedExport(
  AnalyzerDeveloperSnapshotExportContract result, {
  String? reason,
}) {
  expect(result.mappingSucceeded, isFalse, reason: reason);
  expect(result.exportContractComputed, isFalse, reason: reason);
  expect(result.safeForPhase36K, isFalse, reason: reason);
  expect(result.failureMessage, isNotNull, reason: reason);
  _expectNoPublicOfficialOrSideEffectOutput(result);
  _expectNoProductOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectNoPublicOfficialOrSideEffectOutput(
  AnalyzerDeveloperSnapshotExportContract result,
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
  expect(result.persistenceWritePerformed, isFalse);
  expect(result.fileWritePerformed, isFalse);
  expect(result.backendPayloadProduced, isFalse);
}

void _expectNoProductOutput(AnalyzerDeveloperSnapshotExportContract result) {
  expect(result.exportContractIsPublic, isFalse);
  expect(result.exportContractIsProductFeature, isFalse);
  expect(result.exportContractIsSavedAnalysis, isFalse);
  expect(result.exportContractIsPersistenceWrite, isFalse);
  expect(result.exportContractIsFileWrite, isFalse);
  expect(result.exportContractIsUiOutput, isFalse);
  expect(result.exportContractIsArchiveStatsOutput, isFalse);
  expect(result.exportContractIsBackendPayload, isFalse);
  expect(result.exportContractIsOfficial, isFalse);
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

bool _safeForPhase36L(AnalyzerDeveloperSnapshotExportContract result) {
  return result.mappingSucceeded &&
      result.safeForPhase36K &&
      result.exportContractComputed &&
      result.exportContractIsDeveloperOnly &&
      result.exportContractIsInMemoryOnly &&
      result.exportContractIsReadOnly &&
      result.payloadCountsMatchSnapshot &&
      !result.payloadContainsPublicLabels &&
      !result.payloadContainsOfficialMetrics &&
      !result.exportContractIsPublic &&
      !result.exportContractIsProductFeature &&
      !result.exportContractIsSavedAnalysis &&
      !result.exportContractIsPersistenceWrite &&
      !result.exportContractIsFileWrite &&
      !result.exportContractIsUiOutput &&
      !result.exportContractIsArchiveStatsOutput &&
      !result.exportContractIsBackendPayload &&
      !result.exportContractIsOfficial &&
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
      !result.archiveStatsTouched &&
      !result.persistenceWritePerformed &&
      !result.fileWritePerformed &&
      !result.backendPayloadProduced;
}

int _exportBucketCountSum(AnalyzerDeveloperSnapshotExportContract result) {
  return result.positiveCandidateCount +
      result.neutralCandidateCount +
      result.negativeCandidateCount +
      result.unavailableCount;
}

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
