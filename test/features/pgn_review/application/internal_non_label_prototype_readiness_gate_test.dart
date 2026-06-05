@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_experiment_runner.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_observation_review_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalNonLabelPrototypeReadinessGate safe demo', () {
    test('consumes safe Phase 31K review result', () {
      final result = _readiness();

      expect(
        result.reviewMatrixStatus,
        InternalSignalObservationReviewMatrixStatus.readyWithWarnings,
      );
      expect(
        result.runnerStatus,
        InternalSignalExperimentRunnerStatus.completedWithWarnings,
      );
      expect(
        result.consistencyMatrixStatus,
        InternalSignalProfileConsistencyMatrixStatus.consistentWithWarnings,
      );
      expect(result.reviewUnsafeCount, 0);
      expect(result.consistencyBlockerCount, 0);
      expect(result.consistencyCriticalCount, 0);
      expect(result.safeForPhase32AInternalPrototype, isTrue);
    });

    test('default readiness allows only a narrow internal prototype', () {
      final result = _readiness();

      expect(
        result.overallStatus,
        InternalNonLabelPrototypeReadinessStatus.readyWithCoverageWarnings,
      );
      expect(
        result.phase32ARecommendation,
        InternalNonLabelPrototypeReadinessRecommendation
            .proceedToNarrowInternalPrototype,
      );
      expect(result.allowedScopeIds, _allowedScopes);
      expect(result.warningLimitedScopeIds, _warningScopes);
      expect(result.blockedScopeIds, _blockedScopes);
    });
  });

  group('InternalNonLabelPrototypeReadinessGate blockers', () {
    test('unsafeCount greater than zero blocks readiness', () {
      final review = _review().copyWith(
        unsafeCount: 1,
        safeForLaterInternalPrototype: false,
      );
      final result = _readiness(reviewResult: review);

      expect(
        result.overallStatus,
        InternalNonLabelPrototypeReadinessStatus.blockedByUnsafeObservation,
      );
      expect(result.safeForPhase32AInternalPrototype, isFalse);
    });

    test('consistency blocker blocks readiness', () {
      final consistency = _consistency().copyWith(
        blockerCount: 1,
        safeForGuardedInternalExperiment: false,
      );
      final result = _readiness(consistencyResult: consistency);

      expect(
        result.overallStatus,
        InternalNonLabelPrototypeReadinessStatus.blockedByConsistencyFailure,
      );
      expect(result.safeForPhase32AInternalPrototype, isFalse);
    });

    test('consistency critical blocks readiness', () {
      final consistency = _consistency().copyWith(
        criticalCount: 1,
        safeForGuardedInternalExperiment: false,
      );
      final result = _readiness(consistencyResult: consistency);

      expect(
        result.overallStatus,
        InternalNonLabelPrototypeReadinessStatus.blockedByConsistencyFailure,
      );
      expect(result.safeForPhase32AInternalPrototype, isFalse);
    });

    test('unproven Android proof blocks readiness', () {
      final review = _review().copyWith(
        unprovenAndroidCaseIds: const <String>['unproven-proof-case'],
      );
      final result = _readiness(reviewResult: review);

      expect(
        result.overallStatus,
        InternalNonLabelPrototypeReadinessStatus.blockedByUnprovenAndroidProof,
      );
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('unprovenAndroidProofCitation'),
      );
    });

    test('quiet/preparatory activation blocks readiness', () {
      final review = _mutatedReviewRow(
        InternalNonLabelSignalId.quietPreparatorySignalExcluded,
        (row) => row.copyWith(
          observed: true,
          status: InternalSignalObservationReviewStatus.stable,
          supportCaseIds: const <String>['quiet-preparatory-uncertain'],
        ),
      );
      final result = _readiness(reviewResult: review);

      expect(
        result.overallStatus,
        InternalNonLabelPrototypeReadinessStatus.blockedByQuietScope,
      );
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('quietScopeActivated'),
      );
    });
  });

  group('InternalNonLabelPrototypeReadinessGate scope readiness', () {
    test(
      'stable tactical, material, forcing, spread, PV, and proof scopes are allowed',
      () {
        final result = _readiness();

        for (final scopeId in _allowedScopes) {
          final scope = result.scope(scopeId);
          expect(scope.isAllowed, isTrue);
          expect(scope.supportCaseIds, isNotEmpty);
        }
        expect(
          result
              .scope(
                InternalNonLabelPrototypeScopeId.tacticalInternalPrototypeScope,
              )
              .supportCaseIds,
          contains('simple-tactical-capture-check'),
        );
        expect(
          result
              .scope(
                InternalNonLabelPrototypeScopeId
                    .materialSwingInternalPrototypeScope,
              )
              .supportCaseIds,
          contains('queen-win-major-swing'),
        );
      },
    );

    test('Android-proof scope is allowed only for the proven IDs', () {
      final result = _readiness();

      expect(result.androidProofCaseIds, _provenAndroidIds);
      expect(
        result
            .scope(
              InternalNonLabelPrototypeScopeId
                  .androidProofConfidenceInternalPrototypeScope,
            )
            .androidProofCaseIds,
        _provenAndroidIds,
      );
    });

    test(
      'king, endgame, suppression, and budget scopes are warning-limited',
      () {
        final result = _readiness();

        for (final scopeId in _warningScopes) {
          final scope = result.scope(scopeId);
          expect(
            scope.readiness,
            InternalNonLabelPrototypeScopeReadiness.warningLimited,
          );
          expect(scope.coverageGapIds, contains(scopeId.wire));
          expect(
            scope.recommendation,
            InternalNonLabelPrototypeReadinessRecommendation
                .addGoldenCoverageFirst,
          );
        }
      },
    );

    test(
      'quiet, product, metrics, future, and integration scopes are blocked',
      () {
        final result = _readiness();

        for (final scopeId in _blockedScopes) {
          final scope = result.scope(scopeId);
          expect(scope.isBlocked, isTrue, reason: scopeId.wire);
          expect(scope.policyBlockers, isNotEmpty, reason: scopeId.wire);
        }
      },
    );

    test('stable allowed scopes list support case IDs', () {
      final result = _readiness();

      for (final scopeId in result.allowedScopeIds) {
        expect(result.scope(scopeId).supportCaseIds, isNotEmpty);
      }
      expect(result.supportCaseIds, contains('mate-threat-fast-evidence'));
      expect(result.supportCaseIds, contains('queen-win-major-swing'));
      expect(result.supportCaseIds, contains('simple-tactical-capture-check'));
    });

    test('warning-limited scopes preserve coverage-gap recommendations', () {
      final result = _readiness();

      expect(
        result.coverageGapIds,
        containsAll(_warningScopes.map((scope) => scope.wire)),
      );
      expect(
        result.warningLimitedScopeIds,
        contains(
          InternalNonLabelPrototypeScopeId.budgetRiskInternalPrototypeScope,
        ),
      );
    });
  });

  group('InternalNonLabelPrototypeReadinessGate output guardrails', () {
    test(
      'no labels, scores, rankings, metrics, engine, UI, backend, or persistence flags are emitted',
      () {
        final result = _readiness();

        expect(result.productLabelsEmitted, isFalse);
        expect(result.classifierLabelsEmitted, isFalse);
        expect(result.finalMoveLabelsEmitted, isFalse);
        expect(result.officialMetricsAllowed, isFalse);
        expect(result.cpLossComputationImplemented, isFalse);
        expect(result.winProbabilityComputationImplemented, isFalse);
        expect(result.numericMoveScoresComputed, isFalse);
        expect(result.moveRankingComputed, isFalse);
        expect(result.directEngineAccessUsed, isFalse);
        expect(result.uiOutputUsed, isFalse);
        expect(result.backendOutputUsed, isFalse);
        expect(result.persistenceUsed, isFalse);
      },
    );

    test(
      'readiness rejects UI, backend, persistence, and direct engine seams',
      () {
        final result = _readiness().copyWith(
          uiOutputUsed: true,
          backendOutputUsed: true,
          persistenceUsed: true,
          directEngineAccessUsed: true,
        );
        final findings = const InternalNonLabelPrototypeReadinessGateValidator()
            .validate(
              result,
              reviewResult: _review(),
              consistencyResult: _consistency(),
            );

        expect(
          findings.map((finding) => finding.id),
          contains('readinessBoundaryPolicyViolation'),
        );
      },
    );
  });

  group('InternalNonLabelPrototypeReadinessGate reports', () {
    test('markdown report includes readiness sections', () {
      final report = _readiness().renderMarkdownReport();

      expect(report, contains('# Internal Non-Label Prototype Readiness Gate'));
      expect(report, contains('readiness status: readyWithCoverageWarnings'));
      expect(report, contains('Phase 32A recommendation'));
      expect(report, contains('## Allowed Internal Scopes'));
      expect(report, contains('## Warning-Limited Scopes'));
      expect(report, contains('## Blocked Scopes'));
      expect(report, contains('tacticalInternalPrototypeScope'));
    });

    test('JSON report is deterministic and valid', () {
      final first = _readiness().renderJsonReport();
      final second = _readiness().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        internalNonLabelPrototypeReadinessGateReportVersion,
      );
      expect(decoded['overallStatus'], 'readyWithCoverageWarnings');
      expect(decoded['allowedScopeIds'], isA<List<Object?>>());
    });

    test(
      'reports contain no raw engine spam, PV dumps, labels, metrics, scores, or rankings',
      () {
        final report = _readiness().renderMarkdownReport();

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
      final findings = const InternalNonLabelPrototypeReadinessGateValidator()
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
          'lib/features/pgn_review/application/internal_non_label_prototype_readiness_gate.dart',
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
