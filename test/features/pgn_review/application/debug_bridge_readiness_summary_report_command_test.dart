@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_bridge_readiness_summary_report.dart';

void main() {
  group('Debug Bridge Readiness Summary report command', () {
    test('command file exists', () {
      expect(
        File('tool/debug_bridge_readiness_summary_report.dart').existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(result.exitCode, debugBridgeReadinessSummaryReportExitSuccess);
      expect(result.format, DebugBridgeReadinessSummaryReportFormat.markdown);
      expect(result.stdoutText, contains('# Debug Bridge Readiness Summary'));
      expect(result.stdoutText, contains('## Summary Group Table'));
      expect(result.stdoutText, contains('## Summary Record Table'));
      expect(result.stdoutText, contains('## Ready Debug Core Summary'));
      expect(result.stdoutText, contains('## Denied Blocked Field Summary'));
      expect(
        result.stdoutText,
        contains('## Stockfish Raw UCI PV Dump Blocked Summary'),
      );
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32X, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(result.exitCode, debugBridgeReadinessSummaryReportExitSuccess);
      expect(result.format, DebugBridgeReadinessSummaryReportFormat.json);
      expect(decoded['version'], debugBridgeReadinessSummaryReportVersion);
      expect(decoded['totalSummaryGroups'], 9);
      expect(decoded['totalSummaryRecords'], 9);
      expect(decoded['readyDebugCoreInputCount'], 1);
      expect(decoded['constrainedDebugContextInputCount'], 1);
      expect(decoded['readyAllowedFieldCount'], 14);
      expect(decoded['deniedBlockedFieldCount'], 18);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32X'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(result.exitCode, debugBridgeReadinessSummaryReportExitSuccess);
      expect(result.result!.safeForPhase32X, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeReadiness = const DebugBridgeDesignReadinessGate()
          .evaluate()
          .copyWith(
            readinessStatus: DebugBridgeDesignReadinessGateStatus
                .blockedByBridgeValidationFailure,
            unsafeCount: 1,
            safeForPhase32W: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugBridgeReadinessSummaryRequest(
          readinessGateResult: unsafeReadiness,
        ),
      );

      expect(
        result.exitCode,
        debugBridgeReadinessSummaryReportExitUnsafePolicy,
      );
      expect(
        result.result!.hasUnsafeDebugBridgeReadinessSummaryPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(result.exitCode, debugBridgeReadinessSummaryReportExitSuccess);
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.constrainedDebugContextInputCount, 1);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(result.exitCode, debugBridgeReadinessSummaryReportExitUsage);
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
        'numeric move score:',
        'scoreValue',
        'moveScore',
        'rankedMoves',
        'moveRanking active',
        'ACPL active',
        'official accuracy active',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('command source does not execute proof or boundary integrations', () {
      final source = File(
        'tool/debug_bridge_readiness_summary_report.dart',
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

DebugBridgeReadinessSummaryReportCommandResult _run({
  List<String> args = const <String>[],
  DebugBridgeReadinessSummaryRequest? request,
}) {
  return runDebugBridgeReadinessSummaryReportCommand(
    args: args,
    request: request,
  );
}
