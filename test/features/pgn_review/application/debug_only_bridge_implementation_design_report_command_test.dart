@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_implementation_design.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_implementation_design_report.dart';

void main() {
  group('Debug-Only Bridge Implementation Design report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_bridge_implementation_design_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        debugOnlyBridgeImplementationDesignReportExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgeImplementationDesignReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Debug-Only Bridge Implementation Design'),
      );
      expect(result.stdoutText, contains('## Component Table'));
      expect(
        result.stdoutText,
        contains('## Implementation Design Record Table'),
      );
      expect(
        result.stdoutText,
        contains('## Proposed Future Skeleton Classes'),
      );
      expect(result.stdoutText, contains('DebugOnlyBridgeSkeleton'));
      expect(result.stdoutText, contains('## Phase 33F Skeleton Requirement'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(
        result.stdoutText,
        contains('proceedToDebugOnlyBridgeDeveloperSkeleton'),
      );
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase33F, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        debugOnlyBridgeImplementationDesignReportExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgeImplementationDesignReportFormat.json,
      );
      expect(
        decoded['version'],
        debugOnlyBridgeImplementationDesignReportVersion,
      );
      expect(decoded['totalComponents'], 12);
      expect(decoded['totalImplementationDesignRecords'], 12);
      expect(decoded['inputContractDesignCount'], 1);
      expect(decoded['coreRecordDesignCount'], 1);
      expect(decoded['contextRecordDesignCount'], 1);
      expect(decoded['runtimeBlockDesignCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase33F'], isTrue);
      expect(
        decoded['phase33FRecommendation'],
        'proceedToDebugOnlyBridgeDeveloperSkeleton',
      );
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugOnlyBridgeImplementationDesignReportExitSuccess,
      );
      expect(result.result!.safeForPhase33F, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe Phase 33D validation seam', () {
      final unsafeValidation =
          const DebugBridgePrototypeDesignReadinessSummaryValidation()
              .evaluate()
              .copyWith(
                validationStatus:
                    DebugBridgePrototypeDesignReadinessSummaryValidationStatus
                        .blockedByUnsafeSummary,
                unsafeRecordCount: 1,
                safeForPhase33E: false,
              );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugOnlyBridgeImplementationDesignRequest(
          readinessSummaryValidationResult: unsafeValidation,
        ),
      );

      expect(
        result.exitCode,
        debugOnlyBridgeImplementationDesignReportExitUnsafePolicy,
      );
      expect(
        result
            .result!
            .hasUnsafeDebugOnlyBridgeImplementationDesignPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        debugOnlyBridgeImplementationDesignReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.contextRecordDesignCount, 1);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        debugOnlyBridgeImplementationDesignReportExitUsage,
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
        'executable bridge skeleton implemented: true',
        'executable debug bridge prototype implemented: true',
        'implementation wiring implemented: true',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('command source does not execute proof or boundary integrations', () {
      final source = File(
        'tool/debug_only_bridge_implementation_design_report.dart',
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

DebugOnlyBridgeImplementationDesignReportCommandResult _run({
  List<String> args = const <String>[],
  DebugOnlyBridgeImplementationDesignRequest? request,
}) {
  return runDebugOnlyBridgeImplementationDesignReportCommand(
    args: args,
    request: request,
  );
}
