@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_analyzer_adapter_prototype_selected_golden_diagnostic_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_prototype_selected_golden_diagnostic_validation_report.dart';

void main() {
  group(
    'Debug-Only Bridge Analyzer Adapter Prototype Selected Golden Diagnostic Validation report command',
    () {
      test('command file exists', () {
        expect(
          File(
            'tool/debug_only_bridge_analyzer_adapter_prototype_selected_golden_diagnostic_validation_report.dart',
          ).existsSync(),
          isTrue,
        );
      });

      test('markdown report succeeds', () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitSuccess,
        );
        expect(
          result.format,
          DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportFormat
              .markdown,
        );
        expect(
          result.result!.status.wire,
          'selectedGoldenAnalyzerAdapterPrototypeDiagnosticValidatedWithWarnings',
        );
        expect(result.result!.safeForPhase34B, isTrue);
        expect(
          result.result!.nextRecommendation,
          'proceedToAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan',
        );
        expect(result.stdoutText, contains('## Validation Check Table'));
        expect(result.stdoutText, contains('## Selected Row Validation Table'));
        expect(result.stdoutText, contains('## Selected Set Validation'));
        expect(
          result.stdoutText,
          contains('## Proof And Owner Boundary Validation'),
        );
        expect(result.stdoutText, contains('## Denied Field Validation'));
        expect(
          result.stdoutText,
          contains('## Runtime And Integration Boundary Validation'),
        );
        expect(result.stderrText, isEmpty);
      });

      test('JSON report succeeds and is parseable', () {
        final result = _run(args: const <String>['--format=json']);
        final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
        final counts = decoded['counts'] as Map<String, Object?>;

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitSuccess,
        );
        expect(
          decoded['version'],
          debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationVersion,
        );
        expect(
          decoded['validationStatus'],
          'selectedGoldenAnalyzerAdapterPrototypeDiagnosticValidatedWithWarnings',
        );
        expect(decoded['safeForPhase34B'], isTrue);
        expect(
          decoded['nextRecommendation'],
          'proceedToAnalyzerAdapterPrototypeSelectedDiagnosticActionPlan',
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
        expect(decoded['checks'], isA<List<Object?>>());
        expect(decoded['validationRows'], isA<List<Object?>>());
      });

      test('strict report succeeds for safe selected diagnostic validation', () {
        final result = _run(args: const <String>['--strict']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitSuccess,
        );
        expect(result.strict, isTrue);
        expect(result.result!.safeForPhase34B, isTrue);
        expect(result.result!.unsafeCount, 0);
        expect(result.result!.blockerCount, 0);
        expect(result.result!.criticalCount, 0);
        expect(result.result!.activeDeniedFieldCount, 0);
      });

      test('invalid format fails with usage error', () {
        final result = _run(args: const <String>['--format=yaml']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationExitUsage,
        );
        expect(result.commandFailure, 'unknownFormat');
        expect(result.stderrText, contains('usage:'));
      });

      test('output contains no raw engine spam or active product data', () {
        final markdown = _run().stdoutText;
        final json = _run(args: const <String>['--format=json']).stdoutText;

        _expectReportGuardrails(markdown);
        _expectReportGuardrails(json);
      });

      test('source imports remain command and model only', () {
        final source = File(
          'tool/debug_only_bridge_analyzer_adapter_prototype_selected_golden_diagnostic_validation_report.dart',
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

DebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportCommandResult
_run({List<String> args = const <String>[]}) {
  return runDebugOnlyBridgeAnalyzerAdapterPrototypeSelectedGoldenDiagnosticValidationReportCommand(
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
