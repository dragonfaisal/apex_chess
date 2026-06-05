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

Engine execution remains behind `LocalEvalService`. Phase 30G produced deterministic planning decisions. Phase 30H adds a thin executor that consumes those decisions for a single position or small serial batch. Phase 30I adds a measured local review prototype that applies the executor across a serial list of positions. Phase 30J adds an orchestration experiment that maps review-shaped positions into scheduler inputs and runs the measured prototype.

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
- Game-level deep gating is still an experiment-only layer; it selects candidates and reports telemetry but does not replace product review output.
- Telemetry is in-memory only.
- Android collector was not rerun because Phases 30H-30K did not change the native bridge or `LocalEvalService` UCI orchestration.

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

## Phase 30J Orchestration Experiment

`LocalReviewOrchestrationExperiment` is the first non-UI orchestration layer over measured local review.

It can consume:

- already scheduler-ready `LocalAnalysisPositionInput` values;
- lightweight parsed review position records;
- PGN strings through the same `dartchess` parser family already used by local analysis.

The experiment maps only facts that are safely available:

- FEN;
- ply index and move number;
- opening-known and only-legal hints when supplied;
- capture, check, promotion, and castle hints when supplied or parsed;
- existing eval/spread/material hints when supplied;
- developer-only tags.

It does not invent chess facts. Unknown legal-move counts, opening status, material swings, previous evals, and candidate spreads remain absent unless the caller provides them.

Execution remains serial:

- map source positions into scheduler inputs;
- call `MeasuredLocalReviewPrototype`;
- let the measured prototype call `LocalSmartAnalysisExecutor`;
- let the executor call `LocalEvalService`;
- aggregate review-level telemetry and developer observations.

The report includes source count, mapped count, skipped-before-mapping count, measured skip/reject/fast/deep/MultiPV counts, engine calls, elapsed time, budget-stop reason, warnings, failures, and future deep-gating observations. It intentionally omits raw UCI logs and long PV dumps.

Deep-gating output is observation-only in Phase 30J:

- positions that actually received deep search;
- positions that look like future game-level gate candidates because the scheduler planned deep, gated-deep, or MultiPV work;
- budget-pressure observations;
- MultiPV-pressure observations;
- timeout or warning hotspots.

Phase 30J still does not implement:

- final move labels;
- official accuracy or ACPL;
- product review replacement;
- persistence or cache writes;
- backend/server calls;
- UI activation;
- parallel engine execution.

## Phase 30K Game-Level Deep Gating Experiment

`GameLevelDeepGatingExperiment` adds the first game-level policy that decides which positions deserve deferred deeper work after a fast local pass.

The experiment exists to spend local analysis budget selectively:

- run a broad fast pass first when requested;
- inspect fast-pass evidence plus position context;
- generate deterministic `DeepReanalysisCandidate` records;
- suppress opening-known, only-legal, invalid, failed, low-power, and budget-exhausted positions;
- select only the highest-priority candidates under explicit per-game caps;
- optionally execute selected deep positions through `LocalReviewOrchestrationExperiment`.

Candidate reason codes include:

- `majorEvalSwing`;
- `candidateEvalSpread`;
- `tacticalSignal`;
- `materialSwing`;
- `givesCheck`;
- `captureOrPromotion`;
- `mateScoreDetected`;
- `missingFastPv`;
- `highLegalMoveCount`;
- `previousEvalAvailable`;
- budget and suppression reasons.

The policy is pure and deterministic. It can run in `planOnly` mode with provided fast-pass evidence and no engine calls.

Execution modes:

- `planOnly`: no engine calls; use supplied evidence and position context to create a candidate plan.
- `fastPassOnly`: run the bounded fast pass through orchestration, then stop.
- `fastThenPlanDeep`: run the fast pass through orchestration, generate deep candidates, then stop.
- `fastThenExecuteSelectedDeep`: run the fast pass, select candidates, and execute only selected deep positions through the existing measured stack.

Budget rules:

- no unlimited deep search;
- `maxDeepCandidates` caps selection;
- `maxDeepEngineCalls` caps deferred deep work;
- `maxTotalEngineCalls` accounts for fast-pass cost before selecting deep candidates;
- `maxTotalElapsedBudgetMs` can suppress deep selection when the elapsed budget is already exhausted;
- low-power mode suppresses deep by default;
- MultiPV never exceeds the active scheduler profile cap;
- `eco` suppresses deep selection because that profile does not allow deep reanalysis.

Telemetry reports:

