import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_build_config_matrix.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_config_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewBuildConfigMatrix scenarios', () {
    test('contains all required scenario IDs', () {
      final ids = onlineReviewBuildConfigScenarios()
          .map((scenario) => scenario.id)
          .toSet();

      expect(
        ids,
        containsAll(const {
          'defaultDisabled',
          'explicitDisabledWithNoise',
          'devHarnessUiOnly',
          'devHarnessWithHttpsHttp',
          'devHarnessHttpWithoutBaseUri',
          'stagingHttpsHttp',
          'stagingHttpRejectedByDefault',
          'stagingHttpAllowedOnlyWithInsecureDevFlag',
          'internalTesterHttpsHttp',
          'publicPreviewBlockedWithoutPublicGate',
          'publicPreviewFullyExplicitPolicyShape',
          'publicPreviewInsecureHttpRejected',
          'unknownModeFallsBackDisabled',
          'invalidUriFallsBackSafe',
          'baseUriWithoutAllowHttpDoesNothing',
          'allowHttpWithoutModeDoesNothing',
        }),
      );
    });

    test('every scenario verifies successfully', () {
      final failures = verifyOnlineReviewBuildConfigMatrix()
          .where((result) => !result.passed)
          .expand((result) => result.failures)
          .toList();

      expect(failures, isEmpty);
    });

    test('default scenario stays disabled', () {
      final result = _verified('defaultDisabled');

      expect(result.config.mode, OnlineReviewRuntimeMode.disabled);
      expect(result.decision.canShowShell, isFalse);
      expect(result.decision.canUseHttp, isFalse);
      expect(result.decision.canUseDebugHarness, isFalse);
      expect(result.decision.isPublic, isFalse);
      expect(result.repositoryConfig.mode, OnlineReviewRepositoryMode.disabled);
    });

    test('scenarios use only reserved placeholder backend hosts', () {
      for (final scenario in onlineReviewBuildConfigScenarios()) {
        final raw = scenario.rawValues[OnlineReviewRuntimeConfigKeys.baseUri];
        if (raw == null || raw.trim().isEmpty) {
          continue;
        }

        final uri = Uri.tryParse(raw);
        if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
          continue;
        }

        expect(
          uri.host,
          endsWith('.example.test'),
          reason: '${scenario.id} must not use a real backend host',
        );
      }
    });

    test('no scenario uses localhost or a real production URL', () {
      const forbiddenHost =
          'local'
          'host';
      for (final scenario in onlineReviewBuildConfigScenarios()) {
        final values = scenario.rawValues.values.join(' ').toLowerCase();

        expect(values, isNot(contains(forbiddenHost)));
        expect(values, isNot(contains('127.0.0.1')));
        expect(values, isNot(contains('api.apex')));
        expect(values, isNot(contains('apex-chess')));
        expect(values, isNot(contains('apexchess')));
      }
    });

    test('HTTP is never enabled without allowHttp and baseUri', () {
      for (final result in verifyOnlineReviewBuildConfigMatrix()) {
        if (!result.decision.canUseHttp) {
          continue;
        }

        final scenario = _scenario(result.scenarioId);
        expect(
          scenario.rawValues[OnlineReviewRuntimeConfigKeys.allowHttp],
          'true',
          reason: result.scenarioId,
        );
        expect(result.decision.hasBaseUri, isTrue, reason: result.scenarioId);
        expect(result.config.baseUri, isNotNull, reason: result.scenarioId);
      }
    });

    test('public preview is never public without allowPublicEntry', () {
      for (final result in verifyOnlineReviewBuildConfigMatrix()) {
        final scenario = _scenario(result.scenarioId);
        if (scenario.expectedMode != OnlineReviewRuntimeMode.publicPreview) {
          continue;
        }
        if (scenario.rawValues[OnlineReviewRuntimeConfigKeys
                .allowPublicEntry] ==
            'true') {
          continue;
        }

        expect(result.decision.isPublic, isFalse, reason: result.scenarioId);
        expect(
          result.decision.canShowShell,
          isFalse,
          reason: result.scenarioId,
        );
      }
    });

    test('public preview never accepts insecure HTTP', () {
      final result = _verified('publicPreviewInsecureHttpRejected');

      expect(result.config.baseUri, isNull);
      expect(result.decision.canUseHttp, isFalse);
      expect(result.decision.isPublic, isFalse);
      expect(result.repositoryConfig.mode, OnlineReviewRepositoryMode.disabled);
      expect(result.warnings, contains('onlineReviewInsecureHttpRejected'));
    });

    test('repository config matches activation decision', () {
      for (final result in verifyOnlineReviewBuildConfigMatrix()) {
        if (result.decision.canUseHttp) {
          expect(
            result.repositoryConfig.mode,
            OnlineReviewRepositoryMode.http,
            reason: result.scenarioId,
          );
          expect(
            result.repositoryConfig.baseUri,
            result.decision.baseUri,
            reason: result.scenarioId,
          );
        } else {
          expect(
            result.repositoryConfig.mode,
            OnlineReviewRepositoryMode.disabled,
            reason: result.scenarioId,
          );
          expect(result.repositoryConfig.baseUri, isNull);
        }
      }
    });

    test('dev harness visibility does not imply HTTP', () {
      final result = _verified('devHarnessUiOnly');

      expect(result.decision.canShowShell, isTrue);
      expect(result.decision.canUseDebugHarness, isTrue);
      expect(result.decision.canUseHttp, isFalse);
      expect(result.repositoryConfig.mode, OnlineReviewRepositoryMode.disabled);
    });

    test('base URI presence does not imply HTTP', () {
      final result = _verified('baseUriWithoutAllowHttpDoesNothing');

      expect(result.decision.hasBaseUri, isTrue);
      expect(result.decision.canUseHttp, isFalse);
      expect(result.repositoryConfig.mode, OnlineReviewRepositoryMode.disabled);
    });

    test('unknown mode and invalid URI are safe', () {
      final unknownMode = _verified('unknownModeFallsBackDisabled');
      final invalidUri = _verified('invalidUriFallsBackSafe');

      expect(unknownMode.config.mode, OnlineReviewRuntimeMode.disabled);
      expect(unknownMode.decision.canUseHttp, isFalse);
      expect(
        unknownMode.repositoryConfig.mode,
        OnlineReviewRepositoryMode.disabled,
      );
      expect(invalidUri.decision.hasBaseUri, isFalse);
      expect(invalidUri.decision.canUseHttp, isFalse);
      expect(
        invalidUri.repositoryConfig.mode,
        OnlineReviewRepositoryMode.disabled,
      );
    });

    test('scenario safety classification is explicit', () {
      final scenarios = {
        for (final scenario in onlineReviewBuildConfigScenarios())
          scenario.id: scenario,
      };

      expect(scenarios['defaultDisabled']!.isProductionSafe, isTrue);
      expect(scenarios['explicitDisabledWithNoise']!.isProductionSafe, isTrue);
      expect(
        scenarios['publicPreviewFullyExplicitPolicyShape']!.isProductionSafe,
        isFalse,
      );
      expect(
        scenarios['publicPreviewInsecureHttpRejected']!.isDangerous,
        isTrue,
      );
      expect(
        scenarios['stagingHttpAllowedOnlyWithInsecureDevFlag']!
            .expectedWarnings,
        contains('onlineReviewInsecureHttpDevOnly'),
      );
      expect(
        _verified('stagingHttpAllowedOnlyWithInsecureDevFlag').warnings,
        contains('onlineReviewInsecureHttpDevOnly'),
      );
    });
  });

  group('OnlineReviewBuildConfigMatrix guardrails', () {
    test('verifying the matrix does not instantiate HTTP clients', () {
      final source = _matrixSource();

      expect(source, isNot(contains('PackageApexHttpClient')));
      expect(source, isNot(contains('ApexHttpClient')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
      expect(source, isNot(contains('HttpOnlineReviewProductRepository')));
      expect(verifyOnlineReviewBuildConfigMatrix(), isNotEmpty);
    });

    test('matrix source stays pure and boundary-safe', () {
      const forbiddenHost =
          'local'
          'host';
      final source = _matrixSource();

      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('review_draft')));
      expect(source, isNot(contains('governance')));
      expect(source, isNot(contains('reanalysis')));
      expect(source, isNot(contains(forbiddenHost)));
      expect(source, isNot(contains('127.0.0.1')));
      expect(source, isNot(contains('api.apex')));
      expect(source, isNot(contains('APEX_ONLINE_REVIEW_API_KEY')));
      expect(source.toLowerCase(), isNot(contains('secret')));
    });
  });
}

OnlineReviewBuildConfigScenario _scenario(String id) {
  return onlineReviewBuildConfigScenarios().singleWhere(
    (scenario) => scenario.id == id,
  );
}

OnlineReviewBuildConfigVerificationResult _verified(String id) {
  final result = verifyOnlineReviewBuildConfigScenario(_scenario(id));
  expect(result.failures, isEmpty, reason: id);
  return result;
}

String _matrixSource() {
  return File(
    'lib/features/pgn_review/infrastructure/'
    'online_review_build_config_matrix.dart',
  ).readAsStringSync();
}
