# Apex Chess Deep Research Canon

## Purpose
This document condenses the raw research conversation into durable product, UX, engine, and backend principles. It does not copy raw research blocks or third-party code.

## Current Canon

### Competitor Lessons
- Chess.com teaches that friendly labels and review flow matter, but labels must not be copied blindly or inflated.
- Lichess teaches the value of transparent engine analysis, open PGN/export flows, opening explorer concepts, and Win% style modeling.
- Chesskit and similar open-source tools are conceptual references only; do not copy AGPL implementation.
- Lotus-style training validates the future Academy direction: lessons should come from recurring mistakes.
- Cloud engine products show that deeper backend analysis can outperform local mobile analysis, but cost and latency must be managed.

### Classification Research Lessons
- Expected-points/Win% thinking is more user meaningful than raw cp alone.
- Brilliant must be rare, sacrifice-based, and deeply verified.
- Great/Only Move requires alternative-line evidence.
- Missed Win/Missed Mate requires proof that a better line existed.
- Book moves need separate theory treatment.

### UX / Review Lessons
- Users need a review board, timeline, eval chart, badges, better move, and short coaching.
- Beginners need simple explanations; advanced details can be layered.
- Premium UI comes from restraint, not noisy gamification.
- Saved review reopening must be instant and consistent.

### Engine / Backend Lessons
- Local Stockfish is necessary for offline capability and trust.
- Public APIs are useful for import/opening enrichment but risky as the core analysis engine.
- Apex-owned backend should eventually power stronger online Deep analysis.
- Backend output must share the same contract with local output.

### What Apex Should Adopt Conceptually
- Win% and expected-outcome thinking.
- Opening explorer/book as theory context.
- Rare high-confidence labels.
- Mistake-to-training loops.
- Saved analysis as a central product asset.

### What Apex Must Not Copy Blindly
- Third-party code from AGPL sources.
- Competitor UI wording, badge economy, or proprietary heuristics.
- Public API dependency as a core service.
- Dopamine-driven fake "AI" coaching.

### Product-Quality Benchmarks
- No fake engine data.
- No wrong perspective.
- No saved/timeline mismatch.
- No Fast mode overclaims.
- No crash on empty/import/error states.

### Long-Term Proprietary Apex Direction
- Apex-owned raw eval contracts.
- Apex-owned classifier rules and Golden suites.
- Apex-owned backend job format.
- Apex-owned Academy training generation from user data.

## Rules
- Use external research as design evidence, not source code.
- Convert research into Apex-specific contracts and tests.
- Mark obsolete or rejected ideas as historical.
- Keep public claims grounded in implemented capability.

## Forbidden Regressions
- Copying protected code or datasets.
- Treating public APIs as guaranteed unlimited infrastructure.
- Reintroducing fake AI/coach wording.
- Inflating labels for excitement.
- Using raw research snippets as active prompts.

## Phase Usage Notes
- Use this file when planning product direction, competitor parity, training, backend, or classification philosophy.
- Do not use this file as permission to implement broad features; scope phases through `AGENTS.md` and the phase template.
