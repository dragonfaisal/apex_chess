@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_bridge_design_readiness_gate_report.dart';

void main() {
  group('Debug Bridge Design Readiness Gate report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_bridge_design_readiness_gate_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(result.exitCode, debugBridgeDesignReadinessGateReportExitSuccess);
      expect(result.format, DebugBridgeDesignReadinessReportFormat.markdown);
      expect(
        result.stdoutText,
        contains('# Debug Bridge Design Readiness Gate'),
      );
      expect(result.stdoutText, contains('## Readiness Group Table'));
      expect(result.stdoutText, contains('## Readiness Record Table'));
      expect(result.stdoutText, contains('## Ready Debug Core Inputs'));
      expect(result.stdoutText, contains('## Denied Blocked Fields'));
      expect(
        result.stdoutText,
        contains('## Stockfish Raw UCI PV Dump Blocked Status'),
      );
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32W, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(result.exitCode, debugBridgeDesignReadinessGateReportExitSuccess);
      expect(result.format, DebugBridgeDesignReadinessReportFormat.json);
      expect(decoded['version'], debugBridgeDesignReadinessGateReportVersion);
      expect(decoded['totalReadinessGroups'], 8);
      expect(decoded['totalReadinessRecords'], 8);
      expect(decoded['readyDebugCoreInputCount'], 1);
      expect(decoded['constrainedDebugContextInputCount'], 1);
      expect(decoded['readyAllowedFieldCount'], 14);
      expect(decoded['deniedBlockedFieldCount'], 18);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32W'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(result.exitCode, debugBridgeDesignReadinessGateReportExitSuccess);
      expect(result.result!.safeForPhase32W, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeValidation = const DebugOnlyAdapterBridgeDesignValidation()
          .evaluate()
          .copyWith(
            validationStatus: DebugOnlyAdapterBridgeDesignValidationStatus
                .blockedByUnsafeBridgeDesign,
            unsafeRecordCount: 1,
            safeForPhase32V: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugBridgeDesignReadinessGateRequest(
          validationResult: unsafeValidation,
        ),
      );

      expect(
        result.exitCode,
        debugBridgeDesignReadinessGateReportExitUnsafePolicy,
      );
      expect(
        result.result!.hasUnsafeDebugBridgeReadinessPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(result.exitCode, debugBridgeDesignReadinessGateReportExitSuccess);
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.constrainedDebugContextInputCount, 1);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(result.exitCode, debugBridgeDesignReadinessGateReportExitUsage);
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
        'tool/debug_bridge_design_readiness_gate_report.dart',
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

DebugBridgeDesignReadinessGateReportCommandResult _run({
  List<String> args = const <String>[],
  DebugBridgeDesignReadinessGateRequest? request,
}) {
  return runDebugBridgeDesignReadinessGateReportCommand(
    args: args,
    request: request,
  );
}
