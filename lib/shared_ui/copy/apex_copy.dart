/// Centralised product copy for Apex Chess.
///
/// Keep names short, modern, and literal. Screens should prefer these
/// constants over raw strings so Analyze, Archive, Stats, and Academy stay
/// consistent.
library;

class ApexCopy {
  ApexCopy._();

  // ── Brand ──────────────────────────────────────────────────────────────
  static const String appTitle = 'APEX CHESS';
  static const String tagline = 'Fast, clean chess review';
  static const String homeHeroSub =
      'Paste a PGN, import recent games, and review what changed the result.';

  // ── Engine / analysis (replaces "Engine Eval", "Deep Analysis", etc.) ──
  static const String engineBrand = 'Apex Review';

  static const String deepAnalysis = 'Deep Review';

  static const String depthLabel = 'Depth';

  /// Live-play footer — shown under the eval bar while the engine thinks.
  static const String liveEngineFooter = 'Apex Review ready';

  /// Shown while the engine hands back its first thought.
  static const String engineWarming = 'Starting engine…';

  /// Shown before any engine output arrives for the current position.
  static const String awaitingAnalysis = 'Starting review…';

  /// Shown on the radar loader while a saved game is being re-scanned.
  static const String reanalysisPending = 'Loading saved review…';

  // ── Action copy (home screen buttons) ──────────────────────────────────
  static const String playLive = 'LIVE';
  static const String analyzeGame = 'PASTE PGN';
  static const String importMatch = 'IMPORT GAMES';

  // ── Global status / actions ───────────────────────────────────────────
  static const String checking = 'Checking...';
  static const String online = 'Online';
  static const String profile = 'Profile';
  static const String connected = 'Connected';
  static const String verified = 'Verified';
  static const String notFound = 'Not found';
  static const String noProfileFound = 'No profile found';
  static const String offline = 'Offline';
  static const String noConnection = 'No connection';
  static const String chessComUnavailable = 'Chess.com unavailable';
  static const String lichessUnavailable = 'Lichess unavailable';
  static const String profileUnavailable = 'Profile unavailable';
  static const String publicAccount = 'Public Account';
  static const String apexProfile = 'Apex Profile';
  static const String ratings = 'Ratings';
  static const String savedData = 'Saved data';
  static const String showingSavedData = 'Showing saved data';
  static const String backOnline = 'Back online';
  static const String synced = 'Synced';
  static const String serviceUnavailable = 'Service unavailable';
  static const String tryAgain = 'Try again';
  static const String tryAgainOnline = 'Try again when online';
  static const String clear = 'Clear';
  static const String clearFilters = 'Clear filters';
  static const String switchAccount = 'Switch account';
  static const String clearLocalData = 'Clear local data';
  static const String noMatchingGames = 'No matching games';
  static const String chooseExactPlayer = 'Choose exact player';
  static const String noExactPlayerFound = 'No exact player found';
  static const String connectedAccountNotice = 'This is your account';
  static const String searchOlderGames = 'Search older games';
  static const String searchingOlderGames = 'Searching older games';
  static const String search = 'Search';
  static const String searchPlayer = 'Search player';
  static const String searchOpponent = 'Search opponent';
  static const String searchOpponentOpening = 'Search opponent or opening';

  // ── Dialog copy ────────────────────────────────────────────────────────
  static const String pgnDialogTitle = 'Import PGN';
  static const String pgnDialogCta = 'Start Review';
  static const String pgnDialogHint = '1. e4 e5 2. Nf3 Nc6 …';
  static const String pgnDetected = 'Game detected';
  static const String pgnPreviewPrompt = 'Paste PGN to preview';
  static const String pgnDetectedHint = 'PGN detected. Tap to edit.';
  static const String pgnPlayerHint = 'Player name';
  static const String switchSide = 'Switch side';
  static const String chooseSide = 'Choose your side';
  static const String openingNotDetected = 'Opening not detected';

  static String youPlayed(bool userIsWhite) =>
      userIsWhite ? 'You played White' : 'You played Black';

  // ── Import feature (Chess.com / Lichess) ───────────────────────────────
  static const String importTitle = 'IMPORT GAMES';
  static const String importSubtitle =
      'Search a Chess.com or Lichess username and choose a game to review.';
  static const String importHint = 'Search player';
  static const String importAutoFetch =
      'Search starts automatically after the player is found.';
  static const String importSourceChessCom = 'Chess.com';
  static const String importSourceLichess = 'Lichess';
  static const String importEmpty = 'No recent matches found for this handle.';
  static const String importFailed =
      'Could not fetch games — check the handle or your connection.';

  // ── Depth picker ───────────────────────────────────────────────────────
  static const String depthPickerTitle = 'REVIEW MODE';
  static const String depthFastLabel = 'Fast Review';
  static const String depthFastTag = 'Fast';
  static const String depthFastBlurb =
      'A fast read of the game for everyday review.';
  static const String depthDeepLabel = 'Deep Review';
  static const String depthDeepTag = 'Deep';
  static const String depthDeepBlurb =
      'Stronger tactical verification for important games.';
  static const String depthOfflineLabel = 'Offline Review';
  static const String depthOfflineTag = 'Offline';
  static const String depthOfflineBlurb =
      'Runs on this device and may be slower.';

