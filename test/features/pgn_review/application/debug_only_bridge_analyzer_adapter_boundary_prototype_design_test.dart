@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_diagnostic_command.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign', () {
    test('safe default prototype design is ready with warnings', () {
      final result = _safePrototypeDesign();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignStatus
            .prototypeDesignReadyWithWarnings,
      );
      expect(
        result.sourceBoundaryValidationStatus,
        'boundaryDesignValidatedWithWarnings',
      );
      expect(result.sourceBoundaryValidationSafeForPhase33O, isTrue);
      expect(result.safeForPhase33P, isTrue);
      expect(
        result.phase33PRecommendation,
        'validateDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign',
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

    test('consumes Phase 33N validation rows deterministically', () {
      final boundaryValidation = _safeBoundaryValidation();
      final design =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign();
      final first = design.evaluate(
        boundaryValidationResult: boundaryValidation,
      );
      final second = design.evaluate(
        boundaryValidationResult: boundaryValidation,
      );

      expect(first.renderJson(), second.renderJson());
      expect(
        first.totalPrototypeRecords,
        boundaryValidation.totalValidationRows,
      );
      expect(first.inputPacketDesignCount, greaterThan(0));
      expect(first.futureRequirementPacketDesignCount, 1);
    });

    test('maps boundary roles to prototype packet concepts', () {
      final result = _safePrototypeDesign();
      final recordsByCaseId = {
        for (final record in result.prototypeRecords)
          record.sourceDiagnosticCaseId: record,
      };

      expect(
        recordsByCaseId['queen-win-major-swing']!.prototypePacketRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
            .analyzerAdapterPrototypeInputPacket,
      );
      expect(
        recordsByCaseId['queen-win-major-swing']!.futureInternalOnly,
        true,
      );
      expect(
        recordsByCaseId['endgame-precision-candidate-spread-32e']!
            .prototypePacketRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
            .analyzerAdapterPrototypeContextPacket,
      );
      expect(
        recordsByCaseId['endgame-precision-candidate-spread-32e']!.contextOnly,
        true,
      );
      expect(
        recordsByCaseId['budget-pressure-wide-candidate-32e']!
            .prototypePacketRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
            .analyzerAdapterPrototypeWarningLimitedPacket,
      );
      expect(
        recordsByCaseId['pv-multipv-support-boundary-32e']!.prototypePacketRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
            .analyzerAdapterPrototypeProofBoundaryPacket,
      );
      expect(
        recordsByCaseId['quiet-preparatory-hard-case']!.prototypePacketRole,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
            .analyzerAdapterPrototypeExcludedGuardPacket,
      );
    });

    test('proof honesty and owner proof boundaries are preserved', () {
      final result = _safePrototypeDesign();
      final phase32ERecords = result.prototypeRecords.where(
        (record) => record.sourcePhase == 'Phase 32E',
      );
      final proofIds = result.prototypeRecords
          .map((record) => record.androidProofCaseIds)
          .expand((ids) => ids)
          .toSet();

      expect(phase32ERecords, isNotEmpty);
      for (final record in phase32ERecords) {
        expect(
          record.androidProofCaseIds,
          isEmpty,
          reason: record.prototypeRecordId,
        );
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

    test('denied fields and integration boundaries remain blocked', () {
      final result = _safePrototypeDesign();

      for (final record in result.prototypeRecords) {
        expect(record.designOnly, isTrue, reason: record.prototypeRecordId);
        expect(record.developerOnly, isTrue, reason: record.prototypeRecordId);
        expect(
          record.analyzerUnwired,
          isTrue,
          reason: record.prototypeRecordId,
        );
        expect(
          record.activeDeniedFields,
          isEmpty,
          reason: record.prototypeRecordId,
        );
        expect(record.findings, isEmpty, reason: record.prototypeRecordId);
      }
      expect(result.deniedFieldPacketDesignCount, greaterThanOrEqualTo(5));
      expect(result.analyzerWiringCount, 0);
      expect(result.uiTargetCount, 0);
      expect(result.backendTargetCount, 0);
      expect(result.persistenceWriteCount, 0);
      expect(result.engineCallCount, 0);
      expect(result.schedulerExecutionCount, 0);
      expect(result.stockfishCommandLeakCount, 0);
      expect(result.rawUciLeakCount, 0);
      expect(result.pvDumpLeakCount, 0);
    });

    test('unsafe boundary validation is blocked', () {
      final unsafeValidation = _copyBoundaryValidation(
        _safeBoundaryValidation(),
        sourceSafe: false,
        safeForPhase33O: false,
        recommendation:
            'blockedByUnsafeAnalyzerAdapterBoundaryDesignValidation',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign()
              .evaluate(boundaryValidationResult: unsafeValidation);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignStatus
            .blockedByUnsafeBoundaryValidation,
      );
      expect(result.safeForPhase33P, isFalse);
      expect(result.hasUnsafePolicyViolation, isTrue);
    });

    test('validator rejects product labels and scoring leaks', () {
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
      final findings =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidator()
              .validateRecord(
                record,
                knownCaseIds: const <String>{'known-case'},
              );

      expect(findings, contains('productOutput'));
      expect(findings, contains('classifierLabelLeak'));
      expect(findings, contains('finalLabelLeak'));
      expect(findings, contains('numericScoreLeak'));
      expect(findings, contains('aggregateScoreLeak'));
      expect(findings, contains('moveRankingLeak'));
      expect(findings, contains('officialMetricLeak'));
      expect(findings, contains('cpLossLeak'));
      expect(findings, contains('winProbabilityLeak'));
    });

    test(
      'validator rejects UI backend persistence engine scheduler and analyzer wiring',
      () {
        final record = _safePrototypeRecord().copyWith(
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
            const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidator()
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

    test('validator rejects Stockfish command raw UCI and PV dump exposure', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidator();
      final findings = validator.validateRecord(
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

      expect(findings, contains('activeDeniedField'));
      expect(findings, contains('stockfishCommandLeak'));
      expect(findings, contains('rawUciLeak'));
      expect(findings, contains('pvDumpLeak'));
      expect(findings, contains('androidCollectorRequired'));
      expect(textFindings, isNotEmpty);
    });

    test('validator rejects quiet promotion and Phase 32E proof claims', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidator();
      final quietFindings = validator.validateRecord(
        _safePrototypeRecord().copyWith(
          sourceDiagnosticCaseId: 'quiet-preparatory-hard-case',
          diagnosticRole: 'excludedNegativeGuard',
          adapterBoundaryRole: DebugOnlyBridgeAnalyzerAdapterBoundaryRole
              .analyzerInputCandidate
              .wire,
          prototypePacketRole:
              DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypePacketRole
                  .analyzerAdapterPrototypeInputPacket,
          futureInternalOnly: true,
          excludedNegativeGuard: false,
          blockedBoundaryIds: const <String>['quietPreparatoryCoreActivation'],
        ),
        knownCaseIds: const <String>{'quiet-preparatory-hard-case'},
      );
      final proofFindings = validator.validateRecord(
        _safePrototypeRecord().copyWith(
          sourceDiagnosticCaseId: 'budget-pressure-wide-candidate-32e',
          sourcePhase: 'Phase 32E',
          androidProofCaseIds: const <String>['queen-win-major-swing'],
        ),
        knownCaseIds: const <String>{'budget-pressure-wide-candidate-32e'},
      );

      expect(
        quietFindings,
        contains('quietPreparatoryPromotedToPrototypeInput'),
      );
      expect(proofFindings, contains('phase32ECapturedAndroidProofClaim'));
    });

    test('markdown and JSON reports are deterministic and safe', () {
      final result = _safePrototypeDesign();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(markdown, contains('## Prototype Packet Summary'));
      expect(markdown, contains('## Prototype Record Table'));
      expect(markdown, contains('## Role Mapping Behavior'));
      expect(markdown, contains('## Android Proof Boundary'));
      expect(decoded['safeForPhase33P'], isTrue);
      expect(
        decoded['phase33PRecommendation'],
        'validateDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign',
      );
      expect(counts['unsafeCount'], 0);
      expect(markdown, isNot(contains('info depth')));
      expect(markdown, isNot(contains('bestmove e2e4')));
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design.dart',
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

DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignResult
_safePrototypeDesign() {
  return const DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign().evaluate(
    boundaryValidationResult: _safeBoundaryValidation(),
  );
}

DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationResult
_safeBoundaryValidation() {
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

DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationResult
_copyBoundaryValidation(
  DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationResult result, {
  bool? sourceSafe,
  bool? safeForPhase33O,
  String? recommendation,
}) {
  return DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationResult(
    status: result.status,
    sourceBoundaryDesignStatus: result.sourceBoundaryDesignStatus,
    sourceBoundaryDesignSafeForPhase33N:
        sourceSafe ?? result.sourceBoundaryDesignSafeForPhase33N,
    sourceBoundaryDesignRecommendation:
        result.sourceBoundaryDesignRecommendation,
    sourceSelectedGoldenValidationStatus:
        result.sourceSelectedGoldenValidationStatus,
    checks: result.checks,
    validationRows: result.validationRows,
    reportFindings: result.reportFindings,
    safeForPhase33O: safeForPhase33O ?? result.safeForPhase33O,
    phase33ORecommendation: recommendation ?? result.phase33ORecommendation,
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
