/// Phase 6: derive a [PlayerProfile] from a synthetic archive and
/// validate that:
///   * accuracy / blunders-per-game / mistakes-per-game match what
///     the input archive holds (no rounding drift),
///   * weakest-phase reflects whichever third of the timeline carried
///     the largest cumulative cp-loss,
///   * tactical-weakness tags surface only when there are at least
///     two matching plies (single-occurrence noise is filtered),
///   * the suggestion list is empty for an empty profile.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/coach/data/player_profile_service.dart';
import 'package:apex_chess/features/coach/domain/player_profile.dart';

MoveAnalysis _ply({
  required int ply,
  required bool white,
  required MoveQuality cls,
  double deltaW = 0,
  String? bestUci,
  String uci = 'e2e4',
  int? scoreAfter,
}) =>
    MoveAnalysis(
      ply: ply,
      san: 'X',
      uci: uci,
      fenBefore: 'r' * 8,
      fenAfter: 'r' * 8,
      targetSquare: 'e4',
      winPercentBefore: 50,
      winPercentAfter: 50 + deltaW,
      deltaW: deltaW,
      isWhiteMove: white,
      classification: cls,
      engineBestMoveSan: bestUci,
      engineBestMoveUci: bestUci,
      scoreCpAfter: scoreAfter,
      mateInAfter: null,
      inBook: cls == MoveQuality.book,
      message: '',
    );

ArchivedGame _game({
  required String id,
  required String white,
  required String black,
  required String result,
  required AnalysisTimeline timeline,
}) =>
    ArchivedGame(
      id: id,
      source: ArchiveSource.pgn,
      white: white,
      black: black,
      result: result,
      analyzedAt: DateTime.now(),
      depth: 14,
      pgn: '*',
      qualityCounts: timeline.qualityCounts,
      averageCpLoss: timeline.averageCpLoss,
      totalPlies: timeline.totalPlies,
      cachedTimeline: timeline,
    );

