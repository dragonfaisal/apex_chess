@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter runtime execution preflight diagnostic report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticReportExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticStatus
              .controlledAnalyzerAdapterRuntimeExecutionPreflightDiagnosticReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34M, isTrue);
        expect(
          result.result!.nextRecommendation,
          'implementDisabledAnalyzerAdapterRuntimeExecutionSeamProbePatch',
        );
        expect(
          result.stdoutText,
          contains(
            '# Controlled Analyzer Adapter Runtime Execution Preflight Diagnostic',
          ),
        );
        expect(result.stdoutText, contains('## Diagnostic Mode Summary'));
        expect(
          result.stdoutText,
          contains('## Runtime Execution Preflight Diagnostic Rows'),
        );
        expect(result.stdoutText, contains('## Safety Summary'));
        expect(result.stdoutText, contains('## Recommendation'));
      });

      test('JSON report succeeds and is parseable', () {
        final result = _run(args: const <String>['--format=json']);
        final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
        final counts = decoded['counts'] as Map<String, Object?>;

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticReportExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticVersion,
        );
        expect(
          decoded['status'],
          'controlledAnalyzerAdapterRuntimeExecutionPreflightDiagnosticReadyWithWarnings',
        );
        expect(decoded['safeForPhase34M'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'implementDisabledAnalyzerAdapterRuntimeExecutionSeamProbePatch',
        );
        expect(counts['runtimeExecutionCount'], 0);
        expect(counts['runtimeExecutionApprovedCount'], 0);
        expect(counts['executableRuntimeCount'], 0);
        expect(counts['analyzerWiringCount'], 0);
        expect(counts['engineCallCount'], 0);
        expect(counts['schedulerExecutionCount'], 0);
        expect(counts['persistenceWriteCount'], 0);
        expect(counts['productOutputCount'], 0);
        expect(counts['productAdapterCount'], 0);
        expect(counts['savedAnalysisIntegrationCount'], 0);
        expect(counts['activeDeniedFieldCount'], 0);
        expect(decoded['rows'], isA<List<Object?>>());
      });

      test('strict report succeeds for safe demo', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticReportExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('diagnostic modes succeed', () {
        for (final mode
            in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticMode
                .values) {
          final markdown = _run(
            args: <String>[
              '--runtime-execution-preflight-diagnostic=${mode.wire}',
            ],
          );
          final json = _run(
            args: <String>[
              '--runtime-execution-preflight-diagnostic=${mode.wire}',
              '--format=json',
            ],
          );

          expect(
            markdown.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticReportExitSuccess,
            reason: mode.wire,
          );
          expect(markdown.mode, mode);
          expect(markdown.result!.safeForPhase34M, isTrue);
          expect(
            json.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticReportExitSuccess,
            reason: mode.wire,
          );
          expect(jsonDecode(json.stdoutText), isA<Map<String, Object?>>());
        }
      });

      test('invalid format and mode fail with usage error', () {
        final badFormat = _run(args: const <String>['--format=xml']);
        final badMode = _run(
          args: const <String>[
            '--runtime-execution-preflight-diagnostic=missing',
          ],
        );

        expect(
          badFormat.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticReportExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(badFormat.stderrText, contains('usage:'));
        expect(
          badMode.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticReportExitUsage,
        );
        expect(badMode.commandFailure, 'unknownDiagnosticMode');
        expect(badMode.stderrText, contains('usage:'));
      });

      test('output contains no raw engine spam or active product data', () {
        for (final output in <String>[
          _run().stdoutText,
          _run(args: const <String>['--format=json']).stdoutText,
          _run(
            args: const <String>[
              '--runtime-execution-preflight-diagnostic=checks',
            ],
          ).stdoutText,
          _run(
            args: const <String>[
              '--runtime-execution-preflight-diagnostic=decision',
            ],
          ).stdoutText,
        ]) {
          _expectReportGuardrails(output);
        }
      });

      test('source imports remain command-only and integration-free', () {
        final modelSource = File(
          'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic.dart',
        ).readAsStringSync();
        final commandSource = File(
          'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_diagnostic_report.dart',
        ).readAsStringSync();
        final imports = RegExp(r"import '([^']+)';")
            .allMatches('$modelSource\n$commandSource')
            .map((match) => match.group(1)!)
            .join('\n')
            .toLowerCase();

        for (final forbidden in const <String>[
          'package:flutter/',
          'widgets',
          'backend',
          'preflight/server',
          'server',
          'cache',
          'database',
          'ffi',
          'native',
          'stockfish',
          'local_eval_service',
          'scheduler',
        ]) {
          expect(imports, isNot(contains(forbidden)), reason: forbidden);
        }
      });
    },
  );
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightDiagnosticReportCommand(
    args: args,
  );
}

void _expectReportGuardrails(String report) {
  for (final token in const <String>[
    'uciok',
    'readyok',
    'info depth',
    'bestmove e2e4',
    'position fen ',
    'go movetime ',
    'pv e2e4',
    'active fields: productLabel',
    'numeric move score:',
    'ACPL active',
    'official accuracy active',
    'cpLoss active',
    'winProbability active',
    'runtime executed: true',
    'runtimeExecutionApproved: true',
    'executionAllowed: true',
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
