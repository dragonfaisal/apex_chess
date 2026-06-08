@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug Bridge Prototype Design Readiness Summary', () {
    test('consumes safe Phase 33B readiness gate with warning status', () {
      final result = _safeResult();

      expect(
        result.summaryStatus,
        DebugBridgePrototypeDesignReadinessSummaryStatus.summarizedWithWarnings,
      );
      expect(
        result.sourceReadinessGateStatus,
        DebugBridgePrototypeDesignReadinessGateStatus
            .readyForNextInternalStepWithWarnings,
      );
      expect(result.safeForPhase33D, isTrue);
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.executableDebugBridgePrototypeImplemented, isFalse);
      expect(result.implementationWiringImplemented, isFalse);
    });

    test('unsafe Phase 33B readiness gate blocks summary', () {
      final unsafeReadiness = _cachedSafeReadinessGate.copyWith(
        gateStatus: DebugBridgePrototypeDesignReadinessGateStatus
            .blockedByPolicyBoundary,
        unsafeCount: 1,
        safeForPhase33C: false,
      );
      final result = _safeResult(
        DebugBridgePrototypeDesignReadinessSummaryRequest(
          readinessGateResult: unsafeReadiness,
          validationResult: _cachedSafeValidation,
          designResult: _cachedSafeDesign,
          bridgeReadinessGateResult: _cachedSafeGate,
        ),
      );

      expect(
        result.summaryStatus,
        DebugBridgePrototypeDesignReadinessSummaryStatus
            .blockedByUnsafeReadinessGate,
      );
      expect(result.safeForPhase33D, isFalse);
      expect(
        result
            .hasUnsafeDebugBridgePrototypeDesignReadinessSummaryPolicyViolation,
        isTrue,
      );
    });

    test('summary groups are deterministic and preserve 33B boundaries', () {
      final result = _safeResult();

      expect(result.totalSummaryGroups, 11);
      expect(
        result.summaryGroups.map((group) => group.groupId.wire).toList(),
        orderedEquals(<String>[
          'readinessApprovedPrototypeCoreSummary',
          'constrainedPrototypeContextSummary',
          'inactivePrototypeBlockedSummary',
          'inactivePrototypeFutureOnlySummary',
          'approvedAllowedFieldSummary',
          'deniedFieldBoundarySummary',
          'stockfishRawUciPvDumpDeniedSummary',
          'runtimeExecutionBlockedSummary',
          'androidProofBoundarySummary',
          'ownerProofBoundarySummary',
          'futurePhase33DRequirementSummary',
        ]),
      );
      expect(
        result
            .group(
              DebugBridgePrototypeDesignReadinessSummaryGroupId
                  .readinessApprovedPrototypeCoreSummary,
            )
            .sourceGateGroupIds
            .single,
        DebugBridgePrototypeDesignReadinessGateGroupId
            .readinessApprovedPrototypeCoreDesignGroup,
      );
      expect(
        result
            .group(
              DebugBridgePrototypeDesignReadinessSummaryGroupId
                  .constrainedPrototypeContextSummary,
            )
            .contextOnly,
        isTrue,
      );
      expect(
        result
            .group(
              DebugBridgePrototypeDesignReadinessSummaryGroupId
                  .runtimeExecutionBlockedSummary,
            )
            .blockedBoundaryIds,
        contains('implementationWiring'),
      );
      expect(
        result
            .group(
              DebugBridgePrototypeDesignReadinessSummaryGroupId
                  .futurePhase33DRequirementSummary,
            )
            .futurePrerequisites,
        contains(
          'phase33DPrototypeDesignReadinessSummaryValidationOrImplementationDesignReadinessGateOrReportOnlyCheckpoint',
        ),
      );
    });

    test('summary records preserve core context blocked future roles', () {
      final result = _safeResult();

      expect(result.totalSummaryRecords, 11);
      expect(
        result.summaryRecords.map((record) => record.summaryRole.wire).toList(),
        orderedEquals(<String>[
          'readinessApprovedPrototypeCoreSummaryRecord',
          'constrainedPrototypeContextSummaryRecord',
          'inactivePrototypeBlockedSummaryRecord',
          'inactivePrototypeFutureOnlySummaryRecord',
          'approvedAllowedFieldSummaryRecord',
          'deniedFieldBoundarySummaryRecord',
          'stockfishRawUciPvDumpDeniedSummaryRecord',
          'runtimeExecutionBlockedSummaryRecord',
          'androidProofBoundarySummaryRecord',
          'ownerProofBoundarySummaryRecord',
          'futurePhase33DRequirementSummaryRecord',
        ]),
      );
      expect(
        result
            .recordForRole(
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .readinessApprovedPrototypeCoreSummaryRecord,
            )
            .allowedForFutureInternalPlanning,
        isTrue,
      );
      expect(
        result
            .recordForRole(
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .constrainedPrototypeContextSummaryRecord,
            )
            .contextOnly,
        isTrue,
      );
      expect(
        result
            .recordForRole(
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .inactivePrototypeBlockedSummaryRecord,
            )
            .inactive,
        isTrue,
      );
      expect(
        result
            .recordForRole(
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .inactivePrototypeFutureOnlySummaryRecord,
            )
            .inactive,
        isTrue,
      );
      expect(
        result
            .recordForRole(
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .runtimeExecutionBlockedSummaryRecord,
            )
            .inactive,
        isTrue,
      );
    });

    test('aggregate counts and Phase 33D recommendation are deterministic', () {
      final result = _safeResult();

      expect(result.approvedCoreSummaryCount, 1);
      expect(result.constrainedContextSummaryCount, 1);
      expect(result.inactiveBlockedSummaryCount, 1);
      expect(result.inactiveFutureOnlySummaryCount, 1);
      expect(result.approvedAllowedFieldCount, 14);
      expect(result.deniedFieldCount, 18);
      expect(result.stockfishRawUciPvDumpDeniedCount, 3);
      expect(result.runtimeExecutionBlockedCount, 1);
      expect(result.futureRequirementCount, 1);
      expect(result.safeForPhase33D, isTrue);
      expect(
        result.phase33DRecommendation,
        DebugBridgePrototypeDesignReadinessSummaryPhase33DRecommendation
            .proceedToDebugBridgePrototypeDesignReadinessSummaryValidation,
      );
    });

    test('allowed and denied field summary keeps all boundaries explicit', () {
      final result = _safeResult();

      expect(result.allowedFieldIds, orderedEquals(_allowedFieldIds));
      expect(result.allowedFieldIds, isNot(contains('productLabel')));
      expect(result.allowedFieldIds, isNot(contains('stockfishCommand')));
      expect(result.deniedFieldIds, orderedEquals(_deniedFieldIds));
      for (final fieldId in _deniedFieldIds) {
        expect(result.deniedFieldIds, contains(fieldId), reason: fieldId);
      }
      expect(
        result
            .recordForRole(
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .stockfishRawUciPvDumpDeniedSummaryRecord,
            )
            .deniedFieldIds,
        orderedEquals(_engineDumpFieldIds),
      );
    });

    test('Android proof and owner proof summary remain honest', () {
      final result = _safeResult();

      expect(
        result.androidProofCaseIds,
        orderedEquals(_capturedAndroidProofIds),
      );
      for (final phase32ECase in _phase32ECaseIds) {
        expect(result.androidProofCaseIds, isNot(contains(phase32ECase)));
      }
      expect(result.ownerProofQueueCount, 0);
    });

    test('no summary record emits product integration or engine output', () {
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
      for (final record in result.summaryRecords) {
        expect(record.designOnly, isTrue, reason: record.summaryRole.wire);
        for (final key in _safetyFlagKeys) {
          expect(record.safetyFlags[key], isFalse, reason: key);
        }
        expect(record.safetyFlags.values.any((value) => value), isFalse);
      }
    });

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final validator =
          const DebugBridgePrototypeDesignReadinessSummaryValidator();

      expect(
        validator
            .validate(
              result.copyWith(androidProofCaseIds: const ['fake-proof']),
            )
            .map((finding) => finding.id),
        contains('unprovenAndroidProofId'),
      );
      expect(
        validator
            .validate(
              result.copyWith(
                androidProofCaseIds: const [
                  'budget-pressure-wide-candidate-32e',
                ],
              ),
            )
            .map((finding) => finding.id),
        contains('phase32ECaseTreatedAsCapturedProof'),
      );
    });

    test('validator rejects context promotion and non-core core input', () {
      final result = _safeResult();
      final rows = result.summaryRecords
          .map(
            (record) =>
                record.summaryRole ==
                    DebugBridgePrototypeDesignReadinessSummaryRole
                        .readinessApprovedPrototypeCoreSummaryRecord
                ? record.copyWith(
                    sourceGateGroupId:
                        DebugBridgePrototypeDesignReadinessGateGroupId
                            .constrainedPrototypeContextDesignGroup,
                    violationReasons: const [
                      'prototypeCoreConsumesNonCoreInput',
                    ],
                  )
                : record.summaryRole ==
                      DebugBridgePrototypeDesignReadinessSummaryRole
                          .constrainedPrototypeContextSummaryRecord
                ? record.copyWith(
                    contextOnly: false,
                    allowedForFutureInternalPlanning: true,
                  )
                : record,
          )
          .toList(growable: false);
      final ids = const DebugBridgePrototypeDesignReadinessSummaryValidator()
          .validate(result.copyWith(summaryRecords: rows))
          .map((finding) => finding.id)
          .toSet();

      expect(ids, contains('prototypeCoreSummaryConsumesNonCoreInput'));
      expect(ids, contains('contextOnlySummaryPromotedToCore'));
    });

    test(
      'validator rejects blocked future activation and active denied fields',
      () {
        final result = _safeResult();
        final rows = result.summaryRecords
            .map(
              (record) =>
                  record.summaryRole ==
                      DebugBridgePrototypeDesignReadinessSummaryRole
                          .inactivePrototypeBlockedSummaryRecord
                  ? record.copyWith(
                      inactive: false,
                      allowedFieldIds: const ['debugBridgeRecordId'],
                    )
                  : record,
            )
            .toList(growable: false);
        final ids = const DebugBridgePrototypeDesignReadinessSummaryValidator()
            .validate(
              result.copyWith(
                summaryRecords: rows,
                allowedFieldIds: const ['productLabel'],
              ),
            )
            .map((finding) => finding.id)
            .toSet();

        expect(ids, contains('blockedFutureSummaryMadeActive'));
        expect(ids, contains('activeDeniedField'));
      },
    );

    test('validator rejects safety and implementation flags', () {
      final result = _safeResult();
      final validator =
          const DebugBridgePrototypeDesignReadinessSummaryValidator();
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
        'implementsRuntime': 'runtimeImplementationFlagActive',
        'implementsPrototypeExecution':
            'executablePrototypeImplementationFlagActive',
        'implementsWiring': 'implementationWiringFlagActive',
      };

      for (final entry in flags.entries) {
        final rows = result.summaryRecords
            .map(
              (record) =>
                  record.summaryRole ==
                      DebugBridgePrototypeDesignReadinessSummaryRole
                          .readinessApprovedPrototypeCoreSummaryRecord
                  ? record.copyWith(
                      safetyFlags: <String, bool>{entry.key: true},
                    )
                  : record,
            )
            .toList(growable: false);
        expect(
          validator
              .validate(result.copyWith(summaryRecords: rows))
              .map((finding) => finding.id),
          contains(entry.value),
          reason: entry.key,
        );
      }
    });

    test('validator rejects missing future Phase 33D requirement', () {
      final result = _safeResult().copyWith(futureRequirementCount: 0);

      expect(
        const DebugBridgePrototypeDesignReadinessSummaryValidator()
            .validate(result)
            .map((finding) => finding.id),
        contains('missingFuturePhase33DRequirement'),
      );
    });

    test(
      'validator rejects unsafe gate marked summarized and global seams',
      () {
        final result = _safeResult().copyWith(
          sourceReadinessGateStatus:
              DebugBridgePrototypeDesignReadinessGateStatus
                  .blockedByPolicyBoundary,
          unsafeCount: 1,
          safeForPhase33D: true,
          debugBridgeRuntimeImplemented: true,
          executableDebugBridgePrototypeImplemented: true,
          implementationWiringImplemented: true,
          uiTargetsActive: true,
          backendOutputActive: true,
          persistenceWritesActive: true,
          engineCallsActive: true,
          stockfishCommandFieldActive: true,
          rawUciFieldActive: true,
          pvDumpFieldActive: true,
        );
        final ids = const DebugBridgePrototypeDesignReadinessSummaryValidator()
            .validate(result)
            .map((finding) => finding.id)
            .toSet();

        expect(ids, contains('unsafePhase33BReadinessGateMarkedSummarized'));
        expect(
          ids,
          contains(
            'debugBridgePrototypeDesignReadinessSummaryBoundaryPolicyViolation',
          ),
        );
      },
    );

    test('markdown report includes required readiness summary sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(
        report,
        contains('# Debug Bridge Prototype Design Readiness Summary'),
      );
      expect(report, contains('## Summary Group Table'));
      expect(report, contains('## Summary Record Table'));
      expect(report, contains('## Prototype Core Readiness Summary'));
      expect(report, contains('## Context-Only Readiness Summary'));
      expect(report, contains('## Inactive Blocked/Future Summary'));
      expect(report, contains('## Allowed And Denied Field Summary'));
      expect(report, contains('## Stockfish Raw UCI PV Dump Denied Summary'));
      expect(
        report,
        contains('## Runtime/Executable Prototype/Wiring Blocked Status'),
      );
      expect(report, contains('## Phase 33D Recommendation'));
      expect(
        report,
        contains(
          'proceedToDebugBridgePrototypeDesignReadinessSummaryValidation',
        ),
      );
      _expectReportGuardrails(report);
    });

    test('JSON report is deterministic and valid', () {
      final first = _safeResult().renderJsonReport();
      final second = _safeResult().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        debugBridgePrototypeDesignReadinessSummaryReportVersion,
      );
      expect(decoded['summaryStatus'], 'summarizedWithWarnings');
      expect(decoded['totalSummaryGroups'], 11);
      expect(decoded['totalSummaryRecords'], 11);
      expect(decoded['approvedCoreSummaryCount'], 1);
      expect(decoded['constrainedContextSummaryCount'], 1);
      expect(decoded['approvedAllowedFieldCount'], 14);
      expect(decoded['deniedFieldCount'], 18);
      expect(decoded['stockfishRawUciPvDumpDeniedCount'], 3);
      expect(decoded['runtimeExecutionBlockedCount'], 1);
      expect(decoded['futureRequirementCount'], 1);
      expect(decoded['safeForPhase33D'], isTrue);
    });

    test('reports contain no raw logs active labels scores or rankings', () {
      final report = _safeResult().renderMarkdownReport();

      _expectReportGuardrails(report);
      expect(
        const DebugBridgePrototypeDesignReadinessSummaryValidator()
            .validateReportText(report),
        isEmpty,
      );
    });

    test('source imports stay pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      for (final forbidden in const <String>[
        'stockfish',
        'ffi',
        'native',
        'local_eval_service',
        'flutter/widgets',
        'flutter/material',
        'backend',
        'preflight',
        'server',
        'cache',
        'database',
        'persistence',
      ]) {
        expect(imports.toLowerCase(), isNot(contains(forbidden)));
      }
    });
  });
}

