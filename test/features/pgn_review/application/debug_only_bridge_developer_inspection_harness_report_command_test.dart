@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_inspection_harness_report.dart';

void main() {
  group('Debug-Only Bridge Developer Inspection Harness report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_bridge_developer_inspection_harness_report.dart',
        ).existsSync(),
        isTrue,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessReportExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgeDeveloperInspectionHarnessReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Debug-Only Bridge Developer Inspection Harness'),
      );
      expect(result.stdoutText, contains('## Inspection Snapshot Summary'));
      expect(result.stdoutText, contains('## Input Packet Inspection'));
      expect(result.stdoutText, contains('## Output Packet Inspection'));
      expect(result.stdoutText, contains('## Policy Inspection'));
      expect(result.stdoutText, contains('## Bridge Record Inspection Table'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(
        result.stdoutText,
        contains('validateDebugOnlyBridgeDeveloperInspectionHarness'),
      );
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase33I, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessReportExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgeDeveloperInspectionHarnessReportFormat.json,
      );
      expect(
        decoded['version'],
        debugOnlyBridgeDeveloperInspectionHarnessReportVersion,
      );
      expect(decoded['status'], 'inspectionReadyWithWarnings');
      expect(decoded['totalInspectionRows'], 14);
      expect(decoded['unsafeCount'], 0);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase33I'], isTrue);
      expect(
        decoded['phase33IRecommendation'],
        'validateDebugOnlyBridgeDeveloperInspectionHarness',
      );
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessReportExitSuccess,
      );
      expect(result.result!.safeForPhase33I, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe skeleton seam', () {
      final unsafeSkeleton = const DebugOnlyBridgeSkeleton()
          .evaluate()
          .copyWith(
            status: DebugOnlyBridgeSkeletonStatus.blockedByPolicyBoundary,
            unsafeCount: 1,
            safeForPhase33G: false,
            productOutputActive: true,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugOnlyBridgeDeveloperInspectionHarnessRequest(
          skeletonResult: unsafeSkeleton,
        ),
      );

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessReportExitUnsafePolicy,
      );
      expect(
        result
            .result!
            .hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.totalInspectionRows, 14);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperInspectionHarnessReportExitUsage,
      );
      expect(result.stderrText, contains('unknownFormat'));
      expect(result.commandFailure, 'unknownFormat');
    });

    test('command output keeps active-output guardrails', () {
      final report = _run().stdoutText;

      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        'pv e2e4',
        'pvMoves',
        'active fields: productLabel',
        'active fields: finalMoveLabel',
        'active fields: numericMoveScore',
        'allowed fields: productLabel',
        'allowed fields: schedulerExecution',
        'allowed fields: stockfishCommand',
        'numeric move score:',
        'scoreValue',
        'moveScore',
        'rankedMoves',
        'moveRanking active',
        'ACPL active',
        'official accuracy active',
        'runtime implemented: true',
        'executable bridge skeleton implemented: true',
        'executable debug bridge prototype implemented: true',
        'implementation wiring implemented: true',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('command source does not execute proof or boundary integrations', () {
      final source = File(
        'tool/debug_only_bridge_developer_inspection_harness_report.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      expect(source, isNot(contains('Process.run')));
      expect(source, isNot(contains('Process.start')));
      expect(imports, isNot(contains('dart:ffi')));
      expect(imports.toLowerCase(), isNot(contains('stockfish')));
      expect(imports, isNot(contains('LocalEvalService')));
      expect(imports, isNot(contains('package:flutter/')));
      expect(imports, isNot(contains('Widget')));
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

DebugOnlyBridgeDeveloperInspectionHarnessReportCommandResult _run({
  List<String> args = const <String>[],
  DebugOnlyBridgeDeveloperInspectionHarnessRequest? request,
}) {
  return runDebugOnlyBridgeDeveloperInspectionHarnessReportCommand(
    args: args,
    request: request,
  );
}
