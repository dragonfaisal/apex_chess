@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_diagnostic_command.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation', () {
    test('safe default validation passes with warnings', () {
      final selectedValidation =
          const DebugOnlyBridgeSelectedGoldenDiagnosticValidation().evaluate();
      final boundaryDesign =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign().evaluate(
            selectedGoldenValidationResult: selectedValidation,
          );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation()
              .evaluate(
                boundaryDesignResult: boundaryDesign,
                selectedGoldenValidationResult: selectedValidation,
              );

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationStatus
            .boundaryDesignValidatedWithWarnings,
      );
      expect(
        result.sourceBoundaryDesignStatus,
        'boundaryDesignReadyWithWarnings',
      );
      expect(result.sourceBoundaryDesignSafeForPhase33N, isTrue);
      expect(result.safeForPhase33O, isTrue);
      expect(
        result.phase33ORecommendation,
        'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign',
      );
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.unsafeCount, 0);
      expect(result.activeDeniedFieldCount, 0);
      expect(result.productOutputCount, 0);
      expect(result.analyzerWiringCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
    });

    test(
      'Phase 33M boundary design is consumed and rows are deterministic',
      () {
        final selectedValidation =
            const DebugOnlyBridgeSelectedGoldenDiagnosticValidation()
                .evaluate();
        final boundaryDesign =
            const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign().evaluate(
              selectedGoldenValidationResult: selectedValidation,
            );
        final validation =
            const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation();
        final first = validation.evaluate(
          boundaryDesignResult: boundaryDesign,
          selectedGoldenValidationResult: selectedValidation,
        );
        final second = validation.evaluate(
          boundaryDesignResult: boundaryDesign,
          selectedGoldenValidationResult: selectedValidation,
        );

        expect(first.renderJson(), second.renderJson());
        expect(first.totalChecks, 21);
        expect(first.totalValidationRows, boundaryDesign.totalBoundaryRecords);
        expect(first.passedCheckCount, first.totalChecks);
      },
    );

    test('validation preserves adapter boundary roles', () {
      final result = _safeValidation();
      final rowsByCaseId = {
        for (final row in result.validationRows)
          row.sourceDiagnosticCaseId: row,
      };

      expect(
        rowsByCaseId['queen-win-major-swing']!.adapterBoundaryRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.analyzerInputCandidate.wire,
      );
      expect(
        rowsByCaseId['endgame-precision-candidate-spread-32e']!
            .adapterBoundaryRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.contextOnlyCandidate.wire,
      );
      expect(
        rowsByCaseId['budget-pressure-wide-candidate-32e']!.adapterBoundaryRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.warningLimitedCandidate.wire,
      );
      expect(
        rowsByCaseId['pv-multipv-support-boundary-32e']!.adapterBoundaryRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.proofBoundaryOnly.wire,
      );
      expect(
        rowsByCaseId['quiet-preparatory-hard-case']!.adapterBoundaryRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.excludedNegativeGuard.wire,
      );
    });

    test('proof honesty and owner proof boundaries are preserved', () {
      final result = _safeValidation();
      final phase32ERows = result.validationRows.where(
        (row) => row.sourcePhase == 'Phase 32E',
      );
      final proofRows = result.validationRows.where(
        (row) => row.androidProofCaseIds.isNotEmpty,
      );

      expect(phase32ERows, isNotEmpty);
      for (final row in phase32ERows) {
        expect(row.androidProofCaseIds, isEmpty, reason: row.validationRowId);
      }
      expect(
        proofRows.map((row) => row.androidProofCaseIds).expand((ids) => ids),
        everyElement(
          isIn(<String>[
            'mate-threat-fast-evidence',
            'queen-win-major-swing',
            'simple-tactical-capture-check',
          ]),
        ),
      );
      expect(result.unprovenAndroidProofCount, 0);
      expect(result.phase32EProofClaimCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('denied fields and integration boundaries remain inactive', () {
      final result = _safeValidation();

      for (final row in result.validationRows) {
        expect(row.designOnly, isTrue, reason: row.validationRowId);
        expect(row.developerOnly, isTrue, reason: row.validationRowId);
        expect(row.analyzerUnwired, isTrue, reason: row.validationRowId);
        expect(row.activeDeniedFields, isEmpty, reason: row.validationRowId);
        expect(row.findings, isEmpty, reason: row.validationRowId);
      }
      expect(result.deniedFieldBoundaryValidationCount, 1);
      expect(result.runtimeBlockedValidationCount, 1);
      expect(result.schedulerBlockedValidationCount, 1);
      expect(result.persistenceBlockedValidationCount, 1);
      expect(result.engineBlockedValidationCount, 1);
      expect(result.uiTargetCount, 0);
      expect(result.backendTargetCount, 0);
      expect(result.persistenceWriteCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
    });

    test('unsafe boundary design is blocked', () {
      final safeDesign = const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign()
          .evaluate(
            selectedGoldenValidationResult:
                const DebugOnlyBridgeSelectedGoldenDiagnosticValidation()
                    .evaluate(),
          );
      final unsafeDesign = _copyDesign(
        safeDesign,
        sourceSafe: false,
        safeForPhase33N: false,
        recommendation: 'blockedByUnsafeAnalyzerAdapterBoundaryDesign',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation()
              .evaluate(boundaryDesignResult: unsafeDesign);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationStatus
            .blockedByUnsafeBoundaryDesign,
      );
      expect(result.safeForPhase33O, isFalse);
      expect(result.blockerCount, greaterThan(0));
    });

    test('validator rejects product and label output', () {
      final row =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationValidator()
              .validateRecord(
                _safeRecord().copyWith(
                  safetyFlags:
                      const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(
                        isProductOutput: true,
                        emitsClassifierLabel: true,
                        emitsFinalLabel: true,
                      ),
                ),
                knownCaseIds: const <String>{'known-case'},
                provenAndroidProofIds: const <String>{},
              );

      expect(row.status.isUnsafe, isTrue);
      expect(row.findings, contains('productOutput'));
      expect(row.findings, contains('classifierLabelLeak'));
      expect(row.findings, contains('finalLabelLeak'));
    });

    test(
      'validator rejects scores rankings metrics CP-loss and win probability',
      () {
        final row =
            const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationValidator()
                .validateRecord(
                  _safeRecord().copyWith(
                    safetyFlags:
                        const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(
                          hasNumericScore: true,
                          hasAggregateScore: true,
                          ranksMoves: true,
                          emitsOfficialMetric: true,
                          exposesCpLoss: true,
                          exposesWinProbability: true,
                        ),
                  ),
                  knownCaseIds: const <String>{'known-case'},
                  provenAndroidProofIds: const <String>{},
                );

        expect(row.status.isUnsafe, isTrue);
        expect(row.findings, contains('numericScoreLeak'));
        expect(row.findings, contains('aggregateScoreLeak'));
        expect(row.findings, contains('moveRankingLeak'));
        expect(row.findings, contains('officialMetricLeak'));
        expect(row.findings, contains('cpLossLeak'));
        expect(row.findings, contains('winProbabilityLeak'));
      },
    );

    test(
      'validator rejects UI backend persistence engine scheduler and analyzer wiring',
      () {
        final row =
            const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationValidator()
                .validateRecord(
                  _safeRecord().copyWith(
                    analyzerUnwired: false,
                    safetyFlags:
                        const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(
                          targetsUi: true,
                          targetsBackend: true,
                          writesPersistence: true,
                          callsEngine: true,
                          executesScheduler: true,
                          wiresAnalyzer: true,
                          implementsRuntime: true,
                          implementsExecutablePrototype: true,
                        ),
                  ),
                  knownCaseIds: const <String>{'known-case'},
                  provenAndroidProofIds: const <String>{},
                );

        expect(row.status.isUnsafe, isTrue);
        expect(row.findings, contains('uiTarget'));
        expect(row.findings, contains('backendTarget'));
        expect(row.findings, contains('persistenceWrite'));
        expect(row.findings, contains('engineCall'));
        expect(row.findings, contains('schedulerExecution'));
        expect(row.findings, contains('analyzerWiring'));
        expect(row.findings, contains('runtimeImplementation'));
        expect(row.findings, contains('executablePrototypeImplementation'));
      },
    );

    test('validator rejects raw UCI PV dump and Stockfish command', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationValidator();
      final row = validator.validateRecord(
        _safeRecord().copyWith(
          activeDeniedFields: const <String>['rawUci'],
          safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(
            exposesStockfishCommand: true,
            exposesRawUci: true,
            exposesPvDump: true,
            requiresAndroidCollector: true,
          ),
        ),
        knownCaseIds: const <String>{'known-case'},
        provenAndroidProofIds: const <String>{},
      );
      final textFindings = validator.validateReportText(
        'info depth 1 pv e2e4 bestmove e2e4',
      );

      expect(row.status.isUnsafe, isTrue);
      expect(row.findings, contains('activeDeniedField'));
      expect(row.findings, contains('stockfishCommandLeak'));
      expect(row.findings, contains('rawUciLeak'));
      expect(row.findings, contains('pvDumpLeak'));
      expect(row.findings, contains('androidCollectorRequired'));
      expect(textFindings, isNotEmpty);
    });

    test('validator rejects quiet promotion and Phase 32E proof claims', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationValidator();
      final quietRow = validator.validateRecord(
        _safeRecord().copyWith(
          sourceDiagnosticCaseId: 'quiet-preparatory-hard-case',
          diagnosticRole: 'excludedNegativeGuard',
          supportAreaIds: const <String>['quietPreparatoryMove'],
          adapterBoundaryRole:
              DebugOnlyBridgeAnalyzerAdapterBoundaryRole.analyzerInputCandidate,
        ),
        knownCaseIds: const <String>{'quiet-preparatory-hard-case'},
        provenAndroidProofIds: const <String>{},
      );
      final proofRow = validator.validateRecord(
        _safeRecord().copyWith(
          sourceDiagnosticCaseId: 'budget-pressure-wide-candidate-32e',
          sourcePhase: 'Phase 32E',
          androidProofCaseIds: const <String>['queen-win-major-swing'],
        ),
        knownCaseIds: const <String>{'budget-pressure-wide-candidate-32e'},
        provenAndroidProofIds: const <String>{'queen-win-major-swing'},
      );

      expect(quietRow.findings, contains('quietPreparatoryPromotedToCore'));
      expect(proofRow.findings, contains('phase32ECapturedAndroidProofClaim'));
    });

    test('markdown and JSON reports are deterministic and safe', () {
      final result = _safeValidation();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(markdown, contains('## Validation Check Table'));
      expect(markdown, contains('## Boundary Record Validation Table'));
      expect(markdown, contains('## Android Proof Boundary'));
      expect(decoded['safeForPhase33O'], isTrue);
      expect(
        decoded['phase33ORecommendation'],
        'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign',
      );
      expect(counts['unsafeCount'], 0);
      expect(markdown, isNot(contains('info depth')));
      expect(markdown, isNot(contains('bestmove e2e4')));
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design_validation.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, isNot(contains('dart:ffi')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports.toLowerCase(), isNot(contains('stockfish')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('persistence')));
      expect(imports, isNot(contains('cache')));
      expect(imports, isNot(contains('database')));
      expect(imports, isNot(contains('scheduler')));
    });
  });
}

DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationResult _safeValidation() {
  final selectedValidation =
      const DebugOnlyBridgeSelectedGoldenDiagnosticValidation().evaluate();
  final boundaryDesign = const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign()
      .evaluate(selectedGoldenValidationResult: selectedValidation);
  return const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation()
      .evaluate(
        boundaryDesignResult: boundaryDesign,
        selectedGoldenValidationResult: selectedValidation,
      );
}

DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult _copyDesign(
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult result, {
  bool? sourceSafe,
  bool? safeForPhase33N,
  String? recommendation,
  List<DebugOnlyBridgeAnalyzerAdapterBoundaryRecord>? records,
}) {
  return DebugOnlyBridgeAnalyzerAdapterBoundaryDesignResult(
    status: result.status,
    sourceSelectedGoldenValidationStatus:
        result.sourceSelectedGoldenValidationStatus,
    sourceSelectedGoldenValidationSafeForPhase33M:
        sourceSafe ?? result.sourceSelectedGoldenValidationSafeForPhase33M,
    sourceSelectedGoldenValidationRecommendation:
        result.sourceSelectedGoldenValidationRecommendation,
    components: result.components,
    boundaryRecords: records ?? result.boundaryRecords,
    reportFindings: result.reportFindings,
    safeForPhase33N: safeForPhase33N ?? result.safeForPhase33N,
    phase33NRecommendation: recommendation ?? result.phase33NRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterBoundaryRecord _safeRecord() {
  return const DebugOnlyBridgeAnalyzerAdapterBoundaryRecord(
    boundaryRecordId: 'test-record',
    sourceDiagnosticCaseId: 'known-case',
    sourceValidationRowId: 'selected-golden-known-case',
    sourcePhase: 'existing',
    selectedReason: 'test seam',
    diagnosticRole: 'coreSupport',
    adapterBoundaryRole:
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.analyzerInputCandidate,
    supportAreaIds: <String>['tacticalShot'],
    allowedFieldIds: <String>['caseId'],
    deniedFieldIds: <String>['productLabel'],
    blockedBoundaryIds: <String>['productOutput'],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    androidProofCaseIds: <String>[],
    ownerProofRequired: false,
    designOnly: true,
    developerOnly: true,
    analyzerUnwired: true,
    activeDeniedFields: <String>[],
    safetyFlags: DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(),
    findings: <String>[],
    recommendation: 'validateDebugOnlyBridgeAnalyzerAdapterBoundaryDesign',
  );
}
