/// Derive a [PlayerProfile] + [TrainingSuggestion]s from the local
/// archive.
///
/// Pure functions — no IO, no side effects — so the same logic powers
/// the UI providers and the unit tests in
/// `test/features/coach/player_profile_service_test.dart`.
///
/// Phase 6 onboarding intelligence:
///   * after the archive holds at least one analysed game, the profile
///     reads "real" — average accuracy, blunders per game, openings,
///     weakest phase, tactical weaknesses.
///   * the training plan is a deterministic mapping over those numbers
///     so the suggestions are always justified by something the user
///     can verify in their own archive.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:apex_chess/features/coach/domain/player_profile.dart';

class PlayerProfileService {
  const PlayerProfileService();

  /// Compose a [PlayerProfile] from the supplied archive list. The
  /// `me` argument is the username we should attribute mistakes to
  /// — when supplied, we filter per-move stats to the player's *own*
  /// plies so the profile reflects them, not their opponent. When
  /// `null`, every ply across both colours contributes equally.
  PlayerProfile build({
    required List<ArchivedGame> games,
    String? me,
  }) {
    if (games.isEmpty) return PlayerProfile.empty();
    final myKey = me?.trim().toLowerCase();

    int totalPliesMine = 0;
    double totalCpLossMine = 0;
    int blundersMine = 0;
    int mistakesMine = 0;
    int brilliantsMine = 0;
    int missedWinsMine = 0;

    final phaseLoss = <GamePhase, double>{
      GamePhase.opening: 0,
      GamePhase.middlegame: 0,
      GamePhase.endgame: 0,
    };
    final phasePliesMine = <GamePhase, int>{
      GamePhase.opening: 0,
      GamePhase.middlegame: 0,
      GamePhase.endgame: 0,
    };
    final tacticTags = <String, int>{};

    final openingByName = <String, _OpeningAccumulator>{};

    for (final g in games) {
      // Did the player play this game? When `me` is null we treat
      // both colours' moves as "mine".
      final playedAsWhite = myKey != null && g.white.toLowerCase() == myKey;
      final playedAsBlack = myKey != null && g.black.toLowerCase() == myKey;
      final filterByColour = myKey != null;

      // Opening usage — credit the player's colour outcome.
      if (g.openingName != null) {
        final won = (playedAsWhite && g.result == '1-0') ||
            (playedAsBlack && g.result == '0-1');
        final acc = openingByName.putIfAbsent(
          g.openingName!,
          () => _OpeningAccumulator(eco: g.ecoCode),
        );
        acc.games += 1;
        if (myKey != null && won) acc.wins += 1;
      }

      final timeline = g.cachedTimeline;
      if (timeline == null) continue;

      for (final m in timeline.moves) {
        if (filterByColour) {
          final isMine =
              (playedAsWhite && m.isWhiteMove) ||
                  (playedAsBlack && !m.isWhiteMove);
          if (!isMine) continue;
        }

        // Tally per-quality counters for the *player's* moves.
        // Phase A note: MissedWin is tracked as its own axis (per
        // spec § 5.3 `missed_wins_per_game`) AND counted alongside
        // mistakes so the existing tactical-weakness derivation
        // (missed-tactic, opening-mistake, endgame-conversion, …)
        // continues to fire on plies that were classified as
        // Mistake under the old thresholds and now read as Missed
        // Win under the Phase A re-classification.
        switch (m.classification) {
          case MoveQuality.blunder:
            blundersMine += 1;
            tacticTags['blunder'] =
                (tacticTags['blunder'] ?? 0) + 1;
            break;
          case MoveQuality.mistake:
            mistakesMine += 1;
            tacticTags['mistake'] = (tacticTags['mistake'] ?? 0) + 1;
            break;
          case MoveQuality.missedWin:
            missedWinsMine += 1;
            mistakesMine += 1;
            tacticTags['missed-win'] =
                (tacticTags['missed-win'] ?? 0) + 1;
            tacticTags['mistake'] = (tacticTags['mistake'] ?? 0) + 1;
            break;
          case MoveQuality.brilliant:
            brilliantsMine += 1;
            break;
          default:
            break;
        }

        // Accumulate cp-loss-as-winpct for the accuracy number. We
        // already have `deltaW` (signed) — it's negative for the
        // player when they lost ground, so we take the absolute
        // value of negative drops.
        final loss = m.deltaW < 0 ? m.deltaW.abs() : 0.0;
        totalCpLossMine += loss;
        totalPliesMine += 1;

        final phase = _classifyPhase(m, timeline.totalPlies);
        phaseLoss[phase] = (phaseLoss[phase] ?? 0) + loss;
        phasePliesMine[phase] = (phasePliesMine[phase] ?? 0) + 1;

        // Tactical weakness tags — derived from the analyser's per-
        // ply data, not from a separate engine pass. We mark a ply
        // as "missed-tactic" when the player failed to play the
        // engine's #1 *and* it was a Mistake/Blunder, "hanging-
        // piece" when a Blunder followed a non-capture by the
        // *opponent* (best-effort — the analyser doesn't yet
        // surface explicit hangs, so this is a heuristic), and
        // "king-safety" when a Mistake/Blunder happened on or near
        // the player's king file inside the first 25 plies.
        if (m.classification == MoveQuality.blunder ||
            m.classification == MoveQuality.mistake ||
            m.classification == MoveQuality.missedWin) {
          if (m.engineBestMoveUci != null &&
              m.engineBestMoveUci != m.uci) {
            tacticTags['missed-tactic'] =
                (tacticTags['missed-tactic'] ?? 0) + 1;
          }
          if (m.scoreCpAfter != null && m.scoreCpAfter!.abs() >= 250) {
            tacticTags['hanging-piece'] =
                (tacticTags['hanging-piece'] ?? 0) + 1;
          }
          if (m.ply <= 25 &&
              (m.targetSquare.startsWith('e') ||
                  m.targetSquare.startsWith('f') ||
                  m.targetSquare.startsWith('g'))) {
            tacticTags['king-safety'] =
                (tacticTags['king-safety'] ?? 0) + 1;
          }
          if (timeline.totalPlies > 60 &&
              m.ply >= timeline.totalPlies - 20) {
            tacticTags['endgame-conversion'] =
                (tacticTags['endgame-conversion'] ?? 0) + 1;
          }
          if (m.ply <= 12) {
            tacticTags['opening-mistake'] =
                (tacticTags['opening-mistake'] ?? 0) + 1;
          }
        }
      }
    }

    final accuracy = totalPliesMine == 0
        ? 0.0
        : (100.0 - (totalCpLossMine / totalPliesMine)).clamp(0.0, 100.0);

    GamePhase? weakest;
    if (totalPliesMine >= 30) {
      double worstAvg = -1;
      phaseLoss.forEach((phase, loss) {
        final n = phasePliesMine[phase] ?? 0;
        if (n < 5) return;
        final avg = loss / n;
        if (avg > worstAvg) {
          worstAvg = avg;
          weakest = phase;
        }
      });
    }

    final openings = openingByName.entries
        .map((e) => OpeningStat(
              name: e.key,
              eco: e.value.eco,
              gameCount: e.value.games,
              winCount: e.value.wins,
            ))
        .toList()
      ..sort((a, b) => b.gameCount.compareTo(a.gameCount));

    final tags = tacticTags.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final tagNames = tags
        .where((e) => e.value >= 2)
        .take(5)
        .map((e) => e.key)
        .toList();

    return PlayerProfile(
      gameCount: games.length,
      averageAccuracy: accuracy.toDouble(),
      blundersPerGame: blundersMine / games.length,
      mistakesPerGame: mistakesMine / games.length,
      brilliantsPerGame: brilliantsMine / games.length,
      missedWinsPerGame: missedWinsMine / games.length,
      openings: openings,
      weakestPhase: weakest,
      tacticalWeaknesses: tagNames,
    );
  }

