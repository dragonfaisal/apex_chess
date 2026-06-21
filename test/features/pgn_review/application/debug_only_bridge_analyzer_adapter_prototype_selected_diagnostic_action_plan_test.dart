@TestOn('vm')
library;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_selected_diagnostic_action_plan.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_selected_golden_diagnostic_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan', () {
    test('safe default creates action plan with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanStatus
            .selectedDiagnosticActionPlanReadyWithWarnings,
      );
      expect(result.safeForPhase34C, isTrue);
      expect(
        result.nextRecommendation,
        'implementAnalyzerAdapterPrototypeActionPlanPatchSet',
      );
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.analyzerWiringCount, 0);
      expect(result.runtimeImplementationCount, 0);
      expect(result.executablePrototypeCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
      expect(result.persistenceWriteCount, 0);
      expect(result.productOutputCount, 0);
      expect(result.activeDeniedFieldCount, 0);
    });

    test('action groups are populated from selected diagnostics', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan()
              .evaluate();

      expect(result.safeInternalSupportActionCount, greaterThan(0));
      expect(result.warningLimitedFollowupActionCount, greaterThan(0));
      expect(result.proofBoundaryActionCount, greaterThan(0));
      expect(result.excludedGuardActionCount, greaterThan(0));
      expect(result.deniedFieldProtectionActionCount, 1);
      expect(result.prototypeSkeletonImprovementActionCount, 1);
      expect(result.diagnosticCoverageActionCount, greaterThan(0));
      expect(result.futureRuntimePrerequisiteActionCount, 1);
      expect(result.blockedIntegrationActionCount, 1);
      expect(result.phase34CRequirementActionCount, 1);
    });

    test('role mapping preserves selected diagnostic boundaries', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan()
              .evaluate();
      final byCase = {
        for (final action in result.actions) action.sourceCaseId: action,
      };

      expect(
        byCase['queen-win-major-swing']!.actionGroup,
        'safeInternalSupportActions',
      );
      expect(byCase['queen-win-major-swing']!.priority, 'medium');
      expect(
        byCase['king-safety-mating-net-pressure-32e']!.actionGroup,
        'warningLimitedFollowupActions',
      );
      expect(
        byCase['pv-multipv-support-boundary-32e']!.actionGroup,
        'proofBoundaryActions',
      );
      expect(byCase['pv-multipv-support-boundary-32e']!.priority, 'high');
      expect(
        byCase['quiet-preparatory-hard-case']!.actionGroup,
        'excludedGuardActions',
      );
      expect(byCase['quiet-preparatory-hard-case']!.priority, 'high');
    });

    test('denied and blocked integration actions remain inactive', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan()
              .evaluate();
      final denied = result.actions.singleWhere(
        (action) => action.actionGroup == 'deniedFieldProtectionActions',
      );
      final blocked = result.actions.singleWhere(
        (action) => action.actionGroup == 'blockedIntegrationActions',
      );

      expect(denied.priority, 'critical');
      expect(denied.implementationAllowedNow, isFalse);
      expect(denied.deniedFieldIds, contains('productLabel'));
      expect(denied.deniedFieldIds, contains('stockfishCommand'));
      expect(blocked.priority, 'blocked');
      expect(blocked.implementationAllowedNow, isFalse);
      expect(blocked.blockedBoundaryIds, contains('analyzerWiring'));
      expect(blocked.blockedBoundaryIds, contains('schedulerExecution'));
    });

    test('unsafe Phase 34A input blocks action plan', () {
      final validation = const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation().evaluate(
        source: DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSource(
          phase33YDiagnosticPathSafe: false,
          phase33ZSelectedDiagnosticPathSafe: true,
          defaultSelectedOutputDeterministic: true,
          allSafeSelectedOutputDeterministic: true,
          singleSelectedCaseOutputDeterministic: true,
          listGoldenCasesOutputDeterministic: true,
          goldenSectionOutputDeterministic: true,
          markdownJsonStrictModesSafe: true,
          defaultSelectedRows:
              const <
                DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
              >[],
          allSafeSelectedRows:
              const <
                DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
              >[],
          singleSelectedRows:
              const <
                DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
              >[],
          listedGoldenCaseIds: const <String>[],
          reportTexts: const <String>[],
        ),
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan()
              .evaluate(validationResult: validation);

      expect(result.safeForPhase34C, isFalse);
      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanStatus
            .blockedByUnsafeSelectedDiagnosticValidation,
      );
      expect(result.findings, contains('unsafePhase34AInput'));
    });

    test('validator rejects policy seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanValidator();
      final findings = validator.validateActions(
        <DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord>[
          _action().copyWith(actionGroup: 'unknownGroup'),
          _action().copyWith(actionType: 'unknownType'),
          _action().copyWith(
            sourceCaseId: 'quiet-preparatory-hard-case',
            supportAreaIds: const <String>['quietPreparatoryMove'],
            actionGroup: 'safeInternalSupportActions',
          ),
          _action().copyWith(
            sourceCaseId: 'pv-multipv-support-boundary-32e',
            actionGroup: 'safeInternalSupportActions',
          ),
          _action().copyWith(
            sourceCaseId: 'king-safety-mating-net-pressure-32e',
            androidProofIds: const <String>[
              'king-safety-mating-net-pressure-32e',
            ],
          ),
          _action().copyWith(
            ownerProofRequired: true,
            proofLimitReasons: const <String>[],
          ),
          _action().copyWith(
            implementationAllowedNow: true,
            deniedFieldIds: const <String>[
              'productLabel',
              'finalMoveLabel',
              'classifierLabels',
              'numericMoveScore',
              'officialAccuracy',
              'cpLoss',
              'winProbability',
              'moveRanking',
              'thresholds',
              'stockfishCommand',
              'rawUci',
              'pvDump',
              'androidCollectorRequirement',
              'readinessSummaryChain',
              'readinessGate',
            ],
          ),
          _action().copyWith(
            implementationAllowedNow: true,
            blockedBoundaryIds: const <String>[
              'runtimeImplementation',
              'analyzerWiring',
              'executablePrototypeBehavior',
              'directEngineCall',
              'schedulerExecution',
              'productAdapterBehavior',
              'savedAnalysisIntegration',
              'uiTarget',
            ],
          ),
        ],
      );

      expect(findings, contains('missingPhase34CRequirement'));
      expect(findings, contains('unknownActionGroup'));
      expect(findings, contains('unknownActionType'));
      expect(findings, contains('quietPreparatoryPromotion'));
      expect(findings, contains('pvMultiPvPromotion'));
      expect(findings, contains('phase32ECapturedProofClaim'));
      expect(findings, contains('ownerProofWithoutPvMultiPvReason'));
      expect(findings, contains('activeDeniedFields'));
      expect(findings, contains('productLabelsEnabled'));
      expect(findings, contains('finalLabelsEnabled'));
      expect(findings, contains('classifierLabelsEnabled'));
      expect(findings, contains('scoresEnabled'));
      expect(findings, contains('officialMetricsEnabled'));
      expect(findings, contains('cpLossEnabled'));
      expect(findings, contains('winProbabilityEnabled'));
      expect(findings, contains('moveRankingEnabled'));
      expect(findings, contains('thresholdsEnabled'));
      expect(findings, contains('stockfishCommandEnabled'));
      expect(findings, contains('rawUciEnabled'));
      expect(findings, contains('pvDumpEnabled'));
      expect(findings, contains('androidCollectorRequirementEnabled'));
      expect(findings, contains('readinessSummaryChainEnabled'));
      expect(findings, contains('readinessGateEnabled'));
      expect(findings, contains('runtimeImplementationEnabled'));
      expect(findings, contains('analyzerWiringEnabled'));
      expect(findings, contains('executablePrototypeEnabled'));
      expect(findings, contains('engineCallEnabled'));
      expect(findings, contains('schedulerExecutionEnabled'));
      expect(findings, contains('productAdapterEnabled'));
      expect(findings, contains('savedAnalysisIntegrationEnabled'));
      expect(findings, contains('uiBackendPersistenceEnabled'));
    });

    test('validator rejects report text leaks', () {
      final findings =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanValidator()
              .validateReportText('uciok info depth 1 pv e2e4');

      expect(findings, contains('reportTextLeak:uciok'));
      expect(findings, contains('reportTextLeak:info depth'));
      expect(findings, contains('reportTextLeak:pv e2e4'));
    });
  });
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
_action() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord(
    actionId: 'test-action',
    sourceCaseId: 'queen-win-major-swing',
    sourcePhase: 'existing',
    sourceDiagnosticRole: 'developerDiagnosticInputSupport',
    actionGroup: 'safeInternalSupportActions',
    actionType: 'futureInternalPrototypeImprovement',
    priority: 'medium',
    supportAreaIds: <String>['tacticalShot'],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    blockedBoundaryIds: <String>[],
    androidProofIds: <String>['queen-win-major-swing'],
    ownerProofRequired: false,
    implementationAllowedNow: false,
    requiresFutureValidation: true,
    recommendedNextStep: 'implementAnalyzerAdapterPrototypeActionPlanPatchSet',
    deniedFieldIds: <String>[],
  );
}

extension
    on DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord {
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord
  copyWith({
    String? actionId,
    String? sourceCaseId,
    String? sourcePhase,
    String? sourceDiagnosticRole,
    String? actionGroup,
    String? actionType,
    String? priority,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? blockedBoundaryIds,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
    bool? implementationAllowedNow,
    bool? requiresFutureValidation,
    String? recommendedNextStep,
    List<String>? deniedFieldIds,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionRecord(
      actionId: actionId ?? this.actionId,
      sourceCaseId: sourceCaseId ?? this.sourceCaseId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticRole: sourceDiagnosticRole ?? this.sourceDiagnosticRole,
      actionGroup: actionGroup ?? this.actionGroup,
      actionType: actionType ?? this.actionType,
      priority: priority ?? this.priority,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      implementationAllowedNow:
          implementationAllowedNow ?? this.implementationAllowedNow,
      requiresFutureValidation:
          requiresFutureValidation ?? this.requiresFutureValidation,
      recommendedNextStep: recommendedNextStep ?? this.recommendedNextStep,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
    );
  }
}
