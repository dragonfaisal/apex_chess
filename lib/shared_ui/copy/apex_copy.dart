/// Centralised premium copy for Apex Chess.
///
/// All user-facing terminology lives here so the voice of the product can be
/// tuned in one place. Views MUST prefer these constants over raw strings so
/// naming stays consistent across Home, Live Play, PGN Review, Academy,
/// Grandmaster Analytics, and Cheat Detection Radar.
///
/// Phase 5 voice — "multi-million dollar e-sports platform":
///   * "Grandmaster Analytics" (never "Global Dashboard").
///   * "Cheat Detection Radar" (never "Opponent Forensics").
///   * "War Room" / "Live Arena" (never "Live Play").
///   * "Apex Academy — Daily Drills" (never "Spaced Repetition").
///   * "Archived Intel" is kept — it already has the right voice.
library;

class ApexCopy {
  ApexCopy._();

  // ── Brand ──────────────────────────────────────────────────────────────
  static const String appTitle           = 'APEX CHESS';
  static const String tagline            = 'The Grandmaster In Your Pocket';
  static const String homeHeroSub        =
      'On-device neural analysis. Real engine depth. Zero telemetry.';

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
  static const String playLive           = 'ENTER WAR ROOM';
  static const String analyzeGame        = 'QUANTUM DEPTH SCAN';
  static const String importMatch        = 'IMPORT LIVE MATCH';

  // ── Dialog copy ────────────────────────────────────────────────────────
  static const String pgnDialogTitle     = 'Import PGN';
  static const String pgnDialogCta       = 'RUN QUANTUM SCAN';
  static const String pgnDialogHint      = '1. e4 e5 2. Nf3 Nc6 …';

  // ── Import feature (Chess.com / Lichess) ───────────────────────────────
  static const String importTitle         = 'LIVE MATCH INTEL';
  static const String importSubtitle      =
      'Link any Chess.com or Lichess handle — matches stream in automatically.';
  static const String importHint          = 'username';
  static const String importAutoFetch     = 'Auto-stream engaged — verify handle to ingest matches.';
  static const String importSourceChessCom = 'Chess.com';
  static const String importSourceLichess = 'Lichess';
  static const String importEmpty         = 'No recent matches found for this handle.';
  static const String importFailed        =
      'Could not fetch games — check the handle or your connection.';

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

  /// Returns the correct scan-mode label for a given engine depth so the
  /// progress dialog header reads "Fast Analysis" for ≤ D16 and
  /// "Quantum Deep Scan" above. Without this, both modes shared the
  /// `deepAnalysis` constant and the Fast scan mis-advertised itself.
  static String scanHeader(int depth) =>
      depth <= 16 ? depthFastLabel : depthDeepLabel;

  // ── Error messages ─────────────────────────────────────────────────────
  static const String engineUnavailable  =
      'Apex AI Grandmaster could not be reached.';
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

  // ── Connect Account (onboarding) ───────────────────────────────────────
  static const String onboardingTitle    = 'CONNECT HANDLE';
  static const String onboardingHeadline =
      'Link your Chess.com or Lichess handle.';
  static const String onboardingSub      =
      'Matches stream into your Grandmaster Analytics the instant they sync. Read-only. Public endpoints.';
  static const String onboardingConnect  = 'CONNECT';
  static const String onboardingSkip     = 'Skip for now';
  static const String onboardingSwitch   = 'Switch handle';
  static const String onboardingPrivacy  =
      'Read-only. Public profile endpoints. No password, no OAuth.';

  // ── Grandmaster Analytics (the Global Dashboard) ───────────────────────
  static const String dashboardTitle     = 'GRANDMASTER ANALYTICS';
  static const String dashboardSubtitle  =
      'Ratings, openings, and accuracy trends from every match scanned.';
  static const String dashboardEmpty     =
      'Scan any imported match — your Grandmaster Analytics populate themselves.';
  static const String dashboardColorAll   = 'ALL';
  static const String dashboardColorWhite = 'WHITE';
  static const String dashboardColorBlack = 'BLACK';
  static const String dashboardRatingCard   = 'LIVE RATINGS';
  static const String dashboardRatingEmpty  =
      'Connect a handle on Home to stream your live Chess.com / Lichess ratings.';
  static const String dashboardOpeningCard  = 'OPENING ARSENAL';
  static const String dashboardOpeningEmpty =
      'Scan a handful of matches to surface your strongest and weakest lines.';

  // ── Apex Academy ───────────────────────────────────────────────────────
  static const String academyTitle       = 'APEX ACADEMY';
  static const String academySubtitle    =
      'Daily drills engineered from your own mistakes — Lotus-grade spaced repetition.';
  static const String academyEmpty       =
      'Scan at least one match — every Blunder and Mistake enters the Vault and returns here as a drill.';
  static const String academyDone        =
      'All drills cleared for today. Streak preserved — see you tomorrow.';
  static const String academyCorrect     = 'Correct — Apex agrees.';
  static const String academyWrongHeader = 'Not quite.';

  // ── Cheat Detection Radar (profile scanner) ────────────────────────────
  /// Premium alias for "Cheat detector" / "Profile analyser".
  static const String scannerTitle        = 'CHEAT DETECTION RADAR';
  static const String scannerSubtitle     =
      'Correlate an opponent\'s move choices against the Apex AI baseline.';
  static const String scannerCta          = 'LOCK IN TARGET';
  static const String scannerRunning      = 'SCANNING…';
  static const String scannerLoading      =
      'Initiating Neural Analysis…';
  static const String scannerVerdictClean =
      'Within the human band for the stated rating — no red flags.';
  static const String scannerVerdictModerate =
      'Above the expected band — flag for human review.';
  static const String scannerVerdictSuspicious =
      'Well above what a human of this rating produces. Likely engine-assisted.';

  // ── Home tile subtitles ────────────────────────────────────────────────
  static const String tilePlayLiveSub =
      'Face the Apex AI Grandmaster at live depth.';
  static const String tileImportSub =
      'Stream your last 50 matches and deep-scan on demand.';
  static const String tilePgnSub =
      'Paste any PGN — Quantum Scan in seconds.';
  static const String tileArchivesSub =
      'Every match you\'ve ever scanned, one tap away.';
  static const String tileScannerSub =
      'Benchmark any opponent vs the engine baseline.';
  static const String tileDashboardSub =
      'Rating trends, opening arsenal, win rates per colour.';
  static const String tileAcademySub =
      'Today\'s drills, crafted from your weakest positions.';
}
