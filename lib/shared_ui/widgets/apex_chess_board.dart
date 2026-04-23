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
                for (final entry in pieces.entries)
                  _buildPiece(entry.key, entry.value, squareSize),
                if (lastMove != null && lastMoveQuality != null)
                  _buildQualityOverlay(
                      lastMove!.$2, squareSize, lastMoveQuality!),
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
