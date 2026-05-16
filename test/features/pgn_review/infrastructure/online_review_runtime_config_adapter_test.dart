import 'dart:io';

import 'package:apex_chess/features/pgn_review/application/online_review_runtime_gate.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_runtime_config_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewRuntimeConfigAdapter parser', () {
    test('empty map returns disabled config', () {
      final config = parseOnlineReviewRuntimeGateConfig(const {});
      final decision = OnlineReviewRuntimeGate.decide(config);

      expect(config.mode, OnlineReviewRuntimeMode.disabled);
      expect(config.baseUri, isNull);
      expect(config.allowHttp, isFalse);
      expect(config.allowDebugHarness, isFalse);
      expect(config.allowPublicEntry, isFalse);
      expect(decision.isEnabled, isFalse);
      expect(decision.reasonCode, 'onlineReviewDisabled');
    });

    test('mode disabled returns disabled config', () {
      final config = parseOnlineReviewRuntimeGateConfig(const {
        OnlineReviewRuntimeConfigKeys.mode: 'disabled',
      });

      expect(config.mode, OnlineReviewRuntimeMode.disabled);
      expect(config.baseUri, isNull);
      expect(config.allowHttp, isFalse);
    });

    test('mode devHarness with debug allowed enables debug harness only', () {
      final config = parseOnlineReviewRuntimeGateConfig(const {
        OnlineReviewRuntimeConfigKeys.mode: 'devHarness',
        OnlineReviewRuntimeConfigKeys.allowDebugHarness: 'true',
      });
      final decision = OnlineReviewRuntimeGate.decide(config);

      expect(config.mode, OnlineReviewRuntimeMode.devHarness);
      expect(config.allowDebugHarness, isTrue);
      expect(config.allowHttp, isFalse);
      expect(decision.canShowShell, isTrue);
      expect(decision.canUseDebugHarness, isTrue);
      expect(decision.canUseHttp, isFalse);
      expect(decision.isPublic, isFalse);
    });

    test('mode staging with allowHttp and HTTPS baseUri can use HTTP', () {
      final config = parseOnlineReviewRuntimeGateConfig(const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: 'https://example.test',
      });
      final decision = OnlineReviewRuntimeGate.decide(config);

      expect(config.mode, OnlineReviewRuntimeMode.staging);
      expect(config.baseUri, Uri.parse('https://example.test'));
      expect(config.allowHttp, isTrue);
      expect(decision.canUseHttp, isTrue);
      expect(decision.isPublic, isFalse);
      expect(decision.warnings, isEmpty);
    });

    test('mode staging without baseUri stays incomplete for HTTP', () {
      final config = parseOnlineReviewRuntimeGateConfig(const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
      });
      final decision = OnlineReviewRuntimeGate.decide(config);

      expect(config.mode, OnlineReviewRuntimeMode.staging);
      expect(config.baseUri, isNull);
      expect(config.allowHttp, isTrue);
      expect(decision.canUseHttp, isFalse);
      expect(decision.warnings, contains('onlineReviewBaseUriMissing'));
      expect(decision.reasonCode, 'onlineReviewConfigIncomplete');
    });

    test(
      'mode internalTester with allowHttp and HTTPS baseUri is non-public',
      () {
        final config = parseOnlineReviewRuntimeGateConfig(const {
          OnlineReviewRuntimeConfigKeys.mode: 'internalTester',
          OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
          OnlineReviewRuntimeConfigKeys.baseUri: 'https://example.test',
        });
        final decision = OnlineReviewRuntimeGate.decide(config);

        expect(config.mode, OnlineReviewRuntimeMode.internalTester);
        expect(decision.canUseHttp, isTrue);
        expect(decision.canShowShell, isTrue);
        expect(decision.isPublic, isFalse);
        expect(decision.reasonCode, 'onlineReviewInternalTester');
      },
    );

    test('publicPreview without allowPublicEntry is not public', () {
      final config = parseOnlineReviewRuntimeGateConfig(const {
        OnlineReviewRuntimeConfigKeys.mode: 'publicPreview',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: 'https://example.test',
      });
      final decision = OnlineReviewRuntimeGate.decide(config);

      expect(config.mode, OnlineReviewRuntimeMode.publicPreview);
      expect(config.allowPublicEntry, isFalse);
      expect(decision.isEnabled, isFalse);
      expect(decision.canShowShell, isFalse);
      expect(decision.canUseHttp, isFalse);
      expect(decision.isPublic, isFalse);
      expect(decision.warnings, contains('onlineReviewPublicEntryNotAllowed'));
    });

    test(
      'publicPreview with explicit public and HTTP gates is policy-shaped',
      () {
        final config = parseOnlineReviewRuntimeGateConfig(const {
          OnlineReviewRuntimeConfigKeys.mode: 'publicPreview',
          OnlineReviewRuntimeConfigKeys.allowPublicEntry: 'true',
          OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
          OnlineReviewRuntimeConfigKeys.baseUri: 'https://example.test',
        });
        final decision = OnlineReviewRuntimeGate.decide(config);

        expect(config.mode, OnlineReviewRuntimeMode.publicPreview);
        expect(decision.canShowShell, isTrue);
        expect(decision.canUseHttp, isTrue);
        expect(decision.canUseDebugHarness, isFalse);
        expect(decision.isPublic, isTrue);
        expect(decision.reasonCode, 'onlineReviewPublicPreview');
        expect(decision.warnings, isEmpty);
      },
    );

    test('unknown mode normalizes to disabled', () {
      final config = parseOnlineReviewRuntimeGateConfig(const {
        OnlineReviewRuntimeConfigKeys.mode: 'surprise',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: 'https://example.test',
      });

      expect(config.mode, OnlineReviewRuntimeMode.disabled);
      expect(config.baseUri, isNull);
      expect(config.allowHttp, isFalse);
    });

    test('invalid URI becomes null and keeps HTTP unusable', () {
      final config = parseOnlineReviewRuntimeGateConfig(const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: 'not a uri',
      });
      final decision = OnlineReviewRuntimeGate.decide(config);

      expect(config.baseUri, isNull);
      expect(decision.canUseHttp, isFalse);
      expect(decision.warnings, contains('onlineReviewBaseUriMissing'));
    });

    test('http URI is rejected by default', () {
      final config = parseOnlineReviewRuntimeGateConfig(const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: 'http://example.test',
      });
      final decision = OnlineReviewRuntimeGate.decide(config);

      expect(config.baseUri, isNull);
      expect(decision.canUseHttp, isFalse);
    });

    test('http URI requires explicit insecure-dev flag and allowed mode', () {
      final staging = parseOnlineReviewRuntimeGateConfig(const {
        OnlineReviewRuntimeConfigKeys.mode: 'staging',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.allowInsecureHttpForDev: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: 'http://example.test',
      });
      final internalTester = parseOnlineReviewRuntimeGateConfig(const {
        OnlineReviewRuntimeConfigKeys.mode: 'internalTester',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.allowInsecureHttpForDev: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: 'http://example.test',
      });
      final publicPreview = parseOnlineReviewRuntimeGateConfig(const {
        OnlineReviewRuntimeConfigKeys.mode: 'publicPreview',
        OnlineReviewRuntimeConfigKeys.allowHttp: 'true',
        OnlineReviewRuntimeConfigKeys.allowPublicEntry: 'true',
        OnlineReviewRuntimeConfigKeys.allowInsecureHttpForDev: 'true',
        OnlineReviewRuntimeConfigKeys.baseUri: 'http://example.test',
      });

      expect(staging.baseUri, Uri.parse('http://example.test'));
      expect(OnlineReviewRuntimeGate.decide(staging).canUseHttp, isTrue);
      expect(internalTester.baseUri, isNull);
      expect(
        OnlineReviewRuntimeGate.decide(internalTester).canUseHttp,
        isFalse,
      );
      expect(publicPreview.baseUri, isNull);
      expect(OnlineReviewRuntimeGate.decide(publicPreview).canUseHttp, isFalse);
    });
  });

  group('OnlineReviewRuntimeConfigAdapter guardrails', () {
    test('source stays pure, URL-free, and backend-free', () {
      const forbiddenHost =
          'local'
          'host';
      final source = File(
        'lib/features/pgn_review/infrastructure/'
        'online_review_runtime_config_adapter.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('apex_http_client.dart')));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('http_online_review_product_repository')));
      expect(source, isNot(contains('apex_chess_backend')));
      expect(source, isNot(contains(forbiddenHost)));
      expect(source, isNot(contains('127.0.0.1')));
    });
  });
}
