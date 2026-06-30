@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter disabled runtime input envelope report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeStatus
              .disabledAnalyzerAdapterRuntimeInputEnvelopeReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34R, isTrue);
        expect(
          result.result!.nextRecommendation,
          'runDisabledAnalyzerAdapterRuntimeInputEnvelopeDiagnostic',
        );
        expect(
          result.stdoutText,
          contains('# Disabled Analyzer Adapter Runtime Input Envelope'),
        );
        expect(result.stdoutText, contains('## Slot Summary'));
        expect(result.stdoutText, contains('## Boundary Summary'));
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
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeVersion,
        );
        expect(
          decoded['status'],
          'disabledAnalyzerAdapterRuntimeInputEnvelopeReadyWithWarnings',
        );
        expect(decoded['safeForPhase34R'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'runDisabledAnalyzerAdapterRuntimeInputEnvelopeDiagnostic',
        );
        expect(counts['disabledEnvelopeCount'], greaterThanOrEqualTo(1));
        expect(counts['activeRuntimeInputEnvelopeCount'], 0);
        expect(counts['analyzerRuntimeInputApprovedCount'], 0);
        expect(counts['analyzerRuntimeInputProducedCount'], 0);
        expect(counts['runtimeExecutionApprovedCount'], 0);
        expect(counts['runtimeExecutionCount'], 0);
        expect(counts['analyzerWiringCount'], 0);
        expect(counts['executableRuntimeCount'], 0);
        expect(counts['engineCallCount'], 0);
        expect(counts['schedulerExecutionCount'], 0);
        expect(counts['persistenceWriteCount'], 0);
        expect(counts['productOutputCount'], 0);
        expect(counts['productAdapterCount'], 0);
        expect(counts['savedAnalysisIntegrationCount'], 0);
        expect(counts['activePayloadSlotCount'], 0);
        expect(counts['activeDeniedFieldCount'], 0);
        expect(decoded['input'], isA<Map<String, Object?>>());
        expect(decoded['slots'], isA<List<Object?>>());
        expect(decoded['boundaries'], isA<List<Object?>>());
        expect(decoded['blockedReasons'], isA<List<Object?>>());
      });

      test('strict report succeeds for safe demo', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('section reports succeed in markdown and JSON', () {
        for (final section
            in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportSection
                .values) {
          final markdown = _run(args: <String>['--section=${section.wire}']);
          final json = _run(
            args: <String>['--section=${section.wire}', '--format=json'],
          );

          expect(
            markdown.exitCode,
            debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitSuccess,
            reason: section.wire,
          );
          expect(markdown.section, section);
          expect(markdown.result!.safeForPhase34R, isTrue);
          expect(
            json.exitCode,
            debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitSuccess,
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
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(badFormat.stderrText, contains('usage:'));
        expect(
          badSection.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportExitUsage,
        );
        expect(badSection.commandFailure, 'unknownSection');
        expect(badSection.stderrText, contains('usage:'));
      });

      test(
        'output contains no raw engine spam, payloads, or active product data',
        () {
          for (final output in <String>[
            _run().stdoutText,
            _run(args: const <String>['--format=json']).stdoutText,
            _run(args: const <String>['--section=slots']).stdoutText,
            _run(args: const <String>['--section=boundaries']).stdoutText,
            _run(args: const <String>['--section=blocked-reasons']).stdoutText,
            _run(args: const <String>['--section=denied']).stdoutText,
            _run(args: const <String>['--section=proof']).stdoutText,
          ]) {
            _expectReportGuardrails(output);
          }
        },
      );

      test('source imports remain command-only and integration-free', () {
        final modelSource = File(
          'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope.dart',
        ).readAsStringSync();
        final commandSource = File(
          'tool/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_report.dart',
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeReportCommand(
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
    'numeric move score:',
    'ACPL active',
    'official accuracy active',
    'cpLoss active',
    'winProbability active',
    'http://',
    'https://',
    'apiKey',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}
