@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_implementation_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug-Only Bridge Implementation Design', () {
    test('consumes safe Phase 33D validation and is ready with warnings', () {
      final result = _safeResult();

      expect(
        result.implementationDesignStatus,
        DebugOnlyBridgeImplementationDesignStatus
            .implementationDesignReadyWithWarnings,
      );
      expect(
        result.sourceReadinessSummaryValidationStatus,
        DebugBridgePrototypeDesignReadinessSummaryValidationStatus
            .validatedWithWarnings,
      );
      expect(result.safeForPhase33F, isTrue);
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.executableBridgeSkeletonImplemented, isFalse);
      expect(result.executableDebugBridgePrototypeImplemented, isFalse);
      expect(result.implementationWiringImplemented, isFalse);
      expect(
        result.phase33FRecommendation,
        DebugOnlyBridgeImplementationDesignPhase33FRecommendation
            .proceedToDebugOnlyBridgeDeveloperSkeleton,
      );
    });

    test('unsafe Phase 33D validation blocks implementation design', () {
      final unsafeValidation = _cachedSafeSummaryValidation.copyWith(
        validationStatus:
            DebugBridgePrototypeDesignReadinessSummaryValidationStatus
                .blockedByUnsafeSummary,
        unsafeRecordCount: 1,
        safeForPhase33E: false,
      );
      final result = _safeResult(
        DebugOnlyBridgeImplementationDesignRequest(
          readinessSummaryValidationResult: unsafeValidation,
          readinessSummaryResult: _cachedSafeSummary,
          readinessGateResult: _cachedSafeReadinessGate,
          prototypeValidationResult: _cachedSafePrototypeValidation,
          prototypeDesignResult: _cachedSafePrototypeDesign,
          bridgeReadinessGateResult: _cachedSafeGate,
        ),
      );

      expect(
        result.implementationDesignStatus,
        DebugOnlyBridgeImplementationDesignStatus
            .blockedByUnsafeReadinessValidation,
      );
      expect(result.safeForPhase33F, isFalse);
      expect(
        result.hasUnsafeDebugOnlyBridgeImplementationDesignPolicyViolation,
        isTrue,
      );
    });

    test('implementation design components are deterministic', () {
      final result = _safeResult();

      expect(result.totalComponents, 12);
      expect(
        result
            .component(
              DebugOnlyBridgeImplementationDesignComponentId
                  .bridgeInputContractDesign,
            )
            .designStatus,
        DebugOnlyBridgeImplementationDesignItemStatus.bridgeInputContractDesign,
      );
      expect(
        result
            .component(
              DebugOnlyBridgeImplementationDesignComponentId
                  .bridgeCoreRecordDesign,
            )
            .designStatus,
        DebugOnlyBridgeImplementationDesignItemStatus.bridgeCoreRecordDesign,
      );
      expect(
        result
            .component(
              DebugOnlyBridgeImplementationDesignComponentId
                  .bridgeRuntimeBlockDesign,
            )
            .inactive,
        isTrue,
      );
      expect(
        result
            .component(
              DebugOnlyBridgeImplementationDesignComponentId
                  .phase33FImplementationSkeletonRequirement,
            )
            .futurePrerequisites,
        contains('phase33FDeveloperOnlyNonExecutableBridgeSkeleton'),
      );
    });

    test(
      'implementation design records preserve roles and source boundaries',
      () {
        final result = _safeResult();

        expect(result.totalImplementationDesignRecords, 12);
        expect(
          result
              .recordForRole(
                DebugOnlyBridgeImplementationDesignComponentRole
                    .bridgeCoreRecord,
              )
              .sourceSummaryRole,
          DebugBridgePrototypeDesignReadinessSummaryRole
              .readinessApprovedPrototypeCoreSummaryRecord,
        );
        expect(
          result
              .recordForRole(
                DebugOnlyBridgeImplementationDesignComponentRole
                    .bridgeContextRecord,
              )
              .contextOnly,
          isTrue,
        );
        expect(
          result
              .recordForRole(
                DebugOnlyBridgeImplementationDesignComponentRole
                    .bridgeInactiveBlockedRecord,
              )
              .inactive,
          isTrue,
        );
        expect(
          result
              .recordForRole(
                DebugOnlyBridgeImplementationDesignComponentRole
                    .bridgeInactiveFutureRecord,
              )
              .inactive,
          isTrue,
        );
      },
    );

    test('proposed Phase 33F skeleton design is concrete metadata only', () {
      final result = _safeResult();

      expect(result.proposedClassNames, orderedEquals(_proposedClassNames));
      expect(result.proposedFileNames, orderedEquals(_proposedFileNames));
      expect(
        result.proposedMethodNames,
        containsAll(<String>[
          'buildInputFromValidatedSummary',
          'createCoreRecord',
          'createContextRecord',
          'preserveInactiveRecord',
          'validateNoDeniedFields',
          'renderDeveloperOnlyDebugSnapshot',
        ]),
      );
      for (final method in result.proposedMethodNames) {
        expect(
          const DebugOnlyBridgeImplementationDesignValidator()
              .validate(result)
              .where(
                (finding) =>
                    finding.id == 'proposedMethodImpliesForbiddenBehavior' &&
                    finding.methodName == method,
              ),
          isEmpty,
          reason: method,
        );
      }
    });

    test('aggregate implementation design counts are deterministic', () {
      final result = _safeResult();

      expect(result.inputContractDesignCount, 1);
      expect(result.coreRecordDesignCount, 1);
      expect(result.contextRecordDesignCount, 1);
      expect(result.inactiveBlockedRecordDesignCount, 1);
      expect(result.inactiveFutureRecordDesignCount, 1);
      expect(result.allowedFieldContractCount, 1);
      expect(result.deniedFieldContractCount, 1);
      expect(result.runtimeBlockDesignCount, 1);
      expect(result.proofBoundaryDesignCount, 1);
      expect(result.ownerProofBoundaryDesignCount, 1);
      expect(result.skeletonPlanDesignCount, 1);
      expect(result.futureRequirementCount, 1);
      expect(result.safeForPhase33F, isTrue);
    });

    test('allowed and denied field contracts keep boundaries', () {
      final result = _safeResult();

      expect(result.allowedFieldIds, orderedEquals(_allowedFieldIds));
      expect(result.allowedFieldIds, isNot(contains('productLabel')));
      expect(result.allowedFieldIds, isNot(contains('stockfishCommand')));
      expect(result.deniedFieldIds, orderedEquals(_deniedFieldIds));
      for (final fieldId in _deniedFieldIds) {
        expect(result.deniedFieldIds, contains(fieldId), reason: fieldId);
      }
    });

    test('runtime prototype and wiring remain blocked', () {
      final result = _safeResult();
      final runtime = result.recordForRole(
        DebugOnlyBridgeImplementationDesignComponentRole.bridgeRuntimeBlock,
      );

      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.executableBridgeSkeletonImplemented, isFalse);
      expect(result.executableDebugBridgePrototypeImplemented, isFalse);
      expect(result.implementationWiringImplemented, isFalse);
      expect(runtime.inactive, isTrue);
      expect(runtime.blockedBoundaryIds, contains('debugBridgeRuntime'));
      expect(runtime.blockedBoundaryIds, contains('implementationWiring'));
      expect(result.stockfishCommandFieldActive, isFalse);
      expect(result.rawUciFieldActive, isFalse);
      expect(result.pvDumpFieldActive, isFalse);
    });

    test('Android proof boundary and owner proof status remain honest', () {
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

    test(
      'no implementation design record emits product or integration output',
      () {
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
        for (final record in result.implementationDesignRecords) {
          expect(record.safetyFlags.values.any((value) => value), isFalse);
        }
      },
    );

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final validator = const DebugOnlyBridgeImplementationDesignValidator();

      expect(
        validator
            .validate(result.copyWith(androidProofCaseIds: const <String>['x']))
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

    test('validator rejects non-core core and context promotion', () {
      final result = _safeResult();
      final records = result.implementationDesignRecords
          .map(
            (record) =>
                record.componentRole ==
                    DebugOnlyBridgeImplementationDesignComponentRole
                        .bridgeCoreRecord
                ? record.copyWith(
                    contextOnly: true,
                    sourceSummaryRole:
                        DebugBridgePrototypeDesignReadinessSummaryRole
                            .constrainedPrototypeContextSummaryRecord,
                    sourceGateGroupId:
                        DebugBridgePrototypeDesignReadinessGateGroupId
                            .constrainedPrototypeContextDesignGroup,
                  )
                : record.componentRole ==
                      DebugOnlyBridgeImplementationDesignComponentRole
                          .bridgeContextRecord
                ? record.copyWith(contextOnly: false)
                : record,
          )
          .toList(growable: false);
      final ids = const DebugOnlyBridgeImplementationDesignValidator()
          .validate(result.copyWith(implementationDesignRecords: records))
          .map((finding) => finding.id)
          .toSet();

      expect(ids, contains('bridgeCoreDesignConsumesNonCoreInput'));
      expect(ids, contains('contextOnlyDesignPromotedToCore'));
    });

    test('validator rejects active blocked rows and denied fields', () {
      final result = _safeResult();
      final records = result.implementationDesignRecords
          .map(
            (record) =>
                record.componentRole ==
                    DebugOnlyBridgeImplementationDesignComponentRole
                        .bridgeInactiveBlockedRecord
                ? record.copyWith(
                    inactive: false,
                    allowedFieldIds: const <String>['debugBridgeRecordId'],
                  )
                : record,
          )
          .toList(growable: false);
      final ids = const DebugOnlyBridgeImplementationDesignValidator()
          .validate(
            result.copyWith(
              implementationDesignRecords: records,
              allowedFieldIds: const <String>['productLabel'],
            ),
          )
          .map((finding) => finding.id)
          .toSet();

      expect(ids, contains('blockedFutureDesignMadeActive'));
      expect(ids, contains('activeDeniedField'));
    });

    test('validator rejects safety flags and implementation flags', () {
      final result = _safeResult();
      final validator = const DebugOnlyBridgeImplementationDesignValidator();
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
        'targetsBackend': 'backendOutputActive',
        'exposesStockfishCommand': 'stockfishRawUciPvDumpFieldActive',
        'exposesRawUci': 'stockfishRawUciPvDumpFieldActive',
        'exposesPvDump': 'stockfishRawUciPvDumpFieldActive',
        'implementsRuntime': 'runtimeImplementationFlagActive',
        'implementsExecutablePrototype':
            'executablePrototypeImplementationFlagActive',
        'implementsWiring': 'implementationWiringFlagActive',
      };

      for (final entry in flags.entries) {
        final records = result.implementationDesignRecords
            .map(
              (record) =>
                  record.componentRole ==
                      DebugOnlyBridgeImplementationDesignComponentRole
                          .bridgeCoreRecord
                  ? record.copyWith(
                      safetyFlags: <String, bool>{entry.key: true},
                    )
                  : record,
            )
            .toList(growable: false);
        expect(
          validator
              .validate(result.copyWith(implementationDesignRecords: records))
              .map((finding) => finding.id),
          contains(entry.value),
          reason: entry.key,
        );
      }
    });

    test('validator rejects forbidden proposed methods', () {
      final result = _safeResult();
      final records = result.implementationDesignRecords
          .map(
            (record) =>
                record.componentRole ==
                    DebugOnlyBridgeImplementationDesignComponentRole
                        .bridgeSkeletonPlan
                ? record.copyWith(
                    proposedMethodNames: const <String>[
                      'executeEngineSearch',
                      'writePersistenceRecord',
                      'renderUiOutput',
                      'emitProductLabel',
                      'sendStockfishCommand',
                    ],
                  )
                : record,
          )
          .toList(growable: false);
      final findings = const DebugOnlyBridgeImplementationDesignValidator()
          .validate(result.copyWith(implementationDesignRecords: records));

      expect(
        findings.map((finding) => finding.id),
        everyElement('proposedMethodImpliesForbiddenBehavior'),
      );
      expect(findings, hasLength(5));
    });

    test(
      'validator rejects missing future requirement and unsafe ready state',
      () {
        final result = _safeResult().copyWith(
          futureRequirementCount: 0,
          sourceReadinessSummaryValidationStatus:
              DebugBridgePrototypeDesignReadinessSummaryValidationStatus
                  .blockedByPolicyBoundary,
          unsafeCount: 1,
          safeForPhase33F: true,
        );
        final ids = const DebugOnlyBridgeImplementationDesignValidator()
            .validate(result)
            .map((finding) => finding.id)
            .toSet();

        expect(
          ids,
          contains('missingPhase33FImplementationSkeletonRequirement'),
        );
        expect(
          ids,
          contains('unsafePhase33DValidationMarkedImplementationDesignReady'),
        );
      },
    );

    test('global result flags reject integration state', () {
      final result = _safeResult().copyWith(
        debugBridgeRuntimeImplemented: true,
        executableBridgeSkeletonImplemented: true,
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
        const DebugOnlyBridgeImplementationDesignValidator()
            .validate(result)
            .map((finding) => finding.id),
        contains('debugOnlyBridgeImplementationDesignBoundaryPolicyViolation'),
      );
    });

    test(
      'markdown report includes required implementation design sections',
      () {
        final report = _safeResult().renderMarkdownReport();

        expect(report, contains('# Debug-Only Bridge Implementation Design'));
        expect(report, contains('## Component Table'));
        expect(report, contains('## Implementation Design Record Table'));
        expect(report, contains('## Proposed Future Skeleton Classes'));
        expect(report, contains('## Proposed Future Skeleton Files'));
        expect(report, contains('## Input Contract Design'));
        expect(report, contains('## Core/Context/Inactive Record Design'));
        expect(report, contains('## Allowed And Denied Field Contract Design'));
        expect(report, contains('## Runtime/Prototype/Wiring Blocked Design'));
        expect(report, contains('## Android Proof Boundary'));
        expect(report, contains('## Owner Proof Boundary'));
        expect(report, contains('## Phase 33F Skeleton Requirement'));
        expect(report, contains('proceedToDebugOnlyBridgeDeveloperSkeleton'));
        _expectReportGuardrails(report);
      },
    );

    test('JSON report is deterministic and valid', () {
      final first = _safeResult().renderJsonReport();
      final second = _safeResult().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        debugOnlyBridgeImplementationDesignReportVersion,
      );
      expect(decoded['totalComponents'], 12);
      expect(decoded['totalImplementationDesignRecords'], 12);
      expect(decoded['safeForPhase33F'], isTrue);
      expect(
        decoded['phase33FRecommendation'],
        'proceedToDebugOnlyBridgeDeveloperSkeleton',
      );
    });

    test('reports contain no raw UCI spam or active product output', () {
      final report = _safeResult().renderMarkdownReport();

      _expectReportGuardrails(report);
      expect(
        const DebugOnlyBridgeImplementationDesignValidator().validateReportText(
          report,
        ),
        isEmpty,
      );
    });

    test('source imports stay pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_implementation_design.dart',
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

DebugOnlyBridgeImplementationDesignResult _safeResult([
  DebugOnlyBridgeImplementationDesignRequest? request,
]) {
  if (request != null) {
    return const DebugOnlyBridgeImplementationDesign().evaluate(request);
  }
  return _cachedSafeImplementationDesign;
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
    'executable bridge skeleton implemented: true',
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

final DebugOnlyBridgePrototypeDesignResult _cachedSafePrototypeDesign =
    const DebugOnlyBridgePrototypeDesign().evaluate(
      DebugOnlyBridgePrototypeDesignRequest(gateResult: _cachedSafeGate),
    );

final DebugOnlyBridgePrototypeDesignValidationResult
_cachedSafePrototypeValidation =
    const DebugOnlyBridgePrototypeDesignValidation().evaluate(
      DebugOnlyBridgePrototypeDesignValidationRequest(
        designResult: _cachedSafePrototypeDesign,
        gateResult: _cachedSafeGate,
      ),
    );

final DebugBridgePrototypeDesignReadinessGateResult _cachedSafeReadinessGate =
    const DebugBridgePrototypeDesignReadinessGate().evaluate(
      DebugBridgePrototypeDesignReadinessGateRequest(
        validationResult: _cachedSafePrototypeValidation,
        designResult: _cachedSafePrototypeDesign,
        gateResult: _cachedSafeGate,
      ),
    );

final DebugBridgePrototypeDesignReadinessSummaryResult _cachedSafeSummary =
    const DebugBridgePrototypeDesignReadinessSummary().evaluate(
      DebugBridgePrototypeDesignReadinessSummaryRequest(
        readinessGateResult: _cachedSafeReadinessGate,
        validationResult: _cachedSafePrototypeValidation,
        designResult: _cachedSafePrototypeDesign,
        bridgeReadinessGateResult: _cachedSafeGate,
      ),
    );

final DebugBridgePrototypeDesignReadinessSummaryValidationResult
_cachedSafeSummaryValidation =
    const DebugBridgePrototypeDesignReadinessSummaryValidation().evaluate(
      DebugBridgePrototypeDesignReadinessSummaryValidationRequest(
        summaryResult: _cachedSafeSummary,
        readinessGateResult: _cachedSafeReadinessGate,
        validationResult: _cachedSafePrototypeValidation,
        designResult: _cachedSafePrototypeDesign,
        bridgeReadinessGateResult: _cachedSafeGate,
      ),
    );

final DebugOnlyBridgeImplementationDesignResult
_cachedSafeImplementationDesign = const DebugOnlyBridgeImplementationDesign()
    .evaluate(
      DebugOnlyBridgeImplementationDesignRequest(
        readinessSummaryValidationResult: _cachedSafeSummaryValidation,
        readinessSummaryResult: _cachedSafeSummary,
        readinessGateResult: _cachedSafeReadinessGate,
        prototypeValidationResult: _cachedSafePrototypeValidation,
        prototypeDesignResult: _cachedSafePrototypeDesign,
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

const _proposedClassNames = <String>[
  'DebugOnlyBridgeInputPacket',
  'DebugOnlyBridgeOutputPacket',
  'DebugOnlyBridgePolicy',
  'DebugOnlyBridgeRecord',
  'DebugOnlyBridgeSkeleton',
  'DebugOnlyBridgeSkeletonResult',
  'DebugOnlyBridgeSkeletonValidator',
];

const _proposedFileNames = <String>[
  'lib/features/pgn_review/application/debug_only_bridge_policy.dart',
  'lib/features/pgn_review/application/debug_only_bridge_skeleton.dart',
  'lib/features/pgn_review/application/debug_only_bridge_skeleton_validator.dart',
  'test/features/pgn_review/application/debug_only_bridge_skeleton_test.dart',
  'tool/debug_only_bridge_skeleton_snapshot_report.dart',
];
