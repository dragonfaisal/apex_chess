@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug Bridge Readiness Summary Validation', () {
    test('consumes safe Phase 32W summary with warning status', () {
      final result = _safeResult();

      expect(
        result.validationStatus,
        DebugBridgeReadinessSummaryValidationStatus.validatedWithWarnings,
      );
      expect(
        result.sourceSummaryStatus,
        DebugBridgeReadinessSummaryStatus.summarizedWithWarnings,
      );
      expect(result.safeForPhase32Y, isTrue);
      expect(result.unsafeRecordCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.debugBridgePrototypeImplemented, isFalse);
    });

    test('unsafe summary blocks validation', () {
      final unsafeSummary = const DebugBridgeReadinessSummary()
          .evaluate()
          .copyWith(
            summaryStatus:
                DebugBridgeReadinessSummaryStatus.blockedByUnsafeReadiness,
            unsafeCount: 1,
            safeForPhase32X: false,
          );
      final result = _safeResult(
        DebugBridgeReadinessSummaryValidationRequest(
          summaryResult: unsafeSummary,
        ),
      );

      expect(
        result.validationStatus,
        DebugBridgeReadinessSummaryValidationStatus.blockedByUnsafeSummary,
      );
      expect(result.safeForPhase32Y, isFalse);
      expect(
        result.hasUnsafeDebugBridgeReadinessSummaryValidationPolicyViolation,
        isTrue,
      );
    });

    test('validation checks are deterministic', () {
      final result = _safeResult();

      expect(result.totalChecks, 15);
      expect(result.passedCheckCount, 12);
      expect(result.warningCheckCount, 3);
      expect(
        _check(result, 'summaryConsumesReadinessGate').checkStatus,
        DebugBridgeReadinessSummaryValidationCheckStatus.passed,
      );
      expect(
        _check(
          result,
          'constrainedContextSummaryMatchesReadinessGate',
        ).checkStatus,
        DebugBridgeReadinessSummaryValidationCheckStatus.passedWithWarnings,
      );
      expect(
        _check(result, 'stockfishCommandRawUciPvDumpRemainBlocked').checkStatus,
        DebugBridgeReadinessSummaryValidationCheckStatus.passed,
      );
    });

    test('summary group validation rows preserve all Phase 32W groups', () {
      final result = _safeResult();

      expect(result.totalGroupRows, 9);
      expect(
        result
            .groupRowForGroup(
              DebugBridgeReadinessSummaryGroupId.readyDebugCoreInputSummary,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryGroupValidationStatus
            .validReadyDebugCoreInputSummary,
      );
      expect(
        result
            .groupRowForGroup(
              DebugBridgeReadinessSummaryGroupId
                  .constrainedDebugContextInputSummary,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryGroupValidationStatus
            .validConstrainedDebugContextInputSummary,
      );
      expect(
        result
            .groupRowForGroup(
              DebugBridgeReadinessSummaryGroupId
                  .inactiveDebugBlockedInputSummary,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryGroupValidationStatus
            .validInactiveDebugBlockedInputSummary,
      );
      expect(
        result
            .groupRowForGroup(
              DebugBridgeReadinessSummaryGroupId
                  .inactiveDebugFutureOnlyInputSummary,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryGroupValidationStatus
            .validInactiveDebugFutureOnlyInputSummary,
      );
      expect(
        result
            .groupRowForGroup(
              DebugBridgeReadinessSummaryGroupId
                  .stockfishRawUciPvDumpBlockedSummary,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryGroupValidationStatus
            .validStockfishRawUciPvDumpBlockedSummary,
      );
      expect(
        result
            .groupRowForGroup(
              DebugBridgeReadinessSummaryGroupId.androidProofBoundarySummary,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryGroupValidationStatus
            .validAndroidProofBoundarySummary,
      );
      expect(
        result
            .groupRowForGroup(
              DebugBridgeReadinessSummaryGroupId.ownerProofStatusSummary,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryGroupValidationStatus
            .validOwnerProofStatusSummary,
      );
    });

    test('summary record validation rows preserve all Phase 32W roles', () {
      final result = _safeResult();

      expect(result.totalRecordRows, 9);
      expect(
        result
            .recordRowForRole(
              DebugBridgeReadinessSummaryRole.readyDebugCoreInputSummaryRecord,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryRecordValidationStatus
            .validReadyDebugCoreSummaryRecord,
      );
      expect(
        result
            .recordRowForRole(
              DebugBridgeReadinessSummaryRole
                  .constrainedDebugContextInputSummaryRecord,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryRecordValidationStatus
            .validConstrainedDebugContextSummaryRecord,
      );
      expect(
        result
            .recordRowForRole(
              DebugBridgeReadinessSummaryRole
                  .inactiveDebugBlockedInputSummaryRecord,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryRecordValidationStatus
            .validInactiveBlockedSummaryRecord,
      );
      expect(
        result
            .recordRowForRole(
              DebugBridgeReadinessSummaryRole
                  .inactiveDebugFutureOnlyInputSummaryRecord,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryRecordValidationStatus
            .validInactiveFutureOnlySummaryRecord,
      );
      expect(
        result
            .recordRowForRole(
              DebugBridgeReadinessSummaryRole
                  .stockfishRawUciPvDumpBlockedSummaryRecord,
            )
            .validationStatus,
        DebugBridgeReadinessSummaryRecordValidationStatus
            .validStockfishRawUciPvDumpBlockedRecord,
      );
    });

    test('aggregate counts and Phase 32Y recommendation are deterministic', () {
      final result = _safeResult();

      expect(result.validReadyCoreSummaryCount, 1);
      expect(result.validConstrainedContextSummaryCount, 1);
      expect(result.validInactiveBlockedSummaryCount, 1);
      expect(result.validInactiveFutureOnlySummaryCount, 1);
      expect(result.validAllowedFieldSummaryCount, 1);
      expect(result.validDeniedFieldSummaryCount, 1);
      expect(result.validStockfishRawUciPvDumpBlockedCount, 1);
      expect(result.validAndroidProofBoundaryCount, 1);
      expect(result.validOwnerProofStatusCount, 1);
      expect(result.invalidRecordCount, 0);
      expect(result.unsafeRecordCount, 0);
      expect(result.safeForPhase32Y, isTrue);
      expect(
        result.phase32YRecommendation,
        DebugBridgeReadinessSummaryValidationPhase32YRecommendation
            .proceedToDebugBridgeReadinessValidationGate,
      );
    });

    test('allowed and denied field validation keeps bridge boundaries', () {
      final result = _safeResult();

      expect(result.allowedFieldIds, orderedEquals(_allowedBridgeFieldIds));
      expect(result.allowedFieldIds, isNot(contains('productLabel')));
      expect(result.allowedFieldIds, isNot(contains('stockfishCommand')));
      expect(result.deniedFieldIds, orderedEquals(_deniedBridgeFieldIds));
      expect(result.deniedFieldIds, contains('productLabel'));
      expect(result.deniedFieldIds, contains('finalMoveLabel'));
      expect(result.deniedFieldIds, contains('brilliantGreatMissStyleLabels'));
      expect(
        result.deniedFieldIds,
        contains('bestGoodInaccuracyMistakeBlunderStyleLabels'),
      );
      expect(result.deniedFieldIds, contains('numericMoveScore'));
      expect(result.deniedFieldIds, contains('aggregateScore'));
      expect(result.deniedFieldIds, contains('officialAccuracy'));
      expect(result.deniedFieldIds, contains('acpl'));
      expect(result.deniedFieldIds, contains('cpLoss'));
      expect(result.deniedFieldIds, contains('winProbability'));
      expect(result.deniedFieldIds, contains('moveRanking'));
      expect(result.deniedFieldIds, contains('uiOutput'));
      expect(result.deniedFieldIds, contains('backendOutput'));
      expect(result.deniedFieldIds, contains('persistenceOutput'));
      expect(result.deniedFieldIds, contains('directEngineCall'));
      expect(result.deniedFieldIds, contains('stockfishCommand'));
      expect(result.deniedFieldIds, contains('rawUci'));
      expect(result.deniedFieldIds, contains('pvDump'));
    });

    test('Stockfish command raw UCI and PV dump remain blocked', () {
      final result = _safeResult();
      final row = result.recordRowForRole(
        DebugBridgeReadinessSummaryRole
            .stockfishRawUciPvDumpBlockedSummaryRecord,
      );

      expect(row.activeFieldIds, isEmpty);
      expect(row.deniedFieldIds, orderedEquals(_engineDumpFieldIds));
      expect(result.stockfishCommandFieldActive, isFalse);
      expect(result.rawUciFieldActive, isFalse);
      expect(result.pvDumpFieldActive, isFalse);
    });

    test('Android proof boundary and owner proof status validate honestly', () {
      final result = _safeResult();

      expect(result.androidProofCaseIds, _capturedAndroidProofIds);
      for (final phase32ECase in _phase32ECaseIds) {
        expect(result.androidProofCaseIds, isNot(contains(phase32ECase)));
      }
      expect(result.ownerProofQueueCount, 0);
    });

    test('no validation record emits product or integration output', () {
      final result = _safeResult();

      expect(result.productOutputActive, isFalse);
      expect(result.classifierOutputActive, isFalse);
      expect(result.finalMoveLabelOutputActive, isFalse);
      expect(result.officialMetricOutputActive, isFalse);
      expect(result.cpLossOutputActive, isFalse);
      expect(result.winProbabilityOutputActive, isFalse);
      expect(result.numericOutputActive, isFalse);
      expect(result.aggregateScoreOutputActive, isFalse);
      expect(result.moveRankingOutputActive, isFalse);
      expect(result.quietPreparatoryScopeActivated, isFalse);
      expect(result.engineCallsActive, isFalse);
      expect(result.persistenceWritesActive, isFalse);
      expect(result.uiTargetsActive, isFalse);
      expect(result.backendOutputActive, isFalse);
      expect(result.stockfishCommandFieldActive, isFalse);
      expect(result.rawUciFieldActive, isFalse);
      expect(result.pvDumpFieldActive, isFalse);
      for (final row in result.recordRows) {
        expect(row.safetyFlags.values.any((value) => value), isFalse);
      }
    });

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final unproven = result.copyWith(
        androidProofCaseIds: const <String>['unproven-debug-proof'],
      );
      final phase32E = result.copyWith(
        androidProofCaseIds: const <String>['pv-multipv-support-boundary-32e'],
      );
      final validator = const DebugBridgeReadinessSummaryValidationValidator();

      expect(
        validator.validate(unproven).map((finding) => finding.id),
        contains('unprovenAndroidProofId'),
      );
      expect(
        validator.validate(phase32E).map((finding) => finding.id),
        contains('phase32ECaseTreatedAsCapturedProof'),
      );
    });

    test('validator rejects context promotion and non-core core input', () {
      final result = _safeResult();
      final rows = result.recordRows
          .map(
            (row) =>
                row.validationStatus ==
                    DebugBridgeReadinessSummaryRecordValidationStatus
                        .validReadyDebugCoreSummaryRecord
                ? row.copyWith(
                    contextOnly: true,
                    violationReasons: const <String>[
                      'debugCoreConsumesNonCoreInput',
                    ],
                  )
                : row,
          )
          .toList(growable: false);
      final findings = const DebugBridgeReadinessSummaryValidationValidator()
          .validate(result.copyWith(recordRows: rows));
      final ids = findings.map((finding) => finding.id).toSet();

      expect(ids, contains('readyCoreSummaryConsumesNonCoreInput'));
      expect(ids, contains('contextOnlySummaryPromotedToDebugCore'));
    });

    test(
      'validator rejects blocked future activation and active denied fields',
      () {
        final result = _safeResult();
        final rows = result.recordRows
            .map(
              (row) =>
                  row.validationStatus ==
                      DebugBridgeReadinessSummaryRecordValidationStatus
                          .validInactiveBlockedSummaryRecord
                  ? row.copyWith(
                      inactive: false,
                      activeFieldIds: const <String>['debugBridgeRecordId'],
                    )
                  : row,
            )
            .toList(growable: false);
        final findings = const DebugBridgeReadinessSummaryValidationValidator()
            .validate(
              result.copyWith(
                recordRows: rows,
                allowedFieldIds: const <String>['productLabel'],
              ),
            );
        final ids = findings.map((finding) => finding.id).toSet();

        expect(ids, contains('blockedFutureSummaryMadeActive'));
        expect(ids, contains('activeDeniedBridgeField'));
      },
    );

    test('validator rejects policy and safety flags', () {
      final result = _safeResult();
      final validator = const DebugBridgeReadinessSummaryValidationValidator();
      final flags = <String, String>{
        'isProductOutput': 'productOutputActive',
        'isClassifierLabel': 'classifierLabelOutputActive',
        'hasNumericScore': 'numericScoreOutputActive',
        'hasAggregateScore': 'aggregateScoreOutputActive',
        'ranksMoves': 'moveRankingOutputActive',
        'isOfficialMetric': 'officialMetricOutputActive',
        'exposesCpLoss': 'futureMetricOutputActive',
        'exposesWinProbability': 'futureMetricOutputActive',
        'quietPreparatoryScopeActive': 'quietPreparatoryScopeActivated',
        'callsEngine': 'engineCallFlagActive',
        'writesPersistence': 'persistenceWriteFlagActive',
        'targetsUi': 'uiTargetFlagActive',
        'backendOutputActive': 'backendOutputActive',
        'exposesStockfishCommand': 'stockfishRawUciPvDumpFieldActive',
        'exposesRawUci': 'stockfishRawUciPvDumpFieldActive',
        'exposesPvDump': 'stockfishRawUciPvDumpFieldActive',
      };

      for (final entry in flags.entries) {
        final rows = result.recordRows
            .map(
              (row) =>
                  row.validationStatus ==
                      DebugBridgeReadinessSummaryRecordValidationStatus
                          .validReadyDebugCoreSummaryRecord
                  ? row.copyWith(safetyFlags: <String, bool>{entry.key: true})
                  : row,
            )
            .toList(growable: false);
        expect(
          validator
              .validate(result.copyWith(recordRows: rows))
              .map((finding) => finding.id),
          contains(entry.value),
          reason: entry.key,
        );
      }
    });

    test('result flags reject blocked global integration state', () {
      final validator = const DebugBridgeReadinessSummaryValidationValidator();
      final result = _safeResult().copyWith(
        uiTargetsActive: true,
        backendOutputActive: true,
        persistenceWritesActive: true,
        engineCallsActive: true,
        stockfishCommandFieldActive: true,
        rawUciFieldActive: true,
        pvDumpFieldActive: true,
      );

      expect(
        validator.validate(result).map((finding) => finding.id),
        contains(
          'debugBridgeReadinessSummaryValidationBoundaryPolicyViolation',
        ),
      );
    });

    test('markdown report includes required validation sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(report, contains('# Debug Bridge Readiness Summary Validation'));
      expect(report, contains('## Validation Check Table'));
      expect(report, contains('## Summary Group Validation Table'));
      expect(report, contains('## Summary Record Validation Table'));
      expect(report, contains('## Ready Debug Core Validation'));
      expect(report, contains('## Constrained Debug Context Validation'));
      expect(report, contains('## Allowed And Denied Field Validation'));
      expect(
        report,
        contains('## Stockfish Raw UCI PV Dump Blocked Validation'),
      );
      expect(report, contains('## Phase 32Y Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _safeResult().renderJsonReport();
      final second = _safeResult().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        debugBridgeReadinessSummaryValidationReportVersion,
      );
      expect(decoded['totalChecks'], 15);
      expect(decoded['totalGroupRows'], 9);
      expect(decoded['totalRecordRows'], 9);
      expect(decoded['safeForPhase32Y'], isTrue);
    });

    test('reports contain no raw UCI spam or active product outputs', () {
      final report = _safeResult().renderMarkdownReport();

      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        'pv e2e4',
        'pvMoves',
        'active fields: productLabel',
        'active fields: finalMoveLabel',
        'active fields: numericMoveScore',
        'numeric move score:',
        'scoreValue',
        'moveScore',
        'rankedMoves',
        'moveRanking active',
        'ACPL active',
        'official accuracy active',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
      expect(
        const DebugBridgeReadinessSummaryValidationValidator()
            .validateReportText(report),
        isEmpty,
      );
    });

    test('source imports do not cross blocked integration boundaries', () {
      final source = File(
        'lib/features/pgn_review/application/debug_bridge_readiness_summary_validation.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, isNot(contains('dart:ffi')));
      expect(imports.toLowerCase(), isNot(contains('stockfish')));
      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('Widget')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('persistence')));
      expect(imports, isNot(contains('cache')));
      expect(imports, isNot(contains('database')));
    });
  });
}

DebugBridgeReadinessSummaryValidationResult _safeResult([
  DebugBridgeReadinessSummaryValidationRequest? request,
]) {
  return const DebugBridgeReadinessSummaryValidation().evaluate(
    request ?? const DebugBridgeReadinessSummaryValidationRequest.safeDemo(),
  );
}

DebugBridgeReadinessSummaryValidationCheck _check(
  DebugBridgeReadinessSummaryValidationResult result,
  String checkId,
) {
  return result.validationChecks.singleWhere(
    (check) => check.checkId == checkId,
  );
}

const _allowedBridgeFieldIds = <String>[
  'bucketIds',
  'debugBridgeRecordId',
  'evidenceAreaIds',
  'futurePrerequisites',
  'internalConstraints',
  'internalWarnings',
  'newlyAddedSupportCaseIds',
  'proofLimitReason',
  'qualitativeConfidence',
  'sourceAdapterPacketIds',
  'sourceSummaryGroupIds',
  'supportCaseIds',
  'warningLimitedReason',
  'watchListReason',
];

const _deniedBridgeFieldIds = <String>[
  'acpl',
  'aggregateScore',
  'backendOutput',
  'bestGoodInaccuracyMistakeBlunderStyleLabels',
  'brilliantGreatMissStyleLabels',
  'cpLoss',
  'directEngineCall',
  'finalMoveLabel',
  'moveRanking',
  'numericMoveScore',
  'officialAccuracy',
  'persistenceOutput',
  'productLabel',
  'pvDump',
  'rawUci',
  'stockfishCommand',
  'uiOutput',
  'winProbability',
];

const _engineDumpFieldIds = <String>['pvDump', 'rawUci', 'stockfishCommand'];

const _capturedAndroidProofIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];

const _phase32ECaseIds = <String>[
  'budget-pressure-wide-candidate-32e',
  'endgame-precision-candidate-spread-32e',
  'king-safety-mating-net-pressure-32e',
  'pv-multipv-support-boundary-32e',
  'suppression-forced-only-legal-32e',
];
