@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debug-Only Bridge Prototype Design', () {
    test('consumes safe Phase 32Y gate with warning status', () {
      final result = _safeResult();

      expect(
        result.designStatus,
        DebugOnlyBridgePrototypeDesignStatus.designReadyWithWarnings,
      );
      expect(
        result.sourceGateStatus,
        DebugBridgeReadinessValidationGateStatus
            .readyForPrototypeDesignWithWarnings,
      );
      expect(result.safeForPhase33A, isTrue);
      expect(result.unsafeCount, 0);
      expect(result.blockerCount, 0);
      expect(result.criticalCount, 0);
      expect(result.ownerProofQueueCount, 0);
      expect(result.debugBridgeRuntimeImplemented, isFalse);
      expect(result.executableDebugBridgePrototypeImplemented, isFalse);
    });

    test('unsafe readiness gate blocks design', () {
      final unsafeGate = _cachedSafeGate.copyWith(
        gateStatus:
            DebugBridgeReadinessValidationGateStatus.blockedByPolicyBoundary,
        unsafeCount: 1,
        safeForPhase32Z: false,
      );
      final result = _safeResult(
        DebugOnlyBridgePrototypeDesignRequest(gateResult: unsafeGate),
      );

      expect(
        result.designStatus,
        DebugOnlyBridgePrototypeDesignStatus.blockedByReadinessGate,
      );
      expect(result.safeForPhase33A, isFalse);
      expect(
        result.hasUnsafeDebugOnlyBridgePrototypeDesignPolicyViolation,
        isTrue,
      );
    });

    test('design sections are deterministic and explicit', () {
      final result = _safeResult();

      expect(result.totalDesignSections, 10);
      expect(
        result
            .section(
              DebugOnlyBridgePrototypeDesignSectionId.prototypeCoreInputDesign,
            )
            .designStatus,
        DebugOnlyBridgePrototypeDesignSectionStatus.prototypeCoreInputDesign,
      );
      expect(
        result
            .section(
              DebugOnlyBridgePrototypeDesignSectionId
                  .prototypeContextInputDesign,
            )
            .designStatus,
        DebugOnlyBridgePrototypeDesignSectionStatus.prototypeContextInputDesign,
      );
      expect(
        result
            .section(
              DebugOnlyBridgePrototypeDesignSectionId
                  .stockfishRawUciPvDumpDeniedDesign,
            )
            .deniedFieldIds,
        orderedEquals(<String>['pvDump', 'rawUci', 'stockfishCommand']),
      );
      expect(
        result
            .section(
              DebugOnlyBridgePrototypeDesignSectionId
                  .futurePrototypeValidationRequirements,
            )
            .futurePrerequisites,
        contains('validateDebugOnlyBridgePrototypeDesign'),
      );
    });

    test(
      'design records preserve core context blocked and future boundaries',
      () {
        final result = _safeResult();
        final core = result.recordForRole(
          DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord,
        );
        final context = result.recordForRole(
          DebugOnlyBridgePrototypeDesignRole.prototypeContextInputDesignRecord,
        );
        final blocked = result.recordForRole(
          DebugOnlyBridgePrototypeDesignRole
              .prototypeInactiveBlockedInputDesignRecord,
        );
        final future = result.recordForRole(
          DebugOnlyBridgePrototypeDesignRole
              .prototypeInactiveFutureOnlyInputDesignRecord,
        );

        expect(result.totalDesignRecords, 10);
        expect(core.allowedForFuturePrototypeImplementation, isTrue);
        expect(core.designOnly, isTrue);
        expect(context.contextOnly, isTrue);
        expect(context.allowedForFuturePrototypeImplementation, isFalse);
        expect(blocked.inactive, isTrue);
        expect(blocked.allowedFieldIds, isEmpty);
        expect(future.inactive, isTrue);
        expect(future.allowedFieldIds, isEmpty);
      },
    );

    test('allowed and denied field design preserves boundaries', () {
      final result = _safeResult();

      expect(result.allowedFieldIds, orderedEquals(_allowedFieldIds));
      expect(result.allowedFieldIds, isNot(contains('productLabel')));
      expect(result.allowedFieldIds, isNot(contains('stockfishCommand')));
      expect(result.deniedFieldIds, orderedEquals(_deniedFieldIds));
      for (final fieldId in <String>[
        'productLabel',
        'finalMoveLabel',
        'brilliantGreatMissStyleLabels',
        'bestGoodInaccuracyMistakeBlunderStyleLabels',
        'numericMoveScore',
        'aggregateScore',
        'officialAccuracy',
        'acpl',
        'cpLoss',
        'winProbability',
        'moveRanking',
        'uiOutput',
        'backendOutput',
        'persistenceOutput',
        'directEngineCall',
        'stockfishCommand',
        'rawUci',
        'pvDump',
      ]) {
        expect(result.deniedFieldIds, contains(fieldId), reason: fieldId);
      }
    });

    test('Android proof and owner proof boundaries remain honest', () {
      final result = _safeResult();

      expect(
        result.androidProofCaseIds,
        orderedEquals(<String>[
          'mate-threat-fast-evidence',
          'queen-win-major-swing',
          'simple-tactical-capture-check',
        ]),
      );
      for (final phase32ECaseId in _phase32ECaseIds) {
        expect(result.androidProofCaseIds, isNot(contains(phase32ECaseId)));
      }
      expect(result.ownerProofQueueCount, 0);
    });

    test('aggregate counts and Phase 33A recommendation are deterministic', () {
      final result = _safeResult();

      expect(result.prototypeCoreDesignCount, 1);
      expect(result.prototypeContextDesignCount, 1);
      expect(result.inactiveBlockedDesignCount, 1);
      expect(result.inactiveFutureOnlyDesignCount, 1);
      expect(result.allowedFieldDesignCount, 14);
      expect(result.deniedFieldDesignCount, 18);
      expect(result.stockfishRawUciPvDumpDeniedCount, 3);
      expect(result.futureValidationRequirementCount, 1);
      expect(result.safeForPhase33A, isTrue);
      expect(
        result.phase33ARecommendation,
        DebugOnlyBridgePrototypeDesignPhase33ARecommendation
            .validateDebugOnlyBridgePrototypeDesign,
      );
    });

    test(
      'no design record emits product labels scores metrics or runtime flags',
      () {
        final result = _safeResult();

        for (final record in result.designRecords) {
          expect(record.designOnly, isTrue, reason: record.designRole.wire);
          expect(record.safetyFlags['isProductOutput'], isFalse);
          expect(record.safetyFlags['isClassifierLabel'], isFalse);
          expect(record.safetyFlags['hasNumericScore'], isFalse);
          expect(record.safetyFlags['hasAggregateScore'], isFalse);
          expect(record.safetyFlags['ranksMoves'], isFalse);
          expect(record.safetyFlags['isOfficialMetric'], isFalse);
          expect(record.safetyFlags['exposesCpLoss'], isFalse);
          expect(record.safetyFlags['exposesWinProbability'], isFalse);
          expect(record.safetyFlags['callsEngine'], isFalse);
          expect(record.safetyFlags['writesPersistence'], isFalse);
          expect(record.safetyFlags['targetsUi'], isFalse);
          expect(record.safetyFlags['exposesStockfishCommand'], isFalse);
          expect(record.safetyFlags['exposesRawUci'], isFalse);
          expect(record.safetyFlags['exposesPvDump'], isFalse);
          expect(record.safetyFlags['implementsRuntime'], isFalse);
          expect(record.safetyFlags['implementsPrototypeExecution'], isFalse);
        }
      },
    );

    test('validator rejects Android proof violations', () {
      final result = _safeResult();
      final proof = result
          .recordForRole(
            DebugOnlyBridgePrototypeDesignRole.androidProofBoundaryDesignRecord,
          )
          .copyWith(androidProofCaseIds: const <String>['fake-proof']);
      final phase32EProof = proof.copyWith(
        androidProofCaseIds: const <String>[
          'budget-pressure-wide-candidate-32e',
        ],
      );

      expect(
        _findingIds(_validate(_replaceRecord(result, proof))),
        contains('unprovenAndroidProofId'),
      );
      expect(
        _findingIds(_validate(_replaceRecord(result, phase32EProof))),
        contains('phase32ECaseTreatedAsCapturedProof'),
      );
    });

    test('validator rejects context promotion and non-core core input', () {
      final result = _safeResult();
      final core = result
          .recordForRole(
            DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord,
          )
          .copyWith(sourceGateGroupId: 'constrainedDebugContextInputSummary');
      final context = result
          .recordForRole(
            DebugOnlyBridgePrototypeDesignRole
                .prototypeContextInputDesignRecord,
          )
          .copyWith(
            contextOnly: false,
            allowedForFuturePrototypeImplementation: true,
          );

      expect(
        _findingIds(_validate(_replaceRecord(result, core))),
        contains('prototypeCoreConsumesNonCoreInput'),
      );
      expect(
        _findingIds(_validate(_replaceRecord(result, context))),
        contains('contextOnlyInputPromotedToPrototypeCore'),
      );
    });

    test(
      'validator rejects blocked future activation and active denied fields',
      () {
        final result = _safeResult();
        final blocked = result
            .recordForRole(
              DebugOnlyBridgePrototypeDesignRole
                  .prototypeInactiveBlockedInputDesignRecord,
            )
            .copyWith(
              inactive: false,
              allowedFieldIds: const <String>['debugBridgeRecordId'],
            );
        final activeDenied = result
            .recordForRole(
              DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord,
            )
            .copyWith(allowedFieldIds: const <String>['productLabel']);

        expect(
          _findingIds(_validate(_replaceRecord(result, blocked))),
          contains('blockedFutureInputMadeActive'),
        );
        expect(
          _findingIds(_validate(_replaceRecord(result, activeDenied))),
          contains('activeDeniedField'),
        );
      },
    );

    test('validator rejects safety and implementation flags', () {
      final result = _safeResult();

      for (final entry in const <String, String>{
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
      }.entries) {
        final record = _withSafetyFlag(result, entry.key);
        expect(
          _findingIds(_validate(_replaceRecord(result, record))),
          contains(entry.value),
          reason: entry.key,
        );
      }
    });

    test(
      'markdown report includes required sections and no active output leaks',
      () {
        final report = _safeResult().renderMarkdownReport();

        expect(report, contains('## Design Section Table'));
        expect(report, contains('## Design Record Table'));
        expect(report, contains('## Prototype Core Input Design'));
        expect(report, contains('## Prototype Context Input Design'));
        expect(report, contains('## Stockfish Raw UCI PV Dump Denied Design'));
        expect(report, contains('## Future Phase 33A Validation Requirement'));
        expect(report, contains('validateDebugOnlyBridgePrototypeDesign'));
        _expectReportGuardrails(report);
      },
    );

    test('JSON report is deterministic and valid', () {
      final result = _safeResult();
      final first =
          jsonDecode(result.renderJsonReport()) as Map<String, Object?>;
      final second =
          jsonDecode(result.renderJsonReport()) as Map<String, Object?>;

      expect(first, equals(second));
      expect(first['version'], debugOnlyBridgePrototypeDesignReportVersion);
      expect(first['totalDesignSections'], 10);
      expect(first['totalDesignRecords'], 10);
      expect(first['safeForPhase33A'], isTrue);
    });

    test('source imports stay pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/debug_only_bridge_prototype_design.dart',
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

DebugOnlyBridgePrototypeDesignResult _safeResult([
  DebugOnlyBridgePrototypeDesignRequest? request,
]) {
  if (request != null) {
    return const DebugOnlyBridgePrototypeDesign().evaluate(request);
  }
  return _cachedSafeResult;
}

final DebugBridgeReadinessValidationGateResult _cachedSafeGate =
    const DebugBridgeReadinessValidationGate().evaluate(
      const DebugBridgeReadinessValidationGateRequest.safeDemo(),
    );

final DebugOnlyBridgePrototypeDesignResult _cachedSafeResult =
    const DebugOnlyBridgePrototypeDesign().evaluate(
      DebugOnlyBridgePrototypeDesignRequest(gateResult: _cachedSafeGate),
    );

List<DebugOnlyBridgePrototypeDesignFinding> _validate(
  DebugOnlyBridgePrototypeDesignResult result,
) {
  return const DebugOnlyBridgePrototypeDesignValidator().validate(result);
}

Set<String> _findingIds(List<DebugOnlyBridgePrototypeDesignFinding> findings) {
  return findings.map((finding) => finding.id).toSet();
}

DebugOnlyBridgePrototypeDesignResult _replaceRecord(
  DebugOnlyBridgePrototypeDesignResult result,
  DebugOnlyBridgePrototypeDesignRecord replacement,
) {
  return result.copyWith(
    designRecords: result.designRecords
        .map(
          (record) =>
              record.prototypeDesignRecordId ==
                  replacement.prototypeDesignRecordId
              ? replacement
              : record,
        )
        .toList(),
  );
}

DebugOnlyBridgePrototypeDesignRecord _withSafetyFlag(
  DebugOnlyBridgePrototypeDesignResult result,
  String flag,
) {
  final record = result.recordForRole(
    DebugOnlyBridgePrototypeDesignRole.prototypeCoreInputDesignRecord,
  );
  return record.copyWith(
    safetyFlags: <String, bool>{...record.safetyFlags, flag: true},
  );
}

void _expectReportGuardrails(String report) {
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
    'allowed fields: stockfishCommand',
    'scoreValue',
    'moveScore',
    'rankedMoves',
    'ACPL active',
    'official accuracy active',
    'runtime implemented: true',
    'executable debug bridge prototype implemented: true',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}

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

const _phase32ECaseIds = <String>[
  'budget-pressure-wide-candidate-32e',
  'endgame-precision-candidate-spread-32e',
  'king-safety-mating-net-pressure-32e',
  'pv-multipv-support-boundary-32e',
  'suppression-forced-only-legal-32e',
];
