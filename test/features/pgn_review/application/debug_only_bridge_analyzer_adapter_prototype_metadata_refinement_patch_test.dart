@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_patch.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_patch_set_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatch', () {
    test('safe default applies metadata refinements with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatch()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus
            .analyzerAdapterPrototypeMetadataRefinementPatchAppliedWithWarnings,
      );
      expect(result.safeForPhase34F, isTrue);
      expect(
        result.nextRecommendation,
        'runAnalyzerAdapterPrototypeMetadataRefinementDiagnostic',
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
      expect(result.ownerProofQueueCount, 0);
    });

    test('refinement groups are populated deterministically', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatch()
              .evaluate();
      final ids = result.refinements.map((record) => record.refinementId);

      expect(result.totalRefinementRecords, greaterThan(8));
      expect(result.supportTraceabilityMetadataRefinementCount, greaterThan(0));
      expect(result.warningReasonMetadataRefinementCount, greaterThan(0));
      expect(result.proofBoundaryMetadataRefinementCount, greaterThan(0));
      expect(result.excludedGuardMetadataRefinementCount, greaterThan(0));
      expect(result.deniedFieldMetadataRefinementCount, greaterThan(0));
      expect(result.blockedIntegrationMetadataRefinementCount, greaterThan(0));
      expect(result.targetSurfaceMetadataRefinementCount, 1);
      expect(result.diagnosticSummaryMetadataRefinementCount, greaterThan(0));
      expect(
        result.phase34FDiagnosticRequirementRefinementCount,
        greaterThan(0),
      );
      expect(ids, contains('refinement-queen-win-major-swing'));
      expect(ids, contains('refinement-phase34f-diagnostic-requirement'));
    });

    test('source roles map to metadata-only refinements', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatch()
              .evaluate();
      final byCase = {
        for (final row in result.refinements) row.sourceCaseId: row,
      };

      expect(
        byCase['queen-win-major-swing']!.refinementGroup,
        'supportTraceabilityMetadataRefinements',
      );
      expect(
        byCase['pv-multipv-support-boundary-32e']!.refinementGroup,
        'proofBoundaryMetadataRefinements',
      );
      expect(
        byCase['quiet-preparatory-hard-case']!.refinementGroup,
        'excludedGuardMetadataRefinements',
      );
      expect(
        byCase['king-safety-mating-net-pressure-32e']!.refinementGroup,
        'warningReasonMetadataRefinements',
      );
      expect(
        result.refinements.every((record) => record.appliedAsMetadataOnly),
        isTrue,
      );
      expect(
        result.refinements.every((record) => record.requiresFutureValidation),
        isTrue,
      );
    });

    test('unsafe Phase 34D patch-set diagnostic blocks refinement', () {
      final source =
          const DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnostic()
              .evaluate();
      final unsafe =
          DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticResult(
            status:
                DebugOnlyBridgeAnalyzerAdapterPrototypePatchSetDiagnosticStatus
                    .blockedByPolicyBoundary,
            mode: source.mode,
            sourceActionPlanStatus: source.sourceActionPlanStatus,
            sourcePatchSetStatus: source.sourcePatchSetStatus,
            rows: source.rows,
            findings: const <String>['testUnsafePatchSetDiagnostic'],
            allowedTargetSurfaces: source.allowedTargetSurfaces,
            forbiddenTargetSurfaces: source.forbiddenTargetSurfaces,
            safeForPhase34E: false,
            nextRecommendation:
                'blockedByUnsafeAnalyzerAdapterPrototypePatchSetDiagnostic',
          );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatch()
              .evaluate(diagnosticResult: unsafe);

      expect(result.safeForPhase34F, isFalse);
      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus
            .blockedByUnsafePatchSetDiagnostic,
      );
      expect(result.findings, contains('unsafePhase34DPatchSetDiagnostic'));
    });

    test('validator rejects metadata refinement policy seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchValidator();
      final findings = validator.validateRefinements(
        <DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord>[
          _record().copyWith(refinementGroup: 'unknownGroup'),
          _record().copyWith(refinementType: 'unknownType'),
          _record().copyWith(targetSurface: 'productReviewOutput'),
          _record().copyWith(appliedAsMetadataOnly: false),
          _record().copyWith(requiresFutureValidation: false),
          _record().copyWith(
            sourceCaseId: 'quiet-preparatory-hard-case',
            supportAreaIds: const <String>['quietPreparatoryMove'],
            refinementGroup: 'supportTraceabilityMetadataRefinements',
          ),
          _record().copyWith(
            sourceCaseId: 'pv-multipv-support-boundary-32e',
            refinementGroup: 'supportTraceabilityMetadataRefinements',
          ),
          _record().copyWith(
            sourceCaseId: 'king-safety-mating-net-pressure-32e',
            androidProofIds: const <String>[
              'king-safety-mating-net-pressure-32e',
            ],
          ),
          _record().copyWith(
            ownerProofRequired: true,
            proofLimitReasons: const <String>[],
          ),
          _record().copyWith(
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
          _record().copyWith(
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
        contains('missingPhase34FPracticalDiagnosticRecommendation'),
      );
      expect(findings, contains('unknownRefinementGroup'));
      expect(findings, contains('unknownRefinementType'));
      expect(findings, contains('unknownTargetSurface'));
      expect(findings, contains('forbiddenTargetSurface'));
      expect(findings, contains('nonMetadataRefinement'));
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

    test('markdown and JSON rendering are deterministic and safe', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatch()
              .evaluate();
      final markdown = result.renderMarkdown();
      final json = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = json['counts'] as Map<String, Object?>;

      expect(markdown, contains('## Metadata Refinement Records'));
      expect(markdown, contains('## Support Reason Summary'));
      expect(markdown, contains('## Target Surface Summary'));
      expect(json['status'], result.status.wire);
      expect(json['safeForPhase34F'], isTrue);
      expect(
        json['nextRecommendation'],
        'runAnalyzerAdapterPrototypeMetadataRefinementDiagnostic',
      );
      expect(counts['unsafeCount'], 0);
      expect(counts['activeDeniedFieldCount'], 0);
      expect(
        const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchValidator()
            .validateReportText(markdown),
        isEmpty,
      );
    });

    test('validator rejects report text leaks', () {
      final findings =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchValidator()
              .validateReportText('uciok info depth 1 pv e2e4');

      expect(findings, contains('reportTextLeak:uciok'));
      expect(findings, contains('reportTextLeak:info depth'));
      expect(findings, contains('reportTextLeak:pv e2e4'));
    });
  });
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord _record() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord(
    refinementId: 'refinement-test',
    sourceDiagnosticRowId: 'diagnostic-test',
    sourcePatchId: 'patch-test',
    sourceActionId: 'action-test',
    sourceCaseId: 'queen-win-major-swing',
    sourcePhase: 'existing',
    sourceDiagnosticRole: 'developerDiagnosticInputSupport',
    sourcePatchGroup: 'supportTraceabilityPatches',
    refinementGroup: 'supportTraceabilityMetadataRefinements',
    refinementType: 'supportTraceabilityMetadata',
    targetSurface: 'selectedGoldenDiagnosticRows',
    refinedDisplayLabel: 'Support traceability',
    refinedReasonSummary:
        'Metadata-only traceability for queen-win-major-swing',
    sourceChainSummary:
        'queen-win-major-swing -> action-test -> patch-test -> diagnostic-test',
    supportAreaIds: <String>['tacticalShot'],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    blockedBoundaryIds: <String>[],
    deniedFieldIds: <String>[],
    androidProofIds: <String>['queen-win-major-swing'],
    ownerProofRequired: false,
    appliedAsMetadataOnly: true,
    requiresFutureValidation: true,
    recommendation: 'runAnalyzerAdapterPrototypeMetadataRefinementDiagnostic',
  );
}

