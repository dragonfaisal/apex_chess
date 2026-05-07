import 'package:apex_chess/core/domain/entities/analysis_timeline.dart';
import 'package:apex_chess/core/domain/entities/move_analysis.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/presentation/controllers/review_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _fen = '8/8/8/8/8/8/8/8 w - - 0 1';

void main() {
  test('opening review A then B resets active ply and player data', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(reviewControllerProvider.notifier);

    controller.loadTimeline(_timeline(white: 'Alpha', black: 'Beta'));
    controller.jumpTo(1);
    expect(container.read(reviewControllerProvider).currentPly, 1);
    expect(
      container.read(reviewControllerProvider).timeline!.headers['White'],
      'Alpha',
    );

    controller.loadTimeline(
      _timeline(white: 'Gamma', black: 'Delta'),
      userIsBlack: true,
      mode: AnalysisMode.quick,
      userIsWhite: false,
    );
    final state = container.read(reviewControllerProvider);

    expect(state.currentPly, 0);
    expect(state.flipped, isTrue);
    expect(state.mode, AnalysisMode.quick);
    expect(state.userIsWhite, isFalse);
    expect(state.timeline!.headers['White'], 'Gamma');
    expect(state.timeline!.headers['Black'], 'Delta');
  });

  test('reopening saved review preserves move list', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final game = ArchivedGame(
      id: 'saved',
      source: ArchiveSource.pgn,
      white: 'Alpha',
      black: 'Beta',
      result: '1-0',
      analyzedAt: DateTime(2026, 5, 7),
      depth: 14,
      pgn: '1. e4 e5 *',
      qualityCounts: const {MoveQuality.best: 2},
      averageCpLoss: 0,
      totalPlies: 2,
      cachedTimeline: _timeline(white: 'Alpha', black: 'Beta'),
    );

    container
        .read(reviewControllerProvider.notifier)
        .loadTimeline(game.cachedTimeline!);

    final state = container.read(reviewControllerProvider);
    expect(state.totalPlies, 2);
    expect(state.timeline!.moves.map((m) => m.san), ['e4', 'e5']);
    expect(state.currentPly, 0);
  });
}

AnalysisTimeline _timeline({required String white, required String black}) {
  return AnalysisTimeline(
    startingFen: _fen,
    moves: [
      _move(ply: 0, san: 'e4', uci: 'e2e4', isWhite: true),
      _move(ply: 1, san: 'e5', uci: 'e7e5', isWhite: false),
    ],
    headers: {'White': white, 'Black': black, 'Result': '1-0'},
    winPercentages: const [52, 50],
  );
}

MoveAnalysis _move({
  required int ply,
  required String san,
  required String uci,
  required bool isWhite,
}) {
  return MoveAnalysis(
    ply: ply,
    san: san,
    uci: uci,
    fenBefore: _fen,
    fenAfter: _fen,
    targetSquare: uci.substring(2, 4),
    winPercentBefore: 50,
    winPercentAfter: 50,
    deltaW: 0,
    isWhiteMove: isWhite,
    classification: MoveQuality.best,
    message: 'Best',
  );
}
