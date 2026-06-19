@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_boundary_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_implementation_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_implementation_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidation', () {
    test('safe default validates implementation design with warnings', () {
      final result = _safeValidation();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationStatus
            .prototypeImplementationDesignValidatedWithWarnings,
      );
      expect(
        result.sourceImplementationDesignStatus,
        'prototypeImplementationDesignReadyWithWarnings',
      );
      expect(result.sourceImplementationDesignSafeForPhase33T, isTrue);
      expect(result.safeForPhase33U, isTrue);
      expect(
        result.phase33URecommendation,
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation',
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
      final first = _safeValidation();
      final second = _safeValidation();

      expect(first.renderJson(), second.renderJson());
      expect(
        first.checks.map((check) => check.checkId.wire),
        containsAll(<String>[
          'consumesSafePrototypeImplementationDesign',
          'implementationDesignGroupsAreDeterministic',
          'implementationDesignRecordsAreDeterministic',
          'futureClassPacketNamesArePresentAndSafe',
          'inputPacketDesignsRemainFutureInternalOnly',
          'contextPacketDesignsRemainContextOnly',
          'warningLimitedPacketDesignsRemainWarningLimited',
          'proofBoundaryPacketDesignsRemainProofBoundaryOnly',
          'excludedGuardDesignsRemainExcluded',
          'mapperValidatorSnapshotRemainMetadataOnly',
          'allowedFieldsRemainInternalMetadataOnly',
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
          'phase33URequirementPresent',
        ]),
      );
    });

    test('validation rows preserve implementation design source fields', () {
      final result = _safeValidation();
      final queenRow = result.validationRows.firstWhere(
        (row) => row.sourceCaseId == 'queen-win-major-swing',
      );

      expect(
        queenRow.sourceImplementationDesignRecordId,
        startsWith('phase33s-phase33r-'),
      );
      expect(queenRow.sourceValidationRowId, startsWith('phase33r-phase33q-'));
      expect(queenRow.sourcePhase, 'existing');
      expect(queenRow.contractRole, 'internalInputContract');
      expect(
        queenRow.implementationDesignRole,
        'implementationInputPacketDesign',
      );
      expect(queenRow.androidProofCaseIds, <String>['queen-win-major-swing']);
      expect(queenRow.ownerProofRequired, isFalse);
      expect(queenRow.findings, isEmpty);
      expect(
        queenRow.recommendation,
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign',
      );
    });

    test(
      'aggregate validation counts preserve implementation design roles',
      () {
        final result = _safeValidation();

        expect(result.totalValidationRows, 34);
        expect(result.inputPacketDesignValidationCount, 8);
        expect(result.contextPacketDesignValidationCount, 3);
        expect(result.warningLimitedPacketDesignValidationCount, 2);
        expect(result.proofBoundaryPacketDesignValidationCount, 1);
        expect(result.excludedGuardPacketDesignValidationCount, 2);
        expect(result.allowedFieldDesignValidationCount, 1);
        expect(result.deniedFieldDesignValidationCount, 5);
        expect(result.mapperDesignValidationCount, 1);
        expect(result.validatorDesignValidationCount, 1);
        expect(result.debugSnapshotDesignValidationCount, 1);
        expect(result.runtimeBlockedValidationCount, 1);
        expect(result.analyzerWiringBlockedValidationCount, 1);
        expect(result.engineBlockedValidationCount, 1);
        expect(result.schedulerBlockedValidationCount, 1);
        expect(result.productAdapterBlockedValidationCount, 1);
        expect(result.savedAnalysisBlockedValidationCount, 1);
        expect(result.futureRequirementValidationCount, 3);
      },
    );

    test('future names and metadata-only fields validate safely', () {
      final result = _safeValidation();
      final mapperRow = result.validationRows.firstWhere(
        (row) => row.implementationDesignRole == 'implementationMapperDesign',
      );
      final allowedRow = result.validationRows.firstWhere(
        (row) =>
            row.implementationDesignRole == 'implementationAllowedFieldDesign',
      );

      expect(
        mapperRow.futureMapperNames,
        contains('DebugOnlyBridgeAnalyzerAdapterPrototypeMapper'),
      );
      expect(
        allowedRow.allowedInternalFieldIds,
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
      expect(result.activeDeniedFieldCount, 0);
      expect(result.thresholdLeakCount, 0);
    });

    test('Phase 32E proof honesty and owner proof remain preserved', () {
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
      expect(result.phase32EProofClaimCount, 0);
      expect(result.unprovenAndroidProofCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('unsafe Phase 33S input blocks validation', () {
      final unsafeDesign = _copyImplementationDesign(
        _safeImplementationDesign(),
        safeForPhase33T: false,
        recommendation:
            'blockedByUnsafeAnalyzerAdapterPrototypeImplementationDesign',
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidation()
              .evaluate(implementationDesignResult: unsafeDesign);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationStatus
            .blockedByUnsafeImplementationDesign,
      );
      expect(result.safeForPhase33U, isFalse);
      expect(result.hasUnsafePolicyViolation, isTrue);
    });

    test('missing future requirement invalidates validation', () {
      final source = _safeImplementationDesign();
      final withoutFuture = _copyImplementationDesign(
        source,
        implementationDesignRecords: source.implementationDesignRecords
            .where(
              (record) =>
                  record.implementationDesignRole !=
                  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                      .phase33TRequirement,
            )
            .toList(growable: false),
      );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidation()
              .evaluate(implementationDesignResult: withoutFuture);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationStatus
            .invalidImplementationDesignValidation,
      );
      expect(result.safeForPhase33U, isFalse);
      expect(
        result.checks
            .firstWhere(
              (check) => check.checkId.wire == 'phase33URequirementPresent',
            )
            .status
            .wire,
        'blocked',
      );
    });

    test(
      'validator rejects labels scores rankings metrics thresholds and product seams',
      () {
        final row =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationValidator()
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

        expect(row.findings, contains('productOutput'));
        expect(row.findings, contains('classifierLabelLeak'));
        expect(row.findings, contains('finalLabelLeak'));
        expect(row.findings, contains('numericScoreLeak'));
        expect(row.findings, contains('aggregateScoreLeak'));
        expect(row.findings, contains('moveRankingLeak'));
        expect(row.findings, contains('officialMetricLeak'));
        expect(row.findings, contains('thresholdLeak'));
        expect(row.findings, contains('productAdapterBehavior'));
        expect(row.findings, contains('savedAnalysisIntegration'));
        expect(row.findings, contains('cpLossLeak'));
        expect(row.findings, contains('winProbabilityLeak'));
      },
    );

    test(
      'validator rejects integration runtime engine scheduler and raw output leaks',
      () {
        final validator =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationValidator();
        final row = validator.validateRecord(
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
      'validator rejects quiet promotion PV promotion proof claims and unsafe future names',
      () {
        final validator =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationValidator();
        final quietRow = validator.validateRecord(
          _safeImplementationRecord().copyWith(
            sourceCaseId: 'quiet-preparatory-hard-case',
            implementationDesignRole:
                DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                    .implementationInputPacketDesign,
          ),
          knownCaseIds: const <String>{'quiet-preparatory-hard-case'},
        );
        final pvRow = validator.validateRecord(
          _safeImplementationRecord().copyWith(
            sourceCaseId: 'pv-multipv-support-boundary-32e',
            implementationDesignRole:
                DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRole
                    .implementationInputPacketDesign,
          ),
          knownCaseIds: const <String>{'pv-multipv-support-boundary-32e'},
        );
        final proofRow = validator.validateRecord(
          _safeImplementationRecord().copyWith(
            sourceCaseId: 'budget-pressure-wide-candidate-32e',
            sourcePhase: 'Phase 32E',
            androidProofCaseIds: const <String>['queen-win-major-swing'],
          ),
          knownCaseIds: const <String>{'budget-pressure-wide-candidate-32e'},
        );
        final nameRow = validator.validateRecord(
          _safeImplementationRecord().copyWith(
            futureClassNames: const <String>['UnsafeRuntimeAdapter'],
          ),
          knownCaseIds: const <String>{'known-case'},
        );

        expect(quietRow.findings, contains('quietPreparatoryPromoted'));
        expect(pvRow.findings, contains('pvMultiPvPromotedBeyondBoundary'));
        expect(
          proofRow.findings,
          contains('phase32ECapturedAndroidProofClaim'),
        );
        expect(nameRow.findings, contains('unknownFutureClassName'));
      },
    );

    test('markdown and JSON validation reports are deterministic and safe', () {
      final result = _safeValidation();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(markdown, contains('## Validation Check Table'));
      expect(markdown, contains('## Implementation Design Group Validation'));
      expect(markdown, contains('## Future Name Validation'));
      expect(
        markdown,
        contains('## Implementation Design Row Validation Table'),
      );
      expect(markdown, contains('## Allowed and Denied Field Validation'));
      expect(markdown, contains('## Blocked Boundary Validation'));
      expect(markdown, contains('## Phase 33U Requirement'));
      expect(decoded['safeForPhase33U'], isTrue);
      expect(
        decoded['phase33URecommendation'],
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation',
      );
      expect(counts['unsafeCount'], 0);
      expect(markdown, isNot(contains('info depth')));
      expect(markdown, isNot(contains('bestmove e2e4')));
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_implementation_design_validation.dart',
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

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult
_safeValidation() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidation()
      .evaluate(implementationDesignResult: _safeImplementationDesign());
}

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult
_safeImplementationDesign() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesign()
      .evaluate();
}

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult
_copyImplementationDesign(
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult result, {
  List<DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignRecord>?
  implementationDesignRecords,
  bool? safeForPhase33T,
  String? recommendation,
}) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignResult(
    status: result.status,
    sourceContractValidationStatus: result.sourceContractValidationStatus,
    sourceContractValidationSafeForPhase33S:
        result.sourceContractValidationSafeForPhase33S,
    sourceContractValidationRecommendation:
        result.sourceContractValidationRecommendation,
    implementationDesignGroups: result.implementationDesignGroups,
    implementationDesignRecords:
        implementationDesignRecords ?? result.implementationDesignRecords,
    reportFindings: result.reportFindings,
    safeForPhase33T: safeForPhase33T ?? result.safeForPhase33T,
    phase33TRecommendation: recommendation ?? result.phase33TRecommendation,
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
