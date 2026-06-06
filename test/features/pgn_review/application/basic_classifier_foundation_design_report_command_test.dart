@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/basic_classifier_foundation_design.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/basic_classifier_foundation_design_report.dart';

void main() {
  group('Basic Classifier Foundation Design report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/basic_classifier_foundation_design_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('default output is markdown and succeeds', () {
      final result = _run();

      expect(result.exitCode, basicClassifierFoundationDesignReportExitSuccess);
      expect(
        result.format,
        BasicClassifierFoundationDesignReportFormat.markdown,
      );
      expect(result.strict, isFalse);
      expect(
        result.stdoutText,
        contains('# Basic Classifier Foundation Design'),
      );
      expect(result.result!.totalCaseCount, 20);
      expect(result.result!.negativeGuardCount, 1);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;
      final summary = decoded['summary'] as Map<String, Object?>;

      expect(first.exitCode, basicClassifierFoundationDesignReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(decoded['version'], basicClassifierFoundationDesignReportVersion);
      expect(summary['totalCases'], 20);
      expect(summary['protectedCount'], 19);
      expect(summary['negativeGuardCount'], 1);
      expect(summary['incompleteCount'], 0);
      expect(decoded['scopes'], isA<List<Object?>>());
      expect(decoded['evidenceContract'], isA<Map<String, Object?>>());
    });

    test('strict mode succeeds for the safe design-only default', () {
      final result = _run(args: const ['--strict']);

      expect(result.exitCode, basicClassifierFoundationDesignReportExitSuccess);
      expect(result.result!.productLabelsReady, isFalse);
      expect(result.result!.advancedLabelsReady, isFalse);
      expect(result.result!.quietPreparatoryScopeAllowed, isFalse);
    });

    test('strict mode fails if quiet scope is accidentally allowed', () {
      final unsafe = _baseResult().copyWith(
        quietPreparatoryScopeAllowed: true,
        scopes: [
          for (final scope in _baseResult().scopes)
            if (scope.scope ==
                BasicClassifierDesignScope
                    .quietPreparatoryEvidenceClassification)
              scope.copyWith(
                status: BasicClassifierDesignScopeStatus
                    .allowedForDeveloperPrototype,
              )
            else
              scope,
        ],
      );
      final result = _run(
        args: const ['--strict'],
        designer: _FakeDesigner(unsafe),
      );

      expect(
        result.exitCode,
        basicClassifierFoundationDesignReportExitUnsafePolicy,
      );
    });

    test('strict mode fails if product labels are accidentally allowed', () {
      final result = _run(
        args: const ['--strict'],
        designer: _FakeDesigner(
          _baseResult().copyWith(productLabelsReady: true),
        ),
      );

      expect(
        result.exitCode,
        basicClassifierFoundationDesignReportExitUnsafePolicy,
      );
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(result.exitCode, basicClassifierFoundationDesignReportExitUsage);
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(result.exitCode, basicClassifierFoundationDesignReportExitUsage);
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

BasicClassifierFoundationDesignReportCommandResult _run({
  List<String> args = const [],
  BasicClassifierFoundationDesigner designer =
      const BasicClassifierFoundationDesigner(),
}) {
  return runBasicClassifierFoundationDesignReportCommand(
    args: args,
    designer: designer,
  );
}

BasicClassifierFoundationDesignResult _baseResult() {
  return const BasicClassifierFoundationDesigner().evaluate(
    const BasicClassifierFoundationDesignRequest(),
  );
}

class _FakeDesigner implements BasicClassifierFoundationDesigner {
  const _FakeDesigner(this.result);

  final BasicClassifierFoundationDesignResult result;

  @override
  BasicClassifierFoundationDesignResult evaluate(
    BasicClassifierFoundationDesignRequest request,
  ) {
    return result;
  }
}

String _commandSource() {
  return File(
    'tool/basic_classifier_foundation_design_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
