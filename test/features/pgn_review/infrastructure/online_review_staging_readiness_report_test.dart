@TestOn('vm')
library;

import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_repository_config.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_readiness_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewStagingReadinessReport', () {
    test('default report builds and renders while disabled', () {
      final report = buildDefaultOnlineReviewStagingReadinessReport();
      final markdown = renderOnlineReviewStagingReadinessReportMarkdown(report);

      expect(report.version, onlineReviewStagingReadinessReportVersion);
      expect(
        report.readiness.status,
        OnlineReviewStagingReadinessStatus.disabled,
      );
      expect(report.isReady, isFalse);
      expect(report.isStagingReady, isFalse);
      expect(report.isInternalTesterReady, isFalse);
      expect(report.statusLabel, 'disabled');
      expect(report.hardSafetyPassed, isTrue);
      expect(report.allSmokeScenariosPassed, isTrue);
      expect(markdown, contains('# Online Review Staging Readiness Report'));
      expect(markdown, contains('* Readiness status: disabled'));
      expect(
        markdown,
        contains(
          '* Required next step: Keep Online Review disabled; no staging '
          'backend is configured.',
        ),
      );
    });

    test('default report exits 0 while disabled and not staging-ready', () {
      final report = buildDefaultOnlineReviewStagingReadinessReport();

      expect(report.isStagingReady, isFalse);
      expect(onlineReviewStagingReadinessReportExitCode(report), 0);
    });

    test(
      'markdown contains no full URL, local endpoint, or private marker',
      () {
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
        const productionHostHint =
            'api.'
            'apex';
        const dashedProductHost =
            'apex-'
            'chess';
        const compactProductHost =
            'apex'
            'chess';
        const apiKeyHint =
            'apex_online_review_'
            'api_key';
        const privateValueToken =
            'sec'
            'ret';
        final markdown = renderOnlineReviewStagingReadinessReportMarkdown(
          buildDefaultOnlineReviewStagingReadinessReport(),
        ).toLowerCase();

        expect(markdown, isNot(contains('https://')));
        expect(markdown, isNot(contains(loopbackHost)));
        expect(markdown, isNot(contains(loopbackIp)));
        expect(markdown, isNot(contains(emulatorHost)));
        expect(markdown, isNot(contains(wildcardHost)));
        expect(markdown, isNot(contains(productionHostHint)));
        expect(markdown, isNot(contains(dashedProductHost)));
        expect(markdown, isNot(contains(compactProductHost)));
        expect(markdown, isNot(contains(apiKeyHint)));
        expect(markdown, isNot(contains(privateValueToken)));
      },
    );

    test('staging-ready placeholder renders redacted readiness only', () {
      final report = _reportFor(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://staging-api.example.test'),
        ),
      );
      final markdown = renderOnlineReviewStagingReadinessReportMarkdown(report);

      expect(report.isStagingReady, isTrue);
      expect(report.isInternalTesterReady, isFalse);
      expect(report.statusLabel, 'ready for staging smoke');
      expect(onlineReviewStagingReadinessReportExitCode(report), 0);
      expect(markdown, contains('* Staging ready: yes'));
      expect(
        markdown,
        contains(
          '* Base URI fingerprint: '
          'scheme=https;host=staging-api.example.test',
        ),
      );
      expect(markdown, isNot(contains('https://staging-api.example.test')));
      expect(markdown, isNot(contains('/review')));
      expect(markdown, isNot(contains('?')));
    });

    test('internal tester placeholder renders internal readiness safely', () {
      final report = _reportFor(
        OnlineReviewRuntimeGateConfig.internalTester(
          allowHttp: true,
          baseUri: Uri.parse('https://internal-api.example.test'),
        ),
      );
      final markdown = renderOnlineReviewStagingReadinessReportMarkdown(report);

      expect(report.isStagingReady, isFalse);
      expect(report.isInternalTesterReady, isTrue);
      expect(report.statusLabel, 'ready for internal tester smoke');
      expect(onlineReviewStagingReadinessReportExitCode(report), 0);
      expect(markdown, contains('* Internal tester ready: yes'));
      expect(
        markdown,
        contains(
          '* Base URI fingerprint: '
          'scheme=https;host=internal-api.example.test',
        ),
      );
      expect(markdown, isNot(contains('https://internal-api.example.test')));
    });

    test('public preview scenario is not staging-ready', () {
      final report = _reportFor(
        OnlineReviewRuntimeGateConfig.publicPreview(
          allowPublicEntry: true,
          allowHttp: true,
          baseUri: Uri.parse('https://preview-api.example.test'),
        ),
      );

      expect(report.isReady, isFalse);
      expect(report.isStagingReady, isFalse);
      expect(report.statusLabel, 'public preview not allowed');
      expect(
        report.items.map((item) => item.code),
        contains('blocker.publicPreviewMode'),
      );
    });

    test('failing smoke report produces non-zero exit code', () {
      final report = _reportFor(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://staging-api.example.test'),
        ),
        smokeReport: _smokeReport(allPassed: false),
      );

      expect(onlineReviewStagingReadinessReportExitCode(report), 1);
      expect(
        report.items.map((item) => item.code),
        contains('blocker.smokeReportFailed'),
      );
      expect(
        report.items
            .singleWhere((item) => item.code == 'blocker.smokeReportFailed')
            .severity,
        OnlineReviewStagingReadinessReportSeverity.error,
      );
    });

    test('hard safety failure produces non-zero exit code', () {
      final report = _reportFor(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://staging-api.example.test'),
        ),
        smokeReport: _smokeReport(hardSafetyPassed: false),
      );

      expect(onlineReviewStagingReadinessReportExitCode(report), 1);
      expect(
        report.items.map((item) => item.code),
        contains('blocker.hardSafetyFailed'),
      );
    });

    test('dangerous scenario produces error item and non-zero exit code', () {
      final report = _reportFor(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://staging-api.example.test'),
        ),
        smokeReport: _smokeReport(dangerousScenarios: 1),
      );
      final dangerousItem = report.items.singleWhere(
        (item) => item.code == 'blocker.dangerousScenarioPresent',
      );

      expect(onlineReviewStagingReadinessReportExitCode(report), 1);
      expect(
        dangerousItem.severity,
        OnlineReviewStagingReadinessReportSeverity.error,
      );
    });

    test('report item severity is deterministic', () {
      final report = _reportFor(const OnlineReviewRuntimeGateConfig.disabled());

      expect(report.items.first.code, 'blocker.runtimeDisabled');
      expect(
        report.items.first.severity,
        OnlineReviewStagingReadinessReportSeverity.info,
      );
      expect(
        report.items
            .where((item) => item.code.startsWith('warning.'))
            .map((item) => item.severity)
            .toSet(),
        {OnlineReviewStagingReadinessReportSeverity.warning},
      );
    });
  });

  group('OnlineReviewStagingReadinessReport command', () {
    test('tool command exists and docs reference it', () {
      expect(
        File('tool/online_review_staging_readiness_report.dart').existsSync(),
        isTrue,
      );
      expect(
        _contractDocSource(),
        contains('dart run tool/online_review_staging_readiness_report.dart'),
      );
    });

    test('tool command helper renders current safe default', () {
      final report = buildDefaultOnlineReviewStagingReadinessReport();
      final output = renderOnlineReviewStagingReadinessReportMarkdown(report);

      expect(onlineReviewStagingReadinessReportExitCode(report), 0);
      expect(output, contains('# Online Review Staging Readiness Report'));
      expect(output, contains('* Runtime mode: disabled'));
    });
  });

  group('OnlineReviewStagingReadinessReport source guardrails', () {
    test('report file imports no UI, DTO, or HTTP implementation', () {
      final source = _reportSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('HttpOnlineReviewProductRepository')));
      expect(source, isNot(contains('review_draft')));
      expect(source, isNot(contains('governance')));
      expect(source, isNot(contains('reanalysis')));
    });

    test('command file stays pure and deterministic', () {
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
      final source = _commandSource();

      expect(
        source,
        contains('buildDefaultOnlineReviewStagingReadinessReport'),
      );
      expect(
        source,
        contains('renderOnlineReviewStagingReadinessReportMarkdown'),
      );
      expect(source, contains('onlineReviewStagingReadinessReportExitCode'));
      expect(source, contains('io.stdout.write'));
      expect(source, contains('io.exitCode'));
      expect(source, isNot(contains('ProviderContainer')));
      expect(source, isNot(contains('String.fromEnvironment')));
      expect(source, isNot(contains('bool.fromEnvironment')));
      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
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

OnlineReviewStagingReadinessReport _reportFor(
  OnlineReviewRuntimeGateConfig config, {
  OnlineReviewBuildConfigReport? smokeReport,
}) {
  final smoke = smokeReport ?? _smokeReport();
  final decision = OnlineReviewRuntimeGate.decide(config);
  final readiness = buildOnlineReviewStagingBackendReadiness(
    decision: decision,
    repositoryConfig: onlineReviewRepositoryConfigFromActivationDecision(
      decision,
    ),
    smokeReport: smoke,
  );
  return buildOnlineReviewStagingReadinessReport(
    readiness: readiness,
    smokeReport: smoke,
  );
}

OnlineReviewBuildConfigReport _smokeReport({
  bool allPassed = true,
  bool hardSafetyPassed = true,
  int dangerousScenarios = 0,
}) {
  return OnlineReviewBuildConfigReport(
    version: onlineReviewBuildConfigReportVersion,
    totalScenarios: 1,
    passedScenarios: allPassed ? 1 : 0,
    failedScenarios: allPassed ? 0 : 1,
    dangerousScenarios: dangerousScenarios,
    productionSafeScenarios: 1,
    shellVisibleScenarios: 0,
    httpEnabledScenarios: 0,
    publicPolicyScenarios: 0,
    allPassed: allPassed,
    hardSafetyPassed: hardSafetyPassed,
    items: const [],
    scenarioSummaries: const [],
  );
}

String _reportSource() {
  return File(
    'lib/features/pgn_review/infrastructure/'
    'online_review_staging_readiness_report.dart',
  ).readAsStringSync();
}

String _commandSource() {
  return File(
    'tool/online_review_staging_readiness_report.dart',
  ).readAsStringSync();
}

String _contractDocSource() {
  return File('docs/ONLINE_REVIEW_FLUTTER_CONTRACT.md').readAsStringSync();
}
