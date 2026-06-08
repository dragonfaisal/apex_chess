@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug-Only Bridge Prototype Design Validation', () {
    test('consumes safe Phase 32Z prototype design with warning status', () {
      final result = _safeResult();

      expect(
        result.validationStatus,
        DebugOnlyBridgePrototypeDesignValidationStatus.validatedWithWarnings,
      );
      expect(
        result.sourceDesignStatus,
        DebugOnlyBridgePrototypeDesignStatus.designReadyWithWarnings,
      );
      expect(result.safeForPhase33B, isTrue);
      expect(result.unsafeRecordCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.executableDebugBridgePrototypeImplemented, isFalse);
    });

    test('unsafe prototype design blocks validation', () {
      final unsafeDesign = _cachedSafeDesign.copyWith(
        designStatus:
            DebugOnlyBridgePrototypeDesignStatus.blockedByPolicyBoundary,
        unsafeCount: 1,
        safeForPhase33A: false,
      );
      final result = _safeResult(
        DebugOnlyBridgePrototypeDesignValidationRequest(
          designResult: unsafeDesign,
          gateResult: _cachedSafeGate,
        ),
      );

      expect(
        result.validationStatus,
        DebugOnlyBridgePrototypeDesignValidationStatus
            .blockedByUnsafePrototypeDesign,
      );
      expect(result.safeForPhase33B, isFalse);
      expect(
        result.hasUnsafeDebugOnlyBridgePrototypeDesignValidationPolicyViolation,
        isTrue,
      );
    });

    test('validation checks are deterministic', () {
      final result = _safeResult();

      expect(result.totalChecks, 17);
      expect(result.passedCheckCount, 13);
      expect(result.warningCheckCount, 4);
      expect(
        result.check('prototypeDesignConsumesReadinessGate').checkStatus,
        DebugOnlyBridgePrototypeDesignValidationCheckStatus.passed,
      );
      expect(
        result.check('prototypeContextDesignStaysContextOnly').checkStatus,
        DebugOnlyBridgePrototypeDesignValidationCheckStatus.passedWithWarnings,
      );
      expect(
        result.check('stockfishCommandRawUciPvDumpRemainDenied').checkStatus,
        DebugOnlyBridgePrototypeDesignValidationCheckStatus.passed,
      );
      expect(
        result.check('futurePhase33AValidationRequirementPresent').checkStatus,
        DebugOnlyBridgePrototypeDesignValidationCheckStatus.passed,
      );
    });

    test('design section validation rows preserve all Phase 32Z sections', () {
      final result = _safeResult();

      expect(result.totalSectionRows, 10);
      expect(
        result
            .sectionRowForSection(
              DebugOnlyBridgePrototypeDesignSectionId.prototypeCoreInputDesign,
            )
            .validationStatus,
        DebugOnlyBridgePrototypeDesignSectionValidationStatus
            .validPrototypeCoreInputDesign,
      );
      expect(
        result
            .sectionRowForSection(
              DebugOnlyBridgePrototypeDesignSectionId
                  .prototypeContextInputDesign,
            )
            .validationStatus,
        DebugOnlyBridgePrototypeDesignSectionValidationStatus
            .validPrototypeContextInputDesign,
      );
      expect(
        result
            .sectionRowForSection(
              DebugOnlyBridgePrototypeDesignSectionId
                  .stockfishRawUciPvDumpDeniedDesign,
            )
            .deniedFieldIds,
        orderedEquals(_engineDumpFieldIds),
      );
      expect(
        result
            .sectionRowForSection(
              DebugOnlyBridgePrototypeDesignSectionId
                  .futurePrototypeValidationRequirements,
            )
            .validationStatus,
        DebugOnlyBridgePrototypeDesignSectionValidationStatus
            .validFuturePrototypeValidationRequirements,
      );
    });

    test('design record validation rows preserve all Phase 32Z roles', () {
      final result = _safeResult();

      expect(result.totalRecordRows, 10);
      expect(
        result
            .recordRowForRole(
              DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord,
            )
            .validationStatus,
        DebugOnlyBridgePrototypeDesignRecordValidationStatus
            .validPrototypeCoreDesignRecord,
      );
      expect(
        result
            .recordRowForRole(
              DebugOnlyBridgePrototypeDesignRole
                  .prototypeContextInputDesignRecord,
            )
            .contextOnly,
        isTrue,
      );
      expect(
        result
            .recordRowForRole(
              DebugOnlyBridgePrototypeDesignRole
                  .prototypeInactiveBlockedInputDesignRecord,
            )
            .inactive,
        isTrue,
      );
      expect(
        result
            .recordRowForRole(
              DebugOnlyBridgePrototypeDesignRole
                  .futureValidationRequirementRecord,
            )
            .validationStatus,
        DebugOnlyBridgePrototypeDesignRecordValidationStatus
            .validFutureValidationRequirementRecord,
      );
    });

    test('aggregate counts and Phase 33B recommendation are deterministic', () {
      final result = _safeResult();

      expect(result.validPrototypeCoreDesignCount, 1);
      expect(result.validPrototypeContextDesignCount, 1);
      expect(result.validInactiveBlockedDesignCount, 1);
      expect(result.validInactiveFutureOnlyDesignCount, 1);
      expect(result.validAllowedFieldDesignCount, 1);
      expect(result.validDeniedFieldDesignCount, 1);
      expect(result.validStockfishRawUciPvDumpDeniedCount, 1);
      expect(result.validAndroidProofBoundaryCount, 1);
      expect(result.validOwnerProofBoundaryCount, 1);
      expect(result.validFutureValidationRequirementCount, 1);
      expect(result.invalidRecordCount, 0);
      expect(result.unsafeRecordCount, 0);
      expect(result.safeForPhase33B, isTrue);
      expect(
        result.phase33BRecommendation,
        DebugOnlyBridgePrototypeDesignValidationPhase33BRecommendation
            .proceedToDebugBridgePrototypeDesignReadinessGate,
      );
    });

    test('allowed and denied field validation keeps boundaries', () {
      final result = _safeResult();

      expect(result.allowedFieldIds, orderedEquals(_allowedFieldIds));
      expect(result.allowedFieldIds, isNot(contains('productLabel')));
      expect(result.allowedFieldIds, isNot(contains('stockfishCommand')));
      expect(result.deniedFieldIds, orderedEquals(_deniedFieldIds));
      for (final fieldId in _deniedFieldIds) {
        expect(result.deniedFieldIds, contains(fieldId), reason: fieldId);
      }
      expect(
        result
            .recordRowForRole(
              DebugOnlyBridgePrototypeDesignRole
                  .stockfishRawUciPvDumpDeniedDesignRecord,
            )
            .deniedFieldIds,
        orderedEquals(_engineDumpFieldIds),
      );
    });

    test('Android proof and owner proof boundaries validate honestly', () {
      final result = _safeResult();

      expect(
        result.androidProofCaseIds,
        orderedEquals(_capturedAndroidProofIds),
      );
      for (final phase32ECase in _phase32ECaseIds) {
        expect(result.androidProofCaseIds, isNot(contains(phase32ECase)));
      }
      expect(result.ownerProofQueueCount, 0);
    });

    test('runtime and executable prototype flags remain false', () {
      final result = _safeResult();

      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.executableDebugBridgePrototypeImplemented, isFalse);
      for (final row in result.recordRows) {
        expect(row.designOnly, isTrue, reason: row.designRole.wire);
        expect(row.safetyFlags['implementsRuntime'], isFalse);
        expect(row.safetyFlags['implementsPrototypeExecution'], isFalse);
      }
    });

    test('no validation record emits product integration or engine output', () {
      final result = _safeResult();

      expect(result.productOutputActive, isFalse);
      expect(result.classifierOutputActive, isFalse);
      expect(result.finalMoveLabelOutputActive, isFalse);
      expect(result.officialMetricOutputActive, isFalse);
      expect(result.cpLossOutputActive, isFalse);
      expect(result.winProbabilityOutputActive, isFalse);
      expect(result.numericOutputActive, isFalse);
      expect(result.aggregateScoreOutputActive, isFalse);
      expect(result.moveRankingOutputActive, isFalse);
      expect(result.quietPreparatoryScopeActivated, isFalse);
      expect(result.engineCallsActive, isFalse);
      expect(result.persistenceWritesActive, isFalse);
      expect(result.uiTargetsActive, isFalse);
      expect(result.backendOutputActive, isFalse);
      expect(result.stockfishCommandFieldActive, isFalse);
      expect(result.rawUciFieldActive, isFalse);
      expect(result.pvDumpFieldActive, isFalse);
      for (final row in result.recordRows) {
        expect(row.safetyFlags.values.any((value) => value), isFalse);
      }
    });

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final unproven = result.copyWith(
        androidProofCaseIds: const <String>['fake-proof'],
      );
      final phase32E = result.copyWith(
        androidProofCaseIds: const <String>[
          'budget-pressure-wide-candidate-32e',
        ],
      );
      final validator =
          const DebugOnlyBridgePrototypeDesignValidationValidator();

      expect(
        validator.validate(unproven).map((finding) => finding.id),
        contains('unprovenAndroidProofId'),
      );
      expect(
        validator.validate(phase32E).map((finding) => finding.id),
        contains('phase32ECaseTreatedAsCapturedProof'),
      );
    });

    test('validator rejects context promotion and non-core core input', () {
      final result = _safeResult();
      final rows = result.recordRows
          .map(
            (row) =>
                row.validationStatus ==
                    DebugOnlyBridgePrototypeDesignRecordValidationStatus
                        .validPrototypeCoreDesignRecord
                ? row.copyWith(
                    contextOnly: true,
                    violationReasons: const <String>[
                      'prototypeCoreConsumesNonCoreInput',
                    ],
                  )
                : row.validationStatus ==
                      DebugOnlyBridgePrototypeDesignRecordValidationStatus
                          .validPrototypeContextDesignRecord
                ? row.copyWith(
                    contextOnly: false,
                    allowedForFuturePrototypeImplementation: true,
                  )
                : row,
          )
          .toList(growable: false);
      final ids = const DebugOnlyBridgePrototypeDesignValidationValidator()
          .validate(result.copyWith(recordRows: rows))
          .map((finding) => finding.id)
          .toSet();

      expect(ids, contains('prototypeCoreConsumesNonCoreInput'));
      expect(ids, contains('contextOnlyInputPromotedToPrototypeCore'));
    });

    test(
      'validator rejects blocked future activation and active denied fields',
      () {
        final result = _safeResult();
        final rows = result.recordRows
            .map(
              (row) =>
                  row.validationStatus ==
                      DebugOnlyBridgePrototypeDesignRecordValidationStatus
                          .validInactiveBlockedDesignRecord
                  ? row.copyWith(
                      inactive: false,
                      allowedFieldIds: const <String>['debugBridgeRecordId'],
                    )
                  : row,
            )
            .toList(growable: false);
        final ids = const DebugOnlyBridgePrototypeDesignValidationValidator()
            .validate(
              result.copyWith(
                recordRows: rows,
                allowedFieldIds: const <String>['productLabel'],
              ),
            )
            .map((finding) => finding.id)
            .toSet();

        expect(ids, contains('blockedFutureDesignMadeActive'));
        expect(ids, contains('activeDeniedField'));
      },
    );

    test('validator rejects policy safety and implementation flags', () {
      final result = _safeResult();
      final validator =
          const DebugOnlyBridgePrototypeDesignValidationValidator();
      final flags = <String, String>{
        'isProductOutput': 'productOutputActive',
        'isClassifierLabel': 'classifierLabelOutputActive',
        'hasNumericScore': 'numericScoreOutputActive',
        'hasAggregateScore': 'aggregateScoreOutputActive',
        'ranksMoves': 'moveRankingOutputActive',
        'isOfficialMetric': 'officialMetricOutputActive',
        'exposesCpLoss': 'futureMetricOutputActive',
        'exposesWinProbability': 'futureMetricOutputActive',
        'quietPreparatoryScopeActive': 'quietPreparatoryScopeActivated',
        'callsEngine': 'engineCallFlagActive',
        'writesPersistence': 'persistenceWriteFlagActive',
        'targetsUi': 'uiTargetFlagActive',
        'backendOutputActive': 'backendOutputActive',
        'exposesStockfishCommand': 'stockfishRawUciPvDumpFieldActive',
        'exposesRawUci': 'stockfishRawUciPvDumpFieldActive',
        'exposesPvDump': 'stockfishRawUciPvDumpFieldActive',
        'implementsRuntime': 'runtimeImplementationFlagActive',
        'implementsPrototypeExecution':
            'executablePrototypeImplementationFlagActive',
      };

      for (final entry in flags.entries) {
        final rows = result.recordRows
            .map(
              (row) =>
                  row.validationStatus ==
                      DebugOnlyBridgePrototypeDesignRecordValidationStatus
                          .validPrototypeCoreDesignRecord
                  ? row.copyWith(safetyFlags: <String, bool>{entry.key: true})
                  : row,
            )
            .toList(growable: false);
        expect(
          validator
              .validate(result.copyWith(recordRows: rows))
              .map((finding) => finding.id),
          contains(entry.value),
          reason: entry.key,
        );
      }
    });

    test('validator rejects missing Phase 33A validation requirement', () {
      final result = _safeResult().copyWith(
        validFutureValidationRequirementCount: 0,
      );

      expect(
        const DebugOnlyBridgePrototypeDesignValidationValidator()
            .validate(result)
            .map((finding) => finding.id),
        contains('missingPhase33AValidationRequirement'),
      );
    });

    test('result flags reject blocked global integration state', () {
      final result = _safeResult().copyWith(
        debugBridgeRuntimeImplemented: true,
        executableDebugBridgePrototypeImplemented: true,
        uiTargetsActive: true,
        backendOutputActive: true,
        persistenceWritesActive: true,
        engineCallsActive: true,
        stockfishCommandFieldActive: true,
        rawUciFieldActive: true,
        pvDumpFieldActive: true,
      );

      expect(
        const DebugOnlyBridgePrototypeDesignValidationValidator()
            .validate(result)
            .map((finding) => finding.id),
        contains(
          'debugOnlyBridgePrototypeDesignValidationBoundaryPolicyViolation',
        ),
      );
    });

    test('markdown report includes required validation sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(
        report,
        contains('# Debug-Only Bridge Prototype Design Validation'),
      );
      expect(report, contains('## Validation Check Table'));
      expect(report, contains('## Design Section Validation Table'));
      expect(report, contains('## Design Record Validation Table'));
      expect(report, contains('## Prototype Core Design Validation'));
      expect(report, contains('## Prototype Context Design Validation'));
      expect(report, contains('## Allowed And Denied Field Validation'));
      expect(
        report,
        contains('## Stockfish Raw UCI PV Dump Denied Validation'),
      );
      expect(report, contains('## Phase 33A Validation Requirement'));
      expect(report, contains('## Phase 33B Recommendation'));
      _expectReportGuardrails(report);
    });

    test('JSON report is deterministic and valid', () {
      final first = _safeResult().renderJsonReport();
      final second = _safeResult().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        debugOnlyBridgePrototypeDesignValidationReportVersion,
      );
      expect(decoded['totalChecks'], 17);
      expect(decoded['totalSectionRows'], 10);
      expect(decoded['totalRecordRows'], 10);
      expect(decoded['safeForPhase33B'], isTrue);
    });

    test('reports contain no raw UCI spam or active product outputs', () {
      final report = _safeResult().renderMarkdownReport();

      _expectReportGuardrails(report);
      expect(
        const DebugOnlyBridgePrototypeDesignValidationValidator()
            .validateReportText(report),
        isEmpty,
      );
    });

    test('source imports stay pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      for (final forbidden in const <String>[
        'stockfish',
        'ffi',
        'native',
        'local_eval_service',
        'flutter/widgets',
        'flutter/material',
        'backend',
        'preflight',
        'server',
        'cache',
        'database',
        'persistence',
      ]) {
        expect(imports.toLowerCase(), isNot(contains(forbidden)));
      }
    });
  });
}

