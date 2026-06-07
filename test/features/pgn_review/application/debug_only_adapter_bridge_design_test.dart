@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug-Only Adapter Bridge Design', () {
    test('consumes safe Phase 32S validation with default warning status', () {
      final result = _safeResult();

      expect(
        result.designStatus,
        DebugOnlyAdapterBridgeDesignStatus.designReadyWithWarnings,
      );
      expect(
        result.sourceSummaryValidationStatus.wire,
        'validatedWithWarnings',
      );
      expect(result.safeForPhase32U, isTrue);
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('unsafe summary validation blocks bridge design', () {
      final unsafeValidation = const InternalAdapterReadinessSummaryValidation()
          .evaluate()
          .copyWith(
            validationStatus: InternalAdapterReadinessSummaryValidationStatus
                .blockedByUnsafeSummary,
            unsafeSummaryCount: 1,
            safeForPhase32T: false,
          );
      final result = _safeResult(
        DebugOnlyAdapterBridgeDesignRequest(
          summaryValidationResult: unsafeValidation,
        ),
      );

      expect(
        result.designStatus,
        DebugOnlyAdapterBridgeDesignStatus.blockedBySummaryValidationFailure,
      );
      expect(result.safeForPhase32U, isFalse);
      expect(result.hasUnsafeDebugBridgeDesignPolicyViolation, isTrue);
    });

    test(
      'debug core input group includes only validated allowed core output',
      () {
        final result = _safeResult();
        final group = result.group(
          DebugOnlyAdapterBridgeInputGroupId.debugCoreInputGroup,
        );
        final record = result.recordForRole(
          DebugOnlyAdapterBridgeRole.debugCoreInput,
        );

        expect(
          group.designStatus,
          DebugOnlyAdapterBridgeInputGroupStatus.debugCoreInputReady,
        );
        expect(
          group.packetIds,
          orderedEquals(<String>[
            'packet-allowedEvidenceSummary',
            'packet-improvedSupportSummary',
          ]),
        );
        expect(record.allowedForFutureDebugBridge, isTrue);
        expect(record.contextOnly, isFalse);
        expect(record.inactive, isFalse);
      },
    );

    test('debug context input group remains context-only', () {
      final result = _safeResult();
      final group = result.group(
        DebugOnlyAdapterBridgeInputGroupId.debugContextInputGroup,
      );
      final record = result.recordForRole(
        DebugOnlyAdapterBridgeRole.debugContextOnlyInput,
      );

      expect(
        group.packetIds,
        orderedEquals(<String>[
          'packet-constrainedWatchListSummary',
          'packet-proofLimitedSummary',
          'packet-warningLimitedSummary',
        ]),
      );
      expect(record.allowedForFutureDebugBridge, isTrue);
      expect(record.contextOnly, isTrue);
      expect(record.inactive, isFalse);
    });

    test('blocked and future-only input groups remain inactive', () {
      final result = _safeResult();
      final blocked = result.recordForRole(
        DebugOnlyAdapterBridgeRole.debugBlockedInput,
      );
      final future = result.recordForRole(
        DebugOnlyAdapterBridgeRole.debugFutureOnlyInput,
      );

      expect(
        blocked.adapterPacketIds,
        contains('packet-blockedBoundarySummary'),
      );
      expect(blocked.allowedForFutureDebugBridge, isFalse);
      expect(blocked.inactive, isTrue);
      expect(blocked.activeFieldIds, isEmpty);
      expect(future.adapterPacketIds, contains('packet-futureOnlySummary'));
      expect(future.allowedForFutureDebugBridge, isFalse);
      expect(future.inactive, isTrue);
      expect(future.activeFieldIds, isEmpty);
    });

    test('allowed and blocked bridge field groups are explicit', () {
      final result = _safeResult();
      final allowed = result.group(
        DebugOnlyAdapterBridgeInputGroupId.debugAllowedFieldGroup,
      );
      final blocked = result.group(
        DebugOnlyAdapterBridgeInputGroupId.debugBlockedFieldGroup,
      );

      expect(allowed.activeFieldIds, orderedEquals(_allowedBridgeFieldIds));
      expect(allowed.activeFieldIds, isNot(contains('productLabel')));
      expect(allowed.activeFieldIds, isNot(contains('numericMoveScore')));
      expect(blocked.blockedFieldIds, orderedEquals(_blockedBridgeFieldIds));
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

    test('Android proof and owner proof boundaries are preserved', () {
      final result = _safeResult();
      final proof = result.recordForRole(
        DebugOnlyAdapterBridgeRole.debugProofBoundary,
      );
      final owner = result.recordForRole(
        DebugOnlyAdapterBridgeRole.debugOwnerProofStatus,
      );

      expect(result.androidProofCaseIds, _capturedAndroidProofIds);
      expect(proof.androidProofCaseIds, _capturedAndroidProofIds);
      for (final phase32ECase in _phase32ECaseIds) {
        expect(result.androidProofCaseIds, isNot(contains(phase32ECase)));
      }
      expect(result.ownerProofQueueCount, 0);
      expect(owner.androidProofCaseIds, isEmpty);
    });

    test('no bridge record emits product or integration output', () {
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
      for (final record in result.bridgeRecords) {
        expect(record.isProductOutput, isFalse);
        expect(record.isClassifierLabel, isFalse);
        expect(record.hasNumericScore, isFalse);
        expect(record.hasAggregateScore, isFalse);
        expect(record.ranksMoves, isFalse);
        expect(record.isOfficialMetric, isFalse);
        expect(record.callsEngine, isFalse);
        expect(record.writesPersistence, isFalse);
        expect(record.targetsUi, isFalse);
      }
    });

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final proof = result
          .recordForRole(DebugOnlyAdapterBridgeRole.debugProofBoundary)
          .copyWith(
            androidProofCaseIds: const <String>[
              'mate-threat-fast-evidence',
              'unproven-proof-id',
              'pv-multipv-support-boundary-32e',
            ],
          );
      final findings = const DebugOnlyAdapterBridgeDesignValidator().validate(
        result.copyWith(
          androidProofCaseIds: proof.androidProofCaseIds,
          bridgeRecords: <DebugOnlyAdapterBridgeRecord>[proof],
        ),
      );
      final ids = findings.map((finding) => finding.id).toSet();

      expect(ids, contains('unprovenAndroidProofId'));
      expect(ids, contains('phase32ECaseTreatedAsCapturedProof'));
    });

    test('validator rejects active blocked bridge fields', () {
      final result = _safeResult();
      final core = result
          .recordForRole(DebugOnlyAdapterBridgeRole.debugCoreInput)
          .copyWith(activeFieldIds: const <String>['productLabel']);
      final findings = const DebugOnlyAdapterBridgeDesignValidator().validate(
        result.copyWith(
          allowedFieldIds: core.activeFieldIds,
          bridgeRecords: <DebugOnlyAdapterBridgeRecord>[core],
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
          .recordForRole(DebugOnlyAdapterBridgeRole.debugContextOnlyInput)
          .copyWith(bridgeRole: DebugOnlyAdapterBridgeRole.debugCoreInput);
      final blocked = result
          .recordForRole(DebugOnlyAdapterBridgeRole.debugBlockedInput)
          .copyWith(
            inactive: false,
            activeFieldIds: const <String>['debugBridgeRecordId'],
          );
      final future = result
          .recordForRole(DebugOnlyAdapterBridgeRole.debugFutureOnlyInput)
          .copyWith(
            inactive: false,
            activeFieldIds: const <String>['debugBridgeRecordId'],
          );
      final findings = const DebugOnlyAdapterBridgeDesignValidator().validate(
        result.copyWith(
          bridgeRecords: <DebugOnlyAdapterBridgeRecord>[
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

    test('validator rejects unsafe output and bridge integration seams', () {
      final result = _safeResult();
      final core = result.recordForRole(
        DebugOnlyAdapterBridgeRole.debugCoreInput,
      );
      final poisonedRecords = <DebugOnlyAdapterBridgeRecord>[
        core.copyWith(isProductOutput: true),
        core.copyWith(isClassifierLabel: true),
        core.copyWith(hasNumericScore: true),
        core.copyWith(hasAggregateScore: true),
        core.copyWith(ranksMoves: true),
        core.copyWith(isOfficialMetric: true),
        core.copyWith(cpLossOutputActive: true),
        core.copyWith(winProbabilityOutputActive: true),
        core.copyWith(quietPreparatoryScopeActive: true),
        core.copyWith(callsEngine: true),
        core.copyWith(writesPersistence: true),
        core.copyWith(targetsUi: true),
        core.copyWith(backendOutputActive: true),
        core.copyWith(stockfishCommandFieldActive: true),
        core.copyWith(rawUciFieldActive: true),
        core.copyWith(pvDumpFieldActive: true),
      ];
      final ids = poisonedRecords
          .expand(
            (record) => const DebugOnlyAdapterBridgeDesignValidator()
                .validate(
                  result.copyWith(
                    bridgeRecords: <DebugOnlyAdapterBridgeRecord>[record],
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

    test('bridge groups, records, and aggregates are deterministic', () {
      final result = _safeResult();

      expect(result.totalBridgeRecords, 8);
      expect(result.debugCoreInputCount, 1);
      expect(result.debugContextInputCount, 1);
      expect(result.debugBlockedInputCount, 1);
      expect(result.debugFutureOnlyInputCount, 1);
      expect(result.allowedFieldCount, 14);
      expect(result.blockedFieldCount, 18);
      expect(result.safeForPhase32U, isTrue);
      expect(
        result.phase32URecommendation,
        DebugOnlyAdapterBridgeDesignPhase32URecommendation
            .validateDebugOnlyAdapterBridgeDesign,
      );
      expect(
        result.inputGroups.map((group) => group.groupId.wire).toList(),
        orderedEquals(<String>[
          'debugCoreInputGroup',
          'debugContextInputGroup',
          'debugBlockedInputGroup',
          'debugFutureOnlyInputGroup',
          'debugAllowedFieldGroup',
          'debugBlockedFieldGroup',
          'debugProofBoundaryGroup',
          'debugOwnerProofStatusGroup',
        ]),
      );
      expect(
        result.bridgeRecords.map((record) => record.bridgeRole.wire).toList(),
        orderedEquals(<String>[
          'debugCoreInput',
          'debugContextOnlyInput',
          'debugBlockedInput',
          'debugFutureOnlyInput',
          'debugAllowedField',
          'debugBlockedField',
          'debugProofBoundary',
          'debugOwnerProofStatus',
        ]),
      );
    });

    test('markdown report includes required bridge design sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(report, contains('## Bridge Input Group Table'));
      expect(report, contains('## Bridge Contract Record Table'));
      expect(report, contains('## Debug Core Inputs'));
      expect(report, contains('## Debug Context-Only Inputs'));
      expect(report, contains('## Blocked Bridge Fields'));
      expect(report, contains('## Phase 32U Recommendation'));
      expect(report, contains('validateDebugOnlyAdapterBridgeDesign'));
    });

    test('JSON report is deterministic and valid', () {
      final result = _safeResult();
      final decoded =
          jsonDecode(result.renderJsonReport()) as Map<String, Object?>;

      expect(decoded['version'], debugOnlyAdapterBridgeDesignReportVersion);
      expect(decoded['designStatus'], 'designReadyWithWarnings');
      expect(decoded['totalBridgeRecords'], 8);
      expect(decoded['debugCoreInputCount'], 1);
      expect(decoded['debugContextInputCount'], 1);
      expect(decoded['debugBlockedInputCount'], 1);
      expect(decoded['debugFutureOnlyInputCount'], 1);
      expect(decoded['allowedFieldCount'], 14);
      expect(decoded['blockedFieldCount'], 18);
      expect(decoded['safeForPhase32U'], isTrue);
      expect(
        decoded['phase32URecommendation'],
        'validateDebugOnlyAdapterBridgeDesign',
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
        'lib/features/pgn_review/application/debug_only_adapter_bridge_design.dart',
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

DebugOnlyAdapterBridgeDesignResult _safeResult([
  DebugOnlyAdapterBridgeDesignRequest request =
      const DebugOnlyAdapterBridgeDesignRequest(),
]) {
  return const DebugOnlyAdapterBridgeDesign().evaluate(request);
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
