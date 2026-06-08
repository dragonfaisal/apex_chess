@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug Bridge Prototype Design Readiness Summary Validation', () {
    test('consumes safe Phase 33C summary with warning status', () {
      final result = _safeResult();

      expect(
        result.validationStatus,
        DebugBridgePrototypeDesignReadinessSummaryValidationStatus
            .validatedWithWarnings,
      );
      expect(
        result.sourceSummaryStatus,
        DebugBridgePrototypeDesignReadinessSummaryStatus.summarizedWithWarnings,
      );
      expect(result.safeForPhase33E, isTrue);
      expect(result.unsafeRecordCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.executableDebugBridgePrototypeImplemented, isFalse);
      expect(result.implementationWiringImplemented, isFalse);
      expect(
        result.phase33ERecommendation,
        DebugBridgePrototypeDesignReadinessSummaryValidationPhase33ERecommendation
            .proceedToDebugOnlyBridgeImplementationDesign,
      );
    });

    test('unsafe Phase 33C summary blocks validation', () {
      final unsafeSummary = _cachedSafeSummary.copyWith(
        summaryStatus: DebugBridgePrototypeDesignReadinessSummaryStatus
            .blockedByUnsafeReadinessGate,
        unsafeCount: 1,
        safeForPhase33D: false,
      );
      final result = _safeResult(
        DebugBridgePrototypeDesignReadinessSummaryValidationRequest(
          summaryResult: unsafeSummary,
          readinessGateResult: _cachedSafeReadinessGate,
          validationResult: _cachedSafeValidation,
          designResult: _cachedSafeDesign,
          bridgeReadinessGateResult: _cachedSafeGate,
        ),
      );

      expect(
        result.validationStatus,
        DebugBridgePrototypeDesignReadinessSummaryValidationStatus
            .blockedByUnsafeSummary,
      );
      expect(result.safeForPhase33E, isFalse);
      expect(
        result
            .hasUnsafeDebugBridgePrototypeDesignReadinessSummaryValidationPolicyViolation,
        isTrue,
      );
    });

    test('validation checks are deterministic', () {
      final result = _safeResult();

      expect(result.totalChecks, 16);
      expect(result.passedCheckCount, 13);
      expect(result.warningCheckCount, 3);
      expect(
        result.check('summaryConsumesReadinessGate').checkStatus,
        DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus.passed,
      );
      expect(
        result.check('approvedCoreSummaryMatchesGate').checkStatus,
        DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus.passed,
      );
      expect(
        result.check('constrainedContextSummaryMatchesGate').checkStatus,
        DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus
            .passedWithWarnings,
      );
      expect(
        result.check('stockfishRawUciPvDumpRemainDenied').checkStatus,
        DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus.passed,
      );
      expect(
        result.check('runtimePrototypeWiringRemainBlocked').checkStatus,
        DebugBridgePrototypeDesignReadinessSummaryValidationCheckStatus.passed,
      );
    });

    test('summary group validation rows preserve all Phase 33C groups', () {
      final result = _safeResult();

      expect(result.totalGroupRows, 11);
      expect(
        result
            .groupRowForGroup(
              DebugBridgePrototypeDesignReadinessSummaryGroupId
                  .readinessApprovedPrototypeCoreSummary,
            )
            .validationStatus,
        DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
            .validApprovedCoreSummary,
      );
      expect(
        result
            .groupRowForGroup(
              DebugBridgePrototypeDesignReadinessSummaryGroupId
                  .constrainedPrototypeContextSummary,
            )
            .validationStatus,
        DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
            .validConstrainedContextSummary,
      );
      expect(
        result
            .groupRowForGroup(
              DebugBridgePrototypeDesignReadinessSummaryGroupId
                  .inactivePrototypeBlockedSummary,
            )
            .validationStatus,
        DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
            .validInactiveBlockedSummary,
      );
      expect(
        result
            .groupRowForGroup(
              DebugBridgePrototypeDesignReadinessSummaryGroupId
                  .runtimeExecutionBlockedSummary,
            )
            .validationStatus,
        DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
            .validRuntimePrototypeWiringBlockedSummary,
      );
      expect(
        result
            .groupRowForGroup(
              DebugBridgePrototypeDesignReadinessSummaryGroupId
                  .futurePhase33DRequirementSummary,
            )
            .validationStatus,
        DebugBridgePrototypeDesignReadinessSummaryGroupValidationStatus
            .validFutureRequirementSummary,
      );
    });

    test('summary record validation rows preserve all Phase 33C roles', () {
      final result = _safeResult();

      expect(result.totalRecordRows, 11);
      expect(
        result
            .recordRowForRole(
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .readinessApprovedPrototypeCoreSummaryRecord,
            )
            .validationStatus,
        DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
            .validApprovedCoreSummaryRecord,
      );
      expect(
        result
            .recordRowForRole(
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .constrainedPrototypeContextSummaryRecord,
            )
            .validationStatus,
        DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
            .validConstrainedContextSummaryRecord,
      );
      expect(
        result
            .recordRowForRole(
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .stockfishRawUciPvDumpDeniedSummaryRecord,
            )
            .validationStatus,
        DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
            .validStockfishRawUciPvDumpDeniedRecord,
      );
      expect(
        result
            .recordRowForRole(
              DebugBridgePrototypeDesignReadinessSummaryRole
                  .runtimeExecutionBlockedSummaryRecord,
            )
            .validationStatus,
        DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
            .validRuntimePrototypeWiringBlockedRecord,
      );
    });

    test('aggregate validation counts are deterministic', () {
      final result = _safeResult();

      expect(result.validApprovedCoreSummaryCount, 1);
      expect(result.validConstrainedContextSummaryCount, 1);
      expect(result.validInactiveBlockedSummaryCount, 1);
      expect(result.validInactiveFutureOnlySummaryCount, 1);
      expect(result.validAllowedFieldSummaryCount, 1);
      expect(result.validDeniedFieldSummaryCount, 1);
      expect(result.validStockfishRawUciPvDumpDeniedCount, 1);
      expect(result.validRuntimePrototypeWiringBlockedCount, 1);
      expect(result.validAndroidProofBoundaryCount, 1);
      expect(result.validOwnerProofBoundaryCount, 1);
      expect(result.validFutureRequirementCount, 1);
      expect(result.invalidRecordCount, 0);
      expect(result.unsafeRecordCount, 0);
      expect(result.safeForPhase33E, isTrue);
    });

    test('allowed and denied field validation keeps boundaries', () {
      final result = _safeResult();

      expect(result.allowedFieldIds, orderedEquals(_allowedFieldIds));
      expect(result.allowedFieldIds, isNot(contains('productLabel')));
      expect(result.allowedFieldIds, isNot(contains('stockfishCommand')));
      expect(result.deniedFieldIds, orderedEquals(_deniedFieldIds));
      for (final fieldId in _deniedFieldIds) {
        expect(result.deniedFieldIds, contains(fieldId), reason: fieldId);
      }
    });

    test(
      'runtime prototype wiring and Stockfish dump fields remain blocked',
      () {
        final result = _safeResult();
        final runtime = result.recordRowForRole(
          DebugBridgePrototypeDesignReadinessSummaryRole
              .runtimeExecutionBlockedSummaryRecord,
        );
        final stockfish = result.recordRowForRole(
          DebugBridgePrototypeDesignReadinessSummaryRole
              .stockfishRawUciPvDumpDeniedSummaryRecord,
        );

        expect(result.debugBridgeRuntimeImplemented, isFalse);
        expect(result.executableDebugBridgePrototypeImplemented, isFalse);
        expect(result.implementationWiringImplemented, isFalse);
        expect(runtime.inactive, isTrue);
        expect(stockfish.allowedFieldIds, isEmpty);
        expect(stockfish.deniedFieldIds, orderedEquals(_engineDumpFieldIds));
        expect(result.stockfishCommandFieldActive, isFalse);
        expect(result.rawUciFieldActive, isFalse);
        expect(result.pvDumpFieldActive, isFalse);
      },
    );

    test('Android proof boundary and owner proof status validate honestly', () {
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

    test('no validation row emits product or integration output', () {
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
      for (final row in result.recordRows) {
        expect(row.safetyFlags.values.any((value) => value), isFalse);
      }
    });

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final validator =
          const DebugBridgePrototypeDesignReadinessSummaryValidationValidator();

      expect(
        validator
            .validate(
              result.copyWith(
                androidProofCaseIds: const <String>['unproven-proof'],
              ),
            )
            .map((finding) => finding.id),
        contains('unprovenAndroidProofId'),
      );
      expect(
        validator
            .validate(
              result.copyWith(
                androidProofCaseIds: const <String>[
                  'pv-multipv-support-boundary-32e',
                ],
              ),
            )
            .map((finding) => finding.id),
        contains('phase32ECaseTreatedAsCapturedProof'),
      );
    });

    test('validator rejects context promotion and non-core core input', () {
      final result = _safeResult();
      final rows = result.recordRows
          .map(
            (row) =>
                row.validationStatus ==
                    DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
                        .validApprovedCoreSummaryRecord
                ? row.copyWith(
                    contextOnly: true,
                    sourceGateGroupId:
                        DebugBridgePrototypeDesignReadinessGateGroupId
                            .constrainedPrototypeContextDesignGroup,
                    violationReasons: const <String>[
                      'prototypeCoreSummaryConsumesNonCoreInput',
                    ],
                  )
                : row.validationStatus ==
                      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
                          .validConstrainedContextSummaryRecord
                ? row.copyWith(
                    contextOnly: false,
                    allowedForFutureInternalPlanning: true,
                  )
                : row,
          )
          .toList(growable: false);
      final ids =
          const DebugBridgePrototypeDesignReadinessSummaryValidationValidator()
              .validate(result.copyWith(recordRows: rows))
              .map((finding) => finding.id)
              .toSet();

      expect(ids, contains('approvedCoreSummaryConsumesNonCoreInput'));
      expect(ids, contains('contextOnlySummaryPromotedToCore'));
    });

    test(
      'validator rejects blocked future activation and active denied fields',
      () {
        final result = _safeResult();
        final rows = result.recordRows
            .map(
              (row) =>
                  row.validationStatus ==
                      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
                          .validInactiveBlockedSummaryRecord
                  ? row.copyWith(
                      inactive: false,
                      allowedFieldIds: const <String>['debugBridgeRecordId'],
                    )
                  : row,
            )
            .toList(growable: false);
        final ids =
            const DebugBridgePrototypeDesignReadinessSummaryValidationValidator()
                .validate(
                  result.copyWith(
                    recordRows: rows,
                    allowedFieldIds: const <String>['productLabel'],
                  ),
                )
                .map((finding) => finding.id)
                .toSet();

        expect(ids, contains('blockedFutureSummaryMadeActive'));
        expect(ids, contains('activeDeniedField'));
      },
    );

    test('validator rejects policy safety and implementation flags', () {
      final result = _safeResult();
      final validator =
          const DebugBridgePrototypeDesignReadinessSummaryValidationValidator();
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
        final rows = result.recordRows
            .map(
              (row) =>
                  row.validationStatus ==
                      DebugBridgePrototypeDesignReadinessSummaryRecordValidationStatus
                          .validApprovedCoreSummaryRecord
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

    test(
      'validator rejects missing future checkpoint and unsafe validation',
      () {
        final result = _safeResult().copyWith(
          validFutureRequirementCount: 0,
          sourceSummaryStatus: DebugBridgePrototypeDesignReadinessSummaryStatus
              .blockedByPolicyBoundary,
          unsafeRecordCount: 1,
          safeForPhase33E: true,
        );
        final ids =
            const DebugBridgePrototypeDesignReadinessSummaryValidationValidator()
                .validate(result)
                .map((finding) => finding.id)
                .toSet();

        expect(ids, contains('missingFuturePhase33ERequirement'));
        expect(ids, contains('unsafePhase33CSummaryMarkedValidated'));
      },
    );

    test('global result flags reject blocked integration state', () {
      final result = _safeResult().copyWith(
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

      expect(
        const DebugBridgePrototypeDesignReadinessSummaryValidationValidator()
            .validate(result)
            .map((finding) => finding.id),
        contains(
          'debugBridgePrototypeDesignReadinessSummaryValidationBoundaryPolicyViolation',
        ),
      );
    });

    test('markdown report includes required validation sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(
        report,
        contains(
          '# Debug Bridge Prototype Design Readiness Summary Validation',
        ),
      );
      expect(report, contains('## Validation Check Table'));
      expect(report, contains('## Summary Group Validation Table'));
      expect(report, contains('## Summary Record Validation Table'));
      expect(report, contains('## Approved Core Validation'));
      expect(report, contains('## Context-Only Validation'));
      expect(report, contains('## Inactive Blocked/Future Validation'));
      expect(report, contains('## Allowed And Denied Field Validation'));
      expect(
        report,
        contains('## Stockfish Raw UCI PV Dump Denial Validation'),
      );
      expect(
        report,
        contains('## Runtime/Prototype/Wiring Blocked Validation'),
      );
      expect(report, contains('## Phase 33E Recommendation'));
      expect(report, contains('proceedToDebugOnlyBridgeImplementationDesign'));
      _expectReportGuardrails(report);
    });

    test('JSON report is deterministic and valid', () {
      final first = _safeResult().renderJsonReport();
      final second = _safeResult().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        debugBridgePrototypeDesignReadinessSummaryValidationReportVersion,
      );
      expect(decoded['totalChecks'], 16);
      expect(decoded['totalGroupRows'], 11);
      expect(decoded['totalRecordRows'], 11);
      expect(decoded['safeForPhase33E'], isTrue);
      expect(
        decoded['phase33ERecommendation'],
        'proceedToDebugOnlyBridgeImplementationDesign',
      );
    });

    test('reports contain no raw UCI spam or active product outputs', () {
      final report = _safeResult().renderMarkdownReport();

      _expectReportGuardrails(report);
      expect(
        const DebugBridgePrototypeDesignReadinessSummaryValidationValidator()
            .validateReportText(report),
        isEmpty,
      );
    });

    test('source imports stay pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary_validation.dart',
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

DebugBridgePrototypeDesignReadinessSummaryValidationResult _safeResult([
  DebugBridgePrototypeDesignReadinessSummaryValidationRequest? request,
]) {
  if (request != null) {
    return const DebugBridgePrototypeDesignReadinessSummaryValidation()
        .evaluate(request);
  }
  return _cachedSafeValidationResult;
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

final DebugBridgePrototypeDesignReadinessSummaryValidationResult
_cachedSafeValidationResult =
    const DebugBridgePrototypeDesignReadinessSummaryValidation().evaluate(
      DebugBridgePrototypeDesignReadinessSummaryValidationRequest(
        summaryResult: _cachedSafeSummary,
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
