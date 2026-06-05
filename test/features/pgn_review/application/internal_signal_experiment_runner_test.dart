@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_experiment_runner.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InternalSignalExperimentRunner safe demo', () {
    test('runs only when consistency gate is safe', () {
      final result = _run();

      expect(
        result.runnerStatus,
        InternalSignalExperimentRunnerStatus.completedWithWarnings,
      );
      expect(result.consistencyGatePassed, isTrue);
      expect(result.consistencyBlockerCount, 0);
      expect(result.consistencyCriticalCount, 0);
      expect(result.consistencySafeForExperiment, isTrue);
      expect(result.observationCount, greaterThan(0));
    });

    test('skips when blocker count is present', () {
      final result = _run(
        consistencyResult: _safeConsistency().copyWith(
          blockerCount: 1,
          safeForGuardedInternalExperiment: false,
        ),
      );

      expect(
        result.runnerStatus,
        InternalSignalExperimentRunnerStatus.skippedByConsistencyGate,
      );
      expect(result.consistencyGatePassed, isFalse);
      expect(result.observations, isEmpty);
      expect(
        result.failures,
        contains('consistency gate blocked internal signal experiment runner'),
      );
    });

    test('skips when critical count is present', () {
      final result = _run(
        consistencyResult: _safeConsistency().copyWith(
          criticalCount: 1,
          safeForGuardedInternalExperiment: false,
        ),
      );

      expect(
        result.runnerStatus,
        InternalSignalExperimentRunnerStatus.skippedByConsistencyGate,
      );
      expect(result.consistencyCriticalCount, 1);
      expect(result.observations, isEmpty);
    });
  });

  group('InternalSignalExperimentRunner observations', () {
    test('observes active tactical signal', () {
      final observation = _run().observation(
        InternalNonLabelSignalId.tacticalPressureSignal,
      );

      expect(observation.observed, isTrue);
      expect(observation.signalStatus, InternalNonLabelSignalStatus.active);
      expect(
        observation.supportCaseIds,
        contains('simple-tactical-capture-check'),
      );
      expect(observation.hasNumericScore, isFalse);
    });

    test('observes active material signal', () {
      final observation = _run().observation(
        InternalNonLabelSignalId.materialSwingSignal,
      );

      expect(observation.observed, isTrue);
      expect(observation.supportCaseIds, contains('queen-win-major-swing'));
    });

    test('observes active forcing signal', () {
      final observation = _run().observation(
        InternalNonLabelSignalId.forcingLineSignal,
      );

      expect(observation.observed, isTrue);
      expect(
        observation.supportCaseIds,
        contains('forcing-line-variation-hard-case'),
      );
    });

    test('observes candidate spread signal', () {
      final observation = _run().observation(
        InternalNonLabelSignalId.candidateSpreadSignal,
      );

      expect(observation.observed, isTrue);
      expect(observation.supportCaseIds, contains('mate-threat-fast-evidence'));
    });

    test('observes PV and MultiPV support signal', () {
      final observation = _run().observation(
        InternalNonLabelSignalId.pvMultiPvSupportSignal,
      );

      expect(observation.observed, isTrue);
      expect(observation.androidProofCaseIds, [
        'mate-threat-fast-evidence',
        'queen-win-major-swing',
        'simple-tactical-capture-check',
      ]);
    });

    test('includes only proven Android proof IDs', () {
      final result = _run();
      final observation = result.observation(
        InternalNonLabelSignalId.androidProofConfidenceSignal,
      );

      expect(result.provenAndroidCaseIds, [
        'mate-threat-fast-evidence',
        'queen-win-major-swing',
        'simple-tactical-capture-check',
      ]);
      expect(result.unprovenAndroidCaseIds, isEmpty);
      expect(observation.androidProofCaseIds, result.provenAndroidCaseIds);
    });

    test('rejects unproven Android proof IDs through the consistency gate', () {
      final result = _run(
        profileResult: _withSignal(
          InternalNonLabelSignalId.androidProofConfidenceSignal,
          (signal) => signal.copyWith(
            androidProofCaseIds: <String>[
              ...signal.androidProofCaseIds,
              'unproven-proof-case',
            ],
          ),
        ),
      );

      expect(
        result.runnerStatus,
        InternalSignalExperimentRunnerStatus.skippedByConsistencyGate,
      );
      expect(result.consistencyGatePassed, isFalse);
    });

    test('warning signals remain warnings', () {
      final result = _run();

      for (final id in const <InternalNonLabelSignalId>[
        InternalNonLabelSignalId.kingSafetySignal,
        InternalNonLabelSignalId.endgameSupportSignal,
        InternalNonLabelSignalId.suppressionSafetySignal,
      ]) {
        final observation = result.observation(id);
        expect(observation.observed, isTrue);
        expect(
          observation.signalStatus,
          InternalNonLabelSignalStatus.activeWithWarnings,
        );
        expect(observation.warningReason, isNotEmpty);
      }
    });

    test('budget risk remains warning or partial and not a score', () {
      final observation = _run().observation(
        InternalNonLabelSignalId.budgetRiskSignal,
      );

      expect(observation.signalStatus, InternalNonLabelSignalStatus.partial);
      expect(
        observation.qualitativeConfidence,
        InternalNonLabelSignalConfidence.warningOnly,
      );
      expect(observation.hasNumericScore, isFalse);
      expect(observation.ranksMoves, isFalse);
    });

    test('quiet, blocked, metric, and future paths stay inactive', () {
      final result = _run();

      expect(
        result
            .observation(
              InternalNonLabelSignalId.quietPreparatorySignalExcluded,
            )
            .observed,
        isFalse,
      );
      expect(
        result
            .observation(InternalNonLabelSignalId.productLabelSignalBlocked)
            .signalStatus,
        InternalNonLabelSignalStatus.blockedByPolicy,
      );
      expect(
        result
            .observation(InternalNonLabelSignalId.advancedLabelSignalBlocked)
            .observed,
        isFalse,
      );
      expect(
        result
            .observation(InternalNonLabelSignalId.officialMetricSignalBlocked)
            .observed,
        isFalse,
      );
      expect(
        result
            .observation(InternalNonLabelSignalId.cpLossSignalFutureOnly)
            .signalStatus,
        InternalNonLabelSignalStatus.futureOnly,
      );
      expect(
        result
            .observation(
              InternalNonLabelSignalId.winProbabilitySignalFutureOnly,
            )
            .signalStatus,
        InternalNonLabelSignalStatus.futureOnly,
      );
    });

    test('no observation emits labels, scores, rankings, or metrics', () {
      final result = _run();

      for (final observation in result.observations) {
        expect(observation.isProductOutput, isFalse);
        expect(observation.isClassifierLabel, isFalse);
        expect(observation.isOfficialMetric, isFalse);
        expect(observation.hasNumericScore, isFalse);
        expect(observation.ranksMoves, isFalse);
      }
      expect(result.productLabelsEmitted, isFalse);
      expect(result.classifierLabelsEmitted, isFalse);
      expect(result.finalMoveLabelsEmitted, isFalse);
      expect(result.officialMetricsAllowed, isFalse);
      expect(result.cpLossComputationImplemented, isFalse);
      expect(result.winProbabilityComputationImplemented, isFalse);
      expect(result.numericMoveScoresComputed, isFalse);
      expect(result.moveRankingComputed, isFalse);
    });
  });

  group('InternalSignalExperimentRunner validator seams', () {
    test('active observation must have support cases', () {
      final result = _run();
      final mutated = result.copyWith(
        observations: result.observations
            .map(
              (observation) =>
                  observation.signalId ==
                      InternalNonLabelSignalId.tacticalPressureSignal
                  ? observation.copyWith(supportCaseIds: <String>[])
                  : observation,
            )
            .toList(growable: false),
      );
      final findings = const InternalSignalExperimentRunnerValidator().validate(
        mutated,
        consistencyResult: _safeConsistency(),
      );

      expect(
        findings.map((finding) => finding.id),
        contains('activeObservationWithoutSupport'),
      );
    });

    test('validator rejects numeric score seam', () {
      final findings = _findingsWithObservation(
        InternalNonLabelSignalId.materialSwingSignal,
        (observation) => observation.copyWith(hasNumericScore: true),
      );

      expect(
        findings.map((finding) => finding.id),
        contains('observationEmitsNumericScore'),
      );
    });

    test('validator rejects product label seam', () {
      final findings = _findingsWithObservation(
        InternalNonLabelSignalId.tacticalPressureSignal,
        (observation) => observation.copyWith(isClassifierLabel: true),
      );

      expect(
        findings.map((finding) => finding.id),
        contains('observationEmitsForbiddenLabel'),
      );
    });

    test('validator rejects official metric seam', () {
      final findings = _findingsWithObservation(
        InternalNonLabelSignalId.officialMetricSignalBlocked,
        (observation) => observation.copyWith(isOfficialMetric: true),
      );

      expect(
        findings.map((finding) => finding.id),
        contains('observationEmitsOfficialMetric'),
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
        contains('quietPreparatoryObservationBecameActive'),
      );
    });

    test('validator rejects unproven Android proof seam', () {
      final findings = _findingsWithObservation(
        InternalNonLabelSignalId.androidProofConfidenceSignal,
        (observation) => observation.copyWith(
          androidProofCaseIds: <String>[
            ...observation.androidProofCaseIds,
            'unproven-proof-case',
          ],
        ),
      );

      expect(
        findings.map((finding) => finding.id),
        contains('unprovenAndroidProofCitation'),
      );
    });

    test('validator rejects move ranking seam', () {
      final findings = _findingsWithObservation(
        InternalNonLabelSignalId.forcingLineSignal,
        (observation) => observation.copyWith(ranksMoves: true),
      );

      expect(
        findings.map((finding) => finding.id),
        contains('observationRanksMoves'),
      );
    });
  });

  group('InternalSignalExperimentRunner reports and guardrails', () {
    test(
      'markdown report includes runner status and consistency gate status',
      () {
        final report = _run().renderMarkdownReport();

        expect(report, contains('# Internal Signal Experiment Runner'));
        expect(report, contains('runner status: completedWithWarnings'));
        expect(
          report,
          contains('consistency gate status: consistentWithWarnings'),
        );
        expect(report, contains('consistency gate passed: true'));
      },
    );

    test('markdown report includes observations and warning observations', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('Observation Table'));
      expect(report, contains('tacticalPressureSignal'));
      expect(report, contains('Warning Observations'));
      expect(report, contains('budgetRiskSignal'));
    });

    test('markdown report includes support case IDs', () {
      final report = _run().renderMarkdownReport();

      expect(report, contains('Support Cases'));
      expect(report, contains('simple-tactical-capture-check'));
      expect(report, contains('queen-win-major-swing'));
    });

    test('json report is deterministic and valid', () {
      final first = _run().renderJsonReport();
      final second = _run().renderJsonReport();
      final decoded = jsonDecode(first) as Map<String, Object?>;

      expect(first, second);
      expect(decoded['version'], internalSignalExperimentRunnerReportVersion);
      expect(decoded['runnerStatus'], 'completedWithWarnings');
      expect(decoded['observations'], isA<List<Object?>>());
    });

    test('reports contain no raw UCI spam or PV dumps', () {
      final report = _run().renderMarkdownReport();
      final findings = const InternalSignalExperimentRunnerValidator()
          .validateReportText(report);

      expect(findings, isEmpty);
      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('pvMoves')));
    });

    test('reports do not emit final labels or official metric names', () {
      final report = _run().renderMarkdownReport();

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
      final report = _run().renderMarkdownReport();

      expect(report, contains('numeric score values emitted: false'));
      expect(report, isNot(contains('numeric move score:')));
      expect(report, isNot(contains('scoreValue')));
      expect(report, isNot(contains('moveScore')));
      expect(report, isNot(contains('rankedMoves')));
      expect(report, isNot(contains('moveRanking')));
    });

    test('source imports stay pure and local-only', () {
      final source = File(
        'lib/features/pgn_review/application/internal_signal_experiment_runner.dart',
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

InternalSignalExperimentRunnerResult _run({
  InternalSignalProfileConsistencyMatrixResult? consistencyResult,
  InternalNonLabelSignalProfileResult? profileResult,
}) {
  return const InternalSignalExperimentRunner().run(
    InternalSignalExperimentRunnerRequest(
      consistencyResult: consistencyResult,
      profileResult: profileResult,
    ),
  );
}

InternalNonLabelSignalProfileResult _profile() {
  return const InternalNonLabelSignalProfilePrototype().evaluate(
    const InternalNonLabelSignalProfileRequest(),
  );
}

InternalSignalProfileConsistencyMatrixResult _safeConsistency() {
  return const InternalSignalProfileConsistencyMatrix().evaluate(
    InternalSignalProfileConsistencyMatrixRequest(profileResult: _profile()),
  );
}

InternalNonLabelSignalProfileResult _withSignal(
  InternalNonLabelSignalId id,
  InternalNonLabelSignalProfileEntry Function(
    InternalNonLabelSignalProfileEntry signal,
  )
  mutate,
) {
  final profile = _profile();
  final signals = profile.signals
      .map((signal) => signal.signalId == id ? mutate(signal) : signal)
      .toList(growable: false);
  return profile.copyWith(signals: signals);
}

List<InternalSignalExperimentRunnerValidationFinding> _findingsWithObservation(
  InternalNonLabelSignalId id,
  InternalSignalExperimentObservation Function(
    InternalSignalExperimentObservation observation,
  )
  mutate,
) {
  final result = _run();
  final mutated = result.copyWith(
    observations: result.observations
        .map(
          (observation) =>
              observation.signalId == id ? mutate(observation) : observation,
        )
        .toList(growable: false),
  );
  return const InternalSignalExperimentRunnerValidator().validate(
    mutated,
    consistencyResult: _safeConsistency(),
  );
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
