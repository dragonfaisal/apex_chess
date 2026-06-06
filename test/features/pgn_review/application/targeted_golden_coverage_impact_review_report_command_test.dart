@TestOn('vm')
library;

import 'dart:convert';

import 'package:apex_chess/features/pgn_review/application/internal_packet_evidence_hardening_plan.dart';
import 'package:apex_chess/features/pgn_review/application/targeted_golden_coverage_impact_review.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/targeted_golden_coverage_impact_review_report.dart';

void main() {
  group('Targeted Golden Coverage Impact Review report command', () {
    test('markdown works for safe demo', () {
      final result = runTargetedGoldenCoverageImpactReviewReportCommand(
        args: const <String>[],
      );

      expect(
        result.exitCode,
        targetedGoldenCoverageImpactReviewReportExitSuccess,
      );
      expect(
        result.format,
        TargetedGoldenCoverageImpactReviewReportFormat.markdown,
      );
      expect(
        result.stdoutText,
        contains('# Targeted Golden Coverage Impact Review'),
      );
      expect(result.stdoutText, contains('## Phase 32E New Case Impact Table'));
      expect(result.stdoutText, contains('## Hardening Target Impact Table'));
      expect(result.stdoutText, contains('owner proof queue count: 0'));
      expect(result.stderrText, isEmpty);
    });

    test('JSON works for safe demo', () {
      final result = runTargetedGoldenCoverageImpactReviewReportCommand(
        args: const <String>['--format=json'],
      );
      final decoded = jsonDecode(result.stdoutText) as Map<String, Object?>;

      expect(
        result.exitCode,
        targetedGoldenCoverageImpactReviewReportExitSuccess,
      );
      expect(
        result.format,
        TargetedGoldenCoverageImpactReviewReportFormat.json,
      );
      expect(
        decoded['version'],
        targetedGoldenCoverageImpactReviewReportVersion,
      );
      expect(decoded['totalGoldenCases'], 20);
      expect(decoded['protectedCount'], 19);
      expect(decoded['negativeGuardCount'], 1);
      expect(decoded['ownerProofQueueCount'], 0);
      expect(decoded['safeForPhase32G'], isTrue);
    });

    test('strict passes for safe demo', () {
      final result = runTargetedGoldenCoverageImpactReviewReportCommand(
        args: const <String>['--strict'],
      );

      expect(
        result.exitCode,
        targetedGoldenCoverageImpactReviewReportExitSuccess,
      );
      expect(result.result!.safeForPhase32G, isTrue);
      expect(result.result!.unsafeCaseCount, 0);
    });

    test('strict fails on unsafe seam', () {
      final unsafePlan = const InternalPacketEvidenceHardeningPlan()
          .evaluate()
          .copyWith(classifierLabelsEmitted: true);
      final result = runTargetedGoldenCoverageImpactReviewReportCommand(
        args: const <String>['--strict'],
        request: TargetedGoldenCoverageImpactReviewRequest(
          hardeningPlanResult: unsafePlan,
        ),
      );

      expect(
        result.exitCode,
        targetedGoldenCoverageImpactReviewReportExitUnsafePolicy,
      );
      expect(result.result!.hasUnsafeImpactPolicyViolation, isTrue);
    });

    test('usage errors return usage exit code', () {
      final result = runTargetedGoldenCoverageImpactReviewReportCommand(
        args: const <String>['--format=xml'],
      );

      expect(
        result.exitCode,
        targetedGoldenCoverageImpactReviewReportExitUsage,
      );
      expect(result.stderrText, contains('unknownFormat'));
    });
  });
}
