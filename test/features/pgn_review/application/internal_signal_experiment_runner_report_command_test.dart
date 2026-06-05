@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_experiment_runner.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_signal_experiment_runner_report.dart';

void main() {
  group('Internal Signal Experiment Runner report command', () {
    test('command file exists', () {
      expect(
        File('tool/internal_signal_experiment_runner_report.dart').existsSync(),
        true,
      );
    });

    test('default output is safe-demo markdown and succeeds', () {
      final result = _run();

      expect(result.exitCode, internalSignalExperimentRunnerReportExitSuccess);
      expect(
        result.format,
        InternalSignalExperimentRunnerReportFormat.markdown,
      );
      expect(result.strict, isFalse);
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(
        result.stdoutText,
        contains('# Internal Signal Experiment Runner'),
      );
      expect(result.stdoutText, contains('completedWithWarnings'));
      expect(result.result!.consistencyGatePassed, isTrue);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;

      expect(first.exitCode, internalSignalExperimentRunnerReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(decoded['version'], internalSignalExperimentRunnerReportVersion);
      expect(decoded['runnerStatus'], 'completedWithWarnings');
      expect(decoded['observations'], isA<List<Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const ['--strict']);

      expect(result.exitCode, internalSignalExperimentRunnerReportExitSuccess);
      expect(result.result!.consistencyGatePassed, isTrue);
      expect(result.result!.consistencyBlockerCount, 0);
      expect(result.result!.consistencyCriticalCount, 0);
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(args: const ['--safe-demo', '--include-warnings']);

      expect(result.exitCode, internalSignalExperimentRunnerReportExitSuccess);
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.warningObservations, isNotEmpty);
    });

    test('strict mode fails when runner is consistency-blocked', () {
      final result = _run(
        args: const ['--strict'],
        runner: const _FakeRunner(_blockedResult),
      );

      expect(
        result.exitCode,
        internalSignalExperimentRunnerReportExitBlockedStrict,
      );
    });

    test('strict mode fails on unsafe output-policy seam', () {
      final result = _run(
        args: const ['--strict'],
        runner: const _FakeRunner(_unsafeOutputResult),
      );

      expect(
        result.exitCode,
        internalSignalExperimentRunnerReportExitUnsafePolicy,
      );
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(result.exitCode, internalSignalExperimentRunnerReportExitUsage);
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(result.exitCode, internalSignalExperimentRunnerReportExitUsage);
      expect(result.commandFailure, 'unknownFormat');
    });

    test('command output keeps report guardrails', () {
      final report = _run().stdoutText;

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
    });

    test(
      'command source does not execute proof commands or import boundaries',
      () {
        final source = _commandSource();
        final imports = _imports(source);

        expect(source, isNot(contains('Process.run')));
        expect(source, isNot(contains('Process.start')));
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

InternalSignalExperimentRunnerReportCommandResult _run({
  List<String> args = const [],
  InternalSignalExperimentRunner runner =
      const InternalSignalExperimentRunner(),
}) {
  return runInternalSignalExperimentRunnerReportCommand(
    args: args,
    runner: runner,
  );
}

class _FakeRunner implements InternalSignalExperimentRunner {
  const _FakeRunner(this.result);

  final InternalSignalExperimentRunnerResult result;

  @override
  InternalSignalExperimentRunnerValidator get validator =>
      const InternalSignalExperimentRunnerValidator();

  @override
  InternalSignalExperimentRunnerResult run(
    InternalSignalExperimentRunnerRequest request,
  ) {
    return result;
  }
}

const _blockedResult = InternalSignalExperimentRunnerResult(
  runnerStatus: InternalSignalExperimentRunnerStatus.skippedByConsistencyGate,
  experimentId: 'blocked-test',
  consistencyMatrixStatus:
      InternalSignalProfileConsistencyMatrixStatus.blockedByValidation,
  profileStatus: InternalNonLabelSignalProfileStatus.readyWithWarnings,
  consistencyGatePassed: false,
  consistencyBlockerCount: 1,
  consistencyCriticalCount: 0,
  consistencySafeForExperiment: false,
  observations: <InternalSignalExperimentObservation>[],
  validationFindings: <InternalSignalExperimentRunnerValidationFinding>[],
  warnings: <String>[],
  failures: <String>['consistency gate blocked'],
  nextRecommendation:
      InternalSignalExperimentRunnerNextRecommendation.consistencyEvidenceFixes,
  provenAndroidCaseIds: <String>[],
  unprovenAndroidCaseIds: <String>[],
  excludedScopeIds: <String>['quiet-preparatory-uncertain'],
);

const _unsafeOutputResult = InternalSignalExperimentRunnerResult(
  runnerStatus: InternalSignalExperimentRunnerStatus.blocked,
  experimentId: 'unsafe-test',
  consistencyMatrixStatus:
      InternalSignalProfileConsistencyMatrixStatus.consistentWithWarnings,
  profileStatus: InternalNonLabelSignalProfileStatus.readyWithWarnings,
  consistencyGatePassed: true,
  consistencyBlockerCount: 0,
  consistencyCriticalCount: 0,
  consistencySafeForExperiment: true,
  observations: <InternalSignalExperimentObservation>[],
  validationFindings: <InternalSignalExperimentRunnerValidationFinding>[],
  warnings: <String>[],
  failures: <String>[],
  nextRecommendation:
      InternalSignalExperimentRunnerNextRecommendation.consistencyEvidenceFixes,
  provenAndroidCaseIds: <String>[],
  unprovenAndroidCaseIds: <String>[],
  excludedScopeIds: <String>['quiet-preparatory-uncertain'],
  numericMoveScoresComputed: true,
);

String _commandSource() {
  return File(
    'tool/internal_signal_experiment_runner_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
