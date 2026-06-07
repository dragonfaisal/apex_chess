@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/internal_adapter_readiness_summary_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/internal_adapter_readiness_summary_validation_report.dart';

void main() {
  group('Internal Adapter Readiness Summary Validation report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/internal_adapter_readiness_summary_validation_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        internalAdapterReadinessSummaryValidationReportExitSuccess,
      );
      expect(
        result.format,
        InternalAdapterReadinessSummaryValidationReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Internal Adapter Readiness Summary Validation'),
      );
      expect(result.stdoutText, contains('## Validation Check Table'));
      expect(result.stdoutText, contains('## Summary Group Validation Table'));
      expect(result.stdoutText, contains('## Allowed Core Summary Validation'));
      expect(result.stdoutText, contains('## Blocked Output Field Validation'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32T, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        internalAdapterReadinessSummaryValidationReportExitSuccess,
      );
      expect(
        result.format,
        InternalAdapterReadinessSummaryValidationReportFormat.json,
      );
      expect(
        decoded['version'],
        internalAdapterReadinessSummaryValidationReportVersion,
      );
      expect(decoded['totalChecks'], 14);
      expect(decoded['totalGroupRows'], 8);
      expect(decoded['validAllowedCoreSummaryCount'], 1);
      expect(decoded['validConstrainedContextSummaryCount'], 1);
      expect(decoded['validInactiveBlockedSummaryCount'], 1);
      expect(decoded['validInactiveFutureOnlySummaryCount'], 1);
      expect(decoded['validActiveOutputFieldSummaryCount'], 1);
      expect(decoded['validBlockedOutputFieldSummaryCount'], 1);
      expect(decoded['validAndroidProofBoundarySummaryCount'], 1);
      expect(decoded['validOwnerProofStatusSummaryCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32T'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        internalAdapterReadinessSummaryValidationReportExitSuccess,
      );
      expect(result.result!.safeForPhase32T, isTrue);
      expect(result.result!.unsafeSummaryCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeSummary = const InternalAdapterReadinessSummary()
          .evaluate()
          .copyWith(
            summaryStatus:
                InternalAdapterReadinessSummaryStatus.blockedByUnsafeReadiness,
            unsafeCount: 1,
            safeForPhase32S: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: InternalAdapterReadinessSummaryValidationRequest(
          summaryResult: unsafeSummary,
        ),
      );

      expect(
        result.exitCode,
        internalAdapterReadinessSummaryValidationReportExitUnsafePolicy,
      );
      expect(
        result.result!.hasUnsafeAdapterSummaryValidationPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        internalAdapterReadinessSummaryValidationReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.validConstrainedContextSummaryCount, 1);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        internalAdapterReadinessSummaryValidationReportExitUsage,
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
        'tool/internal_adapter_readiness_summary_validation_report.dart',
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

InternalAdapterReadinessSummaryValidationReportCommandResult _run({
  List<String> args = const <String>[],
  InternalAdapterReadinessSummaryValidationRequest? request,
}) {
  return runInternalAdapterReadinessSummaryValidationReportCommand(
    args: args,
    request: request,
  );
}
