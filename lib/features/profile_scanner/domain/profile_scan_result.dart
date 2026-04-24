/// Domain model for the Apex Opponent Forensics scanner.
///
/// SCAFFOLD ONLY. The math — accuracy averaging, suspicion scoring,
/// move-by-move engine correlation — is a future milestone. This file
/// pins the data contract so the UI and any future scorer agree on
/// the shape of the result.
library;

enum SuspicionLevel {
  /// Clean — accuracy within human-plausible range for the stated ELO.
  clean,
  /// Moderately above expected — worth a human look but not damning.
  moderate,
  /// Highly suspicious — accuracy well above what a human of this
  /// rating typically produces.
  suspicious;

  String get label => switch (this) {
        clean => 'Clean',
        moderate => 'Moderate',
        suspicious => 'Suspicious',
      };
}

/// Per-game breakdown used by the details list inside the scanner.
class GameAccuracy {
  final String id;
  final String white;
  final String black;
  final String result;
  final double accuracy; // 0–100
  final int brilliantCount;
  final int blunderCount;

  const GameAccuracy({
    required this.id,
    required this.white,
    required this.black,
    required this.result,
    required this.accuracy,
    required this.brilliantCount,
    required this.blunderCount,
  });
}

/// Top-level scanner output.
class ProfileScanResult {
  final String username;
  final String source; // 'chess.com' | 'lichess'
  final int sampleSize;
  /// Mean accuracy across analysed games (0–100).
  final double averageAccuracy;
  final SuspicionLevel suspicion;
  /// Human-readable justification for the suspicion bucket.
  final String verdict;
  final List<GameAccuracy> games;

  const ProfileScanResult({
    required this.username,
    required this.source,
    required this.sampleSize,
    required this.averageAccuracy,
    required this.suspicion,
    required this.verdict,
    required this.games,
  });
}
