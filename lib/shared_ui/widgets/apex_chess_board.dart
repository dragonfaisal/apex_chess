/// High-performance interactive chess board — Cyber/Electric Blue edition.
///
/// Architecture:
///   • [CustomPaint] draws squares, highlights, and legal-move dots.
///   • [SvgPicture] overlays render pieces with flutter_svg caching.
///   • [GestureDetector] converts taps to algebraic squares.
///   • SVG quality icons overlay the target square of the last move.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:apex_chess/shared_ui/themes/apex_theme.dart';
import 'package:apex_chess/shared_ui/widgets/move_quality_aura.dart';
import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public Widget
// ─────────────────────────────────────────────────────────────────────────────

class ApexChessBoard extends StatelessWidget {
  final String fen;
  final bool flipped;
  final String? selectedSquare;
  final List<String> legalMoveSquares;
  final (String, String)? lastMove;
  final bool isCheck;
  final ValueChanged<String>? onSquareTapped;
  final MoveQuality? lastMoveQuality;

  /// Optional engine "better move" arrow rendered from the source square
  /// to the destination, in algebraic form (e.g. `('f8', 'e7')` for
  /// `Be7`). Independent of [lastMove] so the arrow can survive and
  /// guide the user even when the last-played move is highlighted in a
  /// different colour. `null` hides the arrow entirely.
  final (String, String)? betterMove;

  const ApexChessBoard({
    super.key,
    required this.fen,
    this.flipped = false,
    this.selectedSquare,
    this.legalMoveSquares = const [],
    this.lastMove,
    this.isCheck = false,
    this.onSquareTapped,
    this.lastMoveQuality,
    this.betterMove,
  });

