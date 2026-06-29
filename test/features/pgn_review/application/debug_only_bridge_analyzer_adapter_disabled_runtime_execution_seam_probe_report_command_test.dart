@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter disabled runtime execution seam probe report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeStatus
              .disabledAnalyzerAdapterRuntimeExecutionSeamProbeReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34N, isTrue);
        expect(
          result.result!.nextRecommendation,
          'runDisabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnostic',
        );
        expect(
          result.stdoutText,
          contains('# Disabled Analyzer Adapter Runtime Execution Seam Probe'),
        );
        expect(result.stdoutText, contains('## Seam Probe Request Summary'));
        expect(result.stdoutText, contains('## Seam Probe Response Summary'));
        expect(
          result.stdoutText,
          contains('## Refused Seam Probe Attempt Summary'),
        );
        expect(result.stdoutText, contains('## Boundary Summary'));
        expect(result.stdoutText, contains('## Blocked Reason Summary'));
        expect(result.stdoutText, contains('## Recommendation'));
      });

      test('JSON report succeeds and is parseable', () {
        final result = _run(args: const <String>['--format=json']);
        final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
        final counts = decoded['counts'] as Map<String, Object?>;

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeVersion,
        );
        expect(
          decoded['status'],
          'disabledAnalyzerAdapterRuntimeExecutionSeamProbeReadyWithWarnings',
        );
        expect(decoded['safeForPhase34N'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'runDisabledAnalyzerAdapterRuntimeExecutionSeamProbeDiagnostic',
        );
        expect(counts['seamProbeAttemptCount'], greaterThanOrEqualTo(1));
        expect(counts['seamProbePerformedCount'], 0);
        expect(counts['runtimeExecutionCount'], 0);
        expect(counts['runtimeExecutionApprovedCount'], 0);
        expect(counts['analyzerRuntimeInputCount'], 0);
        expect(counts['analyzerWiringCount'], 0);
        expect(counts['engineCallCount'], 0);
        expect(counts['schedulerExecutionCount'], 0);
        expect(counts['persistenceWriteCount'], 0);
        expect(counts['productOutputCount'], 0);
        expect(counts['productAdapterCount'], 0);
        expect(counts['savedAnalysisIntegrationCount'], 0);
        expect(counts['activeDeniedFieldCount'], 0);
      });

      test('strict report succeeds for safe demo', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('section commands succeed', () {
        for (final section
            in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportSection
                .values) {
          final markdown = _run(args: <String>['--section=${section.wire}']);
          final json = _run(
            args: <String>['--section=${section.wire}', '--format=json'],
          );

          expect(
            markdown.exitCode,
            debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitSuccess,
            reason: section.wire,
          );
          expect(markdown.section, section);
          expect(markdown.result!.safeForPhase34N, isTrue);
          expect(
            json.exitCode,
            debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitSuccess,
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
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(badFormat.stderrText, contains('usage:'));
        expect(
          badSection.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportExitUsage,
        );
        expect(badSection.commandFailure, 'unknownSection');
        expect(badSection.stderrText, contains('usage:'));
      });

      test('output contains no raw engine spam or active product data', () {
        for (final output in <String>[
          _run().stdoutText,
          _run(args: const <String>['--format=json']).stdoutText,
          _run(args: const <String>['--section=request']).stdoutText,
          _run(args: const <String>['--section=boundaries']).stdoutText,
          _run(args: const <String>['--section=blocked-reasons']).stdoutText,
        ]) {
          _expectReportGuardrails(output);
        }
      });

      test('source imports remain command-only and integration-free', () {
        final modelSource = File(
          'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe.dart',
        ).readAsStringSync();
        final commandSource = File(
          'tool/debug_only_bridge_analyzer_adapter_disabled_runtime_execution_seam_probe_report.dart',
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeExecutionSeamProbeReportCommand(
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
    'analyzerRuntimeInputProduced: true',
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
