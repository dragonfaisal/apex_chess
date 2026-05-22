@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/online_review_manual_preflight_result_review.dart';

void main() {
  group('Online Review manual preflight result-review command', () {
    test('command file exists', () {
      expect(
        File(
          'tool/online_review_manual_preflight_result_review.dart',
        ).existsSync(),
        isTrue,
      );
    });

    test('missing input mode exits usage', () async {
      final result = await _run(args: const ['--exit-code=0']);

      expect(result.exitCode, onlineReviewManualPreflightResultReviewExitUsage);
      expect(result.commandFailure, 'missingInputMode');
    });

    test('unknown flag exits usage', () async {
      final result = await _run(args: const ['--unknown', '--exit-code=0']);

      expect(result.exitCode, onlineReviewManualPreflightResultReviewExitUsage);
      expect(result.commandFailure, 'unknownFlag');
    });

    test('combining stdin and input-file exits usage', () async {
      final result = await _run(
        args: [
          '--stdin',
          '--input-file=${_fixturePath('safe_compatible_output.md')}',
          '--exit-code=0',
        ],
      );

      expect(result.exitCode, onlineReviewManualPreflightResultReviewExitUsage);
      expect(result.commandFailure, 'multipleInputModes');
    });

    test(
      'URL-looking input path is rejected without echoing the path',
      () async {
        final unsafePath =
            '${_httpsPrefix}private-staging.example.test/output.md';
        final result = await _run(
          args: ['--input-file=$unsafePath', '--exit-code=0'],
        );

        expect(
          result.exitCode,
          onlineReviewManualPreflightResultReviewExitUsage,
        );
        expect(result.commandFailure, 'unsafeInputPath');
        expect(result.markdown, isNot(contains(unsafePath)));
      },
    );

    test('safe compatible fixture exits success', () async {
      final result = await _fixtureRun('safe_compatible_output.md', 0);

      expect(
        result.exitCode,
        onlineReviewManualPreflightResultReviewExitSuccess,
      );
      expect(result.review.safeToShareSummary, isTrue);
      expect(result.review.compatibleBackend, isTrue);
      expect(result.markdown, contains('* Unlocks analysis: no'));
      expect(
        result.markdown,
        contains('Preflight success does not unlock analysis by itself'),
      );
    });

    test('safe incompatible fixture exits reviewed failure', () async {
      final result = await _fixtureRun('safe_incompatible_output.md', 2);

      expect(
        result.exitCode,
        onlineReviewManualPreflightResultReviewExitReviewedFailure,
      );
      expect(result.review.safeToShareSummary, isTrue);
      expect(result.review.compatibleBackend, isFalse);
    });

    test('unsafe full URL fixture exits unsafe-output', () async {
      final result = await _fixtureRun('unsafe_full_url_output.md', 0);

      expect(
        result.exitCode,
        onlineReviewManualPreflightResultReviewExitUnsafeOutput,
      );
      expect(result.review.safeToShareSummary, isFalse);
      expect(result.markdown, isNot(contains(_privateFixtureUrl)));
    });

    test('unsafe token fixture exits unsafe-output', () async {
      final result = await _fixtureRun('unsafe_token_output.md', 0);

      expect(
        result.exitCode,
        onlineReviewManualPreflightResultReviewExitUnsafeOutput,
      );
      expect(result.review.safeToShareSummary, isFalse);
      expect(result.markdown, isNot(contains('access_token=fake')));
    });

    test('unsafe stack trace fixture exits unsafe-output', () async {
      final result = await _fixtureRun('unsafe_stack_trace_output.md', 74);

      expect(
        result.exitCode,
        onlineReviewManualPreflightResultReviewExitUnsafeOutput,
      );
      expect(result.review.safeToShareSummary, isFalse);
      expect(result.markdown, isNot(contains('package:apex_chess')));
    });

    test('stdin mode reviews safe text without a file path', () async {
      final source = File(
        _fixturePath('safe_compatible_output.md'),
      ).readAsStringSync();
      final result = await _run(
        args: const ['--stdin', '--exit-code=0'],
        stdinReader: () async => source,
      );

      expect(
        result.exitCode,
        onlineReviewManualPreflightResultReviewExitSuccess,
      );
      expect(result.review.compatibleBackend, isTrue);
    });

    test('output never prints raw input content', () async {
      final result = await _fixtureRun('safe_compatible_output.md', 0);

      expect(result.markdown, isNot(contains('raw-compatible-fixture-marker')));
    });

    test('output never prints full URL or local endpoints', () async {
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
      for (final marker in [
        _privateFixtureUrl,
        loopbackHost,
        loopbackIp,
        emulatorHost,
        wildcardHost,
      ]) {
        final result = await _runTempOutput(
          '${_safeCompatibleOutput()}\n$marker',
          exitCode: 0,
        );
        final lower = result.markdown.toLowerCase();

        expect(
          result.exitCode,
          onlineReviewManualPreflightResultReviewExitUnsafeOutput,
        );
        expect(lower, isNot(contains(marker.toLowerCase())));
      }
    });

    test(
      'output never prints raw key, token, game, engine, or review markers',
      () async {
        final markers = [
          'api_key=fake',
          'access_token=fake',
          '[Event "Private"]',
          '1. e4 e5',
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          'engineOutput',
          'reviewPayload',
        ];

        for (final marker in markers) {
          final result = await _runTempOutput(
            '${_safeCompatibleOutput()}\n$marker',
            exitCode: 0,
          );

          expect(
            result.exitCode,
            onlineReviewManualPreflightResultReviewExitUnsafeOutput,
          );
          expect(result.markdown, isNot(contains(marker)));
        }
      },
    );
  });

  group('Online Review manual preflight result-review command guardrails', () {
    test('source imports no HTTP client', () {
      final source = _commandSource();

      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('apex_http_client.dart')));
      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
    });

    test('source imports no ProviderContainer', () {
      final source = _commandSource();

      expect(source, isNot(contains('ProviderContainer')));
      expect(source, isNot(contains('package:riverpod')));
    });

    test('source imports no Flutter widgets or material', () {
      final source = _commandSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
    });

    test('source imports no product analysis activation', () {
      final source = _commandSource();

      expect(source, isNot(contains('OnlineReviewProductRepository')));
      expect(source, isNot(contains('HttpOnlineReviewProductRepository')));
      expect(source, isNot(contains('onlineReviewProductRepositoryProvider')));
      expect(source, isNot(contains('onlineReviewProductActionsProvider')));
      expect(source, isNot(contains('OnlineReviewProductShell')));
      expect(source, isNot(contains('OnlineReviewProductDevHarness')));
    });

    test('source does not call the manual preflight command', () {
      final source = _commandSource();

      expect(source, isNot(contains('online_review_manual_preflight.dart')));
      expect(source, isNot(contains('runOnlineReviewManualPreflightCommand')));
      expect(source, isNot(contains('Process.run')));
      expect(source, isNot(contains('Process.start')));
    });

    test('docs include command syntax and safe-to-share rules', () {
      final docs = _preflightDocs();

      expect(docs, contains('Redacted Manual Preflight Result Review Command'));
      expect(
        docs,
        contains(
          'dart run tool/online_review_manual_preflight_result_review.dart '
          '--input-file=<temporary-local-output.md> --exit-code=0',
        ),
      );
      expect(docs, contains('safeToShareSummary is true'));
      expect(docs, contains('Share only the review summary'));
      expect(docs, contains('unlocksAnalysis` remains false'));
    });

    test('docs contain no real URL and only placeholder URL examples', () {
      final docs =
          '${_preflightDocs()}\n'
          '${File('docs/ONLINE_REVIEW_FLUTTER_CONTRACT.md').readAsStringSync()}';
      final urls = RegExp(
        r'https?://[^\s"`]+',
      ).allMatches(docs).map((match) => match.group(0)!).toSet();

      expect(urls, {'https://private-staging.example.test'});
      expect(docs, isNot(contains('api.apex')));
    });

    test('PR template includes result-review command checklist', () {
      final prTemplate = _singleLine(
        File('.github/PULL_REQUEST_TEMPLATE.md').readAsStringSync(),
      );

      expect(prTemplate, contains('result-review command'));
      expect(prTemplate, contains('focused result-review command tests'));
      expect(prTemplate, contains('no raw output'));
    });

    test('offline local review path remains untouched', () {
      final source = File(
        'lib/features/pgn_review/domain/review_analysis_provider.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('ManualPreflightResultReviewCommand')));
      expect(source, contains('local_offline'));
    });
  });
}

