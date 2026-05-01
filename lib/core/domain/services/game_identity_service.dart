/// PGN/player identity helpers shared by paste, import, archive, and summary.
library;

class PgnGameIdentity {
  const PgnGameIdentity({
    required this.white,
    required this.black,
    required this.result,
    required this.moveCount,
    this.whiteRating,
    this.blackRating,
    this.date,
    this.timeControl,
    this.opening,
    this.eco,
    this.userIsWhite,
  });

  final String white;
  final String black;
  final String result;
  final int moveCount;
  final String? whiteRating;
  final String? blackRating;
  final String? date;
  final String? timeControl;
  final String? opening;
  final String? eco;
  final bool? userIsWhite;

  String get matchup => '$white vs $black';
}

class GameIdentityService {
  const GameIdentityService();

  PgnGameIdentity parsePgn(
    String pgn, {
    String? userHandle,
    bool? selectedUserIsWhite,
  }) {
    final tags = parseTags(pgn);
    final white = _cleanName(tags['White']) ?? 'White';
    final black = _cleanName(tags['Black']) ?? 'Black';
    final resolved =
        selectedUserIsWhite ??
        resolveUserIsWhite(white: white, black: black, handle: userHandle);
    return PgnGameIdentity(
      white: white,
      black: black,
      whiteRating: _cleanName(tags['WhiteElo']),
      blackRating: _cleanName(tags['BlackElo']),
      result: _cleanName(tags['Result']) ?? '*',
      date: _cleanName(tags['UTCDate']) ?? _cleanName(tags['Date']),
      timeControl: _cleanName(tags['TimeControl']),
      opening: _cleanName(tags['Opening']),
      eco: _cleanName(tags['ECO']),
      moveCount: estimateMoveCount(pgn),
      userIsWhite: resolved,
    );
  }

  Map<String, String> parseTags(String pgn) {
    final out = <String, String>{};
    final tag = RegExp(r'^\s*\[([A-Za-z0-9_]+)\s+"([^"]*)"\]\s*$');
    for (final line in pgn.split(RegExp(r'\r?\n'))) {
      final match = tag.firstMatch(line);
      if (match == null) continue;
      out[match.group(1)!] = match.group(2)!;
    }
    return out;
  }

  bool? resolveUserIsWhite({
    required String white,
    required String black,
    String? handle,
  }) {
    final user = normalizeHandle(handle);
    if (user == null) return null;
    if (normalizeHandle(white) == user) return true;
    if (normalizeHandle(black) == user) return false;
    return null;
  }

  String resultLabel(String result, {bool? userIsWhite}) {
    if (result.isEmpty || result == '*') return 'Game unfinished';
    if (result == '1/2-1/2') return 'Draw';
    if (userIsWhite == null) {
      if (result == '1-0') return 'White won';
      if (result == '0-1') return 'Black won';
      return result;
    }
    final won =
        (userIsWhite && result == '1-0') || (!userIsWhite && result == '0-1');
    final lost =
        (userIsWhite && result == '0-1') || (!userIsWhite && result == '1-0');
    if (won) return 'You won';
    if (lost) return 'You lost';
    return result;
  }

  int estimateMoveCount(String pgn) {
    var body = pgn.replaceAll(
      RegExp(r'^\s*\[[^\]]+\]\s*$', multiLine: true),
      ' ',
    );
    body = body.replaceAll(RegExp(r'\{[^}]*\}'), ' ');
    body = body.replaceAll(RegExp(r';[^\n\r]*'), ' ');
    body = body.replaceAll(RegExp(r'\([^)]*\)'), ' ');
    body = body.replaceAll(RegExp(r'\b(1-0|0-1|1/2-1/2|\*)\b'), ' ');
    final sans = body
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .where((token) => !RegExp(r'^\d+\.(\.\.)?$').hasMatch(token))
        .where((token) => !token.startsWith('\$'))
        .length;
    return (sans / 2).ceil();
  }

  static String? normalizeHandle(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    return normalized;
  }

  static String? _cleanName(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty || trimmed == '?') return null;
    return trimmed;
  }
}
