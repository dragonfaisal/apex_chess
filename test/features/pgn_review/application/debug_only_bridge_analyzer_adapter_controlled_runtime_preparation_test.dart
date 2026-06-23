@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_patch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation', () {
    test('safe default prepares disabled runtime boundary with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationStatus
            .controlledAnalyzerAdapterRuntimePreparationReadyWithWarnings,
      );
      expect(result.safeForPhase34H, isTrue);
      expect(
        result.nextRecommendation,
        'runControlledAnalyzerAdapterRuntimePreparationDiagnostic',
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

    test('input, envelopes, preconditions, and blocked seams are concrete', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
              .evaluate();

      expect(result.input.preparationId, isNotEmpty);
      expect(result.input.sourceDiagnosticIds, isNotEmpty);
      expect(result.input.sourceCaseIds, isNotEmpty);
      expect(result.totalPreconditions, greaterThanOrEqualTo(3));
      expect(result.totalEnvelopes, 2);
      expect(result.inputEnvelopeCount, 1);
      expect(result.outputEnvelopeCount, 1);
      expect(
        result.envelopes.every((envelope) => !envelope.executionAllowed),
        isTrue,
      );
      expect(
        result.envelopes.every((envelope) => !envelope.analyzerWiringAllowed),
        isTrue,
      );
      expect(
        result.preconditions.every(
          (precondition) => !precondition.executableNow,
        ),
        isTrue,
      );
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
      expect(result.blockedSeams.every((seam) => seam.blocked), isTrue);
    });

    test('unsafe Phase 34F diagnostic blocks preparation', () {
      final unsafePatch =
          DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult(
            status:
                DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus
                    .blockedByPolicyBoundary,
            sourceDiagnosticStatus: 'unsafeSourceDiagnostic',
            sourcePatchSetStatus: 'unsafePatchSet',
            refinements:
                const <
                  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord
                >[],
            findings: const <String>['unsafeFixture'],
            allowedTargetSurfaces: const <String>[],
            forbiddenTargetSurfaces: const <String>[],
            safeForPhase34F: false,
            nextRecommendation: 'blockedFixture',
          );
      final unsafeDiagnostic =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic()
              .evaluate(refinementPatchResult: unsafePatch);
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
              .evaluate(metadataRefinementDiagnosticResult: unsafeDiagnostic);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationStatus
            .blockedByUnsafeMetadataRefinementDiagnostic,
      );
      expect(result.safeForPhase34H, isFalse);
      expect(
        result.findings,
        contains('unsafePhase34FMetadataRefinementDiagnostic'),
      );
    });

    test('validator rejects runtime, boundary, proof, and denied seams', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
              .evaluate();
      const validator =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationValidator();
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
          deniedFieldIds: const <String>[
            'active:productLabel',
            'active:finalMoveLabel',
            'active:classifierLabels',
            'active:numericMoveScore',
            'active:officialMetric',
            'active:cpLoss',
            'active:winProbability',
            'active:moveRanking',
            'active:thresholds',
            'active:stockfishCommand',
            'active:rawUci',
            'active:pvDump',
            'active:androidCollectorRequirement',
            'active:readinessSummaryChain',
            'active:readinessGate',
          ],
        ),
      );

      expect(policyFindings, contains('executionAllowedEnabled'));
      expect(policyFindings, contains('analyzerWiringEnabled'));
      expect(policyFindings, contains('engineCallsEnabled'));
      expect(policyFindings, contains('schedulerExecutionEnabled'));
      expect(policyFindings, contains('persistenceWriteEnabled'));
      expect(policyFindings, contains('productOutputEnabled'));
      expect(policyFindings, contains('productAdapterEnabled'));
      expect(policyFindings, contains('savedAnalysisIntegrationEnabled'));
      expect(policyFindings, contains('uiBackendActivationEnabled'));
      expect(policyFindings, contains('cacheDatabaseWriteEnabled'));
      expect(policyFindings, contains('executableRuntimeEnabled'));
      expect(policyFindings, contains('activeDeniedFields'));
      expect(policyFindings, contains('productLabelsEnabled'));
      expect(policyFindings, contains('finalLabelsEnabled'));
      expect(policyFindings, contains('classifierLabelsEnabled'));
      expect(policyFindings, contains('scoresEnabled'));
      expect(policyFindings, contains('rankingsMetricsEnabled'));
      expect(policyFindings, contains('cpLossEnabled'));
      expect(policyFindings, contains('winProbabilityEnabled'));
      expect(policyFindings, contains('thresholdsEnabled'));
      expect(policyFindings, contains('stockfishCommandEnabled'));
      expect(policyFindings, contains('rawUciEnabled'));
      expect(policyFindings, contains('pvDumpEnabled'));
      expect(policyFindings, contains('androidCollectorRequirementEnabled'));
      expect(policyFindings, contains('readinessSummaryChainEnabled'));
      expect(policyFindings, contains('readinessGateEnabled'));

      final envelopeFindings = validator.validateEnvelope(
        result.envelopes.first.copyWith(
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
          androidProofIds: const <String>[
            'king-safety-mating-net-pressure-32e',
          ],
          ownerProofRequired: true,
          proofLimitReasons: const <String>[],
          deniedFieldIds: const <String>['active:productLabel'],
        ),
      );

      expect(envelopeFindings, contains('runtimeExecutionResultEnabled'));
      expect(envelopeFindings, contains('analyzerResultEnabled'));
      expect(envelopeFindings, contains('engineResultEnabled'));
      expect(envelopeFindings, contains('schedulerExecutionResultEnabled'));
      expect(envelopeFindings, contains('persistenceWriteEnabled'));
      expect(envelopeFindings, contains('productOutputEnabled'));
      expect(envelopeFindings, contains('productAdapterEnabled'));
      expect(envelopeFindings, contains('savedAnalysisIntegrationEnabled'));
      expect(envelopeFindings, contains('quietPreparatoryPromotion'));
      expect(envelopeFindings, contains('pvMultiPvPromotion'));
      expect(envelopeFindings, contains('phase32ECapturedProofClaim'));
      expect(envelopeFindings, contains('unprovenAndroidProofClaim'));
      expect(envelopeFindings, contains('ownerProofWithoutPvMultiPvReason'));
      expect(envelopeFindings, contains('activeDeniedFields'));

      final seamFindings = validator.validateBlockedSeam(
        result.blockedSeams.first.copyWith(blocked: false),
      );
      expect(seamFindings, contains('blockedSeamActivated'));
      expect(seamFindings, contains('activeDeniedFields'));

      final preconditionFindings = validator.validatePrecondition(
        result.preconditions.first.copyWith(executableNow: true),
      );
      expect(preconditionFindings, contains('runtimePreconditionExecutable'));
    });

    test('markdown and JSON rendering are deterministic and safe', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparation()
              .evaluate();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(markdown, contains('## Disabled Execution Policy'));
      expect(markdown, contains('executionAllowed: false'));
      expect(markdown, contains('analyzerWiringAllowed: false'));
      expect(markdown, contains('## Runtime Preparation Envelopes'));
      expect(markdown, contains('## Blocked Seam Summary'));
      expect(markdown, isNot(contains('bestmove ')));
      expect(markdown, isNot(contains('active:productLabel')));
      expect(
        decoded['version'],
        debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationVersion,
      );
      expect(
        decoded['status'],
        'controlledAnalyzerAdapterRuntimePreparationReadyWithWarnings',
      );
      expect(decoded['safeForPhase34H'], isTrue);
      expect(
        decoded['nextRecommendation'],
        'runControlledAnalyzerAdapterRuntimePreparationDiagnostic',
      );
      expect(counts['runtimeExecutionCount'], 0);
      expect(counts['analyzerWiringCount'], 0);
      expect(counts['engineCallCount'], 0);
      expect(counts['schedulerExecutionCount'], 0);
      expect(counts['persistenceWriteCount'], 0);
      expect(counts['productOutputCount'], 0);
      expect(counts['activeDeniedFieldCount'], 0);
    });

    test('validator rejects report text leaks', () {
      const validator =
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationValidator();

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
