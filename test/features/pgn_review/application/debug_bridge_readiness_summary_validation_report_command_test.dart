@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_bridge_readiness_summary_validation_report.dart';

void main() {
  group('Debug Bridge Readiness Summary Validation report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_bridge_readiness_summary_validation_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        debugBridgeReadinessSummaryValidationReportExitSuccess,
      );
      expect(
        result.format,
        DebugBridgeReadinessSummaryValidationReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Debug Bridge Readiness Summary Validation'),
      );
      expect(result.stdoutText, contains('## Validation Check Table'));
      expect(result.stdoutText, contains('## Summary Group Validation Table'));
      expect(result.stdoutText, contains('## Summary Record Validation Table'));
      expect(result.stdoutText, contains('## Ready Debug Core Validation'));
      expect(
        result.stdoutText,
        contains('## Stockfish Raw UCI PV Dump Blocked Validation'),
      );
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32Y, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        debugBridgeReadinessSummaryValidationReportExitSuccess,
      );
      expect(
        result.format,
        DebugBridgeReadinessSummaryValidationReportFormat.json,
      );
      expect(
        decoded['version'],
        debugBridgeReadinessSummaryValidationReportVersion,
      );
      expect(decoded['totalChecks'], 15);
      expect(decoded['passedCheckCount'], 12);
      expect(decoded['warningCheckCount'], 3);
      expect(decoded['totalGroupRows'], 9);
      expect(decoded['totalRecordRows'], 9);
      expect(decoded['validReadyCoreSummaryCount'], 1);
      expect(decoded['validConstrainedContextSummaryCount'], 1);
      expect(decoded['validStockfishRawUciPvDumpBlockedCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32Y'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugBridgeReadinessSummaryValidationReportExitSuccess,
      );
      expect(result.result!.safeForPhase32Y, isTrue);
      expect(result.result!.unsafeRecordCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeSummary = const DebugBridgeReadinessSummary()
          .evaluate()
          .copyWith(
            summaryStatus:
                DebugBridgeReadinessSummaryStatus.blockedByUnsafeReadiness,
            unsafeCount: 1,
            safeForPhase32X: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugBridgeReadinessSummaryValidationRequest(
          summaryResult: unsafeSummary,
        ),
      );

      expect(
        result.exitCode,
        debugBridgeReadinessSummaryValidationReportExitUnsafePolicy,
      );
      expect(
        result
            .result!
            .hasUnsafeDebugBridgeReadinessSummaryValidationPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        debugBridgeReadinessSummaryValidationReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.validConstrainedContextSummaryCount, 1);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        debugBridgeReadinessSummaryValidationReportExitUsage,
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
        'tool/debug_bridge_readiness_summary_validation_report.dart',
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

DebugBridgeReadinessSummaryValidationReportCommandResult _run({
  List<String> args = const <String>[],
  DebugBridgeReadinessSummaryValidationRequest? request,
}) {
  return runDebugBridgeReadinessSummaryValidationReportCommand(
    args: args,
    request: request,
  );
}
