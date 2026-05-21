import 'dart:io';

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_config_scenarios.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_readiness_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewStagingConfigScenarios', () {
    test('scenario list contains all required IDs', () {
      final ids = onlineReviewStagingConfigScenarios()
          .map((scenario) => scenario.id)
          .toSet();

      expect(
        ids,
        contains(OnlineReviewStagingConfigScenarioId.defaultDisabled),
      );
      expect(
        ids,
        contains(OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady),
      );
      expect(
        ids,
        contains(
          OnlineReviewStagingConfigScenarioId.internalTesterPlaceholderReady,
        ),
      );
      expect(
        ids,
        contains(OnlineReviewStagingConfigScenarioId.stagingMissingBaseUri),
      );
      expect(
        ids,
        contains(OnlineReviewStagingConfigScenarioId.stagingHttpNotAllowed),
      );
      expect(
        ids,
        contains(OnlineReviewStagingConfigScenarioId.stagingLoopbackBlocked),
      );
      expect(
        ids,
        contains(OnlineReviewStagingConfigScenarioId.publicPreviewBlocked),
      );
    });

    test('scenario IDs are unique', () {
      final ids = onlineReviewStagingConfigScenarios()
          .map((scenario) => scenario.id)
          .toList();

      expect(ids.toSet(), hasLength(ids.length));
    });

    test('every scenario matches its expected readiness contract', () {
      for (final scenario in onlineReviewStagingConfigScenarios()) {
        final report = buildOnlineReviewStagingReadinessReportForScenario(
          scenario,
        );
        final readiness = report.readiness;

        expect(readiness.status, scenario.expectedReadinessStatus);
        expect(readiness.isStagingReady, scenario.expectedStagingReady);
        expect(
          readiness.isInternalTesterReady,
          scenario.expectedInternalTesterReady,
        );
        expect(
          onlineReviewStagingReadinessReportExitCode(report),
          scenario.expectedExitCode,
        );
        expect(readiness.blockers, unorderedEquals(scenario.expectedBlockers));
        expect(readiness.warnings, unorderedEquals(scenario.expectedWarnings));
      }
    });

    test('defaultDisabled scenario builds report and exits 0', () {
      final scenario = scenarioById(
        OnlineReviewStagingConfigScenarioId.defaultDisabled,
      );
      final report = buildOnlineReviewStagingReadinessReportForScenario(
        scenario,
      );

      expect(
        report.readiness.status,
        OnlineReviewStagingReadinessStatus.disabled,
      );
      expect(report.isStagingReady, isFalse);
      expect(onlineReviewStagingReadinessReportExitCode(report), 0);
    });

    test('stagingPlaceholderReady becomes staging ready', () {
      final scenario = scenarioById(
        OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady,
      );
      final report = buildOnlineReviewStagingReadinessReportForScenario(
        scenario,
      );
      final markdown = _renderScenario(scenario, report);

      expect(
        report.readiness.status,
        OnlineReviewStagingReadinessStatus.readyForStagingSmoke,
      );
      expect(report.isStagingReady, isTrue);
      expect(report.isInternalTesterReady, isFalse);
      expect(onlineReviewStagingReadinessReportExitCode(report), 0);
      expect(markdown, contains('* Scenario ID: `stagingPlaceholderReady`'));
      expect(markdown, contains('* Staging ready: yes'));
      expect(markdown, contains('scheme=https;host=staging-api.example.test'));
      expect(markdown, isNot(contains('https://staging-api.example.test')));
    });

    test('internalTesterPlaceholderReady becomes internal tester ready', () {
      final scenario = scenarioById(
        OnlineReviewStagingConfigScenarioId.internalTesterPlaceholderReady,
      );
      final report = buildOnlineReviewStagingReadinessReportForScenario(
        scenario,
      );
      final markdown = _renderScenario(scenario, report);

      expect(
        report.readiness.status,
        OnlineReviewStagingReadinessStatus.readyForInternalTesterSmoke,
      );
      expect(report.isStagingReady, isFalse);
      expect(report.isInternalTesterReady, isTrue);
      expect(onlineReviewStagingReadinessReportExitCode(report), 0);
      expect(markdown, contains('* Internal tester ready: yes'));
      expect(markdown, contains('scheme=https;host=internal-api.example.test'));
      expect(markdown, isNot(contains('https://internal-api.example.test')));
    });

    test('stagingMissingBaseUri is not configured with missingBaseUri', () {
      final scenario = scenarioById(
        OnlineReviewStagingConfigScenarioId.stagingMissingBaseUri,
      );
      final report = buildOnlineReviewStagingReadinessReportForScenario(
        scenario,
      );

      expect(
        report.readiness.status,
        OnlineReviewStagingReadinessStatus.notConfigured,
      );
      expect(
        report.readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.missingBaseUri),
      );
      expect(onlineReviewStagingReadinessReportExitCode(report), 0);
    });

    test('stagingHttpNotAllowed is not ready with httpNotAllowed', () {
      final scenario = scenarioById(
        OnlineReviewStagingConfigScenarioId.stagingHttpNotAllowed,
      );
      final report = buildOnlineReviewStagingReadinessReportForScenario(
        scenario,
      );

      expect(report.isReady, isFalse);
      expect(
        report.readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.httpNotAllowed),
      );
      expect(onlineReviewStagingReadinessReportExitCode(report), 0);
    });

    test(
      'stagingLoopbackBlocked is blocked and never prints loopback host',
      () {
        const loopbackIp =
            '127.0.'
            '0.1';
        const emulatorHost =
            '10.0.'
            '2.2';
        final scenario = scenarioById(
          OnlineReviewStagingConfigScenarioId.stagingLoopbackBlocked,
        );
        final report = buildOnlineReviewStagingReadinessReportForScenario(
          scenario,
        );
        final markdown = _renderScenario(scenario, report);

        expect(
          report.readiness.status,
          OnlineReviewStagingReadinessStatus.blocked,
        );
        expect(
          report.readiness.blockers,
          contains(OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed),
        );
        expect(
          report.readiness.blockers,
          contains(OnlineReviewStagingReadinessBlocker.unsafeBaseUri),
        );
        expect(onlineReviewStagingReadinessReportExitCode(report), 1);
        expect(markdown, contains('blocked-loopback-host'));
        expect(markdown, isNot(contains(loopbackIp)));
        expect(markdown, isNot(contains(emulatorHost)));
      },
    );

    test('publicPreviewBlocked is not staging ready', () {
      final scenario = scenarioById(
        OnlineReviewStagingConfigScenarioId.publicPreviewBlocked,
      );
      final report = buildOnlineReviewStagingReadinessReportForScenario(
        scenario,
      );

      expect(
        report.readiness.status,
        OnlineReviewStagingReadinessStatus.publicPreviewNotAllowed,
      );
      expect(report.isReady, isFalse);
      expect(report.isStagingReady, isFalse);
      expect(
        report.readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.publicPreviewMode),
      );
      expect(onlineReviewStagingReadinessReportExitCode(report), 0);
    });

    test('scenario lookup rejects unknown scenario names safely', () {
      expect(
        onlineReviewStagingConfigScenarioIdByName('stagingPlaceholderReady'),
        OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady,
      );
      expect(onlineReviewStagingConfigScenarioIdByName('unknown'), isNull);
    });
  });

  group('OnlineReviewStagingConfigScenarios output guardrails', () {
    test('all scenario reports contain no full URLs or local endpoints', () {
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

      for (final scenario in onlineReviewStagingConfigScenarios()) {
        final report = buildOnlineReviewStagingReadinessReportForScenario(
          scenario,
        );
        final markdown = _renderScenario(scenario, report).toLowerCase();

        expect(markdown, isNot(contains('https://')));
        expect(markdown, isNot(contains('http://')));
        expect(markdown, isNot(contains(loopbackHost)));
        expect(markdown, isNot(contains(loopbackIp)));
        expect(markdown, isNot(contains(emulatorHost)));
        expect(markdown, isNot(contains(wildcardHost)));
      }
    });

    test('all scenario reports contain no private markers', () {
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

      for (final scenario in onlineReviewStagingConfigScenarios()) {
        final report = buildOnlineReviewStagingReadinessReportForScenario(
          scenario,
        );
        final markdown = _renderScenario(scenario, report).toLowerCase();

        expect(markdown, isNot(contains(apiKeyHint)));
        expect(markdown, isNot(contains(privateValueToken)));
        expect(markdown, isNot(contains(privateTokenHint)));
        expect(markdown, isNot(contains(productionHostHint)));
      }
    });

    test('placeholder reports show fingerprints without URI path or query', () {
      final scenarios = [
        scenarioById(
          OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady,
        ),
        scenarioById(
          OnlineReviewStagingConfigScenarioId.internalTesterPlaceholderReady,
        ),
      ];

      for (final scenario in scenarios) {
        final report = buildOnlineReviewStagingReadinessReportForScenario(
          scenario,
        );
        final markdown = _renderScenario(scenario, report);

        expect(markdown, contains('scheme=https;host='));
        expect(markdown, isNot(contains('/review')));
        expect(markdown, isNot(contains('?')));
        expect(markdown, isNot(contains('credential')));
      }
    });
  });

  group('OnlineReviewStagingConfigScenarios command guardrails', () {
    test('command source supports typed scenarios only', () {
      final source = _commandSource();

      expect(source, contains('--scenario='));
      expect(source, contains('onlineReviewStagingConfigScenarioIdByName'));
      expect(
        source,
        contains('buildOnlineReviewStagingReadinessReportForScenario'),
      );
      expect(source, isNot(contains('Uri.parse')));
      expect(source, isNot(contains('APEX_ONLINE_REVIEW_BASE_URI')));
      expect(source, isNot(contains('String.fromEnvironment')));
      expect(source, isNot(contains('bool.fromEnvironment')));
      expect(source, isNot(contains('ProviderContainer')));
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

    test('scenario source stays pure and placeholder-only', () {
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
      final source = _scenarioSource();

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

String _renderScenario(
  OnlineReviewStagingConfigScenario scenario,
  OnlineReviewStagingReadinessReport report,
) {
  return renderOnlineReviewStagingReadinessReportMarkdown(
    report,
    scenarioId: scenario.id.name,
    scenarioDescription: scenario.description,
  );
}

String _commandSource() {
  return File(
    'tool/online_review_staging_readiness_report.dart',
  ).readAsStringSync();
}

String _scenarioSource() {
  return File(
    'lib/features/pgn_review/infrastructure/'
    'online_review_staging_config_scenarios.dart',
  ).readAsStringSync();
}
