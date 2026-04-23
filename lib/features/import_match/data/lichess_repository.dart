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

import 'package:apex_chess/features/import_match/domain/imported_game.dart';

class LichessRepository {
  LichessRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<ImportedGame>> fetchRecentGames(
    String username, {
    int limit = 25,
  }) async {
    final user = username.trim();
    if (user.isEmpty) {
      throw const ImportException('Please enter a Lichess username.');
    }
    try {
      final uri = Uri.parse(
          'https://lichess.org/api/games/user/$user?max=$limit&pgnInJson=true&opening=true&moves=true');
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
      for (final line in body) {
        try {
          final raw = jsonDecode(line) as Map<String, dynamic>;
          final parsed = _parseGame(raw, user);
          if (parsed != null) games.add(parsed);
        } catch (_) {
          // Skip unparsable rows; endpoint occasionally emits control lines.
          continue;
        }
      }
      games.sort((a, b) => b.playedAt.compareTo(a.playedAt));
      return games;
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
      // No winner field → typically a draw on Lichess too.
      result = GameResult.draw;
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
