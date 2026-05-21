@TestOn('vm')
library;

import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_private_staging_config_evaluator.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewPrivateStagingConfigEvaluator', () {
    test(
      'staging HTTPS private config dry-run can proceed when smoke passes',
      () {
        final evaluation = _evaluation();

        expect(
          evaluation.version,
          onlineReviewPrivateStagingConfigEvaluationVersion,
        );
        expect(evaluation.isDryRun, isTrue);
        expect(evaluation.canProceedToManualPreflight, isTrue);
        expect(evaluation.runtimeMode, OnlineReviewRuntimeMode.staging);
        expect(evaluation.allowHttp, isTrue);
        expect(evaluation.canUseHttp, isTrue);
        expect(evaluation.hasBaseUri, isTrue);
        expect(
          evaluation.readinessStatus,
          OnlineReviewStagingReadinessStatus.readyForStagingSmoke,
        );
        expect(evaluation.repositoryMode, OnlineReviewRepositoryMode.http);
        expect(evaluation.smokeReportAllPassed, isTrue);
        expect(evaluation.smokeReportHardSafetyPassed, isTrue);
        expect(evaluation.readinessBlockers, isEmpty);
        expect(
          evaluation.baseUriFingerprint,
          'scheme=https;host=<redacted-host>',
        );
      },
    );

    test('internal tester HTTPS private config dry-run can proceed when smoke '
        'passes', () {
      final evaluation = _evaluation(
        mode: OnlineReviewRuntimeMode.internalTester,
      );

      expect(evaluation.canProceedToManualPreflight, isTrue);
      expect(
        evaluation.readinessStatus,
        OnlineReviewStagingReadinessStatus.readyForInternalTesterSmoke,
      );
      expect(evaluation.repositoryMode, OnlineReviewRepositoryMode.http);
      expect(
        evaluation.readinessWarnings,
        contains(OnlineReviewStagingReadinessWarning.internalTesterOnly),
      );
    });

    test('disabled mode is rejected', () {
      final evaluation = _evaluation(mode: OnlineReviewRuntimeMode.disabled);

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(
        evaluation.readinessStatus,
        OnlineReviewStagingReadinessStatus.disabled,
      );
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.runtimeDisabled),
      );
    });

    test('dev harness mode is rejected', () {
      final evaluation = _evaluation(mode: OnlineReviewRuntimeMode.devHarness);

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.modeNotAllowedForStaging),
      );
    });

    test('public preview mode is rejected', () {
      final evaluation = _evaluation(
        mode: OnlineReviewRuntimeMode.publicPreview,
        allowPublicEntry: true,
      );

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(
        evaluation.readinessStatus,
        OnlineReviewStagingReadinessStatus.publicPreviewNotAllowed,
      );
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.publicPreviewMode),
      );
    });

    test('missing base URI is rejected', () {
      final evaluation = _evaluation(baseUri: null);

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(evaluation.hasBaseUri, isFalse);
      expect(evaluation.baseUriFingerprint, isNull);
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.missingBaseUri),
      );
    });

    test('allowHttp false is rejected', () {
      final evaluation = _evaluation(allowHttp: false);

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(evaluation.canUseHttp, isFalse);
      expect(evaluation.repositoryMode, OnlineReviewRepositoryMode.disabled);
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.httpNotAllowed),
      );
    });

    test('HTTP URI is rejected for private staging dry-run', () {
      final evaluation = _evaluation(
        baseUri: Uri.parse('http://private-staging.example.test'),
      );

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(evaluation.baseUriFingerprint, 'scheme=http;host=<redacted-host>');
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.unsafeBaseUri),
      );
    });

    test('loopback host is rejected without rendering the host value', () {
      const loopbackHost =
          'local'
          'host';
      final evaluation = _evaluation(
        baseUri: Uri(scheme: 'https', host: loopbackHost),
      );
      final markdown = renderOnlineReviewPrivateStagingConfigEvaluationMarkdown(
        evaluation,
      );

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed),
      );
      expect(markdown.toLowerCase(), isNot(contains(loopbackHost)));
    });

    test('127 loopback address is rejected', () {
      const loopbackIp =
          '127.0.'
          '0.1';
      final evaluation = _evaluation(baseUri: Uri.parse('https://$loopbackIp'));

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed),
      );
    });

    test('emulator host is rejected', () {
      const emulatorHost =
          '10.0.'
          '2.2';
      final evaluation = _evaluation(
        baseUri: Uri.parse('https://$emulatorHost'),
      );

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed),
      );
    });

    test('wildcard host is rejected', () {
      const wildcardHost =
          '0.0.'
          '0.0';
      final evaluation = _evaluation(
        baseUri: Uri.parse('https://$wildcardHost'),
      );

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.loopbackUrlNotAllowed),
      );
    });

    test(
      'URI with path/query marker renders only redacted fingerprint and never '
      'prints full URI',
      () {
        const marker =
            'access_'
            'token';
        final uri = Uri.parse(
          'https://private-staging.example.test/review/path?$marker=value'
          '#fragment',
        );
        final evaluation = _evaluation(baseUri: uri);
        final markdown =
            renderOnlineReviewPrivateStagingConfigEvaluationMarkdown(
              evaluation,
            );

        expect(
          evaluation.baseUriFingerprint,
          'scheme=https;host=<redacted-host>',
        );
        expect(markdown, contains('scheme=https;host=<redacted-host>'));
        expect(markdown, isNot(contains(uri.toString())));
        expect(markdown, isNot(contains('private-staging.example.test')));
        expect(markdown, isNot(contains('/review/path')));
        expect(markdown, isNot(contains(marker)));
        expect(markdown, isNot(contains('fragment')));
      },
    );

    test('failing smoke report blocks evaluation', () {
      final evaluation = _evaluation(
        smokeReport: _smokeReport(allPassed: false),
      );

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(evaluation.smokeReportAllPassed, isFalse);
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.smokeReportFailed),
      );
    });

    test('hard safety failure blocks evaluation', () {
      final evaluation = _evaluation(
        smokeReport: _smokeReport(hardSafetyPassed: false),
      );

      expect(evaluation.canProceedToManualPreflight, isFalse);
      expect(evaluation.smokeReportHardSafetyPassed, isFalse);
      expect(
        evaluation.readinessBlockers,
        contains(OnlineReviewStagingReadinessBlocker.hardSafetyFailed),
      );
    });

    test('repository config matches readiness decision for ready state', () {
      final evaluation = _evaluation();

      expect(evaluation.canProceedToManualPreflight, isTrue);
      expect(evaluation.repositoryMode, OnlineReviewRepositoryMode.http);
      expect(evaluation.readinessBlockers, isEmpty);
      expect(
        evaluation.readinessStatus,
        OnlineReviewStagingReadinessStatus.readyForStagingSmoke,
      );
    });

    test('markdown contains no full URL', () {
      final markdown = renderOnlineReviewPrivateStagingConfigEvaluationMarkdown(
        _evaluation(),
      );

      expect(markdown, isNot(contains('https://')));
      expect(markdown, isNot(contains('http://')));
      expect(markdown, isNot(contains('private-staging.example.test')));
    });

    test('markdown contains no local host values', () {
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
      final markdown = renderOnlineReviewPrivateStagingConfigEvaluationMarkdown(
        _evaluation(
          baseUri: Uri(scheme: 'https', host: loopbackHost),
        ),
      ).toLowerCase();

      expect(markdown, isNot(contains(loopbackHost)));
      expect(markdown, isNot(contains(loopbackIp)));
      expect(markdown, isNot(contains(emulatorHost)));
      expect(markdown, isNot(contains(wildcardHost)));
    });

    test(
      'markdown contains no key, game, engine, or review payload markers',
      () {
        const tokenMarker =
            'access_'
            'token';
        final markdown =
            renderOnlineReviewPrivateStagingConfigEvaluationMarkdown(
              _evaluation(
                baseUri: Uri.parse(
                  'https://private-staging.example.test/path?api_key=value'
                  '&$tokenMarker=value',
                ),
              ),
            );
        final lower = markdown.toLowerCase();

        expect(lower, isNot(contains('api_key')));
        expect(lower, isNot(contains(tokenMarker)));
        expect(markdown, isNot(contains('PGN')));
        expect(markdown, isNot(contains('FEN')));
        expect(lower, isNot(contains('engineoutput')));
        expect(lower, isNot(contains('reviewpayload')));
        expect(markdown, isNot(contains('[Event')));
        expect(lower, isNot(contains('bestmove')));
      },
    );

    test('exit code is 0 only for safe staging/internal ready states', () {
      final staging = _evaluation();
      final internal = _evaluation(
        mode: OnlineReviewRuntimeMode.internalTester,
      );
      final blocked = _evaluation(mode: OnlineReviewRuntimeMode.devHarness);

      expect(onlineReviewPrivateStagingConfigEvaluationExitCode(staging), 0);
      expect(onlineReviewPrivateStagingConfigEvaluationExitCode(internal), 0);
      expect(onlineReviewPrivateStagingConfigEvaluationExitCode(blocked), 1);
    });

    test('exit code is non-zero for rejected or blocked states', () {
      final evaluations = [
        _evaluation(mode: OnlineReviewRuntimeMode.disabled),
        _evaluation(mode: OnlineReviewRuntimeMode.devHarness),
        _evaluation(mode: OnlineReviewRuntimeMode.publicPreview),
        _evaluation(baseUri: null),
        _evaluation(allowHttp: false),
        _evaluation(baseUri: Uri.parse('http://private-staging.example.test')),
        _evaluation(smokeReport: _smokeReport(allPassed: false)),
        _evaluation(smokeReport: _smokeReport(hardSafetyPassed: false)),
      ];

      for (final evaluation in evaluations) {
        expect(
          onlineReviewPrivateStagingConfigEvaluationExitCode(evaluation),
          1,
        );
      }
    });
  });

  group('OnlineReviewPrivateStagingConfigEvaluator command guardrails', () {
    test('command source does not accept arbitrary URL CLI args', () {
      final source = _commandSource();

      expect(source, contains('--private-config-dry-run'));
      expect(source, contains('onlineReviewPrivateStagingConfigEnvKeys'));
      expect(source, isNot(contains('--baseUri')));
      expect(source, isNot(contains('--base-uri')));
      expect(source, isNot(contains('--url')));
      expect(source, isNot(contains('Uri.parse')));
      expect(source, isNot(contains('Uri.tryParse')));
    });

    test('command source does not echo environment values', () {
      final source = _commandSource();

      expect(source, contains('_privateStagingEnvironment'));
      expect(
        source,
        isNot(contains('io.stdout.write(io.Platform.environment')),
      );
      expect(
        source,
        isNot(contains('io.stderr.writeln(io.Platform.environment')),
      );
      expect(source, isNot(contains('io.stdout.write(values')));
      expect(source, isNot(contains('io.stderr.writeln(values')));
    });

    test('command source does not instantiate HTTP client', () {
      final source = _commandSource();

      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('HttpOnlineReviewProductRepository')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
    });

    test('command source does not call preflight client', () {
      final source = _commandSource().toLowerCase();

      expect(source, isNot(contains('stagingpreflightclient')));
      expect(source, isNot(contains('httponlinereviewstagingpreflightclient')));
      expect(source, isNot(contains('online_review_staging_preflight.dart')));
      expect(source, isNot(contains('.check(')));
      expect(source, isNot(contains('postjson')));
    });
  });

  group('OnlineReviewPrivateStagingConfigEvaluator source guardrails', () {
    test('source imports no Flutter widgets or material', () {
      final source = _evaluatorSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
    });

    test('source imports no DTOs', () {
      final source = _evaluatorSource();

      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
    });

    test(
      'source imports no backend draft, governance, or reanalysis internals',
      () {
        final source = _evaluatorSource();

        expect(source, isNot(contains('review_draft')));
        expect(source, isNot(contains('governance')));
        expect(source, isNot(contains('storagePayload')));
        expect(source, isNot(contains('schemaPayload')));
        expect(source, isNot(contains('reanalysis')));
      },
    );

    test('environment parser reads only private dry-run keys', () {
      final input = onlineReviewPrivateStagingConfigInputFromEnvironment({
        OnlineReviewPrivateStagingConfigEnvKeys.mode: 'staging',
        OnlineReviewPrivateStagingConfigEnvKeys.allowHttp: 'true',
        OnlineReviewPrivateStagingConfigEnvKeys.baseUri:
            'https://private-staging.example.test',
        'APEX_ONLINE_REVIEW_MODE': 'publicPreview',
      });

      expect(input.mode, OnlineReviewRuntimeMode.staging);
      expect(input.allowHttp, isTrue);
      expect(input.baseUri, Uri.parse('https://private-staging.example.test'));
      expect(input.allowPublicEntry, isFalse);
      expect(input.allowDebugHarness, isFalse);
    });
  });
}

