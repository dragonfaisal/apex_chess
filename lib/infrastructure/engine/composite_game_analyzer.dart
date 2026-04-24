/// Cloud-first game analyser with on-device fallback.
///
/// Apex Chess prefers Lichess Cloud Eval — it's deeper, free, and
/// avoids spinning up the local engine for the entire game. When the
/// cloud is unreachable / rate-limited / silent, we transparently fall
/// back to the on-device Stockfish ([LocalGameAnalyzer]) so the user
/// always gets a full timeline. Both backends emit the same
/// [AnalysisTimeline] shape so callers don't care which one ran.
library;

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/infrastructure/api/cloud_game_analyzer.dart';
import 'package:apex_chess/infrastructure/engine/local_game_analyzer.dart';

class CompositeGameAnalyzer {
  CompositeGameAnalyzer({
    required CloudGameAnalyzer cloud,
    required LocalGameAnalyzer local,
  })  : _cloud = cloud,
        _local = local;

  final CloudGameAnalyzer _cloud;
  final LocalGameAnalyzer _local;

  /// Public accessor in case a feature explicitly wants the on-device
  /// engine (e.g. opponent forensics, where we'd rather burn local CPU
  /// than rate-limit the cloud across dozens of opponent games).
  LocalGameAnalyzer get local => _local;

  /// Public accessor for the cloud analyser — exposed so unit tests can
  /// reach it directly.
  CloudGameAnalyzer get cloud => _cloud;

  Future<AnalysisTimeline> analyzeFromPgn(
    String pgn, {
    void Function(int completed, int total)? onProgress,
    int? depth,
    Duration? movetime,
  }) async {
    try {
      // Cloud knows nothing about depth/movetime — those are local-only
      // tuning knobs — so we don't forward them here.
      return await _cloud.analyzeFromPgn(pgn, onProgress: onProgress);
    } on CloudAnalysisException {
      // Offline / rate-limited / persistent server error → fall back to
      // the on-device engine. We deliberately keep the deep depth (or
      // whatever the caller passed) so the user still gets a quality
      // verdict; the slowdown is the price of cloud-down.
      return _local.analyzeFromPgn(
        pgn,
        onProgress: onProgress,
        depth: depth,
        movetime: movetime,
      );
    }
  }
}
