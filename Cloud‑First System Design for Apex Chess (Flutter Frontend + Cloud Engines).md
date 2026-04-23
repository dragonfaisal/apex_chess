# Cloud‑First System Design for Apex Chess

## Executive Overview

Apex Chess is pivoting from a heavy on‑device Stockfish integration to a **cloud‑first, API‑driven architecture** that keeps the Flutter client under 50 MB while delivering world‑class analysis and gameplay comparable to Lichess and Chess.com. This blueprint defines:[^1][^2]

- The frontend and backend tech stack.
- Cloud engine and analysis architecture, including use of Lichess Cloud Eval and Opening Explorer.
- PGN/SAN handling and move classification logic based on Lichess/Chesskit math.
- Audio/UI synchronization for smooth PGN review.
- Database and API designs that future‑proof for stats, AI bots, and anti‑cheating.

The system is intentionally **API‑centric**: the mobile app is a thin, reactive client; all heavy computation (engine, deep PGN analysis, statistics aggregation, cheat detection) runs in scalable backend services.

***

## Phase 1 – Foundation: Tech Stack & Core Architecture

### 1.1 Frontend: Flutter Architecture for Complex Board State

**State management recommendation: Riverpod 2.x (`riverpod` / `flutter_riverpod`).**

Rationale:

- Riverpod is compile‑time safe, testable, supports dependency injection, and works well with feature‑first architecture.[^3]
- Providers can be parameterized per game/session and decomposed into granular slices (board state, timers, analysis, audio events), which is crucial for a high‑frequency UI like a chess board.

**Frontend architectural pattern:**

- **Feature‑first modules**: e.g., `live_play`, `pgn_review`, `analysis`, `profile`, `settings`.
- Within each feature: `domain`, `data`, `presentation` (Clean Architecture variant reused from your previous design).
- `EngineService` and `AnalysisService` are abstractions in the domain layer that talk to cloud APIs rather than FFI.

Key frontend providers:

- `gameSessionProvider(gameId)` – authoritative game state (board, clocks, result).
- `analysisTimelineProvider(gameId)` – list of per‑move evaluations and classifications (for PGN review).
- `audioEventsProvider(gameId)` – stream or queue of high‑level audio events derived from analysis & navigation (not from raw taps).
- `openingInfoProvider(fen)` – current opening name and book status (from Opening Explorer/local cache).

### 1.2 Backend: Recommended Infrastructure Stack

#### 1.2.1 High‑level choice

For an app that needs **auth, storage, Postgres, Realtime, and serverless compute** with minimal ops, a **Supabase‑centric architecture** backed by custom microservices is a strong fit.[^4]

Recommended stack:

- **Core backend platform:**
  - Supabase (managed Postgres + Auth + Storage + Realtime) for user auth, game storage, and event streams.[^4]
- **Custom logic & engines:**
  - Stateless microservices hosting Stockfish/Scorpio/LCZero for deep analysis and bot play.
  - Implemented in **Go** or **Rust** (high concurrency, low memory, easy containerization).
- **API gateway:**
  - Either Supabase Edge Functions or a standalone API gateway (e.g., Fastify/Node.js or Go + Kong/Envoy) fronting all microservices.

#### 1.2.2 Why Supabase over pure Firebase

Firebase is excellent for mobile‑first apps, but for a chess platform requiring **relational queries (stats, leaderboards)** and future **anti‑cheat analytics**, Postgres is more flexible. Supabase gives:[^4]

- Postgres with SQL and JSONB for flexible schemas.
- Built‑in row‑level security for multi‑tenant safety.
- Realtime channels suitable for live game updates.

The architecture can be summarized as:

```text
[Flutter app]
   ↓ HTTPS / WebSocket
[API Gateway / Edge Functions]
   ↓             ↓
[Postgres (Supabase)]   [Engine & Analysis Microservices]
```

### 1.3 Core Backend Components

