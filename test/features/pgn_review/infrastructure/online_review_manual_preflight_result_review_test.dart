@TestOn('vm')
library;

import 'dart:io';

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_manual_preflight_result_review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewManualPreflightResultReview contract', () {
    test('notRun when no exit code or output exists', () {
      final review = _review(exitCode: null, stdout: null, stderr: null);

      expect(review.version, onlineReviewManualPreflightResultReviewVersion);
      expect(
        review.status,
        OnlineReviewManualPreflightResultReviewStatus.notRun,
      );
      expect(review.safeToShareSummary, isFalse);
      expect(review.compatibleBackend, isFalse);
      expect(review.unlocksAnalysis, isFalse);
      expect(
        review.blockers,
        contains(
          OnlineReviewManualPreflightResultReviewBlocker.missingCommandOutput,
        ),
      );
    });

    test(
      'exit 0 with safe compatible output is compatible but unlocks nothing',
      () {
        final review = _review(exitCode: 0, stdout: _compatibleOutput());

        expect(
          review.status,
          OnlineReviewManualPreflightResultReviewStatus.compatibleBackend,
        );
        expect(review.safeToShareSummary, isTrue);
        expect(review.compatibleBackend, isTrue);
        expect(review.unlocksAnalysis, isFalse);
        expect(review.baseUriFingerprint, 'scheme=https;host=<redacted-host>');
        expect(
          review.contractVersion,
          onlineReviewManualPreflightResultReviewPreflightContract,
        );
        expect(
          review.supportedProductContract,
          onlineReviewManualPreflightResultReviewSupportedProductContract,
        );
        expect(review.backendName, 'Apex Online Review');
        expect(review.backendVersion, 'test-placeholder');
        expect(review.blockers, isEmpty);
      },
    );

    test('exit 2 is incompatibleBackend', () {
      final review = _review(exitCode: 2, stdout: _incompatibleOutput());

      expect(
        review.status,
        OnlineReviewManualPreflightResultReviewStatus.incompatibleBackend,
      );
      expect(review.safeToShareSummary, isTrue);
      expect(review.compatibleBackend, isFalse);
      expect(
        review.blockers,
        contains(
          OnlineReviewManualPreflightResultReviewBlocker.incompatibleContract,
        ),
      );
    });

    test('exit 70 and 64 are safetyGateFailed', () {
      for (final exitCode in [70, 64]) {
        final review = _review(exitCode: exitCode, stdout: _safetyGateOutput());

        expect(
          review.status,
          OnlineReviewManualPreflightResultReviewStatus.safetyGateFailed,
        );
        expect(review.safeToShareSummary, isTrue);
        expect(review.compatibleBackend, isFalse);
        expect(
          review.blockers,
          contains(
            OnlineReviewManualPreflightResultReviewBlocker.commandExitNonZero,
          ),
        );
      }
    });

    test('exit 74 is networkFailed', () {
      final review = _review(exitCode: 74, stdout: _networkFailureOutput());

      expect(
        review.status,
        OnlineReviewManualPreflightResultReviewStatus.networkFailed,
      );
      expect(review.safeToShareSummary, isTrue);
      expect(
        review.blockers,
        contains(OnlineReviewManualPreflightResultReviewBlocker.networkFailure),
      );
    });

    test('full URL output is rejected', () {
      final review = _review(
        exitCode: 0,
        stdout:
            '${_compatibleOutput()}\nprivate endpoint: '
            '${_httpsPrefix}private-staging.example.test',
      );

      expect(
        review.status,
        OnlineReviewManualPreflightResultReviewStatus.rejectedForUnsafeOutput,
      );
      expect(review.safeToShareSummary, isFalse);
      expect(
        review.blockers,
        contains(
          OnlineReviewManualPreflightResultReviewBlocker.fullUrlLeakDetected,
        ),
      );
    });

    test('local endpoint output is rejected', () {
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
        loopbackHost,
        loopbackIp,
        emulatorHost,
        wildcardHost,
      ]) {
        final review = _review(
          exitCode: 0,
          stdout: '${_compatibleOutput()}\n$marker',
        );

        expect(
          review.status,
          OnlineReviewManualPreflightResultReviewStatus.rejectedForUnsafeOutput,
        );
        expect(
          review.blockers,
          contains(
            OnlineReviewManualPreflightResultReviewBlocker.fullUrlLeakDetected,
          ),
        );
      }
    });

    test('token and API key markers in stdout or stderr are rejected', () {
      for (final marker in ['api_key=value', 'access_token=value']) {
        final review = _review(
          exitCode: 0,
          stdout: _compatibleOutput(),
          stderr: marker,
        );

        expect(
          review.status,
          OnlineReviewManualPreflightResultReviewStatus.rejectedForUnsafeOutput,
        );
        expect(
          review.blockers,
          contains(
            OnlineReviewManualPreflightResultReviewBlocker.tokenLeakDetected,
          ),
        );
      }
    });

    test('PGN, FEN, engine, and review markers are rejected', () {
      final markers = [
        '[Event "Private"]',
        '1. e4 e5 2. Nf3',
        'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'engineOutput',
        'bestmove e2e4',
        'reviewPayload',
      ];

      for (final marker in markers) {
        final review = _review(
          exitCode: 0,
          stdout: '${_compatibleOutput()}\n$marker',
        );

        expect(
          review.status,
          OnlineReviewManualPreflightResultReviewStatus.rejectedForUnsafeOutput,
        );
        expect(
          review.blockers,
          contains(
            OnlineReviewManualPreflightResultReviewBlocker
                .analysisPayloadLeakDetected,
          ),
        );
      }
    });

    test('stack trace markers are rejected', () {
      final review = _review(
        exitCode: 74,
        stdout: _networkFailureOutput(),
        stderr: 'Stack trace:\npackage:apex_chess/file.dart 10:2',
      );

      expect(
        review.status,
        OnlineReviewManualPreflightResultReviewStatus.rejectedForUnsafeOutput,
      );
      expect(
        review.blockers,
        contains(
          OnlineReviewManualPreflightResultReviewBlocker.stackTraceLeakDetected,
        ),
      );
    });

    test('raw JSON body markers are rejected', () {
      final review = _review(
        exitCode: 0,
        stdout: '${_compatibleOutput()}\n{"contractVersion":"raw"}',
      );

      expect(
        review.status,
        OnlineReviewManualPreflightResultReviewStatus.rejectedForUnsafeOutput,
      );
      expect(
        review.blockers,
        contains(
          OnlineReviewManualPreflightResultReviewBlocker.rawBodyLeakDetected,
        ),
      );
    });

    test('renderer never includes raw output', () {
      const rawMarker = 'raw-private-output-marker';
      final review = _review(
        exitCode: 0,
        stdout: _compatibleOutput(rawMarker: rawMarker),
      );
      final markdown = renderOnlineReviewManualPreflightResultReviewMarkdown(
        review,
      );

      expect(
        markdown,
        contains('# Online Review Manual Preflight Result Review'),
      );
      expect(markdown, isNot(contains(rawMarker)));
      expect(markdown, isNot(contains('raw-private-output-marker')));
    });

    test('renderer includes warnings that analysis remains locked', () {
      final markdown = renderOnlineReviewManualPreflightResultReviewMarkdown(
        _review(exitCode: 0, stdout: _compatibleOutput()),
      );

      expect(markdown, contains('preflightDoesNotUnlockAnalysis'));
      expect(markdown, contains('* Unlocks analysis: no'));
      expect(markdown, contains('No analysis request is approved'));
    });

    test('safe compatible output does not unlock analysis', () {
      final review = _review(exitCode: 0, stdout: _compatibleOutput());

      expect(review.compatibleBackend, isTrue);
      expect(review.unlocksAnalysis, isFalse);
    });
  });

  group('OnlineReviewManualPreflightResultReview docs and checklist', () {
    test('docs include runbook commands', () {
      final docs = _preflightDocs();

      expect(
        docs,
        contains('First Controlled Private Staging Preflight Runbook'),
      );
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
      expect(
        docs,
        contains(
          'dart run tool/online_review_staging_readiness_report.dart '
          '--private-config-dry-run',
        ),
      );
      expect(
        docs,
        contains(
          'dart run tool/online_review_manual_preflight.dart --real-network '
          '--i-understand-this-is-private-staging',
        ),
      );
    });

    test('docs include env setup and cleanup commands', () {
      final docs = _preflightDocs();

      expect(docs, contains('APEX_PRIVATE_ONLINE_REVIEW_MODE'));
      expect(docs, contains('APEX_PRIVATE_ONLINE_REVIEW_ALLOW_HTTP'));
      expect(docs, contains('APEX_PRIVATE_ONLINE_REVIEW_BASE_URI'));
      expect(
        docs,
        contains('APEX_PRIVATE_ONLINE_REVIEW_REAL_PREFLIGHT_APPROVAL'),
      );
      expect(
        docs,
        contains('I_UNDERSTAND_THIS_IS_PRIVATE_STAGING_PREFLIGHT_ONLY'),
      );
      expect(
        docs,
        contains('Remove-Item Env:\\APEX_PRIVATE_ONLINE_REVIEW_MODE'),
      );
      expect(
        docs,
        contains('Remove-Item Env:\\APEX_PRIVATE_ONLINE_REVIEW_BASE_URI'),
      );
      expect(
        docs,
        contains(
          'Remove-Item Env:\\APEX_PRIVATE_ONLINE_REVIEW_REAL_PREFLIGHT_APPROVAL',
        ),
      );
    });

    test('docs include safe-to-share rules', () {
      final docs = _preflightDocs();

      expect(docs, contains('Safe-to-share result rules'));
      expect(docs, contains('Share only the redacted Markdown report summary'));
      expect(docs, contains('Do not share full URLs'));
      expect(docs, contains('raw response bodies'));
      expect(docs, contains('stack traces'));
      expect(docs, contains('PGN, FEN, engine output'));
      expect(docs, contains('does not unlock'));
    });

    test('docs contain no real URL and only placeholder URL examples', () {
      final docs = _preflightDocs();
      final urlMatches = RegExp(r'https?://[^\s"`]+').allMatches(docs);

      expect(urlMatches, isNotEmpty);
      for (final match in urlMatches) {
        expect(match.group(0), contains('.example.test'));
      }
      expect(docs, isNot(contains('staging-api.example.test')));
      expect(docs, isNot(contains('api.apex')));
    });

    test('PR template includes result review and runbook guard', () {
      final prTemplate = _singleLine(
        File('.github/PULL_REQUEST_TEMPLATE.md').readAsStringSync(),
      );

      expect(prTemplate, contains('manual preflight runbook or result review'));
      expect(prTemplate, contains('focused result-review tests'));
      expect(
        prTemplate,
        contains('raw URLs, private values, and command output'),
      );
    });
  });

  group('OnlineReviewManualPreflightResultReview source guardrails', () {
    test('source imports no HTTP client', () {
      final source = _source();

      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('apex_http_client.dart')));
      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
    });

    test('source imports no ProviderContainer', () {
      final source = _source();

      expect(source, isNot(contains('ProviderContainer')));
      expect(source, isNot(contains('package:riverpod')));
    });

    test('source imports no UI packages', () {
      final source = _source();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
    });

    test('source imports no product analysis activation paths', () {
      final source = _source();

      expect(source, isNot(contains('OnlineReviewProductRepository')));
      expect(source, isNot(contains('HttpOnlineReviewProductRepository')));
      expect(source, isNot(contains('onlineReviewProductRepositoryProvider')));
      expect(source, isNot(contains('onlineReviewProductActionsProvider')));
      expect(source, isNot(contains('OnlineReviewProductShell')));
      expect(source, isNot(contains('OnlineReviewProductDevHarness')));
    });

    test('offline local review path remains untouched', () {
      final source = File(
        'lib/features/pgn_review/domain/review_analysis_provider.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('ManualPreflightResultReview')));
      expect(source, contains('local_offline'));
    });
  });
}

