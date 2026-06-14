@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_boundary_design_validation_report.dart';

void main() {
  group('Debug-Only Bridge analyzer adapter boundary design validation report', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_bridge_analyzer_adapter_boundary_design_validation_report.dart',
        ).existsSync(),
        isTrue,
      );
    });

    test('default markdown command succeeds', () {
      final result = _run();

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationExitSuccess,
      );
      expect(
        result.stdoutText,
        contains(
          '# Debug-Only Bridge Analyzer Adapter Boundary Design Validation',
        ),
      );
      expect(result.stdoutText, contains('## Validation Check Table'));
      expect(
        result.stdoutText,
        contains('## Boundary Record Validation Table'),
      );
      expect(
        result.stdoutText,
        contains('## Analyzer Input Candidate Validation'),
      );
      expect(result.stdoutText, contains('## Denied Field Validation'));
      expect(
        result.stdoutText,
        contains(
          '## Runtime, Scheduler, Persistence, And Engine Blocked Validation',
        ),
      );
      expect(result.stdoutText, contains('## Android Proof Boundary'));
      expect(
        result.stdoutText,
        contains(
          'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign',
        ),
      );
      expect(result.result!.safeForPhase33O, isTrue);
      expect(result.stderrText, isEmpty);
    });

    test('JSON command succeeds and is parseable', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationExitSuccess,
      );
      expect(
        decoded['validationStatus'],
        'boundaryDesignValidatedWithWarnings',
      );
      expect(decoded['safeForPhase33O'], isTrue);
      expect(
        decoded['phase33ORecommendation'],
        'proceedToDebugOnlyBridgeAnalyzerAdapterBoundaryPrototypeDesign',
      );
      expect(counts['unsafeCount'], 0);
      expect(counts['activeDeniedFieldCount'], 0);
      expect(counts['engineCallCount'], 0);
      expect(counts['schedulerExecutionCount'], 0);
      expect(counts['analyzerWiringCount'], 0);
      expect(decoded['checks'], isA<List<Object?>>());
      expect(decoded['validationRows'], isA<List<Object?>>());
    });

    test('strict mode succeeds for safe demo validation', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationExitSuccess,
      );
      expect(result.strict, isTrue);
      expect(result.result!.blockerCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.safeForPhase33O, isTrue);
    });

    test('usage rejects unknown flags', () {
      final result = _run(args: const <String>['--unknown']);

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationExitUsage,
      );
      expect(result.stderrText, contains('unknownFlag'));
      expect(result.commandFailure, 'unknownFlag');
    });

    test('output contains no raw engine spam or secrets', () {
      final report = _run().stdoutText;

      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        'pv e2e4',
        'position fen',
        'go depth',
        'active fields: productLabel',
        'numeric move score:',
        'ACPL active',
        'official accuracy active',
        'cpLoss active',
        'winProbability active',
        'http://',
        'https://',
        'apiKey',
        'secret=',
        'token=',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('source imports remain tool-only and integration-free', () {
      final source = File(
        'tool/debug_only_bridge_analyzer_adapter_boundary_design_validation_report.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(source, isNot(contains('Process.run')));
      expect(source, isNot(contains('Process.start')));
      expect(imports, isNot(contains('dart:ffi')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports.toLowerCase(), isNot(contains('stockfish')));
      expect(imports, isNot(contains('backend')));
      expect(imports, isNot(contains('preflight')));
      expect(imports, isNot(contains('server')));
      expect(imports, isNot(contains('persistence')));
      expect(imports, isNot(contains('cache')));
      expect(imports, isNot(contains('database')));
      expect(imports, isNot(contains('scheduler')));
    });
  });
}

DebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationReportCommandResult _run({
  List<String> args = const <String>[],
}) {
  return runDebugOnlyBridgeAnalyzerAdapterBoundaryDesignValidationReportCommand(
    args: args,
  );
}
