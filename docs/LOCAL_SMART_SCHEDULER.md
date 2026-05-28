# Local Smart Scheduler

Phase 30G adds the first local smart scheduler prototype for Apex Chess.

The scheduler exists because local Stockfish is now proven enough to use on Android, but it must not be driven blindly. A world-class mobile review path needs fast searches for ordinary positions, selective deeper work for tactically suspicious positions, and explicit resource caps so analysis remains usable on battery-powered devices.

## Strategy

The scheduler is local-first and pure:

- it plans Stockfish search budgets for one position at a time;
- it validates FEN before any engine command can be planned;
- it can skip known opening positions and only-legal-move positions without engine work;
- it returns finite depth, movetime, and MultiPV requests;
- it does not call Stockfish directly;
- it does not create move labels, accuracy, ACPL, persistence, backend calls, or UI state.

Engine execution remains behind `LocalEvalService`. Phase 30G produced deterministic planning decisions. Phase 30H adds a thin executor that consumes those decisions for a single position or small serial batch. Phase 30I adds a measured local review prototype that applies the executor across a serial list of positions.

## Profiles

Profiles define budgets, not quality labels.

| Profile | Fast pass | Deep budget | Max depth | Max MultiPV | Deep allowed | Intended use |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| `eco` | 50 ms / depth 8 | 100 ms / depth 10 | 10 | 1 | no | Battery-first or opening-heavy scans |
| `balanced` | 100 ms / depth 12 | 500 ms / depth 16 | 16 | 3 | yes | Default mobile review prototype |
| `performance` | 150 ms / depth 14 | 900 ms / depth 18 | 18 | 3 | yes | Faster devices or plugged-in sessions |
| `owner` | 250 ms / depth 16 | 1500 ms / depth 20 | 20 | 3 | yes | Strongest local prototype budget |

Low-power mode is an input flag, not a platform channel yet. When set, any profile is reduced to a small single-PV fast pass with thermal-safe budgeting.

## Position Inputs

`LocalAnalysisPositionInput` is intentionally small and extensible. It can carry:

- `fen`;
- move number and ply index;
- legal move count;
- opening-known and only-legal-move hints;
- material swing after the move;
- previous and provisional centipawn evals;
- candidate eval spread;
- check, capture, promotion, and castle signals;
- low-power mode;
- optional tags for future callers.

The scheduler does not infer opening theory or generate legal moves itself in Phase 30G. Callers provide those hints when available.

## Decision Types

The planner can return:

- `rejectInvalidFen`: malformed FEN is rejected before engine use.
- `skipOpening`: known opening position needs no engine search.
- `skipForced`: only legal move needs no engine search.
- `fastPassOnly`: one small single-PV search.
- `fastPassThenMaybeDeep`: fast pass first, with a gated deep budget reserved for a later executor.
- `deepReanalysis`: tactical or major eval signal earns a deeper finite search.
- `multipvProbe`: complex position gets MultiPV without full deep search.
- `lowPowerFastOnly`: low-power mode forces the reduced single-PV budget.

Every decision includes reason codes, whether an engine call is required, planned search steps, a safety budget, and a developer debug summary.

## Budget Rules

Hard caps apply to every planned search:

- no unlimited search;
- no depth above the active profile max;
- no movetime above the active profile deep budget;
- no MultiPV above the active profile max;
- low-power mode clamps to MultiPV 1 and small fast-pass budgets;
- quiet positions stay MultiPV 1;
- MultiPV 2 is used for suspicious/complex probes;
- MultiPV 3 is reserved for critical or high-complexity positions when the profile allows it.

Deep reanalysis is selective. It can be planned for material-sacrifice signals, large candidate spread, major eval swing, promotion, or similar tactical context. This is only search planning, not move classification.

## Android Proof Relationship

Phase 30F provisionally approved the current FFI bridge for a scheduler prototype after:

