@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness.dart';
import 'package:apex_chess/features/pgn_review/application/debug_only_bridge_developer_inspection_harness_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/debug_only_bridge_developer_diagnostic_command.dart';

void main() {
  group('Debug-Only Bridge Developer Diagnostic command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/debug_only_bridge_developer_diagnostic_command.dart',
        ).existsSync(),
        isTrue,
      );
    });

    test(
      'default markdown command succeeds and includes diagnostic sections',
      () {
        final result = _run();

        expect(
          result.exitCode,
          debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess,
        );
        expect(
          result.format,
          DebugOnlyBridgeDeveloperDiagnosticFormat.markdown,
        );
        expect(result.section, DebugOnlyBridgeDeveloperDiagnosticSection.all);
        expect(result.safeDemo, isTrue);
        expect(
          result.stdoutText,
          contains('# Debug-Only Bridge Developer Diagnostic'),
        );
        expect(result.stdoutText, contains('## Source Phase Chain'));
        expect(result.stdoutText, contains('## Inspection Snapshot Summary'));
        expect(result.stdoutText, contains('## Input/Output Packet Summary'));
        expect(result.stdoutText, contains('## Policy Summary'));
        expect(result.stdoutText, contains('## Record Role Summary'));
        expect(result.stdoutText, contains('## Boundary Summary'));
        expect(result.stdoutText, contains('## Android Proof Boundary'));
        expect(
          result.stdoutText,
          contains('## Runtime/Prototype/Wiring Blocked Summary'),
        );
        expect(result.stdoutText, contains('## Recommendation'));
        expect(
          result.stdoutText,
          contains('proceedToSelectedGoldenBridgeDiagnosticRun'),
        );
        expect(result.stderrText, isEmpty);
        expect(result.result!.safeForPhase33J, isTrue);
      },
    );

    test('JSON command succeeds and is parseable', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess,
      );
      expect(result.format, DebugOnlyBridgeDeveloperDiagnosticFormat.json);
      expect(
        decoded['version'],
        debugOnlyBridgeDeveloperDiagnosticCommandVersion,
      );
      expect(
        decoded['diagnosticStatus'],
        'inspectionHarnessValidatedWithWarnings',
      );
      expect(decoded['section'], 'all');
      expect(decoded['safeForNextStep'], isTrue);
      expect(
        decoded['recommendation'],
        'proceedToSelectedGoldenBridgeDiagnosticRun',
      );
      expect(decoded['sourcePhaseChain'], isA<Map<String, Object?>>());
      expect(decoded['snapshot'], isA<Map<String, Object?>>());
      expect(decoded['packets'], isA<Map<String, Object?>>());
      expect(decoded['policy'], isA<Map<String, Object?>>());
      expect(decoded['records'], isA<Map<String, Object?>>());
      expect(decoded['boundaries'], isA<Map<String, Object?>>());
      expect(decoded['proof'], isA<Map<String, Object?>>());
      expect(decoded['runtime'], isA<Map<String, Object?>>());
      expect(decoded['next'], isA<Map<String, Object?>>());
    });

    test('strict mode succeeds for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess,
      );
      expect(result.strict, isTrue);
      expect(result.result!.blockerCount, 0);
      expect(result.result!.criticalCount, 0);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.runtimeEnabledCount, 0);
      expect(result.result!.safeForPhase33J, isTrue);
    });

    test('each section mode succeeds', () {
      for (final section in DebugOnlyBridgeDeveloperDiagnosticSection.values) {
        final result = _run(args: <String>['--section=${section.wire}']);

        expect(
          result.exitCode,
          debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess,
          reason: section.wire,
        );
        expect(result.section, section);
        expect(
          result.stdoutText,
          contains('selected section: ${section.wire}'),
        );
      }
    });

    test('section outputs include their expected summaries', () {
      expect(
        _run(args: const <String>['--section=snapshot']).stdoutText,
        contains('## Inspection Snapshot Summary'),
      );
      expect(
        _run(args: const <String>['--section=packets']).stdoutText,
        contains('## Input/Output Packet Summary'),
      );
      expect(
        _run(args: const <String>['--section=policy']).stdoutText,
        contains('## Policy Summary'),
      );
      expect(
        _run(args: const <String>['--section=records']).stdoutText,
        contains('## Inspection Record Rows'),
      );
      expect(
        _run(args: const <String>['--section=boundaries']).stdoutText,
        contains('scheduler execution denied: true'),
      );
      expect(
        _run(args: const <String>['--section=proof']).stdoutText,
        contains('owner proof queue count: 0'),
      );
      expect(
        _run(args: const <String>['--section=runtime']).stdoutText,
        contains('runtime enabled count: 0'),
      );
      expect(
        _run(args: const <String>['--section=recommendation']).stdoutText,
        contains('proceedToSelectedGoldenBridgeDiagnosticRun'),
      );
    });

    test('invalid section fails with usage error', () {
      final result = _run(args: const <String>['--section=unknown']);

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperDiagnosticCommandExitUsage,
      );
      expect(result.stderrText, contains('unknownSection'));
      expect(result.commandFailure, 'unknownSection');
    });

    test('strict mode fails on unsafe validation seam', () {
      final unsafeHarness = const DebugOnlyBridgeDeveloperInspectionHarness()
          .inspectSafeDemo()
          .copyWith(
            status: DebugOnlyBridgeDeveloperInspectionHarnessStatus
                .blockedByPolicyBoundary,
            unsafeCount: 1,
            safeForPhase33I: false,
            productOutputActive: true,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest(
          inspectionHarnessResult: unsafeHarness,
        ),
      );

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperDiagnosticCommandExitUnsafePolicy,
      );
      expect(
        result
            .result!
            .hasUnsafeDebugOnlyBridgeDeveloperInspectionHarnessValidationPolicyViolation,
        isTrue,
      );
    });

    test('output keeps active-output and secret guardrails', () {
      final report = _run().stdoutText;

      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        'pv e2e4',
        'pvMoves',
        'position fen',
        'go depth',
        'active fields: productLabel',
        'active fields: finalMoveLabel',
        'active fields: numericMoveScore',
        'allowed fields: productLabel',
        'allowed fields: schedulerExecution',
        'numeric move score:',
        'scoreValue',
        'moveScore',
        'rankedMoves',
        'moveRanking active',
        'ACPL active',
        'official accuracy active',
        'cpLoss active',
        'winProbability active',
        'http://',
        'https://',
        'apiKey',
        'secret=',
        'token=',
        'runtime implemented: true',
        'executable bridge skeleton implemented: true',
        'executable debug bridge prototype implemented: true',
        'implementation wiring implemented: true',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('source imports remain developer-only and integration-free', () {
      final source = File(
        'tool/debug_only_bridge_developer_diagnostic_command.dart',
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
      expect(imports, isNot(contains('scheduler')));
    });
  });
}

DebugOnlyBridgeDeveloperDiagnosticCommandResult _run({
  List<String> args = const <String>[],
  DebugOnlyBridgeDeveloperInspectionHarnessValidationRequest? request,
}) {
  return runDebugOnlyBridgeDeveloperDiagnosticCommand(
    args: args,
    request: request,
  );
}
