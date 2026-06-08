@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_prototype_design_report.dart';

void main() {
  group('Debug-Only Bridge Prototype Design report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_bridge_prototype_design_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(result.exitCode, debugOnlyBridgePrototypeDesignReportExitSuccess);
      expect(
        result.format,
        DebugOnlyBridgePrototypeDesignReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Debug-Only Bridge Prototype Design'),
      );
      expect(result.stdoutText, contains('## Design Section Table'));
      expect(result.stdoutText, contains('## Design Record Table'));
      expect(result.stdoutText, contains('## Prototype Core Input Design'));
      expect(
        result.stdoutText,
        contains('## Future Phase 33A Validation Requirement'),
      );
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase33A, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(result.exitCode, debugOnlyBridgePrototypeDesignReportExitSuccess);
      expect(result.format, DebugOnlyBridgePrototypeDesignReportFormat.json);
      expect(decoded['version'], debugOnlyBridgePrototypeDesignReportVersion);
      expect(decoded['totalDesignSections'], 10);
      expect(decoded['totalDesignRecords'], 10);
      expect(decoded['prototypeCoreDesignCount'], 1);
      expect(decoded['prototypeContextDesignCount'], 1);
      expect(decoded['allowedFieldDesignCount'], 14);
      expect(decoded['deniedFieldDesignCount'], 18);
      expect(decoded['stockfishRawUciPvDumpDeniedCount'], 3);
      expect(decoded['futureValidationRequirementCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase33A'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(result.exitCode, debugOnlyBridgePrototypeDesignReportExitSuccess);
      expect(result.result!.safeForPhase33A, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeGate = _cachedSafeGate.copyWith(
        gateStatus:
            DebugBridgeReadinessValidationGateStatus.blockedByPolicyBoundary,
        unsafeCount: 1,
        safeForPhase32Z: false,
      );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugOnlyBridgePrototypeDesignRequest(gateResult: unsafeGate),
      );

      expect(
        result.exitCode,
        debugOnlyBridgePrototypeDesignReportExitUnsafePolicy,
      );
      expect(
        result.result!.hasUnsafeDebugOnlyBridgePrototypeDesignPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(result.exitCode, debugOnlyBridgePrototypeDesignReportExitSuccess);
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.prototypeContextDesignCount, 1);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(result.exitCode, debugOnlyBridgePrototypeDesignReportExitUsage);
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
        'tool/debug_only_bridge_prototype_design_report.dart',
      ).readAsStringSync();
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .join('\n');

      for (final forbidden in const <String>[
        'stockfish',
        'ffi',
        'native',
        'local_eval_service',
        'process.start',
        'process.run',
        'flutter/widgets',
        'flutter/material',
        'backend',
        'preflight',
        'server',
        'cache',
        'database',
        'persistence',
      ]) {
        expect(imports.toLowerCase(), isNot(contains(forbidden)));
      }
      expect(source, isNot(contains('Process.start')));
      expect(source, isNot(contains('Process.run')));
    });
  });
}

DebugOnlyBridgePrototypeDesignReportCommandResult _run({
  List<String> args = const <String>[],
  DebugOnlyBridgePrototypeDesignRequest? request,
}) {
  return runDebugOnlyBridgePrototypeDesignReportCommand(
    args: args,
    request: request ?? _cachedSafeRequest,
  );
}

final DebugBridgeReadinessValidationGateResult _cachedSafeGate =
    const DebugBridgeReadinessValidationGate().evaluate(
      const DebugBridgeReadinessValidationGateRequest.safeDemo(),
    );

final DebugOnlyBridgePrototypeDesignRequest _cachedSafeRequest =
    DebugOnlyBridgePrototypeDesignRequest(gateResult: _cachedSafeGate);
