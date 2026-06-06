@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/golden_classifier_readiness_gate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/golden_classifier_readiness_report.dart';

void main() {
  group('Golden Classifier Readiness report command', () {
    test('command file exists', () {
      expect(
        File('tool/golden_classifier_readiness_report.dart').existsSync(),
        true,
      );
    });

    test('default output is markdown and succeeds', () {
      final result = _run();

      expect(result.exitCode, goldenClassifierReadinessReportExitSuccess);
      expect(result.format, GoldenClassifierReadinessReportFormat.markdown);
      expect(result.strict, isFalse);
      expect(result.stdoutText, contains('# Golden Classifier Readiness Gate'));
      expect(result.result!.totalCaseCount, 20);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;
      final summary = decoded['summary'] as Map<String, Object?>;

      expect(first.exitCode, goldenClassifierReadinessReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(decoded['version'], goldenClassifierReadinessReportVersion);
      expect(summary['totalCases'], 20);
      expect(summary['protectedCount'], 19);
      expect(summary['negativeGuardCount'], 1);
      expect(summary['incompleteCount'], 0);
      expect(decoded['scopes'], isA<List<Object?>>());
      expect(decoded['quietPreparatoryEvidence'], isA<List<Object?>>());
    });

    test('strict mode fails because current readiness is blocked', () {
      final result = _run(args: const ['--strict']);

      expect(result.exitCode, goldenClassifierReadinessReportExitBlockedStrict);
      expect(result.result!.negativeGuardCount, 1);
      expect(result.result!.incompleteCount, 0);
      expect(
        result.result!.nextRecommendedPhase,
        GoldenClassifierNextPhase.basicClassifierFoundationDesignOnly,
      );
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(result.exitCode, goldenClassifierReadinessReportExitUsage);
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(result.exitCode, goldenClassifierReadinessReportExitUsage);
      expect(result.commandFailure, 'unknownFormat');
    });

    test('report command output keeps guardrails', () {
      final report = _run().stdoutText;

      expect(report, isNot(contains('uciok')));
      expect(report, isNot(contains('readyok')));
      expect(report, isNot(contains('info depth')));
      expect(report, isNot(contains('bestmove e2e4')));
      expect(report, isNot(contains(' pv ')));
      expect(report, isNot(contains('Brilliant')));
      expect(report, isNot(contains('Great')));
      expect(report, isNot(contains('Miss')));
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

GoldenClassifierReadinessReportCommandResult _run({
  List<String> args = const [],
}) {
  return runGoldenClassifierReadinessReportCommand(args: args);
}

String _commandSource() {
  return File(
    'tool/golden_classifier_readiness_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
