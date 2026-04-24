/// Profile Scanner service — SCAFFOLD with dummy data.
///
/// The real implementation will:
///   1. Pull the last N games from Chess.com or Lichess.
///   2. Run each through the local engine at Fast D14.
///   3. Aggregate per-game accuracy and compare against ELO-expected
///      ranges to produce a [SuspicionLevel].
///
/// For now `scan` returns deterministic canned data so the UI can be
/// built and reviewed without backing the math.
library;

import 'dart:math';

import '../domain/profile_scan_result.dart';

class ProfileScannerService {
  /// Simulates network + analysis latency so the UI's loading state is
  /// exercised during manual QA. The real version will stream real
  /// progress updates; this one just sleeps.
  Future<ProfileScanResult> scan({
    required String username,
    required String source,
    int sampleSize = 10,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    // Deterministic pseudo-variance so two runs against the same name
    // feel consistent while still being different per username. A real
    // PRNG seeded on the username lets reviewers screenshot consistent
    // results.
    final seed = username.hashCode & 0x7fffffff;
    final rng = Random(seed);

    final avg = 62 + rng.nextDouble() * 34; // 62–96
    final suspicion = avg >= 92
        ? SuspicionLevel.suspicious
        : avg >= 82
            ? SuspicionLevel.moderate
            : SuspicionLevel.clean;
    final verdict = switch (suspicion) {
      SuspicionLevel.clean =>
        'Accuracy sits within the human band for the stated rating.',
      SuspicionLevel.moderate =>
        'Accuracy is above the typical band — flag for a human review.',
      SuspicionLevel.suspicious =>
        'Accuracy is well above what a human of this rating typically produces.',
    };

    final games = [
      for (var i = 0; i < sampleSize; i++)
        GameAccuracy(
          id: '$username-sample-$i',
          white: i.isEven ? username : 'opponent_$i',
          black: i.isEven ? 'opponent_$i' : username,
          result: ['1-0', '0-1', '1/2-1/2'][i % 3],
          accuracy: (avg - 6 + rng.nextDouble() * 12).clamp(0, 100),
          brilliantCount: rng.nextInt(2),
          blunderCount: rng.nextInt(3),
        ),
    ];

    return ProfileScanResult(
      username: username,
      source: source,
      sampleSize: sampleSize,
      averageAccuracy: avg,
      suspicion: suspicion,
      verdict: verdict,
      games: games,
    );
  }
}
