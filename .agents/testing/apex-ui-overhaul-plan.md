# Test plan — PR #2 "Deep Space Cinematic UI + local Stockfish wiring"

**What changed (user-visible):**
1. Home screen no longer overflows on compact windows; uses a scrollable layout with the new "APEX CHESS" / "On-Device Neural Grandmaster" copy and a sapphire-gradient primary action.
2. PGN review board picks up a **Sapphire → Aurora halo** (`BrilliantGlow`) when the current move is classified as a brilliant move.
3. "Deep Space Cinematic" theme: deep-blue background gradient, glassmorphism dialogs, Google Fonts display typography.

## What I will test (primary flow)

One end-to-end run against the Linux desktop build:

1. Launch app via `flutter run -d linux`.
2. Verify the home screen renders the new theme + no overflow is reported.
3. Tap **DEMO • OPERA GAME 1858** to open the review screen (exercises `mockAnalysisApiProvider` → `ReviewController.loadTimeline`).
4. Click the **▶ forward** button 25 times to reach ply index 24 (the `Bxd7+ Nxd7` → `Qb8+` / rook sac sequence — curated as `MoveQuality.brilliant` in `mock_analysis_api_client.dart:86`).
5. Capture a screenshot with the `BrilliantGlow` halo visible.
6. Advance further to ply 30 (curated second brilliant move, `mock_analysis_api_client.dart:98`) for a second independent trigger.

## Key adversarial assertions

| # | Action | Expected (pass) | If broken (fail) |
|---|---|---|---|
| A1 | `flutter run -d linux` | Debug console is **clean of** `RenderFlex overflowed by N pixels` warnings from `home_screen.dart` at startup and after window resize to <700 px height. | Any `RenderFlex overflowed` message naming `home_screen.dart` proves Task 1a regressed. |
| A2 | Inspect home screen | Visible text includes **"APEX CHESS"**, **"On-Device Neural Grandmaster"**, **"ENTER LIVE MATCH"**, **"QUANTUM DEPTH SCAN"**, **"DEMO • OPERA GAME 1858"**, **"Apex AI Analyst • On-Device"**. Background shows a dark-blue vertical gradient (not a flat charcoal). Primary button shows a Sapphire-to-deep-sapphire gradient with glow shadow. | Missing any of the five premium copy strings ⇒ `ApexCopy` not threaded through. Flat grey background ⇒ `ApexGradients.spaceCanvas` not applied. |
| A3 | Tap **DEMO • OPERA GAME 1858** | Navigation pushes `ReviewScreen`; the board renders, the advantage chart appears, and the coach card shows "Book move — King's Pawn Opening." for ply 0. | Crash or "No analysis loaded." ⇒ `mockAnalysisApiProvider` or `gameAnalyzerProvider` broken. |
| A4 | Click **▶ forward** 25 times | At ply 24 the coach card shows the text **"Brilliant sacrifice! Rook given for devastating attack."** AND the board is visibly enclosed by a **cyan/aurora halo** (outer glow + inner rim-light) not present on the previous ply. | Coach text present but no halo ⇒ `BrilliantGlow` wiring regressed. Halo present on ply 23 but not 24 ⇒ inverse (wiring triggers on wrong predicate). |
| A5 | Capture a second screenshot one ply later (ply 25) | Coach card text changes to **"Forced recapture."** AND the halo **fades away** (no outer glow, no cyan rim). | Halo persists on ply 25 ⇒ `BrilliantGlow.visible` isn't re-evaluating on state change. |
| A6 | Click ▶ 5 more times (ply 30) | Coach card shows **"Brilliant! Queen sacrifice forces checkmate."** AND the halo re-appears. | No halo ⇒ single-fire animation bug. |

A4/A5/A6 together form the adversarial contract: the halo must toggle on → off → on across three adjacent plies in a way that would be **visibly different** if `BrilliantGlow(visible: …)` were constant, hard-coded, or reading the wrong field.

## Out of scope (documented reasons)

* **Live play engine round-trip** — STUB engine always returns `bestmove e2e4` and a fixed `info depth 1`; testing it via UI wouldn't distinguish a working `LocalEvalService` from a broken one. Real Stockfish + `dup2` in a `flutter run` debug build would swallow Dart `print()` (documented caveat). Deferring live play verification to a future session with real NNUE weights or a feature-flag gate.
* **Stockfish vendor compile** — already verified in non-test mode: `scripts/fetch_stockfish.sh` + `cmake --build` produced `libstockfish_bridge.so` (550 KB, 6 exported symbols). Re-verifying would not add signal.
* **PGN dialog flow** — exercises `LocalGameAnalyzer` against STUB which classifies every move as `MoveQuality.best` with `score cp 0`, giving no BrilliantGlow to verify. Low signal.

## Evidence to capture

* Terminal tail showing `flutter run -d linux` successful startup with no RenderFlex warnings.
* Screenshot: home screen (full-height and a resized ~600×700 window to prove the fix).
* Screenshot: review screen at ply 0 (Opera demo loaded).
* Screenshot: review screen at ply 24 (brilliant — halo visible).
* Screenshot: review screen at ply 25 (halo faded).
* Screenshot: review screen at ply 30 (halo re-visible).
* One continuous screen recording of the click path from home → ply 30.
