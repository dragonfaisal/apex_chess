/// Fetches recent public games for a Lichess username.
///
/// Uses Lichess's NDJSON game export endpoint — no auth required for
/// public games:
///
///   `GET https://lichess.org/api/games/user/{username}?max=N&pgnInJson=true`
///        `Accept: application/x-ndjson`
///
/// The server streams one JSON object per line, each including the PGN
/// string and structured metadata. We buffer the stream into a list, map
/// into [ImportedGame], and sort newest → oldest.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:apex_chess/features/import_match/data/chess_com_repository.dart'
    show ImportPage;
import 'package:apex_chess/features/import_match/domain/imported_game.dart';

class LichessRepository {
  LichessRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

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
  /// paginate; pass `null` (the default) to start from the newest game.
  /// Cursor encodes the oldest `lastMoveAt` of the previous page (ms)
  /// which the Lichess API consumes via `until=` to continue backwards.
  Future<ImportPage> fetchPage(
    String username, {
    int pageSize = 25,
    String? cursor,
  }) async {
    final user = username.trim();
    if (user.isEmpty) {
      throw const ImportException('Please enter a Lichess username.');
    }
    try {
      final params = <String, String>{
        'max': '$pageSize',
        'pgnInJson': 'true',
        'opening': 'true',
        'moves': 'true',
        'sort': 'dateDesc',
      };
      final untilMs = int.tryParse(cursor ?? '');
      if (untilMs != null) {
        // `until` is exclusive of the boundary timestamp, which is
        // exactly what we want for "continue past the previous page".
        params['until'] = '$untilMs';
      }
      final uri = Uri.https(
          'lichess.org', '/api/games/user/$user', params);
      final request = http.Request('GET', uri)
        ..headers['Accept'] = 'application/x-ndjson';
      final streamed =
          await _client.send(request).timeout(const Duration(seconds: 20));
      if (streamed.statusCode == 404) {
        throw const ImportException('Lichess user not found.');
      }
      if (streamed.statusCode != 200) {
        throw const ImportException('Lichess responded unexpectedly.');
      }
      final body = await streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .where((l) => l.trim().isNotEmpty)
          .toList()
          .timeout(const Duration(seconds: 25));

      final games = <ImportedGame>[];
      int? oldestMs;
      for (final line in body) {
        try {
          final raw = jsonDecode(line) as Map<String, dynamic>;
          final parsed = _parseGame(raw, user);
          if (parsed != null) {
            games.add(parsed);
            final ts = parsed.playedAt.millisecondsSinceEpoch;
            if (oldestMs == null || ts < oldestMs) oldestMs = ts;
          }
        } catch (_) {
          // Skip unparsable rows; endpoint occasionally emits control lines.
          continue;
        }
      }
      games.sort((a, b) => b.playedAt.compareTo(a.playedAt));
      // Lichess returned fewer games than requested → stream exhausted.
      // Otherwise advance the cursor to the oldest game's timestamp so the
      // next page continues strictly before it.
      final nextCursor = (games.length < pageSize || oldestMs == null)
          ? null
          : oldestMs.toString();
      return ImportPage(games: games, cursor: nextCursor);
    } on ImportException {
      rethrow;
    } on TimeoutException {
      throw const ImportException(
          'Lichess took too long to respond. Try again.');
    } catch (_) {
      throw const ImportException(
          'Could not reach Lichess. Check your connection.');
    }
  }

  ImportedGame? _parseGame(Map<String, dynamic> raw, String lookupUser) {
    final pgn = (raw['pgn'] as String?) ?? '';
    if (pgn.isEmpty) return null;

    final players = raw['players'] as Map<String, dynamic>? ?? const {};
    final white = players['white'] as Map<String, dynamic>? ?? const {};
    final black = players['black'] as Map<String, dynamic>? ?? const {};

    final whiteUser = white['user'] as Map<String, dynamic>?;
    final blackUser = black['user'] as Map<String, dynamic>?;
    final whiteName = (whiteUser?['name'] as String?) ??
        (white['aiLevel'] != null ? 'Stockfish L${white['aiLevel']}' : 'Anonymous');
    final blackName = (blackUser?['name'] as String?) ??
        (black['aiLevel'] != null ? 'Stockfish L${black['aiLevel']}' : 'Anonymous');
    final whiteRating = (white['rating'] as num?)?.toInt();
    final blackRating = (black['rating'] as num?)?.toInt();

    // Lichess winner: "white" | "black" | absent (draw).
    final winner = raw['winner'] as String?;
    GameResult result;
    if (winner == 'white') {
      result = GameResult.whiteWon;
    } else if (winner == 'black') {
      result = GameResult.blackWon;
    } else if (raw['status'] == 'draw' ||
        raw['status'] == 'stalemate' ||
        raw['status'] == 'insufficient') {
      result = GameResult.draw;
    } else {
      // No winner + unrecognised status (aborted, noStart, variantEnd, etc.).
      result = GameResult.unknown;
    }

    final createdAt = (raw['createdAt'] as num?)?.toInt();
    final lastMoveAt = (raw['lastMoveAt'] as num?)?.toInt() ?? createdAt ?? 0;
    final playedAt = lastMoveAt > 0
        ? DateTime.fromMillisecondsSinceEpoch(lastMoveAt)
        : DateTime.now();

    final clock = raw['clock'] as Map<String, dynamic>?;
    final initial = (clock?['initial'] as num?)?.toInt();
    final increment = (clock?['increment'] as num?)?.toInt() ?? 0;
    String? timeControl;
    if (initial != null && initial > 0) {
      final minutes = initial ~/ 60;
      final seconds = initial % 60;
      final baseText = seconds == 0
          ? '$minutes min'
          : '$minutes:${seconds.toString().padLeft(2, '0')}';
      timeControl = increment > 0 ? '$baseText +$increment' : baseText;
    } else if (raw['speed'] != null) {
      timeControl = (raw['speed'] as String).replaceFirst(
          raw['speed'][0], (raw['speed'][0] as String).toUpperCase());
    }

    final movesRaw = raw['moves'] as String? ?? '';
    final plies = movesRaw.trim().isEmpty ? 0 : movesRaw.trim().split(' ').length;

    final opening = raw['opening'] as Map<String, dynamic>?;

    PlayerColor? userColor;
    if ((whiteUser?['name'] as String?)?.toLowerCase() ==
        lookupUser.toLowerCase()) {
      userColor = PlayerColor.white;
    } else if ((blackUser?['name'] as String?)?.toLowerCase() ==
        lookupUser.toLowerCase()) {
      userColor = PlayerColor.black;
    }

    return ImportedGame(
      id: 'li:${raw['id'] ?? '$whiteName-$blackName-$lastMoveAt'}',
      source: GameSource.lichess,
      whiteName: whiteName,
      blackName: blackName,
      whiteRating: whiteRating,
      blackRating: blackRating,
      result: result,
      playedAt: playedAt,
      timeControl: timeControl,
      moveCount: (plies / 2).ceil(),
      pgn: pgn,
      eco: opening?['eco'] as String?,
      openingName: opening?['name'] as String?,
      userColor: userColor,
    );
  }
}
