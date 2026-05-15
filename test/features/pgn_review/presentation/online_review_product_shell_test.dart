import 'dart:async';
import 'dart:io';

import 'package:apex_chess/app/di/providers.dart';
import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/application/online_review_product_use_case.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/presentation/online_review_product_shell.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineReviewProductShell', () {
    testWidgets('renders idle state with default providers', (tester) async {
      await tester.pumpWidget(_host());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('online-review-product-shell')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('online-review-shell-idle')),
        findsOneWidget,
      );
      expect(find.text('Online Review'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('online-review-shell-submit')),
        findsOneWidget,
      );
    });

    testWidgets(
      'default submit renders disabled failure without touching HTTP',
      (tester) async {
        final client = _RecordingHttpClient();
        final container = ProviderContainer(
          overrides: [
            onlineReviewProductHttpClientProvider.overrideWithValue(client),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(_host(container: container));
        await tester.tap(
          find.byKey(const ValueKey('online-review-shell-submit')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('online-review-shell-failure')),
          findsOneWidget,
        );
        expect(
          find.text('Online Review is currently disabled in this app graph.'),
          findsOneWidget,
        );
        expect(client.calls, 0);
      },
    );

    testWidgets('renders loading while a request is pending', (tester) async {
      final repository = _PendingRepository();
      final container = _containerFor(repository);
      addTearDown(container.dispose);

      await tester.pumpWidget(_host(container: container));
      await tester.tap(
        find.byKey(const ValueKey('online-review-shell-submit')),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('online-review-shell-loading')),
        findsOneWidget,
      );
      expect(find.text('Request in progress'), findsOneWidget);

      repository.complete(ApexOnlineReviewRepositoryResult.success(_review()));
      await tester.pumpAndSettle();
    });

    testWidgets('renders success summary and move rows', (tester) async {
      final container = _containerFor(
        _RecordingRepository(
          (_) async => ApexOnlineReviewRepositoryResult.success(
            _review(totalPlies: 1, analyzedMoves: 1, moves: [_move()]),
          ),
        ),
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
      expect(
        find.byKey(const ValueKey('online-review-shell-summary')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('online-review-shell-move-row-0')),
        findsOneWidget,
      );
      expect(find.text('Best'), findsWidgets);
      expect(find.text('1 warning'), findsOneWidget);
    });

    testWidgets('retryable failure shows retry action', (tester) async {
      final container = _containerFor(
        _RecordingRepository(
          (_) async => const ApexOnlineReviewRepositoryResult.failure(
            ApexOnlineReviewRepositoryFailure(
              code: 'timeout',
              message: 'Request timed out',
              isRetryable: true,
              source: 'network',
            ),
          ),
        ),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_host(container: container));
      await tester.tap(
        find.byKey(const ValueKey('online-review-shell-submit')),
      );
      await tester.pumpAndSettle();

      expect(find.text('The review request timed out.'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('online-review-shell-retry')),
        findsOneWidget,
      );
    });

    testWidgets('retry action can advance a fake flow to success', (
      tester,
    ) async {
      final repository = _SequenceRepository(
        first: (_) async => const ApexOnlineReviewRepositoryResult.failure(
          ApexOnlineReviewRepositoryFailure(
            code: 'networkError',
            message: 'Network unavailable',
            isRetryable: true,
            source: 'network',
          ),
        ),
        next: (_) async => ApexOnlineReviewRepositoryResult.success(
          _review(totalPlies: 2, analyzedMoves: 2),
        ),
      );
      final container = _containerFor(repository);
      addTearDown(container.dispose);

      await tester.pumpWidget(_host(container: container));
      await tester.tap(
        find.byKey(const ValueKey('online-review-shell-submit')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('online-review-shell-retry')));
      await tester.pumpAndSettle();

      expect(repository.calls, 2);
      expect(
        find.byKey(const ValueKey('online-review-shell-success')),
        findsOneWidget,
      );
      expect(find.text('2'), findsWidgets);
    });

    testWidgets('reset returns the shell to idle', (tester) async {
      final container = _containerFor(
        _RecordingRepository(
          (_) async => ApexOnlineReviewRepositoryResult.success(_review()),
        ),
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_host(container: container));
      await tester.tap(
        find.byKey(const ValueKey('online-review-shell-submit')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('online-review-shell-reset')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('online-review-shell-idle')),
        findsOneWidget,
      );
    });
  });

  group('OnlineReviewProductShell guardrails', () {
    test('shell source stays on presentation seams only', () {
      final source = File(
        'lib/features/pgn_review/presentation/'
        'online_review_product_shell.dart',
      ).readAsStringSync();

      expect(source, contains('onlineReviewProductViewModelProvider'));
      expect(source, contains('onlineReviewProductActionsProvider'));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
      expect(source, isNot(contains('online_review_product_controller.dart')));
      expect(source, isNot(contains('online_review_product_use_case.dart')));
      expect(source, isNot(contains('apex_http_client.dart')));
      expect(source, isNot(contains('http_online_review_product_repository')));
      expect(source, isNot(contains('C:\\apex_chess_backend')));
    });

    test('active review pipeline still does not consume the shell seam', () {
      final providers = File('lib/app/di/providers.dart').readAsStringSync();
      final pipelineStart = providers.indexOf(
        'final reviewAnalysisPipelineProvider',
      );
      final pipelineSource = providers.substring(pipelineStart);

      expect(
        pipelineSource,
        isNot(contains('onlineReviewProductViewModelProvider')),
      );
      expect(
        pipelineSource,
        isNot(contains('onlineReviewProductActionsProvider')),
      );
      expect(pipelineSource, contains('LocalOfflineReviewProvider'));
    });
  });
}

