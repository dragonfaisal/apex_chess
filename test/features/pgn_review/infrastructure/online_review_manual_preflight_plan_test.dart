@TestOn('vm')
library;

import 'dart:io';

import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_manual_preflight_plan.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_private_staging_config_evaluator.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_config_scenarios.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_preflight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewManualPreflightPlan approval contract', () {
    test('private dry-run blocked produces blocked plan', () {
      final plan = _plan(privateDryRun: _privateDryRun(baseUri: null));

      expect(plan.version, onlineReviewManualPreflightPlanVersion);
      expect(plan.status, OnlineReviewManualPreflightApprovalStatus.blocked);
      expect(plan.approvedForFutureManualPreflight, isFalse);
      expect(plan.approvedForRealNetworkPreflight, isFalse);
      expect(plan.dryRunCanProceed, isFalse);
      expect(
        plan.blockers,
        contains(OnlineReviewManualPreflightBlocker.privateDryRunNotReady),
      );
    });

    test('private dry-run ready with no fake result is ready for fake-client '
        'simulation', () {
      final plan = _plan(privateDryRun: _privateDryRun());

      expect(
        plan.status,
        OnlineReviewManualPreflightApprovalStatus.readyForFakeClientSimulation,
      );
      expect(plan.approvedForFutureManualPreflight, isFalse);
      expect(plan.fakeClientPreflightSuccess, isFalse);
      expect(plan.blockers, isEmpty);
    });

    test('fake preflight success without explicit approval blocks', () {
      final plan = _plan(
        privateDryRun: _privateDryRun(),
        fakeClientPreflightResult: _successPreflightResult(),
      );

      expect(plan.status, OnlineReviewManualPreflightApprovalStatus.blocked);
      expect(plan.fakeClientPreflightSuccess, isTrue);
      expect(
        plan.blockers,
        contains(OnlineReviewManualPreflightBlocker.missingExplicitApproval),
      );
    });

    test(
      'fake preflight success with explicit approval approves future phase',
      () {
        final plan = _plan(
          privateDryRun: _privateDryRun(),
          fakeClientPreflightResult: _successPreflightResult(),
          explicitApprovalForFutureManualPreflight: true,
        );

        expect(
          plan.status,
          OnlineReviewManualPreflightApprovalStatus
              .approvedForFutureManualPreflight,
        );
        expect(plan.approvedForFutureManualPreflight, isTrue);
        expect(plan.approvedForRealNetworkPreflight, isFalse);
        expect(plan.blockers, isEmpty);
      },
    );

    test('approvedForRealNetworkPreflight is always false', () {
      final plans = [
        _plan(privateDryRun: _privateDryRun(baseUri: null)),
        _plan(privateDryRun: _privateDryRun()),
        _plan(
          privateDryRun: _privateDryRun(),
          fakeClientPreflightResult: _successPreflightResult(),
        ),
        _plan(
          privateDryRun: _privateDryRun(),
          fakeClientPreflightResult: _successPreflightResult(),
          explicitApprovalForFutureManualPreflight: true,
        ),
      ];

      for (final plan in plans) {
        expect(plan.approvedForRealNetworkPreflight, isFalse);
      }
    });

    test('fake preflight contract mismatch blocks', () {
      final plan = _plan(
        privateDryRun: _privateDryRun(),
        fakeClientPreflightResult: _failedPreflightResult(
          OnlineReviewStagingPreflightFailureCode.contractMismatch,
          source: 'contract',
        ),
        explicitApprovalForFutureManualPreflight: true,
      );

      expect(plan.status, OnlineReviewManualPreflightApprovalStatus.blocked);
      expect(
        plan.blockers,
        contains(OnlineReviewManualPreflightBlocker.preflightContractMismatch),
      );
    });

    test('fake preflight ok=false blocks', () {
      final plan = _plan(
        privateDryRun: _privateDryRun(),
        fakeClientPreflightResult: _backendUnavailablePreflightResult(),
        explicitApprovalForFutureManualPreflight: true,
      );

      expect(plan.status, OnlineReviewManualPreflightApprovalStatus.blocked);
      expect(
        plan.blockers,
        contains(OnlineReviewManualPreflightBlocker.preflightTransportFailed),
      );
    });

    test(
      'fake preflight network error blocks without retry execution',
      () async {
        final client = _StaticFakePreflightClient(
          _failedPreflightResult(
            OnlineReviewStagingPreflightFailureCode.networkError,
            source: 'network',
            retryable: true,
          ),
        );

        final result = await runFakeOnlineReviewStagingPreflightSimulation(
          client: client,
          readiness: _readyReadiness(),
        );
        final plan = _plan(
          privateDryRun: _privateDryRun(),
          fakeClientPreflightResult: result,
          explicitApprovalForFutureManualPreflight: true,
        );

        expect(client.callCount, 1);
        expect(plan.status, OnlineReviewManualPreflightApprovalStatus.blocked);
        expect(
          plan.blockers,
          contains(OnlineReviewManualPreflightBlocker.preflightTransportFailed),
        );
      },
    );

    test('forbidden payload fake result blocks', () {
      final plan = _plan(
        privateDryRun: _privateDryRun(),
        fakeClientPreflightResult: _failedPreflightResult(
          OnlineReviewStagingPreflightFailureCode.forbiddenPayload,
          source: 'contract',
        ),
        explicitApprovalForFutureManualPreflight: true,
      );

      expect(plan.status, OnlineReviewManualPreflightApprovalStatus.blocked);
      expect(
        plan.blockers,
        contains(OnlineReviewManualPreflightBlocker.forbiddenPayloadDetected),
      );
    });

    test(
      'public preview private dry-run rejection cannot reach fake-client-ready '
      'status',
      () {
        final plan = _plan(
          privateDryRun: _privateDryRun(
            mode: OnlineReviewRuntimeMode.publicPreview,
            allowPublicEntry: true,
          ),
        );

        expect(
          plan.status,
          isNot(
            OnlineReviewManualPreflightApprovalStatus
                .readyForFakeClientSimulation,
          ),
        );
        expect(
          plan.blockers,
          contains(OnlineReviewManualPreflightBlocker.publicPreviewMode),
        );
      },
    );

    test('required next steps are stable', () {
      final dryRunBlocked = _plan(privateDryRun: _privateDryRun(baseUri: null));
      final needsFake = _plan(privateDryRun: _privateDryRun());
      final needsApproval = _plan(
        privateDryRun: _privateDryRun(),
        fakeClientPreflightResult: _successPreflightResult(),
      );
      final approved = _plan(
        privateDryRun: _privateDryRun(),
        fakeClientPreflightResult: _successPreflightResult(),
        explicitApprovalForFutureManualPreflight: true,
      );

      expect(
        dryRunBlocked.requiredNextStep,
        'Pass the private staging config dry-run before fake-client preflight '
        'simulation.',
      );
      expect(
        needsFake.requiredNextStep,
        'Run fake-client preflight fixture simulation, then rebuild the manual '
        'preflight plan.',
      );
      expect(
        needsApproval.requiredNextStep,
        'Record explicit future manual preflight approval after fake-client '
        'simulation passes; real network remains forbidden in this phase.',
      );
      expect(
        approved.requiredNextStep,
        'Future manual preflight is approved only as a later explicit phase; '
        'real network remains forbidden now.',
      );
    });

    test('warnings include fake-client and no-real-network guardrails', () {
      final plan = _plan(privateDryRun: _privateDryRun());

      expect(
        plan.warnings,
        contains(OnlineReviewManualPreflightWarning.fakeClientOnly),
      );
      expect(
        plan.warnings,
        contains(OnlineReviewManualPreflightWarning.noRealBackendConnection),
      );
      expect(
        plan.warnings,
        contains(OnlineReviewManualPreflightWarning.noAnalysisRequest),
      );
    });

    test('plan output contains no full URL', () {
      final markdown = renderOnlineReviewManualPreflightPlanMarkdown(
        _plan(
          privateDryRun: _privateDryRun(),
          fakeClientPreflightResult: _successPreflightResult(),
          explicitApprovalForFutureManualPreflight: true,
        ),
      );

      expect(markdown, isNot(contains('https://')));
      expect(markdown, isNot(contains('http://')));
      expect(markdown, isNot(contains('private-staging.example.test')));
      expect(markdown, isNot(contains('staging-api.example.test')));
    });

    test(
      'plan output contains no local, token, game, engine, or review markers',
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
        const tokenMarker =
            'access'
            'Token';
        final markdown = renderOnlineReviewManualPreflightPlanMarkdown(
          _plan(
            privateDryRun: _privateDryRun(),
            fakeClientPreflightResult: _failedPreflightResult(
              OnlineReviewStagingPreflightFailureCode.forbiddenPayload,
              source: 'contract',
            ),
            explicitApprovalForFutureManualPreflight: true,
          ),
        );
        final lower = markdown.toLowerCase();

        expect(lower, isNot(contains(loopbackHost)));
        expect(lower, isNot(contains(loopbackIp)));
        expect(lower, isNot(contains(emulatorHost)));
        expect(lower, isNot(contains(wildcardHost)));
        expect(markdown, isNot(contains(tokenMarker)));
        expect(markdown, isNot(contains('PGN')));
        expect(markdown, isNot(contains('FEN')));
        expect(lower, isNot(contains('engineoutput')));
        expect(lower, isNot(contains('reviewpayload')));
        expect(markdown, isNot(contains('[Event')));
        expect(lower, isNot(contains('bestmove')));
      },
    );
  });

  group('OnlineReviewManualPreflightPlan fake-client simulation', () {
    test(
      'fixture success can feed the approval plan through fake client only',
      () async {
        final result = await runFakeOnlineReviewStagingPreflightSimulation(
          client: _FixturePreflightClient('success_compatible.json'),
          readiness: _readyReadiness(),
        );
        final plan = _plan(
          privateDryRun: _privateDryRun(),
          fakeClientPreflightResult: result,
          explicitApprovalForFutureManualPreflight: true,
        );

        expect(result.isSuccess, isTrue);
        expect(
          plan.status,
          OnlineReviewManualPreflightApprovalStatus
              .approvedForFutureManualPreflight,
        );
        expect(plan.approvedForRealNetworkPreflight, isFalse);
      },
    );

    test('fixture contract mismatch blocks through fake client only', () async {
      final result = await runFakeOnlineReviewStagingPreflightSimulation(
        client: _FixturePreflightClient(
          'failure_wrong_preflight_contract.json',
        ),
        readiness: _readyReadiness(),
      );
      final plan = _plan(
        privateDryRun: _privateDryRun(),
        fakeClientPreflightResult: result,
        explicitApprovalForFutureManualPreflight: true,
      );

      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.contractMismatch,
      );
      expect(
        plan.blockers,
        contains(OnlineReviewManualPreflightBlocker.preflightContractMismatch),
      );
    });
  });

  group('OnlineReviewManualPreflightPlan source guardrails', () {
    test('plan builder does not instantiate HTTP clients', () {
      final source = _planSource();

      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('HttpOnlineReviewStagingPreflightClient')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
    });

    test('plan builder does not call preflight client', () {
      final source = _buildFunctionSource();

      expect(source, contains('fakeClientPreflightResult'));
      expect(source, isNot(contains('.check(')));
      expect(source, isNot(contains('runFakeOnlineReviewStagingPreflight')));
    });

    test('source imports no Flutter widgets or material', () {
      final source = _planSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
    });

    test('source imports no product DTOs', () {
      final source = _planSource();

      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
    });

    test('source imports no ProviderContainer', () {
      final source = _planSource();

      expect(source, isNot(contains('ProviderContainer')));
      expect(source, isNot(contains('package:riverpod')));
    });

    test(
      'source imports no backend draft, governance, or reanalysis internals',
      () {
        final source = _planSource();

        expect(source, isNot(contains('review_draft')));
        expect(source, isNot(contains('governance')));
        expect(source, isNot(contains('storagePayload')));
        expect(source, isNot(contains('schemaPayload')));
        expect(source, isNot(contains('reanalysis')));
      },
    );

    test('offline local review path remains untouched', () {
      final planSource = _planSource();
      final offlineProviderSource = File(
        'lib/features/pgn_review/domain/review_analysis_provider.dart',
      ).readAsStringSync();

      expect(planSource, isNot(contains('local_offline')));
      expect(offlineProviderSource, contains('local_offline'));
    });

    test('docs and PR checklist mention fake-client manual plan', () {
      final preflightDocs = File(
        'docs/ONLINE_REVIEW_STAGING_PREFLIGHT_CONTRACT.md',
      ).readAsStringSync();
      final flutterContract = File(
        'docs/ONLINE_REVIEW_FLUTTER_CONTRACT.md',
      ).readAsStringSync();
      final prTemplate = File(
        '.github/PULL_REQUEST_TEMPLATE.md',
      ).readAsStringSync();

      expect(preflightDocs, contains('Manual Preflight Approval Plan'));
      expect(preflightDocs, contains('fake-client-only gate'));
      expect(
        preflightDocs,
        contains('does not approve real network preflight'),
      );
      expect(flutterContract, contains('OnlineReviewManualPreflightPlan'));
      expect(flutterContract, contains('fake-client-only approval'));
      expect(prTemplate, contains('manual preflight approval planning'));
      expect(prTemplate, contains('fake-client-only'));
    });
  });
}

