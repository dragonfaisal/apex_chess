@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_scoring_design.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_signal_profile.dart';
import 'package:apex_chess/features/pgn_review/application/internal_signal_profile_consistency_matrix.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_signal_profile_consistency_matrix_report.dart';

void main() {
  group('Internal Signal Profile Consistency Matrix report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/internal_signal_profile_consistency_matrix_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('default output is safe-demo markdown and succeeds', () {
      final result = _run();

      expect(
        result.exitCode,
        internalSignalProfileConsistencyMatrixReportExitSuccess,
      );
      expect(
        result.format,
        InternalSignalProfileConsistencyReportFormat.markdown,
      );
      expect(result.strict, isFalse);
      expect(result.safeDemo, isTrue);
      expect(result.includePartial, isFalse);
      expect(
        result.stdoutText,
        contains('# Internal Signal Profile Consistency Matrix'),
      );
      expect(result.stdoutText, contains('consistentWithWarnings'));
      expect(result.result!.safeForGuardedInternalExperiment, isTrue);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;

      expect(
        first.exitCode,
        internalSignalProfileConsistencyMatrixReportExitSuccess,
      );
      expect(first.stdoutText, second.stdoutText);
      expect(
        decoded['version'],
        internalSignalProfileConsistencyMatrixReportVersion,
      );
      expect(decoded['matrixStatus'], 'consistentWithWarnings');
      expect(decoded['rows'], isA<List<Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const ['--strict']);

      expect(
        result.exitCode,
        internalSignalProfileConsistencyMatrixReportExitSuccess,
      );
      expect(result.result!.blockerCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.safeForGuardedInternalExperiment, isTrue);
    });

    test('safe-demo and include-partial flags are accepted', () {
      final result = _run(args: const ['--safe-demo', '--include-partial']);

      expect(
        result.exitCode,
        internalSignalProfileConsistencyMatrixReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includePartial, isTrue);
      expect(
        result.result!.totalChecks,
        InternalSignalProfileConsistencyCheckId.values.length,
      );
    });

    test('strict mode fails when consistency has blocker only', () {
      final result = _run(
        args: const ['--strict'],
        consistencyMatrix: const _FakeConsistencyMatrix(_blockedResult),
      );

      expect(
        result.exitCode,
        internalSignalProfileConsistencyMatrixReportExitBlockedStrict,
      );
    });

    test('strict mode fails on unsafe output-policy seam', () {
      final result = _run(
        args: const ['--strict'],
        consistencyMatrix: const _FakeConsistencyMatrix(_unsafeOutputResult),
      );

      expect(
        result.exitCode,
        internalSignalProfileConsistencyMatrixReportExitUnsafePolicy,
      );
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(
        result.exitCode,
        internalSignalProfileConsistencyMatrixReportExitUsage,
      );
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(
        result.exitCode,
        internalSignalProfileConsistencyMatrixReportExitUsage,
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

InternalSignalProfileConsistencyMatrixReportCommandResult _run({
  List<String> args = const [],
  InternalSignalProfileConsistencyMatrix consistencyMatrix =
      const InternalSignalProfileConsistencyMatrix(),
}) {
  return runInternalSignalProfileConsistencyMatrixReportCommand(
    args: args,
    consistencyMatrix: consistencyMatrix,
  );
}

class _FakeConsistencyMatrix implements InternalSignalProfileConsistencyMatrix {
  const _FakeConsistencyMatrix(this.result);

  final InternalSignalProfileConsistencyMatrixResult result;

  @override
  InternalSignalProfileConsistencyMatrixValidator get validator =>
      const InternalSignalProfileConsistencyMatrixValidator();

  @override
  InternalSignalProfileConsistencyMatrixResult evaluate(
    InternalSignalProfileConsistencyMatrixRequest request,
  ) {
    return result;
  }
}

const _blockedResult = InternalSignalProfileConsistencyMatrixResult(
  matrixStatus:
      InternalSignalProfileConsistencyMatrixStatus.blockedByValidation,
  profileStatus: InternalNonLabelSignalProfileStatus.readyWithWarnings,
  scoringDesignStatus:
      InternalNonLabelScoringDesignStatus.designReadyWithWarnings,
  coverageMatrixStatus:
      InternalEvidenceAreaCoverageMatrixStatus.readyWithWarnings,
  harnessStatus: InternalBucketExperimentHarnessStatus.completedInternalOnly,
  guardStatus: InternalBucketExperimentGuardStatus.allowedInternalOnly,
  guardAllowed: true,
  rows: <InternalSignalProfileConsistencyRow>[],
  validationFindings: <InternalSignalProfileConsistencyValidationFinding>[],
  warnings: <String>[],
  failures: <String>[],
  totalChecks: 0,
  consistentCount: 0,
  warningCount: 0,
  blockerCount: 1,
  criticalCount: 0,
  activeSignalsChecked: 0,
  blockedSignalsChecked: 0,
  excludedSignalsChecked: 0,
  futureOnlySignalsChecked: 0,
  safeForGuardedInternalExperiment: false,
  nextRecommendation:
      InternalSignalProfileConsistencyNextPhase.consistencyEvidenceFixes,
  provenAndroidCaseIds: <String>[],
  unprovenAndroidCaseIds: <String>[],
  excludedScopeIds: <String>['quiet-preparatory-uncertain'],
);

const _unsafeOutputResult = InternalSignalProfileConsistencyMatrixResult(
  matrixStatus:
      InternalSignalProfileConsistencyMatrixStatus.blockedByValidation,
  profileStatus: InternalNonLabelSignalProfileStatus.readyWithWarnings,
  scoringDesignStatus:
      InternalNonLabelScoringDesignStatus.designReadyWithWarnings,
  coverageMatrixStatus:
      InternalEvidenceAreaCoverageMatrixStatus.readyWithWarnings,
  harnessStatus: InternalBucketExperimentHarnessStatus.completedInternalOnly,
  guardStatus: InternalBucketExperimentGuardStatus.allowedInternalOnly,
  guardAllowed: true,
  rows: <InternalSignalProfileConsistencyRow>[],
  validationFindings: <InternalSignalProfileConsistencyValidationFinding>[],
  warnings: <String>[],
  failures: <String>[],
  totalChecks: 0,
  consistentCount: 0,
  warningCount: 0,
  blockerCount: 0,
  criticalCount: 1,
  activeSignalsChecked: 0,
  blockedSignalsChecked: 0,
  excludedSignalsChecked: 0,
  futureOnlySignalsChecked: 0,
  safeForGuardedInternalExperiment: false,
  nextRecommendation:
      InternalSignalProfileConsistencyNextPhase.consistencyEvidenceFixes,
  provenAndroidCaseIds: <String>[],
  unprovenAndroidCaseIds: <String>[],
  excludedScopeIds: <String>['quiet-preparatory-uncertain'],
  numericMoveScoresComputed: true,
);

String _commandSource() {
  return File(
    'tool/internal_signal_profile_consistency_matrix_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
