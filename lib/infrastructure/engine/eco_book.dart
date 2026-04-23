/// Local ECO opening book — FEN → { code, name } lookup.
///
/// Loaded once on first access from the bundled
/// `assets/openings/eco.tsv` (derived from the lichess-org/chess-openings
/// dataset, MIT license — ~3690 lines, ~368 KB). Each row contains:
///
/// ```
/// eco <TAB> name <TAB> pgn
/// A00     Amar Opening    1. Nh3
/// ```
///
/// At load time we:
///   1. Parse the short PGN with **dartchess** to obtain the resulting
///      position.
///   2. Normalise the FEN to the "piece placement + side to move +
///      castling rights + en-passant" prefix (the first four fields),
///      stripping the halfmove clock and fullmove counter so the same
///      position reached by different move orders still matches.
///   3. Index that prefix → [EcoEntry] in an in-memory map.
///
/// The analyzer calls [contains] / [lookup] on every pre-move FEN. A hit
/// means the move played reaches a known theoretical position and can be
/// classified as [MoveQuality.book] — bypassing the Stockfish search and
/// saving substantial battery in the opening phase.
///
/// If loading fails (asset missing, corrupt, or on platforms where
/// `rootBundle` is unavailable — tests) the book silently degrades to an
/// empty set and the analyzer falls back to engine-only classification.
library;

import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/services.dart' show rootBundle;

class EcoEntry {
  const EcoEntry({required this.eco, required this.name});
  final String eco;
  final String name;
}

class EcoBook {
  EcoBook._(this._positions);

  final Map<String, EcoEntry> _positions;

  /// Async factory — loads and indexes the bundled TSV. Never throws; on
  /// failure returns an empty book.
  static Future<EcoBook> load({
    String assetPath = 'assets/openings/eco.tsv',
  }) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      return _fromTsv(raw);
    } catch (_) {
      return EcoBook._(const {});
    }
  }

  /// Synchronous factory for tests — takes a TSV body directly.
  static EcoBook fromTsv(String body) => _fromTsv(body);

  static EcoBook _fromTsv(String body) {
    final map = <String, EcoEntry>{};
    final lines = body.split('\n');
    for (final line in lines) {
      if (line.isEmpty) continue;
      if (line.startsWith('eco\t')) continue; // header
      final cols = line.split('\t');
      if (cols.length < 3) continue;
      final eco = cols[0].trim();
      final name = cols[1].trim();
      final pgn = cols[2].trim();
      if (eco.isEmpty || name.isEmpty || pgn.isEmpty) continue;
      final fen = _fenFromPgn(pgn);
      if (fen == null) continue;
      // Keep the first entry per position — the TSV is sorted with shorter
      // (more general) openings before their deeper variations, so this
      // preserves the broadest classification for a given FEN prefix.
      map.putIfAbsent(fen, () => EcoEntry(eco: eco, name: name));
    }
    return EcoBook._(map);
  }

  /// Normalises a full FEN to the "piece placement + side + castling +
  /// en passant" prefix — the 50-move and fullmove counters vary between
  /// routes to the same position and would cause false misses.
  static String _normalise(String fen) {
    final parts = fen.split(' ');
    if (parts.length < 4) return fen;
    return parts.take(4).join(' ');
  }

  static String? _fenFromPgn(String pgn) {
    try {
      Position pos = Chess.initial;
      // Strip move numbers and annotations.
      final cleaned = pgn
          .replaceAll(RegExp(r'\{[^}]*\}'), ' ')
          .replaceAll(RegExp(r'\([^)]*\)'), ' ')
          .replaceAll(RegExp(r'\d+\.(\.\.)?'), ' ')
          .split(RegExp(r'\s+'))
          .where((t) => t.isNotEmpty && !_isResultToken(t))
          .toList();
      for (final san in cleaned) {
        final move = pos.parseSan(san);
        if (move == null) return null;
        pos = pos.play(move);
      }
      return _normalise(pos.fen);
    } catch (_) {
      return null;
    }
  }

  static bool _isResultToken(String s) =>
      s == '1-0' || s == '0-1' || s == '1/2-1/2' || s == '*';

  /// Total number of indexed positions — useful for tests and diagnostics.
  int get size => _positions.length;

  bool contains(String fen) => _positions.containsKey(_normalise(fen));

  EcoEntry? lookup(String fen) => _positions[_normalise(fen)];
}