Future<OnlineReviewManualPreflightResultReviewCommandResult> _run({
  required List<String> args,
  Future<String> Function()? stdinReader,
}) {
  return runOnlineReviewManualPreflightResultReviewCommand(
    args: args,
    stdinReader: stdinReader,
  );
}

Future<OnlineReviewManualPreflightResultReviewCommandResult> _fixtureRun(
  String fileName,
  int exitCode,
) {
  return _run(
    args: ['--input-file=${_fixturePath(fileName)}', '--exit-code=$exitCode'],
  );
}

Future<OnlineReviewManualPreflightResultReviewCommandResult> _runTempOutput(
  String output, {
  required int exitCode,
}) {
  final directory = Directory.systemTemp.createTempSync(
    'apex_manual_preflight_review_',
  );
  addTearDown(() {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  });
  final file = File('${directory.path}/captured-output.md')
    ..writeAsStringSync(output);
  return _run(args: ['--input-file=${file.path}', '--exit-code=$exitCode']);
}

String _fixturePath(String fileName) {
  return 'test/fixtures/online_review_manual_preflight_result_review/$fileName';
}

String _safeCompatibleOutput() {
  return File(_fixturePath('safe_compatible_output.md')).readAsStringSync();
}

String _commandSource() {
  return File(
    'tool/online_review_manual_preflight_result_review.dart',
  ).readAsStringSync();
}

String _preflightDocs() {
  return File(
    'docs/ONLINE_REVIEW_STAGING_PREFLIGHT_CONTRACT.md',
  ).readAsStringSync();
}

String _singleLine(String value) {
  return value.replaceAll(RegExp(r'\s+'), ' ');
}

const _httpsPrefix =
    'https'
    '://';
const _privateFixtureUrl =
    'https'
    '://private-staging.example.test';
