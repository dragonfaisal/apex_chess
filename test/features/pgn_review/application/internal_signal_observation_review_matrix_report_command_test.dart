@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_experiment_runner.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_observation_review_matrix.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_signal_observation_review_matrix_report.dart';

void main() {
  group('Internal Signal Observation Review Matrix report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/internal_signal_observation_review_matrix_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('default output is safe-demo markdown and succeeds', () {
      final result = _run();

      expect(
        result.exitCode,
        internalSignalObservationReviewMatrixReportExitSuccess,
      );
      expect(
        result.format,
        InternalSignalObservationReviewReportFormat.markdown,
      );
      expect(result.strict, isFalse);
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(
        result.stdoutText,
        contains('# Internal Signal Observation Review Matrix'),
      );
      expect(result.stdoutText, contains('readyWithWarnings'));
      expect(result.result!.unsafeCount, 0);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;

      expect(
        first.exitCode,
        internalSignalObservationReviewMatrixReportExitSuccess,
      );
      expect(first.stdoutText, second.stdoutText);
      expect(
        decoded['version'],
        internalSignalObservationReviewMatrixReportVersion,
      );
      expect(decoded['matrixStatus'], 'readyWithWarnings');
      expect(decoded['rows'], isA<List<Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const ['--strict']);

      expect(
        result.exitCode,
        internalSignalObservationReviewMatrixReportExitSuccess,
      );
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.safeForLaterInternalPrototype, isTrue);
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(args: const ['--safe-demo', '--include-warnings']);

      expect(
        result.exitCode,
        internalSignalObservationReviewMatrixReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.warningRows, isNotEmpty);
    });

    test('strict mode fails on unsafe policy seam', () {
      final result = _run(
        args: const ['--strict'],
        request: _unsafeReviewRequest(),
      );

      expect(
        result.exitCode,
        internalSignalObservationReviewMatrixReportExitUnsafePolicy,
      );
      expect(result.result!.unsafeCount, greaterThan(0));
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(
        result.exitCode,
        internalSignalObservationReviewMatrixReportExitUsage,
      );
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(
        result.exitCode,
        internalSignalObservationReviewMatrixReportExitUsage,
      );
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

InternalSignalObservationReviewMatrixReportCommandResult _run({
  List<String> args = const [],
  InternalSignalObservationReviewMatrixRequest? request,
}) {
  return runInternalSignalObservationReviewMatrixReportCommand(
    args: args,
    request: request,
  );
}

InternalSignalObservationReviewMatrixRequest _unsafeReviewRequest() {
  final runner = const InternalSignalExperimentRunner().run(
    const InternalSignalExperimentRunnerRequest(),
  );
  final unsafeRunner = runner.copyWith(
    observations: runner.observations
        .map(
          (observation) =>
              observation.signalId ==
                  InternalNonLabelSignalId.tacticalPressureSignal
              ? observation.copyWith(hasNumericScore: true)
              : observation,
        )
        .toList(growable: false),
  );
  return InternalSignalObservationReviewMatrixRequest(
    runnerResult: unsafeRunner,
  );
}

String _commandSource() {
  return File(
    'tool/internal_signal_observation_review_matrix_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
