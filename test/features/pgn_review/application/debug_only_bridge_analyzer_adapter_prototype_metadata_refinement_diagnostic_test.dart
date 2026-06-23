@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_diagnostic.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_patch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic', () {
    test('safe default diagnostic is ready with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticStatus
            .analyzerAdapterPrototypeMetadataRefinementDiagnosticReadyWithWarnings,
      );
      expect(
        result.mode,
        DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
            .defaultMode,
      );
      expect(result.safeForPhase34G, isTrue);
      expect(
        result.nextRecommendation,
        'implementControlledAnalyzerAdapterRuntimePreparationPatch',
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

    test('diagnostic modes filter refinement rows deterministically', () {
      final diagnostic =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic();

      expect(diagnostic.evaluate().totalDiagnosticRows, greaterThan(8));
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                      .allSafe,
            )
            .totalDiagnosticRows,
        diagnostic.evaluate().totalDiagnosticRows,
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                      .support,
            )
            .supportDiagnosticRowCount,
        greaterThan(0),
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                      .warning,
            )
            .warningDiagnosticRowCount,
        greaterThan(0),
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                      .proof,
            )
            .proofDiagnosticRowCount,
        1,
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                      .guards,
            )
            .guardDiagnosticRowCount,
        greaterThan(0),
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                      .denied,
            )
            .deniedDiagnosticRowCount,
        1,
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                      .blocked,
            )
            .blockedDiagnosticRowCount,
        greaterThan(0),
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                      .surfaces,
            )
            .surfaceDiagnosticRowCount,
        1,
      );
      expect(
        diagnostic
            .evaluate(
              mode:
                  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                      .recommendation,
            )
            .recommendationDiagnosticRowCount,
        greaterThan(0),
      );
    });

    test('diagnostic rows preserve refinement boundaries', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic()
              .evaluate();
      final byCase = {for (final row in result.rows) row.sourceCaseId: row};

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
      expect(result.rows.every((row) => row.appliedAsMetadataOnly), isTrue);
      expect(result.phase32EProofClaimCount, 0);
      expect(result.unprovenAndroidProofCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('unsafe Phase 34E metadata refinement blocks diagnostic', () {
      final source =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatch()
              .evaluate();
      final unsafe =
          DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchResult(
            status:
                DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementPatchStatus
                    .blockedByPolicyBoundary,
            sourceDiagnosticStatus: source.sourceDiagnosticStatus,
            sourcePatchSetStatus: source.sourcePatchSetStatus,
            refinements: source.refinements,
            findings: const <String>['testUnsafeMetadataRefinementPatch'],
            allowedTargetSurfaces: source.allowedTargetSurfaces,
            forbiddenTargetSurfaces: source.forbiddenTargetSurfaces,
            safeForPhase34F: false,
            nextRecommendation:
                'blockedByUnsafeAnalyzerAdapterPrototypeMetadataRefinementPatch',
          );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic()
              .evaluate(refinementPatchResult: unsafe);

      expect(result.safeForPhase34G, isFalse);
      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticStatus
            .blockedByUnsafeMetadataRefinementPatch,
      );
      expect(
        result.findings,
        contains('unsafePhase34EMetadataRefinementPatch'),
      );
    });

    test('validator rejects diagnostic policy seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticValidator();
      final findings = validator.validateRows(
        <
          DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
        >[
          _row().copyWith(refinementGroup: 'unknownGroup'),
          _row().copyWith(refinementType: 'unknownType'),
          _row().copyWith(targetSurface: 'productReviewOutput'),
          _row().copyWith(appliedAsMetadataOnly: false),
          _row().copyWith(
            sourceCaseId: 'quiet-preparatory-hard-case',
            supportAreaIds: const <String>['quietPreparatoryMove'],
            refinementGroup: 'supportTraceabilityMetadataRefinements',
          ),
          _row().copyWith(
            sourceCaseId: 'pv-multipv-support-boundary-32e',
            refinementGroup: 'supportTraceabilityMetadataRefinements',
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
        mode:
            DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                .defaultMode,
      );

      expect(findings, contains('unknownRefinementGroup'));
      expect(findings, contains('unknownRefinementType'));
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

      final missingRecommendationFindings = validator.validateRows(
        <
          DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
        >[_row().copyWith(recommendation: 'wrongNextStep')],
        mode:
            DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                .defaultMode,
      );
      expect(
        missingRecommendationFindings,
        contains('missingPhase34GControlledRuntimePreparationRecommendation'),
      );
    });

    test('markdown and JSON rendering are deterministic and safe', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnostic()
              .evaluate();
      final markdown = result.renderMarkdown();
      final json = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = json['counts'] as Map<String, Object?>;

      expect(markdown, contains('## Source Phase Chain'));
      expect(markdown, contains('## Refinement Diagnostic Rows'));
      expect(markdown, contains('## Target Surface Summary'));
      expect(json['status'], result.status.wire);
      expect(json['safeForPhase34G'], isTrue);
      expect(
        json['nextRecommendation'],
        'implementControlledAnalyzerAdapterRuntimePreparationPatch',
      );
      expect(counts['unsafeCount'], 0);
      expect(counts['activeDeniedFieldCount'], 0);
      expect(
        const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticValidator()
            .validateReportText(markdown),
        isEmpty,
      );
    });

    test('validator rejects report text leaks', () {
      final findings =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticValidator()
              .validateReportText('uciok info depth 1 pv e2e4');

      expect(findings, contains('reportTextLeak:uciok'));
      expect(findings, contains('reportTextLeak:info depth'));
      expect(findings, contains('reportTextLeak:pv e2e4'));
    });
  });
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow _row() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow(
    diagnosticRowId: 'diagnostic-refinement-test',
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
    diagnosticStatus: 'metadataRefinementDiagnosticReady',
    findings: <String>[],
    recommendation: 'implementControlledAnalyzerAdapterRuntimePreparationPatch',
  );
}

extension
    on DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow {
  DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow
  copyWith({
    String? diagnosticRowId,
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
    String? diagnosticStatus,
    List<String>? findings,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticRow(
      diagnosticRowId: diagnosticRowId ?? this.diagnosticRowId,
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
      diagnosticStatus: diagnosticStatus ?? this.diagnosticStatus,
      findings: findings ?? this.findings,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}
