import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_debug_read_facade.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_debug_read_facade_mapper.dart';
import 'package:apex_chess/features/analysis/domain/analyzer_developer_snapshot_export_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'Phase 36M developer snapshot debug read facade safety golden cases',
    () {
      test(
        'clean one-entry debug facade stays developer-only and read-only',
        () {
          final result = _map(_export());

          _expectCleanFacade(result);
          expect(result.sourceExportContractComputed, isTrue);
          expect(result.sourceExportContractIsDeveloperOnly, isTrue);
          expect(result.sourceExportContractIsInMemoryOnly, isTrue);
          expect(result.sourceExportContractIsReadOnly, isTrue);
          expect(result.totalPrivateEntries, 1);
          expect(result.positiveCandidateCount, 1);
          expect(result.readableSummaryMatchesExport, isTrue);
          expect(_safeForPhase36N(result), isTrue);
        },
      );

      test(
        'clean mixed-count debug facade copies private counts from export',
        () {
          final source = _export(
            totalPrivateEntries: 4,
            positiveCandidateCount: 1,
            neutralCandidateCount: 1,
            negativeCandidateCount: 1,
            unavailableCount: 1,
          );
          final result = _map(source);

          _expectCleanFacade(result);
          expect(result.totalPrivateEntries, source.totalPrivateEntries);
          expect(result.positiveCandidateCount, source.positiveCandidateCount);
          expect(result.neutralCandidateCount, source.neutralCandidateCount);
          expect(result.negativeCandidateCount, source.negativeCandidateCount);
          expect(result.unavailableCount, source.unavailableCount);
          expect(_facadeBucketCountSum(result), source.totalPrivateEntries);
          expect(result.readableSummaryMatchesExport, isTrue);
          expect(_safeForPhase36N(result), isTrue);
        },
      );

      test('blocks unsafe export variants', () {
        final variants = <String, AnalyzerDeveloperSnapshotExportContract>{
          'public': _export(exportContractIsPublic: true),
          'official': _export(exportContractIsOfficial: true),
          'product feature': _export(exportContractIsProductFeature: true),
          'saved analysis': _export(exportContractIsSavedAnalysis: true),
          'persistence write': _export(exportContractIsPersistenceWrite: true),
          'file write': _export(exportContractIsFileWrite: true),
          'UI output': _export(exportContractIsUiOutput: true),
          'archive/stats': _export(exportContractIsArchiveStatsOutput: true),
          'backend payload': _export(exportContractIsBackendPayload: true),
          'not developer-only': _export(exportContractIsDeveloperOnly: false),
          'not in-memory-only': _export(exportContractIsInMemoryOnly: false),
          'not read-only': _export(exportContractIsReadOnly: false),
          'count match flag false': _export(payloadCountsMatchSnapshot: false),
          'contains public labels': _export(payloadContainsPublicLabels: true),
          'contains official metrics': _export(
            payloadContainsOfficialMetrics: true,
          ),
        };

        for (final entry in variants.entries) {
          _expectBlockedFacade(_map(entry.value), reason: entry.key);
        }
      });

      test('blocks public and official computation variants', () {
        final variants = <String, AnalyzerDeveloperSnapshotExportContract>{
          'publicLabelComputed': _export(publicLabelComputed: true),
          'publicLabel': _export(publicLabel: 'internal-public-label-leak'),
          'officialMoveQualityComputed': _export(
            officialMoveQualityComputed: true,
          ),
          'officialMoveQuality': _export(
            officialMoveQuality: 'internal-official-quality-leak',
          ),
          'officialCpLossComputed': _export(officialCpLossComputed: true),
          'officialWinPercentComputed': _export(
            officialWinPercentComputed: true,
          ),
          'accuracyComputed': _export(accuracyComputed: true),
          'acplComputed': _export(acplComputed: true),
          'classificationComputed': _export(classificationComputed: true),
          'publicClassifierOutputComputed': _export(
            publicClassifierOutputComputed: true,
          ),
        };

        for (final entry in variants.entries) {
          _expectBlockedFacade(_map(entry.value), reason: entry.key);
        }
      });

      test(
        'blocks side-effect variants and keeps facade effects impossible',
        () {
          final variants = <String, AnalyzerDeveloperSnapshotExportContract>{
            'savedAnalysisWritten': _export(savedAnalysisWritten: true),
            'uiOutputProduced': _export(uiOutputProduced: true),
            'archiveStatsTouched': _export(archiveStatsTouched: true),
            'persistenceWritePerformed': _export(
              persistenceWritePerformed: true,
            ),
            'fileWritePerformed': _export(fileWritePerformed: true),
            'backendPayloadProduced': _export(backendPayloadProduced: true),
          };

          for (final entry in variants.entries) {
            final result = _map(entry.value);

            _expectBlockedFacade(result, reason: entry.key);
            expect(result.savedAnalysisWritten, isFalse);
            expect(result.uiOutputProduced, isFalse);
            expect(result.archiveStatsTouched, isFalse);
            expect(result.persistenceWritePerformed, isFalse);
            expect(result.fileWritePerformed, isFalse);
            expect(result.backendPayloadProduced, isFalse);
          }
        },
      );

      test('read-only hard ban holds for valid facades', () {
        final oneEntry = _map(_export());
        final mixed = _map(
          _export(
            totalPrivateEntries: 4,
            positiveCandidateCount: 1,
            neutralCandidateCount: 1,
            negativeCandidateCount: 1,
            unavailableCount: 1,
          ),
        );

        _expectCleanFacade(oneEntry);
        _expectCleanFacade(mixed);
        expect(oneEntry.debugFacadeIsReadOnly, isTrue);
        expect(mixed.debugFacadeIsReadOnly, isTrue);
        expect(oneEntry.savedAnalysisWritten, isFalse);
        expect(oneEntry.uiOutputProduced, isFalse);
        expect(oneEntry.archiveStatsTouched, isFalse);
        expect(oneEntry.persistenceWritePerformed, isFalse);
        expect(oneEntry.fileWritePerformed, isFalse);
        expect(oneEntry.backendPayloadProduced, isFalse);
        expect(mixed.savedAnalysisWritten, isFalse);
        expect(mixed.uiOutputProduced, isFalse);
        expect(mixed.archiveStatsTouched, isFalse);
        expect(mixed.persistenceWritePerformed, isFalse);
        expect(mixed.fileWritePerformed, isFalse);
        expect(mixed.backendPayloadProduced, isFalse);
      });

      test('developer-only hard ban holds for valid facades', () {
        final oneEntry = _map(_export());
        final mixed = _map(
          _export(
            totalPrivateEntries: 4,
            positiveCandidateCount: 1,
            neutralCandidateCount: 1,
            negativeCandidateCount: 1,
            unavailableCount: 1,
          ),
        );

        _expectCleanFacade(oneEntry);
        _expectCleanFacade(mixed);
        expect(oneEntry.debugFacadeIsDeveloperOnly, isTrue);
        expect(mixed.debugFacadeIsDeveloperOnly, isTrue);
        expect(oneEntry.debugFacadeIsPublic, isFalse);
        expect(oneEntry.debugFacadeIsProductFeature, isFalse);
        expect(oneEntry.debugFacadeIsUiOutput, isFalse);
        expect(oneEntry.debugFacadeIsSavedAnalysis, isFalse);
        expect(oneEntry.debugFacadeIsPersistenceWrite, isFalse);
        expect(oneEntry.debugFacadeIsFileWrite, isFalse);
        expect(oneEntry.debugFacadeIsArchiveStatsOutput, isFalse);
        expect(oneEntry.debugFacadeIsBackendPayload, isFalse);
        expect(oneEntry.debugFacadeIsOfficial, isFalse);
        expect(mixed.debugFacadeIsPublic, isFalse);
        expect(mixed.debugFacadeIsProductFeature, isFalse);
        expect(mixed.debugFacadeIsUiOutput, isFalse);
        expect(mixed.debugFacadeIsSavedAnalysis, isFalse);
        expect(mixed.debugFacadeIsPersistenceWrite, isFalse);
        expect(mixed.debugFacadeIsFileWrite, isFalse);
        expect(mixed.debugFacadeIsArchiveStatsOutput, isFalse);
        expect(mixed.debugFacadeIsBackendPayload, isFalse);
        expect(mixed.debugFacadeIsOfficial, isFalse);
      });

      test('developer status guard never reports ready for unsafe data', () {
        final clean = _map(_export());
        final unsafe = _map(_export(exportContractIsPublic: true));
        final unavailable = _map(_export(mappingSucceeded: false));

        _expectCleanFacade(clean);
        expect(clean.developerReadStatus.wire, 'ready');
        expect(clean.developerReadMessage.wire, 'developerSnapshotReady');

        _expectBlockedFacade(unsafe);
        expect(unsafe.developerReadStatus.wire, 'unavailable');
        expect(unsafe.developerReadMessage.wire, 'sourceExportUnsafe');

        _expectBlockedFacade(unavailable);
        expect(unavailable.developerReadStatus.wire, 'unavailable');
        expect(
          unavailable.developerReadMessage.wire,
          'sourceExportUnavailable',
        );
      });

      test('public-label hard ban covers exposed debug facade fields', () {
        final clean = _map(_export());
        _expectForbiddenStringsAbsent(clean);

        for (final forbidden in _forbiddenPublicLabelStrings) {
          final exportIdLeak = _map(
            _export(exportContractId: 'phase36J:$forbidden:blocked'),
          );
          final snapshotIdLeak = _map(
            _export(sourceSnapshotId: 'phase36H:$forbidden:blocked'),
          );
          final envelopeIdLeak = _map(
            _export(sourceReviewEnvelopeId: 'phase36F:$forbidden:blocked'),
          );

          _expectBlockedFacade(exportIdLeak, reason: forbidden);
          _expectBlockedFacade(snapshotIdLeak, reason: forbidden);
          _expectBlockedFacade(envelopeIdLeak, reason: forbidden);
          _expectForbiddenStringsAbsent(exportIdLeak);
          _expectForbiddenStringsAbsent(snapshotIdLeak);
          _expectForbiddenStringsAbsent(envelopeIdLeak);
        }
      });

      test('official metrics hard ban holds for valid facades', () {
        final oneEntry = _map(_export());
        final mixed = _map(
          _export(
            totalPrivateEntries: 4,
            positiveCandidateCount: 1,
            neutralCandidateCount: 1,
            negativeCandidateCount: 1,
            unavailableCount: 1,
          ),
        );

        _expectCleanFacade(oneEntry);
        _expectCleanFacade(mixed);
        _expectNoPublicOfficialOrSideEffectOutput(oneEntry);
        _expectNoPublicOfficialOrSideEffectOutput(mixed);
      });

      test('product-output hard ban holds for valid facades', () {
        final result = _map(_export());

        _expectCleanFacade(result);
        expect(result.debugFacadeIsPublic, isFalse);
        expect(result.debugFacadeIsProductFeature, isFalse);
        expect(result.debugFacadeIsUiOutput, isFalse);
        expect(result.debugFacadeIsSavedAnalysis, isFalse);
        expect(result.debugFacadeIsPersistenceWrite, isFalse);
        expect(result.debugFacadeIsFileWrite, isFalse);
        expect(result.debugFacadeIsArchiveStatsOutput, isFalse);
        expect(result.debugFacadeIsBackendPayload, isFalse);
        expect(result.debugFacadeIsOfficial, isFalse);
        expect(result.debugFacadeIsDeveloperOnly, isTrue);
        expect(result.debugFacadeIsReadOnly, isTrue);
      });
    },
  );
}

