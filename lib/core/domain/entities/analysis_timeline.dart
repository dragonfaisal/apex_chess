/// Full-game analysis timeline — the complete analysis result.
///
/// Contains an ordered list of [MoveAnalysis] for every ply,
/// plus a Win% array for the advantage chart.
/// All data is pre-computed (by backend or mock) and consumed
/// by the UI in O(1) per ply.
library;

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'move_analysis.dart';

class AnalysisTimeline {
  /// Ordered per-move analyses (index 0 = ply 0 = White's first move).
  final List<MoveAnalysis> moves;

  /// Starting FEN (usually standard initial position).
  final String startingFen;

  /// PGN headers (Event, White, Black, Date, Result, etc.)
  final Map<String, String> headers;

  /// Win% array (White's perspective) — one value per ply for the chart.
  final List<double> winPercentages;

  const AnalysisTimeline({
    required this.moves,
    required this.startingFen,
    required this.headers,
    required this.winPercentages,
  });

  /// Total number of plies.
  int get totalPlies => moves.length;

  /// O(1) access to a specific ply's analysis.
  MoveAnalysis? operator [](int ply) {
    if (ply < 0 || ply >= moves.length) return null;
    return moves[ply];
  }

  /// Count of each quality classification.
  Map<MoveQuality, int> get qualityCounts {
    final counts = <MoveQuality, int>{};
    for (final move in moves) {
      final q = move.classification;
      counts[q] = (counts[q] ?? 0) + 1;
    }
    return counts;
  }

  /// Average centipawn loss (for accuracy display).
  double get averageCpLoss {
    if (moves.isEmpty) return 0;
    double totalLoss = 0;
    for (final m in moves) {
      totalLoss += m.deltaW < 0 ? m.deltaW.abs() : 0;
    }
    return totalLoss / moves.length;
  }
}
