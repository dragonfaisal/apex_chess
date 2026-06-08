@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug Bridge Readiness Validation Gate', () {
    test('consumes safe Phase 32X summary validation with warning status', () {
      final result = _safeResult();

      expect(
        result.gateStatus,
        DebugBridgeReadinessValidationGateStatus
            .readyForPrototypeDesignWithWarnings,
      );
      expect(
        result.sourceValidationStatus,
        DebugBridgeReadinessSummaryValidationStatus.validatedWithWarnings,
      );
      expect(result.safeForPhase32Z, isTrue);
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.debugBridgePrototypeImplemented, isFalse);
    });

    test('unsafe summary validation blocks gate', () {
      final unsafeValidation = const DebugBridgeReadinessSummaryValidation()
          .evaluate()
          .copyWith(
            validationStatus: DebugBridgeReadinessSummaryValidationStatus
                .blockedByUnsafeSummary,
            unsafeRecordCount: 1,
            safeForPhase32Y: false,
          );
      final result = _safeResult(
        DebugBridgeReadinessValidationGateRequest(
          validationResult: unsafeValidation,
        ),
      );

      expect(
        result.gateStatus,
        DebugBridgeReadinessValidationGateStatus
            .blockedBySummaryValidationFailure,
      );
      expect(result.safeForPhase32Z, isFalse);
      expect(
        result.hasUnsafeDebugBridgeReadinessValidationGatePolicyViolation,
        isTrue,
      );
    });

    test('gate groups preserve prototype and boundary roles', () {
      final result = _safeResult();

      expect(result.totalGateGroups, 9);
      expect(
        result
            .group(
              DebugBridgeReadinessValidationGateGroupId
                  .prototypeReadyDebugCoreGroup,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateGroupStatus
            .prototypeReadyDebugCoreGroup,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessValidationGateGroupId
                  .constrainedDebugContextGroup,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateGroupStatus
            .constrainedDebugContextGroup,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessValidationGateGroupId
                  .inactiveDebugBlockedGroup,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateGroupStatus.inactiveDebugBlockedGroup,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessValidationGateGroupId
                  .inactiveDebugFutureOnlyGroup,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateGroupStatus
            .inactiveDebugFutureOnlyGroup,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessValidationGateGroupId
                  .prototypeReadyAllowedFieldGroup,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateGroupStatus
            .prototypeReadyAllowedFieldGroup,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessValidationGateGroupId
                  .stockfishRawUciPvDumpDeniedGroup,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateGroupStatus
            .stockfishRawUciPvDumpDeniedGroup,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessValidationGateGroupId
                  .validatedAndroidProofBoundaryGroup,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateGroupStatus
            .validatedAndroidProofBoundaryGroup,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessValidationGateGroupId
                  .emptyOwnerProofGateGroup,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateGroupStatus.emptyOwnerProofGateGroup,
      );
    });

    test('gate records are deterministic and preserve safe roles', () {
      final result = _safeResult();

      expect(result.totalGateRecords, 9);
      expect(
        result
            .recordForRole(
              DebugBridgeReadinessValidationGateRole.prototypeReadyDebugCore,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateRecordStatus.prototypeReadyDebugCore,
      );
      expect(
        result
            .recordForRole(
              DebugBridgeReadinessValidationGateRole.constrainedDebugContext,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateRecordStatus.constrainedDebugContext,
      );
      expect(
        result
            .recordForRole(
              DebugBridgeReadinessValidationGateRole.inactiveDebugBlocked,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateRecordStatus.inactiveDebugBlocked,
      );
      expect(
        result
            .recordForRole(
              DebugBridgeReadinessValidationGateRole
                  .stockfishRawUciPvDumpDenied,
            )
            .gateStatus,
        DebugBridgeReadinessValidationGateRecordStatus
            .stockfishRawUciPvDumpDenied,
      );
    });

    test(
      'prototype core context blocked and future records keep boundaries',
      () {
        final result = _safeResult();
        final core = result.recordForRole(
          DebugBridgeReadinessValidationGateRole.prototypeReadyDebugCore,
        );
        final context = result.recordForRole(
          DebugBridgeReadinessValidationGateRole.constrainedDebugContext,
        );
        final blocked = result.recordForRole(
          DebugBridgeReadinessValidationGateRole.inactiveDebugBlocked,
        );
        final future = result.recordForRole(
          DebugBridgeReadinessValidationGateRole.inactiveDebugFutureOnly,
        );

        expect(core.allowedForFuturePrototypeDesign, isTrue);
        expect(core.contextOnly, isFalse);
        expect(context.allowedForFuturePrototypeDesign, isFalse);
        expect(context.contextOnly, isTrue);
        expect(blocked.inactive, isTrue);
        expect(blocked.allowedFieldIds, isEmpty);
        expect(future.inactive, isTrue);
        expect(future.allowedFieldIds, isEmpty);
      },
    );

    test('allowed and denied field gate behavior preserves boundaries', () {
      final result = _safeResult();

      expect(result.allowedFieldIds, orderedEquals(_allowedBridgeFieldIds));
      expect(result.allowedFieldIds, isNot(contains('productLabel')));
      expect(result.allowedFieldIds, isNot(contains('stockfishCommand')));
      expect(result.deniedFieldIds, orderedEquals(_deniedBridgeFieldIds));
      expect(result.deniedFieldIds, contains('productLabel'));
      expect(result.deniedFieldIds, contains('finalMoveLabel'));
      expect(result.deniedFieldIds, contains('brilliantGreatMissStyleLabels'));
      expect(
        result.deniedFieldIds,
        contains('bestGoodInaccuracyMistakeBlunderStyleLabels'),
      );
      expect(result.deniedFieldIds, contains('numericMoveScore'));
      expect(result.deniedFieldIds, contains('aggregateScore'));
      expect(result.deniedFieldIds, contains('officialAccuracy'));
      expect(result.deniedFieldIds, contains('acpl'));
      expect(result.deniedFieldIds, contains('cpLoss'));
      expect(result.deniedFieldIds, contains('winProbability'));
      expect(result.deniedFieldIds, contains('moveRanking'));
      expect(result.deniedFieldIds, contains('uiOutput'));
      expect(result.deniedFieldIds, contains('backendOutput'));
      expect(result.deniedFieldIds, contains('persistenceOutput'));
      expect(result.deniedFieldIds, contains('directEngineCall'));
      expect(result.deniedFieldIds, contains('stockfishCommand'));
      expect(result.deniedFieldIds, contains('rawUci'));
      expect(result.deniedFieldIds, contains('pvDump'));
    });

    test('Stockfish raw UCI and PV dump denied group is explicit', () {
      final result = _safeResult();
      final group = result.group(
        DebugBridgeReadinessValidationGateGroupId
            .stockfishRawUciPvDumpDeniedGroup,
      );
      final record = result.recordForRole(
        DebugBridgeReadinessValidationGateRole.stockfishRawUciPvDumpDenied,
      );

      expect(group.allowedFieldIds, isEmpty);
      expect(group.deniedFieldIds, orderedEquals(_engineDumpFieldIds));
      expect(record.deniedFieldIds, orderedEquals(_engineDumpFieldIds));
      expect(result.stockfishCommandFieldActive, isFalse);
      expect(result.rawUciFieldActive, isFalse);
      expect(result.pvDumpFieldActive, isFalse);
    });

    test('Android proof and owner proof gate status remain honest', () {
      final result = _safeResult();

      expect(result.androidProofCaseIds, _capturedAndroidProofIds);
      for (final phase32ECase in _phase32ECaseIds) {
        expect(result.androidProofCaseIds, isNot(contains(phase32ECase)));
      }
      expect(result.ownerProofQueueCount, 0);
    });

    test('aggregate counts and Phase 32Z recommendation are deterministic', () {
      final result = _safeResult();

      expect(result.prototypeReadyDebugCoreCount, 1);
      expect(result.constrainedDebugContextCount, 1);
      expect(result.inactiveBlockedCount, 1);
      expect(result.inactiveFutureOnlyCount, 1);
      expect(result.prototypeReadyAllowedFieldCount, 14);
      expect(result.deniedFieldCount, 18);
      expect(result.stockfishRawUciPvDumpDeniedCount, 3);
      expect(result.safeForPhase32Z, isTrue);
      expect(
        result.phase32ZRecommendation,
        DebugBridgeReadinessValidationGatePhase32ZRecommendation
            .proceedToDebugOnlyBridgePrototypeDesign,
      );
    });

    test('no gate record emits product or integration output', () {
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
      for (final record in result.gateRecords) {
        expect(record.safetyFlags.values.any((value) => value), isFalse);
      }
    });

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final validator = const DebugBridgeReadinessValidationGateValidator();

      expect(
        validator
            .validate(
              result.copyWith(
                androidProofCaseIds: const <String>['unproven-debug-proof'],
              ),
            )
            .map((finding) => finding.id),
        contains('unprovenAndroidProofId'),
      );
      expect(
        validator
            .validate(
              result.copyWith(
                androidProofCaseIds: const <String>[
                  'pv-multipv-support-boundary-32e',
                ],
              ),
            )
            .map((finding) => finding.id),
        contains('phase32ECaseTreatedAsCapturedProof'),
      );
    });

    test(
      'validator rejects context promotion and non-core prototype input',
      () {
        final result = _safeResult();
        final records = result.gateRecords
            .map(
              (record) =>
                  record.gateRole ==
                      DebugBridgeReadinessValidationGateRole
                          .prototypeReadyDebugCore
                  ? record.copyWith(
                      contextOnly: true,
                      violationReasons: const <String>[
                        'prototypeCoreConsumesNonCoreInput',
                      ],
                    )
                  : record,
            )
            .toList(growable: false);
        final findings = const DebugBridgeReadinessValidationGateValidator()
            .validate(result.copyWith(gateRecords: records));
        final ids = findings.map((finding) => finding.id).toSet();

        expect(ids, contains('prototypeReadyCoreConsumesNonCoreInput'));
        expect(ids, contains('contextOnlyInputPromotedToPrototypeReadyCore'));
      },
    );

    test(
      'validator rejects blocked future activation and active denied field',
      () {
        final result = _safeResult();
        final records = result.gateRecords
            .map(
              (record) =>
                  record.gateRole ==
                      DebugBridgeReadinessValidationGateRole
                          .inactiveDebugBlocked
                  ? record.copyWith(
                      inactive: false,
                      allowedFieldIds: const <String>['debugBridgeRecordId'],
                    )
                  : record,
            )
            .toList(growable: false);
        final findings = const DebugBridgeReadinessValidationGateValidator()
            .validate(
              result.copyWith(
                gateRecords: records,
                allowedFieldIds: const <String>['productLabel'],
              ),
            );
        final ids = findings.map((finding) => finding.id).toSet();

        expect(ids, contains('blockedFutureInputMadeActive'));
        expect(ids, contains('activeDeniedField'));
      },
    );

    test('validator rejects policy and safety flags', () {
      final result = _safeResult();
      final validator = const DebugBridgeReadinessValidationGateValidator();
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
      };

      for (final entry in flags.entries) {
        final records = result.gateRecords
            .map(
              (record) =>
                  record.gateRole ==
                      DebugBridgeReadinessValidationGateRole
                          .prototypeReadyDebugCore
                  ? record.copyWith(
                      safetyFlags: <String, bool>{entry.key: true},
                    )
                  : record,
            )
            .toList(growable: false);
        expect(
          validator
              .validate(result.copyWith(gateRecords: records))
              .map((finding) => finding.id),
          contains(entry.value),
          reason: entry.key,
        );
      }
    });

    test('global blocked integration flags are rejected', () {
      final result = _safeResult().copyWith(
        uiTargetsActive: true,
        backendOutputActive: true,
        persistenceWritesActive: true,
        engineCallsActive: true,
        stockfishCommandFieldActive: true,
        rawUciFieldActive: true,
        pvDumpFieldActive: true,
      );

      expect(
        const DebugBridgeReadinessValidationGateValidator()
            .validate(result)
            .map((finding) => finding.id),
        contains('debugBridgeReadinessValidationGateBoundaryPolicyViolation'),
      );
    });

    test('markdown report includes required gate sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(report, contains('# Debug Bridge Readiness Validation Gate'));
      expect(report, contains('## Gate Group Table'));
      expect(report, contains('## Gate Record Table'));
      expect(report, contains('## Prototype-Ready Debug Core Records'));
      expect(report, contains('## Constrained Debug Context Records'));
      expect(report, contains('## Allowed And Denied Field Boundaries'));
      expect(report, contains('## Stockfish Raw UCI PV Dump Denied Boundary'));
      expect(report, contains('## Phase 32Z Recommendation'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _safeResult().renderJsonReport();
      final second = _safeResult().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        debugBridgeReadinessValidationGateReportVersion,
      );
      expect(decoded['totalGateGroups'], 9);
      expect(decoded['totalGateRecords'], 9);
      expect(decoded['prototypeReadyAllowedFieldCount'], 14);
      expect(decoded['deniedFieldCount'], 18);
      expect(decoded['stockfishRawUciPvDumpDeniedCount'], 3);
      expect(decoded['safeForPhase32Z'], isTrue);
    });

    test('reports contain no raw UCI spam or active product outputs', () {
      final report = _safeResult().renderMarkdownReport();

      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        'pv e2e4',
        'pvMoves',
        'allowed fields: productLabel',
        'allowed fields: finalMoveLabel',
        'allowed fields: numericMoveScore',
        'numeric move score:',
        'scoreValue',
        'moveScore',
        'rankedMoves',
        'moveRanking active',
        'ACPL active',
        'official accuracy active',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
      expect(
        const DebugBridgeReadinessValidationGateValidator().validateReportText(
          report,
        ),
        isEmpty,
      );
    });

    test('source imports do not cross blocked integration boundaries', () {
      final source = File(
        'lib/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart',
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

DebugBridgeReadinessValidationGateResult _safeResult([
  DebugBridgeReadinessValidationGateRequest? request,
]) {
  return const DebugBridgeReadinessValidationGate().evaluate(
    request ?? const DebugBridgeReadinessValidationGateRequest.safeDemo(),
  );
}

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

const _deniedBridgeFieldIds = <String>[
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
