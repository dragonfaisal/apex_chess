import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/review_entry_contract.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
const _afterE4 = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';

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

  test('historic canonical variant reopens without current-policy reuse', () {
    final current = _gameWithTimeline();
    final historicTimeline = AnalysisTimeline(
      startingFen: current.cachedTimeline!.startingFen,
      moves: current.cachedTimeline!.moves,
      headers: current.cachedTimeline!.headers,
      winPercentages: current.cachedTimeline!.winPercentages,
      classifierVersion: 5,
      analysisSchemaVersion: 3,
      completionStatus: AnalysisCompletionStatus.complete,
      expectedPlies: 1,
    );
    final historic = ArchivedGame(
      id: 'historic-variant',
      source: current.source,
      white: current.white,
      black: current.black,
      result: current.result,
      analyzedAt: current.analyzedAt,
      depth: current.depth,
      pgn: current.pgn,
      qualityCounts: historicTimeline.qualityCounts,
      averageCpLoss: historicTimeline.averageCpLoss,
      totalPlies: historicTimeline.totalPlies,
      cachedTimeline: historicTimeline,
      classifierVersion: 5,
      analysisSchemaVersion: 3,
      recordKind: ArchivedRecordKind.canonicalDocument,
      canonicalGameId: 'game-sha256',
      analysisVariantId: 'variant-sha256-v5',
      canonicalIndexVerified: true,
    );

    expect(historic.isCacheCurrent, isFalse);
    expect(historic.isExactStoredVariantReopenable, isTrue);
    expect(ReviewEntryContract.canOpenCachedReview(historic), isTrue);
    expect(
      ReviewEntryIntent.savedReview(historic).destination,
      ReviewEntryDestination.summary,
    );
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
  final openingEvidence = OpeningEvidence(
    artifact: _openingArtifact,
    artifactVerification: OpeningArtifactVerification.verified,
    state: OpeningMatchState.noMatch,
    beforePositionKey: OpeningPositionKey.fromFen(_fen).value,
    afterPositionKey: OpeningPositionKey.fromFen(_afterE4).value,
    playedUci: 'e2e4',
    transitionVerified: false,
    totalCandidateCount: 0,
    matchedPly: 1,
    reasonCode: 'no_match',
  );
  final timeline = AnalysisTimeline(
    startingFen: _fen,
    moves: [
      MoveAnalysis(
        ply: 0,
        san: 'e4',
        uci: 'e2e4',
        fenBefore: _fen,
        fenAfter: _afterE4,
        targetSquare: 'e4',
        winPercentBefore: 50,
        winPercentAfter: 52,
        deltaW: 2,
        isWhiteMove: true,
        classification: MoveQuality.best,
        message: 'Best',
        openingEvidence: openingEvidence,
      ),
    ],
    headers: const {'White': 'White', 'Black': 'Black', 'Result': '1-0'},
    winPercentages: const [52],
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: 1,
    openingBookVersion: kApexOpeningBookVersion,
    openingArtifact: _openingArtifact,
    openingArtifactVerification: OpeningArtifactVerification.verified,
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
    openingBookVersion: kApexOpeningBookVersion,
  );
}

const _openingArtifact = OpeningArtifactIdentity(
  datasetName: 'apex-eco',
  sourceRevision: '2026-07-17',
  sourceSha256:
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  contentSha256:
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
  licenseSpdx: 'MIT',
  provenanceReference: 'assets/openings/PROVENANCE.md',
);
