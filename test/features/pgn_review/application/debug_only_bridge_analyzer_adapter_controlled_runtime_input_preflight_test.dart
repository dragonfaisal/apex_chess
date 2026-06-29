@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight', () {
    test(
      'safe default creates disabled runtime input preflight with warnings',
      () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight()
                .evaluate();

        expect(
          result.status,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightStatus
              .controlledAnalyzerAdapterRuntimeInputPreflightReadyWithWarnings,
        );
        expect(result.safeForPhase34P, isTrue);
        expect(
          result.nextRecommendation,
          'runControlledAnalyzerAdapterRuntimeInputPreflightDiagnostic',
        );
        expect(result.unsafeCount, 0);
        expect(result.blockerCount, 0);
        expect(result.criticalCount, 0);
        expect(result.seamProbePerformedCount, 0);
        expect(result.runtimeExecutionCount, 0);
        expect(result.runtimeExecutionApprovedCount, 0);
        expect(result.analyzerRuntimeInputProducedCount, 0);
        expect(result.analyzerRuntimeInputApprovedCount, 0);
        expect(result.analyzerWiringCount, 0);
        expect(result.executableRuntimeCount, 0);
        expect(result.engineCallCount, 0);
        expect(result.schedulerExecutionCount, 0);
        expect(result.persistenceWriteCount, 0);
        expect(result.productOutputCount, 0);
        expect(result.productAdapterCount, 0);
        expect(result.savedAnalysisIntegrationCount, 0);
        expect(result.activeDeniedFieldCount, 0);
        expect(result.ownerProofQueueCount, 0);
        expect(result.totalChecks, 34);
        expect(result.passedCheckCount, result.totalChecks);
        expect(result.blockedReasonCount, greaterThan(0));
      },
    );

    test('preflight checks cover runtime input production seams', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight()
              .evaluate();
      final checkIds = result.checks.map((check) => check.checkId).toSet();

      expect(
        checkIds,
        containsAll(const <String>[
          'seamProbeDiagnosticPresent',
          'seamProbeResultPresent',
          'seamProbeRequestedAsRefusedRecord',
          'seamProbePerformedFalse',
          'executionPerformedFalse',
          'executionAllowedFalse',
          'runtimeExecutionApprovedFalse',
          'analyzerRuntimeInputProducedFalse',
          'analyzerRuntimeInputApprovedFalse',
          'analyzerRuntimeInputBoundaryPresent',
          'analyzerRuntimeInputBlocked',
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

    test('preflight decision keeps input approval and production false', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight()
              .evaluate();
      final decision = result.decision;
      final policy = result.policy;

      expect(decision.seamProbePerformed, isFalse);
      expect(decision.executionPerformed, isFalse);
      expect(decision.executionAllowed, isFalse);
      expect(decision.runtimeExecutionApproved, isFalse);
      expect(decision.analyzerRuntimeInputApproved, isFalse);
      expect(decision.analyzerRuntimeInputProduced, isFalse);
      expect(decision.analyzerWiringAllowed, isFalse);
      expect(decision.engineCallsAllowed, isFalse);
      expect(decision.schedulerAllowed, isFalse);
      expect(decision.persistenceAllowed, isFalse);
      expect(decision.productOutputAllowed, isFalse);
      expect(decision.productAdapterAllowed, isFalse);
      expect(decision.savedAnalysisAllowed, isFalse);
      expect(policy.seamProbeAllowed, isFalse);
      expect(policy.executionAllowed, isFalse);
      expect(policy.runtimeExecutionApproved, isFalse);
      expect(policy.analyzerRuntimeInputApproved, isFalse);
      expect(policy.analyzerRuntimeInputProduced, isFalse);
      expect(policy.uiAllowed, isFalse);
      expect(policy.backendAllowed, isFalse);
      expect(policy.cacheAllowed, isFalse);
      expect(policy.databaseAllowed, isFalse);
    });

    test('unsafe Phase 34N diagnostic blocks preflight', () {
      final safeDiagnostic =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic()
              .evaluate();
      final unsafeDiagnostic =
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticResult(
            status:
                DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticStatus
                    .blockedByPolicyBoundary,
            mode: safeDiagnostic.mode,
            sourceSeamProbeStatus: safeDiagnostic.sourceSeamProbeStatus,
            sourcePreflightDiagnosticStatus:
                safeDiagnostic.sourcePreflightDiagnosticStatus,
            sourcePreflightStatus: safeDiagnostic.sourcePreflightStatus,
            sourceDisabledRuntimeSkeletonDiagnosticStatus:
                safeDiagnostic.sourceDisabledRuntimeSkeletonDiagnosticStatus,
            sourceDisabledRuntimeSkeletonStatus:
                safeDiagnostic.sourceDisabledRuntimeSkeletonStatus,
            rows: safeDiagnostic.rows,
            findings: const <String>['unsafeFixture'],
            safeForPhase34O: false,
            nextRecommendation: 'blockedFixture',
          );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight()
              .evaluate(disabledSeamProbeDiagnosticResult: unsafeDiagnostic);

      expect(result.safeForPhase34P, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34NDisabledRuntimeExecutionSeamProbeDiagnostic'),
      );
    });

    test('validator rejects input production, runtime, product, and leaks', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight()
              .evaluate();
      const validator =
          ControlledAnalyzerAdapterRuntimeInputPreflightValidator();

      final findings = validator.validatePreflight(
        input: result.input.copyWith(
          sourceCaseIds: const <String>['pv-multipv-support-boundary-32e'],
          supportAreaIds: const <String>['quietPreparatoryMove'],
          proofLimitReasons: const <String>[],
          androidProofIds: const <String>[
            'king-safety-mating-net-pressure-32e',
          ],
          ownerProofRequired: true,
          seamProbePerformed: true,
          executionPerformed: true,
          executionAllowed: true,
          runtimeExecutionApproved: true,
          analyzerRuntimeInputApproved: true,
          analyzerRuntimeInputProduced: true,
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
            'active:analyzerRuntimeInput',
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
        checks: <ControlledAnalyzerAdapterRuntimeInputPreflightCheck>[
          result.checks.first.copyWith(
            checkId: 'unknownCheck',
            passed: false,
            blockedReasonIds: const <String>['active:UI'],
            deniedFieldIds: const <String>['active:productLabel'],
            recommendation: 'wrongRecommendation',
          ),
        ],
        policy: result.policy.copyWith(
          seamProbeAllowed: true,
          executionAllowed: true,
          runtimeExecutionApproved: true,
          analyzerRuntimeInputApproved: true,
          analyzerRuntimeInputProduced: true,
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
          seamProbePerformed: true,
          executionPerformed: true,
          executionAllowed: true,
          runtimeExecutionApproved: true,
          analyzerRuntimeInputApproved: true,
          analyzerRuntimeInputProduced: true,
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
            <ControlledAnalyzerAdapterRuntimeInputPreflightBlockedReason>[
              result.blockedReasons.first.copyWith(
                blockedReasonId: 'active:runtimeInput',
                blocked: false,
                deniedFieldIds: const <String>['active:productLabel'],
                recommendation: 'wrongRecommendation',
              ),
            ],
      );

      expect(findings, contains('seamProbePerformedEnabled'));
      expect(findings, contains('executionPerformedEnabled'));
      expect(findings, contains('executionAllowedEnabled'));
      expect(findings, contains('runtimeExecutionApprovedEnabled'));
      expect(findings, contains('analyzerRuntimeInputApproved'));
      expect(findings, contains('analyzerRuntimeInputProduced'));
      expect(findings, contains('analyzerRuntimeInputEnabled'));
      expect(findings, contains('analyzerWiringEnabled'));
      expect(findings, contains('engineCallsEnabled'));
      expect(findings, contains('schedulerExecutionEnabled'));
      expect(findings, contains('persistenceWriteEnabled'));
      expect(findings, contains('productOutputEnabled'));
      expect(findings, contains('productAdapterEnabled'));
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
      expect(findings, contains('unknownRuntimeInputPreflightCheck'));
      expect(findings, contains('runtimeInputPreflightCheckFailed'));
      expect(findings, contains('blockedReasonActivated'));
      expect(findings, contains('uiBackendActivationEnabled'));
      expect(findings, contains('cacheDatabaseWriteEnabled'));
      expect(findings, contains('seamProbeDiagnosticMissing'));
      expect(findings, contains('seamProbeResultMissing'));
      expect(findings, contains('refusedSeamProbeRecordMissing'));
      expect(findings, contains('analyzerRuntimeInputBoundaryMissing'));

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
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight()
              .evaluate();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;

      expect(
        markdown,
        contains('# Controlled Analyzer Adapter Runtime Input Preflight'),
      );
      expect(markdown, contains('analyzer runtime input approved count: 0'));
      expect(markdown, contains('analyzer runtime input produced count: 0'));
      expect(markdown, contains('runtime execution count: 0'));
      expect(decoded['status'], result.status.wire);
      expect(decoded['safeForPhase34P'], isTrue);
      expect(decoded['nextRecommendation'], result.nextRecommendation);
      expect(decoded['checks'], isA<List<Object?>>());
      expect(decoded['decision'], isA<Map<String, Object?>>());
      expect(decoded['blockedReasons'], isA<List<Object?>>());
      expect(markdown, isNot(contains('bestmove e2e4')));
      expect(markdown, isNot(contains('analyzerRuntimeInputProduced: true')));
    });
  });
}
