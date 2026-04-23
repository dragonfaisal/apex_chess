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
import 'package:apex_chess/infrastructure/engine/local_eval_service.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';
import 'package:apex_chess/infrastructure/api/mock_analysis_api_client.dart';

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

/// Quantum Depth Scan — analyzes a full PGN via the local engine. Replaces
/// the previous `cloudGameAnalyzerProvider`.
final gameAnalyzerProvider = Provider<LocalGameAnalyzer>((ref) {
  final eval = ref.watch(liveEvalServiceProvider);
  return LocalGameAnalyzer(eval: eval);
});

/// Mock analysis API client for the "Demo • Opera Game" hero.
final mockAnalysisApiProvider = Provider<MockAnalysisApiClient>((ref) {
  return const MockAnalysisApiClient();
});
