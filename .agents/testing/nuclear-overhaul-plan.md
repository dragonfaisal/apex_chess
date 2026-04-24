# Nuclear Overhaul (PR #3) — Test Plan

## What I'm proving
PR #3 ships four intertwined changes. I'll test ONE end-to-end flow that
exercises all four surfaces, anchored to a concrete real Chess.com game
so every assertion has a specific expected value a reviewer can verify
against the PGN.

- Task 1 — analysis pipeline + eval bar
- Task 2 — castling sync (king + rook highlighted together)
- Task 3 — Live Import UI (Chess.com path)
- Task 4 — ECO opening book (Theory classification + engine bypass)

## Anchor game

Pulled live from `api.chess.com/pub/player/hikaru/games/2026/04`:

- White: `morphy1984` (2923)
- Black: `Hikaru` (3418)
- Result: `0-1` — White resigned after 20. Bd4
- URL: https://www.chess.com/game/live/166910114456
- Opening: Sicilian Defense, Kan (Maróczy Bind) — ECO **B41**
- Total plies: 40
- First 10 plies (mainline Kan): `1.e4 c5 2.Nf3 e6 3.d4 cxd4 4.Nxd4 a6 5.c4 Nf6`
- Castling: **ply 30** (15...O-O-O) — Black long castle, `e8→c8` king + `a8→d8` rook
- Decisive swing: plies 36–40 after `18...Rh2 19.Rxd8+ Qxd8 20.g4 Bd4`

