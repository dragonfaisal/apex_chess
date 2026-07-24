import 'package:flutter/material.dart';

/// Presentation-only board geometry projected from already persisted evidence.
///
/// This contract carries squares, not chess meaning. Callers must validate the
/// evidence before constructing it; the board never infers tactics.
class ApexBoardOverlay {
  const ApexBoardOverlay({
    required this.semanticLabel,
    this.principalArrow,
    this.targetSquares = const <String>[],
    this.raySquares = const <String>[],
    this.supportSquares = const <String>[],
  });

  final String semanticLabel;
  final (String, String)? principalArrow;
  final List<String> targetSquares;
  final List<String> raySquares;
  final List<String> supportSquares;

  bool get isEmpty =>
      principalArrow == null &&
      targetSquares.isEmpty &&
      raySquares.isEmpty &&
      supportSquares.isEmpty;
}

/// Shared orientation transform used by overlay painters and focused tests.
abstract final class ApexBoardGeometry {
  static bool isSquare(String? value) =>
      value != null && RegExp(r'^[a-h][1-8]$').hasMatch(value);

  static Offset centerForSquare(
    String square, {
    required Size boardSize,
    required bool flipped,
  }) {
    assert(isSquare(square));
    final file = square.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final rank = int.parse(square[1]) - 1;
    final displayFile = flipped ? 7 - file : file;
    final displayRank = flipped ? rank : 7 - rank;
    final squareWidth = boardSize.width / 8;
    final squareHeight = boardSize.height / 8;
    return Offset(
      (displayFile + 0.5) * squareWidth,
      (displayRank + 0.5) * squareHeight,
    );
  }
}
