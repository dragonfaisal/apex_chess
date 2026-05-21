import 'dart:io';

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_config_scenarios.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_scenario_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewStagingScenarioSummary', () {
    test('summary builds over all scenarios', () {
      final summary = buildOnlineReviewStagingScenarioSummary();

      expect(summary.version, onlineReviewStagingScenarioSummaryVersion);
      expect(summary.entries, isNotEmpty);
      expect(summary.evaluatedScenarios, summary.totalScenarios);
    });

    test('totalScenarios equals scenario list length', () {
      final scenarios = onlineReviewStagingConfigScenarios();
      final summary = buildOnlineReviewStagingScenarioSummary();

      expect(summary.totalScenarios, scenarios.length);
      expect(summary.evaluatedScenarios, scenarios.length);
    });

    test('every scenario has exactly one summary entry', () {
      final scenarioIds = onlineReviewStagingConfigScenarios()
          .map((scenario) => scenario.id)
          .toSet();
      final summaryIds = buildOnlineReviewStagingScenarioSummary().entries
          .map((entry) => entry.scenarioId)
          .toList();

      expect(summaryIds.toSet(), scenarioIds);
      expect(summaryIds.length, scenarioIds.length);
    });

    test('current controlled scenarios pass expectations and safety', () {
      final summary = buildOnlineReviewStagingScenarioSummary();

      expect(summary.allExpectationsPassed, isTrue);
      expect(summary.noUnsafeOutputLeaks, isTrue);
      expect(summary.hardSafetyPassed, isTrue);
      expect(summary.failedExpectationScenarios, 0);
      expect(summary.leakedUnsafeOutputScenarios, 0);
      expect(onlineReviewStagingScenarioSummaryExitCode(summary), 0);
      expect(summary.errors, isEmpty);
    });

    test('ready scenario counts are precise', () {
      final summary = buildOnlineReviewStagingScenarioSummary();

      expect(summary.stagingReadyScenarios, 1);
      expect(summary.internalTesterReadyScenarios, 1);
      expect(summary.safelyBlockedScenarios, 5);
      expect(summary.nonZeroExitScenarios, 1);
    });

    test('stagingPlaceholderReady is counted as staging-ready', () {
      final entry = _entry(
        buildOnlineReviewStagingScenarioSummary(),
        OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady,
      );

      expect(
        entry.status,
        OnlineReviewStagingReadinessStatus.readyForStagingSmoke,
      );
      expect(entry.stagingReady, isTrue);
      expect(entry.internalTesterReady, isFalse);
      expect(entry.expectationPassed, isTrue);
      expect(entry.unsafeOutputLeakDetected, isFalse);
    });

    test(
      'internalTesterPlaceholderReady is counted as internal-tester-ready',
      () {
        final entry = _entry(
          buildOnlineReviewStagingScenarioSummary(),
          OnlineReviewStagingConfigScenarioId.internalTesterPlaceholderReady,
        );

        expect(
          entry.status,
          OnlineReviewStagingReadinessStatus.readyForInternalTesterSmoke,
        );
        expect(entry.stagingReady, isFalse);
        expect(entry.internalTesterReady, isTrue);
        expect(entry.expectationPassed, isTrue);
      },
    );

    test('defaultDisabled is safely blocked and not a failure', () {
      final entry = _entry(
        buildOnlineReviewStagingScenarioSummary(),
        OnlineReviewStagingConfigScenarioId.defaultDisabled,
      );

      expect(entry.status, OnlineReviewStagingReadinessStatus.disabled);
      expect(entry.stagingReady, isFalse);
      expect(entry.internalTesterReady, isFalse);
      expect(entry.exitCode, 0);
      expect(entry.expectationPassed, isTrue);
    });

    test('publicPreviewBlocked is safely blocked and not staging-ready', () {
      final entry = _entry(
        buildOnlineReviewStagingScenarioSummary(),
        OnlineReviewStagingConfigScenarioId.publicPreviewBlocked,
      );

      expect(
        entry.status,
        OnlineReviewStagingReadinessStatus.publicPreviewNotAllowed,
      );
      expect(entry.stagingReady, isFalse);
      expect(entry.internalTesterReady, isFalse);
      expect(entry.exitCode, 0);
      expect(entry.expectationPassed, isTrue);
    });

    test('loopback scenario is blocked and does not leak loopback host', () {
      const loopbackIp =
          '127.0.'
          '0.1';
      final summary = buildOnlineReviewStagingScenarioSummary();
      final entry = _entry(
        summary,
        OnlineReviewStagingConfigScenarioId.stagingLoopbackBlocked,
      );
      final markdown = renderOnlineReviewStagingScenarioSummaryMarkdown(
        summary,
      );

      expect(entry.status, OnlineReviewStagingReadinessStatus.blocked);
      expect(entry.exitCode, 1);
      expect(entry.expectedExitCode, 1);
      expect(
        entry.blockers,
        contains(OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed),
      );
      expect(entry.expectationPassed, isTrue);
      expect(entry.unsafeOutputLeakDetected, isFalse);
      expect(markdown, isNot(contains(loopbackIp)));
    });

    test('injected failing expectation path returns non-zero', () {
      final failingScenario = OnlineReviewStagingConfigScenario(
        id: OnlineReviewStagingConfigScenarioId.defaultDisabled,
        description: 'Injected failing expectation for summary tests.',
        rawValues: const {},
        expectedReadinessStatus:
            OnlineReviewStagingReadinessStatus.readyForStagingSmoke,
        expectedStagingReady: true,
        expectedInternalTesterReady: false,
        expectedExitCode: 0,
      );
      final summary = buildOnlineReviewStagingScenarioSummary(
        scenarios: [failingScenario],
      );

      expect(summary.allExpectationsPassed, isFalse);
      expect(summary.failedExpectationScenarios, 1);
      expect(summary.errors.single, contains('defaultDisabled'));
      expect(onlineReviewStagingScenarioSummaryExitCode(summary), 1);
    });
  });

  group('OnlineReviewStagingScenarioSummary markdown', () {
    test('markdown contains heading and all scenario IDs', () {
      final summary = buildOnlineReviewStagingScenarioSummary();
      final markdown = renderOnlineReviewStagingScenarioSummaryMarkdown(
        summary,
      );

      expect(markdown, contains('# Online Review Staging Scenario Summary'));
      for (final scenario in onlineReviewStagingConfigScenarios()) {
        expect(markdown, contains(scenario.id.name));
      }
    });

    test('markdown contains no full URLs or local endpoints', () {
      const loopbackHost =
          'local'
          'host';
      const loopbackIp =
          '127.0.'
          '0.1';
      const emulatorHost =
          '10.0.'
          '2.2';
      const wildcardHost =
          '0.0.'
          '0.0';
      final markdown = renderOnlineReviewStagingScenarioSummaryMarkdown(
        buildOnlineReviewStagingScenarioSummary(),
      ).toLowerCase();

      expect(markdown, isNot(contains('https://')));
      expect(markdown, isNot(contains('http://')));
      expect(markdown, isNot(contains(loopbackHost)));
      expect(markdown, isNot(contains(loopbackIp)));
      expect(markdown, isNot(contains(emulatorHost)));
      expect(markdown, isNot(contains(wildcardHost)));
    });

    test('markdown contains no private markers', () {
      const apiKeyHint =
          'apex_online_review_'
          'api_key';
      const privateValueToken =
          'sec'
          'ret';
      const privateTokenHint =
          'private_'
          'token';
      const productionHostHint =
          'api.'
          'apex';
      final markdown = renderOnlineReviewStagingScenarioSummaryMarkdown(
        buildOnlineReviewStagingScenarioSummary(),
      ).toLowerCase();

      expect(markdown, isNot(contains(apiKeyHint)));
      expect(markdown, isNot(contains(privateValueToken)));
      expect(markdown, isNot(contains(privateTokenHint)));
      expect(markdown, isNot(contains(productionHostHint)));
    });

    test('markdown includes safety notes and no errors', () {
      final markdown = renderOnlineReviewStagingScenarioSummaryMarkdown(
        buildOnlineReviewStagingScenarioSummary(),
      );

      expect(markdown, contains('## Errors'));
      expect(markdown, contains('* None'));
      expect(markdown, contains('* Fixture-only.'));
      expect(markdown, contains('* No arbitrary URL input.'));
      expect(markdown, contains('* No backend connection.'));
    });
  });

  group('OnlineReviewStagingScenarioSummary command guardrails', () {
    test('command source supports all-scenarios and rejects combinations', () {
      final source = _commandSource();

      expect(source, contains('--all-scenarios'));
      expect(source, contains('buildOnlineReviewStagingScenarioSummary'));
      expect(
        source,
        contains('renderOnlineReviewStagingScenarioSummaryMarkdown'),
      );
      expect(source, contains('onlineReviewStagingScenarioSummaryExitCode'));
      expect(source, contains('args.length != 1'));
      expect(source, isNot(contains('Uri.parse')));
      expect(source, isNot(contains('APEX_ONLINE_REVIEW_BASE_URI')));
      expect(source, isNot(contains('String.fromEnvironment')));
      expect(source, isNot(contains('bool.fromEnvironment')));
    });

    test('command source imports no HTTP, DTO, provider, or UI boundaries', () {
      final source = _commandSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('ProviderContainer')));
      expect(source, isNot(contains('review_draft')));
      expect(source, isNot(contains('governance')));
      expect(source, isNot(contains('reanalysis')));
    });

    test('summary source stays pure and boundary-safe', () {
      const loopbackHost =
          'local'
          'host';
      const loopbackIp =
          '127.0.'
          '0.1';
      const emulatorHost =
          '10.0.'
          '2.2';
      const productionHostHint =
          'api.'
          'apex';
      const apiKeyHint =
          'apex_online_review_'
          'api_key';
      const privateValueToken =
          'sec'
          'ret';
      final source = _summarySource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('ProviderContainer')));
      expect(source, isNot(contains('review_draft')));
      expect(source, isNot(contains('governance')));
      expect(source, isNot(contains('reanalysis')));
      expect(source, isNot(contains(loopbackHost)));
      expect(source, isNot(contains(loopbackIp)));
      expect(source, isNot(contains(emulatorHost)));
      expect(source, isNot(contains(productionHostHint)));
      expect(source, isNot(contains(apiKeyHint)));
      expect(source.toLowerCase(), isNot(contains(privateValueToken)));
    });
  });
}

OnlineReviewStagingScenarioSummaryEntry _entry(
  OnlineReviewStagingScenarioSummaryResult summary,
  OnlineReviewStagingConfigScenarioId id,
) {
  return summary.entries.singleWhere((entry) => entry.scenarioId == id);
}

String _commandSource() {
  return File(
    'tool/online_review_staging_readiness_report.dart',
  ).readAsStringSync();
}

String _summarySource() {
  return File(
    'lib/features/pgn_review/infrastructure/'
    'online_review_staging_scenario_summary.dart',
  ).readAsStringSync();
}
