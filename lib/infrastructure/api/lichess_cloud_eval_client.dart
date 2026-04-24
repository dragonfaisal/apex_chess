/// HTTP client for the Lichess Cloud Eval API.
///
/// GET `https://lichess.org/api/cloud-eval?fen=<FEN>&multiPv=1`
///
/// Implements:
///   • Exponential backoff on 429 Too Many Requests
///   • Circuit breaker (trips after 3 consecutive 429s)
///   • 30-day in-memory cache keyed by (fen, depth, multiPv)
///   • Automatic fallback signal when rate-limited
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import 'package:apex_chess/core/network/api_headers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Response Models
// ─────────────────────────────────────────────────────────────────────────────

class CloudEvalResult {
  /// Evaluation of the best line (PV[0]) in centipawns, White's POV.
  final int? scoreCp;

  /// Mate-in for the best line, White's POV.
  final int? mateIn;

  /// Evaluation of the second-best line (PV[1]) in centipawns, White's
  /// POV. `null` when Lichess only returned a single PV — the cloud
  /// database often has multiPv=1 for less-popular positions.
  final int? secondBestCp;

  /// Mate-in for the second-best line, White's POV.
  final int? secondBestMate;

  /// Search depth achieved.
  final int depth;

  /// Principal variation of the best line (list of UCI moves).
  final List<String> pvMoves;

  /// Number of nodes searched (knodes).
  final int knodes;

  const CloudEvalResult({
    this.scoreCp,
    this.mateIn,
    this.secondBestCp,
    this.secondBestMate,
    required this.depth,
    required this.pvMoves,
    required this.knodes,
  });

  factory CloudEvalResult.fromJson(Map<String, dynamic> json) {
    final pvs = json['pvs'] as List<dynamic>? ?? [];
    final firstPv = pvs.isNotEmpty ? pvs[0] as Map<String, dynamic> : null;
    final secondPv = pvs.length > 1 ? pvs[1] as Map<String, dynamic> : null;

    int? cp;
    int? mate;
    int? cp2;
    int? mate2;
    List<String> moves = [];

    if (firstPv != null) {
      cp = firstPv['cp'] as int?;
      mate = firstPv['mate'] as int?;
      final movesStr = firstPv['moves'] as String? ?? '';
      moves = movesStr.split(' ').where((s) => s.isNotEmpty).toList();
    }
    if (secondPv != null) {
      cp2 = secondPv['cp'] as int?;
      mate2 = secondPv['mate'] as int?;
    }

    return CloudEvalResult(
      scoreCp: cp,
      mateIn: mate,
      secondBestCp: cp2,
      secondBestMate: mate2,
      depth: json['depth'] as int? ?? 0,
      pvMoves: moves,
      knodes: json['knodes'] as int? ?? 0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Client
// ─────────────────────────────────────────────────────────────────────────────

class LichessCloudEvalClient {
  final http.Client _httpClient;

  static const String _baseUrl = 'https://lichess.org/api/cloud-eval';

  /// Maximum retries on transient errors.
  static const int _maxRetries = 3;

  /// Base delay for exponential backoff.
  static const Duration _baseDelay = Duration(seconds: 2);

  /// Circuit breaker: consecutive 429 count.
  int _consecutive429s = 0;

  /// Circuit breaker threshold — after this many 429s, stop calling.
  static const int _circuitBreakerThreshold = 3;

  /// Circuit breaker reset time.
  DateTime? _circuitBreakerTrippedAt;
  static const Duration _circuitBreakerCooldown = Duration(minutes: 5);

  /// In-memory cache: fen → result.
  final Map<String, _CachedEval> _cache = {};

  LichessCloudEvalClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Fetches cloud evaluation for a FEN position.
  ///
  /// Returns `null` if:
  ///   - Rate limited (429) and circuit breaker is tripped
  ///   - Server error after max retries
  ///   - Position not found in Lichess cloud database (404)
  Future<CloudEvalResult?> getEvaluation(
    String fen, {
    int multiPv = 1,
  }) async {
    // ── Circuit breaker check ──────────────────────────────────────
    if (_isCircuitBreakerTripped()) {
      return null; // Caller should fall back to local engine.
    }

    // ── Cache check ────────────────────────────────────────────────
    final cacheKey = '$fen|$multiPv';
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.result;
    }

    // ── HTTP request with exponential backoff ──────────────────────
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final uri = Uri.parse(_baseUrl).replace(queryParameters: {
          'fen': fen,
          'multiPv': multiPv.toString(),
        });

        final response = await _httpClient
            .get(uri, headers: apexJsonHeaders)
            .timeout(const Duration(seconds: 10));

        switch (response.statusCode) {
          case 200:
            _consecutive429s = 0; // Reset circuit breaker.
            final json = jsonDecode(response.body) as Map<String, dynamic>;
            final result = CloudEvalResult.fromJson(json);

            // Cache the result (30-day TTL).
            _cache[cacheKey] = _CachedEval(
              result: result,
              expiresAt: DateTime.now().add(const Duration(days: 30)),
            );

            return result;

          case 404:
            // Position not in cloud database — not an error.
            return null;

          case 429:
            _consecutive429s++;
            if (_consecutive429s >= _circuitBreakerThreshold) {
              _circuitBreakerTrippedAt = DateTime.now();
            }
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
        if (attempt < _maxRetries) {
          await _backoff(attempt);
          continue;
        }
        return null;
      }
    }

    return null;
  }

  /// Whether the circuit breaker is currently tripped.
  bool _isCircuitBreakerTripped() {
    if (_circuitBreakerTrippedAt == null) return false;
    if (DateTime.now().difference(_circuitBreakerTrippedAt!) >
        _circuitBreakerCooldown) {
      // Cooldown elapsed — reset.
      _circuitBreakerTrippedAt = null;
      _consecutive429s = 0;
      return false;
    }
    return true;
  }

  /// Whether the client is currently rate-limited.
  bool get isRateLimited => _isCircuitBreakerTripped();

  /// Exponential backoff with jitter.
  Future<void> _backoff(int attempt) async {
    final delayMs = _baseDelay.inMilliseconds * math.pow(2, attempt);
    final jitter = math.Random().nextInt(500);
    await Future<void>.delayed(
        Duration(milliseconds: delayMs.toInt() + jitter));
  }

  /// Clears the in-memory cache.
  void clearCache() => _cache.clear();

  void dispose() => _httpClient.close();
}

class _CachedEval {
  final CloudEvalResult result;
  final DateTime expiresAt;

  const _CachedEval({required this.result, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
