/// Centralised premium copy for Apex Chess.
///
/// All user-facing terminology lives here so the voice of the product can be
/// tuned in one place. Views MUST prefer these constants over raw strings so
/// naming stays consistent across Home, Live Play, and PGN Review.
///
/// Where a boring term and a premium term coexist, the premium one is the
/// public identifier; the boring one is documented in a comment so code
/// reviewers can connect the dots back to engineering jargon.
library;

class ApexCopy {
  ApexCopy._();

  // ── Brand ──────────────────────────────────────────────────────────────
  static const String appTitle           = 'APEX CHESS';
  static const String tagline            = 'On-Device Neural Grandmaster';

  // ── Engine / analysis (replaces "Engine Eval", "Deep Analysis", etc.) ──
  /// Premium alias for "Engine Eval" / "Stockfish".
  static const String engineBrand        = 'Apex AI Grandmaster';
  /// Premium alias for "Deep Analysis" / "engine at high depth".
  static const String deepAnalysis       = 'Quantum Deep Scan';
  /// Premium alias for "Depth" header on the eval bar.
  static const String depthLabel         = 'Quantum Depth';
  /// Live-play footer — shown under the eval bar while the engine thinks.
  static const String liveEngineFooter   = 'Apex AI Grandmaster • On-Device';
  /// Shown while the engine hands back its first thought.
  static const String engineWarming      = 'Calibrating Apex AI…';
  /// Shown before any engine output arrives for the current position.
  static const String awaitingAnalysis   = 'Initiating Neural Analysis…';
  /// Shown on the radar loader while a saved game is being re-scanned.
  static const String reanalysisPending  = 'Replaying Neural Analysis…';

  // ── Action copy (home screen buttons) ──────────────────────────────────
  static const String playLive           = 'ENTER LIVE MATCH';
  static const String analyzeGame        = 'QUANTUM DEPTH SCAN';
  static const String importMatch        = 'IMPORT LIVE MATCH';

  // ── Dialog copy ────────────────────────────────────────────────────────
  static const String pgnDialogTitle     = 'Import PGN';
  static const String pgnDialogCta       = 'RUN QUANTUM SCAN';
  static const String pgnDialogHint      = '1. e4 e5 2. Nf3 Nc6 …';

  // ── Import feature (Chess.com / Lichess) ───────────────────────────────
  static const String importTitle         = 'IMPORT MATCH';
  static const String importSubtitle      =
      'Pull any Chess.com or Lichess profile and scan any recent game.';
  static const String importHint          = 'username';
  static const String importFetch         = 'FETCH GAMES';
  static const String importSourceChessCom = 'Chess.com';
  static const String importSourceLichess = 'Lichess';
  static const String importEmpty         = 'No recent matches found.';
  static const String importFailed        =
      'Could not fetch games — check username or connection.';

  // ── Depth picker ───────────────────────────────────────────────────────
  static const String depthPickerTitle    = 'SCAN MODE';
  static const String depthFastLabel      = 'Fast Analysis';
  static const String depthFastTag        = 'Depth 14';
  static const String depthFastBlurb      =
      'Quick ply-by-ply read-out. Ideal for casual review.';
  static const String depthDeepLabel      = 'Quantum Deep Scan';
  static const String depthDeepTag        = 'Depth 22';
  static const String depthDeepBlurb      =
      'Full-resolution Apex AI sweep. Surfaces brilliant moves and missed tactics.';

  // ── Error messages ─────────────────────────────────────────────────────
  static const String engineUnavailable  =
      'Apex AI Analyst could not be reached.';
  static const String analysisFailed     =
      'Quantum Scan could not complete — try again.';

  // ── Move-quality display labels ────────────────────────────────────────
  /// Premium labels for the seven classification tiers. Keep in sync with
  /// [MoveQuality] in core/domain.
  static const String brilliantLabel     = 'Brilliant';
  static const String brilliantSymbol    = '!!';
  static const String bestLabel          = 'Best Move';
  static const String bestSymbol         = '★';
  static const String excellentLabel     = 'Excellent';
  static const String excellentSymbol    = '!';
  static const String goodLabel          = 'Solid';
  static const String inaccuracyLabel    = 'Inaccuracy';
  static const String inaccuracySymbol   = '?!';
  static const String mistakeLabel       = 'Mistake';
  static const String mistakeSymbol      = '?';
  static const String blunderLabel       = 'Blunder';
  static const String blunderSymbol      = '??';
  static const String bookLabel          = 'Theory';
  static const String bookSymbol         = '📖';

  /// Glow celebration copy (shown above the board when a brilliant fires).
  static const String brilliantCelebration = 'Brilliant!! Apex confirms.';

  // ── Archived Intel (saved game library) ────────────────────────────────
  /// Premium alias for "Saved games" / "Analysis history".
  static const String archivesTitle       = 'ARCHIVED INTEL';
  static const String archivesSubtitle    =
      'Replay any previously-scanned match at full Quantum depth.';

  // ── Opponent Forensics (profile scanner) ───────────────────────────────
  /// Premium alias for "Cheat detector" / "Profile analyser".
  static const String scannerTitle        = 'OPPONENT FORENSICS';
  static const String scannerSubtitle     =
      'Calibrate an opponent\'s move quality against the Apex AI baseline.';
  static const String scannerCta          = 'INITIATE SCAN';
  static const String scannerRunning      = 'SCANNING…';
  static const String scannerLoading      =
      'Initiating Neural Analysis…';
}