DebugBridgePrototypeDesignReadinessSummaryResult _safeResult([
  DebugBridgePrototypeDesignReadinessSummaryRequest? request,
]) {
  if (request != null) {
    return const DebugBridgePrototypeDesignReadinessSummary().evaluate(request);
  }
  return _cachedSafeSummary;
}

void _expectReportGuardrails(String report) {
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
    'allowed fields: productLabel',
    'allowed fields: stockfishCommand',
    'numeric move score:',
    'scoreValue',
    'moveScore',
    'rankedMoves',
    'moveRanking active',
    'ACPL active',
    'official accuracy active',
    'runtime implemented: true',
    'executable debug bridge prototype implemented: true',
    'implementation wiring implemented: true',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}

final DebugBridgeReadinessValidationGateResult _cachedSafeGate =
    const DebugBridgeReadinessValidationGate().evaluate(
      const DebugBridgeReadinessValidationGateRequest.safeDemo(),
    );

final DebugOnlyBridgePrototypeDesignResult _cachedSafeDesign =
    const DebugOnlyBridgePrototypeDesign().evaluate(
      DebugOnlyBridgePrototypeDesignRequest(gateResult: _cachedSafeGate),
    );

final DebugOnlyBridgePrototypeDesignValidationResult _cachedSafeValidation =
    const DebugOnlyBridgePrototypeDesignValidation().evaluate(
      DebugOnlyBridgePrototypeDesignValidationRequest(
        designResult: _cachedSafeDesign,
        gateResult: _cachedSafeGate,
      ),
    );

