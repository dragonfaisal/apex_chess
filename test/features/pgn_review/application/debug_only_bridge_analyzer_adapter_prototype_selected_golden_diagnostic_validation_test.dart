@TestOn('vm')
library;

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_selected_golden_diagnostic_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation', () {
    test('safe default validates with warnings', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation()
              .evaluate();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationStatus
            .selectedGoldenAnalyzerAdapterPrototypeDiagnosticValidatedWithWarnings,
      );
      expect(result.safeForPhase34B, isTrue);
      expect(
        result.nextRecommendation,
        'proceedToAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan',
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

    test('selected row roles preserve expected boundaries', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation()
              .evaluate();
      final byCase = {
        for (final row in result.validationRows) row.sourceCaseId: row,
      };

      expect(
        byCase['queen-win-major-swing']!.diagnosticRole,
        'developerDiagnosticInputSupport',
      );
      expect(
        byCase['forcing-line-variation-hard-case']!.diagnosticRole,
        'developerDiagnosticInputSupport',
      );
      expect(
        byCase['sacrifice-compensation-hard-case']!.diagnosticRole,
        'developerDiagnosticInputSupport',
      );
      expect(
        byCase['king-safety-mating-net-pressure-32e']!.diagnosticRole,
        'warningLimited',
      );
      expect(
        byCase['endgame-precision-candidate-spread-32e']!.diagnosticRole,
        'warningLimited',
      );
      expect(
        byCase['budget-pressure-wide-candidate-32e']!.diagnosticRole,
        'warningLimited',
      );
      expect(
        byCase['pv-multipv-support-boundary-32e']!.diagnosticRole,
        'proofBoundaryOnly',
      );
      expect(
        byCase['quiet-preparatory-hard-case']!.diagnosticRole,
        'excludedNegativeGuard',
      );
    });

    test('proof and owner boundaries remain safe', () {
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation()
              .evaluate();

      expect(result.phase32EProofClaimCount, 0);
      expect(result.unprovenAndroidProofCount, 0);
      expect(result.ownerProofQueueCount, 0);
      for (final row in result.validationRows) {
        expect(
          row.androidProofIds,
          everyElement(
            isIn(const <String>{
              'mate-threat-fast-evidence',
              'queen-win-major-swing',
              'simple-tactical-capture-check',
            }),
          ),
        );
      }
    });

    test('validator rejects active denied and product fields', () {
      final source = _sourceWithRows(<
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
      >[
        _safeRow().copyWith(
          activeDeniedFieldIds: const <String>[
            'productLabel',
            'finalMoveLabel',
            'classifierLabels',
            'numericMoveScore',
            'aggregateScore',
            'officialAccuracy',
            'acpl',
            'cpLoss',
            'winProbability',
            'moveRanking',
            'thresholds',
          ],
        ),
      ]);
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation()
              .evaluate(source: source);

      expect(result.safeForPhase34B, isFalse);
      expect(result.activeDeniedFieldCount, greaterThan(0));
      expect(result.productOutputCount, greaterThan(0));
      expect(result.labelLeakCount, greaterThan(0));
      expect(result.finalLabelLeakCount, greaterThan(0));
      expect(result.scoreLeakCount, greaterThan(0));
      expect(result.metricLeakCount, greaterThan(0));
      expect(result.cpLossLeakCount, greaterThan(0));
      expect(result.winProbabilityLeakCount, greaterThan(0));
      expect(result.moveRankingLeakCount, greaterThan(0));
      expect(result.thresholdLeakCount, greaterThan(0));
    });

    test('validator rejects integration and engine seams', () {
      final source = _sourceWithRows(<
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
      >[
        _safeRow().copyWith(
          activeDeniedFieldIds: const <String>[
            'uiTarget',
            'backendTarget',
            'persistenceWrite',
            'directEngineCall',
            'schedulerExecution',
            'analyzerWiring',
            'runtimeImplementation',
            'executablePrototypeBehavior',
            'productAdapterBehavior',
            'savedAnalysisIntegration',
            'stockfishCommand',
            'rawUci',
            'pvDump',
            'androidCollectorRequirement',
            'readinessSummaryChain',
            'readinessGate',
          ],
        ),
      ]);
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation()
              .evaluate(source: source);

      expect(result.safeForPhase34B, isFalse);
      expect(result.uiTargetCount, greaterThan(0));
      expect(result.backendTargetCount, greaterThan(0));
      expect(result.persistenceWriteCount, greaterThan(0));
      expect(result.engineCallCount, greaterThan(0));
      expect(result.schedulerExecutionCount, greaterThan(0));
      expect(result.analyzerWiringCount, greaterThan(0));
      expect(result.runtimeImplementationCount, greaterThan(0));
      expect(result.executablePrototypeCount, greaterThan(0));
      expect(result.productAdapterBehaviorCount, greaterThan(0));
      expect(result.savedAnalysisIntegrationCount, greaterThan(0));
      expect(result.stockfishCommandLeakCount, greaterThan(0));
      expect(result.rawUciLeakCount, greaterThan(0));
      expect(result.pvDumpLeakCount, greaterThan(0));
      expect(result.androidCollectorRequirementCount, greaterThan(0));
    });

    test('validator rejects role and proof honesty seams', () {
      final source = _sourceWithRows(<
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
      >[
        _safeRow().copyWith(diagnosticRole: 'unknownRole'),
        _safeRow().copyWith(
          caseId: 'quiet-preparatory-hard-case',
          diagnosticRole: 'developerDiagnosticInputSupport',
          supportAreaIds: const <String>['quietPreparatoryMove'],
        ),
        _safeRow().copyWith(
          caseId: 'pv-multipv-support-boundary-32e',
          diagnosticRole: 'developerDiagnosticInputSupport',
        ),
        _safeRow().copyWith(
          caseId: 'king-safety-mating-net-pressure-32e',
          androidProofIds: const <String>[
            'king-safety-mating-net-pressure-32e',
          ],
        ),
        _safeRow().copyWith(
          ownerProofRequired: true,
          proofLimitReasons: const <String>[],
        ),
      ]);
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation()
              .evaluate(source: source);
      final findings = result.validationRows.expand((row) => row.findings);

      expect(result.safeForPhase34B, isFalse);
      expect(findings, contains('unknownSelectedDiagnosticRole'));
      expect(findings, contains('quietPreparatoryPromotion'));
      expect(findings, contains('pvMultiPvPromotion'));
      expect(findings, contains('phase32ECapturedProofClaim'));
      expect(findings, contains('ownerProofWithoutPvMultiPvReason'));
    });

    test('report text leak is rejected', () {
      final source = _sourceWithRows(
        <
          DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
        >[_safeRow()],
        reportTexts: const <String>['uciok info depth 1 pv e2e4'],
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidation()
              .evaluate(source: source);

      expect(result.safeForPhase34B, isFalse);
      expect(result.reportFindings, contains('reportTextLeak:uciok'));
      expect(result.reportFindings, contains('reportTextLeak:info depth'));
      expect(result.reportFindings, contains('reportTextLeak:pv e2e4'));
    });
  });
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSource
_sourceWithRows(
  List<
    DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
  >
  rows, {
  List<String> reportTexts = const <String>['safe report text'],
}) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSource(
    phase33YDiagnosticPathSafe: true,
    phase33ZSelectedDiagnosticPathSafe: true,
    defaultSelectedOutputDeterministic: true,
    allSafeSelectedOutputDeterministic: true,
    singleSelectedCaseOutputDeterministic: true,
    listGoldenCasesOutputDeterministic: true,
    goldenSectionOutputDeterministic: true,
    markdownJsonStrictModesSafe: true,
    defaultSelectedRows: rows,
    allSafeSelectedRows: rows,
    singleSelectedRows: rows.take(1).toList(),
    listedGoldenCaseIds: rows.map((row) => row.caseId).toList(),
    reportTexts: reportTexts,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
_safeRow() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow(
    caseId: 'queen-win-major-swing',
    title: 'Queen win major swing',
    sourcePhase: 'existing',
    selectedReason: 'safe diagnostic support',
    diagnosticRole: 'developerDiagnosticInputSupport',
    supportAreaIds: <String>['tacticalShot'],
    warningReasons: <String>[
      'developerOnlySelectedGoldenAnalyzerAdapterPrototypeDiagnosticNoEngineExecution',
    ],
    proofLimitReasons: <String>[],
    androidProofIds: <String>['queen-win-major-swing'],
    ownerProofRequired: false,
    activeDeniedFieldIds: <String>[],
    blockedBoundaryIds: <String>['productOutput'],
    recommendation:
        'proceedToAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan',
  );
}

