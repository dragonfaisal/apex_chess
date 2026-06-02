@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_guards.dart';
import 'package:apex_chess/features/pgn_review/application/internal_bucket_experiment_harness.dart';
import 'package:apex_chess/features/pgn_review/application/internal_evidence_area_coverage_matrix.dart';
import 'package:apex_chess/features/pgn_review/application/internal_non_label_scoring_design.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_non_label_scoring_design_report.dart';

void main() {
  group('Internal Non-Label Scoring Design report command', () {
    test('command file exists', () {
      expect(
        File('tool/internal_non_label_scoring_design_report.dart').existsSync(),
        true,
      );
    });

    test('default output is safe-demo markdown and succeeds', () {
      final result = _run();

      expect(result.exitCode, internalNonLabelScoringDesignReportExitSuccess);
      expect(result.format, InternalNonLabelScoringDesignReportFormat.markdown);
      expect(result.strict, isFalse);
      expect(result.safeDemo, isTrue);
      expect(result.includePartial, isFalse);
      expect(
        result.stdoutText,
        contains('# Internal Non-Label Scoring Design'),
      );
      expect(result.stdoutText, contains('designReadyWithWarnings'));
      expect(result.result!.guardAllowed, isTrue);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;

      expect(first.exitCode, internalNonLabelScoringDesignReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(decoded['version'], internalNonLabelScoringDesignReportVersion);
      expect(decoded['scoringDesignStatus'], 'designReadyWithWarnings');
      expect(decoded['dimensions'], isA<List<Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const ['--strict']);

      expect(result.exitCode, internalNonLabelScoringDesignReportExitSuccess);
      expect(result.result!.guardAllowed, isTrue);
      expect(result.result!.hasUnsafeScoringDesignPolicyViolation, isFalse);
    });

    test('safe-demo and include-partial flags are accepted', () {
      final result = _run(args: const ['--safe-demo', '--include-partial']);

      expect(result.exitCode, internalNonLabelScoringDesignReportExitSuccess);
      expect(result.safeDemo, isTrue);
      expect(result.includePartial, isTrue);
      expect(
        result.result!.dimensionCount,
        InternalNonLabelScoringDimensionId.values.length,
      );
    });

    test('strict mode fails when design is blocked without unsafe output', () {
      final result = _run(
        args: const ['--strict'],
        design: const _FakeDesign(_blockedResult),
      );

      expect(
        result.exitCode,
        internalNonLabelScoringDesignReportExitBlockedStrict,
      );
    });

    test('strict mode fails on unsafe output-policy seam', () {
      final result = _run(
        args: const ['--strict'],
        design: const _FakeDesign(_unsafeOutputResult),
      );

      expect(
        result.exitCode,
        internalNonLabelScoringDesignReportExitUnsafePolicy,
      );
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(result.exitCode, internalNonLabelScoringDesignReportExitUsage);
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(result.exitCode, internalNonLabelScoringDesignReportExitUsage);
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

InternalNonLabelScoringDesignReportCommandResult _run({
  List<String> args = const [],
  InternalNonLabelScoringDesign design = const InternalNonLabelScoringDesign(),
}) {
  return runInternalNonLabelScoringDesignReportCommand(
    args: args,
    design: design,
  );
}

class _FakeDesign implements InternalNonLabelScoringDesign {
  const _FakeDesign(this.result);

  final InternalNonLabelScoringDesignResult result;

  @override
  InternalNonLabelScoringDesignValidator get validator =>
      const InternalNonLabelScoringDesignValidator();

  @override
  InternalNonLabelScoringDesignResult evaluate(
    InternalNonLabelScoringDesignRequest request,
  ) {
    return result;
  }
}

const _blockedResult = InternalNonLabelScoringDesignResult(
  status: InternalNonLabelScoringDesignStatus.blockedByMatrix,
  matrixStatus: InternalEvidenceAreaCoverageMatrixStatus.blockedByHarness,
  harnessStatus: InternalBucketExperimentHarnessStatus.skippedByGuard,
  guardStatus: InternalBucketExperimentGuardStatus.blockedByUnsupportedBucket,
  guardAllowed: false,
  dimensionCount: 0,
  dimensions: <InternalNonLabelScoringDimensionDesign>[],
  validationFindings: <InternalNonLabelScoringDesignValidationFinding>[],
  warnings: <String>[],
  failures: <String>['coverage matrix blocked request'],
  nextRecommendedPhase:
      InternalNonLabelScoringDesignNextPhase.designEvidenceFixes,
  provenAndroidCaseIds: <String>[],
  unprovenAndroidCaseIds: <String>[],
  excludedScopeIds: <String>['quiet-preparatory-uncertain'],
);

const _unsafeOutputResult = InternalNonLabelScoringDesignResult(
  status: InternalNonLabelScoringDesignStatus.designReadyInternalOnly,
  matrixStatus: InternalEvidenceAreaCoverageMatrixStatus.readyInternalOnly,
  harnessStatus: InternalBucketExperimentHarnessStatus.completedInternalOnly,
  guardStatus: InternalBucketExperimentGuardStatus.allowedInternalOnly,
  guardAllowed: true,
  dimensionCount: 0,
  dimensions: <InternalNonLabelScoringDimensionDesign>[],
  validationFindings: <InternalNonLabelScoringDesignValidationFinding>[],
  warnings: <String>[],
  failures: <String>[],
  nextRecommendedPhase:
      InternalNonLabelScoringDesignNextPhase.guardedNonLabelPrototype,
  provenAndroidCaseIds: <String>[],
  unprovenAndroidCaseIds: <String>[],
  excludedScopeIds: <String>[],
  numericMoveScoresComputed: true,
);

String _commandSource() {
  return File(
    'tool/internal_non_label_scoring_design_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