  @override
  Widget build(BuildContext context) {
    final pieces = _parseFen(fen);
    return AspectRatio(
      aspectRatio: 1.0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boardSize = constraints.maxWidth;
          final squareSize = boardSize / 8;
          return GestureDetector(
            onTapUp: (details) => _handleTap(details, squareSize),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ApexBoardPainter(flipped: flipped),
                    isComplex: false, willChange: false,
                  ),
                ),
                if (lastMove != null) ...[
                  _buildHighlight(lastMove!.$1, squareSize,
                      ApexColors.electricBlue.withAlpha(25)),
                  _buildHighlight(lastMove!.$2, squareSize,
                      ApexColors.electricBlue.withAlpha(40)),
                  // Castling: detect from king's 2-square horizontal hop
                  // on the back rank and highlight the rook's trail so the
                  // eye reads the move as a single combined action
                  // instead of a king move with a rook that "teleports".
                  ..._buildCastlingRookHighlight(lastMove!, squareSize),
                ],
                if (selectedSquare != null)
                  _buildHighlight(selectedSquare!, squareSize,
                      ApexColors.electricBlue.withAlpha(65)),
                if (isCheck) _buildCheckHighlight(pieces, squareSize),
                for (final sq in legalMoveSquares)
                  _buildLegalMoveIndicator(sq, squareSize,
                      isOccupied: pieces.values.any((e) =>
                          e.$1 == _fileFromAlgebraic(sq) &&
                          e.$2 == _rankFromAlgebraic(sq))),
                // Per-quality breathing neon aura on the move's target
                // square. Rendered under the piece so the piece reads
                // against a glowing halo instead of being washed out.
                if (lastMove != null && lastMoveQuality != null)
                  _buildQualityAura(
                      lastMove!.$2, squareSize, lastMoveQuality!),
                for (final entry in pieces.entries)
                  _buildPiece(entry.key, entry.value, squareSize),
                if (lastMove != null && lastMoveQuality != null)
                  _buildQualityOverlay(
                      lastMove!.$2, squareSize, lastMoveQuality!),
                // Engine "better move" arrow + destination halo. Drawn
                // *after* pieces so it reads on top of the board, but
                // *before* coordinates so the file/rank labels stay
                // legible. Only renders for valid algebraic squares —
                // out-of-band data is silently skipped.
                if (betterMove != null) ...[
                  _buildBetterMoveHalo(betterMove!.$2, squareSize),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _BetterMoveArrowPainter(
                          fromFile: _fileFromAlgebraic(betterMove!.$1),
                          fromRank: _rankFromAlgebraic(betterMove!.$1),
                          toFile: _fileFromAlgebraic(betterMove!.$2),
                          toRank: _rankFromAlgebraic(betterMove!.$2),
                          flipped: flipped,
                        ),
                        isComplex: false,
                        willChange: false,
                      ),
                    ),
                  ),
                ],
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CoordinatePainter(flipped: flipped),
                    isComplex: false, willChange: false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleTap(TapUpDetails details, double squareSize) {
    if (onSquareTapped == null) return;
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;
    int file = (dx / squareSize).floor().clamp(0, 7);
    int rank = (dy / squareSize).floor().clamp(0, 7);
    if (flipped) { file = 7 - file; rank = 7 - rank; }
    else { rank = 7 - rank; }
    final algebraic =
        '${String.fromCharCode('a'.codeUnitAt(0) + file)}${rank + 1}';
    onSquareTapped!(algebraic);
  }

  Widget _buildHighlight(String square, double squareSize, Color color) {
    final pos = _squareToPosition(square, squareSize);
    return Positioned(
      left: pos.dx, top: pos.dy, width: squareSize, height: squareSize,
      child: Container(color: color),
    );
  }

  /// If [lastMove] is a castling king-hop, return a pair of highlights for
  /// the rook's corresponding move. Supports all four castling patterns:
  ///
  ///   e1g1 ⇢ h1f1 (White kingside)   e1c1 ⇢ a1d1 (White queenside)
  ///   e8g8 ⇢ h8f8 (Black kingside)   e8c8 ⇢ a8d8 (Black queenside)
  ///
  /// Returns an empty list for any non-castling move — cheap guard, runs
  /// once per rebuild, and callers can spread the result unconditionally.
  List<Widget> _buildCastlingRookHighlight(
      (String, String) move, double squareSize) {
    final (from, to) = move;
    if (from.length != 2 || to.length != 2) return const [];
    // Must be a king starting on e-file and landing on g/c-file of the
    // same rank 1 or 8.
    if (from[0] != 'e' || from[1] != to[1]) return const [];
    final rank = from[1];
    if (rank != '1' && rank != '8') return const [];
    String rookFrom;
    String rookTo;
    switch (to[0]) {
      case 'g':
        rookFrom = 'h$rank';
        rookTo = 'f$rank';
      case 'c':
        rookFrom = 'a$rank';
        rookTo = 'd$rank';
      default:
        return const [];
    }
    return [
      _buildHighlight(rookFrom, squareSize,
          ApexColors.electricBlue.withAlpha(25)),
      _buildHighlight(rookTo, squareSize,
          ApexColors.electricBlue.withAlpha(40)),
    ];
  }

  Widget _buildCheckHighlight(
      Map<String, (int, int, String)> pieces, double squareSize) {
    final fenParts = fen.split(' ');
    final sideToMove = fenParts.length > 1 ? fenParts[1] : 'w';
    final kingChar = sideToMove == 'w' ? 'K' : 'k';
    for (final entry in pieces.entries) {
      if (entry.value.$3 == kingChar) {
        final pos = _squareToPositionFromFileRank(
            entry.value.$1, entry.value.$2, squareSize);
        return Positioned(
          left: pos.dx, top: pos.dy, width: squareSize, height: squareSize,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [
                ApexColors.blunder.withAlpha(180),
                ApexColors.blunder.withAlpha(60),
                Colors.transparent,
              ], stops: const [0.0, 0.5, 1.0]),
            ),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildLegalMoveIndicator(String square, double squareSize,
      {bool isOccupied = false}) {
    final pos = _squareToPosition(square, squareSize);
    return Positioned(
      left: pos.dx, top: pos.dy, width: squareSize, height: squareSize,
      child: Center(
        child: isOccupied
            ? Container(
                width: squareSize * 0.95, height: squareSize * 0.95,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  border: Border.all(
                    color: ApexColors.electricBlue.withAlpha(100),
                    width: squareSize * 0.08)))
            : Container(
                width: squareSize * 0.28, height: squareSize * 0.28,
                decoration: BoxDecoration(
                  color: ApexColors.electricBlue.withAlpha(90),
                  shape: BoxShape.circle)),
      ),
    );
  }

  Widget _buildQualityAura(
      String square, double squareSize, MoveQuality quality) {
    final pos = _squareToPosition(square, squareSize);
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      width: squareSize,
      height: squareSize,
      child: MoveQualityAura(
        // `ValueKey` forces a fresh controller when the quality flips
        // on the same square — otherwise the breath would continue
        // from a stale phase when stepping through the review timeline.
        key: ValueKey('aura-$square-${quality.name}'),
        quality: quality,
      ),
    );
  }

  Widget _buildQualityOverlay(
      String square, double squareSize, MoveQuality quality) {
    final pos = _squareToPosition(square, squareSize);
    final iconSize = squareSize * 0.38;
    return Positioned(
      left: pos.dx + squareSize - iconSize - 1,
      top: pos.dy + 1, width: iconSize, height: iconSize,
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(color: quality.color.withAlpha(80),
              blurRadius: 6, spreadRadius: -1),
        ]),
        child: SvgPicture.asset(quality.svgAssetPath, fit: BoxFit.contain),
      ),
    );
  }

  /// Soft cyan halo on the destination square of the engine's better
  /// move — reads as "look here" without competing with the per-quality
  /// aura already on the played-move square.
  Widget _buildBetterMoveHalo(String square, double squareSize) {
    final pos = _squareToPosition(square, squareSize);
    return Positioned(
      left: pos.dx,
      top: pos.dy,
      width: squareSize,
      height: squareSize,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: ApexColors.electricBlue.withAlpha(45),
            border: Border.all(
              color: ApexColors.electricBlue.withAlpha(160),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildPiece(String key, (int, int, String) value, double squareSize) {
    final (file, rank, pieceChar) = value;
    final pos = _squareToPositionFromFileRank(file, rank, squareSize);
    return Positioned(
      left: pos.dx, top: pos.dy, width: squareSize, height: squareSize,
      child: Padding(
        padding: EdgeInsets.all(squareSize * 0.05),
        child: SvgPicture.asset(_pieceAssetPath(pieceChar), fit: BoxFit.contain),
      ),
    );
  }

  Offset _squareToPosition(String algebraic, double squareSize) {
    final file = _fileFromAlgebraic(algebraic);
    final rank = _rankFromAlgebraic(algebraic);
    return _squareToPositionFromFileRank(file, rank, squareSize);
  }

  Offset _squareToPositionFromFileRank(int file, int rank, double squareSize) {
    final displayFile = flipped ? (7 - file) : file;
    final displayRank = flipped ? rank : (7 - rank);
    return Offset(displayFile * squareSize, displayRank * squareSize);
  }

  static int _fileFromAlgebraic(String sq) =>
      sq.codeUnitAt(0) - 'a'.codeUnitAt(0);
  static int _rankFromAlgebraic(String sq) => int.parse(sq[1]) - 1;

  Map<String, (int, int, String)> _parseFen(String fen) {
    final placement = fen.split(' ').first;
    final ranks = placement.split('/');
    final pieces = <String, (int, int, String)>{};
    for (int fenRank = 0; fenRank < ranks.length && fenRank < 8; fenRank++) {
      int file = 0;
      for (final char in ranks[fenRank].runes) {
        final c = String.fromCharCode(char);
        if (file >= 8) break;
        final digit = int.tryParse(c);
        if (digit != null) { file += digit; }
        else {
          final boardRank = 7 - fenRank;
          pieces['$file-$boardRank-$c'] = (file, boardRank, c);
          file++;
        }
      }
    }
    return pieces;
  }

  static String _pieceAssetPath(String fenChar) {
    final color = fenChar == fenChar.toUpperCase() ? 'w' : 'b';
    final piece = fenChar.toUpperCase();
    return 'assets/pieces/$color$piece.svg';
  }
}

class _ApexBoardPainter extends CustomPainter {
  final bool flipped;
  _ApexBoardPainter({this.flipped = false});
  static const Color _lightSquare = Color(0xFF333340);
  static const Color _darkSquare = Color(0xFF1E1E28);

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 8;
    final lightPaint = Paint()..color = _lightSquare;
    final darkPaint = Paint()..color = _darkSquare;
    for (int rank = 0; rank < 8; rank++) {
      for (int file = 0; file < 8; file++) {
        final isLight = (rank + file) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(file * squareSize, rank * squareSize,
              squareSize, squareSize),
          isLight ? lightPaint : darkPaint);
      }
    }
    final borderPaint = Paint()
      ..color = ApexColors.electricBlue.withAlpha(50)
      ..style = PaintingStyle.stroke ..strokeWidth = 1.5;
    canvas.drawRect(Offset.zero & size, borderPaint);
  }

  @override
  bool shouldRepaint(_ApexBoardPainter oldDelegate) =>
      flipped != oldDelegate.flipped;
}

