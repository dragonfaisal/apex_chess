@TestOn('vm')
library;

import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_manual_preflight_plan.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_private_staging_config_evaluator.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_real_preflight_design_review.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_preflight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewRealPreflightDesignReview contract', () {
    test('missing private dry-run blocks', () {
      final review = _review(
        privateDryRun: null,
        manualPreflightPlan: _approvedManualPlan(_privateDryRun()),
      );

      expect(
        review.status,
        OnlineReviewRealPreflightDesignReviewStatus.blocked,
      );
      expect(review.privateDryRunReady, isFalse);
      expect(
        review.blockers,
        contains(
          OnlineReviewRealPreflightDesignReviewBlocker.privateDryRunMissing,
        ),
      );
      expect(review.approvedForFutureRealPreflightDesign, isFalse);
    });

    test('private dry-run not ready blocks', () {
      final dryRun = _privateDryRun(baseUri: null);
      final review = _review(
        privateDryRun: dryRun,
        manualPreflightPlan: _approvedManualPlan(_privateDryRun()),
      );

      expect(
        review.status,
        OnlineReviewRealPreflightDesignReviewStatus.blocked,
      );
      expect(review.privateDryRunReady, isFalse);
      expect(
        review.blockers,
        contains(
          OnlineReviewRealPreflightDesignReviewBlocker.privateDryRunNotReady,
        ),
      );
    });

    test('missing manual preflight plan blocks', () {
      final review = _review(
        privateDryRun: _privateDryRun(),
        manualPreflightPlan: null,
      );

      expect(
        review.status,
        OnlineReviewRealPreflightDesignReviewStatus.blocked,
      );
      expect(review.fakeClientPlanApproved, isFalse);
      expect(
        review.blockers,
        contains(
          OnlineReviewRealPreflightDesignReviewBlocker.fakeClientPlanMissing,
        ),
      );
    });

    test('manual preflight plan not approved blocks', () {
      final dryRun = _privateDryRun();
      final review = _review(
        privateDryRun: dryRun,
        manualPreflightPlan: _manualPlanNeedingApproval(dryRun),
      );

      expect(
        review.status,
        OnlineReviewRealPreflightDesignReviewStatus.blocked,
      );
      expect(review.fakeClientPlanApproved, isFalse);
      expect(
        review.blockers,
        contains(
          OnlineReviewRealPreflightDesignReviewBlocker
              .fakeClientPlanNotApproved,
        ),
      );
    });

    test('ready dry-run and approved fake-client plan without explicit design '
        'approval needs approval', () {
      final dryRun = _privateDryRun();
      final review = _review(
        privateDryRun: dryRun,
        manualPreflightPlan: _approvedManualPlan(dryRun),
      );

      expect(
        review.status,
        OnlineReviewRealPreflightDesignReviewStatus.needsApproval,
      );
      expect(review.privateDryRunReady, isTrue);
      expect(review.fakeClientPlanApproved, isTrue);
      expect(review.approvedForFutureRealPreflightDesign, isFalse);
      expect(
        review.blockers,
        contains(
          OnlineReviewRealPreflightDesignReviewBlocker
              .missingFutureCommandDesign,
        ),
      );
    });

    test('ready dry-run and approved fake-client plan with explicit design '
        'approval approves future design', () {
      final dryRun = _privateDryRun();
      final review = _review(
        privateDryRun: dryRun,
        manualPreflightPlan: _approvedManualPlan(dryRun),
        explicitApprovalForFutureRealPreflightDesign: true,
      );

      expect(
        review.status,
        OnlineReviewRealPreflightDesignReviewStatus
            .approvedForFutureRealPreflightDesign,
      );
      expect(review.approvedForFutureRealPreflightDesign, isTrue);
      expect(review.approvedForRealNetworkExecutionNow, isFalse);
      expect(review.blockers, isEmpty);
      expect(
        review.allowedFutureCommandName,
        onlineReviewFutureRealPreflightCommandName,
      );
    });

    test('approvedForRealNetworkExecutionNow is always false', () {
      final dryRun = _privateDryRun();
      final reviews = [
        _review(privateDryRun: null, manualPreflightPlan: null),
        _review(privateDryRun: _privateDryRun(baseUri: null)),
        _review(privateDryRun: dryRun, manualPreflightPlan: null),
        _review(
          privateDryRun: dryRun,
          manualPreflightPlan: _approvedManualPlan(dryRun),
        ),
        _review(
          privateDryRun: dryRun,
          manualPreflightPlan: _approvedManualPlan(dryRun),
          explicitApprovalForFutureRealPreflightDesign: true,
        ),
      ];

      for (final review in reviews) {
        expect(review.approvedForRealNetworkExecutionNow, isFalse);
      }
    });

    test('public preview private dry-run rejected cannot approve design', () {
      final publicDryRun = _privateDryRun(
        mode: OnlineReviewRuntimeMode.publicPreview,
        allowPublicEntry: true,
      );
      final review = _review(
        privateDryRun: publicDryRun,
        manualPreflightPlan: _approvedManualPlan(_privateDryRun()),
        explicitApprovalForFutureRealPreflightDesign: true,
      );

      expect(
        review.status,
        isNot(
          OnlineReviewRealPreflightDesignReviewStatus
              .approvedForFutureRealPreflightDesign,
        ),
      );
      expect(
        review.blockers,
        contains(
          OnlineReviewRealPreflightDesignReviewBlocker.publicPreviewForbidden,
        ),
      );
    });

    test('required checks include every precondition and command policy', () {
      final review = _approvedReview();
      final checks = review.requiredChecks.join('\n');

      expect(checks, contains('Build config report'));
      expect(checks, contains('All-scenarios staging readiness'));
      expect(checks, contains('Private staging config dry-run'));
      expect(checks, contains('Fake-client preflight fixture simulation'));
      expect(checks, contains('Manual preflight plan'));
      expect(checks, contains('Real preflight design review'));
      expect(checks, contains('Manual real-network preflight command'));
      expect(checks, contains('no-default-activation'));
    });

    test('allowed input sources are environment-only and non-committed', () {
      final sources = _approvedReview().allowedInputSources.join('\n');

      expect(sources, contains('Explicit non-committed environment variables'));
      expect(sources, contains('APEX_PRIVATE_ONLINE_REVIEW_MODE'));
      expect(sources, contains('APEX_PRIVATE_ONLINE_REVIEW_BASE_URI'));
      expect(sources, contains('APEX_PRIVATE_ONLINE_REVIEW_ALLOW_HTTP'));
      expect(sources, isNot(contains('--baseUri')));
    });

    test(
      'forbidden input sources include URL args and hardcoded source URL',
      () {
        final sources = _approvedReview().forbiddenInputSources.join('\n');

        expect(sources, contains('Command-line URL arguments'));
        expect(sources, contains('--baseUri'));
        expect(sources, contains('Hardcoded source URL'));
        expect(sources, contains('Committed environment files'));
        expect(sources, contains('CI secrets in this phase'));
        expect(sources, contains('Public preview configuration'));
      },
    );

    test('markdown contains no full URL', () {
      final markdown = renderOnlineReviewRealPreflightDesignReviewMarkdown(
        _approvedReview(),
      );

      expect(markdown, isNot(contains('https://')));
      expect(markdown, isNot(contains('http://')));
      expect(markdown, isNot(contains('private-staging.example.test')));
      expect(markdown, isNot(contains('staging-api.example.test')));
    });

    test('markdown contains no local endpoints', () {
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
      final markdown = renderOnlineReviewRealPreflightDesignReviewMarkdown(
        _approvedReview(),
      ).toLowerCase();

      expect(markdown, isNot(contains(loopbackHost)));
      expect(markdown, isNot(contains(loopbackIp)));
      expect(markdown, isNot(contains(emulatorHost)));
      expect(markdown, isNot(contains(wildcardHost)));
    });

    test(
      'markdown contains no key, token, game, engine, or review markers',
      () {
        const tokenMarker =
            'access'
            'Token';
        final markdown = renderOnlineReviewRealPreflightDesignReviewMarkdown(
          _approvedReview(),
        );
        final lower = markdown.toLowerCase();

        expect(lower, isNot(contains('api_key')));
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

  group('OnlineReviewRealPreflightDesignReview source guardrails', () {
    test('source imports no HTTP client', () {
      final source = _designReviewSource();

      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('apex_http_client.dart')));
      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
    });

    test('source imports no ProviderContainer', () {
      final source = _designReviewSource();

      expect(source, isNot(contains('ProviderContainer')));
      expect(source, isNot(contains('package:riverpod')));
    });

    test('source imports no Flutter widgets or material', () {
      final source = _designReviewSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
    });

    test('source imports no product response DTOs', () {
      final source = _designReviewSource();

      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
    });

    test(
      'source imports no backend draft, governance, or reanalysis internals',
      () {
        final source = _designReviewSource();

        expect(source, isNot(contains('review_draft')));
        expect(source, isNot(contains('governance')));
        expect(source, isNot(contains('storagePayload')));
        expect(source, isNot(contains('schemaPayload')));
        expect(source, isNot(contains('reanalysis')));
      },
    );

    test('manual preflight command file exists as explicit tool only', () {
      expect(
        File('tool/online_review_manual_preflight.dart').existsSync(),
        isTrue,
      );
    });

    test('offline local review path remains untouched', () {
      final source = _designReviewSource();
      final offlineProviderSource = File(
        'lib/features/pgn_review/domain/review_analysis_provider.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('local_offline')));
      expect(offlineProviderSource, contains('local_offline'));
    });

    test('docs and PR checklist mention design-only real preflight review', () {
      final preflightDocs = File(
        'docs/ONLINE_REVIEW_STAGING_PREFLIGHT_CONTRACT.md',
      ).readAsStringSync();
      final flutterContract = File(
        'docs/ONLINE_REVIEW_FLUTTER_CONTRACT.md',
      ).readAsStringSync();
      final prTemplate = File(
        '.github/PULL_REQUEST_TEMPLATE.md',
      ).readAsStringSync();

      expect(
        preflightDocs,
        contains('Real-Network Manual Preflight Design Review'),
      );
      expect(
        preflightDocs,
        contains(onlineReviewFutureRealPreflightCommandName),
      );
      expect(
        preflightDocs,
        contains('Command-line URL arguments are forbidden'),
      );
      expect(preflightDocs, contains('Manual Real-Network Preflight Command'));
      expect(
        flutterContract,
        contains('OnlineReviewRealPreflightDesignReview'),
      );
      expect(flutterContract, contains('design-review gate'));
      expect(prTemplate, contains('real preflight design review'));
      expect(prTemplate, contains('manual real-network preflight command'));
    });
  });
}

