@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic',
    () {
      test('safe default reports preflight diagnostic with warnings', () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
                .evaluate();

        expect(
          result.status,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticStatus
              .controlledAnalyzerAdapterRuntimeExecutionPreflightDiagnosticReadyWithWarnings,
        );
        expect(
          result.mode,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
              .defaultMode,
        );
        expect(result.safeForPhase34M, isTrue);
        expect(
          result.nextRecommendation,
          'implementDisabledAnalyzerAdapterRuntimeExecutionSeamProbePatch',
        );
        expect(result.unsafeCount, 0);
        expect(result.blockerCount, 0);
        expect(result.criticalCount, 0);
        expect(result.runtimeExecutionCount, 0);
        expect(result.runtimeExecutionApprovedCount, 0);
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
        expect(result.totalDiagnosticRows, greaterThan(0));
      });

      test('diagnostic modes are deterministic and safe', () {
        for (final mode
            in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
                .values) {
          final result =
              const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
                  .evaluate(mode: mode);

          expect(result.mode, mode);
          expect(result.safeForPhase34M, isTrue, reason: mode.wire);
          expect(result.unsafeCount, 0, reason: mode.wire);
          expect(result.blockerCount, 0, reason: mode.wire);
          expect(
            result.rows.every((row) => row.diagnosticMode == mode.wire),
            isTrue,
            reason: mode.wire,
          );
          expect(
            result.rows.every((row) => !row.executionAllowed),
            isTrue,
            reason: mode.wire,
          );
          expect(
            result.rows.every((row) => !row.runtimeExecutionApproved),
            isTrue,
            reason: mode.wire,
          );
          expect(
            result.rows.every((row) => !row.executionPerformed),
            isTrue,
            reason: mode.wire,
          );
          expect(
            result.rows.every((row) => !row.analyzerWiringAllowed),
            isTrue,
            reason: mode.wire,
          );
        }
      });

      test('mode-specific row counts match selected preflight areas', () {
        final checks =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
                .evaluate(
                  mode:
                      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
                          .checks,
                );
        final decision =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
                .evaluate(
                  mode:
                      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
                          .decision,
                );
        final blocked =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
                .evaluate(
                  mode:
                      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
                          .blockedReasons,
                );

        expect(checks.totalDiagnosticRows, checks.checkDiagnosticRowCount);
        expect(checks.totalDiagnosticRows, 24);
        expect(decision.totalDiagnosticRows, 1);
        expect(decision.decisionDiagnosticRowCount, 1);
        expect(
          blocked.totalDiagnosticRows,
          blocked.blockedReasonDiagnosticRowCount,
        );
        expect(blocked.totalDiagnosticRows, 15);
      });

      test('unsafe Phase 34K preflight blocks diagnostic', () {
        final safe =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
                .evaluate();
        final unsafe = ControlledAnalyzerAdapterRuntimeExecutionPreflightResult(
          status:
              DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightStatus
                  .blockedByPolicyBoundary,
          sourceDiagnosticStatus: safe.sourceDiagnosticStatus,
          sourceSkeletonStatus: safe.sourceSkeletonStatus,
          sourceRuntimePreparationDiagnosticStatus:
              safe.sourceRuntimePreparationDiagnosticStatus,
          sourceRuntimePreparationStatus: safe.sourceRuntimePreparationStatus,
          input: safe.input.copyWith(executionAllowed: true),
          checks: safe.checks,
          policy: safe.policy,
          decision: safe.decision,
          blockedReasons: safe.blockedReasons,
          findings: const <String>['unsafeFixture'],
          safeForPhase34L: false,
          nextRecommendation: 'blockedFixture',
        );
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
                .evaluate(runtimeExecutionPreflightResult: unsafe);

        expect(result.safeForPhase34M, isFalse);
        expect(
          result.findings,
          contains('unsafePhase34KControlledRuntimeExecutionPreflight'),
        );
      });

      test('validator rejects runtime, product, proof, and report leak seams', () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
                .evaluate();
        final row = result.rows.first;
        const validator =
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticValidator();

        final findings = validator.validateRow(
          row.copyWith(
            diagnosticMode: 'unknownMode',
            executionAllowed: true,
            runtimeExecutionApproved: true,
            executionPerformed: true,
            analyzerWiringAllowed: true,
            engineCallsAllowed: true,
            schedulerAllowed: true,
            persistenceAllowed: true,
            productOutputAllowed: true,
            productAdapterAllowed: true,
            savedAnalysisAllowed: true,
            blockedReasonIds: const <String>['active:UI', 'active:engineCall'],
            sourceCaseIds: const <String>['pv-multipv-support-boundary-32e'],
            supportAreaIds: const <String>['quietPreparatoryMove'],
            proofLimitReasons: const <String>[],
            androidProofIds: const <String>[
              'king-safety-mating-net-pressure-32e',
            ],
            ownerProofRequired: true,
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
            findings: const <String>['fixtureFinding'],
            recommendation: 'wrongRecommendation',
          ),
        );

        expect(
          findings,
          contains('unknownRuntimeExecutionPreflightDiagnosticMode'),
        );
        expect(findings, contains('executionAllowedEnabled'));
        expect(findings, contains('runtimeExecutionApprovedEnabled'));
        expect(findings, contains('executionPerformedEnabled'));
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
        expect(findings, contains('blockedReasonActivated'));
        expect(findings, contains('diagnosticRowFindingsPresent'));
        expect(
          findings,
          contains(
            'missingPhase34MDisabledRuntimeExecutionSeamProbeRecommendation',
          ),
        );

        expect(
          validator.validateReportText('info depth 12 score cp 10 pv e2e4'),
          contains('reportTextLeak:pvDump'),
        );
      });

      test('markdown and JSON render deterministically without active leaks', () {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
                .evaluate();
        final markdown = result.renderMarkdown();
        final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;

        expect(
          markdown,
          contains(
            '# Controlled Analyzer Adapter Runtime Execution Preflight Diagnostic',
          ),
        );
        expect(markdown, contains('runtime execution count: 0'));
        expect(markdown, contains('runtime execution approved count: 0'));
        expect(markdown, contains('owner proof queue count: 0'));
        expect(decoded['status'], result.status.wire);
        expect(decoded['safeForPhase34M'], isTrue);
        expect(decoded['nextRecommendation'], result.nextRecommendation);
        expect(decoded['rows'], isA<List<Object?>>());
        expect(markdown, isNot(contains('bestmove e2e4')));
        expect(markdown, isNot(contains('executionPerformed: true')));
      });
    },
  );
}
