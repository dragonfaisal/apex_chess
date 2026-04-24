/// Fetches recent public games for a Chess.com username.
///
/// Chess.com exposes a monthly archive API — no auth required:
///   1. `GET /pub/player/{user}/games/archives` returns a list of archive
///      URLs sorted oldest → newest.
///   2. `GET {archive}` returns all games played that month, each with its
///      own PGN string and structured metadata.
///
/// To keep the UI snappy we fetch the **most recent archive only** and
/// return up to [limit] games sorted newest → oldest. The API responses
/// are small (~50-100 KB) so this is a single HTTP round-trip on the
/// happy path.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:apex_chess/features/import_match/domain/imported_game.dart';

class ChessComRepository {
  ChessComRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const _ua = 'ApexChess/1.0 (+https://apex.chess)';

  Future<List<ImportedGame>> fetchRecentGames(
    String username, {
    int limit = 25,
  }) async {
    final user = username.trim();
    if (user.isEmpty) {
      throw const ImportException('Please enter a Chess.com username.');
    }
    try {
      final archivesUri = Uri.parse(
          'https://api.chess.com/pub/player/$user/games/archives');
      final archivesResp = await _client
          .get(archivesUri, headers: {'User-Agent': _ua})
          .timeout(const Duration(seconds: 15));
      if (archivesResp.statusCode == 404) {
        throw const ImportException('Chess.com user not found.');
      }
      if (archivesResp.statusCode != 200) {
        throw const ImportException('Chess.com responded unexpectedly.');
      }
      final archivesJson = jsonDecode(archivesResp.body) as Map<String, dynamic>;
      final archives = (archivesJson['archives'] as List? ?? const [])
          .cast<String>();
      if (archives.isEmpty) return const [];

      // Fetch the latest archive first; if it's empty (e.g. user only
      // played a single partial month), fall back to the previous one.
      final games = <ImportedGame>[];
      for (final archive in archives.reversed.take(2)) {
        final resp = await _client
            .get(Uri.parse(archive), headers: {'User-Agent': _ua})
            .timeout(const Duration(seconds: 20));
        if (resp.statusCode != 200) continue;
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final rawGames =
            (body['games'] as List? ?? const []).cast<Map<String, dynamic>>();
        for (final raw in rawGames.reversed) {
          final parsed = _parseGame(raw, user);
          if (parsed != null) games.add(parsed);
          if (games.length >= limit) break;
        }
        if (games.length >= limit) break;
      }
      return games;
    } on ImportException {
      rethrow;
    } on TimeoutException {
      throw const ImportException(
          'Chess.com took too long to respond. Try again.');
    } catch (_) {
      throw const ImportException(
          'Could not reach Chess.com. Check your connection.');
    }
  }

  ImportedGame? _parseGame(Map<String, dynamic> raw, String lookupUser) {
    final pgn = (raw['pgn'] as String?) ?? '';
    if (pgn.isEmpty) return null;

    final white = raw['white'] as Map<String, dynamic>?;
    final black = raw['black'] as Map<String, dynamic>?;
    final whiteName = (white?['username'] as String?) ?? 'Unknown';
    final blackName = (black?['username'] as String?) ?? 'Unknown';
    final whiteRating = (white?['rating'] as num?)?.toInt();
    final blackRating = (black?['rating'] as num?)?.toInt();

    // Chess.com "result" values: win, resigned, timeout, checkmated,
    // stalemate, agreed, repetition, 50move, insufficient, timevsinsufficient.
    final whiteResult = (white?['result'] as String?) ?? '';
    final blackResult = (black?['result'] as String?) ?? '';
    GameResult result;
    if (whiteResult == 'win') {
      result = GameResult.whiteWon;
    } else if (blackResult == 'win') {
      result = GameResult.blackWon;
    } else if (_isDraw(whiteResult) || _isDraw(blackResult)) {
      result = GameResult.draw;
    } else {
      result = GameResult.unknown;
    }

    final endTimeSec = (raw['end_time'] as num?)?.toInt() ?? 0;
    final playedAt = endTimeSec > 0
        ? DateTime.fromMillisecondsSinceEpoch(endTimeSec * 1000)
        : DateTime.now();

    final timeControl = raw['time_control'] as String?;
    // Use ceil — a game ending on White's move has an odd ply count, and
    // truncating would under-report by one full move half the time.
    final moveCount = (_countPlies(pgn) / 2).ceil();

    PlayerColor? userColor;
    if (whiteName.toLowerCase() == lookupUser.toLowerCase()) {
      userColor = PlayerColor.white;
    } else if (blackName.toLowerCase() == lookupUser.toLowerCase()) {
      userColor = PlayerColor.black;
    }

    return ImportedGame(
      id: 'cc:${raw['url'] ?? '$whiteName-$blackName-$endTimeSec'}',
      source: GameSource.chessCom,
      whiteName: whiteName,
      blackName: blackName,
      whiteRating: whiteRating,
      blackRating: blackRating,
      result: result,
      playedAt: playedAt,
      timeControl: _humanTimeControl(timeControl),
      moveCount: moveCount,
      pgn: pgn,
      // Chess.com's JSON `eco` field is a URL (e.g.
      // https://www.chess.com/openings/Italian-Game), not the ECO code the
      // card wants to render. Extract the actual ECO tag from the PGN.
      eco: _extractTagValue(pgn, 'ECO'),
      // Chess.com PGNs don't ship an [Opening] tag — they encode the
      // opening name in the [ECOUrl] slug (e.g. `.../openings/
      // Queens-Gambit-Declined-Queens-Knight-Variation-3...Nf6-4.e3`).
      // Fall back to that slug when [Opening] is absent so the card shows
      // something human-readable next to the ECO code.
      openingName: _extractTagValue(pgn, 'Opening') ??
          _openingFromEcoUrl(_extractTagValue(pgn, 'ECOUrl')) ??
          _openingFromEcoUrl(raw['eco'] as String?),
      userColor: userColor,
    );
  }