- positions considered;
- fast failures;
- opening/forced/invalid suppressions;
- candidates generated and selected;
- budget and low-power suppressions;
- deep executions;
- MultiPV deep executions;
- timeout, warning, and budget-violation counts;
- elapsed milliseconds;
- max candidate priority.

The developer report remains compact. It includes counts, selected candidate summaries, suppression reasons, warnings, failures, and the next recommendation. It intentionally avoids raw UCI logs, long PV dumps, final move labels, official accuracy, or ACPL.

Phase 30K still does not implement:

- final move labels;
- Brilliant, Great, Miss, or similar classifier output;
- official accuracy or ACPL;
- replacement product review results;
- persistence, cache, or database writes;
- backend/server calls;
- UI activation;
- parallel engine execution.

## Phase 30L Budget Tuning

`DeepGatingBudgetTuningRunner` adds a pure representative-game telemetry layer over the Phase 30K policy.

The tuning layer exists to answer whether the deep-gating policy is selective enough before product integration. It does not require Android, a host bridge, or real engine execution in normal tests.

Representative scenario categories:

- quiet opening-heavy;
- tactical middlegame;
- technical endgame;
- low-power suppression;
- forcing line;
- mixed invalid/safety;
- budget pressure.

The default profile matrix compares:

- `eco`;
- `balanced`;
- `performance`;
- `owner`;
- `balanced` with low-power enabled.

The current tuning path is intentionally pure:

- representative games use compact scheduler-ready position inputs;
- optional fast-pass evidence is supplied as structured test data;
- `DeepGatingPolicy` ranks and suppresses candidates;
- selected ratios, reason-code counts, suppressions, and estimated deep call cost are aggregated;
- no real local engine call is required.

Selected-deep ratio guardrails:

- `eco` should select no deep work;
- low-power should suppress deep work;
- `balanced` should stay a small selective subset;
- `performance` may select a larger subset but remains finite;
- `owner` can be strongest, but must still avoid selecting every move by default;
- budget-pressure scenarios must make budget suppression visible.

Budget pressure means the policy found plausible candidates but explicit per-game caps suppressed some of them. That is not a product failure by itself; it is the signal Phase 30M should use to choose default mobile budgets and decide which scenarios need stronger evidence before deeper execution.

The tuning report includes:

- scenario/profile table;
- positions considered;
- candidates generated;
- candidates selected;
- selected ratio;
- budget status;
- top reason-code counts;
- suppression counts;
- warnings and observations.

Phase 30L still does not implement:

- final move labels;
- Brilliant, Great, Miss, or similar classifier output;
- official accuracy or ACPL;
- replacement product review results;
- persistence, cache, or database writes;
- backend/server calls;
- UI activation;
- parallel engine execution.

## Phase 30M Developer-Only Integration

`LocalReviewIntegrationExperiment` is the first developer-only integration layer over `GameLevelDeepGatingExperiment`.

It compares three paths for small review-shaped position sets:

- pure plan candidate counts;
- fast-pass measured execution plus deep-candidate planning;
- selected-deep execution under explicit budgets.

The source can be scheduler-ready `LocalAnalysisPositionInput` values or lightweight parsed review positions. Parsed positions are mapped conservatively into scheduler inputs: FEN, ply and move indexes, opening/forced hints, tactical hints, eval/spread/material hints, and developer tags are preserved when supplied. Unknown chess facts are left unset.

Budget presets are explicit and finite:

| Preset | Profile | Max deep candidates | Max deep calls | Max total calls | Max elapsed |
| --- | --- | ---: | ---: | ---: | ---: |
| `ecoSafe` | `eco` | 0 | 0 | 12 | 5,000 ms |
| `balancedDefault` | `balanced` | 3 | 6 | 24 | 15,000 ms |
| `performanceMeasured` | `performance` | 5 | 10 | 40 | 30,000 ms |
| `ownerStrongLocal` | `owner` | 8 | 16 | 64 | 60,000 ms |

Execution remains serial and local-first:

- `planOnly` performs no engine calls;
- `fastThenPlanDeep` runs the fast pass and selects deep candidates without executing them;
- `fastThenExecuteSelectedDeep` executes only selected deep candidates;
- all engine work stays behind `GameLevelDeepGatingExperiment`, `LocalReviewOrchestrationExperiment`, `MeasuredLocalReviewPrototype`, `LocalSmartAnalysisExecutor`, and `LocalEvalService`;
- no product review controller, UI, storage, backend, or classifier layer is updated.

