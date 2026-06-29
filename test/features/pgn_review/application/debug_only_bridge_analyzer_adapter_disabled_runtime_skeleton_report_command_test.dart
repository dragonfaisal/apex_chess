@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter Disabled Runtime Skeleton report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonStatus
              .disabledAnalyzerAdapterRuntimeSkeletonReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34J, isTrue);
        expect(
          result.result!.nextRecommendation,
          'runDisabledAnalyzerAdapterRuntimeSkeletonDiagnostic',
        );
        expect(
          result.stdoutText,
          contains('# Disabled Analyzer Adapter Runtime Skeleton'),
        );
        expect(result.stdoutText, contains('## Request Envelope Summary'));
        expect(result.stdoutText, contains('## Response Envelope Summary'));
        expect(
          result.stdoutText,
          contains('## Disabled Execution Attempt Summary'),
        );
        expect(result.stdoutText, contains('## Disabled Runtime Policy'));
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
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonVersion,
        );
        expect(
          decoded['status'],
          'disabledAnalyzerAdapterRuntimeSkeletonReadyWithWarnings',
        );
        expect(decoded['safeForPhase34J'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'runDisabledAnalyzerAdapterRuntimeSkeletonDiagnostic',
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
        expect(decoded['request'], isA<Map<String, Object?>>());
        expect(decoded['response'], isA<Map<String, Object?>>());
        expect(decoded['executionAttempt'], isA<Map<String, Object?>>());
        expect(decoded['blockedSeams'], isA<List<Object?>>());
      });

      test('strict report succeeds for safe demo', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('section commands succeed', () {
        for (final section in const <String>[
          'all',
          'request',
          'response',
          'attempt',
          'policy',
          'blocked-seams',
          'denied',
          'recommendation',
        ]) {
          final markdown = _run(args: <String>['--section=$section']);
          final json = _run(
            args: <String>['--section=$section', '--format=json'],
          );

          expect(
            markdown.exitCode,
            debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitSuccess,
            reason: section,
          );
          expect(markdown.section.wire, section);
          expect(
            json.exitCode,
            debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitSuccess,
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
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(badFormat.stderrText, contains('usage:'));
        expect(
          badSection.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportExitUsage,
        );
        expect(badSection.commandFailure, 'unknownSection');
        expect(badSection.stderrText, contains('usage:'));
      });

      test('output contains no raw engine spam or active product data', () {
        for (final output in <String>[
          _run().stdoutText,
          _run(args: const <String>['--format=json']).stdoutText,
          _run(args: const <String>['--section=request']).stdoutText,
          _run(args: const <String>['--section=response']).stdoutText,
          _run(args: const <String>['--section=attempt']).stdoutText,
          _run(args: const <String>['--section=policy']).stdoutText,
        ]) {
          _expectReportGuardrails(output);
        }
      });

      test('source imports remain command-only and integration-free', () {
        final modelSource = File(
          'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton.dart',
        ).readAsStringSync();
        final commandSource = File(
          'tool/debug_only_bridge_analyzer_adapter_disabled_runtime_skeleton_report.dart',
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportCommandResult _run({
  List<String> args = const <String>[],
}) {
  return runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeSkeletonReportCommand(
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
