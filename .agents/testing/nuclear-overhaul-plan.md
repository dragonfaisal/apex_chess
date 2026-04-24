# Nuclear Overhaul — Test Plan (run 6)

Target commit: `2e46c66` (branch `devin/1776982522-apex-nuclear-overhaul`).

## What changed since run 5
- **900 ms per-position `movetime` cap** forwarded from `LocalGameAnalyzer` to
  `LocalEvalService`. Depth 14 is still requested; `UciGo` emits both
  terminators so Stockfish stops at whichever hits first. Budget for an
  85-ply game drops from ~30 min to ~80 s.
  - <ref_snippet file="/home/ubuntu/repos/apex_chess/lib/infrastructure/engine/local_eval_service.dart" lines="143-154" />
  - <ref_snippet file="/home/ubuntu/repos/apex_chess/lib/infrastructure/engine/local_game_analyzer.dart" lines="50-78" />

The prior five runs validated:
- No home-screen overflow, Opera demo absent, 3 entry points rendered.
- Chess.com import returns real cards with ratings + ECO code + opening
  label derived from `[ECOUrl]` slug.
- `(plies/2).ceil()` moveCount renders correctly on odd-ply games.
- `[ECO]` tag used instead of the `eco` URL field.
- 45 s eval timeout holds; engine no longer dies on first slow position.

Run 5 blocked on wall-clock time (3/85 plies in 90 s). Run 6's only
new claim: **a real Chess.com game completes inside ~2 min** and the
resulting timeline surfaces a valid mix of classifications.

## Primary flow — single recording

1. `flutter run -d linux --release` (release for realistic engine speed)
2. Home → `IMPORT LIVE MATCH`
3. Type `hikaru` → Fetch Games
4. Pick a **short, tactical** Chess.com game — prefer one with a
   published game length around **40–60 plies** so the recording stays
   watchable. Skip games longer than ~80 plies or shorter than 20.
5. Tap the row → Depth picker → **Fast Analysis (Depth 14)**
6. Wait for the timeline to fully populate. Step through to observe
   classifications, castling, and the eval bar.

## Adversarial assertions

Each assertion is designed so a broken build would look visibly different.

| # | Assertion | Broken-build signature |
|---|---|---|
| A1 | Analysis **completes** without the red "Quantum Scan failed — engine stopped responding." banner. | Old build would stall or abort; before 2e46c66 it would crawl at ~3 plies per 90 s. |
| A2 | Total wall-clock time from Fast Analysis tap to "done" is less than **(plies × 1.5 s + 10 s overhead)**. | Without the movetime cap, tactical positions spent 15–30 s each. |
| A3 | At least one opening ply (1–10) classifies as **Theory** with an opening-name pill. | If everything is `Solid`, the ECO-book async-race fix regressed. |
| A4 | At least one non-book ply classifies as **Blunder** / **Mistake** / **Inaccuracy** across the whole game. | A game that's all `Solid` means the UCI sync contract regressed; every modern Chess.com game contains ≥1 inaccuracy at D14. |
| A5 | Card "N moves" matches `ceil(plies/2)` for the chosen game. | Old `~/2` would under-report odd-ply games by 1. |
| A6 | Card shows `<ECO> • <readable opening name>` (not a URL, not bare code). | Indicates both the `[ECO]` tag fix and the `[ECOUrl]`-slug parser are holding. |
| A7 | If the chosen game contains a castling move, the four squares of the castling shape (e.g. e8 + g8 + h8 + f8 for 0-0) highlight in the **same frame** when navigating to that ply. | Only king squares lit means the shape-detection from `e86fb8e` regressed. |
| A8 | Eval bar renders at least one negative float (e.g. `-1.4`) without overflow or render errors during stepping. | Unhandled negative-cp would throw `RenderFlex` or NaN layout. |

## Pass / fail

- **Pass**: A1, A2, A3, A4, A5, A6, A8 all pass. A7 passes **if** the
  chosen game contains castling; otherwise record it as "untested —
  no castling in chosen game" and do not retry with a different game
  (would double-length the recording).
- **Fail** on any of A1–A6, A8: stop, capture state, exit test mode,
  debug, re-enter.

## Out of scope for this run

- Lichess import path (already validated in earlier run).
- Quantum Deep Scan (Depth 22) — same code path at a different budget;
  validating Fast Analysis is sufficient.
- Regression of BrilliantGlow from PR #2.
