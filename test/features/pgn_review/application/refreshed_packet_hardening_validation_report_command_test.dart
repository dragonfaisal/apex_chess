@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/refreshed_packet_hardening_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/refreshed_packet_hardening_validation_report.dart';

void main() {
  group('Refreshed Packet Hardening Validation report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/refreshed_packet_hardening_validation_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        refreshedPacketHardeningValidationReportExitSuccess,
      );
      expect(
        result.format,
        RefreshedPacketHardeningValidationReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Refreshed Packet Hardening Validation'),
      );
      expect(result.stdoutText, contains('## Validation Check Table'));
      expect(result.stdoutText, contains('## Target Validation Summary'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32I, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        refreshedPacketHardeningValidationReportExitSuccess,
      );
      expect(
        result.format,
        RefreshedPacketHardeningValidationReportFormat.json,
      );
      expect(
        decoded['version'],
        refreshedPacketHardeningValidationReportVersion,
      );
      expect(decoded['totalChecks'], 15);
      expect(decoded['validatedTargetCount'], 20);
      expect(decoded['warningLimitedTargetCount'], 4);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32I'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        refreshedPacketHardeningValidationReportExitSuccess,
      );
      expect(result.result!.safeForPhase32I, isTrue);
      expect(result.result!.blockerCount, 0);
      expect(result.result!.criticalCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeRefresh = const RefreshedInternalPacketHardeningPlan()
          .evaluate()
          .copyWith(
            refreshedStatus:
                RefreshedInternalPacketHardeningStatus.blockedByUnsafeImpact,
            unsafeCount: 1,
            safeForPhase32H: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: RefreshedPacketHardeningValidationRequest(
          refreshedPlanResult: unsafeRefresh,
        ),
      );

      expect(
        result.exitCode,
        refreshedPacketHardeningValidationReportExitUnsafePolicy,
      );
      expect(result.result!.hasUnsafeValidationPolicyViolation, isTrue);
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        refreshedPacketHardeningValidationReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.warningLimitedTargetCount, 4);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        refreshedPacketHardeningValidationReportExitUsage,
      );
      expect(result.stderrText, contains('unknownFormat'));
      expect(result.commandFailure, 'unknownFormat');
    });

    test('command output keeps report guardrails', () {
      final report = _run().stdoutText;

      for (final token in const <String>[
        'uciok',
        'readyok',
        'info depth',
        'bestmove e2e4',
        ' pv ',
        'pvMoves',
        'Brilliant',
        'Great',
        'Miss',
        'Best',
        'Good',
        'Inaccuracy',
        'Mistake',
        'Blunder',
        'ACPL',
        'accuracy',
        'moveScore',
        'scoreValue',
        'rankedMoves',
        'moveRanking',
      ]) {
        expect(report, isNot(contains(token)), reason: token);
      }
    });

    test('command source does not execute proof or boundary integrations', () {
      final source = File(
        'tool/refreshed_packet_hardening_validation_report.dart',
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

RefreshedPacketHardeningValidationReportCommandResult _run({
  List<String> args = const <String>[],
  RefreshedPacketHardeningValidationRequest? request,
}) {
  return runRefreshedPacketHardeningValidationReportCommand(
    args: args,
    request: request,
  );
}