  /// Generate one or more [TrainingSuggestion]s ordered by severity.
  /// Every suggestion is justified by a number the caller can read
  /// off [PlayerProfile] — there is no engine call here.
  List<TrainingSuggestion> suggest(PlayerProfile profile) {
    if (!profile.hasData) return const [];
    final out = <TrainingSuggestion>[];

    if (profile.blundersPerGame >= 1.5) {
      out.add(TrainingSuggestion(
        id: 'reduce-blunders',
        headline: 'Cut your blunders in half',
        body: 'You average ${profile.blundersPerGame.toStringAsFixed(1)} '
            'blunders per game. Spend a few minutes a day on tactics '
            'puzzles and double-check long captures before committing.',
        severity: TrainingSeverity.high,
      ));
    } else if (profile.blundersPerGame >= 0.6) {
      out.add(TrainingSuggestion(
        id: 'reduce-blunders',
        headline: 'Tighten up tactical vision',
        body: 'Blunders/game: ${profile.blundersPerGame.toStringAsFixed(1)}. '
            'Try a daily 10-puzzle warm-up before rated play.',
        severity: TrainingSeverity.medium,
      ));
    }

    if (profile.weakestPhase != null) {
      final phase = profile.weakestPhase!;
      out.add(TrainingSuggestion(
        id: 'phase-${phase.name}',
        headline: 'Strengthen your ${phase.label.toLowerCase()}',
        body: 'Your largest Win% drops happen in the ${phase.label}. '
            'Focus the next training block on ${phase.label.toLowerCase()} '
            'patterns and re-visit the move report from your worst games.',
        severity: TrainingSeverity.medium,
      ));
    }

    for (final tag in profile.tacticalWeaknesses.take(3)) {
      final headline = switch (tag) {
        'missed-tactic' => 'Missed-tactic drills',
        'missed-win' => 'Convert your wins',
        'hanging-piece' => 'Stop hanging pieces',
        'king-safety' => 'Improve king safety',
        'endgame-conversion' => 'Convert winning endgames',
        'opening-mistake' => 'Polish your openings',
        _ => 'Recurring weakness: $tag',
      };
      final body = switch (tag) {
        'missed-tactic' =>
          'Several positions had a winning combination you missed. '
              'Try the Apex AI tactical sets at level 1500+ for 15 minutes a day.',
        'missed-win' =>
          'You repeatedly reached winning positions and let the advantage '
              'slip. Replay your best games from the archive and force '
              'yourself to find the most accurate move at every turn.',
        'hanging-piece' =>
          'Multiple games featured loose pieces. Before committing a move, '
              'list every undefended piece on both sides.',
        'king-safety' =>
          'Errors clustered near your king during the opening. Slow down '
              'when the centre opens and prioritise castling early.',
        'endgame-conversion' =>
          'You picked up advantages but let them slip late. Drill basic '
              'rook + pawn endings until they\'re automatic.',
        'opening-mistake' =>
          'Most of your worst moves landed in the first 12 plies. Lock '
              'in one solid repertoire for each colour.',
        _ => 'Review the games tagged with this weakness in your archive.',
      };
      out.add(TrainingSuggestion(
        id: tag,
        headline: headline,
        body: body,
        severity: TrainingSeverity.medium,
      ));
    }

    if (profile.averageAccuracy >= 92 && out.isEmpty) {
      out.add(const TrainingSuggestion(
        id: 'maintain',
        headline: 'Maintain peak accuracy',
        body: 'Your accuracy is consistently above 92%. Keep the same '
            'routine — solve a handful of harder tactics each week to '
            'stay sharp.',
        severity: TrainingSeverity.low,
      ));
    }

    return out;
  }

