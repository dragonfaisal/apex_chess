@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter controlled runtime input preflight diagnostic report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticStatus
              .controlledAnalyzerAdapterRuntimeInputPreflightDiagnosticReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34Q, isTrue);
        expect(
          result.result!.nextRecommendation,
          'implementDisabledAnalyzerAdapterRuntimeInputEnvelopePatch',
        );
        expect(
          result.stdoutText,
          contains(
            '# Controlled Analyzer Adapter Runtime Input Preflight Diagnostic',
          ),
        );
        expect(result.stdoutText, contains('## Diagnostic Mode Summary'));
        expect(
          result.stdoutText,
          contains('## Runtime Input Preflight Diagnostic Rows'),
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
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticVersion,
        );
        expect(
          decoded['status'],
          'controlledAnalyzerAdapterRuntimeInputPreflightDiagnosticReadyWithWarnings',
        );
        expect(decoded['safeForPhase34Q'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'implementDisabledAnalyzerAdapterRuntimeInputEnvelopePatch',
        );
        expect(counts['checkDiagnosticRowCount'], 34);
        expect(counts['seamProbePerformedCount'], 0);
        expect(counts['runtimeExecutionCount'], 0);
        expect(counts['runtimeExecutionApprovedCount'], 0);
        expect(counts['analyzerRuntimeInputApprovedCount'], 0);
        expect(counts['analyzerRuntimeInputProducedCount'], 0);
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
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('diagnostic modes succeed', () {
        for (final mode
            in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticMode
                .values) {
          final markdown = _run(
            args: <String>['--runtime-input-preflight-diagnostic=${mode.wire}'],
          );
          final json = _run(
            args: <String>[
              '--runtime-input-preflight-diagnostic=${mode.wire}',
              '--format=json',
            ],
          );

          expect(
            markdown.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitSuccess,
            reason: mode.wire,
          );
          expect(markdown.mode, mode);
          expect(markdown.result!.safeForPhase34Q, isTrue);
          expect(
            json.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitSuccess,
            reason: mode.wire,
          );
          expect(jsonDecode(json.stdoutText), isA<Map<String, Object?>>());
        }
      });

      test('invalid format and mode fail with usage error', () {
        final badFormat = _run(args: const <String>['--format=xml']);
        final badMode = _run(
          args: const <String>['--runtime-input-preflight-diagnostic=missing'],
        );

        expect(
          badFormat.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(badFormat.stderrText, contains('usage:'));
        expect(
          badMode.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportExitUsage,
        );
        expect(
          badMode.commandFailure,
          'unknownRuntimeInputPreflightDiagnosticMode',
        );
        expect(badMode.stderrText, contains('usage:'));
      });

      test('output contains no raw engine spam or active product data', () {
        for (final output in <String>[
          _run().stdoutText,
          _run(args: const <String>['--format=json']).stdoutText,
          _run(
            args: const <String>['--runtime-input-preflight-diagnostic=checks'],
          ).stdoutText,
          _run(
            args: const <String>[
              '--runtime-input-preflight-diagnostic=decision',
            ],
          ).stdoutText,
          _run(
            args: const <String>[
              '--runtime-input-preflight-diagnostic=blocked-reasons',
            ],
          ).stdoutText,
        ]) {
          _expectReportGuardrails(output);
        }
      });

      test('source imports remain command-only and integration-free', () {
        final modelSource = File(
          'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic.dart',
        ).readAsStringSync();
        final commandSource = File(
          'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_input_preflight_diagnostic_report.dart',
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

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputPreflightDiagnosticReportCommand(
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
    'analyzerRuntimeInputApproved: true',
    'analyzerRuntimeInputProduced: true',
    'executionAllowed: true',
    'seamProbePerformed: true',
    'analyzer wired: true',
    'engine call active',
    'scheduler execution active',
    'http://',
    'https://',
    'apiKey',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}