1. **Auth Service:** email/password, OAuth, or magic links via Supabase Auth.
2. **Game Service:** CRUD/stream for live games, finished games, PGN imports.
3. **Analysis Service:** orchestrates calls to:
   - Lichess Cloud Eval (for cached, free evals).[^5]
   - Internal engine cluster (for deeper or offline analyses).
4. **Opening Service:** integrates with Lichess Opening Explorer (`explorer.lichess.ovh`) and local curated opening tables.[^6][^7]
5. **Stats Service:** aggregates per‑player statistics over time (ACPL, accuracy, blunder rate etc.).
6. **Anti‑Cheat Service (later):** model evaluation of live play vs engine suggestions, suspicious pattern detection.

All backend components are exposed via a **versioned REST+WebSocket API** (e.g., `/v1/game`, `/v1/analysis`, `/v1/opening`, etc.).

***

## Phase 2 – Cloud Engine, PGN/SAN, and Gamification Logic

### 2.1 Cloud Engine & Analysis Architecture

#### 2.1.1 Replacing local Stockfish with cloud APIs

Sources of evaluation:

1. **Lichess Cloud Eval API** (`/api/cloud-eval`) – returns cached, multi‑line Stockfish evaluations for many positions without running a new engine instance.[^5]

   - Endpoint (documented in Lichess API): get cached evaluation for FEN if available.[^1][^5]
   - Pros: zero CPU cost, instant if cached (especially for opening / common middlegame), includes multiple variations.[^5]
   - Cons: rate‑limited and only for cached positions; cannot rely on it for all moves or high‑volume analysis.[^8]

2. **Your own Engine Service** – containerized Stockfish (or cluster).

   - Exposed via internal API (e.g., `/engine/eval` accepting FEN + depth/prefs).
   - Horizontally scalable with Kubernetes / ECS / Nomad.
   - Responsible for deep analysis requests, bots, and non‑cached positions.

**Evaluation flow for a single FEN:**

1. `AnalysisService` receives `POST /v1/analysis/fen` with:
   - `fen`, `depth`, `numLines`, `mode` (live, quick, deep), `cacheOnly` flag.
2. **Step 1**: Query Lichess Cloud Eval (for public FENs):[^5]
   - If 200 and evaluation is fresh, normalize result and return to client.
3. **Step 2**: If Cloud Eval does not have the position or rate‑limited:
   - Check internal cache (Redis/KeyDB or Postgres table storing eval JSON).
   - On miss, queue a job to internal Engine Service and return either:
     - a pending status with job ID, or
     - a fast shallow eval if engine capacity permits immediate evaluation.

**PGN‑wide analysis (game review):**

- `POST /v1/analysis/game` with PGN or gameId.
- Backend:
  - Uses a chess library (e.g., `python-chess`, or your own service using `dartchess` logic ported) to:
    - Parse PGN.
    - Generate FEN for every ply.
  - For each FEN:
    - Check local cache.
    - Optionally query Cloud Eval for common positions.
    - Otherwise schedule engine jobs.
  - Store all `PositionEval` results in Postgres (JSONB per move) and/or Redis.
  - Once complete, produce per‑move analysis including Win%, classifications, etc. and store in `analysis_moves` table.

The mobile app calls `GET /v1/analysis/game/:gameId` to retrieve a full `MoveAnalysis[]` timeline rather than spamming per‑FEN requests.

#### 2.1.2 Rate limits & caching strategy

Because Lichess Cloud Eval is rate‑limited and meant for **cached positions only**, you **must not** hammer it with every analysis request.[^8][^5]

Strategies:

- Use Cloud Eval only for:
  - Popular openings and common middlegame positions.
  - Low‑depth “quick hints” in live play.
- For full PGN analysis:
  - First, try Cloud Eval only for “shallow evaluation” passes.
  - For missing positions or deeper analysis, use your own engine cluster.
- Maintain an **EvalCache** table:
  - Keyed by `(fen, engine_id, depth, lines)`.
  - Contains top lines, cp, mate, depth, and evaluation timestamp.
  - Enforce TTL or versioning when engine parameters change.

