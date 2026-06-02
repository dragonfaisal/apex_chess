@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/basic_classifier_evidence_contract.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/basic_classifier_evidence_contract_report.dart';

void main() {
  group('Basic Classifier Evidence Contract report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/basic_classifier_evidence_contract_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('default output is markdown and succeeds', () {
      final result = _run();

      expect(result.exitCode, basicClassifierEvidenceContractReportExitSuccess);
      expect(
        result.format,
        BasicClassifierEvidenceContractReportFormat.markdown,
      );
      expect(result.strict, isFalse);
      expect(
        result.stdoutText,
        contains('# Basic Classifier Evidence Contract Prototype'),
      );
      expect(result.result!.totalCaseCount, 15);
      expect(result.result!.negativeGuardCount, 1);
    });

    test('json output is valid and deterministic', () {
      final first = _run(args: const ['--format=json']);
      final second = _run(args: const ['--format=json']);
      final decoded = jsonDecode(first.stdoutText) as Map<String, Object?>;
      final summary = decoded['summary'] as Map<String, Object?>;

      expect(first.exitCode, basicClassifierEvidenceContractReportExitSuccess);
      expect(first.stdoutText, second.stdoutText);
      expect(decoded['version'], basicClassifierEvidenceContractReportVersion);
      expect(summary['totalCases'], 15);
      expect(summary['protectedCount'], 14);
      expect(summary['negativeGuardCount'], 1);
      expect(summary['incompleteCount'], 0);
      expect(decoded['fields'], isA<List<Object?>>());
      expect(decoded['groups'], isA<List<Object?>>());
    });

    test('strict mode succeeds for the safe evidence contract default', () {
      final result = _run(args: const ['--strict']);

      expect(result.exitCode, basicClassifierEvidenceContractReportExitSuccess);
      expect(result.result!.readyForPhase31C, isTrue);
      expect(result.result!.validationFindings, isEmpty);
      expect(result.result!.hasUnsafeOutputPolicyViolation, isFalse);
    });

    test('strict mode fails if quiet scope is accidentally allowed', () {
      final base = _baseResult();
      final unsafe = base.copyWith(
        groups: [
          for (final group in base.groups)
            if (group.group ==
                BasicClassifierEvidenceGroup.quietPreparatoryEvidence)
              group.copyWith(
                readiness: BasicClassifierEvidenceGroupReadiness
                    .readyForDeveloperEvidence,
                supportingCaseIds: ['quiet-preparatory-hard-case'],
              )
            else
              group,
        ],
      );
      final result = _run(
        args: const ['--strict'],
        builder: _FakeBuilder(unsafe),
      );

      expect(
        result.exitCode,
        basicClassifierEvidenceContractReportExitUnsafePolicy,
      );
    });

    test('strict mode fails if product output is accidentally allowed', () {
      final base = _baseResult();
      final unsafe = base.copyWith(
        fields: [
          for (final field in base.fields)
            if (field.field ==
                BasicClassifierContractField.productLabelOutputAvailable)
              field.copyWith(status: BasicClassifierEvidenceFieldStatus.present)
            else
              field,
        ],
      );
      final result = _run(
        args: const ['--strict'],
        builder: _FakeBuilder(unsafe),
      );

      expect(
        result.exitCode,
        basicClassifierEvidenceContractReportExitUnsafePolicy,
      );
    });

    test('strict mode fails if validation blocks the contract', () {
      final blocked = _baseResult().copyWith(
        status: BasicClassifierEvidenceContractStatus.blockedByValidation,
        validationFindings: const <BasicClassifierEvidenceValidationFinding>[
          BasicClassifierEvidenceValidationFinding(
            id: 'readyGroupWithoutSupport',
            severity: BasicClassifierEvidenceValidationSeverity.error,
            message: 'group cannot be ready without support',
            group: BasicClassifierEvidenceGroup.tacticalEvidence,
          ),
        ],
      );
      final result = _run(
        args: const ['--strict'],
        builder: _FakeBuilder(blocked),
      );

      expect(
        result.exitCode,
        basicClassifierEvidenceContractReportExitBlockedStrict,
      );
    });

    test('unknown flag exits usage error', () {
      final result = _run(args: const ['--unknown']);

      expect(result.exitCode, basicClassifierEvidenceContractReportExitUsage);
      expect(result.commandFailure, 'unknownFlag');
      expect(result.stderrText, contains('Usage:'));
    });

    test('unknown format exits usage error', () {
      final result = _run(args: const ['--format=xml']);

      expect(result.exitCode, basicClassifierEvidenceContractReportExitUsage);
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

BasicClassifierEvidenceContractReportCommandResult _run({
  List<String> args = const [],
  BasicClassifierEvidenceContractBuilder builder =
      const BasicClassifierEvidenceContractBuilder(),
}) {
  return runBasicClassifierEvidenceContractReportCommand(
    args: args,
    builder: builder,
  );
}

BasicClassifierEvidenceContractPrototype _baseResult() {
  return const BasicClassifierEvidenceContractBuilder().evaluate(
    const BasicClassifierEvidenceContractRequest(),
  );
}

class _FakeBuilder implements BasicClassifierEvidenceContractBuilder {
  const _FakeBuilder(this.result);

  final BasicClassifierEvidenceContractPrototype result;

  @override
  BasicClassifierEvidenceContractValidator get validator =>
      const BasicClassifierEvidenceContractValidator();

  @override
  BasicClassifierEvidenceContractPrototype evaluate(
    BasicClassifierEvidenceContractRequest request,
  ) {
    return result;
  }
}

String _commandSource() {
  return File(
    'tool/basic_classifier_evidence_contract_report.dart',
  ).readAsStringSync();
}

String _imports(String source) {
  return source
      .split('\n')
      .where((line) => line.trimLeft().startsWith('import '))
      .join('\n');
}
