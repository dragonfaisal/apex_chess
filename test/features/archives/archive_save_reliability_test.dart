import 'package:apex_chess/core/domain/entities/analysis_profile.dart';
import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/classification_evidence.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/data/archive_save_hook.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/domain/review_document.dart';
import 'package:apex_chess/features/archives/presentation/controllers/archive_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';
const _afterE4 = 'rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1';

void main() {
  test('same PGN and profile produce stable archive identity', () {
    final a = archiveIdForAnalysis(
      pgn: _pgn,
      analysisProfileId: AnalysisProfileId.fastReview,
      providerId: 'local_offline',
      engineVersion: 'local-test',
    );
    final b = archiveIdForAnalysis(
      pgn: _pgn.replaceAll('\n', '\r\n'),
      analysisProfileId: AnalysisProfileId.fastReview,
      providerId: 'local_offline',
      engineVersion: 'local-test',
    );

    expect(a, b);
  });

  test(
    'Fast and Deep cache identities are distinct but canonical key is shared',
    () {
      final fastCache = archiveIdForAnalysis(
        pgn: _pgn,
        analysisProfileId: AnalysisProfileId.fastReview,
        providerId: 'local_offline',
        engineVersion: 'local-test',
      );
      final deepCache = archiveIdForAnalysis(
        pgn: _pgn,
        analysisProfileId: AnalysisProfileId.deepReview,
        providerId: 'local_offline',
        engineVersion: 'local-test',
      );
      final fastArchive = ArchivedGame.canonicalKeyFor(
        pgn: _pgn,
        pgnHash: archiveIdForPgn(_pgn),
        white: 'Alpha',
        black: 'Beta',
        result: '1-0',
      );
      final deepArchive = ArchivedGame.canonicalKeyFor(
        pgn: _pgn,
        pgnHash: archiveIdForPgn(_pgn),
        white: 'Alpha',
        black: 'Beta',
        result: '1-0',
      );

      expect(fastCache, isNot(deepCache));
      expect(fastArchive, deepArchive);
    },
  );

  testWidgets('saving same review twice upserts and keeps display fields', (
    tester,
  ) async {
    final saved = <String, ArchivedGame>{};

    final firstId = await _saveWithWidgetRef(
      tester,
      saved,
      timeline: _timeline(),
      pgn: _pgn,
      depth: 14,
      source: ArchiveSource.chessCom,
      playedAt: DateTime(2026, 5, 6),
      analysisMode: AnalysisMode.quick,
      timeControl: '3 min',
    );
    final secondId = await _saveWithWidgetRef(
      tester,
      saved,
      timeline: _timeline(),
      pgn: _pgn,
      depth: 14,
      source: ArchiveSource.chessCom,
      playedAt: DateTime(2026, 5, 6),
      analysisMode: AnalysisMode.quick,
      timeControl: '3 min',
    );

    expect(firstId, secondId);
    expect(saved, hasLength(1));
    final game = saved.values.single;
    expect(game.white, 'Alpha');
    expect(game.black, 'Beta');
    expect(game.source, ArchiveSource.chessCom);
    expect(game.result, '1-0');
    expect(game.reviewModeLabel, 'Fast');
    expect(game.timeControl, '3 min');
    expect(game.cachedTimeline, isNotNull);
    expect(game.qualityCountsLive[MoveQuality.best], 1);
  });

  testWidgets('Fast then Deep same PGN preserve two canonical variants', (
    tester,
  ) async {
    final saved = <String, ArchivedGame>{};

    final fastId = await _saveWithWidgetRef(
      tester,
      saved,
      timeline: _timeline(
        analysisMode: 'quick',
        analysisProfileId: 'fast_review',
      ),
      pgn: _pgn,
      depth: 14,
      source: ArchiveSource.pgn,
      analysisMode: AnalysisMode.quick,
    );
    final deepId = await _saveWithWidgetRef(
      tester,
      saved,
      timeline: _timeline(
        analysisMode: 'deep',
        analysisProfileId: 'deep_review',
      ),
      pgn: _pgn,
      depth: 22,
      source: ArchiveSource.pgn,
      analysisMode: AnalysisMode.deep,
    );

    expect(fastId, isNotNull);
    expect(deepId, isNotNull);
    expect(fastId, isNot(deepId));
    expect(saved, hasLength(2));
    expect(saved.values.map((game) => game.reviewModeLabel).toSet(), {
      'Fast',
      'Deep',
    });
  });
}

