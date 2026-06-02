@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_evidence_area_coverage_matrix_report.dart';

void main() {
  group('Internal Evidence Area Coverage Matrix report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/internal_evidence_area_coverage_matrix_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('default output is safe-demo markdown and succeeds', () {
      final result = _run();

      expect(
        result.exitCode,
        internalEvidenceAreaCoverageMatrixReportExitSuccess,
      );
      expect(
        result.format,
        InternalEvidenceAreaCoverageMatrixReportFormat.markdown,
      );
      expect(result.strict, isFalse);
      expect(result.safeDemo, isTrue);
      expect(result.includePartial, isFalse);
      expect(
        result.stdoutText,
        contains('# Internal Evidence Area Coverage Matrix'),
      );
      expect(result.stdoutText, contains('readyWithWarnings'));
      expect(result.result!.guardAllowed, isTrue);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;

      expect(
        first.exitCode,
        internalEvidenceAreaCoverageMatrixReportExitSuccess,
      );
      expect(first.stdoutText, second.stdoutText);
      expect(
        decoded['version'],
        internalEvidenceAreaCoverageMatrixReportVersion,
      );
      expect(decoded['matrixStatus'], 'readyWithWarnings');
      expect(decoded['areas'], isA<List<Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const ['--strict']);

      expect(
        result.exitCode,
        internalEvidenceAreaCoverageMatrixReportExitSuccess,
      );
      expect(result.result!.guardAllowed, isTrue);
      expect(result.result!.hasUnsafeMatrixPolicyViolation, isFalse);
    });

    test('safe-demo and include-partial flags are accepted', () {
      final result = _run(args: const ['--safe-demo', '--include-partial']);

      expect(
        result.exitCode,
        internalEvidenceAreaCoverageMatrixReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includePartial, isTrue);
      expect(result.result!.harnessStatus, isNotNull);
    });

    test('strict mode fails when matrix is blocked without unsafe output', () {
      final result = _run(
        args: const ['--strict'],
        matrix: const _FakeMatrix(_blockedResult),
      );

      expect(
        result.exitCode,
        internalEvidenceAreaCoverageMatrixReportExitBlockedStrict,
      );
    });

    test('strict mode fails on unsafe output-policy seam', () {
      final result = _run(
        args: const ['--strict'],
        matrix: const _FakeMatrix(_unsafeOutputResult),
      );

      expect(
        result.exitCode,
        internalEvidenceAreaCoverageMatrixReportExitUnsafePolicy,
      );
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(
        result.exitCode,
        internalEvidenceAreaCoverageMatrixReportExitUsage,
      );
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(
        result.exitCode,
        internalEvidenceAreaCoverageMatrixReportExitUsage,
      );
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

InternalEvidenceAreaCoverageMatrixReportCommandResult _run({
  List<String> args = const [],
  InternalEvidenceAreaCoverageMatrix matrix =
      const InternalEvidenceAreaCoverageMatrix(),
}) {
  return runInternalEvidenceAreaCoverageMatrixReportCommand(
    args: args,
    matrix: matrix,
  );
}

class _FakeMatrix implements InternalEvidenceAreaCoverageMatrix {
  const _FakeMatrix(this.result);

  final InternalEvidenceAreaCoverageMatrixResult result;

  @override
  InternalEvidenceAreaCoverageMatrixValidator get validator =>
      const InternalEvidenceAreaCoverageMatrixValidator();

  @override
  InternalEvidenceAreaCoverageMatrixResult evaluate(
    InternalEvidenceAreaCoverageMatrixRequest request,
  ) {
    return result;
  }
}

const _blockedResult = InternalEvidenceAreaCoverageMatrixResult(
  status: InternalEvidenceAreaCoverageMatrixStatus.blockedByHarness,
  harnessStatus: InternalBucketExperimentHarnessStatus.skippedByGuard,
  guardStatus: InternalBucketExperimentGuardStatus.blockedByUnsupportedBucket,
  guardAllowed: false,
  areaCount: 0,
  entries: <InternalEvidenceAreaCoverageEntry>[],
  validationFindings: <InternalEvidenceAreaCoverageValidationFinding>[],
  warnings: <String>[],
  failures: <String>['harness blocked request'],
  nextRecommendedPhase:
      InternalEvidenceAreaCoverageNextPhase.coverageEvidenceFixes,
  provenAndroidCaseIds: <String>[],
  unprovenAndroidCaseIds: <String>[],
  excludedScopeIds: <String>['quiet-preparatory-uncertain'],
);

const _unsafeOutputResult = InternalEvidenceAreaCoverageMatrixResult(
  status: InternalEvidenceAreaCoverageMatrixStatus.readyInternalOnly,
  harnessStatus: InternalBucketExperimentHarnessStatus.completedInternalOnly,
  guardStatus: InternalBucketExperimentGuardStatus.allowedInternalOnly,
  guardAllowed: true,
  areaCount: 0,
  entries: <InternalEvidenceAreaCoverageEntry>[],
  validationFindings: <InternalEvidenceAreaCoverageValidationFinding>[],
  warnings: <String>[],
  failures: <String>[],
  nextRecommendedPhase:
      InternalEvidenceAreaCoverageNextPhase.internalNonLabelScoringDesign,
  provenAndroidCaseIds: <String>[],
  unprovenAndroidCaseIds: <String>[],
  excludedScopeIds: <String>[],
  productOutputEmitted: true,
);

String _commandSource() {
  return File(
    'tool/internal_evidence_area_coverage_matrix_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