extension
    on
        DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow {
  DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow
  copyWith({
    String? caseId,
    String? title,
    String? sourcePhase,
    String? selectedReason,
    String? diagnosticRole,
    List<String>? supportAreaIds,
    List<String>? warningReasons,
    List<String>? proofLimitReasons,
    List<String>? androidProofIds,
    bool? ownerProofRequired,
    List<String>? activeDeniedFieldIds,
    List<String>? blockedBoundaryIds,
    String? recommendation,
  }) {
    return DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationSourceRow(
      caseId: caseId ?? this.caseId,
      title: title ?? this.title,
      sourcePhase: sourcePhase ?? this.sourcePhase,
      selectedReason: selectedReason ?? this.selectedReason,
      diagnosticRole: diagnosticRole ?? this.diagnosticRole,
      supportAreaIds: supportAreaIds ?? this.supportAreaIds,
      warningReasons: warningReasons ?? this.warningReasons,
      proofLimitReasons: proofLimitReasons ?? this.proofLimitReasons,
      androidProofIds: androidProofIds ?? this.androidProofIds,
      ownerProofRequired: ownerProofRequired ?? this.ownerProofRequired,
      activeDeniedFieldIds: activeDeniedFieldIds ?? this.activeDeniedFieldIds,
      blockedBoundaryIds: blockedBoundaryIds ?? this.blockedBoundaryIds,
      recommendation: recommendation ?? this.recommendation,
    );
  }
}
