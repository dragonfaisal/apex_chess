/// UI-only helpers for the PGN paste dialog.
library;

import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/core/domain/services/game_identity_service.dart';
import 'package:apex_chess/infrastructure/engine/eco_book.dart';
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
    EcoBook? ecoBook,
  }) {
    final header = _composeOpening(identity.eco, identity.opening);
    if (header != null) return header;

    final bookHit = ecoBook == null ? null : _lookupEcoBook(pgn, ecoBook);
    if (bookHit != null) return '${bookHit.eco} · ${bookHit.name}';

    return _basicOpeningFallback(pgn) ?? ApexCopy.openingNotDetected;
  }

  static EcoEntry? _lookupEcoBook(String pgn, EcoBook ecoBook) {
    try {
      Position position = Chess.initial;
      EcoEntry? best;
      for (final san in _sanTokens(pgn)) {
        final move = position.parseSan(san);
        if (move == null) break;
        position = position.play(move);
        final hit = ecoBook.lookup(position.fen);
        if (hit != null) best = hit;
      }
      return best;
    } catch (_) {
      return null;
    }
  }

  static String? _basicOpeningFallback(String pgn) {
    final tokens = _sanTokens(pgn).take(6).toList(growable: false);
    for (final opening in _basicOpenings) {
      if (_startsWith(tokens, opening.$1)) return opening.$2;
    }
    return null;
  }

  static List<String> _sanTokens(String pgn) {
    var body = pgn
        .replaceAll(RegExp(r'^\s*\[[^\]]+\]\s*$', multiLine: true), ' ')
        .replaceAll(RegExp(r'\{[^}]*\}'), ' ')
        .replaceAll(RegExp(r';[^\n\r]*'), ' ')
        .replaceAll(RegExp(r'\([^)]*\)'), ' ')
        .replaceAll(RegExp(r'\$\d+'), ' ')
        .replaceAll(RegExp(r'\d+\.(\.\.)?'), ' ');
    return body
        .split(RegExp(r'\s+'))
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .where((token) => !_isResultToken(token))
        .map((token) => token.replaceAll(RegExp(r'[!?+#]+$'), ''))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
  }

  static String? _composeOpening(String? eco, String? opening) {
    final cleanEco = _clean(eco);
    final cleanOpening = _clean(opening);
    if (cleanEco == null && cleanOpening == null) return null;
    if (cleanEco != null && cleanOpening != null) {
      return '$cleanEco · $cleanOpening';
    }
    return cleanOpening ?? cleanEco;
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed == '?') return null;
    return trimmed;
  }

  static bool _startsWith(List<String> tokens, List<String> prefix) {
    if (tokens.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (tokens[i] != prefix[i]) return false;
    }
    return true;
  }

  static bool _isResultToken(String token) =>
      token == '1-0' || token == '0-1' || token == '1/2-1/2' || token == '*';

  static const List<(List<String>, String)> _basicOpenings = [
    (['e4', 'e5', 'Nf3', 'Nc6', 'Bb5'], 'C60 · Ruy Lopez'),
    (['e4', 'e5', 'Nf3', 'Nc6', 'Bc4'], 'C50 · Italian Game'),
    (['e4', 'e5', 'Nf3', 'Nc6', 'd4'], 'C44 · Scotch Game'),
    (['e4', 'e5', 'Nf3', 'Nc6', 'Nc3', 'Nf6'], 'C47 · Four Knights Game'),
    (['e4', 'e5', 'Nf3', 'Nf6'], 'C42 · Petrov Defense'),
    (['e4', 'e5', 'Nf3', 'd6'], 'C41 · Philidor Defense'),
    (['e4', 'c5'], 'B20 · Sicilian Defense'),
    (['e4', 'e6'], 'C00 · French Defense'),
    (['e4', 'c6'], 'B10 · Caro-Kann Defense'),
    (['e4', 'd5'], 'B01 · Scandinavian Defense'),
    (['e4', 'Nf6'], 'B02 · Alekhine Defense'),
    (['e4', 'd6', 'd4', 'Nf6', 'Nc3', 'g6'], 'B07 · Pirc Defense'),
    (['e4', 'g6'], 'B06 · Modern Defense'),
    (['d4', 'Nf6', 'c4', 'g6'], 'E60 · King\'s Indian Defense'),
    (['d4', 'Nf6', 'c4', 'g6', 'Nc3', 'd5'], 'D70 · Grunfeld Defense'),
    (['d4', 'd5', 'c4'], 'D06 · Queen\'s Gambit'),
    (['d4', 'd5', 'c4', 'c6'], 'D10 · Slav Defense'),
    (['d4', 'd5', 'Bf4'], 'D02 · London System'),
    (['d4', 'f5'], 'A80 · Dutch Defense'),
    (['d4', 'Nf6', 'c4', 'e6', 'Nc3', 'Bb4'], 'E20 · Nimzo-Indian Defense'),
    (['d4', 'Nf6', 'c4', 'e6'], 'E10 · Indian Game'),
    (['c4', 'e5'], 'A20 · English Opening'),
    (['Nf3', 'd5'], 'A04 · Zukertort Opening'),
  ];
}
