@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_implementation_design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug-Only Bridge Developer Skeleton Validation', () {
    test(
      'validates safe Phase 33F skeleton and recommends inspection harness',
      () {
        final result = _safeValidation();

        expect(
          result.status,
          DebugOnlyBridgeDeveloperSkeletonValidationStatus
              .skeletonValidatedWithWarnings,
        );
        expect(
          result.sourceSkeletonStatus,
          DebugOnlyBridgeSkeletonStatus.skeletonReadyWithWarnings,
        );
        expect(
          result.sourceImplementationDesignStatus,
          DebugOnlyBridgeImplementationDesignStatus
              .implementationDesignReadyWithWarnings,
        );
        expect(result.safeForPhase33H, isTrue);
        expect(result.unsafeCount, 0);
        expect(result.blockerCount, 0);
        expect(result.criticalCount, 0);
        expect(result.ownerProofQueueCount, 0);
        expect(result.activeDeniedFieldCount, 0);
        expect(result.productOutputCount, 0);
        expect(result.runtimeEnabledCount, 0);
        expect(result.engineCallCount, 0);
        expect(result.uiTargetCount, 0);
        expect(result.persistenceWriteCount, 0);
        expect(
          result.phase33HRecommendation,
          DebugOnlyBridgeDeveloperSkeletonValidationPhase33HRecommendation
              .proceedToDebugOnlyBridgeDeveloperInspectionHarness,
        );
      },
    );

    test('validation checks are deterministic and all pass for safe demo', () {
      final result = _safeValidation();

      expect(result.totalChecks, 19);
      expect(result.passedCheckCount, 19);
      expect(result.warningCheckCount, 0);
      expect(
        result.validationChecks.map((check) => check.checkId),
        orderedEquals(DebugOnlyBridgeDeveloperSkeletonValidationCheckId.values),
      );
      expect(
        result.validationChecks.every((check) => check.checkStatus.isPassed),
        isTrue,
      );
    });

    test('input, output, and policy rows validate safe packets only', () {
      final result = _safeValidation();
      final input = result.rowForRole(
        DebugOnlyBridgeDeveloperSkeletonValidationRowRole.inputPacket,
      );
      final output = result.rowForRole(
        DebugOnlyBridgeDeveloperSkeletonValidationRowRole.outputPacket,
      );
      final policy = result.rowForRole(
        DebugOnlyBridgeDeveloperSkeletonValidationRowRole.policy,
      );

      expect(
        input.status,
        DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validInputPacket,
      );
      expect(
        output.status,
        DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validOutputPacket,
      );
      expect(
        policy.status,
        DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validPolicy,
      );
      for (final row in <DebugOnlyBridgeDeveloperSkeletonValidationRow>[
        input,
        output,
        policy,
      ]) {
        expect(row.developerOnly, isTrue);
        expect(row.designOnly, isTrue);
        expect(row.allowedFieldIds, orderedEquals(_allowedFieldIds));
        expect(row.deniedFieldIds, orderedEquals(_deniedFieldIds));
        expect(row.findings, isEmpty);
        expect(row.safetyFlags.values.any((value) => value), isFalse);
      }
    });

    test(
      'bridge record rows preserve core context inactive and boundary roles',
      () {
        final result = _safeValidation();

        expect(result.totalValidationRows, 14);
        expect(result.inputPacketValidationCount, 1);
        expect(result.outputPacketValidationCount, 1);
        expect(result.policyValidationCount, 1);
        expect(result.recordValidationCount, 11);
        expect(result.validCoreRecordCount, 1);
        expect(result.validContextRecordCount, 1);
        expect(result.validInactiveRecordCount, 2);
        expect(result.validDeniedBoundaryCount, 2);
        expect(result.validRuntimeBlockedCount, 1);
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeDeveloperSkeletonValidationRowRole.core,
              )
              .status,
          DebugOnlyBridgeDeveloperSkeletonValidationRowStatus.validCoreRecord,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeDeveloperSkeletonValidationRowRole.context,
              )
              .contextOnly,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                    .inactiveBlocked,
              )
              .inactive,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                    .inactiveFuture,
              )
              .inactive,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                    .stockfishRawUciPvDumpDenied,
              )
              .deniedFieldIds,
          orderedEquals(<String>['pvDump', 'rawUci', 'stockfishCommand']),
        );
      },
    );

    test('aggregate leak counters stay zero for safe demo', () {
      final result = _safeValidation();

      expect(result.invalidRecordCount, 0);
      expect(result.unsafeRecordCount, 0);
      expect(result.labelLeakCount, 0);
      expect(result.scoreLeakCount, 0);
      expect(result.metricLeakCount, 0);
      expect(result.cpLossLeakCount, 0);
      expect(result.winProbabilityLeakCount, 0);
      expect(result.backendTargetCount, 0);
      expect(result.schedulerExecutionCount, 0);
      expect(result.stockfishCommandLeakCount, 0);
      expect(result.rawUciLeakCount, 0);
      expect(result.pvDumpLeakCount, 0);
      expect(
        result
            .hasUnsafeDebugOnlyBridgeDeveloperSkeletonValidationPolicyViolation,
        isFalse,
      );
    });

    test(
      'validator rejects unsafe skeleton or implementation design marked safe',
      () {
        final safe = _safeValidation();
        final unsafeSkeleton = safe.skeletonResult.copyWith(
          status: DebugOnlyBridgeSkeletonStatus.blockedByPolicyBoundary,
          safeForPhase33G: false,
          unsafeCount: 1,
        );
        final unsafeImplementation = safe.implementationDesignResult.copyWith(
          implementationDesignStatus: DebugOnlyBridgeImplementationDesignStatus
              .blockedByUnsafeReadinessValidation,
          safeForPhase33F: false,
          unsafeCount: 1,
        );
        final ids = const DebugOnlyBridgeDeveloperSkeletonValidationValidator()
            .validate(
              safe.copyWith(
                skeletonResult: unsafeSkeleton,
                implementationDesignResult: unsafeImplementation,
                safeForPhase33H: true,
                unsafeCount: 1,
              ),
            )
            .map((finding) => finding.id)
            .toSet();

        expect(ids, contains('unsafeSkeletonResultMarkedValid'));
        expect(ids, contains('unsafeImplementationDesignInput'));
      },
    );

    test('unsafe skeleton input blocks validation result', () {
      final unsafeSkeleton = _safeSkeleton.copyWith(
        status: DebugOnlyBridgeSkeletonStatus.blockedByPolicyBoundary,
        safeForPhase33G: false,
        unsafeCount: 1,
        productOutputActive: true,
      );
      final result = _evaluate(
        DebugOnlyBridgeDeveloperSkeletonValidationRequest(
          skeletonResult: unsafeSkeleton,
        ),
      );

      expect(
        result.status,
        DebugOnlyBridgeDeveloperSkeletonValidationStatus
            .blockedByPolicyBoundary,
      );
      expect(result.safeForPhase33H, isFalse);
      expect(result.productOutputCount, greaterThan(0));
    });

    test('validator rejects missing Phase 33H requirement', () {
      final result = _safeValidation();
      final rows = result.validationRows
          .where(
            (row) =>
                row.role !=
                DebugOnlyBridgeDeveloperSkeletonValidationRowRole
                    .futureRequirement,
          )
          .toList(growable: false);
      final ids = const DebugOnlyBridgeDeveloperSkeletonValidationValidator()
          .validate(result.copyWith(validationRows: rows))
          .map((finding) => finding.id)
          .toSet();

      expect(ids, contains('missingPhase33HRequirement'));
    });

    test('active denied fields and scheduler execution are rejected', () {
      final result = _evaluate(
        DebugOnlyBridgeDeveloperSkeletonValidationRequest(
          inputPacket: _safeSkeleton.inputPacket.copyWith(
            allowedFieldIds: const <String>[
              'productLabel',
              'schedulerExecution',
            ],
          ),
        ),
      );

      expect(
        result.status,
        DebugOnlyBridgeDeveloperSkeletonValidationStatus
            .blockedByPolicyBoundary,
      );
      expect(result.activeDeniedFieldCount, 1);
      expect(result.schedulerExecutionCount, 1);
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('activeDeniedField'),
      );
    });

    test(
      'policy flags reject product labels scores metrics and integrations',
      () {
        final unsafePolicy = _safeSkeleton.policy.copyWith(
          allowProductOutput: true,
          allowClassifierLabels: true,
          allowNumericScores: true,
          allowAggregateScores: true,
          allowOfficialMetrics: true,
          allowCpLoss: true,
          allowWinProbability: true,
          allowMoveRanking: true,
          allowUi: true,
          allowBackend: true,
          allowPersistence: true,
          allowDirectEngine: true,
          allowStockfishCommand: true,
          allowRawUci: true,
          allowPvDump: true,
          allowRuntime: true,
          allowExecutablePrototype: true,
          allowWiring: true,
        );
        final result = _evaluate(
          DebugOnlyBridgeDeveloperSkeletonValidationRequest(
            policy: unsafePolicy,
          ),
        );

        expect(
          result.status,
          DebugOnlyBridgeDeveloperSkeletonValidationStatus
              .blockedByPolicyBoundary,
        );
        expect(result.productOutputCount, greaterThan(0));
        expect(result.labelLeakCount, greaterThan(0));
        expect(result.scoreLeakCount, greaterThan(0));
        expect(result.metricLeakCount, greaterThan(0));
        expect(result.cpLossLeakCount, greaterThan(0));
        expect(result.winProbabilityLeakCount, greaterThan(0));
        expect(result.uiTargetCount, greaterThan(0));
        expect(result.backendTargetCount, greaterThan(0));
        expect(result.persistenceWriteCount, greaterThan(0));
        expect(result.engineCallCount, greaterThan(0));
        expect(result.stockfishCommandLeakCount, greaterThan(0));
        expect(result.rawUciLeakCount, greaterThan(0));
        expect(result.pvDumpLeakCount, greaterThan(0));
      },
    );

    test('record boundary mutations are rejected', () {
      final output = _safeSkeleton.outputPacket.copyWith(
        records: _safeSkeleton.outputPacket.records
            .map(
              (record) => switch (record.role) {
                DebugOnlyBridgeRecordRole.core => record.copyWith(
                  contextOnly: true,
                  sourceImplementationComponentRole:
                      DebugOnlyBridgeImplementationDesignComponentRole
                          .bridgeContextRecord,
                ),
                DebugOnlyBridgeRecordRole.context => record.copyWith(
                  contextOnly: false,
                ),
                DebugOnlyBridgeRecordRole.inactiveBlocked => record.copyWith(
                  inactive: false,
                ),
                _ => record,
              },
            )
            .toList(growable: false),
      );
      final result = _evaluate(
        DebugOnlyBridgeDeveloperSkeletonValidationRequest(outputPacket: output),
      );
      final ids = result.validationFindings.map((finding) => finding.id);

      expect(ids, contains('coreRecordSourcedFromNonCoreInput'));
      expect(ids, contains('contextRecordPromotedToCore'));
      expect(ids, contains('inactiveRecordMadeActive'));
      expect(result.unsafeRecordCount, greaterThan(0));
    });

    test(
      'record safety flags reject labels scores runtime UI persistence engine and dumps',
      () {
        final flagIds = <String>[
          'isProductOutput',
          'isClassifierLabel',
          'hasNumericScore',
          'hasAggregateScore',
          'ranksMoves',
          'isOfficialMetric',
          'exposesCpLoss',
          'exposesWinProbability',
          'quietPreparatoryScopeActive',
          'targetsUi',
          'targetsBackend',
          'writesPersistence',
          'callsEngine',
          'exposesStockfishCommand',
          'exposesRawUci',
          'exposesPvDump',
          'implementsRuntime',
          'implementsExecutablePrototype',
          'implementsWiring',
        ];

        for (final flagId in flagIds) {
          final output = _safeSkeleton.outputPacket.copyWith(
            records: _safeSkeleton.outputPacket.records
                .map(
                  (record) => record.role == DebugOnlyBridgeRecordRole.core
                      ? record.copyWith(
                          safetyFlags: <String, bool>{flagId: true},
                        )
                      : record,
                )
                .toList(growable: false),
          );
          final result = _evaluate(
            DebugOnlyBridgeDeveloperSkeletonValidationRequest(
              outputPacket: output,
            ),
          );

          expect(result.safeForPhase33H, isFalse, reason: flagId);
          expect(
            result.validationFindings.map((finding) => finding.id),
            contains('${flagId}Active'),
            reason: flagId,
          );
        }
      },
    );

    test('Android proof boundary rejects unproven and Phase 32E proof IDs', () {
      final result = _evaluate(
        DebugOnlyBridgeDeveloperSkeletonValidationRequest(
          policy: _safeSkeleton.policy.copyWith(
            capturedAndroidProofIds: const <String>[
              'unproven-proof',
              'pv-multipv-support-boundary-32e',
            ],
          ),
        ),
      );
      final ids = result.validationFindings.map((finding) => finding.id);

      expect(ids, contains('unprovenAndroidProofId'));
      expect(ids, contains('phase32ECaseTreatedAsCapturedProof'));
      expect(result.safeForPhase33H, isFalse);
    });

    test('owner proof queue requires explicit PV reason', () {
      final result = _safeValidation().copyWith(
        ownerProofQueueCount: 1,
        warnings: const <String>['owner proof requested without reason'],
      );

      expect(
        const DebugOnlyBridgeDeveloperSkeletonValidationValidator()
            .validate(result)
            .map((finding) => finding.id),
        contains('ownerProofRequiredWithoutPvReason'),
      );
    });

    test('global output and implementation flags are rejected', () {
      final ids = const DebugOnlyBridgeDeveloperSkeletonValidationValidator()
          .validate(
            _safeValidation().copyWith(
              developerOnly: false,
              debugBridgeRuntimeImplemented: true,
              executableBridgeSkeletonImplemented: true,
              executableDebugBridgePrototypeImplemented: true,
              implementationWiringImplemented: true,
              productOutputActive: true,
              classifierOutputActive: true,
              finalMoveLabelOutputActive: true,
              officialMetricOutputActive: true,
              cpLossOutputActive: true,
              winProbabilityOutputActive: true,
              numericOutputActive: true,
              aggregateScoreOutputActive: true,
              moveRankingOutputActive: true,
              quietPreparatoryScopeActivated: true,
              engineCallsActive: true,
              persistenceWritesActive: true,
              uiTargetsActive: true,
              backendOutputActive: true,
              stockfishCommandFieldActive: true,
              rawUciFieldActive: true,
              pvDumpFieldActive: true,
            ),
          )
          .map((finding) => finding.id);

      expect(
        ids,
        contains('developerSkeletonValidationBoundaryPolicyViolation'),
      );
    });

    test('markdown report includes required validation sections', () {
      final report = _safeValidation().renderMarkdownReport();

      expect(
        report,
        contains('# Debug-Only Bridge Developer Skeleton Validation'),
      );
      expect(report, contains('## Validation Check Table'));
      expect(report, contains('## Input Packet Validation'));
      expect(report, contains('## Output Packet Validation'));
      expect(report, contains('## Policy Validation'));
      expect(report, contains('## Bridge Record Validation Table'));
      expect(report, contains('## Allowed/Denied Field Boundary Validation'));
      expect(report, contains('## Stockfish/Raw UCI/PV Denial Validation'));
      expect(
        report,
        contains('## Runtime/Prototype/Wiring Blocked Validation'),
      );
      expect(report, contains('## Android Proof Boundary'));
      expect(report, contains('## Owner Proof Boundary'));
      expect(
        report,
        contains('proceedToDebugOnlyBridgeDeveloperInspectionHarness'),
      );
      _expectReportGuardrails(report);
    });

    test('JSON report is deterministic and valid', () {
      final first = _safeValidation().renderJsonReport();
      final second = _safeValidation().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        debugOnlyBridgeDeveloperSkeletonValidationReportVersion,
      );
      expect(decoded['status'], 'skeletonValidatedWithWarnings');
      expect(decoded['totalChecks'], 19);
      expect(decoded['totalValidationRows'], 14);
      expect(decoded['safeForPhase33H'], isTrue);
      expect(
        decoded['phase33HRecommendation'],
        'proceedToDebugOnlyBridgeDeveloperInspectionHarness',
      );
    });

    test('report text validator rejects raw UCI and PV dumps', () {
      final findings =
          const DebugOnlyBridgeDeveloperSkeletonValidationValidator()
              .validateReportText('uciok\ninfo depth 1\npv e2e4 e7e5');

      expect(
        findings.map((finding) => finding.id),
        containsAll(<String>['rawUciReportText', 'pvDumpReportText']),
      );
      expect(
        const DebugOnlyBridgeDeveloperSkeletonValidationValidator()
            .validateReportText(_safeValidation().renderMarkdownReport()),
        isEmpty,
      );
    });

    test('source imports stay pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_developer_skeleton_validation.dart',
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
        'scheduler',
      ]) {
        expect(imports.toLowerCase(), isNot(contains(forbidden)));
      }
    });
  });
}

DebugOnlyBridgeDeveloperSkeletonValidationResult _evaluate([
  DebugOnlyBridgeDeveloperSkeletonValidationRequest request =
      const DebugOnlyBridgeDeveloperSkeletonValidationRequest(),
]) {
  return const DebugOnlyBridgeDeveloperSkeletonValidation().evaluate(request);
}

DebugOnlyBridgeDeveloperSkeletonValidationResult _safeValidation() =>
    _cachedSafeValidation;

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
    'allowed fields: schedulerExecution',
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

final DebugOnlyBridgeSkeletonResult _safeSkeleton =
    const DebugOnlyBridgeSkeleton().evaluate();

final DebugOnlyBridgeDeveloperSkeletonValidationResult _cachedSafeValidation =
    const DebugOnlyBridgeDeveloperSkeletonValidation().evaluate(
      DebugOnlyBridgeDeveloperSkeletonValidationRequest(
        skeletonResult: _safeSkeleton,
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
  'schedulerExecution',
  'stockfishCommand',
  'uiOutput',
  'winProbability',
];
