import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/review_entry_contract.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen = '8/8/8/8/8/8/8/8 w - - 0 1';

void main() {
  test('import and PGN intents analyze before mutating review state', () {
    final importIntent = ReviewEntryIntent.importedGame(
      AnalysisProfile.fastReview,
    );
    final pgnIntent = ReviewEntryIntent.pastedPgn(AnalysisProfile.deepReview);

    expect(importIntent.destination, ReviewEntryDestination.analyze);
    expect(pgnIntent.destination, ReviewEntryDestination.analyze);
    expect(importIntent.mutatesReviewStateBeforeData, isFalse);
    expect(pgnIntent.mutatesReviewStateBeforeData, isFalse);
  });

  test('saved review intent opens summary when cached timeline exists', () {
    final intent = ReviewEntryIntent.savedReview(_gameWithTimeline());

    expect(intent.destination, ReviewEntryDestination.summary);
    expect(intent.requiresAnalysis, isFalse);
    expect(intent.archiveSearch, 'C50');
  });

  test('saved review intent opens board directly when requested', () {
    final intent = ReviewEntryIntent.savedReview(
      _gameWithTimeline(),
      preferBoard: true,
    );

    expect(intent.destination, ReviewEntryDestination.board);
  });

  test('missing saved review falls back to Archive safely', () {
    final intent = ReviewEntryIntent.savedReview(null);

    expect(intent.destination, ReviewEntryDestination.archiveFallback);
    expect(intent.mutatesReviewStateBeforeData, isFalse);
  });

  test('partial saved review falls back with useful search', () {
    final intent = ReviewEntryIntent.savedReview(
      ArchivedGame(
        id: 'partial',
        source: ArchiveSource.pgn,
        white: 'White',
        black: 'Black',
        result: '*',
        analyzedAt: DateTime(2026, 5, 7),
        depth: 14,
        pgn: '',
        qualityCounts: const {},
        averageCpLoss: 0,
        totalPlies: 0,
        openingName: 'Scotch Game',
      ),
    );

    expect(intent.destination, ReviewEntryDestination.archiveFallback);
    expect(intent.archiveSearch, 'Scotch Game');
  });
}

ArchivedGame _gameWithTimeline() {
  final timeline = AnalysisTimeline(
    startingFen: _fen,
    moves: [
      MoveAnalysis(
        ply: 0,
        san: 'e4',
        uci: 'e2e4',
        fenBefore: _fen,
        fenAfter: _fen,
        targetSquare: 'e4',
        winPercentBefore: 50,
        winPercentAfter: 52,
        deltaW: 2,
        isWhiteMove: true,
        classification: MoveQuality.best,
        message: 'Best',
      ),
    ],
    headers: const {'White': 'White', 'Black': 'Black', 'Result': '1-0'},
    winPercentages: const [52],
  );
  return ArchivedGame(
    id: 'saved',
    source: ArchiveSource.chessCom,
    white: 'White',
    black: 'Black',
    result: '1-0',
    analyzedAt: DateTime(2026, 5, 7),
    depth: 14,
    pgn: '1. e4 *',
    qualityCounts: timeline.qualityCounts,
    averageCpLoss: timeline.averageCpLoss,
    totalPlies: timeline.totalPlies,
    ecoCode: 'C50',
    cachedTimeline: timeline,
  );
}
