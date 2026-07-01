@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight_diagnostic_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter activation preflight diagnostic report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight_diagnostic_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticReportExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticStatus
              .controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnosticReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34U, isTrue);
        expect(
          result.result!.nextRecommendation,
          'implementDisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePatch',
        );
        expect(
          result.stdoutText,
          contains(
            '# Controlled Analyzer Adapter Runtime Input Envelope Activation Preflight Diagnostic',
          ),
        );
        expect(result.stdoutText, contains('## Diagnostic Mode Summary'));
        expect(
          result.stdoutText,
          contains('## Activation Preflight Diagnostic Rows'),
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
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticReportExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticVersion,
        );
        expect(
          decoded['status'],
          'controlledAnalyzerAdapterRuntimeInputEnvelopeActivationPreflightDiagnosticReadyWithWarnings',
        );
        expect(decoded['safeForPhase34U'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'implementDisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidatePatch',
        );
        expect(counts['totalDiagnosticRows'], 71);
        expect(counts['checkDiagnosticRowCount'], 38);
        expect(counts['decisionDiagnosticRowCount'], 1);
        expect(counts['blockedReasonDiagnosticRowCount'], 29);
        expect(counts['disabledEnvelopeCount'], greaterThanOrEqualTo(1));
        expect(counts['activationPreflightCount'], greaterThanOrEqualTo(1));
        expect(counts['activationApprovedCount'], 0);
        expect(counts['activationPerformedCount'], 0);
        expect(counts['activeRuntimeInputEnvelopeCount'], 0);
        expect(counts['playablePayloadCount'], 0);
        expect(counts['analyzerRuntimeInputApprovedCount'], 0);
        expect(counts['analyzerRuntimeInputProducedCount'], 0);
        expect(counts['runtimeExecutionApprovedCount'], 0);
        expect(counts['runtimeExecutionCount'], 0);
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
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticReportExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('diagnostic modes succeed', () {
        for (final mode
            in DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticMode
                .values) {
          final markdown = _run(
            args: <String>[
              '--runtime-input-envelope-activation-preflight-diagnostic=${mode.wire}',
            ],
          );
          final json = _run(
            args: <String>[
              '--runtime-input-envelope-activation-preflight-diagnostic=${mode.wire}',
              '--format=json',
            ],
          );

          expect(
            markdown.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticReportExitSuccess,
            reason: mode.wire,
          );
          expect(markdown.mode, mode);
          expect(markdown.result!.safeForPhase34U, isTrue);
          expect(
            json.exitCode,
            debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticReportExitSuccess,
            reason: mode.wire,
          );
          expect(jsonDecode(json.stdoutText), isA<Map<String, Object?>>());
        }
      });

      test('invalid format and mode fail with usage error', () {
        final badFormat = _run(args: const <String>['--format=xml']);
        final badMode = _run(
          args: const <String>[
            '--runtime-input-envelope-activation-preflight-diagnostic=missing',
          ],
        );

        expect(
          badFormat.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticReportExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(badFormat.stderrText, contains('usage:'));
        expect(
          badMode.exitCode,
          debugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticReportExitUsage,
        );
        expect(
          badMode.commandFailure,
          'unknownRuntimeInputEnvelopeActivationPreflightDiagnosticMode',
        );
        expect(badMode.stderrText, contains('usage:'));
      });

      test(
        'output contains no raw engine spam, payloads, active envelope, or active product data',
        () {
          for (final output in <String>[
            _run().stdoutText,
            _run(args: const <String>['--format=json']).stdoutText,
            _run(
              args: const <String>[
                '--runtime-input-envelope-activation-preflight-diagnostic=checks',
              ],
            ).stdoutText,
            _run(
              args: const <String>[
                '--runtime-input-envelope-activation-preflight-diagnostic=decision',
              ],
            ).stdoutText,
            _run(
              args: const <String>[
                '--runtime-input-envelope-activation-preflight-diagnostic=blocked-reasons',
              ],
            ).stdoutText,
          ]) {
            _expectReportGuardrails(output);
          }
        },
      );

      test('source imports remain command-only and integration-free', () {
        final modelSource = File(
          'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight_diagnostic.dart',
        ).readAsStringSync();
        final commandSource = File(
          'tool/debug_only_bridge_analyzer_adapter_controlled_runtime_input_envelope_activation_preflight_diagnostic_report.dart',
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

DebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterControlledRuntimeInputEnvelopeActivationPreflightDiagnosticReportCommand(
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
    'playable fen payload',
    'pgn payload:',
    'uci move payload',
    'activationApproved: true',
    'activationPerformed: true',
    'activeRuntimeInputEnvelope: true',
    'analyzerRuntimeInputApproved: true',
    'analyzerRuntimeInputProduced: true',
    'runtimeExecutionApproved: true',
    'executionAllowed: true',
    'executionPerformed: true',
    'analyzer wired: true',
    'engine call active',
    'scheduler execution active',
    'active fields: productLabel',
    'cp-loss',
    'win probability',
    'readiness gate passed',
  ]) {
    expect(report.toLowerCase(), isNot(contains(token.toLowerCase())));
  }
}
