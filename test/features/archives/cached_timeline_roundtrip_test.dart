/// Phase 6: validate that an [ArchivedGame] round-trips through JSON
/// **with** its full [AnalysisTimeline] attached, so re-opening from
/// the archive screen can skip the engine entirely.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';

void main() {
  test('cachedTimeline round-trips through fromJson/toJson', () {
    final timeline = AnalysisTimeline(
      startingFen:
          'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      moves: [
        MoveAnalysis(
          ply: 0,
          san: 'e4',
          uci: 'e2e4',
          fenBefore:
              'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
          fenAfter:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          targetSquare: 'e4',
          winPercentBefore: 50.0,
          winPercentAfter: 52.0,
          deltaW: 2.0,
          isWhiteMove: true,
          classification: MoveQuality.book,
          engineBestMoveSan: null,
          engineBestMoveUci: null,
          scoreCpAfter: null,
          mateInAfter: null,
          inBook: true,
          openingName: "King's Pawn Opening",
          ecoCode: 'B00',
          message: 'B00 • King\'s Pawn Opening',
        ),
        MoveAnalysis(
          ply: 1,
          san: 'c5',
          uci: 'c7c5',
          fenBefore:
              'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1',
          fenAfter:
              'rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2',
          targetSquare: 'c5',
          winPercentBefore: 52.0,
          winPercentAfter: 50.0,
          deltaW: -2.0,
          isWhiteMove: false,
          classification: MoveQuality.best,
          engineBestMoveSan: 'c5',
          engineBestMoveUci: 'c7c5',
          scoreCpAfter: 0,
          mateInAfter: null,
          inBook: false,
          message: "Best move — Apex AI's #1 choice.",
        ),
      ],
      winPercentages: [52.0, 50.0],
      headers: const {
        'White': 'A',
        'Black': 'B',
        'Result': '*',
      },
    );

    final game = ArchivedGame.fromTimeline(
      timeline: timeline,
      id: 'test-id',
      source: ArchiveSource.pgn,
      depth: 14,
      pgn: '1. e4 c5 *',
    );

    expect(game.cachedTimeline, isNotNull);
    final round = ArchivedGame.fromJson(game.toJson());
    expect(round.cachedTimeline, isNotNull);
    expect(round.cachedTimeline!.moves.length, 2);
    expect(round.cachedTimeline!.moves.first.san, 'e4');
    expect(
        round.cachedTimeline!.moves.first.classification, MoveQuality.book);
    expect(round.cachedTimeline!.moves.last.classification, MoveQuality.best);
    expect(round.cachedTimeline!.winPercentages, hasLength(2));
    expect(round.cachedTimeline!.startingFen, timeline.startingFen);
  });

  test('legacy record without cachedTimeline still parses', () {
    // Records persisted before Phase 6 don't carry the new key.
    // We must keep parsing them — the archive screen falls back to
    // re-running analysis when `cachedTimeline` is null.
    final legacy = <String, dynamic>{
      'id': 'legacy-id',
      'source': 'pgn',
      'white': 'A',
      'black': 'B',
      'result': '*',
      'analyzedAt': DateTime.now().toIso8601String(),
      'depth': 12,
      'pgn': '1. e4 *',
      'qualityCounts': {'best': 1},
      'averageCpLoss': 0.0,
      'totalPlies': 1,
    };
    final g = ArchivedGame.fromJson(legacy);
    expect(g.cachedTimeline, isNull);
    expect(g.id, 'legacy-id');
  });
}