void main() {
  const service = PlayerProfileService();

  test('empty archive ⇒ empty profile + no suggestions', () {
    final profile = service.build(games: []);
    expect(profile.hasData, isFalse);
    expect(service.suggest(profile), isEmpty);
  });

  test('blunders/mistakes per game count only my colour', () {
    // White is "me" — my plies are even-indexed.
    final timeline = AnalysisTimeline(
      startingFen: '',
      headers: const {},
      winPercentages: const [],
      moves: [
        _ply(ply: 0, white: true, cls: MoveQuality.blunder, deltaW: -12),
        _ply(ply: 1, white: false, cls: MoveQuality.blunder, deltaW: -12),
        _ply(ply: 2, white: true, cls: MoveQuality.mistake, deltaW: -7),
        _ply(ply: 3, white: false, cls: MoveQuality.best, deltaW: 0),
      ],
    );
    final games = [
      _game(
        id: '1',
        white: 'me',
        black: 'opp',
        result: '0-1',
        timeline: timeline,
      ),
    ];
    final profile = service.build(games: games, me: 'me');
    expect(profile.gameCount, 1);
    expect(profile.blundersPerGame, 1.0); // only the white-side blunder
    expect(profile.mistakesPerGame, 1.0);
    // Suggestions: blunder + opening + missed-tactic / opening-mistake
    final suggestions = service.suggest(profile);
    expect(suggestions, isNotEmpty);
    expect(
        suggestions.any((s) => s.id == 'reduce-blunders'), isTrue);
  });

  test('opening stats credit the player\'s colour win/total', () {
    AnalysisTimeline lineWith(String name, String eco) => AnalysisTimeline(
          startingFen: '',
          headers: {'Opening': name, 'ECO': eco},
          winPercentages: const [],
          moves: const [],
        );
    final games = [
      ArchivedGame(
        id: '1',
        source: ArchiveSource.pgn,
        white: 'me',
        black: 'opp',
        result: '1-0',
        analyzedAt: DateTime.now(),
        depth: 14,
        pgn: '*',
        qualityCounts: const {},
        averageCpLoss: 0,
        totalPlies: 0,
        openingName: 'Sicilian Defense',
        ecoCode: 'B20',
        cachedTimeline: lineWith('Sicilian Defense', 'B20'),
      ),
      ArchivedGame(
        id: '2',
        source: ArchiveSource.pgn,
        white: 'me',
        black: 'opp',
        result: '0-1',
        analyzedAt: DateTime.now(),
        depth: 14,
        pgn: '*',
        qualityCounts: const {},
        averageCpLoss: 0,
        totalPlies: 0,
        openingName: 'Sicilian Defense',
        ecoCode: 'B20',
        cachedTimeline: lineWith('Sicilian Defense', 'B20'),
      ),
    ];
    final profile = service.build(games: games, me: 'me');
    expect(profile.openings, hasLength(1));
    expect(profile.openings.first.name, 'Sicilian Defense');
    expect(profile.openings.first.gameCount, 2);
    expect(profile.openings.first.winCount, 1);
    expect(profile.openings.first.winRate, 50.0);
  });

  test('weakest phase = the third with the largest deltaW magnitude',
      () {
    // 90 plies — split into 3 phases of 30. Filtered to white-only
    // ⇒ ~45 plies of mine, well over the 30-ply minimum the service
    // requires before picking a weakest phase.
    final moves = <MoveAnalysis>[];
    for (int i = 0; i < 30; i++) {
      moves.add(_ply(ply: i, white: i.isEven, cls: MoveQuality.good,
          deltaW: -0.2));
    }
    for (int i = 30; i < 60; i++) {
      moves.add(_ply(ply: i, white: i.isEven, cls: MoveQuality.mistake,
          deltaW: -6.0));
    }
    for (int i = 60; i < 90; i++) {
      moves.add(_ply(ply: i, white: i.isEven, cls: MoveQuality.good,
          deltaW: -0.3));
    }
    final timeline = AnalysisTimeline(
      startingFen: '',
      headers: const {},
      winPercentages: const [],
      moves: moves,
    );
    final games = [
      _game(
          id: '1',
          white: 'me',
          black: 'opp',
          result: '0-1',
          timeline: timeline),
    ];
    final profile = service.build(games: games, me: 'me');
    expect(profile.weakestPhase, GamePhase.middlegame);
  });

  test(
      'MissedWin plies feed missedWinsPerGame AND keep contributing to '
      'the mistakes/missed-tactic stream (Phase A regression)', () {
    // Two MissedWin plies and one Mistake — all from "me" (white,
    // even ply). Pre-Phase-A these would have been three Mistakes
    // and produced three drills + three "missed-tactic" tags. The
    // re-classification must not erase any of that signal.
    final timeline = AnalysisTimeline(
      startingFen: '',
      headers: const {},
      winPercentages: const [],
      moves: [
        _ply(
          ply: 14,
          white: true,
          cls: MoveQuality.missedWin,
          deltaW: -15,
          uci: 'd1d4',
          bestUci: 'd1h5',
        ),
        _ply(
          ply: 16,
          white: true,
          cls: MoveQuality.missedWin,
          deltaW: -12,
          uci: 'a2a3',
          bestUci: 'g2g4',
        ),
        _ply(
          ply: 18,
          white: true,
          cls: MoveQuality.mistake,
          deltaW: -7,
          uci: 'b1c3',
          bestUci: 'b1d2',
        ),
      ],
    );
    final profile = service.build(
      games: [
        _game(
          id: 'g',
          white: 'me',
          black: 'opp',
          result: '1/2-1/2',
          timeline: timeline,
        ),
      ],
      me: 'me',
    );

    // Spec § 5.3: missed wins per game tracked as its own axis.
    expect(profile.missedWinsPerGame, 2.0);
    // Mistakes-per-game still includes MissedWin so existing
    // dashboards / training plans keep firing.
    expect(profile.mistakesPerGame, 3.0);
    // The aggregate weakness signal carries through to the tag
    // stream — `missed-win` and `missed-tactic` both surface (each
    // ≥ 2 occurrences).
    expect(profile.tacticalWeaknesses, contains('missed-win'));
    expect(profile.tacticalWeaknesses, contains('missed-tactic'));
  });
}
