@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter Controlled Runtime Preparation diagnostic report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticReportExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticStatus
              .controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34I, isTrue);
        expect(
          result.result!.nextRecommendation,
          'implementDisabledAnalyzerAdapterRuntimeSkeleton',
        );
        expect(
          result.stdoutText,
          contains(
            '# Controlled Analyzer Adapter Runtime Preparation Diagnostic',
          ),
        );
        expect(result.stdoutText, contains('## Runtime Preparation Summary'));
        expect(result.stdoutText, contains('## Safety Summary'));
        expect(result.stdoutText, contains('safe for Phase 34I: true'));
      });

      test('JSON report succeeds and is parseable', () {
        final result = _run(args: const <String>['--format=json']);
        final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
        final counts = decoded['counts'] as Map<String, Object?>;

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticReportExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticVersion,
        );
        expect(
          decoded['status'],
          'controlledAnalyzerAdapterRuntimePreparationDiagnosticReadyWithWarnings',
        );
        expect(decoded['safeForPhase34I'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'implementDisabledAnalyzerAdapterRuntimeSkeleton',
        );
        expect(counts['runtimeExecutionCount'], 0);
        expect(counts['executableRuntimeCount'], 0);
        expect(counts['analyzerWiringCount'], 0);
        expect(counts['engineCallCount'], 0);
        expect(counts['schedulerExecutionCount'], 0);
        expect(counts['persistenceWriteCount'], 0);
        expect(counts['productOutputCount'], 0);
        expect(counts['activeDeniedFieldCount'], 0);
        expect(decoded['rows'], isA<List<Object?>>());
      });

      test('strict report succeeds for safe demo', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticReportExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('runtime-preparation diagnostic modes succeed', () {
        for (final mode
            in DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticMode
                .values) {
          final markdown = _run(
            args: <String>['--runtime-preparation-diagnostic=${mode.wire}'],
          );
          final json = _run(
            args: <String>[
              '--runtime-preparation-diagnostic=${mode.wire}',
              '--format=json',
            ],
          );

          expect(
            markdown.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticReportExitSuccess,
            reason: mode.wire,
          );
          expect(markdown.mode, mode);
          expect(
            json.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticReportExitSuccess,
            reason: mode.wire,
          );
          expect(jsonDecode(json.stdoutText), isA<Map<String, Object?>>());
        }
      });

      test('invalid format and mode fail with usage error', () {
        final badFormat = _run(args: const <String>['--format=xml']);
        final badMode = _run(
          args: const <String>['--runtime-preparation-diagnostic=runtime'],
        );

        expect(
          badFormat.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticReportExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(badFormat.stderrText, contains('usage:'));
        expect(
          badMode.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticReportExitUsage,
        );
        expect(badMode.commandFailure, 'unknownRuntimePreparationDiagnostic');
        expect(badMode.stderrText, contains('usage:'));
      });

      test('output contains no raw engine spam or active product data', () {
        for (final output in <String>[
          _run().stdoutText,
          _run(args: const <String>['--format=json']).stdoutText,
          _run(
            args: const <String>['--runtime-preparation-diagnostic=envelopes'],
          ).stdoutText,
          _run(
            args: const <String>[
              '--runtime-preparation-diagnostic=blocked-seams',
            ],
          ).stdoutText,
          _run(
            args: const <String>['--runtime-preparation-diagnostic=denied'],
          ).stdoutText,
        ]) {
          _expectReportGuardrails(output);
        }
      });

      test('source imports remain command-only and integration-free', () {
        final modelSource = File(
          'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic.dart',
        ).readAsStringSync();
        final commandSource = File(
          'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_diagnostic_report.dart',
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
          expect(imports, isNot(contains(forbidden)), reason: forbidden);
        }
      });
    },
  );
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationDiagnosticReportCommand(
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
