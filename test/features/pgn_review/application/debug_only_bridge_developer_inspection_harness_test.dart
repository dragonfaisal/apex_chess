@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug-Only Bridge Developer Inspection Harness', () {
    test('inspects safe Phase 33G validation and recommends Phase 33I', () {
      final result = _safeInspection;

      expect(
        result.status,
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
      expect(result.safeForPhase33I, isTrue);
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
        result.phase33IRecommendation,
        DebugOnlyBridgeDeveloperInspectionPhase33IRecommendation
            .validateDebugOnlyBridgeDeveloperInspectionHarness,
      );
    });

    test(
      'inspection snapshot exposes deterministic developer-only summaries',
      () {
        final snapshot = _safeInspection.snapshot;

        expect(
          snapshot.snapshotId,
          'phase33h-debug-only-bridge-developer-inspection-snapshot',
        );
        expect(
          snapshot.inputPacketId,
          _safeInspection.inputPacket.inputPacketId,
        );
        expect(
          snapshot.outputPacketId,
          _safeInspection.outputPacket.outputPacketId,
        );
        expect(snapshot.developerOnly, isTrue);
        expect(snapshot.skeletonOnly, isTrue);
        expect(snapshot.hasUnsafeInspectionOutput, isFalse);
        expect(snapshot.recordRoleSummary['core'], 1);
        expect(snapshot.recordRoleSummary['context'], 1);
        expect(snapshot.recordRoleSummary['inactiveBlocked'], 1);
        expect(snapshot.recordRoleSummary['inactiveFuture'], 1);
        expect(snapshot.allowedFieldSummary, orderedEquals(_allowedFieldIds));
        expect(snapshot.deniedFieldSummary, orderedEquals(_deniedFieldIds));
        expect(
          snapshot.proofBoundarySummary,
          orderedEquals(_capturedAndroidProofIds),
        );
        expect(
          snapshot.futurePrerequisiteSummary,
          contains('phase33IValidateDebugOnlyBridgeDeveloperInspectionHarness'),
        );
      },
    );

    test(
      'inspection rows cover packets policy and all bridge record roles',
      () {
        final result = _safeInspection;

        expect(result.totalInspectionRows, 14);
        expect(result.inputPacketInspectionCount, 1);
        expect(result.outputPacketInspectionCount, 1);
        expect(result.policyInspectionCount, 1);
        expect(result.recordInspectionCount, 11);
        expect(result.coreRecordInspectionCount, 1);
        expect(result.contextRecordInspectionCount, 1);
        expect(result.inactiveRecordInspectionCount, 2);
        expect(result.deniedBoundaryInspectionCount, 2);
        expect(result.runtimeBlockedInspectionCount, 1);
        expect(result.proofBoundaryInspectionCount, 1);

        final input = result.rowForRole(
          DebugOnlyBridgeDeveloperInspectionRowRole.inputPacketInspection,
        );
        final context = result.rowForRole(
          DebugOnlyBridgeDeveloperInspectionRowRole.contextRecordInspection,
        );
        final inactive = result.rowsForRole(
          DebugOnlyBridgeDeveloperInspectionRowRole.inactiveRecordInspection,
        );
        final stockfish = result.rowForRole(
          DebugOnlyBridgeDeveloperInspectionRowRole
              .stockfishRawUciPvDumpDeniedInspection,
        );

        expect(
          input.status,
          DebugOnlyBridgeDeveloperInspectionRowStatus.inspected,
        );
        expect(context.contextOnly, isTrue);
        expect(inactive, hasLength(2));
        expect(inactive.every((row) => row.inactive), isTrue);
        expect(
          stockfish.deniedFieldIds,
          orderedEquals(<String>['pvDump', 'rawUci', 'stockfishCommand']),
        );
        expect(
          result.inspectionRows.every((row) => row.findings.isEmpty),
          isTrue,
        );
      },
    );

    test('harness helper methods inspect the same safe row boundaries', () {
      const harness = DebugOnlyBridgeDeveloperInspectionHarness();
      final inputRow = harness.inspectInputPacket(_safeInspection.inputPacket);
      final outputRow = harness.inspectOutputPacket(
        _safeInspection.outputPacket,
      );
      final policyRow = harness.inspectPolicy(_safeInspection.policy);
      final deniedRows = harness.inspectDeniedBoundaries(
        _safeInspection.outputPacket,
      );
      final runtimeRows = harness.inspectRuntimeBoundaries(
        _safeInspection.outputPacket,
      );
      final proofRows = harness.inspectProofBoundaries(
        _safeInspection.outputPacket,
      );

      expect(inputRow.findings, isEmpty);
      expect(outputRow.findings, isEmpty);
      expect(policyRow.findings, isEmpty);
      expect(deniedRows, hasLength(2));
      expect(runtimeRows, hasLength(1));
      expect(proofRows, hasLength(2));
    });

    test('unsafe skeleton validation or skeleton input blocks inspection', () {
      final unsafeValidation = _safeInspection.skeletonValidationResult
          .copyWith(
            status: DebugOnlyBridgeDeveloperSkeletonValidationStatus
                .blockedByPolicyBoundary,
            safeForPhase33H: false,
            unsafeCount: 1,
            productOutputActive: true,
          );
      final unsafeSkeleton = _safeInspection.skeletonResult.copyWith(
        status: DebugOnlyBridgeSkeletonStatus.blockedByPolicyBoundary,
        safeForPhase33G: false,
        unsafeCount: 1,
        productOutputActive: true,
      );

      final validationResult = _evaluate(
        DebugOnlyBridgeDeveloperInspectionHarnessRequest(
          skeletonValidationResult: unsafeValidation,
        ),
      );
      final skeletonResult = _evaluate(
        DebugOnlyBridgeDeveloperInspectionHarnessRequest(
          skeletonResult: unsafeSkeleton,
        ),
      );

      expect(
        validationResult.status,
        DebugOnlyBridgeDeveloperInspectionHarnessStatus.blockedByPolicyBoundary,
      );
      expect(validationResult.safeForPhase33I, isFalse);
      expect(
        skeletonResult.status,
        DebugOnlyBridgeDeveloperInspectionHarnessStatus.blockedByPolicyBoundary,
      );
      expect(skeletonResult.safeForPhase33I, isFalse);
    });

    test('validator rejects missing Phase 33I requirement', () {
      final rows = _safeInspection.inspectionRows
          .where(
            (row) =>
                row.role !=
                DebugOnlyBridgeDeveloperInspectionRowRole
                    .futureRequirementInspection,
          )
          .toList(growable: false);
      final ids = const DebugOnlyBridgeDeveloperInspectionHarnessValidator()
          .validate(_safeInspection.copyWith(inspectionRows: rows))
          .map((finding) => finding.id)
          .toSet();

      expect(ids, contains('missingPhase33IRequirement'));
    });

    test('validator rejects active denied and scheduler execution fields', () {
      final rows = _safeInspection.inspectionRows
          .map(
            (row) =>
                row.role ==
                    DebugOnlyBridgeDeveloperInspectionRowRole
                        .inputPacketInspection
                ? row.copyWith(
                    allowedFieldIds: <String>[
                      ...row.allowedFieldIds,
                      'productLabel',
                      'schedulerExecution',
                    ],
                  )
                : row,
          )
          .toList(growable: false);
      final result = _safeInspection.copyWith(inspectionRows: rows);
      final ids = const DebugOnlyBridgeDeveloperInspectionHarnessValidator()
          .validate(result)
          .map((finding) => finding.id)
          .toSet();

      expect(ids, contains('activeDeniedField'));
      expect(
        rows
            .firstWhere(
              (row) =>
                  row.role ==
                  DebugOnlyBridgeDeveloperInspectionRowRole
                      .inputPacketInspection,
            )
            .hasActiveDeniedField,
        isTrue,
      );
    });

    test('policy activation is counted and blocks evaluated inspection', () {
      final policy = _safeInspection.policy.copyWith(
        allowRawUci: true,
        allowDirectEngine: true,
      );
      final result = _evaluate(
        DebugOnlyBridgeDeveloperInspectionHarnessRequest(policy: policy),
      );

      expect(
        result.status,
        DebugOnlyBridgeDeveloperInspectionHarnessStatus.blockedByPolicyBoundary,
      );
      expect(result.safeForPhase33I, isFalse);
      expect(result.rawUciLeakCount, greaterThan(0));
      expect(result.engineCallCount, greaterThan(0));
    });

    test('validator rejects record boundary and proof violations', () {
      final rows = _safeInspection.inspectionRows
          .map(
            (row) =>
                row.role ==
                    DebugOnlyBridgeDeveloperInspectionRowRole
                        .contextRecordInspection
                ? row.copyWith(contextOnly: false)
                : row.role ==
                      DebugOnlyBridgeDeveloperInspectionRowRole
                          .inactiveRecordInspection
                ? row.copyWith(inactive: false)
                : row.role ==
                      DebugOnlyBridgeDeveloperInspectionRowRole
                          .proofBoundaryInspection
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
      final ids = const DebugOnlyBridgeDeveloperInspectionHarnessValidator()
          .validate(_safeInspection.copyWith(inspectionRows: rows))
          .map((finding) => finding.id)
          .toSet();

      expect(ids, contains('contextRecordPromotedToCore'));
      expect(ids, contains('inactiveRecordMadeActive'));
      expect(ids, contains('unprovenAndroidProofId'));
      expect(ids, contains('phase32ECaseClaimedAsCapturedProof'));
    });

    test('validator rejects owner proof queue without explicit PV reason', () {
      final snapshot = _safeInspection.snapshot.copyWith(
        warningSummary: const <String>[],
        futurePrerequisiteSummary: const <String>[
          'phase33IValidateDebugOnlyBridgeDeveloperInspectionHarness',
        ],
      );
      final rows = _safeInspection.inspectionRows
          .map(
            (row) => row.copyWith(
              warningReasons: const <String>[],
              proofLimitReasons: const <String>[],
            ),
          )
          .toList(growable: false);
      final ids = const DebugOnlyBridgeDeveloperInspectionHarnessValidator()
          .validate(
            _safeInspection.copyWith(
              ownerProofQueueCount: 1,
              snapshot: snapshot,
              inspectionRows: rows,
            ),
          )
          .map((finding) => finding.id)
          .toSet();

      expect(ids, contains('ownerProofRequiredWithoutPvReason'));
    });

    test('markdown and JSON reports are deterministic and safe', () {
      final markdown = _safeInspection.renderMarkdownReport();
      final json = _safeInspection.renderJsonReport();
      final decoded = jsonDecode(json) as Map<String, Object?>;

      expect(
        markdown,
        contains('# Debug-Only Bridge Developer Inspection Harness'),
      );
      expect(markdown, contains('## Inspection Snapshot Summary'));
      expect(markdown, contains('## Input Packet Inspection'));
      expect(markdown, contains('## Output Packet Inspection'));
      expect(markdown, contains('## Policy Inspection'));
      expect(markdown, contains('## Bridge Record Inspection Table'));
      expect(
        markdown,
        contains('## Runtime/Prototype/Wiring Blocked Inspection'),
      );
      expect(
        markdown,
        contains('validateDebugOnlyBridgeDeveloperInspectionHarness'),
      );
      expect(
        decoded['version'],
        debugOnlyBridgeDeveloperInspectionHarnessReportVersion,
      );
      expect(decoded['status'], 'inspectionReadyWithWarnings');
      expect(decoded['totalInspectionRows'], 14);
      expect(decoded['safeForPhase33I'], isTrue);
      expect(
        decoded['phase33IRecommendation'],
        'validateDebugOnlyBridgeDeveloperInspectionHarness',
      );
      expect(
        const DebugOnlyBridgeDeveloperInspectionHarnessValidator()
            .validateReportText(markdown),
        isEmpty,
      );
    });

    test('report and source keep integration guardrails', () {
      final report = _safeInspection.renderMarkdownReport();
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_developer_inspection_harness.dart',
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

DebugOnlyBridgeDeveloperInspectionHarnessResult _evaluate(
  DebugOnlyBridgeDeveloperInspectionHarnessRequest request,
) {
  return const DebugOnlyBridgeDeveloperInspectionHarness().evaluate(request);
}

final DebugOnlyBridgeDeveloperInspectionHarnessResult _safeInspection =
    const DebugOnlyBridgeDeveloperInspectionHarness().inspectSafeDemo();

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
