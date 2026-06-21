@TestOn('vm')
library;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_action_plan_patch_set.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_selected_diagnostic_action_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet', () {
    test('safe default applies metadata-only patch set with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetStatus
            .analyzerAdapterPrototypeActionPlanPatchSetAppliedWithWarnings,
      );
      expect(result.safeForPhase34D, isTrue);
      expect(
        result.nextRecommendation,
        'runAnalyzerAdapterPrototypeActionPlanPatchSetDiagnostic',
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

    test('patch groups are populated from the Phase 34B action plan', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet()
              .evaluate();

      expect(result.supportTraceabilityPatchCount, greaterThan(0));
      expect(result.warningFollowupMarkerPatchCount, greaterThan(0));
      expect(result.proofBoundaryMarkerPatchCount, greaterThan(0));
      expect(result.excludedGuardPreservationPatchCount, greaterThan(0));
      expect(result.deniedFieldProtectionPatchCount, 1);
      expect(result.diagnosticCoveragePatchCount, greaterThan(0));
      expect(result.prototypeSkeletonMetadataPatchCount, 1);
      expect(result.blockedIntegrationSentinelPatchCount, 1);
      expect(result.futurePrerequisiteMarkerPatchCount, 1);
      expect(result.phase34DPracticalDiagnosticRequirementPatchCount, 1);
    });

    test('selected diagnostic roles map to metadata-only patch intents', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet()
              .evaluate();
      final byCase = {
        for (final patch in result.patches) patch.sourceCaseId: patch,
      };

      expect(
        byCase['queen-win-major-swing']!.patchGroup,
        'supportTraceabilityPatches',
      );
      expect(
        byCase['queen-win-major-swing']!.patchType,
        'supportTraceabilityPatch',
      );
      expect(
        byCase['king-safety-mating-net-pressure-32e']!.patchGroup,
        'warningFollowupMarkerPatches',
      );
      expect(
        byCase['pv-multipv-support-boundary-32e']!.patchGroup,
        'proofBoundaryMarkerPatches',
      );
      expect(
        byCase['quiet-preparatory-hard-case']!.patchGroup,
        'excludedGuardPreservationPatches',
      );
      for (final patch in result.patches) {
        expect(patch.appliedAsMetadataOnly, isTrue);
        expect(
          patch.targetSurface,
          isNot(anyOf('productReviewOutput', 'analyzerRuntimeInput', 'UI')),
        );
      }
    });

    test('denied and blocked integration patches remain inactive', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet()
              .evaluate();
      final denied = result.patches.singleWhere(
        (patch) => patch.patchGroup == 'deniedFieldProtectionPatches',
      );
      final blocked = result.patches.singleWhere(
        (patch) => patch.patchGroup == 'blockedIntegrationSentinelPatches',
      );

      expect(denied.patchPriority, 'critical');
      expect(denied.implementationAllowedNow, isFalse);
      expect(denied.deniedFieldIds, contains('productLabel'));
      expect(denied.deniedFieldIds, contains('stockfishCommand'));
      expect(denied.targetSurface, 'deniedFieldBoundaryMetadata');
      expect(blocked.patchPriority, 'blocked');
      expect(blocked.implementationAllowedNow, isFalse);
      expect(blocked.targetSurface, 'blockedIntegrationMetadata');
      expect(blocked.blockedBoundaryIds, contains('analyzerWiring'));
      expect(blocked.blockedBoundaryIds, contains('schedulerExecution'));
    });

    test('unsafe Phase 34B action plan blocks patch set', () {
      final source =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan()
              .evaluate();
      final unsafe =
          DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanResult(
            status:
                DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlanStatus
                    .blockedByPolicyBoundary,
            sourceValidationStatus: source.sourceValidationStatus,
            actions: source.actions,
            findings: const <String>['testUnsafeActionPlan'],
            safeForPhase34C: false,
            nextRecommendation:
                'blockedByUnsafeAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan',
          );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet()
              .evaluate(actionPlanResult: unsafe);

      expect(result.safeForPhase34D, isFalse);
      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetStatus
            .blockedByUnsafeSelectedDiagnosticActionPlan,
      );
      expect(result.findings, contains('unsafePhase34BActionPlan'));
    });

    test('validator rejects patch policy seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetValidator();
      final findings = validator.validatePatches(
        <DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord>[
          _patch().copyWith(patchGroup: 'unknownGroup'),
          _patch().copyWith(patchType: 'unknownType'),
          _patch().copyWith(targetSurface: 'productReviewOutput'),
          _patch().copyWith(appliedAsMetadataOnly: false),
          _patch().copyWith(requiresFutureValidation: false),
          _patch().copyWith(
            sourceCaseId: 'quiet-preparatory-hard-case',
            supportAreaIds: const <String>['quietPreparatoryMove'],
            patchGroup: 'supportTraceabilityPatches',
          ),
          _patch().copyWith(
            sourceCaseId: 'pv-multipv-support-boundary-32e',
            patchGroup: 'supportTraceabilityPatches',
          ),
          _patch().copyWith(
            sourceCaseId: 'king-safety-mating-net-pressure-32e',
            androidProofIds: const <String>[
              'king-safety-mating-net-pressure-32e',
            ],
          ),
          _patch().copyWith(
            ownerProofRequired: true,
            proofLimitReasons: const <String>[],
          ),
          _patch().copyWith(
            appliedAsMetadataOnly: false,
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
          _patch().copyWith(
            appliedAsMetadataOnly: false,
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

      expect(
        findings,
        contains('missingPhase34DPracticalDiagnosticRequirement'),
      );
      expect(findings, contains('unknownPatchGroup'));
      expect(findings, contains('unknownPatchType'));
      expect(findings, contains('unknownTargetSurface'));
      expect(findings, contains('forbiddenTargetSurface'));
      expect(findings, contains('nonMetadataPatch'));
      expect(findings, contains('missingFutureValidation'));
      expect(findings, contains('quietPreparatoryPromotion'));
      expect(findings, contains('pvMultiPvPromotion'));
      expect(findings, contains('phase32ECapturedProofClaim'));
      expect(findings, contains('unprovenAndroidProofClaim'));
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
          const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetValidator()
              .validateReportText('uciok info depth 1 pv e2e4');

      expect(findings, contains('reportTextLeak:uciok'));
      expect(findings, contains('reportTextLeak:info depth'));
      expect(findings, contains('reportTextLeak:pv e2e4'));
    });
  });
}

DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord _patch() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord(
    patchId: 'test-patch',
    sourceActionId: 'test-action',
    sourceCaseId: 'queen-win-major-swing',
    sourcePhase: 'existing',
    sourceDiagnosticRole: 'developerDiagnosticInputSupport',
    sourceActionGroup: 'safeInternalSupportActions',
    patchGroup: 'supportTraceabilityPatches',
    patchType: 'supportTraceabilityPatch',
    patchPriority: 'medium',
    targetSurface: 'selectedGoldenDiagnosticRows',
    targetRecordId: 'metadata-test-action',
    supportAreaIds: <String>['tacticalShot'],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    blockedBoundaryIds: <String>[],
    deniedFieldIds: <String>[],
    androidProofIds: <String>['queen-win-major-swing'],
    ownerProofRequired: false,
    implementationAllowedNow: true,
    appliedAsMetadataOnly: true,
    requiresFutureValidation: true,
    recommendation: 'runAnalyzerAdapterPrototypeActionPlanPatchSetDiagnostic',
  );
}

extension on DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord {
  DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord copyWith({
    String? patchId,
    String? sourceActionId,
    String? sourceCaseId,
    String? sourcePhase,
    String? sourceDiagnosticRole,
    String? sourceActionGroup,
    String? patchGroup,
    String? patchType,
    String? patchPriority,
    String? targetSurface,
    String? targetRecordId,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? blockedBoundaryIds,
    List<String>? deniedFieldIds,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
    bool? implementationAllowedNow,
    bool? appliedAsMetadataOnly,
    bool? requiresFutureValidation,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchRecord(
      patchId: patchId ?? this.patchId,
      sourceActionId: sourceActionId ?? this.sourceActionId,
      sourceCaseId: sourceCaseId ?? this.sourceCaseId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticRole: sourceDiagnosticRole ?? this.sourceDiagnosticRole,
      sourceActionGroup: sourceActionGroup ?? this.sourceActionGroup,
      patchGroup: patchGroup ?? this.patchGroup,
      patchType: patchType ?? this.patchType,
      patchPriority: patchPriority ?? this.patchPriority,
      targetSurface: targetSurface ?? this.targetSurface,
      targetRecordId: targetRecordId ?? this.targetRecordId,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      implementationAllowedNow:
          implementationAllowedNow ?? this.implementationAllowedNow,
      appliedAsMetadataOnly:
          appliedAsMetadataOnly ?? this.appliedAsMetadataOnly,
      requiresFutureValidation:
          requiresFutureValidation ?? this.requiresFutureValidation,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}
