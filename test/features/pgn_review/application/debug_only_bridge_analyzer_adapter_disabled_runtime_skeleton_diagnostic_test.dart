@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic', () {
    test('safe default reports disabled runtime skeleton with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticStatus
            .disabledAnalyzerAdapterRuntimeSkeletonDiagnosticReadyWithWarnings,
      );
      expect(
        result.mode,
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
            .defaultMode,
      );
      expect(result.safeForPhase34K, isTrue);
      expect(
        result.nextRecommendation,
        'implementControlledAnalyzerAdapterRuntimeExecutionPreflightPatch',
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
          in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
              .values) {
        final result =
            const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
                .evaluate(mode: mode);

        expect(result.mode, mode);
        expect(result.safeForPhase34K, isTrue, reason: mode.wire);
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

    test('mode-specific row counts match selected skeleton areas', () {
      final request =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
                        .request,
              );
      final response =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
                        .response,
              );
      final attempt =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
                        .attempt,
              );
      final blocked =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
              .evaluate(
                mode:
                    DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
                        .blockedSeams,
              );

      expect(request.totalDiagnosticRows, request.requestDiagnosticRowCount);
      expect(response.totalDiagnosticRows, response.responseDiagnosticRowCount);
      expect(attempt.totalDiagnosticRows, 1);
      expect(attempt.attemptDiagnosticRowCount, 1);
      expect(attempt.rows.single.executionAttempted, isTrue);
      expect(attempt.rows.single.executionPerformed, isFalse);
      expect(
        blocked.totalDiagnosticRows,
        blocked.blockedSeamDiagnosticRowCount,
      );
    });

    test('unsafe Phase 34I skeleton blocks diagnostic', () {
      final safe = const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton()
          .evaluate();
      final unsafe = DisabledAnalyzerAdapterRuntimeSkeletonResult(
        status: DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonStatus
            .blockedByPolicyBoundary,
        sourceDiagnosticStatus: safe.sourceDiagnosticStatus,
        sourcePreparationStatus: safe.sourcePreparationStatus,
        request: safe.request.copyWith(executionAllowed: true),
        response: safe.response,
        policy: safe.policy,
        envelopes: safe.envelopes,
        executionAttempt: safe.executionAttempt,
        blockedSeams: safe.blockedSeams,
        findings: const <String>['unsafeFixture'],
        safeForPhase34J: false,
        nextRecommendation: 'blockedFixture',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
              .evaluate(skeletonResult: unsafe);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticStatus
            .blockedByPolicyBoundary,
      );
      expect(result.safeForPhase34K, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34IDisabledRuntimeSkeleton'),
      );
    });

    test('unsafe Phase 34H diagnostic input blocks diagnostic', () {
      final preparation =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
              .evaluate();
      final unsafeRuntimeDiagnostic =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticResult(
            status:
                DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus
                    .blockedByPolicyBoundary,
            mode:
                DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
                    .defaultMode,
            sourcePreparationStatus: preparation.status.wire,
            sourceMetadataRefinementDiagnosticStatus:
                preparation.sourceMetadataRefinementDiagnosticStatus,
            sourceMetadataRefinementStatus:
                preparation.sourceMetadataRefinementStatus,
            rows:
                const <
                  DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticRow
                >[],
            findings: const <String>['unsafeFixture'],
            safeForPhase34I: false,
            nextRecommendation: 'blockedFixture',
          );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
              .evaluate(
                runtimePreparationResult: preparation,
                runtimePreparationDiagnosticResult: unsafeRuntimeDiagnostic,
              );

      expect(result.safeForPhase34K, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34HControlledRuntimePreparationDiagnostic'),
      );
    });

    test('validator rejects runtime, proof, denied, and report leak seams', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
              .evaluate();
      final row = result.rows.first;
      const validator =
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticValidator();

      final findings = validator.validateRow(
        row.copyWith(
          diagnosticMode: 'unknownMode',
          executionAttempted: true,
          executionPerformed: true,
          executionRefusedReason: '',
          executionAllowed: true,
          analyzerWiringAllowed: true,
          engineCallsAllowed: true,
          schedulerAllowed: true,
          persistenceAllowed: true,
          productOutputAllowed: true,
          productAdapterAllowed: true,
          savedAnalysisAllowed: true,
          blockedSeamIds: const <String>['active:UI', 'active:engineCall'],
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
          recommendation: 'wrongRecommendation',
        ),
      );

      expect(
        findings,
        contains(
          'missingPhase34KControlledRuntimeExecutionPreflightRecommendation',
        ),
      );
      expect(
        findings,
        contains('unknownDisabledRuntimeSkeletonDiagnosticMode'),
      );
      expect(findings, contains('runtimeExecutionResultEnabled'));
      expect(findings, contains('executionAllowedEnabled'));
      expect(findings, contains('analyzerWiringEnabled'));
      expect(findings, contains('engineCallsEnabled'));
      expect(findings, contains('schedulerExecutionEnabled'));
      expect(findings, contains('persistenceWriteEnabled'));
      expect(findings, contains('productOutputEnabled'));
      expect(findings, contains('productAdapterEnabled'));
      expect(findings, contains('savedAnalysisIntegrationEnabled'));
      expect(findings, contains('blockedSeamActivated'));
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
        validator.validateReportText('info depth 1 score cp 20 pv e2e4'),
        contains('reportTextLeak:pvDump'),
      );
    });

    test('markdown and JSON rendering are deterministic and safe', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnostic()
              .evaluate();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(
        markdown,
        contains('# Disabled Analyzer Adapter Runtime Skeleton Diagnostic'),
      );
      expect(markdown, contains('disabled runtime skeleton diagnostic mode'));
      expect(markdown, contains('safe for Phase 34K: true'));
      expect(markdown, isNot(contains('bestmove ')));
      expect(markdown, isNot(contains('active:productLabel')));
      expect(
        decoded['version'],
        debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticVersion,
      );
      expect(
        decoded['status'],
        'disabledAnalyzerAdapterRuntimeSkeletonDiagnosticReadyWithWarnings',
      );
      expect(decoded['safeForPhase34K'], isTrue);
      expect(
        decoded['nextRecommendation'],
        'implementControlledAnalyzerAdapterRuntimeExecutionPreflightPatch',
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