  static String scanHeader(int depth) =>
      depth <= 16 ? depthFastLabel : depthDeepLabel;

  // ── Error messages ─────────────────────────────────────────────────────
  static const String engineUnavailable = 'Apex Review could not be reached.';
  static const String analysisFailed = 'Review could not complete — try again.';
  static const String couldNotOpenReview = 'Could not open review';
  static const String savedReviewUnavailable = 'Saved review unavailable';
  static const String invalidPgn = 'Invalid PGN';

  // ── Move-quality display labels ────────────────────────────────────────
  /// Premium labels for the seven classification tiers. Keep in sync with
  /// [MoveQuality] in core/domain.
  static const String brilliantLabel = 'Brilliant';
  static const String brilliantSymbol = '!!';
  static const String bestLabel = 'Best';
  static const String bestSymbol = '★';
  static const String excellentLabel = 'Excellent';
  static const String excellentSymbol = '!';
  static const String goodLabel = 'Good';
  static const String inaccuracyLabel = 'Inaccuracy';
  static const String inaccuracySymbol = '?!';
  static const String mistakeLabel = 'Mistake';
  static const String mistakeSymbol = '?';
  static const String blunderLabel = 'Blunder';
  static const String blunderSymbol = '??';
  static const String bookLabel = 'Book';
  static const String bookSymbol = '📖';

  /// Glow celebration copy (shown above the board when a brilliant fires).
  static const String brilliantCelebration = 'Brilliant!! Apex confirms.';

  static const String archivesTitle = 'ARCHIVE';
  static const String archivesSubtitle = 'Open saved reviews instantly.';

  // ── Connect Account (onboarding) ───────────────────────────────────────
  static const String onboardingTitle = 'CONNECT HANDLE';
  static const String onboardingHeadline =
      'Link your Chess.com or Lichess handle.';
  static const String onboardingSub =
      'Use public profile data to speed up imports and personalize results. No password needed.';
  static const String onboardingConnect = 'CONNECT';
  static const String onboardingSkip = 'Skip for now';
  static const String onboardingSwitch = 'Switch handle';
  static const String onboardingPrivacy =
      'Read-only. Public profile endpoints. No password, no OAuth.';

  static const String dashboardTitle = 'STATS';
  static const String dashboardSubtitle = 'Public account · Apex reviews';
  static const String dashboardEmptyTitle = 'No analyzed stats yet.';
  static const String dashboardEmpty = 'Review games to build your dashboard.';
  static const String dashboardEmptyHint = 'Use Analyze to review a game.';
  static const String dashboardColorAll = 'ALL';
  static const String dashboardColorWhite = 'WHITE';
  static const String dashboardColorBlack = 'BLACK';
  static const String dashboardRatingCard = 'LIVE RATINGS';
  static const String dashboardRatingEmpty =
      'Connect a handle to show Chess.com / Lichess ratings.';
  static const String dashboardOpeningCard = 'OPENING ARSENAL';
  static const String dashboardOpeningEmpty =
      'Scan a handful of matches to surface your strongest and weakest lines.';
  static const String dashboardPlayerSearchTitle = 'PLAYER SEARCH';
  static const String dashboardPlayerSearchSubtitle = 'Public profile';
  static const String dashboardPlayerSearchHint = 'Search username';
  static const String dashboardNoPublicData = 'No public data';
  static const String dashboardNoGamesFound = 'No games found';
  static const String dashboardAccountOverview = 'Account overview';
  static const String dashboardRatings = 'Ratings';
  static const String dashboardRecentForm = 'Recent form';
  static const String dashboardPublicAccountStats = 'Public account stats';
  static const String dashboardPublicSections = 'Ratings · Results · Games';

  // ── Apex Academy ───────────────────────────────────────────────────────
  static const String academyTitle = 'ACADEMY';
  static const String academySubtitle = 'Review games to unlock drills.';
  static const String academyEmpty = 'Review games to unlock drills.';
  static const String academyDone = 'All drills cleared for today.';
  static const String academyCorrect = 'Correct — Apex agrees.';
  static const String academyWrongHeader = 'Not quite.';

  static const String scannerTitle = 'OPPONENT INSIGHTS';
  static const String scannerSubtitle =
      'Review public games and performance signals.';
  static const String scannerCta = 'Build profile';
  static const String scannerRunning = 'Checking games...';
  static const String scannerLoading = 'Building profile...';
  static const String scannerCancelled = 'Scan cancelled';
  static const String scannerVerdictClean =
      'Typical for the stated rating sample.';
  static const String scannerVerdictModerate =
      'Elevated compared with the expected rating sample.';
  static const String scannerVerdictSuspicious =
      'High variance compared with the expected rating sample.';

  // ── Home tile subtitles ────────────────────────────────────────────────
  static const String tilePlayLiveSub = 'Play with live feedback.';
  static const String tileImportSub = 'Find recent games and review on demand.';
  static const String tilePgnSub = 'Paste any PGN and start review.';
  static const String tileArchivesSub =
      'Every match you\'ve ever scanned, one tap away.';
  static const String tileScannerSub =
      'Review public games and performance signals.';
  static const String tileDashboardSub =
      'Ratings, accuracy, openings, and recent reviews.';
  static const String tileAcademySub =
      'Today\'s drills, crafted from your weakest positions.';
}
