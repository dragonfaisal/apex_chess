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
          contains('proceedToSelectedGoldenBridgeDiagnosticValidation'),
        );
        expect(result.stderrText, isEmpty);
        expect(result.result!.safeForPhase33J, isTrue);
        expect(result.selectedGoldenDiagnostic, isNull);
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
        'proceedToSelectedGoldenBridgeDiagnosticValidation',
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
      expect(decoded.containsKey('selectedGoldenDiagnostic'), isFalse);
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
        contains('proceedToSelectedGoldenBridgeDiagnosticValidation'),
      );
      expect(
        _run(args: const <String>['--section=golden']).stdoutText,
        contains('## Selected Golden Diagnostic'),
      );
    });

    test('--list-golden-cases succeeds', () {
      final result = _run(args: const <String>['--list-golden-cases']);

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess,
      );
      expect(
        result.stdoutText,
        contains('# Debug-Only Bridge Golden Case Selection'),
      );
      expect(result.stdoutText, contains('default-selected'));
      expect(result.stdoutText, contains('all-safe-selected'));
      expect(result.stdoutText, contains('queen-win-major-swing'));
      expect(result.stdoutText, contains('pv-multipv-support-boundary-32e'));
      expect(result.stderrText, isEmpty);
    });

    test('selected Golden modes succeed', () {
      for (final args in const <List<String>>[
        <String>['--golden-case=default-selected'],
        <String>['--golden-case=all-safe-selected'],
        <String>['--golden-case=queen-win-major-swing'],
        <String>['--golden-case=default-selected', '--section=golden'],
      ]) {
        final result = _run(args: args);

        expect(
          result.exitCode,
          debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess,
          reason: args.join(' '),
        );
        expect(result.selectedGoldenDiagnostic, isNotNull);
        expect(result.selectedGoldenDiagnostic!.safeForNextStep, isTrue);
        expect(result.stdoutText, contains('## Selected Golden Diagnostic'));
        expect(
          result.stdoutText,
          contains('proceedToSelectedGoldenBridgeDiagnosticValidation'),
        );
      }
    });

    test('selected Golden JSON is deterministic and parseable', () {
      final result = _run(
        args: const <String>['--golden-case=default-selected', '--format=json'],
      );
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;
      final selected =
          decoded['selectedGoldenDiagnostic'] as Map<String, Object?>;
      final counts = selected['counts'] as Map<String, Object?>;
      final rows = selected['rows'] as List<Object?>;

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess,
      );
      expect(selected['selection'], 'default-selected');
      expect(selected['status'], 'selectedGoldenDiagnosticReadyWithWarnings');
      expect(selected['safeForNextStep'], isTrue);
      expect(counts['selectedRowCount'], 7);
      expect(counts['unsafeCount'], 0);
      expect(counts['activeDeniedFieldCount'], 0);
      expect(counts['engineCallCount'], 0);
      expect(counts['schedulerExecutionCount'], 0);
      expect(rows.first, isA<Map<String, Object?>>());
    });

    test('selected Golden strict mode succeeds for safe default selection', () {
      final result = _run(
        args: const <String>['--golden-case=default-selected', '--strict'],
      );

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperDiagnosticCommandExitSuccess,
      );
      expect(result.selectedGoldenDiagnostic!.blockerCount, 0);
      expect(result.selectedGoldenDiagnostic!.criticalCount, 0);
      expect(result.selectedGoldenDiagnostic!.unsafeCount, 0);
      expect(result.selectedGoldenDiagnostic!.activeDeniedFieldCount, 0);
      expect(result.selectedGoldenDiagnostic!.engineCallCount, 0);
      expect(result.selectedGoldenDiagnostic!.schedulerExecutionCount, 0);
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

    test('unknown Golden case fails with usage error', () {
      final result = _run(
        args: const <String>['--golden-case=not-a-golden-case'],
      );

      expect(
        result.exitCode,
        debugOnlyBridgeDeveloperDiagnosticCommandExitUsage,
      );
      expect(result.stderrText, contains('unknownGoldenCase'));
      expect(result.commandFailure, 'unknownGoldenCase');
    });

    test('quiet preparatory case is excluded from active core output', () {
      final result = _run(
        args: const <String>[
          '--golden-case=quiet-preparatory-hard-case',
          '--section=golden',
        ],
      );
      final row = result.selectedGoldenDiagnostic!.rows.single;

      expect(row.caseId, 'quiet-preparatory-hard-case');
      expect(
        row.diagnosticRole,
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.excludedNegativeGuard,
      );
      expect(
        row.blockedBoundaryIds,
        contains('quietPreparatoryCoreActivation'),
      );
      expect(row.activeDeniedFields, isEmpty);
      expect(
        result.selectedGoldenDiagnostic!.quietPreparatoryCoreActivationCount,
        0,
      );
    });

    test('Phase 32E selected cases do not claim captured Android proof', () {
      final result = _run(
        args: const <String>['--golden-case=default-selected'],
      );
      final phase32ERows = result.selectedGoldenDiagnostic!.rows.where(
        (row) => row.sourcePhase == 'Phase 32E',
      );

      expect(phase32ERows, isNotEmpty);
      for (final row in phase32ERows) {
        expect(row.androidProofCaseIds, isEmpty, reason: row.caseId);
        expect(
          row.proofLimitReasons,
          contains('phase32ECaseIsNotCapturedProof'),
          reason: row.caseId,
        );
      }
      expect(
        result.selectedGoldenDiagnostic!.phase32ECapturedProofClaimCount,
        0,
      );
      expect(result.selectedGoldenDiagnostic!.unprovenAndroidProofCount, 0);
    });

    test('PV MultiPV selected case remains boundary watch-list only', () {
      final result = _run(
        args: const <String>[
          '--golden-case=pv-multipv-support-boundary-32e',
          '--section=golden',
        ],
      );
      final row = result.selectedGoldenDiagnostic!.rows.single;

      expect(
        row.diagnosticRole,
        DebugOnlyBridgeSelectedGoldenDiagnosticRole.proofBoundaryOnly,
      );
      expect(row.androidProofCaseIds, isEmpty);
      expect(row.ownerProofRequired, isFalse);
      expect(row.blockedBoundaryIds, contains('pvMultiPvOwnerProofEscalation'));
      expect(
        row.proofLimitReasons,
        contains('pvMultiPvBoundaryWatchListOnlyNoOwnerProof'),
      );
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

    test('selected Golden output keeps diagnostic guardrails', () {
      final report = _run(
        args: const <String>[
          '--golden-case=default-selected',
          '--section=golden',
        ],
      ).stdoutText;

      expect(report, contains('active denied field count: 0'));
      expect(report, contains('product output count: 0'));
      expect(report, contains('engine call count: 0'));
      expect(report, contains('scheduler execution count: 0'));
      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        'pv e2e4',
        'position fen',
        'go depth',
        'active fields: productLabel',
        'active fields: finalMoveLabel',
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
