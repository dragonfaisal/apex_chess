@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_bucket_experiment_harness_report.dart';

void main() {
  group('Internal Bucket Experiment Harness report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/internal_bucket_experiment_harness_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('default output is safe-demo markdown and succeeds', () {
      final result = _run();

      expect(result.exitCode, internalBucketExperimentHarnessReportExitSuccess);
      expect(
        result.format,
        InternalBucketExperimentHarnessReportFormat.markdown,
      );
      expect(result.strict, isFalse);
      expect(result.safeDemo, isTrue);
      expect(result.includePartial, isFalse);
      expect(
        result.stdoutText,
        contains('# Internal Bucket Experiment Harness'),
      );
      expect(result.stdoutText, contains('completedInternalOnly'));
      expect(result.result!.guardAllowed, isTrue);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;

      expect(first.exitCode, internalBucketExperimentHarnessReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(decoded['version'], internalBucketExperimentHarnessReportVersion);
      expect(decoded['harnessStatus'], 'completedInternalOnly');
      expect(decoded['guardStatus'], 'allowedInternalOnly');
      expect(decoded['observations'], isA<List<Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const ['--strict']);

      expect(result.exitCode, internalBucketExperimentHarnessReportExitSuccess);
      expect(result.result!.guardAllowed, isTrue);
      expect(result.result!.hasUnsafeHarnessOutputPolicyViolation, isFalse);
    });

    test('safe-demo and include-partial flags are accepted', () {
      final result = _run(args: const ['--safe-demo', '--include-partial']);

      expect(result.exitCode, internalBucketExperimentHarnessReportExitSuccess);
      expect(result.safeDemo, isTrue);
      expect(result.includePartial, isTrue);
      expect(result.result!.experimentId, 'safe-demo-internal-buckets');
    });

    test('strict mode fails when harness is blocked without unsafe output', () {
      final result = _run(
        args: const ['--strict'],
        harness: const _FakeHarness(_blockedResult),
      );

      expect(
        result.exitCode,
        internalBucketExperimentHarnessReportExitBlockedStrict,
      );
    });

    test('strict mode fails on unsafe output-policy seam', () {
      final result = _run(
        args: const ['--strict'],
        harness: const _FakeHarness(_unsafeOutputResult),
      );

      expect(
        result.exitCode,
        internalBucketExperimentHarnessReportExitUnsafePolicy,
      );
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(result.exitCode, internalBucketExperimentHarnessReportExitUsage);
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(result.exitCode, internalBucketExperimentHarnessReportExitUsage);
      expect(result.commandFailure, 'unknownFormat');
    });

    test('command output keeps guardrails', () {
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
    });

    test(
      'command source does not execute proof commands or import engine UI',
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

InternalBucketExperimentHarnessReportCommandResult _run({
  List<String> args = const [],
  InternalBucketExperimentHarness harness =
      const InternalBucketExperimentHarness(),
}) {
  return runInternalBucketExperimentHarnessReportCommand(
    args: args,
    harness: harness,
  );
}

class _FakeHarness implements InternalBucketExperimentHarness {
  const _FakeHarness(this.result);

  final InternalBucketExperimentHarnessResult result;

  @override
  InternalBucketExperimentGuard get guard =>
      const InternalBucketExperimentGuard();

  @override
  InternalBucketExperimentHarnessResult run(
    InternalBucketExperimentHarnessRequest request,
  ) {
    return result;
  }
}

const _blockedResult = InternalBucketExperimentHarnessResult(
  experimentId: 'blocked-test',
  status: InternalBucketExperimentHarnessStatus.skippedByGuard,
  guardStatus: InternalBucketExperimentGuardStatus.blockedByUnsupportedBucket,
  guardAllowed: false,
  requestedBucketCount: 1,
  observations: <InternalBucketExperimentObservation>[],
  inactiveObservations: <InternalBucketExperimentObservation>[],
  guardPolicyViolations: <InternalBucketExperimentPolicyViolation>[],
  supportingCaseIds: <String>[],
  androidProofCaseIds: <String>[],
  unprovenAndroidCaseIds: <String>[],
  excludedScopeIds: <String>['quiet-preparatory-uncertain'],
  readyEvidenceAreas: <String>[],
  blockedEvidenceAreas: <String>['unsupportedBucket'],
  partialWarnings: <String>[],
  skippedBucketIds: <InternalEvidenceBucketId>[],
  blockedBucketIds: <InternalEvidenceBucketId>[
    InternalEvidenceBucketId.tacticalSupported,
  ],
  warnings: <String>[],
  failures: <String>['guard blocked request'],
  nextRecommendation:
      InternalBucketExperimentHarnessNextRecommendation.guardPolicyFixes,
);

const _unsafeOutputResult = InternalBucketExperimentHarnessResult(
  experimentId: 'unsafe-test',
  status: InternalBucketExperimentHarnessStatus.completedInternalOnly,
  guardStatus: InternalBucketExperimentGuardStatus.allowedInternalOnly,
  guardAllowed: true,
  requestedBucketCount: 1,
  observations: <InternalBucketExperimentObservation>[],
  inactiveObservations: <InternalBucketExperimentObservation>[],
  guardPolicyViolations: <InternalBucketExperimentPolicyViolation>[],
  supportingCaseIds: <String>[],
  androidProofCaseIds: <String>[],
  unprovenAndroidCaseIds: <String>[],
  excludedScopeIds: <String>[],
  readyEvidenceAreas: <String>[],
  blockedEvidenceAreas: <String>[],
  partialWarnings: <String>[],
  skippedBucketIds: <InternalEvidenceBucketId>[],
  blockedBucketIds: <InternalEvidenceBucketId>[],
  warnings: <String>[],
  failures: <String>[],
  nextRecommendation: InternalBucketExperimentHarnessNextRecommendation
      .futureInternalNonLabelAnalysis,
  productOutputEmitted: true,
);

String _commandSource() {
  return File(
    'tool/internal_bucket_experiment_harness_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
