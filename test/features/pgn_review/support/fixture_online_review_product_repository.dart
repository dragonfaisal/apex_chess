import 'dart:convert';
import 'dart:io';

import 'package:apex_chess/features/pgn_review/domain/online_review_product_adapter.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_domain.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_dto.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';

typedef FixtureTextLoader = Future<String> Function(String path);

class FixtureOnlineReviewProductRepository
    implements OnlineReviewProductRepository {
  FixtureOnlineReviewProductRepository({
    Map<ApexOnlineReviewMode, String>? fixturePaths,
    String fixtureRoot = _defaultFixtureRoot,
    FixtureTextLoader? fixtureLoader,
    OnlineReviewProductAdapter adapter = const OnlineReviewProductAdapter(),
  }) : _fixturePaths = {..._defaultFixturePaths, ...?fixturePaths},
       _fixtureRoot = fixtureRoot,
       _fixtureLoader = fixtureLoader,
       _adapter = adapter;

  static const _defaultFixtureRoot = 'test/fixtures/online_review_product';

  static const _defaultFixturePaths = {
    ApexOnlineReviewMode.onlineFast: 'success/success_fast_minimal.json',
    ApexOnlineReviewMode.onlineDeep:
        'success/success_deep_with_criticality.json',
    ApexOnlineReviewMode.dev: 'debug/debug_enabled_compact.json',
  };

  final Map<ApexOnlineReviewMode, String> _fixturePaths;
  final String _fixtureRoot;
  final FixtureTextLoader? _fixtureLoader;
  final OnlineReviewProductAdapter _adapter;

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) async {
    final relativePath = _fixturePaths[request.mode];
    if (relativePath == null) {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'fixtureNotConfigured',
          message: 'No fixture configured for requested review mode',
          isRetryable: false,
          source: 'fixture',
        ),
      );
    }

    try {
      final raw = await _loadFixture(relativePath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const ApexOnlineReviewRepositoryResult.failure(
          ApexOnlineReviewRepositoryFailure(
            code: 'invalidFixtureShape',
            message: 'Online review fixture must decode to an object',
            isRetryable: false,
            source: 'parsing',
          ),
        );
      }
      final json = decoded.map((key, value) => MapEntry(key.toString(), value));
      final dto = OnlineReviewProductResponseDto.fromJson(json);
      final review = _adapter.fromDto(dto);

      if (dto.isFailure || review.failure != null) {
        final failure = review.failure;
        return ApexOnlineReviewRepositoryResult.failure(
          ApexOnlineReviewRepositoryFailure(
            code: failure?.code ?? 'onlineReviewFailed',
            message: failure?.message ?? 'Online review failed',
            isRetryable: false,
            source: 'fixture',
          ),
          review: review,
        );
      }

      return ApexOnlineReviewRepositoryResult.success(review);
    } on FileSystemException {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'fixtureMissing',
          message: 'Online review fixture could not be loaded',
          isRetryable: false,
          source: 'fixture',
        ),
      );
    } on FormatException {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'fixtureParsingFailed',
          message: 'Online review fixture could not be parsed',
          isRetryable: false,
          source: 'parsing',
        ),
      );
    } catch (_) {
      return const ApexOnlineReviewRepositoryResult.failure(
        ApexOnlineReviewRepositoryFailure(
          code: 'fixtureUnknownFailure',
          message: 'Online review fixture analysis failed unexpectedly',
          isRetryable: false,
          source: 'unknown',
        ),
      );
    }
  }

  Future<String> _loadFixture(String relativePath) {
    final path = '$_fixtureRoot/$relativePath';
    final loader = _fixtureLoader;
    if (loader != null) return loader(path);
    return File(path).readAsString();
  }
}
