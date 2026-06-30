@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic', () {
    test('safe default reports runtime input preflight diagnostic with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticStatus
            .controlledAnalyzerAdapterRuntimeInputPreflightDiagnosticReadyWithWarnings,
      );
      expect(
        result.mode,
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
            .defaultMode,
      );
      expect(result.safeForPhase34Q, isTrue);
      expect(
        result.nextRecommendation,
        'implementDisabledAnalyzerAdapterRuntimeInputEnvelopePatch',
      );
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.seamProbePerformedCount, 0);
      expect(result.runtimeExecutionCount, 0);
      expect(result.runtimeExecutionApprovedCount, 0);
      expect(result.analyzerRuntimeInputProducedCount, 0);
      expect(result.analyzerRuntimeInputApprovedCount, 0);
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
      expect(result.checkDiagnosticRowCount, 34);
      expect(result.decisionDiagnosticRowCount, 1);
      expect(result.deniedDiagnosticRowCount, 1);
      expect(result.proofDiagnosticRowCount, 1);
      expect(result.recommendationDiagnosticRowCount, 1);
    });

    test('diagnostic modes are deterministic and keep input disabled', () {
      for (final mode
          in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
              .values) {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
                .evaluate(mode: mode);

        expect(result.mode, mode);
        expect(result.safeForPhase34Q, isTrue, reason: mode.wire);
        expect(result.unsafeCount, 0, reason: mode.wire);
        expect(result.blockerCount, 0, reason: mode.wire);
        expect(
          result.rows.every((row) => row.diagnosticMode == mode.wire),
          isTrue,
          reason: mode.wire,
        );
        expect(
          result.rows.every((row) => !row.analyzerRuntimeInputApproved),
          isTrue,
          reason: mode.wire,
        );
        expect(
          result.rows.every((row) => !row.analyzerRuntimeInputProduced),
          isTrue,
          reason: mode.wire,
        );
        expect(
          result.rows.every((row) => !row.runtimeExecutionApproved),
          isTrue,
          reason: mode.wire,
        );
        expect(
          result.rows.every((row) => !row.executionAllowed),
          isTrue,
          reason: mode.wire,
        );
        expect(
          result.rows.every((row) => !row.seamProbePerformed),
          isTrue,
          reason: mode.wire,
        );
      }
    });

    test('mode-specific row counts match runtime input preflight areas', () {
      final checks =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
                        .checks,
              );
      final blockedReasons =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
                        .blockedReasons,
              );
      final decision =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
                        .decision,
              );
      final recommendation =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
                        .recommendation,
              );

      expect(checks.totalDiagnosticRows, checks.checkDiagnosticRowCount);
      expect(checks.totalDiagnosticRows, 34);
      expect(
        blockedReasons.totalDiagnosticRows,
        blockedReasons.blockedReasonDiagnosticRowCount,
      );
      expect(blockedReasons.totalDiagnosticRows, 17);
      expect(decision.totalDiagnosticRows, 1);
      expect(decision.decisionDiagnosticRowCount, 1);
      expect(recommendation.totalDiagnosticRows, 1);
      expect(recommendation.recommendationDiagnosticRowCount, 1);
    });

    test('unsafe Phase 34O runtime input preflight blocks diagnostic', () {
      final safe =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflight()
              .evaluate();
      final unsafe = ControlledAnalyzerAdapterRuntimeInputPreflightResult(
        status:
            DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightStatus
                .blockedByPolicyBoundary,
        sourceSeamProbeDiagnosticStatus: safe.sourceSeamProbeDiagnosticStatus,
        sourceSeamProbeStatus: safe.sourceSeamProbeStatus,
        sourceRuntimeExecutionPreflightDiagnosticStatus:
            safe.sourceRuntimeExecutionPreflightDiagnosticStatus,
        sourceRuntimeExecutionPreflightStatus:
            safe.sourceRuntimeExecutionPreflightStatus,
        sourceDisabledRuntimeSkeletonDiagnosticStatus:
            safe.sourceDisabledRuntimeSkeletonDiagnosticStatus,
        input: safe.input.copyWith(analyzerRuntimeInputProduced: true),
        checks: safe.checks,
        policy: safe.policy,
        decision: safe.decision,
        blockedReasons: safe.blockedReasons,
        findings: const <String>['unsafeFixture'],
        safeForPhase34P: false,
        nextRecommendation: 'blockedFixture',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
              .evaluate(runtimeInputPreflightResult: unsafe);

      expect(result.safeForPhase34Q, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34OControlledRuntimeInputPreflight'),
      );
    });

    test('unsafe Phase 34N seam probe diagnostic blocks diagnostic', () {
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
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
              .evaluate(disabledSeamProbeDiagnosticResult: unsafeDiagnostic);

      expect(result.safeForPhase34Q, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34NDisabledRuntimeExecutionSeamProbeDiagnostic'),
      );
    });

    test('validator rejects runtime input, runtime, product, and leaks', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
              .evaluate();
      final row = result.rows.first;
      const validator =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticValidator();

      final findings = validator.validateRow(
        row.copyWith(
          diagnosticMode: 'unknownMode',
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
          checkIds: const <String>['active:runtimeInput'],
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
          findings: const <String>['unsafeRowFixture'],
          recommendation: 'wrongRecommendation',
        ),
      );

      expect(findings, contains('unknownRuntimeInputPreflightDiagnosticMode'));
      expect(
        findings,
        contains('missingPhase34QDisabledRuntimeInputEnvelopeRecommendation'),
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
      expect(findings, contains('blockedReasonActivated'));
      expect(findings, contains('runtimeInputPreflightCheckActivated'));
      expect(findings, contains('activeDeniedFields'));
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
      expect(findings, contains('runtimeExecutionResultEnabled'));
      expect(findings, contains('analyzerResultEnabled'));
      expect(findings, contains('engineResultEnabled'));
      expect(findings, contains('schedulerExecutionResultEnabled'));
      expect(findings, contains('cacheDatabaseWriteEnabled'));
      expect(findings, contains('productAdapterBehaviorEnabled'));
      expect(findings, contains('savedAnalysisIntegrationEnabled'));
      expect(findings, contains('readinessSummaryChainEnabled'));
      expect(findings, contains('readinessGateEnabled'));
      expect(findings, contains('quietPreparatoryPromotion'));
      expect(findings, contains('pvMultiPvPromotion'));
      expect(findings, contains('phase32ECapturedProofClaim'));
      expect(findings, contains('unprovenAndroidProofClaim'));
      expect(findings, contains('ownerProofWithoutPvMultiPvReason'));
      expect(findings, contains('diagnosticRowFindingsPresent'));

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
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnostic()
              .evaluate();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(
        markdown,
        contains(
          '# Controlled Analyzer Adapter Runtime Input Preflight Diagnostic',
        ),
      );
      expect(markdown, contains('analyzer runtime input approved count: 0'));
      expect(markdown, contains('analyzer runtime input produced count: 0'));
      expect(markdown, contains('runtime execution count: 0'));
      expect(decoded['status'], result.status.wire);
      expect(decoded['safeForPhase34Q'], isTrue);
      expect(decoded['nextRecommendation'], result.nextRecommendation);
      expect(counts['unsafeCount'], 0);
      expect(counts['analyzerRuntimeInputApprovedCount'], 0);
      expect(counts['analyzerRuntimeInputProducedCount'], 0);
      expect(decoded['rows'], isA<List<Object?>>());
      expect(markdown, isNot(contains('bestmove e2e4')));
      expect(markdown, isNot(contains('analyzerRuntimeInputProduced: true')));
    });
  });
}