OnlineReviewManualPreflightPlan _plan({
  required OnlineReviewPrivateStagingConfigEvaluation privateDryRun,
  OnlineReviewStagingPreflightResult? fakeClientPreflightResult,
  bool explicitApprovalForFutureManualPreflight = false,
}) {
  return buildOnlineReviewManualPreflightPlan(
    privateDryRun: privateDryRun,
    fakeClientPreflightResult: fakeClientPreflightResult,
    explicitApprovalForFutureManualPreflight:
        explicitApprovalForFutureManualPreflight,
  );
}

OnlineReviewPrivateStagingConfigEvaluation _privateDryRun({
  OnlineReviewRuntimeMode mode = OnlineReviewRuntimeMode.staging,
  bool allowHttp = true,
  Object? baseUri = _defaultBaseUriValue,
  bool allowPublicEntry = false,
  OnlineReviewBuildConfigReport? smokeReport,
}) {
  final parsedBaseUri = switch (baseUri) {
    null => null,
    final Uri uri => uri,
    final String raw => Uri.parse(raw),
    _ => throw ArgumentError.value(baseUri, 'baseUri'),
  };

  return evaluateOnlineReviewPrivateStagingConfigDryRun(
    input: OnlineReviewPrivateStagingConfigInput(
      mode: mode,
      allowHttp: allowHttp,
      baseUri: parsedBaseUri,
      allowDebugHarness: false,
      allowPublicEntry: allowPublicEntry,
    ),
    smokeReport: smokeReport ?? _smokeReport(),
  );
}

