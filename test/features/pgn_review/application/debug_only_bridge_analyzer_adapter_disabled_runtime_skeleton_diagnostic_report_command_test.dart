@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter Disabled Runtime Skeleton diagnostic report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticReportExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticStatus
              .disabledAnalyzerAdapterRuntimeSkeletonDiagnosticReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34K, isTrue);
        expect(
          result.result!.nextRecommendation,
          'implementControlledAnalyzerAdapterRuntimeExecutionPreflightPatch',
        );
        expect(
          result.stdoutText,
          contains('# Disabled Analyzer Adapter Runtime Skeleton Diagnostic'),
        );
        expect(result.stdoutText, contains('## Diagnostic Mode Summary'));
        expect(
          result.stdoutText,
          contains('## Disabled Runtime Skeleton Diagnostic Rows'),
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
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticReportExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticVersion,
        );
        expect(
          decoded['status'],
          'disabledAnalyzerAdapterRuntimeSkeletonDiagnosticReadyWithWarnings',
        );
        expect(decoded['safeForPhase34K'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'implementControlledAnalyzerAdapterRuntimeExecutionPreflightPatch',
        );
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
        expect(decoded['rows'], isA<List<Object?>>());
      });

      test('strict report succeeds for safe demo', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticReportExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('diagnostic modes succeed', () {
        for (final mode
            in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticMode
                .values) {
          final markdown = _run(
            args: <String>[
              '--disabled-runtime-skeleton-diagnostic=${mode.wire}',
            ],
          );
          final json = _run(
            args: <String>[
              '--disabled-runtime-skeleton-diagnostic=${mode.wire}',
              '--format=json',
            ],
          );

          expect(
            markdown.exitCode,
            debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticReportExitSuccess,
            reason: mode.wire,
          );
          expect(markdown.mode, mode);
          expect(markdown.result!.safeForPhase34K, isTrue);
          expect(
            json.exitCode,
            debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticReportExitSuccess,
            reason: mode.wire,
          );
          expect(jsonDecode(json.stdoutText), isA<Map<String, Object?>>());
        }
      });

      test('invalid format and mode fail with usage error', () {
        final badFormat = _run(args: const <String>['--format=xml']);
        final badMode = _run(
          args: const <String>[
            '--disabled-runtime-skeleton-diagnostic=missing',
          ],
        );

        expect(
          badFormat.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticReportExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(badFormat.stderrText, contains('usage:'));
        expect(
          badMode.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticReportExitUsage,
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
              '--disabled-runtime-skeleton-diagnostic=attempt',
            ],
          ).stdoutText,
          _run(
            args: const <String>[
              '--disabled-runtime-skeleton-diagnostic=policy',
            ],
          ).stdoutText,
        ]) {
          _expectReportGuardrails(output);
        }
      });

      test('source imports remain command-only and integration-free', () {
        final modelSource = File(
          'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic.dart',
        ).readAsStringSync();
        final commandSource = File(
          'tool/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_diagnostic_report.dart',
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonDiagnosticReportCommand(
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
    'executionPerformed: true',
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
