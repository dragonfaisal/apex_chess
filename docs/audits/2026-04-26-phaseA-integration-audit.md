# Phase A integration audit (post-PR-#18)

> Status: complete — see PR description for OUTPUT REQUIRED matrix.
> Date: 2026-04-26

PR #18 shipped a research-backed `MoveClassifier` whose **isolated** unit tests
all pass (146/146 at merge time), but the user's real-game review on Android
showed the classifier giving **worse** verdicts than the Phase 6 brain it
replaced. This document records the integration-level root causes and the
fixes that landed on top of #18.

## 1. Root causes

| # | Symptom on device | Root cause in code |
|---|---|---|
| 1 | Brilliant tag attached to opponent's recapture / consolidating mate move instead of the sacrifice ply | `EvaluationAnalyzer.analyze(...)` left `isFirstSacrificePly` and `isTrivialRecapture` to caller-supplied defaults of `true`/`false`. Both pipelines (`local_game_analyzer.dart`, `cloud_game_analyzer.dart`) never overrode them, so every flagged sacrifice was fed `isFirstSacrificePly=true` regardless of where it sat in the line. |
| 2 | Quiet sideline in opening labelled Mistake / Inaccuracy | Pipelines never passed `isBook=true` for plies inside the opening unless the *exact* FEN had an ECO match in the local book. |
| 3 | Forced / Great never fired in real reviews | Engine layer is single-PV only; `multiPvWhiteWinPercents` / `secondBestWhiteWinPercent` were always `null` so the Forced and "PV1≫PV2" Great gates could never trigger. |
| 4 | Archive list shows Brilliants the timeline doesn't actually contain | `ArchivedGame.qualityCounts` was a frozen snapshot persisted at analysis time. After the classifier brain changed (Phase 6 → Phase A) the snapshot diverged from the cached timeline. |
| 5 | Re-opening a Phase 6 game still shows Phase 6 verdicts | No `classifierVersion` in the cache, so the archive screen's "instant re-open" path served stale timelines indefinitely. |
| 6 | Imported Black-user games show me at the top of the board | `ReviewState` had no orientation field; `ApexChessBoard.flipped` was never wired from the imported game's user colour. |
| 7 | Connect-account screen stays put after a successful connect | `ConnectAccountScreen.onComplete` is the only signal the screen watches before navigating; profile_screen and home_screen pushed it without supplying `onComplete`. |

## 2. Files changed

```
lib/core/domain/services/sacrifice_trajectory.dart   (NEW) — material-trajectory walker producing per-ply
                                                              isFirstSacrificePly / isTrivialRecapture / isSacrifice.
lib/core/domain/services/analysis_debug_export.dart  (NEW) — kDebugMode JSON-line dump of every analysed
                                                              ply (audit step A).
lib/infrastructure/engine/local_game_analyzer.dart        — wires SacrificeTrajectory into the on-device
                                                              pipeline; passes opening-phase fallback isBook=true
                                                              for plies < 8 when no ECO match found.
lib/infrastructure/api/cloud_game_analyzer.dart           — same wiring on the Lichess pipeline; also forwards
                                                              the openingService's openingName / ecoCode.
lib/features/archives/domain/archived_game.dart           — adds `kClassifierVersion` (= 3),
                                                              `AnalysisMode { quick, deep }`,
                                                              `qualityCountsLive` (timeline-derived),
                                                              `isCacheCurrent`. Backward-compatible JSON.
lib/features/archives/presentation/controllers/
    archive_controller.dart                               — re-analysis writes new counts from the new timeline
                                                              and bumps classifierVersion.
lib/features/archives/presentation/views/archive_screen.dart
                                                          — instant re-open path checks isCacheCurrent;
                                                              passes userIsBlack to the review controller.
lib/features/global_dashboard/presentation/controllers/
    dashboard_controller.dart                             — switches the qualityTotals aggregation to use
                                                              qualityCountsLive instead of the persisted snapshot.
lib/features/pgn_review/presentation/controllers/
    review_controller.dart                                — adds `flipped` to `ReviewState`, `userIsBlack`
                                                              to `loadTimeline`, `toggleFlip()`.
lib/features/pgn_review/presentation/views/review_screen.dart
                                                          — wires `state.flipped` into ApexChessBoard +
                                                              adds an AppBar flip button.
lib/features/import_match/presentation/views/
    import_match_screen.dart                              — passes `userIsBlack: widget.userIsWhite == false`.
lib/features/profile/presentation/views/profile_screen.dart
                                                          — supplies onComplete to ConnectAccountScreen so
                                                              connect / switch returns to profile.
lib/features/home/presentation/views/home_screen.dart     — same fix for the home-screen "Connect Account" CTA.
```