OnlineReviewBuildConfigReport _smokeReport() {
  return OnlineReviewBuildConfigReport(
    version: onlineReviewBuildConfigReportVersion,
    totalScenarios: 1,
    passedScenarios: 1,
    failedScenarios: 0,
    dangerousScenarios: 1,
    productionSafeScenarios: 1,
    shellVisibleScenarios: 0,
    httpEnabledScenarios: 0,
    publicPolicyScenarios: 0,
    allPassed: true,
    hardSafetyPassed: true,
    items: const [],
    scenarioSummaries: const [],
  );
}

OnlineReviewStagingPreflightResult _successPreflightResult() {
  return OnlineReviewStagingPreflightResult(
    status: OnlineReviewStagingPreflightStatus.success,
    response: OnlineReviewStagingPreflightResponse(
      contractVersion: onlineReviewStagingPreflightContractVersion,
      status: OnlineReviewStagingPreflightStatus.success,
      ok: true,
      backendName: 'Apex Online Review',
      backendVersion: 'test-placeholder',
      supportedProductContract:
          onlineReviewStagingPreflightSupportedProductContract,
      serverTime: '2026-01-01T00:00:00Z',
      warnings: const [],
    ),
  );
}

OnlineReviewStagingPreflightResult _backendUnavailablePreflightResult() {
  return OnlineReviewStagingPreflightResult(
    status: OnlineReviewStagingPreflightStatus.failed,
    response: OnlineReviewStagingPreflightResponse(
      contractVersion: onlineReviewStagingPreflightContractVersion,
      status: OnlineReviewStagingPreflightStatus.failed,
      ok: false,
      backendName: 'Apex Online Review',
      backendVersion: 'test-placeholder',
      supportedProductContract:
          onlineReviewStagingPreflightSupportedProductContract,
      serverTime: '2026-01-01T00:00:00Z',
      warnings: const [],
    ),
    failure: const OnlineReviewStagingPreflightFailure(
      code: OnlineReviewStagingPreflightFailureCode.unexpected,
      message: 'Online Review staging preflight backend reported unavailable.',
      isRetryable: false,
      source: 'backend',
    ),
  );
}