  static bool _isDraw(String result) => const {
        'agreed',
        'repetition',
        'stalemate',
        '50move',
        'insufficient',
        'timevsinsufficient',
      }.contains(result);

  /// Counts moves from the SAN body; good enough for display and avoids a
  /// full PGN parse on the import list.
  static int _countPlies(String pgn) {
    final body = pgn.split('\n\n').last;
    final cleaned = body
        .replaceAll(RegExp(r'\{[^}]*\}'), ' ')
        .replaceAll(RegExp(r'\([^)]*\)'), ' ');
    final tokens = cleaned.split(RegExp(r'\s+'));
    var plies = 0;
    for (final t in tokens) {
      if (t.isEmpty) continue;
      // Anchored on both ends so glued tokens like `1.e4` are NOT skipped;
      // only pure move-number tokens (`1.`, `1...`) are filtered out.
      if (RegExp(r'^\d+\.+$').hasMatch(t)) continue;
      if (const ['1-0', '0-1', '1/2-1/2', '*'].contains(t)) continue;
      plies++;
    }
    return plies;
  }

  static String? _humanTimeControl(String? tc) {
    if (tc == null || tc.isEmpty) return null;
    // Chess.com formats: "60", "180+2", "600", "900+10"
    final parts = tc.split('+');
    final base = int.tryParse(parts[0]);
    if (base == null) return tc;
    final increment = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final minutes = base ~/ 60;
    final seconds = base % 60;
    final baseText = seconds == 0 ? '$minutes min' : '$minutes:${seconds.toString().padLeft(2, '0')}';
    return increment > 0 ? '$baseText +$increment' : baseText;
  }

  static String? _extractTagValue(String pgn, String tag) {
    final re = RegExp('\\[${RegExp.escape(tag)} "([^"]*)"\\]');
    final match = re.firstMatch(pgn);
    return match?.group(1);
  }

  /// Parses the opening slug from a Chess.com ECOUrl like
  /// `https://www.chess.com/openings/Queens-Gambit-Declined-Queens-Knight-Variation-3...Nf6-4.e3`.
  /// Returns a cleaned human name like `Queens Gambit Declined, Queens Knight`
  /// or `null` when the slug can't be parsed. Notation moves (tokens with
  /// a digit + dot, e.g. `3...Nf6`, `4.e3`) are stripped; only the named
  /// variation remains.
  static String? _openingFromEcoUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final ix = url.indexOf('/openings/');
    if (ix < 0) return null;
    final slug = url.substring(ix + '/openings/'.length);
    if (slug.isEmpty) return null;
    final parts = slug.split('-').where((p) => p.isNotEmpty).toList();
    // Drop move-notation segments (`3...Nf6`, `4.e3`, etc.) so the label
    // stays short and reads like an opening name.
    final named = parts
        .where((p) => !RegExp(r'^\d').hasMatch(p))
        .toList();
    if (named.isEmpty) return null;
    // Trim to first 5 tokens to avoid long compound variation names.
    final trimmed = named.take(5).join(' ');
    return trimmed.isEmpty ? null : trimmed;
  }
}
