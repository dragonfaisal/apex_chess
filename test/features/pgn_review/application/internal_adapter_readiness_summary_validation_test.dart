@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Internal Adapter Readiness Summary Validation', () {
    test('consumes safe Phase 32R summary with default warning status', () {
      final result = _safeResult();

      expect(
        result.validationStatus,
        InternalAdapterReadinessSummaryValidationStatus.validatedWithWarnings,
      );
      expect(result.sourceSummaryStatus.wire, 'summarizedWithWarnings');
      expect(result.safeForPhase32T, isTrue);
      expect(result.unsafeSummaryCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('unsafe summary blocks validation', () {
      final unsafeSummary = const InternalAdapterReadinessSummary()
          .evaluate()
          .copyWith(
            summaryStatus:
                InternalAdapterReadinessSummaryStatus.blockedByUnsafeReadiness,
            unsafeCount: 1,
            safeForPhase32S: false,
          );
      final result = _safeResult(
        InternalAdapterReadinessSummaryValidationRequest(
          summaryResult: unsafeSummary,
        ),
      );

      expect(
        result.validationStatus,
        InternalAdapterReadinessSummaryValidationStatus.blockedByUnsafeSummary,
      );
      expect(result.safeForPhase32T, isFalse);
      expect(result.hasUnsafeAdapterSummaryValidationPolicyViolation, isTrue);
    });

    test(
      'allowed core summary validates with exactly allowed core packets',
      () {
        final result = _safeResult();
        final row = result.rowForGroup(
          InternalAdapterReadinessSummaryGroupId.allowedCorePacketSummary,
        );

        expect(
          row.validationStatus,
          InternalAdapterReadinessSummaryGroupValidationStatus
              .validAllowedCoreSummary,
        );
        expect(row.groupRecordIds, hasLength(2));
        expect(
          row.packetIds,
          containsAll(<String>[
            'packet-allowedEvidenceSummary',
            'packet-improvedSupportSummary',
          ]),
        );
        expect(
          row.packetIds,
          isNot(contains('packet-constrainedWatchListSummary')),
        );
        expect(row.safeForNextPhase, isTrue);
      },
    );

    test('constrained context summary validates with context-only packets', () {
      final result = _safeResult();
      final row = result.rowForGroup(
        InternalAdapterReadinessSummaryGroupId.constrainedContextPacketSummary,
      );

      expect(
        row.validationStatus,
        InternalAdapterReadinessSummaryGroupValidationStatus
            .validConstrainedContextSummary,
      );
      expect(
        row.packetIds,
        containsAll(<String>[
          'packet-constrainedWatchListSummary',
          'packet-proofLimitedSummary',
          'packet-warningLimitedSummary',
        ]),
      );
      expect(row.groupRecordIds, hasLength(3));
      expect(row.warningReason, contains('constrained'));
    });

    test('blocked and future-only summaries validate inactive', () {
      final result = _safeResult();
      final blocked = result.rowForGroup(
        InternalAdapterReadinessSummaryGroupId.inactiveBlockedPacketSummary,
      );
      final future = result.rowForGroup(
        InternalAdapterReadinessSummaryGroupId.inactiveFutureOnlyPacketSummary,
      );

      expect(
        blocked.validationStatus,
        InternalAdapterReadinessSummaryGroupValidationStatus
            .validInactiveBlockedSummary,
      );
      expect(blocked.packetIds, contains('packet-blockedBoundarySummary'));
      expect(blocked.activeOutputFieldIds, isEmpty);
      expect(
        future.validationStatus,
        InternalAdapterReadinessSummaryGroupValidationStatus
            .validInactiveFutureOnlySummary,
      );
      expect(future.packetIds, contains('packet-futureOnlySummary'));
      expect(future.activeOutputFieldIds, isEmpty);
    });

    test('active and blocked output field summaries validate boundaries', () {
      final result = _safeResult();
      final active = result.rowForGroup(
        InternalAdapterReadinessSummaryGroupId.allowedActiveOutputFieldSummary,
      );
      final blocked = result.rowForGroup(
        InternalAdapterReadinessSummaryGroupId.blockedOutputFieldSummary,
      );

      expect(
        active.validationStatus,
        InternalAdapterReadinessSummaryGroupValidationStatus
            .validActiveOutputFieldSummary,
      );
      expect(active.activeOutputFieldIds, hasLength(15));
      expect(active.activeOutputFieldIds, isNot(contains('productLabel')));
      expect(active.activeOutputFieldIds, isNot(contains('numericMoveScore')));
      expect(
        blocked.validationStatus,
        InternalAdapterReadinessSummaryGroupValidationStatus
            .validBlockedOutputFieldSummary,
      );
      expect(
        blocked.blockedOutputFieldIds,
        containsAll(_blockedOutputFieldIds),
      );
      expect(result.blockedOutputFieldIds, contains('productLabel'));
      expect(result.blockedOutputFieldIds, contains('finalMoveLabel'));
      expect(result.blockedOutputFieldIds, contains('numericMoveScore'));
      expect(result.blockedOutputFieldIds, contains('officialAccuracy'));
      expect(result.blockedOutputFieldIds, contains('acpl'));
      expect(result.blockedOutputFieldIds, contains('cpLoss'));
      expect(result.blockedOutputFieldIds, contains('winProbability'));
      expect(result.blockedOutputFieldIds, contains('moveRanking'));
      expect(result.blockedOutputFieldIds, contains('uiOutputFields'));
      expect(
        result.blockedOutputFieldIds,
        contains('backendPersistenceFields'),
      );
      expect(result.blockedOutputFieldIds, contains('directEngineCallFields'));
    });

    test('Android proof and owner proof boundaries validate', () {
      final result = _safeResult();
      final android = result.rowForGroup(
        InternalAdapterReadinessSummaryGroupId.androidProofBoundarySummary,
      );
      final owner = result.rowForGroup(
        InternalAdapterReadinessSummaryGroupId.ownerProofStatusSummary,
      );

      expect(
        android.validationStatus,
        InternalAdapterReadinessSummaryGroupValidationStatus
            .validAndroidProofBoundarySummary,
      );
      expect(result.androidProofCaseIds, _capturedAndroidProofIds);
      for (final phase32ECase in _phase32ECaseIds) {
        expect(result.androidProofCaseIds, isNot(contains(phase32ECase)));
      }
      expect(
        owner.validationStatus,
        InternalAdapterReadinessSummaryGroupValidationStatus
            .validOwnerProofStatusSummary,
      );
      expect(owner.ownerProofQueueCount, 0);
      expect(result.ownerProofQueueCount, 0);
    });

    test('allowed core summary containing non-core packet fails', () {
      final summary = const InternalAdapterReadinessSummary().evaluate();
      final contextRecord = summary.recordForPacket(
        'packet-constrainedWatchListSummary',
      );
      final poisonedSummary = summary.copyWith(
        records: <InternalAdapterReadinessSummaryRecord>[
          ...summary.records,
          contextRecord.copyWith(
            summaryRecordId: 'summary-poisoned-context-as-core',
            allowedForNextInternalStep: true,
            constrainedForContextOnly: false,
          ),
        ],
      );
      final result = _safeResult(
        InternalAdapterReadinessSummaryValidationRequest(
          summaryResult: poisonedSummary,
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('allowedCoreSummaryContainsNonCorePacket'),
      );
      expect(
        result.validationStatus,
        InternalAdapterReadinessSummaryValidationStatus.blockedByUnsafeSummary,
      );
    });

    test('validator rejects context-to-core promotion', () {
      final result = _safeResult();
      final row = result
          .rowForGroup(
            InternalAdapterReadinessSummaryGroupId
                .constrainedContextPacketSummary,
          )
          .copyWith(
            groupKind: InternalAdapterReadinessSummaryValidationGroupKind
                .allowedCoreSummary,
          );
      final findings =
          const InternalAdapterReadinessSummaryValidationValidator().validate(
            result.copyWith(
              groupRows: <InternalAdapterReadinessSummaryValidationRow>[
                for (final existing in result.groupRows)
                  existing.sourceSummaryGroupId == row.sourceSummaryGroupId
                      ? row
                      : existing,
              ],
            ),
          );

      expect(
        findings.map((finding) => finding.id),
        contains('contextOnlySummaryPromotedToAllowedCore'),
      );
    });

    test('validator rejects blocked and future summary activation', () {
      final result = _safeResult();
      final blocked = result
          .rowForGroup(
            InternalAdapterReadinessSummaryGroupId.inactiveBlockedPacketSummary,
          )
          .copyWith(activeOutputFieldIds: const <String>['supportCaseIds']);
      final future = result
          .rowForGroup(
            InternalAdapterReadinessSummaryGroupId
                .inactiveFutureOnlyPacketSummary,
          )
          .copyWith(activeOutputFieldIds: const <String>['supportCaseIds']);
      final findings =
          const InternalAdapterReadinessSummaryValidationValidator().validate(
            result.copyWith(
              groupRows: <InternalAdapterReadinessSummaryValidationRow>[
                for (final existing in result.groupRows)
                  existing.sourceSummaryGroupId == blocked.sourceSummaryGroupId
                      ? blocked
                      : existing.sourceSummaryGroupId ==
                            future.sourceSummaryGroupId
                      ? future
                      : existing,
              ],
            ),
          );

      expect(
        findings
            .where((finding) => finding.id == 'blockedFutureSummaryMadeActive')
            .length,
        2,
      );
    });

    test('policy flags stay inactive across summary validation rows', () {
      final result = _safeResult();

      expect(result.productOutputActive, isFalse);
      expect(result.classifierOutputActive, isFalse);
      expect(result.finalMoveLabelOutputActive, isFalse);
      expect(result.officialMetricOutputActive, isFalse);
      expect(result.cpLossOutputActive, isFalse);
      expect(result.winProbabilityOutputActive, isFalse);
      expect(result.numericOutputActive, isFalse);
      expect(result.moveRankingOutputActive, isFalse);
      expect(result.quietPreparatoryScopeActivated, isFalse);
      expect(result.engineCallsActive, isFalse);
      expect(result.persistenceWritesActive, isFalse);
      expect(result.uiTargetsActive, isFalse);
      expect(result.backendOutputActive, isFalse);
      for (final row in result.groupRows) {
        expect(row.isProductOutput, isFalse);
        expect(row.isClassifierLabel, isFalse);
        expect(row.hasNumericScore, isFalse);
        expect(row.ranksMoves, isFalse);
        expect(row.isOfficialMetric, isFalse);
        expect(row.callsEngine, isFalse);
        expect(row.writesPersistence, isFalse);
        expect(row.targetsUi, isFalse);
      }
    });

    test('validator rejects unsafe output and integration seams', () {
      final result = _safeResult();
      final row = result.rowForGroup(
        InternalAdapterReadinessSummaryGroupId.allowedCorePacketSummary,
      );
      final poisonedRows = <InternalAdapterReadinessSummaryValidationRow>[
        row.copyWith(isProductOutput: true),
        row.copyWith(isClassifierLabel: true),
        row.copyWith(hasNumericScore: true),
        row.copyWith(ranksMoves: true),
        row.copyWith(isOfficialMetric: true),
        row.copyWith(cpLossOutputActive: true),
        row.copyWith(winProbabilityOutputActive: true),
        row.copyWith(quietPreparatoryScopeActive: true),
        row.copyWith(callsEngine: true),
        row.copyWith(writesPersistence: true),
        row.copyWith(targetsUi: true),
      ];

      final ids = poisonedRows
          .expand(
            (poisoned) =>
                const InternalAdapterReadinessSummaryValidationValidator()
                    .validate(
                      result.copyWith(
                        groupRows:
                            <InternalAdapterReadinessSummaryValidationRow>[
                              poisoned,
                            ],
                      ),
                    )
                    .map((finding) => finding.id),
          )
          .toSet();

      expect(ids, contains('productOutputActive'));
      expect(ids, contains('classifierLabelOutputActive'));
      expect(ids, contains('numericScoreOutputActive'));
      expect(ids, contains('moveRankingOutputActive'));
      expect(ids, contains('officialMetricOutputActive'));
      expect(ids, contains('futureMetricOutputActive'));
      expect(ids, contains('quietPreparatoryScopeActivated'));
      expect(ids, contains('engineCallFlagActive'));
      expect(ids, contains('persistenceWriteFlagActive'));
      expect(ids, contains('uiTargetFlagActive'));
    });

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final android = result
          .rowForGroup(
            InternalAdapterReadinessSummaryGroupId.androidProofBoundarySummary,
          )
          .copyWith(
            androidProofCaseIds: const <String>[
              'mate-threat-fast-evidence',
              'unproven-proof-id',
              'pv-multipv-support-boundary-32e',
            ],
          );
      final findings =
          const InternalAdapterReadinessSummaryValidationValidator().validate(
            result.copyWith(
              androidProofCaseIds: android.androidProofCaseIds,
              groupRows: <InternalAdapterReadinessSummaryValidationRow>[
                android,
              ],
            ),
          );
      final ids = findings.map((finding) => finding.id).toSet();

      expect(ids, contains('unprovenAndroidProofId'));
      expect(ids, contains('phase32ECaseTreatedAsCapturedProof'));
    });

    test(
      'check rows, validation rows, and aggregate counts are deterministic',
      () {
        final result = _safeResult();

        expect(result.totalChecks, 14);
        expect(result.passedCheckCount, 11);
        expect(result.warningCheckCount, 3);
        expect(result.totalGroupRows, 8);
        expect(result.validAllowedCoreSummaryCount, 1);
        expect(result.validConstrainedContextSummaryCount, 1);
        expect(result.validInactiveBlockedSummaryCount, 1);
        expect(result.validInactiveFutureOnlySummaryCount, 1);
        expect(result.validActiveOutputFieldSummaryCount, 1);
        expect(result.validBlockedOutputFieldSummaryCount, 1);
        expect(result.validAndroidProofBoundarySummaryCount, 1);
        expect(result.validOwnerProofStatusSummaryCount, 1);
        expect(result.invalidSummaryCount, 0);
        expect(result.unsafeSummaryCount, 0);
        expect(
          result.checks.map((check) => check.checkId).toList(),
          orderedEquals(<String>[
            'activeOutputFieldsRemainInternalOnly',
            'allowedCoreSummaryMatchesReadinessGate',
            'androidProofBoundaryIsCapturedOnly',
            'blockedOutputFieldsRemainDenied',
            'constrainedContextSummaryMatchesReadinessGate',
            'inactiveBlockedSummaryMatchesReadinessGate',
            'inactiveFutureOnlySummaryMatchesReadinessGate',
            'noLabelsScoresRankingsMetrics',
            'noUiBackendPersistenceEngineFields',
            'ownerProofQueueRemainsEmpty',
            'phase32ECasesAreNotCapturedProof',
            'productBoundariesRemainBlocked',
            'quietScopeRemainsExcluded',
            'summaryConsumesReadinessGate',
          ]),
        );
        expect(
          result.groupRows.map((row) => row.sourceSummaryGroupId.wire).toList(),
          orderedEquals(<String>[
            'allowedCorePacketSummary',
            'constrainedContextPacketSummary',
            'inactiveBlockedPacketSummary',
            'inactiveFutureOnlyPacketSummary',
            'allowedActiveOutputFieldSummary',
            'blockedOutputFieldSummary',
            'androidProofBoundarySummary',
            'ownerProofStatusSummary',
          ]),
        );
        expect(
          result.phase32TRecommendation,
          InternalAdapterReadinessSummaryValidationPhase32TRecommendation
              .proceedToDebugOnlyAdapterBridgeDesign,
        );
      },
    );

    test('markdown report includes required sections', () {
      final report = _safeResult().renderMarkdownReport();

      expect(report, contains('## Validation Check Table'));
      expect(report, contains('## Summary Group Validation Table'));
      expect(report, contains('## Allowed Core Summary Validation'));
      expect(report, contains('## Constrained Context Summary Validation'));
      expect(report, contains('## Blocked Output Field Validation'));
      expect(report, contains('## Owner Proof Status Validation'));
      expect(report, contains('## Phase 32T Recommendation'));
      expect(report, contains('proceedToDebugOnlyAdapterBridgeDesign'));
    });

    test('JSON report is deterministic and valid', () {
      final result = _safeResult();
      final decoded =
          jsonDecode(result.renderJsonReport()) as Map<String, Object?>;

      expect(
        decoded['version'],
        internalAdapterReadinessSummaryValidationReportVersion,
      );
      expect(decoded['validationStatus'], 'validatedWithWarnings');
      expect(decoded['totalChecks'], 14);
      expect(decoded['totalGroupRows'], 8);
      expect(decoded['safeForPhase32T'], isTrue);
      expect(
        decoded['phase32TRecommendation'],
        'proceedToDebugOnlyAdapterBridgeDesign',
      );
    });

    test(
      'reports contain no raw UCI, PV dumps, active labels, scores, or rankings',
      () {
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
      },
    );

    test(
      'source imports stay clear of engine UI backend and persistence seams',
      () {
        final source = File(
          'lib/features/pgn_review/application/internal_adapter_readiness_summary_validation.dart',
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
      },
    );
  });
}

InternalAdapterReadinessSummaryValidationResult _safeResult([
  InternalAdapterReadinessSummaryValidationRequest request =
      const InternalAdapterReadinessSummaryValidationRequest(),
]) {
  return const InternalAdapterReadinessSummaryValidation().evaluate(request);
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

const _blockedOutputFieldIds = <String>[
  'productLabel',
  'finalMoveLabel',
  'brilliantGreatMissStyleLabels',
  'bestGoodInaccuracyMistakeBlunderStyleLabels',
  'numericMoveScore',
  'officialAccuracy',
  'acpl',
  'cpLoss',
  'winProbability',
  'moveRanking',
  'uiOutputFields',
  'backendPersistenceFields',
  'directEngineCallFields',
];