Widget _host({ProviderContainer? container}) {
  final child = MaterialApp(
    theme: ApexTheme.dark,
    home: const Scaffold(body: OnlineReviewProductShell(pgn: '1. e4 *')),
  );
  if (container == null) {
    return ProviderScope(child: child);
  }
  return UncontrolledProviderScope(container: container, child: child);
}

ProviderContainer _containerFor(OnlineReviewProductRepository repository) {
  return ProviderContainer(
    overrides: [
      onlineReviewProductUseCaseProvider.overrideWithValue(
        OnlineReviewProductUseCase(repository: repository),
      ),
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

class _SequenceRepository implements OnlineReviewProductRepository {
  _SequenceRepository({required this.first, required this.next});

  final Future<ApexOnlineReviewRepositoryResult> Function(
    ApexOnlineReviewRequest request,
  )
  first;
  final Future<ApexOnlineReviewRepositoryResult> Function(
    ApexOnlineReviewRequest request,
  )
  next;

  int calls = 0;

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) {
    calls++;
    return calls == 1 ? first(request) : next(request);
  }
}

class _PendingRepository implements OnlineReviewProductRepository {
  final _completer = Completer<ApexOnlineReviewRepositoryResult>();

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) {
    return _completer.future;
  }

  void complete(ApexOnlineReviewRepositoryResult result) {
    _completer.complete(result);
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

ApexOnlineReview _review({
  int totalPlies = 0,
  int analyzedMoves = 0,
  List<ApexReviewedMove> moves = const [],
}) {
  return ApexOnlineReview(
    contractVersion: 'online-review-product-v1',
    mode: ApexOnlineReviewMode.onlineFast,
    status: ApexReviewStatus.completed,
    summary: ApexOnlineReviewSummary(
      totalPlies: totalPlies,
      analyzedMoves: analyzedMoves,
      failedMoves: 0,
      qualityCounts: const {},
      bestMoveCount: moves
          .where((move) => move.quality == ApexMoveQuality.best)
          .length,
      inaccuracyCount: 0,
      mistakeCount: 0,
      blunderCount: 0,
      criticalMoveCount: moves.where((move) => move.isCritical).length,
    ),
    moves: moves,
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

ApexReviewedMove _move() {
  return ApexReviewedMove(
    ply: 0,
    moveNumber: 1,
    side: 'white',
    san: 'e4',
    uci: 'e2e4',
    quality: ApexMoveQuality.best,
    confidence: ApexReviewConfidence.high,
    criticalityLevel: ApexCriticalityLevel.low,
    isCritical: false,
    isTacticalCandidate: true,
    hasMateWarning: false,
    warnings: const ['futureWarning'],
  );
}
