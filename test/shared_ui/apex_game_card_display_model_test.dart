import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';
import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/archives/presentation/models/archived_game_card_display.dart';
import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/features/import_match/presentation/models/imported_game_card_display.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/apex_game_card.dart';
import 'package:apex_chess/shared_ui/widgets/apex_player_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApexGameCardDisplayModel imported-game mapping', () {
    test('user won maps to Won tone and YOU chip on white', () {
      final model = _imported(
        result: GameResult.whiteWon,
        userColor: PlayerColor.white,
      ).toApexGameCardDisplay();

      expect(model.resultTone, GameResultTone.won);
      expect(model.white.side, ApexPlayerSide.white);
      expect(model.black.side, ApexPlayerSide.black);
      expect(model.white.isUser, isTrue);
      expect(model.black.isUser, isFalse);
      expect(model.white.identity.isConnectedUser, isTrue);
      expect(model.white.identity.side, PlayerIdentitySide.white);
      expect(model.white.identity.platform, PlayerIdentityPlatform.chessCom);
      expect(model.black.identity.isOpponent, isTrue);
      expect(model.resolvedResultLabel, 'Won');
    });

    test('user lost maps to Lost tone and YOU chip on black', () {
      final model = _imported(
        result: GameResult.whiteWon,
        userColor: PlayerColor.black,
      ).toApexGameCardDisplay();

      expect(model.resultTone, GameResultTone.lost);
      expect(model.white.isUser, isFalse);
      expect(model.black.isUser, isTrue);
      expect(model.black.identity.isConnectedUser, isTrue);
      expect(model.black.identity.sideLabel, 'Black');
      expect(model.resolvedResultLabel, 'Lost');
    });

    test('draw maps to Draw tone', () {
      final model = _imported(
        result: GameResult.draw,
        userColor: PlayerColor.white,
      ).toApexGameCardDisplay();

      expect(model.resultTone, GameResultTone.draw);
      expect(model.resolvedResultLabel, 'Draw');
    });

    test('import display model avoids repeated loud result copy', () {
      final model = _imported(
        result: GameResult.blackWon,
        userColor: PlayerColor.white,
      ).toApexGameCardDisplay();
      final text = [
        model.resolvedResultLabel,
        model.primaryMeta,
        model.secondaryMeta,
      ].whereType<String>().join(' ');

      expect(text, contains('Lost'));
      expect(text, isNot(contains('You lost vs')));
      expect(text, isNot(contains('Black won')));
      expect(text, isNot(contains('0-1')));
    });

    test('card display model carries long names and opening safely', () {
      final model = ImportedGame(
        id: 'long',
        source: GameSource.chessCom,
        whiteName: 'VeryVeryLongWhiteHandleThatShouldEllipsize',
        blackName: 'VeryVeryLongBlackHandleThatShouldEllipsize',
        whiteRating: 1500,
        blackRating: 1510,
        result: GameResult.draw,
        playedAt: DateTime(2026, 4, 20),
        timeControl: '3 min',
        moveCount: 42,
        pgn: '1. e4 *',
        openingName:
            'Extremely Long Opening Name With Many Words And A Variation',
        eco: 'C45',
        userColor: PlayerColor.white,
      ).toApexGameCardDisplay();

      expect(model.white.name, contains('VeryVeryLongWhite'));
      expect(model.black.name, contains('VeryVeryLongBlack'));
      expect(model.primaryMeta, contains('Extremely Long Opening Name'));
      expect(model.moveCountLabel, '42 moves');
      expect(model.white.identity.displayUsername, contains('VeryVeryLong'));
    });

    testWidgets('card surfaces use markers chip and single source label', (
      tester,
    ) async {
      final model = _imported(
        result: GameResult.whiteWon,
        userColor: PlayerColor.white,
      ).toApexGameCardDisplay();

      await tester.pumpWidget(
        MaterialApp(
          theme: ApexTheme.dark,
          home: Scaffold(body: ApexGameCard(model: model)),
        ),
      );

      expect(
        find.byKey(const ValueKey('apex-white-side-marker')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('apex-black-side-marker')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('apex-platform-chessCom-badge')),
        findsNothing,
      );
      expect(find.byType(ApexPlayerAvatar), findsNothing);
      expect(find.byType(ApexMoveCountChip), findsOneWidget);
      expect(
        find.byKey(const ValueKey('apex-move-count-chip')),
        findsOneWidget,
      );
      final moveChip = tester.widget<Container>(
        find.byKey(const ValueKey('apex-move-count-chip')),
      );
      final chipDecoration = moveChip.decoration! as BoxDecoration;
      expect(
        (chipDecoration.border! as Border).top.width,
        lessThanOrEqualTo(0.6),
      );
      expect(find.textContaining('Chess.com'), findsOneWidget);
      expect(find.text('Won'), findsOneWidget);
      expect(find.text('YOU'), findsOneWidget);
    });

    test('result tones map to soft readable card tones', () {
      expect(GameResultTone.won.color, ApexColors.emerald);
      expect(GameResultTone.lost.color, ApexColors.rubyBright);
      expect(GameResultTone.draw.color, ApexColors.sapphireBright);
      expect(GameResultTone.won.cardTintAlpha, greaterThan(0));
      expect(GameResultTone.lost.cardAccentAlpha, greaterThan(0));
      expect(GameResultTone.draw.cardTintAlpha, lessThan(0.05));
    });
  });

  group('ApexGameCardDisplayModel archive mapping', () {
    test('archive card uses result tone from connected user perspective', () {
      final model = _archived(
        result: '0-1',
      ).toApexGameCardDisplay(userHandle: 'apexuser');

      expect(model.resultTone, GameResultTone.lost);
      expect(model.white.isUser, isTrue);
      expect(model.black.isUser, isFalse);
      expect(model.white.identity.platform, PlayerIdentityPlatform.chessCom);
      expect(model.white.identity.rating, '1500');
      expect(model.secondaryMeta, contains('Chess.com'));
      expect(model.secondaryMeta, contains('Deep'));
      expect(model.secondaryMeta, contains('76%'));
      expect(model.moveCountLabel, '20 moves');
      expect(model.badges, contains('Blunder 3'));
    });

    testWidgets('archive card has no row avatars and one source label', (
      tester,
    ) async {
      final model = _archived(
        result: '1-0',
      ).toApexGameCardDisplay(userHandle: 'apexuser');

      await tester.pumpWidget(
        MaterialApp(
          theme: ApexTheme.dark,
          home: Scaffold(body: ApexGameCard(model: model)),
        ),
      );

      expect(
        find.byKey(const ValueKey('apex-platform-chessCom-badge')),
        findsNothing,
      );
      expect(find.byType(ApexPlayerAvatar), findsNothing);
      expect(find.byType(ApexMoveCountChip), findsOneWidget);
      expect(find.textContaining('Chess.com'), findsOneWidget);
      expect(find.text('YOU'), findsOneWidget);
    });

    testWidgets('missing move count chip does not crash', (tester) async {
      const model = ApexGameCardDisplayModel(
        resultTone: GameResultTone.draw,
        white: ApexGamePlayerDisplay(side: ApexPlayerSide.white, name: 'White'),
        black: ApexGamePlayerDisplay(side: ApexPlayerSide.black, name: 'Black'),
        primaryMeta: 'Opening not detected',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ApexTheme.dark,
          home: Scaffold(body: ApexGameCard(model: model)),
        ),
      );

      expect(find.byType(ApexMoveCountChip), findsNothing);
      expect(find.text('Opening not detected'), findsOneWidget);
    });
  });
}

ImportedGame _imported({
  required GameResult result,
  required PlayerColor? userColor,
}) {
  return ImportedGame(
    id: 'g1',
    source: GameSource.chessCom,
    whiteName: 'ApexUser',
    blackName: 'RojoHijo',
    whiteRating: 1500,
    blackRating: 1510,
    result: result,
    playedAt: DateTime(2026, 4, 20),
    timeControl: '3 min',
    moveCount: 42,
    pgn: '1. e4 *',
    openingName: 'Scotch Game',
    eco: 'C45',
    userColor: userColor,
  );
}

ArchivedGame _archived({required String result}) {
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
    qualityCounts: const {MoveQuality.blunder: 3},
    averageCpLoss: 24,
    totalPlies: 40,
    openingName: 'Andersen Opening',
    ecoCode: 'A00',
  );
}