OnlineReviewManualPreflightResultReview _review({
  required int? exitCode,
  String? stdout,
  String? stderr = '',
}) {
  return reviewOnlineReviewManualPreflightCommandOutput(
    OnlineReviewManualPreflightResultReviewInput(
      exitCode: exitCode,
      stdoutText: stdout,
      stderrText: stderr,
    ),
  );
}

String _compatibleOutput({String? rawMarker}) {
  final buffer = StringBuffer()
    ..writeln('# Online Review Manual Preflight Report')
    ..writeln()
    ..writeln('* Version: `online-review-manual-preflight-command-report-v1`')
    ..writeln('* Manual/private only: yes')
    ..writeln('* Attempted network: yes')
    ..writeln('* Success: yes')
    ..writeln('* Runtime mode: staging')
    ..writeln('* Base URI fingerprint: scheme=https;host=<redacted-host>')
    ..writeln('* Preflight status: success')
    ..writeln(
      '* Contract version: '
      '$onlineReviewManualPreflightResultReviewPreflightContract',
    )
    ..writeln(
      '* Supported product contract: '
      '$onlineReviewManualPreflightResultReviewSupportedProductContract',
    )
    ..writeln('* Backend name: Apex Online Review')
    ..writeln('* Backend version: test-placeholder')
    ..writeln('* Next step: Record this redacted compatibility report.')
    ..writeln()
    ..writeln('## Warnings')
    ..writeln()
    ..writeln('* None')
    ..writeln()
    ..writeln('## Failures')
    ..writeln()
    ..writeln('* None');
  if (rawMarker != null) {
    buffer.writeln('* Raw marker intentionally ignored: $rawMarker');
  }
  return buffer.toString();
}

String _incompatibleOutput() {
  return _compatibleOutput()
      .replaceFirst('* Success: yes', '* Success: no')
      .replaceFirst(
        '* Preflight status: success',
        '* Preflight status: failed',
      );
}

String _safetyGateOutput() {
  return _compatibleOutput()
      .replaceFirst('* Attempted network: yes', '* Attempted network: no')
      .replaceFirst('* Success: yes', '* Success: no')
      .replaceFirst(
        '* Preflight status: success',
        '* Preflight status: blocked',
      );
}

String _networkFailureOutput() {
  return _compatibleOutput()
      .replaceFirst('* Success: yes', '* Success: no')
      .replaceFirst('* Preflight status: success', '* Preflight status: failed')
      .replaceFirst('* None', '* `networkError`');
}

String _source() {
  return File(
    'lib/features/pgn_review/infrastructure/'
    'online_review_manual_preflight_result_review.dart',
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
