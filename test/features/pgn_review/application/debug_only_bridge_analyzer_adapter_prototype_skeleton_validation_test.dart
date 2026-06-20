@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_implementation_design_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_skeleton_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidation', () {
    test('safe default validation passes with warnings', () {
      final result = _safeValidation();

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus
            .prototypeSkeletonValidatedWithWarnings,
      );
      expect(
        result.sourceSkeletonStatus,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonStatus
            .prototypeSkeletonReadyWithWarnings,
      );
      expect(result.sourceSkeletonSafeForPhase33V, isTrue);
      expect(result.safeForPhase33W, isTrue);
      expect(
        result.phase33WRecommendation,
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness',
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

    test(
      'validation rows are deterministic for packets records and policy',
      () {
        final result = _safeValidation();

        expect(result.totalChecks, 17);
        expect(result.passedCheckCount, 17);
        expect(result.warningCheckCount, 1);
        expect(result.totalValidationRows, 38);
        expect(result.inputPacketValidationCount, 1);
        expect(result.contextPacketValidationCount, 1);
        expect(result.internalInputRecordValidationCount, 8);
        expect(result.contextOnlyRecordValidationCount, 3);
        expect(result.warningLimitedRecordValidationCount, 2);
        expect(result.proofBoundaryRecordValidationCount, 1);
        expect(result.excludedGuardRecordValidationCount, 2);
        expect(result.allowedFieldBoundaryRecordValidationCount, 1);
        expect(result.deniedFieldBoundaryRecordValidationCount, 5);
        expect(result.mapperMetadataRecordValidationCount, 1);
        expect(result.validatorMetadataRecordValidationCount, 1);
        expect(result.debugSnapshotMetadataRecordValidationCount, 1);
        expect(result.runtimeBlockedRecordValidationCount, 1);
        expect(result.analyzerWiringBlockedRecordValidationCount, 1);
        expect(result.engineBlockedRecordValidationCount, 1);
        expect(result.schedulerBlockedRecordValidationCount, 1);
        expect(result.productAdapterBlockedRecordValidationCount, 1);
        expect(result.savedAnalysisBlockedRecordValidationCount, 1);
        expect(result.futureRequirementRecordValidationCount, 3);
        expect(result.policyValidationCount, 1);
        expect(result.reportSafetyValidationCount, 1);
      },
    );

    test('packet rows stay developer-only in-memory and analyzer-unwired', () {
      final result = _safeValidation();
      final input = result.rowForRole(
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
            .inputPacketValidation,
      );
      final context = result.rowForRole(
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
            .contextPacketValidation,
      );

      expect(input.developerOnly, isTrue);
      expect(input.inMemoryOnly, isTrue);
      expect(input.analyzerUnwired, isTrue);
      expect(input.allowedFieldIds, contains('recordRole'));
      expect(input.allowedFieldIds, isNot(contains('rawUci')));
      expect(context.developerOnly, isTrue);
      expect(context.contextOnly, isTrue);
      expect(context.analyzerUnwired, isTrue);
    });

    test(
      'record roles preserve context warning proof excluded and blocked states',
      () {
        final result = _safeValidation();

        expect(
          result
              .rowForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                    .contextOnlyRecordValidation,
              )
              .contextOnly,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                    .warningLimitedRecordValidation,
              )
              .warningLimited,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                    .proofBoundaryRecordValidation,
              )
              .proofBoundaryOnly,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                    .excludedGuardRecordValidation,
              )
              .excludedGuard,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                    .deniedFieldBoundaryRecordValidation,
              )
              .inactive,
          isTrue,
        );
        expect(
          result
              .rowForRole(
                DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                    .runtimeBlockedRecordValidation,
              )
              .inactive,
          isTrue,
        );
      },
    );

    test('Phase 32E proof honesty and owner proof remain preserved', () {
      final result = _safeValidation();
      final phase32ERows = result.validationRows.where(
        (row) => row.sourcePhase == 'Phase 32E',
      );
      final proofIds = result.validationRows
          .expand((row) => row.androidProofCaseIds)
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

    test('unsafe Phase 33U skeleton input blocks validation', () {
      final unsafeSource = _copyImplementationValidation(
        _safeImplementationValidation(),
        safeForPhase33U: false,
        recommendation:
            'blockedByUnsafeAnalyzerAdapterPrototypeImplementationDesignValidation',
      );
      final unsafeSkeleton =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeMapper().evaluate(
            validationResult: unsafeSource,
          );
      final result =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidation()
              .evaluate(skeletonResult: unsafeSkeleton);

      expect(
        result.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationStatus
            .blockedByUnsafePrototypeSkeleton,
      );
      expect(result.safeForPhase33W, isFalse);
      expect(result.blockerCount, greaterThan(0));
    });

    test('validator rejects label score metric threshold and product seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationValidator();
      final row = _safeRow();
      final seams = <String, String>{
        'productLabel': 'productOutput',
        'finalMoveLabel': 'finalLabelLeak',
        'classifierLabel': 'classifierLabelLeak',
        'brilliantGreatMiss': 'classifierLabelLeak',
        'bestGoodInaccuracyMistakeBlunder': 'classifierLabelLeak',
        'numericMoveScore': 'numericScoreLeak',
        'aggregateScore': 'aggregateScoreLeak',
        'officialMetric': 'officialMetricLeak',
        'accuracy': 'officialMetricLeak',
        'acpl': 'officialMetricLeak',
        'moveRanking': 'moveRankingLeak',
        'thresholds': 'thresholdLeak',
      };

      for (final entry in seams.entries) {
        final findings = validator.validateRow(
          row.copyWith(activeDeniedFieldIds: <String>[entry.key]),
        );

        expect(findings, contains('activeDeniedField'), reason: entry.key);
        expect(findings, contains(entry.value), reason: entry.key);
      }
    });

    test('validator rejects cp win integration runtime and raw seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationValidator();
      final row = _safeRow();
      final seams = <String, String>{
        'cpLoss': 'cpLossLeak',
        'winProbability': 'winProbabilityLeak',
        'uiTarget': 'uiTarget',
        'backendTarget': 'backendTarget',
        'persistenceWrite': 'persistenceWrite',
        'directEngineAccess': 'engineCall',
        'schedulerExecution': 'schedulerExecution',
        'analyzerWiring': 'analyzerWiring',
        'runtimeImplementation': 'runtimeImplementation',
        'executablePrototypeBehavior': 'executablePrototypeImplementation',
        'productAdapterBehavior': 'productAdapterBehavior',
        'savedAnalysisIntegration': 'savedAnalysisIntegration',
        'stockfishCommand': 'stockfishCommandLeak',
        'rawUci': 'rawUciLeak',
        'pvDump': 'pvDumpLeak',
        'androidCollectorRequirement': 'androidCollectorRequired',
      };

      for (final entry in seams.entries) {
        final findings = validator.validateRow(
          row.copyWith(activeDeniedFieldIds: <String>[entry.key]),
        );

        expect(findings, contains('activeDeniedField'), reason: entry.key);
        expect(findings, contains(entry.value), reason: entry.key);
      }
    });

    test('validator rejects quiet PV proof owner and unknown role seams', () {
      final validator =
          const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationValidator();

      expect(
        validator.validateRow(
          _safeRow().copyWith(
            sourceCaseId: 'quiet-preparatory-uncertain',
            validationRole:
                DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                    .internalInputRecordValidation,
          ),
        ),
        contains('quietPreparatoryPromoted'),
      );
      expect(
        validator.validateRow(
          _safeRow().copyWith(
            sourceCaseId: 'pv-multipv-support-boundary-32e',
            validationRole:
                DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                    .internalInputRecordValidation,
          ),
        ),
        contains('pvMultiPvPromotedBeyondBoundary'),
      );
      expect(
        validator.validateRow(
          _safeRow().copyWith(
            sourceCaseId: 'king-safety-mating-net-pressure-32e',
            sourcePhase: 'Phase 32E',
            androidProofCaseIds: <String>['mate-threat-fast-evidence'],
          ),
        ),
        contains('phase32ECapturedAndroidProofClaim'),
      );
      expect(
        validator.validateRow(_safeRow().copyWith(ownerProofRequired: true)),
        contains('ownerProofWithoutPvMultiPvReason'),
      );
      expect(
        validator.validateRow(
          _safeRow().copyWith(androidProofCaseIds: <String>['unproven-proof']),
        ),
        contains('unprovenAndroidProofId'),
      );
      expect(
        validator.validateRow(_safeRow().copyWith(sourceRole: 'unknownRole')),
        contains('unknownRecordRole'),
      );
      expect(
        validator.validateRow(
          _safeRow().copyWith(
            sourceRole: 'unknownPacketRole',
            validationRole:
                DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                    .inputPacketValidation,
          ),
        ),
        contains('unknownPacketRole'),
      );
    });

    test('validator rejects missing Phase 33W requirement', () {
      final result = _safeValidation();
      final withoutFuture = result.copyWith(
        validationRows: result.validationRows
            .where(
              (row) =>
                  row.validationRole !=
                  DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
                      .futureRequirementRecordValidation,
            )
            .toList(growable: false),
      );

      expect(
        const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationValidator()
            .validateResult(withoutFuture),
        contains('missingPhase33WRequirement'),
      );
    });

    test('markdown and JSON reports are deterministic and safe', () {
      final result = _safeValidation();
      final markdown = result.renderMarkdown();
      final json = result.renderJson();
      final decoded = jsonDecode(json) as Map<String, Object?>;

      expect(markdown, contains('Validation Check Table'));
      expect(markdown, contains('Packet Validation Summary'));
      expect(markdown, contains('Record Role Validation Summary'));
      expect(markdown, contains('Policy Validation Summary'));
      expect(markdown, contains('Proof Boundary Validation'));
      expect(markdown, contains('Phase 33W Recommendation'));
      expect(
        decoded['validationStatus'],
        'prototypeSkeletonValidatedWithWarnings',
      );
      expect(decoded['safeForPhase33W'], isTrue);
      expect(
        decoded['phase33WRecommendation'],
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness',
      );
      _expectReportGuardrails(markdown);
      _expectReportGuardrails(json);
    });

    test('source imports remain application-layer and integration-free', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_skeleton_validation.dart',
      ).readAsStringSync();
      final imports = RegExp(
        r"import '([^']+)';",
      ).allMatches(source).map((match) => match.group(1)!).join('\n');

      for (final forbidden in const <String>[
        'package:flutter/',
        'widgets',
        'backend',
        'preflight',
        'server',
        'cache',
        'database',
        'ffi',
        'native',
        'stockfish',
        'local_eval_service',
        'scheduler',
      ]) {
        expect(imports.toLowerCase(), isNot(contains(forbidden)));
      }
    });
  });
}

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationResult
_safeValidation() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidation()
      .evaluate();
}

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult
_safeImplementationValidation() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidation()
      .evaluate();
}

DebugOnlyBridgeAnalyzerAdapterPrototypeImplementationDesignValidationResult
_copyImplementationValidation(
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

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow _safeRow() {
  return const DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRow(
    validationRowId: 'phase33v-test-row',
    sourceRecordId: 'phase33u-test-record',
    sourceCaseId: 'known-case',
    sourcePhase: 'existing',
    sourceRole: 'internalInputRecord',
    validationRole:
        DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowRole
            .internalInputRecordValidation,
    status: DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonValidationRowStatus
        .valid,
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
    findings: <String>[],
    recommendation:
        'proceedToDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness',
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
