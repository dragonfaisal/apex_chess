@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_observation_review_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NarrowInternalNonLabelAnalysisPrototype safe demo', () {
    test('consumes safe Phase 31L readiness result', () {
      final result = _prototype();

      expect(
        result.readinessStatus,
        InternalNonLabelPrototypeReadinessStatus.readyWithCoverageWarnings,
      );
      expect(result.safeForPhase32AInternalPrototype, isTrue);
      expect(result.readinessGatePassed, isTrue);
      expect(result.reviewUnsafeCount, 0);
      expect(result.consistencyBlockerCount, 0);
      expect(result.consistencyCriticalCount, 0);
    });

    test('default prototype completes with coverage warnings', () {
      final result = _prototype();

      expect(
        result.prototypeStatus,
        NarrowInternalNonLabelAnalysisPrototypeStatus
            .completedWithCoverageWarnings,
      );
      expect(result.packetCount, 6);
      expect(result.allowedScopePacketIds, _allowedScopes);
      expect(result.warningLimitedScopeIds, _warningScopes);
      expect(result.blockedScopeIds, _blockedScopes);
    });
  });

  group('NarrowInternalNonLabelAnalysisPrototype readiness gate first', () {
    test('prototype skips when readiness gate is unsafe', () {
      final readiness = _readiness().copyWith(
        overallStatus:
            InternalNonLabelPrototypeReadinessStatus.blockedByPolicyBoundary,
        safeForPhase32AInternalPrototype: false,
      );
      final result = _prototype(readinessResult: readiness);

      expect(
        result.prototypeStatus,
        NarrowInternalNonLabelAnalysisPrototypeStatus.skippedByReadinessGate,
      );
      expect(result.packets, isEmpty);
    });

    test('prototype skips when unsafe observations exist', () {
      final review = _review().copyWith(
        unsafeCount: 1,
        safeForLaterInternalPrototype: false,
      );
      final result = _prototype(reviewResult: review);

      expect(
        result.prototypeStatus,
        NarrowInternalNonLabelAnalysisPrototypeStatus.skippedByReadinessGate,
      );
      expect(result.reviewUnsafeCount, 1);
    });

    test('prototype skips when consistency blockers exist', () {
      final consistency = _consistency().copyWith(
        blockerCount: 1,
        safeForGuardedInternalExperiment: false,
      );
      final result = _prototype(consistencyResult: consistency);

      expect(
        result.prototypeStatus,
        NarrowInternalNonLabelAnalysisPrototypeStatus.skippedByReadinessGate,
      );
      expect(result.consistencyBlockerCount, 1);
    });
  });

  group('NarrowInternalNonLabelAnalysisPrototype packet generation', () {
    test('creates tactical packet', () {
      final packet = _prototype().packet(
        InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
      );

      expect(
        packet.activeSignalIds,
        contains(InternalNonLabelSignalId.tacticalPressureSignal),
      );
      expect(packet.supportCaseIds, contains('simple-tactical-capture-check'));
    });

    test('creates material swing packet', () {
      final packet = _prototype().packet(
        InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
      );

      expect(
        packet.activeSignalIds,
        contains(InternalNonLabelSignalId.materialSwingSignal),
      );
      expect(packet.supportCaseIds, contains('queen-win-major-swing'));
    });

    test('creates forcing line packet', () {
      final packet = _prototype().packet(
        InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
      );

      expect(
        packet.activeSignalIds,
        contains(InternalNonLabelSignalId.forcingLineSignal),
      );
      expect(
        packet.supportCaseIds,
        contains('forcing-line-variation-hard-case'),
      );
    });

    test('creates candidate spread packet', () {
      final packet = _prototype().packet(
        InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
      );

      expect(
        packet.activeSignalIds,
        contains(InternalNonLabelSignalId.candidateSpreadSignal),
      );
      expect(packet.supportCaseIds, contains('mate-threat-fast-evidence'));
    });

    test('creates PV and MultiPV packet', () {
      final packet = _prototype().packet(
        InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
      );

      expect(
        packet.activeSignalIds,
        contains(InternalNonLabelSignalId.pvMultiPvSupportSignal),
      );
      expect(packet.androidProofCaseIds, _provenAndroidIds);
    });

    test('creates Android proof confidence packet', () {
      final packet = _prototype().packet(
        InternalNonLabelPrototypeScopeId
            .androidProofConfidenceInternalPrototypeScope,
      );

      expect(
        packet.activeSignalIds,
        contains(InternalNonLabelSignalId.androidProofConfidenceSignal),
      );
      expect(packet.androidProofCaseIds, _provenAndroidIds);
    });

    test('Android proof packet includes only proven IDs', () {
      final result = _prototype();

      expect(result.androidProofCaseIds, _provenAndroidIds);
      for (final packet in result.packets) {
        for (final caseId in packet.androidProofCaseIds) {
          expect(_provenAndroidIds, contains(caseId));
        }
      }
    });

    test('unproven Android proof ID is rejected', () {
      final review = _mutatedReviewRow(
        InternalNonLabelSignalId.androidProofConfidenceSignal,
        (row) => row.copyWith(
          androidProofCaseIds: <String>[
            ...row.androidProofCaseIds,
            'unproven-proof-case',
          ],
        ),
      );
      final readiness = _readiness(reviewResult: review);
      final result = _prototype(
        reviewResult: review,
        readinessResult: readiness,
      );

      expect(
        result.prototypeStatus,
        NarrowInternalNonLabelAnalysisPrototypeStatus.blockedByPolicy,
      );
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('unprovenAndroidProofCitation'),
      );
    });
  });

  group('NarrowInternalNonLabelAnalysisPrototype scope boundaries', () {
    test('warning-limited scopes appear only as warnings', () {
      final result = _prototype();

      expect(result.allowedScopePacketIds, isNot(containsAll(_warningScopes)));
      expect(
        result.warningLimitedScopeIds,
        containsAll(<InternalNonLabelPrototypeScopeId>[
          InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
          InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
          InternalNonLabelPrototypeScopeId
              .suppressionSafetyInternalPrototypeScope,
          InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
        ]),
      );
    });

    test('blocked scopes remain blocked', () {
      final result = _prototype();

      expect(result.blockedScopeIds, containsAll(_blockedScopes));
      expect(
        result.allowedScopePacketIds,
        isNot(
          contains(
            InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
          ),
        ),
      );
      expect(
        result.allowedScopePacketIds,
        isNot(
          contains(InternalNonLabelPrototypeScopeId.productLabelPrototypeScope),
        ),
      );
      expect(
        result.allowedScopePacketIds,
        isNot(
          contains(
            InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
          ),
        ),
      );
      expect(
        result.allowedScopePacketIds,
        isNot(contains(InternalNonLabelPrototypeScopeId.cpLossPrototypeScope)),
      );
      expect(
        result.allowedScopePacketIds,
        isNot(
          contains(
            InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
          ),
        ),
      );
      expect(
        result.allowedScopePacketIds,
        isNot(
          contains(InternalNonLabelPrototypeScopeId.uiProductIntegrationScope),
        ),
      );
      expect(
        result.allowedScopePacketIds,
        isNot(
          contains(InternalNonLabelPrototypeScopeId.backendIntegrationScope),
        ),
      );
      expect(
        result.allowedScopePacketIds,
        isNot(contains(InternalNonLabelPrototypeScopeId.persistenceScope)),
      );
      expect(
        result.allowedScopePacketIds,
        isNot(
          contains(InternalNonLabelPrototypeScopeId.directEngineAccessScope),
        ),
      );
    });

    test('no packet emits labels, scores, rankings, or official metrics', () {
      final result = _prototype();

      for (final packet in result.packets) {
        expect(packet.isProductOutput, isFalse);
        expect(packet.isClassifierLabel, isFalse);
        expect(packet.isOfficialMetric, isFalse);
        expect(packet.hasNumericScore, isFalse);
        expect(packet.ranksMoves, isFalse);
        expect(packet.quietScopeActive, isFalse);
        expect(packet.cpLossComputationImplemented, isFalse);
        expect(packet.winProbabilityComputationImplemented, isFalse);
      }
      expect(result.productLabelsEmitted, isFalse);
      expect(result.classifierLabelsEmitted, isFalse);
      expect(result.finalMoveLabelsEmitted, isFalse);
      expect(result.officialMetricsAllowed, isFalse);
      expect(result.numericMoveScoresComputed, isFalse);
      expect(result.moveRankingComputed, isFalse);
    });

    test('packet without support cases is invalid', () {
      final review = _mutatedReviewRow(
        InternalNonLabelSignalId.tacticalPressureSignal,
        (row) => row.copyWith(supportCaseIds: const <String>[]),
      );
      final readiness = _readiness(reviewResult: review);
      final result = _prototype(
        reviewResult: review,
        readinessResult: readiness,
      );

      expect(
        result.prototypeStatus,
        NarrowInternalNonLabelAnalysisPrototypeStatus.blockedByPolicy,
      );
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('packetWithoutSupportCases'),
      );
    });

    test('warning-limited scope cannot become allowed packet', () {
      final readiness = _readiness();
      final mutatedScopes = readiness.scopeRecords
          .map(
            (scope) =>
                scope.scopeId ==
                    InternalNonLabelPrototypeScopeId
                        .kingSafetyInternalPrototypeScope
                ? scope.copyWith(
                    readiness: InternalNonLabelPrototypeScopeReadiness
                        .allowedWithWarnings,
                  )
                : scope,
          )
          .toList(growable: false);
      final mutatedReadiness = readiness.copyWith(
        scopeRecords: mutatedScopes,
        allowedScopeIds: <InternalNonLabelPrototypeScopeId>[
          ...readiness.allowedScopeIds,
          InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
        ],
        warningLimitedScopeIds: readiness.warningLimitedScopeIds
            .where(
              (scope) =>
                  scope !=
                  InternalNonLabelPrototypeScopeId
                      .kingSafetyInternalPrototypeScope,
            )
            .toList(growable: false),
      );

      final result = _prototype(readinessResult: mutatedReadiness);

      expect(
        result.prototypeStatus,
        NarrowInternalNonLabelAnalysisPrototypeStatus.blockedByPolicy,
      );
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('warningLimitedScopePacket'),
      );
    });
  });

  group('NarrowInternalNonLabelAnalysisPrototype reports', () {
    test('markdown report includes prototype sections', () {
      final report = _prototype().renderMarkdownReport();

      expect(
        report,
        contains('# Narrow Internal Non-Label Analysis Prototype'),
      );
      expect(
        report,
        contains('prototype status: completedWithCoverageWarnings'),
      );
      expect(report, contains('readiness gate status'));
      expect(report, contains('## Packet Table'));
      expect(report, contains('## Warning-Limited Scopes'));
      expect(report, contains('## Blocked Scopes'));
      expect(report, contains('## Future Prerequisites'));
      expect(report, contains('tacticalInternalPrototypeScope'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _prototype().renderJsonReport();
      final second = _prototype().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        narrowInternalNonLabelAnalysisPrototypeReportVersion,
      );
      expect(decoded['prototypeStatus'], 'completedWithCoverageWarnings');
      expect(decoded['packets'], isA<List<Object?>>());
    });

    test(
      'reports contain no raw engine spam, PV dumps, labels, metrics, scores, or rankings',
      () {
        final report = _prototype().renderMarkdownReport();

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

    test('validator rejects report text with forbidden output seams', () {
      final findings = const NarrowInternalNonLabelAnalysisPrototypeValidator()
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
          'lib/features/pgn_review/application/narrow_internal_non_label_analysis_prototype.dart',
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

NarrowInternalNonLabelAnalysisPrototypeResult _prototype({
  InternalNonLabelPrototypeReadinessResult? readinessResult,
  InternalSignalObservationReviewMatrixResult? reviewResult,
  InternalSignalProfileConsistencyMatrixResult? consistencyResult,
}) {
  return const NarrowInternalNonLabelAnalysisPrototype().run(
    NarrowInternalNonLabelAnalysisPrototypeRequest(
      readinessResult: readinessResult,
      reviewResult: reviewResult,
      consistencyResult: consistencyResult,
    ),
  );
}

InternalNonLabelPrototypeReadinessResult _readiness({
  InternalSignalObservationReviewMatrixResult? reviewResult,
  InternalSignalProfileConsistencyMatrixResult? consistencyResult,
}) {
  return const InternalNonLabelPrototypeReadinessGate().evaluate(
    InternalNonLabelPrototypeReadinessGateRequest(
      reviewResult: reviewResult,
      consistencyResult: consistencyResult,
    ),
  );
}

InternalSignalObservationReviewMatrixResult _review() {
  return const InternalSignalObservationReviewMatrix().evaluate(
    const InternalSignalObservationReviewMatrixRequest(),
  );
}

InternalSignalProfileConsistencyMatrixResult _consistency() {
  return const InternalSignalProfileConsistencyMatrix().evaluate(
    const InternalSignalProfileConsistencyMatrixRequest(),
  );
}

InternalSignalObservationReviewMatrixResult _mutatedReviewRow(
  InternalNonLabelSignalId signalId,
  InternalSignalObservationReviewRow Function(
    InternalSignalObservationReviewRow row,
  )
  mutate,
) {
  final review = _review();
  return review.copyWith(
    rows: review.rows
        .map((row) => row.signalId == signalId ? mutate(row) : row)
        .toList(growable: false),
  );
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}

const _allowedScopes = <InternalNonLabelPrototypeScopeId>[
  InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.materialSwingInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.forcingLineInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.candidateSpreadInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.pvMultiPvSupportInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.androidProofConfidenceInternalPrototypeScope,
];

const _warningScopes = <InternalNonLabelPrototypeScopeId>[
  InternalNonLabelPrototypeScopeId.kingSafetyInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.endgameInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.suppressionSafetyInternalPrototypeScope,
  InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
];

const _blockedScopes = <InternalNonLabelPrototypeScopeId>[
  InternalNonLabelPrototypeScopeId.quietPreparatoryPrototypeScope,
  InternalNonLabelPrototypeScopeId.productLabelPrototypeScope,
  InternalNonLabelPrototypeScopeId.advancedLabelPrototypeScope,
  InternalNonLabelPrototypeScopeId.officialMetricPrototypeScope,
  InternalNonLabelPrototypeScopeId.cpLossPrototypeScope,
  InternalNonLabelPrototypeScopeId.winProbabilityPrototypeScope,
  InternalNonLabelPrototypeScopeId.uiProductIntegrationScope,
  InternalNonLabelPrototypeScopeId.backendIntegrationScope,
  InternalNonLabelPrototypeScopeId.persistenceScope,
  InternalNonLabelPrototypeScopeId.directEngineAccessScope,
];

const _provenAndroidIds = <String>[
  'mate-threat-fast-evidence',
  'queen-win-major-swing',
  'simple-tactical-capture-check',
];