The integration result reports source count, mapped count, pure candidate count, selected-deep count, executed-deep count, fast/deep/total engine calls, elapsed time, selected-deep ratio, budget pressure, warning/failure propagation, top reason codes, and suppressions.

The developer report intentionally omits raw UCI logs, long PV dumps, final move labels, official accuracy, and ACPL.

Phase 30M still does not implement:

- final move labels;
- Brilliant, Great, Miss, or similar classifier output;
- official accuracy or ACPL;
- replacement product review results;
- persistence, cache, or database writes;
- backend/server calls;
- UI activation;
- parallel engine execution.

## Phase 30N PGN-Derived Fixture Profiles

`LocalReviewPgnFixtureProfileRunner` validates the developer-only integration stack on compact legal game-shaped inputs instead of scheduler-ready synthetic positions only.

Fixture categories:

- quiet opening;
- tactical middlegame;
- forcing line;
- technical endgame;
- budget pressure;
- invalid safety.

Fixtures are intentionally compact and test-safe. PGNs are parsed with the same `dartchess` family already used by local orchestration, then mapped into `LocalReviewOrchestrationPosition` records. Fixture-specific hints may add developer-only context such as candidate spread, material swing, legal-move count, or check/capture hints. The mapper does not infer missing chess facts beyond what the PGN parser and fixture hints supply.

The default comparison matrix covers:

- `ecoSafe` in plan-only mode;
- `balancedDefault` in plan-only mode;
- `performanceMeasured` in plan-only mode;
- `ownerStrongLocal` in plan-only mode;
- `balancedDefault` with low-power enabled;
- `balancedDefault` fast-then-plan;
- `performanceMeasured` fast-then-plan.

The fixture comparison verifies broad guardrails:

- `ecoSafe` selects no deep work;
- low-power selects no deep work;
- `balancedDefault` remains a small controlled subset;
- `performanceMeasured` may select at least as many candidates as balanced, but still not every move;
- `ownerStrongLocal` remains finite;
- budget-pressure fixtures make cap suppressions visible;
- invalid PGNs fail safely without engine calls.

The comparison report includes fixture/profile rows, mapped position counts, pure candidate counts, selected-deep counts, selected ratios, engine calls, budget pressure, warnings, failures, and guardrail messages. It intentionally omits raw UCI logs, long PV dumps, final move labels, official accuracy, and ACPL.

Phase 30N still does not implement:

- final move labels;
- Brilliant, Great, Miss, or similar classifier output;
- official accuracy or ACPL;
- replacement product review results;
- persistence, cache, or database writes;
- backend/server calls;
- UI activation;
- parallel engine execution.

## Phase 30O Real-Device Selected-Deep Smoke

`LocalReviewPgnFixtureDeviceSmokeCollector` adds a developer-only real-device smoke layer over the compact PGN fixture profile runner.

The smoke exists to prove selected-deep execution on Android without turning the experiment into product review output. It runs the existing local stack only:

- `LocalReviewPgnFixtureProfileRunner`;
- `LocalReviewIntegrationExperiment`;
- `GameLevelDeepGatingExperiment`;
- `LocalReviewOrchestrationExperiment`;
- `MeasuredLocalReviewPrototype`;
- `LocalSmartAnalysisExecutor`;
- `LocalEvalService`.

Default scope is intentionally conservative:

- fixtures: quiet opening plus tactical middlegame;
- mode: `fastThenExecuteSelectedDeep`;
- preset: `balancedDefault`;
- max fixtures: 2;
- max positions per fixture: 14;
- max total engine calls: 32;
- max elapsed budget: 30,000 ms.

`performanceMeasured` is available only with a second explicit flag and a larger explicit cap.

Opt-in command:

```powershell
flutter test integration_test/local_review_pgn_fixture_device_smoke_test.dart -d <android-device-id> --dart-define=APEX_RUN_LOCAL_REVIEW_PGN_FIXTURE_DEVICE_SMOKE=true
```

Optional performance preset:

```powershell
flutter test integration_test/local_review_pgn_fixture_device_smoke_test.dart -d <android-device-id> --dart-define=APEX_RUN_LOCAL_REVIEW_PGN_FIXTURE_DEVICE_SMOKE=true --dart-define=APEX_RUN_LOCAL_REVIEW_PGN_FIXTURE_DEVICE_SMOKE_PERFORMANCE=true
```

Without the opt-in flag, the integration test prints a skipped result and does not run the local engine. Normal unit tests use fake engine execution only.

The smoke report renders safe JSON and markdown with:

- platform, device, ABI, and engine identity text when available;
- fixture and preset counts;
- mapped positions;
- pure candidate count;
- selected and executed deep count;
- selected-deep ratio;
- fast, deep, and total engine calls;
- elapsed time;
- timeout, warning, failure, and budget-pressure counts;
- per-fixture summaries.

Pass interpretation:

- at least one `balancedDefault` fixture run completes;
- selected-deep ratio is finite and below 100%;
- total engine calls stay within caps;
- execution remains serial through the existing stack;
- no uncaught exception occurs;
- no visible stub identity is accepted.

Warning interpretation:

- no selected-deep work was planned or executed;
- budget pressure appears;
- balanced selected-deep ratio is high;
- timeout or missing-result warnings appear;
- `performanceMeasured` looks too expensive for the requested cap.

Failure interpretation:

- selected every mapped position for deep analysis;
- total engine call cap exceeded;
- visible stub identity;
- fixture execution failure or unbounded selected-deep behavior.

Phase 30O still does not implement:

- final move labels;
- Brilliant, Great, Miss, or similar classifier output;
- official accuracy or ACPL;
- replacement product review results;
- persistence, cache, or database writes;
- backend/server calls;
- UI activation;
- parallel engine execution.

## Phase 30P Golden Analysis Suite

Owner-run Phase 30O real-device selected-deep smoke passed on an S22 Ultra / SM S908U1 / android-arm64 / Android 16 target with ABI-consistent packaging.

Observed 30O evidence:

- `balancedDefault` completed with warnings: 2 fixture runs, 21 mapped positions, 5 candidates, 3 selected-deep executions, selected-deep ratio about 0.14, 27 total engine calls, elapsed about 1.8 to 2.0 seconds, 1 budget-pressure row, 0 timeouts, 0 failures.
- `performanceMeasured` completed with warnings: 2 preset runs, 42 mapped positions, 10 candidates, 8 selected deep, 7 executed deep, selected-deep ratio about 0.19, 57 total engine calls, elapsed about 5.9 seconds, 0 timeouts, 0 failures.
- Stub identity was not detected.

That evidence supports starting `GoldenAnalysisSuite` as the durable regression layer for future analysis intelligence. The suite records compact, license-safe hard cases with:

- category and motif taxonomy;
- source FEN, compact PGN, parsed position, or synthetic safety input;
- explicit safety flags;
- expected scheduler/deep-gating behavior;
- broad evidence expectations such as reason codes, MultiPV minimums, budget pressure, and suppression reasons.

Runner modes:

- `metadataOnly` validates IDs, sources, motifs, safety flags, and blocked product claims.
- `planOnly` runs the pure deep-gating policy without real engine calls.
- `fakeEvidence` supplies deterministic fast-pass evidence to test reason-code behavior without requiring Stockfish.

The initial cases cover quiet opening skip, invalid FEN safety, forced move skip, tactical capture/check, material sacrifice compensation, mate-threat evidence, quiet preparatory uncertainty, technical endgame conservatism, budget pressure, and queen-win material swing.

Golden suite documentation: [GOLDEN_ANALYSIS_SUITE.md](GOLDEN_ANALYSIS_SUITE.md).

Phase 30P still does not implement:

- final move labels;
- Brilliant, Great, Miss, or similar classifier output;
- official accuracy or ACPL;
- replacement product review results;
- persistence, cache, or database writes;
- backend/server calls;
- UI activation;
- parallel engine execution.

## Phase 30Q Golden Evidence Review

`GoldenEvidenceReviewRunner` adds a developer-only readiness workflow over `GoldenAnalysisSuite`.

It reviews each golden case and returns one of these evidence states:

- passed;
- passed with warnings;
- incomplete evidence;
- needs real-engine evidence;
- behavior mismatch;
- budget mismatch;
- blocked unsafe claim;
- failed.

The review workflow checks:

- metadata and safety flags;
- blocked product claims;
- expected behavior consistency;
- satisfied and missing reason codes;
- expected suppression reasons;
- budget/cap status;
- future real-device proof needs.

The real-device path is reference-only in normal tests. Cases that require future PV or selected-deep proof are listed with opt-in command guidance; no Android collector is executed by default.

Phase 30Q still keeps classifier work blocked. It does not implement final move labels, Brilliant/Great/Miss-style labels, official metrics, UI activation, backend calls, persistence, or direct engine access.

## Phase 30R Golden Evidence Report Command

`dart run tool/golden_evidence_review_report.dart` now prints a deterministic developer-only report over the Golden Evidence Review workflow.

