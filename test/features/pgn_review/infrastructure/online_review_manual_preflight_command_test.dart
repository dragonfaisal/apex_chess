@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_preflight.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_scenario_summary.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/online_review_manual_preflight.dart';

void main() {
  group('Online Review manual preflight command usage gates', () {
    test('command file exists', () {
      expect(
        File('tool/online_review_manual_preflight.dart').existsSync(),
        isTrue,
      );
    });

    test('command rejects missing required flags', () async {
      final client = _RecordingHttpClient.unused();
      final result = await _run(args: const [], client: client);

      expect(result.exitCode, onlineReviewManualPreflightExitUsage);
      expect(result.report.attemptedNetwork, isFalse);
      expect(client.callCount, 0);
      expect(
        result.report.failures,
        contains('requiredManualPreflightFlagsMissing'),
      );
    });

    test('command rejects unknown flags', () async {
      final client = _RecordingHttpClient.unused();
      final result = await _run(
        args: const ['--real-network', '--unknown'],
        client: client,
      );

      expect(result.exitCode, onlineReviewManualPreflightExitUsage);
      expect(client.callCount, 0);
    });

    test('command rejects baseUri command-line input', () async {
      final result = await _run(
        args: [..._requiredArgs, '--baseUri=$_privateBaseUriValue'],
      );

      expect(result.exitCode, onlineReviewManualPreflightExitUsage);
      expect(result.report.failures, contains('unsafeCommandLineUrlInput'));
      expect(result.markdown, isNot(contains(_privateBaseUriValue)));
    });

    test('command rejects any URL command-line argument', () async {
      for (final arg in [
        '${_httpsPrefix}private-staging.example.test',
        '${_httpPrefix}private-staging.example.test',
      ]) {
        final result = await _run(args: [..._requiredArgs, arg]);

        expect(result.exitCode, onlineReviewManualPreflightExitUsage);
        expect(result.report.failures, contains('unsafeCommandLineUrlInput'));
        expect(result.markdown, isNot(contains(arg)));
      }
    });

    test('command requires explicit approval environment value', () async {
      final client = _RecordingHttpClient.unused();
      final result = await _run(
        env: _approvedEnv(includeApproval: false),
        client: client,
      );

      expect(result.exitCode, onlineReviewManualPreflightExitSafetyGate);
      expect(result.report.attemptedNetwork, isFalse);
      expect(client.callCount, 0);
      expect(
        result.report.failures,
        contains('manualPreflightPlanNotApproved'),
      );
      expect(result.report.failures, contains('missingExplicitApproval'));
    });

    test('missing private env config fails before network', () async {
      final client = _RecordingHttpClient.unused();
      final result = await _run(
        env: {
          OnlineReviewManualPreflightCommandEnvKeys.approval:
              onlineReviewManualPreflightApprovalEnvValue,
        },
        client: client,
      );

      expect(result.exitCode, onlineReviewManualPreflightExitSafetyGate);
      expect(result.report.attemptedNetwork, isFalse);
      expect(client.callCount, 0);
      expect(result.report.failures, contains('privateDryRunNotReady'));
    });

    test(
      'disabled, dev harness, and public preview modes fail before network',
      () async {
        for (final mode in ['disabled', 'devHarness', 'publicPreview']) {
          final client = _RecordingHttpClient.unused();
          final result = await _run(
            env: _approvedEnv(mode: mode),
            client: client,
          );

          expect(result.exitCode, onlineReviewManualPreflightExitSafetyGate);
          expect(result.report.attemptedNetwork, isFalse);
          expect(client.callCount, 0);
          expect(result.report.failures, contains('privateDryRunNotReady'));
        }
      },
    );

    test('allowHttp false fails before network', () async {
      final client = _RecordingHttpClient.unused();
      final result = await _run(
        env: _approvedEnv(allowHttp: 'false'),
        client: client,
      );

      expect(result.exitCode, onlineReviewManualPreflightExitSafetyGate);
      expect(client.callCount, 0);
      expect(result.report.failures, contains('httpNotAllowed'));
    });

    test('HTTP URI fails before network', () async {
      final client = _RecordingHttpClient.unused();
      final result = await _run(
        env: _approvedEnv(
          baseUri: Uri(scheme: 'http', host: _privateHost).toString(),
        ),
        client: client,
      );

      expect(result.exitCode, onlineReviewManualPreflightExitSafetyGate);
      expect(client.callCount, 0);
      expect(result.report.failures, contains('unsafeBaseUri'));
    });

    test('loopback and emulator hosts fail before network', () async {
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

      for (final host in [
        loopbackHost,
        loopbackIp,
        emulatorHost,
        wildcardHost,
      ]) {
        final client = _RecordingHttpClient.unused();
        final result = await _run(
          env: _approvedEnv(
            baseUri: Uri(scheme: 'https', host: host).toString(),
          ),
          client: client,
        );

        expect(result.exitCode, onlineReviewManualPreflightExitSafetyGate);
        expect(result.report.attemptedNetwork, isFalse);
        expect(client.callCount, 0);
        expect(result.markdown.toLowerCase(), isNot(contains(host)));
      }
    });

    test(
      'base URI path query fragment and userinfo fail before network',
      () async {
        final client = _RecordingHttpClient.unused();
        final result = await _run(
          env: _approvedEnv(
            baseUri: Uri(
              scheme: 'https',
              userInfo: 'user:token',
              host: _privateHost,
              path: 'private/path',
              queryParameters: const {'api_key': 'value'},
              fragment: 'fragment',
            ).toString(),
          ),
          client: client,
        );

        expect(result.exitCode, onlineReviewManualPreflightExitSafetyGate);
        expect(client.callCount, 0);
        expect(result.report.failures, contains('baseUriMustBeOriginOnly'));
        expect(result.markdown, isNot(contains('token')));
        expect(result.markdown, isNot(contains('api_key')));
        expect(result.markdown, isNot(contains('private/path')));
      },
    );

    test('smoke report failure fails before network', () async {
      final client = _RecordingHttpClient.unused();
      final result = await _run(
        client: client,
        buildSmokeReport: () => _smokeReport(allPassed: false),
      );

      expect(result.exitCode, onlineReviewManualPreflightExitSafetyGate);
      expect(client.callCount, 0);
      expect(result.report.failures, contains('buildConfigReportNotPassed'));
    });

    test('all-scenario readiness failure fails before network', () async {
      final client = _RecordingHttpClient.unused();
      final result = await _run(
        client: client,
        buildScenarioSummary: () =>
            _scenarioSummary(allExpectationsPassed: false),
      );

      expect(result.exitCode, onlineReviewManualPreflightExitSafetyGate);
      expect(client.callCount, 0);
      expect(result.report.failures, contains('allScenarioReadinessNotPassed'));
    });

    test('design review failure fails before network', () async {
      final client = _RecordingHttpClient.unused();
      final result = await _run(
        client: client,
        explicitDesignApprovalOverride: false,
      );

      expect(result.exitCode, onlineReviewManualPreflightExitSafetyGate);
      expect(client.callCount, 0);
      expect(
        result.report.failures,
        contains('realPreflightDesignReviewNotApproved'),
      );
      expect(result.report.failures, contains('missingFutureCommandDesign'));
    });
  });

  group('Online Review manual preflight command transport mapping', () {
    test('successful compatible injected HTTP client exits 0', () async {
      final client = _RecordingHttpClient.success();
      final result = await _run(client: client);

      expect(result.exitCode, onlineReviewManualPreflightExitSuccess);
      expect(result.report.attemptedNetwork, isTrue);
      expect(result.report.success, isTrue);
      expect(
        result.report.preflightStatus,
        OnlineReviewStagingPreflightStatus.success,
      );
      expect(client.callCount, 1);
      expect(client.lastUri!.path, onlineReviewStagingPreflightEndpointPath);
      expect(client.lastBody!.keys, isNot(contains('pgn')));
      expect(client.lastBody!.keys, isNot(contains('fen')));
      expect(client.lastBody!.keys, isNot(contains('userId')));
      expect(client.lastBody!.keys, isNot(contains('authToken')));
      expect(client.lastBody!.keys, isNot(contains('engineOutput')));
      expect(client.lastBody!.keys, isNot(contains('reviewPayload')));
    });

    test('unsupported product contract exits incompatible', () async {
      final result = await _run(
        client: _RecordingHttpClient.withBody({
          ..._successJson(),
          'supportedProductContract': 'other-contract',
        }),
      );

      expect(result.exitCode, onlineReviewManualPreflightExitIncompatible);
      expect(result.report.success, isFalse);
      expect(result.report.failures, contains('contractMismatch'));
    });

    test('wrong preflight contract exits incompatible', () async {
      final result = await _run(
        client: _RecordingHttpClient.withBody({
          ..._successJson(),
          'contractVersion': 'wrong-contract',
        }),
      );

      expect(result.exitCode, onlineReviewManualPreflightExitIncompatible);
      expect(result.report.failures, contains('contractMismatch'));
    });

    test('ok false exits incompatible', () async {
      final result = await _run(
        client: _RecordingHttpClient.withBody({..._successJson(), 'ok': false}),
      );

      expect(result.exitCode, onlineReviewManualPreflightExitIncompatible);
      expect(result.report.failures, contains('unexpected'));
    });

    test('non-2xx exits incompatible without raw body leakage', () async {
      final result = await _run(
        client: _RecordingHttpClient.response(
          const ApexHttpResponse(
            statusCode: 503,
            body: 'stackTrace token pgn fen engineOutput reviewPayload',
          ),
        ),
      );

      expect(result.exitCode, onlineReviewManualPreflightExitIncompatible);
      expect(result.report.failures, contains('httpStatus'));
      expect(result.markdown.toLowerCase(), isNot(contains('stacktrace')));
      expect(result.markdown.toLowerCase(), isNot(contains('token')));
      expect(result.markdown.toLowerCase(), isNot(contains('engineoutput')));
      expect(result.markdown.toLowerCase(), isNot(contains('reviewpayload')));
    });

    test('network exception exits network failure', () async {
      final result = await _run(
        client: _RecordingHttpClient.throwing(
          const ApexHttpNetworkException('connection failed'),
        ),
      );

      expect(result.exitCode, onlineReviewManualPreflightExitNetwork);
      expect(result.report.failures, contains('networkError'));
    });

    test('timeout exits network failure', () async {
      final result = await _run(
        client: _RecordingHttpClient.throwing(TimeoutException('slow')),
      );

      expect(result.exitCode, onlineReviewManualPreflightExitNetwork);
      expect(result.report.failures, contains('timeout'));
    });

    test('output never contains full URL or private host', () async {
      final result = await _run(
        client: _RecordingHttpClient.withBody({
          ..._successJson(),
          'backendName': 'Apex Online Review',
          'backendVersion': 'test-placeholder',
          'warnings': ['safe-warning'],
        }),
      );

      expect(result.markdown, contains('scheme=https;host=<redacted-host>'));
      expect(result.markdown, isNot(contains(_privateBaseUriValue)));
      expect(result.markdown, isNot(contains(_privateHost)));
      expect(result.markdown, isNot(contains(_httpsPrefix)));
      expect(result.markdown, isNot(contains(_httpPrefix)));
    });

    test(
      'output never contains key, token, PGN, FEN, engine, or review markers',
      () async {
        final result = await _run(
          client: _RecordingHttpClient.withBody({
            ..._successJson(),
            'backendName': 'safe',
            'backendVersion': 'token-value',
            'warnings': [
              'api_key value',
              'raw PGN',
              'FEN marker',
              'engineOutput',
              'reviewPayload',
              'safe-warning',
            ],
          }),
        );
        final lower = result.markdown.toLowerCase();

        expect(lower, isNot(contains('api_key')));
        expect(lower, isNot(contains('token')));
        expect(result.markdown, isNot(contains('PGN')));
        expect(result.markdown, isNot(contains('FEN')));
        expect(lower, isNot(contains('engineoutput')));
        expect(lower, isNot(contains('reviewpayload')));
        expect(result.markdown, contains('safe-warning'));
      },
    );
  });

  group('Online Review manual preflight command source guardrails', () {
    test('command source sends no analysis request path', () {
      final source = _commandSource();

      expect(source, isNot(contains('/analysis/request')));
      expect(source, isNot(contains('/analysis/submit')));
      expect(
        source,
        isNot(contains('/analysis/dev/online-review-product/analyze')),
      );
      expect(source, contains('HttpOnlineReviewStagingPreflightClient'));
    });

    test('command source contains preflight transport only', () {
      final source = _commandSource();

      expect(source, contains('online_review_staging_preflight.dart'));
      expect(source, isNot(contains('HttpOnlineReviewProductRepository')));
      expect(source, isNot(contains('OnlineReviewProductRepository')));
      expect(source, isNot(contains('onlineReviewProductRepositoryProvider')));
    });

    test('source imports no UI or ProviderContainer', () {
      final source = _commandSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('ProviderContainer')));
    });

    test(
      'source has no hardcoded real URL or default HTTP-enabling env values',
      () {
        final source = _commandSource();
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

        expect(source, isNot(contains(_httpsPrefix)));
        expect(source, isNot(contains(_httpPrefix)));
        expect(source, isNot(contains(loopbackHost)));
        expect(source, isNot(contains(loopbackIp)));
        expect(source, isNot(contains(emulatorHost)));
        expect(source, isNot(contains(productionHostHint)));
        expect(source, isNot(contains('=true')));
        expect(source, isNot(contains('allowHttp: true')));
      },
    );

    test('offline local review path remains untouched', () {
      final source = File(
        'lib/features/pgn_review/domain/review_analysis_provider.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('online_review_manual_preflight')));
      expect(source, isNot(contains('OnlineReviewManualPreflight')));
    });
  });
}