OnlineReviewRealPreflightDesignReview _review({
  required OnlineReviewPrivateStagingConfigEvaluation? privateDryRun,
  OnlineReviewManualPreflightPlan? manualPreflightPlan,
  bool explicitApprovalForFutureRealPreflightDesign = false,
}) {
  return buildOnlineReviewRealPreflightDesignReview(
    privateDryRun: privateDryRun,
    manualPreflightPlan: manualPreflightPlan,
    explicitApprovalForFutureRealPreflightDesign:
        explicitApprovalForFutureRealPreflightDesign,
  );
}

OnlineReviewRealPreflightDesignReview _approvedReview() {
  final dryRun = _privateDryRun();
  return _review(
    privateDryRun: dryRun,
    manualPreflightPlan: _approvedManualPlan(dryRun),
    explicitApprovalForFutureRealPreflightDesign: true,
  );
}

OnlineReviewManualPreflightPlan _approvedManualPlan(
  OnlineReviewPrivateStagingConfigEvaluation dryRun,
) {
  return buildOnlineReviewManualPreflightPlan(
    privateDryRun: dryRun,
    fakeClientPreflightResult: _successPreflightResult(),
    explicitApprovalForFutureManualPreflight: true,
  );
}

OnlineReviewManualPreflightPlan _manualPlanNeedingApproval(
  OnlineReviewPrivateStagingConfigEvaluation dryRun,
) {
  return buildOnlineReviewManualPreflightPlan(
    privateDryRun: dryRun,
    fakeClientPreflightResult: _successPreflightResult(),
    explicitApprovalForFutureManualPreflight: false,
  );
}

OnlineReviewPrivateStagingConfigEvaluation _privateDryRun({
  OnlineReviewRuntimeMode mode = OnlineReviewRuntimeMode.staging,
  bool allowHttp = true,
  Object? baseUri = _defaultBaseUriHost,
  bool allowPublicEntry = false,
}) {
  final parsedBaseUri = switch (baseUri) {
    null => null,
    final Uri uri => uri,
    final String host => Uri(scheme: 'https', host: host),
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
    smokeReport: _smokeReport(),
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

String _designReviewSource() {
  return File(
    'lib/features/pgn_review/infrastructure/'
    'online_review_real_preflight_design_review.dart',
  ).readAsStringSync();
}

const _defaultBaseUriHost = 'private-staging.example.test';
