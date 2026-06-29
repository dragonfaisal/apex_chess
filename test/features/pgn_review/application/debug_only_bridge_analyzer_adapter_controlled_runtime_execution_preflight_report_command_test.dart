@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter controlled runtime execution preflight report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightReportExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightStatus
              .controlledAnalyzerAdapterRuntimeExecutionPreflightReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34L, isTrue);
        expect(
          result.result!.nextRecommendation,
          'runControlledAnalyzerAdapterRuntimeExecutionPreflightDiagnostic',
        );
        expect(
          result.stdoutText,
          contains('# Controlled Analyzer Adapter Runtime Execution Preflight'),
        );
        expect(result.stdoutText, contains('## Preflight Check Summary'));
        expect(result.stdoutText, contains('## Preflight Decision Summary'));
        expect(result.stdoutText, contains('## Blocked Reason Summary'));
        expect(result.stdoutText, contains('## Denied Field Summary'));
        expect(result.stdoutText, contains('## Proof Boundary Summary'));
        expect(result.stdoutText, contains('## Recommendation'));
      });

      test('JSON report succeeds and is parseable', () {
        final result = _run(args: const <String>['--format=json']);
        final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
        final counts = decoded['counts'] as Map<String, Object?>;

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightReportExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightVersion,
        );
        expect(
          decoded['status'],
          'controlledAnalyzerAdapterRuntimeExecutionPreflightReadyWithWarnings',
        );
        expect(decoded['safeForPhase34L'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'runControlledAnalyzerAdapterRuntimeExecutionPreflightDiagnostic',
        );
        expect(counts['totalChecks'], 24);
        expect(counts['runtimeExecutionCount'], 0);
        expect(counts['executableRuntimeCount'], 0);
        expect(counts['analyzerWiringCount'], 0);
        expect(counts['engineCallCount'], 0);
        expect(counts['schedulerExecutionCount'], 0);
        expect(counts['persistenceWriteCount'], 0);
        expect(counts['productOutputCount'], 0);
        expect(counts['productAdapterCount'], 0);
        expect(counts['savedAnalysisIntegrationCount'], 0);
        expect(counts['activeDeniedFieldCount'], 0);
        expect(decoded['checks'], isA<List<Object?>>());
        expect(decoded['decision'], isA<Map<String, Object?>>());
        expect(decoded['blockedReasons'], isA<List<Object?>>());
      });

      test('strict report succeeds for safe demo', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightReportExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('report sections succeed', () {
        for (final section
            in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightReportSection
                .values) {
          final markdown = _run(args: <String>['--section=${section.wire}']);
          final json = _run(
            args: <String>['--section=${section.wire}', '--format=json'],
          );

          expect(
            markdown.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightReportExitSuccess,
            reason: section.wire,
          );
          expect(markdown.section, section);
          expect(
            markdown.stdoutText,
            contains(
              section ==
                      DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightReportSection
                          .all
                  ? '# Controlled Analyzer Adapter Runtime Execution Preflight'
                  : section.wire,
            ),
          );
          expect(
            json.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightReportExitSuccess,
            reason: section.wire,
          );
          expect(jsonDecode(json.stdoutText), isA<Map<String, Object?>>());
        }
      });

      test('invalid format and section fail with usage error', () {
        final badFormat = _run(args: const <String>['--format=xml']);
        final badSection = _run(args: const <String>['--section=missing']);

        expect(
          badFormat.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightReportExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(badFormat.stderrText, contains('usage:'));
        expect(
          badSection.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightReportExitUsage,
        );
        expect(badSection.commandFailure, 'unknownSection');
        expect(badSection.stderrText, contains('usage:'));
      });

      test('output contains no raw engine spam or active product data', () {
        for (final output in <String>[
          _run().stdoutText,
          _run(args: const <String>['--format=json']).stdoutText,
          _run(args: const <String>['--section=checks']).stdoutText,
          _run(args: const <String>['--section=decision']).stdoutText,
          _run(args: const <String>['--section=blocked-reasons']).stdoutText,
        ]) {
          _expectReportGuardrails(output);
        }
      });

      test('source imports remain command-only and integration-free', () {
        final modelSource = File(
          'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight.dart',
        ).readAsStringSync();
        final commandSource = File(
          'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_execution_preflight_report.dart',
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

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterControlledRuntimeExecutionPreflightReportCommand(
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
