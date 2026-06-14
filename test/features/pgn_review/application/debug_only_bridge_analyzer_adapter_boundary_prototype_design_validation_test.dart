@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_diagnostic_command.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidation', () {
    test('safe default prototype design validation passes with warnings', () {
      final result = _safeValidation();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationStatus
            .prototypeDesignValidatedWithWarnings,
      );
      expect(
        result.sourcePrototypeDesignStatus,
        'prototypeDesignReadyWithWarnings',
      );
      expect(result.sourcePrototypeDesignSafeForPhase33P, isTrue);
      expect(result.safeForPhase33Q, isTrue);
      expect(
        result.phase33QRecommendation,
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign',
      );
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.analyzerWiringCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
      expect(result.activeDeniedFieldCount, 0);
      expect(result.productOutputCount, 0);
    });

    test('Phase 33O prototype design is consumed deterministically', () {
      final prototypeDesign = _safePrototypeDesign();
      final validation =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidation();
      final first = validation.evaluate(prototypeDesignResult: prototypeDesign);
      final second = validation.evaluate(
        prototypeDesignResult: prototypeDesign,
      );

      expect(first.renderJson(), second.renderJson());
      expect(first.totalChecks, 18);
      expect(first.passedCheckCount, first.totalChecks);
      expect(first.totalValidationRows, prototypeDesign.totalPrototypeRecords);
    });

    test('validation preserves prototype packet role boundaries', () {
      final result = _safeValidation();
      final rowsByCaseId = {
        for (final row in result.validationRows)
          row.sourceDiagnosticCaseId: row,
      };

      expect(
        rowsByCaseId['queen-win-major-swing']!.prototypePacketRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
            .analyzerAdapterPrototypeInputPacket
            .wire,
      );
      expect(rowsByCaseId['queen-win-major-swing']!.futureInternalOnly, isTrue);
      expect(
        rowsByCaseId['endgame-precision-candidate-spread-32e']!
            .prototypePacketRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
            .analyzerAdapterPrototypeContextPacket
            .wire,
      );
      expect(
        rowsByCaseId['budget-pressure-wide-candidate-32e']!.prototypePacketRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
            .analyzerAdapterPrototypeWarningLimitedPacket
            .wire,
      );
      expect(
        rowsByCaseId['pv-multipv-support-boundary-32e']!.prototypePacketRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
            .analyzerAdapterPrototypeProofBoundaryPacket
            .wire,
      );
      expect(
        rowsByCaseId['quiet-preparatory-hard-case']!.prototypePacketRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
            .analyzerAdapterPrototypeExcludedGuardPacket
            .wire,
      );
    });

    test('aggregate role counts are deterministic', () {
      final result = _safeValidation();

      expect(result.inputPacketValidationCount, 8);
      expect(result.contextPacketValidationCount, 3);
      expect(result.warningLimitedPacketValidationCount, 2);
      expect(result.proofBoundaryPacketValidationCount, 1);
      expect(result.excludedGuardPacketValidationCount, 2);
      expect(result.deniedFieldPacketValidationCount, 5);
      expect(result.futureRequirementPacketValidationCount, 1);
    });

    test('proof honesty and owner proof boundaries are preserved', () {
      final result = _safeValidation();
      final phase32ERows = result.validationRows.where(
        (row) => row.sourcePhase == 'Phase 32E',
      );
      final proofIds = result.validationRows
          .map((row) => row.androidProofCaseIds)
          .expand((ids) => ids)
          .toSet();

      expect(phase32ERows, isNotEmpty);
      for (final row in phase32ERows) {
        expect(row.androidProofCaseIds, isEmpty, reason: row.validationRowId);
      }
      expect(
        proofIds,
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

    test('denied fields and integration boundaries stay inactive', () {
      final result = _safeValidation();

      for (final row in result.validationRows) {
        expect(row.designOnly, isTrue, reason: row.validationRowId);
        expect(row.developerOnly, isTrue, reason: row.validationRowId);
        expect(row.analyzerUnwired, isTrue, reason: row.validationRowId);
        expect(row.activeDeniedFields, isEmpty, reason: row.validationRowId);
        expect(row.findings, isEmpty, reason: row.validationRowId);
      }
      expect(result.uiTargetCount, 0);
      expect(result.backendTargetCount, 0);
      expect(result.persistenceWriteCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
      expect(result.stockfishCommandLeakCount, 0);
      expect(result.rawUciLeakCount, 0);
      expect(result.pvDumpLeakCount, 0);
    });

    test('unsafe prototype design is blocked', () {
      final unsafeDesign = _copyPrototypeDesign(
        _safePrototypeDesign(),
        safeForPhase33P: false,
        recommendation: 'blockedByUnsafeAnalyzerAdapterBoundaryPrototypeDesign',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidation()
              .evaluate(prototypeDesignResult: unsafeDesign);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationStatus
            .blockedByUnsafePrototypeDesign,
      );
      expect(result.safeForPhase33Q, isFalse);
      expect(result.hasUnsafePolicyViolation, isTrue);
    });

    test('validator rejects product labels and score metric leaks', () {
      final record = _safePrototypeRecord().copyWith(
        safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(
          isProductOutput: true,
          emitsClassifierLabel: true,
          emitsFinalLabel: true,
          hasNumericScore: true,
          hasAggregateScore: true,
          ranksMoves: true,
          emitsOfficialMetric: true,
          exposesCpLoss: true,
          exposesWinProbability: true,
        ),
      );
      final row =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationValidator()
              .validateRecord(
                record,
                knownCaseIds: const <String>{'known-case'},
              );

      expect(row.status.isUnsafe, isTrue);
      expect(row.findings, contains('productOutput'));
      expect(row.findings, contains('classifierLabelLeak'));
      expect(row.findings, contains('finalLabelLeak'));
      expect(row.findings, contains('numericScoreLeak'));
      expect(row.findings, contains('aggregateScoreLeak'));
      expect(row.findings, contains('moveRankingLeak'));
      expect(row.findings, contains('officialMetricLeak'));
      expect(row.findings, contains('cpLossLeak'));
      expect(row.findings, contains('winProbabilityLeak'));
    });

    test(
      'validator rejects UI backend persistence engine scheduler analyzer runtime leaks',
      () {
        final row =
            const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationValidator()
                .validateRecord(
                  _safePrototypeRecord().copyWith(
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

    test('validator rejects Stockfish command raw UCI and PV dump exposure', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationValidator();
      final row = validator.validateRecord(
        _safePrototypeRecord().copyWith(
          activeDeniedFields: const <String>['rawUci'],
          safetyFlags: const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(
            exposesStockfishCommand: true,
            exposesRawUci: true,
            exposesPvDump: true,
            requiresAndroidCollector: true,
          ),
        ),
        knownCaseIds: const <String>{'known-case'},
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

    test(
      'validator rejects quiet promotion Phase 32E proof and PV promotion',
      () {
        final validator =
            const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationValidator();
        final quietRow = validator.validateRecord(
          _safePrototypeRecord().copyWith(
            sourceDiagnosticCaseId: 'quiet-preparatory-hard-case',
            diagnosticRole: 'excludedNegativeGuard',
            blockedBoundaryIds: const <String>[
              'quietPreparatoryCoreActivation',
            ],
            excludedNegativeGuard: false,
          ),
          knownCaseIds: const <String>{'quiet-preparatory-hard-case'},
        );
        final proofRow = validator.validateRecord(
          _safePrototypeRecord().copyWith(
            sourceDiagnosticCaseId: 'budget-pressure-wide-candidate-32e',
            sourcePhase: 'Phase 32E',
            androidProofCaseIds: const <String>['queen-win-major-swing'],
          ),
          knownCaseIds: const <String>{'budget-pressure-wide-candidate-32e'},
        );
        final pvRow = validator.validateRecord(
          _safePrototypeRecord().copyWith(
            sourceDiagnosticCaseId: 'pv-multipv-support-boundary-32e',
            adapterBoundaryRole: DebugOnlyBridgeAnalyzerAdapterBoundaryRole
                .analyzerInputCandidate
                .wire,
            prototypePacketRole:
                DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
                    .analyzerAdapterPrototypeInputPacket,
            futureInternalOnly: true,
            proofBoundaryOnly: false,
          ),
          knownCaseIds: const <String>{'pv-multipv-support-boundary-32e'},
        );

        expect(
          quietRow.findings,
          contains('quietPreparatoryPromotedToPrototypeInput'),
        );
        expect(
          proofRow.findings,
          contains('phase32ECapturedAndroidProofClaim'),
        );
        expect(pvRow.findings, contains('proofBoundaryPromoted'));
      },
    );

    test('markdown and JSON validation reports are deterministic and safe', () {
      final result = _safeValidation();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(markdown, contains('## Validation Check Table'));
      expect(markdown, contains('## Prototype Packet Validation Table'));
      expect(markdown, contains('## Prototype Packet Role Validation'));
      expect(markdown, contains('## Android Proof Boundary'));
      expect(decoded['safeForPhase33Q'], isTrue);
      expect(
        decoded['phase33QRecommendation'],
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign',
      );
      expect(counts['unsafeCount'], 0);
      expect(markdown, isNot(contains('info depth')));
      expect(markdown, isNot(contains('bestmove e2e4')));
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design_validation.dart',
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

DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult
_safeValidation() {
  return const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidation()
      .evaluate(prototypeDesignResult: _safePrototypeDesign());
}

DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignResult
_safePrototypeDesign() {
  final selectedValidation =
      const DebugOnlyBridgeSelectedGoldenDiagnosticValidation().evaluate();
  final boundaryDesign = const DebugOnlyBridgeAnalyzerAdapterBoundaryDesign()
      .evaluate(selectedGoldenValidationResult: selectedValidation);
  final boundaryValidation =
      const DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidation().evaluate(
        boundaryDesignResult: boundaryDesign,
        selectedGoldenValidationResult: selectedValidation,
      );
  return const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign().evaluate(
    boundaryValidationResult: boundaryValidation,
  );
}

DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignResult
_copyPrototypeDesign(
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignResult result, {
  bool? safeForPhase33P,
  String? recommendation,
  List<DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord>? records,
}) {
  return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignResult(
    status: result.status,
    sourceBoundaryValidationStatus: result.sourceBoundaryValidationStatus,
    sourceBoundaryValidationSafeForPhase33O:
        result.sourceBoundaryValidationSafeForPhase33O,
    sourceBoundaryValidationRecommendation:
        result.sourceBoundaryValidationRecommendation,
    prototypeRecords: records ?? result.prototypeRecords,
    reportFindings: result.reportFindings,
    safeForPhase33P: safeForPhase33P ?? result.safeForPhase33P,
    phase33PRecommendation: recommendation ?? result.phase33PRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord
_safePrototypeRecord() {
  return const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignRecord(
    prototypeRecordId: 'test-prototype-record',
    sourceValidationRowId: 'phase33n-test',
    sourceBoundaryRecordId: 'phase33m-test',
    sourceDiagnosticCaseId: 'known-case',
    sourcePhase: 'existing',
    diagnosticRole: 'coreSupport',
    adapterBoundaryRole: 'analyzerInputCandidate',
    prototypePacketRole:
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
            .analyzerAdapterPrototypeInputPacket,
    designOnly: true,
    developerOnly: true,
    analyzerUnwired: true,
    futureInternalOnly: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedNegativeGuard: false,
    inactiveDeniedFieldPacket: false,
    allowedFieldIds: <String>['caseId'],
    deniedFieldIds: <String>['productLabel'],
    blockedBoundaryIds: <String>['productOutput'],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    androidProofCaseIds: <String>[],
    ownerProofRequired: false,
    activeDeniedFields: <String>[],
    safetyFlags: DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(),
    findings: <String>[],
    recommendation:
        'validateDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign',
  );
}