Backend enforces **per‑user and per‑IP rate limits** for analysis endpoints. When Cloud Eval returns 429, gracefully fall back to local engine or show a “cloud eval not available, using local engine” message.

### 2.2 SAN & Move Generation in Flutter

For client‑side move validation and SAN display without heavy CPU, leverage existing Dart chess libraries.

Recommended packages:

- **`dartchess`** – full chess rules and move generation, FEN/PGN read/write.[^9][^10]
  - Pros: Comprehensive, supports variants (though you can limit to standard), native Dart (
>not< web) but works fine in Flutter mobile.[^9]
- **`chess`** (Dart) – leaner library for standard chess move generation, FEN, PGN.[^11]

For a lightweight, mobile‑only app:

- Use **`dartchess`** in a dedicated `ChessRules` service encapsulated behind your domain interfaces.
- Responsibilities:
  - Apply moves and maintain board state locally for live play.
  - Validate user moves and handle legality (check, checkmate, stalemate, etc.).
  - Generate SAN notation from moves (e.g., `Nf3`, `Bxf7+`, `O-O`).
  - Parse imported PGNs client‑side when offline or low‑latency is needed.

This keeps the Flutter app from needing to round‑trip to the backend for basic rules or SAN.

### 2.3 Lichess Win% Math & Knight Fork / Perspective Bug

Lichess’ Win% equation (documented in `accuracy` page) is:[^12][^13]

Let `centipawns` be the evaluation (cp) from the engine for the side to move.

1. Clamp cp to a reasonable range, e.g. \([-1000, 1000]\).

2. Compute:

\[ Win\% = 50 + 50 \cdot \left( \frac{2}{1 + e^{-0.00368208 \cdot cp}} - 1 \right). \]

For each move at ply \(i\):

- Let \(W_{prev}\) be the Win% for the position **before** the move.
- Let \(W_{curr}\) be the Win% for the position **after** the move.
- Let \(s = +1\) if White played the move, and \(s = -1\) if Black played.

Define signed delta:

\[ \Delta W = (W_{curr} - W_{prev}) \cdot s. \]

This ensures that **worsening the mover’s position always yields negative \(\Delta W\) regardless of color**, fixing perspective issues.[^13][^14]

Chesskit’s thresholds (already extracted previously) can be mirrored cloud‑side:

- \(\Delta W < -20\): Blunder.
- \(-20 \le \Delta W < -10\): Mistake.
- \(-10 \le \Delta W < -5\): Inaccuracy.
- \(-5 \le \Delta W < -2\): Okay.
- \(\Delta W \ge -2\): Excellent/Good.
- Move equals engine best: Best move (★).

#### Fixing the “Knight Fork” / sacrifice misclassification

The previous bug occurred because the evaluation logic looked only at **cp differences** or naive Win% change without context of sacrifices and alternatives. The Chesskit/Lichess logic for “Splendid/Brilliant” and “Perfect/Only move” avoids this by:

- Checking if the move is a **piece sacrifice** (not just pawn) using the FEN + move vs engine best line.
- Ensuring Win% does not drop by more than a small tolerance (e.g., \(\Delta W \ge -2\)).
- Ensuring the resulting position is **not losing** and that there is no alternate line with trivially winning Win% (>97% for White, <3% for Black).[^14]

To avoid misclassifying Knight forks and similar sacrifices:

1. Compute **Win%** for:
   - The played move (using cloud engine or cached evals for the position after the move).
   - The engine’s top line for the previous position (before the move).
   - At least one strong alternative line (previous position, first line whose first move \(\neq\) played move).

2. Apply the **Splendid/Perfect logic** cloud‑side exactly as in Chesskit:

   - Splendid (“Brilliant”):
     - \(\Delta W \ge -2\).
     - `isPieceSacrifice` is true.
     - Move is not losing and does not ignore a trivially winning alternative.

   - Perfect (“Great/Only”):
     - \(\Delta W \ge -2\).
     - Not a simple recapture.
     - Not losing and no trivially winning alternative.
     - Either crosses the 50% Win% boundary with \(\Delta W > 10\), or is >10% better than the best alternative.[^14]

