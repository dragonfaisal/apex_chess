import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_matrix.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewBuildConfigReport', () {
    test('builds from the default matrix', () {
      final scenarios = onlineReviewBuildConfigScenarios();
      final report = buildOnlineReviewBuildConfigReport();

      expect(report.version, onlineReviewBuildConfigReportVersion);
      expect(report.totalScenarios, scenarios.length);
      expect(report.scenarioSummaries, hasLength(scenarios.length));
      expect(report.items, isNotEmpty);
    });

    test('current matrix passes with a hard safety verdict', () {
      final report = buildOnlineReviewBuildConfigReport();

      expect(report.allPassed, isTrue);
      expect(report.hardSafetyPassed, isTrue);
      expect(report.failedScenarios, 0);
      expect(report.passedScenarios, report.totalScenarios);
    });

    test('counts match matrix verification output', () {
      final scenarios = onlineReviewBuildConfigScenarios();
      final results = verifyOnlineReviewBuildConfigMatrix();
      final report = buildOnlineReviewBuildConfigReport();

      expect(report.totalScenarios, scenarios.length);
      expect(
        report.dangerousScenarios,
        scenarios.where((scenario) => scenario.isDangerous).length,
      );
      expect(
        report.productionSafeScenarios,
        scenarios.where((scenario) => scenario.isProductionSafe).length,
      );
      expect(
        report.shellVisibleScenarios,
        results.where((result) => result.decision.canShowShell).length,
      );
      expect(
        report.httpEnabledScenarios,
        results.where((result) => result.decision.canUseHttp).length,
      );
      expect(
        report.publicPolicyScenarios,
        results.where((result) => result.decision.isPublic).length,
      );
      expect(report.publicPolicyScenarios, 1);
    });

    test('HTTP count matches repository HTTP summaries', () {
      final report = buildOnlineReviewBuildConfigReport();
      final httpSummaries = report.scenarioSummaries.where(
        (summary) => summary.repositoryMode == OnlineReviewRepositoryMode.http,
      );

      expect(report.httpEnabledScenarios, httpSummaries.length);
      for (final summary in httpSummaries) {
        expect(summary.canUseHttp, isTrue, reason: summary.scenarioId);
      }
    });

    test('dangerous count matches intentionally flagged scenarios', () {
      final report = buildOnlineReviewBuildConfigReport();

      expect(report.dangerousScenarios, 1);
      expect(
        report.scenarioSummaries
            .where((summary) => summary.dangerous)
            .map((summary) => summary.scenarioId),
        contains('publicPreviewInsecureHttpRejected'),
      );
    });

    test('warnings and info items are grouped by scenario', () {
      final report = buildOnlineReviewBuildConfigReport();
      final warnings = report.items.where(
        (item) =>
            item.severity == OnlineReviewBuildConfigReportSeverity.warning,
      );
      final info = report.items.where(
        (item) => item.severity == OnlineReviewBuildConfigReportSeverity.info,
      );
      final errors = report.items.where(
        (item) => item.severity == OnlineReviewBuildConfigReportSeverity.error,
      );

      expect(errors, isEmpty);
      expect(
        warnings.map((item) => item.scenarioId),
        contains('stagingHttpAllowedOnlyWithInsecureDevFlag'),
      );
      expect(
        warnings.map((item) => item.message),
        contains('onlineReviewInsecureHttpDevOnly'),
      );
      expect(info, hasLength(1));
      expect(info.single.scenarioId, 'publicPreviewFullyExplicitPolicyShape');
    });

    test('markdown render is deterministic and contains all scenario IDs', () {
      final report = buildOnlineReviewBuildConfigReport();
      final first = renderOnlineReviewBuildConfigReportMarkdown(report);
      final second = renderOnlineReviewBuildConfigReportMarkdown(report);

      expect(first, second);
      expect(
        first,
        contains('# Online Review Build Configuration Smoke Report'),
      );
      expect(first, contains('## Scenario Summary'));
      expect(first, contains('## Warnings'));
      expect(first, contains('## Failures'));
      expect(first, contains('## Safety Notes'));
      for (final scenario in onlineReviewBuildConfigScenarios()) {
        expect(first, contains(scenario.id));
      }
    });

    test('markdown contains no local or real production endpoints', () {
      const forbiddenHost =
          'local'
          'host';
      final markdown = renderOnlineReviewBuildConfigReportMarkdown(
        buildOnlineReviewBuildConfigReport(),
      ).toLowerCase();

      expect(markdown, isNot(contains(forbiddenHost)));
      expect(markdown, isNot(contains('127.0.0.1')));
      expect(markdown, isNot(contains('api.apex')));
      expect(markdown, isNot(contains('apex-chess')));
      expect(markdown, isNot(contains('apexchess')));
      expect(markdown, isNot(contains('apex_online_review_api_key')));
      expect(markdown, isNot(contains('secret')));
    });

    test('injected failing scenario reports failures without throwing', () {
      final report = buildOnlineReviewBuildConfigReport(
        scenarios: [
          OnlineReviewBuildConfigScenario(
            id: 'injectedFailure',
            description: 'Intentionally wrong expectations for report testing.',
            rawValues: const {},
            expectedMode: OnlineReviewRuntimeMode.staging,
            expectedCanShowShell: true,
            expectedCanUseHttp: true,
            expectedCanUseDebugHarness: true,
            expectedIsPublic: true,
            expectedHasBaseUri: true,
            expectedRepositoryMode: OnlineReviewRepositoryMode.http,
            isProductionSafe: false,
            isDangerous: true,
          ),
        ],
      );

      expect(report.allPassed, isFalse);
      expect(report.hardSafetyPassed, isFalse);
      expect(report.failedScenarios, 1);
      expect(
        report.items.where(
          (item) =>
              item.severity == OnlineReviewBuildConfigReportSeverity.error,
        ),
        isNotEmpty,
      );
      expect(
        renderOnlineReviewBuildConfigReportMarkdown(report),
        contains('injectedFailure: injectedFailure: expected mode='),
      );
    });
  });

  group('OnlineReviewBuildConfigReport guardrails', () {
    test('report builder does not instantiate HTTP clients', () {
      final source = _reportSource();

      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
      expect(source, isNot(contains('HttpOnlineReviewProductRepository')));
      expect(buildOnlineReviewBuildConfigReport().totalScenarios, isPositive);
    });

    test('report source stays pure and boundary-safe', () {
      const forbiddenHost =
          'local'
          'host';
      final source = _reportSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('review_draft')));
      expect(source, isNot(contains('governance')));
      expect(source, isNot(contains('reanalysis')));
      expect(source, isNot(contains(forbiddenHost)));
      expect(source, isNot(contains('127.0.0.1')));
      expect(source, isNot(contains('api.apex')));
      expect(source, isNot(contains('APEX_ONLINE_REVIEW_API_KEY')));
      expect(source.toLowerCase(), isNot(contains('secret')));
    });
  });
}

String _reportSource() {
  return File(
    'lib/features/pgn_review/infrastructure/'
    'online_review_build_config_report.dart',
  ).readAsStringSync();
}
