@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_bridge_prototype_design_readiness_summary_validation_report.dart';

void main() {
  group('Debug Bridge Prototype Design Readiness Summary Validation report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_bridge_prototype_design_readiness_summary_validation_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessSummaryValidationReportExitSuccess,
      );
      expect(
        result.format,
        DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat
            .markdown,
      );
      expect(
        result.stdoutText,
        contains(
          '# Debug Bridge Prototype Design Readiness Summary Validation',
        ),
      );
      expect(result.stdoutText, contains('## Validation Check Table'));
      expect(result.stdoutText, contains('## Summary Group Validation Table'));
      expect(result.stdoutText, contains('## Summary Record Validation Table'));
      expect(result.stdoutText, contains('## Approved Core Validation'));
      expect(
        result.stdoutText,
        contains('## Allowed And Denied Field Validation'),
      );
      expect(
        result.stdoutText,
        contains('## Stockfish Raw UCI PV Dump Denial Validation'),
      );
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(
        result.stdoutText,
        contains('proceedToDebugOnlyBridgeImplementationDesign'),
      );
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase33E, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessSummaryValidationReportExitSuccess,
      );
      expect(
        result.format,
        DebugBridgePrototypeDesignReadinessSummaryValidationReportFormat.json,
      );
      expect(
        decoded['version'],
        debugBridgePrototypeDesignReadinessSummaryValidationReportVersion,
      );
      expect(decoded['totalChecks'], 16);
      expect(decoded['totalGroupRows'], 11);
      expect(decoded['totalRecordRows'], 11);
      expect(decoded['validApprovedCoreSummaryCount'], 1);
      expect(decoded['validRuntimePrototypeWiringBlockedCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase33E'], isTrue);
      expect(
        decoded['phase33ERecommendation'],
        'proceedToDebugOnlyBridgeImplementationDesign',
      );
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessSummaryValidationReportExitSuccess,
      );
      expect(result.result!.safeForPhase33E, isTrue);
      expect(result.result!.unsafeRecordCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe summary', () {
      final unsafeSummary = const DebugBridgePrototypeDesignReadinessSummary()
          .evaluate()
          .copyWith(
            summaryStatus: DebugBridgePrototypeDesignReadinessSummaryStatus
                .blockedByPolicyBoundary,
            unsafeCount: 1,
            safeForPhase33D: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugBridgePrototypeDesignReadinessSummaryValidationRequest(
          summaryResult: unsafeSummary,
        ),
      );

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessSummaryValidationReportExitUnsafePolicy,
      );
      expect(
        result
            .result!
            .hasUnsafeDebugBridgePrototypeDesignReadinessSummaryValidationPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessSummaryValidationReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.validConstrainedContextSummaryCount, 1);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessSummaryValidationReportExitUsage,
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
        'allowed fields: stockfishCommand',
        'numeric move score:',
        'scoreValue',
        'moveScore',
        'rankedMoves',
        'moveRanking active',
        'ACPL active',
        'official accuracy active',
        'runtime implemented: true',
        'executable debug bridge prototype implemented: true',
        'implementation wiring implemented: true',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('command source does not execute proof or boundary integrations', () {
      final source = File(
        'tool/debug_bridge_prototype_design_readiness_summary_validation_report.dart',
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

DebugBridgePrototypeDesignReadinessSummaryValidationReportCommandResult _run({
  List<String> args = const <String>[],
  DebugBridgePrototypeDesignReadinessSummaryValidationRequest? request,
}) {
  return runDebugBridgePrototypeDesignReadinessSummaryValidationReportCommand(
    args: args,
    request: request,
  );
}
