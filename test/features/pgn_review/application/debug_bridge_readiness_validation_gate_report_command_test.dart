@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_summary_validation.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_bridge_readiness_validation_gate_report.dart';

void main() {
  group('Debug Bridge Readiness Validation Gate report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_bridge_readiness_validation_gate_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        debugBridgeReadinessValidationGateReportExitSuccess,
      );
      expect(
        result.format,
        DebugBridgeReadinessValidationGateReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Debug Bridge Readiness Validation Gate'),
      );
      expect(result.stdoutText, contains('## Gate Group Table'));
      expect(result.stdoutText, contains('## Gate Record Table'));
      expect(
        result.stdoutText,
        contains('## Prototype-Ready Debug Core Records'),
      );
      expect(
        result.stdoutText,
        contains('## Stockfish Raw UCI PV Dump Denied Boundary'),
      );
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32Z, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        debugBridgeReadinessValidationGateReportExitSuccess,
      );
      expect(
        result.format,
        DebugBridgeReadinessValidationGateReportFormat.json,
      );
      expect(
        decoded['version'],
        debugBridgeReadinessValidationGateReportVersion,
      );
      expect(decoded['totalGateGroups'], 9);
      expect(decoded['totalGateRecords'], 9);
      expect(decoded['prototypeReadyDebugCoreCount'], 1);
      expect(decoded['constrainedDebugContextCount'], 1);
      expect(decoded['prototypeReadyAllowedFieldCount'], 14);
      expect(decoded['deniedFieldCount'], 18);
      expect(decoded['stockfishRawUciPvDumpDeniedCount'], 3);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32Z'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugBridgeReadinessValidationGateReportExitSuccess,
      );
      expect(result.result!.safeForPhase32Z, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeValidation = const DebugBridgeReadinessSummaryValidation()
          .evaluate()
          .copyWith(
            validationStatus: DebugBridgeReadinessSummaryValidationStatus
                .blockedByUnsafeSummary,
            unsafeRecordCount: 1,
            safeForPhase32Y: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugBridgeReadinessValidationGateRequest(
          validationResult: unsafeValidation,
        ),
      );

      expect(
        result.exitCode,
        debugBridgeReadinessValidationGateReportExitUnsafePolicy,
      );
      expect(
        result
            .result!
            .hasUnsafeDebugBridgeReadinessValidationGatePolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        debugBridgeReadinessValidationGateReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.constrainedDebugContextCount, 1);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        debugBridgeReadinessValidationGateReportExitUsage,
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
        'allowed fields: productLabel',
        'allowed fields: finalMoveLabel',
        'allowed fields: numericMoveScore',
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
        'tool/debug_bridge_readiness_validation_gate_report.dart',
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

DebugBridgeReadinessValidationGateReportCommandResult _run({
  List<String> args = const <String>[],
  DebugBridgeReadinessValidationGateRequest? request,
}) {
  return runDebugBridgeReadinessValidationGateReportCommand(
    args: args,
    request: request,
  );
}
