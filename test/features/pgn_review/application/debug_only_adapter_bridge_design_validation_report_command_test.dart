@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_adapter_bridge_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_adapter_bridge_design_validation_report.dart';

void main() {
  group('Debug-Only Adapter Bridge Design Validation report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_adapter_bridge_design_validation_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        debugOnlyAdapterBridgeDesignValidationReportExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyAdapterBridgeDesignValidationReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Debug-Only Adapter Bridge Design Validation'),
      );
      expect(result.stdoutText, contains('## Validation Check Table'));
      expect(result.stdoutText, contains('## Bridge Group Validation Table'));
      expect(result.stdoutText, contains('## Bridge Record Validation Table'));
      expect(result.stdoutText, contains('## Debug Core Validation'));
      expect(result.stdoutText, contains('## Blocked Bridge Field Validation'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32V, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        debugOnlyAdapterBridgeDesignValidationReportExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyAdapterBridgeDesignValidationReportFormat.json,
      );
      expect(
        decoded['version'],
        debugOnlyAdapterBridgeDesignValidationReportVersion,
      );
      expect(decoded['totalChecks'], 15);
      expect(decoded['totalGroupRows'], 8);
      expect(decoded['totalRecordRows'], 8);
      expect(decoded['validDebugCoreInputCount'], 1);
      expect(decoded['validDebugContextInputCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32V'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugOnlyAdapterBridgeDesignValidationReportExitSuccess,
      );
      expect(result.result!.safeForPhase32V, isTrue);
      expect(result.result!.unsafeRecordCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeDesign = const DebugOnlyAdapterBridgeDesign()
          .evaluate()
          .copyWith(
            designStatus: DebugOnlyAdapterBridgeDesignStatus
                .blockedBySummaryValidationFailure,
            unsafeCount: 1,
            safeForPhase32U: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugOnlyAdapterBridgeDesignValidationRequest(
          designResult: unsafeDesign,
        ),
      );

      expect(
        result.exitCode,
        debugOnlyAdapterBridgeDesignValidationReportExitUnsafePolicy,
      );
      expect(
        result.result!.hasUnsafeDebugBridgeDesignValidationPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        debugOnlyAdapterBridgeDesignValidationReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.warningCheckCount, 3);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        debugOnlyAdapterBridgeDesignValidationReportExitUsage,
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
        'tool/debug_only_adapter_bridge_design_validation_report.dart',
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

DebugOnlyAdapterBridgeDesignValidationReportCommandResult _run({
  List<String> args = const <String>[],
  DebugOnlyAdapterBridgeDesignValidationRequest? request,
}) {
  return runDebugOnlyAdapterBridgeDesignValidationReportCommand(
    args: args,
    request: request,
  );
}
