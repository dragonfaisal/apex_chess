library;

import 'package:dartchess/dartchess.dart';

import 'package:apex_chess/core/domain/services/evaluation_analyzer.dart'
    show normalizeCastlingUci;

class PgnValidationException implements Exception {
  const PgnValidationException(this.message);

  final String message;

  @override
  String toString() => 'PgnValidationException: $message';
}

enum ValidatedTerminalState { none, checkmate, stalemate, insufficientMaterial }

class ValidatedPgnMove {
  const ValidatedPgnMove({
    required this.fenBefore,
    required this.fenAfter,
    required this.san,
    required this.uci,
    required this.targetSquare,
    required this.isWhiteMove,
    required this.isCapture,
    required this.terminalState,
  });

  final String fenBefore;
  final String fenAfter;
  final String san;
  final String uci;
  final String targetSquare;
  final bool isWhiteMove;
  final bool isCapture;
  final ValidatedTerminalState terminalState;
}

class ValidatedPgnGame {
  const ValidatedPgnGame({
    required this.headers,
    required this.startingFen,
    required this.moves,
  });

  final Map<String, String> headers;
  final String startingFen;
  final List<ValidatedPgnMove> moves;
}

/// Strict, rules-only gate for the exact mainline that will be analysed.
///
/// dartchess remains authoritative for chess legality and FEN evolution. The
/// lexical pass exists because its permissive PGN reader intentionally skips
/// unknown movetext tokens; a review product must reject those tokens instead
/// of silently analysing a valid prefix.
class PgnMainlineValidator {
  const PgnMainlineValidator();

  ValidatedPgnGame validate(String source) {
    if (source.trim().isEmpty) {
      throw const PgnValidationException('PGN is empty.');
    }

    final intendedSan = _strictMainlineTokens(source);
    if (intendedSan.isEmpty) {
      throw const PgnValidationException('PGN contains no moves.');
    }

    final PgnGame<PgnNodeData> game;
    try {
      game = PgnGame.parsePgn(source);
    } on Object {
      throw const PgnValidationException('PGN could not be parsed.');
    }

    final parsedNodes = game.moves.mainline().toList(growable: false);
    if (parsedNodes.length != intendedSan.length) {
      throw const PgnValidationException(
        'PGN contains an invalid or unsupported mainline token.',
      );
    }

    Position position;
    try {
      position = PgnGame.startingPosition(game.headers);
    } on Object {
      throw const PgnValidationException('PGN starting position is invalid.');
    }
    final startingFen = position.fen;
    final moves = <ValidatedPgnMove>[];

    for (var index = 0; index < parsedNodes.length; index++) {
      final node = parsedNodes[index];
      if (_normaliseSanToken(node.san) !=
          _normaliseSanToken(intendedSan[index])) {
        throw PgnValidationException(
          'PGN mainline token ${index + 1} was not reconstructed exactly.',
        );
      }

      final move = position.parseSan(node.san);
      if (move is! NormalMove || !position.isLegal(move)) {
        throw PgnValidationException(
          'Illegal move at ply ${index + 1}: ${node.san}.',
        );
      }

      final fenBefore = position.fen;
      final isWhiteMove = position.turn == Side.white;
      final rawUci =
          '${_square(move.from)}${_square(move.to)}'
          '${move.promotion == null ? '' : _promotion(move.promotion!)}';
      final uci = normalizeCastlingUci(rawUci);
      final isCapture = _isCapture(position, move);
      final after = position.play(move);
      moves.add(
        ValidatedPgnMove(
          fenBefore: fenBefore,
          fenAfter: after.fen,
          san: node.san,
          uci: uci,
          targetSquare: uci.substring(2, 4),
          isWhiteMove: isWhiteMove,
          isCapture: isCapture,
          terminalState: after.isCheckmate
              ? ValidatedTerminalState.checkmate
              : after.isStalemate
              ? ValidatedTerminalState.stalemate
              : after.isInsufficientMaterial
              ? ValidatedTerminalState.insufficientMaterial
              : ValidatedTerminalState.none,
        ),
      );
      position = after;
    }

    return ValidatedPgnGame(
      headers: Map<String, String>.from(game.headers),
      startingFen: startingFen,
      moves: List<ValidatedPgnMove>.unmodifiable(moves),
    );
  }

