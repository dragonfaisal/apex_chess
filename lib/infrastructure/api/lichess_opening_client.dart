/// HTTP client for the Lichess Opening Explorer API.
///
/// GET `https://explorer.lichess.ovh/lichess?fen=<FEN>&speeds=...&ratings=...`
///
/// Implements:
///   • Exponential backoff on 429 Too Many Requests
///   • In-memory cache keyed by FEN (24-hour TTL)
///   • Structured response model for opening detection
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import 'package:apex_chess/core/network/api_headers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Response Models
// ─────────────────────────────────────────────────────────────────────────────

/// A single move option from the opening explorer.
class ExplorerMove {
  /// UCI notation (e.g., "e2e4").
  final String uci;

  /// SAN notation (e.g., "e4").
  final String san;

  /// Total games played with this move.
  final int totalGames;

  /// White wins / draws / black wins.
  final int whiteWins;
  final int draws;
  final int blackWins;

  /// Average Elo of players.
  final int? averageRating;

  const ExplorerMove({
    required this.uci,
    required this.san,
    required this.totalGames,
    required this.whiteWins,
    required this.draws,
    required this.blackWins,
    this.averageRating,
  });

  /// Win rate for White (0.0–1.0).
  double get whiteWinRate =>
      totalGames > 0 ? whiteWins / totalGames : 0.5;

  factory ExplorerMove.fromJson(Map<String, dynamic> json) {
    final white = json['white'] as int? ?? 0;
    final draws = json['draws'] as int? ?? 0;
    final black = json['black'] as int? ?? 0;
    return ExplorerMove(
      uci: json['uci'] as String? ?? '',
      san: json['san'] as String? ?? '',
      totalGames: white + draws + black,
      whiteWins: white,
      draws: draws,
      blackWins: black,
      averageRating: json['averageRating'] as int?,
    );
  }
}

/// Full explorer response for a position.
class OpeningExplorerResult {
  /// Opening name (e.g., "Sicilian Defense: Najdorf Variation").
  final String? openingName;

  /// ECO code (e.g., "B97").
  final String? ecoCode;

  /// Available moves from this position, sorted by popularity.
  final List<ExplorerMove> moves;

  /// Total games in the database for this position.
  final int totalGames;

  const OpeningExplorerResult({
    this.openingName,
    this.ecoCode,
    required this.moves,
    required this.totalGames,
  });

  /// Whether this position is in the opening book (has enough games).
  bool get isInBook => totalGames >= 50;

  /// Whether a specific move (by SAN) is a book move.
  bool isMoveInBook(String san) {
    return moves.any((m) => m.san == san && m.totalGames >= 10);
  }

  factory OpeningExplorerResult.fromJson(Map<String, dynamic> json) {
    final opening = json['opening'] as Map<String, dynamic>?;
    final movesJson = json['moves'] as List<dynamic>? ?? [];

    final moves = movesJson
        .map((m) => ExplorerMove.fromJson(m as Map<String, dynamic>))
        .toList();

    int total = 0;
    for (final m in moves) {
      total += m.totalGames;
    }

    return OpeningExplorerResult(
      openingName: opening?['name'] as String?,
      ecoCode: opening?['eco'] as String?,
      moves: moves,
      totalGames: total,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Client
// ─────────────────────────────────────────────────────────────────────────────

class LichessOpeningClient {
  final http.Client _httpClient;

  static const String _baseUrl = 'https://explorer.lichess.ovh/lichess';

  static const int _maxRetries = 2;
  static const Duration _baseDelay = Duration(seconds: 1);

  /// In-memory cache: fen → result (24h TTL).
  final Map<String, _CachedOpening> _cache = {};

  LichessOpeningClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Queries the opening explorer for a given FEN.
  ///
  /// [speeds] — filter by game speed: 'bullet', 'blitz', 'rapid', 'classical'.
  /// [ratings] — filter by rating bracket: '1600', '1800', '2000', '2200', '2500'.
  ///
  /// Returns `null` on network error or rate limiting.
  Future<OpeningExplorerResult?> getOpening(
    String fen, {
    List<String> speeds = const ['blitz', 'rapid', 'classical'],
    List<String> ratings = const ['1800', '2000', '2200', '2500'],
  }) async {
    // ── Cache check ────────────────────────────────────────────────
    final cacheKey = fen;
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.result;
    }

    // ── HTTP request with exponential backoff ──────────────────────
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final uri = Uri.parse(_baseUrl).replace(queryParameters: {
          'fen': fen,
          'speeds': speeds.join(','),
          'ratings': ratings.join(','),
        });

        final response = await _httpClient
            .get(uri, headers: apexJsonHeaders)
            .timeout(const Duration(seconds: 8));

        switch (response.statusCode) {
          case 200:
            final json = jsonDecode(response.body) as Map<String, dynamic>;
            final result = OpeningExplorerResult.fromJson(json);

            // Cache (24h TTL).
            _cache[cacheKey] = _CachedOpening(
              result: result,
              expiresAt: DateTime.now().add(const Duration(hours: 24)),
            );

            return result;

          case 429:
            if (attempt < _maxRetries) {
              await _backoff(attempt);
              continue;
            }
            return null;

          default:
            if (attempt < _maxRetries) {
              await _backoff(attempt);
              continue;
            }
            return null;
        }
      } on TimeoutException {
        if (attempt < _maxRetries) {
          await _backoff(attempt);
          continue;
        }
        return null;
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  Future<void> _backoff(int attempt) async {
    final delayMs = _baseDelay.inMilliseconds * math.pow(2, attempt);
    final jitter = math.Random().nextInt(300);
    await Future<void>.delayed(
        Duration(milliseconds: delayMs.toInt() + jitter));
  }

  void clearCache() => _cache.clear();
  void dispose() => _httpClient.close();
}

class _CachedOpening {
  final OpeningExplorerResult result;
  final DateTime expiresAt;

  const _CachedOpening({required this.result, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
