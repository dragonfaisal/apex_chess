import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_backend_readiness.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_config_scenarios.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_staging_preflight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewStagingPreflight compatibility fixtures', () {
    test('all expected fixture files exist', () {
      for (final path in _fixturePaths) {
        expect(File('$_fixtureRoot/$path').existsSync(), isTrue);
      }
    });

    test(
      'success_compatible parses to success and unlocks analysis attempt',
      () async {
        final result = await _resultForFixture('success_compatible.json');

        expect(result.status, OnlineReviewStagingPreflightStatus.success);
        expect(result.isSuccess, isTrue);
        expect(result.canAttemptAnalysis, isTrue);
        expect(
          result.response!.contractVersion,
          onlineReviewStagingPreflightContractVersion,
        );
        expect(
          result.response!.supportedProductContract,
          onlineReviewStagingPreflightSupportedProductContract,
        );
        expect(result.failure, isNull);
      },
    );

    test('success_with_warnings preserves safe warning strings', () async {
      final result = await _resultForFixture('success_with_warnings.json');

      expect(result.isSuccess, isTrue);
      expect(
        result.response!.warnings,
        contains('staging-preflight-warning-placeholder'),
      );
    });

    test('maintenance ok=false maps to failed safe result', () async {
      final result = await _resultForFixture('failure_maintenance.json');

      expect(result.status, OnlineReviewStagingPreflightStatus.failed);
      expect(result.response!.ok, isFalse);
      expect(result.canAttemptAnalysis, isFalse);
      expect(result.failure!.source, 'backend');
      expect(_resultText(result), isNot(contains('rawPgn')));
      expect(_resultText(result), isNot(contains('accessToken')));
    });

    test('unsupported product contract maps to contractMismatch', () async {
      final result = await _resultForFixture(
        'failure_unsupported_product_contract.json',
      );

      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.contractMismatch,
      );
      expect(result.canAttemptAnalysis, isFalse);
    });

    test('wrong preflight contract maps to contractMismatch', () async {
      final result = await _resultForFixture(
        'failure_wrong_preflight_contract.json',
      );

      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.contractMismatch,
      );
      expect(result.canAttemptAnalysis, isFalse);
    });

    test('missing required fields map to contractMismatch', () async {
      final result = await _resultForFixture(
        'failure_missing_required_fields.json',
      );

      expect(
        result.failure!.code,
        OnlineReviewStagingPreflightFailureCode.contractMismatch,
      );
      expect(result.canAttemptAnalysis, isFalse);
    });

    test(
      'forbidden payload fixture is rejected without surfacing values',
      () async {
        final result = await _resultForFixture(
          'failure_extra_forbidden_payload.json',
        );
        final text = _resultText(result);

        expect(
          result.failure!.code,
          OnlineReviewStagingPreflightFailureCode.forbiddenPayload,
        );
        expect(result.response, isNull);
        expect(result.canAttemptAnalysis, isFalse);
        expect(text, isNot(contains('forbidden-placeholder')));
        expect(text, isNot(contains('rawPgn')));
        expect(text, isNot(contains('apiKey')));
        expect(text, isNot(contains('accessToken')));
        expect(text, isNot(contains('engineOutput')));
        expect(text, isNot(contains('userId')));
        expect(text, isNot(contains('analysisResult')));
      },
    );
  });

  group('OnlineReviewStagingPreflight fixture guardrails', () {
    test('fixture contents contain no real or local URLs', () {
      for (final path in _fixturePaths) {
        final raw = _fixtureRaw(path);

        expect(raw, isNot(contains('http://')));
        expect(raw, isNot(contains('https://')));
        expect(raw, isNot(contains('localhost')));
        expect(raw, isNot(contains('127.0.0.1')));
        expect(raw, isNot(contains('10.0.2.2')));
        expect(raw, isNot(contains('0.0.0.0')));
        expect(raw, isNot(contains('api.apex')));
      }
    });

    test('fixture values contain no realistic credentials or tokens', () {
      for (final path in _fixturePaths) {
        final values = _allStringValues(_fixtureJson(path));
        for (final value in values) {
          expect(value, isNot(matches(RegExp(r'sk-[A-Za-z0-9]{16,}'))));
          expect(value, isNot(matches(RegExp(r'Bearer\s+[A-Za-z0-9._-]+'))));
          expect(value, isNot(matches(RegExp(r'eyJ[A-Za-z0-9_-]{12,}'))));
          expect(value.toLowerCase(), isNot(contains('password')));
          expect(value.toLowerCase(), isNot(contains('private token')));
        }
      }
    });

    test('fixture values contain no PGN, FEN, or engine output', () {
      for (final path in _fixturePaths) {
        final values = _allStringValues(_fixtureJson(path));
        for (final value in values) {
          expect(value, isNot(contains('[Event')));
          expect(value, isNot(matches(RegExp(r'\b1\.\s*[a-hNBRQKO]'))));
          expect(value, isNot(matches(RegExp(r'\b[prnbqkPRNBQK1-8]{1,8}/'))));
          expect(value.toLowerCase(), isNot(contains('info depth')));
          expect(value.toLowerCase(), isNot(contains('bestmove')));
        }
      }
    });
  });

  group('OnlineReviewStagingPreflight compatibility docs', () {
    test('docs mention allowed fields and forbidden fields', () {
      final docs = _preflightDocs();

      expect(docs, contains('Allowed Response Fields'));
      expect(docs, contains('contractVersion'));
      expect(docs, contains('supportedProductContract'));
      expect(docs, contains('Forbidden Request Or Response Content'));
      expect(docs, contains('raw PGN'));
      expect(docs, contains('access tokens'));
      expect(docs, contains('engine stdout or stderr'));
      expect(docs, contains('review payloads'));
      expect(docs, contains('stack traces'));
    });

    test('docs mention private staging opt-in plan', () {
      final docs = _preflightDocs();
      final mainContract = File(
        'docs/ONLINE_REVIEW_FLUTTER_CONTRACT.md',
      ).readAsStringSync();

      expect(docs, contains('Private Staging Opt-In Plan'));
      expect(
        docs,
        contains('dart run tool/online_review_build_config_report.dart'),
      );
      expect(
        docs,
        contains(
          'dart run tool/online_review_staging_readiness_report.dart '
          '--all-scenarios',
        ),
      );
      expect(docs, contains('No real URL may be committed'));
      expect(
        mainContract,
        contains('ONLINE_REVIEW_STAGING_PREFLIGHT_CONTRACT.md'),
      );
    });

    test('docs contain no real backend URL', () {
      final docs =
          '${_preflightDocs()}\n'
          '${File('docs/ONLINE_REVIEW_FLUTTER_CONTRACT.md').readAsStringSync()}';

      expect(docs, isNot(contains('https://')));
      expect(docs, isNot(contains('http://')));
      expect(docs, isNot(contains('localhost')));
      expect(docs, isNot(contains('127.0.0.1')));
      expect(docs, isNot(contains('10.0.2.2')));
      expect(docs, isNot(contains('0.0.0.0')));
      expect(docs, isNot(contains('api.apex')));
    });

    test('PR checklist includes preflight compatibility safety line', () {
      final prTemplate = File(
        '.github/PULL_REQUEST_TEMPLATE.md',
      ).readAsStringSync();

      expect(prTemplate, contains('staging preflight transport'));
      expect(prTemplate, contains('compatibility fixtures'));
      expect(prTemplate, contains('contract docs'));
      expect(prTemplate, contains('kept default HTTP'));
      expect(prTemplate, contains('disabled'));
    });
  });
}