Tests added:

```
test/core/domain/services/sacrifice_trajectory_test.dart                — 6 cases covering recapture detection,
                                                                            first-sac-ply gate, parity heuristic,
                                                                            and FEN-parse failures.
test/features/archives/cached_timeline_roundtrip_test.dart              — extended with three new cases pinning
                                                                            classifierVersion / analysisMode
                                                                            JSON round-trip and qualityCountsLive
                                                                            divergence behaviour.
```

## 3. Before / after on real fixtures

The trajectory walker is exercised by the `sacrifice_trajectory_test.dart`
fixtures using actual PGN-fragment FENs:

* **Italian recapture (Nxe5 → Nxe5)** —  the second ply now reports
  `isTrivialRecapture: true`, closing the Brilliant gate. Pre-fix it was
  `false` by default and the Brilliant gate could open.
* **Mover a piece down playing a quiet move** —  reports
  `isFirstSacrificePly: false`, so any further "sacrifice" the classifier
  sees is recognised as consolidation, not a fresh Brilliant candidate.
* **Mover at parity playing 1.e4** — reports `isFirstSacrificePly: true`,
  so a real sacrifice on this ply is still eligible.
* **Bad FEN** — every flag drops to `false`, keeping Brilliant closed
  rather than fabricating it from corrupt input.

End-to-end verification on a real device requires Stockfish (no engine on
the host VM) — see PR #18 / #19 device-test checklist.

## 4. Should PR #18 be replaced or amended?

**Amended.** The classifier brain inside #18 is correct in isolation; only
the upstream pipelines were under-feeding it. This PR sits on top of #18 on
its own branch and amends the integration without redesigning #18.

## 5. Confirmations

* **No crash regressions.** `flutter analyze` clean; 157/157 tests pass
  (149 carried over from #18 + 8 new). The engine, FFI, and Skia paths
  from PRs #15 / #16 are untouched.
* **Archive counts match timeline.** `ArchivedGame.qualityCountsLive` now
  derives from `cachedTimeline.qualityCounts` whenever a timeline is
  attached; `dashboard_controller` and `archive_controller` both consume
  the live derivation. The "qualityCountsLive prefers timeline" test
  pins this behaviour against intentionally divergent fixture data.
* **User-as-Black perspective is correct.** `ReviewState.flipped` is set
  from `widget.userIsWhite == false` at import time; the AppBar flip
  button toggles the override. The archive re-open path looks up the
  connected account's username against the stored game's `black` header
  to derive the same flag for previously-imported games.

## 6. What's still pending (deliberately deferred)

* **Quick / Deep analysis mode separation** — `AnalysisMode` is
  persisted on `ArchivedGame` but the UI surface (depth pill toggle,
  per-mode classifier gating) is not yet wired. Deep mode also needs
  MultiPV plumbing in `LocalEvalService` before Forced / Great can fire
  at all on the on-device path.
* **MultiPV in `LocalEvalService.evaluate()`** — engine layer still
  returns PV1 only. Adding `setoption name MultiPV value N` + parser
  changes is a follow-up.
* **Real Opening Explorer** — opening-phase fallback (`ply < 8 ⇒
  isBook=true`) is in place; full Lichess Opening Explorer integration
  is a separate phase.

These are tracked as separate items on the Phase A todo list and do
**not** block the regression fixes in this PR.
