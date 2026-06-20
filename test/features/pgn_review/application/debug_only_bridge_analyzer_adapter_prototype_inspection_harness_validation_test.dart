@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_inspection_harness.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_inspection_harness_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidation', () {
    test('safe default validation passes with warnings', () {
      final result = _safeValidation();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationStatus
            .prototypeInspectionHarnessValidatedWithWarnings,
      );
      expect(
        result.sourceHarnessStatus,
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
            .prototypeInspectionReadyWithWarnings,
      );
      expect(result.sourceHarnessSafeForPhase33X, isTrue);
      expect(result.safeForPhase33Y, isTrue);
      expect(
        result.phase33YRecommendation,
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand',
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

    test('validation rows and checks are deterministic', () {
      final result = _safeValidation();

      expect(result.totalChecks, 17);
      expect(result.passedCheckCount, 17);
      expect(result.warningCheckCount, 1);
      expect(result.totalValidationRows, 35);
      expect(result.sourceHarnessInputValidationCount, 1);
      expect(result.sourceSkeletonValidationInputValidationCount, 1);
      expect(result.sourceSkeletonResultInputValidationCount, 1);
      expect(result.inspectionSnapshotValidationCount, 1);
      expect(result.inputPacketSummaryValidationCount, 1);
      expect(result.contextPacketSummaryValidationCount, 1);
      expect(result.policySummaryValidationCount, 1);
      expect(result.recordRoleSummaryValidationCount, 17);
      expect(result.androidProofBoundaryValidationCount, 1);
      expect(result.ownerProofBoundaryValidationCount, 1);
      expect(result.deniedFieldBoundaryValidationCount, 1);
      expect(result.reportSafetyValidationCount, 1);
      expect(result.runtimeBlockedBoundaryValidationCount, 1);
      expect(result.analyzerWiringBlockedBoundaryValidationCount, 1);
      expect(result.engineBlockedBoundaryValidationCount, 1);
      expect(result.schedulerBlockedBoundaryValidationCount, 1);
      expect(result.productAdapterBlockedBoundaryValidationCount, 1);
      expect(result.savedAnalysisBlockedBoundaryValidationCount, 1);
      expect(result.futureRequirementValidationCount, 1);
    });

    test('snapshot and packet rows stay developer-only and in-memory', () {
      final result = _safeValidation();
      final snapshot = result.rowForRole(
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .inspectionSnapshotValidation,
      );
      final input = result.rowForRole(
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .inputPacketSummaryValidation,
      );
      final context = result.rowForRole(
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .contextPacketSummaryValidation,
      );

      expect(snapshot.developerOnly, isTrue);
      expect(snapshot.inMemoryOnly, isTrue);
      expect(snapshot.analyzerUnwired, isTrue);
      expect(input.allowedFieldIds, contains('recordRole'));
      expect(input.allowedFieldIds, isNot(contains('rawUci')));
      expect(context.contextOnly, isTrue);
      expect(context.allowedFieldIds, isEmpty);
    });

    test('policy record role proof and owner boundaries remain safe', () {
      final result = _safeValidation();
      final policy = result.rowForRole(
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .policySummaryValidation,
      );
      final recordRows = result.validationRows.where(
        (row) =>
            row.validationRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                .recordRoleSummaryValidation,
      );
      final proof = result.rowForRole(
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .androidProofBoundaryValidation,
      );
      final owner = result.rowForRole(
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .ownerProofBoundaryValidation,
      );

      expect(policy.activeDeniedFieldIds, isEmpty);
      expect(
        recordRows
            .firstWhere((row) => row.sourceRole == 'contextOnlyRecord')
            .contextOnly,
        isTrue,
      );
      expect(
        recordRows
            .firstWhere((row) => row.sourceRole == 'excludedGuardRecord')
            .excludedGuard,
        isTrue,
      );
      expect(
        recordRows
            .firstWhere((row) => row.sourceRole == 'deniedFieldBoundaryRecord')
            .inactive,
        isTrue,
      );
      expect(proof.androidProofCaseIds, <String>[
        'mate-threat-fast-evidence',
        'queen-win-major-swing',
        'simple-tactical-capture-check',
      ]);
      expect(owner.ownerProofRequired, isFalse);
      expect(result.phase32EProofClaimCount, 0);
      expect(result.unprovenAndroidProofCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('unsafe Phase 33W harness blocks validation', () {
      final unsafeHarness = _safeHarness().copyWith(
        safeForPhase33X: false,
        phase33XRecommendation:
            'blockedByUnsafeAnalyzerAdapterPrototypeInspectionHarness',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidation()
              .evaluate(harnessResult: unsafeHarness);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationStatus
            .blockedByUnsafeInspectionHarness,
      );
      expect(result.safeForPhase33Y, isFalse);
      expect(result.blockerCount, greaterThan(0));
      expect(result.unsafeCount, greaterThan(0));
    });

    test('validator rejects label score metric threshold and product seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationValidator();
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
    });

    test('validator rejects integration runtime raw and proof seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationValidator();
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

      expect(
        validator.validateRow(
          row.copyWith(sourceCaseId: 'quiet-preparatory-uncertain'),
        ),
        contains('quietPreparatoryPromoted'),
      );
      expect(
        validator.validateRow(
          row.copyWith(sourceCaseId: 'pv-multipv-support-boundary-32e'),
        ),
        contains('pvMultiPvPromotedBeyondBoundary'),
      );
      expect(
        validator.validateRow(
          row.copyWith(
            sourceCaseId: 'king-safety-mating-net-pressure-32e',
            sourcePhase: 'Phase 32E',
            androidProofCaseIds: <String>['mate-threat-fast-evidence'],
          ),
        ),
        contains('phase32ECapturedAndroidProofClaim'),
      );
      expect(
        validator.validateRow(
          row.copyWith(androidProofCaseIds: <String>['unproven-proof']),
        ),
        contains('unprovenAndroidProofId'),
      );
      expect(
        validator.validateRow(
          row.copyWith(
            ownerProofRequired: true,
            proofLimitReasons: const <String>[],
          ),
        ),
        contains('ownerProofWithoutPvMultiPvReason'),
      );
      expect(
        validator.validateRow(row.copyWith(sourceRole: 'unknownRole')),
        contains('unknownInspectionRowRole'),
      );
      expect(
        validator.validateRow(
          row.copyWith(
            validationRole:
                DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                    .futureRequirementValidation,
            recommendation: 'wrongNextStep',
          ),
        ),
        contains('missingPhase33YRequirement'),
      );
    });

    test('validator rejects missing Phase 33Y requirement', () {
      final result = _safeValidation();
      final withoutFuture = result.copyWith(
        validationRows: result.validationRows
            .where(
              (row) =>
                  row.validationRole !=
                  DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
                      .futureRequirementValidation,
            )
            .toList(growable: false),
      );

      expect(
        const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationValidator()
            .validateResult(withoutFuture),
        contains('missingPhase33YRequirement'),
      );
    });

    test('markdown and JSON reports are deterministic and safe', () {
      final result = _safeValidation();
      final markdown = result.renderMarkdown();
      final json = result.renderJson();
      final decoded = jsonDecode(json) as Map<String, Object?>;

      expect(markdown, contains('Validation Check Table'));
      expect(markdown, contains('Snapshot Validation Summary'));
      expect(markdown, contains('Packet Validation Summary'));
      expect(markdown, contains('Policy Record Proof Validation Summary'));
      expect(markdown, contains('Proof Boundary Validation'));
      expect(markdown, contains('Phase 33Y Recommendation'));
      expect(
        decoded['validationStatus'],
        'prototypeInspectionHarnessValidatedWithWarnings',
      );
      expect(decoded['safeForPhase33Y'], isTrue);
      expect(
        decoded['phase33YRecommendation'],
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand',
      );
      _expectReportGuardrails(markdown);
      _expectReportGuardrails(json);
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_inspection_harness_validation.dart',
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

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationResult
_safeValidation() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidation()
      .evaluate();
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionResult _safeHarness() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness()
      .inspectSafeDemo();
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow
_safeRow() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRow(
    validationRowId: 'phase33x-test-row',
    sourceInspectionRowId: 'phase33w-test-row',
    sourceRecordId: 'phase33w-test-record',
    sourceCaseId: 'known-case',
    sourcePhase: 'existing',
    sourceRole: 'internalInputRecord',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowRole
            .sourceHarnessInputValidation,
    status:
        DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessValidationRowStatus
            .valid,
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: <String>['recordRole', 'sourceCaseId'],
    deniedFieldIds: _deniedFields,
    androidProofCaseIds: <String>[],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    blockedBoundaryIds: <String>['analyzerWiring', 'productOutput'],
    activeDeniedFieldIds: <String>[],
    ownerProofRequired: false,
    findings: <String>[],
    recommendation:
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand',
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

const _deniedFields = <String>[
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
];
