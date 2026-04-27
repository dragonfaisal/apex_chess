/// A summary of a player's strengths and weaknesses, derived **purely
/// from the local archive** of analysed games.
///
/// No network calls, no token auth — the profile is recomputed every
/// time the archive changes (Phase 6 onboarding intelligence). The
/// surface is intentionally small and concrete so the UI can read each
/// number directly without further math.
library;

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';

/// Three coarse phases of a chess game, as the analyser tags them. We
/// don't need PGN-tag fidelity here — the goal is to highlight a
/// region the player consistently mishandles.
enum GamePhase { opening, middlegame, endgame }

extension GamePhaseLabel on GamePhase {
  String get label => switch (this) {
        GamePhase.opening => 'Opening',
        GamePhase.middlegame => 'Middlegame',
        GamePhase.endgame => 'Endgame',
      };
}

class OpeningStat {
  const OpeningStat({
    required this.name,
    required this.eco,
    required this.gameCount,
    required this.winCount,
  });
  final String name;
  final String? eco;
  final int gameCount;
  final int winCount;
  double get winRate => gameCount == 0 ? 0 : winCount / gameCount * 100;
}

class PlayerProfile {
  const PlayerProfile({
    required this.gameCount,
    required this.averageAccuracy,
    required this.blundersPerGame,
    required this.mistakesPerGame,
    required this.brilliantsPerGame,
    required this.openings,
    required this.weakestPhase,
    required this.tacticalWeaknesses,
  });

  /// Pure-data empty profile so callers can render "no data yet"
  /// without null-checking every getter.
  factory PlayerProfile.empty() => const PlayerProfile(
        gameCount: 0,
        averageAccuracy: 0,
        blundersPerGame: 0,
        mistakesPerGame: 0,
        brilliantsPerGame: 0,
        openings: [],
        weakestPhase: null,
        tacticalWeaknesses: [],
      );

  /// Total number of analysed games the profile was computed from.
  final int gameCount;

  /// Win% accuracy averaged across all games (0–100). Higher is
  /// better. Computed as `100 - average_cp_loss_in_winpct`, clamped
  /// to [0, 100].
  final double averageAccuracy;

  final double blundersPerGame;
  final double mistakesPerGame;
  final double brilliantsPerGame;

  /// Top openings the player has played, sorted by frequency.
  final List<OpeningStat> openings;

  /// The phase of the game in which the player loses the most Win%.
  /// `null` when the archive is too small for a confident pick.
  final GamePhase? weakestPhase;

  /// Free-form tags that frequently apply to the player's mistakes —
  /// e.g. "missed-tactic", "hanging-piece", "king-safety". Ordered by
  /// frequency.
  final List<String> tacticalWeaknesses;

  bool get hasData => gameCount > 0;
}

/// One concrete training suggestion derived from [PlayerProfile].
///
/// Kept as a flat data class (no widgets, no theming) so the suggestions
/// can be consumed by the existing UI without forcing a redesign — the
/// caller picks where to render `headline` / `body`.
class TrainingSuggestion {
  const TrainingSuggestion({
    required this.id,
    required this.headline,
    required this.body,
    required this.severity,
  });

  /// Stable id for de-dup / persistence (e.g. `"missed-tactic"`).
  final String id;
  final String headline;
  final String body;
  final TrainingSeverity severity;
}

enum TrainingSeverity { high, medium, low }

extension TrainingSeverityLabel on TrainingSeverity {
  String get label => switch (this) {
        TrainingSeverity.high => 'High Priority',
        TrainingSeverity.medium => 'Mid Priority',
        TrainingSeverity.low => 'Polish',
      };
}

/// Bag of (quality → count) collapsed across the entire archive — kept
/// out of [PlayerProfile] to keep the latter lean. Useful for tests
/// asserting derivation correctness.
typedef AggregateQualityCounts = Map<MoveQuality, int>;
