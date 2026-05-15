/// Non-UI repository selection for the Online Review product boundary.
library;

import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_adapter.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/http_online_review_product_repository.dart';

enum OnlineReviewRepositoryMode { disabled, fixture, http }

class OnlineReviewRepositoryConfig {
  OnlineReviewRepositoryConfig({
    this.mode = OnlineReviewRepositoryMode.disabled,
    this.baseUri,
    this.timeout = const Duration(seconds: 10),
    Map<String, String> extraHeaders = const {},
  }) : extraHeaders = Map.unmodifiable({...extraHeaders});

  factory OnlineReviewRepositoryConfig.disabled() {
    return OnlineReviewRepositoryConfig();
  }

  factory OnlineReviewRepositoryConfig.fixture() {
    return OnlineReviewRepositoryConfig(
      mode: OnlineReviewRepositoryMode.fixture,
    );
  }

  factory OnlineReviewRepositoryConfig.http({
    required Uri? baseUri,
    Duration timeout = const Duration(seconds: 10),
    Map<String, String> extraHeaders = const {},
  }) {
    return OnlineReviewRepositoryConfig(
      mode: OnlineReviewRepositoryMode.http,
      baseUri: baseUri,
      timeout: timeout,
      extraHeaders: extraHeaders,
    );
  }

  final OnlineReviewRepositoryMode mode;
  final Uri? baseUri;
  final Duration timeout;
  final Map<String, String> extraHeaders;
}

typedef FixtureOnlineReviewRepositoryBuilder =
    OnlineReviewProductRepository Function(OnlineReviewProductAdapter adapter);

class OnlineReviewRepositoryFactory {
  const OnlineReviewRepositoryFactory._();

  static OnlineReviewProductRepository create(
    OnlineReviewRepositoryConfig config, {
    ApexHttpClient? httpClient,
    OnlineReviewProductAdapter adapter = const OnlineReviewProductAdapter(),
    FixtureOnlineReviewRepositoryBuilder? fixtureBuilder,
  }) {
    return switch (config.mode) {
      OnlineReviewRepositoryMode.disabled =>
        const DisabledOnlineReviewProductRepository(),
      OnlineReviewRepositoryMode.fixture =>
        fixtureBuilder == null
            ? const DisabledOnlineReviewProductRepository(
                code: 'onlineReviewFixtureNotConfigured',
                message: 'Online review fixture repository is not configured',
              )
            : fixtureBuilder(adapter),
      OnlineReviewRepositoryMode.http =>
        config.baseUri == null
            ? const DisabledOnlineReviewProductRepository(
                code: 'onlineReviewHttpNotConfigured',
                message: 'Online review HTTP repository is not configured',
              )
            : HttpOnlineReviewProductRepository(
                baseUri: config.baseUri!,
                httpClient: httpClient ?? PackageApexHttpClient(),
                adapter: adapter,
                timeout: config.timeout,
                headers: config.extraHeaders,
              ),
    };
  }
}

class DisabledOnlineReviewProductRepository
    implements OnlineReviewProductRepository {
  const DisabledOnlineReviewProductRepository({
    this.code = 'onlineReviewDisabled',
    this.message = 'Online review repository is disabled',
  });

  final String code;
  final String message;

  @override
  Future<ApexOnlineReviewRepositoryResult> analyze(
    ApexOnlineReviewRequest request,
  ) async {
    return ApexOnlineReviewRepositoryResult.failure(
      ApexOnlineReviewRepositoryFailure(
        code: code,
        message: message,
        isRetryable: false,
        source: 'disabled',
      ),
    );
  }
}
