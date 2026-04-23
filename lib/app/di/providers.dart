/// Riverpod dependency injection — app-level providers.
///
/// Cloud-Only architecture — no local engine dependencies.
/// All providers that cross feature boundaries live here.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