3. The **“Knight fork”** (sacrifice of material for positional advantage) will:
   - Show minimal or positive \(\Delta W\).
   - Be recognized as a sacrifice versus engine’s best line.
   - Not be flagged as Blunder because \(\Delta W\) will not be < −20.

By computing all of this **on the backend** (with strong chess libraries and engine data) and returning only the final `MoveClassification` to the client, the mobile app remains lightweight and bug‑free.

### 2.4 Clean handling of SAN in Flutter

Workflow:

1. On device:
   - Maintain a `Chess` object using `dartchess` or `chess` package representing the current game state.[^11][^9]
   - After every legal move, ask the library for SAN representation of the move.
   - For PGN import, parse PGN entirely on device (or on backend if you want centralized logic), then show SAN moves in the UI.

2. On the backend:
   - For analysis/historical games, you can also use `python-chess` or similar to validate and annotate PGNs, but the client doesn’t depend on this for basic display.

This provides the desired user‑facing notation (`Nf3`, `Bxf7+`, `O-O`, etc.) with minimal CPU cost.

***

## Phase 3 – UX, Audio Synchronization, Opening Explorer, & Future Scale

### 3.1 UI Architecture for Instant API Responses

The key is to avoid per‑click remote calls. Instead, treat analysis as a **timeline resource** that is pre‑fetched.

For PGN review:

1. User imports a PGN → app POSTs it once: `POST /v1/analysis/game`.
2. Backend parses and runs whole‑game analysis asynchronously, then stores results.
3. App subscribes via polling or WebSocket (Supabase Realtime channel) to `analysis_status(gameId)` and `analysis_moves(gameId)`.
4. Once analysis is ready, app downloads the full `MoveAnalysis[]` JSON payload (per‑move classification, Win%, SAN, opening tags) and **keeps it locally in memory**.
5. When user scrubs Next/Prev:
   - UI reads from in‑memory timeline only; **no network calls per click**.
   - Riverpod provider returns `MoveAnalysis` for the selected ply in O(1).

For Live Play:

- Board state is driven by WebSocket/Realtimes updates of moves, not per‑move HTTP.
- Analysis hints are optional; they are either:
  - Provided as part of the game stream (`hint` fields), or
  - Fetched from cloud with coarse throttling (e.g., one evaluation per 5–10 seconds, or on user‑requested hints only).

### 3.2 Audio & UI Synchronization Strategy

Problems to solve:

- Rapid scrubbing through 40–60 moves causes: overlapping sounds, stale audio, and possible UI jank.

Architectural solution:

1. **Centralized AudioController service on the client**

   - Expose a `ReviewAudioController` (singleton or Riverpod provider) with an immutable queue of high‑level audio events:
     - e.g., `MoveSoundEvent(moveType, classification, timestamp)`.
   - Only the PGN review controller can enqueue events; UI widgets never call the audio engine directly.

2. **Debounced navigation events**

   - When user taps Next/Prev or drags a slider, emit a `NavigationEvent` with the target ply.
   - Use a short debounce (e.g., 80–120 ms) to coalesce scrubbing into fewer updates.

3. **Audio event rules**

   - On each final navigation (after debounce), determine difference from previous ply:
     - If moving +1: play standard move sound + classification sound (if major event).
     - If jumping multiple moves: optionally play only a “whoosh” or a summary sound at the final position.
   - Use a **voice‑leading rule**: if a new audio event arrives while another is playing, fade out the current one and play the latest, unless the old one is critical (e.g. game end).
   - Apply a global rate limit: “no more than one heavy sound (blunder/brilliant) per X ms”.

4. **Non‑blocking audio playback**

   - Audio playback uses a separate isolate or at least runs via asynchronous APIs so it never blocks the UI thread.
   - All heavy audio decoding can be pre‑loaded (e.g. load 10–20 small audio clips on app start or first use).

