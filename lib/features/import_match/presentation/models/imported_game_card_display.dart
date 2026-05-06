/// Import Games adapter for the shared Apex game card.
library;

import 'package:apex_chess/features/import_match/domain/imported_game.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/widgets/apex_game_card.dart';

extension ImportedGameCardDisplay on ImportedGame {
  ApexGameCardDisplayModel toApexGameCardDisplay() {
    return ApexGameCardDisplayModel(
      resultTone: importResultTone,
      white: ApexGamePlayerDisplay(
        side: ApexPlayerSide.white,
        name: whiteName,
        rating: whiteRating?.toString(),
        isUser: userColor == PlayerColor.white,
        platform: source.identityPlatform,
      ),
      black: ApexGamePlayerDisplay(
        side: ApexPlayerSide.black,
        name: blackName,
        rating: blackRating?.toString(),
        isUser: userColor == PlayerColor.black,
        platform: source.identityPlatform,
      ),
      primaryMeta: importOpeningLine,
      secondaryMeta: importSourceLine,
    );
  }

  GameResultTone get importResultTone {
    if (result == GameResult.draw) return GameResultTone.draw;
    if (userColor == null || result == GameResult.unknown) {
      return GameResultTone.unknown;
    }
    final won =
        (userColor == PlayerColor.white && result == GameResult.whiteWon) ||
        (userColor == PlayerColor.black && result == GameResult.blackWon);
    return won ? GameResultTone.won : GameResultTone.lost;
  }

  String get importOpeningLine {
    final opening = openingName == null || openingName!.trim().isEmpty
        ? ApexCopy.openingNotDetected
        : '${eco == null || eco!.trim().isEmpty ? '' : '${eco!.trim()} '}${openingName!.trim()}';
    return '$opening · $moveCount moves';
  }

  String get importSourceLine {
    return [
      sourceLabel,
      if (timeControl != null && timeControl!.trim().isNotEmpty)
        timeControl!.trim(),
      relativeTime,
    ].join(' · ');
  }
}

extension on GameSource {
  PlayerIdentityPlatform get identityPlatform {
    return switch (this) {
      GameSource.chessCom => PlayerIdentityPlatform.chessCom,
      GameSource.lichess => PlayerIdentityPlatform.lichess,
    };
  }
}
