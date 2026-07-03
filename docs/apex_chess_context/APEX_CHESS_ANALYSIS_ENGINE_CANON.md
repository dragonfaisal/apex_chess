# Apex Chess Analysis Engine Canon

## Purpose
This document defines the durable analysis and engine rules for Apex Chess. It protects engine correctness, score perspective, saved-analysis consistency, and honest Fast vs Deep behavior.

## Current Canon

### Stockfish / Local Engine Expectations
- Local Android engine must be real Stockfish through the native bridge, not a fake stub.
- Engine lifecycle must be proven on Android for launch, UCI handshake, FEN input, search, raw eval, perspective normalization, and adapter boundaries.
- Engine work must use short timeouts, fail closed, and avoid UI isolate blocking.

### Online Backend Direction
- Online Fast/Deep should eventually use Apex-owned backend analysis when the product is ready.
- Public APIs may enrich openings or import metadata, but must not be the core analysis dependency.
- Backend phases must be separate from Flutter phases.

### Fast vs Deep Review
- Fast Review: fast, shallow, conservative, useful for first-pass review.
- Deep Review: slower, stronger, allowed to make higher-confidence labels only after deeper evidence.
- Fast mode must not overclaim Brilliant, Great, Missed Win, or deep tactical certainty.

### Depth Expectations
- Depth values are evidence strength, not marketing.
- A depth-1 probe proves plumbing only; it does not justify product labels.
- Final classification depth and MultiPV policy must be explicit per mode.

### Raw UCI Handling
- Raw UCI output is developer-only evidence.
- Product and analyzer contracts should receive structured fields: best move, depth, raw score type, cp, mate, source, and perspective.
- Raw output previews must be sanitized and truncated.

### Score Perspective Rules
- Raw UCI score must be treated as side-to-move perspective unless the engine boundary documents a different convention.
- Normalize to explicit White and Black perspective fields before analyzer/classifier/review usage.
- Never use ambiguous names like `score`, `eval`, or `advantage` without a perspective suffix.

### CP / Mate Handling
- CP and mate are separate score types.
- Do not convert mate to centipawns inside raw evidence phases.
- Do not compute Win%, CP-loss, or move quality until the relevant phase explicitly owns that math.

### Before / After Evaluation Concept
- Move quality requires at least before-position and after-position evidence.
- Single-FEN raw eval is not move classification.
- Before/after deltas must preserve player/mover perspective.

### CP-Loss and Win% Delta Risks
- CP-loss can mislead in mating positions and high-eval positions.
- Win% delta must be computed from the mover/player perspective, not blindly from raw engine side-to-move score.
- Official accuracy/ACPL must not be exposed until the math, source, and persistence are proven.

### MultiPV Requirements
- Great, Only Move, Brilliant, Missed Win, and Missed Mate need alternative-line evidence.
- MultiPV must be used where alternative move comparison is part of the claim.
- Single-PV evidence is insufficient for "only move" claims.

### Android / Local Engine Proof Lessons
- Native bridge loading can fail on Windows host while Android succeeds; report host-blocked proof honestly.
- Android proof is mandatory for real native engine behavior.
- Probes must advance implementation value, not become repeated readiness loops.

### Saved-Analysis Consistency
- Saved review data must reopen with the same timeline, labels, and counts.
- Aggregates should derive from saved timeline data, not stale database snapshots.
- If classifier logic changes, saved analysis versioning and migration policy must be explicit.

### Failure / Fallback Behavior
- Engine failures must fail closed.
- No fake `0.0` eval fallback.
- If backend or local engine is unavailable, the app must say unavailable, partial, or retry, not pretend analysis succeeded.

## Rules
- Validate FEN before it reaches engine input.
- Keep raw engine evidence, normalized perspective evidence, and classifier labels as separate layers.
- Treat Android proof as required for Stockfish/FFI/native lifecycle changes.
- Use controlled probes to prove one boundary at a time, then consolidate into real adapter work.

## Forbidden Regressions
- Stub engine or constant `0.0` score used as analysis.
- Wrong perspective for Black or side-to-move positions.
- Fake or overconfident classifications from shallow output.
- Saved Brilliant mismatch between archive counts and timeline.
- Book/theory phase inconsistencies.
- Fast mode assigning deep-only labels.
- Raw UCI, PV dumps, or Stockfish command strings in product UI.
- Full analysis claims from single-FEN or depth-1 plumbing probes.

## Phase Usage Notes
- Use this file for any phase touching Stockfish, UCI, raw eval, score normalization, analyzer adapter boundaries, or saved analysis evidence.
- Required focused validation depends on touched layer: pure math tests for normalization, Android proof for native engine behavior, classifier tests for labels.
- Do not run full engine suites for docs-only or narrow pure-model changes unless shared runtime behavior is touched.
