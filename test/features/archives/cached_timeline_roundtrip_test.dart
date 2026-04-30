/// Phase 6: validate that an [ArchivedGame] round-trips through JSON
/// **with** its full [AnalysisTimeline] attached, so re-opening from
/// the archive screen can skip the engine entirely.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';

void main() {
  test('cachedTimeline round-trips through fromJson/toJson', () {
    final timeline = AnalysisTimeline(
      startingFen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      moves: [
        MoveAnalysis(
          ply: 0,
          san: 'e4',
          uci: 'e2e4',
          fenBefore: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
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
          openingStatus: OpeningStatus.bookTheory,
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
          openingStatus: OpeningStatus.bookDeviation,
          engineLines: const [
            EngineLine(
              rank: 1,
              moveUci: 'c7c5',
              moveSan: 'c5',
              scoreCp: 0,
              depth: 14,
              whiteWinPercent: 50.0,
              pvMoves: ['c7c5'],
            ),
          ],
          message: "Best move — Apex AI's #1 choice.",
        ),
      ],
      winPercentages: [52.0, 50.0],
      headers: const {'White': 'A', 'Black': 'B', 'Result': '*'},
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
    expect(round.cachedTimeline!.moves.first.classification, MoveQuality.book);
    expect(round.cachedTimeline!.moves.last.classification, MoveQuality.best);
    expect(
      round.cachedTimeline!.moves.first.openingStatus,
      OpeningStatus.bookTheory,
    );
    expect(round.cachedTimeline!.moves.last.engineLines.single.moveSan, 'c5');
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
    // Phase A integration audit: legacy records pre-date the
    // classifierVersion field, so they must surface as v1 — otherwise
    // the archive UI cannot detect that a re-scan is needed.
    expect(g.classifierVersion, 1);
    expect(
      g.isCacheCurrent,
      isFalse,
      reason: 'no cached timeline + version 1 ⇒ cache not current',
    );
    // Default analysis mode falls back to deep so older records keep
    // showing all classification tiers in the UI.
    expect(g.analysisMode, AnalysisMode.deep);
  });

  test('current-version record with cached timeline reports cache current', () {
    final timeline = AnalysisTimeline(
      startingFen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      moves: const [],
      winPercentages: const [],
      headers: const {'White': 'A', 'Black': 'B', 'Result': '*'},
    );
    final game = ArchivedGame.fromTimeline(
      timeline: timeline,
      id: 'fresh-id',
      source: ArchiveSource.pgn,
      depth: 14,
      pgn: '*',
    );
    expect(game.classifierVersion, kClassifierVersion);
    expect(game.isCacheCurrent, isTrue);
  });

  test(
    'qualityCountsLive derives from cached timeline regardless of stored map',
    () {
      // Synthetic divergence: the persisted `qualityCounts` map says one
      // Brilliant, but the cached timeline contains zero. The audit fix
      // makes [qualityCountsLive] trust the timeline so the archive UI
      // never advertises Brilliants that the timeline doesn't actually
      // hold.
      final timeline = AnalysisTimeline(
        startingFen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
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
            classification: MoveQuality.best,
            engineBestMoveSan: null,
            engineBestMoveUci: null,
            scoreCpAfter: null,
            mateInAfter: null,
            inBook: false,
            message: '',
          ),
        ],
        winPercentages: const [52.0],
        headers: const {'White': 'A', 'Black': 'B', 'Result': '*'},
      );
      final game = ArchivedGame(
        id: 'divergent',
        source: ArchiveSource.pgn,
        white: 'A',
        black: 'B',
        result: '*',
        analyzedAt: DateTime.now(),
        depth: 14,
        pgn: '1. e4 *',
        // Stored map intentionally lies — the live derivation should
        // override it.
        qualityCounts: const {MoveQuality.brilliant: 1},
        averageCpLoss: 0,
        totalPlies: 1,
        cachedTimeline: timeline,
      );
      expect(
        game.brilliantCount,
        0,
        reason: 'live counts trust the timeline, not the persisted map',
      );
      expect(game.qualityCountsLive[MoveQuality.best], 1);
    },
  );
}
