/// Riverpod dependency injection — app-level providers.
///
/// Cloud-first architecture with an optional local-engine escape hatch for
/// offline analysis and power-user features. All providers that cross
/// feature boundaries live here.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/infrastructure/engine/engine.dart';
import 'package:apex_chess/infrastructure/api/cloud_eval_service.dart';
import 'package:apex_chess/infrastructure/api/cloud_game_analyzer.dart';
import 'package:apex_chess/infrastructure/api/lichess_cloud_eval_client.dart';
import 'package:apex_chess/infrastructure/api/lichess_opening_client.dart';
import 'package:apex_chess/infrastructure/api/mock_analysis_api_client.dart';
import 'package:apex_chess/infrastructure/api/opening_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cloud API Clients
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton Lichess Cloud Eval HTTP client.
final lichessCloudEvalProvider = Provider<LichessCloudEvalClient>((ref) {
  final client = LichessCloudEvalClient();
  ref.onDispose(() => client.dispose());
  return client;
});

/// Singleton Lichess Opening Explorer HTTP client.
final lichessOpeningProvider = Provider<LichessOpeningClient>((ref) {
  final client = LichessOpeningClient();
  ref.onDispose(() => client.dispose());
  return client;
});

// ─────────────────────────────────────────────────────────────────────────────
// Services
// ─────────────────────────────────────────────────────────────────────────────

/// Cloud evaluation service (wraps LichessCloudEvalClient).
final cloudEvalServiceProvider = Provider<CloudEvalService>((ref) {
  final client = ref.watch(lichessCloudEvalProvider);
  return CloudEvalService(client: client);
});

/// Opening detection service (wraps LichessOpeningClient).
final openingServiceProvider = Provider<OpeningService>((ref) {
  final client = ref.watch(lichessOpeningProvider);
  return OpeningService(client: client);
});

// ─────────────────────────────────────────────────────────────────────────────
// Analyzers
// ─────────────────────────────────────────────────────────────────────────────

/// Cloud-only full game analyzer (Opening Explorer + Cloud Eval).
final cloudGameAnalyzerProvider = Provider<CloudGameAnalyzer>((ref) {
  final cloudEval = ref.watch(cloudEvalServiceProvider);
  final openings = ref.watch(openingServiceProvider);
  return CloudGameAnalyzer(cloudEval: cloudEval, openings: openings);
});

/// Mock analysis API client for development/demo.
final mockAnalysisApiProvider = Provider<MockAnalysisApiClient>((ref) {
  return const MockAnalysisApiClient();
});

// ─────────────────────────────────────────────────────────────────────────────
// Local engine (Stockfish via FFI + Isolate)
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton local [ChessEngine] backed by Stockfish.
///
/// The engine is started lazily on first `ref.watch` / `ref.read` and
/// disposed with the owning [ProviderContainer]. Feature modules that want
/// local analysis should depend on this provider instead of instantiating
/// [StockfishEngine] directly so tests can override it.
final stockfishEngineProvider = Provider<ChessEngine>((ref) {
  final engine = StockfishEngine();
  // Kick off startup without blocking provider construction. Callers that
  // need to await readiness should use `engineReadyProvider` below.
  ref.onDispose(() async {
    await engine.dispose();
  });
  return engine;
});

/// Awaitable handle that resolves once the local engine's UCI handshake
/// has completed. Widgets can `ref.watch` this to gate analysis UI behind
/// engine readiness.
final engineReadyProvider = FutureProvider<ChessEngine>((ref) async {
  final engine = ref.watch(stockfishEngineProvider);
  if (!engine.isRunning) await engine.start();
  return engine;
});
