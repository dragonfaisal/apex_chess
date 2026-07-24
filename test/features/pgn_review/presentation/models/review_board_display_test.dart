import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/entities/move_insight.dart';
import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/analysis_versions.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_quality_display.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/models/review_board_display.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/widgets/apex_board_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/move_insight_test_fixtures.dart';

const _startFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

MoveAnalysis _move({
  required int ply,
  required bool isWhite,
  required String san,
  required String uci,
  MoveQuality quality = MoveQuality.good,
  String message = '',
  String coachExplanation = '',
  int? scoreCpAfter,
  int? mateInAfter,
  String? bestUci,
  String? bestSan,
  List<EngineLine> engineLines = const <EngineLine>[],
  bool playedEqualsPv1 = false,
  MoveInsight? insight,
  OpeningEvidence? openingEvidence,
}) {
  return MoveAnalysis(
    ply: ply,
    san: san,
    uci: uci,
    fenBefore: _startFen,
    fenAfter: _startFen,
    targetSquare: uci.length >= 4 ? uci.substring(2, 4) : '',
    winPercentBefore: 50,
    winPercentAfter: scoreCpAfter == null ? 50 : (scoreCpAfter > 0 ? 64 : 36),
    deltaW: 0,
    isWhiteMove: isWhite,
    classification: quality,
    message: message,
    coachExplanation: coachExplanation,
    scoreCpAfter: scoreCpAfter,
    mateInAfter: mateInAfter,
    engineBestMoveUci: bestUci,
    engineBestMoveSan: bestSan,
    engineLines: engineLines,
    playedEqualsPv1: playedEqualsPv1,
    insight: insight,
    openingEvidence: openingEvidence,
  );
}

OpeningEvidence _verifiedOpening() {
  const artifact = OpeningArtifactIdentity(
    datasetName: 'apex-eco',
    sourceRevision: 'chapter8-test',
    sourceSha256:
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    contentSha256:
        'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
    licenseSpdx: 'MIT',
    provenanceReference: 'assets/openings/PROVENANCE.md',
  );
  return OpeningEvidence(
    artifact: artifact,
    artifactVerification: OpeningArtifactVerification.verified,
    state: OpeningMatchState.knownTransition,
    beforePositionKey: OpeningPositionKey.fromFen(_startFen).value,
    afterPositionKey: OpeningPositionKey.fromFen(_startFen).value,
    playedUci: 'e2e4',
    transitionVerified: true,
    selectedCandidate: const OpeningCandidate(
      ecoCode: 'B00',
      openingName: "King's Pawn Game",
      sourceLineId:
          'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
      sourceTerminalPly: 1,
      matchedPly: 1,
      exactPositionName: true,
    ),
    totalCandidateCount: 1,
    matchedPly: 1,
    reasonCode: 'known_transition',
  );
}

AnalysisTimeline _timeline({
  String white = 'WhitePlayerLongName',
  String black = 'BlackPlayerLongName',
}) {
  return AnalysisTimeline(
    moves: [
      _move(
        ply: 0,
        isWhite: true,
        san: 'e4',
        uci: 'e2e4',
        quality: MoveQuality.best,
        scoreCpAfter: 24,
      ),
      _move(
        ply: 1,
        isWhite: false,
        san: 'e5',
        uci: 'e7e5',
        quality: MoveQuality.inaccuracy,
        scoreCpAfter: 45,
        bestUci: 'c7c5',
        bestSan: 'c5',
      ),
      _move(
        ply: 2,
        isWhite: true,
        san: 'Qh5??',
        uci: 'd1h5',
        quality: MoveQuality.blunder,
        message: '',
        scoreCpAfter: -180,
        bestUci: 'g1f3',
        bestSan: 'Nf3',
      ),
    ],
    startingFen: _startFen,
    headers: {
      'White': white,
      'Black': black,
      'WhiteElo': '1280',
      'BlackElo': '1310',
      'Result': '1-0',
    },
    winPercentages: const [54, 58, 31],
    explanationPolicyVersion: kApexExplanationPolicyVersion,
    explanationClaimSchemaVersion: kApexExplanationClaimSchemaVersion,
    explanationRendererVersion: kApexExplanationRendererVersion,
    analysisSchemaVersion: kApexAnalysisSchemaVersion,
  );
}

