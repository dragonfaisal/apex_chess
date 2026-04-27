# Apex Chess – Move Analysis, Training, and UX Specification

## 1. Executive Summary

Apex Chess already has a stable Flutter app with local Stockfish, PGN import, and basic analysis. The next step is to reach **world‑class analysis quality and training UX** comparable to, and in specific ways surpassing, Lichess, Chess.com, Chessify, and Lotus Chess.[^1][^2][^3][^4][^5]

This specification defines:

- A **Win%‑based move classification system** aligned with Lichess’ logistic evaluation model, Chesskit’s thresholds, and Chess.com’s expected‑points classifications.[^6][^7][^1]
- Carefully constrained rules for **Brilliant, Great, Missed Win, Book, Forced, Blunder**, designed to eliminate false positives (especially sacrificial “brilliants”).
- Dual **Quick vs Deep analysis modes** for mobile Stockfish with sensible depth, MultiPV, and caching strategies to avoid overheating while still enabling high‑quality final evaluations.[^2]
- A **live‑play analysis design** that keeps the UI smooth, avoids cheating, and provides optional coach assistance without spamming evaluations.
- A combined **local OpeningBookService** and optional **OpeningExplorerService** using ECO data and Lichess Opening Explorer/Masters, with clear rules for Book/Theory and book‑move mistakes.[^8][^9]
- Robust **Chess.com and Lichess import flows** using public APIs only (no passwords), handling rate limits, caching, and duplicates.[^10][^11][^12][^13][^14][^15]
- A **player statistics dashboard** and an **Apex Academy** training system inspired by Lotus Chess’s personalized training and spaced repetition, but implemented in a license‑safe, original way.[^4][^5][^16][^17][^18]
- World‑class **analysis review UX**, archive behavior, UI identity, and a **phased roadmap** tailored for an AI coding agent.

All algorithms are expressed at the level of math and data flows; no AGPL or proprietary code is copied. Lichess and Chesskit logic are used as conceptual references only, and Chess.com’s published criteria are used to inform boundaries, not to replicate their UI or wording.[^19][^1][^6]

***

## 2. Sources & References

Key sources used for this spec:

- **Lichess / Lila**
  - Lichess API docs (games export, analysis, opening).[^14][^3]
  - Lichess Win% / accuracy documentation describing logistic mapping from centipawns.[^7][^6]
  - Lichess Opening Explorer / Masters repositories.[^9][^8]

- **Chesskit (AGPL)**
  - Open‑source web trainer that re‑implements Lichess‑style move classification and accuracy on top of Stockfish, including `winPercentage`, `moveClassification`, and accuracy helpers.[^19]
  - Used purely for conceptual understanding of thresholds and Brilliant/Perfect logic; **no code to be copied** due to AGPL.

- **Chess.com**
  - Official article: *“How are moves classified? What is a 'blunder' or 'brilliant,' etc.?”* explaining expected‑points‑based thresholds and definitions for Brilliant, Great, Miss, etc.[^1]
  - Chess.com Public Data API and community docs for fetching game archives.[^11][^12][^20][^15][^10]

- **Lichess game export**
  - API examples for exporting user games with evals, clocks, and openings.[^13][^14]

- **Training apps / UX patterns**
  - Lotus Chess – Trainer & Play (Google Play, App Store, reviews) for personalized opening courses, mistake‑based drills, and Duolingo‑like UX.[^5][^21][^16][^17][^18][^4]
  - Chessify and similar cloud‑engine apps for mobile engine usage patterns.[^2]

- **Mobile UX & UI patterns**
  - Skeleton loading UX guidance.[^22]
  - Haptic feedback discussions for chess mobile apps (timing and cadence).[^23]

All licensing constraints are respected: Lichess (AGPLv3) and Chesskit (AGPLv3) cannot be copied; Chess.com content is used only for conceptual ranges, not UI duplication.[^1][^19]

***

## 3. Algorithms & Formulas

### 3.1 Mapping Stockfish Centipawns to Win Probability

#### 3.1.1 Lichess logistic model

Lichess uses a logistic function to transform engine centipawn evaluations into an expected score (Win%) for the side to move.[^6][^7]

Let \(cp\) be the centipawn evaluation (Stockfish score) for the side to move. Lichess clamps \(cp\) and uses a fixed coefficient:

1. Clamp centipawns:

\[ cp_c = \min(1000, \max(-1000, cp)). \]

2. Map to win percentage using:

\[ Win\% = 50 + 50 \cdot \left( \frac{2}{1 + e^{-0.00368208 \cdot cp_c}} - 1 \right). \]

This is equivalent to a symmetric logistic curve centered at \(cp=0\), giving 50% at equality and approaching 0/100% for large negative/positive scores.[^7][^6]

**Mate scores:** For forced mates, Lichess and Chesskit treat them as extreme outcomes; a common implementation is:

- Mate in \(+N\) (side to move giving mate): Win% = 100.
- Mate in \(-N\): Win% = 0.[^24][^19]

In Apex Chess, use this convention for consistency with both Lichess and Chesskit behaviors.

#### 3.1.2 Implementation notes

- Always use the same logistic function for all modes (Quick/Deep) and all game phases to make Win% comparable.
- Clamp cp before exponentiation to avoid numerical issues and match Lichess behavior.[^6][^7]

### 3.2 Mover‑Perspective Delta

