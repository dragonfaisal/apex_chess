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

  /// Average centipawn loss for plies played by the White side.
  ///
  /// Used by the archive card to surface per-colour accuracy. When the
  /// user knows which colour they played (imported Chess.com / Lichess
  /// game), we show "You: X ACPL · Opponent: Y ACPL" instead of the
  /// single aggregate number — the Phase A audit flagged the latter as
  /// misleading because it blends the user's accuracy with the
  /// opponent's.
  double get averageCpLossWhite => _acplForSide(isWhite: true);

  /// Average centipawn loss for plies played by the Black side.
  double get averageCpLossBlack => _acplForSide(isWhite: false);

  double _acplForSide({required bool isWhite}) {
    double total = 0;
    int count = 0;
    for (final m in moves) {
      if (m.isWhiteMove != isWhite) continue;
      count++;
      total += m.deltaW < 0 ? m.deltaW.abs() : 0;
    }
    return count == 0 ? 0 : total / count;
  }

  // ── Serialisation ──────────────────────────────────────────────
  // Persisted alongside [ArchivedGame] so the archive can re-open a
  // game **instantly** instead of replaying the entire engine
  // pipeline. Heavy fields (per-ply FEN strings) dominate the size,
  // but a typical 60-move game lands at ~15–25 KB JSON which is
  // trivial for Hive's `Box<String>` to hold.

  Map<String, dynamic> toJson() => {
        'startingFen': startingFen,
        'headers': headers,
        'winPercentages': winPercentages,
        'moves': moves.map((m) => m.toJson()).toList(growable: false),
      };

  factory AnalysisTimeline.fromJson(Map<dynamic, dynamic> j) {
    final headersRaw = (j['headers'] as Map?) ?? const {};
    final winsRaw = (j['winPercentages'] as List?) ?? const [];
    final movesRaw = (j['moves'] as List?) ?? const [];
    return AnalysisTimeline(
      startingFen: j['startingFen'] as String? ?? '',
      headers: {
        for (final e in headersRaw.entries)
          e.key.toString(): e.value?.toString() ?? '',
      },
      winPercentages: [
        for (final v in winsRaw) (v as num).toDouble(),
      ],
      moves: [
        for (final m in movesRaw)
          MoveAnalysis.fromJson(m as Map),
      ],
    );
  }
}
