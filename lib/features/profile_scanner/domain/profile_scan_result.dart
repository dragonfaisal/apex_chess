/// Domain model for the Apex Cheat Detection Radar.
///
/// The suspicion score is a composite of three independent signals
/// (see `ProfileScannerService`):
///   1. Engine-match rate — fraction of non-book user moves that match
///      the Stockfish top-3 lines.
///   2. Centipawn-loss variance — humans play noisier; engines are
///      flat. Low variance at high accuracy is suspicious.
///   3. ELO-vs-accuracy band — the same 92% accuracy on a 1200 account
///      is far more damning than on a 2400 account.
library;

enum SuspicionLevel {
  /// Clean — signal within human-plausible range for the stated ELO.
  clean,
  /// Moderately above expected — worth a human look but not damning.
  moderate,
  /// Highly suspicious — multiple signals outside human band for
  /// this rating.
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

  /// Fraction of non-book user plies whose played move matched one of
  /// the engine's top lines (i.e. `best` or `brilliant` classification)
  /// — 0..1.
  final double engineMatchRate;

  /// Population stdev of the per-ply Win% loss on the user's side.
  /// A low value at a high [accuracy] is the classic engine-assisted
  /// signature: consistent, flat, almost never noisy.
  final double cpLossStdDev;

  /// ELO the user played at in this game (if known from headers).
  final int? rating;

  const GameAccuracy({
    required this.id,
    required this.white,
    required this.black,
    required this.result,
    required this.accuracy,
    required this.brilliantCount,
    required this.blunderCount,
    required this.engineMatchRate,
    required this.cpLossStdDev,
    this.rating,
  });
}

/// Top-level scanner output.
class ProfileScanResult {
  final String username;
  final String source; // 'chess.com' | 'lichess'
  final int sampleSize;
  /// Mean accuracy across analysed games (0–100).
  final double averageAccuracy;
  /// Mean engine-match rate across games (0..1).
  final double averageEngineMatchRate;
  /// Mean rating from game headers (null if unavailable).
  final int? averageRating;
  /// Composite 0..100 suspicion score — 0 = definitely human, 100 =
  /// engine-parity across every signal.
  final double suspicionScore;
  final SuspicionLevel suspicion;
  /// Human-readable justification for the suspicion bucket.
  final String verdict;
  final List<GameAccuracy> games;

  const ProfileScanResult({
    required this.username,
    required this.source,
    required this.sampleSize,
    required this.averageAccuracy,
    required this.averageEngineMatchRate,
    required this.averageRating,
    required this.suspicionScore,
    required this.suspicion,
    required this.verdict,
    required this.games,
  });
}
