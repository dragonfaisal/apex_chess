/// Live profile-stats client for Chess.com and Lichess.
///
/// Hits each provider's **public, unauthenticated** profile endpoints and
/// collapses the three time-control buckets the Grandmaster Analytics
/// dashboard cares about: Blitz, Rapid, Bullet. Also returns total-game
/// counts and W/D/L when the provider surfaces them (Chess.com exposes
/// them per category; Lichess exposes per-perf aggregates via
/// `api/user/{u}` plus a separate `api/user/{u}/perf/{perf}`).
///
/// This is deliberately thin — no caching, no retries, no token auth —
/// so it can be wired into a `FutureProvider.family` that fires once a
/// username verifies. Network failures return `ProfileStats.unknown()`
/// so the UI degrades to "no live data yet" instead of a thrown error.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Which platform the handle belongs to.
enum ProfileStatsSource { chessCom, lichess }

/// A single time-control rating snapshot plus lifetime record.
class RatingBucket {
  const RatingBucket({
    required this.label,
    required this.rating,
    required this.wins,
    required this.losses,
    required this.draws,
  });

  final String label;
  final int? rating;
  final int wins;
  final int losses;
  final int draws;

  int get total => wins + losses + draws;
  double get winRate => total == 0 ? 0 : (wins / total) * 100;
}

/// Snapshot returned by [ProfileStatsService.fetch].
class ProfileStats {
  const ProfileStats({
    required this.source,
    required this.username,
    required this.displayName,
    required this.buckets,
  });

  factory ProfileStats.unknown({
    required ProfileStatsSource source,
    required String username,
  }) =>
      ProfileStats(
        source: source,
        username: username,
        displayName: username,
        buckets: const [],
      );

  final ProfileStatsSource source;
  final String username;
  final String displayName;
  final List<RatingBucket> buckets;

  bool get hasData => buckets.any((b) => b.rating != null || b.total > 0);

  int get totalGames =>
      buckets.fold<int>(0, (sum, b) => sum + b.total);
  int get totalWins =>
      buckets.fold<int>(0, (sum, b) => sum + b.wins);
  int get totalLosses =>
      buckets.fold<int>(0, (sum, b) => sum + b.losses);
  int get totalDraws =>
      buckets.fold<int>(0, (sum, b) => sum + b.draws);

  double get winRate =>
      totalGames == 0 ? 0 : (totalWins / totalGames) * 100;
}

class ProfileStatsService {
  ProfileStatsService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const _ua = 'ApexChess/1.0 (+https://apex.chess)';
  static const _timeout = Duration(seconds: 8);

  /// Fetches the live rating buckets for [username] on [source]. Never
  /// throws — falls back to [ProfileStats.unknown] on any failure.
  Future<ProfileStats> fetch({
    required ProfileStatsSource source,
    required String username,
  }) async {
    final u = username.trim().toLowerCase();
    if (u.isEmpty) {
      return ProfileStats.unknown(source: source, username: username);
    }
    try {
      return switch (source) {
        ProfileStatsSource.chessCom => await _fetchChessCom(u),
        ProfileStatsSource.lichess => await _fetchLichess(u),
      };
    } on TimeoutException {
      return ProfileStats.unknown(source: source, username: username);
    } on SocketException {
      return ProfileStats.unknown(source: source, username: username);
    } on http.ClientException {
      return ProfileStats.unknown(source: source, username: username);
    } on FormatException {
      return ProfileStats.unknown(source: source, username: username);
    }
  }

  Future<ProfileStats> _fetchChessCom(String u) async {
    // `player/{u}/stats` returns `chess_blitz/chess_rapid/chess_bullet`
    // each carrying `{last: {rating}, record: {win, loss, draw}}`.
    final statsUri =
        Uri.parse('https://api.chess.com/pub/player/$u/stats');
    final res = await _client
        .get(statsUri, headers: const {'User-Agent': _ua})
        .timeout(_timeout);
    if (res.statusCode != 200) {
      return ProfileStats.unknown(
          source: ProfileStatsSource.chessCom, username: u);
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    RatingBucket parse(String key, String label) {
      final b = body[key];
      if (b is! Map<String, dynamic>) {
        return RatingBucket(
            label: label, rating: null, wins: 0, losses: 0, draws: 0);
      }
      final rating = (b['last'] is Map<String, dynamic>)
          ? (b['last']['rating'] as num?)?.toInt()
          : null;
      final rec = (b['record'] is Map<String, dynamic>)
          ? b['record'] as Map<String, dynamic>
          : const <String, dynamic>{};
      return RatingBucket(
        label: label,
        rating: rating,
        wins: (rec['win'] as num?)?.toInt() ?? 0,
        losses: (rec['loss'] as num?)?.toInt() ?? 0,
        draws: (rec['draw'] as num?)?.toInt() ?? 0,
      );
    }

    return ProfileStats(
      source: ProfileStatsSource.chessCom,
      username: u,
      displayName: u,
      buckets: [
        parse('chess_bullet', 'Bullet'),
        parse('chess_blitz', 'Blitz'),
        parse('chess_rapid', 'Rapid'),
      ],
    );
  }

  Future<ProfileStats> _fetchLichess(String u) async {
    // Lichess exposes `{perfs: {bullet: {rating, games, ...}, ...},
    // count: {win, loss, draw, all, ...}}` on the base user endpoint.
    // W/L/D isn't split per-perf on this route without extra calls —
    // we surface the aggregate on the Blitz bucket (most representative
    // for the majority of users) and leave the others rating-only.
    final uri = Uri.parse('https://lichess.org/api/user/$u');
    final res = await _client
        .get(uri, headers: const {'User-Agent': _ua})
        .timeout(_timeout);
    if (res.statusCode != 200) {
      return ProfileStats.unknown(
          source: ProfileStatsSource.lichess, username: u);
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    if (body['closed'] == true) {
      return ProfileStats.unknown(
          source: ProfileStatsSource.lichess, username: u);
    }
    final perfs = (body['perfs'] is Map<String, dynamic>)
        ? body['perfs'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final count = (body['count'] is Map<String, dynamic>)
        ? body['count'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final wins = (count['win'] as num?)?.toInt() ?? 0;
    final losses = (count['loss'] as num?)?.toInt() ?? 0;
    final draws = (count['draw'] as num?)?.toInt() ?? 0;

    int? perfRating(String key) {
      final p = perfs[key];
      if (p is! Map<String, dynamic>) return null;
      return (p['rating'] as num?)?.toInt();
    }

    return ProfileStats(
      source: ProfileStatsSource.lichess,
      username: u,
      displayName: (body['username'] as String?) ?? u,
      buckets: [
        RatingBucket(
          label: 'Bullet',
          rating: perfRating('bullet'),
          wins: 0,
          losses: 0,
          draws: 0,
        ),
        // Blitz carries the aggregate W/L/D so the Profile card has a
        // meaningful ratio without a second API round-trip.
        RatingBucket(
          label: 'Blitz',
          rating: perfRating('blitz'),
          wins: wins,
          losses: losses,
          draws: draws,
        ),
        RatingBucket(
          label: 'Rapid',
          rating: perfRating('rapid'),
          wins: 0,
          losses: 0,
          draws: 0,
        ),
      ],
    );
  }

  void dispose() => _client.close();
}
