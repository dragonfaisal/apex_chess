library;

import 'package:apex_chess/features/archives/domain/archived_game.dart';
import 'package:apex_chess/features/pgn_review/domain/review_entry_contract.dart';

ArchivedGame? findOpenableCanonicalSavedReview({
  required Iterable<ArchivedGame> games,
  required String pgn,
  required String white,
  required String black,
  required String result,
  DateTime? playedAt,
}) {
  final key = ArchivedGame.canonicalKeyFor(
    pgn: pgn,
    white: white,
    black: black,
    result: result,
    playedAt: playedAt,
  );
  final matches = games.where(
    (game) =>
        game.canonicalGameKey == key &&
        ReviewEntryContract.canOpenCachedReview(game),
  );
  final collapsed = ArchivedGame.collapseCanonical(matches);
  return collapsed.isEmpty ? null : collapsed.first;
}
