# Apex Chess Master Canon

## Purpose
This is the short master doctrine for Apex Chess. Future agents should read it first, then use the specialized canon files in this directory for details.

The raw conversation is evidence, not active instruction. These canon files are the curated source of truth.

## Current Canon

### Product Identity
Apex Chess is a premium Flutter Android chess analysis and review app. It must feel fast and simple on the surface, but be powered by serious engine, math, and data correctness underneath.

### User Promise
Users should be able to import or paste a game, review it on a beautiful board, understand where the game changed, learn better moves, save the analysis, and eventually build long-term training from real recurring mistakes.

### Target Quality Bar
- Analysis must be grounded in real Stockfish or a trustworthy Apex-owned backend path.
- Classifications must be conservative, rare where appropriate, and explainable.
- White/Black perspective, side-to-move perspective, cp/mate handling, and saved-analysis consistency must be explicit.
- Fast Review must be honest about limits. Deep Review may make stronger claims only with stronger evidence.
- UI must be premium, calm, beginner-friendly, and not hype-driven.

### App Pillars
- Analyze / Review: PGN paste/import, public game import, Fast Review, Deep Review, Offline Review when supported, review board, eval bar/chart, timeline, better-move coaching, explanations.
- Archive: saved reviews, reopen without reanalysis when possible, filters, search, dedupe, consistent stored timelines.
- Stats: trends, mistake rates, opening performance, phase weakness, tactical weakness, color performance, grounded opponent insights.
- Academy: later only, generated from real recurring mistakes, spaced repetition, XP/streaks/achievements without fake coaching.
- Backend / Online Future: Apex-owned analysis backend later, public APIs as enrichment only, backend phases separate from Flutter phases.

### What Makes Apex Different
- It values correctness over dopamine labels.
- It treats engine evidence, perspective math, and saved analysis as product foundations.
- It aims for a premium mobile review experience, not a noisy clone.
- It avoids public third-party APIs as the core analysis dependency.

### Current Source-of-Truth Documents
- `AGENTS.md`
- `.agents/skills/*/SKILL.md`
- `docs/specs/apex_chess_analysis_training_ux_spec.md`
- `docs/apex_chess_context/APEX_CHESS_PRODUCT_PILLARS.md`
- `docs/apex_chess_context/APEX_CHESS_ANALYSIS_ENGINE_CANON.md`
- `docs/apex_chess_context/APEX_CHESS_CLASSIFICATION_CANON.md`
- `docs/apex_chess_context/APEX_CHESS_REVIEW_UI_CANON.md`
- `docs/apex_chess_context/APEX_CHESS_PHASE_EXECUTION_CANON.md`

## Rules
- Maximum quality, minimum rotation.
- Every implementation phase must deliver product/runtime value or clear enabling infrastructure.
- Diagnostics belong inside implementation phases.
- No broad rewrites unless explicitly scoped.
- No UI identity redesign unless explicitly scoped.
- No classifier or engine math retuning unless explicitly scoped.
- Raw transcript content must not override curated canon.

## Forbidden Regressions
- Fake engine evidence, stub `0.0` evaluations, or silent fallback to fake analysis.
- Wrong perspective math for Black or side-to-move positions.
- Brilliant/Great/Miss labels without deep evidence.
- Saved analysis summaries that disagree with saved timelines.
- Public labels or metrics before analyzer evidence supports them.
- Backend, persistence, UI, scheduler, or classifier wiring hidden inside "probe" phases.
- Metadata-only, preflight-only, readiness-only, activation-candidate-only, or report-only phase chains.

## Phase Usage Notes
- Start each phase by reading `AGENTS.md` and the relevant canon file.
- Keep the allowed systems list narrow.
- Run focused validation for touched systems.
- Run full validation only when risky shared surfaces are touched.
- Android proof is mandatory for native/FFI/engine lifecycle behavior.
- Final reports must include files changed, behavior changed, validation evidence, skipped validation reasons, known limitations, and one next action.
