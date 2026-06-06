@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/refreshed_internal_packet_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/refreshed_internal_packet_hardening_plan_report.dart';

void main() {
  group('Refreshed Internal Packet Hardening Plan report command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/refreshed_internal_packet_hardening_plan_report.dart',
        ).existsSync(),
        true,
      );
    });

    test('markdown works for safe demo', () {
      final result = _run();

      expect(
        result.exitCode,
        refreshedInternalPacketHardeningPlanReportExitSuccess,
      );
      expect(
        result.format,
        RefreshedInternalPacketHardeningPlanReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Refreshed Internal Packet Hardening Plan'),
      );
      expect(result.stdoutText, contains('## Refreshed Target Table'));
      expect(result.stdoutText, contains('## Improved Targets'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
      expect(result.result!.safeForPhase32H, isTrue);
    });

    test('JSON works for safe demo', () {
      final result = _run(args: const <String>['--format=json']);
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        refreshedInternalPacketHardeningPlanReportExitSuccess,
      );
      expect(
        result.format,
        RefreshedInternalPacketHardeningPlanReportFormat.json,
      );
      expect(
        decoded['version'],
        refreshedInternalPacketHardeningPlanReportVersion,
      );
      expect(decoded['totalTargets'], 20);
      expect(decoded['improvedTargetCount'], 8);
      expect(decoded['stillWarningLimitedCount'], 4);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32H'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = _run(args: const <String>['--strict']);

      expect(
        result.exitCode,
        refreshedInternalPacketHardeningPlanReportExitSuccess,
      );
      expect(result.result!.safeForPhase32H, isTrue);
      expect(result.result!.unsafeCount, 0);
      expect(result.result!.criticalCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafeImpact = const TargetedGoldenCoverageImpactReview()
          .evaluate()
          .copyWith(
            impactStatus:
                TargetedGoldenCoverageImpactStatus.blockedByUnsafeCase,
            unsafeCaseCount: 1,
            safeForPhase32G: false,
          );
      final result = _run(
        args: const <String>['--strict'],
        request: RefreshedInternalPacketHardeningPlanRequest(
          impactReviewResult: unsafeImpact,
        ),
      );

      expect(
        result.exitCode,
        refreshedInternalPacketHardeningPlanReportExitUnsafePolicy,
      );
      expect(result.result!.hasUnsafeRefreshPolicyViolation, isTrue);
    });

    test('safe-demo and include-warnings flags are accepted', () {
      final result = _run(
        args: const <String>['--safe-demo', '--include-warnings'],
      );

      expect(
        result.exitCode,
        refreshedInternalPacketHardeningPlanReportExitSuccess,
      );
      expect(result.safeDemo, isTrue);
      expect(result.includeWarnings, isTrue);
      expect(result.result!.stillWarningLimitedCount, 4);
    });

    test('usage errors return usage exit code', () {
      final result = _run(args: const <String>['--format=xml']);

      expect(
        result.exitCode,
        refreshedInternalPacketHardeningPlanReportExitUsage,
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
        'tool/refreshed_internal_packet_hardening_plan_report.dart',
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

RefreshedInternalPacketHardeningPlanReportCommandResult _run({
  List<String> args = const <String>[],
  RefreshedInternalPacketHardeningPlanRequest? request,
}) {
  return runRefreshedInternalPacketHardeningPlanReportCommand(
    args: args,
    request: request,
  );
}
