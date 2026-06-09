@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_implementation_design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug-Only Bridge Developer Skeleton', () {
    test('consumes safe Phase 33E implementation design and is ready', () {
      final result = _safeResult();

      expect(
        result.status,
        DebugOnlyBridgeSkeletonStatus.skeletonReadyWithWarnings,
      );
      expect(
        result.sourceImplementationDesignStatus,
        DebugOnlyBridgeImplementationDesignStatus
            .implementationDesignReadyWithWarnings,
      );
      expect(result.safeForPhase33G, isTrue);
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.executableBridgeSkeletonImplemented, isFalse);
      expect(result.executableDebugBridgePrototypeImplemented, isFalse);
      expect(result.implementationWiringImplemented, isFalse);
      expect(
        result.phase33GRecommendation,
        DebugOnlyBridgePhase33GRecommendation
            .validateDebugOnlyBridgeDeveloperSkeleton,
      );
    });

    test('input and output packets carry safe internal fields only', () {
      final result = _safeResult();

      expect(
        result.inputPacket.sourceImplementationDesignId,
        debugOnlyBridgeImplementationDesignReportVersion,
      );
      expect(result.inputPacket.inputPacketId, contains('phase33f'));
      expect(result.outputPacket.outputPacketId, contains('phase33f'));
      expect(result.outputPacket.skeletonVersion, contains('phase33f'));
      expect(result.outputPacket.developerOnly, isTrue);
      expect(result.outputPacket.safeForDeveloperInspection, isTrue);
      expect(
        result.inputPacket.allowedFieldIds,
        orderedEquals(_allowedFieldIds),
      );
      expect(
        result.outputPacket.allowedFieldIds,
        orderedEquals(_allowedFieldIds),
      );
      expect(
        result.inputPacket.allowedFieldIds,
        isNot(contains('productLabel')),
      );
      expect(result.outputPacket.allowedFieldIds, isNot(contains('rawUci')));
      expect(result.inputPacket.deniedFieldIds, orderedEquals(_deniedFieldIds));
      expect(
        result.outputPacket.deniedFieldIds,
        orderedEquals(_deniedFieldIds),
      );
    });

    test('bridge records preserve safe roles and counts', () {
      final result = _safeResult();

      expect(result.totalRecords, 11);
      expect(result.coreRecordCount, 1);
      expect(result.contextRecordCount, 1);
      expect(result.inactiveRecordCount, 2);
      expect(result.deniedBoundaryRecordCount, 2);
      expect(result.runtimeBlockedRecordCount, 1);
      expect(result.futureRequirementCount, 1);
      expect(
        result
            .recordForRole(DebugOnlyBridgeRecordRole.core)
            .sourceImplementationComponentRole,
        DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord,
      );
      expect(
        result.recordForRole(DebugOnlyBridgeRecordRole.context).contextOnly,
        isTrue,
      );
      expect(
        result
            .recordForRole(DebugOnlyBridgeRecordRole.inactiveBlocked)
            .inactive,
        isTrue,
      );
      expect(
        result.recordForRole(DebugOnlyBridgeRecordRole.inactiveFuture).inactive,
        isTrue,
      );
      expect(
        result
            .recordForRole(
              DebugOnlyBridgeRecordRole.stockfishRawUciPvDumpDenied,
            )
            .deniedFieldIds,
        orderedEquals(<String>['pvDump', 'rawUci', 'stockfishCommand']),
      );
    });

    test('policy safe default keeps every output boundary disabled', () {
      final policy = _safeResult().policy;

      expect(policy.allowedFieldIds, orderedEquals(_allowedFieldIds));
      expect(policy.deniedFieldIds, orderedEquals(_deniedFieldIds));
      expect(
        policy.capturedAndroidProofIds,
        orderedEquals(_capturedAndroidProofIds),
      );
      expect(policy.allowProductOutput, isFalse);
      expect(policy.allowClassifierLabels, isFalse);
      expect(policy.allowNumericScores, isFalse);
      expect(policy.allowAggregateScores, isFalse);
      expect(policy.allowOfficialMetrics, isFalse);
      expect(policy.allowCpLoss, isFalse);
      expect(policy.allowWinProbability, isFalse);
      expect(policy.allowMoveRanking, isFalse);
      expect(policy.allowUi, isFalse);
      expect(policy.allowBackend, isFalse);
      expect(policy.allowPersistence, isFalse);
      expect(policy.allowDirectEngine, isFalse);
      expect(policy.allowStockfishCommand, isFalse);
      expect(policy.allowRawUci, isFalse);
      expect(policy.allowPvDump, isFalse);
      expect(policy.allowRuntime, isFalse);
      expect(policy.allowExecutablePrototype, isFalse);
      expect(policy.allowWiring, isFalse);
      expect(policy.hasUnsafeAllowance, isFalse);
    });

    test('skeleton mapping helpers create safe developer-only records', () {
      final skeleton = const DebugOnlyBridgeSkeleton();
      final design = _cachedSafeImplementationDesign;
      final input = skeleton.buildInputFromImplementationDesign(design);
      final summaryInput = skeleton.buildInputFromValidatedSummary(
        _cachedSafeSummaryValidation,
      );
      final coreSource = design.recordForRole(
        DebugOnlyBridgeImplementationDesignComponentRole.bridgeCoreRecord,
      );
      final contextSource = design.recordForRole(
        DebugOnlyBridgeImplementationDesignComponentRole.bridgeContextRecord,
      );
      final core = skeleton.createCoreRecord(coreSource);
      final context = skeleton.createContextRecord(contextSource);

      expect(
        input.approvedCoreRecordIds,
        contains('phase33e-bridgeCoreRecord'),
      );
      expect(
        summaryInput.approvedCoreRecordIds.single,
        contains('readinessApprovedPrototypeCoreSummary'),
      );
      expect(core.role, DebugOnlyBridgeRecordRole.core);
      expect(core.developerOnly, isTrue);
      expect(core.safetyFlags.values.any((value) => value), isFalse);
      expect(context.role, DebugOnlyBridgeRecordRole.context);
      expect(context.contextOnly, isTrue);
      expect(
        skeleton
            .validateNoDeniedFields(<String>['productLabel'])
            .map((finding) => finding.id),
        contains('activeDeniedField'),
      );
    });

    test('unsafe Phase 33E implementation design blocks skeleton', () {
      final unsafeDesign = _cachedSafeImplementationDesign.copyWith(
        implementationDesignStatus: DebugOnlyBridgeImplementationDesignStatus
            .blockedByUnsafeReadinessValidation,
        unsafeCount: 1,
        safeForPhase33F: false,
      );
      final result = _safeResult(
        DebugOnlyBridgeSkeletonRequest(
          implementationDesignResult: unsafeDesign,
        ),
      );

      expect(
        result.status,
        DebugOnlyBridgeSkeletonStatus.blockedByUnsafeImplementationDesign,
      );
      expect(result.safeForPhase33G, isFalse);
      expect(
        result.hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation,
        isTrue,
      );
    });

    test(
      'validator rejects missing future requirement and unsafe ready seam',
      () {
        final result = _safeResult().copyWith(
          futureRequirementCount: 0,
          sourceImplementationDesignStatus:
              DebugOnlyBridgeImplementationDesignStatus
                  .blockedByUnsafeReadinessValidation,
          sourceImplementationDesignSafeForPhase33F: false,
          unsafeCount: 1,
          safeForPhase33G: true,
        );
        final ids = const DebugOnlyBridgeSkeletonValidator()
            .validate(result)
            .map((finding) => finding.id)
            .toSet();

        expect(ids, contains('missingPhase33FSkeletonRequirement'));
        expect(
          ids,
          contains('unsafeImplementationDesignInputMarkedSkeletonReady'),
        );
      },
    );

    test('validator rejects core/context/inactive record boundary changes', () {
      final result = _safeResult();
      final records = result.outputPacket.records
          .map(
            (record) => record.role == DebugOnlyBridgeRecordRole.core
                ? record.copyWith(
                    contextOnly: true,
                    sourceImplementationComponentRole:
                        DebugOnlyBridgeImplementationDesignComponentRole
                            .bridgeContextRecord,
                  )
                : record.role == DebugOnlyBridgeRecordRole.context
                ? record.copyWith(contextOnly: false)
                : record.role == DebugOnlyBridgeRecordRole.inactiveBlocked
                ? record.copyWith(inactive: false)
                : record,
          )
          .toList(growable: false);
      final mutatedOutput = result.outputPacket.copyWith(records: records);
      final ids = const DebugOnlyBridgeSkeletonValidator()
          .validate(result.copyWith(outputPacket: mutatedOutput))
          .map((finding) => finding.id)
          .toSet();

      expect(ids, contains('coreRecordConsumesNonCoreInput'));
      expect(ids, contains('contextRecordPromotedToCore'));
      expect(ids, contains('blockedFutureRecordMadeActive'));
    });

    test(
      'validator rejects denied fields, policy flags, and proof violations',
      () {
        final result = _safeResult();
        final policy = result.policy.copyWith(
          allowedFieldIds: const <String>['rawUci'],
          allowRawUci: true,
        );
        final output = result.outputPacket.copyWith(
          allowedFieldIds: const <String>['productLabel'],
          androidProofCaseIds: const <String>[
            'pv-multipv-support-boundary-32e',
          ],
        );
        final input = result.inputPacket.copyWith(
          androidProofCaseIds: const <String>['unproven-proof'],
        );
        final ids = const DebugOnlyBridgeSkeletonValidator()
            .validate(
              result.copyWith(
                policy: policy,
                outputPacket: output,
                inputPacket: input,
              ),
            )
            .map((finding) => finding.id)
            .toSet();

        expect(ids, contains('activeDeniedField'));
        expect(ids, contains('debugOnlyBridgePolicyBoundaryViolation'));
        expect(ids, contains('unprovenAndroidProofId'));
        expect(ids, contains('phase32ECaseTreatedAsCapturedProof'));
      },
    );

    test('validator rejects safety and global implementation flags', () {
      final result = _safeResult();
      final validator = const DebugOnlyBridgeSkeletonValidator();
      final flagIds = <String, String>{
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

      for (final entry in flagIds.entries) {
        final records = result.outputPacket.records
            .map(
              (record) => record.role == DebugOnlyBridgeRecordRole.core
                  ? record.copyWith(
                      safetyFlags: <String, bool>{entry.key: true},
                    )
                  : record,
            )
            .toList(growable: false);
        expect(
          validator
              .validate(
                result.copyWith(
                  outputPacket: result.outputPacket.copyWith(records: records),
                ),
              )
              .map((finding) => finding.id),
          contains(entry.value),
          reason: entry.key,
        );
      }

      expect(
        validator
            .validate(
              result.copyWith(
                debugBridgeRuntimeImplemented: true,
                executableBridgeSkeletonImplemented: true,
                implementationWiringImplemented: true,
                uiTargetsActive: true,
                backendOutputActive: true,
                persistenceWritesActive: true,
                engineCallsActive: true,
                stockfishCommandFieldActive: true,
                rawUciFieldActive: true,
                pvDumpFieldActive: true,
              ),
            )
            .map((finding) => finding.id),
        contains('debugOnlyBridgeDeveloperSkeletonBoundaryPolicyViolation'),
      );
    });

    test('owner proof queue requires explicit PV reason', () {
      final result = _safeResult().copyWith(
        ownerProofQueueCount: 1,
        warnings: const <String>['owner proof requested without reason'],
      );

      expect(
        const DebugOnlyBridgeSkeletonValidator()
            .validate(result)
            .map((finding) => finding.id),
        contains('ownerProofRequiredWithoutPvReason'),
      );
    });

    test('markdown report includes required skeleton sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(report, contains('# Debug-Only Bridge Developer Skeleton'));
      expect(report, contains('## Input Packet Summary'));
      expect(report, contains('## Output Packet Summary'));
      expect(report, contains('## Policy Summary'));
      expect(report, contains('## Bridge Record Table'));
      expect(report, contains('## Core/Context/Inactive Record Counts'));
      expect(report, contains('## Allowed And Denied Field Boundaries'));
      expect(report, contains('## Stockfish/Raw UCI/PV Dump Denial'));
      expect(report, contains('## Runtime/Prototype/Wiring Blocked Status'));
      expect(report, contains('## Android Proof Boundary'));
      expect(report, contains('## Owner Proof Boundary'));
      expect(report, contains('validateDebugOnlyBridgeDeveloperSkeleton'));
      _expectReportGuardrails(report);
    });

    test('JSON report is deterministic and valid', () {
      final first = _safeResult().renderJsonReport();
      final second = _safeResult().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], debugOnlyBridgeDeveloperSkeletonReportVersion);
      expect(decoded['totalRecords'], 11);
      expect(decoded['coreRecordCount'], 1);
      expect(decoded['contextRecordCount'], 1);
      expect(decoded['runtimeBlockedRecordCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase33G'], isTrue);
      expect(
        decoded['phase33GRecommendation'],
        'validateDebugOnlyBridgeDeveloperSkeleton',
      );
    });

    test('report text validator rejects raw UCI and PV dumps', () {
      final findings = const DebugOnlyBridgeSkeletonValidator()
          .validateReportText('uciok\ninfo depth 1\npv e2e4 e7e5');

      expect(
        findings.map((finding) => finding.id),
        containsAll(<String>['rawUciReportText', 'pvDumpReportText']),
      );
      expect(
        const DebugOnlyBridgeSkeletonValidator().validateReportText(
          _safeResult().renderMarkdownReport(),
        ),
        isEmpty,
      );
    });

    test('source imports stay pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_developer_skeleton.dart',
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

DebugOnlyBridgeSkeletonResult _safeResult([
  DebugOnlyBridgeSkeletonRequest? request,
]) {
  if (request != null) {
    return const DebugOnlyBridgeSkeleton().evaluate(request);
  }
  return _cachedSafeSkeleton;
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

final DebugBridgePrototypeDesignReadinessSummaryValidationResult
_cachedSafeSummaryValidation =
    const DebugBridgePrototypeDesignReadinessSummaryValidation().evaluate();

final DebugOnlyBridgeImplementationDesignResult
_cachedSafeImplementationDesign = const DebugOnlyBridgeImplementationDesign()
    .evaluate(
      DebugOnlyBridgeImplementationDesignRequest(
        readinessSummaryValidationResult: _cachedSafeSummaryValidation,
      ),
    );

final DebugOnlyBridgeSkeletonResult _cachedSafeSkeleton =
    const DebugOnlyBridgeSkeleton().evaluate(
      DebugOnlyBridgeSkeletonRequest(
        implementationDesignResult: _cachedSafeImplementationDesign,
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

const _capturedAndroidProofIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];