/// Draws an electric-blue arrow from the source to destination square
/// of the engine's better-move suggestion. Coordinates are board-local
/// (top-left origin) and respect [flipped] so a Black-perspective board
/// still draws the arrow correctly.
class _BetterMoveArrowPainter extends CustomPainter {
  _BetterMoveArrowPainter({
    required this.fromFile,
    required this.fromRank,
    required this.toFile,
    required this.toRank,
    required this.flipped,
  });

  final int fromFile;
  final int fromRank;
  final int toFile;
  final int toRank;
  final bool flipped;

  @override
  void paint(Canvas canvas, Size size) {
    if (fromFile < 0 || fromFile > 7 || toFile < 0 || toFile > 7) return;
    if (fromRank < 0 || fromRank > 7 || toRank < 0 || toRank > 7) return;
    if (fromFile == toFile && fromRank == toRank) return;

    final squareSize = size.width / 8;
    Offset center(int file, int rank) {
      final df = flipped ? 7 - file : file;
      final dr = flipped ? rank : 7 - rank;
      return Offset(
        df * squareSize + squareSize / 2,
        dr * squareSize + squareSize / 2,
      );
    }

    final start = center(fromFile, fromRank);
    final end = center(toFile, toRank);
    final dir = end - start;
    final dist = dir.distance;
    if (dist <= 1) return;
    final unit = Offset(dir.dx / dist, dir.dy / dist);

    // Pull the shaft endpoints in by a small margin so the arrow
    // doesn't overlap the centre of the source piece nor poke past the
    // destination square.
    final shaftStart = start + unit * (squareSize * 0.32);
    final tip = end - unit * (squareSize * 0.18);
    final shaftEnd = tip - unit * (squareSize * 0.30);

    final shaftPaint = Paint()
      ..color = ApexColors.electricBlue.withAlpha(220)
      ..style = PaintingStyle.stroke
      ..strokeWidth = squareSize * 0.16
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(shaftStart, shaftEnd, shaftPaint);

    final perp = Offset(-unit.dy, unit.dx);
    final headHalfWidth = squareSize * 0.28;
    final headBaseLeft = shaftEnd + perp * headHalfWidth;
    final headBaseRight = shaftEnd - perp * headHalfWidth;
    final headPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(headBaseLeft.dx, headBaseLeft.dy)
      ..lineTo(headBaseRight.dx, headBaseRight.dy)
      ..close();
    final headPaint = Paint()
      ..color = ApexColors.electricBlue.withAlpha(230)
      ..style = PaintingStyle.fill;
    canvas.drawPath(headPath, headPaint);
  }