This game is rich: opening book territory for the first ~10 plies,
clear castling shape for Task 2, real eval swing for Task 1 (White
wouldn't resign from a balanced position), and it's reachable through
the Import flow that Task 3 built.

## Primary flow (single recording)

### Step 0 — Launch
`flutter run -d linux` from `/home/ubuntu/repos/apex_chess`.

### Step 1 — Home screen
Expected:
- Title `APEX CHESS` rendered in Sora, 6-letter spacing
- Three actions visible and fully onscreen at 1280×720: `ENTER LIVE MATCH`, `IMPORT LIVE MATCH`, `QUANTUM DEPTH SCAN`
- No `RenderFlex overflowed` message from `home_screen.dart:104` (the regression).
- Opera demo button is **absent** (PR #3 deleted it).

Pass iff all three actions visible, no overflow log.

### Step 2 — Open Import Match
Click `IMPORT LIVE MATCH`.

Expected:
- Screen titled `IMPORT MATCH` with subtitle `Pull any Chess.com or Lichess profile and scan any recent game.`
- Source toggle defaults to **Chess.com** (left chip highlighted).
- Username input (JetBrains Mono) empty.
- `FETCH GAMES` button visible.

Pass iff title + subtitle match literally and toggle defaults to Chess.com.

### Step 3 — Fetch real Chess.com games
Type `hikaru` into the username field, press `FETCH GAMES`.

Expected:
- Within ~3s a list of glass cards appears.
- Top card or a near-top card matches the anchor game: players
  `morphy1984` / `hikaru`, ratings visible (`2923` / `3418`), one side
  shows a result badge.
- Opening label under at least one card reads `<ECO> • <Opening name>`
  (e.g. `D35 • Queens Gambit Declined …`). Chess.com PGNs don't ship an
  `[Opening]` tag, so the card derives the name from the `[ECOUrl]` slug
  (commit 1d41242). If the card shows only the ECO code with no name, or
  a raw `https://www.chess.com/openings/...` URL, that fix regressed.

Pass iff the anchor game is visible in the list with correct player
names + ratings.

### Step 4 — Open depth picker
Tap the anchor game card.

Expected:
- A glassmorphism dialog titled `SCAN MODE` opens with two cards:
  - `Fast Analysis` / `Depth 14`
  - `Quantum Deep Scan` / `Depth 22`
- Cancel button visible.

Pass iff both options render with correct depth labels.

### Step 5 — Kick off Fast Analysis
Tap `Fast Analysis`.

Expected:
- `_ImportAnalysisDialog` progress bar opens.
- Progress counter increments from 0/40 toward 40/40 over ~15-60s
  (depth 14 on REAL Stockfish; STUB would zip through in <1s without
  real evals — used as a sanity indicator that REAL engine is actually
  driving the analysis).
- On completion, Review screen opens.

Pass iff progress counter reaches 40/40 and Review screen opens. If
progress hangs >2 min → fail.

### Step 6 — Opening book (Task 4) check on plies 1-10
On Review screen, step forward from ply 0.

For plies 1-10 (mainline Kan), expected on several of them:
- Coach card shows **classification = `Theory`** (not `Solid`/`Good`).
- The `Theory` / opening-name pill appears under the eval bar
  (`openingLabel` is wired to `currentMove.openingName`).
- scoreCp is `null` and the eval bar reads `—` (book moves bypass the
  engine by design — Task 4's core contract).

Pass iff at least one of plies 1-10 is classified `Theory` with an
opening-name pill. If every ply of 1-10 is classified `Solid`, the book
bypass is broken.

### Step 7 — Castling visual (Task 2) on ply 30
Use the advance controls to jump to ply 30 (Black's 15...O-O-O).

Expected on the board:
- Trail highlight on **e8** (king's from-square) AND **c8** (king's
  to-square).
- Synthesised trail highlight on **a8** (rook from) AND **d8** (rook
  to). All four squares visibly lit; king + rook read as one action.
- Coach card SAN reads `15... O-O-O`.

Pass iff all four squares (e8, c8, a8, d8) are highlighted in the same
frame. If only e8+c8 light up (king alone), Task 2 is broken.

### Step 8 — Analysis accuracy sanity (Task 1)
Walk through the whole game with the ▶ control.

Expected across plies 11-40:
- At least one ply is classified **Blunder** or **Mistake** (White
  resigned — the evaluation must swing against White somewhere;
  "everything is Solid" → pipeline still broken).
- The classification color badge in the coach card is distinct
  (Blunder = red, Mistake = amber, Inaccuracy = yellow, Good = green,
  Best = emerald, Book = indigo).
- Advantage chart (EvaluationChart) is a **smooth curve**, not a flat
  line with a sudden step at the book/engine boundary. This
  specifically validates the fix commit addressing Devin Review
  finding #2 (book→engine transition Win% backfill).

Pass iff ≥1 Blunder/Mistake appears in plies 11-40 AND advantage chart
has no abrupt vertical step between the last book ply and the first
engine ply.

### Step 9 — Eval bar edge cases (Task 1 hardening)
While walking through the game, observe the eval bar values.

Expected:
- When Black has the advantage (later plies), bar shows a **negative
  float** prefixed with `-`, e.g. `-4.2`. No render error overlay.
- No `Infinity` / `NaN` / stack-trace banner at any point.
- `openingLabel` pill visible during the book phase, absent during the
  engine phase.

Pass iff the bar displays a negative float at least once without a
render error.

## Also validated as a side-effect (second round of Devin Review fixes)
- Step 3 card opening label reads `B41 • Sicilian Defense: Kan…` — a raw
  `https://www.chess.com/openings/...` URL would mean the `eco` URL →
  PGN-tag fix in fae266f didn't land.
- Step 3 card `N moves` pill matches the actual full-move count (40
  plies → `20 moves`, not `19`) — confirms the `(plies/2).ceil()` fix.
- Steps 6-8 only make sense if the analyzer awaits the ECO book future
  (fae266f provider rewiring). If that fix regressed, step 6 fails.

## Things explicitly NOT tested in this plan
- Lichess API path (Task 3 has two repositories; Chess.com exercises
  the same UI/shape so one real fetch is enough for a recording).
- Quantum Deep Scan (Depth 22) — same code path as Fast, just slower.
- Live Play castling — the ApexChessBoard highlighting code is shared;
  ply 30 of the anchor game already proves the rendering.
- Mate-in-X eval bar rendering — would require a PGN that finishes in a
  forced mate (resignation game doesn't provoke it). Acceptable gap —
  covered by unit tests on `ApexEvalBar._scoreText`.

## Why this flow would look different if the change were broken

| Broken in | Visible symptom this plan catches |
|---|---|
| Opera demo not actually removed | Home step 1 shows a 4th button |
| Import UI not wired | Step 2 fails — screen doesn't open |
| Chess.com fetcher broken | Step 3 fails — empty list / spinner hangs |
| UCI sync not fixed | Step 8 — all plies classify `Solid`, advantage chart is flat |
| Castling sync not fixed (Task 2) | Step 7 — only e8 + c8 highlight, a8 + d8 are untouched |
| ECO book not loaded | Step 6 — no Theory pill on any opening ply |
| `_FillStrip` flipped regression | (not exercised — latent; validated by unit tests) |
| Book→engine transition regression | Step 8 advantage chart shows a visible vertical step |

## Artifacts I'll produce
- Single screen recording covering steps 1-9 with `computer.record_annotate`
  structured markers (`test_start` + `assertion` per step).
- Single GitHub comment on PR #3 containing pass/fail bullets +
  embedded screenshots + link to this session.
- `test-report.md` with inline screenshots.

## Code refs
- Home flow: <ref_snippet file="/home/ubuntu/repos/apex_chess/lib/features/home/presentation/views/home_screen.dart" lines="73-96" />
- Import entry: <ref_file file="/home/ubuntu/repos/apex_chess/lib/features/import_match/presentation/views/import_match_screen.dart" />
- Depth picker: `DepthPickerDialog` inside the same file
- Chess.com repo: <ref_file file="/home/ubuntu/repos/apex_chess/lib/features/import_match/data/chess_com_repository.dart" />
- UCI sync: <ref_file file="/home/ubuntu/repos/apex_chess/lib/infrastructure/engine/local_eval_service.dart" />
- Analyzer + book gate + backfill: <ref_snippet file="/home/ubuntu/repos/apex_chess/lib/infrastructure/engine/local_game_analyzer.dart" lines="139-215" />
- Castling highlight: <ref_file file="/home/ubuntu/repos/apex_chess/lib/shared_ui/widgets/apex_chess_board.dart" />
- ECO book: <ref_file file="/home/ubuntu/repos/apex_chess/lib/infrastructure/engine/eco_book.dart" />
- Eval bar: <ref_file file="/home/ubuntu/repos/apex_chess/lib/shared_ui/widgets/apex_eval_bar.dart" />
