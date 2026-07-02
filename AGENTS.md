# Apex Chess Agent Instructions

## Project Mission

Apex Chess is a Flutter Android chess analysis and review app. Its mission is to give players fast, clear, premium game review backed by a serious analysis brain: PGN/import analysis, saved reviews, archive, stats, and later Academy training generated from real recurring mistakes.

Execution law: maximum quality, minimum rotation.

Every implementation phase must combine real implementation value, guardrails, focused validation, and a concise report. Do not split one meaningful implementation into separate diagnostic, preflight, readiness, activation-candidate, and report phases.

## Apex Product North Star

- Analyze: PGN paste/import, Chess.com/Lichess public game import, Fast Review, Deep Review, offline review when supported, review board, evaluation bar/chart, move timeline, better-move coaching, and useful explanations.
- Engine / Analysis Brain: reliable engine evaluation, correct White/Black perspective, Win% delta model, MultiPV evidence for Great/Only Move, strict Brilliant rules, Missed Win logic, opening/book handling, and saved-analysis consistency.
- Archive: saved reviews, instant reopen without reanalysis when possible, filters by result/color/source/date/quality, search, and dedupe.
- Stats: accuracy trends, blunder/mistake rates, opening performance, weak phase detection, tactical weaknesses, color performance, and opponent insights only when grounded in real data.
- Academy later: lessons generated from real recurring mistakes, spaced repetition, XP/streaks/achievements, and no fake AI coaching.
- UI Identity: fast, clean, premium, simple on the surface, powerful underneath, beginner-friendly, Material 3 inspired, deep dark navy, electric blue/cyan accents, subtle neon only when meaningful, and no fake hype words.
- Backend / Online Future: Apex-owned backend later; public third-party APIs may enrich imports/openings but must not become the core dependency. Backend phases must stay separate from Flutter phases unless explicitly scoped.

## Architecture Boundaries

- Prefer the existing feature-first Flutter structure under `lib/features/`, with domain, data, presentation, controller, provider, repository, and view-model seams preserved.
- Keep chess math and classifier behavior in pure Dart domain services where possible.
- Keep UI code consuming presentation-safe state rather than transport DTOs, debug internals, raw engine output, or persistence internals.
- Keep Online Review/backend work behind explicit contracts and disabled gates until scoped activation work exists.
- Keep local engine work behind safe engine abstractions and fail-closed behavior.

## Do Not Touch Casually

Do not casually touch:

- Stockfish, FFI, native bridge, CMake/Gradle packaging, UCI parsing, engine isolates, lifecycle, or Android engine proof collectors.
- Analyzer runtime, runtime input envelopes, scheduler execution, or DeepTacticalVerifier.
- Classifier math, Win% model, Brilliant/Great/Missed Win/Book/Blunder rules, MultiPV evidence handling, or perspective normalization.
- Persistence, cache formats, saved analysis, archive reopen, database-like storage, or migrations.
- Backend contracts, activation gates, private staging/preflight paths, URL handling, or public preview flags.
- Broad Flutter UI identity, theme, navigation, shared providers, or app root wiring.
- Tests/fixtures that encode engine, classifier, archive, review, or backend safety unless the phase explicitly owns that surface.

## Phase Scoping Rules

- No broad rewrites.
- No UI redesign unless scoped.
- No classifier or engine math retuning unless scoped.
- A valid phase must provide product/runtime value or clear enabling infrastructure.
- A valid phase must advance at least one of: engine substrate, analyzer input, analyzer output, classifier correctness, saved analysis, review UI, import/archive/stats flow, backend contract, or real QA coverage for a touched system.
- Diagnostics belong inside implementation phases.
- Reject standalone diagnostic, preflight, readiness, activation-candidate, metadata-only, and report-only loops unless they directly enable or block a real implementation in the same phase.
- Prompts that say "world-class" must define acceptance criteria.
- Do not start new product features while required engine/analyzer/persistence contracts for that feature are unstable.

## Validation Policy

- Use focused validation for narrow changes.
- Run the smallest meaningful tests for the touched system.
- Full validation is for risky surfaces, not every small docs/tool/skill change.
- Do not run full Flutter, engine, classifier, or Android matrices for workflow docs or skill-only changes.
- Android manual verification is required when changing real Stockfish packaging, FFI lifecycle, scheduler execution, thermal/battery behavior, Android-only integration flows, or user-visible flows that host tests cannot cover.

## Focused vs Full Test Policy

Focused tests are usually enough for:

- Docs, workflow, skill, and prompt-template changes.
- Isolated pure-domain changes with narrow blast radius.
- Small copy, model, mapper, or widget-state changes.

Run broader suites when touching:

- Engine, native bridge, UCI, scheduler, analyzer runtime, or Android proof.
- Classifier thresholds, Win% math, perspective handling, MultiPV evidence, or label persistence.
- Persistence/cache schema, saved analysis, archive reopen, or dedupe behavior.
- Shared providers, app routing, navigation, or visible Analyze/Archive/Stats/Review flows.
- Backend activation gates, staging/preflight tools, URL handling, or public availability logic.

## Reporting Policy

Final reports must be concise and factual. Include files changed, behavior changed, tests run, validation evidence, skipped validations with reason, known limitations, and next action.

Do not overclaim readiness. Do not claim production approval from fake, fixture-only, disabled, or developer-only evidence. Do not write hype.

## Naming Conventions

- Phase names: `Phase <number><letter> - <short product/runtime value>`.
- Checkpoint tags: `checkpoint-phase-<phase>-<slug>` only for meaningful implementation or approved workflow artifacts.
- Skills: kebab-case directories under `.agents/skills/<skill-name>/SKILL.md`.
- Dart code should follow existing naming, feature boundaries, and analyzer style.
- Reports and docs should use clear, scoped names that describe the behavior or contract they protect.

## Git Checkpoint Policy

- Do not create commits or tags unless the user asks.
- Do not create checkpoint tags for diagnostic-only, preflight-only, readiness-only, activation-candidate-only, or metadata-only work.
- Before any requested commit/tag, verify `git status`, summarize changed files, and avoid reverting unrelated user changes.
- If the worktree contains unrelated changes, ignore them unless they block the scoped task.

## Product Language Rules

- Apex copy must be clear, calm, grounded, and useful for chess players.
- Avoid fake hype words, fake AI coaching, unsupported opponent insights, and claims not backed by data.
- Beginner-facing explanations should be understandable without exposing raw engine internals unless a debug/dev surface is explicitly scoped.
- UI language should fit a premium chess analysis app: direct, precise, and not gamified beyond what the scoped feature supports.

## Anti-Loop Rules

- No standalone diagnostic/preflight/readiness/activation loops.
- No metadata-only phase chains.
- No diagnostic-only phases with no implementation value.
- No repeated readiness gates for the same blocked surface.
- No full test matrix overuse for small docs/tool/skill changes.
- No broad prompts that touch engine, analyzer, classifier, UI, persistence, backend, and tests at once.
- No feature prompts that depend on unstable engine/analyzer/persistence contracts unless the phase stabilizes those contracts.

## Final Report Template

```markdown
FILES CHANGED:

* <path>

BEHAVIOR CHANGED:

* <runtime/product behavior, or "None - workflow/docs only">

TESTS RUN:

* <commands and result>

VALIDATION EVIDENCE:

* <specific evidence>

SKIPPED VALIDATIONS:

* <validation> - <reason>

KNOWN LIMITATIONS:

* <remaining limitation or "None known">

NEXT ACTION:

* <one precise next action>
```
