/// Riverpod dependency injection — app-level providers.
///
/// Apex Chess runs an on-device engine exclusively from the UI layer:
/// `liveEvalServiceProvider` and `gameAnalyzerProvider` both resolve to the
/// local Stockfish-backed services. Legacy Lichess cloud clients remain
/// compiled in `infrastructure/api/` but are no longer reachable from any
/// view (see PR description for the rationale).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/infrastructure/engine/engine.dart';
import 'package:apex_chess/features/user_validation/data/username_validator.dart';
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
// Evaluation service — local only
// ─────────────────────────────────────────────────────────────────────────────

/// Apex AI Analyst — local, non-blocking position evaluator. Replaces the
/// previous `cloudEvalServiceProvider`.
final liveEvalServiceProvider = Provider<LocalEvalService>((ref) {
  final engine = ref.watch(stockfishEngineProvider);
  return LocalEvalService(engine: engine);
});

// ─────────────────────────────────────────────────────────────────────────────
// Full-game analyzer — local only
// ─────────────────────────────────────────────────────────────────────────────

/// Local ECO opening book — loaded once from the bundled TSV.
///
/// Evaluated lazily on first analyser invocation; failures degrade to an
/// empty book (no book-based classification, but the engine pipeline is
/// unaffected).
final ecoBookProvider = FutureProvider<EcoBook>((ref) async {
  return EcoBook.load();
});

/// Quantum Depth Scan — analyzes a full PGN via the local engine. Replaces
/// the previous `cloudGameAnalyzerProvider`.
final gameAnalyzerProvider = Provider<LocalGameAnalyzer>((ref) {
  final eval = ref.watch(liveEvalServiceProvider);
  // Hand the analyzer the book *future* directly: on the first
  // `analyzeFromPgn` call it awaits the asset load before classifying the
  // opening plies. A synchronous `.asData?.value` read would race the load
  // and silently disable book classification for the first game scanned.
  final bookFuture = ref.watch(ecoBookProvider.future);
  return LocalGameAnalyzer(eval: eval, bookFuture: bookFuture);
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