Future<OnlineReviewManualPreflightCommandResult> _run({
  List<String> args = _requiredArgs,
  Map<String, String>? env,
  _RecordingHttpClient? client,
  OnlineReviewBuildConfigReport Function()? buildSmokeReport,
  OnlineReviewStagingScenarioSummaryResult Function()? buildScenarioSummary,
  OnlineReviewStagingPreflightResult? fakeClientPreflightResult,
  bool? explicitDesignApprovalOverride,
}) {
  final httpClient = client ?? _RecordingHttpClient.success();
  return runOnlineReviewManualPreflightCommand(
    args: args,
    environment: env ?? _approvedEnv(),
    httpClientFactory: () => httpClient,
    buildSmokeReport: buildSmokeReport,
    buildScenarioSummary: buildScenarioSummary,
    fakeClientPreflightResult: fakeClientPreflightResult,
    explicitDesignApprovalOverride: explicitDesignApprovalOverride,
    preflightTimeout: const Duration(seconds: 1),
  );
}

Map<String, String> _approvedEnv({
  String mode = 'staging',
  String allowHttp = 'true',
  String? baseUri,
  bool includeApproval = true,
}) {
  return {
    OnlineReviewManualPreflightCommandEnvKeys.mode: mode,
    OnlineReviewManualPreflightCommandEnvKeys.allowHttp: allowHttp,
    OnlineReviewManualPreflightCommandEnvKeys.baseUri:
        baseUri ?? _privateBaseUriValue,
    if (includeApproval)
      OnlineReviewManualPreflightCommandEnvKeys.approval:
          onlineReviewManualPreflightApprovalEnvValue,
  };
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
    dangerousScenarios: 1,
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

OnlineReviewStagingScenarioSummaryResult _scenarioSummary({
  bool allExpectationsPassed = true,
  bool noUnsafeOutputLeaks = true,
  bool hardSafetyPassed = true,
}) {
  return OnlineReviewStagingScenarioSummaryResult(
    version: onlineReviewStagingScenarioSummaryVersion,
    totalScenarios: 1,
    evaluatedScenarios: 1,
    stagingReadyScenarios: 1,
    internalTesterReadyScenarios: 0,
    safelyBlockedScenarios: 0,
    nonZeroExitScenarios: 0,
    failedExpectationScenarios: allExpectationsPassed ? 0 : 1,
    leakedUnsafeOutputScenarios: noUnsafeOutputLeaks ? 0 : 1,
    allExpectationsPassed: allExpectationsPassed,
    noUnsafeOutputLeaks: noUnsafeOutputLeaks,
    hardSafetyPassed: hardSafetyPassed,
    entries: const [],
    errors: const [],
  );
}

Map<String, Object?> _successJson() {
  return {
    'contractVersion': onlineReviewStagingPreflightContractVersion,
    'ok': true,
    'backendName': 'Apex Online Review',
    'backendVersion': 'test-placeholder',
    'supportedProductContract':
        onlineReviewStagingPreflightSupportedProductContract,
    'warnings': <String>[],
  };
}

String _commandSource() {
  return File('tool/online_review_manual_preflight.dart').readAsStringSync();
}

class _RecordingHttpClient extends ApexHttpClient {
  _RecordingHttpClient(this._handler);

  factory _RecordingHttpClient.unused() {
    return _RecordingHttpClient((_, _, _, _) {
      fail('HTTP client should not be called before safety gates pass.');
    });
  }

  factory _RecordingHttpClient.success() {
    return _RecordingHttpClient.withBody(_successJson());
  }

  factory _RecordingHttpClient.withBody(Map<String, Object?> body) {
    return _RecordingHttpClient.response(
      ApexHttpResponse(statusCode: 200, body: jsonEncode(body)),
    );
  }

  factory _RecordingHttpClient.response(ApexHttpResponse response) {
    return _RecordingHttpClient((_, _, _, _) async => response);
  }

  factory _RecordingHttpClient.throwing(Object error) {
    return _RecordingHttpClient((_, _, _, _) async => throw error);
  }

  final Future<ApexHttpResponse> Function(
    Uri uri,
    Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  )
  _handler;

  int callCount = 0;
  Uri? lastUri;
  Map<String, Object?>? lastBody;

  @override
  Future<ApexHttpResponse> postJson(
    Uri uri, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    callCount += 1;
    lastUri = uri;
    lastBody = Map.unmodifiable(body);
    return _handler(uri, body, headers, timeout);
  }
}

const _requiredArgs = [
  '--real-network',
  '--i-understand-this-is-private-staging',
];
const _privateHost = 'private-staging.example.test';
final _privateBaseUriValue = Uri(
  scheme: 'https',
  host: _privateHost,
).toString();
const _httpsPrefix =
    'https'
    '://';
const _httpPrefix =
    'http'
    '://';