const _fixtureRoot = 'test/fixtures/online_review_staging_preflight';

const _fixturePaths = [
  'success_compatible.json',
  'success_with_warnings.json',
  'failure_maintenance.json',
  'failure_unsupported_product_contract.json',
  'failure_wrong_preflight_contract.json',
  'failure_extra_forbidden_payload.json',
  'failure_missing_required_fields.json',
];

Future<OnlineReviewStagingPreflightResult> _resultForFixture(
  String fixturePath,
) {
  return HttpOnlineReviewStagingPreflightClient(
    baseUri: Uri.parse('https://staging-api.example.test'),
    httpClient: _FixtureHttpClient(_fixtureRaw(fixturePath)),
    timeout: const Duration(seconds: 2),
  ).check(_stagingReadyReadiness());
}

OnlineReviewStagingBackendReadiness _stagingReadyReadiness() {
  return buildOnlineReviewStagingReadinessReportForScenario(
    scenarioById(OnlineReviewStagingConfigScenarioId.stagingPlaceholderReady),
  ).readiness;
}

String _fixtureRaw(String path) {
  return File('$_fixtureRoot/$path').readAsStringSync();
}

Map<String, Object?> _fixtureJson(String path) {
  final decoded = jsonDecode(_fixtureRaw(path));
  return (decoded as Map).map((key, value) => MapEntry(key.toString(), value));
}

Set<String> _allStringValues(Object? value) {
  if (value is String) {
    return {value};
  }
  if (value is Map) {
    return {for (final child in value.values) ..._allStringValues(child)};
  }
  if (value is List) {
    return {for (final child in value) ..._allStringValues(child)};
  }
  return const {};
}

String _resultText(OnlineReviewStagingPreflightResult result) {
  return [
    result.status.name,
    result.response?.contractVersion,
    result.response?.backendName,
    result.response?.backendVersion,
    result.response?.supportedProductContract,
    result.response?.serverTime,
    result.response?.warnings.join(','),
    result.failure?.code.name,
    result.failure?.message,
    result.failure?.source,
  ].whereType<String>().join(' ');
}

String _preflightDocs() {
  return File(
    'docs/ONLINE_REVIEW_STAGING_PREFLIGHT_CONTRACT.md',
  ).readAsStringSync();
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
