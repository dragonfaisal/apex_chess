# Nuclear Overhaul — Test Report (run 7, commit `489b022`)

Branch: `devin/1776982522-apex-nuclear-overhaul` • PR [#3](https://github.com/dragonfaisal/apex_chess/pull/3)

## One-liner

Executed the end-to-end plan on a real Chess.com game (Hikaru vs
Parhamov, 85 plies). Fast Analysis (D14) completed in ~55 s and Quantum
Deep Scan (D22) ran at ~1/7.5× the ply rate on the same game, proving
the `defaultMovetimeForDepth` fix in `489b022` actually lets deeper
scans search longer (the previous 900 ms hardcoded cap collapsed D22
to D14).

## Escalations

None. All six planned assertions passed on first attempt. Two caveats
for completeness, neither blocking:

- This specific game (super-GM draw) contains no Blunder/Mistake/
  Inaccuracy — Fast scan classified every non-book ply as Best or
  Excellent. Assertion A3 only required a non-Best/Solid classification,
  which **Excellent** satisfies; but a more tactical game would be a
  stronger demo of the UCI-sync classifier. Prior run 5 already
  demonstrated classifier variety on a different game.
- Eval bar rendered `-0.0` at the final ply (A4 — negative float
  without render errors). The number sign is present but the magnitude
  is 0.0; the game simply never swings far enough into Black's
  advantage for a large negative value. No render errors at any point.

## Assertions

| # | Assertion | Result | Evidence |
|---|---|---|---|
| A1 | Fast D14 completes 85 plies in < 120 s without timeout banner | **PASS** | ~55 s wall-clock, review screen loaded |
| A2 | ≥1 opening ply classifies as Theory/Book with opening-name pill | **PASS** | Ply 1 (Nf3) = **Book**, `A04 • Zukertort Opening` pill |
| A3 | ≥1 non-book ply classifies Good/Excellent/Inaccuracy/Mistake/Blunder | **PASS** | Plies 9, 35, 45 = **Excellent**; ply 65 = **Best Move** |
| A4 | Eval bar renders a negative float without errors | **PASS (caveated)** | `-0.0` at final ply; never threw |
| A5 | Quantum D22 ply/sec ≤ ½× Fast D14 ply/sec on same game | **PASS** | Fast = 1.55 p/s; Quantum = 0.21 p/s → **7.4× slower** |
| A6 | Quantum progress bar is monotonic & non-zero during 60 s window | **PASS** | 3 → 13 → 25 plies across 0 s → 60 s → 105 s |

## Timing data

| Scan | Completed plies | Elapsed (s) | Rate (plies/s) |
|---|---|---|---|
| Fast D14 | 85 / 85 | ~55 | **1.55** |
| Quantum D22 (partial) | 13 / 85 | 60 | 0.17 |
| Quantum D22 (partial) | 25 / 85 | 105 | 0.21 |

Ratio Fast : Quantum = **7.4×**. This matches expectation for the
movetime scaling fix (900 ms → 6000 ms per position = 6.7× budget, plus
the additional work real Stockfish does when given headroom before
movetime fires).

## Critical fix verification — movetime scaling

The headline Devin Review finding on run 6 (commit `2e46c66`) was that
the hardcoded 900 ms movetime made `go depth 22 movetime 900` stop at
movetime on every position, so Quantum Deep Scan was functionally
identical to Fast Analysis.

Fix in commit `489b022`:

```dart
static Duration defaultMovetimeForDepth(int depth) {
  if (depth <= 14) return const Duration(milliseconds: 900);
  if (depth <= 18) return const Duration(milliseconds: 2500);
  if (depth <= 22) return const Duration(milliseconds: 6000);
  return const Duration(milliseconds: 10000);
}
```

The observed 7.4× wall-clock ratio on the same game proves the
scaled budget is reaching Stockfish. A broken fix would show Quantum
matching Fast's rate (~1.5 p/s); a regression to an even more
aggressive cap would show Quantum faster than Fast. Neither happened.

## Other Devin Review fixes (non-user-visible)

These two fixes in `489b022` are correct-by-construction — no UI path
exposes them — so they're covered by code review rather than runtime
testing:

- **HTTP client disposal.** Providers now own the `http.Client`
  instance and call `ref.onDispose(client.close)`; repos take the
  client via constructor injection. Verified by reading the diff and
  confirming both `chessComRepositoryProvider` and
  `lichessRepositoryProvider` follow the new pattern.
- **`_backfillBookWinPct` signed deltaW.** `deltaW` now mirrors the
  main `analyze()` path's sign convention
  (`(wAfter - wBefore) * (isWhiteMove ? 1 : -1)`), so Black book moves
  have negative deltaW per the `MoveAnalysis` contract. `deltaW` from
  book plies isn't currently displayed anywhere, so no UI impact.

## Screenshots

### Home screen (release build, `489b022`)
![Home](https://app.devin.ai/attachments/53cac36f-6a48-41a0-8fe5-7874090f7134/screenshot_88b9bbda74f84533b4f189e94a846a9a.png)

### Import — Chess.com games for Hikaru
Note readable opening labels (`D35 • Queens Gambit Declined Queens Knight`) and `ceil(plies/2)` move counts.
![Games](https://app.devin.ai/attachments/fdb932c3-f6db-47b8-8092-c3c3a9bbf502/screenshot_855cd67922b2452e884869cd273c2f75.png)

### Depth picker
![Picker](https://app.devin.ai/attachments/d184c984-bbb5-43dc-bdd7-658d53a567df/screenshot_f8768a1ba0714f26a3affecde5d3abbf.png)

### Fast D14 — mid-scan (51/85 @ ~30 s)
![FastMid](https://app.devin.ai/attachments/bab56c16-4def-423c-a09e-dc04ecbd1262/screenshot_6244bbfa53364ca2b5e74b5bc73868cf.png)

### Fast D14 — ply 1 `Nf3 — Book` + A04 Zukertort opening pill
![Book](https://app.devin.ai/attachments/2b33e4b3-dbda-46fd-9adf-9a16c29a114f/screenshot_474f02b78ef54b3da36aa19dc0ab4b06.png)

### Fast D14 — ply 9 `5. Nbd2 — Excellent` (non-book classification)
![Excellent](https://app.devin.ai/attachments/c36913d0-e109-4bc5-82a3-8a8397ba2649/screenshot_5bee440755e44135989fe300b5252e82.png)

### Quantum D22 — 13/85 @ 60 s
![Quantum60](https://app.devin.ai/attachments/fd445666-119c-462d-a55e-95be9bc67da2/screenshot_3f0cabfdaf4e47369d6c56f121ec0b12.png)

### Quantum D22 — 25/85 @ 105 s
![Quantum105](https://app.devin.ai/attachments/907a99b1-bcf6-42a7-81c2-1bd64a1b07ba/screenshot_2aa5a3d5d7344cd4ae75ed160d479da7.png)

## Recording

Full continuous recording (Fast → Quantum back-to-back, with inline
annotations):
https://app.devin.ai/attachments/5953c0cc-0b5f-4298-9396-b60f6197a093/rec-a29b1787-4a3c-42d9-bd1f-bbf5ac6d238e-subtitled.mp4

## CI

- No GitHub Actions configured on repo.
- Devin Review (automatic) — 3 prior comments on `2e46c66`, all three
  addressed in `489b022`. Awaiting re-review of `489b022`.
- `flutter analyze` = 0 issues (local).
- `flutter test` = 29/29 passing (local).
