# Apex Chess Product Pillars

## Purpose
This document defines what Apex Chess must become as a product. It converts broad planning into durable product pillars and prevents future work from drifting into fake features or disconnected engineering.

## Current Canon
Apex Chess is an analysis-first mobile product. The experience should start with real review value: import a game, understand it, save it, revisit it, and build improvement loops from real evidence.

Each pillar below includes purpose, expected user experience, required quality, forbidden shortcuts, and future expansion notes.

### Analyze / Review
- Purpose: turn a chess game into an understandable review.
- Expected UX: user enters or imports a game, sees board, timeline, eval movement, labels, better move, and explanations.
- Required quality: results must be based on valid positions, real engine evidence, correct perspective, and stable saved output.
- Forbidden shortcuts: no fake summaries, no labels from missing engine data, no raw UCI leaked into UI.
- Future expansion: compare Fast vs Deep, show confidence, and surface tactical verification only when proven.

### Import PGN
- Purpose: make paste/import the reliable base input path.
- Expected UX: user pastes PGN, gets validation feedback, can review without crashes.
- Required quality: sanitize PGN, normalize headers, reject malformed input safely.
- Forbidden shortcuts: no accepting empty PGN, no crashing on unusual Unicode, no partial moves treated as complete games.
- Future expansion: batch import and dedupe against Archive.

### Chess.com / Lichess Public Import Direction
- Purpose: enrich import flow using public game sources.
- Expected UX: user fetches public games by handle, sees clear source/date/result, can choose games to analyze.
- Required quality: public APIs only, safe headers, rate-limit handling, Unicode-safe names, offline fallbacks.
- Forbidden shortcuts: no password scraping, no private data assumptions, no blocking UI during fetch.
- Future expansion: source-specific metadata, dedupe, archive filters, and source reliability indicators.

### Fast Review
- Purpose: quick first-pass review.
- Expected UX: user gets fast feedback without waiting for deep searches.
- Required quality: honest depth, conservative labels, clear limits.
- Forbidden shortcuts: no Brilliant/Great/Miss final claims without deep verification.
- Future expansion: "needs deep review" flags for tactical or uncertain positions.

### Deep Review
- Purpose: slower, stronger post-game review.
- Expected UX: user accepts longer run time in exchange for higher confidence labels and better coaching.
- Required quality: deeper search, MultiPV where needed, tactical verification for rare labels, saved consistency.
- Forbidden shortcuts: no deep labels from shallow or single-line evidence.
- Future expansion: backend-powered deeper analysis, stronger explanation generation, analysis confidence.

### Offline / Local Review
- Purpose: give useful analysis without a backend when supported.
- Expected UX: local Stockfish analysis works on Android with clear battery/time limits.
- Required quality: native engine proof, lifecycle safety, timeouts, no UI blocking.
- Forbidden shortcuts: no hidden stub fallback, no pretending offline equals backend-strength Deep.
- Future expansion: device capability profiles and adaptive depth budgets.

### Review Board
- Purpose: make analysis visual and navigable.
- Expected UX: board, move list, eval timeline, highlights, arrows, and badges stay synchronized.
- Required quality: no overlapping controls, no blocked board, correct ply selection, legal orientation.
- Forbidden shortcuts: no giant decorative layout over product function.
- Future expansion: variation stepping, before/after position comparison, training from position.

### Eval Bar / Chart
- Purpose: show the game story at a glance.
- Expected UX: eval movement is readable, with jumps aligned to moves.
- Required quality: perspective labels must be explicit; mate and cp must not be confused.
- Forbidden shortcuts: no charting fake zeros, no mixing raw side-to-move score with White/Black score.
- Future expansion: confidence bands and engine-depth indicators.

### Move Timeline
- Purpose: let users scan mistakes and key moments.
- Expected UX: badges, move notation, score change, and selected ply are easy to navigate.
- Required quality: labels match stored move data exactly.
- Forbidden shortcuts: no archive count mismatches, no badge in list that is absent in timeline.
- Future expansion: filters by label, phase, tactical motif, and review confidence.

### Better-Move Coaching
- Purpose: teach concrete alternatives.
- Expected UX: for mistakes, user sees better move arrow and concise reason.
- Required quality: better move must come from engine evidence and be legal in the position.
- Forbidden shortcuts: no "AI says" copy without evidence, no fabricated best move.
- Future expansion: show principal idea, opponent threat, and practice mode.

### Explanations
- Purpose: translate analysis into human learning.
- Expected UX: beginner-friendly text explains what changed without jargon overload.
- Required quality: explanation must be grounded in actual score, tactic, or positional evidence.
- Forbidden shortcuts: no fake motivational copy, no hallucinated plans.
- Future expansion: explanation tiers for beginner/intermediate/advanced.

### Archive / Saved Analyses
- Purpose: preserve completed reviews.
- Expected UX: reopen saved games instantly when data is current.
- Required quality: saved payload must include enough timeline evidence to avoid reanalysis when possible.
- Forbidden shortcuts: no stale aggregate counts, no saved Brilliant mismatch, no hidden schema drift.
- Future expansion: filters by result/color/source/date/quality, search, dedupe, compare versions.

### Stats
- Purpose: show long-term improvement from real saved games.
- Expected UX: trends, blunder/mistake rates, openings, phases, color performance, tactical weakness.
- Required quality: only compute stats from real saved analysis and known metadata.
- Forbidden shortcuts: no opponent insights without sufficient data, no crash on empty datasets.
- Future expansion: grounded opponent profiles, phase weakness, opening drill recommendations.

### Academy / Training Future
- Purpose: turn recurring real mistakes into training.
- Expected UX: lessons, drills, spaced repetition, streaks, XP, and achievements come from saved mistakes.
- Required quality: drill positions must map to real game evidence.
- Forbidden shortcuts: no fake AI coach, no generic lesson pretending to be personalized.
- Future expansion: recurring motif detection, daily plan, achievement economy, coach mode.

### Backend / Online Analysis Future
- Purpose: support stronger analysis than local devices can provide.
- Expected UX: online Deep can be stronger, queued, saved, and reopened.
- Required quality: Apex-owned backend contract, secure analysis jobs, consistent saved result schema.
- Forbidden shortcuts: no blind dependency on public APIs as core, no backend claims before service exists.
- Future expansion: deeper Stockfish, cloud queues, private opening resources, scalable analysis storage.

## Rules
- Product work must map to one or more pillars above.
- Each feature must state whether it is local-only, backend-backed, or future-only.
- User-facing claims must match analysis evidence strength.

## Forbidden Regressions
- Product UI exposing fake, shallow, or unsupported analysis as final.
- Archive/Stats/Academy reading inconsistent schemas.
- Fast Review pretending to be Deep Review.
- Public imports freezing or crashing the app.
- Training content not grounded in real mistakes.

## Phase Usage Notes
- Use this document when scoping Analyze, Import, Archive, Stats, Academy, Review, or Backend phases.
- If a phase does not advance one pillar or its enabling infrastructure, reject or merge it into a real implementation phase.
