@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton', () {
    test('safe default creates disabled runtime skeleton with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonStatus
            .disabledAnalyzerAdapterRuntimeSkeletonReadyWithWarnings,
      );
      expect(result.safeForPhase34J, isTrue);
      expect(
        result.nextRecommendation,
        'runDisabledAnalyzerAdapterRuntimeSkeletonDiagnostic',
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
    });

    test('request response attempt policy and blocked seams stay disabled', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton()
              .evaluate();

      expect(result.request.requestEnvelopeId, isNotEmpty);
      expect(result.response.responseEnvelopeId, isNotEmpty);
      expect(result.executionAttempt.executionAttempted, isTrue);
      expect(result.executionAttempt.executionPerformed, isFalse);
      expect(result.executionAttempt.executionRefused, isTrue);
      expect(
        result.executionAttempt.executionRefusedReason,
        'executionDisabledByPhase34IPolicy',
      );
      expect(result.policy.executionAllowed, isFalse);
      expect(result.policy.analyzerWiringAllowed, isFalse);
      expect(result.policy.engineCallsAllowed, isFalse);
      expect(result.policy.schedulerAllowed, isFalse);
      expect(result.policy.persistenceAllowed, isFalse);
      expect(result.policy.productOutputAllowed, isFalse);
      expect(result.policy.productAdapterAllowed, isFalse);
      expect(result.policy.savedAnalysisAllowed, isFalse);
      expect(result.totalEnvelopes, 2);
      expect(result.blockedSeams.every((seam) => seam.blocked), isTrue);
      expect(
        result.blockedSeams.map((seam) => seam.blockedSeamId),
        containsAll(<String>[
          'analyzerRuntime',
          'analyzerWiring',
          'engineCall',
          'StockfishBridge',
          'AndroidCollector',
          'schedulerExecution',
          'persistenceWrite',
          'productAdapter',
          'savedAnalysisIntegration',
          'UI',
          'backend',
          'cache',
          'database',
        ]),
      );
    });

    test('unsafe Phase 34H diagnostic blocks skeleton', () {
      final preparation =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
              .evaluate();
      final unsafeDiagnostic =
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
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton()
              .evaluate(
                runtimePreparationDiagnosticResult: unsafeDiagnostic,
                runtimePreparationResult: preparation,
              );

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonStatus
            .blockedByUnsafeRuntimePreparationDiagnostic,
      );
      expect(result.safeForPhase34J, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34HControlledRuntimePreparationDiagnostic'),
      );
    });

    test('safe methods are pure disabled helpers', () {
      const skeleton = DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton();
      final preparation =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
              .evaluate();
      final diagnostic =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnostic()
              .evaluate(runtimePreparationResult: preparation);
      final request = skeleton.buildDisabledRuntimeRequest(
        diagnostic: diagnostic,
        preparation: preparation,
      );
      final attempt = skeleton.refuseExecution(request);
      final response = skeleton.buildDisabledRuntimeResponse(
        request: request,
        attempt: attempt,
      );

      expect(request.executionAllowed, isFalse);
      expect(attempt.executionPerformed, isFalse);
      expect(attempt.executionRefused, isTrue);
      expect(response.executionAllowed, isFalse);
      expect(
        skeleton.validateDisabledRuntimeSkeleton(skeleton.evaluate()),
        isEmpty,
      );
    });

    test('validator rejects runtime, integration, proof, and denied seams', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton()
              .evaluate();
      const validator = DisabledAnalyzerAdapterRuntimeSkeletonValidator();
      final requestFindings = validator.validateRequest(
        result.request.copyWith(
          executionAllowed: true,
          analyzerWiringAllowed: true,
          engineCallsAllowed: true,
          schedulerAllowed: true,
          persistenceAllowed: true,
          productOutputAllowed: true,
          productAdapterAllowed: true,
          savedAnalysisAllowed: true,
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
        requestFindings,
        contains(
          'missingPhase34JDisabledRuntimeSkeletonDiagnosticRecommendation',
        ),
      );
      expect(requestFindings, contains('executionAllowedEnabled'));
      expect(requestFindings, contains('analyzerWiringEnabled'));
      expect(requestFindings, contains('engineCallsEnabled'));
      expect(requestFindings, contains('schedulerExecutionEnabled'));
      expect(requestFindings, contains('persistenceWriteEnabled'));
      expect(requestFindings, contains('productOutputEnabled'));
      expect(requestFindings, contains('productAdapterEnabled'));
      expect(requestFindings, contains('savedAnalysisIntegrationEnabled'));
      expect(requestFindings, contains('activeDeniedFields'));
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
      expect(requestFindings, contains('analyzerResultEnabled'));
      expect(requestFindings, contains('engineResultEnabled'));
      expect(requestFindings, contains('schedulerExecutionResultEnabled'));
      expect(requestFindings, contains('cacheDatabaseWriteEnabled'));
      expect(requestFindings, contains('productAdapterBehaviorEnabled'));
      expect(requestFindings, contains('savedAnalysisIntegrationEnabled'));
      expect(requestFindings, contains('readinessSummaryChainEnabled'));
      expect(requestFindings, contains('readinessGateEnabled'));
      expect(requestFindings, contains('quietPreparatoryPromotion'));
      expect(requestFindings, contains('pvMultiPvPromotion'));
      expect(requestFindings, contains('phase32ECapturedProofClaim'));
      expect(requestFindings, contains('unprovenAndroidProofClaim'));
      expect(requestFindings, contains('ownerProofWithoutPvMultiPvReason'));

      final attemptFindings = validator.validateExecutionAttempt(
        result.executionAttempt.copyWith(
          executionPerformed: true,
          executionRefused: false,
          executionRefusedReason: '',
          deniedFieldIds: const <String>['active:productLabel'],
          recommendation: 'wrongRecommendation',
        ),
      );
      expect(attemptFindings, contains('runtimeExecutionResultEnabled'));
      expect(attemptFindings, contains('disabledExecutionAttemptNotRefused'));
      expect(attemptFindings, contains('missingExecutionRefusedReason'));
      expect(attemptFindings, contains('activeDeniedFields'));

      final policyFindings = validator.validatePolicy(
        result.policy.copyWith(
          executionAllowed: true,
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
          executableRuntimeAllowed: true,
        ),
      );
      expect(policyFindings, contains('uiBackendActivationEnabled'));
      expect(policyFindings, contains('cacheDatabaseWriteEnabled'));
      expect(policyFindings, contains('executableRuntimeEnabled'));

      final seamFindings = validator.validateBlockedSeam(
        result.blockedSeams.first.copyWith(blocked: false),
      );
      expect(seamFindings, contains('blockedSeamActivated'));
    });

    test('markdown and JSON rendering are deterministic and safe', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeleton()
              .evaluate();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(
        markdown,
        contains('# Disabled Analyzer Adapter Runtime Skeleton'),
      );
      expect(markdown, contains('execution performed: false'));
      expect(markdown, contains('execution refused: true'));
      expect(markdown, contains('safe for Phase 34J: true'));
      expect(markdown, isNot(contains('bestmove ')));
      expect(markdown, isNot(contains('active:productLabel')));
      expect(
        decoded['version'],
        debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonVersion,
      );
      expect(
        decoded['status'],
        'disabledAnalyzerAdapterRuntimeSkeletonReadyWithWarnings',
      );
      expect(decoded['safeForPhase34J'], isTrue);
      expect(
        decoded['nextRecommendation'],
        'runDisabledAnalyzerAdapterRuntimeSkeletonDiagnostic',
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

    test('validator rejects report text leaks', () {
      const validator = DisabledAnalyzerAdapterRuntimeSkeletonValidator();

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
  });
}
