/// Local-first game analyser with manual cloud fallback.
///
/// Apex Chess uses on-device Stockfish as the primary source of truth.
/// Lichess Cloud Eval remains injectable for explicit/manual fallback
/// flows, but automatic analysis never hits it and therefore cannot be
/// rate-limited by HTTP 429.
library;

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart'
    show AnalysisMode;
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
    AnalysisMode mode = AnalysisMode.deep,
  }) async {
    return _local.analyzeFromPgn(
      pgn,
      onProgress: onProgress,
      depth: depth,
      movetime: movetime,
      mode: mode,
    );
  }
}
