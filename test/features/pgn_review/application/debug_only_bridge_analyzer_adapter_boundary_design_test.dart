@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_diagnostic_command.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterBoundaryDesign', () {
    test(
      'safe default design is ready with warnings and consumes validation',
      () {
        final selectedValidation =
            const DebugOnlyBridgeSelectedGoldenDiagnosticValidation()
                .evaluate();
        final result = const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign()
            .evaluate(selectedGoldenValidationResult: selectedValidation);

        expect(
          result.status,
          DebugOnlyBridgeAnalyzerAdapterBoundaryDesignStatus
              .boundaryDesignReadyWithWarnings,
        );
        expect(result.sourceSelectedGoldenValidationSafeForPhase33M, isTrue);
        expect(
          result.sourceSelectedGoldenValidationRecommendation,
          'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryDesign',
        );
        expect(result.safeForPhase33N, isTrue);
        expect(
          result.phase33NRecommendation,
          'validateDebugOnlyBridgeAnalyzerAdapterBoundaryDesign',
        );
        expect(result.blockerCount, 0);
        expect(result.criticalCount, 0);
        expect(result.unsafeCount, 0);
        expect(result.activeDeniedFieldCount, 0);
        expect(result.productOutputCount, 0);
        expect(result.engineCallCount, 0);
        expect(result.schedulerExecutionCount, 0);
        expect(result.analyzerWiringCount, 0);
      },
    );

    test('boundary records are deterministic', () {
      final selectedValidation =
          const DebugOnlyBridgeSelectedGoldenDiagnosticValidation().evaluate();
      final design = const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign();
      final first = design.evaluate(
        selectedGoldenValidationResult: selectedValidation,
      );
      final second = design.evaluate(
        selectedGoldenValidationResult: selectedValidation,
      );

      expect(first.renderJson(), second.renderJson());
      expect(first.components.length, 12);
      expect(first.totalBoundaryRecords, second.totalBoundaryRecords);
    });

    test('allowed roles map correctly', () {
      final selectedValidation =
          const DebugOnlyBridgeSelectedGoldenDiagnosticValidation().evaluate();
      final result = const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign()
          .evaluate(selectedGoldenValidationResult: selectedValidation);
      final recordsByCaseId = {
        for (final record in result.boundaryRecords)
          record.sourceDiagnosticCaseId: record,
      };

      expect(
        recordsByCaseId['queen-win-major-swing']!.adapterBoundaryRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.analyzerInputCandidate,
      );
      expect(
        recordsByCaseId['endgame-precision-candidate-spread-32e']!
            .adapterBoundaryRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.contextOnlyCandidate,
      );
      expect(
        recordsByCaseId['budget-pressure-wide-candidate-32e']!
            .adapterBoundaryRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.warningLimitedCandidate,
      );
      expect(
        recordsByCaseId['pv-multipv-support-boundary-32e']!.adapterBoundaryRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.proofBoundaryOnly,
      );
      expect(
        recordsByCaseId['quiet-preparatory-hard-case']!.adapterBoundaryRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryRole.excludedNegativeGuard,
      );
    });

    test('Phase 32E proof honesty and Android proof limits are preserved', () {
      final selectedValidation =
          const DebugOnlyBridgeSelectedGoldenDiagnosticValidation().evaluate();
      final result = const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign()
          .evaluate(selectedGoldenValidationResult: selectedValidation);
      final phase32ERecords = result.boundaryRecords.where(
        (record) => record.sourcePhase == 'Phase 32E',
      );

      expect(phase32ERecords, isNotEmpty);
      for (final record in phase32ERecords) {
        expect(
          record.androidProofCaseIds,
          isEmpty,
          reason: record.boundaryRecordId,
        );
      }
      expect(result.unprovenAndroidProofCount, 0);
      expect(result.phase32EProofClaimCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('denied fields and runtime integration remain inactive', () {
      final selectedValidation =
          const DebugOnlyBridgeSelectedGoldenDiagnosticValidation().evaluate();
      final result = const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign()
          .evaluate(selectedGoldenValidationResult: selectedValidation);

      for (final record in result.boundaryRecords) {
        expect(record.designOnly, isTrue, reason: record.boundaryRecordId);
        expect(record.developerOnly, isTrue, reason: record.boundaryRecordId);
        expect(record.analyzerUnwired, isTrue, reason: record.boundaryRecordId);
        expect(
          record.activeDeniedFields,
          isEmpty,
          reason: record.boundaryRecordId,
        );
        expect(
          record.safetyFlags.hasUnsafeFlag,
          isFalse,
          reason: record.boundaryRecordId,
        );
      }
      expect(result.runtimeBlockedCount, 1);
      expect(result.schedulerBlockedCount, 1);
      expect(result.persistenceBlockedCount, 1);
      expect(result.engineBlockedCount, 1);
    });

    test('validator rejects product labels and classifier/final labels', () {
      final record = _safeRecord().copyWith(
        safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(
          isProductOutput: true,
          emitsClassifierLabel: true,
          emitsFinalLabel: true,
        ),
      );
      final findings =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidator()
              .validateRecord(
                record,
                knownCaseIds: const <String>{'known-case'},
              );

      expect(findings, contains('productOutput'));
      expect(findings, contains('classifierLabelLeak'));
      expect(findings, contains('finalLabelLeak'));
    });

    test(
      'validator rejects scores rankings metrics CP-loss and win probability',
      () {
        final record = _safeRecord().copyWith(
          safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(
            hasNumericScore: true,
            hasAggregateScore: true,
            ranksMoves: true,
            emitsOfficialMetric: true,
            exposesCpLoss: true,
            exposesWinProbability: true,
          ),
        );
        final findings =
            const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidator()
                .validateRecord(
                  record,
                  knownCaseIds: const <String>{'known-case'},
                );

        expect(findings, contains('numericScoreLeak'));
        expect(findings, contains('aggregateScoreLeak'));
        expect(findings, contains('moveRankingLeak'));
        expect(findings, contains('officialMetricLeak'));
        expect(findings, contains('cpLossLeak'));
        expect(findings, contains('winProbabilityLeak'));
      },
    );

    test(
      'validator rejects UI backend persistence engine scheduler and analyzer wiring',
      () {
        final record = _safeRecord().copyWith(
          analyzerUnwired: false,
          safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(
            targetsUi: true,
            targetsBackend: true,
            writesPersistence: true,
            callsEngine: true,
            executesScheduler: true,
            wiresAnalyzer: true,
            implementsRuntime: true,
            implementsExecutablePrototype: true,
          ),
        );
        final findings =
            const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidator()
                .validateRecord(
                  record,
                  knownCaseIds: const <String>{'known-case'},
                );

        expect(findings, contains('uiTarget'));
        expect(findings, contains('backendTarget'));
        expect(findings, contains('persistenceWrite'));
        expect(findings, contains('engineCall'));
        expect(findings, contains('schedulerExecution'));
        expect(findings, contains('analyzerWiring'));
        expect(findings, contains('runtimeImplementation'));
        expect(findings, contains('executablePrototypeImplementation'));
      },
    );

    test('validator rejects raw engine fields and raw report text leaks', () {
      final record = _safeRecord().copyWith(
        activeDeniedFields: const <String>['rawUci'],
        safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(
          exposesStockfishCommand: true,
          exposesRawUci: true,
          exposesPvDump: true,
          requiresAndroidCollector: true,
        ),
      );
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidator();
      final findings = validator.validateRecord(
        record,
        knownCaseIds: const <String>{'known-case'},
      );
      final textFindings = validator.validateReportText(
        'info depth 1 pv e2e4 bestmove e2e4',
      );

      expect(findings, contains('activeDeniedField'));
      expect(findings, contains('stockfishCommandLeak'));
      expect(findings, contains('rawUciLeak'));
      expect(findings, contains('pvDumpLeak'));
      expect(findings, contains('androidCollectorRequired'));
      expect(textFindings, isNotEmpty);
    });

    test('validator rejects quiet promotion and Phase 32E proof claims', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidator();
      final quietFindings = validator.validateRecord(
        _safeRecord().copyWith(
          sourceDiagnosticCaseId: 'quiet-preparatory-hard-case',
          diagnosticRole: 'excludedNegativeGuard',
          supportAreaIds: const <String>['quietPreparatoryMove'],
          adapterBoundaryRole:
              DebugOnlyBridgeAnalyzerAdapterBoundaryRole.analyzerInputCandidate,
        ),
        knownCaseIds: const <String>{'quiet-preparatory-hard-case'},
      );
      final phase32EFindings = validator.validateRecord(
        _safeRecord().copyWith(
          sourceDiagnosticCaseId: 'budget-pressure-wide-candidate-32e',
          sourcePhase: 'Phase 32E',
          androidProofCaseIds: const <String>['queen-win-major-swing'],
        ),
        knownCaseIds: const <String>{'budget-pressure-wide-candidate-32e'},
      );

      expect(quietFindings, contains('quietPreparatoryPromotedToCore'));
      expect(phase32EFindings, contains('phase32ECapturedAndroidProofClaim'));
    });

    test('markdown and JSON reports are deterministic and safe', () {
      final result = const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign()
          .evaluate(
            selectedGoldenValidationResult:
                const DebugOnlyBridgeSelectedGoldenDiagnosticValidation()
                    .evaluate(),
          );
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(markdown, contains('## Boundary Component Table'));
      expect(markdown, contains('## Boundary Record Table'));
      expect(markdown, contains('## Android Proof Boundary'));
      expect(decoded['safeForPhase33N'], isTrue);
      expect(
        decoded['phase33NRecommendation'],
        'validateDebugOnlyBridgeAnalyzerAdapterBoundaryDesign',
      );
      expect(counts['unsafeCount'], 0);
      expect(markdown, isNot(contains('info depth')));
      expect(markdown, isNot(contains('bestmove e2e4')));
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart',
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
