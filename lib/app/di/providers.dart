/// Riverpod dependency injection — app-level providers.
///
/// Apex Chess analyses positions via a **cloud-first composite**:
///   * [gameAnalyzerProvider] resolves to a [CompositeGameAnalyzer]
///     that tries Lichess Cloud Eval first and falls back to the local
///     Stockfish engine on cloud failure (offline, rate-limited, server
///     error, persistent "position not found").
///   * [localGameAnalyzerProvider] is exposed separately for batch
///     workloads (opponent forensics scans dozens of games at once and
///     we don't want to hammer the Lichess endpoint).
///   * [liveEvalServiceProvider] still uses the local engine — the
///     review screen needs deterministic per-position evals at custom
///     depths and the cloud database doesn't expose that knob.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/infrastructure/engine/engine.dart';
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

/// Local-only Apex AI Grandmaster — exposed for batch workloads
/// (opponent forensics) where cloud-first would rate-limit aggressively.
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

/// Cloud-first PGN analyser — primary entry point for the Review
/// pipeline. Falls back to [localGameAnalyzerProvider] when Lichess is
/// unreachable so the user always gets a verdict.
final gameAnalyzerProvider = Provider<CompositeGameAnalyzer>((ref) {
  final cloud = CloudGameAnalyzer(
    cloudEval: ref.watch(cloudEvalServiceProvider),
    openings: ref.watch(openingServiceProvider),
  );
  final local = ref.watch(localGameAnalyzerProvider);
  return CompositeGameAnalyzer(cloud: cloud, local: local);
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
