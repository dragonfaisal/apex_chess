# Apex Chess Backend and Online Future

## Purpose
This document defines the long-term online/backend direction for Apex Chess without allowing premature backend claims or fake online analysis.

## Current Canon

### Why Online Fast/Deep Should Eventually Be Stronger
- Mobile local Stockfish is useful, but constrained by thermals, battery, and time.
- Backend analysis can run deeper, longer, and more consistently.
- Online Deep should eventually provide stronger verification for Brilliant, Great, Missed Win, and training generation.

### Backend-Driven Stockfish Direction
- Apex should own the backend analysis contract and job format.
- Backend engine versions, depth, MultiPV, timeout, and hardware profile must be recorded.
- Backend results must map into the same raw eval, perspective, analyzer, classifier, saved analysis, archive, and stats contracts.

### Public APIs as Enrichment
- Chess.com/Lichess public APIs may support public game import and metadata.
- Lichess Opening Explorer or similar resources may inform book/theory enrichment.
- Public APIs must not be the core guaranteed analysis dependency.
- Handle rate limits, errors, and API changes gracefully.

### Saved Analysis and Archive Implications
- Backend results should be saved with source, engine version, depth, MultiPV, timestamp, and schema version.
- Reopening should not reanalyze if saved analysis is current.
- Local and backend outputs must remain comparable through common contracts.

### Anti-Cheat-Sensitive Handling
- Avoid live-game assistance features that create cheating risk.
- If online analysis jobs exist, treat user/game data carefully and avoid exposing private details.
- Do not build stealth assistance workflows.

### Future Proprietary Apex Resources
- Apex-owned opening resources.
- Apex-owned Golden analysis suites.
- Apex-owned tactical motif extraction.
- Apex-owned Academy lesson generation from saved user mistakes.

### Scalability and Cost Notes
- Deep analysis is compute-expensive; queueing, caching, and dedupe are mandatory.
- Fast/Deep tiers should have clear depth and cost budgets.
- Store reusable results keyed by canonical game identity and analysis parameters.

### What Must Not Be Faked
- "Online Deep" before backend exists.
- Stronger-than-local claims without backend evidence.
- AI coaching without grounded analysis.
- Opponent insights without sufficient saved data.

## Rules
- Backend phases must be separate from Flutter phases.
- Backend output must use explicit contracts and versions.
- Public API failure must degrade gracefully.
- Security/privacy must be considered before uploading user games.

## Forbidden Regressions
- Blind dependency on free public APIs for core analysis.
- Backend claims implemented as frontend labels only.
- Saved analysis schema incompatible with local analysis.
- No queue/cache/cost plan for deep backend work.
- Anti-cheat-sensitive live assistance without policy.

## Phase Usage Notes
- Use this file for backend, online import, online analysis, archive syncing, and cloud Deep planning.
- Do not start backend work from a Flutter UI prompt.
- Require contract-first design before server implementation.
