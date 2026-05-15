/// Riverpod dependency injection — app-level providers.
///
/// Apex Chess analyses positions via a **local-first composite**:
///   * [gameAnalyzerProvider] resolves to a [CompositeGameAnalyzer]
///     that uses local Stockfish as the automatic source of truth.
///   * [localGameAnalyzerProvider] is exposed separately for batch
///     workloads and forensics.
///   * [liveEvalServiceProvider] still uses the local engine — the
///     review screen needs deterministic per-position evals at custom
///     depths and the cloud database doesn't expose that knob.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/infrastructure/engine/engine.dart';
import 'package:apex_chess/core/network/apex_http_client.dart';
import 'package:apex_chess/features/archives/data/archive_repository.dart';
import 'package:apex_chess/features/pgn_review/domain/analysis_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/http_online_review_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_api_contract.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_adapter.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_product_repository.dart';
import 'package:apex_chess/features/pgn_review/domain/online_review_provider.dart';
import 'package:apex_chess/features/pgn_review/domain/review_analysis_provider.dart';
import 'package:apex_chess/features/pgn_review/infrastructure/online_review_product_repository_factory.dart';
import 'package:apex_chess/features/user_validation/data/username_validator.dart';
import 'package:apex_chess/infrastructure/api/cloud_eval_service.dart';
import 'package:apex_chess/infrastructure/api/cloud_game_analyzer.dart';
import 'package:apex_chess/infrastructure/api/lichess_cloud_eval_client.dart';
import 'package:apex_chess/infrastructure/api/lichess_opening_client.dart';
import 'package:apex_chess/infrastructure/api/opening_service.dart';
import 'package:apex_chess/infrastructure/engine/composite_game_analyzer.dart';
import 'package:apex_chess/infrastructure/engine/eco_book.dart';
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local engine (Stockfish via FFI + Isolate)
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton local [ChessEngine] backed by Stockfish.
///
/// The engine is started lazily on first `ref.watch` / `ref.read` and
/// disposed with the owning [ProviderContainer]. Tests can override this
/// provider with a `FakeEngine`.
final stockfishEngineProvider = Provider<ChessEngine>((ref) {
  final engine = StockfishEngine();
  ref.onDispose(() async {
    await engine.dispose();
  });
  return engine;
});

/// Awaitable handle that resolves once the engine's UCI handshake has
/// completed. Widgets can `ref.watch` this to gate analysis UI behind
/// engine readiness.
final engineReadyProvider = FutureProvider<ChessEngine>((ref) async {
  final engine = ref.watch(stockfishEngineProvider);
  if (!engine.isRunning) await engine.start();
  return engine;
});

// ─────────────────────────────────────────────────────────────────────────────
// Evaluation service — local only (live review needs custom depth)
// ─────────────────────────────────────────────────────────────────────────────

/// Apex AI Analyst — local, non-blocking position evaluator.
final liveEvalServiceProvider = Provider<LocalEvalService>((ref) {
  final engine = ref.watch(stockfishEngineProvider);
  return LocalEvalService(engine: engine);
});

// ─────────────────────────────────────────────────────────────────────────────
// Cloud + opening clients
// ─────────────────────────────────────────────────────────────────────────────

/// Lichess Cloud Eval client — wraps the free `/api/cloud-eval` endpoint
/// with a 30-day in-memory cache and a 429 circuit breaker.
final cloudEvalServiceProvider = Provider<CloudEvalService>((ref) {
  final client = LichessCloudEvalClient();
  final svc = CloudEvalService(client: client);
  ref.onDispose(svc.dispose);
  return svc;
});

/// Lichess Opening Explorer — backs the book classification + ECO
/// metadata path. Cached server-side; the client only adds in-memory
/// caching and exponential backoff.
final openingServiceProvider = Provider<OpeningService>((ref) {
  final client = LichessOpeningClient();
  final svc = OpeningService(client: client);
  ref.onDispose(svc.dispose);
  return svc;
});

// ─────────────────────────────────────────────────────────────────────────────
// Full-game analysers
// ─────────────────────────────────────────────────────────────────────────────

/// Local ECO opening book — loaded once from the bundled TSV.
///
/// Evaluated lazily on first analyser invocation; failures degrade to an
/// empty book (no book-based classification, but the engine pipeline is
/// unaffected).
final ecoBookProvider = FutureProvider<EcoBook>((ref) async {
  return EcoBook.load();
});

