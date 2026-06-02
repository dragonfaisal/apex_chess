@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_bucket_experiment_guards_report.dart';

void main() {
  group('Internal Bucket Experiment Guards report command', () {
    test('command file exists', () {
      expect(
        File('tool/internal_bucket_experiment_guards_report.dart').existsSync(),
        true,
      );
    });

    test('default output is safe-demo markdown and succeeds', () {
      final result = _run();

      expect(result.exitCode, internalBucketExperimentGuardsReportExitSuccess);
      expect(
        result.format,
        InternalBucketExperimentGuardsReportFormat.markdown,
      );
      expect(result.strict, isFalse);
      expect(result.safeDemo, isTrue);
      expect(
        result.stdoutText,
        contains('# Internal Bucket Experiment Guards'),
      );
      expect(result.stdoutText, contains('allowedInternalOnly'));
      expect(result.result!.allowed, isTrue);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;

      expect(first.exitCode, internalBucketExperimentGuardsReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(decoded['version'], internalBucketExperimentGuardsReportVersion);
      expect(decoded['status'], 'allowedInternalOnly');
      expect(decoded['allowedBucketIds'], isA<List<Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const ['--strict']);

      expect(result.exitCode, internalBucketExperimentGuardsReportExitSuccess);
      expect(result.result!.allowed, isTrue);
      expect(result.result!.policyViolations, isEmpty);
    });

    test('safe-demo flag is accepted', () {
      final result = _run(args: const ['--safe-demo']);

      expect(result.exitCode, internalBucketExperimentGuardsReportExitSuccess);
      expect(result.safeDemo, isTrue);
      expect(result.result!.experimentId, 'safe-demo-internal-buckets');
    });

    test('strict mode fails on unsafe product output request', () {
      final result = _run(
        args: const ['--strict'],
        request: const InternalBucketExperimentRequest(
          allowProductLabels: true,
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.tacticalSupported,
          ],
          claimedAndroidProofCaseIds: <String>[],
        ),
      );

      expect(
        result.exitCode,
        internalBucketExperimentGuardsReportExitUnsafePolicy,
      );
      expect(
        result.result!.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByProductLabelPolicy,
      );
    });

    test('strict mode fails when quiet scope is requested', () {
      final result = _run(
        args: const ['--strict'],
        request: const InternalBucketExperimentRequest(
          allowQuietPreparatoryScope: true,
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.tacticalSupported,
          ],
          claimedAndroidProofCaseIds: <String>[],
        ),
      );

      expect(
        result.exitCode,
        internalBucketExperimentGuardsReportExitUnsafePolicy,
      );
      expect(
        result.result!.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByQuietScopeExclusion,
      );
    });

    test('strict mode fails on unproven Android proof claim', () {
      final result = _run(
        args: const ['--strict'],
        request: const InternalBucketExperimentRequest(
          requestedBuckets: <InternalEvidenceBucketId>[
            InternalEvidenceBucketId.androidProofBacked,
          ],
          claimedAndroidProofCaseIds: <String>['quiet-preparatory-hard-case'],
        ),
      );

      expect(
        result.exitCode,
        internalBucketExperimentGuardsReportExitUnsafePolicy,
      );
      expect(
        result.result!.overallStatus,
        InternalBucketExperimentGuardStatus.blockedByUnprovenAndroidProof,
      );
    });

    test('strict mode can report non-policy blocked result with exit 68', () {
      final base = const InternalBucketExperimentGuard().evaluate(
        const InternalBucketExperimentRequest.safeDemo(),
      );
      final blocked = _copyBlocked(base);
      final result = _run(args: const ['--strict'], guard: _FakeGuard(blocked));

      expect(
        result.exitCode,
        internalBucketExperimentGuardsReportExitBlockedStrict,
      );
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(result.exitCode, internalBucketExperimentGuardsReportExitUsage);
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(result.exitCode, internalBucketExperimentGuardsReportExitUsage);
      expect(result.commandFailure, 'unknownFormat');
    });

    test('command output keeps guardrails', () {
      final report = _run().stdoutText;

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
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

InternalBucketExperimentGuardsReportCommandResult _run({
  List<String> args = const [],
  InternalBucketExperimentGuard guard = const InternalBucketExperimentGuard(),
  InternalBucketExperimentRequest? request,
}) {
  return runInternalBucketExperimentGuardsReportCommand(
    args: args,
    guard: guard,
    request: request,
  );
}

InternalBucketExperimentGuardResult _copyBlocked(
  InternalBucketExperimentGuardResult base,
) {
  return InternalBucketExperimentGuardResult(
    experimentId: base.experimentId,
    overallStatus: InternalBucketExperimentGuardStatus.invalidRequest,
    allowed: false,
    requestedBucketCount: base.requestedBucketCount,
    allowedBucketIds: base.allowedBucketIds,
    warningBucketIds: base.warningBucketIds,
    blockedBucketIds: base.blockedBucketIds,
    policyViolations: const <InternalBucketExperimentPolicyViolation>[],
    supportingCaseIds: base.supportingCaseIds,
    excludedScopeIds: base.excludedScopeIds,
    provenAndroidCaseIds: base.provenAndroidCaseIds,
    unprovenAndroidCaseIds: base.unprovenAndroidCaseIds,
    warnings: base.warnings,
    failures: base.failures,
    bucketPrototypeStatus: base.bucketPrototypeStatus,
    contractStatus: base.contractStatus,
    foundationStatus: base.foundationStatus,
    readinessStatus: base.readinessStatus,
    nextRecommendation: InternalBucketExperimentNextPhase.guardPolicyFixes,
  );
}

class _FakeGuard implements InternalBucketExperimentGuard {
  const _FakeGuard(this.result);

  final InternalBucketExperimentGuardResult result;

  @override
  InternalBucketExperimentPolicy get policy =>
      const InternalBucketExperimentPolicy();

  @override
  InternalBucketExperimentGuardResult evaluate(
    InternalBucketExperimentRequest request,
  ) {
    return result;
  }
}

String _commandSource() {
  return File(
    'tool/internal_bucket_experiment_guards_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
