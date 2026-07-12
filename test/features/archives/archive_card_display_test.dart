import 'package:flutter_test/flutter_test.dart';

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/models/archived_game_card_display.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/widgets/apex_game_card.dart';

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

  test('archive display model uses result tone and side rows', () {
    final model = game(
      result: '1-0',
    ).toApexGameCardDisplay(userHandle: 'apexuser');

    expect(model.resultTone, GameResultTone.won);
    expect(model.white.side, ApexPlayerSide.white);
    expect(model.black.side, ApexPlayerSide.black);
    expect(model.white.isUser, isTrue);
    expect(model.black.isUser, isFalse);
    expect(model.white.identity.isConnectedUser, isTrue);
    expect(model.white.identity.side, PlayerIdentitySide.white);
    expect(model.black.identity.isOpponent, isTrue);
    expect(model.white.identity.platform, PlayerIdentityPlatform.chessCom);
    expect(model.primaryMeta, 'A00 Andersen Opening');
    expect(model.moveCountLabel, '20 moves');
    expect(model.secondaryMeta, contains('Chess.com'));
    expect(model.secondaryMeta, contains('Deep'));
    expect(model.secondaryMeta, contains('Metrics unavailable'));
    expect(model.badges, isEmpty);
  });

  test(
    'archive saved review card includes source mode accuracy and counts',
    () {
      final model = game(
        result: '1-0',
      ).toApexGameCardDisplay(userHandle: 'apexuser');

      expect(model.secondaryMeta, contains('Chess.com'));
      expect(model.secondaryMeta, contains('Deep'));
      expect(model.secondaryMeta, contains('Metrics unavailable'));
      expect(model.badges, isEmpty);
    },
  );

  test('canonical card uses saved perspective and compact provenance', () {
    final canonical = ArchivedGame(
      id: 'review-1',
      source: ArchiveSource.pgn,
      white: 'Alpha',
      black: 'Beta',
      result: '0-1',
      analyzedAt: DateTime(2026, 7, 11),
      depth: 14,
      pgn: '',
      qualityCounts: const {MoveQuality.best: 1},
      averageCpLoss: 12,
      cpLossSampleCount: 1,
      totalPlies: 2,
      analysisProfileId: 'fast_review',
      recordKind: ArchivedRecordKind.canonicalDocument,
      canonicalGameId: 'game-id',
      analysisVariantId: 'variant-id',
      analyzedUserIsWhite: false,
      engineIdentity: 'apex-stockfish-bridge/0.3.0|Stockfish 17',
      canonicalIndexVerified: true,
    );

    final model = canonical.toApexGameCardDisplay(userHandle: 'alpha');
    expect(model.white.isUser, isFalse);
    expect(model.black.isUser, isTrue);
    expect(model.secondaryMeta, contains('Fast'));
    expect(model.secondaryMeta, contains('Stockfish 17'));
    expect(model.secondaryMeta, contains('ACPL 12.0'));
    expect(model.secondaryMeta, isNot(contains('Legacy review')));
  });
}