Future<String?> _saveWithWidgetRef(
  WidgetTester tester,
  Map<String, ArchivedGame> saved, {
  required AnalysisTimeline timeline,
  required String pgn,
  required int depth,
  required ArchiveSource source,
  DateTime? playedAt,
  AnalysisMode analysisMode = AnalysisMode.deep,
  String? timeControl,
}) async {
  Future<String?>? pending;
  var started = false;
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        archiveControllerProvider.overrideWith(
          () => _FakeArchiveController(saved),
        ),
      ],
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, _) {
            if (!started) {
              started = true;
              pending = Future<String?>.microtask(
                () => saveAnalysisToArchive(
                  ref: ref,
                  timeline: timeline,
                  pgn: pgn,
                  depth: depth,
                  source: source,
                  playedAt: playedAt,
                  analysisMode: analysisMode,
                  timeControl: timeControl,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  final result = pending == null ? null : await pending!;
  await tester.pumpWidget(const SizedBox.shrink());
  return result;
}

const _pgn = '''
[Site "https://www.chess.com/game/live/123"]
[White "Alpha"]
[Black "Beta"]
[Result "1-0"]

1. e4 *
''';

AnalysisTimeline _timeline({
  String analysisMode = 'quick',
  String analysisProfileId = 'fast_review',
}) {
  final evidence = MoveClassificationEvidence(
    mover: ClassificationMover.white,
    evaluationBefore: const ClassificationScore.cp(0),
    playedMoveEvaluation: const ClassificationScore.cp(20),
    bestMoveEvaluation: const ClassificationScore.cp(20),
    playedMoveUci: 'e2e4',
    bestMoveUci: 'e2e4',
    candidates: const <ClassificationCandidateEvidence>[
      ClassificationCandidateEvidence(
        rootUci: 'e2e4',
        rank: 1,
        score: ClassificationScore.cp(20),
        achievedDepth: 14,
        isLegal: true,
        pvComplete: true,
      ),
    ],
    requestedMultiPv: 1,
    receivedMultiPv: 1,
    candidateSetComplete: true,
    candidateSetCoherent: true,
    bestMovePv1Consistent: true,
    searchQualityMet: true,
    achievedDepthFloor: 14,
    legalMoveCount: 20,
    bookState: ClassificationBookState.notBook,
    verificationState: ClassificationVerificationState.notRequested,
    forcedState: ClassificationForcedState.notForced,
  );
  final decision = const EvaluationAnalyzer().analyzeEvidence(evidence);
  return AnalysisTimeline(
    startingFen: _fen,
    moves: [
      MoveAnalysis(
        ply: 0,
        san: 'e4',
        uci: 'e2e4',
        fenBefore: _fen,
        fenAfter: _afterE4,
        targetSquare: 'e4',
        winPercentBefore: decision.winPercentBefore,
        winPercentAfter: decision.winPercentAfter,
        deltaW: decision.deltaW,
        isWhiteMove: true,
        classification: decision.quality,
        baseClassification: decision.baseQuality,
        finalClassification: decision.quality,
        reasonCode: decision.reasonCode,
        classificationEvidence: evidence,
        classificationReasonCodes: decision.reasonCodes,
        classificationFailedGates: decision.failedGates,
        playedEqualsPv1: decision.playedEqualsPv1,
        moverCpLoss: decision.moverCpLoss,
        requestedDepth: 14,
        achievedDepthBefore: 14,
        achievedDepthAfter: 14,
        multiPvReceived: 1,
        searchQualityMet: true,
        engineBestMoveUci: 'e2e4',
        scoreCpAfter: 20,
        engineLines: <EngineLine>[
          EngineLine(
            rank: 1,
            moveUci: 'e2e4',
            moveSan: 'e4',
            scoreCp: 20,
            depth: 14,
            whiteWinPercent: decision.winPercentAfter,
            pvMoves: const <String>['e2e4'],
          ),
        ],
        message: decision.message,
        analysisMode: analysisMode,
        engineVersion: 'local-test',
      ),
    ],
    headers: const {
      'White': 'Alpha',
      'Black': 'Beta',
      'Result': '1-0',
      'ECO': 'C20',
      'Opening': 'King Pawn',
    },
    winPercentages: <double>[decision.winPercentAfter],
    analysisMode: analysisMode,
    analysisProfileId: analysisProfileId,
    providerId: 'local_offline',
    engineVersion: 'local-test',
    pgnHash: archiveIdForPgn(_pgn),
    completionStatus: AnalysisCompletionStatus.complete,
    expectedPlies: 1,
  );
}

class _FakeArchiveController extends ArchiveController {
  _FakeArchiveController(this.saved);

  final Map<String, ArchivedGame> saved;

  @override
  ArchiveState build() => ArchiveState(games: saved.values.toList());

  @override
  Future<String> saveReviewDocument(ReviewDocument document) async {
    final profile = document.compatibility.profileId;
    final game = ArchivedGame.fromTimeline(
      timeline: document.timeline,
      id: document.documentId,
      source: ArchiveSource.fromWire(document.game.sourceProvider),
      depth: document.run.achievedDepth ?? 0,
      pgn: document.game.originalPgn,
      playedAt: document.game.importedAt,
      analysisMode: profile == 'fast_review'
          ? AnalysisMode.quick
          : AnalysisMode.deep,
      timeControl: document.game.headers['TimeControl'],
    );
    saved[game.id] = game;
    state = ArchiveState(games: saved.values.toList());
    return game.id;
  }
}
