@TestOn('vm')
library;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_action_plan_patch_set.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_patch_set_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic', () {
    test('safe default diagnostic is ready with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticStatus
            .analyzerAdapterPrototypePatchSetDiagnosticReadyWithWarnings,
      );
      expect(
        result.mode,
        DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
            .defaultMode,
      );
      expect(result.safeForPhase34E, isTrue);
      expect(
        result.nextRecommendation,
        'implementAnalyzerAdapterPrototypeMetadataRefinementPatch',
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

    test('diagnostic modes filter patch rows deterministically', () {
      final diagnostic =
          const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic();

      expect(diagnostic.evaluate().totalDiagnosticRows, greaterThan(8));
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
                      .allSafe,
            )
            .totalDiagnosticRows,
        diagnostic.evaluate().totalDiagnosticRows,
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
                      .support,
            )
            .supportTraceabilityRowCount,
        greaterThan(0),
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
                      .warning,
            )
            .warningFollowupMarkerRowCount,
        greaterThan(0),
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
                      .proof,
            )
            .proofBoundaryMarkerRowCount,
        1,
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
                      .guards,
            )
            .excludedGuardPreservationRowCount,
        greaterThan(0),
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
                      .denied,
            )
            .deniedFieldProtectionRowCount,
        1,
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
                      .blocked,
            )
            .blockedIntegrationSentinelRowCount,
        1,
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
                      .recommendation,
            )
            .phase34DRequirementRowCount,
        1,
      );
    });

    test('diagnostic rows preserve patch boundaries', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic()
              .evaluate();
      final byCase = {for (final row in result.rows) row.sourceCaseId: row};

      expect(
        byCase['queen-win-major-swing']!.patchGroup,
        'supportTraceabilityPatches',
      );
      expect(
        byCase['pv-multipv-support-boundary-32e']!.patchGroup,
        'proofBoundaryMarkerPatches',
      );
      expect(
        byCase['quiet-preparatory-hard-case']!.patchGroup,
        'excludedGuardPreservationPatches',
      );
      expect(
        byCase['king-safety-mating-net-pressure-32e']!.patchGroup,
        'warningFollowupMarkerPatches',
      );
      expect(result.rows.every((row) => row.appliedAsMetadataOnly), isTrue);
      expect(result.phase32EProofClaimCount, 0);
      expect(result.unprovenAndroidProofCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('unsafe Phase 34C patch set blocks diagnostic', () {
      final source =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSet()
              .evaluate();
      final unsafe =
          DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetResult(
            status:
                DebugOnlyBridgeAnalyzerAdapterPrototypeActionPlanPatchSetStatus
                    .blockedByPolicyBoundary,
            sourceActionPlanStatus: source.sourceActionPlanStatus,
            sourceValidationStatus: source.sourceValidationStatus,
            patches: source.patches,
            findings: const <String>['testUnsafePatchSet'],
            safeForPhase34D: false,
            nextRecommendation:
                'blockedByUnsafeAnalyzerAdapterPrototypeActionPlanPatchSet',
          );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic()
              .evaluate(patchSetResult: unsafe);

      expect(result.safeForPhase34E, isFalse);
      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticStatus
            .blockedByUnsafePatchSet,
      );
      expect(result.findings, contains('unsafePhase34CPatchSet'));
    });

    test('validator rejects diagnostic policy seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticValidator();
      final findings = validator.validateRows(
        <DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow>[
          _row().copyWith(patchGroup: 'unknownGroup'),
          _row().copyWith(patchType: 'unknownType'),
          _row().copyWith(targetSurface: 'productReviewOutput'),
          _row().copyWith(appliedAsMetadataOnly: false),
          _row().copyWith(
            sourceCaseId: 'quiet-preparatory-hard-case',
            supportAreaIds: const <String>['quietPreparatoryMove'],
            patchGroup: 'supportTraceabilityPatches',
          ),
          _row().copyWith(
            sourceCaseId: 'pv-multipv-support-boundary-32e',
            patchGroup: 'supportTraceabilityPatches',
          ),
          _row().copyWith(
            sourceCaseId: 'king-safety-mating-net-pressure-32e',
            androidProofIds: const <String>[
              'king-safety-mating-net-pressure-32e',
            ],
          ),
          _row().copyWith(
            ownerProofRequired: true,
            proofLimitReasons: const <String>[],
          ),
          _row().copyWith(
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
          _row().copyWith(
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
        mode: DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
            .defaultMode,
      );

      expect(findings, contains('unknownPatchGroup'));
      expect(findings, contains('unknownPatchType'));
      expect(findings, contains('unknownTargetSurface'));
      expect(findings, contains('forbiddenTargetSurface'));
      expect(findings, contains('nonMetadataDiagnosticRow'));
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

    test('validator rejects missing Phase 34E recommendation', () {
      final findings =
          const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticValidator()
              .validateRows(
                <DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow>[
                  _row().copyWith(recommendation: 'wrongNextStep'),
                ],
                mode:
                    DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticMode
                        .defaultMode,
              );

      expect(
        findings,
        contains('missingPhase34EMetadataRefinementRecommendation'),
      );
    });

    test('validator rejects report text leaks', () {
      final findings =
          const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticValidator()
              .validateReportText('uciok info depth 1 pv e2e4');

      expect(findings, contains('reportTextLeak:uciok'));
      expect(findings, contains('reportTextLeak:info depth'));
      expect(findings, contains('reportTextLeak:pv e2e4'));
    });
  });
}

DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow _row() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow(
    diagnosticRowId: 'diagnostic-test',
    patchId: 'patch-test',
    sourceActionId: 'action-test',
    sourceCaseId: 'queen-win-major-swing',
    sourcePhase: 'existing',
    sourceDiagnosticRole: 'developerDiagnosticInputSupport',
    sourceActionGroup: 'safeInternalSupportActions',
    patchGroup: 'supportTraceabilityPatches',
    patchType: 'supportTraceabilityPatch',
    patchPriority: 'medium',
    targetSurface: 'selectedGoldenDiagnosticRows',
    appliedAsMetadataOnly: true,
    supportAreaIds: <String>['tacticalShot'],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    blockedBoundaryIds: <String>[],
    deniedFieldIds: <String>[],
    androidProofIds: <String>['queen-win-major-swing'],
    ownerProofRequired: false,
    diagnosticStatus: 'patchDiagnosticReadyWithWarnings',
    findings: <String>[],
    recommendation: 'implementAnalyzerAdapterPrototypeMetadataRefinementPatch',
  );
}

extension on DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow {
  DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow copyWith({
    String? diagnosticRowId,
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
    bool? appliedAsMetadataOnly,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? blockedBoundaryIds,
    List<String>? deniedFieldIds,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
    String? diagnosticStatus,
    List<String>? findings,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticRow(
      diagnosticRowId: diagnosticRowId ?? this.diagnosticRowId,
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
      appliedAsMetadataOnly:
          appliedAsMetadataOnly ?? this.appliedAsMetadataOnly,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      diagnosticStatus: diagnosticStatus ?? this.diagnosticStatus,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}
