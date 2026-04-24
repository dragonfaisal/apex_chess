# Nuclear Overhaul — Test Plan (run 7)

Target commit: `489b022` (branch `devin/1776982522-apex-nuclear-overhaul`).

## What changed since run 6

Three new Devin Review findings on run 6's movetime commit. All three
fixed in `489b022`:

1. **CRITICAL — movetime now scales with depth.**
   Run 6 hardcoded 900 ms for every position, so `go depth 22 movetime 900`
   always stopped at movetime (~D14 on desktop NNUE), making Quantum Deep
   Scan functionally identical to Fast Analysis. New behaviour:
   `LocalGameAnalyzer.defaultMovetimeForDepth(depth)` returns 900 ms @ D14,
   6000 ms @ D≤22.
   - <ref_snippet file="/home/ubuntu/repos/apex_chess/lib/infrastructure/engine/local_game_analyzer.dart" lines="69-78" />
2. **MEDIUM — HTTP clients now close on provider dispose.**
   Providers own the client; repos take it via ctor injection.
   - <ref_snippet file="/home/ubuntu/repos/apex_chess/lib/features/import_match/presentation/controllers/import_controller.dart" lines="14-28" />
3. **LOW — `_backfillBookWinPct` deltaW is signed per side-to-move.**
   Matches the main `analyze()` path's contract.

Everything else (ECO book race, Chess.com moveCount ceil, ECO from PGN
tag, ECOUrl slug parsing, 45 s eval timeout, resilient stall handling)
was already validated in run 6.

## Primary flow — single recording

Two back-to-back scans on the same game — the depth-dependent ply rate
is what proves the critical fix.

1. Home → `IMPORT LIVE MATCH` → `hikaru` → Fetch
2. Tap the Parhamov game (43 moves, A07 Kings Indian Attack, 85 plies)
3. **Fast Analysis (D14)** — should complete in ~60–80 s as before.
4. Return to the game list, tap the same game again.
5. **Quantum Deep Scan (D22)** — do NOT wait for completion; observe
   the progress bar for ~60 s to measure the plies/sec rate.
6. Return home.

## Adversarial assertions

| # | Assertion | Broken-build signature |
|---|---|---|
| A1 | Fast Analysis completes 85 plies in < 120 s without the timeout banner. | Regression of the movetime cap would stall again. |
| A2 | After completion, at least one opening ply classifies as **Theory / Book** with opening-name pill. | ECO book async-race regression. |
| A3 | After completion, at least one non-book ply shows a non-"Best/Solid" classification (Good / Excellent / Inaccuracy / Mistake / Blunder). | UCI sync contract regression; a game that's all Solid would indicate the classifier is stuck. |
| A4 | Eval bar renders at least one negative float during stepping without render errors. | Unhandled negative cp would throw `RenderFlex` or NaN layout. |
| A5 | **Quantum D22 shows measurably slower ply/sec than Fast D14** on the same game: at 60 s elapsed, Quantum progress must be *less than half* of Fast's rate. For Fast at ~1.3 plies/s, Quantum should be ≤ 0.3 plies/s (roughly 6×–10× slower). | If Quantum ploughs through at the same rate as Fast, the movetime scaling fix didn't take and the picker is still a lie. |
| A6 | Quantum progress bar shows a *non-zero, monotonically increasing* ply count during the 60 s observation window. | A stuck bar at 0/N would mean the engine died on first position. |

## Pass / fail

- **Pass**: A1, A2, A3, A4, A5, A6 all pass.
- **Fail** on any: stop, capture state, exit test mode, debug, re-enter.

## Out of scope for this run

- Castling visual (Parhamov game has no castling; covered by unit
  coverage in earlier commits and verified visually in earlier runs).
- Lichess import path (already validated).
- HTTP client disposal test — no user-visible behaviour; verified
  behind the fact that repeated provider invalidations no longer leak
  sockets. Covered by the code review + static analysis.
- `_backfillBookWinPct` sign fix — not user-visible; covered by
  unit tests in the same commit.
