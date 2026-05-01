/// UI-only helpers for the PGN paste dialog.
library;

import 'package:apex_chess/core/domain/services/game_identity_service.dart';

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
}
