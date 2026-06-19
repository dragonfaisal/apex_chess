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
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_implementation_design.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_diagnostic_command.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign', () {
    test('safe default implementation design is ready with warnings', () {
      final result = _safeImplementationDesign();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignStatus
            .prototypeImplementationDesignReadyWithWarnings,
      );
      expect(
        result.sourceContractValidationStatus,
        'prototypeContractDesignValidatedWithWarnings',
      );
      expect(result.sourceContractValidationSafeForPhase33S, isTrue);
      expect(result.safeForPhase33T, isTrue);
      expect(
        result.phase33TRecommendation,
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign',
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

    test('implementation design groups are deterministic and complete', () {
      final first = _safeImplementationDesign();
      final second = _safeImplementationDesign();

      expect(first.renderJson(), second.renderJson());
      expect(first.totalImplementationDesignGroups, 17);
      expect(
        first.implementationDesignGroups.map((group) => group.groupId.wire),
        containsAll(<String>[
          'implementationInputPacketDesignGroup',
          'implementationContextPacketDesignGroup',
          'implementationWarningLimitedPacketDesignGroup',
          'implementationProofBoundaryPacketDesignGroup',
          'implementationExcludedGuardPacketDesignGroup',
          'implementationAllowedFieldDesignGroup',
          'implementationDeniedFieldDesignGroup',
          'implementationMapperDesignGroup',
          'implementationValidatorDesignGroup',
          'implementationDebugSnapshotDesignGroup',
          'implementationRuntimeBlockedGroup',
          'implementationAnalyzerWiringBlockedGroup',
          'implementationEngineBlockedGroup',
          'implementationSchedulerBlockedGroup',
          'implementationProductAdapterBlockedGroup',
          'implementationSavedAnalysisBlockedGroup',
          'phase33TRequirementGroup',
        ]),
      );
    });

    test('contract roles map to implementation design roles', () {
      final result = _safeImplementationDesign();
      final recordsByCaseId = {
        for (final record in result.implementationDesignRecords)
          record.sourceCaseId: record,
      };

      expect(
        recordsByCaseId['queen-win-major-swing']!.implementationDesignRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationInputPacketDesign,
      );
      expect(
        recordsByCaseId['endgame-precision-candidate-spread-32e']!
            .implementationDesignRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationContextPacketDesign,
      );
      expect(
        recordsByCaseId['budget-pressure-wide-candidate-32e']!
            .implementationDesignRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationWarningLimitedPacketDesign,
      );
      expect(
        recordsByCaseId['pv-multipv-support-boundary-32e']!
            .implementationDesignRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationProofBoundaryPacketDesign,
      );
      expect(
        recordsByCaseId['quiet-preparatory-hard-case']!
            .implementationDesignRole,
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationExcludedGuardPacketDesign,
      );
    });

    test('aggregate counts preserve implementation design surfaces', () {
      final result = _safeImplementationDesign();

      expect(result.totalImplementationDesignRecords, 34);
      expect(result.inputPacketDesignCount, 8);
      expect(result.contextPacketDesignCount, 3);
      expect(result.warningLimitedPacketDesignCount, 2);
      expect(result.proofBoundaryPacketDesignCount, 1);
      expect(result.excludedGuardPacketDesignCount, 2);
      expect(result.allowedFieldDesignCount, 1);
      expect(result.deniedFieldDesignCount, 5);
      expect(result.mapperDesignCount, 1);
      expect(result.validatorDesignCount, 1);
      expect(result.debugSnapshotDesignCount, 1);
      expect(result.runtimeBlockedCount, 1);
      expect(result.analyzerWiringBlockedCount, 1);
      expect(result.engineBlockedCount, 1);
      expect(result.schedulerBlockedCount, 1);
      expect(result.productAdapterBlockedCount, 1);
      expect(result.savedAnalysisBlockedCount, 1);
      expect(result.futureRequirementCount, 3);
    });

    test(
      'future class packet mapper validator and snapshot names are explicit',
      () {
        final result = _safeImplementationDesign();

        expect(
          result.proposedClassNames,
          containsAll(<String>[
            'DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket',
            'DebugOnlyBridgeAnalyzerAdapterPrototypeContextPacket',
            'DebugOnlyBridgeAnalyzerAdapterPrototypeRecord',
            'DebugOnlyBridgeAnalyzerAdapterPrototypePolicy',
            'DebugOnlyBridgeAnalyzerAdapterPrototypeMapper',
            'DebugOnlyBridgeAnalyzerAdapterPrototypeResult',
            'DebugOnlyBridgeAnalyzerAdapterPrototypeValidator',
            'DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot',
          ]),
        );
        expect(
          result.proposedPacketNames,
          containsAll(<String>[
            'DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket',
            'DebugOnlyBridgeAnalyzerAdapterPrototypeContextPacket',
            'DebugOnlyBridgeAnalyzerAdapterPrototypeRecord',
            'DebugOnlyBridgeAnalyzerAdapterPrototypePolicy',
          ]),
        );
        expect(
          result.proposedMapperNames,
          contains('DebugOnlyBridgeAnalyzerAdapterPrototypeMapper'),
        );
        expect(
          result.proposedValidatorNames,
          contains('DebugOnlyBridgeAnalyzerAdapterPrototypeValidator'),
        );
        expect(
          result.proposedDebugSnapshotNames,
          contains('DebugOnlyBridgeAnalyzerAdapterPrototypeDebugSnapshot'),
        );
      },
    );

    test('allowed and denied field design stays explicit', () {
      final result = _safeImplementationDesign();
      final allowedRecord = result.implementationDesignRecords.firstWhere(
        (record) =>
            record.implementationDesignRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .implementationAllowedFieldDesign,
      );
      final deniedRecord = result.implementationDesignRecords.firstWhere(
        (record) =>
            record.implementationDesignRole ==
            DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                .implementationDeniedFieldDesign,
      );

      expect(
        allowedRecord.allowedInternalFieldIds,
        containsAll(<String>[
          'implementationDesignRecordId',
          'sourceValidationRowId',
          'sourceContractRecordId',
          'sourcePrototypeRecordId',
          'sourceCaseId',
          'sourcePhase',
          'prototypePacketRole',
          'contractRole',
          'implementationDesignRole',
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
          'productAdapterBehavior',
          'savedAnalysisIntegration',
        ]),
      );
    });

    test('Phase 32E proof honesty and owner proof remain preserved', () {
      final result = _safeImplementationDesign();
      final phase32ERecords = result.implementationDesignRecords.where(
        (record) => record.sourcePhase == 'Phase 32E',
      );
      final proofIds = result.implementationDesignRecords
          .map((record) => record.androidProofCaseIds)
          .expand((ids) => ids)
          .toSet();

      expect(phase32ERecords, isNotEmpty);
      for (final record in phase32ERecords) {
        expect(record.androidProofCaseIds, isEmpty);
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

    test('unsafe Phase 33R input blocks implementation design', () {
      final unsafeValidation = _copyContractValidation(
        _safeContractValidation(),
        safeForPhase33S: false,
        recommendation:
            'blockedByUnsafeAnalyzerAdapterPrototypeContractDesignValidation',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign()
              .evaluate(contractValidationResult: unsafeValidation);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignStatus
            .blockedByUnsafeContractValidation,
      );
      expect(result.safeForPhase33T, isFalse);
      expect(result.hasUnsafePolicyViolation, isTrue);
    });

    test(
      'validator rejects labels scores rankings metrics thresholds and product seams',
      () {
        final findings =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidator()
                .validateRecord(
                  _safeImplementationRecord().copyWith(
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
                );

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
            const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidator();
        final findings = validator.validateRecord(
          _safeImplementationRecord().copyWith(
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
            const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidator();
        final quietFindings = validator.validateRecord(
          _safeImplementationRecord().copyWith(
            sourceCaseId: 'quiet-preparatory-hard-case',
            implementationDesignRole:
                DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                    .implementationInputPacketDesign,
          ),
          knownCaseIds: const <String>{'quiet-preparatory-hard-case'},
        );
        final pvFindings = validator.validateRecord(
          _safeImplementationRecord().copyWith(
            sourceCaseId: 'pv-multipv-support-boundary-32e',
            implementationDesignRole:
                DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                    .implementationInputPacketDesign,
          ),
          knownCaseIds: const <String>{'pv-multipv-support-boundary-32e'},
        );
        final proofFindings = validator.validateRecord(
          _safeImplementationRecord().copyWith(
            sourceCaseId: 'budget-pressure-wide-candidate-32e',
            sourcePhase: 'Phase 32E',
            androidProofCaseIds: const <String>['queen-win-major-swing'],
          ),
          knownCaseIds: const <String>{'budget-pressure-wide-candidate-32e'},
        );

        expect(quietFindings, contains('quietPreparatoryPromoted'));
        expect(pvFindings, contains('pvMultiPvPromotedBeyondBoundary'));
        expect(proofFindings, contains('phase32ECapturedAndroidProofClaim'));
      },
    );

    test('future requirement seam is enforced', () {
      final findings =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidator()
              .validateRecord(
                _safeImplementationRecord().copyWith(
                  implementationDesignRole:
                      DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                          .phase33TRequirement,
                  recommendation: 'wrongNextStep',
                ),
                knownCaseIds: const <String>{'known-case'},
              );

      expect(findings, contains('missingPhase33TRequirement'));
    });

    test('markdown and JSON reports are deterministic and safe', () {
      final result = _safeImplementationDesign();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;
      final futureNames = decoded['futureNames'] as Map<String, Object?>;

      expect(markdown, contains('## Implementation Design Group Table'));
      expect(markdown, contains('## Future Prototype Names'));
      expect(markdown, contains('## Implementation Design Record Table'));
      expect(markdown, contains('## Allowed and Denied Field Design'));
      expect(markdown, contains('## Mapper Validator Snapshot Design'));
      expect(markdown, contains('## Blocked Boundary Design'));
      expect(markdown, contains('## Phase 33T Requirement'));
      expect(decoded['safeForPhase33T'], isTrue);
      expect(
        decoded['phase33TRecommendation'],
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign',
      );
      expect(counts['unsafeCount'], 0);
      expect(futureNames['classNames'], isA<List<Object?>>());
      expect(markdown, isNot(contains('info depth')));
      expect(markdown, isNot(contains('bestmove e2e4')));
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_implementation_design.dart',
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

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult
_safeImplementationDesign() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign()
      .evaluate(contractValidationResult: _safeContractValidation());
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

DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationResult
_copyContractValidation(
  DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationResult
  result, {
  bool? safeForPhase33S,
  String? recommendation,
}) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeContractDesignValidationResult(
    status: result.status,
    sourceContractDesignStatus: result.sourceContractDesignStatus,
    sourceContractDesignSafeForPhase33R:
        result.sourceContractDesignSafeForPhase33R,
    sourceContractDesignRecommendation:
        result.sourceContractDesignRecommendation,
    checks: result.checks,
    validationRows: result.validationRows,
    reportFindings: result.reportFindings,
    safeForPhase33S: safeForPhase33S ?? result.safeForPhase33S,
    phase33SRecommendation: recommendation ?? result.phase33SRecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord
_safeImplementationRecord() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord(
    implementationDesignRecordId: 'test-implementation-design-record',
    sourceValidationRowId: 'phase33r-test-row',
    sourceContractRecordId: 'phase33q-test-record',
    sourcePrototypeRecordId: 'phase33o-test-record',
    sourceCaseId: 'known-case',
    sourcePhase: 'existing',
    prototypePacketRole: 'analyzerAdapterPrototypeInputPacket',
    contractRole: 'internalInputContract',
    implementationDesignRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
            .implementationInputPacketDesign,
    allowedInternalFieldIds: <String>[
      'implementationDesignRecordId',
      'sourceCaseId',
    ],
    deniedFieldIds: <String>[
      'productLabel',
      'thresholds',
      'stockfishCommand',
      'rawUci',
      'pvDump',
      'productAdapterBehavior',
      'savedAnalysisIntegration',
    ],
    blockedBoundaryIds: <String>['productOutput'],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    androidProofCaseIds: <String>[],
    ownerProofRequired: false,
    developerOnly: true,
    designOnly: true,
    analyzerUnwired: true,
    runtimeBlocked: true,
    executablePrototypeBlocked: true,
    futureClassNames: <String>[
      'DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket',
    ],
    futurePacketNames: <String>[
      'DebugOnlyBridgeAnalyzerAdapterPrototypeInputPacket',
    ],
    futureMapperNames: <String>[],
    futureValidatorNames: <String>[],
    futureDebugSnapshotNames: <String>[],
    activeDeniedFieldIds: <String>[],
    safetyFlags: DebugOnlyBridgeAnalyzerAdapterBoundarySafetyFlags(),
    findings: <String>[],
    recommendation:
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign',
  );
}