To classify moves based on change in winning chances, everything must be normalized to the **mover’s perspective**.

For each ply \(i\):

- \(W_{prev}\): Win% of position **before** the move (from side to move at that position).
- \(W_{curr}\): Win% of position **after** the move (from side to move at the previous position’s perspective).
- \(s\): +1 if White made the move, −1 if Black made the move.

Define the **mover‑perspective Win% delta**:

\[ \Delta W = (W_{curr} - W_{prev}) \cdot s. \]

Interpretation:

- \(\Delta W < 0\): mover worsened their winning chances.
- \(\Delta W = 0\): mover played an equally strong move.
- \(\Delta W > 0\): mover improved their chances.

This is the same perspective normalization used in Chesskit’s classification and in Chess.com’s expected‑points model (which tracks how the mover’s expected outcome changes).[^19][^1]

### 3.3 Baseline Move Classifications Using Win%

#### 3.3.1 Chess.com expected‑points thresholds

Chess.com’s public article defines centipawn/Win%‑based boundaries for move quality based on **loss of expected points**, normalized to the mover’s perspective.[^1]

They give example ranges where **loss in expected points** (similar in spirit to Win% drop) is mapped roughly as:

- Best: 0.00
- Excellent: 0.00–0.02
- Good: 0.02–0.05
- Inaccuracy: 0.05–0.10
- Mistake: 0.10–0.20
- Blunder: ≥0.20

The exact numeric interpretation depends on rating, but conceptually they correspond to increasing loss of winning chances.[^1]

#### 3.3.2 Chesskit‑style Win% thresholds

Chesskit implements similar boundaries using Win% differences (mover‑perspective \(\Delta W\)) rather than raw CP.[^19]

A strong baseline classification for Apex Chess:

- Let \(\Delta W\) be the mover‑perspective Win% change in percentage points (0–100 scale).

| Condition on \(\Delta W\)        | Classification (baseline) |
|-----------------------------------|---------------------------|
| \(\Delta W < -20\)               | Blunder                   |
| \(-20 \le \Delta W < -10\)       | Mistake                   |
| \(-10 \le \Delta W < -5\)        | Inaccuracy                |
| \(-5 \le \Delta W < -2\)         | Okay / Slightly worse     |
| \(\Delta W \ge -2\)              | Excellent / Good          |

This is consistent with Chesskit’s code and broadly aligned with Chess.com’s magnitude ranges after translating expected‑points into Win%.[^19][^1]

A move that exactly matches the principal engine move for the previous position should be tagged **Best** even if \(\Delta W\) is slightly negative due to depth/precision differences.

### 3.4 Mate Scores and Classification

When the engine reports mate scores, classification should treat forced mates as **extreme Win%** rather than unstable CP spikes.

- If the position before the move is winning by force (e.g., mate in \(+N\) within a Win% threshold \(> 90\)), classification is constrained: losing that forced win is likely a **Missed Win** or worse.
- If the move results in a forced mate against the mover (mate in \(-N\)), it should be a **Blunder** or worse, regardless of CP.

Separate rules in section 3.6 ensure that Brilliant/Great are not awarded when the mover is already completely winning or when the move transitions into a lost position (mate against them), even if the move is a sacrifice.

### 3.5 Color Perspective (White/Black)

The mover‑perspective delta definition already corrects for color:

- White moves: \(s = +1\).
- Black moves: \(s = -1\).

This means the same \(\Delta W\) thresholds apply for both sides.

For convenience:

- Store and compute Win% as “expected score for the player to move” at each position.
- Whenever comparing before/after states for the same player, use \(\Delta W\) to remove color bias.

### 3.6 Strict Rules for Brilliant, Great, Missed Win, Book, Forced, Blunder

#### 3.6.1 Blunder

**Definition:** a move that substantially worsens the mover’s winning chances.

Conditions:

- \(\Delta W < -20\) percentage points.
- OR the move transitions from winning (Win% > 70) to roughly equal (Win% between 40–60) or losing (Win% < 40).
- OR the move results in a forced mate against the mover (mate in \(-N\)).

Rationale: this matches Chess.com’s Mistake/Blunder separation and Chesskit’s \(\Delta W < -20\) rule.[^1][^19]

#### 3.6.2 Forced Move

**Definition:** a move where all but one candidate lead to a clearly inferior outcome.

Implementation:

- From the previous position, use MultiPV \(k\) (e.g., 3–5 lines) at sufficient depth.
- If only **one** line keeps Win% within a small tolerance (e.g., within 5 percentage points of the best line) and all others drop by >20 percentage points:
  - Mark the mover’s chosen move as **Forced** if they played that line.

Do not penalize slight inaccuracy in forced situations; classification can be capped at “Okay” if the move is not the literal best but avoids catastrophe.

#### 3.6.3 Book / Theory

**Definition:** a move that remains within recognized opening theory.

Conditions:

- Position is within the first N plies (e.g., first 10–15 moves) **and** either:
  - Found in the local ECO book, or
  - Found in Lichess Opening Explorer / Masters database with sufficient game count.[^8][^9]
- The played move exists in the book at that node.

Even book moves can be **Mistakes** if the engine shows a large drop in Win% and the opening book is outdated; however, for user experience, in the first few plies you may choose to:

- Tag such moves as **Book?** or **Dubious Book** instead of generic Blunder, and explain that the line is playable but inferior.

#### 3.6.4 Great Move

