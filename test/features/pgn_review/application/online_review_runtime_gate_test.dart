import 'dart:io';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_repository_config.dart';
import 'package:apex_chess/features/pgn_review/presentation/online_review_product_dev_harness.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewRuntimeGate default behavior', () {
    test('default provider decision is fully disabled', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final decision = container.read(onlineReviewActivationDecisionProvider);

      expect(decision.mode, OnlineReviewRuntimeMode.disabled);
      expect(decision.isEnabled, isFalse);
      expect(decision.canShowShell, isFalse);
      expect(decision.canUseHttp, isFalse);
      expect(decision.canUseDebugHarness, isFalse);
      expect(decision.isPublic, isFalse);
      expect(decision.hasBaseUri, isFalse);
      expect(decision.baseUri, isNull);
      expect(decision.reasonCode, 'onlineReviewDisabled');
      expect(decision.warnings, isEmpty);
    });

    test('reading the activation decision has no HTTP side effect', () {
      final client = _RecordingHttpClient();
      final container = ProviderContainer(
        overrides: [
          onlineReviewProductHttpClientProvider.overrideWithValue(client),
          onlineReviewRuntimeGateConfigProvider.overrideWithValue(
            OnlineReviewRuntimeGateConfig.staging(
              allowHttp: true,
              baseUri: Uri.parse('https://example.test'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final decision = container.read(onlineReviewActivationDecisionProvider);

      expect(decision.canUseHttp, isTrue);
      expect(client.calls, 0);
    });
  });

  group('OnlineReviewRuntimeGate mode behavior', () {
    test('dev harness can show shell and debug harness without HTTP', () {
      final decision = OnlineReviewRuntimeGate.decide(
        const OnlineReviewRuntimeGateConfig.devHarness(),
      );

      expect(decision.isEnabled, isTrue);
      expect(decision.canShowShell, isTrue);
      expect(decision.canUseDebugHarness, isTrue);
      expect(decision.canUseHttp, isFalse);
      expect(decision.isPublic, isFalse);
      expect(decision.reasonCode, 'onlineReviewDevHarness');
    });

    test('dev harness HTTP still requires explicit allowHttp and baseUri', () {
      final missing = OnlineReviewRuntimeGate.decide(
        const OnlineReviewRuntimeGateConfig.devHarness(allowHttp: true),
      );
      expect(missing.canUseHttp, isFalse);
      expect(missing.warnings, contains('onlineReviewBaseUriMissing'));
      expect(missing.reasonCode, 'onlineReviewConfigIncomplete');

      final configured = OnlineReviewRuntimeGate.decide(
        OnlineReviewRuntimeGateConfig.devHarness(
          allowHttp: true,
          baseUri: Uri.parse('https://example.test'),
        ),
      );
      expect(configured.canUseHttp, isTrue);
      expect(configured.baseUri, Uri.parse('https://example.test'));
      expect(configured.isPublic, isFalse);
    });

    test('staging HTTP requires allowHttp and explicit baseUri', () {
      final missing = OnlineReviewRuntimeGate.decide(
        const OnlineReviewRuntimeGateConfig.staging(allowHttp: true),
      );
      expect(missing.isEnabled, isTrue);
      expect(missing.canShowShell, isTrue);
      expect(missing.canUseHttp, isFalse);
      expect(missing.warnings, contains('onlineReviewBaseUriMissing'));

      final configured = OnlineReviewRuntimeGate.decide(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://example.test'),
        ),
      );
      expect(configured.reasonCode, 'onlineReviewStaging');
      expect(configured.canUseHttp, isTrue);
      expect(configured.isPublic, isFalse);
    });

    test('internal tester stays non-public and requires explicit baseUri', () {
      final configured = OnlineReviewRuntimeGate.decide(
        OnlineReviewRuntimeGateConfig.internalTester(
          allowHttp: true,
          baseUri: Uri.parse('https://example.test'),
        ),
      );

      expect(configured.isEnabled, isTrue);
      expect(configured.canShowShell, isTrue);
      expect(configured.canUseHttp, isTrue);
      expect(configured.canUseDebugHarness, isFalse);
      expect(configured.isPublic, isFalse);
      expect(configured.reasonCode, 'onlineReviewInternalTester');
    });

    test(
      'public preview requires explicit public entry and transport gates',
      () {
        final blocked = OnlineReviewRuntimeGate.decide(
          const OnlineReviewRuntimeGateConfig.publicPreview(),
        );
        expect(blocked.isEnabled, isFalse);
        expect(blocked.canShowShell, isFalse);
        expect(blocked.canUseHttp, isFalse);
        expect(blocked.isPublic, isFalse);
        expect(blocked.warnings, contains('onlineReviewPublicEntryNotAllowed'));
        expect(blocked.reasonCode, 'onlineReviewPublicEntryNotAllowed');

        final publicPreview = OnlineReviewRuntimeGate.decide(
          OnlineReviewRuntimeGateConfig.publicPreview(
            allowPublicEntry: true,
            allowHttp: true,
            baseUri: Uri.parse('https://example.test'),
          ),
        );
        expect(publicPreview.isEnabled, isTrue);
        expect(publicPreview.canShowShell, isTrue);
        expect(publicPreview.canUseHttp, isTrue);
        expect(publicPreview.canUseDebugHarness, isFalse);
        expect(publicPreview.isPublic, isTrue);
        expect(publicPreview.reasonCode, 'onlineReviewPublicPreview');
        expect(publicPreview.warnings, isEmpty);
      },
    );
  });

  group('OnlineReviewRuntimeGate config relationships', () {
    test('repository config derivation is conservative', () {
      final disabled = OnlineReviewRuntimeGate.decide(
        const OnlineReviewRuntimeGateConfig.disabled(),
      );
      expect(
        onlineReviewRepositoryConfigFromActivationDecision(disabled).mode,
        OnlineReviewRepositoryMode.disabled,
      );

      final missingBaseUri = OnlineReviewRuntimeGate.decide(
        const OnlineReviewRuntimeGateConfig.staging(allowHttp: true),
      );
      expect(
        onlineReviewRepositoryConfigFromActivationDecision(missingBaseUri).mode,
        OnlineReviewRepositoryMode.disabled,
      );

      final staging = OnlineReviewRuntimeGate.decide(
        OnlineReviewRuntimeGateConfig.staging(
          allowHttp: true,
          baseUri: Uri.parse('https://example.test'),
        ),
      );
      final repositoryConfig =
          onlineReviewRepositoryConfigFromActivationDecision(staging);
      expect(repositoryConfig.mode, OnlineReviewRepositoryMode.http);
      expect(repositoryConfig.baseUri, Uri.parse('https://example.test'));
    });

    test('shell feature config derives from runtime decision', () {
      final disabledContainer = ProviderContainer();
      addTearDown(disabledContainer.dispose);
      expect(
        disabledContainer.read(onlineReviewShellFeatureConfigProvider).mode,
        OnlineReviewShellActivationMode.disabled,
      );

      final devContainer = ProviderContainer(
        overrides: [
          onlineReviewRuntimeGateConfigProvider.overrideWithValue(
            const OnlineReviewRuntimeGateConfig.devHarness(),
          ),
        ],
      );
      addTearDown(devContainer.dispose);
      final shellConfig = devContainer.read(
        onlineReviewShellFeatureConfigProvider,
      );
      expect(shellConfig.mode, OnlineReviewShellActivationMode.devHarness);
      expect(shellConfig.reasonCode, 'onlineReviewDevHarness');
    });

    test('provider overrides update the decision deterministically', () {
      final container = ProviderContainer(
        overrides: [
          onlineReviewRuntimeGateConfigProvider.overrideWithValue(
            OnlineReviewRuntimeGateConfig.internalTester(
              allowHttp: true,
              baseUri: Uri.parse('https://example.test'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final first = container.read(onlineReviewActivationDecisionProvider);
      final second = container.read(onlineReviewActivationDecisionProvider);

      expect(first.reasonCode, 'onlineReviewInternalTester');
      expect(first.canUseHttp, isTrue);
      expect(second.reasonCode, first.reasonCode);
      expect(second.canUseHttp, first.canUseHttp);
    });
  });

  group('OnlineReviewRuntimeGate guardrails', () {
    test('runtime gate and derivation sources stay pure and URL-free', () {
      final runtimeSource = File(
        'lib/features/pgn_review/application/online_review_runtime_gate.dart',
      ).readAsStringSync();
      final repositoryDerivationSource = File(
        'lib/features/pgn_review/infrastructure/'
        'online_review_runtime_repository_config.dart',
      ).readAsStringSync();

      for (final source in [runtimeSource, repositoryDerivationSource]) {
        expect(source, isNot(contains('OnlineReviewProductResponseDto')));
        expect(source, isNot(contains('online_review_product_dto.dart')));
        expect(source, isNot(contains('apex_http_client.dart')));
        expect(source, isNot(contains('package:http')));
        expect(source, isNot(contains('package:dio')));
        expect(source, isNot(contains('package:flutter/material.dart')));
        expect(source, isNot(contains('package:flutter/widgets.dart')));
        expect(source, isNot(contains('localhost')));
        expect(source, isNot(contains('127.0.0.1')));
        expect(source, isNot(contains('apex_chess_backend')));
      }
    });
  });
}

class _RecordingHttpClient extends ApexHttpClient {
  int calls = 0;

  @override
  Future<ApexHttpResponse> postJson(
    Uri uri, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    calls++;
    return const ApexHttpResponse(statusCode: 500, body: '{}');
  }
}
