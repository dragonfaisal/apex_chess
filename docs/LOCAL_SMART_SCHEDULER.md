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

Engine execution remains behind `LocalEvalService`. Phase 30G only produces deterministic planning decisions that a later game-review executor can consume.

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

## Intentionally Not Implemented

Phase 30G does not implement:

- Brilliant, Great, Miss, or other final move-label logic;
- official accuracy or ACPL;
- full-game review scheduling;
- persistence, cache, or database writes;
- backend/server/preflight calls;
- product UI, navigation, or activation;
- thermal platform channels;
- device-specific owner performance profiles;
- direct Stockfish execution from the scheduler.

## Phase 30H Recommendation

Phase 30H should add a thin local scheduler executor around the existing review path:

- consume `LocalSchedulerDecision` for each parsed position;
- keep all engine calls behind `LocalEvalService`;
- execute fast pass first;
- execute gated deep reanalysis only when fast-pass results justify it;
- measure per-game search counts, elapsed time, MultiPV usage, and skipped positions;
- preserve the current classifier and accuracy layers unchanged;
- rerun the Android collector if engine orchestration changes materially.