The command supports metadata-only, plan-only, fake-evidence, and real-device-reference-only modes, plus markdown or JSON output. It runs under plain Dart without Android, does not load the real engine, does not call `LocalEvalService`, and does not execute the opt-in Android collector. Strict flags can turn incomplete evidence, real-device-needed evidence, or mismatch/unsafe rows into explicit nonzero exits for local regression gates.

The report makes protected, incomplete, real-device-needed, mismatched, budget-mismatched, and unsafe golden cases visible without product UI. Product labels remain blocked: Phase 30R still does not add final move labels, Brilliant/Great/Miss-style labels, official accuracy, ACPL, persistence, backend work, or product review replacement.

## Phase 30S Tactical Motif Taxonomy And Evidence Model

Phase 30S expands the Golden Analysis Suite with an internal tactical motif taxonomy and a pure `GoldenMotifEvidencePolicy`.

The policy maps motifs to broad evidence groups: material, tactical, king safety, forcing, positional, suppression, uncertainty, budget, and real-device proof. Existing golden cases now carry richer motif metadata and broad evidence expectations, so sacrifice rows require compensation evidence, mate-threat rows require king-safety or mate/forcing evidence, quiet preparatory rows remain visibly incomplete without stronger proof, opening and forced rows expect suppression, invalid rows expect rejection, and budget rows expect budget-suppression visibility.

The Golden Evidence Review report now includes motif group coverage, motif evidence group coverage, cases with motif evidence gaps, and real-device-proof cases in markdown and JSON. This remains developer-only evidence hardening. Phase 30S does not add final move labels, Brilliant/Great/Miss-style labels, official accuracy, ACPL, UI activation, backend calls, persistence, cache/database writes, or product review replacement.

## Phase 30T Golden Evidence Triage And Proof Queue

Phase 30T adds a developer-only Golden Evidence Triage layer over the Golden Evidence Review report data.

The triage model produces deterministic status counts, per-case priorities, motif evidence gaps, weak motif groups, recommended handcrafted hard-case areas, and a smallest owner-run proof queue. The optional `dart run tool/golden_evidence_triage_report.dart` command prints markdown or JSON locally without Android, without real-engine loading, without `LocalEvalService`, and without executing proof commands.

The proof queue recommends only future opt-in owner runs for cases that need real-device selected-deep evidence. Protected cases and fake-evidence-only cases are excluded from that queue.

Classifier work remains blocked. Phase 30T does not add final move labels, Brilliant/Great/Miss-style labels, official accuracy, ACPL, UI activation, backend calls, persistence, cache/database writes, product review replacement, or direct engine access.

## Phase 30U Owner Android Golden Proof Queue

Phase 30U adds an opt-in owner-run Android proof queue for Golden Evidence Triage targets.

The collector uses the current triage proof queue by default, runs only those selected golden cases through `LocalReviewIntegrationExperiment` in selected-deep mode, and renders safe markdown/JSON proof output. It stays behind the existing local stack and does not call Stockfish, FFI, native bridge code, or `LocalEvalService` directly from the proof model.

Default scope remains conservative: `balancedDefault`, max three targets, finite engine-call and elapsed-time caps, no performance run unless explicitly enabled. Unsupported mappings, missing PV, insufficient MultiPV, budget pressure, timeouts, failures, and stub identity are surfaced instead of hidden.

Opt-in command:

```powershell
flutter test integration_test/golden_owner_android_proof_queue_test.dart -d <android-device-id> --dart-define=APEX_RUN_GOLDEN_OWNER_ANDROID_PROOF_QUEUE=true
```

Optional performance run:

```powershell
flutter test integration_test/golden_owner_android_proof_queue_test.dart -d <android-device-id> --dart-define=APEX_RUN_GOLDEN_OWNER_ANDROID_PROOF_QUEUE=true --dart-define=APEX_RUN_GOLDEN_OWNER_ANDROID_PROOF_QUEUE_PERFORMANCE=true
```

Without the opt-in flag, the integration test skips and does not start the engine. Phase 30U remains developer-only evidence collection and still does not add final move labels, Brilliant/Great/Miss-style labels, official accuracy, ACPL, UI activation, backend calls, persistence, cache/database writes, product review replacement, or classifier threshold changes.

## Phase 30V Golden Proof Evidence Ingestion

Phase 30V consumes the owner-run Phase 30U S22 Ultra proof output as static developer evidence.

The ingested proof records:

