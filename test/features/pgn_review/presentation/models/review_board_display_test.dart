import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/engine_line.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/core/domain/services/move_quality_display.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:apex_chess/features/pgn_review/presentation/models/review_board_display.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _startFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

MoveAnalysis _move({
  required int ply,
  required bool isWhite,
  required String san,
  required String uci,
  MoveQuality quality = MoveQuality.good,
  String message = '',
  int? scoreCpAfter,
  int? mateInAfter,
  String? bestUci,
  String? bestSan,
  List<EngineLine> engineLines = const <EngineLine>[],
  bool playedEqualsPv1 = false,
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
    scoreCpAfter: scoreCpAfter,
    mateInAfter: mateInAfter,
    engineBestMoveUci: bestUci,
    engineBestMoveSan: bestSan,
    engineLines: engineLines,
    playedEqualsPv1: playedEqualsPv1,
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
    expect(
      ReviewEvalDisplay.fromMove(
        _move(ply: 0, isWhite: true, san: 'e4', uci: 'e2e4', scoreCpAfter: 120),
      ).advantageLabel,
      'White',
    );
    expect(
      ReviewEvalDisplay.fromMove(
        _move(
          ply: 1,
          isWhite: false,
          san: 'e5',
          uci: 'e7e5',
          scoreCpAfter: -120,
        ),
      ).advantageLabel,
      'Black',
    );
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
  });

  test('each public move quality maps to chip label and marker', () {
    final expected = {
      ReviewMoveLabel.brilliant: '!!',
      ReviewMoveLabel.great: '!',
      ReviewMoveLabel.best: '*',
      ReviewMoveLabel.excellent: '+',
      ReviewMoveLabel.good: '',
      ReviewMoveLabel.book: 'Book',
      ReviewMoveLabel.inaccuracy: '?!',
      ReviewMoveLabel.mistake: '?',
      ReviewMoveLabel.miss: '?',
      ReviewMoveLabel.blunder: '??',
    };

    for (final entry in expected.entries) {
      final chip = ReviewMoveQualityChipDisplay.fromLabel(entry.key);
      expect(chip.label, entry.key.label);
      expect(chip.marker, entry.value);
    }
  });

  test('coach insight fallback stays short and honest', () {
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
    expect(insight.explanation.length, lessThanOrEqualTo(86));
    expect(insight.explanation.toLowerCase(), isNot(contains('stockfish')));
    expect(insight.explanation, 'This gives the opponent a clear chance.');
    expect(insight.betterMove, 'Nf3');
    expect(insight.betterMoveReason, 'Avoids the worst of the danger.');
    expect(insight.betterMoveReason, isNot(insight.explanation));
  });

  test('current move explanation appears without a Better Move', () {
    final insight = ReviewCoachInsightDisplay.fromMove(
      _move(
        ply: 0,
        isWhite: true,
        san: 'e4',
        uci: 'e2e4',
        quality: MoveQuality.best,
        bestUci: 'e2e4',
        bestSan: 'e4',
      ),
      timeline: _timeline(),
      mode: AnalysisMode.deep,
      userIsWhite: true,
    );

    expect(insight.explanation, 'This move keeps the advantage.');
    expect(insight.betterMove, isNull);
    expect(insight.betterMoveReason, isNull);
  });

  test('coach detail maps public qualities to safe explanations', () {
    final cases = {
      MoveQuality.brilliant: 'This move finds a rare resource.',
      MoveQuality.best: 'This move keeps the advantage.',
      MoveQuality.excellent: 'This move keeps the position under control.',
      MoveQuality.blunder: 'This gives the opponent a clear chance.',
      MoveQuality.missedWin: 'This move misses a stronger tactic.',
    };

    for (final entry in cases.entries) {
      final insight = ReviewCoachInsightDisplay.fromMove(
        _move(
          ply: 0,
          isWhite: true,
          san: 'Nf3',
          uci: 'g1f3',
          quality: entry.key,
          message: '',
        ),
        timeline: _timeline(),
        mode: AnalysisMode.deep,
        userIsWhite: true,
      );

      expect(insight.coachDetail, entry.value);
      expect(insight.coachDetail.toLowerCase(), isNot(contains('stockfish')));
    }

    expect(
      ReviewCoachInsightDisplay.empty().coachDetail,
      'No deeper explanation available for this move.',
    );
  });

  test('timeline active move mapping uses compact ply labels', () {
    final items = ReviewTimelinePlyDisplay.fromTimeline(
      _timeline(),
      activePly: 1,
    );

    expect(items[0].label, '1. e4');
    expect(items[1].label, '1... e5');
    expect(items[1].isActive, isTrue);
    expect(items[1].marker, '?!');
  });

  test(
    'best move arrow stays hidden for good moves and updates by active ply',
    () {
      final quietDisplay = ReviewBoardDisplayModel.fromTimeline(
        AnalysisTimeline(
          moves: [
            _move(
              ply: 0,
              isWhite: true,
              san: 'Nf3',
              uci: 'g1f3',
              quality: MoveQuality.excellent,
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

      expect(quietDisplay.bestMoveArrow, isNull);
      expect(quietDisplay.insight.betterMove, isNull);
      expect(inaccuracyDisplay.bestMoveArrow, ('c7', 'c5'));
      expect(inaccuracyDisplay.insight.betterMove, 'c5');
      expect(
        inaccuracyDisplay.insight.explanation,
        'This move misses a stronger continuation.',
      );
      expect(
        inaccuracyDisplay.insight.betterMoveReason,
        'Stronger continuation.',
      );
      expect(
        inaccuracyDisplay.insight.betterMoveReason,
        isNot(inaccuracyDisplay.insight.explanation),
      );
      expect(blunderDisplay.bestMoveArrow, ('g1', 'f3'));
      expect(blunderDisplay.insight.betterMove, 'Nf3');
      expect(
        blunderDisplay.insight.betterMoveReason,
        'Avoids the worst of the danger.',
      );
    },
  );

  test(
    'Better Move hides for Best Brilliant and Great even with engine data',
    () {
      for (final quality in [
        MoveQuality.best,
        MoveQuality.brilliant,
        MoveQuality.great,
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

        expect(display.insight.explanation, startsWith('This move'));
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

  test('review controller starts at first ply and respects boundaries', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(reviewControllerProvider.notifier);

    controller.loadTimeline(_timeline(), userIsWhite: true);
    expect(container.read(reviewControllerProvider).currentPly, 0);

    controller.prev();
    expect(container.read(reviewControllerProvider).currentPly, 0);

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
