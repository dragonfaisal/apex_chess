@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug Bridge Prototype Design Readiness Gate', () {
    test('consumes safe Phase 33A validation with warning status', () {
      final result = _safeResult();

      expect(
        result.gateStatus,
        DebugBridgePrototypeDesignReadinessGateStatus
            .readyForNextInternalStepWithWarnings,
      );
      expect(
        result.sourceValidationStatus,
        DebugOnlyBridgePrototypeDesignValidationStatus.validatedWithWarnings,
      );
      expect(result.safeForPhase33C, isTrue);
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.executableDebugBridgePrototypeImplemented, isFalse);
    });

    test('unsafe Phase 33A validation blocks readiness', () {
      final unsafeValidation = _cachedSafeValidation.copyWith(
        validationStatus: DebugOnlyBridgePrototypeDesignValidationStatus
            .blockedByPolicyBoundary,
        unsafeRecordCount: 1,
        safeForPhase33B: false,
      );
      final result = _safeResult(
        DebugBridgePrototypeDesignReadinessGateRequest(
          validationResult: unsafeValidation,
          designResult: _cachedSafeDesign,
          gateResult: _cachedSafeGate,
        ),
      );

      expect(
        result.gateStatus,
        DebugBridgePrototypeDesignReadinessGateStatus
            .blockedByPrototypeDesignValidationFailure,
      );
      expect(result.safeForPhase33C, isFalse);
      expect(
        result.hasUnsafePrototypeDesignReadinessGatePolicyViolation,
        isTrue,
      );
    });

    test('readiness groups are deterministic and explicit', () {
      final result = _safeResult();

      expect(result.totalGateGroups, 11);
      expect(
        result
            .group(
              DebugBridgePrototypeDesignReadinessGateGroupId
                  .readinessApprovedPrototypeCoreDesignGroup,
            )
            .gateStatus,
        DebugBridgePrototypeDesignReadinessGateGroupStatus
            .readinessApprovedPrototypeCoreDesign,
      );
      expect(
        result
            .group(
              DebugBridgePrototypeDesignReadinessGateGroupId
                  .constrainedPrototypeContextDesignGroup,
            )
            .gateStatus,
        DebugBridgePrototypeDesignReadinessGateGroupStatus
            .constrainedPrototypeContextDesign,
      );
      expect(
        result
            .group(
              DebugBridgePrototypeDesignReadinessGateGroupId
                  .runtimeExecutionBlockedGroup,
            )
            .blockedBoundaryIds,
        orderedEquals(<String>[
          'debugBridgeRuntime',
          'executableDebugBridgePrototype',
        ]),
      );
      expect(
        result
            .group(
              DebugBridgePrototypeDesignReadinessGateGroupId
                  .futurePhase33CRequirementGroup,
            )
            .futurePrerequisites,
        contains(
          'phase33CPrototypeDesignReadinessSummaryOrImplementationDesignCheckpoint',
        ),
      );
    });

    test('readiness records preserve all expected roles', () {
      final result = _safeResult();

      expect(result.totalGateRecords, 11);
      expect(
        result
            .recordForRole(
              DebugBridgePrototypeDesignReadinessGateRole
                  .readinessApprovedPrototypeCoreDesign,
            )
            .gateStatus,
        DebugBridgePrototypeDesignReadinessGateRecordStatus
            .readinessApprovedPrototypeCoreDesign,
      );
      expect(
        result
            .recordForRole(
              DebugBridgePrototypeDesignReadinessGateRole
                  .constrainedPrototypeContextDesign,
            )
            .contextOnly,
        isTrue,
      );
      expect(
        result
            .recordForRole(
              DebugBridgePrototypeDesignReadinessGateRole
                  .inactivePrototypeBlockedDesign,
            )
            .inactive,
        isTrue,
      );
      expect(
        result
            .recordForRole(
              DebugBridgePrototypeDesignReadinessGateRole
                  .runtimeExecutionBlocked,
            )
            .inactive,
        isTrue,
      );
      expect(
        result
            .recordForRole(
              DebugBridgePrototypeDesignReadinessGateRole
                  .futurePhase33CRequirement,
            )
            .gateStatus,
        DebugBridgePrototypeDesignReadinessGateRecordStatus
            .futurePhase33CRequirement,
      );
    });

    test('aggregate counts and Phase 33C recommendation are deterministic', () {
      final result = _safeResult();

      expect(result.readinessApprovedCoreDesignCount, 1);
      expect(result.constrainedContextDesignCount, 1);
      expect(result.inactiveBlockedDesignCount, 1);
      expect(result.inactiveFutureOnlyDesignCount, 1);
      expect(result.approvedAllowedFieldCount, 14);
      expect(result.deniedFieldCount, 18);
      expect(result.stockfishRawUciPvDumpDeniedCount, 3);
      expect(result.runtimeExecutionBlockedCount, 1);
      expect(result.futureRequirementCount, 1);
      expect(result.safeForPhase33C, isTrue);
      expect(
        result.phase33CRecommendation,
        DebugBridgePrototypeDesignReadinessGatePhase33CRecommendation
            .proceedToDebugBridgePrototypeDesignReadinessSummary,
      );
    });

    test('allowed and denied field readiness keeps boundaries', () {
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
              DebugBridgePrototypeDesignReadinessGateRole
                  .stockfishRawUciPvDumpDenied,
            )
            .deniedFieldIds,
        orderedEquals(_engineDumpFieldIds),
      );
    });

    test('Android proof and owner proof boundaries stay honest', () {
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

    test('runtime and executable prototype remain blocked', () {
      final result = _safeResult();

      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.executableDebugBridgePrototypeImplemented, isFalse);
      final runtimeRecord = result.recordForRole(
        DebugBridgePrototypeDesignReadinessGateRole.runtimeExecutionBlocked,
      );
      expect(runtimeRecord.inactive, isTrue);
      expect(runtimeRecord.safetyFlags['implementsRuntime'], isFalse);
      expect(
        runtimeRecord.safetyFlags['implementsPrototypeExecution'],
        isFalse,
      );
      for (final record in result.readinessRecords) {
        expect(record.designOnly, isTrue, reason: record.gateRole.wire);
        expect(record.safetyFlags.values.any((value) => value), isFalse);
      }
    });

    test('no gate record emits product integration or engine output', () {
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
    });

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final validator =
          const DebugBridgePrototypeDesignReadinessGateValidator();

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
      final rows = result.readinessRecords
          .map(
            (row) =>
                row.gateRole ==
                    DebugBridgePrototypeDesignReadinessGateRole
                        .readinessApprovedPrototypeCoreDesign
                ? row.copyWith(
                    contextOnly: true,
                    violationReasons: const [
                      'prototypeCoreConsumesNonCoreInput',
                    ],
                  )
                : row.gateRole ==
                      DebugBridgePrototypeDesignReadinessGateRole
                          .constrainedPrototypeContextDesign
                ? row.copyWith(
                    contextOnly: false,
                    allowedForFutureInternalPrototypePlanning: true,
                  )
                : row,
          )
          .toList(growable: false);
      final ids = const DebugBridgePrototypeDesignReadinessGateValidator()
          .validate(result.copyWith(readinessRecords: rows))
          .map((finding) => finding.id)
          .toSet();

      expect(ids, contains('prototypeCoreConsumesNonCoreInput'));
      expect(ids, contains('contextOnlyInputPromotedToCore'));
    });

    test(
      'validator rejects blocked future activation and active denied fields',
      () {
        final result = _safeResult();
        final rows = result.readinessRecords
            .map(
              (row) =>
                  row.gateRole ==
                      DebugBridgePrototypeDesignReadinessGateRole
                          .inactivePrototypeBlockedDesign
                  ? row.copyWith(
                      inactive: false,
                      allowedFieldIds: const ['debugBridgeRecordId'],
                    )
                  : row,
            )
            .toList(growable: false);
        final ids = const DebugBridgePrototypeDesignReadinessGateValidator()
            .validate(
              result.copyWith(
                readinessRecords: rows,
                allowedFieldIds: const ['productLabel'],
              ),
            )
            .map((finding) => finding.id)
            .toSet();

        expect(ids, contains('blockedFutureDesignMadeActive'));
        expect(ids, contains('activeDeniedField'));
      },
    );

    test('validator rejects policy safety and implementation flags', () {
      final result = _safeResult();
      final validator =
          const DebugBridgePrototypeDesignReadinessGateValidator();
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
      };

      for (final entry in flags.entries) {
        final rows = result.readinessRecords
            .map(
              (row) =>
                  row.gateRole ==
                      DebugBridgePrototypeDesignReadinessGateRole
                          .readinessApprovedPrototypeCoreDesign
                  ? row.copyWith(safetyFlags: <String, bool>{entry.key: true})
                  : row,
            )
            .toList(growable: false);
        expect(
          validator
              .validate(result.copyWith(readinessRecords: rows))
              .map((finding) => finding.id),
          contains(entry.value),
          reason: entry.key,
        );
      }
    });

    test('validator rejects missing future Phase 33C requirement', () {
      final result = _safeResult().copyWith(futureRequirementCount: 0);

      expect(
        const DebugBridgePrototypeDesignReadinessGateValidator()
            .validate(result)
            .map((finding) => finding.id),
        contains('missingFuturePhase33CRequirement'),
      );
    });

    test('result flags reject blocked global integration state', () {
      final result = _safeResult().copyWith(
        debugBridgeRuntimeImplemented: true,
        executableDebugBridgePrototypeImplemented: true,
        uiTargetsActive: true,
        backendOutputActive: true,
        persistenceWritesActive: true,
        engineCallsActive: true,
        stockfishCommandFieldActive: true,
        rawUciFieldActive: true,
        pvDumpFieldActive: true,
      );

      expect(
        const DebugBridgePrototypeDesignReadinessGateValidator()
            .validate(result)
            .map((finding) => finding.id),
        contains(
          'debugBridgePrototypeDesignReadinessGateBoundaryPolicyViolation',
        ),
      );
    });

    test('markdown report includes required readiness sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(
        report,
        contains('# Debug Bridge Prototype Design Readiness Gate'),
      );
      expect(report, contains('## Readiness Group Table'));
      expect(report, contains('## Readiness Record Table'));
      expect(report, contains('## Prototype Core Design Readiness'));
      expect(report, contains('## Context-Only Design Readiness'));
      expect(report, contains('## Allowed And Denied Field Readiness'));
      expect(report, contains('## Stockfish Raw UCI PV Dump Denied Status'));
      expect(
        report,
        contains('## Runtime/Executable Prototype Blocked Status'),
      );
      expect(report, contains('## Phase 33C Recommendation'));
      _expectReportGuardrails(report);
    });

    test('JSON report is deterministic and valid', () {
      final first = _safeResult().renderJsonReport();
      final second = _safeResult().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        debugBridgePrototypeDesignReadinessGateReportVersion,
      );
      expect(decoded['totalGateGroups'], 11);
      expect(decoded['totalGateRecords'], 11);
      expect(decoded['approvedAllowedFieldCount'], 14);
      expect(decoded['deniedFieldCount'], 18);
      expect(decoded['runtimeExecutionBlockedCount'], 1);
      expect(decoded['futureRequirementCount'], 1);
      expect(decoded['safeForPhase33C'], isTrue);
    });

    test('reports contain no raw UCI spam or active product outputs', () {
      final report = _safeResult().renderMarkdownReport();

      _expectReportGuardrails(report);
      expect(
        const DebugBridgePrototypeDesignReadinessGateValidator()
            .validateReportText(report),
        isEmpty,
      );
    });

    test('source imports stay pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/debug_bridge_prototype_design_readiness_gate.dart',
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

DebugBridgePrototypeDesignReadinessGateResult _safeResult([
  DebugBridgePrototypeDesignReadinessGateRequest? request,
]) {
  if (request != null) {
    return const DebugBridgePrototypeDesignReadinessGate().evaluate(request);
  }
  return _cachedSafeReadinessGate;
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