/// Local-only Apex AI Grandmaster.
final localGameAnalyzerProvider = Provider<LocalGameAnalyzer>((ref) {
  final eval = ref.watch(liveEvalServiceProvider);
  // Hand the analyzer the book *future* directly: on the first
  // `analyzeFromPgn` call it awaits the asset load before classifying
  // the opening plies. A synchronous `.asData?.value` read would race
  // the load and silently disable book classification for the first
  // game scanned.
  final bookFuture = ref.watch(ecoBookProvider.future);
  return LocalGameAnalyzer(eval: eval, bookFuture: bookFuture);
});

/// Local-first PGN analyser — primary entry point for the Review pipeline.
final gameAnalyzerProvider = Provider<CompositeGameAnalyzer>((ref) {
  final cloud = CloudGameAnalyzer(
    cloudEval: ref.watch(cloudEvalServiceProvider),
    openings: ref.watch(openingServiceProvider),
  );
  final local = ref.watch(localGameAnalyzerProvider);
  return CompositeGameAnalyzer(cloud: cloud, local: local);
});

final onlineReviewHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

// ─────────────────────────────────────────────────────────────────────────────
// Online Review product repository — registered, but disabled by default
// ─────────────────────────────────────────────────────────────────────────────

final onlineReviewRepositoryConfigProvider =
    Provider<OnlineReviewRepositoryConfig>((ref) {
      return OnlineReviewRepositoryConfig.disabled();
    });

final onlineReviewProductAdapterProvider = Provider<OnlineReviewProductAdapter>(
  (ref) {
    return const OnlineReviewProductAdapter();
  },
);

final onlineReviewProductHttpClientProvider = Provider<ApexHttpClient>((ref) {
  final client = PackageApexHttpClient();
  ref.onDispose(client.close);
  return client;
});

final onlineReviewProductRepositoryProvider =
    Provider<OnlineReviewProductRepository>((ref) {
      final config = ref.watch(onlineReviewRepositoryConfigProvider);
      final httpClient =
          config.mode == OnlineReviewRepositoryMode.http &&
              config.baseUri != null
          ? ref.watch(onlineReviewProductHttpClientProvider)
          : null;
      return OnlineReviewRepositoryFactory.create(
        config,
        httpClient: httpClient,
        adapter: ref.watch(onlineReviewProductAdapterProvider),
      );
    });

final onlineFastReviewProvider = Provider<OnlineReviewProvider>((ref) {
  final config = OnlineReviewProviderConfig.fromEnvironment(
    AnalysisReviewMode.onlineFast,
  );
  if (!config.isConfigured) {
    return DisabledOnlineReviewProvider(config: config);
  }
  return HttpOnlineReviewProvider(
    mode: AnalysisReviewMode.onlineFast,
    config: config,
    httpClient: ref.watch(onlineReviewHttpClientProvider),
  );
});

final onlineDeepReviewProvider = Provider<OnlineReviewProvider>((ref) {
  final config = OnlineReviewProviderConfig.fromEnvironment(
    AnalysisReviewMode.onlineDeep,
  );
  if (!config.isConfigured) {
    return DisabledOnlineReviewProvider(config: config);
  }
  return HttpOnlineReviewProvider(
    mode: AnalysisReviewMode.onlineDeep,
    config: config,
    httpClient: ref.watch(onlineReviewHttpClientProvider),
  );
});

/// Shared review pipeline. All analysis entry points should call this instead
/// of directly invoking a screen-local analyzer.
final reviewAnalysisPipelineProvider = FutureProvider<GameReviewPipeline>((
  ref,
) async {
  final analyzer = ref.watch(gameAnalyzerProvider);
  final cache = await ArchiveRepository.open();
  return GameReviewPipeline(
    fastProvider: OnlineReviewAnalysisProvider(
      onlineProvider: ref.watch(onlineFastReviewProvider),
      profile: AnalysisProfile.fastReview,
    ),
    deepProvider: OnlineReviewAnalysisProvider(
      onlineProvider: ref.watch(onlineDeepReviewProvider),
      profile: AnalysisProfile.deepReview,
    ),
    offlineProvider: LocalOfflineReviewProvider(analyzer),
    cacheRepository: cache,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Username existence validator (Chess.com + Lichess)
// ─────────────────────────────────────────────────────────────────────────────

/// Shared [UsernameValidator] — a thin HTTP client wrapping the two
/// providers' public profile endpoints. The debounce + stale-guard
/// logic lives in the per-screen [UsernameValidationController] that
/// consumes this provider.
final usernameValidatorProvider = Provider<UsernameValidator>((ref) {
  final validator = UsernameValidator();
  ref.onDispose(validator.dispose);
  return validator;
});