Inspired by Chess.com’s **Great Move** definition: moves that are critical to the game’s outcome or the only good move available.[^1]

Conditions (all high‑level ideas):

- \(\Delta W > 10\) and the move crosses the evaluation boundary (e.g., losing → equal, equal → winning); **or**
- The move is at least 10 percentage points better than the next‑best alternative line:

\[ (W_{curr} - W_{alt}) \cdot s > 10. \]

Additional constraints:

- Not a trivial recapture (exclude routine material regains).
- Position after the move is not clearly losing.

Use deep MultiPV verification for Great moves.

#### 3.6.5 Missed Win

Chess.com defines “Miss” / “Missed Win” as failing to convert an opponent’s mistake into a winning position, instead ending equal or worse.[^1]

Conditions:

- Before the move, Win% for the mover is **winning** (e.g., >70) due to opponent’s mistake.
- There exists an engine line that maintains the win (best line), but the mover chose a move that:
  - Yields Win% in the “equal” band (40–60) or worse.
  - Drops Win% by at least 20 percentage points.

Classification:

- Tag such moves as **Missed Win** (possibly alongside Inaccuracy/Mistake), and surface them in training as special drills.

#### 3.6.6 Brilliant Move (Very Strict)

Goal: Brilliant should be rare and always meaningful, never just “any sacrifice” or assigned to the wrong ply.
Chess.com’s revised definition: a Brilliant move is when you find a **good piece sacrifice** with additional conditions: not ending in a bad position, and not being trivially winning even without the sacrifice.[^1]
Chesskit’s **Splendid** and **Perfect** moves encode similar constraints, but its code is AGPL; we only use conceptual ideas.[^19]

For Apex Chess, define Brilliant as follows (all conditions must hold):

1. **Piece sacrifice:**
   - The move gives up a piece (knight, bishop, rook, or queen) relative to the best non‑sacrificial line **and** cannot be matched by a trivial recapture in the next ply.
   - Implement by comparing material before/after and analyzing engine PV vs played line.

2. **Soundness:**
   - \(\Delta W \ge -2\) (no significant loss of winning chances).
   - Position after the move is **not losing** for the mover:
     - For White: \(W_{curr} \ge 50\).
     - For Black: \(W_{curr} \le 50\).
   - There is **no alternative line** (from previous position) that is trivially winning beyond the sacrifice line:
     - For White: \(W_{alt} \le 97\).
     - For Black: \(W_{alt} \ge 3\).

3. **Game context:**
   - The position before the move must not already be trivially winning (e.g., Win% > 90), otherwise the sacrifice is “win‑more” rather than brilliant.
   - The move must not result in a forced mate **against** the mover in any engine PV; if so, it is a blunder.

4. **Ply correctness:**
   - Brilliant is only awarded on the **ply where the sacrifice occurs**, not subsequent consolidating moves.
   - That ply must be the earliest move in the sacrificial sequence that commits to the material deficit.

5. **Deep verification:**
   - Any candidate Brilliant must be re‑evaluated with **Deep Analysis settings** (higher depth, high MultiPV) before committing.

If any of these fail, degrade to **Great** or **Excellent** instead of Brilliant.

***

## 4. Architecture Recommendations (Engine & Modes)

### 4.1 Quick vs Deep Analysis Modes

#### 4.1.1 Goals

- **Quick Analysis**: Fast, low‑resource evaluation to give casual feedback right after a game or during basic review.
- **Deep Analysis**: Slower, high‑depth evaluation used for final classifications (Brilliant, Great, Missed Win) and archive storage.

#### 4.1.2 Mobile Stockfish depth/movetime strategy

Referencing patterns from mobile engine tools (e.g., Chessify), practical depth targets on modern phones (mid‑range, 2024+):[^2]

- Quick Analysis:
  - Target depth: ~15–18 plies.
  - Movetime: 50–200 ms per position, depending on device performance/battery mode.
  - MultiPV: 1–2.

- Deep Analysis:
  - Target depth: ~22–26 plies (or time‑based, e.g., 500–1500 ms per critical position).
  - MultiPV: 3–5 for classification and Great/Missed Win detection.

Depth must be tuned empirically; above ranges are a safe starting point for mobile with local engines.

#### 4.1.3 MultiPV strategy

- Quick mode:
  - Use MultiPV = 1 (principal line) for most positions.
  - Optionally MultiPV = 2–3 for positions flagged as highly unbalanced or candidate tactical spots (e.g., large evaluation swings).

- Deep mode:
  - MultiPV = 3–5 for all positions in final pass.
  - Always use MultiPV ≥3 for candidate Brilliant/Great/Missed Win to evaluate alternatives.

Use MultiPV lines to compute \(W_{alt}\) and to detect “only move” and Missed Win scenarios.

#### 4.1.4 Triggering deep verification selectively

- Run **Quick Analysis** on all moves by default.
- Identify **candidate moves** for deep re‑analysis:
  - Candidate Brilliant (sacrifices with promising \(\Delta W\)).
  - Candidate Great / Missed Win / big swings (|\(\Delta W\)| ≥ 15).
  - Moves with large CP swings but ambiguous Win% due to shallow depth.

For these candidates:

- Run Deep Analysis only on the subset of positions (e.g., 10–20% of moves) to reduce CPU load and battery usage.

#### 4.1.5 Recommended UCI settings

Baseline UCI options for mobile Stockfish:

- `Threads = 1` or 2 (depending on device & battery budget).
- `Hash = 64–256 MB` depending on available RAM.
- `Contempt = 0` (or engine default).
- `MultiPV = 1` (Quick) / `3–5` (Deep for candidates).
- Use `go depth N` or `go movetime T` depending on mode:
  - Quick: `go movetime 50–200`.
  - Deep: `go movetime 500–1500` for candidates.

Expose an internal “engine profile” so you can tune these per device capabilities.

#### 4.1.6 Cache strategy

Cache key:

- `engine_cache_key = hash(PGN || engine_version || depth || mode || multipv)`.
- Use stable identifiers:
  - `game_id` (internal UUID or PGN hash).
  - `engine_version` (Stockfish build ID/commit).
  - `analysis_mode` (`quick` / `deep`).
  - `max_depth` or `movetime`, `multipv`.

Cache per game:

- Store per‑position evaluations including all MultiPV lines, Win%, and classifications.
- Quick and Deep analyses are stored **separately**; Deep overrides Quick only for final display when available.

When reopening an analyzed game:

- Load stored Deep analysis if present.
- If only Quick exists, show Quick and optionally offer “Run Deep Analysis” button.

***

### 4.2 Live Play Analysis

#### 4.2.1 Assistance modes

Define configurable modes:

1. **Disabled** – No engine during live play.
2. **Coach Hint** – Engine runs only on explicit user request for the current position.
3. **Post‑Move Feedback** – After user’s move, engine gives a short quality indicator (e.g., a colored icon), but no explicit best move.
4. **Full Analysis** – Engine runs continuously (for offline vs‑engine games only), showing suggested moves and classification. **Never enable this for rated online games**.

#### 4.2.2 When engine should run

- For online or serious games where cheating is a concern, restrict engine usage to:
  - **Post‑game analysis** only; no in‑game engine.
  - Or, in casual modes, engine can run but only against offline bots or un‑rated “training” games.

- For offline training or vs‑engine:
  - Only run engine **after** the user’s move, not on every frame.
  - Use a small movetime (e.g., 50–150 ms) for quick hints.

#### 4.2.3 Update frequency & UI non‑blocking

- Engine must run in a background isolate (which you already do) with messages passed back via streams.
- Limit frequency:
  - For continuous hint mode, do not update suggestions more frequently than, say, once every 0.5–1.0 seconds.
  - Cancel ongoing analysis if the user makes a new move before results arrive.

#### 4.2.4 Avoiding cheating‑like behavior

- For any future online play integration:
  - Disable engine analysis while connected to remote servers for rated or leaderboards games.
  - Allow optional local hints only in clearly labeled **Training** / **vs Engine** modes.
  - Store flags in game records indicating if engine assistance was used.

#### 4.2.5 Live move classification & hints

- Live classification can be simplified:
  - Show rough categories (Excellent, Inaccuracy, Blunder) based on Quick Analysis only.
  - Reserve Brilliant/Great/Missed Win labels for **post‑game Deep Analysis**.

- Hints display:
  - Single best‑move arrow for coach mode (only on explicit request).
  - Optionally highlight squares for tactical opportunities in training modes (forks, pins).

***

### 4.3 Opening Book & Opening Explorer

#### 4.3.1 Research basis

- **Lichess Opening Explorer** and **Masters database** expose move statistics per FEN, based on Lichess or master games.[^9][^8]
- Local ECO books provide standardized codes and names for openings.[^8][^9]

#### 4.3.2 Local OpeningBookService

Responsibilities:

- Maintain a local database (e.g., SQLite/Isar) of ECO codes and mainline moves.
- Map FENs to:
  - ECO code.
  - Opening name.
  - Mainline moves (SAN/UCI) up to a limited depth, e.g., 12 plies.

Behavior:

- For early moves (e.g., first 10–15 plies), check local book first.
- If the current position and move exist in book → mark as **Book/Theory**.
- If the position exists but the move does not → **Book deviation**.

#### 4.3.3 OpeningExplorerService (online)

Optional cloud service wrapping Lichess Opening Explorer:[^9][^8]

- Endpoint: `GET /opening/fen?fen=<FEN>&moves=<play>&...` → proxies to `https://explorer.lichess.ovh/lichess` or `/masters`.
- Returns:
  - Opening name and ECO code.
  - Move list with frequencies and win/draw/loss stats.

Integration:

- If online, prefer OpeningExplorerService when local book has no data or to enhance it with stats.
- Cache responses locally for commonly reached positions.

#### 4.3.4 Book vs mistake logic

- A move should be **Book** if it is in book and within a small Win% tolerance of best engine lines (e.g., no drop >10 points).
- A book move can still be flagged as a **book inaccuracy** if engine shows \(\Delta W < -10\) and explorer indicates poor practical success.
- Show ECO + opening name + “deviation at move #N” in analysis view for clarity.

***

### 4.4 Chess.com / Lichess Account Import Architecture

#### 4.4.1 Public APIs

**Chess.com Public Data API:**

- Archives index:
  - `GET https://api.chess.com/pub/player/{username}/games/archives` → months available.[^12][^15][^11]
- Monthly games:
  - `GET https://api.chess.com/pub/player/{username}/games/{YYYY}/{MM}` → JSON games.[^15][^11][^12]
- PGN export variant:
  - `GET https://api.chess.com/pub/player/{username}/games/{YYYY}/{MM}/pgn`.[^10]