- balanced-default selected-deep proof for `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`;
- performance-measured selected-deep proof for the same three cases;
- Android / `arm64-v8a` execution through the existing local stack;
- engine identity `apex-stockfish-bridge/0.3.0`;
- stub identity detected: false;
- zero timeouts, zero failures, zero budget-pressure rows, zero missing-PV rows, and zero insufficient-MultiPV rows.

The Golden Evidence Review and Triage layers now use that static proof to clear real-device-needed status only for the three owner-proven case IDs. The default proof queue is empty after ingestion, while quiet preparatory uncertainty and weak motif-group recommendations remain visible.

Classifier work remains blocked. Phase 30V does not add final move labels, Brilliant/Great/Miss-style labels, official accuracy, ACPL, UI activation, backend calls, persistence, cache/database writes, product review replacement, or classifier threshold changes.

## Phase 30W Recommendation

Phase 30W adds five compact handcrafted golden cases for weak motif coverage: king-safety/mating-net pressure, quiet preparatory uncertainty, sacrifice compensation, endgame precision, and forcing-line variation.

The post-30W Golden Evidence Review state is 15 total cases, 13 protected, 2 incomplete, and 0 real-device-needed rows. The owner proof queue remains empty because no new row requests PV or MultiPV proof. Quiet preparatory uncertainty remains visible rather than over-promoted.

Classifier work remains blocked. Phase 30W does not add final move labels, Brilliant/Great/Miss-style labels, official accuracy, ACPL, UI activation, backend calls, persistence, cache/database writes, product review replacement, direct engine access, or classifier threshold changes.

## Phase 30X Recommendation

Phase 30X should decide whether to add deterministic fake evidence for the two quiet preparatory incomplete rows or queue a narrowly scoped owner proof only if a future quiet case explicitly requires PV/MultiPV evidence.

## Phase 30X Evidence-To-Classifier Readiness Gate

Phase 30X adds a readiness gate only. `GoldenClassifierReadinessGate` sits above Golden Evidence Review, Golden Evidence Triage, and the static Android proof evidence to decide whether any future classifier foundation can be planned.

The gate does not run Android, load real Stockfish, call `LocalEvalService`, change scheduler thresholds, replace product review output, add UI, add persistence, or emit move labels. It reports scope readiness and blockers in markdown/JSON through:

```powershell
dart run tool/golden_classifier_readiness_report.dart
```

Current post-30W decision:

- product-facing labels remain blocked;
- advanced candidate gates remain blocked;
- quiet/preparatory foundation remains blocked by `quiet-preparatory-uncertain` and `quiet-preparatory-hard-case`;
- basic classifier foundation is allowed only as developer-only design/prototype that emits no labels and excludes incomplete quiet-preparatory motifs;
- tactical, material, forcing-line, and king-safety evidence is stronger than quiet evidence but still not product-label readiness.

The next recommended phase is `Phase 30Y -- Quiet Preparatory Evidence Resolution` unless future evidence changes the blocker ordering.

## Phase 30Y Quiet Preparatory Evidence Resolution

Phase 30Y resolves the quiet/preparatory evidence gap with a pure `QuietPreparatoryEvidence` model and policy. It distinguishes unsupported quiet moves, intentionally incomplete quiet evidence, deterministic broad support, explicit PV/MultiPV proof needs, protected quiet evidence, and quiet evidence mismatches.

Current post-30Y state:

- total golden cases: 15;
- protected cases: 14;
- incomplete cases: 1 (`quiet-preparatory-uncertain`);
- real-device-needed cases: 0;
- owner Android proof queue: empty;
- `quiet-preparatory-hard-case` is protected by broad deterministic support groups;
- `quiet-preparatory-uncertain` remains visible and unresolved.

Classifier output remains blocked. Basic classifier foundation can only remain developer-only design/prototype work, product-facing labels remain blocked, advanced candidate gates remain blocked, and quiet/preparatory scope remains blocked until the unresolved quiet uncertainty is either supported or intentionally excluded by a later gate.

## Phase 30Z Quiet Preparatory Negative Guard

Phase 30Z makes the remaining quiet/preparatory uncertainty explicit instead of forcing protection. `quiet-preparatory-uncertain` is now an intentional negative guard: it proves unsupported quiet moves must remain excluded from future classifier scopes unless stronger evidence is added later.

Current post-30Z state:

- total golden cases: 15;
- protected cases: 14;
- negative guard cases: 1 (`quiet-preparatory-uncertain`);
- incomplete cases: 0;
- real-device-needed cases: 0;
- owner Android proof queue: empty;
- `quiet-preparatory-hard-case` remains protected by broad deterministic support groups;
- `quiet-preparatory-uncertain` is visible, not protected, not failed, and not queued for Android proof.

This remains readiness and evidence work only. Product-facing labels and advanced candidate gates stay blocked. Basic developer-only classifier design may proceed later only with quiet/preparatory scope excluded, and reports must keep that exclusion visible.

## Phase 31A Basic Classifier Foundation Design

Phase 31A adds a pure `BasicClassifierFoundationDesign` model and report command. It is design/prototype infrastructure only. It consumes the current golden suite, evidence review, triage, Android proof evidence, and classifier-readiness gate to describe future classifier inputs without adding classifier output.

Allowed scopes are limited to developer-only non-quiet evidence design: non-quiet basic evidence, tactical evidence, material swing evidence, forcing-line evidence, king-safety evidence, conservative endgame evidence, and safety/suppression evidence. These scopes can list supporting golden case IDs and required future input fields, but they do not create move labels.

Blocked scopes remain quiet/preparatory classification, product-facing labels, advanced candidate gates, officialAccuracy, and officialAcpl. `quiet-preparatory-uncertain` remains the negative guard that excludes quiet/preparatory classification, while `quiet-preparatory-hard-case` remains protected evidence only.

No scheduler integration is added in Phase 31A. The local engine stack, selected-deep scheduler, product review flow, saved analysis, UI, backend, persistence, and real-device proof collector are unchanged. Normal tests still do not require real Stockfish or Android.

## Phase 31B Evidence Contract Prototype

Phase 31B adds a pure `BasicClassifierEvidenceContract` prototype and report command. It consumes the Phase 31A foundation design and golden evidence review data to describe developer-only evidence fields, group readiness, support mapping, blocked future fields, and the quiet/preparatory exclusion.

No scheduler or product integration is added in Phase 31B. The local engine stack, selected-deep scheduler, product review flow, saved analysis, UI, backend, persistence, and Android proof collector are unchanged. The contract does not compute CP loss, win probability, official metrics, or move labels. Quiet/preparatory classification remains excluded by `quiet-preparatory-uncertain`; non-quiet evidence groups may proceed only toward internal non-label bucket design.

## Phase 31C Internal Non-Label Evidence Buckets

Phase 31C adds a pure `InternalEvidenceBucketPrototype` model and report command. It consumes the Phase 31B evidence contract to group current developer-only evidence into internal buckets such as tactical support, material swing support, forcing-line support, king-safety support, conservative endgame support, suppression support, Android-proof backing, candidate spread, and PV/MultiPV support.

No scheduler or product integration is added in Phase 31C. The local engine stack, selected-deep scheduler, product review flow, saved analysis, UI, backend, persistence, and Android proof collector are unchanged. Buckets are not move labels. Product output remains blocked, official metrics remain blocked, CP-loss and win-probability computation remain unimplemented, and quiet/preparatory classification remains excluded by `quiet-preparatory-uncertain`.

## Phase 31D Internal Bucket Experiment Guards

Phase 31D adds a pure `InternalBucketExperimentGuard` model and report command. It protects future internal bucket experiments from requesting product labels, advanced labels, official metrics, CP-loss or win-probability computation, quiet/preparatory scope, unproven Android proof claims, direct engine access, UI/backend output, or persistence.

No scheduler or product integration is added in Phase 31D. The local engine stack, selected-deep scheduler, product review flow, saved analysis, UI, backend, persistence, and Android proof collector are unchanged. Safe experiments may only use supported non-quiet buckets as developer-only evidence references.

## Phase 31E Internal Non-Label Bucket Experiment Harness

Phase 31E adds a pure `InternalBucketExperimentHarness` model and report command. It runs only after the Phase 31D guard approves the request, then observes approved supported non-quiet internal buckets, supporting golden case IDs, partial-bucket warnings, blocked/excluded areas, and proven Android proof references.

No scheduler or product integration is added in Phase 31E. The local engine stack, selected-deep scheduler, product review flow, saved analysis, UI, backend, persistence, and Android proof collector are unchanged. The harness does not classify moves, score moves, compute official metrics, compute CP loss, compute win probability, call the engine, run Android, or emit product-facing labels. Quiet/preparatory scope remains excluded by `quiet-preparatory-uncertain`.

## Phase 31F Internal Evidence Area Coverage Matrix

