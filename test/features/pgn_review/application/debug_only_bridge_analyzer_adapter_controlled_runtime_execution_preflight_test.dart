@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight', () {
    test('safe default creates disabled preflight with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightStatus
            .controlledAnalyzerAdapterRuntimeExecutionPreflightReadyWithWarnings,
      );
      expect(result.safeForPhase34L, isTrue);
      expect(
        result.nextRecommendation,
        'runControlledAnalyzerAdapterRuntimeExecutionPreflightDiagnostic',
      );
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.runtimeExecutionCount, 0);
      expect(result.executableRuntimeCount, 0);
      expect(result.analyzerWiringCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
      expect(result.persistenceWriteCount, 0);
      expect(result.productOutputCount, 0);
      expect(result.productAdapterCount, 0);
      expect(result.savedAnalysisIntegrationCount, 0);
      expect(result.activeDeniedFieldCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.totalChecks, 24);
      expect(result.passedCheckCount, result.totalChecks);
      expect(result.blockedReasonCount, greaterThan(0));
    });

    test('preflight checks cover disabled runtime execution seams', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
              .evaluate();
      final checkIds = result.checks.map((check) => check.checkId).toSet();

      expect(
        checkIds,
        containsAll(const <String>[
          'disabledSkeletonPresent',
          'requestEnvelopePresent',
          'responseEnvelopePresent',
          'refusedExecutionAttemptPresent',
          'executionPerformedFalse',
          'executionAllowedFalse',
          'analyzerWiringAllowedFalse',
          'engineCallsAllowedFalse',
          'schedulerAllowedFalse',
          'persistenceAllowedFalse',
          'productOutputAllowedFalse',
          'productAdapterAllowedFalse',
          'savedAnalysisAllowedFalse',
          'stockfishCommandBlocked',
          'rawUciBlocked',
          'pvDumpBlocked',
          'androidCollectorBlocked',
          'productLabelsBlocked',
          'numericScoresBlocked',
          'officialMetricsBlocked',
          'cpLossBlocked',
          'winProbabilityBlocked',
          'phase32EProofHonestyPreserved',
          'quietPreparatoryExclusionPreserved',
        ]),
      );
      expect(result.checks.every((check) => check.passed), isTrue);
    });

    test('preflight decision keeps all runtime permissions false', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
              .evaluate();
      final decision = result.decision;
      final policy = result.policy;

      expect(decision.executionAllowed, isFalse);
      expect(decision.runtimeExecutionApproved, isFalse);
      expect(decision.analyzerWiringAllowed, isFalse);
      expect(decision.engineCallsAllowed, isFalse);
      expect(decision.schedulerAllowed, isFalse);
      expect(decision.persistenceAllowed, isFalse);
      expect(decision.productOutputAllowed, isFalse);
      expect(decision.productAdapterAllowed, isFalse);
      expect(decision.savedAnalysisAllowed, isFalse);
      expect(policy.executionAllowed, isFalse);
      expect(policy.runtimeExecutionApproved, isFalse);
      expect(policy.analyzerWiringAllowed, isFalse);
      expect(policy.engineCallsAllowed, isFalse);
      expect(policy.schedulerAllowed, isFalse);
      expect(policy.persistenceAllowed, isFalse);
      expect(policy.productOutputAllowed, isFalse);
      expect(policy.productAdapterAllowed, isFalse);
      expect(policy.savedAnalysisAllowed, isFalse);
      expect(policy.uiAllowed, isFalse);
      expect(policy.backendAllowed, isFalse);
      expect(policy.cacheAllowed, isFalse);
      expect(policy.databaseAllowed, isFalse);
    });

    test('unsafe Phase 34J diagnostic blocks preflight', () {
      final safeDiagnostic =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
              .evaluate();
      final unsafeDiagnostic =
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticResult(
            status:
                DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticStatus
                    .blockedByPolicyBoundary,
            mode: safeDiagnostic.mode,
            sourceSkeletonStatus: safeDiagnostic.sourceSkeletonStatus,
            sourceRuntimePreparationDiagnosticStatus:
                safeDiagnostic.sourceRuntimePreparationDiagnosticStatus,
            sourceRuntimePreparationStatus:
                safeDiagnostic.sourceRuntimePreparationStatus,
            rows: safeDiagnostic.rows,
            findings: const <String>['unsafeFixture'],
            safeForPhase34K: false,
            nextRecommendation: 'blockedFixture',
          );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
              .evaluate(
                disabledRuntimeSkeletonDiagnosticResult: unsafeDiagnostic,
              );

      expect(result.safeForPhase34L, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34JDisabledRuntimeSkeletonDiagnostic'),
      );
    });

    test('validator rejects runtime, product, proof, and report leak seams', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
              .evaluate();
      const validator =
          ControlledAnalyzerAdapterRuntimeExecutionPreflightValidator();

      final findings = validator.validatePreflight(
        input: result.input.copyWith(
          sourceCaseIds: const <String>['pv-multipv-support-boundary-32e'],
          supportAreaIds: const <String>['quietPreparatoryMove'],
          proofLimitReasons: const <String>[],
          androidProofIds: const <String>[
            'king-safety-mating-net-pressure-32e',
          ],
          ownerProofRequired: true,
          executionAllowed: true,
          runtimeExecutionApproved: true,
          analyzerWiringAllowed: true,
          engineCallsAllowed: true,
          schedulerAllowed: true,
          persistenceAllowed: true,
          productOutputAllowed: true,
          productAdapterAllowed: true,
          savedAnalysisAllowed: true,
          blockedReasonIds: const <String>['active:engineCall'],
          deniedFieldIds: const <String>[
            'active:productLabel',
            'active:finalMoveLabel',
            'active:classifierLabels',
            'active:brilliantGreatMiss',
            'active:bestGoodInaccuracyMistakeBlunder',
            'active:numericMoveScore',
            'active:aggregateScore',
            'active:officialMetric',
            'active:accuracy',
            'active:acpl',
            'active:cpLoss',
            'active:winProbability',
            'active:moveRanking',
            'active:thresholds',
            'active:stockfishCommand',
            'active:rawUci',
            'active:pvDump',
            'active:androidCollectorRequirement',
            'active:runtimeExecutionResult',
            'active:analyzerResult',
            'active:engineResult',
            'active:schedulerExecutionResult',
            'active:cacheDatabaseWrite',
            'active:productAdapterBehavior',
            'active:savedAnalysisIntegration',
            'active:readinessSummaryChain',
            'active:readinessGate',
          ],
          recommendation: 'wrongRecommendation',
        ),
        checks: <ControlledAnalyzerAdapterRuntimeExecutionPreflightCheck>[
          result.checks.first.copyWith(
            checkId: 'unknownCheck',
            passed: false,
            blockedReasonIds: const <String>['active:UI'],
            deniedFieldIds: const <String>['active:productLabel'],
            recommendation: 'wrongRecommendation',
          ),
        ],
        policy: result.policy.copyWith(
          executionAllowed: true,
          runtimeExecutionApproved: true,
          analyzerWiringAllowed: true,
          engineCallsAllowed: true,
          schedulerAllowed: true,
          persistenceAllowed: true,
          productOutputAllowed: true,
          productAdapterAllowed: true,
          savedAnalysisAllowed: true,
          uiAllowed: true,
          backendAllowed: true,
          cacheAllowed: true,
          databaseAllowed: true,
          deniedFieldIds: const <String>['active:productLabel'],
        ),
        decision: result.decision.copyWith(
          executionAllowed: true,
          runtimeExecutionApproved: true,
          analyzerWiringAllowed: true,
          engineCallsAllowed: true,
          schedulerAllowed: true,
          persistenceAllowed: true,
          productOutputAllowed: true,
          productAdapterAllowed: true,
          savedAnalysisAllowed: true,
          blockedReasonIds: const <String>['active:runtimeExecution'],
          recommendation: 'wrongRecommendation',
        ),
        blockedReasons:
            <ControlledAnalyzerAdapterRuntimeExecutionPreflightBlockedReason>[
              result.blockedReasons.first.copyWith(
                blockedReasonId: 'active:runtimeExecution',
                blocked: false,
                deniedFieldIds: const <String>['active:productLabel'],
                recommendation: 'wrongRecommendation',
              ),
            ],
        executionPerformed: true,
      );

      expect(findings, contains('executionAllowedEnabled'));
      expect(findings, contains('runtimeExecutionApprovedEnabled'));
      expect(findings, contains('analyzerWiringEnabled'));
      expect(findings, contains('engineCallsEnabled'));
      expect(findings, contains('schedulerExecutionEnabled'));
      expect(findings, contains('persistenceWriteEnabled'));
      expect(findings, contains('productOutputEnabled'));
      expect(findings, contains('productAdapterEnabled'));
      expect(findings, contains('savedAnalysisIntegrationEnabled'));
      expect(findings, contains('runtimeExecutionResultEnabled'));
      expect(findings, contains('analyzerResultEnabled'));
      expect(findings, contains('engineResultEnabled'));
      expect(findings, contains('schedulerExecutionResultEnabled'));
      expect(findings, contains('cacheDatabaseWriteEnabled'));
      expect(findings, contains('productAdapterBehaviorEnabled'));
      expect(findings, contains('savedAnalysisIntegrationEnabled'));
      expect(findings, contains('productLabelsEnabled'));
      expect(findings, contains('finalLabelsEnabled'));
      expect(findings, contains('classifierLabelsEnabled'));
      expect(findings, contains('scoresEnabled'));
      expect(findings, contains('rankingsMetricsAccuracyAcplEnabled'));
      expect(findings, contains('cpLossEnabled'));
      expect(findings, contains('winProbabilityEnabled'));
      expect(findings, contains('thresholdsEnabled'));
      expect(findings, contains('stockfishCommandEnabled'));
      expect(findings, contains('rawUciEnabled'));
      expect(findings, contains('pvDumpEnabled'));
      expect(findings, contains('androidCollectorRequirementEnabled'));
      expect(findings, contains('readinessSummaryChainEnabled'));
      expect(findings, contains('readinessGateEnabled'));
      expect(findings, contains('quietPreparatoryPromotion'));
      expect(findings, contains('pvMultiPvPromotion'));
      expect(findings, contains('phase32ECapturedProofClaim'));
      expect(findings, contains('unprovenAndroidProofClaim'));
      expect(findings, contains('ownerProofWithoutPvMultiPvReason'));
      expect(findings, contains('unknownRuntimeExecutionPreflightCheck'));
      expect(findings, contains('runtimeExecutionPreflightCheckFailed'));
      expect(findings, contains('blockedReasonActivated'));
      expect(findings, contains('uiBackendActivationEnabled'));
      expect(findings, contains('cacheDatabaseWriteEnabled'));
      expect(findings, contains('disabledSkeletonMissing'));
      expect(findings, contains('requestEnvelopeMissing'));
      expect(findings, contains('responseEnvelopeMissing'));
      expect(findings, contains('refusedExecutionAttemptMissing'));

      expect(
        validator.validateReportText('info depth 12 score cp 10 pv e2e4'),
        contains('reportTextLeak:pvDump'),
      );
      expect(
        validator.validateReportText('position fen x go movetime 10'),
        contains('reportTextLeak:stockfishPosition'),
      );
    });

    test('markdown and JSON render deterministically without active leaks', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
              .evaluate();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;

      expect(
        markdown,
        contains('# Controlled Analyzer Adapter Runtime Execution Preflight'),
      );
      expect(markdown, contains('runtime execution count: 0'));
      expect(markdown, contains('analyzer wiring count: 0'));
      expect(markdown, contains('owner proof queue count: 0'));
      expect(decoded['status'], result.status.wire);
      expect(decoded['safeForPhase34L'], isTrue);
      expect(decoded['nextRecommendation'], result.nextRecommendation);
      expect(decoded['checks'], isA<List<Object?>>());
      expect(decoded['decision'], isA<Map<String, Object?>>());
      expect(decoded['blockedReasons'], isA<List<Object?>>());
      expect(markdown, isNot(contains('bestmove e2e4')));
      expect(markdown, isNot(contains('executionPerformed: true')));
    });
  });
}
