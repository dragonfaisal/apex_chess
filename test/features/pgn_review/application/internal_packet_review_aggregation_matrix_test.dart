@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_observation_review_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalPacketReviewAggregationMatrix safe demo', () {
    test(
      'consumes safe Phase 32A prototype, readiness, and review results',
      () {
        final result = _matrix();

        expect(
          result.prototypeStatus,
          NarrowInternalNonLabelAnalysisPrototypeStatus
              .completedWithCoverageWarnings,
        );
        expect(
          result.readinessStatus,
          InternalNonLabelPrototypeReadinessStatus.readyWithCoverageWarnings,
        );
        expect(
          result.reviewMatrixStatus,
          InternalSignalObservationReviewMatrixStatus.readyWithWarnings,
        );
        expect(result.safeForPhase32C, isTrue);
        expect(result.unsafePacketCount, 0);
      },
    );

    test('aggregate counts are deterministic', () {
      final result = _matrix();

      expect(result.totalPackets, 6);
      expect(result.stablePacketCount, 5);
      expect(result.stableNarrowPacketCount, 0);
      expect(result.proofLimitedPacketCount, 1);
      expect(result.warningLimitedScopeCount, 4);
      expect(result.blockedScopeCount, 10);
      expect(result.unsafePacketCount, 0);
      expect(result.rows.length, 20);
    });

    test('unique support case IDs are deterministic', () {
      final first = _matrix().uniqueSupportCaseIds;
      final second = _matrix().uniqueSupportCaseIds;

      expect(first, second);
      expect(first, contains('mate-threat-fast-evidence'));
      expect(first, contains('queen-win-major-swing'));
      expect(first, contains('simple-tactical-capture-check'));
      expect(first, contains('quiet-preparatory-hard-case'));
    });

    test('Phase 32C recommendation is deterministic', () {
      final result = _matrix();

      expect(
        result.phase32CRecommendation,
        InternalPacketReviewPhase32CRecommendation
            .proceedToInternalPacketStabilityPrototype,
      );
      expect(result.safeForPhase32C, isTrue);
    });
  });

  group('InternalPacketReviewAggregationMatrix packet rows', () {
    test('tactical packet is stable with broad support', () {
      final row = _matrix().row(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
      );

      expect(row.reviewStatus, InternalPacketReviewStatus.stable);
      expect(
        row.supportBreadth,
        InternalPacketSupportBreadth.broadGoldenSupport,
      );
      expect(row.supportCaseIds, contains('simple-tactical-capture-check'));
    });

    test('material swing packet is stable', () {
      final row = _matrix().row(
        InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
      );

      expect(row.reviewStatus, InternalPacketReviewStatus.stable);
      expect(row.supportCaseIds, contains('queen-win-major-swing'));
      expect(
        row.supportBreadth,
        InternalPacketSupportBreadth.broadGoldenSupport,
      );
    });

    test('forcing line packet is stable or stable narrow', () {
      final row = _matrix().row(
        InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
      );

      expect(
        row.reviewStatus,
        isIn(<InternalPacketReviewStatus>[
          InternalPacketReviewStatus.stable,
          InternalPacketReviewStatus.stableNarrow,
        ]),
      );
      expect(row.supportCaseIds, contains('forcing-line-variation-hard-case'));
    });

    test('candidate spread packet is stable', () {
      final row = _matrix().row(
        InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
      );

      expect(row.reviewStatus, InternalPacketReviewStatus.stable);
      expect(row.supportCaseIds, contains('mate-threat-fast-evidence'));
    });

    test('PV and MultiPV packet is stable with warnings or proof-limited', () {
      final row = _matrix().row(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
      );

      expect(
        row.reviewStatus,
        isIn(<InternalPacketReviewStatus>[
          InternalPacketReviewStatus.stableWithWarnings,
          InternalPacketReviewStatus.proofLimited,
        ]),
      );
      expect(row.androidProofCaseIds, _provenAndroidIds);
      expect(row.warningReasons, isNotEmpty);
    });

    test('Android proof confidence packet is proof-limited and valid', () {
      final row = _matrix().row(
        InternalNonLabelPrototypeScopeId
            .androidProofConfidenceInternalPrototypeScope,
      );

      expect(row.reviewStatus, InternalPacketReviewStatus.proofLimited);
      expect(row.androidProofCaseIds, _provenAndroidIds);
      expect(
        row.recommendation,
        InternalPacketReviewRecommendation.keepProofLimited,
      );
    });

    test('Android proof IDs are exactly the three proven IDs', () {
      final result = _matrix();

      expect(result.androidProofCaseIds, _provenAndroidIds);
      for (final row in result.rows) {
        for (final caseId in row.androidProofCaseIds) {
          expect(_provenAndroidIds, contains(caseId));
        }
      }
    });
  });

  group('InternalPacketReviewAggregationMatrix warning and blocked rows', () {
    test('warning-limited king safety remains warning only', () {
      _expectWarningOnly(
        InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
      );
    });

    test('warning-limited endgame remains warning only', () {
      _expectWarningOnly(
        InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
      );
    });

    test('warning-limited suppression remains warning only', () {
      _expectWarningOnly(
        InternalNonLabelPrototypeScopeId
            .suppressionSafetyInternalPrototypeScope,
      );
    });

    test('warning-limited budget risk remains warning only', () {
      _expectWarningOnly(
        InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
      );
    });

    test('quiet and product label scopes remain blocked', () {
      final result = _matrix();

      expect(
        result
            .row(
              InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
            )
            .reviewStatus,
        InternalPacketReviewStatus.blockedCorrectly,
      );
      expect(
        result
            .row(InternalNonLabelPrototypeScopeId.productLabelPrototypeScope)
            .reviewStatus,
        InternalPacketReviewStatus.blockedCorrectly,
      );
    });

    test('advanced labels and official metrics remain blocked', () {
      final result = _matrix();

      expect(
        result
            .row(InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope)
            .reviewStatus,
        InternalPacketReviewStatus.blockedCorrectly,
      );
      expect(
        result
            .row(InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope)
            .reviewStatus,
        InternalPacketReviewStatus.blockedCorrectly,
      );
    });

    test('CP-loss and win probability remain future-only', () {
      final result = _matrix();

      expect(
        result
            .row(InternalNonLabelPrototypeScopeId.cpLossPrototypeScope)
            .reviewStatus,
        InternalPacketReviewStatus.futureOnlyCorrectly,
      );
      expect(
        result
            .row(InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope)
            .reviewStatus,
        InternalPacketReviewStatus.futureOnlyCorrectly,
      );
    });

    test(
      'UI, backend, persistence, and direct engine scopes remain blocked',
      () {
        final result = _matrix();

        for (final scopeId in const <InternalNonLabelPrototypeScopeId>[
          InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
          InternalNonLabelPrototypeScopeId.backendIntegrationScope,
          InternalNonLabelPrototypeScopeId.persistenceScope,
          InternalNonLabelPrototypeScopeId.directEngineAccessScope,
        ]) {
          expect(
            result.row(scopeId).reviewStatus,
            InternalPacketReviewStatus.blockedCorrectly,
            reason: scopeId.wire,
          );
        }
      },
    );
  });

  group('InternalPacketReviewAggregationMatrix validator seams', () {
    test('unproven Android proof ID is rejected', () {
      final prototype = _prototype();
      final mutated = prototype.copyWith(
        packets: prototype.packets
            .map(
              (packet) =>
                  packet.allowedScopeId ==
                      InternalNonLabelPrototypeScopeId
                          .androidProofConfidenceInternalPrototypeScope
                  ? packet.copyWith(
                      androidProofCaseIds: <String>[
                        ...packet.androidProofCaseIds,
                        'unproven-proof-case',
                      ],
                    )
                  : packet,
            )
            .toList(growable: false),
      );
      final result = _matrix(prototypeResult: mutated);

      expect(result.unsafePacketCount, greaterThan(0));
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('unprovenAndroidProofCitation'),
      );
      expect(
        result.phase32CRecommendation,
        InternalPacketReviewPhase32CRecommendation.blockedByUnsafePacket,
      );
    });

    test('stable packet must have support cases', () {
      final result = _matrix(
        prototypeResult: _mutatedPacket(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (packet) => packet.copyWith(supportCaseIds: const <String>[]),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('stablePacketWithoutSupportCases'),
      );
    });

    test('stable packet must have active signal IDs', () {
      final result = _matrix(
        prototypeResult: _mutatedPacket(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (packet) => packet.copyWith(
            activeSignalIds: const <InternalNonLabelSignalId>[],
          ),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('stablePacketWithoutActiveSignals'),
      );
    });

    test('stable packet must have evidence area IDs', () {
      final result = _matrix(
        prototypeResult: _mutatedPacket(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (packet) => packet.copyWith(
            evidenceAreaIds: const <InternalEvidenceAreaId>[],
          ),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('stablePacketWithoutEvidenceAreas'),
      );
    });

    test('stable packet must have bucket IDs', () {
      final result = _matrix(
        prototypeResult: _mutatedPacket(
          InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
          (packet) =>
              packet.copyWith(bucketIds: const <InternalEvidenceBucketId>[]),
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('stablePacketWithoutBuckets'),
      );
    });

    test('warning-limited scope cannot become core packet', () {
      final prototype = _prototype();
      final added = prototype.packets.first.copyWith(
        packetId: 'kingSafetyInternalPrototypeScope-packet',
        allowedScopeId:
            InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
        activeSignalIds: const <InternalNonLabelSignalId>[
          InternalNonLabelSignalId.kingSafetySignal,
        ],
      );
      final result = _matrix(
        prototypeResult: prototype.copyWith(
          packets: <NarrowInternalAnalysisPrototypePacket>[
            ...prototype.packets,
            added,
          ],
        ),
      );

      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('warningLimitedScopeBecameCorePacket'),
      );
    });

    test(
      'no packet emits label, score, ordering, or official metric output',
      () {
        final result = _matrix();

        for (final row in result.packetRows) {
          expect(row.isProductOutput, isFalse);
          expect(row.isClassifierLabel, isFalse);
          expect(row.isOfficialMetric, isFalse);
          expect(row.hasNumericScore, isFalse);
          expect(row.ranksMoves, isFalse);
        }
        expect(result.productLabelsEmitted, isFalse);
        expect(result.classifierLabelsEmitted, isFalse);
        expect(result.finalMoveLabelsEmitted, isFalse);
        expect(result.officialMetricsAllowed, isFalse);
        expect(result.numericMoveScoresComputed, isFalse);
        expect(result.moveRankingComputed, isFalse);
      },
    );

    test('validator rejects forbidden output seams', () {
      final unsafePrototype = _mutatedPacket(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
        (packet) => packet.copyWith(
          isClassifierLabel: true,
          hasNumericScore: true,
          ranksMoves: true,
          isOfficialMetric: true,
        ),
      );
      final result = _matrix(prototypeResult: unsafePrototype);

      expect(result.unsafePacketCount, greaterThan(0));
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('packetUnsafeOutputBoundary'),
      );
    });
  });

  group('InternalPacketReviewAggregationMatrix reports', () {
    test('markdown report includes packet table and aggregate counts', () {
      final report = _matrix().renderMarkdownReport();

      expect(report, contains('# Internal Packet Review Aggregation Matrix'));
      expect(report, contains('matrix status: readyWithWarnings'));
      expect(report, contains('## Packet Review Table'));
      expect(report, contains('## Aggregate Counts'));
      expect(report, contains('tacticalInternalPrototypeScope-packet'));
    });

    test('markdown report includes proof-limited rows and warning scopes', () {
      final report = _matrix().renderMarkdownReport();

      expect(report, contains('## Proof-Limited Packets'));
      expect(
        report,
        contains('androidProofConfidenceInternalPrototypeScope-packet'),
      );
      expect(report, contains('## Warning-Limited Scopes'));
      expect(report, contains('kingSafetyInternalPrototypeScope'));
    });

    test('markdown report includes blocked and future-only scopes', () {
      final report = _matrix().renderMarkdownReport();

      expect(report, contains('## Blocked And Future-Only Scopes'));
      expect(report, contains('quietPreparatoryPrototypeScope'));
      expect(report, contains('cpLossPrototypeScope'));
      expect(report, contains('winProbabilityPrototypeScope'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _matrix().renderJsonReport();
      final second = _matrix().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        internalPacketReviewAggregationMatrixReportVersion,
      );
      expect(decoded['matrixStatus'], 'readyWithWarnings');
      expect(decoded['rows'], isA<List<Object?>>());
    });

    test(
      'reports contain no raw UCI spam, PV dumps, final labels, metrics, scores, or ordering output',
      () {
        final report = _matrix().renderMarkdownReport();

        expect(report, isNot(contains('uciok')));
        expect(report, isNot(contains('readyok')));
        expect(report, isNot(contains('info depth')));
        expect(report, isNot(contains('bestmove e2e4')));
        expect(report, isNot(contains(' pv ')));
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
        expect(report, isNot(contains('moveScore')));
        expect(report, isNot(contains('rankedMoves')));
        expect(report, isNot(contains('moveRanking')));
      },
    );

    test('validator rejects unsafe report text', () {
      final findings = const InternalPacketReviewAggregationMatrixValidator()
          .validateReportText('uciok\nmoveScore: 1\nrankedMoves\n');

      expect(
        findings.map((finding) => finding.id),
        contains('rawUciReportText'),
      );
      expect(
        findings.map((finding) => finding.id),
        contains('numericMoveScoreReportText'),
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
          'lib/features/pgn_review/application/internal_packet_review_aggregation_matrix.dart',
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

InternalPacketReviewAggregationMatrixResult _matrix({
  NarrowInternalNonLabelAnalysisPrototypeResult? prototypeResult,
  InternalNonLabelPrototypeReadinessResult? readinessResult,
  InternalSignalObservationReviewMatrixResult? reviewResult,
}) {
  return const InternalPacketReviewAggregationMatrix().evaluate(
    InternalPacketReviewAggregationMatrixRequest(
      prototypeResult: prototypeResult,
      readinessResult: readinessResult,
      reviewResult: reviewResult,
    ),
  );
}

NarrowInternalNonLabelAnalysisPrototypeResult _prototype() {
  return const NarrowInternalNonLabelAnalysisPrototype().run(
    const NarrowInternalNonLabelAnalysisPrototypeRequest(),
  );
}

NarrowInternalNonLabelAnalysisPrototypeResult _mutatedPacket(
  InternalNonLabelPrototypeScopeId scopeId,
  NarrowInternalAnalysisPrototypePacket Function(
    NarrowInternalAnalysisPrototypePacket packet,
  )
  mutate,
) {
  final prototype = _prototype();
  return prototype.copyWith(
    packets: prototype.packets
        .map(
          (packet) =>
              packet.allowedScopeId == scopeId ? mutate(packet) : packet,
        )
        .toList(growable: false),
  );
}

void _expectWarningOnly(InternalNonLabelPrototypeScopeId scopeId) {
  final row = _matrix().row(scopeId);

  expect(row.reviewStatus, InternalPacketReviewStatus.warningOnly);
  expect(
    row.recommendation,
    InternalPacketReviewRecommendation.keepWarningLimited,
  );
  expect(row.coverageGapIds, contains(scopeId.wire));
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
