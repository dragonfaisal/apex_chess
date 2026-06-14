@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_contract_design.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_diagnostic_command.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign', () {
    test('safe default contract design is ready with warnings', () {
      final result = _safeContractDesign();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignStatus
            .prototypeContractDesignReadyWithWarnings,
      );
      expect(
        result.sourcePrototypeValidationStatus,
        'prototypeDesignValidatedWithWarnings',
      );
      expect(result.sourcePrototypeValidationSafeForPhase33Q, isTrue);
      expect(result.safeForPhase33R, isTrue);
      expect(
        result.phase33RRecommendation,
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign',
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

    test('contract groups are deterministic and complete', () {
      final first = _safeContractDesign();
      final second = _safeContractDesign();

      expect(first.renderJson(), second.renderJson());
      expect(first.totalContractGroups, 12);
      expect(
        first.contractGroups.map((group) => group.groupId.wire),
        containsAll(<String>[
          'prototypeContractInputGroup',
          'prototypeContractContextGroup',
          'prototypeContractWarningLimitedGroup',
          'prototypeContractProofBoundaryGroup',
          'prototypeContractExcludedGuardGroup',
          'prototypeContractDeniedFieldGroup',
          'prototypeContractAllowedInternalFieldGroup',
          'prototypeContractRuntimeBlockedGroup',
          'prototypeContractAnalyzerWiringBlockedGroup',
          'prototypeContractEngineBlockedGroup',
          'prototypeContractSchedulerBlockedGroup',
          'phase33RRequirementGroup',
        ]),
      );
    });

    test('contract record roles preserve validated prototype packet roles', () {
      final result = _safeContractDesign();
      final recordsByCaseId = {
        for (final record in result.contractRecords)
          record.sourceCaseId: record,
      };

      expect(
        recordsByCaseId['queen-win-major-swing']!.contractRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .internalInputContract,
      );
      expect(
        recordsByCaseId['endgame-precision-candidate-spread-32e']!.contractRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole.contextOnlyContract,
      );
      expect(
        recordsByCaseId['budget-pressure-wide-candidate-32e']!.contractRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .warningLimitedContract,
      );
      expect(
        recordsByCaseId['pv-multipv-support-boundary-32e']!.contractRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .proofBoundaryContract,
      );
      expect(
        recordsByCaseId['quiet-preparatory-hard-case']!.contractRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
            .excludedGuardContract,
      );
    });

    test('aggregate counts preserve contract surfaces', () {
      final result = _safeContractDesign();

      expect(result.internalInputContractCount, 8);
      expect(result.contextOnlyContractCount, 3);
      expect(result.warningLimitedContractCount, 2);
      expect(result.proofBoundaryContractCount, 1);
      expect(result.excludedGuardContractCount, 2);
      expect(result.deniedFieldContractCount, 5);
      expect(result.allowedInternalFieldContractCount, 1);
      expect(result.runtimeBlockedContractCount, 1);
      expect(result.analyzerWiringBlockedContractCount, 1);
      expect(result.engineBlockedContractCount, 1);
      expect(result.schedulerBlockedContractCount, 1);
      expect(result.futureRequirementContractCount, 2);
    });

    test('allowed and denied field contracts are explicit', () {
      final result = _safeContractDesign();
      final allowedRecord = result.contractRecords.firstWhere(
        (record) =>
            record.contractRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                .allowedInternalFieldContract,
      );
      final deniedRecord = result.contractRecords.firstWhere(
        (record) =>
            record.contractRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                .deniedFieldContract,
      );

      expect(
        allowedRecord.allowedInternalFieldIds,
        containsAll(<String>[
          'contractRecordId',
          'sourcePrototypeRecordId',
          'sourceCaseId',
          'prototypePacketRole',
          'contractRole',
          'warningReasons',
          'proofLimitReasons',
          'androidProofBoundaryIds',
          'blockedBoundaryIds',
        ]),
      );
      expect(
        deniedRecord.deniedFieldIds,
        containsAll(<String>[
          'productLabel',
          'finalMoveLabel',
          'classifierLabel',
          'brilliantGreatMiss',
          'bestGoodInaccuracyMistakeBlunder',
          'numericMoveScore',
          'aggregateScore',
          'officialMetric',
          'accuracy',
          'acpl',
          'cpLoss',
          'winProbability',
          'moveRanking',
          'thresholds',
          'uiTarget',
          'backendTarget',
          'persistenceWrite',
          'schedulerExecution',
          'directEngineAccess',
          'stockfishCommand',
          'rawUci',
          'pvDump',
          'androidCollectorRequirement',
          'analyzerWiring',
          'runtimeImplementation',
          'executablePrototypeBehavior',
        ]),
      );
    });

    test(
      'Phase 32E proof honesty and owner proof boundaries are preserved',
      () {
        final result = _safeContractDesign();
        final phase32ERecords = result.contractRecords.where(
          (record) => record.sourcePhase == 'Phase 32E',
        );
        final proofIds = result.contractRecords
            .map((record) => record.androidProofCaseIds)
            .expand((ids) => ids)
            .toSet();

        expect(phase32ERecords, isNotEmpty);
        for (final record in phase32ERecords) {
          expect(
            record.androidProofCaseIds,
            isEmpty,
            reason: record.contractRecordId,
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
        expect(result.phase32EProofClaimCount, 0);
        expect(result.unprovenAndroidProofCount, 0);
        expect(result.ownerProofQueueCount, 0);
      },
    );

    test('unsafe Phase 33P input blocks contract design', () {
      final unsafeValidation = _copyPrototypeValidation(
        _safePrototypeValidation(),
        safeForPhase33Q: false,
        recommendation:
            'blockedByUnsafeAnalyzerAdapterBoundaryPrototypeDesignValidation',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign()
              .evaluate(prototypeValidationResult: unsafeValidation);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignStatus
            .blockedByUnsafePrototypeValidation,
      );
      expect(result.safeForPhase33R, isFalse);
      expect(result.hasUnsafePolicyViolation, isTrue);
    });

    test(
      'validator rejects product labels scores metrics and probability leaks',
      () {
        final record = _safeContractRecord().copyWith(
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
            const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidator()
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
      },
    );

    test(
      'validator rejects integration runtime engine scheduler and raw output leaks',
      () {
        final validator =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidator();
        final findings = validator.validateRecord(
          _safeContractRecord().copyWith(
            analyzerUnwired: false,
            runtimeBlocked: false,
            executablePrototypeBlocked: false,
            activeDeniedFieldIds: const <String>['rawUci'],
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

        expect(findings, contains('analyzerWiringEnabled'));
        expect(findings, contains('runtimeImplementation'));
        expect(findings, contains('executablePrototypeImplementation'));
        expect(findings, contains('activeDeniedField'));
        expect(findings, contains('uiTarget'));
        expect(findings, contains('backendTarget'));
        expect(findings, contains('persistenceWrite'));
        expect(findings, contains('engineCall'));
        expect(findings, contains('schedulerExecution'));
        expect(findings, contains('stockfishCommandLeak'));
        expect(findings, contains('rawUciLeak'));
        expect(findings, contains('pvDumpLeak'));
        expect(findings, contains('androidCollectorRequired'));
        expect(textFindings, isNotEmpty);
      },
    );

    test(
      'validator rejects quiet promotion PV promotion and Phase 32E proof claims',
      () {
        final validator =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidator();
        final quietFindings = validator.validateRecord(
          _safeContractRecord().copyWith(
            sourceCaseId: 'quiet-preparatory-hard-case',
            contractRole: DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                .internalInputContract,
          ),
          knownCaseIds: const <String>{'quiet-preparatory-hard-case'},
        );
        final pvFindings = validator.validateRecord(
          _safeContractRecord().copyWith(
            sourceCaseId: 'pv-multipv-support-boundary-32e',
            contractRole: DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                .internalInputContract,
          ),
          knownCaseIds: const <String>{'pv-multipv-support-boundary-32e'},
        );
        final proofFindings = validator.validateRecord(
          _safeContractRecord().copyWith(
            sourceCaseId: 'budget-pressure-wide-candidate-32e',
            sourcePhase: 'Phase 32E',
            androidProofCaseIds: const <String>['queen-win-major-swing'],
          ),
          knownCaseIds: const <String>{'budget-pressure-wide-candidate-32e'},
        );

        expect(
          quietFindings,
          contains('quietPreparatoryPromotedToInternalInput'),
        );
        expect(pvFindings, contains('pvMultiPvPromotedBeyondBoundary'));
        expect(proofFindings, contains('phase32ECapturedAndroidProofClaim'));
      },
    );

    test('markdown and JSON reports are deterministic and safe', () {
      final result = _safeContractDesign();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(markdown, contains('## Contract Group Table'));
      expect(markdown, contains('## Contract Record Table'));
      expect(markdown, contains('## Allowed Internal Field Contract'));
      expect(markdown, contains('## Denied Field Contract'));
      expect(markdown, contains('## Android Proof Boundary'));
      expect(decoded['safeForPhase33R'], isTrue);
      expect(
        decoded['phase33RRecommendation'],
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign',
      );
      expect(counts['unsafeCount'], 0);
      expect(markdown, isNot(contains('info depth')));
      expect(markdown, isNot(contains('bestmove e2e4')));
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_contract_design.dart',
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

DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult
_safeContractDesign() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign().evaluate(
    prototypeValidationResult: _safePrototypeValidation(),
  );
}

DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult
_safePrototypeValidation() {
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

DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult
_copyPrototypeValidation(
  DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult
  result, {
  bool? safeForPhase33Q,
  String? recommendation,
}) {
  return DebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesignValidationResult(
    status: result.status,
    sourcePrototypeDesignStatus: result.sourcePrototypeDesignStatus,
    sourcePrototypeDesignSafeForPhase33P:
        result.sourcePrototypeDesignSafeForPhase33P,
    sourcePrototypeDesignRecommendation:
        result.sourcePrototypeDesignRecommendation,
    sourceBoundaryValidationStatus: result.sourceBoundaryValidationStatus,
    checks: result.checks,
    validationRows: result.validationRows,
    reportFindings: result.reportFindings,
    safeForPhase33Q: safeForPhase33Q ?? result.safeForPhase33Q,
    phase33QRecommendation: recommendation ?? result.phase33QRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord _safeContractRecord() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord(
    contractRecordId: 'test-contract-record',
    sourcePrototypeRecordId: 'phase33o-test-record',
    sourceCaseId: 'known-case',
    sourcePhase: 'existing',
    prototypePacketRole: 'analyzerAdapterPrototypeInputPacket',
    contractRole: DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
        .internalInputContract,
    allowedInternalFieldIds: <String>['contractRecordId', 'sourceCaseId'],
    deniedFieldIds: <String>['productLabel', 'rawUci'],
    blockedBoundaryIds: <String>['productOutput'],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    androidProofCaseIds: <String>[],
    ownerProofRequired: false,
    developerOnly: true,
    contractOnly: true,
    analyzerUnwired: true,
    runtimeBlocked: true,
    executablePrototypeBlocked: true,
    activeDeniedFieldIds: <String>[],
    safetyFlags: DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(),
    findings: <String>[],
    recommendation:
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign',
  );
}
