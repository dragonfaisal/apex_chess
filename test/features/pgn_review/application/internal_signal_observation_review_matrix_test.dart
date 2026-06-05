@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_experiment_runner.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_observation_review_matrix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalSignalObservationReviewMatrix safe demo', () {
    test('consumes safe runner result', () {
      final result = _review();

      expect(
        result.matrixStatus,
        InternalSignalObservationReviewMatrixStatus.readyWithWarnings,
      );
      expect(
        result.runnerStatus,
        InternalSignalExperimentRunnerStatus.completedWithWarnings,
      );
      expect(result.totalRows, 16);
      expect(result.unsafeCount, 0);
      expect(result.safeForLaterInternalPrototype, isTrue);
    });

    test('stable active observations have support cases', () {
      final result = _review();

      for (final row in result.stableRows) {
        expect(row.observed, isTrue);
        expect(row.supportCaseIds, isNotEmpty);
        expect(row.sourceDimensionIds, isNotEmpty);
        expect(row.evidenceAreaIds, isNotEmpty);
      }
    });
  });

  group('InternalSignalObservationReviewMatrix active observation review', () {
    test('tactical observation is stable', () {
      final row = _review().row(
        InternalNonLabelSignalId.tacticalPressureSignal,
      );

      expect(row.status, InternalSignalObservationReviewStatus.stable);
      expect(row.supportCaseIds, contains('simple-tactical-capture-check'));
    });

    test('material observation is stable', () {
      final row = _review().row(InternalNonLabelSignalId.materialSwingSignal);

      expect(row.status, InternalSignalObservationReviewStatus.stable);
      expect(row.supportCaseIds, contains('queen-win-major-swing'));
    });

    test('forcing observation is stable', () {
      final row = _review().row(InternalNonLabelSignalId.forcingLineSignal);

      expect(row.status, InternalSignalObservationReviewStatus.stable);
      expect(row.supportCaseIds, contains('forcing-line-variation-hard-case'));
    });

    test('candidate-spread observation is stable', () {
      final row = _review().row(InternalNonLabelSignalId.candidateSpreadSignal);

      expect(row.status, InternalSignalObservationReviewStatus.stable);
      expect(row.supportCaseIds, contains('mate-threat-fast-evidence'));
    });

    test('PV and MultiPV observation is stable or stable with warnings', () {
      final row = _review().row(
        InternalNonLabelSignalId.pvMultiPvSupportSignal,
      );

      expect(
        row.status,
        isIn(<InternalSignalObservationReviewStatus>[
          InternalSignalObservationReviewStatus.stable,
          InternalSignalObservationReviewStatus.stableWithWarnings,
        ]),
      );
      expect(row.androidProofCaseIds, [
        'mate-threat-fast-evidence',
        'queen-win-major-swing',
        'simple-tactical-capture-check',
      ]);
    });

    test('Android-proof observation uses only proven IDs', () {
      final result = _review();
      final row = result.row(
        InternalNonLabelSignalId.androidProofConfidenceSignal,
      );

      expect(row.androidProofCaseIds, result.provenAndroidCaseIds);
      expect(row.androidProofCaseIds, [
        'mate-threat-fast-evidence',
        'queen-win-major-swing',
        'simple-tactical-capture-check',
      ]);
      expect(result.unprovenAndroidCaseIds, isEmpty);
    });

    test('unproven Android proof ID is rejected', () {
      final runner = _runner();
      final mutated = runner.copyWith(
        observations: runner.observations
            .map(
              (observation) =>
                  observation.signalId ==
                      InternalNonLabelSignalId.androidProofConfidenceSignal
                  ? observation.copyWith(
                      androidProofCaseIds: <String>[
                        ...observation.androidProofCaseIds,
                        'unproven-proof-case',
                      ],
                    )
                  : observation,
            )
            .toList(growable: false),
      );

      final result = _review(runnerResult: mutated);

      expect(result.unsafeCount, greaterThan(0));
      expect(
        result.validationFindings.map((finding) => finding.id),
        contains('unprovenAndroidProofCitation'),
      );
    });
  });

  group('InternalSignalObservationReviewMatrix warning and policy rows', () {
    test(
      'king-safety observation remains warning-only or stable with warnings',
      () {
        final row = _review().row(InternalNonLabelSignalId.kingSafetySignal);

        expect(
          row.status,
          isIn(<InternalSignalObservationReviewStatus>[
            InternalSignalObservationReviewStatus.warningOnly,
            InternalSignalObservationReviewStatus.stableWithWarnings,
          ]),
        );
        expect(row.warningReason, isNotEmpty);
      },
    );

    test('endgame observation remains warning or coverage-needed', () {
      final row = _review().row(InternalNonLabelSignalId.endgameSupportSignal);

      expect(
        row.status,
        isIn(<InternalSignalObservationReviewStatus>[
          InternalSignalObservationReviewStatus.warningOnly,
          InternalSignalObservationReviewStatus.needsMoreGoldenCoverage,
        ]),
      );
    });

    test('suppression observation remains warning or coverage-needed', () {
      final row = _review().row(
        InternalNonLabelSignalId.suppressionSafetySignal,
      );

      expect(
        row.status,
        isIn(<InternalSignalObservationReviewStatus>[
          InternalSignalObservationReviewStatus.warningOnly,
          InternalSignalObservationReviewStatus.needsMoreGoldenCoverage,
        ]),
      );
      expect(
        row.recommendation,
        isNot(InternalSignalObservationReviewRecommendation.keepStable),
      );
    });

    test('budget observation remains warning or coverage-needed', () {
      final row = _review().row(InternalNonLabelSignalId.budgetRiskSignal);

      expect(
        row.status,
        isIn(<InternalSignalObservationReviewStatus>[
          InternalSignalObservationReviewStatus.warningOnly,
          InternalSignalObservationReviewStatus.needsMoreGoldenCoverage,
        ]),
      );
      expect(
        row.recommendation,
        InternalSignalObservationReviewRecommendation.addGoldenCoverage,
      );
    });

    test('quiet observation remains excluded', () {
      final row = _review().row(
        InternalNonLabelSignalId.quietPreparatorySignalExcluded,
      );

      expect(row.observed, isFalse);
      expect(
        row.status,
        InternalSignalObservationReviewStatus.excludedCorrectly,
      );
      expect(
        row.recommendation,
        InternalSignalObservationReviewRecommendation.keepExcluded,
      );
    });

    test('product, advanced, and metric observations remain blocked', () {
      final result = _review();

      for (final id in const <InternalNonLabelSignalId>[
        InternalNonLabelSignalId.productLabelSignalBlocked,
        InternalNonLabelSignalId.advancedLabelSignalBlocked,
        InternalNonLabelSignalId.officialMetricSignalBlocked,
      ]) {
        final row = result.row(id);
        expect(row.observed, isFalse);
        expect(
          row.status,
          InternalSignalObservationReviewStatus.blockedCorrectly,
        );
      }
    });

    test('CP-loss and win probability remain future-only', () {
      final result = _review();

      expect(
        result.row(InternalNonLabelSignalId.cpLossSignalFutureOnly).status,
        InternalSignalObservationReviewStatus.futureOnlyCorrectly,
      );
      expect(
        result
            .row(InternalNonLabelSignalId.winProbabilitySignalFutureOnly)
            .status,
        InternalSignalObservationReviewStatus.futureOnlyCorrectly,
      );
    });
  });

  group('InternalSignalObservationReviewMatrix validator seams', () {
    test('no observation emits labels, scores, rankings, or metrics', () {
      final result = _review();
      final runner = _runner();

      for (final observation in runner.observations) {
        expect(observation.isClassifierLabel, isFalse);
        expect(observation.hasNumericScore, isFalse);
        expect(observation.ranksMoves, isFalse);
        expect(observation.isOfficialMetric, isFalse);
      }
      expect(result.classifierLabelsEmitted, isFalse);
      expect(result.numericMoveScoresComputed, isFalse);
      expect(result.moveRankingComputed, isFalse);
      expect(result.officialMetricsAllowed, isFalse);
    });

    test('stable observation without support becomes unsafe or invalid', () {
      final result = _review();
      final mutated = result.copyWith(
        rows: result.rows
            .map(
              (row) =>
                  row.signalId ==
                      InternalNonLabelSignalId.tacticalPressureSignal
                  ? row.copyWith(supportCaseIds: <String>[])
                  : row,
            )
            .toList(growable: false),
      );
      final findings = const InternalSignalObservationReviewMatrixValidator()
          .validate(mutated, runnerResult: _runner());

      expect(
        findings.map((finding) => finding.id),
        contains('stableObservationWithoutSupport'),
      );
    });

    test('warning observation without warning reason becomes invalid', () {
      final result = _review();
      final mutated = result.copyWith(
        rows: result.rows
            .map(
              (row) => row.signalId == InternalNonLabelSignalId.budgetRiskSignal
                  ? row.copyWith(warningReason: '', futurePrerequisite: '')
                  : row,
            )
            .toList(growable: false),
      );
      final findings = const InternalSignalObservationReviewMatrixValidator()
          .validate(mutated, runnerResult: _runner());

      expect(
        findings.map((finding) => finding.id),
        contains('warningObservationWithoutReason'),
      );
    });

    test('validator rejects numeric score seam', () {
      final findings = _findingsWithObservation(
        InternalNonLabelSignalId.tacticalPressureSignal,
        (observation) => observation.copyWith(hasNumericScore: true),
      );

      expect(
        findings.map((finding) => finding.id),
        contains('observationEmitsNumericScore'),
      );
    });

    test('validator rejects quiet activation seam', () {
      final findings = _findingsWithObservation(
        InternalNonLabelSignalId.quietPreparatorySignalExcluded,
        (observation) =>
            observation.copyWith(observed: true, quietScopeActive: true),
      );

      expect(
        findings.map((finding) => finding.id),
        contains('quietPreparatoryObservationActivated'),
      );
    });
  });

  group('InternalSignalObservationReviewMatrix reports and guardrails', () {
    test('markdown report includes review status', () {
      final report = _review().renderMarkdownReport();

      expect(report, contains('# Internal Signal Observation Review Matrix'));
      expect(report, contains('review matrix status: readyWithWarnings'));
      expect(report, contains('unsafe observation count: 0'));
    });

    test('markdown report includes stable and warning observations', () {
      final report = _review().renderMarkdownReport();

      expect(report, contains('Stable Observations'));
      expect(report, contains('tacticalPressureSignal'));
      expect(report, contains('Warning Observations'));
      expect(report, contains('budgetRiskSignal'));
    });

    test('markdown report includes recommendations', () {
      final report = _review().renderMarkdownReport();

      expect(report, contains('Recommendations'));
      expect(report, contains('keepStable'));
      expect(report, contains('addGoldenCoverage'));
    });

    test('json report is deterministic and valid', () {
      final first = _review().renderJsonReport();
      final second = _review().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(
        decoded['version'],
        internalSignalObservationReviewMatrixReportVersion,
      );
      expect(decoded['matrixStatus'], 'readyWithWarnings');
      expect(decoded['rows'], isA<List<Object?>>());
    });

    test('reports contain no raw UCI spam or PV dumps', () {
      final report = _review().renderMarkdownReport();
      final findings = const InternalSignalObservationReviewMatrixValidator()
          .validateReportText(report);

      expect(findings, isEmpty);
      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
    });

    test('reports contain no final labels or official metric names', () {
      final report = _review().renderMarkdownReport();

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

    test('reports contain no numeric move score or ranking output', () {
      final report = _review().renderMarkdownReport();

      expect(report, contains('numeric score values emitted: false'));
      expect(report, isNot(contains('numeric move score:')));
      expect(report, isNot(contains('scoreValue')));
      expect(report, isNot(contains('moveScore')));
      expect(report, isNot(contains('rankedMoves')));
      expect(report, isNot(contains('moveRanking')));
    });

    test('source imports stay pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/internal_signal_observation_review_matrix.dart',
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
    });
  });
}

InternalSignalObservationReviewMatrixResult _review({
  InternalSignalExperimentRunnerResult? runnerResult,
}) {
  return const InternalSignalObservationReviewMatrix().evaluate(
    InternalSignalObservationReviewMatrixRequest(runnerResult: runnerResult),
  );
}

InternalSignalExperimentRunnerResult _runner() {
  return const InternalSignalExperimentRunner().run(
    const InternalSignalExperimentRunnerRequest(),
  );
}

List<InternalSignalObservationReviewValidationFinding> _findingsWithObservation(
  InternalNonLabelSignalId id,
  InternalSignalExperimentObservation Function(
    InternalSignalExperimentObservation observation,
  )
  mutate,
) {
  final runner = _runner();
  final mutatedRunner = runner.copyWith(
    observations: runner.observations
        .map(
          (observation) =>
              observation.signalId == id ? mutate(observation) : observation,
        )
        .toList(growable: false),
  );
  final result = _review(runnerResult: mutatedRunner);
  return const InternalSignalObservationReviewMatrixValidator().validate(
    result,
    runnerResult: mutatedRunner,
  );
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