final DebugBridgePrototypeDesignReadinessGateResult _cachedSafeReadinessGate =
    const DebugBridgePrototypeDesignReadinessGate().evaluate(
      DebugBridgePrototypeDesignReadinessGateRequest(
        validationResult: _cachedSafeValidation,
        designResult: _cachedSafeDesign,
        gateResult: _cachedSafeGate,
      ),
    );

final DebugBridgePrototypeDesignReadinessSummaryResult _cachedSafeSummary =
    const DebugBridgePrototypeDesignReadinessSummary().evaluate(
      DebugBridgePrototypeDesignReadinessSummaryRequest(
        readinessGateResult: _cachedSafeReadinessGate,
        validationResult: _cachedSafeValidation,
        designResult: _cachedSafeDesign,
        bridgeReadinessGateResult: _cachedSafeGate,
      ),
    );

const _allowedFieldIds = <String>[
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

const _deniedFieldIds = <String>[
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

const _safetyFlagKeys = <String>[
  'isProductOutput',
  'isClassifierLabel',
  'hasNumericScore',
  'hasAggregateScore',
  'ranksMoves',
  'isOfficialMetric',
  'exposesCpLoss',
  'exposesWinProbability',
  'exposesStockfishCommand',
  'exposesRawUci',
  'exposesPvDump',
  'callsEngine',
  'writesPersistence',
  'targetsUi',
  'implementsRuntime',
  'implementsPrototypeExecution',
  'implementsWiring',
];
