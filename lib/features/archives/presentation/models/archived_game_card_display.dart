/// Archive adapter for the shared Apex game card.
library;

import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/shared_ui/identity/player_identity_display.dart';
import 'package:apex_chess/shared_ui/widgets/apex_game_card.dart';

extension ArchivedGameCardDisplay on ArchivedGame {
  ApexGameCardDisplayModel toApexGameCardDisplay({String? userHandle}) {
    final userIsBlack = userIsBlackFor(userHandle);
    final moveCount = (totalPlies / 2).ceil();
    return ApexGameCardDisplayModel(
      resultTone: archiveResultTone(userHandle: userHandle),
      white: ApexGamePlayerDisplay(
        side: ApexPlayerSide.white,
        name: white,
        rating: _archiveRatingOrNull(whiteRating),
        isUser: userIsBlack == false,
        platform: source.identityPlatform,
      ),
      black: ApexGamePlayerDisplay(
        side: ApexPlayerSide.black,
        name: black,
        rating: _archiveRatingOrNull(blackRating),
        isUser: userIsBlack == true,
        platform: source.identityPlatform,
      ),
      primaryMeta: '$openingLine · $moveCount moves',
      secondaryMeta: [
        sourceLabel,
        reviewModeLabel,
        relativePlayedAt,
      ].join(' · '),
      badges: archiveQualityBadges,
    );
  }

  GameResultTone archiveResultTone({String? userHandle}) {
    if (result == '1/2-1/2') return GameResultTone.draw;
    final userIsBlack = userIsBlackFor(userHandle);
    if (userIsBlack == null) return GameResultTone.unknown;
    final won =
        (!userIsBlack && result == '1-0') || (userIsBlack && result == '0-1');
    return won ? GameResultTone.won : GameResultTone.lost;
  }

  List<String> get archiveQualityBadges {
    return [
      if (missCount > 0) 'Miss $missCount',
      if (blunderCount > 0) 'Blunder $blunderCount',
      if (brilliantCount > 0) 'Brilliant $brilliantCount',
      if (greatCount > 0) 'Great $greatCount',
    ];
  }
}

extension on ArchiveSource {
  PlayerIdentityPlatform get identityPlatform {
    return switch (this) {
      ArchiveSource.chessCom => PlayerIdentityPlatform.chessCom,
      ArchiveSource.lichess => PlayerIdentityPlatform.lichess,
      ArchiveSource.pgn => PlayerIdentityPlatform.pgn,
    };
  }
}

String? _archiveRatingOrNull(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  return value;
}
