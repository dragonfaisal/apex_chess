@TestOn('vm')
library;

import 'dart:io';

import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_matrix.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Online Review build config report command', () {
    test('tool command exists', () {
      expect(
        File('tool/online_review_build_config_report.dart').existsSync(),
        isTrue,
      );
    });

    test('report helper renders the command output and passing exit code', () {
      final report = buildOnlineReviewBuildConfigReport();
      final output = renderOnlineReviewBuildConfigReportMarkdown(report);

      expect(onlineReviewBuildConfigReportExitCode(report), 0);
      expect(
        output,
        contains('# Online Review Build Configuration Smoke Report'),
      );
      expect(output, contains('* Hard safety verdict: yes'));
      expect(output, contains('* All passed: yes'));
    });

    test('report output includes all matrix scenario IDs', () {
      final output = renderOnlineReviewBuildConfigReportMarkdown(
        buildOnlineReviewBuildConfigReport(),
      );

      for (final scenario in onlineReviewBuildConfigScenarios()) {
        expect(output, contains(scenario.id));
      }
    });

    test('output contains no local endpoints, production URLs, or keys', () {
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
      const dashedProductHost =
          'apex-'
          'chess';
      const compactProductHost =
          'apex'
          'chess';
      const privateValueToken =
          'sec'
          'ret';
      const apiKeyHint =
          'apex_online_review_'
          'api_key';
      final output = renderOnlineReviewBuildConfigReportMarkdown(
        buildOnlineReviewBuildConfigReport(),
      ).toLowerCase();

      expect(output, isNot(contains(loopbackHost)));
      expect(output, isNot(contains(loopbackIp)));
      expect(output, isNot(contains(emulatorHost)));
      expect(output, isNot(contains(productionHostHint)));
      expect(output, isNot(contains(dashedProductHost)));
      expect(output, isNot(contains(compactProductHost)));
      expect(output, isNot(contains(apiKeyHint)));
      expect(output, isNot(contains(privateValueToken)));
    });
  });

  group('Online Review build config report command guardrails', () {
    test('contract docs reference the required safety checklist command', () {
      final source = _contractDocSource();

      expect(source, contains('## Build-mode safety verification'));
      expect(
        source,
        contains('dart run tool/online_review_build_config_report.dart'),
      );
      expect(source, contains('required before any staging backend'));
      expect(source, contains('all scenarios'));
      expect(source, contains('pass, the hard safety verdict passes'));
      expect(source, contains('hard safety verdict passes'));
      expect(source, contains('default mode remains disabled'));
      expect(source, contains('no real backend URLs'));
      expect(source, contains('does not activate Online Review'));
    });

    test('contract docs keep the safety checklist non-live', () {
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
      final source = _contractDocSource().toLowerCase();

      expect(source, isNot(contains(loopbackHost)));
      expect(source, isNot(contains(loopbackIp)));
      expect(source, isNot(contains(emulatorHost)));
      expect(source, isNot(contains(productionHostHint)));
      expect(source, isNot(contains(dashedProductHost)));
      expect(source, isNot(contains(compactProductHost)));
      expect(source, isNot(contains(apiKeyHint)));
      expect(source, isNot(contains(privateValueToken)));
      expect(source, isNot(contains('apex_online_review_base_uri=')));
      expect(source, isNot(contains('apex_online_review_allow_http=true')));
      expect(
        source,
        isNot(contains('apex_online_review_allow_public_entry=true')),
      );
    });

    test('PR template references the smoke command and safety checklist', () {
      final source = _singleLine(_prTemplateSource());

      expect(source, contains('## Online Review Safety'));
      expect(
        source,
        contains('dart run tool/online_review_build_config_report.dart'),
      );
      expect(source, contains('allPassed == true'));
      expect(source, contains('hardSafetyPassed == true'));
      expect(source, contains('does not enable live HTTP by default'));
      expect(
        source,
        contains('public or user-facing without an explicit approved phase'),
      );
      expect(
        source,
        contains('Shell visibility and HTTP enablement remain separate'),
      );
      expect(source, contains('Base URI remains explicit and gated'));
      expect(source, contains('For PRs unrelated to Online Review'));
      expect(source, contains('N/A'));
    });

    test('PR template stays verification-only and URL-free', () {
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
      final source = _prTemplateSource().toLowerCase();

      expect(source, isNot(contains(loopbackHost)));
      expect(source, isNot(contains(loopbackIp)));
      expect(source, isNot(contains(emulatorHost)));
      expect(source, isNot(contains(productionHostHint)));
      expect(source, isNot(contains(dashedProductHost)));
      expect(source, isNot(contains(compactProductHost)));
      expect(source, isNot(contains(apiKeyHint)));
      expect(source, isNot(contains(privateValueToken)));
      expect(source, isNot(contains('apex_online_review_base_uri')));
      expect(source, isNot(contains('apex_online_review_allow_http=true')));
      expect(
        source,
        isNot(contains('apex_online_review_allow_public_entry=true')),
      );
      expect(source, isNot(contains('deploy')));
      expect(source, isNot(contains('publish')));
      expect(source, isNot(contains('upload-artifact')));
      expect(source, isNot(contains('build apk')));
      expect(source, isNot(contains('release.apk')));
      expect(source, isNot(contains('signing')));
    });

    test('contract docs include the future CI adoption plan', () {
      final source = _singleLine(_contractDocSource());

      expect(source, contains('### Future CI adoption plan'));
      expect(
        source,
        contains('Phase 1: PR checklist requires the smoke command manually'),
      );
      expect(source, contains('Phase 2: When a repo CI convention exists'));
      expect(source, contains('Phase 3: Before staging or public preview'));
      expect(
        source,
        contains('dart run tool/online_review_build_config_report.dart'),
      );
      expect(source, contains('test/features/pgn_review/'));
      expect(source, contains('no real backend URLs or activation flags'));
    });

    test(
      'online review CI workflow hooks stay verification-only if present',
      () {
        for (final source in _onlineReviewWorkflowSources()) {
          final lowerSource = source.toLowerCase();

          expect(
            source,
            contains('dart run tool/online_review_build_config_report.dart'),
          );
          expect(lowerSource, isNot(contains('deploy')));
          expect(lowerSource, isNot(contains('publish')));
          expect(lowerSource, isNot(contains('upload-artifact')));
          expect(lowerSource, isNot(contains('build apk')));
          expect(lowerSource, isNot(contains('release.apk')));
          expect(lowerSource, isNot(contains('signing')));
          expect(lowerSource, isNot(contains('apex_online_review_base_uri')));
          expect(
            lowerSource,
            isNot(contains('apex_online_review_allow_http=true')),
          );
          expect(
            lowerSource,
            isNot(contains('apex_online_review_allow_public_entry=true')),
          );
        }
      },
    );

    test('tool source wires stdout and report exit code only', () {
      final source = _toolSource();

      expect(source, contains('buildOnlineReviewBuildConfigReport'));
      expect(source, contains('renderOnlineReviewBuildConfigReportMarkdown'));
      expect(source, contains('onlineReviewBuildConfigReportExitCode'));
      expect(source, contains('io.stdout.write'));
      expect(source, contains('io.exitCode'));
    });

    test('tool source stays CLI-only and does not read build defines', () {
      const loopbackHost =
          'local'
          'host';
      const loopbackIp =
          '127.0.'
          '0.1';
      const emulatorHost =
          '10.0.'
          '2.2';
      final source = _toolSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('String.fromEnvironment')));
      expect(source, isNot(contains('bool.fromEnvironment')));
      expect(source, isNot(contains('ProviderContainer')));
      expect(source, isNot(contains(loopbackHost)));
      expect(source, isNot(contains(loopbackIp)));
      expect(source, isNot(contains(emulatorHost)));
    });

    test(
      'tool source does not import transport, DTO, or backend internals',
      () {
        final source = _toolSource();

        expect(source, isNot(contains('PackageApexHttpClient')));
        expect(source, isNot(contains('ApexHttpClient')));
        expect(source, isNot(contains('package:http')));
        expect(source, isNot(contains('package:dio')));
        expect(source, isNot(contains('HttpOnlineReviewProductRepository')));
        expect(source, isNot(contains('OnlineReviewProductResponseDto')));
        expect(source, isNot(contains('online_review_product_dto.dart')));
        expect(source, isNot(contains('review_draft')));
        expect(source, isNot(contains('governance')));
        expect(source, isNot(contains('reanalysis')));
      },
    );

    test('tool source does not activate runtime UI or repositories', () {
      final source = _toolSource();

      expect(source, isNot(contains('OnlineReviewProductDevHarness')));
      expect(source, isNot(contains('online_review_product_dev_harness.dart')));
      expect(source, isNot(contains('online_review_product_shell.dart')));
      expect(source, isNot(contains('onlineReviewProductRepositoryProvider')));
      expect(source, isNot(contains('onlineReviewActivationDecisionProvider')));
    });
  });
}

String _toolSource() {
  return File('tool/online_review_build_config_report.dart').readAsStringSync();
}

String _contractDocSource() {
  return File('docs/ONLINE_REVIEW_FLUTTER_CONTRACT.md').readAsStringSync();
}

String _prTemplateSource() {
  return File('.github/PULL_REQUEST_TEMPLATE.md').readAsStringSync();
}

String _singleLine(String source) {
  return source.replaceAll(RegExp(r'\s+'), ' ');
}

List<String> _onlineReviewWorkflowSources() {
  final directory = Directory('.github/workflows');
  if (!directory.existsSync()) {
    return const [];
  }
  return [
    for (final entity in directory.listSync(recursive: true))
      if (entity is File && _isWorkflowFile(entity.path))
        if (_isOnlineReviewWorkflow(entity)) entity.readAsStringSync(),
  ];
}

bool _isWorkflowFile(String path) {
  final lowerPath = path.toLowerCase();
  return lowerPath.endsWith('.yml') || lowerPath.endsWith('.yaml');
}

bool _isOnlineReviewWorkflow(File file) {
  final source = file.readAsStringSync();
  return source.contains('online_review_build_config_report') ||
      source.contains('Online Review');
}
