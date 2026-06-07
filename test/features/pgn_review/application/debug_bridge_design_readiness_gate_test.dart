@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug Bridge Design Readiness Gate', () {
    test('consumes safe Phase 32U validation with warning status', () {
      final result = _safeResult();

      expect(
        result.readinessStatus,
        DebugBridgeDesignReadinessGateStatus.readyWithWarnings,
      );
      expect(
        result.sourceValidationStatus,
        DebugOnlyAdapterBridgeDesignValidationStatus.validatedWithWarnings,
      );
      expect(result.safeForPhase32W, isTrue);
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('unsafe bridge validation blocks readiness', () {
      final unsafeValidation = const DebugOnlyAdapterBridgeDesignValidation()
          .evaluate()
          .copyWith(
            validationStatus: DebugOnlyAdapterBridgeDesignValidationStatus
                .blockedByUnsafeBridgeDesign,
            unsafeRecordCount: 1,
            safeForPhase32V: false,
          );
      final result = _safeResult(
        DebugBridgeDesignReadinessGateRequest(
          validationResult: unsafeValidation,
        ),
      );

      expect(
        result.readinessStatus,
        DebugBridgeDesignReadinessGateStatus.blockedByBridgeValidationFailure,
      );
      expect(result.safeForPhase32W, isFalse);
      expect(result.hasUnsafeDebugBridgeReadinessPolicyViolation, isTrue);
    });

    test('readiness groups preserve bridge validation boundaries', () {
      final result = _safeResult();

      expect(
        result
            .group(DebugBridgeDesignReadinessGroupId.readyDebugCoreInputGroup)
            .readinessStatus,
        DebugBridgeDesignReadinessGroupStatus.readyDebugCoreInputGroup,
      );
      expect(
        result
            .group(
              DebugBridgeDesignReadinessGroupId
                  .constrainedDebugContextInputGroup,
            )
            .readinessStatus,
        DebugBridgeDesignReadinessGroupStatus.constrainedDebugContextInputGroup,
      );
      expect(
        result
            .group(
              DebugBridgeDesignReadinessGroupId.inactiveDebugBlockedInputGroup,
            )
            .readinessStatus,
        DebugBridgeDesignReadinessGroupStatus.inactiveDebugBlockedInputGroup,
      );
      expect(
        result
            .group(
              DebugBridgeDesignReadinessGroupId
                  .inactiveDebugFutureOnlyInputGroup,
            )
            .readinessStatus,
        DebugBridgeDesignReadinessGroupStatus.inactiveDebugFutureOnlyInputGroup,
      );
      expect(
        result
            .group(
              DebugBridgeDesignReadinessGroupId.readyAllowedDebugFieldGroup,
            )
            .readinessStatus,
        DebugBridgeDesignReadinessGroupStatus.readyAllowedDebugFieldGroup,
      );
      expect(
        result
            .group(
              DebugBridgeDesignReadinessGroupId.deniedBlockedDebugFieldGroup,
            )
            .readinessStatus,
        DebugBridgeDesignReadinessGroupStatus.deniedBlockedDebugFieldGroup,
      );
      expect(
        result
            .group(
              DebugBridgeDesignReadinessGroupId.validatedProofBoundaryGroup,
            )
            .readinessStatus,
        DebugBridgeDesignReadinessGroupStatus.validatedProofBoundaryGroup,
      );
      expect(
        result
            .group(DebugBridgeDesignReadinessGroupId.emptyOwnerProofStatusGroup)
            .readinessStatus,
        DebugBridgeDesignReadinessGroupStatus.emptyOwnerProofStatusGroup,
      );
    });

    test(
      'readiness records preserve core context blocked and future roles',
      () {
        final result = _safeResult();

        expect(
          result
              .recordForRole(DebugBridgeDesignReadinessRole.readyDebugCoreInput)
              .readinessStatus,
          DebugBridgeDesignReadinessRecordStatus.readyDebugCoreInput,
        );
        expect(
          result
              .recordForRole(
                DebugBridgeDesignReadinessRole.constrainedDebugContextInput,
              )
              .readinessStatus,
          DebugBridgeDesignReadinessRecordStatus.constrainedDebugContextInput,
        );
        expect(
          result
              .recordForRole(
                DebugBridgeDesignReadinessRole.inactiveDebugBlockedInput,
              )
              .readinessStatus,
          DebugBridgeDesignReadinessRecordStatus.inactiveDebugBlockedInput,
        );
        expect(
          result
              .recordForRole(
                DebugBridgeDesignReadinessRole.inactiveDebugFutureOnlyInput,
              )
              .readinessStatus,
          DebugBridgeDesignReadinessRecordStatus.inactiveDebugFutureOnlyInput,
        );
      },
    );

    test('ready core and constrained context records are explicit', () {
      final result = _safeResult();
      final core = result.recordForRole(
        DebugBridgeDesignReadinessRole.readyDebugCoreInput,
      );
      final context = result.recordForRole(
        DebugBridgeDesignReadinessRole.constrainedDebugContextInput,
      );

      expect(core.allowedForFutureDebugPrototype, isTrue);
      expect(core.contextOnly, isFalse);
      expect(core.inactive, isFalse);
      expect(context.allowedForFutureDebugPrototype, isFalse);
      expect(context.contextOnly, isTrue);
      expect(context.inactive, isFalse);
    });

    test('blocked and future readiness records remain inactive', () {
      final result = _safeResult();
      final blocked = result.recordForRole(
        DebugBridgeDesignReadinessRole.inactiveDebugBlockedInput,
      );
      final future = result.recordForRole(
        DebugBridgeDesignReadinessRole.inactiveDebugFutureOnlyInput,
      );

      expect(blocked.allowedForFutureDebugPrototype, isFalse);
      expect(blocked.inactive, isTrue);
      expect(blocked.activeFieldIds, isEmpty);
      expect(future.allowedForFutureDebugPrototype, isFalse);
      expect(future.inactive, isTrue);
      expect(future.activeFieldIds, isEmpty);
    });

    test('allowed and denied bridge fields preserve boundaries', () {
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
    });

    test('Android proof and owner proof readiness remain honest', () {
      final result = _safeResult();

      expect(result.androidProofCaseIds, _capturedAndroidProofIds);
      for (final phase32ECase in _phase32ECaseIds) {
        expect(result.androidProofCaseIds, isNot(contains(phase32ECase)));
      }
      expect(result.ownerProofQueueCount, 0);
    });

    test('no readiness record emits product or integration output', () {
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
      for (final record in result.readinessRecords) {
        expect(record.safetyFlags.values.any((value) => value), isFalse);
      }
    });

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final proof = result
          .recordForRole(DebugBridgeDesignReadinessRole.validatedProofBoundary)
          .copyWith(
            androidProofCaseIds: const <String>[
              'mate-threat-fast-evidence',
              'unproven-proof-id',
              'pv-multipv-support-boundary-32e',
            ],
          );
      final findings = const DebugBridgeDesignReadinessGateValidator().validate(
        result.copyWith(
          androidProofCaseIds: proof.androidProofCaseIds,
          readinessRecords: <DebugBridgeDesignReadinessRecord>[proof],
        ),
      );
      final ids = findings.map((finding) => finding.id).toSet();

      expect(ids, contains('unprovenAndroidProofId'));
      expect(ids, contains('phase32ECaseTreatedAsCapturedProof'));
    });

    test('validator rejects active blocked bridge fields', () {
      final result = _safeResult();
      final core = result
          .recordForRole(DebugBridgeDesignReadinessRole.readyDebugCoreInput)
          .copyWith(activeFieldIds: const <String>['productLabel']);
      final findings = const DebugBridgeDesignReadinessGateValidator().validate(
        result.copyWith(
          allowedFieldIds: core.activeFieldIds,
          readinessRecords: <DebugBridgeDesignReadinessRecord>[core],
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
          .recordForRole(
            DebugBridgeDesignReadinessRole.constrainedDebugContextInput,
          )
          .copyWith(
            readinessRole: DebugBridgeDesignReadinessRole.readyDebugCoreInput,
          );
      final blocked = result
          .recordForRole(
            DebugBridgeDesignReadinessRole.inactiveDebugBlockedInput,
          )
          .copyWith(
            inactive: false,
            activeFieldIds: const <String>['debugBridgeRecordId'],
          );
      final future = result
          .recordForRole(
            DebugBridgeDesignReadinessRole.inactiveDebugFutureOnlyInput,
          )
          .copyWith(
            inactive: false,
            activeFieldIds: const <String>['debugBridgeRecordId'],
          );
      final findings = const DebugBridgeDesignReadinessGateValidator().validate(
        result.copyWith(
          readinessRecords: <DebugBridgeDesignReadinessRecord>[
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
      final design = const DebugOnlyAdapterBridgeDesign().evaluate();
      final core = design
          .recordForRole(DebugOnlyAdapterBridgeRole.debugCoreInput)
          .copyWith(
            adapterPacketIds: const <String>[
              'packet-constrainedWatchListSummary',
            ],
          );
      final records = design.bridgeRecords
          .map(
            (record) =>
                record.bridgeRole == DebugOnlyAdapterBridgeRole.debugCoreInput
                ? core
                : record,
          )
          .toList(growable: false);
      final poisoned = _safeResult(
        DebugBridgeDesignReadinessGateRequest(
          designResult: design.copyWith(bridgeRecords: records),
        ),
      );
      final findings = const DebugBridgeDesignReadinessGateValidator().validate(
        poisoned.copyWith(safeForPhase32W: true),
      );

      expect(
        poisoned
            .recordForRole(DebugBridgeDesignReadinessRole.readyDebugCoreInput)
            .violationReasons,
        contains('debugCoreConsumesNonCoreInput'),
      );
      expect(
        findings.map((finding) => finding.id),
        contains('debugCoreConsumesNonCoreInput'),
      );
    });

    test('validator rejects unsafe output and bridge integration seams', () {
      final result = _safeResult();
      final core = result.recordForRole(
        DebugBridgeDesignReadinessRole.readyDebugCoreInput,
      );
      final poisonedRecords = <DebugBridgeDesignReadinessRecord>[
        _withSafety(core, 'isProductOutput'),
        _withSafety(core, 'isClassifierLabel'),
        _withSafety(core, 'hasNumericScore'),
        _withSafety(core, 'hasAggregateScore'),
        _withSafety(core, 'ranksMoves'),
        _withSafety(core, 'isOfficialMetric'),
        _withSafety(core, 'exposesCpLoss'),
        _withSafety(core, 'exposesWinProbability'),
        _withSafety(core, 'quietPreparatoryScopeActive'),
        _withSafety(core, 'callsEngine'),
        _withSafety(core, 'writesPersistence'),
        _withSafety(core, 'targetsUi'),
        _withSafety(core, 'backendOutputActive'),
        _withSafety(core, 'exposesStockfishCommand'),
        _withSafety(core, 'exposesRawUci'),
        _withSafety(core, 'exposesPvDump'),
      ];
      final ids = poisonedRecords
          .expand(
            (record) => const DebugBridgeDesignReadinessGateValidator()
                .validate(
                  result.copyWith(
                    readinessRecords: <DebugBridgeDesignReadinessRecord>[
                      record,
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

    test('readiness groups, records, and aggregates are deterministic', () {
      final result = _safeResult();

      expect(result.totalReadinessGroups, 8);
      expect(result.totalReadinessRecords, 8);
      expect(result.readyDebugCoreInputCount, 1);
      expect(result.constrainedDebugContextInputCount, 1);
      expect(result.inactiveBlockedInputCount, 1);
      expect(result.inactiveFutureOnlyInputCount, 1);
      expect(result.readyAllowedFieldCount, 14);
      expect(result.deniedBlockedFieldCount, 18);
      expect(result.unsafeCount, 0);
      expect(result.safeForPhase32W, isTrue);
      expect(
        result.phase32WRecommendation,
        DebugBridgeDesignReadinessPhase32WRecommendation
            .proceedToDebugBridgeReadinessSummary,
      );
      expect(
        result.readinessGroups.map((group) => group.groupId.wire).toList(),
        orderedEquals(<String>[
          'readyDebugCoreInputGroup',
          'constrainedDebugContextInputGroup',
          'inactiveDebugBlockedInputGroup',
          'inactiveDebugFutureOnlyInputGroup',
          'readyAllowedDebugFieldGroup',
          'deniedBlockedDebugFieldGroup',
          'validatedProofBoundaryGroup',
          'emptyOwnerProofStatusGroup',
        ]),
      );
      expect(
        result.readinessRecords
            .map((record) => record.readinessRole.wire)
            .toList(),
        orderedEquals(<String>[
          'readyDebugCoreInput',
          'constrainedDebugContextInput',
          'inactiveDebugBlockedInput',
          'inactiveDebugFutureOnlyInput',
          'readyAllowedDebugField',
          'deniedBlockedDebugField',
          'validatedProofBoundary',
          'emptyOwnerProofStatus',
        ]),
      );
    });

    test('markdown report includes required readiness sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(report, contains('## Readiness Group Table'));
      expect(report, contains('## Readiness Record Table'));
      expect(report, contains('## Ready Debug Core Inputs'));
      expect(report, contains('## Constrained Debug Context Inputs'));
      expect(report, contains('## Denied Blocked Fields'));
      expect(report, contains('## Stockfish Raw UCI PV Dump Blocked Status'));
      expect(report, contains('## Phase 32W Recommendation'));
      expect(report, contains('proceedToDebugBridgeReadinessSummary'));
    });

    test('JSON report is deterministic and valid', () {
      final result = _safeResult();
      final decoded =
          jsonDecode(result.renderJsonReport()) as Map<String, Object?>;

      expect(decoded['version'], debugBridgeDesignReadinessGateReportVersion);
      expect(decoded['readinessStatus'], 'readyWithWarnings');
      expect(decoded['totalReadinessGroups'], 8);
      expect(decoded['totalReadinessRecords'], 8);
      expect(decoded['readyDebugCoreInputCount'], 1);
      expect(decoded['constrainedDebugContextInputCount'], 1);
      expect(decoded['readyAllowedFieldCount'], 14);
      expect(decoded['deniedBlockedFieldCount'], 18);
      expect(decoded['safeForPhase32W'], isTrue);
      expect(
        decoded['phase32WRecommendation'],
        'proceedToDebugBridgeReadinessSummary',
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
        'lib/features/pgn_review/application/debug_bridge_design_readiness_gate.dart',
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

DebugBridgeDesignReadinessGateResult _safeResult([
  DebugBridgeDesignReadinessGateRequest request =
      const DebugBridgeDesignReadinessGateRequest(),
]) {
  return const DebugBridgeDesignReadinessGate().evaluate(request);
}

DebugBridgeDesignReadinessRecord _withSafety(
  DebugBridgeDesignReadinessRecord record,
  String key,
) {
  return record.copyWith(
    safetyFlags: <String, bool>{...record.safetyFlags, key: true},
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
