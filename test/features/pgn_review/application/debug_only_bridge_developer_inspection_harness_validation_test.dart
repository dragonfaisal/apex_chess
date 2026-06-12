@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug-Only Bridge Developer Inspection Harness Validation', () {
    test('validates safe Phase 33H harness and recommends Phase 33J', () {
      final result = _safeValidation;

      expect(
        result.status,
        DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
            .inspectionHarnessValidatedWithWarnings,
      );
      expect(
        result.sourceInspectionHarnessStatus,
        DebugOnlyBridgeDeveloperInspectionHarnessStatus
            .inspectionReadyWithWarnings,
      );
      expect(
        result.sourceSkeletonValidationStatus,
        DebugOnlyBridgeDeveloperSkeletonValidationStatus
            .skeletonValidatedWithWarnings,
      );
      expect(
        result.sourceSkeletonStatus,
        DebugOnlyBridgeSkeletonStatus.skeletonReadyWithWarnings,
      );
      expect(result.safeForPhase33J, isTrue);
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.activeDeniedFieldCount, 0);
      expect(result.productOutputCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
      expect(result.uiTargetCount, 0);
      expect(result.persistenceWriteCount, 0);
      expect(
        result.phase33JRecommendation,
        DebugOnlyBridgeDeveloperInspectionHarnessValidationPhase33JRecommendation
            .proceedToDebugOnlyBridgeDeveloperDiagnosticCommand,
      );
    });

    test('validation checks are deterministic and all pass for safe demo', () {
      final result = _safeValidation;

      expect(result.totalChecks, 20);
      expect(result.passedCheckCount, 20);
      expect(result.warningCheckCount, 0);
      expect(
        result.validationChecks.map((check) => check.checkId.wire),
        orderedEquals(
          DebugOnlyBridgeDeveloperInspectionHarnessValidationCheckId.values.map(
            (checkId) => checkId.wire,
          ),
        ),
      );
      expect(
        result.validationChecks.every((check) => check.checkStatus.isPassed),
        isTrue,
      );
      expect(result.validationFindings, isEmpty);
    });

    test('snapshot validation is developer-only and safe', () {
      final row = _safeValidation.rowForRole(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
            .snapshotValidation,
      );

      expect(_safeValidation.snapshotValidationCount, 1);
      expect(row.validationRowId, 'phase33i-snapshot');
      expect(row.sourceSnapshotId, _safeValidation.snapshot.snapshotId);
      expect(row.developerOnly, isTrue);
      expect(row.skeletonOnly, isTrue);
      expect(row.contextOnly, isFalse);
      expect(row.inactive, isFalse);
      expect(row.allowedFieldIds, orderedEquals(_allowedFieldIds));
      expect(row.deniedFieldIds, orderedEquals(_deniedFieldIds));
      expect(row.androidProofCaseIds, orderedEquals(_capturedAndroidProofIds));
      expect(
        row.futurePrerequisites,
        contains('phase33JDebugOnlyBridgeDeveloperDiagnosticCommand'),
      );
      expect(row.hasUnsafeOutput, isFalse);
    });

    test('input output and policy validation rows remain safe', () {
      final result = _safeValidation;
      final input = result.rowForRole(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
            .inputPacketInspectionValidation,
      );
      final output = result.rowForRole(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
            .outputPacketInspectionValidation,
      );
      final policy = result.rowForRole(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
            .policyInspectionValidation,
      );

      expect(result.inputPacketValidationCount, 1);
      expect(result.outputPacketValidationCount, 1);
      expect(result.policyValidationCount, 1);
      expect(input.hasUnsafeOutput, isFalse);
      expect(output.hasUnsafeOutput, isFalse);
      expect(policy.hasUnsafeOutput, isFalse);
      expect(input.deniedFieldIds, orderedEquals(_deniedFieldIds));
      expect(output.deniedFieldIds, orderedEquals(_deniedFieldIds));
      expect(policy.deniedFieldIds, orderedEquals(_deniedFieldIds));
      expect(result.policy.hasUnsafeAllowance, isFalse);
      expect(result.outputPacket.safeForDeveloperInspection, isTrue);
    });

    test('inspection row validation preserves roles and counts', () {
      final result = _safeValidation;

      expect(result.totalValidationRows, 15);
      expect(result.recordValidationCount, 11);
      expect(result.validCoreInspectionCount, 1);
      expect(result.validContextInspectionCount, 1);
      expect(result.validInactiveInspectionCount, 2);
      expect(result.validDeniedBoundaryInspectionCount, 3);
      expect(result.validRuntimeBlockedInspectionCount, 1);
      expect(result.invalidRowCount, 0);
      expect(result.unsafeRowCount, 0);
      expect(
        result
            .rowForRole(
              DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                  .coreRecordInspectionValidation,
            )
            .contextOnly,
        isFalse,
      );
      expect(
        result
            .rowForRole(
              DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                  .contextRecordInspectionValidation,
            )
            .contextOnly,
        isTrue,
      );
      expect(
        result
            .rowsForRole(
              DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                  .inactiveRecordInspectionValidation,
            )
            .every((row) => row.inactive),
        isTrue,
      );
    });

    test('allowed denied proof and runtime boundaries remain explicit', () {
      final result = _safeValidation;
      final stockfish = result.rowForRole(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
            .stockfishRawUciPvDumpDeniedInspectionValidation,
      );
      final runtime = result.rowForRole(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
            .runtimeBlockedInspectionValidation,
      );
      final proof = result.rowForRole(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
            .proofBoundaryInspectionValidation,
      );

      expect(
        result.snapshot.allowedFieldSummary,
        orderedEquals(_allowedFieldIds),
      );
      expect(
        result.snapshot.deniedFieldSummary,
        orderedEquals(_deniedFieldIds),
      );
      expect(
        stockfish.deniedFieldIds,
        orderedEquals(<String>['pvDump', 'rawUci', 'stockfishCommand']),
      );
      expect(runtime.blockedBoundaryIds, contains('debugBridgeRuntime'));
      expect(result.runtimeEnabledCount, 0);
      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.executableBridgeSkeletonImplemented, isFalse);
      expect(result.executableDebugBridgePrototypeImplemented, isFalse);
      expect(result.implementationWiringImplemented, isFalse);
      expect(
        proof.androidProofCaseIds,
        orderedEquals(_capturedAndroidProofIds),
      );
    });

    test('aggregate leak counters remain zero for safe demo', () {
      final result = _safeValidation;

      expect(result.labelLeakCount, 0);
      expect(result.scoreLeakCount, 0);
      expect(result.metricLeakCount, 0);
      expect(result.cpLossLeakCount, 0);
      expect(result.winProbabilityLeakCount, 0);
      expect(result.uiTargetCount, 0);
      expect(result.backendTargetCount, 0);
      expect(result.persistenceWriteCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
      expect(result.stockfishCommandLeakCount, 0);
      expect(result.rawUciLeakCount, 0);
      expect(result.pvDumpLeakCount, 0);
      expect(
        result
            .hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessValidationPolicyViolation,
        isFalse,
      );
    });

    test('unsafe harness skeleton validation and skeleton input block', () {
      final unsafeHarness = _safeValidation.inspectionHarnessResult.copyWith(
        status: DebugOnlyBridgeDeveloperInspectionHarnessStatus
            .blockedByPolicyBoundary,
        unsafeCount: 1,
        safeForPhase33I: false,
        productOutputActive: true,
      );
      final unsafeValidation = _safeValidation.skeletonValidationResult
          .copyWith(
            status: DebugOnlyBridgeDeveloperSkeletonValidationStatus
                .blockedByPolicyBoundary,
            safeForPhase33H: false,
            unsafeCount: 1,
            productOutputActive: true,
          );
      final unsafeSkeleton = _safeValidation.skeletonResult.copyWith(
        status: DebugOnlyBridgeSkeletonStatus.blockedByPolicyBoundary,
        safeForPhase33G: false,
        unsafeCount: 1,
        productOutputActive: true,
      );

      final harnessResult = _evaluate(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest(
          inspectionHarnessResult: unsafeHarness,
        ),
      );
      final validationResult = _evaluate(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest(
          skeletonValidationResult: unsafeValidation,
        ),
      );
      final skeletonResult = _evaluate(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest(
          skeletonResult: unsafeSkeleton,
        ),
      );

      expect(
        harnessResult.status,
        DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
            .blockedByPolicyBoundary,
      );
      expect(validationResult.safeForPhase33J, isFalse);
      expect(
        validationResult.status,
        DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
            .blockedByUnsafeInspectionHarness,
      );
      expect(
        skeletonResult.status,
        DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
            .blockedByUnsafeInspectionHarness,
      );
    });

    test('validator rejects missing Phase 33J requirement', () {
      final rows = _safeValidation.validationRows
          .where(
            (row) =>
                row.role !=
                DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                    .futureRequirementInspectionValidation,
          )
          .toList(growable: false);
      final ids =
          const DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator()
              .validate(_safeValidation.copyWith(validationRows: rows))
              .map((finding) => finding.id)
              .toSet();

      expect(ids, contains('missingPhase33JRequirement'));
    });

    test('validator rejects active denied scheduler and dump fields', () {
      final rows = _safeValidation.validationRows
          .map(
            (row) =>
                row.role ==
                    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                        .inputPacketInspectionValidation
                ? row.copyWith(
                    allowedFieldIds: <String>[
                      ...row.allowedFieldIds,
                      'productLabel',
                      'schedulerExecution',
                      'stockfishCommand',
                      'rawUci',
                      'pvDump',
                    ],
                  )
                : row,
          )
          .toList(growable: false);
      final ids =
          const DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator()
              .validate(_safeValidation.copyWith(validationRows: rows))
              .map((finding) => finding.id)
              .toSet();

      expect(ids, contains('activeDeniedField'));
      expect(ids, contains('schedulerExecutionFieldActive'));
      expect(ids, contains('stockfishRawUciPvDumpFieldActive'));
    });

    test('validator rejects role and proof boundary violations', () {
      final rows = _safeValidation.validationRows
          .map(
            (row) =>
                row.role ==
                    DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                        .contextRecordInspectionValidation
                ? row.copyWith(contextOnly: false)
                : row.role ==
                      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                          .inactiveRecordInspectionValidation
                ? row.copyWith(inactive: false)
                : row.role ==
                      DebugOnlyBridgeDeveloperInspectionHarnessValidationRowRole
                          .proofBoundaryInspectionValidation
                ? row.copyWith(
                    androidProofCaseIds: <String>[
                      ...row.androidProofCaseIds,
                      'pv-multipv-support-boundary-32e',
                      'unproven-proof-id',
                    ],
                  )
                : row,
          )
          .toList(growable: false);
      final ids =
          const DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator()
              .validate(_safeValidation.copyWith(validationRows: rows))
              .map((finding) => finding.id)
              .toSet();

      expect(ids, contains('contextInspectionPromotedToCore'));
      expect(ids, contains('inactiveInspectionMadeActive'));
      expect(ids, contains('unprovenAndroidProofId'));
      expect(ids, contains('phase32ECaseClaimedAsCapturedProof'));
    });

    test('validator rejects owner proof without explicit PV reason', () {
      final snapshot = _safeValidation.snapshot.copyWith(
        warningSummary: const <String>[],
        futurePrerequisiteSummary: const <String>[
          'phase33JDebugOnlyBridgeDeveloperDiagnosticCommand',
        ],
      );
      final rows = _safeValidation.validationRows
          .map(
            (row) => row.copyWith(
              warningReasons: const <String>[],
              proofLimitReasons: const <String>[],
            ),
          )
          .toList(growable: false);
      final ids =
          const DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator()
              .validate(
                _safeValidation.copyWith(
                  snapshot: snapshot,
                  validationRows: rows,
                  ownerProofQueueCount: 1,
                ),
              )
              .map((finding) => finding.id)
              .toSet();

      expect(ids, contains('ownerProofRequiredWithoutPvReason'));
    });

    test('policy and runtime activation block evaluated validation', () {
      final policy = _safeValidation.policy.copyWith(
        allowRawUci: true,
        allowDirectEngine: true,
        allowRuntime: true,
      );
      final result = _evaluate(
        DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest(
          policy: policy,
        ),
      );

      expect(
        result.status,
        anyOf(
          DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
              .blockedByPolicyBoundary,
          DebugOnlyBridgeDeveloperInspectionHarnessValidationStatus
              .blockedByUnsafeInspectionHarness,
        ),
      );
      expect(result.safeForPhase33J, isFalse);
      expect(result.policy.hasUnsafeAllowance, isTrue);
      expect(result.policy.allowRawUci, isTrue);
      expect(result.policy.allowDirectEngine, isTrue);
    });

    test('markdown and JSON reports are deterministic and safe', () {
      final markdown = _safeValidation.renderMarkdownReport();
      final json = _safeValidation.renderJsonReport();
      final decoded = jsonDecode(json) as Map<String, Object?>;

      expect(
        markdown,
        contains('# Debug-Only Bridge Developer Inspection Harness Validation'),
      );
      expect(markdown, contains('## Validation Check Table'));
      expect(markdown, contains('## Snapshot Validation'));
      expect(markdown, contains('## Input/Output Packet Validation'));
      expect(markdown, contains('## Policy Validation'));
      expect(markdown, contains('## Inspection Row Validation Table'));
      expect(markdown, contains('## Stockfish/Raw UCI/PV Denial Validation'));
      expect(
        markdown,
        contains('## Runtime/Prototype/Wiring Blocked Validation'),
      );
      expect(markdown, contains('## Scheduler Execution Denied Validation'));
      expect(
        markdown,
        contains('proceedToDebugOnlyBridgeDeveloperDiagnosticCommand'),
      );
      expect(
        decoded['version'],
        debugOnlyBridgeDeveloperInspectionHarnessValidationReportVersion,
      );
      expect(decoded['status'], 'inspectionHarnessValidatedWithWarnings');
      expect(decoded['totalChecks'], 20);
      expect(decoded['totalValidationRows'], 15);
      expect(decoded['safeForPhase33J'], isTrue);
      expect(
        decoded['phase33JRecommendation'],
        'proceedToDebugOnlyBridgeDeveloperDiagnosticCommand',
      );
      expect(
        const DebugOnlyBridgeDeveloperInspectionHarnessValidationValidator()
            .validateReportText(markdown),
        isEmpty,
      );
    });

    test('report and source keep integration guardrails', () {
      final report = _safeValidation.renderMarkdownReport();
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_developer_inspection_harness_validation.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        'pv e2e4',
        'pvMoves',
        'active fields: productLabel',
        'allowed fields: productLabel',
        'allowed fields: schedulerExecution',
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

      expect(source, isNot(contains('Process.run')));
      expect(source, isNot(contains('Process.start')));
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
      expect(imports, isNot(contains('scheduler')));
    });
  });
}

DebugOnlyBridgeDeveloperInspectionHarnessValidationResult _evaluate(
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest request,
) {
  return const DebugOnlyBridgeDeveloperInspectionHarnessValidation().evaluate(
    request,
  );
}

final DebugOnlyBridgeDeveloperInspectionHarnessValidationResult
_safeValidation = const DebugOnlyBridgeDeveloperInspectionHarnessValidation()
    .evaluate();

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
  'schedulerExecution',
  'stockfishCommand',
  'uiOutput',
  'winProbability',
];

const _capturedAndroidProofIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];