  /// Heuristic mapping of a ply to a coarse phase. Splits the game into
  /// thirds and forces the first 12 plies (book territory) into
  /// [GamePhase.opening] regardless of total length, so a long game
  /// doesn't accidentally classify move 4 as middlegame.
  GamePhase _classifyPhase(MoveAnalysis m, int totalPlies) {
    if (m.ply < 12) return GamePhase.opening;
    if (totalPlies <= 0) return GamePhase.middlegame;
    final third = totalPlies ~/ 3;
    if (m.ply < third) return GamePhase.opening;
    if (m.ply < third * 2) return GamePhase.middlegame;
    return GamePhase.endgame;
  }
}

class _OpeningAccumulator {
  _OpeningAccumulator({this.eco});
  final String? eco;
  int games = 0;
  int wins = 0;
}

/// Riverpod surface — recomputes whenever the archive changes. Reads
/// the player's username off the [archiveControllerProvider]'s filter
/// state so the same profile reflects the user the UI is currently
/// viewing.
final playerProfileProvider = Provider<PlayerProfile>((ref) {
  final state = ref.watch(archiveControllerProvider);
  const service = PlayerProfileService();
  return service.build(
    games: state.games,
    me: state.filters.perspective,
  );
});

final trainingSuggestionsProvider = Provider<List<TrainingSuggestion>>((ref) {
  final profile = ref.watch(playerProfileProvider);
  const service = PlayerProfileService();
  return service.suggest(profile);
});
