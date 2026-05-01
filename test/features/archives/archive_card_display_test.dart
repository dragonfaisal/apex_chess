import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';

void main() {
  ArchivedGame game({required String result}) {
    return ArchivedGame(
      id: 'a1',
      source: ArchiveSource.chessCom,
      white: 'ApexUser',
      black: 'RojoHijo',
      whiteRating: '1500',
      blackRating: '1510',
      result: result,
      analyzedAt: DateTime(2026, 4, 21),
      depth: 22,
      pgn: '1. e4 *',
      qualityCounts: const {MoveQuality.blunder: 1},
      averageCpLoss: 24,
      totalPlies: 40,
      openingName: 'Andersen Opening',
      ecoCode: 'A00',
    );
  }

  test('archive card display headline uses user-perspective result', () {
    expect(
      game(result: '1-0').resultHeadline(userHandle: 'apexuser'),
      'You won vs RojoHijo',
    );
    expect(
      game(result: '1-0').resultHeadline(userHandle: 'rojohijo'),
      'You lost vs ApexUser',
    );
    expect(
      game(result: '1/2-1/2').resultHeadline(userHandle: 'apexuser'),
      'Draw vs RojoHijo',
    );
  });

  test('archive unknown perspective uses side result text', () {
    expect(game(result: '0-1').resultHeadline(userHandle: null), 'Black won');
    expect(game(result: '1-0').secondaryResultText, 'White won · 1-0');
  });
}
