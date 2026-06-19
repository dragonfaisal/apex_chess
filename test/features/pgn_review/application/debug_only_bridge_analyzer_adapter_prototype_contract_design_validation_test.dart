@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_prototype_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_contract_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_contract_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_diagnostic_command.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidation', () {
    test('safe default validates contract design with warnings', () {
      final result = _safeContractValidation();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationStatus
            .prototypeContractDesignValidatedWithWarnings,
      );
      expect(
        result.sourceContractDesignStatus,
        'prototypeContractDesignReadyWithWarnings',
      );
      expect(result.sourceContractDesignSafeForPhase33R, isTrue);
      expect(result.safeForPhase33S, isTrue);
      expect(
        result.phase33SRecommendation,
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign',
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

    test('validation checks are deterministic and complete', () {
      final first = _safeContractValidation();
      final second = _safeContractValidation();

      expect(first.renderJson(), second.renderJson());
      expect(
        first.checks.map((check) => check.checkId.wire),
        containsAll(<String>[
          'consumesSafePrototypeContractDesign',
          'contractGroupsAreDeterministic',
          'contractRecordsAreDeterministic',
          'internalInputContractsRemainFutureInternalOnly',
          'contextOnlyContractsRemainContextOnly',
          'warningLimitedContractsRemainWarningLimited',
          'proofBoundaryContractsRemainProofBoundaryOnly',
          'quietPreparatoryRemainsExcludedGuard',
          'allowedInternalFieldsRemainMetadataOnly',
          'deniedFieldsRemainInactive',
          'phase32ECasesDoNotClaimCapturedAndroidProof',
          'androidProofIdsRemainCapturedOnly',
          'ownerProofQueueRemainsEmpty',
          'analyzerWiringRemainsBlocked',
          'runtimeExecutablePrototypeRemainBlocked',
          'engineSchedulerUiBackendPersistenceRemainBlocked',
          'productAdapterSavedAnalysisRemainBlocked',
          'noLabelsScoresRankingsMetrics',
          'noCpLossOrWinProbability',
          'thresholdsRemainDenied',
          'noStockfishCommandRawUciPvDump',
          'reportContainsNoRawUciOrPvDump',
          'phase33SRequirementPresent',
        ]),
      );
    });

    test('validation rows preserve contract source fields', () {
      final result = _safeContractValidation();
      final queenRow = result.validationRows.firstWhere(
        (row) => row.sourceCaseId == 'queen-win-major-swing',
      );

      expect(
        queenRow.sourceContractRecordId,
        startsWith('phase33q-phase33p-phase33o-'),
      );
      expect(queenRow.sourcePrototypeRecordId, startsWith('phase33o-'));
      expect(queenRow.sourcePhase, 'existing');
      expect(
        queenRow.prototypePacketRole,
        'analyzerAdapterPrototypeInputPacket',
      );
      expect(queenRow.contractRole, 'internalInputContract');
      expect(queenRow.androidProofCaseIds, <String>['queen-win-major-swing']);
      expect(queenRow.ownerProofRequired, isFalse);
      expect(queenRow.findings, isEmpty);
      expect(
        queenRow.recommendation,
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeContractDesign',
      );
    });

    test('aggregate validation counts preserve contract groups', () {
      final result = _safeContractValidation();

      expect(result.totalValidationRows, 28);
      expect(result.internalInputContractValidationCount, 8);
      expect(result.contextOnlyContractValidationCount, 3);
      expect(result.warningLimitedContractValidationCount, 2);
      expect(result.proofBoundaryContractValidationCount, 1);
      expect(result.excludedGuardContractValidationCount, 2);
      expect(result.deniedFieldContractValidationCount, 5);
      expect(result.allowedInternalFieldContractValidationCount, 1);
      expect(result.runtimeBlockedContractValidationCount, 1);
      expect(result.analyzerWiringBlockedContractValidationCount, 1);
      expect(result.engineBlockedContractValidationCount, 1);
      expect(result.schedulerBlockedContractValidationCount, 1);
      expect(result.futureRequirementContractValidationCount, 2);
    });

    test('allowed and denied field validation remains metadata-only', () {
      final result = _safeContractValidation();
      final allowedRow = result.validationRows.firstWhere(
        (row) => row.contractRole == 'allowedInternalFieldContract',
      );
      final deniedRow = result.validationRows.firstWhere(
        (row) => row.contractRole == 'deniedFieldContract',
      );

      expect(
        allowedRow.allowedInternalFieldIds,
        containsAll(<String>[
          'contractRecordId',
          'sourcePrototypeRecordId',
          'sourceCaseId',
          'sourcePhase',
          'prototypePacketRole',
          'contractRole',
          'warningReasons',
          'proofLimitReasons',
          'androidProofBoundaryIds',
          'blockedBoundaryIds',
        ]),
      );
      expect(
        deniedRow.deniedFieldIds,
        containsAll(<String>[
          'productLabel',
          'finalMoveLabel',
          'classifierLabel',
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
        ]),
      );
      expect(result.activeDeniedFieldCount, 0);
      expect(result.thresholdLeakCount, 0);
    });

    test('Phase 32E proof honesty and owner proof remain preserved', () {
      final result = _safeContractValidation();
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
      expect(result.phase32EProofClaimCount, 0);
      expect(result.unprovenAndroidProofCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('unsafe Phase 33Q input blocks validation', () {
      final unsafeContract = _copyContractDesign(
        _safeContractDesign(),
        safeForPhase33R: false,
        recommendation: 'blockedByUnsafeAnalyzerAdapterPrototypeContractDesign',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidation()
              .evaluate(contractDesignResult: unsafeContract);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationStatus
            .blockedByUnsafeContractDesign,
      );
      expect(result.safeForPhase33S, isFalse);
      expect(result.hasUnsafePolicyViolation, isTrue);
    });

    test('missing future requirement invalidates validation', () {
      final source = _safeContractDesign();
      final withoutFuture = _copyContractDesign(
        source,
        contractRecords: source.contractRecords
            .where(
              (record) =>
                  record.contractRole !=
                  DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                      .futureRequirementContract,
            )
            .toList(growable: false),
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidation()
              .evaluate(contractDesignResult: withoutFuture);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationStatus
            .invalidContractDesignValidation,
      );
      expect(result.safeForPhase33S, isFalse);
      expect(
        result.checks
            .firstWhere(
              (check) => check.checkId.wire == 'phase33SRequirementPresent',
            )
            .status
            .wire,
        'blocked',
      );
    });

    test(
      'validator rejects labels scores rankings metrics thresholds and product seams',
      () {
        final findings =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationValidator()
                .validateRecord(
                  _safeContractRecord().copyWith(
                    activeDeniedFieldIds: const <String>[
                      'thresholds',
                      'productAdapterBehavior',
                      'savedAnalysisIntegration',
                    ],
                    safetyFlags:
                        const DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(
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
                  ),
                  knownCaseIds: const <String>{'known-case'},
                )
                .findings;

        expect(findings, contains('productOutput'));
        expect(findings, contains('classifierLabelLeak'));
        expect(findings, contains('finalLabelLeak'));
        expect(findings, contains('numericScoreLeak'));
        expect(findings, contains('aggregateScoreLeak'));
        expect(findings, contains('moveRankingLeak'));
        expect(findings, contains('officialMetricLeak'));
        expect(findings, contains('thresholdLeak'));
        expect(findings, contains('productAdapterBehavior'));
        expect(findings, contains('savedAnalysisIntegration'));
        expect(findings, contains('cpLossLeak'));
        expect(findings, contains('winProbabilityLeak'));
      },
    );

    test(
      'validator rejects integration runtime engine scheduler and raw output leaks',
      () {
        final validator =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationValidator();
        final row = validator.validateRecord(
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
          'uciok info depth 1 pv e2e4 bestmove e2e4',
        );

        expect(row.findings, contains('analyzerWiringEnabled'));
        expect(row.findings, contains('runtimeImplementation'));
        expect(row.findings, contains('executablePrototypeImplementation'));
        expect(row.findings, contains('activeDeniedField'));
        expect(row.findings, contains('uiTarget'));
        expect(row.findings, contains('backendTarget'));
        expect(row.findings, contains('persistenceWrite'));
        expect(row.findings, contains('engineCall'));
        expect(row.findings, contains('schedulerExecution'));
        expect(row.findings, contains('stockfishCommandLeak'));
        expect(row.findings, contains('rawUciLeak'));
        expect(row.findings, contains('pvDumpLeak'));
        expect(row.findings, contains('androidCollectorRequired'));
        expect(textFindings, isNotEmpty);
      },
    );

    test(
      'validator rejects quiet promotion PV promotion and Phase 32E proof claims',
      () {
        final validator =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationValidator();
        final quietRow = validator.validateRecord(
          _safeContractRecord().copyWith(
            sourceCaseId: 'quiet-preparatory-hard-case',
            contractRole: DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                .internalInputContract,
          ),
          knownCaseIds: const <String>{'quiet-preparatory-hard-case'},
        );
        final pvRow = validator.validateRecord(
          _safeContractRecord().copyWith(
            sourceCaseId: 'pv-multipv-support-boundary-32e',
            contractRole: DebugOnlyBridgeAnalyzerAdapterPrototypeContractRole
                .internalInputContract,
          ),
          knownCaseIds: const <String>{'pv-multipv-support-boundary-32e'},
        );
        final proofRow = validator.validateRecord(
          _safeContractRecord().copyWith(
            sourceCaseId: 'budget-pressure-wide-candidate-32e',
            sourcePhase: 'Phase 32E',
            androidProofCaseIds: const <String>['queen-win-major-swing'],
          ),
          knownCaseIds: const <String>{'budget-pressure-wide-candidate-32e'},
        );

        expect(
          quietRow.findings,
          contains('quietPreparatoryPromotedToInternalInput'),
        );
        expect(pvRow.findings, contains('pvMultiPvPromotedBeyondBoundary'));
        expect(
          proofRow.findings,
          contains('phase32ECapturedAndroidProofClaim'),
        );
      },
    );

    test('markdown and JSON reports are deterministic and safe', () {
      final result = _safeContractValidation();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(markdown, contains('## Validation Check Table'));
      expect(markdown, contains('## Contract Group Validation'));
      expect(markdown, contains('## Contract Record Validation Table'));
      expect(markdown, contains('## Allowed and Denied Field Validation'));
      expect(markdown, contains('## Blocked Boundary Validation'));
      expect(markdown, contains('## Android Proof Boundary'));
      expect(decoded['safeForPhase33S'], isTrue);
      expect(
        decoded['phase33SRecommendation'],
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign',
      );
      expect(counts['unsafeCount'], 0);
      expect(markdown, isNot(contains('info depth')));
      expect(markdown, isNot(contains('bestmove e2e4')));
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_contract_design_validation.dart',
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

DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationResult
_safeContractValidation() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidation()
      .evaluate(contractDesignResult: _safeContractDesign());
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

DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult _copyContractDesign(
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult result, {
  List<DebugOnlyBridgeAnalyzerAdapterPrototypeContractRecord>? contractRecords,
  bool? safeForPhase33R,
  String? recommendation,
}) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignResult(
    status: result.status,
    sourcePrototypeValidationStatus: result.sourcePrototypeValidationStatus,
    sourcePrototypeValidationSafeForPhase33Q:
        result.sourcePrototypeValidationSafeForPhase33Q,
    sourcePrototypeValidationRecommendation:
        result.sourcePrototypeValidationRecommendation,
    contractGroups: result.contractGroups,
    contractRecords: contractRecords ?? result.contractRecords,
    reportFindings: result.reportFindings,
    safeForPhase33R: safeForPhase33R ?? result.safeForPhase33R,
    phase33RRecommendation: recommendation ?? result.phase33RRecommendation,
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
    deniedFieldIds: <String>[
      'productLabel',
      'thresholds',
      'stockfishCommand',
      'rawUci',
      'pvDump',
    ],
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
