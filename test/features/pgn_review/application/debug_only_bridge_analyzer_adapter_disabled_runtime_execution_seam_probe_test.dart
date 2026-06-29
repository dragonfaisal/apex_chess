@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe', () {
    test('safe default creates disabled seam probe with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeStatus
            .disabledAnalyzerAdapterRuntimeExecutionSeamProbeReadyWithWarnings,
      );
      expect(result.safeForPhase34N, isTrue);
      expect(
        result.nextRecommendation,
        'runDisabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnostic',
      );
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.seamProbeAttemptCount, greaterThanOrEqualTo(1));
      expect(result.seamProbePerformedCount, 0);
      expect(result.runtimeExecutionCount, 0);
      expect(result.runtimeExecutionApprovedCount, 0);
      expect(result.analyzerRuntimeInputCount, 0);
      expect(result.analyzerWiringCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
      expect(result.persistenceWriteCount, 0);
      expect(result.productOutputCount, 0);
      expect(result.productAdapterCount, 0);
      expect(result.savedAnalysisIntegrationCount, 0);
      expect(result.activeDeniedFieldCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('request response and attempt remain refused metadata only', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe()
              .evaluate();

      expect(result.request.seamProbeRequested, isTrue);
      expect(result.request.seamProbePerformed, isFalse);
      expect(result.request.executionPerformed, isFalse);
      expect(result.request.runtimeExecutionApproved, isFalse);
      expect(result.request.analyzerRuntimeInputProduced, isFalse);
      expect(result.attempt.seamProbeRequested, isTrue);
      expect(result.attempt.seamProbePerformed, isFalse);
      expect(result.attempt.executionPerformed, isFalse);
      expect(result.attempt.runtimeExecutionApproved, isFalse);
      expect(result.attempt.analyzerRuntimeInputProduced, isFalse);
      expect(result.attempt.refused, isTrue);
      expect(result.attempt.refusedReason, 'seamProbeDisabledByPolicy');
      expect(
        result.response.responseStatus,
        'disabledSeamProbeRefusedByPolicy',
      );
      expect(result.response.seamProbePerformed, isFalse);
      expect(result.response.executionPerformed, isFalse);
      expect(result.response.analyzerRuntimeInputProduced, isFalse);
    });

    test('boundaries and blocked reasons are deterministic and blocked', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe()
              .evaluate();

      expect(result.totalBoundaries, 16);
      expect(result.blockedBoundaryCount, result.totalBoundaries);
      expect(result.totalBlockedReasons, 24);
      expect(
        result.boundaries.map((boundary) => boundary.boundaryId),
        containsAll(const <String>[
          'disabledRuntimeSkeletonBoundary',
          'runtimeExecutionPreflightBoundary',
          'analyzerRuntimeInputBoundary',
          'analyzerWiringBoundary',
          'engineCallBoundary',
          'stockfishBridgeBoundary',
          'androidCollectorBoundary',
          'schedulerExecutionBoundary',
          'persistenceWriteBoundary',
          'productOutputBoundary',
          'productAdapterBoundary',
          'savedAnalysisBoundary',
          'uiBoundary',
          'backendBoundary',
          'cacheBoundary',
          'databaseBoundary',
        ]),
      );
      expect(
        result.blockedReasons.map((reason) => reason.blockedReasonId),
        containsAll(const <String>[
          'seamProbeDisabledByPolicy',
          'runtimeExecutionNotApproved',
          'executionAllowedFalse',
          'analyzerRuntimeInputBlocked',
          'stockfishCommandBlocked',
          'rawUciBlocked',
          'pvDumpBlocked',
          'phase32EProofHonestyPreserved',
          'quietPreparatoryExclusionPreserved',
        ]),
      );
      expect(result.boundaries.every((boundary) => boundary.blocked), isTrue);
      expect(result.blockedReasons.every((reason) => reason.blocked), isTrue);
    });

    test('unsafe Phase 34L preflight diagnostic blocks seam probe', () {
      final preflight =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflight()
              .evaluate();
      final safeDiagnostic =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnostic()
              .evaluate(runtimeExecutionPreflightResult: preflight);
      final unsafeDiagnostic =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticResult(
            status:
                DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticStatus
                    .blockedByPolicyBoundary,
            mode: safeDiagnostic.mode,
            sourcePreflightStatus: safeDiagnostic.sourcePreflightStatus,
            sourceDisabledRuntimeSkeletonDiagnosticStatus:
                safeDiagnostic.sourceDisabledRuntimeSkeletonDiagnosticStatus,
            sourceDisabledRuntimeSkeletonStatus:
                safeDiagnostic.sourceDisabledRuntimeSkeletonStatus,
            sourceRuntimePreparationDiagnosticStatus:
                safeDiagnostic.sourceRuntimePreparationDiagnosticStatus,
            sourceRuntimePreparationStatus:
                safeDiagnostic.sourceRuntimePreparationStatus,
            rows: safeDiagnostic.rows,
            findings: const <String>['unsafeFixture'],
            safeForPhase34M: false,
            nextRecommendation: 'blockedFixture',
          );

      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe()
              .evaluate(
                runtimeExecutionPreflightResult: preflight,
                runtimeExecutionPreflightDiagnosticResult: unsafeDiagnostic,
              );

      expect(result.safeForPhase34N, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34LRuntimeExecutionPreflightDiagnostic'),
      );
    });

    test('validator rejects execution, product, proof, and leak seams', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe()
              .evaluate();
      const validator =
          DisabledAnalyzerAdapterRuntimeExecutionSeamProbeValidator();

      final requestFindings = validator.validateRequest(
        result.request.copyWith(
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
          supportAreaIds: const <String>['quietPreparatoryMove'],
          proofLimitReasons: const <String>[],
          androidProofIds: const <String>['king-safety-mating-net-32e'],
          ownerProofRequired: true,
          deniedFieldIds: const <String>[
            'active:productLabel',
            'active:finalMoveLabel',
            'active:classifierLabel',
            'active:brilliantLabel',
            'active:bestMoveLabel',
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
      );

      expect(requestFindings, contains('seamProbePerformedEnabled'));
      expect(requestFindings, contains('executionPerformedEnabled'));
      expect(requestFindings, contains('executionAllowedEnabled'));
      expect(requestFindings, contains('runtimeExecutionApprovedEnabled'));
      expect(requestFindings, contains('analyzerRuntimeInputProduced'));
      expect(requestFindings, contains('analyzerWiringEnabled'));
      expect(requestFindings, contains('engineCallsEnabled'));
      expect(requestFindings, contains('schedulerExecutionEnabled'));
      expect(requestFindings, contains('persistenceWriteEnabled'));
      expect(requestFindings, contains('productOutputEnabled'));
      expect(requestFindings, contains('productAdapterEnabled'));
      expect(requestFindings, contains('savedAnalysisIntegrationEnabled'));
      expect(requestFindings, contains('productLabelsEnabled'));
      expect(requestFindings, contains('finalLabelsEnabled'));
      expect(requestFindings, contains('classifierLabelsEnabled'));
      expect(requestFindings, contains('scoresEnabled'));
      expect(requestFindings, contains('rankingsMetricsAccuracyAcplEnabled'));
      expect(requestFindings, contains('cpLossEnabled'));
      expect(requestFindings, contains('winProbabilityEnabled'));
      expect(requestFindings, contains('thresholdsEnabled'));
      expect(requestFindings, contains('stockfishCommandEnabled'));
      expect(requestFindings, contains('rawUciEnabled'));
      expect(requestFindings, contains('pvDumpEnabled'));
      expect(requestFindings, contains('androidCollectorRequirementEnabled'));
      expect(requestFindings, contains('runtimeExecutionResultEnabled'));
      expect(requestFindings, contains('analyzerRuntimeInputEnabled'));
      expect(requestFindings, contains('analyzerResultEnabled'));
      expect(requestFindings, contains('engineResultEnabled'));
      expect(requestFindings, contains('schedulerExecutionResultEnabled'));
      expect(requestFindings, contains('cacheDatabaseWriteEnabled'));
      expect(requestFindings, contains('productAdapterBehaviorEnabled'));
      expect(requestFindings, contains('savedAnalysisIntegrationEnabled'));
      expect(requestFindings, contains('readinessSummaryChainEnabled'));
      expect(requestFindings, contains('readinessGateEnabled'));
      expect(requestFindings, contains('quietPreparatoryPromotion'));
      expect(requestFindings, contains('phase32ECapturedProofClaim'));
      expect(requestFindings, contains('unprovenAndroidProofClaim'));
      expect(requestFindings, contains('ownerProofWithoutPvMultiPvReason'));
      expect(
        requestFindings,
        contains('missingPhase34NDisabledSeamProbeDiagnosticRecommendation'),
      );

      expect(
        validator.validateReportText('info depth 12 score cp 10 pv e2e4'),
        contains('reportTextLeak:pvDump'),
      );
    });

    test('markdown and JSON render deterministically without active leaks', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbe()
              .evaluate();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(
        markdown,
        contains('# Disabled Analyzer Adapter Runtime Execution Seam Probe'),
      );
      expect(markdown, contains('seam probe performed count: 0'));
      expect(markdown, contains('runtime execution approved count: 0'));
      expect(markdown, contains('analyzer runtime input count: 0'));
      expect(decoded['status'], result.status.wire);
      expect(decoded['safeForPhase34N'], isTrue);
      expect(decoded['nextRecommendation'], result.nextRecommendation);
      expect(counts['seamProbeAttemptCount'], greaterThanOrEqualTo(1));
      expect(counts['seamProbePerformedCount'], 0);
      expect(counts['runtimeExecutionCount'], 0);
      expect(counts['runtimeExecutionApprovedCount'], 0);
      expect(counts['analyzerRuntimeInputCount'], 0);
      expect(markdown, isNot(contains('bestmove e2e4')));
      expect(markdown, isNot(contains('executionPerformed: true')));
    });
  });
}