extension on DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord {
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord copyWith({
    String? refinementId,
    String? sourceDiagnosticRowId,
    String? sourcePatchId,
    String? sourceActionId,
    String? sourceCaseId,
    String? sourcePhase,
    String? sourceDiagnosticRole,
    String? sourcePatchGroup,
    String? refinementGroup,
    String? refinementType,
    String? targetSurface,
    String? refinedDisplayLabel,
    String? refinedReasonSummary,
    String? sourceChainSummary,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? blockedBoundaryIds,
    List<String>? deniedFieldIds,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
    bool? appliedAsMetadataOnly,
    bool? requiresFutureValidation,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementRecord(
      refinementId: refinementId ?? this.refinementId,
      sourceDiagnosticRowId:
          sourceDiagnosticRowId ?? this.sourceDiagnosticRowId,
      sourcePatchId: sourcePatchId ?? this.sourcePatchId,
      sourceActionId: sourceActionId ?? this.sourceActionId,
      sourceCaseId: sourceCaseId ?? this.sourceCaseId,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      sourceDiagnosticRole: sourceDiagnosticRole ?? this.sourceDiagnosticRole,
      sourcePatchGroup: sourcePatchGroup ?? this.sourcePatchGroup,
      refinementGroup: refinementGroup ?? this.refinementGroup,
      refinementType: refinementType ?? this.refinementType,
      targetSurface: targetSurface ?? this.targetSurface,
      refinedDisplayLabel: refinedDisplayLabel ?? this.refinedDisplayLabel,
      refinedReasonSummary: refinedReasonSummary ?? this.refinedReasonSummary,
      sourceChainSummary: sourceChainSummary ?? this.sourceChainSummary,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      deniedFieldIds: deniedFieldIds ?? this.deniedFieldIds,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      appliedAsMetadataOnly:
          appliedAsMetadataOnly ?? this.appliedAsMetadataOnly,
      requiresFutureValidation:
          requiresFutureValidation ?? this.requiresFutureValidation,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}