  List<String> _strictMainlineTokens(String source) {
    final out = <String>[];
    final token = StringBuffer();
    var braceDepth = 0;
    var variationDepth = 0;
    var inLineComment = false;
    var movetextStarted = false;
    var sawResult = false;
    var lineStart = true;
    var inHeader = false;

    void flush() {
      var value = token.toString().trim();
      token.clear();
      if (value.isEmpty || variationDepth > 0 || braceDepth > 0) return;
      value = value.replaceFirst(RegExp(r'^\d+\.(?:\.\.)?'), '');
      if (value.isEmpty || RegExp(r'^\$\d+$').hasMatch(value)) return;
      if (_results.contains(value)) {
        sawResult = true;
        return;
      }
      if (sawResult) {
        throw const PgnValidationException(
          'PGN contains movetext after the game result.',
        );
      }
      value = value.replaceAll(RegExp(r'[!?]+$'), '');
      if (value.isEmpty) return;
      movetextStarted = true;
      out.add(value);
    }

    for (var i = 0; i < source.length; i++) {
      final ch = source[i];
      if (inLineComment) {
        if (ch == '\n' || ch == '\r') {
          inLineComment = false;
          lineStart = true;
        }
        continue;
      }
      if (inHeader) {
        if (ch == ']') inHeader = false;
        if (ch == '\n' || ch == '\r') lineStart = true;
        continue;
      }
      if (braceDepth > 0) {
        if (ch == '{') braceDepth++;
        if (ch == '}') braceDepth--;
        continue;
      }
      if (ch == '{') {
        flush();
        braceDepth = 1;
        continue;
      }
      if (ch == '}') {
        throw const PgnValidationException('PGN has an unmatched comment.');
      }
      if (ch == ';' || (ch == '%' && lineStart)) {
        flush();
        inLineComment = true;
        continue;
      }
      if (ch == '[' && lineStart) {
        flush();
        if (movetextStarted) {
          throw const PgnValidationException(
            'Only one PGN game can be reviewed at a time.',
          );
        }
        inHeader = true;
        lineStart = false;
        continue;
      }
      if (ch == '(') {
        flush();
        variationDepth++;
        continue;
      }
      if (ch == ')') {
        flush();
        if (variationDepth == 0) {
          throw const PgnValidationException('PGN has an unmatched variation.');
        }
        variationDepth--;
        continue;
      }
      if (RegExp(r'\s').hasMatch(ch)) {
        flush();
        lineStart = ch == '\n' || ch == '\r';
        continue;
      }
      lineStart = false;
      if (variationDepth == 0) token.write(ch);
    }
    flush();

    if (braceDepth != 0 || variationDepth != 0 || inHeader) {
      throw const PgnValidationException(
        'PGN contains an unterminated comment, variation, or header.',
      );
    }
    return out;
  }

  static const _results = <String>{'1-0', '0-1', '1/2-1/2', '*'};

  String _normaliseSanToken(String value) => value
      .replaceAll('0-0-0', 'O-O-O')
      .replaceAll('0-0', 'O-O')
      .replaceAll(RegExp(r'[!?]+$'), '');

  bool _isCapture(Position position, NormalMove move) {
    final moving = position.board.pieceAt(move.from);
    final target = position.board.pieceAt(move.to);
    if (target != null) {
      final castling =
          moving?.role == Role.king &&
          move.from.file == 4 &&
          (move.to.file == 0 || move.to.file == 7);
      return !castling;
    }
    return moving?.role == Role.pawn && move.from.file != move.to.file;
  }

  String _square(Square square) =>
      '${String.fromCharCode('a'.codeUnitAt(0) + square.file)}${square.rank + 1}';

  String _promotion(Role role) => switch (role) {
    Role.queen => 'q',
    Role.rook => 'r',
    Role.bishop => 'b',
    Role.knight => 'n',
    _ => throw const PgnValidationException('Unsupported promotion role.'),
  };
}