OnlineReviewPrivateStagingConfigEvaluation _evaluation({
  OnlineReviewRuntimeMode mode = OnlineReviewRuntimeMode.staging,
  bool allowHttp = true,
  Object? baseUri = _defaultBaseUriValue,
  bool allowDebugHarness = false,
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
      allowDebugHarness: allowDebugHarness,
      allowPublicEntry: allowPublicEntry,
    ),
    smokeReport: smokeReport ?? _smokeReport(),
  );
}

OnlineReviewBuildConfigReport _smokeReport({
  bool allPassed = true,
  bool hardSafetyPassed = true,
}) {
  return OnlineReviewBuildConfigReport(
    version: onlineReviewBuildConfigReportVersion,
    totalScenarios: 1,
    passedScenarios: allPassed ? 1 : 0,
    failedScenarios: allPassed ? 0 : 1,
    dangerousScenarios: allPassed && hardSafetyPassed ? 1 : 0,
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

String _evaluatorSource() {
  return File(
    'lib/features/pgn_review/infrastructure/'
    'online_review_private_staging_config_evaluator.dart',
  ).readAsStringSync();
}

String _commandSource() {
  return File(
    'tool/online_review_staging_readiness_report.dart',
  ).readAsStringSync();
}

const _defaultBaseUriValue = 'https://private-staging.example.test';