**Lichess API:**

- User games export:
  - `GET https://lichess.org/api/games/user/{username}?max=...&analysed=true&clocks=true&evals=true&opening=true&literate=true` (requires token for analyzed/evals, but public base works).[^13][^14]
- Formats: NDJSON PGN or JSON when flags set.

#### 4.4.2 Rate limits & headers

- Chess.com PubAPI is read‑only and expects a reasonable User‑Agent.[^15]
- Lichess API has per‑IP and per‑token limits; respect documented rates and backoff.[^14]

Always send a custom `User-Agent: ApexChess/1.0 (contact: support@...)` and optionally `From` header.

#### 4.4.3 Import design

Flow:

1. **Account connection**
   - User enters Chess.com and/or Lichess usernames (no passwords/OAuth initially).
   - Store username and platform in local DB under `linked_accounts`.

2. **Sync now**
   - For each account:
     - Fetch archives index (Chess.com) or stream games with pagination (Lichess).[^11][^13]
     - Track last imported month or last game ID to avoid duplicates.

3. **Game caching**
   - Store raw PGNs and metadata (opponent, time control, result, rating, site) in `imported_games`.
   - Use a composite key per game:
     - `(platform, game_id_from_site)` where available, or `(platform, username, start_time, opponent, pgn_hash)`.

4. **Error handling**
   - On 4xx for specific month: log and skip.
   - On network failure: show non‑blocking banner (“Sync partially completed, tap to retry”) and mark import job as partial.

5. **Multiple accounts & switch**
   - Allow adding multiple accounts per platform.
   - Provide one‑tap filter per account in stats and archive views.

#### 4.4.4 Cache schema

Tables (or collections):

- `linked_accounts` – id, platform, username, added_at, last_sync_at, last_archive_pointer.
- `imported_games` – id, account_id, platform_game_id, pgn, metadata (JSON: ratings, time control, result, ECO, etc.), unique constraint to avoid duplicates.

No passwords: only public endpoints are used; OAuth is optional future enhancement.

***

## 5. Data Models

### 5.1 Analysis & Classification

**GameAnalysis** (top‑level):

- `id` (UUID)
- `game_id` (imported game reference)
- `mode` (`quick` | `deep`)
- `engine_version`
- `settings` (JSON: depth, movetime, MultiPV)
- `created_at`, `completed_at`

**MoveAnalysis** (per ply):

- `analysis_id`
- `ply_index`
- `san`, `uci`
- `fen_before`, `fen_after`
- `cp`, `mate` (principal line)
- `win_before`, `win_after`, `delta_win` (mover‑perspective)
- `side_to_move` (`white`/`black`)
- `classification` enum
- Flags: `is_brilliant`, `is_great`, `is_missed_win`, `is_book`, `is_forced`
- `pv_lines` (JSON of MultiPV lines with cp/mate, win%)
- `explanation` (optional text / explanation code)

Indexes:

- `(analysis_id, ply_index)`
- `(game_id)` for retrieval.

### 5.2 Archive Cache

See section 9; archive needs to store both **analysis** and **visualization** (eval graph). A separate **EvalPoint** model can hold per‑move evaluation for graph plotting: `move_index`, `eval_cp`, `win_percent`.

### 5.3 Player Statistics

**PlayerStatsAggregate** (per user, per time range):

- `user_id`
- `color` (`white`/`black`/`both`)
- `time_control` (`bullet`, `blitz`, `rapid`, `classical`, `other`)
- `period` (`all_time`, `last_30d`, etc.)
- `games_played`, `wins`, `losses`, `draws`
- `accuracy_avg`, `accuracy_white`, `accuracy_black`
- `blunders_per_game`, `mistakes_per_game`, `missed_wins_per_game`
- `avg_game_length`

**OpeningStats**:

- `user_id`
- `eco_code`, `opening_name`
- `color`
- `games_played`, `wins`, `losses`, `draws`
- `avg_accuracy`, `avg_blunders_per_game`

### 5.4 Apex Academy Training

**TrainingItem** (normalized training unit):

- `id` (UUID)
- `type` (`hanging_piece`, `missed_tactic`, `missed_mate`, `opening_mistake`, `endgame_conversion`, `king_safety`, `blunder_recovery`)
- `source` (`user_game`, `generic_puzzle`)
- `source_game_id`, `source_ply`
- `fen`
- `side_to_move`
- `prompt` (short text)
- `correct_move` (SAN/uci)
- `alternative_moves` (list, for MCQ or explanation)
- `explanation` (human‑readable text or templated string)
- `difficulty_rating` (internal)

**TrainingProgress** (user‑item relation):

- `user_id`
- `training_item_id`
- `box_index` (for Leitner system, e.g., 1–5)
- `last_seen_at`
- `success_streak`
- `next_due_at`
- `mastery_score` (0–1)

**XP / Streaks**:

- User profile fields:
  - `total_xp`, `daily_xp_goal`, `current_streak_days`, `longest_streak_days`.
- XP log table per training session with type and amount.

***

## 6. UX Specifications

### 6.1 Analysis Review UX

#### 6.1.1 Screen layout (portrait)

- **Top bar**:
  - Back button.
  - Game summary (players, result, date, opening name + ECO).
  - Flip board button.

