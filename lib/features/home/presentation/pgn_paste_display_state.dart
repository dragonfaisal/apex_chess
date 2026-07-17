/// UI-only helpers for the PGN paste dialog.
library;

import 'package:apex_chess/core/domain/entities/opening_evidence.dart';
import 'package:apex_chess/core/domain/services/game_identity_service.dart';
import 'package:apex_chess/core/domain/services/pgn_mainline_validator.dart';
import 'package:apex_chess/shared_ui/copy/apex_copy.dart';

class PgnPasteDisplayState {
  const PgnPasteDisplayState._();

  static const parseDebounce = Duration(milliseconds: 350);

  static bool shouldCollapseInput({
    required String pgn,
    required PgnGameIdentity identity,
  }) {
    final text = pgn.trim();
    if (text.length < 8) return false;
    if (identity.moveCount <= 0) return false;
    return RegExp(r'\b1\.(\.\.)?').hasMatch(text) ||
        RegExp(r'^\s*\[[A-Za-z0-9_]+\s+"', multiLine: true).hasMatch(text);
  }

  static String sideLabel(bool userIsWhite) => ApexCopy.youPlayed(userIsWhite);

  static String openingLabel({
    required String pgn,
    required PgnGameIdentity identity,
    OpeningLookup? openingLookup,
  }) {
    if (openingLookup == null) return ApexCopy.openingDataLoading;
    if (!openingLookup.isAvailable) return ApexCopy.openingDataUnavailable;

    final selected = _lookupOpening(pgn, openingLookup);
    if (selected != null) {
      return '${selected.ecoCode} · ${selected.openingName}';
    }
    return ApexCopy.openingNotDetected;
  }

  static OpeningCandidate? _lookupOpening(
    String pgn,
    OpeningLookup openingLookup,
  ) {
    try {
      final game = const PgnMainlineValidator().validate(pgn);
      final headers = <String, String>{
        for (final entry in game.headers.entries)
          entry.key.trim().toLowerCase(): entry.value.trim(),
      };
      final standardStart =
          headers['setup'] != '1' &&
          !headers.containsKey('fen') &&
          OpeningPositionKey.isStandardInitialFen(game.startingFen);
      final evidence = <OpeningEvidence>[];
      for (var ply = 0; ply < game.moves.length; ply++) {
        final move = game.moves[ply];
        evidence.add(
          openingLookup.lookupTransition(
            fenBefore: move.fenBefore,
            playedMoveUci: move.uci,
            fenAfter: move.fenAfter,
            ply: ply,
            standardStart: standardStart,
          ),
        );
      }
      return OpeningEvidence.deepestNamed(evidence);
    } catch (_) {
      return null;
    }
  }
}