DebugOnlyBridgePrototypeDesignValidationResult _safeResult([
  DebugOnlyBridgePrototypeDesignValidationRequest? request,
]) {
  if (request != null) {
    return const DebugOnlyBridgePrototypeDesignValidation().evaluate(request);
  }
  return _cachedSafeValidation;
}

void _expectReportGuardrails(String report) {
  for (final token in const <String>[
    'uciok',
    'readyok',
    'info depth',
    'bestmove e2e4',
    'pv e2e4',
    'pvMoves',
    'active fields: productLabel',
    'active fields: finalMoveLabel',
    'active fields: numericMoveScore',
    'allowed fields: productLabel',
    'allowed fields: stockfishCommand',
    'numeric move score:',
    'scoreValue',
    'moveScore',
    'rankedMoves',
    'moveRanking active',
    'ACPL active',
    'official accuracy active',
    'runtime implemented: true',
    'executable debug bridge prototype implemented: true',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}

final DebugBridgeReadinessValidationGateResult _cachedSafeGate =
    const DebugBridgeReadinessValidationGate().evaluate(
      const DebugBridgeReadinessValidationGateRequest.safeDemo(),
    );

final DebugOnlyBridgePrototypeDesignRequest _cachedSafeDesignRequest =
    DebugOnlyBridgePrototypeDesignRequest(gateResult: _cachedSafeGate);

final DebugOnlyBridgePrototypeDesignResult _cachedSafeDesign =
    const DebugOnlyBridgePrototypeDesign().evaluate(_cachedSafeDesignRequest);

final DebugOnlyBridgePrototypeDesignValidationResult _cachedSafeValidation =
    const DebugOnlyBridgePrototypeDesignValidation().evaluate(
      DebugOnlyBridgePrototypeDesignValidationRequest(
        designResult: _cachedSafeDesign,
        gateResult: _cachedSafeGate,
      ),
    );

const _allowedFieldIds = <String>[
  'bucketIds',
  'debugBridgeRecordId',
  'evidenceAreaIds',
  'futurePrerequisites',
  'internalConstraints',
  'internalWarnings',
  'newlyAddedSupportCaseIds',
  'proofLimitReason',
  'qualitativeConfidence',
  'sourceAdapterPacketIds',
  'sourceSummaryGroupIds',
  'supportCaseIds',
  'warningLimitedReason',
  'watchListReason',
];

const _deniedFieldIds = <String>[
  'acpl',
  'aggregateScore',
  'backendOutput',
  'bestGoodInaccuracyMistakeBlunderStyleLabels',
  'brilliantGreatMissStyleLabels',
  'cpLoss',
  'directEngineCall',
  'finalMoveLabel',
  'moveRanking',
  'numericMoveScore',
  'officialAccuracy',
  'persistenceOutput',
  'productLabel',
  'pvDump',
  'rawUci',
  'stockfishCommand',
  'uiOutput',
  'winProbability',
];

const _engineDumpFieldIds = <String>['pvDump', 'rawUci', 'stockfishCommand'];

const _capturedAndroidProofIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];

const _phase32ECaseIds = <String>[
  'budget-pressure-wide-candidate-32e',
  'endgame-precision-candidate-spread-32e',
  'king-safety-mating-net-pressure-32e',
  'pv-multipv-support-boundary-32e',
  'suppression-forced-only-legal-32e',
];
