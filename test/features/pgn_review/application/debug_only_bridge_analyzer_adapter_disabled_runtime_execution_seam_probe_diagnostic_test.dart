@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic', () {
    test('safe default reports seam probe diagnostic with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticStatus
            .disabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnosticReadyWithWarnings,
      );
      expect(
        result.mode,
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
            .defaultMode,
      );
      expect(result.safeForPhase34O, isTrue);
      expect(
        result.nextRecommendation,
        'implementControlledAnalyzerAdapterRuntimeInputPreflightPatch',
      );
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.seamProbeAttemptCount, greaterThanOrEqualTo(1));
      expect(result.seamProbePerformedCount, 0);
      expect(result.runtimeExecutionCount, 0);
      expect(result.runtimeExecutionApprovedCount, 0);
      expect(result.analyzerRuntimeInputProducedCount, 0);
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
          in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
              .values) {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic()
                .evaluate(mode: mode);

        expect(result.mode, mode);
        expect(result.safeForPhase34O, isTrue, reason: mode.wire);
        expect(result.unsafeCount, 0, reason: mode.wire);
        expect(result.blockerCount, 0, reason: mode.wire);
        expect(
          result.rows.every((row) => row.diagnosticMode == mode.wire),
          isTrue,
          reason: mode.wire,
        );
        expect(
          result.rows.every((row) => !row.seamProbePerformed),
          isTrue,
          reason: mode.wire,
        );
        expect(
          result.rows.every((row) => !row.executionPerformed),
          isTrue,
          reason: mode.wire,
        );
        expect(
          result.rows.every((row) => !row.runtimeExecutionApproved),
          isTrue,
          reason: mode.wire,
        );
        expect(
          result.rows.every((row) => !row.analyzerRuntimeInputProduced),
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

    test('mode-specific row counts match seam probe areas', () {
      final request =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
                        .request,
              );
      final boundaries =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
                        .boundaries,
              );
      final reasons =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticMode
                        .blockedReasons,
              );

      expect(request.totalDiagnosticRows, 1);
      expect(request.requestDiagnosticRowCount, 1);
      expect(
        boundaries.totalDiagnosticRows,
        boundaries.boundaryDiagnosticRowCount,
      );
      expect(boundaries.totalDiagnosticRows, 16);
      expect(
        reasons.totalDiagnosticRows,
        reasons.blockedReasonDiagnosticRowCount,
      );
      expect(reasons.totalDiagnosticRows, 24);
    });

    test('unsafe Phase 34M seam probe blocks diagnostic', () {
      final safe =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe()
              .evaluate();
      final unsafe = DisabledAnalyzerAdapterRuntimeExecutionSeamProbeResult(
        status:
            DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeStatus
                .blockedByPolicyBoundary,
        sourcePreflightDiagnosticStatus: safe.sourcePreflightDiagnosticStatus,
        sourcePreflightStatus: safe.sourcePreflightStatus,
        sourceDisabledRuntimeSkeletonDiagnosticStatus:
            safe.sourceDisabledRuntimeSkeletonDiagnosticStatus,
        sourceDisabledRuntimeSkeletonStatus:
            safe.sourceDisabledRuntimeSkeletonStatus,
        sourceRuntimePreparationDiagnosticStatus:
            safe.sourceRuntimePreparationDiagnosticStatus,
        input: safe.input.copyWith(seamProbePerformed: true),
        request: safe.request,
        response: safe.response,
        policy: safe.policy,
        attempt: safe.attempt,
        boundaries: safe.boundaries,
        blockedReasons: safe.blockedReasons,
        findings: const <String>['unsafeFixture'],
        safeForPhase34N: false,
        nextRecommendation: 'blockedFixture',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic()
              .evaluate(seamProbeResult: unsafe);

      expect(result.safeForPhase34O, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34MDisabledRuntimeExecutionSeamProbe'),
      );
    });

    test('validator rejects runtime, product, proof, and report leak seams', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic()
              .evaluate();
      final row = result.rows.first;
      const validator =
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnosticValidator();

      final findings = validator.validateRow(
        row.copyWith(
          diagnosticMode: 'unknownMode',
          seamProbePerformed: true,
          executionPerformed: true,
          executionAllowed: true,
          runtimeExecutionApproved: true,
          analyzerRuntimeInputProduced: true,
          analyzerWiringAllowed: true,
          engineCallsAllowed: true,
          schedulerAllowed: true,
          persistenceAllowed: true,
          productOutputAllowed: true,
          productAdapterAllowed: true,
          savedAnalysisAllowed: true,
          boundaryIds: const <String>['active:engineCallBoundary'],
          blockedReasonIds: const <String>['active:engineCall'],
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
          findings: const <String>['fixtureFinding'],
          recommendation: 'wrongRecommendation',
        ),
      );

      expect(findings, contains('unknownDisabledSeamProbeDiagnosticMode'));
      expect(findings, contains('seamProbePerformedEnabled'));
      expect(findings, contains('executionPerformedEnabled'));
      expect(findings, contains('executionAllowedEnabled'));
      expect(findings, contains('runtimeExecutionApprovedEnabled'));
      expect(findings, contains('analyzerRuntimeInputProduced'));
      expect(findings, contains('analyzerWiringEnabled'));
      expect(findings, contains('engineCallsEnabled'));
      expect(findings, contains('schedulerExecutionEnabled'));
      expect(findings, contains('persistenceWriteEnabled'));
      expect(findings, contains('productOutputEnabled'));
      expect(findings, contains('productAdapterEnabled'));
      expect(findings, contains('savedAnalysisIntegrationEnabled'));
      expect(findings, contains('runtimeExecutionResultEnabled'));
      expect(findings, contains('analyzerRuntimeInputEnabled'));
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
      expect(findings, contains('seamProbeBoundaryActivated'));
      expect(findings, contains('blockedReasonActivated'));
      expect(findings, contains('diagnosticRowFindingsPresent'));
      expect(
        findings,
        contains(
          'missingPhase34OControlledRuntimeInputPreflightRecommendation',
        ),
      );

      expect(
        validator.validateReportText('info depth 12 score cp 10 pv e2e4'),
        contains('reportTextLeak:pvDump'),
      );
    });

    test('markdown and JSON render deterministically without active leaks', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeDiagnostic()
              .evaluate();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;

      expect(
        markdown,
        contains(
          '# Disabled Analyzer Adapter Runtime Execution Seam Probe Diagnostic',
        ),
      );
      expect(markdown, contains('seam probe performed count: 0'));
      expect(markdown, contains('runtime execution count: 0'));
      expect(markdown, contains('analyzer runtime input produced count: 0'));
      expect(decoded['status'], result.status.wire);
      expect(decoded['safeForPhase34O'], isTrue);
      expect(decoded['nextRecommendation'], result.nextRecommendation);
      expect(decoded['rows'], isA<List<Object?>>());
      expect(markdown, isNot(contains('bestmove e2e4')));
      expect(markdown, isNot(contains('seamProbePerformed: true')));
    });
  });
}