void main() {
  test('review navigation display model maps active ply and arrows', () {
    final display = ReviewBoardDisplayModel.fromTimeline(
      _timeline(),
      currentPly: 1,
      flipped: false,
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );

    expect(display.currentPly, 1);
    expect(display.currentMove?.san, 'e5');
    expect(display.lastMove, ('e7', 'e5'));
    expect(display.selectedSquare, 'e5');
    expect(display.bestMoveArrow, ('c7', 'c5'));
    expect(display.canGoPrevious, isTrue);
    expect(display.canGoNext, isTrue);
  });

  test('board orientation preserves correct player identity', () {
    final timeline = _timeline();
    final whiteBottom = ReviewBoardDisplayModel.fromTimeline(
      timeline,
      currentPly: 0,
      flipped: false,
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );
    final blackBottom = ReviewBoardDisplayModel.fromTimeline(
      timeline,
      currentPly: 0,
      flipped: true,
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );

    expect(whiteBottom.topPlayer.side, ReviewBoardSide.black);
    expect(whiteBottom.bottomPlayer.side, ReviewBoardSide.white);
    expect(whiteBottom.bottomPlayer.isUser, isTrue);
    expect(blackBottom.topPlayer.side, ReviewBoardSide.white);
    expect(blackBottom.bottomPlayer.side, ReviewBoardSide.black);
    expect(blackBottom.topPlayer.isUser, isTrue);
    expect(whiteBottom.bottomPlayer.identity.isConnectedUser, isTrue);
    expect(whiteBottom.bottomPlayer.identity.side, PlayerIdentitySide.white);
    expect(whiteBottom.topPlayer.identity.isOpponent, isTrue);
    expect(
      blackBottom.topPlayer.identity.displayUsername,
      'WhitePlayerLongName',
    );
  });

  test('eval display maps positive negative equal mate and missing values', () {
    final whiteEval = ReviewEvalDisplay.fromMove(
      _move(ply: 0, isWhite: true, san: 'e4', uci: 'e2e4', scoreCpAfter: 120),
    );
    final blackEval = ReviewEvalDisplay.fromMove(
      _move(ply: 1, isWhite: false, san: 'e5', uci: 'e7e5', scoreCpAfter: -120),
    );

    expect(whiteEval.advantageLabel, 'White');
    expect(whiteEval.percentageLabel, endsWith('%'));
    expect(blackEval.advantageLabel, 'Black');
    expect(blackEval.percentageLabel, endsWith('%'));
    expect(
      ReviewEvalDisplay.fromMove(
        _move(ply: 0, isWhite: true, san: 'Nf3', uci: 'g1f3', scoreCpAfter: 0),
      ).label,
      'Equal',
    );
    expect(
      ReviewEvalDisplay.fromMove(
        _move(ply: 0, isWhite: true, san: 'Qh5#', uci: 'd1h5', mateInAfter: 3),
      ).whiteShare,
      1.0,
    );
    expect(ReviewEvalDisplay.fromMove(null).isKnown, isFalse);
    expect(ReviewEvalDisplay.fromMove(null).percentageLabel, '—');
  });

  test('each public move quality maps to chip label and marker', () {
    final expected = {
      ReviewMoveLabel.brilliant: '!!',
      ReviewMoveLabel.great: '!',
      ReviewMoveLabel.onlyMove: 'Only',
      ReviewMoveLabel.forced: 'Forced',
      ReviewMoveLabel.best: '*',
      ReviewMoveLabel.excellent: '+',
      ReviewMoveLabel.good: '',
      ReviewMoveLabel.book: 'Book',
      ReviewMoveLabel.inaccuracy: '?!',
      ReviewMoveLabel.mistake: '?',
      ReviewMoveLabel.miss: '?',
      ReviewMoveLabel.blunder: '??',
      ReviewMoveLabel.unavailable: '—',
    };

    for (final entry in expected.entries) {
      final chip = ReviewMoveQualityChipDisplay.fromLabel(entry.key);
      expect(chip.label, entry.key.label);
      expect(chip.marker, entry.value);
    }
  });

  test('coach insight omits generic filler when evidence is absent', () {
    final insight = ReviewCoachInsightDisplay.fromMove(
      _move(
        ply: 2,
        isWhite: true,
        san: 'Qh5??',
        uci: 'd1h5',
        quality: MoveQuality.blunder,
        message: '',
        bestUci: 'g1f3',
        bestSan: 'Nf3',
      ),
      timeline: _timeline(),
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );

    expect(insight.quality.label, 'Blunder');
    expect(insight.explanation, isNull);
    expect(insight.betterMove, 'Nf3');
    expect(insight.betterMoveReason, isNull);
  });

  test('structured authoritative insight appears without legacy prose', () {
    final insight = ReviewCoachInsightDisplay.fromMove(
      _move(
        ply: 0,
        isWhite: true,
        san: 'e4',
        uci: 'e2e4',
        quality: MoveQuality.best,
        bestUci: 'e2e4',
        bestSan: 'e4',
        coachExplanation: 'Spoofed legacy explanation.',
        insight: testBookInsight(),
      ),
      timeline: _timeline(),
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );

    expect(insight.explanation, "This follows B00 · King's Pawn Game theory.");
    expect(insight.betterMove, isNull);
    expect(insight.betterMoveReason, isNull);
  });

  test('advanced outcome and mechanism use one persisted artifact', () {
    final persisted = testForkInsight();
    final insight = ReviewCoachInsightDisplay.fromMove(
      _move(
        ply: 0,
        isWhite: true,
        san: 'Nc7+',
        uci: 'b5c7',
        quality: MoveQuality.great,
        insight: persisted,
      ),
      timeline: _timeline(),
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );

    expect(
      insight.explanation,
      'The knight forks the king and queen, so the queen cannot be saved.',
    );
    expect(insight.coachDetail, 'One move creates two immediate threats.');
    expect(
      insight.consequenceDetail,
      'The best response still loses the queen.',
    );
    expect(insight.engineLinePreview, 'Nc7+ Kf8 Nxa8 Kg8');
    expect(insight.artifactDigest, persisted.integrityDigest);
  });

  test('schema-v4 timeline cannot surface a structured schema-v5 insight', () {
    final insight = ReviewCoachInsightDisplay.fromMove(
      _move(
        ply: 0,
        isWhite: true,
        san: 'e4',
        uci: 'e2e4',
        quality: MoveQuality.best,
        insight: testBookInsight(),
      ),
      timeline: _timeline().copyWith(
        analysisSchemaVersion: kApexLegacyAnalysisSchemaVersion,
        explanationPolicyVersion: 0,
        explanationClaimSchemaVersion: 0,
        explanationRendererVersion: 0,
      ),
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );

    expect(insight.explanation, isNull);
    expect(insight.coachDetail, isNull);
  });

  test('generic and debug-like explanation text is suppressed', () {
    for (final text in [
      'This is a good move.',
      'The engine prefers another move.',
      'Stockfish PV says d4.',
      'PV line starts with d4.',
      'Raw UCI move d2d4.',
    ]) {
      final insight = ReviewCoachInsightDisplay.fromMove(
        _move(
          ply: 0,
          isWhite: true,
          san: 'Nf3',
          uci: 'g1f3',
          coachExplanation: text,
        ),
        timeline: _timeline(),
        mode: AnalysisMode.deep,
        userIsWhite: true,
      );
      expect(insight.coachDetail, isNull);
      expect(insight.explanation, isNull);
    }
  });

  test('timeline move mapping is compact and cached by timeline', () {
    final timeline = _timeline();
    final items = ReviewTimelinePlyDisplay.fromTimeline(timeline);
    final warm = ReviewTimelinePlyDisplay.fromTimeline(timeline);

    expect(items[0].label, '1. e4');
    expect(items[1].label, '1... e5');
    expect(items[1].marker, '?!');
    expect(identical(items, warm), isTrue);
  });

  test('100-ply selected navigation reuses the mapped timeline', () {
    final moves = <MoveAnalysis>[
      for (var ply = 0; ply < 100; ply++)
        _move(
          ply: ply,
          isWhite: ply.isEven,
          san: ply.isEven ? 'Nf3' : 'Nf6',
          uci: ply.isEven ? 'g1f3' : 'g8f6',
          insight: ply == 50 ? testForkInsight() : null,
        ),
    ];
    final timeline = _timeline().copyWith(
      moves: moves,
      winPercentages: List<double>.filled(100, 50),
    );
    final cold = Stopwatch()..start();
    ReviewBoardDisplayModel.fromTimeline(
      timeline,
      currentPly: 0,
      flipped: false,
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );
    cold.stop();
    final warm = Stopwatch()..start();
    for (var ply = 0; ply < 100; ply++) {
      ReviewBoardDisplayModel.fromTimeline(
        timeline,
        currentPly: ply,
        flipped: false,
        mode: AnalysisMode.deep,
        userIsWhite: true,
      );
    }
    warm.stop();

    expect(ReviewTimelinePlyDisplay.fromTimeline(timeline), hasLength(100));
    debugPrint(
      'CHAPTER7_NAV_PERF coldUs=${cold.elapsedMicroseconds} '
      'selected100Us=${warm.elapsedMicroseconds}',
    );
  });

  test('better move arrow hides without data and updates by active ply', () {
    final noDataDisplay = ReviewBoardDisplayModel.fromTimeline(
      AnalysisTimeline(
        moves: [
          _move(
            ply: 0,
            isWhite: true,
            san: 'Nf3',
            uci: 'g1f3',
            quality: MoveQuality.excellent,
          ),
        ],
        startingFen: _startFen,
        headers: const {},
        winPercentages: const [50],
      ),
      currentPly: 0,
      flipped: false,
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );
    final inaccuracyDisplay = ReviewBoardDisplayModel.fromTimeline(
      _timeline(),
      currentPly: 1,
      flipped: false,
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );
    final blunderDisplay = ReviewBoardDisplayModel.fromTimeline(
      _timeline(),
      currentPly: 2,
      flipped: true,
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );

    expect(noDataDisplay.bestMoveArrow, isNull);
    expect(noDataDisplay.insight.betterMove, isNull);
    expect(inaccuracyDisplay.bestMoveArrow, ('c7', 'c5'));
    expect(inaccuracyDisplay.insight.betterMove, 'c5');
    expect(inaccuracyDisplay.insight.explanation, isNull);
    expect(inaccuracyDisplay.insight.betterMoveReason, isNull);
    expect(blunderDisplay.bestMoveArrow, ('g1', 'f3'));
    expect(blunderDisplay.insight.betterMove, 'Nf3');
    expect(blunderDisplay.insight.betterMoveReason, isNull);
  });

  test('Better Move appears for all eligible non-top-tier qualities', () {
    final eligible = {
      MoveQuality.excellent: 'd4',
      MoveQuality.good: 'd4',
      MoveQuality.inaccuracy: 'd4',
      MoveQuality.mistake: 'd4',
      MoveQuality.missedWin: 'd4',
      MoveQuality.blunder: 'd4',
    };

    for (final entry in eligible.entries) {
      final display = ReviewBoardDisplayModel.fromTimeline(
        AnalysisTimeline(
          moves: [
            _move(
              ply: 0,
              isWhite: true,
              san: 'Nf3',
              uci: 'g1f3',
              quality: entry.key,
              bestUci: 'd2d4',
              bestSan: entry.value,
            ),
          ],
          startingFen: _startFen,
          headers: const {},
          winPercentages: const [50],
        ),
        currentPly: 0,
        flipped: false,
        mode: AnalysisMode.deep,
        userIsWhite: true,
      );

      expect(display.insight.betterMove, entry.value);
      expect(display.bestMoveArrow, ('d2', 'd4'));
      expect(display.insight.betterMoveReason, isNull);
    }
  });

  test('root SAN can suggest Better without exposing an unverified line', () {
    final display = ReviewBoardDisplayModel.fromTimeline(
      AnalysisTimeline(
        moves: [
          _move(
            ply: 1,
            isWhite: false,
            san: 'e5',
            uci: 'e7e5',
            quality: MoveQuality.good,
            bestUci: 'c7c5',
            engineLines: const [
              EngineLine(
                rank: 1,
                moveSan: 'c5 Nf3',
                depth: 16,
                whiteWinPercent: 50,
              ),
            ],
          ),
        ],
        startingFen: _startFen,
        headers: const {},
        winPercentages: const [50],
      ),
      currentPly: 0,
      flipped: false,
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );

    expect(display.insight.betterMove, 'c5');
    expect(display.insight.engineLinePreview, isNull);
    expect(display.bestMoveArrow, ('c7', 'c5'));
  });

  test(
    'Better Move hides for Best Brilliant and Great even with engine data',
    () {
      for (final quality in [
        MoveQuality.best,
        MoveQuality.brilliant,
        MoveQuality.great,
        MoveQuality.book,
        MoveQuality.onlyMove,
        MoveQuality.forced,
        MoveQuality.unavailable,
      ]) {
        final display = ReviewBoardDisplayModel.fromTimeline(
          AnalysisTimeline(
            moves: [
              _move(
                ply: 0,
                isWhite: true,
                san: 'Nf3',
                uci: 'g1f3',
                quality: quality,
                bestUci: 'd2d4',
                bestSan: 'd4',
              ),
            ],
            startingFen: _startFen,
            headers: const {},
            winPercentages: const [50],
          ),
          currentPly: 0,
          flipped: false,
          mode: AnalysisMode.deep,
          userIsWhite: true,
        );

        expect(display.insight.explanation, isNull);
        expect(display.insight.betterMove, isNull);
        expect(display.bestMoveArrow, isNull);
      }
    },
  );

  test('better move arrow is stable across review modes and orientation', () {
    final fast = ReviewBoardDisplayModel.fromTimeline(
      _timeline(),
      currentPly: 1,
      flipped: false,
      mode: AnalysisMode.quick,
      userIsWhite: true,
    );
    final deepFlipped = ReviewBoardDisplayModel.fromTimeline(
      _timeline(),
      currentPly: 1,
      flipped: true,
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );

    expect(fast.insight.betterMove, 'c5');
    expect(deepFlipped.insight.betterMove, 'c5');
    expect(fast.bestMoveArrow, ('c7', 'c5'));
    expect(deepFlipped.bestMoveArrow, ('c7', 'c5'));
  });

  test(
    'selected-ply authority binds document variant execution and position',
    () {
      final timeline = _timeline();
      final first = ReviewBoardDisplayModel.fromState(
        ReviewState(
          timeline: timeline,
          currentPly: 1,
          executionId: 7,
          gameId: 'game-a',
          analysisVariantId: 'variant-fast',
          reviewDocumentId: 'document-fast',
          userIsWhite: true,
        ),
      );
      final replacement = ReviewBoardDisplayModel.fromState(
        ReviewState(
          timeline: timeline,
          currentPly: 1,
          executionId: 8,
          gameId: 'game-a',
          analysisVariantId: 'variant-deep',
          reviewDocumentId: 'document-deep',
          userIsWhite: true,
        ),
      );

      expect(first.documentIdentity, 'document-fast');
      expect(first.variantIdentity, 'variant-fast');
      expect(first.gameIdentity, 'game-a');
      expect(first.currentMove?.san, 'e5');
      expect(first.fenBefore, _startFen);
      expect(first.fenAfter, _startFen);
      expect(first.moverLabel, 'Black moved');
      expect(first.sideToMoveLabel, 'White to move');
      expect(first.presentationKey, isNot(replacement.presentationKey));
      expect(first.executionKey, isNot(replacement.executionKey));
    },
  );

  test(
    'critical navigation uses persisted labels mate and causal insight only',
    () {
      final timeline = _timeline();
      final first = ReviewBoardDisplayModel.fromTimeline(
        timeline,
        currentPly: 0,
        flipped: false,
        mode: AnalysisMode.deep,
        userIsWhite: true,
      );
      final last = ReviewBoardDisplayModel.fromTimeline(
        timeline,
        currentPly: 2,
        flipped: false,
        mode: AnalysisMode.deep,
        userIsWhite: true,
      );

      expect(first.criticalPlies, [1, 2]);
      expect(first.isCriticalMoment, isFalse);
      expect(first.previousCriticalPly, isNull);
      expect(first.nextCriticalPly, 1);
      expect(last.isCriticalMoment, isTrue);
      expect(last.previousCriticalPly, 1);
      expect(last.nextCriticalPly, isNull);

      final calm = _timeline().copyWith(
        moves: [_move(ply: 0, isWhite: true, san: 'e4', uci: 'e2e4')],
        winPercentages: const [50],
      );
      expect(
        ReviewBoardDisplayModel.fromTimeline(
          calm,
          currentPly: 0,
          flipped: false,
          mode: AnalysisMode.deep,
          userIsWhite: true,
        ).criticalPlies,
        isEmpty,
      );
    },
  );

  test(
    'verified opening and evidence-backed fork overlay share selected ply',
    () {
      final openingMove = _move(
        ply: 0,
        isWhite: true,
        san: 'e4',
        uci: 'e2e4',
        quality: MoveQuality.book,
        insight: testBookInsight(),
        openingEvidence: _verifiedOpening(),
      );
      final openingTimeline = _timeline().copyWith(
        moves: [openingMove],
        winPercentages: const [50],
      );
      final opening = ReviewBoardDisplayModel.fromTimeline(
        openingTimeline,
        currentPly: 0,
        flipped: false,
        mode: AnalysisMode.deep,
        userIsWhite: true,
      );
      expect(opening.opening.isVerified, isTrue);
      expect(opening.opening.label, "B00 · King's Pawn Game");

      final forkTimeline = _timeline().copyWith(
        moves: [
          _move(
            ply: 0,
            isWhite: true,
            san: 'Nc7+',
            uci: 'b5c7',
            quality: MoveQuality.great,
            insight: testForkInsight(),
          ),
        ],
        winPercentages: const [60],
      );
      final fork = ReviewBoardDisplayModel.fromTimeline(
        forkTimeline,
        currentPly: 0,
        flipped: true,
        mode: AnalysisMode.deep,
        userIsWhite: true,
      );
      expect(fork.mechanism?.label, 'Fork');
      expect(fork.boardOverlay?.principalArrow, ('c7', 'a8'));
      expect(fork.boardOverlay?.targetSquares, containsAll(['a8', 'e8']));
      expect(fork.boardOverlay?.semanticLabel, 'Tactical mechanism: Fork');
      expect(fork.bestMoveArrow, isNull);
    },
  );

  test('historic compatibility is explicit and never invents insight', () {
    final schema4 = _timeline().copyWith(
      analysisSchemaVersion: kApexLegacyAnalysisSchemaVersion,
      explanationPolicyVersion: 0,
      explanationClaimSchemaVersion: 0,
      explanationRendererVersion: 0,
    );
    final schema5 = _timeline().copyWith(
      analysisSchemaVersion: kApexLegacyInsightAnalysisSchemaVersion,
      explanationPolicyVersion: kApexLegacyExplanationPolicyVersion,
      explanationClaimSchemaVersion: kApexLegacyExplanationClaimSchemaVersion,
      explanationRendererVersion: kApexLegacyExplanationRendererVersion,
    );
    final old = ReviewBoardDisplayModel.fromTimeline(
      schema4,
      currentPly: 0,
      flipped: false,
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );
    final historic = ReviewBoardDisplayModel.fromTimeline(
      schema5,
      currentPly: 0,
      flipped: false,
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );
    expect(old.compatibility, ReviewCompatibilityState.historicSchema4);
    expect(old.insight.hasDetails, isFalse);
    expect(historic.compatibility, ReviewCompatibilityState.historicSchema5);
  });

  test('board square orientation transform is deterministic', () {
    expect(
      ApexBoardGeometry.centerForSquare(
        'a1',
        boardSize: const Size(80, 80),
        flipped: false,
      ),
      const Offset(5, 75),
    );
    expect(
      ApexBoardGeometry.centerForSquare(
        'a1',
        boardSize: const Size(80, 80),
        flipped: true,
      ),
      const Offset(75, 5),
    );
    expect(ApexBoardGeometry.isSquare('e4'), isTrue);
    expect(ApexBoardGeometry.isSquare('e9'), isFalse);
  });

  test(
    'ten thousand selected-ply projections reuse bounded timeline cache',
    () {
      final timeline = _timeline();
      final first = ReviewBoardDisplayModel.fromTimeline(
        timeline,
        currentPly: 0,
        flipped: false,
        mode: AnalysisMode.deep,
        userIsWhite: true,
      );
      final stopwatch = Stopwatch()..start();
      for (var index = 0; index < 10000; index++) {
        final display = ReviewBoardDisplayModel.fromTimeline(
          timeline,
          currentPly: index % timeline.totalPlies,
          flipped: index.isOdd,
          mode: AnalysisMode.deep,
          userIsWhite: true,
        );
        expect(identical(display.timeline, first.timeline), isTrue);
        expect(identical(display.criticalPlies, first.criticalPlies), isTrue);
      }
      stopwatch.stop();
      debugPrint(
        'CHAPTER8_PRESENTATION_PERF jumps=10000 '
        'elapsedUs=${stopwatch.elapsedMicroseconds}',
      );
    },
  );

  test('review controller starts at first ply and respects boundaries', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(reviewControllerProvider.notifier);

    controller.loadTimeline(_timeline(), userIsWhite: true);
    expect(container.read(reviewControllerProvider).currentPly, 0);

    controller.prev();
    expect(container.read(reviewControllerProvider).currentPly, -1);

    controller.prev();
    expect(container.read(reviewControllerProvider).currentPly, -1);

    controller.next();
    controller.next();
    controller.next();
    expect(container.read(reviewControllerProvider).currentPly, 2);

    controller.toggleFlip();
    expect(container.read(reviewControllerProvider).flipped, isTrue);

    controller.loadTimeline(_timeline(white: 'NewWhite'), initialPly: 99);
    expect(container.read(reviewControllerProvider).currentPly, 2);
    controller.loadTimeline(_timeline(white: 'ResetWhite'));
    expect(container.read(reviewControllerProvider).currentPly, 0);
  });
}
