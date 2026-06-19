@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_implementation_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_skeleton.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeSkeleton', () {
    test('safe default skeleton is ready with warnings', () {
      final result = _safeResult();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
            .prototypeSkeletonReadyWithWarnings,
      );
      expect(
        result.sourceValidationStatus,
        'prototypeImplementationDesignValidatedWithWarnings',
      );
      expect(result.sourceValidationSafeForPhase33U, isTrue);
      expect(result.safeForPhase33V, isTrue);
      expect(
        result.phase33VRecommendation,
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation',
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

    test('input and context packets remain in-memory and developer-only', () {
      final result = _safeResult();

      expect(
        result.inputPacket.inputPacketId,
        'phase33u-analyzer-adapter-prototype-input-packet',
      );
      expect(
        result.contextPacket.contextPacketId,
        'phase33u-analyzer-adapter-prototype-context-packet',
      );
      expect(result.inputPacket.developerOnly, isTrue);
      expect(result.inputPacket.inMemoryOnly, isTrue);
      expect(result.inputPacket.analyzerUnwired, isTrue);
      expect(result.contextPacket.contextOnly, isTrue);
      expect(result.inputPacket.hasUnsafeInput, isFalse);
      expect(result.inputPacket.allowedFieldIds, contains('recordRole'));
      expect(result.inputPacket.allowedFieldIds, isNot(contains('rawUci')));
      expect(result.inputPacket.deniedFieldIds, contains('productLabel'));
      expect(result.inputPacket.deniedFieldIds, contains('stockfishCommand'));
    });

    test(
      'record role counts preserve Phase 33T implementation design rows',
      () {
        final result = _safeResult();

        expect(result.totalRecords, 34);
        expect(result.internalInputRecordCount, 8);
        expect(result.contextOnlyRecordCount, 3);
        expect(result.warningLimitedRecordCount, 2);
        expect(result.proofBoundaryRecordCount, 1);
        expect(result.excludedGuardRecordCount, 2);
        expect(result.allowedFieldBoundaryRecordCount, 1);
        expect(result.deniedFieldBoundaryRecordCount, 5);
        expect(result.mapperMetadataRecordCount, 1);
        expect(result.validatorMetadataRecordCount, 1);
        expect(result.debugSnapshotMetadataRecordCount, 1);
        expect(result.runtimeBlockedRecordCount, 1);
        expect(result.analyzerWiringBlockedRecordCount, 1);
        expect(result.engineBlockedRecordCount, 1);
        expect(result.schedulerBlockedRecordCount, 1);
        expect(result.productAdapterBlockedRecordCount, 1);
        expect(result.savedAnalysisBlockedRecordCount, 1);
        expect(result.futureRequirementRecordCount, 3);
      },
    );

    test(
      'records map input context warning proof and excluded roles safely',
      () {
        final result = _safeResult();

        expect(
          result
              .recordForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
                    .internalInputRecord,
              )
              .inMemoryOnly,
          isTrue,
        );
        expect(
          result
              .recordForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
                    .contextOnlyRecord,
              )
              .contextOnly,
          isTrue,
        );
        expect(
          result
              .recordForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
                    .warningLimitedRecord,
              )
              .warningLimited,
          isTrue,
        );
        expect(
          result
              .recordForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
                    .proofBoundaryRecord,
              )
              .proofBoundaryOnly,
          isTrue,
        );
        expect(
          result
              .recordForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
                    .excludedGuardRecord,
              )
              .excludedGuard,
          isTrue,
        );
        expect(
          result
              .recordForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
                    .deniedFieldBoundaryRecord,
              )
              .inactive,
          isTrue,
        );
      },
    );

    test('policy safe default keeps every blocked capability disabled', () {
      final policy = _safeResult().policy;

      expect(policy.hasUnsafeAllowance, isFalse);
      expect(policy.allowsProductOutput, isFalse);
      expect(policy.allowsAnalyzerWiring, isFalse);
      expect(policy.allowsRuntimeImplementation, isFalse);
      expect(policy.allowsExecutablePrototype, isFalse);
      expect(policy.allowsEngineCalls, isFalse);
      expect(policy.allowsSchedulerExecution, isFalse);
      expect(policy.allowsPersistenceWrites, isFalse);
      expect(policy.allowsUiTargets, isFalse);
      expect(policy.allowsBackendTargets, isFalse);
      expect(policy.allowsProductAdapter, isFalse);
      expect(policy.allowsSavedAnalysisIntegration, isFalse);
      expect(policy.allowsClassifierLabels, isFalse);
      expect(policy.allowsFinalLabels, isFalse);
      expect(policy.allowsNumericScores, isFalse);
      expect(policy.allowsAggregateScores, isFalse);
      expect(policy.allowsOfficialMetrics, isFalse);
      expect(policy.allowsCpLoss, isFalse);
      expect(policy.allowsWinProbability, isFalse);
      expect(policy.allowsMoveRanking, isFalse);
      expect(policy.allowsStockfishCommand, isFalse);
      expect(policy.allowsRawUci, isFalse);
      expect(policy.allowsPvDump, isFalse);
      expect(policy.allowsAndroidCollector, isFalse);
    });

    test('Phase 32E proof honesty and owner proof remain preserved', () {
      final result = _safeResult();
      final phase32ERecords = result.records.where(
        (record) => record.sourcePhase == 'Phase 32E',
      );
      final proofIds = result.records
          .map((record) => record.androidProofCaseIds)
          .expand((ids) => ids)
          .toSet();

      expect(phase32ERecords, isNotEmpty);
      for (final record in phase32ERecords) {
        expect(record.androidProofCaseIds, isEmpty, reason: record.recordId);
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

    test('unsafe Phase 33T input blocks skeleton', () {
      final unsafeValidation = _copyValidation(
        _safeValidation(),
        safeForPhase33U: false,
        recommendation:
            'blockedByUnsafeAnalyzerAdapterPrototypeImplementationDesignValidation',
      );
      final result = const DebugOnlyBridgeAnalyzerAdapterPrototypeMapper()
          .evaluate(validationResult: unsafeValidation);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
            .blockedByUnsafeImplementationDesignValidation,
      );
      expect(result.safeForPhase33V, isFalse);
      expect(result.hasUnsafePolicyViolation, isTrue);
    });

    test(
      'validator rejects labels scores rankings metrics thresholds and product seams',
      () {
        final validator =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeValidator();
        final findings = validator.validateRecord(
          _safeRecord().copyWith(
            activeDeniedFieldIds: const <String>[
              'thresholds',
              'productAdapterBehavior',
              'savedAnalysisIntegration',
            ],
            safetyFlags: const <String, bool>{
              'isProductOutput': true,
              'isClassifierLabel': true,
              'hasNumericScore': true,
              'hasAggregateScore': true,
              'ranksMoves': true,
              'isOfficialMetric': true,
              'exposesCpLoss': true,
              'exposesWinProbability': true,
            },
          ),
        );

        expect(findings, contains('productOutput'));
        expect(findings, contains('classifierLabelLeak'));
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
      'validator rejects integration runtime engine scheduler and raw leaks',
      () {
        final validator =
            const DebugOnlyBridgeAnalyzerAdapterPrototypeValidator();
        final findings = validator.validateRecord(
          _safeRecord().copyWith(
            analyzerUnwired: false,
            activeDeniedFieldIds: const <String>['rawUci'],
            safetyFlags: const <String, bool>{
              'targetsUi': true,
              'targetsBackend': true,
              'writesPersistence': true,
              'callsEngine': true,
              'executesScheduler': true,
              'wiresAnalyzer': true,
              'implementsRuntime': true,
              'implementsExecutablePrototype': true,
              'exposesStockfishCommand': true,
              'exposesRawUci': true,
              'exposesPvDump': true,
              'requiresAndroidCollector': true,
            },
          ),
        );
        final textFindings = validator.validateReportText(
          'uciok info depth 1 pv e2e4 bestmove e2e4',
        );

        expect(findings, contains('analyzerWiringEnabled'));
        expect(findings, contains('activeDeniedField'));
        expect(findings, contains('uiTarget'));
        expect(findings, contains('backendTarget'));
        expect(findings, contains('persistenceWrite'));
        expect(findings, contains('engineCall'));
        expect(findings, contains('schedulerExecution'));
        expect(findings, contains('analyzerWiring'));
        expect(findings, contains('runtimeImplementation'));
        expect(findings, contains('executablePrototypeImplementation'));
        expect(findings, contains('stockfishCommandLeak'));
        expect(findings, contains('rawUciLeak'));
        expect(findings, contains('pvDumpLeak'));
        expect(findings, contains('androidCollectorRequired'));
        expect(textFindings, isNotEmpty);
      },
    );

    test('validator rejects quiet promotion PV promotion and proof claims', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeValidator();
      final quietFindings = validator.validateRecord(
        _safeRecord().copyWith(
          sourceCaseId: 'quiet-preparatory-hard-case',
          role: DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
              .internalInputRecord,
        ),
      );
      final pvFindings = validator.validateRecord(
        _safeRecord().copyWith(
          sourceCaseId: 'pv-multipv-support-boundary-32e',
          role: DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole
              .internalInputRecord,
        ),
      );
      final proofFindings = validator.validateRecord(
        _safeRecord().copyWith(
          sourceCaseId: 'budget-pressure-wide-candidate-32e',
          sourcePhase: 'Phase 32E',
          androidProofCaseIds: const <String>['queen-win-major-swing'],
        ),
      );

      expect(quietFindings, contains('quietPreparatoryPromoted'));
      expect(pvFindings, contains('pvMultiPvPromotedBeyondBoundary'));
      expect(proofFindings, contains('phase32ECapturedAndroidProofClaim'));
    });

    test('markdown and JSON reports are deterministic and safe', () {
      final result = _safeResult();
      final markdown = result.renderMarkdown();
      final decoded = jsonDecode(result.renderJson()) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(markdown, contains('## Packet Summary'));
      expect(markdown, contains('## Policy Summary'));
      expect(markdown, contains('## Record Role Summary'));
      expect(markdown, contains('## Prototype Record Table'));
      expect(markdown, contains('## Proof Boundary Summary'));
      expect(markdown, contains('## Denied Field Summary'));
      expect(
        markdown,
        contains('## Runtime Analyzer Engine Scheduler Product Block Summary'),
      );
      expect(markdown, contains('## Debug Snapshot Summary'));
      expect(decoded['safeForPhase33V'], isTrue);
      expect(
        decoded['phase33VRecommendation'],
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation',
      );
      expect(counts['unsafeCount'], 0);
      _expectReportGuardrails(markdown);
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_skeleton.dart',
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

DebugOnlyBridgeAnalyzerAdapterPrototypeResult _safeResult() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeMapper().evaluate();
}

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult
_safeValidation() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidation()
      .evaluate();
}

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult
_copyValidation(
  DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult
  result, {
  bool? safeForPhase33U,
  String? recommendation,
}) {
  return DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult(
    status: result.status,
    sourceImplementationDesignStatus: result.sourceImplementationDesignStatus,
    sourceImplementationDesignSafeForPhase33T:
        result.sourceImplementationDesignSafeForPhase33T,
    sourceImplementationDesignRecommendation:
        result.sourceImplementationDesignRecommendation,
    checks: result.checks,
    validationRows: result.validationRows,
    reportFindings: result.reportFindings,
    safeForPhase33U: safeForPhase33U ?? result.safeForPhase33U,
    phase33URecommendation: recommendation ?? result.phase33URecommendation,
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeRecord _safeRecord() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeRecord(
    recordId: 'test-record',
    role: DebugOnlyBridgeAnalyzerAdapterPrototypeRecordRole.internalInputRecord,
    sourceValidationRowId: 'phase33t-test',
    sourceImplementationDesignRecordId: 'phase33s-test',
    sourceCaseId: 'known-case',
    sourcePhase: 'existing',
    implementationDesignRole: 'implementationInputPacketDesign',
    developerOnly: true,
    inMemoryOnly: true,
    analyzerUnwired: true,
    contextOnly: false,
    warningLimited: false,
    proofBoundaryOnly: false,
    excludedGuard: false,
    inactive: false,
    allowedFieldIds: <String>['recordRole', 'sourceCaseId'],
    deniedFieldIds: <String>[
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
    ],
    blockedBoundaryIds: <String>['productOutput'],
    warningReasons: <String>[],
    proofLimitReasons: <String>[],
    androidProofCaseIds: <String>[],
    ownerProofRequired: false,
    activeDeniedFieldIds: <String>[],
    safetyFlags: <String, bool>{},
    findings: <String>[],
    recommendation:
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation',
  );
}

void _expectReportGuardrails(String report) {
  for (final token in const <String>[
    'uciok',
    'readyok',
    'info depth',
    'bestmove e2e4',
    'pv e2e4',
    'active fields: productLabel',
    'numeric move score:',
    'ACPL active',
    'official accuracy active',
    'cpLoss active',
    'winProbability active',
    'runtime implemented: true',
    'analyzer wired: true',
    'engine call active',
    'scheduler execution active',
    'http://',
    'https://',
    'apiKey',
    'secret=',
    'token=',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}
