@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_prototype_design_readiness_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_bridge_prototype_design_readiness_gate_report.dart';

void main() {
  group('Debug Bridge Prototype Design Readiness Gate report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_bridge_prototype_design_readiness_gate_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessGateReportExitSuccess,
      );
      expect(
        result.format,
        DebugBridgePrototypeDesignReadinessGateReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Debug Bridge Prototype Design Readiness Gate'),
      );
      expect(result.stdoutText, contains('## Readiness Group Table'));
      expect(result.stdoutText, contains('## Readiness Record Table'));
      expect(result.stdoutText, contains('## Prototype Core Design Readiness'));
      expect(
        result.stdoutText,
        contains('## Stockfish Raw UCI PV Dump Denied Status'),
      );
      expect(
        result.stdoutText,
        contains('## Runtime/Executable Prototype Blocked Status'),
      );
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase33C, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessGateReportExitSuccess,
      );
      expect(
        result.format,
        DebugBridgePrototypeDesignReadinessGateReportFormat.json,
      );
      expect(
        decoded['version'],
        debugBridgePrototypeDesignReadinessGateReportVersion,
      );
      expect(decoded['totalGateGroups'], 11);
      expect(decoded['totalGateRecords'], 11);
      expect(decoded['readinessApprovedCoreDesignCount'], 1);
      expect(decoded['approvedAllowedFieldCount'], 14);
      expect(decoded['deniedFieldCount'], 18);
      expect(decoded['stockfishRawUciPvDumpDeniedCount'], 3);
      expect(decoded['runtimeExecutionBlockedCount'], 1);
      expect(decoded['futureRequirementCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase33C'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessGateReportExitSuccess,
      );
      expect(result.result!.safeForPhase33C, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeValidation = _cachedSafeValidation.copyWith(
        validationStatus: DebugOnlyBridgePrototypeDesignValidationStatus
            .blockedByPolicyBoundary,
        unsafeRecordCount: 1,
        safeForPhase33B: false,
      );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugBridgePrototypeDesignReadinessGateRequest(
          validationResult: unsafeValidation,
          designResult: _cachedSafeDesign,
          gateResult: _cachedSafeGate,
        ),
      );

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessGateReportExitUnsafePolicy,
      );
      expect(
        result.result!.hasUnsafePrototypeDesignReadinessGatePolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessGateReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.constrainedContextDesignCount, 1);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        debugBridgePrototypeDesignReadinessGateReportExitUsage,
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
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('command source does not execute proof or boundary integrations', () {
      final source = File(
        'tool/debug_bridge_prototype_design_readiness_gate_report.dart',
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

DebugBridgePrototypeDesignReadinessGateReportCommandResult _run({
  List<String> args = const <String>[],
  DebugBridgePrototypeDesignReadinessGateRequest? request,
}) {
  return runDebugBridgePrototypeDesignReadinessGateReportCommand(
    args: args,
    request: request ?? _cachedSafeRequest,
  );
}

final DebugBridgeReadinessValidationGateResult _cachedSafeGate =
    const DebugBridgeReadinessValidationGate().evaluate(
      const DebugBridgeReadinessValidationGateRequest.safeDemo(),
    );

final DebugOnlyBridgePrototypeDesignResult _cachedSafeDesign =
    const DebugOnlyBridgePrototypeDesign().evaluate(
      DebugOnlyBridgePrototypeDesignRequest(gateResult: _cachedSafeGate),
    );

final DebugOnlyBridgePrototypeDesignValidationResult _cachedSafeValidation =
    const DebugOnlyBridgePrototypeDesignValidation().evaluate(
      DebugOnlyBridgePrototypeDesignValidationRequest(
        designResult: _cachedSafeDesign,
        gateResult: _cachedSafeGate,
      ),
    );

final DebugBridgePrototypeDesignReadinessGateRequest _cachedSafeRequest =
    DebugBridgePrototypeDesignReadinessGateRequest(
      validationResult: _cachedSafeValidation,
      designResult: _cachedSafeDesign,
      gateResult: _cachedSafeGate,
    );
