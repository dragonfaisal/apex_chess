/// Coach-style explanation text for an engine "better move" suggestion.
///
/// Designed to render under the existing `Better: <SAN>` line in the
/// Review coach card so the user sees both the engine's notation **and**
/// a one-sentence rationale they can act on without parsing UCI / SAN
/// in their head.
///
/// The text is intentionally deterministic — we never *invent* tactical
/// reasons (e.g. "this defends the back rank") because we don't run a
/// secondary engine pass over the candidate line. We compose only what
/// we can prove from the inputs:
///
///   * the piece name (decoded from SAN's leading letter or pawn fall-
///     through),
///   * the destination square (last two characters of the UCI before
///     any promotion suffix),
///   * a verb tuned to the classification of the *played* move.
///
/// Falls back to `null` for inputs we can't parse so callers can hide
/// the row instead of rendering "Move the null to ?".
library;

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';

class BetterMoveExplanation {
  const BetterMoveExplanation({
    required this.from,
    required this.to,
    required this.sentence,
  });

  /// Algebraic source square (e.g. `f8`).
  final String from;

  /// Algebraic destination square (e.g. `e7`).
  final String to;

  /// Coach sentence — one short line, suitable for an italic caption
  /// beneath the SAN.
  final String sentence;

  /// Build a fully-formed explanation, or `null` when [bestMoveUci] /
  /// [bestMoveSan] don't carry enough information.
  ///
  /// [playedQuality] tunes the verb so the user reads severity along
  /// with the suggestion: "Move the bishop to e7 to **avoid losing
  /// material**" reads correctly for a Mistake but not for a Best.
  ///
  /// (Renamed from `from` to avoid clashing with the constructor's
  /// implicit `BetterMoveExplanation.from` factory name in Dart.)
  static BetterMoveExplanation? compose({
    required String? bestMoveUci,
    required String? bestMoveSan,
    required MoveQuality playedQuality,
  }) {
    if (bestMoveUci == null) return null;
    final norm = normalizeCastlingUci(bestMoveUci);
    if (norm.length < 4) return null;
    final fromSq = norm.substring(0, 2);
    final toSq = norm.substring(2, 4);
    if (!_isAlgebraic(fromSq) || !_isAlgebraic(toSq)) return null;

    final piece = _pieceFromSan(bestMoveSan) ?? 'piece';
    final verb = _verbForClassification(playedQuality);
    final isCastle = bestMoveSan != null &&
        (bestMoveSan.startsWith('O-O-O') || bestMoveSan.startsWith('O-O'));
    final isPromotion = norm.length >= 5;
    final destPhrase = isCastle
        ? (bestMoveSan.startsWith('O-O-O')
            ? 'castle queenside'
            : 'castle kingside')
        : isPromotion
            ? 'promote on $toSq'
            : 'move the $piece to $toSq';

    final sentence = '${_capitalise(destPhrase)} $verb';
    return BetterMoveExplanation(
      from: fromSq,
      to: toSq,
      sentence: sentence,
    );
  }

  static bool _isAlgebraic(String s) {
    if (s.length != 2) return false;
    final f = s.codeUnitAt(0);
    final r = s.codeUnitAt(1);
    return f >= 0x61 /* a */ && f <= 0x68 /* h */ &&
        r >= 0x31 /* 1 */ && r <= 0x38 /* 8 */;
  }

  static String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static String? _pieceFromSan(String? san) {
    if (san == null || san.isEmpty) return null;
    if (san.startsWith('O-O-O') || san.startsWith('O-O')) return 'king';
    final c = san[0];
    return switch (c) {
      'K' => 'king',
      'Q' => 'queen',
      'R' => 'rook',
      'B' => 'bishop',
      'N' => 'knight',
      _ => 'pawn',
    };
  }

  /// Verb / clause matching the *played* move's classification.
  ///
  /// We never claim a specific tactical reason ("to defend the king",
  /// "to fork the queen") because that would require a second engine
  /// pass. Instead we tune the *severity* of the recommendation so the
  /// user reads "avoid losing material" on a Blunder and "keep the
  /// initiative" on a Best.
  static String _verbForClassification(MoveQuality q) {
    switch (q) {
      case MoveQuality.blunder:
        return 'to avoid losing material and steady the position.';
      case MoveQuality.mistake:
        return 'to keep the position safe and recover the eval.';
      case MoveQuality.inaccuracy:
        return 'for a stronger continuation that holds the eval.';
      case MoveQuality.good:
      case MoveQuality.excellent:
        return 'to stay flush with the engine\'s top line.';
      case MoveQuality.best:
      case MoveQuality.brilliant:
      case MoveQuality.great:
      case MoveQuality.book:
        return 'to maintain the initiative.';
    }
  }
}