- **Main area (top half)**:
  - Board (CustomPaint), always visible.
  - Auto‑oriented so the **user’s color is at the bottom**; initial orientation from game metadata (if user is Black, flip by default).

- **Bottom area (split)**:
  - **Move navigation bar**:
    - Prev/Next move buttons.
    - “Jump to blunders” / “Next critical moment” buttons.
  - **Horizontal timeline** (swipeable card strip):
    - Each card = half‑move or move pair, showing SAN + classification icon + tiny eval bar.
  - **Details panel (collapsible)**:
    - Shows: Win% before/after, \(\Delta W\), classification description, best move (with arrow on board), explanation text.

Empty/loading states:

- Use skeleton loaders matching the structure of the board + timeline + panel, not spinners, to keep perceived performance high.[^22]

Accessibility:

- High contrast for classification colors.
- Larger tap targets for navigation.
- Optional text‑only view for color‑deficient users.

#### 6.1.2 Interaction model

- Horizontal swipe on timeline → jumps to corresponding ply.
- Long‑press on a move card → open move detail sheet with full engine lines.
- Tap on classification icon → explanation popover (“Why this is a blunder”).

Orientation:

- Default: user’s color at bottom.
- Board flip button toggles orientation; this preference is persisted per user.

#### 6.1.3 Saved analysis reopening

- From the archive list, tapping a game should open analysis screen **instantly** by loading cached MoveAnalysis data.
- Only if no analysis exists should a “Analyze game” action be shown.

### 6.2 Player Statistics Dashboard UX

Layout ideas:

- **Top section** – High‑level KPIs:
  - Overall accuracy, win rate, games analyzed, blunders/mistakes per game.

- **Tabs or segmented control**:
  - `Overview`, `Openings`, `Time Controls`, `Tactics`, `Endgames`.

- **Openings tab**:
  - List of openings with horizontal bars showing win rate and number of games.
  - Tap into opening → per‑color stats + link to Apex Academy modules for that opening.

- **Tactics & themes**:
  - Heat map of errors by theme (forks, pins, back rank, etc.) derived from training classification.

Mobile clarity:

- Use cards with minimal text and strong numeric typography to feel premium.
- Avoid dense tables; use segmented charts and scrollable lists.

### 6.3 Apex Academy UX

- **Home**:
  - Shows daily XP goal, streak, and “Start training” button.
  - Cards for recommended modules (“Fix your Sicilian as Black”, “Convert rook endgames”).

- **Training session**:
  - Single position on board, minimal chrome.
  - Prompt at top (“Find the winning tactic”, “Punish this blunder”).
  - If multiple choice, max 2–3 answer buttons; otherwise force user to play move on board.
  - After answer: show explanation panel with text and arrows.

Avoid confusing TV‑quiz UI; keep it focused and chess‑centric.

### 6.4 Product Identity & UI Quality

- **Visual identity:** premium, futuristic; dark backgrounds, electric blue/cyan accents, subtle gradients.
- **Typography:** modern sans for body + slightly distinctive display for headings; maintain hierarchy with type size and weight.
- **Animation:** subtle transitions only; no flashy card stacks.
- **Haptics:**
  - Light haptic feedback on piece drop and critical classifications (e.g., blunder) but not on every opponent move; avoid delayed vibrations that feel “fake”.[^23]
- **Skeleton loaders:** mimic final layout, fade into content seamlessly, per UX best practices.[^22]

Avoid:

- Outdated card‑heavy dashboards.
- Cluttered side panels with too many toggles.
- Overly playful visuals that conflict with “premium” identity.

***

## 7. Implementation Roadmap for Devin

### Phase A – Move Classification Rebuild

Scope:

- Implement Win% logistic mapping, mover‑perspective \(\Delta W\), and classification rules for **Blunder, Mistake, Inaccuracy, Okay, Good/Excellent, Best, Great, Missed Win, Brilliant, Book, Forced**.

Likely files to change/create:

- `lib/core/platform/engine/engine_service.dart` – ensure cp/mate outputs are standardized.
- `lib/features/analysis/domain/move_classifier.dart` – new pure domain service.
- `lib/features/analysis/data/models/move_analysis_model.dart` – updated schema.
- `lib/features/analysis/data/repositories/analysis_repository_impl.dart` – integrate classifier.

New services/entities:

- `WinPercentCalculator` (pure function or static class).
- `MoveClassifier` (uses Win%, MultiPV results, and rules in section 3).

Risks:

- Misinterpreting mating scores.
- Overfitting thresholds for one rating band.

Tests required:

- Unit tests for logistic mapping with known cp→Win% pairs.
- Golden tests for classification given known cp/mate sequences (constructed from Lichess/Chess.com examples).

Acceptance criteria:

- Brilliant moves are rare in a large test corpus and satisfy all constraints.
- No Brilliant is assigned in positions where engine shows forced mate against mover or trivial win without sacrifice.

### Phase B – Quick/Deep Modes + Caching

Scope:

- Implement separate Quick and Deep analysis settings; selective deep verification.

Files:

- `engine_isolate_manager.dart` – accept mode/depth params.
- `analysis_repository_impl.dart` – orchestrate Quick pass + candidate Deep.
- `analysis_cache.dart` – new caching layer.

New entities:

- `AnalysisMode` enum.
- `EngineProfile` (depth, movetime, MultiPV per mode).

Risks:

- Overuse of deep analysis causing battery drain.

Tests:

- Performance tests on mid‑range device simulations.
- Verification that Deep results override Quick correctly without duplication.

Acceptance:

- Quick analysis of a 40‑move game finishes within target time budget (e.g., <10–20 seconds on mid‑range device) without overheating.
- Deep analysis only runs for a small subset of positions and terminates correctly.

### Phase C – Analysis Review UX Rebuild

Scope:

- Implement UI layout and interactions from section 6.1.

Files:

- `analysis_screen.dart`.
- `move_timeline_widget.dart`.
- `move_detail_bottom_sheet.dart`.

New components:

- Board + timeline composite widgets.
- Skeleton loader widgets.

Risks:

- Over‑rendering causing frame drops.

Tests:

- Golden tests for layout.
- Performance profiling on long timelines.

Acceptance:

- Board always visible; timeline and detail panel match spec.
- Orientation behaves correctly for user as Black.

### Phase D – Account Import & Stats Dashboard

Scope:

- Implement Chess.com/Lichess imports and base stats dashboard.

Files:

- `account_import_service.dart` (HTTP calls to public APIs).
- `imported_games_repository.dart`.
- `stats_service.dart`.
- `stats_screen.dart`.

New entities:

- `LinkedAccount` model.
- `ImportedGame` model.
- `PlayerStatsAggregate`, `OpeningStats`.

Risks:

- Hitting API rate limits; poor error messaging.

Tests:

- Mocked API responses for both platforms.
- Duplicate game detection tests.

Acceptance:

- User can add/remove accounts and sync games without entering passwords.
- Stats screen shows meaningful metrics after analysis runs.

### Phase E – Apex Academy Training System

Scope:

- Build training data model, lesson generation, spaced repetition, and XP/streaks.

Files:

- `training_item_model.dart`.
- `training_generator_service.dart` (extracts drills from analyzed games).
- `spaced_repetition_scheduler.dart`.
- `academy_screen.dart`, `training_session_screen.dart`.

Risks:

- Poor item quality (unclear prompts, ambiguous solutions).

Tests:

- Unit tests for scheduler (due dates, box movements).
- Snapshot tests for training session flows.

Acceptance:

- From a corpus of analyzed games, the system generates a variety of drills (tactics, openings, endgames).
- Daily training session respects XP/streak goals.

### Phase F – Polish, Testing, QA

Scope:

- UI polish, skeleton loaders, haptics, animations, accessibility.

Files:

- Any screen requiring UX refinement.
- Global theme and animation helpers.

Risks:

- Regressions from refactors.

Tests:

- Full integration test suite.
- Manual QA across devices and orientations.

Acceptance:

- App feels “premium” and responsive.
- No regressions in stability.

***

## 8. Testing Checklist

- **Math & classification**:
  - Logistic mapping matches reference values.
  - Synthetic positions where Brilliant/Great/Missed Win are known yield expected labels.

- **Engine integration**:
  - Quick vs Deep produce consistent results; Deep never downgrades Brilliant to Blunder without explanation.

- **Live play**:
  - Engine never blocks UI.
  - Assistance disabled during online rated games.

- **Opening detection**:
  - ECO and deviation point correct for common openings.

- **Imports**:
  - Chess.com and Lichess imports handle network failures and duplicates.

- **Stats**:
  - Accuracy and per‑opening stats computed correctly against controlled PGN sets.

- **Training**:
  - Spaced repetition surfaces due items correctly.

- **UX**:
  - Orientation behavior, board controls, skeletons, and haptics behave correctly on Android devices.

***

## 9. Instructions for the Coding Agent (Devin)

- Treat this spec as the **source of truth** for algorithms and UX behaviors.
- Implement all math (Win%, \(\Delta W\), thresholds) from formulas here, not by copying any external code.
- For any behavior that uses external APIs (Chess.com/Lichess), follow their documented rate limits and header requirements.[^10][^11][^13][^14][^15]
- Introduce new services as pure Dart/domain components where possible, and only plug into Flutter/UI via providers.
- Prefer test‑driven development for move classification, opening detection, and training schedulers.
- Document any deviations from thresholds or ranges in comments referencing this spec.

***

## 10. Risks and What Not to Do

- **License risks**:
  - Lichess (`lila`) and Chesskit are **AGPLv3** projects; you **must not copy any code** or link against server‑side components in a way that would impose AGPL on Apex Chess.[^19]
  - Use their logic conceptually only, implementing all algorithms from scratch.

- **Chess.com IP**:
  - Do not copy Chess.com’s UI, copy, or proprietary wording. Use their published expected‑points ranges conceptually but design your own copy and icons.[^1]

- **Engine abuse**:
  - Do not enable engine analysis during rated online games; this would be indistinguishable from cheating.

- **Over‑classification**:
  - Do not mark every sacrifice as Brilliant. Only moves meeting all strict criteria should get that label.

- **User trust**:
  - Avoid inconsistent counts (e.g., archive showing “2 Brilliant moves” when timeline has none). All displayed aggregates must be computed from stored MoveAnalysis data.

Following this specification will give Apex Chess a robust, explainable, and extensible analysis and training system with UX and move quality matching or surpassing top chess apps, while remaining legally and technically sound.

---

## References