  @override
  bool shouldRepaint(_BetterMoveArrowPainter old) =>
      old.fromFile != fromFile ||
      old.fromRank != fromRank ||
      old.toFile != toFile ||
      old.toRank != toRank ||
      old.flipped != flipped;
}

class _CoordinatePainter extends CustomPainter {
  final bool flipped;
  _CoordinatePainter({this.flipped = false});
  static const _files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 8;
    final fontSize = squareSize * 0.15;
    final textStyle = TextStyle(
      color: ApexColors.textTertiary.withAlpha(130),
      fontSize: fontSize, fontWeight: FontWeight.w600, fontFamily: 'Inter');
    for (int f = 0; f < 8; f++) {
      final fileIndex = flipped ? 7 - f : f;
      final tp = TextPainter(
        text: TextSpan(text: _files[fileIndex], style: textStyle),
        textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas,
          Offset(f * squareSize + squareSize - tp.width - 2,
              size.height - tp.height - 2));
    }
    for (int r = 0; r < 8; r++) {
      final rankNumber = flipped ? r + 1 : 8 - r;
      final tp = TextPainter(
        text: TextSpan(text: '$rankNumber', style: textStyle),
        textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(3, r * squareSize + 2));
    }
  }

  @override
  bool shouldRepaint(_CoordinatePainter oldDelegate) =>
      flipped != oldDelegate.flipped;
}
