@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_inspection_harness.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_prototype_inspection_harness_report.dart';

void main() {
  group(
    'debug_only_bridge_analyzer_adapter_prototype_inspection_harness_report',
    () {
      test('default markdown command succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitSuccess,
        );
        expect(
          result.format,
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportFormat
              .markdown,
        );
        expect(result.result, isNotNull);
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionStatus
              .prototypeInspectionReadyWithWarnings,
        );
        expect(result.result!.safeForPhase33X, isTrue);
        expect(result.stdoutText, contains('Inspection Snapshot Summary'));
        expect(result.stdoutText, contains('Packet Inspection Summary'));
        expect(result.stdoutText, contains('Policy Inspection Summary'));
        expect(result.stdoutText, contains('Record Role Inspection Summary'));
        expect(result.stdoutText, contains('Proof Boundary Inspection'));
        expect(result.stderrText, isEmpty);
      });

      test('JSON command succeeds and is parseable', () {
        final result = _run(args: const <String>['--format=json']);
        final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportVersion,
        );
        expect(
          decoded['inspectionStatus'],
          'prototypeInspectionReadyWithWarnings',
        );
        expect(decoded['safeForPhase33X'], isTrue);
        expect(
          decoded['phase33XRecommendation'],
          'validateDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarness',
        );
      });

      test('strict mode succeeds for safe demo inspection', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('invalid format fails with usage error', () {
        final result = _run(args: const <String>['--format=yaml']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessExitUsage,
        );
        expect(result.commandFailure, 'unknownFormat');
        expect(result.stderrText, contains('usage:'));
      });

      test('output contains no raw engine spam or active product data', () {
        final result = _run();

        _expectReportGuardrails(result.stdoutText);
      });

      test('source imports remain command-only and integration-free', () {
        final source = File(
          'tool/debug_only_bridge_analyzer_adapter_prototype_inspection_harness_report.dart',
        ).readAsStringSync();
        final imports = RegExp(
          r"import '([^']+)';",
        ).allMatches(source).map((match) => match.group(1)!).join('\n');

        for (final forbidden in const <String>[
          'package:flutter/',
          'widgets',
          'backend',
          'preflight',
          'server',
          'cache',
          'database',
          'ffi',
          'native',
          'stockfish',
          'local_eval_service',
          'scheduler',
        ]) {
          expect(imports.toLowerCase(), isNot(contains(forbidden)));
        }
      });
    },
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterPrototypeInspectionHarnessReportCommand(
    args: args,
  );
}

void _expectReportGuardrails(String report) {
  for (final token in const <String>[
    'uciok',
    'readyok',
    'info depth',
    'bestmove e2e4',
    'pv e2e4',
    'active fields: productLabel',
    'numeric move score:',
    'ACPL active',
    'official accuracy active',
    'cpLoss active',
    'winProbability active',
    'runtime implemented: true',
    'analyzer wired: true',
    'engine call active',
    'scheduler execution active',
    'http://',
    'https://',
    'apiKey',
    'secret=',
    'token=',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}
