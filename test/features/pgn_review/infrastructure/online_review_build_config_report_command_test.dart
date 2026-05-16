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

    test('output contains no local endpoints, production URLs, or secrets', () {
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
      const secretToken =
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
      expect(output, isNot(contains(secretToken)));
    });
  });

  group('Online Review build config report command guardrails', () {
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
