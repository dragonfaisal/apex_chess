# Golden Analysis Suite

## Purpose

Golden Analysis Suite v1 is Apex's durable quality-memory layer for local analysis behavior.

It records hard chess-analysis cases as named, license-safe regression inputs with explicit scheduler and deep-gating expectations. The suite is not a product classifier and does not claim final move quality.

The goal is to prevent patching by anecdote:

- every hard case gets a stable ID;
- every expected behavior is explicit;
- every future analysis fix can become a permanent regression case;
- no single-position workaround is accepted unless it improves the general suite.

## Case Schema

Each `GoldenAnalysisCase` includes:

- `id` and `title`;
- category, such as tactical shot, material sacrifice, queen trap, forced mate threat, opening skip, forced move skip, invalid safety, or budget pressure;
- source type, currently FEN position, compact PGN, parsed position, or synthetic safety case;
- source text, such as FEN or compact PGN;
- scheduler-ready `LocalAnalysisPositionInput` records;
- motif tags;
- safety flags for license-safe, handcrafted, external comparison pending, and no final label;
- expected behavior;
- optional fake fast-pass evidence for pure tests.

The suite intentionally prefers compact handcrafted FENs and short test-safe positions. It does not import third-party datasets.

## Motif Taxonomy

Golden motif tags are taxonomy only. They do not produce user-facing labels.

Current motifs include:

- sacrifice;
- material compensation;
- queen win;
- mate threat;
- forcing line;
- only move;
- quiet move;
- zwischenzug;
- fork;
- pin;
- skewer;
- discovered attack;
- deflection;
- decoy;
- overload;
- promotion;
- endgame precision;
- opening theory;
- invalid safety;
- budget pressure.

## Expected Behavior Model

Golden expected behavior describes what the local engine stack should do, not what a user-facing move label should be.

Examples:

- reject invalid FEN before engine work;
- skip opening-known positions;
- skip forced positions when an explicit hint is supplied;
- generate a deep candidate for tactical or material-swing evidence;
- select deep under balanced or performance only when budget allows;
- avoid deep work for quiet opening cases;
- request MultiPV at least 2 for selected critical cases;
- stay within profile budgets;
- surface budget pressure;
- never emit final move labels.

## Evidence Model

Evidence expectations are intentionally broad in v1. They check reason codes and safety signals rather than brittle exact centipawn values.

Supported evidence expectations include:

- minimum eval swing range;
- minimum candidate spread range;
- material swing range;
- mate score expected or not expected;
- PV should be non-empty when a future real-engine proof mode runs;
- minimum MultiPV when selected;
- expected reason codes such as tactical signal, material swing, mate score detected, candidate eval spread, gives check, capture or promotion, and major eval swing;
- expected suppression reasons such as opening suppressed, forced suppressed, invalid FEN suppressed, or budget suppressed.

## Runner Modes

`GoldenAnalysisSuiteRunner` supports:

- `metadataOnly`: validates IDs, sources, motifs, safety flags, blocked labels/metrics, and broad schema consistency.
- `planOnly`: runs cases through the pure deep-gating policy without real engine execution.
- `fakeEvidence`: uses supplied fast-pass evidence to verify reason-code and mate-evidence expectations without requiring Stockfish.

Normal tests do not require Android or a host Stockfish bridge.

## Golden Evidence Review Workflow

`GoldenEvidenceReviewRunner` is the developer-only review layer above the golden suite. It decides whether each golden case has enough evidence to protect future analysis work.

Review modes:

- `metadataOnly`: validates case safety and structure only.
- `planOnly`: checks pure deep-gating behavior without supplied fast-pass evidence.
- `fakeEvidence`: checks deterministic supplied evidence and reason codes without real engine execution.
- `realDeviceEvidenceReferenceOnly`: identifies cases that need future opt-in real-device selected-deep proof and prints command guidance, but does not run Android.

Per-case readiness statuses:

- `passed`: case is protected for the requested review mode.
- `passedWithWarnings`: case is usable but warnings remain visible.
- `incompleteEvidence`: the case needs fake evidence or clearer expectations before it can protect future work.
- `needsRealEngineEvidence`: the case needs opt-in real-device proof, usually for PV or selected-deep evidence that pure tests should not fake.
- `behaviorMismatch`: the expected scheduler/deep-gating behavior does not match current behavior.
- `budgetMismatch`: a cap, ratio, or budget-pressure expectation is violated.
- `blockedUnsafeClaim`: the case encodes an unsafe product claim or is not explicitly safe.
- `failed`: structural or expectation failures need correction.

Incomplete is different from failed:

- Incomplete means the case may be valid, but the current evidence is not strong enough yet.
- Failed means the case, expectation, or current behavior is wrong for the requested mode.

Real-device evidence is needed when a case expects PV content or other selected-deep evidence that must come from the Android local engine path. Normal tests only identify these cases and keep them out of mandatory real-engine execution.

The workflow protects future classifier work by forcing each hard case to say one of:

- this case is protected;
- this case needs fake evidence;
- this case needs real-device proof;
- this expectation is unsafe or mismatched.

## Initial V1 Cases

The initial suite includes compact cases for:

- quiet opening skip;
- invalid FEN safety;
- forced move skip;
- simple tactical capture/check;
- material sacrifice compensation;
- mate-threat evidence;
- quiet preparatory uncertainty;
- technical endgame conservatism;
- budget pressure;
- queen-win major swing.

The cases are framework guards and evidence expectations, not final chess judgments.

## Adding New Hard Cases

When adding a case:

1. Use a stable descriptive ID.
2. Keep the source compact and license-safe.
3. Prefer handcrafted FENs or existing repo-owned compact fixtures.
4. Add motif tags and expected behavior.
5. Prefer broad reason-code expectations over exact centipawn assertions.
6. Do not encode Brilliant, Great, Miss, official accuracy, ACPL, or product-facing labels.
7. If the case needs real-engine PV evidence, mark it as future real-engine proof instead of forcing normal tests to load Stockfish.

## What V1 Does Not Claim

Golden Analysis Suite v1 does not:

- classify moves;
- compute official accuracy or ACPL;
- replace product review output;
- prove all chess motifs are covered;
- assert exact engine scores;
- run Android real-engine checks in normal tests;
- store user data.

## Future Classifier Support

Future classifier work must use the golden suite as a regression gate. A classifier may only claim behavior that survives these named cases without breaking older cases, and new hard examples should be added to the suite before thresholds are tuned.
