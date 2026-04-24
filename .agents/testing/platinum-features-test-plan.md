# Platinum Features + Engine Audit — Test Plan

Target commit: `c142c0f` (branch `devin/1777037044-engine-audit-platinum`, PR #5).

## What changed

1. **Engine audit log** — `developer.log(name: 'apex.engine')` emits one
   `uci_eval …` line per search in debug builds with `fen`,
   `depth_target`, `depth_reached`, `movetime_cap_ms`, `elapsed_ms`,
   `score_cp_white`, `mate_in_white`, `bestmove`. Existence of these
   lines with non-trivial `elapsed_ms` is the objective disproof of
   the "engine is faking" claim.
2. **Quantum Deep Scan card overflow** — `Flexible` + ellipsis on the
   label `Text`, `maxLines: 2` on the blurb. No more 61-pixel right
   overflow on narrow widths.
3. **Castle SFX** — `assets/sounds/castle.mp3` (339 ms double-tink).
   New `ChessSoundType.castle`. `live_play_controller` detects
   "king moves 2 files on back rank" before the capture branch;
   `review_audio_controller` detects `san.startsWith('O-O')` before
   the capture branch.
4. **Platinum scaffold**:
   - Infinite scroll: `ImportPage { games, cursor }` returned by both
     repos. `ImportController.fetchMore()` appends de-duplicated by
     game id. `ImportMatchScreen` prefetches 220 px before list bottom.
   - Recent searches: `shared_preferences`-backed controller, MRU ≤ 8
     per source. Dropdown shown when field is focused AND empty.
   - Radar loader: `RadarScan` (`CustomPainter`, 45° sweep, 2.8 s per
     rotation). Rendered behind the `XX%` in both analysis dialogs.

## Primary flow — single recording

Linux desktop (`flutter run -d linux`), window maximized before
recording. Debug mode so `developer.log` output is visible in stdout.

1. **Cold start** — launch. Screenshot home.
2. **Home → IMPORT LIVE MATCH**.
3. **Recent searches empty state** — tap username field. Dropdown
   should *not* show (no history yet, field empty).
4. **Type `hikaru`** — type, then blur focus by tapping elsewhere /
   pressing Enter / tapping Fetch.
5. **Fetch** — verify game cards load.
6. **Infinite scroll** — scroll to the bottom of the list. Spinner
   appears at the footer; new cards load; list grows; scroll again
   to confirm multi-page pagination.
7. **Tap a game** — depth picker dialog opens.
8. **Overflow check** — screenshot the depth picker at current window
   width; then resize window to ~390 px wide (iPhone SE equivalent);
   re-screenshot. Neither should show the "RIGHT OVERFLOWED …" yellow
   banner on the Quantum card.
9. **Fast Analysis (D14)** — tap. Radar loader should rotate
   continuously behind the progress readout. Let the scan complete.
10. **Engine audit log** — tail the Flutter stdout buffer for
    `[apex.engine]` lines emitted during step 9. Capture 3+ lines
    verbatim.
11. **Review screen** — step through to confirm analysis populated.
    Close the review.
12. **Recent searches persistence** — quit the app. Relaunch.
    Navigate to IMPORT LIVE MATCH. Tap username field. Dropdown
    should now show `hikaru` under "RECENT SEARCHES".
13. **Castle SFX** — Home → ENTER LIVE MATCH. Play e4, e5, Nf3, Nc6,
    Bc4, Bc5, O-O. Confirm the castling move plays a distinct
    double-tink sound (not move.mp3 / capture.mp3). Capture the
    on-screen event; audio evidence = annotation only (Linux test
    VM was missing GStreamer plugins in prior runs; may still be).

## Adversarial assertions

| # | Assertion | Broken-build signature |
|---|---|---|
| A1 | On cold start, home renders without any `RenderFlex overflowed` assertion in the debug console. | Overflow regression. |
| A2 | Depth picker Quantum Deep Scan card renders at 390 px window width without yellow overflow stripe on the right edge. | Task 2 fix didn't land. |
| A3 | During Fast D14 scan, stdout contains ≥ 3 lines matching `\[apex\.engine\] uci_eval fen=".+" depth_target=14 depth_reached=(1[0-4]\|\?) .+ elapsed_ms=\d+` with **`elapsed_ms ≥ 100`** on at least 2 of them (non-book plies). | Engine is short-circuiting; "faking" claim would be real. |
| A4 | Radar sweep visibly rotates throughout the scan — continuous angular motion independent of progress ticks. | `CustomPainter` animation controller not wired. |
| A5 | Scroll to list bottom triggers a footer spinner, and the list length visibly grows (e.g. from 25 → 50). | `ScrollController` listener / cursor pagination broken. |
| A6 | After quit + relaunch, tapping the empty username field shows `hikaru` in a "RECENT SEARCHES" dropdown. | `shared_preferences` persistence broken or dropdown visibility logic wrong. |
| A7 | During a live-play O-O, the SFX is audibly different from a normal move (or — if audio stack broken on VM — the code path calls `ChessSoundType.castle` per log). | Task 3 fix didn't take. |
| A8 | Analysis completes without a thrown exception. Review screen renders evaluations. | Generic regression. |

## Pass / fail

- **Pass**: all 8 assertions pass or are verifiable from evidence.
- **Inconclusive**: assertion cannot be objectively verified
  (flag it explicitly in the report, e.g. audio on a silent VM).
- **Fail** on any functional assertion: stop recording, capture state,
  exit test mode, fix, re-enter.

## Out of scope

- iOS / Android builds (desktop Linux only).
- Lichess infinite scroll path (Chess.com exercises the same controller).
- `castle.mp3` subjective quality (only that the code path is taken).
- Re-verifying PR #3's UCI sync contract (already validated;
  audit log here only *adds* observability).

## CI & review state

- GitHub Actions: 0 checks configured.
- Devin Review: pending on `c142c0f`.
- No actionable review comments at test-plan time.
