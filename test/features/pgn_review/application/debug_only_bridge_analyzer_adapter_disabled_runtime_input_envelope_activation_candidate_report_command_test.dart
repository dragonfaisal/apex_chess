@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_activation_candidate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_activation_candidate_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter disabled runtime input envelope activation candidate report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_activation_candidate_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateStatus
              .disabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34V, isTrue);
        expect(
          result.result!.nextRecommendation,
          'runDisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateDiagnostic',
        );
        expect(
          result.stdoutText,
          contains(
            '# Disabled Analyzer Adapter Runtime Input Envelope Activation Candidate',
          ),
        );
        expect(result.stdoutText, contains('## Candidate Records'));
        expect(result.stdoutText, contains('## Boundaries'));
        expect(result.stdoutText, contains('## Blocked Reasons'));
        expect(result.stdoutText, contains('## Proof Boundary'));
        expect(result.stdoutText, contains('## Denied Fields'));
      });

      test('JSON report succeeds and is parseable', () {
        final result = _run(args: const <String>['--format=json']);
        final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
        final counts = decoded['counts'] as Map<String, Object?>;

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateVersion,
        );
        expect(
          decoded['status'],
          'disabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateReadyWithWarnings',
        );
        expect(decoded['safeForPhase34V'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'runDisabledAnalyzerAdapterRuntimeInputEnvelopeActivationCandidateDiagnostic',
        );
        expect(counts['candidateRecordCount'], 16);
        expect(counts['boundaryCount'], 21);
        expect(counts['blockedReasonCount'], 31);
        expect(counts['disabledEnvelopeCount'], greaterThanOrEqualTo(1));
        expect(counts['activationPreflightCount'], greaterThanOrEqualTo(1));
        expect(counts['activationCandidateCount'], greaterThanOrEqualTo(1));
        expect(counts['activationCandidateApprovedCount'], 0);
        expect(counts['activationCandidatePromotedCount'], 0);
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
        expect(decoded['records'], isA<List<Object?>>());
        expect(decoded['boundaries'], isA<List<Object?>>());
        expect(decoded['blockedReasons'], isA<List<Object?>>());
      });

      test('strict report succeeds for safe demo', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('report sections succeed', () {
        for (final section
            in DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
                .values) {
          final markdown = _run(args: <String>['--section=${section.wire}']);
          final json = _run(
            args: <String>['--section=${section.wire}', '--format=json'],
          );

          expect(
            markdown.exitCode,
            debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitSuccess,
            reason: section.wire,
          );
          expect(markdown.section, section);
          expect(
            markdown.stdoutText,
            contains(
              section ==
                      DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportSection
                          .all
                  ? '# Disabled Analyzer Adapter Runtime Input Envelope Activation Candidate'
                  : section.wire,
            ),
          );
          expect(
            json.exitCode,
            debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitSuccess,
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
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(badFormat.stderrText, contains('usage:'));
        expect(
          badSection.exitCode,
          debugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportExitUsage,
        );
        expect(badSection.commandFailure, 'unknownSection');
        expect(badSection.stderrText, contains('usage:'));
      });

      test(
        'output contains no raw engine spam, payloads, active candidate, or active product data',
        () {
          for (final output in <String>[
            _run().stdoutText,
            _run(args: const <String>['--format=json']).stdoutText,
            _run(args: const <String>['--section=candidate']).stdoutText,
            _run(args: const <String>['--section=boundaries']).stdoutText,
            _run(args: const <String>['--section=blocked-reasons']).stdoutText,
          ]) {
            _expectReportGuardrails(output);
          }
        },
      );

      test('source imports remain command-only and integration-free', () {
        final modelSource = File(
          'lib/features/pgn_review/application/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_activation_candidate.dart',
        ).readAsStringSync();
        final commandSource = File(
          'tool/debug_only_bridge_analyzer_adapter_disabled_runtime_input_envelope_activation_candidate_report.dart',
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

DebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterDisabledRuntimeInputEnvelopeActivationCandidateReportCommand(
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
    'activationCandidateApproved: true',
    'activationCandidatePromoted: true',
    'activationApproved: true',
    'activationPerformed: true',
    'activeRuntimeInputEnvelope: true',
    'analyzerRuntimeInputApproved: true',
    'analyzerRuntimeInputProduced: true',
    'runtimeExecutionApproved: true',
    'executionAllowed: true',
    'executionPerformed: true',
    'productOutputAllowed: true',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}
