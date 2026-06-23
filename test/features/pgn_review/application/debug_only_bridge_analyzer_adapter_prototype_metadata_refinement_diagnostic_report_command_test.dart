@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_diagnostic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_diagnostic_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter Prototype Metadata Refinement Diagnostic report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_diagnostic_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitSuccess,
        );
        expect(
          result.result!.status,
          DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticStatus
              .analyzerAdapterPrototypeMetadataRefinementDiagnosticReadyWithWarnings,
        );
        expect(result.result!.safeForPhase34G, isTrue);
        expect(
          result.result!.nextRecommendation,
          'implementControlledAnalyzerAdapterRuntimePreparationPatch',
        );
        expect(result.stdoutText, contains('## Source Phase Chain'));
        expect(result.stdoutText, contains('## Diagnostic Mode Summary'));
        expect(result.stdoutText, contains('## Refinement Diagnostic Rows'));
        expect(result.stdoutText, contains('## Refinement Group Summary'));
        expect(result.stdoutText, contains('## Target Surface Summary'));
        expect(result.stdoutText, contains('## Safety Summary'));
        expect(result.stdoutText, contains('## Recommendation'));
      });

      test('JSON report succeeds and is parseable', () {
        final result = _run(args: const <String>['--format=json']);
        final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
        final counts = decoded['counts'] as Map<String, Object?>;

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticVersion,
        );
        expect(
          decoded['status'],
          'analyzerAdapterPrototypeMetadataRefinementDiagnosticReadyWithWarnings',
        );
        expect(decoded['refinementDiagnosticMode'], 'default');
        expect(decoded['safeForPhase34G'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'implementControlledAnalyzerAdapterRuntimePreparationPatch',
        );
        expect(counts['unsafeCount'], 0);
        expect(counts['blockerCount'], 0);
        expect(counts['criticalCount'], 0);
        expect(counts['analyzerWiringCount'], 0);
        expect(counts['runtimeImplementationCount'], 0);
        expect(counts['executablePrototypeCount'], 0);
        expect(counts['engineCallCount'], 0);
        expect(counts['schedulerExecutionCount'], 0);
        expect(counts['persistenceWriteCount'], 0);
        expect(counts['productOutputCount'], 0);
        expect(counts['activeDeniedFieldCount'], 0);
        expect(decoded['rows'], isA<List<Object?>>());
      });

      test('strict report succeeds', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.safeForPhase34G, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
      });

      test('refinement diagnostic mode commands succeed', () {
        for (final mode
            in DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticMode
                .values) {
          final result = _run(
            args: <String>['--refinement-diagnostic=${mode.wire}'],
          );

          expect(
            result.exitCode,
            debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitSuccess,
            reason: mode.wire,
          );
          expect(result.refinementDiagnosticMode, mode);
          expect(
            result.stdoutText,
            contains('refinement diagnostic mode: ${mode.wire}'),
          );
        }
      });

      test('invalid format and refinement diagnostic fail with usage error', () {
        final badFormat = _run(args: const <String>['--format=yaml']);
        final badMode = _run(
          args: const <String>['--refinement-diagnostic=unknown'],
        );

        expect(
          badFormat.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitUsage,
        );
        expect(badFormat.commandFailure, 'unknownFormat');
        expect(
          badMode.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticExitUsage,
        );
        expect(badMode.commandFailure, 'unknownRefinementDiagnostic');
      });

      test('output contains no raw engine spam or active product data', () {
        final markdown = _run().stdoutText;
        final json = _run(args: const <String>['--format=json']).stdoutText;

        _expectReportGuardrails(markdown);
        _expectReportGuardrails(json);
      });

      test('source imports remain model-only and command-only', () {
        final source = File(
          'tool/debug_only_bridge_analyzer_adapter_prototype_metadata_refinement_diagnostic_report.dart',
        ).readAsStringSync();
        final imports = RegExp(
          r"import '([^']+)';",
        ).allMatches(source).map((match) => match.group(1)!).join('\n');

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
          expect(imports.toLowerCase(), isNot(contains(forbidden)));
        }
      });
    },
  );
}

DebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterPrototypeMetadataRefinementDiagnosticReportCommand(
    args: args,
  );
}

void _expectReportGuardrails(String report) {
  for (final token in const <String>[
    'uciok',
    'readyok',
    'info depth',
    'bestmove e2e4',
    'pv e2e4',
    'active fields: productLabel',
    'numeric move score:',
    'ACPL active',
    'official accuracy active',
    'cpLoss active',
    'winProbability active',
    'runtime implemented: true',
    'analyzer wired: true',
    'engine call active',
    'scheduler execution active',
    'readiness summary chain active',
    'readiness gate active',
    'http://',
    'https://',
    'apiKey',
    'secret=',
    'token=',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}
