import 'dart:io';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_use_case.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:apex_chess/features/pgn_review/presentation/online_review_product_dev_harness.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReview shell activation gate', () {
    test('defaults to disabled', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final config = container.read(onlineReviewShellFeatureConfigProvider);
      expect(config.mode, OnlineReviewShellActivationMode.disabled);
      expect(config.isEnabled, isFalse);
    });

    testWidgets('default harness render stays disabled and hides the shell', (
      tester,
    ) async {
      await tester.pumpWidget(_host());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('online-review-dev-harness-disabled')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('online-review-product-shell')),
        findsNothing,
      );
      expect(find.text('Online Review dev harness'), findsOneWidget);
    });

    testWidgets('enabled override exposes the guarded shell', (tester) async {
      final container = _enabledContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_host(container: container));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('online-review-dev-harness')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('online-review-product-shell')),
        findsOneWidget,
      );
      expect(find.text('Online Review Dev Harness'), findsOneWidget);
    });

    testWidgets(
      'enabled harness keeps repository disabled and makes no HTTP calls by default',
      (tester) async {
        final httpClient = _RecordingHttpClient();
        final container = _enabledContainer(
          extraOverrides: [
            onlineReviewProductHttpClientProvider.overrideWithValue(httpClient),
          ],
        );
        addTearDown(container.dispose);

        expect(
          container.read(onlineReviewRepositoryConfigProvider).mode,
          OnlineReviewRepositoryMode.disabled,
        );

        await tester.pumpWidget(_host(container: container));
        await tester.tap(
          find.byKey(const ValueKey('online-review-shell-submit')),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Online Review is currently disabled in this app graph.'),
          findsOneWidget,
        );
        expect(httpClient.calls, 0);
      },
    );

    testWidgets('enabled harness can render fake success overrides', (
      tester,
    ) async {
      final container = _enabledContainer(
        extraOverrides: [
          onlineReviewProductUseCaseProvider.overrideWithValue(
            OnlineReviewProductUseCase(
              repository: _RecordingRepository(
                (_) async =>
                    ApexOnlineReviewRepositoryResult.success(_review()),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_host(container: container));
      await tester.tap(
        find.byKey(const ValueKey('online-review-shell-submit')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('online-review-shell-success')),
        findsOneWidget,
      );
    });
  });

  group('OnlineReviewProductDevHarness guardrails', () {
    test('harness source stays activation-only and transport-free', () {
      final source = File(
        'lib/features/pgn_review/presentation/'
        'online_review_product_dev_harness.dart',
      ).readAsStringSync();

      expect(source, contains('onlineReviewShellFeatureConfigProvider'));
      expect(source, contains('OnlineReviewProductShell'));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('apex_http_client.dart')));
      expect(source, isNot(contains('http_online_review_product_repository')));
      expect(source, isNot(contains('online_review_product_controller.dart')));
      expect(source, isNot(contains('online_review_product_use_case.dart')));
      expect(source, isNot(contains('C:\\apex_chess_backend')));
    });

    test('main app paths do not expose the harness by default', () {
      final mainSource = File('lib/main.dart').readAsStringSync();
      final homeSource = File(
        'lib/features/home/presentation/views/home_screen.dart',
      ).readAsStringSync();

      expect(mainSource, isNot(contains('OnlineReviewProductDevHarness')));
      expect(homeSource, isNot(contains('OnlineReviewProductDevHarness')));
      expect(
        mainSource,
        isNot(contains('onlineReviewShellFeatureConfigProvider')),
      );
      expect(
        homeSource,
        isNot(contains('onlineReviewShellFeatureConfigProvider')),
      );
    });

    test('active review pipeline remains offline/local preserving', () {
      final providers = File('lib/app/di/providers.dart').readAsStringSync();
      final pipelineStart = providers.indexOf(
        'final reviewAnalysisPipelineProvider',
      );
      final pipelineSource = providers.substring(pipelineStart);

      expect(
        pipelineSource,
        isNot(contains('onlineReviewShellFeatureConfigProvider')),
      );
      expect(pipelineSource, contains('LocalOfflineReviewProvider'));
    });
  });
}

Widget _host({ProviderContainer? container}) {
  final child = MaterialApp(
    theme: ApexTheme.dark,
    home: const OnlineReviewProductDevHarness(),
  );
  if (container == null) {
    return ProviderScope(child: child);
  }
  return UncontrolledProviderScope(container: container, child: child);
}

ProviderContainer _enabledContainer({
  List<Override> extraOverrides = const [],
}) {
  return ProviderContainer(
    overrides: [
      onlineReviewShellFeatureConfigProvider.overrideWithValue(
        const OnlineReviewShellFeatureConfig.devHarness(),
      ),
      ...extraOverrides,
    ],
  );
}

class _RecordingRepository implements OnlineReviewProductRepository {
  _RecordingRepository(this._handler);

  final Future<ApexOnlineReviewRepositoryResult> Function(
    ApexOnlineReviewRequest request,
  )
  _handler;

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) {
    return _handler(request);
  }
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

ApexOnlineReview _review() {
  return ApexOnlineReview(
    contractVersion: 'online-review-product-v1',
    mode: ApexOnlineReviewMode.onlineFast,
    status: ApexReviewStatus.completed,
    summary: ApexOnlineReviewSummary(
      totalPlies: 1,
      analyzedMoves: 1,
      failedMoves: 0,
      qualityCounts: const {},
      bestMoveCount: 1,
      inaccuracyCount: 0,
      mistakeCount: 0,
      blunderCount: 0,
      criticalMoveCount: 0,
    ),
    moves: const [],
    providerInfo: const ApexReviewProviderInfo(
      provider: 'fake',
      engine: 'none',
      analysisVersion: 'test',
      classifierVersion: 'test',
      productContractVersion: 'online-review-product-v1',
      mode: ApexOnlineReviewMode.onlineFast,
      targetDepthTier: 'test',
      isExecutionHintOnly: true,
    ),
  );
}