Phase 31F adds a pure `InternalEvidenceAreaCoverageMatrix` model and report command. It consumes approved Phase 31E harness output and summarizes evidence coverage by internal area: strong, adequate, partial, excluded, blocked, or future-only.

No scheduler or product integration is added in Phase 31F. The local engine stack, selected-deep scheduler, product review flow, saved analysis, UI, backend, persistence, and Android proof collector are unchanged. The matrix does not classify moves, score moves, compute official metrics, compute CP loss, compute win probability, call the engine, run Android, or emit product-facing labels. Quiet/preparatory scope remains excluded by `quiet-preparatory-uncertain`.

## Phase 31G Internal Non-Label Coverage-Informed Scoring Design

Phase 31G adds a pure `InternalNonLabelScoringDesign` model and report command. It consumes the Phase 31F coverage matrix and turns area coverage into developer-only design dimensions with qualitative signal types and future prerequisites.

No scheduler or product integration is added in Phase 31G. The local engine stack, selected-deep scheduler, product review flow, saved analysis, UI, backend, persistence, and Android proof collector are unchanged. The design layer does not classify moves, compute scores, add numeric weights, create thresholds, compute official metrics, compute CP loss, compute win probability, call the engine, run Android, or emit product-facing labels. Quiet/preparatory scope remains excluded by `quiet-preparatory-uncertain`.

## Phase 31H Guarded Internal Non-Label Signal Profile

Phase 31H adds a pure `InternalNonLabelSignalProfilePrototype` model and report command. It consumes the Phase 31G scoring design and turns internal design dimensions into qualitative developer-only signal profiles with confidence values, support case IDs, Android proof references, warning-only signals, blocked signals, excluded signals, and future prerequisites.

No scheduler or product integration is added in Phase 31H. The local engine stack, selected-deep scheduler, product review flow, saved analysis, UI, backend, persistence, and Android proof collector are unchanged. The signal profile does not classify moves, compute numeric scores, rank moves, create thresholds, compute official metrics, compute CP loss, compute win probability, call the engine, run Android, or emit product-facing labels. Quiet/preparatory scope remains excluded by `quiet-preparatory-uncertain`.

## Phase 31I Internal Signal Profile Consistency Matrix

Phase 31I adds a pure `InternalSignalProfileConsistencyMatrix` model and report command. It consumes the Phase 31H signal profile and verifies that active signals keep source dimensions, evidence areas, bucket mappings, Golden support cases, valid Android proof references, and explicit warning or future-prerequisite context where needed.

No scheduler or product integration is added in Phase 31I. The local engine stack, selected-deep scheduler, product review flow, saved analysis, UI, backend, persistence, and Android proof collector are unchanged. The consistency matrix does not classify moves, compute numeric or aggregate scores, rank moves, create thresholds, compute official metrics, compute CP loss, compute win probability, call the engine, run Android, or emit product-facing labels. Quiet/preparatory scope remains excluded by `quiet-preparatory-uncertain`.

## Phase 31J Guarded Internal Signal Experiment Runner

Phase 31J adds a pure `InternalSignalExperimentRunner` model and report command. It consumes the Phase 31I consistency matrix and Phase 31H signal profile, then runs only when the consistency gate has zero blockers, zero criticals, and is marked safe for guarded internal experiments.

No scheduler or product integration is added in Phase 31J. The local engine stack, selected-deep scheduler, product review flow, saved analysis, UI, backend, persistence, and Android proof collector are unchanged. The runner produces internal signal observations only: active signals are visible, warning and partial signals remain warnings, and blocked/excluded/future-only paths stay inactive. It does not classify moves, compute numeric or aggregate scores, rank moves, create thresholds, compute official metrics, compute CP loss, compute win probability, call the engine, run Android, or emit product-facing labels. Quiet/preparatory scope remains excluded by `quiet-preparatory-uncertain`.

## Phase 31K Internal Signal Observation Review Matrix

Phase 31K adds a pure `InternalSignalObservationReviewMatrix` model and report command. It consumes Phase 31J runner observations and reviews them for stability, Golden support, Android proof validity, warning safety, and blocked/excluded/future-only policy correctness.

No scheduler or product integration is added in Phase 31K. The local engine stack, selected-deep scheduler, product review flow, saved analysis, UI, backend, persistence, and Android proof collector are unchanged. The review matrix does not classify moves, compute numeric or aggregate scores, rank moves, create thresholds, compute official metrics, compute CP loss, compute win probability, call the engine, run Android, or emit product-facing labels. Quiet/preparatory scope remains excluded by `quiet-preparatory-uncertain`.
