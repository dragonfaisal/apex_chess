@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_bridge_readiness_validation_gate.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_prototype_design_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_prototype_design_validation_report.dart';

void main() {
  group('Debug-Only Bridge Prototype Design Validation report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_bridge_prototype_design_validation_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        debugOnlyBridgePrototypeDesignValidationReportExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgePrototypeDesignValidationReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Debug-Only Bridge Prototype Design Validation'),
      );
      expect(result.stdoutText, contains('## Validation Check Table'));
      expect(result.stdoutText, contains('## Design Section Validation Table'));
      expect(result.stdoutText, contains('## Design Record Validation Table'));
      expect(
        result.stdoutText,
        contains('## Prototype Core Design Validation'),
      );
      expect(
        result.stdoutText,
        contains('## Stockfish Raw UCI PV Dump Denied Validation'),
      );
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase33B, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        debugOnlyBridgePrototypeDesignValidationReportExitSuccess,
      );
      expect(
        result.format,
        DebugOnlyBridgePrototypeDesignValidationReportFormat.json,
      );
      expect(
        decoded['version'],
        debugOnlyBridgePrototypeDesignValidationReportVersion,
      );
      expect(decoded['totalChecks'], 17);
      expect(decoded['passedCheckCount'], 13);
      expect(decoded['warningCheckCount'], 4);
      expect(decoded['totalSectionRows'], 10);
      expect(decoded['totalRecordRows'], 10);
      expect(decoded['validPrototypeCoreDesignCount'], 1);
      expect(decoded['validStockfishRawUciPvDumpDeniedCount'], 1);
      expect(decoded['validFutureValidationRequirementCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase33B'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugOnlyBridgePrototypeDesignValidationReportExitSuccess,
      );
      expect(result.result!.safeForPhase33B, isTrue);
      expect(result.result!.unsafeRecordCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.blockerCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeDesign = _cachedSafeDesign.copyWith(
        designStatus:
            DebugOnlyBridgePrototypeDesignStatus.blockedByPolicyBoundary,
        unsafeCount: 1,
        safeForPhase33A: false,
      );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugOnlyBridgePrototypeDesignValidationRequest(
          designResult: unsafeDesign,
          gateResult: _cachedSafeGate,
        ),
      );

      expect(
        result.exitCode,
        debugOnlyBridgePrototypeDesignValidationReportExitUnsafePolicy,
      );
      expect(
        result
            .result!
            .hasUnsafeDebugOnlyBridgePrototypeDesignValidationPolicyViolation,
        isTrue,
      );
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        debugOnlyBridgePrototypeDesignValidationReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.validPrototypeContextDesignCount, 1);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        debugOnlyBridgePrototypeDesignValidationReportExitUsage,
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
        'tool/debug_only_bridge_prototype_design_validation_report.dart',
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

DebugOnlyBridgePrototypeDesignValidationReportCommandResult _run({
  List<String> args = const <String>[],
  DebugOnlyBridgePrototypeDesignValidationRequest? request,
}) {
  return runDebugOnlyBridgePrototypeDesignValidationReportCommand(
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

final DebugOnlyBridgePrototypeDesignValidationRequest _cachedSafeRequest =
    DebugOnlyBridgePrototypeDesignValidationRequest(
      designResult: _cachedSafeDesign,
      gateResult: _cachedSafeGate,
    );
