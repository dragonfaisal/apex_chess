@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic', () {
    test('safe default reports disabled runtime preparation with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus
            .controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyWithWarnings,
      );
      expect(
        result.mode,
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
            .defaultMode,
      );
      expect(result.sourcePreparationStatus, isNotEmpty);
      expect(result.safeForPhase34I, isTrue);
      expect(
        result.nextRecommendation,
        'implementDisabledAnalyzerAdapterRuntimeSkeleton',
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
      expect(result.totalDiagnosticRows, greaterThan(0));
    });

    test('diagnostic modes are deterministic and safe', () {
      for (final mode
          in DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
              .values) {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
                .evaluate(mode: mode);

        expect(result.mode, mode);
        expect(result.safeForPhase34I, isTrue, reason: mode.wire);
        expect(result.unsafeCount, 0, reason: mode.wire);
        expect(result.blockerCount, 0, reason: mode.wire);
        expect(result.criticalCount, 0, reason: mode.wire);
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
          result.rows.every((row) => !row.analyzerWiringAllowed),
          isTrue,
          reason: mode.wire,
        );
        expect(
          result.rows.every((row) => !row.engineCallsAllowed),
          isTrue,
          reason: mode.wire,
        );
      }
    });

    test('mode-specific row counts match selected runtime-preparation areas', () {
      final envelopes =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
                        .envelopes,
              );
      final preconditions =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
                        .preconditions,
              );
      final policy =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
                        .policy,
              );
      final blockedSeams =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
                        .blockedSeams,
              );
      final proof =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
                        .proof,
              );

      expect(
        envelopes.totalDiagnosticRows,
        envelopes.envelopeDiagnosticRowCount,
      );
      expect(
        preconditions.totalDiagnosticRows,
        preconditions.preconditionDiagnosticRowCount,
      );
      expect(policy.totalDiagnosticRows, 1);
      expect(policy.policyDiagnosticRowCount, 1);
      expect(
        blockedSeams.totalDiagnosticRows,
        blockedSeams.blockedSeamDiagnosticRowCount,
      );
      expect(proof.totalDiagnosticRows, 1);
      expect(proof.proofDiagnosticRowCount, 1);
    });

    test('unsafe Phase 34G runtime preparation blocks diagnostic', () {
      final source =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
              .evaluate();
      final unsafeSource = ControlledAnalyzerAdapterRuntimePreparationResult(
        status: DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationStatus
            .blockedByPolicyBoundary,
        sourceMetadataRefinementDiagnosticStatus:
            source.sourceMetadataRefinementDiagnosticStatus,
        sourceMetadataRefinementStatus: source.sourceMetadataRefinementStatus,
        sourcePatchSetDiagnosticStatus: source.sourcePatchSetDiagnosticStatus,
        input: source.input,
        policy: source.policy,
        preconditions: source.preconditions,
        envelopes: source.envelopes,
        blockedSeams: source.blockedSeams,
        findings: const <String>['unsafeFixture'],
        safeForPhase34H: false,
        nextRecommendation: 'blockedFixture',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
              .evaluate(runtimePreparationResult: unsafeSource);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus
            .blockedByUnsafeControlledRuntimePreparation,
      );
      expect(result.safeForPhase34I, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34GControlledRuntimePreparation'),
      );
    });

    test('validator rejects runtime, proof, denied, and report leak seams', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
              .evaluate();
      final row = result.rows.first;
      const validator =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticValidator();

      final findings = validator.validateRow(
        row.copyWith(
          preparationRole: 'unknownRole',
          executionAllowed: true,
          analyzerWiringAllowed: true,
          engineCallsAllowed: true,
          schedulerAllowed: true,
          persistenceAllowed: true,
          productOutputAllowed: true,
          productAdapterAllowed: true,
          savedAnalysisAllowed: true,
          blockedSeamIds: const <String>['active:UI'],
          deniedFieldIds: const <String>[
            'active:productLabel',
            'active:finalMoveLabel',
            'active:classifierLabels',
            'active:numericMoveScore',
            'active:aggregateScore',
            'active:officialMetric',
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
          supportAreaIds: const <String>['quietPreparatoryMove'],
          sourceCaseIds: const <String>['pv-multipv-support-boundary-32e'],
          proofLimitReasons: const <String>[],
          androidProofIds: const <String>[
            'king-safety-mating-net-pressure-32e',
          ],
          ownerProofRequired: true,
          recommendation: 'wrongRecommendation',
        ),
      );

      expect(findings, contains('unknownRuntimePreparationDiagnosticRole'));
      expect(
        findings,
        contains('missingPhase34IDisabledRuntimeSkeletonRecommendation'),
      );
      expect(findings, contains('executionAllowedEnabled'));
      expect(findings, contains('analyzerWiringEnabled'));
      expect(findings, contains('engineCallsEnabled'));
      expect(findings, contains('schedulerExecutionEnabled'));
      expect(findings, contains('persistenceWriteEnabled'));
      expect(findings, contains('productOutputEnabled'));
      expect(findings, contains('productAdapterEnabled'));
      expect(findings, contains('savedAnalysisIntegrationEnabled'));
      expect(findings, contains('uiBackendCacheDatabaseActivationEnabled'));
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

      expect(
        validator.validateReportText('bestmove e2e4'),
        contains('reportTextLeak:stockfishBestMove'),
      );
      expect(
        validator.validateReportText('position fen 8/8/8/8/8/8/8/8 w - - 0 1'),
        contains('reportTextLeak:stockfishPosition'),
      );
      expect(
        validator.validateReportText('go movetime 1000'),
        contains('reportTextLeak:stockfishCommand'),
      );
      expect(
        validator.validateReportText('info depth 1 score cp 20 pv e2e4'),
        contains('reportTextLeak:pvDump'),
      );
    });

    test('markdown and JSON output remain deterministic and safe', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
              .evaluate();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(
        markdown,
        contains(
          '# Controlled Analyzer Adapter Runtime Preparation Diagnostic',
        ),
      );
      expect(markdown, contains('| Execution |'));
      expect(markdown, contains('safe for Phase 34I: true'));
      expect(markdown, isNot(contains('bestmove ')));
      expect(markdown, isNot(contains('active:productLabel')));
      expect(
        decoded['version'],
        debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticVersion,
      );
      expect(
        decoded['status'],
        'controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyWithWarnings',
      );
      expect(decoded['safeForPhase34I'], isTrue);
      expect(
        decoded['nextRecommendation'],
        'implementDisabledAnalyzerAdapterRuntimeSkeleton',
      );
      expect(counts['runtimeExecutionCount'], 0);
      expect(counts['executableRuntimeCount'], 0);
      expect(counts['analyzerWiringCount'], 0);
      expect(counts['engineCallCount'], 0);
      expect(counts['schedulerExecutionCount'], 0);
      expect(counts['persistenceWriteCount'], 0);
      expect(counts['productOutputCount'], 0);
      expect(counts['productAdapterCount'], 0);
      expect(counts['savedAnalysisIntegrationCount'], 0);
      expect(counts['activeDeniedFieldCount'], 0);
    });
  });
}
