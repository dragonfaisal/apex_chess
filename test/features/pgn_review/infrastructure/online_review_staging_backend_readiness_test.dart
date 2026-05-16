import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_repository_config.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewStagingBackendReadiness contract', () {
    test('default disabled config produces disabled readiness', () {
      final readiness = _readiness(
        const OnlineReviewRuntimeGateConfig.disabled(),
      );

      expect(readiness.version, onlineReviewStagingBackendReadinessVersion);
      expect(readiness.status, OnlineReviewStagingReadinessStatus.disabled);
      expect(readiness.isReady, isFalse);
      expect(readiness.isStagingReady, isFalse);
      expect(readiness.isInternalTesterReady, isFalse);
      expect(readiness.runtimeMode, OnlineReviewRuntimeMode.disabled);
      expect(readiness.canUseHttp, isFalse);
      expect(readiness.hasBaseUri, isFalse);
      expect(readiness.baseUriHostFingerprint, isNull);
      expect(readiness.repositoryMode, OnlineReviewRepositoryMode.disabled);
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.runtimeDisabled),
      );
      expect(
        readiness.warnings,
        contains(OnlineReviewStagingReadinessWarning.explicitHttpRequired),
      );
      expect(
        readiness.warnings,
        contains(OnlineReviewStagingReadinessWarning.explicitBaseUriRequired),
      );
      expect(
        readiness.requiredNextStep,
        'Keep Online Review disabled; no staging backend is configured.',
      );
    });

    test('dev harness UI-only is not staging ready', () {
      final readiness = _readiness(
        const OnlineReviewRuntimeGateConfig.devHarness(),
      );

      expect(readiness.status, OnlineReviewStagingReadinessStatus.blocked);
      expect(readiness.isReady, isFalse);
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.modeNotAllowedForStaging),
      );
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.httpNotAllowed),
      );
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.missingBaseUri),
      );
    });

    test('dev harness with HTTP and baseUri is still not staging ready', () {
      final readiness = _readiness(
        OnlineReviewRuntimeGateConfig.devHarness(
          allowHttp: true,
          baseUri: Uri.parse('https://dev-api.example.test'),
        ),
      );

      expect(readiness.canUseHttp, isTrue);
      expect(readiness.repositoryMode, OnlineReviewRepositoryMode.http);
      expect(readiness.isReady, isFalse);
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.modeNotAllowedForStaging),
      );
    });

    test('staging HTTPS with HTTP and passing smoke is staging ready', () {
      final readiness = _readiness(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://staging-api.example.test'),
        ),
      );

      expect(
        readiness.status,
        OnlineReviewStagingReadinessStatus.readyForStagingSmoke,
      );
      expect(readiness.isReady, isTrue);
      expect(readiness.isStagingReady, isTrue);
      expect(readiness.isInternalTesterReady, isFalse);
      expect(readiness.blockers, isEmpty);
      expect(readiness.canUseHttp, isTrue);
      expect(readiness.hasBaseUri, isTrue);
      expect(readiness.repositoryMode, OnlineReviewRepositoryMode.http);
      expect(
        readiness.baseUriHostFingerprint,
        'scheme=https;host=staging-api.example.test',
      );
    });

    test('staging missing baseUri is not configured', () {
      final readiness = _readiness(
        const OnlineReviewRuntimeGateConfig.staging(allowHttp: true),
      );

      expect(
        readiness.status,
        OnlineReviewStagingReadinessStatus.notConfigured,
      );
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.missingBaseUri),
      );
      expect(
        readiness.requiredNextStep,
        'Provide an explicit HTTPS staging base URI through build defines, '
        'then run the smoke report command.',
      );
    });

    test('staging with allowHttp false is not ready', () {
      final readiness = _readiness(
        OnlineReviewRuntimeGateConfig.staging(
          baseUri: Uri.parse('https://staging-api.example.test'),
        ),
      );

      expect(
        readiness.status,
        OnlineReviewStagingReadinessStatus.notConfigured,
      );
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.httpNotAllowed),
      );
      expect(readiness.repositoryMode, OnlineReviewRepositoryMode.disabled);
    });

    test('staging with a loopback host is blocked', () {
      const loopbackHost =
          'local'
          'host';
      final readiness = _readiness(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://$loopbackHost'),
        ),
      );

      expect(readiness.status, OnlineReviewStagingReadinessStatus.blocked);
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed),
      );
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.unsafeBaseUri),
      );
      expect(readiness.baseUriHostFingerprint, 'blocked-loopback-host');
      expect(readiness.baseUriHostFingerprint, isNot(contains(loopbackHost)));
    });

    test('staging with inconsistent repository config is blocked', () {
      final decision = OnlineReviewRuntimeGate.decide(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://staging-api.example.test'),
        ),
      );
      final readiness = buildOnlineReviewStagingBackendReadiness(
        decision: decision,
        repositoryConfig: OnlineReviewRepositoryConfig.disabled(),
        smokeReport: _smokeReport(),
      );

      expect(readiness.status, OnlineReviewStagingReadinessStatus.blocked);
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.unknown),
      );
      expect(
        readiness.requiredNextStep,
        'Align the repository config with the activation decision before '
        'staging.',
      );
    });

    test('internal tester HTTPS with HTTP and passing smoke is ready', () {
      final readiness = _readiness(
        OnlineReviewRuntimeGateConfig.internalTester(
          allowHttp: true,
          baseUri: Uri.parse('https://internal-api.example.test'),
        ),
      );

      expect(
        readiness.status,
        OnlineReviewStagingReadinessStatus.readyForInternalTesterSmoke,
      );
      expect(readiness.isReady, isTrue);
      expect(readiness.isStagingReady, isFalse);
      expect(readiness.isInternalTesterReady, isTrue);
      expect(
        readiness.warnings,
        contains(OnlineReviewStagingReadinessWarning.internalTesterOnly),
      );
      expect(
        readiness.requiredNextStep,
        'Internal tester backend smoke readiness passed; keep this contract '
        'verification-only until an approved activation phase.',
      );
    });

    test('public preview fully explicit remains not staging ready', () {
      final readiness = _readiness(
        OnlineReviewRuntimeGateConfig.publicPreview(
          allowPublicEntry: true,
          allowHttp: true,
          baseUri: Uri.parse('https://preview-api.example.test'),
        ),
      );

      expect(
        readiness.status,
        OnlineReviewStagingReadinessStatus.publicPreviewNotAllowed,
      );
      expect(readiness.isReady, isFalse);
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.publicPreviewMode),
      );
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.modeNotAllowedForStaging),
      );
      expect(
        readiness.requiredNextStep,
        'Public preview is not allowed in this staging readiness phase.',
      );
    });

    test('public preview insecure and unsafe is blocked', () {
      final readiness = _readiness(
        OnlineReviewRuntimeGateConfig.publicPreview(
          allowPublicEntry: true,
          allowHttp: true,
          baseUri: Uri.parse('http://preview-api.example.test'),
        ),
      );

      expect(
        readiness.status,
        OnlineReviewStagingReadinessStatus.publicPreviewNotAllowed,
      );
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.publicPreviewMode),
      );
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.unsafeBaseUri),
      );
      expect(readiness.isReady, isFalse);
    });

    test('failing smoke report blocks readiness', () {
      final readiness = _readiness(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://staging-api.example.test'),
        ),
        smokeReport: _smokeReport(allPassed: false),
      );

      expect(readiness.status, OnlineReviewStagingReadinessStatus.blocked);
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.smokeReportFailed),
      );
      expect(
        readiness.requiredNextStep,
        'Run dart run tool/online_review_build_config_report.dart and fix '
        'failures before staging.',
      );
    });

    test('hard safety failure blocks readiness', () {
      final readiness = _readiness(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://staging-api.example.test'),
        ),
        smokeReport: _smokeReport(hardSafetyPassed: false),
      );

      expect(readiness.status, OnlineReviewStagingReadinessStatus.blocked);
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.hardSafetyFailed),
      );
    });

    test('dangerous scenario count blocks readiness', () {
      final readiness = _readiness(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://staging-api.example.test'),
        ),
        smokeReport: _smokeReport(dangerousScenarios: 1),
      );

      expect(readiness.status, OnlineReviewStagingReadinessStatus.blocked);
      expect(
        readiness.blockers,
        contains(OnlineReviewStagingReadinessBlocker.dangerousScenarioPresent),
      );
    });

    test('base URI fingerprint never exposes full URI details', () {
      const productionHostHint =
          'api.'
          'apex';
      final fingerprint = safeBaseUriHostFingerprint(
        Uri.parse(
          'https://staging-api.example.test/review/path?credential=value',
        ),
      );

      expect(fingerprint, 'scheme=https;host=staging-api.example.test');
      expect(fingerprint, isNot(contains('/review')));
      expect(fingerprint, isNot(contains('?')));
      expect(fingerprint, isNot(contains('credential')));
      expect(fingerprint, isNot(contains('value')));
      expect(fingerprint, isNot(contains(productionHostHint)));
    });

    test('non-placeholder HTTPS host is blocked in this phase', () {
      final readiness = _readiness(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri(scheme: 'https', host: 'unapproved-host'),
        ),
      );

      expect(readiness.status, OnlineReviewStagingReadinessStatus.blocked);
      expect(
        readiness.blockers,
        contains(
          OnlineReviewStagingReadinessBlocker.realUrlNotAllowedInThisPhase,
        ),
      );
      expect(readiness.baseUriHostFingerprint, 'blocked-non-placeholder-host');
    });

    test('required next step is stable for major statuses', () {
      final stagingReady = _readiness(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://staging-api.example.test'),
        ),
      );
      final devHarness = _readiness(
        const OnlineReviewRuntimeGateConfig.devHarness(),
      );

      expect(
        stagingReady.requiredNextStep,
        'Staging backend smoke readiness passed; keep this contract '
        'verification-only until an approved activation phase.',
      );
      expect(
        devHarness.requiredNextStep,
        'Use staging or internalTester mode for backend readiness; dev '
        'harness is not eligible.',
      );
    });
  });

  group('OnlineReviewStagingBackendReadiness guardrails', () {
    test('readiness builder is pure and does not instantiate HTTP clients', () {
      final source = _readinessSource();

      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
      expect(source, isNot(contains('HttpOnlineReviewProductRepository')));
      expect(
        _readiness(const OnlineReviewRuntimeGateConfig.disabled()).isReady,
        isFalse,
      );
    });

    test('readiness source stays pure and boundary-safe', () {
      const forbiddenHost =
          'local'
          'host';
      const loopbackIp =
          '127.0.'
          '0.1';
      const emulatorHost =
          '10.0.'
          '2.2';
      const apiKeyHint =
          'apex_online_review_'
          'api_key';
      const productionHostHint =
          'api.'
          'apex';
      const privateValueToken =
          'sec'
          'ret';
      final source = _readinessSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('apex_http_client.dart')));
      expect(source, isNot(contains('review_draft')));
      expect(source, isNot(contains('governance')));
      expect(source, isNot(contains('reanalysis')));
      expect(source, isNot(contains(forbiddenHost)));
      expect(source, isNot(contains(loopbackIp)));
      expect(source, isNot(contains(emulatorHost)));
      expect(source, isNot(contains(productionHostHint)));
      expect(source, isNot(contains(apiKeyHint)));
      expect(source.toLowerCase(), isNot(contains(privateValueToken)));
    });
  });
}

OnlineReviewStagingBackendReadiness _readiness(
  OnlineReviewRuntimeGateConfig config, {
  OnlineReviewBuildConfigReport? smokeReport,
}) {
  final decision = OnlineReviewRuntimeGate.decide(config);
  return buildOnlineReviewStagingBackendReadiness(
    decision: decision,
    repositoryConfig: onlineReviewRepositoryConfigFromActivationDecision(
      decision,
    ),
    smokeReport: smokeReport ?? _smokeReport(),
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

String _readinessSource() {
  return File(
    'lib/features/pgn_review/infrastructure/'
    'online_review_staging_backend_readiness.dart',
  ).readAsStringSync();
}
