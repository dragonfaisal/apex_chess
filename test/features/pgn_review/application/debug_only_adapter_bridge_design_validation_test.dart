@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug-Only Adapter Bridge Design Validation', () {
    test('consumes safe Phase 32T bridge design with warning status', () {
      final result = _safeResult();

      expect(
        result.validationStatus,
        DebugOnlyAdapterBridgeDesignValidationStatus.validatedWithWarnings,
      );
      expect(
        result.sourceBridgeDesignStatus,
        DebugOnlyAdapterBridgeDesignStatus.designReadyWithWarnings,
      );
      expect(result.safeForPhase32V, isTrue);
      expect(result.unsafeRecordCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('unsafe bridge design blocks validation', () {
      final unsafeDesign = const DebugOnlyAdapterBridgeDesign()
          .evaluate()
          .copyWith(
            designStatus: DebugOnlyAdapterBridgeDesignStatus
                .blockedBySummaryValidationFailure,
            unsafeCount: 1,
            safeForPhase32U: false,
          );
      final result = _safeResult(
        DebugOnlyAdapterBridgeDesignValidationRequest(
          designResult: unsafeDesign,
        ),
      );

      expect(
        result.validationStatus,
        DebugOnlyAdapterBridgeDesignValidationStatus
            .blockedByUnsafeBridgeDesign,
      );
      expect(result.safeForPhase32V, isFalse);
      expect(
        result.hasUnsafeDebugBridgeDesignValidationPolicyViolation,
        isTrue,
      );
    });

    test('bridge groups validate with expected group statuses', () {
      final result = _safeResult();

      expect(
        result
            .groupRowForGroup(
              DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup,
            )
            .validationStatus,
        DebugOnlyAdapterBridgeGroupValidationStatus.validDebugCoreInputGroup,
      );
      expect(
        result
            .groupRowForGroup(
              DebugOnlyAdapterBridgeInputGroupId.debugContextInputGroup,
            )
            .validationStatus,
        DebugOnlyAdapterBridgeGroupValidationStatus.validDebugContextInputGroup,
      );
      expect(
        result
            .groupRowForGroup(
              DebugOnlyAdapterBridgeInputGroupId.debugBlockedInputGroup,
            )
            .validationStatus,
        DebugOnlyAdapterBridgeGroupValidationStatus.validDebugBlockedInputGroup,
      );
      expect(
        result
            .groupRowForGroup(
              DebugOnlyAdapterBridgeInputGroupId.debugFutureOnlyInputGroup,
            )
            .validationStatus,
        DebugOnlyAdapterBridgeGroupValidationStatus
            .validDebugFutureOnlyInputGroup,
      );
      expect(
        result
            .groupRowForGroup(
              DebugOnlyAdapterBridgeInputGroupId.debugAllowedFieldGroup,
            )
            .validationStatus,
        DebugOnlyAdapterBridgeGroupValidationStatus.validDebugAllowedFieldGroup,
      );
      expect(
        result
            .groupRowForGroup(
              DebugOnlyAdapterBridgeInputGroupId.debugBlockedFieldGroup,
            )
            .validationStatus,
        DebugOnlyAdapterBridgeGroupValidationStatus.validDebugBlockedFieldGroup,
      );
      expect(
        result
            .groupRowForGroup(
              DebugOnlyAdapterBridgeInputGroupId.debugProofBoundaryGroup,
            )
            .validationStatus,
        DebugOnlyAdapterBridgeGroupValidationStatus
            .validDebugProofBoundaryGroup,
      );
      expect(
        result
            .groupRowForGroup(
              DebugOnlyAdapterBridgeInputGroupId.debugOwnerProofStatusGroup,
            )
            .validationStatus,
        DebugOnlyAdapterBridgeGroupValidationStatus
            .validDebugOwnerProofStatusGroup,
      );
    });

    test(
      'bridge record validation rows preserve core/context/boundary roles',
      () {
        final result = _safeResult();

        expect(
          result
              .recordRowForRole(DebugOnlyAdapterBridgeRole.debugCoreInput)
              .validationStatus,
          DebugOnlyAdapterBridgeRecordValidationStatus.validDebugCoreInput,
        );
        expect(
          result
              .recordRowForRole(
                DebugOnlyAdapterBridgeRole.debugContextOnlyInput,
              )
              .validationStatus,
          DebugOnlyAdapterBridgeRecordValidationStatus
              .validDebugContextOnlyInput,
        );
        expect(
          result
              .recordRowForRole(DebugOnlyAdapterBridgeRole.debugBlockedInput)
              .validationStatus,
          DebugOnlyAdapterBridgeRecordValidationStatus.validDebugBlockedInput,
        );
        expect(
          result
              .recordRowForRole(DebugOnlyAdapterBridgeRole.debugFutureOnlyInput)
              .validationStatus,
          DebugOnlyAdapterBridgeRecordValidationStatus
              .validDebugFutureOnlyInput,
        );
        expect(
          result
              .recordRowForRole(DebugOnlyAdapterBridgeRole.debugAllowedField)
              .validationStatus,
          DebugOnlyAdapterBridgeRecordValidationStatus.validDebugAllowedField,
        );
        expect(
          result
              .recordRowForRole(DebugOnlyAdapterBridgeRole.debugBlockedField)
              .validationStatus,
          DebugOnlyAdapterBridgeRecordValidationStatus.validDebugBlockedField,
        );
        expect(
          result
              .recordRowForRole(DebugOnlyAdapterBridgeRole.debugProofBoundary)
              .validationStatus,
          DebugOnlyAdapterBridgeRecordValidationStatus.validDebugProofBoundary,
        );
        expect(
          result
              .recordRowForRole(
                DebugOnlyAdapterBridgeRole.debugOwnerProofStatus,
              )
              .validationStatus,
          DebugOnlyAdapterBridgeRecordValidationStatus
              .validDebugOwnerProofStatus,
        );
      },
    );

    test('debug core and context validation preserve packet boundaries', () {
      final result = _safeResult();
      final coreGroup = result.groupRowForGroup(
        DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup,
      );
      final context = result.recordRowForRole(
        DebugOnlyAdapterBridgeRole.debugContextOnlyInput,
      );

      expect(
        coreGroup.bridgeRecordIds,
        contains('debug-bridge-debugCoreInputGroup'),
      );
      expect(context.contextOnly, isTrue);
      expect(context.inactive, isFalse);
      expect(context.safeForNextPhase, isTrue);
      expect(
        result.check('debugCoreInputsUseOnlyAllowedCore').checkStatus,
        DebugOnlyAdapterBridgeDesignValidationCheckStatus.passed,
      );
      expect(
        result.check('debugContextInputsStayContextOnly').checkStatus,
        DebugOnlyAdapterBridgeDesignValidationCheckStatus.passedWithWarnings,
      );
    });

    test('blocked and future inputs validate as inactive', () {
      final result = _safeResult();
      final blocked = result.recordRowForRole(
        DebugOnlyAdapterBridgeRole.debugBlockedInput,
      );
      final future = result.recordRowForRole(
        DebugOnlyAdapterBridgeRole.debugFutureOnlyInput,
      );

      expect(blocked.inactive, isTrue);
      expect(blocked.activeFieldIds, isEmpty);
      expect(future.inactive, isTrue);
      expect(future.activeFieldIds, isEmpty);
      expect(
        result.check('debugBlockedInputsStayInactive').checkStatus,
        DebugOnlyAdapterBridgeDesignValidationCheckStatus.passedWithWarnings,
      );
      expect(
        result.check('debugFutureOnlyInputsStayInactive').checkStatus,
        DebugOnlyAdapterBridgeDesignValidationCheckStatus.passedWithWarnings,
      );
    });

    test('allowed and blocked bridge fields validate expected boundaries', () {
      final result = _safeResult();

      expect(result.allowedFieldIds, orderedEquals(_allowedBridgeFieldIds));
      expect(result.allowedFieldIds, isNot(contains('productLabel')));
      expect(result.allowedFieldIds, isNot(contains('stockfishCommand')));
      expect(result.blockedFieldIds, orderedEquals(_blockedBridgeFieldIds));
      expect(result.blockedFieldIds, contains('productLabel'));
      expect(result.blockedFieldIds, contains('finalMoveLabel'));
      expect(result.blockedFieldIds, contains('brilliantGreatMissStyleLabels'));
      expect(
        result.blockedFieldIds,
        contains('bestGoodInaccuracyMistakeBlunderStyleLabels'),
      );
      expect(result.blockedFieldIds, contains('numericMoveScore'));
      expect(result.blockedFieldIds, contains('aggregateScore'));
      expect(result.blockedFieldIds, contains('officialAccuracy'));
      expect(result.blockedFieldIds, contains('acpl'));
      expect(result.blockedFieldIds, contains('cpLoss'));
      expect(result.blockedFieldIds, contains('winProbability'));
      expect(result.blockedFieldIds, contains('moveRanking'));
      expect(result.blockedFieldIds, contains('uiOutput'));
      expect(result.blockedFieldIds, contains('backendOutput'));
      expect(result.blockedFieldIds, contains('persistenceOutput'));
      expect(result.blockedFieldIds, contains('directEngineCall'));
      expect(result.blockedFieldIds, contains('stockfishCommand'));
      expect(result.blockedFieldIds, contains('rawUci'));
      expect(result.blockedFieldIds, contains('pvDump'));
      expect(
        result.check('stockfishCommandRawUciPvDumpStayBlocked').checkStatus,
        DebugOnlyAdapterBridgeDesignValidationCheckStatus.passed,
      );
    });

    test('Android proof and owner proof validation remains honest', () {
      final result = _safeResult();

      expect(result.androidProofCaseIds, _capturedAndroidProofIds);
      for (final phase32ECase in _phase32ECaseIds) {
        expect(result.androidProofCaseIds, isNot(contains(phase32ECase)));
      }
      expect(result.ownerProofQueueCount, 0);
      expect(
        result.check('androidProofIdsAreCapturedOnly').checkStatus,
        DebugOnlyAdapterBridgeDesignValidationCheckStatus.passed,
      );
      expect(
        result.check('phase32ECasesAreNotCapturedProof').checkStatus,
        DebugOnlyAdapterBridgeDesignValidationCheckStatus.passed,
      );
      expect(
        result.check('ownerProofQueueRemainsEmpty').checkStatus,
        DebugOnlyAdapterBridgeDesignValidationCheckStatus.passed,
      );
    });

    test('no validation row emits product or integration output', () {
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
      final proof = result
          .recordRowForRole(DebugOnlyAdapterBridgeRole.debugProofBoundary)
          .copyWith(
            androidProofCaseIds: const <String>[
              'mate-threat-fast-evidence',
              'unproven-proof-id',
              'pv-multipv-support-boundary-32e',
            ],
          );
      final findings = const DebugOnlyAdapterBridgeDesignValidationValidator()
          .validate(
            result.copyWith(
              androidProofCaseIds: proof.androidProofCaseIds,
              recordRows: <DebugOnlyAdapterBridgeRecordValidationRow>[proof],
            ),
          );
      final ids = findings.map((finding) => finding.id).toSet();

      expect(ids, contains('unprovenAndroidProofId'));
      expect(ids, contains('phase32ECaseTreatedAsCapturedProof'));
    });

    test('validator rejects active blocked bridge field', () {
      final result = _safeResult();
      final core = result
          .recordRowForRole(DebugOnlyAdapterBridgeRole.debugCoreInput)
          .copyWith(activeFieldIds: const <String>['productLabel']);
      final findings = const DebugOnlyAdapterBridgeDesignValidationValidator()
          .validate(
            result.copyWith(
              allowedFieldIds: core.activeFieldIds,
              recordRows: <DebugOnlyAdapterBridgeRecordValidationRow>[core],
            ),
          );

      expect(
        findings.map((finding) => finding.id),
        contains('activeBlockedBridgeField'),
      );
    });

    test('validator rejects context-to-core and boundary activation', () {
      final result = _safeResult();
      final context = result
          .recordRowForRole(DebugOnlyAdapterBridgeRole.debugContextOnlyInput)
          .copyWith(bridgeRole: DebugOnlyAdapterBridgeRole.debugCoreInput);
      final blocked = result
          .recordRowForRole(DebugOnlyAdapterBridgeRole.debugBlockedInput)
          .copyWith(
            inactive: false,
            activeFieldIds: const <String>['debugBridgeRecordId'],
          );
      final future = result
          .recordRowForRole(DebugOnlyAdapterBridgeRole.debugFutureOnlyInput)
          .copyWith(
            inactive: false,
            activeFieldIds: const <String>['debugBridgeRecordId'],
          );
      final findings = const DebugOnlyAdapterBridgeDesignValidationValidator()
          .validate(
            result.copyWith(
              recordRows: <DebugOnlyAdapterBridgeRecordValidationRow>[
                context,
                blocked,
                future,
              ],
            ),
          );
      final ids = findings.map((finding) => finding.id).toList();

      expect(ids, contains('contextOnlyInputPromotedToDebugCore'));
      expect(ids.where((id) => id == 'blockedFutureInputMadeActive').length, 2);
    });

    test('validator rejects debug core consuming non-core input', () {
      final result = _safeResult();
      final design = const DebugOnlyAdapterBridgeDesign().evaluate();
      final core = design
          .recordForRole(DebugOnlyAdapterBridgeRole.debugCoreInput)
          .copyWith(
            adapterPacketIds: const <String>[
              'packet-constrainedWatchListSummary',
            ],
          );
      final poisonedDesign = design.copyWith(
        bridgeRecords: <DebugOnlyAdapterBridgeRecord>[core],
      );
      final poisoned = _safeResult(
        DebugOnlyAdapterBridgeDesignValidationRequest(
          designResult: poisonedDesign,
        ),
      );
      final findings = const DebugOnlyAdapterBridgeDesignValidationValidator()
          .validate(poisoned.copyWith(safeForPhase32V: true));

      expect(
        poisoned.recordRows.single.violationReasons,
        contains('debugCoreConsumesNonCoreInput'),
      );
      expect(
        findings.map((finding) => finding.id),
        contains('debugCoreConsumesNonCoreInput'),
      );
      expect(
        result.check('debugCoreInputsUseOnlyAllowedCore').checkStatus,
        DebugOnlyAdapterBridgeDesignValidationCheckStatus.passed,
      );
    });

    test('validator rejects unsafe output and bridge integration seams', () {
      final result = _safeResult();
      final core = result.recordRowForRole(
        DebugOnlyAdapterBridgeRole.debugCoreInput,
      );
      final poisonedRows = <DebugOnlyAdapterBridgeRecordValidationRow>[
        _withSafety(core, 'isProductOutput'),
        _withSafety(core, 'isClassifierLabel'),
        _withSafety(core, 'hasNumericScore'),
        _withSafety(core, 'hasAggregateScore'),
        _withSafety(core, 'ranksMoves'),
        _withSafety(core, 'isOfficialMetric'),
        _withSafety(core, 'cpLossOutputActive'),
        _withSafety(core, 'winProbabilityOutputActive'),
        _withSafety(core, 'quietPreparatoryScopeActive'),
        _withSafety(core, 'callsEngine'),
        _withSafety(core, 'writesPersistence'),
        _withSafety(core, 'targetsUi'),
        _withSafety(core, 'backendOutputActive'),
        _withSafety(core, 'stockfishCommandFieldActive'),
        _withSafety(core, 'rawUciFieldActive'),
        _withSafety(core, 'pvDumpFieldActive'),
      ];
      final ids = poisonedRows
          .expand(
            (row) => const DebugOnlyAdapterBridgeDesignValidationValidator()
                .validate(
                  result.copyWith(
                    recordRows: <DebugOnlyAdapterBridgeRecordValidationRow>[
                      row,
                    ],
                  ),
                )
                .map((finding) => finding.id),
          )
          .toSet();

      expect(ids, contains('productOutputActive'));
      expect(ids, contains('classifierLabelOutputActive'));
      expect(ids, contains('numericScoreOutputActive'));
      expect(ids, contains('aggregateScoreOutputActive'));
      expect(ids, contains('moveRankingOutputActive'));
      expect(ids, contains('officialMetricOutputActive'));
      expect(ids, contains('futureMetricOutputActive'));
      expect(ids, contains('quietPreparatoryScopeActivated'));
      expect(ids, contains('engineCallFlagActive'));
      expect(ids, contains('persistenceWriteFlagActive'));
      expect(ids, contains('uiTargetFlagActive'));
      expect(ids, contains('backendOutputActive'));
      expect(ids, contains('stockfishRawUciPvDumpFieldActive'));
    });

    test('validation checks, rows, and aggregates are deterministic', () {
      final result = _safeResult();

      expect(result.totalChecks, 15);
      expect(result.passedCheckCount, 12);
      expect(result.warningCheckCount, 3);
      expect(result.totalGroupRows, 8);
      expect(result.totalRecordRows, 8);
      expect(result.validDebugCoreInputCount, 1);
      expect(result.validDebugContextInputCount, 1);
      expect(result.validInactiveBlockedInputCount, 1);
      expect(result.validInactiveFutureOnlyInputCount, 1);
      expect(result.validAllowedFieldGroupCount, 1);
      expect(result.validBlockedFieldGroupCount, 1);
      expect(result.validProofBoundaryCount, 1);
      expect(result.validOwnerProofStatusCount, 1);
      expect(result.invalidRecordCount, 0);
      expect(result.unsafeRecordCount, 0);
      expect(result.safeForPhase32V, isTrue);
      expect(
        result.phase32VRecommendation,
        DebugOnlyAdapterBridgeDesignValidationPhase32VRecommendation
            .proceedToDebugBridgeDesignReadinessGate,
      );
      expect(
        result.checks.map((check) => check.checkId).toList(),
        orderedEquals(<String>[
          'allowedFieldsAreInternalEvidenceSafe',
          'androidProofIdsAreCapturedOnly',
          'blockedFieldsRemainDenied',
          'bridgeConsumesValidatedSummary',
          'debugBlockedInputsStayInactive',
          'debugContextInputsStayContextOnly',
          'debugCoreInputsUseOnlyAllowedCore',
          'debugFutureOnlyInputsStayInactive',
          'noLabelsScoresRankingsMetrics',
          'noUiBackendPersistenceEngineFields',
          'ownerProofQueueRemainsEmpty',
          'phase32ECasesAreNotCapturedProof',
          'productBoundariesRemainBlocked',
          'quietScopeRemainsExcluded',
          'stockfishCommandRawUciPvDumpStayBlocked',
        ]),
      );
    });

    test('markdown report includes required validation sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(report, contains('## Validation Check Table'));
      expect(report, contains('## Bridge Group Validation Table'));
      expect(report, contains('## Bridge Record Validation Table'));
      expect(report, contains('## Debug Core Validation'));
      expect(report, contains('## Debug Context-Only Validation'));
      expect(report, contains('## Blocked Bridge Field Validation'));
      expect(report, contains('## Phase 32V Recommendation'));
      expect(report, contains('proceedToDebugBridgeDesignReadinessGate'));
    });

    test('JSON report is deterministic and valid', () {
      final result = _safeResult();
      final decoded =
          jsonDecode(result.renderJsonReport()) as Map<String, Object?>;

      expect(
        decoded['version'],
        debugOnlyAdapterBridgeDesignValidationReportVersion,
      );
      expect(decoded['validationStatus'], 'validatedWithWarnings');
      expect(decoded['totalChecks'], 15);
      expect(decoded['totalGroupRows'], 8);
      expect(decoded['totalRecordRows'], 8);
      expect(decoded['validDebugCoreInputCount'], 1);
      expect(decoded['validDebugContextInputCount'], 1);
      expect(decoded['validInactiveBlockedInputCount'], 1);
      expect(decoded['validInactiveFutureOnlyInputCount'], 1);
      expect(decoded['safeForPhase32V'], isTrue);
      expect(
        decoded['phase32VRecommendation'],
        'proceedToDebugBridgeDesignReadinessGate',
      );
    });

    test('reports contain no raw logs, active labels, scores, or rankings', () {
      final report = _safeResult().renderMarkdownReport();

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
        'numeric move score:',
        'scoreValue',
        'moveScore',
        'rankedMoves',
        'moveRanking active',
        'official accuracy active',
        'ACPL active',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('source imports stay clear of runtime integration seams', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(imports, isNot(contains('dart:ffi')));
      expect(imports.toLowerCase(), isNot(contains('stockfish')));
      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('Widget')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('persistence')));
      expect(imports, isNot(contains('cache')));
      expect(imports, isNot(contains('database')));
    });
  });
}

DebugOnlyAdapterBridgeDesignValidationResult _safeResult([
  DebugOnlyAdapterBridgeDesignValidationRequest request =
      const DebugOnlyAdapterBridgeDesignValidationRequest(),
]) {
  return const DebugOnlyAdapterBridgeDesignValidation().evaluate(request);
}

DebugOnlyAdapterBridgeRecordValidationRow _withSafety(
  DebugOnlyAdapterBridgeRecordValidationRow row,
  String key,
) {
  return row.copyWith(
    safetyFlags: <String, bool>{...row.safetyFlags, key: true},
  );
}

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

const _allowedBridgeFieldIds = <String>[
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

const _blockedBridgeFieldIds = <String>[
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
