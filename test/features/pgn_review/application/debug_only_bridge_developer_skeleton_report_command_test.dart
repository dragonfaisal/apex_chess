@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_skeleton.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_implementation_design.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_skeleton_report.dart';

void main() {
  group('Debug-Only Bridge Developer Skeleton report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_bridge_developer_skeleton_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperSkeletonReportExitSuccess,
      );
      expect(result.format, DebugOnlyBridgeSkeletonReportFormat.markdown);
      expect(
        result.stdoutText,
        contains('# Debug-Only Bridge Developer Skeleton'),
      );
      expect(result.stdoutText, contains('## Input Packet Summary'));
      expect(result.stdoutText, contains('## Output Packet Summary'));
      expect(result.stdoutText, contains('## Policy Summary'));
      expect(result.stdoutText, contains('## Bridge Record Table'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(
        result.stdoutText,
        contains('validateDebugOnlyBridgeDeveloperSkeleton'),
      );
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase33G, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperSkeletonReportExitSuccess,
      );
      expect(result.format, DebugOnlyBridgeSkeletonReportFormat.json);
      expect(decoded['version'], debugOnlyBridgeDeveloperSkeletonReportVersion);
      expect(decoded['totalRecords'], 11);
      expect(decoded['coreRecordCount'], 1);
      expect(decoded['contextRecordCount'], 1);
      expect(decoded['runtimeBlockedRecordCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase33G'], isTrue);
      expect(
        decoded['phase33GRecommendation'],
        'validateDebugOnlyBridgeDeveloperSkeleton',
      );
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperSkeletonReportExitSuccess,
      );
      expect(result.result!.safeForPhase33G, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe implementation design seam', () {
      final unsafeDesign = const DebugOnlyBridgeImplementationDesign()
          .evaluate()
          .copyWith(
            implementationDesignStatus:
                DebugOnlyBridgeImplementationDesignStatus
                    .blockedByUnsafeReadinessValidation,
            unsafeCount: 1,
            safeForPhase33F: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugOnlyBridgeSkeletonRequest(
          implementationDesignResult: unsafeDesign,
        ),
      );

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperSkeletonReportExitUnsafePolicy,
      );
      expect(
        result.result!.hasUnsafeDebugOnlyBridgeDeveloperSkeletonPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperSkeletonReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.coreRecordCount, 1);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(result.exitCode, debugOnlyBridgeDeveloperSkeletonReportExitUsage);
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
        'tool/debug_only_bridge_developer_skeleton_report.dart',
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
    });
  });
}

DebugOnlyBridgeDeveloperSkeletonReportCommandResult _run({
  List<String> args = const <String>[],
  DebugOnlyBridgeSkeletonRequest? request,
}) {
  return runDebugOnlyBridgeDeveloperSkeletonReportCommand(
    args: args,
    request: request,
  );
}