5. **UI synchronization**

   - Use a single source of truth for the current ply index via Riverpod.
   - When ply changes:
     - UI redraws board and side panels using cached `MoveAnalysis` for that ply.
     - AudioController receives `onPlyChanged` event and decides what to play.

This decouples the **what** (plausible audio sequence) from the **how fast the user scrubs**, ensuring the app remains responsive.

### 3.3 Opening Explorer API – Perfect Book Handling

Lichess Opening Explorer API is served by `explorer.lichess.ovh` and is documented in public wrappers.[^7][^6]

Key endpoint pattern:[^7]

- **Example:** `GET https://explorer.lichess.ovh/lichess?fen=<FEN>&play=<moves>&speeds=blitz,rapid,classical&ratings=2000,2200,2500`.
- Parameters:
  - `fen`: FEN of the starting position.
  - `play`: comma‑separated UCI moves from the root position.
  - Filters: rated speeds, rating ranges, variant, etc.

Integration strategy:

1. On backend, implement `GET /v1/opening/fen`:
   - Accepts `fen`, optional filters (speeds, ratings, minGames).

---

## References

1. [Lichess.org API Docs](https://lichess.org/api)

2. [API Tips - Lichess.org](https://lichess.org/page/api-tips) - Lichess offers a wide range of API endpoints which can be used for everything from downloading games...

3. [How to create a chess app in flutter - PSI Blog](https://psi-blog.github.io/post/chess_app/) - In this post, I'm going to explain how to create a basic chess app with Flutter. For this app I used...

4. [Handling WebSockets | Supabase Docs](https://supabase.com/docs/guides/functions/websockets) - This allows you to: Build real-time applications like chat or live updates; Create WebSocket relay s...

5. [Database of all lichess Cloud evaluations](https://lichess.org/forum/lichess-feedback/database-of-all-lichess-cloud-evaluations) - This new set of lichess features would be well accompanied by the option to turn off cloud input whe...

6. [loicmarie/lichess-opening-explorer - GitHub](https://github.com/loicmarie/lichess-opening-explorer) - lichess-opening-explorer. Wrapper for the Lichess Opening Explorer public API written in node.js. Us...

7. [niklasf/lila-openingexplorer3: Opening explorer for lichess.org - GitHub](https://github.com/niklasf/lila-openingexplorer3) - Required to find an opening name, if fen is not an exact match for a named position. player, string,...

8. [Cloud-eval API returns 429 from the very start · Issue #18781 - GitHub](https://github.com/lichess-org/lila/issues/18781) - Seems a bit brutal. You get a warning that you evaluated too much, but you have to chill a day? Bett...

9. [dartchess | Dart package - Pub.dev](https://pub.dev/packages/dartchess) - Provides chess and chess variants rules and operations including chess move generation, read and wri...

10. [dartchess example | Dart package - Pub.dev](https://pub.dev/packages/dartchess/example) - Provides chess and chess variants rules and operations including chess move generation, read and wri...

11. [chess - Dart and Flutter package in Game Development category](https://fluttergems.dev/packages/chess/) - chess is a Dart and Flutter package. A library for legal chess move generation, maintenance of chess...

12. [Which centipawn calculation algorithm is Lichess currently using?](https://lichess.org/forum/lichess-feedback/which-centipawn-calculation-algorithm-is-lichess-currently-using) - Lichess page about accuracy and centipawns calculate win rate% using: Win% = 50 + 50 * (2 / (1 + exp...

13. [Lichess Accuracy metric](https://lichess.org/page/accuracy) - The Accuracy metric indicates how well you play - according to Stockfish, the strongest chess engine...

14. [GuillaumeSD/Chesskit: Chess website to review games ... - GitHub](https://github.com/GuillaumeSD/Chesskit) - Chesskit is an open-source chess website to play, view, analyze and review your chess games for free...

