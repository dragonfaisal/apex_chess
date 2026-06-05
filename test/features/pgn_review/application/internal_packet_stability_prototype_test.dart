@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_stability_prototype.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalPacketStabilityPrototype safe demo', () {
    test('consumes safe Phase 32B matrix result', () {
      final result = _stability();

      expect(
        result.sourceMatrixStatus,
        InternalPacketReviewAggregationMatrixStatus.readyWithWarnings,
      );
      expect(
        result.sourcePrototypeStatus,
        NarrowInternalNonLabelAnalysisPrototypeStatus
            .completedWithCoverageWarnings,
      );
      expect(
        result.sourceReadinessStatus,
        InternalNonLabelPrototypeReadinessStatus.readyWithCoverageWarnings,
      );
      expect(result.safeForPhase32D, isTrue);
      expect(result.unsafeCount, 0);
    });

    test('aggregate counts are deterministic', () {
      final result = _stability();

      expect(result.totalStabilityRecords, 20);
      expect(result.stableCount, 4);
      expect(result.stableNarrowCount, 0);
      expect(result.stableWithWarningsCount, 1);
      expect(result.proofLimitedStableCount, 1);
      expect(result.warningLimitedCount, 4);
      expect(result.blockedOrFutureOnlyCount, 10);
      expect(result.unstableCount, 0);
      expect(result.unsafeCount, 0);
    });

    test('unique support case IDs are deterministic', () {
      final first = _stability().uniqueSupportCaseIds;
      final second = _stability().uniqueSupportCaseIds;

      expect(first, second);
      expect(first, contains('mate-threat-fast-evidence'));
      expect(first, contains('queen-win-major-swing'));
      expect(first, contains('simple-tactical-capture-check'));
      expect(first, contains('quiet-preparatory-hard-case'));
    });

    test('Phase 32D recommendation is deterministic', () {
      final result = _stability();

      expect(
        result.phase32DRecommendation,
        InternalPacketStabilityPhase32DRecommendation
            .proceedToInternalPacketEvidenceHardeningPlan,
      );
      expect(result.safeForPhase32D, isTrue);
    });
  });

  group('InternalPacketStabilityPrototype packet records', () {
    test('tactical packet is stable', () {
      final record = _stability().record(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
      );

      expect(record.stabilityStatus, InternalPacketStabilityStatus.stable);
      expect(record.sourceReviewStatus, InternalPacketReviewStatus.stable);
      expect(record.supportCaseIds, contains('simple-tactical-capture-check'));
      expect(
        record.recommendation,
        InternalPacketStabilityRecommendation.preserveStablePacket,
      );
    });

    test('material swing packet is stable', () {
      final record = _stability().record(
        InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
      );

      expect(record.stabilityStatus, InternalPacketStabilityStatus.stable);
      expect(record.supportCaseIds, contains('queen-win-major-swing'));
    });

    test('forcing line packet is stable or stable narrow', () {
      final record = _stability().record(
        InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
      );

      expect(
        record.stabilityStatus,
        isIn(<InternalPacketStabilityStatus>[
          InternalPacketStabilityStatus.stable,
          InternalPacketStabilityStatus.stableNarrow,
        ]),
      );
      expect(
        record.supportCaseIds,
        contains('forcing-line-variation-hard-case'),
      );
    });

    test('candidate spread packet is stable', () {
      final record = _stability().record(
        InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
      );

      expect(record.stabilityStatus, InternalPacketStabilityStatus.stable);
      expect(record.supportCaseIds, contains('mate-threat-fast-evidence'));
    });

    test('PV and MultiPV packet is stable with warnings', () {
      final record = _stability().record(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
      );

      expect(
        record.stabilityStatus,
        InternalPacketStabilityStatus.stableWithWarnings,
      );
      expect(record.androidProofCaseIds, _provenAndroidIds);
      expect(record.warningReason, isNotEmpty);
    });

    test('Android proof confidence packet is proof-limited stable', () {
      final record = _stability().record(
        InternalNonLabelPrototypeScopeId
            .androidProofConfidenceInternalPrototypeScope,
      );

      expect(
        record.stabilityStatus,
        InternalPacketStabilityStatus.proofLimitedStable,
      );
      expect(record.androidProofCaseIds, _provenAndroidIds);
      expect(
        record.recommendation,
        InternalPacketStabilityRecommendation.preserveProofLimitedPacket,
      );
      expect(record.proofLimitReason, isNotEmpty);
    });

    test('Android proof IDs are exactly the three proven IDs', () {
      final result = _stability();

      expect(result.androidProofCaseIds, _provenAndroidIds);
      for (final record in result.records) {
        for (final caseId in record.androidProofCaseIds) {
          expect(_provenAndroidIds, contains(caseId));
        }
      }
    });
  });

  group('InternalPacketStabilityPrototype warning and blocked records', () {
    test('king safety remains warning-limited only', () {
      _expectWarningLimitedOnly(
        InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
      );
    });

    test('endgame remains warning-limited only', () {
      _expectWarningLimitedOnly(
        InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
      );
    });

    test('suppression safety remains warning-limited only', () {
      _expectWarningLimitedOnly(
        InternalNonLabelPrototypeScopeId
            .suppressionSafetyInternalPrototypeScope,
      );
    });

    test('budget risk remains warning-limited only', () {
      _expectWarningLimitedOnly(
        InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
      );
    });

    test('quiet and product label scopes remain blocked', () {
      final result = _stability();

      expect(
        result
            .record(
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
            )
            .stabilityStatus,
        InternalPacketStabilityStatus.blockedCorrectly,
      );
      expect(
        result
            .record(InternalNonLabelPrototypeScopeId.productLabelPrototypeScope)
            .stabilityStatus,
        InternalPacketStabilityStatus.blockedCorrectly,
      );
    });

    test('advanced labels and official metrics remain blocked', () {
      final result = _stability();

      expect(
        result
            .record(
              InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
            )
            .stabilityStatus,
        InternalPacketStabilityStatus.blockedCorrectly,
      );
      expect(
        result
            .record(
              InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
            )
            .stabilityStatus,
        InternalPacketStabilityStatus.blockedCorrectly,
      );
    });

    test('CP-loss and win probability remain future-only', () {
      final result = _stability();

      expect(
        result
            .record(InternalNonLabelPrototypeScopeId.cpLossPrototypeScope)
            .stabilityStatus,
        InternalPacketStabilityStatus.futureOnlyCorrectly,
      );
      expect(
        result
            .record(
              InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
            )
            .stabilityStatus,
        InternalPacketStabilityStatus.futureOnlyCorrectly,
      );
    });

    test(
      'UI, backend, persistence, and direct engine scopes remain blocked',
      () {
        final result = _stability();

        for (final scopeId in const <InternalNonLabelPrototypeScopeId>[
          InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
          InternalNonLabelPrototypeScopeId.backendIntegrationScope,
          InternalNonLabelPrototypeScopeId.persistenceScope,
          InternalNonLabelPrototypeScopeId.directEngineAccessScope,
        ]) {
          expect(
            result.record(scopeId).stabilityStatus,
            InternalPacketStabilityStatus.blockedCorrectly,
            reason: scopeId.wire,
          );
        }
      },
    );
  });

  group('InternalPacketStabilityPrototype validator seams', () {
    test('unproven Android proof ID is rejected', () {
      final result = _stability(
        matrixResult: _mutatedMatrixRow(
          InternalNonLabelPrototypeScopeId
              .androidProofConfidenceInternalPrototypeScope,
          (row) => row.copyWith(
            androidProofCaseIds: <String>[
              ...row.androidProofCaseIds,
              'unproven-proof-case',
            ],
          ),
        ),
      );

      expect(result.unsafeCount, greaterThan(0));
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('unprovenAndroidProofCitation'),
      );
      expect(
        result.phase32DRecommendation,
        InternalPacketStabilityPhase32DRecommendation.blockedByUnsafeOutput,
      );
    });

    test('stable record must have support cases', () {
      final result = _stability(
        matrixResult: _mutatedMatrixRow(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (row) => row.copyWith(supportCaseIds: const <String>[]),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('stableRecordWithoutSupportCases'),
      );
    });

    test('stable record must have active signal IDs', () {
      final result = _stability(
        matrixResult: _mutatedMatrixRow(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (row) =>
              row.copyWith(activeSignalIds: const <InternalNonLabelSignalId>[]),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('stableRecordWithoutActiveSignals'),
      );
    });

    test('stable record must have evidence area IDs', () {
      final result = _stability(
        matrixResult: _mutatedMatrixRow(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (row) =>
              row.copyWith(evidenceAreaIds: const <InternalEvidenceAreaId>[]),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('stableRecordWithoutEvidenceAreas'),
      );
    });

    test('stable record must have bucket IDs', () {
      final result = _stability(
        matrixResult: _mutatedMatrixRow(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (row) => row.copyWith(bucketIds: const <InternalEvidenceBucketId>[]),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('stableRecordWithoutBuckets'),
      );
    });

    test('warning-limited scope cannot become stable packet', () {
      final result = _stability(
        matrixResult: _mutatedMatrixRow(
          InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
          (row) => row.copyWith(
            packetId: 'kingSafetyInternalPrototypeScope-stable-packet',
            reviewStatus: InternalPacketReviewStatus.stable,
            isCorePacket: true,
          ),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('warningLimitedScopePromotedToStablePacket'),
      );
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('warningLimitedScopeCannotBecomeStablePacket'),
      );
    });

    test('no record emits label output', () {
      final result = _stability();

      for (final record in result.corePacketRecords) {
        expect(record.isProductOutput, isFalse);
        expect(record.isClassifierLabel, isFalse);
      }
      expect(result.productLabelsEmitted, isFalse);
      expect(result.classifierLabelsEmitted, isFalse);
      expect(result.finalMoveLabelsEmitted, isFalse);
    });

    test('no record emits numeric value output', () {
      final result = _stability();

      for (final record in result.corePacketRecords) {
        expect(record.hasNumericValue, isFalse);
      }
      expect(result.numericMoveValuesComputed, isFalse);
    });

    test('no record orders moves', () {
      final result = _stability();

      for (final record in result.corePacketRecords) {
        expect(record.ordersMoves, isFalse);
      }
      expect(result.moveOrderingComputed, isFalse);
    });

    test('no record emits official metric output', () {
      final result = _stability();

      for (final record in result.corePacketRecords) {
        expect(record.isOfficialMetric, isFalse);
      }
      expect(result.officialMetricsAllowed, isFalse);
    });

    test('validator rejects forbidden output seams', () {
      final result = _stability(
        matrixResult: _mutatedMatrixRow(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (row) => row.copyWith(
            isClassifierLabel: true,
            hasNumericScore: true,
            ranksMoves: true,
            isOfficialMetric: true,
          ),
        ),
      );

      expect(result.unsafeCount, greaterThan(0));
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('recordUnsafeOutputBoundary'),
      );
    });
  });

  group('InternalPacketStabilityPrototype reports', () {
    test('markdown report includes stability table and aggregate counts', () {
      final report = _stability().renderMarkdownReport();

      expect(report, contains('# Internal Packet Stability Prototype'));
      expect(report, contains('prototype status: stableWithWarnings'));
      expect(report, contains('## Stability Table'));
      expect(report, contains('## Aggregate Counts'));
      expect(report, contains('tacticalInternalPrototypeScope-packet'));
    });

    test('markdown report includes proof-limited rows', () {
      final report = _stability().renderMarkdownReport();

      expect(report, contains('## Proof-Limited Stable Packets'));
      expect(
        report,
        contains('androidProofConfidenceInternalPrototypeScope-packet'),
      );
      expect(report, contains('proofLimitedStable'));
    });

    test('markdown report includes warning-limited scopes', () {
      final report = _stability().renderMarkdownReport();

      expect(report, contains('## Warning-Limited Scopes'));
      expect(report, contains('kingSafetyInternalPrototypeScope'));
      expect(report, contains('budgetRiskInternalPrototypeScope'));
    });

    test('markdown report includes blocked and future-only scopes', () {
      final report = _stability().renderMarkdownReport();

      expect(report, contains('## Blocked And Future-Only Scopes'));
      expect(report, contains('quietPreparatoryPrototypeScope'));
      expect(report, contains('cpLossPrototypeScope'));
      expect(report, contains('winProbabilityPrototypeScope'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _stability().renderJsonReport();
      final second = _stability().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalPacketStabilityPrototypeReportVersion);
      expect(decoded['prototypeStatus'], 'stableWithWarnings');
      expect(decoded['records'], isA<List<Object?>>());
    });

    test('reports contain no raw UCI spam', () {
      final report = _stability().renderMarkdownReport();

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
    });

    test('reports contain no PV dumps', () {
      final report = _stability().renderMarkdownReport();

      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
      expect(report, isNot(contains('e2e4 e7e5')));
    });

    test('reports contain no final labels or official metric output names', () {
      final report = _stability().renderMarkdownReport();

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

    test('reports contain no numeric value or move ordering output names', () {
      final report = _stability().renderMarkdownReport();

      expect(report, isNot(contains('moveScore')));
      expect(report, isNot(contains('scoreValue')));
      expect(report, isNot(contains('rankedMoves')));
      expect(report, isNot(contains('moveRanking')));
    });

    test('validator rejects unsafe report text', () {
      final findings = const InternalPacketStabilityPrototypeValidator()
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
          'lib/features/pgn_review/application/internal_packet_stability_prototype.dart',
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

InternalPacketStabilityPrototypeResult _stability({
  InternalPacketReviewAggregationMatrixResult? matrixResult,
  NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult,
  InternalNonLabelPrototypeReadinessResult? readinessResult,
}) {
  return const InternalPacketStabilityPrototype().evaluate(
    InternalPacketStabilityPrototypeRequest(
      matrixResult: matrixResult,
      prototypeResult: prototypeResult,
      readinessResult: readinessResult,
    ),
  );
}

InternalPacketReviewAggregationMatrixResult _matrix() {
  return const InternalPacketReviewAggregationMatrix().evaluate(
    const InternalPacketReviewAggregationMatrixRequest(),
  );
}

InternalPacketReviewAggregationMatrixResult _mutatedMatrixRow(
  InternalNonLabelPrototypeScopeId scopeId,
  InternalPacketReviewAggregationRow Function(
    InternalPacketReviewAggregationRow row,
  )
  mutate,
) {
  final matrix = _matrix();
  return matrix.copyWith(
    rows: matrix.rows
        .map((row) => row.allowedScopeId == scopeId ? mutate(row) : row)
        .toList(growable: false),
  );
}

void _expectWarningLimitedOnly(InternalNonLabelPrototypeScopeId scopeId) {
  final record = _stability().record(scopeId);

  expect(
    record.stabilityStatus,
    InternalPacketStabilityStatus.warningLimitedOnly,
  );
  expect(
    record.recommendation,
    InternalPacketStabilityRecommendation.keepWarningLimited,
  );
  expect(record.coverageGapIds, contains(scopeId.wire));
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

const _provenAndroidIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];