- clean Android packaging proof for `arm64-v8a`;
- S22 Ultra real-engine proof with Stockfish 17;
- `uciok` and `readyok`;
- MultiPV 3 distinct;
- invalid-FEN rejection before engine;
- 20/20 lifecycle cycles;
- no stale bestmove or queue contamination;
- 139 benchmark rows.

That approval is not final production sign-off. Scheduler work must keep the existing local engine proof and stub guardrails intact, and the Android collector should be rerun after engine/native/scheduler orchestration changes.

## Phase 30H Executor

`LocalSmartAnalysisExecutor` is the first execution layer over the pure scheduler.

It does:

- call `LocalSmartAnalysisScheduler.plan(...)` before any engine work;
- return `skipped` for known openings and only-legal-move positions;
- return `rejected` for invalid FEN before any engine call;
- run a fast pass first for engine-required decisions;
- run deep reanalysis only when the scheduler planned a deep decision or follow-up step;
- request MultiPV only when the planned search step asks for it;
- call the engine only through `LocalEvalService.evaluate(...)`;
- continue serially through small batches and aggregate telemetry;
- return safe failure results instead of throwing for expected engine errors.

It tracks:

- positions planned, skipped, and rejected;
- engine call count;
- fast calls;
- deep calls;
- MultiPV calls;
- elapsed milliseconds;
- timeout count;
- invalid-FEN count;
- budget-violation count;
- warning count.

Warnings are developer-facing and include missing bestmove, missing PV, missing score, and insufficient MultiPV lines. They do not become move labels.

## Intentionally Not Implemented

Phase 30G/30H does not implement:

- Brilliant, Great, Miss, or other final move-label logic;
- official accuracy or ACPL;
- full-game product review scheduling;
- persistence, cache, or database writes;
- backend/server/preflight calls;
- product UI, navigation, or activation;
- thermal platform channels;
- device-specific owner performance profiles;
- direct Stockfish execution from the scheduler or executor.

## Current Limitations

- The measured prototype is not wired into `LocalGameAnalyzer` yet.
- Batch execution is serial and intentionally small-scope.
- Gated deep follow-up currently means "run after fast success"; the next phase should decide which fast-pass signals justify that gate in a full-game context.
- Telemetry is in-memory only.
- Android collector was not rerun because Phase 30H did not change the native bridge or `LocalEvalService` UCI orchestration.

## Phase 30I Measured Review Prototype

`MeasuredLocalReviewPrototype` applies `LocalSmartAnalysisExecutor` across a list of scheduler position inputs.

It does:

- execute positions serially;
- preserve per-position result order;
- apply `maxPositions`;
- stop safely when `maxTotalEngineCalls` is reached or exceeded;
- stop safely when `maxTotalElapsedBudgetMs` is reached;
- stop on first failure only when `failFast` is true;
- continue after single-position failures when `failFast` is false;
- aggregate warnings and failures into a developer-facing result;
- render a compact developer report without raw engine logs.

Measured review telemetry includes:

- positions planned, executed, skipped, and rejected;
- engine calls;
- fast calls;
- deep calls;
- MultiPV calls;
- elapsed milliseconds;
- timeouts;
- invalid FENs;
- missing PV warnings;
- missing bestmove warnings;
- budget violations;
- max single-position elapsed milliseconds;
- slowest position index and optional position id.

The prototype uses executor decisions as-is. It does not decide game-level deep gating from fast-pass output yet. That is intentionally deferred so Phase 30I stays a measurement layer rather than a classifier or final review scheduler.

## Phase 30J Recommendation

Phase 30J should wire the measured prototype into a local review orchestration experiment:

- consume `LocalSchedulerExecutionResult` for parsed positions;
- keep all engine calls behind `LocalEvalService`;
- keep execution serial unless a later device proof validates parallel workers;
- use executor telemetry to report skipped, fast, deep, MultiPV, timeout, and warning counts;
- decide the full-game gate for when fast-pass output earns deep reanalysis;
- measure per-game search counts, elapsed time, MultiPV usage, and skipped positions;
- preserve the current classifier and accuracy layers unchanged;
- rerun the Android collector if engine orchestration changes materially.
