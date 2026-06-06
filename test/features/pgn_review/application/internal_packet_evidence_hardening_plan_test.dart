@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/golden_android_proof_evidence.dart';
import 'package:apex_chess/features/pgn_review/application/golden_analysis_suite.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_stability_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalPacketEvidenceHardeningPlan safe demo', () {
    test('consumes safe Phase 32C stability result', () {
      final stability = _stability();
      final result = _plan(stabilityResult: stability);

      expect(result.sourceStabilityStatus, stability.prototypeStatus);
      expect(
        result.sourceMatrixStatus,
        InternalPacketReviewAggregationMatrixStatus.readyWithWarnings,
      );
      expect(
        result.sourcePrototypeStatus,
        NarrowInternalNonLabelAnalysisPrototypeStatus
            .completedWithCoverageWarnings,
      );
      expect(result.safeForPhase32E, isTrue);
      expect(result.validationFindings, isEmpty);
    });

    test('default status is ready for targeted hardening', () {
      final result = _plan();

      expect(
        result.hardeningStatus,
        isIn(<InternalPacketEvidenceHardeningStatus>[
          InternalPacketEvidenceHardeningStatus.readyForTargetedHardening,
          InternalPacketEvidenceHardeningStatus.readyWithNarrowScope,
        ]),
      );
      expect(result.safeForPhase32E, isTrue);
      expect(result.criticalCount, 0);
    });

    test('aggregate counts and priorities are deterministic', () {
      final result = _plan();

      expect(result.totalTargets, 20);
      expect(result.preserveCount, 4);
      expect(result.addGoldenCoverageCount, 5);
      expect(result.proofLimitedCount, 1);
      expect(result.warningLimitedCount, 4);
      expect(result.blockedCount, 8);
      expect(result.futureOnlyCount, 2);
      expect(result.highPriorityCount, 0);
      expect(result.criticalCount, 0);
    });

    test('support case IDs and Phase 32E recommendation are deterministic', () {
      final first = _plan();
      final second = _plan();

      expect(first.supportCaseIds, second.supportCaseIds);
      expect(first.supportCaseIds, contains('mate-threat-fast-evidence'));
      expect(first.supportCaseIds, contains('queen-win-major-swing'));
      expect(first.supportCaseIds, contains('simple-tactical-capture-check'));
      expect(
        first.supportCaseIds,
        contains('king-safety-mating-net-hard-case'),
      );
      expect(
        first.supportCaseIds,
        contains('king-safety-mating-net-pressure-32e'),
      );
      expect(
        first.supportCaseIds,
        contains('endgame-precision-candidate-spread-32e'),
      );
      expect(
        first.supportCaseIds,
        contains('suppression-forced-only-legal-32e'),
      );
      expect(
        first.supportCaseIds,
        contains('budget-pressure-wide-candidate-32e'),
      );
      expect(first.supportCaseIds, contains('pv-multipv-support-boundary-32e'));
      expect(
        first.phase32ERecommendation,
        InternalPacketEvidencePhase32ERecommendation
            .addTargetedGoldenCoverageCases,
      );
    });
  });

  group('InternalPacketEvidenceHardeningPlan target actions', () {
    test('stable packets are preserved', () {
      _expectTarget(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        InternalPacketEvidenceHardeningActionType.preserveStablePacket,
        InternalPacketEvidenceHardeningPriority.none,
      );
      _expectTarget(
        InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
        InternalPacketEvidenceHardeningActionType.preserveStablePacket,
        InternalPacketEvidenceHardeningPriority.none,
      );
      _expectTarget(
        InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
        InternalPacketEvidenceHardeningActionType.preserveStablePacket,
        InternalPacketEvidenceHardeningPriority.none,
      );
    });

    test('forcing-line packet action is deterministic and supported', () {
      final target = _plan().target(
        InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
      );

      expect(
        target.recommendedAction,
        isIn(<InternalPacketEvidenceHardeningActionType>[
          InternalPacketEvidenceHardeningActionType.preserveStablePacket,
          InternalPacketEvidenceHardeningActionType.addGoldenCoverage,
        ]),
      );
      expect(
        target.supportCaseIds,
        contains('forcing-line-variation-hard-case'),
      );
    });

    test('PV and MultiPV packet remains warning-aware', () {
      final target = _plan().target(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
      );

      expect(
        target.currentStatus,
        InternalPacketStabilityStatus.stableWithWarnings,
      );
      expect(
        target.recommendedAction,
        InternalPacketEvidenceHardeningActionType.addGoldenCoverage,
      );
      expect(target.priority, InternalPacketEvidenceHardeningPriority.low);
      expect(target.ownerProofAllowed, isTrue);
      expect(target.ownerProofRequired, isFalse);
      expect(
        target.missingCoverageAreas,
        contains('PV/MultiPV support coverage'),
      );
    });

    test('Android proof packet remains proof-limited', () {
      final result = _plan();
      final target = result.target(
        InternalNonLabelPrototypeScopeId
            .androidProofConfidenceInternalPrototypeScope,
      );

      expect(
        target.recommendedAction,
        InternalPacketEvidenceHardeningActionType.keepProofLimited,
      );
      expect(
        target.targetKind,
        InternalPacketEvidenceHardeningTargetKind.androidProofScope,
      );
      expect(target.priority, InternalPacketEvidenceHardeningPriority.low);
      expect(target.androidProofCaseIds, _provenAndroidIds);
      expect(result.androidProofCaseIds, _provenAndroidIds);
      expect(target.ownerProofAllowed, isTrue);
      expect(target.ownerProofRequired, isFalse);
    });

    test('warning-limited scopes recommend targeted Golden coverage', () {
      _expectWarningCoverage(
        InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
        'king-safety / mating-net coverage',
      );
      _expectWarningCoverage(
        InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
        'endgame precision coverage',
      );
      _expectWarningCoverage(
        InternalNonLabelPrototypeScopeId
            .suppressionSafetyInternalPrototypeScope,
        'suppression safety coverage',
      );
      _expectWarningCoverage(
        InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
        'budget pressure coverage',
      );
    });

    test('quiet and policy scopes remain blocked or future-only', () {
      final result = _plan();

      expect(
        result
            .target(
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
            )
            .recommendedAction,
        InternalPacketEvidenceHardeningActionType.keepExcludedByNegativeGuard,
      );
      for (final scopeId in const <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
        InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
        InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
        InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
        InternalNonLabelPrototypeScopeId.backendIntegrationScope,
        InternalNonLabelPrototypeScopeId.persistenceScope,
        InternalNonLabelPrototypeScopeId.directEngineAccessScope,
      ]) {
        final target = result.target(scopeId);
        expect(
          target.recommendedAction,
          InternalPacketEvidenceHardeningActionType.keepBlockedByPolicy,
          reason: scopeId.wire,
        );
        expect(target.addsCoverage, isFalse);
      }
      for (final scopeId in const <InternalNonLabelPrototypeScopeId>[
        InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
        InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
      ]) {
        final target = result.target(scopeId);
        expect(
          target.recommendedAction,
          InternalPacketEvidenceHardeningActionType.keepFutureOnly,
          reason: scopeId.wire,
        );
        expect(target.addsCoverage, isFalse);
      }
    });

    test('owner proof is not required by default', () {
      final result = _plan();

      expect(
        result.targets.any((target) => target.ownerProofRequired),
        isFalse,
      );
    });

    test('suggested hard-case areas are deterministic', () {
      final result = _plan();

      expect(
        result.suggestedHardCaseAreas,
        containsAll(<String>[
          'king-safety / mating-net coverage',
          'endgame precision coverage',
          'suppression safety coverage',
          'budget pressure coverage',
          'PV/MultiPV support coverage',
        ]),
      );
      expect(result.suggestedHardCaseAreas, _plan().suggestedHardCaseAreas);
    });
  });

  group('InternalPacketEvidenceHardeningPlan validator seams', () {
    test('unproven Android proof ID becomes blocked by unsafe state', () {
      final result = _plan(
        stabilityResult: _mutatedStabilityRecord(
          InternalNonLabelPrototypeScopeId
              .androidProofConfidenceInternalPrototypeScope,
          (record) => _copyRecord(
            record,
            androidProofCaseIds: <String>[
              ...record.androidProofCaseIds,
              'unproven-proof-case',
            ],
          ),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('unprovenAndroidProofCitation'),
      );
      expect(
        result.hardeningStatus,
        InternalPacketEvidenceHardeningStatus.blockedByUnsafePacket,
      );
      expect(
        result.phase32ERecommendation,
        InternalPacketEvidencePhase32ERecommendation
            .blockedByUnsafeHardeningState,
      );
      expect(result.safeForPhase32E, isFalse);
    });

    test('missing stable support and mappings become high priority', () {
      final result = _plan(
        stabilityResult: _mutatedStabilityRecord(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (record) => _copyRecord(
            record,
            supportCaseIds: const <String>[],
            activeSignalIds: const <InternalNonLabelSignalId>[],
            evidenceAreaIds: const <InternalEvidenceAreaId>[],
            bucketIds: const <InternalEvidenceBucketId>[],
          ),
        ),
      );
      final target = result.target(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
      );

      expect(target.priority, InternalPacketEvidenceHardeningPriority.high);
      expect(result.highPriorityCount, 1);
    });

    test('validator rejects unsafe packet marked safe', () {
      final safe = _plan();
      final forged = safe.copyWith(
        safeForPhase32E: true,
        targets: safe.targets
            .map(
              (target) =>
                  target.scopeId ==
                      InternalNonLabelPrototypeScopeId
                          .tacticalInternalPrototypeScope
                  ? target.copyWith(
                      currentStatus: InternalPacketStabilityStatus.unsafe,
                    )
                  : target,
            )
            .toList(growable: false),
      );

      final findings = const InternalPacketEvidenceHardeningPlanValidator()
          .validate(forged, cases: _cases, androidProofEvidence: _proof);

      expect(
        findings.map((finding) => finding.id),
        contains('unsafeHardeningStateMarkedSafe'),
      );
    });

    test('validator rejects label output', () {
      _expectUnsafeRecordFinding(
        (record) => _copyRecord(record, isClassifierLabel: true),
      );
    });

    test('validator rejects numeric value output', () {
      _expectUnsafeRecordFinding(
        (record) => _copyRecord(record, hasNumericValue: true),
      );
    });

    test('validator rejects move ordering output', () {
      _expectUnsafeRecordFinding(
        (record) => _copyRecord(record, ordersMoves: true),
      );
    });

    test('validator rejects official metric output', () {
      _expectUnsafeRecordFinding(
        (record) => _copyRecord(record, isOfficialMetric: true),
      );
    });

    test('validator rejects future computations', () {
      final result = _plan(
        stabilityResult: _mutatedStabilityRecord(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (record) => _copyRecord(
            record,
            cpLossComputationImplemented: true,
            winProbabilityComputationImplemented: true,
          ),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('futureComputationActivated'),
      );
      expect(result.hasUnsafeHardeningPolicyViolation, isTrue);
    });

    test('validator rejects quiet activation', () {
      final result = _plan(
        stabilityResult: _mutatedStabilityRecord(
          InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
          (record) => _copyRecord(record, quietScopeActive: true),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('quietPreparatoryHardeningActivated'),
      );
    });

    test('validator rejects owner proof without explicit PV reason', () {
      final safe = _plan();
      final target = safe.target(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
      );
      final forged = safe.copyWith(
        targets: <InternalPacketEvidenceHardeningTarget>[
          target.copyWith(
            ownerProofRequired: true,
            reason: 'manual owner proof requested',
            nextStep: 'queue owner proof',
          ),
        ],
      );

      final findings = const InternalPacketEvidenceHardeningPlanValidator()
          .validate(forged, cases: _cases, androidProofEvidence: _proof);

      expect(
        findings.map((finding) => finding.id),
        contains('ownerProofRequiredWithoutPvReason'),
      );
    });

    test('validator rejects blocked scope receiving coverage action', () {
      final safe = _plan();
      final target = safe.target(
        InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
      );
      final forged = safe.copyWith(
        targets: <InternalPacketEvidenceHardeningTarget>[
          target.copyWith(
            recommendedAction:
                InternalPacketEvidenceHardeningActionType.addGoldenCoverage,
          ),
        ],
      );

      final findings = const InternalPacketEvidenceHardeningPlanValidator()
          .validate(forged, cases: _cases, androidProofEvidence: _proof);

      expect(
        findings.map((finding) => finding.id),
        contains('blockedScopeReceivedCoverageAction'),
      );
    });

    test('validator rejects unstable packet preserved as stable', () {
      final safe = _plan();
      final target = safe.target(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
      );
      final forged = safe.copyWith(
        targets: <InternalPacketEvidenceHardeningTarget>[
          target.copyWith(
            currentStatus: InternalPacketStabilityStatus.unstable,
            recommendedAction:
                InternalPacketEvidenceHardeningActionType.preserveStablePacket,
          ),
        ],
      );

      final findings = const InternalPacketEvidenceHardeningPlanValidator()
          .validate(forged, cases: _cases, androidProofEvidence: _proof);

      expect(
        findings.map((finding) => finding.id),
        contains('unstablePacketPreservedAsStable'),
      );
    });
  });

  group('InternalPacketEvidenceHardeningPlan reports', () {
    test('markdown report includes hardening status and target table', () {
      final report = _plan().renderMarkdownReport();

      expect(report, contains('# Internal Packet Evidence Hardening Plan'));
      expect(report, contains('hardening status: readyForTargetedHardening'));
      expect(report, contains('## Target Table'));
      expect(report, contains('tacticalInternalPrototypeScope-packet'));
    });

    test('markdown report includes aggregate and priority counts', () {
      final report = _plan().renderMarkdownReport();

      expect(report, contains('total targets: 20'));
      expect(report, contains('preserve count: 4'));
      expect(report, contains('add coverage count: 5'));
      expect(report, contains('## Priority Counts'));
      expect(report, contains('critical count: 0'));
    });

    test(
      'markdown report includes suggested hard-case areas and Phase 32E',
      () {
        final report = _plan().renderMarkdownReport();

        expect(report, contains('## Suggested Hard-Case Areas'));
        expect(report, contains('king-safety / mating-net coverage'));
        expect(report, contains('PV/MultiPV support coverage'));
        expect(report, contains('king-safety-mating-net-pressure-32e'));
        expect(report, contains('pv-multipv-support-boundary-32e'));
        expect(report, contains('## Phase 32E Recommendation'));
        expect(report, contains('addTargetedGoldenCoverageCases'));
      },
    );

    test('JSON report is deterministic and valid', () {
      final first = _plan().renderJsonReport();
      final second = _plan().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        internalPacketEvidenceHardeningPlanReportVersion,
      );
      expect(decoded['hardeningStatus'], 'readyForTargetedHardening');
      expect(decoded['targets'], isA<List<Object?>>());
    });

    test('reports contain no raw UCI spam or PV dumps', () {
      final report = _plan().renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
      expect(report, isNot(contains('e2e4 e7e5')));
    });

    test('reports contain no final labels or official metrics', () {
      final report = _plan().renderMarkdownReport();

      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
      expect(report, isNot(contains('Best')));
      expect(report, isNot(contains('Good')));
      expect(report, isNot(contains('Inaccuracy')));
      expect(report, isNot(contains('Mistake')));
      expect(report, isNot(contains('Blunder')));
      expect(report, isNot(contains('ACPL')));
      expect(report, isNot(contains('accuracy')));
    });

    test('reports contain no numeric move score or move ranking output', () {
      final report = _plan().renderMarkdownReport();

      expect(report, isNot(contains('moveScore')));
      expect(report, isNot(contains('scoreValue')));
      expect(report, isNot(contains('rankedMoves')));
      expect(report, isNot(contains('moveRanking')));
    });

    test('validator rejects unsafe report text', () {
      final findings = const InternalPacketEvidenceHardeningPlanValidator()
          .validateReportText('uciok\nmoveScore: 1\nrankedMoves\n');

      expect(
        findings.map((finding) => finding.id),
        contains('rawUciReportText'),
      );
      expect(
        findings.map((finding) => finding.id),
        contains('numericMoveValueReportText'),
      );
      expect(
        findings.map((finding) => finding.id),
        contains('moveOrderingReportText'),
      );
    });

    test(
      'source does not import engine, UI, backend, or persistence boundaries',
      () {
        final source = File(
          'lib/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart',
        ).readAsStringSync();
        final imports = _imports(source);

        expect(imports, isNot(contains('Stockfish')));
        expect(imports, isNot(contains('stockfish_bridge')));
        expect(imports, isNot(contains('dart:ffi')));
        expect(imports, isNot(contains('native')));
        expect(imports, isNot(contains('LocalEvalService')));
        expect(imports, isNot(contains('flutter/material')));
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

InternalPacketEvidenceHardeningPlanResult _plan({
  InternalPacketStabilityPrototypeResult? stabilityResult,
  InternalPacketReviewAggregationMatrixResult? matrixResult,
  NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult,
}) {
  return const InternalPacketEvidenceHardeningPlan().evaluate(
    InternalPacketEvidenceHardeningPlanRequest(
      stabilityResult: stabilityResult,
      matrixResult: matrixResult,
      prototypeResult: prototypeResult,
    ),
  );
}

InternalPacketStabilityPrototypeResult _stability() {
  return const InternalPacketStabilityPrototype().evaluate(
    const InternalPacketStabilityPrototypeRequest(),
  );
}

InternalPacketStabilityPrototypeResult _mutatedStabilityRecord(
  InternalNonLabelPrototypeScopeId scopeId,
  InternalPacketStabilityRecord Function(InternalPacketStabilityRecord record)
  mutate,
) {
  final stability = _stability();
  return stability.copyWith(
    records: stability.records
        .map((record) => record.scopeId == scopeId ? mutate(record) : record)
        .toList(growable: false),
  );
}

InternalPacketStabilityRecord _copyRecord(
  InternalPacketStabilityRecord record, {
  String? recordId,
  String? packetId,
  InternalNonLabelPrototypeScopeId? scopeId,
  InternalPacketStabilityStatus? stabilityStatus,
  InternalPacketReviewStatus? sourceReviewStatus,
  List<String>? supportCaseIds,
  List<String>? androidProofCaseIds,
  List<InternalNonLabelSignalId>? activeSignalIds,
  List<InternalEvidenceAreaId>? evidenceAreaIds,
  List<InternalEvidenceBucketId>? bucketIds,
  bool? isCorePacket,
  bool? isProductOutput,
  bool? isClassifierLabel,
  bool? isOfficialMetric,
  bool? hasNumericValue,
  bool? ordersMoves,
  bool? quietScopeActive,
  bool? cpLossComputationImplemented,
  bool? winProbabilityComputationImplemented,
  List<String>? emittedOutputNames,
}) {
  return InternalPacketStabilityRecord(
    recordId: recordId ?? record.recordId,
    packetId: packetId ?? record.packetId,
    scopeId: scopeId ?? record.scopeId,
    stabilityStatus: stabilityStatus ?? record.stabilityStatus,
    sourceReviewStatus: sourceReviewStatus ?? record.sourceReviewStatus,
    supportCaseIds: supportCaseIds ?? record.supportCaseIds,
    androidProofCaseIds: androidProofCaseIds ?? record.androidProofCaseIds,
    activeSignalIds: activeSignalIds ?? record.activeSignalIds,
    evidenceAreaIds: evidenceAreaIds ?? record.evidenceAreaIds,
    bucketIds: bucketIds ?? record.bucketIds,
    qualitativeConfidence: record.qualitativeConfidence,
    stabilityReason: record.stabilityReason,
    warningReason: record.warningReason,
    proofLimitReason: record.proofLimitReason,
    coverageGapIds: record.coverageGapIds,
    blockedBoundaryIds: record.blockedBoundaryIds,
    futurePrerequisites: record.futurePrerequisites,
    recommendation: record.recommendation,
    isCorePacket: isCorePacket ?? record.isCorePacket,
    isProductOutput: isProductOutput ?? record.isProductOutput,
    isClassifierLabel: isClassifierLabel ?? record.isClassifierLabel,
    isOfficialMetric: isOfficialMetric ?? record.isOfficialMetric,
    hasNumericValue: hasNumericValue ?? record.hasNumericValue,
    ordersMoves: ordersMoves ?? record.ordersMoves,
    quietScopeActive: quietScopeActive ?? record.quietScopeActive,
    cpLossComputationImplemented:
        cpLossComputationImplemented ?? record.cpLossComputationImplemented,
    winProbabilityComputationImplemented:
        winProbabilityComputationImplemented ??
        record.winProbabilityComputationImplemented,
    emittedOutputNames: emittedOutputNames ?? record.emittedOutputNames,
  );
}

void _expectTarget(
  InternalNonLabelPrototypeScopeId scopeId,
  InternalPacketEvidenceHardeningActionType action,
  InternalPacketEvidenceHardeningPriority priority,
) {
  final target = _plan().target(scopeId);

  expect(target.recommendedAction, action, reason: scopeId.wire);
  expect(target.priority, priority, reason: scopeId.wire);
  expect(target.targetKind, InternalPacketEvidenceHardeningTargetKind.packet);
  expect(target.supportCaseIds, isNotEmpty);
}

void _expectWarningCoverage(
  InternalNonLabelPrototypeScopeId scopeId,
  String suggestedArea,
) {
  final target = _plan().target(scopeId);

  expect(
    target.targetKind,
    InternalPacketEvidenceHardeningTargetKind.warningScope,
  );
  expect(
    target.recommendedAction,
    InternalPacketEvidenceHardeningActionType.addGoldenCoverage,
  );
  expect(target.priority, InternalPacketEvidenceHardeningPriority.medium);
  expect(target.suggestedCaseArea, suggestedArea);
  expect(target.missingCoverageAreas, contains(suggestedArea));
}

void _expectUnsafeRecordFinding(
  InternalPacketStabilityRecord Function(InternalPacketStabilityRecord record)
  mutate,
) {
  final result = _plan(
    stabilityResult: _mutatedStabilityRecord(
      InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
      mutate,
    ),
  );

  expect(
    result.validationFindings.map((finding) => finding.id),
    contains('hardeningTargetUnsafeOutputBoundary'),
  );
  expect(result.hasUnsafeHardeningPolicyViolation, isTrue);
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

const _cases = GoldenAnalysisCases.defaults;
const _proof = GoldenAndroidProofEvidence.phase30uS22Ultra;

const _provenAndroidIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];