1. [How are moves classified? What is a 'blunder' or 'brilliant,' etc.?](https://support.chess.com/en/articles/8572705-how-are-moves-classified-what-is-a-blunder-or-brilliant-etc) - If the expected points lost by a move is between a set of upper and lower limits, then the correspon...

2. [Chessify - Magic Chess Tools - App Store](https://apps.apple.com/vn/app/chessify-magic-chess-tools/id1397066775) - ... best chess engine from a starting position or your current analysis board. - Learn chess theory ...

3. [Lichess.org API Docs](https://lichess.org/api)

4. [Lotus Chess – Trainer - Apps on Google Play](https://play.google.com/store/apps/details?id=com.lotuschess.app&hl=en) - Games

Apps

Movies & TV

Books

Kids

Lotus Chess – Opening Trainer

Lotus Chess

In-app purchases
...

5. [LotusChess | Gamified Chess Learning App](https://www.lotus-chess.com) - Lotus Chess is a personalized opening trainer that enables you to quickly perfect your chess opening...

6. [Which centipawn calculation algorithm is Lichess currently using?](https://lichess.org/forum/lichess-feedback/which-centipawn-calculation-algorithm-is-lichess-currently-using) - Lichess page about accuracy and centipawns calculate win rate% using: Win% = 50 + 50 * (2 / (1 + exp...

7. [Lichess Accuracy metric](https://lichess.org/page/accuracy) - The Accuracy metric indicates how well you play - according to Stockfish, the strongest chess engine...

8. [loicmarie/lichess-opening-explorer - GitHub](https://github.com/loicmarie/lichess-opening-explorer) - lichess-opening-explorer. Wrapper for the Lichess Opening Explorer public API written in node.js ......

9. [niklasf/lila-openingexplorer3: Opening explorer for lichess.org - GitHub](https://github.com/niklasf/lila-openingexplorer3) - Required to find an opening name, if fen is not an exact match for a named position. player, string,...

10. [download all my games for a month - Chess Forums](https://www.chess.com/forum/view/help-support/download-all-my-games-for-a-month) - How do I save it into a pgn file so i can open in a database program like chessbase? You'll have to ...

11. [Help with Chess.com API: Retrieve Elo vs. Number of Rapid Games](https://www.chess.com/forum/view/general/help-with-chess-com-api-retrieve-elo-vs-number-of-rapid-games) - https://api.chess.com/pub/player/<usernerme>/games/archives ==> this helps you get all the game arch...

12. [Chess.com API | Documentation | Postman API Network](https://www.postman.com/team-zouhair/chess-analyse/documentation/q50kqzo/chess-com-api) - This is a read-only REST API that responds with JSON-LD data. ... Player Game Archives · Open reques...

13. [Lichess API - GitHub Gist](https://gist.github.com/mistrasteos/d536a54ca8bdf87f51f797a49585b179) - This query options include clock, annotations and some relevant information about the game. replace ...

14. [api/doc/specs/lichess-api.yaml at master · lichess-org/api - GitHub](https://github.com/lichess-org/api/blob/master/doc/specs/lichess-api.yaml) - Lichess API documentation and examples. Contribute to lichess-org/api development by creating an acc...

15. [Chess.com API - PublicAPI](https://publicapi.dev/chess-com-api) - This API documentation serves as a guide for developers to access and utilize the Chess.com PubAPI f...

16. [Lotus Chess – Trainer - APK Download for Android - Aptoide](https://lotus-chess.en.aptoide.com/app) - Lotus Chess is a powerful chess training app designed to help you improve faster than any other ches...

17. [Lotus_Chess : r/Lotus_Chess - Reddit](https://www.reddit.com/r/Lotus_Chess/comments/1otks22/lotus_chess/) - Lotus Chess: Master Openings with Your Personalized AI Coach ... training plan ... Line-by-Line Dril...

18. [App Review: Lotus Chess - Reddit](https://www.reddit.com/r/chess/comments/1kh6s78/app_review_lotus_chess/) - It's a new app for studying openings. The app takes your LiChess.org or Chess.com username to pull y...

19. [GuillaumeSD/Chesskit: Chess website to review games ... - GitHub](https://github.com/GuillaumeSD/Chesskit) - Chesskit is an open-source chess website to play, view, analyze and review your chess games for free...

20. [How I downloaded all my chess.com games using Python. - Reddit](https://www.reddit.com/r/chess/comments/9ifkaq/how_i_downloaded_all_my_chesscom_games_using/) - Using the chess.com API and Python3 I was able to download all my games in monthly archives. Here is...

21. [Lotus Chess – Trainer - App Store](https://apps.apple.com/us/app/lotus-chess-trainer/id6738741464) - # Lotus Chess – Trainer

Learn. Train. Improve.

Free · In‑App Purchases · Designed for iPad. Not ve...

22. [Skeleton loading screen design — How to improve perceived ...](https://blog.logrocket.com/ux-design/skeleton-loading-screen-design/) - Skeleton loading screens keep users engaged during load time. Learn why they're better than spinners...

23. [Chess com Haptic Feedback on Mobile App is WRONG . Please ...](https://www.chess.com/forum/view/site-feedback/chess-com-haptic-feedback-on-mobile-app-is-wrong-please-fix-it) - Chess.com's current haptic feedback isn't actually haptic feedback—it's just a delayed vibration aft...

24. [How to Reproduce a Lichess Advantage Chart in Python](https://www.landonlehman.com/post/how-to-reproduce-a-lichess-advantage-chart-in-python/) - This is reported either in centipawns (1/100th of a pawn) or in moves to checkmate. This value repor...

