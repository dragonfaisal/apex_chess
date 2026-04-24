/// Fetches recent public games for a Chess.com username.
///
/// Chess.com exposes a monthly archive API — no auth required:
///   1. `GET /pub/player/{user}/games/archives` returns a list of archive
///      URLs sorted oldest → newest.
///   2. `GET {archive}` returns all games played that month, each with its
///      own PGN string and structured metadata.
///
/// ### Pagination
///
/// The public screen consumes results page-by-page to support infinite
/// scroll. Each call to [fetchRecentGames] returns at most [pageSize]
/// games plus a [ImportPage.cursor] describing where to resume. For
/// Chess.com the cursor encodes both the archive index *and* the
/// within-archive offset, formatted as `"archiveIx:rawOffset"`:
///
///   * `archiveIx` — 0 = most recent archive; increases into history.
///   * `rawOffset` — how many entries of `rawGames.reversed` we've
///     already consumed from that archive. Offsets count raw entries
///     (including ones [_parseGame] rejected) so the resume point is
///     stable across retries.
///
/// Without the offset, a page that fills partway through an archive
/// would permanently lose the remaining games in that archive — the
/// next call would skip forward to the next archive.
/// `cursor == null` means there are no more archives to paginate into.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:apex_chess/features/import_match/domain/imported_game.dart';

/// A single page of imported games plus a cursor for the next page.
///
/// `cursor == null` indicates the stream is exhausted.
class ImportPage {
  const ImportPage({required this.games, this.cursor});
  final List<ImportedGame> games;
  final String? cursor;
}

class ChessComRepository {
  ChessComRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const _ua = 'ApexChess/1.0 (+https://apex.chess)';

  /// Convenience wrapper for callers that only need the first page.
  /// Historical API — preserved so existing tests keep passing.
  Future<List<ImportedGame>> fetchRecentGames(
    String username, {
    int limit = 25,
  }) async {
    final page = await fetchPage(username, pageSize: limit);
    return page.games;
  }

  /// Fetch one page of games. Pass `cursor` from the previous page to
  /// paginate; pass `null` (the default) to start from the newest archive.
  Future<ImportPage> fetchPage(
    String username, {
    int pageSize = 25,
    String? cursor,
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
      final archivesJson =
          jsonDecode(archivesResp.body) as Map<String, dynamic>;
      final archives = (archivesJson['archives'] as List? ?? const [])
          .cast<String>()
          // Reverse so index 0 = newest archive; stable pagination order.
          .reversed
          .toList();
      if (archives.isEmpty) return const ImportPage(games: []);

      // Decode `"archiveIx[:rawOffset]"`. Legacy cursors from older
      // clients that only encoded `archiveIx` still parse correctly
      // (offset defaults to 0).
      final parts = (cursor ?? '0').split(':');
      final startIx = int.tryParse(parts[0]) ?? 0;
      final startOffset =
          parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      if (startIx >= archives.length) {
        return const ImportPage(games: []);
      }

      final games = <ImportedGame>[];
      var ix = startIx;
      var skip = startOffset;
      // `consumedInArchive` tracks how many raw entries we've walked
      // through in the *current* archive (including the initial skip
      // and any [_parseGame] rejections) — it becomes the rawOffset
      // of the next cursor if we fill mid-archive.
      var consumedInArchive = startOffset;

      // Walk archives from newest until we've filled the page — an archive
      // with zero qualifying games shouldn't stall the iteration.
      while (ix < archives.length && games.length < pageSize) {
        final archive = archives[ix];
        final resp = await _client
            .get(Uri.parse(archive), headers: {'User-Agent': _ua})
            .timeout(const Duration(seconds: 20));
        if (resp.statusCode != 200) {
          ix++;
          skip = 0;
          consumedInArchive = 0;
          continue;
        }
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final reversed = (body['games'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .reversed
            .toList();

        var archiveExhausted = true;
        for (var i = skip; i < reversed.length; i++) {
          consumedInArchive = i + 1;
          final parsed = _parseGame(reversed[i], user);
          if (parsed != null) games.add(parsed);
          if (games.length >= pageSize) {
            archiveExhausted = consumedInArchive >= reversed.length;
            break;
          }
        }
        if (archiveExhausted) {
          ix++;
          skip = 0;
          consumedInArchive = 0;
        }
      }

      // If we stopped mid-archive, resume from the next unread entry
      // in the same archive; otherwise advance to the next archive.
      // null = no more archives to paginate into.
      final String? nextCursor;
      if (ix >= archives.length) {
        nextCursor = null;
      } else if (consumedInArchive > 0) {
        nextCursor = '$ix:$consumedInArchive';
      } else {
        nextCursor = '$ix:0';
      }
      return ImportPage(games: games, cursor: nextCursor);
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
