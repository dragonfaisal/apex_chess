/// Position-level heuristics shared by both local + cloud analyzers.
///
/// These are intentionally engine-agnostic — they look only at the FEN
/// before / after the played move (and optionally after the opponent's
/// reply) so the same sacrifice + material-balance signals fire whether
/// the verdict came from on-device Stockfish or from Lichess Cloud Eval.
library;

import 'package:dartchess/dartchess.dart';

class PositionHeuristics {
  PositionHeuristics._();

  /// Did the mover surrender ≥ a minor piece's worth of material on this
  /// ply *without* the opponent immediately reclaiming it?
  ///
  /// [afterReplyFen] is the FEN after the opponent's reply (or after the
  /// played move when this was the last ply). The balance is computed in
  /// raw piece points (P=1, N=3, B=3, R=5, Q=9) and normalised to the
  /// mover's perspective before thresholding. A `null` parse on either
  /// side returns `false` so the analyser never invents brilliancies.
  static bool isSacrificeMove({
    required String before,
    required String afterReplyFen,
    required bool isWhiteMove,
  }) {
    final balanceBefore = materialBalanceFromFen(before);
    final balanceAfter = materialBalanceFromFen(afterReplyFen);
    if (balanceBefore == null || balanceAfter == null) return false;
    final moverSign = isWhiteMove ? 1 : -1;
    final delta = (balanceAfter - balanceBefore) * moverSign;
    return delta <= -3;
  }

  /// Raw material balance (White − Black) in piece points, or `null` if
  /// the FEN can't be parsed.
  static int? materialBalanceFromFen(String fen) {
    try {
      final pos = Chess.fromSetup(Setup.parseFen(fen));
      int total = 0;
      for (final side in [Side.white, Side.black]) {
        final sign = side == Side.white ? 1 : -1;
        final pieces = pos.board.bySide(side);
        for (final sq in pieces.squares) {
          final p = pos.board.pieceAt(sq);
          if (p == null) continue;
          total += sign * pieceValue(p.role);
        }
      }
      return total;
    } catch (_) {
      return null;
    }
  }

  static int pieceValue(Role role) => switch (role) {
        Role.pawn => 1,
        Role.knight => 3,
        Role.bishop => 3,
        Role.rook => 5,
        Role.queen => 9,
        Role.king => 0,
      };
}
