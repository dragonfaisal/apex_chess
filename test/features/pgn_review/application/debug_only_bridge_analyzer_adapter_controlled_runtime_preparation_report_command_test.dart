@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter Controlled Runtime Preparation report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationStatus
              .controlledAnalyzerAdapterRuntimePreparationReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34H, isTrue);
        expect(
          result.result!.nextRecommendation,
          'runControlledAnalyzerAdapterRuntimePreparationDiagnostic',
        );
        expect(result.stdoutText, contains('## Disabled Execution Policy'));
        expect(result.stdoutText, contains('executionAllowed: false'));
        expect(result.stdoutText, contains('analyzerWiringAllowed: false'));
        expect(result.stdoutText, contains('engineCallsAllowed: false'));
        expect(result.stdoutText, contains('## Runtime Preconditions'));
        expect(result.stdoutText, contains('## Runtime Preparation Envelopes'));
        expect(result.stdoutText, contains('## Blocked Seam Summary'));
        expect(result.stdoutText, contains('## Denied Field Summary'));
        expect(result.stdoutText, contains('## Recommendation'));
      });

      test('JSON report succeeds and is parseable', () {
        final result = _run(args: const <String>['--format=json']);
        final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
        final counts = decoded['counts'] as Map<String, Object?>;

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationVersion,
        );
        expect(
          decoded['status'],
          'controlledAnalyzerAdapterRuntimePreparationReadyWithWarnings',
        );
        expect(decoded['safeForPhase34H'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'runControlledAnalyzerAdapterRuntimePreparationDiagnostic',
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
        expect(decoded['envelopes'], isA<List<Object?>>());
        expect(decoded['blockedSeams'], isA<List<Object?>>());
      });

      test('strict report succeeds', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('section commands succeed', () {
        for (final section in <String>[
          'all',
          'preconditions',
          'envelopes',
          'blocked-seams',
          'policy',
          'denied',
          'recommendation',
        ]) {
          final markdown = _run(args: <String>['--section=$section']);
          final json = _run(
            args: <String>['--section=$section', '--format=json'],
          );

          expect(
            markdown.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitSuccess,
            reason: section,
          );
          expect(
            json.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitSuccess,
            reason: section,
          );
          expect(jsonDecode(json.stdoutText), isA<Map<String, Object?>>());
        }
      });

      test('invalid format and section fail with usage error', () {
        final badFormat = _run(args: const <String>['--format=xml']);
        final badSection = _run(args: const <String>['--section=runtime']);

        expect(
          badFormat.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitUsage,
        );
        expect(badFormat.stderrText, contains('unknownFormat'));
        expect(
          badSection.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportExitUsage,
        );
        expect(badSection.stderrText, contains('unknownSection'));
      });

      test('output contains no raw engine spam or active product data', () {
        for (final output in <String>[
          _run().stdoutText,
          _run(args: const <String>['--format=json']).stdoutText,
          _run(args: const <String>['--section=preconditions']).stdoutText,
          _run(args: const <String>['--section=envelopes']).stdoutText,
          _run(args: const <String>['--section=blocked-seams']).stdoutText,
        ]) {
          expect(output, isNot(contains('bestmove ')));
          expect(output, isNot(contains('position fen ')));
          expect(output, isNot(contains('go movetime ')));
          expect(output, isNot(contains('active:productLabel')));
          expect(output, isNot(contains('backend://')));
        }
      });

      test('source imports remain command-only and integration-free', () {
        final modelSource = File(
          'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation.dart',
        ).readAsStringSync();
        final commandSource = File(
          'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_preparation_report.dart',
        ).readAsStringSync();
        final imports = RegExp(r"import '([^']+)';")
            .allMatches('$modelSource\n$commandSource')
            .map((match) => match.group(1)!)
            .join('\n');

        expect(imports, isNot(contains('flutter/')));
        expect(imports, isNot(contains('widgets')));
        expect(imports, isNot(contains('preflight')));
        expect(imports, isNot(contains('server')));
        expect(imports, isNot(contains('cache')));
        expect(imports, isNot(contains('database')));
        expect(imports, isNot(contains('ffi')));
        expect(imports, isNot(contains('stockfish')));
        expect(imports, isNot(contains('local_eval_service')));
        expect(imports, isNot(contains('scheduler')));
      });
    },
  );
}

DebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterControlledRuntimePreparationReportCommand(
    args: args,
  );
}