AnalyzerDeveloperSnapshotDebugReadFacade _map(
  AnalyzerDeveloperSnapshotExportContract source,
) {
  return mapDeveloperSnapshotExportContractToDebugReadFacade(source);
}

void _expectCleanFacade(AnalyzerDeveloperSnapshotDebugReadFacade result) {
  expect(result.mappingSucceeded, isTrue);
  expect(result.debugFacadeComputed, isTrue);
  expect(result.debugFacadeIsDeveloperOnly, isTrue);
  expect(result.debugFacadeIsReadOnly, isTrue);
  expect(result.readableSummaryMatchesExport, isTrue);
  expect(result.readableSummaryContainsPublicLabels, isFalse);
  expect(result.readableSummaryContainsOfficialMetrics, isFalse);
  expect(result.developerReadStatus.wire, 'ready');
  expect(result.developerReadMessage.wire, 'developerSnapshotReady');
  expect(result.safeForPhase36M, isTrue);
  _expectNoPublicOfficialOrSideEffectOutput(result);
  _expectNoProductOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectBlockedFacade(
  AnalyzerDeveloperSnapshotDebugReadFacade result, {
  String? reason,
}) {
  expect(result.mappingSucceeded, isFalse, reason: reason);
  expect(result.debugFacadeComputed, isFalse, reason: reason);
  expect(result.safeForPhase36M, isFalse, reason: reason);
  expect(result.developerReadStatus.wire, 'unavailable', reason: reason);
  expect(
    {
      AnalyzerDeveloperSnapshotDebugReadMessage.sourceExportUnsafe.wire,
      AnalyzerDeveloperSnapshotDebugReadMessage.sourceExportUnavailable.wire,
    },
    contains(result.developerReadMessage.wire),
    reason: reason,
  );
  expect(result.failureMessage, isNotNull, reason: reason);
  _expectNoPublicOfficialOrSideEffectOutput(result);
  _expectNoProductOutput(result);
  _expectForbiddenStringsAbsent(result);
}

void _expectNoPublicOfficialOrSideEffectOutput(
  AnalyzerDeveloperSnapshotDebugReadFacade result,
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

void _expectNoProductOutput(AnalyzerDeveloperSnapshotDebugReadFacade result) {
  expect(result.debugFacadeIsPublic, isFalse);
  expect(result.debugFacadeIsProductFeature, isFalse);
  expect(result.debugFacadeIsUiOutput, isFalse);
  expect(result.debugFacadeIsSavedAnalysis, isFalse);
  expect(result.debugFacadeIsPersistenceWrite, isFalse);
  expect(result.debugFacadeIsFileWrite, isFalse);
  expect(result.debugFacadeIsArchiveStatsOutput, isFalse);
  expect(result.debugFacadeIsBackendPayload, isFalse);
  expect(result.debugFacadeIsOfficial, isFalse);
}

void _expectForbiddenStringsAbsent(
  AnalyzerDeveloperSnapshotDebugReadFacade result,
) {
  final exposed = <String?>{
    result.debugFacadeId,
    result.debugFacadeSource,
    result.sourceExportContractId,
    result.sourceSnapshotId,
    result.sourceReviewEnvelopeId,
    result.publicLabel,
    result.officialMoveQuality,
    result.developerReadStatus.wire,
    result.developerReadMessage.wire,
  }.whereType<String>();

  for (final value in exposed) {
    for (final forbidden in _forbiddenPublicLabelStrings) {
      expect(value.contains(forbidden), isFalse, reason: value);
    }
  }
}

bool _safeForPhase36N(AnalyzerDeveloperSnapshotDebugReadFacade result) {
  return result.mappingSucceeded &&
      result.safeForPhase36M &&
      result.debugFacadeComputed &&
      result.debugFacadeIsDeveloperOnly &&
      result.debugFacadeIsReadOnly &&
      result.readableSummaryMatchesExport &&
      !result.readableSummaryContainsPublicLabels &&
      !result.readableSummaryContainsOfficialMetrics &&
      result.developerReadStatus ==
          AnalyzerDeveloperSnapshotDebugReadStatus.ready &&
      result.developerReadMessage ==
          AnalyzerDeveloperSnapshotDebugReadMessage.developerSnapshotReady &&
      !result.debugFacadeIsPublic &&
      !result.debugFacadeIsProductFeature &&
      !result.debugFacadeIsUiOutput &&
      !result.debugFacadeIsSavedAnalysis &&
      !result.debugFacadeIsPersistenceWrite &&
      !result.debugFacadeIsFileWrite &&
      !result.debugFacadeIsArchiveStatsOutput &&
      !result.debugFacadeIsBackendPayload &&
      !result.debugFacadeIsOfficial &&
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

int _facadeBucketCountSum(AnalyzerDeveloperSnapshotDebugReadFacade result) {
  return result.positiveCandidateCount +
      result.neutralCandidateCount +
      result.negativeCandidateCount +
      result.unavailableCount;
}

AnalyzerDeveloperSnapshotExportContract _export({
  String exportContractId = 'phase36J:phase36H:safe-snapshot:inMemory',
  String sourceSnapshotId = 'phase36H:safe-snapshot',
  String sourceReviewEnvelopeId = 'phase36F:safe-envelope',
  String sourceTimelineCollectionId = 'phase36D:safe-collection',
  String sourceReviewSummaryId = 'phase36E:safe-summary',
  bool sourceSnapshotComputed = true,
  bool sourceSnapshotIsDeveloperOnly = true,
  bool sourceSnapshotIsReadOnly = true,
  bool sourceSnapshotIsPublic = false,
  bool sourceSnapshotIsProductReview = false,
  bool sourceSnapshotIsSavedAnalysis = false,
  bool sourceSnapshotIsOfficial = false,
  bool sourceSnapshotIsUiOutput = false,
  bool sourceSnapshotIsArchiveStatsOutput = false,
  bool sourceSnapshotIsFullGameAnalysis = false,
  bool sourceSnapshotIsProductTimeline = false,
  bool exportContractComputed = true,
  bool exportContractIsDeveloperOnly = true,
  bool exportContractIsInMemoryOnly = true,
  bool exportContractIsReadOnly = true,
  bool exportContractIsPublic = false,
  bool exportContractIsProductFeature = false,
  bool exportContractIsSavedAnalysis = false,
  bool exportContractIsPersistenceWrite = false,
  bool exportContractIsFileWrite = false,
  bool exportContractIsUiOutput = false,
  bool exportContractIsArchiveStatsOutput = false,
  bool exportContractIsBackendPayload = false,
  bool exportContractIsOfficial = false,
  int totalPrivateEntries = 1,
  int positiveCandidateCount = 1,
  int neutralCandidateCount = 0,
  int negativeCandidateCount = 0,
  int unavailableCount = 0,
  bool payloadCountsMatchSnapshot = true,
  bool payloadContainsPublicLabels = false,
  bool payloadContainsOfficialMetrics = false,
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
  bool persistenceWritePerformed = false,
  bool fileWritePerformed = false,
  bool backendPayloadProduced = false,
  bool mappingSucceeded = true,
  bool safeForPhase36K = true,
}) {
  return AnalyzerDeveloperSnapshotExportContract(
    exportContractId: exportContractId,
    sourceSnapshotId: sourceSnapshotId,
    sourceReviewEnvelopeId: sourceReviewEnvelopeId,
    sourceTimelineCollectionId: sourceTimelineCollectionId,
    sourceReviewSummaryId: sourceReviewSummaryId,
    exportContractSource: analyzerDeveloperSnapshotExportContractSource,
    exportContractVersion: analyzerDeveloperSnapshotExportContractVersion,
    sourceSnapshotComputed: sourceSnapshotComputed,
    sourceSnapshotIsDeveloperOnly: sourceSnapshotIsDeveloperOnly,
    sourceSnapshotIsReadOnly: sourceSnapshotIsReadOnly,
    sourceSnapshotIsPublic: sourceSnapshotIsPublic,
    sourceSnapshotIsProductReview: sourceSnapshotIsProductReview,
    sourceSnapshotIsSavedAnalysis: sourceSnapshotIsSavedAnalysis,
    sourceSnapshotIsOfficial: sourceSnapshotIsOfficial,
    sourceSnapshotIsUiOutput: sourceSnapshotIsUiOutput,
    sourceSnapshotIsArchiveStatsOutput: sourceSnapshotIsArchiveStatsOutput,
    sourceSnapshotIsFullGameAnalysis: sourceSnapshotIsFullGameAnalysis,
    sourceSnapshotIsProductTimeline: sourceSnapshotIsProductTimeline,
    exportContractComputed: exportContractComputed,
    exportContractIsDeveloperOnly: exportContractIsDeveloperOnly,
    exportContractIsInMemoryOnly: exportContractIsInMemoryOnly,
    exportContractIsReadOnly: exportContractIsReadOnly,
    exportContractIsPublic: exportContractIsPublic,
    exportContractIsProductFeature: exportContractIsProductFeature,
    exportContractIsSavedAnalysis: exportContractIsSavedAnalysis,
    exportContractIsPersistenceWrite: exportContractIsPersistenceWrite,
    exportContractIsFileWrite: exportContractIsFileWrite,
    exportContractIsUiOutput: exportContractIsUiOutput,
    exportContractIsArchiveStatsOutput: exportContractIsArchiveStatsOutput,
    exportContractIsBackendPayload: exportContractIsBackendPayload,
    exportContractIsOfficial: exportContractIsOfficial,
    totalPrivateEntries: totalPrivateEntries,
    positiveCandidateCount: positiveCandidateCount,
    neutralCandidateCount: neutralCandidateCount,
    negativeCandidateCount: negativeCandidateCount,
    unavailableCount: unavailableCount,
    payloadCountsMatchSnapshot: payloadCountsMatchSnapshot,
    payloadContainsPublicLabels: payloadContainsPublicLabels,
    payloadContainsOfficialMetrics: payloadContainsOfficialMetrics,
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
    persistenceWritePerformed: persistenceWritePerformed,
    fileWritePerformed: fileWritePerformed,
    backendPayloadProduced: backendPayloadProduced,
    mappingSucceeded: mappingSucceeded,
    failureMessage: mappingSucceeded ? null : 'blocked fake export',
    safeForPhase36K: safeForPhase36K,
    nextRecommendation: safeForPhase36K
        ? analyzerDeveloperSnapshotExportContractNextRecommendation
        : analyzerDeveloperSnapshotExportContractFailureRecommendation,
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
