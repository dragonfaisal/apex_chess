@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_inspection_harness.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_skeleton_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness', () {
    test('safe default inspection passes with warnings', () {
      final result = _safeInspection();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
            .prototypeInspectionReadyWithWarnings,
      );
      expect(
        result.sourceValidationStatus,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus
            .prototypeSkeletonValidatedWithWarnings,
      );
      expect(result.sourceValidationSafeForPhase33W, isTrue);
      expect(result.sourceSkeletonSafeForPhase33V, isTrue);
      expect(result.safeForPhase33X, isTrue);
      expect(
        result.phase33XRecommendation,
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness',
      );
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.analyzerWiringCount, 0);
      expect(result.runtimeImplementationCount, 0);
      expect(result.executablePrototypeCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
      expect(result.persistenceWriteCount, 0);
      expect(result.productOutputCount, 0);
      expect(result.activeDeniedFieldCount, 0);
    });

    test(
      'inspection rows are deterministic for packets records and policy',
      () {
        final result = _safeInspection();

        expect(result.totalInspectionRows, 41);
        expect(result.inputPacketInspectionCount, 1);
        expect(result.contextPacketInspectionCount, 1);
        expect(result.policyInspectionCount, 1);
        expect(result.internalInputRecordInspectionCount, 8);
        expect(result.contextOnlyRecordInspectionCount, 3);
        expect(result.warningLimitedRecordInspectionCount, 2);
        expect(result.proofBoundaryRecordInspectionCount, 1);
        expect(result.excludedGuardRecordInspectionCount, 2);
        expect(result.allowedFieldBoundaryInspectionCount, 1);
        expect(result.deniedFieldBoundaryInspectionCount, 5);
        expect(result.mapperMetadataInspectionCount, 1);
        expect(result.validatorMetadataInspectionCount, 1);
        expect(result.debugSnapshotMetadataInspectionCount, 1);
        expect(result.runtimeBlockedInspectionCount, 1);
        expect(result.analyzerWiringBlockedInspectionCount, 1);
        expect(result.engineBlockedInspectionCount, 1);
        expect(result.schedulerBlockedInspectionCount, 1);
        expect(result.productAdapterBlockedInspectionCount, 1);
        expect(result.savedAnalysisBlockedInspectionCount, 1);
        expect(result.androidProofBoundaryInspectionCount, 1);
        expect(result.ownerProofBoundaryInspectionCount, 1);
        expect(result.reportSafetyInspectionCount, 1);
        expect(result.futureRequirementInspectionCount, 4);
      },
    );

    test('snapshot inspects packets policy proof and blocked boundaries', () {
      final result = _safeInspection();
      final snapshot = result.snapshot;

      expect(snapshot.developerOnly, isTrue);
      expect(snapshot.inMemoryOnly, isTrue);
      expect(snapshot.analyzerUnwired, isTrue);
      expect(snapshot.safeForDeveloperInspection, isTrue);
      expect(snapshot.packetSummary['internalInputRecordCount'], 8);
      expect(snapshot.policySummary['allowsProductOutput'], isFalse);
      expect(snapshot.policySummary['allowsAnalyzerWiring'], isFalse);
      expect(snapshot.policySummary['allowsEngineCalls'], isFalse);
      expect(snapshot.policySummary['allowsSchedulerExecution'], isFalse);
      expect(snapshot.allowedFieldIds, contains('recordRole'));
      expect(snapshot.allowedFieldIds, isNot(contains('rawUci')));
      expect(snapshot.deniedFieldIds, contains('rawUci'));
      expect(snapshot.deniedFieldIds, contains('stockfishCommand'));
      expect(
        snapshot.androidProofCaseIds,
        orderedEquals(<String>[
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
    });

    test(
      'record rows preserve context warning proof excluded and inactive roles',
      () {
        final result = _safeInspection();

        expect(
          result
              .rowForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                    .contextOnlyRecordInspection,
              )
              .contextOnly,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                    .warningLimitedRecordInspection,
              )
              .warningLimited,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                    .proofBoundaryRecordInspection,
              )
              .proofBoundaryOnly,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                    .excludedGuardRecordInspection,
              )
              .excludedGuard,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                    .deniedFieldBoundaryInspection,
              )
              .inactive,
          isTrue,
        );
      },
    );

    test('Phase 32E proof honesty and owner proof remain preserved', () {
      final result = _safeInspection();
      final phase32ERows = result.inspectionRows.where(
        (row) => row.sourcePhase == 'Phase 32E',
      );
      final proofIds = result.inspectionRows
          .expand((row) => row.androidProofCaseIds)
          .toSet();

      expect(phase32ERows, isNotEmpty);
      for (final row in phase32ERows) {
        expect(row.androidProofCaseIds, isEmpty, reason: row.inspectionRowId);
      }
      expect(
        proofIds,
        containsAll(<String>[
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
      expect(result.phase32EProofClaimCount, 0);
      expect(result.unprovenAndroidProofCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('unsafe Phase 33V validation input blocks inspection', () {
      final unsafeValidation = _safeValidation().copyWith(
        safeForPhase33W: false,
        phase33WRecommendation:
            'blockedByUnsafeAnalyzerAdapterPrototypeSkeletonValidation',
      );

      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness()
              .evaluate(validationResult: unsafeValidation);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
            .blockedByUnsafeSkeletonValidation,
      );
      expect(result.safeForPhase33X, isFalse);
      expect(result.blockerCount, 0);
      expect(result.unsafeCount, greaterThan(0));
    });

    test(
      'validator rejects label score metric threshold and product seams',
      () {
        final validator =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionValidator();
        final row = _safeRow();
        final seams = <String, String>{
          'productLabel': 'productOutput',
          'finalMoveLabel': 'finalLabelLeak',
          'classifierLabel': 'classifierLabelLeak',
          'brilliantGreatMiss': 'classifierLabelLeak',
          'bestGoodInaccuracyMistakeBlunder': 'classifierLabelLeak',
          'numericMoveScore': 'numericScoreLeak',
          'aggregateScore': 'aggregateScoreLeak',
          'officialMetric': 'officialMetricLeak',
          'accuracy': 'officialMetricLeak',
          'acpl': 'officialMetricLeak',
          'moveRanking': 'moveRankingLeak',
          'thresholds': 'thresholdLeak',
        };

        for (final entry in seams.entries) {
          final findings = validator.validateRow(
            row.copyWith(activeDeniedFieldIds: <String>[entry.key]),
          );

          expect(findings, contains('activeDeniedField'), reason: entry.key);
          expect(findings, contains(entry.value), reason: entry.key);
        }
      },
    );

    test('validator rejects integration runtime and raw seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionValidator();
      final row = _safeRow();
      final seams = <String, String>{
        'cpLoss': 'cpLossLeak',
        'winProbability': 'winProbabilityLeak',
        'uiTarget': 'uiTarget',
        'backendTarget': 'backendTarget',
        'persistenceWrite': 'persistenceWrite',
        'directEngineAccess': 'engineCall',
        'schedulerExecution': 'schedulerExecution',
        'analyzerWiring': 'analyzerWiring',
        'runtimeImplementation': 'runtimeImplementation',
        'executablePrototypeBehavior': 'executablePrototypeImplementation',
        'productAdapterBehavior': 'productAdapterBehavior',
        'savedAnalysisIntegration': 'savedAnalysisIntegration',
        'stockfishCommand': 'stockfishCommandLeak',
        'rawUci': 'rawUciLeak',
        'pvDump': 'pvDumpLeak',
        'androidCollectorRequirement': 'androidCollectorRequired',
      };

      for (final entry in seams.entries) {
        final findings = validator.validateRow(
          row.copyWith(activeDeniedFieldIds: <String>[entry.key]),
        );

        expect(findings, contains('activeDeniedField'), reason: entry.key);
        expect(findings, contains(entry.value), reason: entry.key);
      }
    });

    test('validator rejects quiet PV proof owner and requirement seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionValidator();

      expect(
        validator.validateRow(
          _safeRow().copyWith(sourceCaseId: 'quiet-preparatory-uncertain'),
        ),
        contains('quietPreparatoryPromoted'),
      );
      expect(
        validator.validateRow(
          _safeRow().copyWith(sourceCaseId: 'pv-multipv-support-boundary-32e'),
        ),
        contains('pvMultiPvPromotedBeyondBoundary'),
      );
      expect(
        validator.validateRow(
          _safeRow().copyWith(
            sourceCaseId: 'king-safety-mating-net-pressure-32e',
            sourcePhase: 'Phase 32E',
            androidProofCaseIds: <String>['mate-threat-fast-evidence'],
          ),
        ),
        contains('phase32ECapturedAndroidProofClaim'),
      );
      expect(
        validator.validateRow(
          _safeRow().copyWith(androidProofCaseIds: <String>['unproven-proof']),
        ),
        contains('unprovenAndroidProofId'),
      );
      expect(
        validator.validateRow(
          _safeRow().copyWith(
            role: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .ownerProofBoundaryInspection,
            activeDeniedFieldIds: <String>['ownerProofQueue'],
          ),
        ),
        contains('ownerProofWithoutPvMultiPvReason'),
      );
      expect(
        validator.validateRow(_safeRow().copyWith(sourceRole: 'unknownRole')),
        contains('unknownInspectionSourceRole'),
      );
      expect(
        validator.validateRow(
          _safeRow().copyWith(
            role: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                .futureRequirementInspection,
            recommendation: 'wrongNextStep',
          ),
        ),
        contains('missingPhase33XRequirement'),
      );
    });

    test('validator rejects missing Phase 33X requirement', () {
      final result = _safeInspection();
      final withoutFuture = result.copyWith(
        inspectionRows: result.inspectionRows
            .where(
              (row) =>
                  row.role !=
                  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
                      .futureRequirementInspection,
            )
            .toList(growable: false),
      );

      expect(
        const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionValidator()
            .validateResult(withoutFuture),
        contains('missingPhase33XRequirement'),
      );
    });

    test('markdown and JSON reports are deterministic and safe', () {
      final result = _safeInspection();
      final markdown = result.renderMarkdown();
      final json = result.renderJson();
      final decoded = jsonDecode(json) as Map<String, Object?>;

      expect(markdown, contains('Inspection Snapshot Summary'));
      expect(markdown, contains('Packet Inspection Summary'));
      expect(markdown, contains('Policy Inspection Summary'));
      expect(markdown, contains('Record Role Inspection Summary'));
      expect(markdown, contains('Proof Boundary Inspection'));
      expect(markdown, contains('Phase 33X Recommendation'));
      expect(
        decoded['inspectionStatus'],
        'prototypeInspectionReadyWithWarnings',
      );
      expect(decoded['safeForPhase33X'], isTrue);
      expect(
        decoded['phase33XRecommendation'],
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness',
      );
      _expectReportGuardrails(markdown);
      _expectReportGuardrails(json);
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_inspection_harness.dart',
      ).readAsStringSync();
      final imports = RegExp(
        r"import '([^']+)';",
      ).allMatches(source).map((match) => match.group(1)!).join('\n');

      for (final forbidden in const <String>[
        'package:flutter/',
        'widgets',
        'backend',
        'preflight',
        'server',
        'cache',
        'database',
        'ffi',
        'native',
        'stockfish',
        'local_eval_service',
        'scheduler',
      ]) {
        expect(imports.toLowerCase(), isNot(contains(forbidden)));
      }
    });
  });
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult _safeInspection() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness()
      .inspectSafeDemo();
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult
_safeValidation() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidation()
      .evaluate();
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow _safeRow() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRow(
    inspectionRowId: 'phase33w-test-row',
    sourceRecordId: 'phase33u-test-record',
    sourceCaseId: 'known-case',
    sourcePhase: 'existing',
    sourceRole: 'internalInputRecord',
    role: DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowRole
        .internalInputRecordInspection,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionRowStatus.inspected,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: <String>['recordRole', 'sourceCaseId'],
    deniedFieldIds: <String>[
      'productLabel',
      'finalMoveLabel',
      'classifierLabel',
      'brilliantGreatMiss',
      'bestGoodInaccuracyMistakeBlunder',
      'numericMoveScore',
      'aggregateScore',
      'officialMetric',
      'accuracy',
      'acpl',
      'cpLoss',
      'winProbability',
      'moveRanking',
      'thresholds',
      'uiTarget',
      'backendTarget',
      'persistenceWrite',
      'schedulerExecution',
      'directEngineAccess',
      'stockfishCommand',
      'rawUci',
      'pvDump',
      'androidCollectorRequirement',
      'analyzerWiring',
      'runtimeImplementation',
      'executablePrototypeBehavior',
      'productAdapterBehavior',
      'savedAnalysisIntegration',
    ],
    androidProofCaseIds: <String>[],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    blockedBoundaryIds: <String>['productOutput'],
    activeDeniedFieldIds: <String>[],
    findings: <String>[],
    recommendation: 'keepInternalInputInspectableOnly',
  );
}

void _expectReportGuardrails(String report) {
  for (final token in const <String>[
    'uciok',
    'readyok',
    'info depth',
    'bestmove e2e4',
    'pv e2e4',
    'active fields: productLabel',
    'numeric move score:',
    'ACPL active',
    'official accuracy active',
    'cpLoss active',
    'winProbability active',
    'runtime implemented: true',
    'analyzer wired: true',
    'engine call active',
    'scheduler execution active',
    'http://',
    'https://',
    'apiKey',
    'secret=',
    'token=',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}