OnlineReviewStagingPreflightResult _failedPreflightResult(
  OnlineReviewStagingPreflightFailureCode code, {
  required String source,
  bool retryable = false,
}) {
  return OnlineReviewStagingPreflightResult(
    status: OnlineReviewStagingPreflightStatus.failed,
    failure: OnlineReviewStagingPreflightFailure(
      code: code,
      message: 'Safe fake preflight failure.',
      isRetryable: retryable,
      source: source,
    ),
  );
}

OnlineReviewStagingBackendReadiness _readyReadiness() {
  return buildOnlineReviewStagingReadinessReportForScenario(
    scenarioById(OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady),
  ).readiness;
}

String _fixtureRaw(String name) {
  return File(
    'test/fixtures/online_review_staging_preflight/$name',
  ).readAsStringSync();
}

String _planSource() {
  return File(
    'lib/features/pgn_review/infrastructure/'
    'online_review_manual_preflight_plan.dart',
  ).readAsStringSync();
}

String _buildFunctionSource() {
  final source = _planSource();
  final start = source.indexOf(
    'OnlineReviewManualPreflightPlan '
    'buildOnlineReviewManualPreflightPlan',
  );
  final end = source.indexOf(
    'Future<OnlineReviewStagingPreflightResult>',
    start,
  );
  return source.substring(start, end);
}

