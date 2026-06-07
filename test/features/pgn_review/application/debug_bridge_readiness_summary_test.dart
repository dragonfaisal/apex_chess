@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug Bridge Readiness Summary', () {
    test('consumes safe Phase 32V readiness gate with warning status', () {
      final result = _safeResult();

      expect(
        result.summaryStatus,
        DebugBridgeReadinessSummaryStatus.summarizedWithWarnings,
      );
      expect(
        result.sourceReadinessStatus,
        DebugBridgeDesignReadinessGateStatus.readyWithWarnings,
      );
      expect(result.safeForPhase32X, isTrue);
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.debugBridgePrototypeImplemented, isFalse);
    });

    test('unsafe bridge readiness blocks summary', () {
      final unsafeReadiness = const DebugBridgeDesignReadinessGate()
          .evaluate()
          .copyWith(
            readinessStatus: DebugBridgeDesignReadinessGateStatus
                .blockedByBridgeValidationFailure,
            unsafeCount: 1,
            safeForPhase32W: false,
          );
      final result = _safeResult(
        DebugBridgeReadinessSummaryRequest(
          readinessGateResult: unsafeReadiness,
        ),
      );

      expect(
        result.summaryStatus,
        DebugBridgeReadinessSummaryStatus.blockedByUnsafeReadiness,
      );
      expect(result.safeForPhase32X, isFalse);
      expect(
        result.hasUnsafeDebugBridgeReadinessSummaryPolicyViolation,
        isTrue,
      );
    });

    test('summary groups preserve readiness boundaries', () {
      final result = _safeResult();

      expect(
        result
            .group(
              DebugBridgeReadinessSummaryGroupId.readyDebugCoreInputSummary,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus.readyDebugCoreInputSummary,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessSummaryGroupId
                  .constrainedDebugContextInputSummary,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus
            .constrainedDebugContextInputSummary,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessSummaryGroupId
                  .inactiveDebugBlockedInputSummary,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus.inactiveDebugBlockedInputSummary,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessSummaryGroupId
                  .inactiveDebugFutureOnlyInputSummary,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus
            .inactiveDebugFutureOnlyInputSummary,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessSummaryGroupId.readyAllowedDebugFieldSummary,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus.readyAllowedDebugFieldSummary,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessSummaryGroupId.deniedBlockedDebugFieldSummary,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus.deniedBlockedDebugFieldSummary,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessSummaryGroupId
                  .stockfishRawUciPvDumpBlockedSummary,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus
            .stockfishRawUciPvDumpBlockedSummary,
      );
      expect(
        result
            .group(
              DebugBridgeReadinessSummaryGroupId.androidProofBoundarySummary,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus.androidProofBoundarySummary,
      );
      expect(
        result
            .group(DebugBridgeReadinessSummaryGroupId.ownerProofStatusSummary)
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus.ownerProofStatusSummary,
      );
    });

    test('summary records preserve core context blocked and future roles', () {
      final result = _safeResult();

      expect(
        result
            .recordForRole(
              DebugBridgeReadinessSummaryRole.readyDebugCoreInputSummaryRecord,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus.readyDebugCoreInputSummary,
      );
      expect(
        result
            .recordForRole(
              DebugBridgeReadinessSummaryRole
                  .constrainedDebugContextInputSummaryRecord,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus
            .constrainedDebugContextInputSummary,
      );
      expect(
        result
            .recordForRole(
              DebugBridgeReadinessSummaryRole
                  .inactiveDebugBlockedInputSummaryRecord,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus.inactiveDebugBlockedInputSummary,
      );
      expect(
        result
            .recordForRole(
              DebugBridgeReadinessSummaryRole
                  .inactiveDebugFutureOnlyInputSummaryRecord,
            )
            .summaryStatus,
        DebugBridgeReadinessSummaryItemStatus
            .inactiveDebugFutureOnlyInputSummary,
      );
    });

    test('ready core and constrained context summaries are explicit', () {
      final result = _safeResult();
      final core = result.recordForRole(
        DebugBridgeReadinessSummaryRole.readyDebugCoreInputSummaryRecord,
      );
      final context = result.recordForRole(
        DebugBridgeReadinessSummaryRole
            .constrainedDebugContextInputSummaryRecord,
      );

      expect(core.allowedForFutureDebugPrototypePlanning, isTrue);
      expect(core.contextOnly, isFalse);
      expect(core.inactive, isFalse);
      expect(context.allowedForFutureDebugPrototypePlanning, isFalse);
      expect(context.contextOnly, isTrue);
      expect(context.inactive, isFalse);
    });

    test('blocked and future summaries remain inactive', () {
      final result = _safeResult();
      final blocked = result.recordForRole(
        DebugBridgeReadinessSummaryRole.inactiveDebugBlockedInputSummaryRecord,
      );
      final future = result.recordForRole(
        DebugBridgeReadinessSummaryRole
            .inactiveDebugFutureOnlyInputSummaryRecord,
      );

      expect(blocked.allowedForFutureDebugPrototypePlanning, isFalse);
      expect(blocked.inactive, isTrue);
      expect(blocked.activeFieldIds, isEmpty);
      expect(future.allowedForFutureDebugPrototypePlanning, isFalse);
      expect(future.inactive, isTrue);
      expect(future.activeFieldIds, isEmpty);
    });

    test('allowed and denied bridge fields preserve boundaries', () {
      final result = _safeResult();

      expect(result.allowedFieldIds, orderedEquals(_allowedBridgeFieldIds));
      expect(result.allowedFieldIds, isNot(contains('productLabel')));
      expect(result.allowedFieldIds, isNot(contains('stockfishCommand')));
      expect(result.deniedFieldIds, orderedEquals(_blockedBridgeFieldIds));
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

    test('Stockfish raw UCI and PV dump blocked summary is explicit', () {
      final result = _safeResult();
      final group = result.group(
        DebugBridgeReadinessSummaryGroupId.stockfishRawUciPvDumpBlockedSummary,
      );
      final record = result.recordForRole(
        DebugBridgeReadinessSummaryRole
            .stockfishRawUciPvDumpBlockedSummaryRecord,
      );

      expect(group.deniedFieldIds, orderedEquals(_engineDumpFieldIds));
      expect(record.deniedFieldIds, orderedEquals(_engineDumpFieldIds));
      expect(record.inactive, isTrue);
      expect(record.activeFieldIds, isEmpty);
    });

    test('Android proof and owner proof summary remain honest', () {
      final result = _safeResult();

      expect(result.androidProofCaseIds, _capturedAndroidProofIds);
      for (final phase32ECase in _phase32ECaseIds) {
        expect(result.androidProofCaseIds, isNot(contains(phase32ECase)));
      }
      expect(result.ownerProofQueueCount, 0);
    });

    test('no summary record emits product or integration output', () {
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
      for (final record in result.summaryRecords) {
        expect(record.safetyFlags.values.any((value) => value), isFalse);
      }
    });

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final proof = result
          .recordForRole(
            DebugBridgeReadinessSummaryRole.androidProofBoundarySummaryRecord,
          )
          .copyWith(
            androidProofCaseIds: const <String>[
              'mate-threat-fast-evidence',
              'unproven-proof-id',
              'pv-multipv-support-boundary-32e',
            ],
          );
      final findings = const DebugBridgeReadinessSummaryValidator().validate(
        result.copyWith(
          androidProofCaseIds: proof.androidProofCaseIds,
          summaryRecords: <DebugBridgeReadinessSummaryRecord>[proof],
        ),
      );
      final ids = findings.map((finding) => finding.id).toSet();

      expect(ids, contains('unprovenAndroidProofId'));
      expect(ids, contains('phase32ECaseTreatedAsCapturedProof'));
    });

    test('validator rejects active denied bridge fields', () {
      final result = _safeResult();
      final core = result
          .recordForRole(
            DebugBridgeReadinessSummaryRole.readyDebugCoreInputSummaryRecord,
          )
          .copyWith(activeFieldIds: const <String>['productLabel']);
      final findings = const DebugBridgeReadinessSummaryValidator().validate(
        result.copyWith(
          allowedFieldIds: core.activeFieldIds,
          summaryRecords: <DebugBridgeReadinessSummaryRecord>[core],
        ),
      );

      expect(
        findings.map((finding) => finding.id),
        contains('activeDeniedBridgeField'),
      );
    });

    test('validator rejects context-to-core and boundary activation', () {
      final result = _safeResult();
      final context = result
          .recordForRole(
            DebugBridgeReadinessSummaryRole
                .constrainedDebugContextInputSummaryRecord,
          )
          .copyWith(
            summaryRole: DebugBridgeReadinessSummaryRole
                .readyDebugCoreInputSummaryRecord,
          );
      final blocked = result
          .recordForRole(
            DebugBridgeReadinessSummaryRole
                .inactiveDebugBlockedInputSummaryRecord,
          )
          .copyWith(
            inactive: false,
            activeFieldIds: const <String>['debugBridgeRecordId'],
          );
      final future = result
          .recordForRole(
            DebugBridgeReadinessSummaryRole
                .inactiveDebugFutureOnlyInputSummaryRecord,
          )
          .copyWith(
            inactive: false,
            activeFieldIds: const <String>['debugBridgeRecordId'],
          );
      final findings = const DebugBridgeReadinessSummaryValidator().validate(
        result.copyWith(
          summaryRecords: <DebugBridgeReadinessSummaryRecord>[
            context,
            blocked,
            future,
          ],
        ),
      );
      final ids = findings.map((finding) => finding.id).toList();

      expect(ids, contains('contextOnlySummaryPromotedToDebugCore'));
      expect(
        ids.where((id) => id == 'blockedFutureSummaryMadeActive').length,
        2,
      );
    });

    test('validator rejects debug core summary consuming non-core input', () {
      final result = _safeResult();
      final core = result
          .recordForRole(
            DebugBridgeReadinessSummaryRole.readyDebugCoreInputSummaryRecord,
          )
          .copyWith(
            violationReasons: const <String>['debugCoreConsumesNonCoreInput'],
          );
      final findings = const DebugBridgeReadinessSummaryValidator().validate(
        result.copyWith(
          summaryRecords: <DebugBridgeReadinessSummaryRecord>[core],
        ),
      );

      expect(
        findings.map((finding) => finding.id),
        contains('debugCoreSummaryConsumesNonCoreInput'),
      );
    });

    test('validator rejects unsafe output and bridge integration seams', () {
      final result = _safeResult();
      final core = result.recordForRole(
        DebugBridgeReadinessSummaryRole.readyDebugCoreInputSummaryRecord,
      );
      final poisonedRecords = <DebugBridgeReadinessSummaryRecord>[
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
            (record) => const DebugBridgeReadinessSummaryValidator()
                .validate(
                  result.copyWith(
                    summaryRecords: <DebugBridgeReadinessSummaryRecord>[record],
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

    test('summary groups, records, and aggregates are deterministic', () {
      final result = _safeResult();

      expect(result.totalSummaryGroups, 9);
      expect(result.totalSummaryRecords, 9);
      expect(result.readyDebugCoreInputCount, 1);
      expect(result.constrainedDebugContextInputCount, 1);
      expect(result.inactiveBlockedInputCount, 1);
      expect(result.inactiveFutureOnlyInputCount, 1);
      expect(result.readyAllowedFieldCount, 14);
      expect(result.deniedBlockedFieldCount, 18);
      expect(result.unsafeCount, 0);
      expect(result.safeForPhase32X, isTrue);
      expect(
        result.phase32XRecommendation,
        DebugBridgeReadinessSummaryPhase32XRecommendation
            .proceedToDebugBridgeReadinessSummaryValidation,
      );
      expect(
        result.summaryGroups.map((group) => group.groupId.wire).toList(),
        orderedEquals(<String>[
          'readyDebugCoreInputSummary',
          'constrainedDebugContextInputSummary',
          'inactiveDebugBlockedInputSummary',
          'inactiveDebugFutureOnlyInputSummary',
          'readyAllowedDebugFieldSummary',
          'deniedBlockedDebugFieldSummary',
          'stockfishRawUciPvDumpBlockedSummary',
          'androidProofBoundarySummary',
          'ownerProofStatusSummary',
        ]),
      );
      expect(
        result.summaryRecords.map((record) => record.summaryRole.wire).toList(),
        orderedEquals(<String>[
          'readyDebugCoreInputSummaryRecord',
          'constrainedDebugContextInputSummaryRecord',
          'inactiveDebugBlockedInputSummaryRecord',
          'inactiveDebugFutureOnlyInputSummaryRecord',
          'readyAllowedDebugFieldSummaryRecord',
          'deniedBlockedDebugFieldSummaryRecord',
          'stockfishRawUciPvDumpBlockedSummaryRecord',
          'androidProofBoundarySummaryRecord',
          'ownerProofStatusSummaryRecord',
        ]),
      );
    });

    test('markdown report includes required summary sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(report, contains('## Summary Group Table'));
      expect(report, contains('## Summary Record Table'));
      expect(report, contains('## Ready Debug Core Summary'));
      expect(report, contains('## Constrained Debug Context Summary'));
      expect(report, contains('## Denied Blocked Field Summary'));
      expect(report, contains('## Stockfish Raw UCI PV Dump Blocked Summary'));
      expect(report, contains('## Phase 32X Recommendation'));
      expect(
        report,
        contains('proceedToDebugBridgeReadinessSummaryValidation'),
      );
    });

    test('JSON report is deterministic and valid', () {
      final result = _safeResult();
      final decoded =
          jsonDecode(result.renderJsonReport()) as Map<String, Object?>;

      expect(decoded['version'], debugBridgeReadinessSummaryReportVersion);
      expect(decoded['summaryStatus'], 'summarizedWithWarnings');
      expect(decoded['totalSummaryGroups'], 9);
      expect(decoded['totalSummaryRecords'], 9);
      expect(decoded['readyDebugCoreInputCount'], 1);
      expect(decoded['constrainedDebugContextInputCount'], 1);
      expect(decoded['readyAllowedFieldCount'], 14);
      expect(decoded['deniedBlockedFieldCount'], 18);
      expect(decoded['safeForPhase32X'], isTrue);
      expect(
        decoded['phase32XRecommendation'],
        'proceedToDebugBridgeReadinessSummaryValidation',
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
        'lib/features/pgn_review/application/debug_bridge_readiness_summary.dart',
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

DebugBridgeReadinessSummaryResult _safeResult([
  DebugBridgeReadinessSummaryRequest request =
      const DebugBridgeReadinessSummaryRequest(),
]) {
  return const DebugBridgeReadinessSummary().evaluate(request);
}

DebugBridgeReadinessSummaryRecord _withSafety(
  DebugBridgeReadinessSummaryRecord record,
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

const _engineDumpFieldIds = <String>['pvDump', 'rawUci', 'stockfishCommand'];
