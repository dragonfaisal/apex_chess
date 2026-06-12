@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_inspection_harness_validation_report.dart';

void main() {
  group('Debug-Only Bridge Developer Inspection Harness Validation command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_bridge_developer_inspection_harness_validation_report.dart',
        ).existsSync(),
        isTrue,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat
            .markdown,
      );
      expect(
        result.stdoutText,
        contains('# Debug-Only Bridge Developer Inspection Harness Validation'),
      );
      expect(result.stdoutText, contains('## Validation Check Table'));
      expect(result.stdoutText, contains('## Snapshot Validation'));
      expect(result.stdoutText, contains('## Input/Output Packet Validation'));
      expect(result.stdoutText, contains('## Policy Validation'));
      expect(result.stdoutText, contains('## Inspection Row Validation Table'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(
        result.stdoutText,
        contains('proceedToDebugOnlyBridgeDeveloperDiagnosticCommand'),
      );
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase33J, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgeDeveloperInspectionHarnessValidationReportFormat.json,
      );
      expect(
        decoded['version'],
        debugOnlyBridgeDeveloperInspectionHarnessValidationReportVersion,
      );
      expect(decoded['status'], 'inspectionHarnessValidatedWithWarnings');
      expect(decoded['totalChecks'], 20);
      expect(decoded['totalValidationRows'], 15);
      expect(decoded['unsafeCount'], 0);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase33J'], isTrue);
      expect(
        decoded['phase33JRecommendation'],
        'proceedToDebugOnlyBridgeDeveloperDiagnosticCommand',
      );
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitSuccess,
      );
      expect(result.result!.safeForPhase33J, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe harness seam', () {
      final unsafeHarness = const DebugOnlyBridgeDeveloperInspectionHarness()
          .inspectSafeDemo()
          .copyWith(
            status: DebugOnlyBridgeDeveloperInspectionHarnessStatus
                .blockedByPolicyBoundary,
            unsafeCount: 1,
            safeForPhase33I: false,
            productOutputActive: true,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest(
          inspectionHarnessResult: unsafeHarness,
        ),
      );

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitUnsafePolicy,
      );
      expect(
        result
            .result!
            .hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessValidationPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.totalChecks, 20);
      expect(result.result!.totalValidationRows, 15);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessValidationReportExitUsage,
      );
      expect(result.stderrText, contains('unknownFormat'));
      expect(result.commandFailure, 'unknownFormat');
    });

    test('command output keeps active-output guardrails', () {
      final report = _run().stdoutText;

      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        'pv e2e4',
        'pvMoves',
        'active fields: productLabel',
        'active fields: finalMoveLabel',
        'active fields: numericMoveScore',
        'allowed fields: productLabel',
        'allowed fields: schedulerExecution',
        'allowed fields: stockfishCommand',
        'numeric move score:',
        'scoreValue',
        'moveScore',
        'rankedMoves',
        'moveRanking active',
        'ACPL active',
        'official accuracy active',
        'runtime implemented: true',
        'executable bridge skeleton implemented: true',
        'executable debug bridge prototype implemented: true',
        'implementation wiring implemented: true',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('command source does not execute proof or boundary integrations', () {
      final source = File(
        'tool/debug_only_bridge_developer_inspection_harness_validation_report.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(source, isNot(contains('Process.run')));
      expect(source, isNot(contains('Process.start')));
      expect(imports, isNot(contains('dart:ffi')));
      expect(imports.toLowerCase(), isNot(contains('stockfish')));
      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('Widget')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('persistence')));
      expect(imports, isNot(contains('cache')));
      expect(imports, isNot(contains('database')));
      expect(imports, isNot(contains('scheduler')));
    });
  });
}

DebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommandResult _run({
  List<String> args = const <String>[],
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest? request,
}) {
  return runDebugOnlyBridgeDeveloperInspectionHarnessValidationReportCommand(
    args: args,
    request: request,
  );
}
