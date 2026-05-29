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

Phase 30S expands the internal taxonomy into motif groups:

- material and sacrifice: `sacrifice`, `temporarySacrifice`, `exchangeSacrifice`, `pieceSacrifice`, `materialCompensation`, `queenWin`, `rookWin`, `pieceWin`, and `pawnBreakthrough`;
- king safety and mate: `mateThreat`, `forcedMate`, `backRankWeakness`, `exposedKing`, `kingHunt`, and `matingNet`;
- forcing and tactical: `forcingLine`, `checkSequence`, `zwischenzug`, `fork`, `pin`, `skewer`, `discoveredAttack`, `deflection`, `decoy`, `overload`, `trappedPiece`, `clearance`, `interference`, `removeDefender`, and existing promotion tactics;
- positional and quiet: `quietMove`, `quietPreparatoryMove`, `prophylaxis`, `restriction`, `outpost`, `openFile`, `passedPawn`, and `endgamePrecision`;
- safety and control: `onlyMove`, `openingTheory`, `invalidSafety`, `budgetPressure`, `evidenceIncomplete`, and `realDeviceProofNeeded`.

These tags are internal evidence taxonomy. They are not product labels and must not be shown as final move quality.

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

Phase 30S adds broad motif evidence expectations for future-proofing:

- boolean requirements such as material swing, material compensation, mate signal, forcing-line signal, king-safety signal, only-move signal, quiet-move evidence, candidate spread, MultiPV evidence, non-empty PV proof, budget pressure, suppression reason, and real-device proof;
- structured reason groups: tactical, material, king safety, forcing, positional, suppression, and uncertainty;
- declared evidence groups for cases that should be visible in coverage even when pure tests intentionally avoid engine proof.

Exact centipawn assertions remain optional and should not be the default.

## Motif-To-Evidence Policy

`GoldenMotifEvidencePolicy` maps motif tags to expected evidence groups without running an engine.

Examples:

- sacrifice motifs require material, tactical, and compensation evidence;
- mate-threat motifs require mate, king-safety, and forcing evidence;
- quiet preparatory moves do not force deep certainty without supporting evidence;
- opening theory expects suppression or skip visibility, not deep work;
- invalid safety expects rejection before engine work;
- budget pressure expects budget-suppression visibility;
- real-device-proof motifs mark future opt-in proof needs.

The review runner uses this policy to mark missing motif-required evidence as `incompleteEvidence`. It does not fake evidence. Hard contradictions, unsafe claims, budget mismatches, and behavior mismatches keep their existing statuses.

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

## Golden Evidence Report Command

Phase 30R adds a developer-only report command:

```powershell
dart run tool/golden_evidence_review_report.dart
```

The command runs locally without Android, does not load the real engine, does not call `LocalEvalService`, does not read network, and does not write files by default. It prints deterministic output and exits `0` for completed reports unless an explicit strict flag is supplied.

Supported review modes:

- `--mode=metadataOnly`: validates golden case safety and structure.
- `--mode=planOnly`: runs pure deep-gating plans without supplied fake evidence or engine execution.
- `--mode=fakeEvidence`: default mode; reviews deterministic supplied evidence without real engine work.
- `--mode=realDeviceEvidenceReferenceOnly`: lists cases that need future opt-in real-device proof and prints safe command guidance only.

Supported formats:

- `--format=markdown`: default; prints summary counts, category coverage, motif coverage, motif group coverage, motif evidence group coverage, per-case table, evidence gaps, real-device-needed cases, and next recommended action.
- `--format=json`: prints the same report data in stable structured form, including motif evidence group coverage and cases with motif evidence gaps.

Strict flags:

- `--fail-on-incomplete`: exits nonzero when incomplete evidence exists.
- `--fail-on-real-device-needed`: exits nonzero when future real-device proof is needed.
- `--fail-on-mismatch`: exits nonzero when behavior mismatch, budget mismatch, blocked unsafe claim, or failure rows exist.

Exit code policy:

- `0`: report generated successfully and no strict failure was triggered.
- `64`: bad command usage, unknown flag, unknown mode, or unknown format.
- `65`: strict incomplete-evidence failure.
- `66`: strict real-device-needed failure.
- `67`: strict mismatch, unsafe-claim, or failure row.

Real-device reference mode does not run Android. It prints this safe opt-in guidance for a future owner run:

```powershell
flutter test integration_test/local_review_pgn_fixture_device_smoke_test.dart -d <android-device-id> --dart-define=APEX_RUN_LOCAL_REVIEW_PGN_FIXTURE_DEVICE_SMOKE=true
```

The report intentionally excludes raw UCI logs, long PV dumps, final move labels, official accuracy, ACPL, backend URLs, and secrets. It is not classifier work. Golden cases remain regression inputs and evidence expectations, not product claims.

Phase 30S makes evidence gaps more visible, especially quiet preparatory uncertainty and real-device proof needs. This prepares future classifier work by requiring structured chess evidence first; it does not implement classifier output.

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