const _defaultBaseUriValue = 'https://private-staging.example.test';

class _StaticFakePreflightClient implements OnlineReviewStagingPreflightClient {
  _StaticFakePreflightClient(this.result);

  final OnlineReviewStagingPreflightResult result;
  var callCount = 0;

  @override
  Future<OnlineReviewStagingPreflightResult> check(
    OnlineReviewStagingBackendReadiness readiness,
  ) async {
    callCount += 1;
    return result;
  }
}

class _FixturePreflightClient implements OnlineReviewStagingPreflightClient {
  _FixturePreflightClient(this.fixtureName);

  final String fixtureName;

  @override
  Future<OnlineReviewStagingPreflightResult> check(
    OnlineReviewStagingBackendReadiness readiness,
  ) {
    return HttpOnlineReviewStagingPreflightClient(
      baseUri: Uri.parse('https://staging-api.example.test'),
      httpClient: _FixtureHttpClient(_fixtureRaw(fixtureName)),
      timeout: const Duration(seconds: 2),
    ).check(readiness);
  }
}

class _FixtureHttpClient extends ApexHttpClient {
  const _FixtureHttpClient(this.body);

  final String body;

  @override
  Future<ApexHttpResponse> postJson(
    Uri uri, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    return ApexHttpResponse(statusCode: 200, body: this.body);
  }
}
