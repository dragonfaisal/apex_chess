@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_prototype_diagnostic_command.dart';

void main() {
  group('Debug-Only Bridge Analyzer Adapter Prototype Diagnostic command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_bridge_analyzer_adapter_prototype_diagnostic_command.dart',
        ).existsSync(),
        isTrue,
      );
    });

    test('default markdown command succeeds and includes sections', () {
      final result = _run();

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.markdown,
      );
      expect(
        result.section,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.all,
      );
      expect(result.safeDemo, isTrue);
      expect(
        result.diagnosticResult!.status,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticStatus
            .prototypeDiagnosticCommandReadyWithWarnings,
      );
      expect(result.diagnosticResult!.safeForPhase33Z, isTrue);
      expect(result.stdoutText, contains('## Source Phase Chain'));
      expect(result.stdoutText, contains('## Inspection Snapshot Summary'));
      expect(result.stdoutText, contains('## Packet Summary'));
      expect(result.stdoutText, contains('## Policy Flag Summary'));
      expect(result.stdoutText, contains('## Record Role Summary'));
      expect(result.stdoutText, contains('## Android Proof Boundary Summary'));
      expect(result.stdoutText, contains('## Allowed/Denied Field Summary'));
      expect(
        result.stdoutText,
        contains(
          '## Runtime/Analyzer/Engine/Scheduler/Product Blocked Summary',
        ),
      );
      expect(result.stdoutText, contains('## Recommendation'));
      expect(
        result.stdoutText,
        contains(
          'proceedToSelectedGoldenAnalyzerAdapterPrototypeDiagnosticRun',
        ),
      );
      expect(result.stderrText, isEmpty);
    });

    test('JSON command succeeds and is parseable', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticFormat.json,
      );
      expect(
        decoded['version'],
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandVersion,
      );
      expect(
        decoded['diagnosticStatus'],
        'prototypeDiagnosticCommandReadyWithWarnings',
      );
      expect(decoded['section'], 'all');
      expect(decoded['safeForPhase33Z'], isTrue);
      expect(decoded['safeForNextStep'], isTrue);
      expect(
        decoded['nextRecommendation'],
        'proceedToSelectedGoldenAnalyzerAdapterPrototypeDiagnosticRun',
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
      expect(decoded['sourcePhaseChain'], isA<Map<String, Object?>>());
      expect(decoded['snapshot'], isA<Map<String, Object?>>());
      expect(decoded['packets'], isA<Map<String, Object?>>());
      expect(decoded['policy'], isA<Map<String, Object?>>());
      expect(decoded['records'], isA<Map<String, Object?>>());
      expect(decoded['proof'], isA<Map<String, Object?>>());
      expect(decoded['boundaries'], isA<Map<String, Object?>>());
      expect(decoded['runtime'], isA<Map<String, Object?>>());
      expect(decoded['next'], isA<Map<String, Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const <String>['--strict']);
      final diagnostic = result.diagnosticResult!;

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
      );
      expect(result.strict, isTrue);
      expect(diagnostic.safeForPhase33Z, isTrue);
      expect(diagnostic.unsafeCount, 0);
      expect(diagnostic.blockerCount, 0);
      expect(diagnostic.criticalCount, 0);
      expect(diagnostic.analyzerWiringCount, 0);
      expect(diagnostic.runtimeImplementationCount, 0);
      expect(diagnostic.executablePrototypeCount, 0);
      expect(diagnostic.engineCallCount, 0);
      expect(diagnostic.schedulerExecutionCount, 0);
      expect(diagnostic.persistenceWriteCount, 0);
      expect(diagnostic.productOutputCount, 0);
      expect(diagnostic.activeDeniedFieldCount, 0);
    });

    test('each section mode succeeds', () {
      for (final section
          in DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticSection.values) {
        final result = _run(args: <String>['--section=${section.wire}']);

        expect(
          result.exitCode,
          debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitSuccess,
          reason: section.wire,
        );
        expect(result.section, section);
        expect(
          result.stdoutText,
          contains('selected section: ${section.wire}'),
        );
      }
    });

    test('section outputs include expected summaries', () {
      expect(
        _run(args: const <String>['--section=snapshot']).stdoutText,
        contains('## Inspection Snapshot Summary'),
      );
      expect(
        _run(args: const <String>['--section=packets']).stdoutText,
        contains('## Packet Summary'),
      );
      expect(
        _run(args: const <String>['--section=policy']).stdoutText,
        contains('## Policy Flag Summary'),
      );
      expect(
        _run(args: const <String>['--section=records']).stdoutText,
        contains('## Inspection Validation Rows'),
      );
      expect(
        _run(args: const <String>['--section=proof']).stdoutText,
        contains('owner proof queue count: 0'),
      );
      expect(
        _run(args: const <String>['--section=boundaries']).stdoutText,
        contains('Stockfish/raw UCI/PV dump denied: true'),
      );
      expect(
        _run(args: const <String>['--section=runtime']).stdoutText,
        contains('scheduler execution count: 0'),
      );
      expect(
        _run(args: const <String>['--section=recommendation']).stdoutText,
        contains(
          'proceedToSelectedGoldenAnalyzerAdapterPrototypeDiagnosticRun',
        ),
      );
    });

    test('invalid section and format fail with usage error', () {
      final badSection = _run(args: const <String>['--section=unknown']);
      final badFormat = _run(args: const <String>['--format=yaml']);

      expect(
        badSection.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage,
      );
      expect(badSection.commandFailure, 'unknownSection');
      expect(badSection.stderrText, contains('usage:'));
      expect(
        badFormat.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandExitUsage,
      );
      expect(badFormat.commandFailure, 'unknownFormat');
      expect(badFormat.stderrText, contains('usage:'));
    });

    test('output contains no raw engine spam or active product data', () {
      final markdown = _run().stdoutText;
      final json = _run(args: const <String>['--format=json']).stdoutText;

      _expectReportGuardrails(markdown);
      _expectReportGuardrails(json);
    });

    test('source imports remain command-only and integration-free', () {
      final source = File(
        'tool/debug_only_bridge_analyzer_adapter_prototype_diagnostic_command.dart',
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
  });
}

DebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommandResult _run({
  List<String> args = const <String>[],
}) {
  return runDebugOnlyBridgeAnalyzerAdapterPrototypeDiagnosticCommand(
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
    'http://',
    'https://',
    'apiKey',
    'secret=',
    'token=',
  ]) {
    expect(report, isNot(contains(token)), reason: token);
  }
}
