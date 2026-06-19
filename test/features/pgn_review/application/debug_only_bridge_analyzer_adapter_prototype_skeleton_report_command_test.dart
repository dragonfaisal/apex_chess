@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_analyzer_adapter_prototype_skeleton_report.dart';

void main() {
  group('Debug-Only Bridge analyzer adapter prototype skeleton report', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_bridge_analyzer_adapter_prototype_skeleton_report.dart',
        ).existsSync(),
        isTrue,
      );
    });

    test('default markdown command succeeds', () {
      final result = _run();

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonExitSuccess,
      );
      expect(
        result.stdoutText,
        contains('# Debug-Only Bridge Analyzer Adapter Prototype Skeleton'),
      );
      expect(result.stdoutText, contains('## Packet Summary'));
      expect(result.stdoutText, contains('## Policy Summary'));
      expect(result.stdoutText, contains('## Record Role Summary'));
      expect(result.stdoutText, contains('## Proof Boundary Summary'));
      expect(result.stdoutText, contains('## Denied Field Summary'));
      expect(
        result.stdoutText,
        contains('## Runtime Analyzer Engine Scheduler Product Block Summary'),
      );
      expect(
        result.stdoutText,
        contains(
          'validateDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation',
        ),
      );
      expect(result.result!.safeForPhase33V, isTrue);
      expect(result.stderrText, isEmpty);
    });

    test('JSON command succeeds and is parseable', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
      final counts = decoded['counts'] as Map<String, Object?>;
      final policy = decoded['policy'] as Map<String, Object?>;

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonExitSuccess,
      );
      expect(decoded['skeletonStatus'], 'prototypeSkeletonReadyWithWarnings');
      expect(decoded['safeForPhase33V'], isTrue);
      expect(
        decoded['phase33VRecommendation'],
        'validateDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonImplementation',
      );
      expect(counts['unsafeCount'], 0);
      expect(counts['activeDeniedFieldCount'], 0);
      expect(counts['productOutputCount'], 0);
      expect(counts['analyzerWiringCount'], 0);
      expect(counts['runtimeImplementationCount'], 0);
      expect(counts['executablePrototypeCount'], 0);
      expect(counts['engineCallCount'], 0);
      expect(counts['schedulerExecutionCount'], 0);
      expect(counts['persistenceWriteCount'], 0);
      expect(policy['hasUnsafeAllowance'], isFalse);
      expect(decoded['records'], isA<List<Object?>>());
    });

    test('strict mode succeeds for safe demo skeleton', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonExitSuccess,
      );
      expect(result.strict, isTrue);
      expect(result.result!.blockerCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.safeForPhase33V, isTrue);
    });

    test('usage rejects unknown flags', () {
      final result = _run(args: const <String>['--unknown']);

      expect(
        result.exitCode,
        debugOnlyBridgeAnalyzerAdapterPrototypeSkeletonExitUsage,
      );
      expect(result.stderrText, contains('unknownFlag'));
      expect(result.commandFailure, 'unknownFlag');
    });

    test('output contains no raw engine spam or active product data', () {
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
        'tool/debug_only_bridge_analyzer_adapter_prototype_skeleton_report.dart',
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

DebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonReportCommandResult _run({
  List<String> args = const <String>[],
}) {
  return runDebugOnlyBridgeAnalyzerAdapterPrototypeSkeletonReportCommand(
    args: args,
  );
}
