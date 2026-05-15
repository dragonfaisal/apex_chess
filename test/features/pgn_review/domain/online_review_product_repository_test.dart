import 'dart:io';

import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixture_online_review_product_repository.dart';

void main() {
  const minimalPgn = '1. e4 *';

  group('OnlineReviewProductRepository fixture behavior', () {
    test('returns a domain success result for onlineFast fixture', () async {
      final repository = FixtureOnlineReviewProductRepository();

      final result = await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: minimalPgn,
          mode: ApexOnlineReviewMode.onlineFast,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.failure, isNull);
      expect(result.review, isA<ApexOnlineReview>());
      expect(result.review!.mode, ApexOnlineReviewMode.onlineFast);
      expect(result.review!.status, ApexReviewStatus.completed);
      expect(result.review!.summary.totalPlies, 1);
      expect(result.review!.moves, hasLength(1));
    });

    test('returns a valid onlineDeep domain review', () async {
      final repository = FixtureOnlineReviewProductRepository();

      final result = await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: minimalPgn,
          mode: ApexOnlineReviewMode.onlineDeep,
          requestedDepth: 18,
          requestedMultiPv: 3,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.review!.mode, ApexOnlineReviewMode.onlineDeep);
      expect(result.review!.providerInfo.mode, ApexOnlineReviewMode.onlineDeep);
      expect(result.review!.moves.single.isCritical, isTrue);
    });

    test('returns a valid dev domain review', () async {
      final repository = FixtureOnlineReviewProductRepository();

      final result = await repository.analyze(
        const ApexOnlineReviewRequest(
          pgn: minimalPgn,
          mode: ApexOnlineReviewMode.dev,
          includeDebug: true,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.review!.mode, ApexOnlineReviewMode.dev);
      expect(result.review!.hasDebug, isTrue);
    });

    test(
      'preserves invalid PGN failure details from failure fixture',
      () async {
        final repository = FixtureOnlineReviewProductRepository(
          fixturePaths: const {
            ApexOnlineReviewMode.onlineFast: 'failure/failure_invalid_pgn.json',
          },
        );

        final result = await repository.analyze(
          const ApexOnlineReviewRequest(
            pgn: 'not a pgn',
            mode: ApexOnlineReviewMode.onlineFast,
          ),
        );

        expect(result.isSuccess, isFalse);
        expect(result.failure!.code, 'invalidPgn');
        expect(result.failure!.message, 'Invalid PGN');
        expect(result.failure!.source, 'fixture');
        expect(result.failure!.isRetryable, isFalse);
        expect(result.review, isNotNull);
        expect(result.review!.status, ApexReviewStatus.failed);
        expect(result.review!.moves, isEmpty);
        expect(result.review!.failure!.code, 'invalidPgn');
      },
    );

    test(
      'returns repository failure for invalid JSON without throwing',
      () async {
        final repository = FixtureOnlineReviewProductRepository(
          fixtureLoader: (_) async => '{ invalid json',
        );

        final result = await repository.analyze(
          const ApexOnlineReviewRequest(
            pgn: minimalPgn,
            mode: ApexOnlineReviewMode.onlineFast,
          ),
        );

        expect(result.isSuccess, isFalse);
        expect(result.review, isNull);
        expect(result.failure!.code, 'fixtureParsingFailed');
        expect(result.failure!.source, 'parsing');
      },
    );

    test(
      'returns repository failure for missing fixture without throwing',
      () async {
        final repository = FixtureOnlineReviewProductRepository(
          fixturePaths: const {
            ApexOnlineReviewMode.onlineFast: 'missing/nope.json',
          },
        );

        final result = await repository.analyze(
          const ApexOnlineReviewRequest(
            pgn: minimalPgn,
            mode: ApexOnlineReviewMode.onlineFast,
          ),
        );

        expect(result.isSuccess, isFalse);
        expect(result.review, isNull);
        expect(result.failure!.code, 'fixtureMissing');
        expect(result.failure!.source, 'fixture');
      },
    );

    test(
      'returns repository failure for DTO parsing errors without throwing',
      () async {
        final repository = FixtureOnlineReviewProductRepository(
          fixtureLoader: (_) async => '{"ok": true}',
        );

        final result = await repository.analyze(
          const ApexOnlineReviewRequest(
            pgn: minimalPgn,
            mode: ApexOnlineReviewMode.onlineFast,
          ),
        );

        expect(result.isSuccess, isFalse);
        expect(result.review, isNull);
        expect(result.failure!.code, 'fixtureParsingFailed');
        expect(result.failure!.source, 'parsing');
      },
    );

    test(
      'does not calculate official metrics or add advanced labels',
      () async {
        final repository = FixtureOnlineReviewProductRepository();
        final fast = await repository.analyze(
          const ApexOnlineReviewRequest(
            pgn: minimalPgn,
            mode: ApexOnlineReviewMode.onlineFast,
          ),
        );
        final deep = await repository.analyze(
          const ApexOnlineReviewRequest(
            pgn: minimalPgn,
            mode: ApexOnlineReviewMode.onlineDeep,
          ),
        );
        final qualities = ApexMoveQuality.values.map((value) => value.wire);

        expect(qualities, isNot(contains('Brilliant')));
        expect(qualities, isNot(contains('Great')));
        expect(qualities, isNot(contains('Miss')));
        expect(qualities, isNot(contains('Book')));
        expect(qualities, isNot(contains('Forced')));
        expect(fast.review!.summary.accuracy, isNull);
        expect(fast.review!.summary.acpl, isNull);
        expect(deep.review!.summary.accuracy, isNull);
        expect(deep.review!.summary.acpl, isNull);
      },
    );
  });

  group('OnlineReviewProductRepository boundaries', () {
    test('public repository API exposes domain models, not DTOs', () {
      final source = File(
        'lib/features/pgn_review/domain/online_review_product_repository.dart',
      ).readAsStringSync();

      expect(source, contains('Future<ApexOnlineReviewRepositoryResult>'));
      expect(source, contains('final ApexOnlineReview? review;'));
      expect(source, isNot(contains('OnlineReviewProductResponseDto')));
      expect(source, isNot(contains('online_review_product_dto.dart')));
    });

    test('fixture repository stays non-live and fixture-local', () {
      final source = File(
        'test/features/pgn_review/support/'
        'fixture_online_review_product_repository.dart',
      ).readAsStringSync();

      expect(source, contains('test/fixtures/online_review_product'));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
      expect(source, isNot(contains('flutter_riverpod')));
      expect(source, isNot(contains('package:riverpod')));
      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('C:\\apex_chess_backend')));
      expect(source, isNot(contains('/analysis/dev/online-review-product')));
    });

    test('public repository interface stays provider, UI, and backend free', () {
      final source = File(
        'lib/features/pgn_review/domain/online_review_product_repository.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:dio')));
      expect(source, isNot(contains('flutter_riverpod')));
      expect(source, isNot(contains('package:riverpod')));
      expect(source, isNot(contains('package:flutter/material.dart')));
      expect(source, isNot(contains('package:flutter/widgets.dart')));
      expect(source, isNot(contains('C:\\apex_chess_backend')));
    });
  });
}
