/// Structural FEN validation before sending `position fen ...` to UCI.
library;

enum FenValidationIssue {
  none,
  empty,
  controlCharacter,
  fieldCount,
  boardRankCount,
  boardRankWidth,
  boardToken,
  sideToMove,
  castling,
  enPassant,
  halfmoveClock,
  fullmoveNumber,
}

class FenValidationResult {
  const FenValidationResult._(this.issue, this.message);

  const FenValidationResult.valid() : this._(FenValidationIssue.none, 'valid');

  const FenValidationResult.invalid(FenValidationIssue issue, String message)
    : this._(issue, message);

  final FenValidationIssue issue;
  final String message;

  bool get isValid => issue == FenValidationIssue.none;

  @override
  String toString() => isValid ? 'valid' : '${issue.name}: $message';
}

/// Validates the shape Stockfish's UCI parser expects for `position fen`.
///
/// This is intentionally structural rather than a full legality check. It
/// rejects malformed, empty, and partial inputs before they reach native code.
FenValidationResult validateFenForEngineCommand(String fen) {
  final trimmed = fen.trim();
  if (trimmed.isEmpty) {
    return const FenValidationResult.invalid(
      FenValidationIssue.empty,
      'FEN is empty',
    );
  }

  for (var i = 0; i < trimmed.length; i++) {
    final cu = trimmed.codeUnitAt(i);
    if (cu == 0 || (cu < 0x20 && cu != 0x09)) {
      return const FenValidationResult.invalid(
        FenValidationIssue.controlCharacter,
        'FEN contains a control character',
      );
    }
  }

  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length != 4 && parts.length != 6) {
    return const FenValidationResult.invalid(
      FenValidationIssue.fieldCount,
      'FEN must have 4 or 6 fields',
    );
  }

  final board = _validateBoard(parts[0]);
  if (!board.isValid) return board;

  final stm = parts[1];
  if (stm != 'w' && stm != 'b') {
    return const FenValidationResult.invalid(
      FenValidationIssue.sideToMove,
      'side to move must be w or b',
    );
  }

  final castling = _validateCastling(parts[2]);
  if (!castling.isValid) return castling;

  final ep = _validateEnPassant(parts[3]);
  if (!ep.isValid) return ep;

  if (parts.length == 6) {
    final halfmove = int.tryParse(parts[4]);
    if (halfmove == null || halfmove < 0) {
      return const FenValidationResult.invalid(
        FenValidationIssue.halfmoveClock,
        'halfmove clock must be a non-negative integer',
      );
    }
    final fullmove = int.tryParse(parts[5]);
    if (fullmove == null || fullmove <= 0) {
      return const FenValidationResult.invalid(
        FenValidationIssue.fullmoveNumber,
        'fullmove number must be a positive integer',
      );
    }
  }

  return const FenValidationResult.valid();
}

bool isFenValidForEngineCommand(String fen) =>
    validateFenForEngineCommand(fen).isValid;

FenValidationResult _validateBoard(String board) {
  final ranks = board.split('/');
  if (ranks.length != 8) {
    return const FenValidationResult.invalid(
      FenValidationIssue.boardRankCount,
      'board must contain exactly 8 ranks',
    );
  }

  const pieces = 'pnbrqkPNBRQK';
  for (final rank in ranks) {
    if (rank.isEmpty) {
      return const FenValidationResult.invalid(
        FenValidationIssue.boardToken,
        'board rank cannot be empty',
      );
    }
    var width = 0;
    for (var i = 0; i < rank.length; i++) {
      final ch = rank[i];
      final digit = int.tryParse(ch);
      if (digit != null) {
        if (digit < 1 || digit > 8) {
          return const FenValidationResult.invalid(
            FenValidationIssue.boardToken,
            'rank digit must be 1 through 8',
          );
        }
        width += digit;
      } else if (pieces.contains(ch)) {
        width += 1;
      } else {
        return const FenValidationResult.invalid(
          FenValidationIssue.boardToken,
          'board contains an invalid piece token',
        );
      }
    }
    if (width != 8) {
      return const FenValidationResult.invalid(
        FenValidationIssue.boardRankWidth,
        'each board rank must describe exactly 8 files',
      );
    }
  }
  return const FenValidationResult.valid();
}

FenValidationResult _validateCastling(String castling) {
  if (castling == '-') return const FenValidationResult.valid();
  if (castling.isEmpty) {
    return const FenValidationResult.invalid(
      FenValidationIssue.castling,
      'castling field cannot be empty',
    );
  }
  const allowed = 'KQkq';
  final seen = <String>{};
  for (var i = 0; i < castling.length; i++) {
    final ch = castling[i];
    if (!allowed.contains(ch) || !seen.add(ch)) {
      return const FenValidationResult.invalid(
        FenValidationIssue.castling,
        'castling field must use unique KQkq flags or -',
      );
    }
  }
  return const FenValidationResult.valid();
}

FenValidationResult _validateEnPassant(String ep) {
  if (ep == '-') return const FenValidationResult.valid();
  if (ep.length != 2) {
    return const FenValidationResult.invalid(
      FenValidationIssue.enPassant,
      'en-passant field must be - or a square',
    );
  }
  final file = ep.codeUnitAt(0) - 'a'.codeUnitAt(0);
  final rank = ep[1];
  if (file < 0 || file > 7 || (rank != '3' && rank != '6')) {
    return const FenValidationResult.invalid(
      FenValidationIssue.enPassant,
      'en-passant square must be on rank 3 or 6',
    );
  }
  return const FenValidationResult.valid();
}
