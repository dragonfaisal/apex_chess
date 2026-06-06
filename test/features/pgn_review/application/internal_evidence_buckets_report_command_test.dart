@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_evidence_buckets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_evidence_buckets_report.dart';

void main() {
  group('Internal Evidence Buckets report command', () {
    test('command file exists', () {
      expect(
        File('tool/internal_evidence_buckets_report.dart').existsSync(),
        true,
      );
    });

    test('default output is markdown and succeeds', () {
      final result = _run();

      expect(result.exitCode, internalEvidenceBucketsReportExitSuccess);
      expect(result.format, InternalEvidenceBucketsReportFormat.markdown);
      expect(result.strict, isFalse);
      expect(
        result.stdoutText,
        contains('# Internal Evidence Buckets Prototype'),
      );
      expect(result.result!.totalCaseCount, 20);
      expect(result.result!.negativeGuardCount, 1);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;
      final summary = decoded['summary'] as Map<String, Object?>;

      expect(first.exitCode, internalEvidenceBucketsReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(decoded['version'], internalEvidenceBucketsReportVersion);
      expect(summary['totalCases'], 20);
      expect(summary['protectedCount'], 19);
      expect(summary['negativeGuardCount'], 1);
      expect(decoded['buckets'], isA<List<Object?>>());
    });

    test('strict mode succeeds for the safe default buckets', () {
      final result = _run(args: const ['--strict']);

      expect(result.exitCode, internalEvidenceBucketsReportExitSuccess);
      expect(result.result!.readyForPhase31D, isTrue);
      expect(result.result!.validationFindings, isEmpty);
      expect(result.result!.hasUnsafeBucketPolicyViolation, isFalse);
    });

    test('strict mode fails if a blocked bucket is supported', () {
      final base = _baseResult();
      final unsafe = base.copyWith(
        buckets: [
          for (final bucket in base.buckets)
            if (bucket.id == InternalEvidenceBucketId.productLabelOutputBlocked)
              bucket.copyWith(
                status: InternalEvidenceBucketStatus.supported,
                supportingCaseIds: ['simple-tactical-capture-check'],
              )
            else
              bucket,
        ],
      );
      final result = _run(
        args: const ['--strict'],
        builder: _FakeBuilder(unsafe),
      );

      expect(result.exitCode, internalEvidenceBucketsReportExitUnsafePolicy);
    });

    test('strict mode fails if quiet bucket is not excluded', () {
      final base = _baseResult();
      final unsafe = base.copyWith(
        buckets: [
          for (final bucket in base.buckets)
            if (bucket.id == InternalEvidenceBucketId.quietPreparatoryExcluded)
              bucket.copyWith(status: InternalEvidenceBucketStatus.supported)
            else
              bucket,
        ],
      );
      final result = _run(
        args: const ['--strict'],
        builder: _FakeBuilder(unsafe),
      );

      expect(result.exitCode, internalEvidenceBucketsReportExitUnsafePolicy);
    });

    test('strict mode fails if a readiness validation error exists', () {
      final blocked = _baseResult().copyWith(
        status: InternalEvidenceBucketPrototypeStatus.blockedByValidation,
        validationFindings: const <InternalEvidenceBucketValidationFinding>[
          InternalEvidenceBucketValidationFinding(
            id: 'supportedBucketWithoutCases',
            severity: InternalEvidenceBucketValidationSeverity.error,
            message: 'bucket cannot be supported without cases',
            bucketId: InternalEvidenceBucketId.tacticalSupported,
          ),
        ],
      );
      final result = _run(
        args: const ['--strict'],
        builder: _FakeBuilder(blocked),
      );

      expect(result.exitCode, internalEvidenceBucketsReportExitBlockedStrict);
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(result.exitCode, internalEvidenceBucketsReportExitUsage);
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(result.exitCode, internalEvidenceBucketsReportExitUsage);
      expect(result.commandFailure, 'unknownFormat');
    });

    test('report command output keeps guardrails', () {
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

InternalEvidenceBucketsReportCommandResult _run({
  List<String> args = const [],
  InternalEvidenceBucketBuilder builder = const InternalEvidenceBucketBuilder(),
}) {
  return runInternalEvidenceBucketsReportCommand(args: args, builder: builder);
}

InternalEvidenceBucketPrototype _baseResult() {
  return const InternalEvidenceBucketBuilder().evaluate(
    const InternalEvidenceBucketRequest(),
  );
}

class _FakeBuilder implements InternalEvidenceBucketBuilder {
  const _FakeBuilder(this.result);

  final InternalEvidenceBucketPrototype result;

  @override
  InternalEvidenceBucketValidator get validator =>
      const InternalEvidenceBucketValidator();

  @override
  InternalEvidenceBucketPrototype evaluate(
    InternalEvidenceBucketRequest request,
  ) {
    return result;
  }
}

String _commandSource() {
  return File('tool/internal_evidence_buckets_report.dart').readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
