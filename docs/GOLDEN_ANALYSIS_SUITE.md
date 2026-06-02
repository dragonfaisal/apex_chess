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

Quiet/preparatory rows also carry a narrower quiet-evidence policy after Phase 30Y. A quiet tag alone is never enough to protect a case and never forces deep analysis. The quiet evidence model asks for broad support groups such as candidate spread plus a future tactical threat, opponent-threat reduction plus positional or king-safety signal, a forcing line enabled next, PV/MultiPV proof when explicitly required, or clear alternative-move weakness. When a quiet case explicitly requires PV/MultiPV proof, normal tests mark it as needing future real-engine evidence instead of treating fake evidence as equivalent to device proof.

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

## Golden Evidence Triage

Phase 30T adds a developer-only triage layer over Golden Evidence Review.

The triage result answers what needs attention next:

- cases already protected by the current evidence model;
- cases with incomplete fake or structured evidence;
- cases needing future opt-in owner Android proof;
- cases with motif evidence gaps;
- weak and strong motif groups;
- recommended handcrafted hard-case areas;
- the smallest deterministic owner-run proof queue.

Per-case triage entries keep the case ID, category, internal motifs, current review status, missing evidence groups, missing reason codes, missing suppression reasons, real-device-proof need, priority, next action, and rationale.

Priorities are developer workflow priorities only:

- `none`: already protected for the current evidence workflow.
- `low`: visible but not blocking stronger evidence work.
- `medium`: needs attention, commonly quiet preparatory uncertainty or thin motif coverage.
- `high`: needs proof or investigation before it can protect important future behavior.
- `critical`: unsafe claims or hard blockers that must not be normalized.

Recommended actions are also internal workflow actions:

- `keepProtected`: no immediate work needed.
- `addFakeEvidence`: add deterministic broad evidence or reason coverage.
- `addHandcraftedCase`: add a compact license-safe hard case when the motif group is thin.
- `runOwnerAndroidProof`: use opt-in Android proof for selected-deep evidence that pure tests must not fake.
- `adjustExpectation`: correct contradictory expectations.
- `investigateMismatch`: inspect behavior or budget mismatch.
- `blockUnsafeClaim`: remove or quarantine unsafe product-claim content.

The owner proof queue excludes protected cases and fake-evidence-only cases. It orders targets by priority and case ID, limits the target count, and prints safe command guidance only. It does not run Android or load the real engine.

Weak motif group recommendations are deterministic prompts for future handcrafted coverage, such as sacrifice compensation, quiet preparatory evidence, king-safety and mating-net proof, forcing-line proof, and endgame precision proof. Phase 30T does not add a large case set; it decides where new cases would matter.

The optional report command is:

```powershell
dart run tool/golden_evidence_triage_report.dart
```

Supported flags:

- `--format=markdown`: default summary report with counts, evidence gaps, proof queue, weak motif groups, and next actions.
- `--format=json`: stable structured report with the same triage data.
- `--max-proof-targets=<n>`: caps owner-proof recommendations.
- `--include-protected`: includes protected cases in the detailed table.

The triage report excludes raw UCI logs, long PV dumps, final move labels, official accuracy, ACPL, backend URLs, and secrets. It remains developer-only evidence planning. Motifs are internal taxonomy, not product labels, and golden cases remain regression inputs rather than product claims.

## Owner Android Proof Queue

Phase 30U adds an opt-in owner-run Android proof collector for the current Golden Evidence Triage proof queue.

The collector selects proof targets from `GoldenEvidenceTriageRunner` by default. With the current suite, that means the smallest high-priority queue:

- `mate-threat-fast-evidence`;
- `queen-win-major-swing`;
- `simple-tactical-capture-check`.

The collector runs only selected proof targets through the existing local stack:

- `LocalReviewIntegrationExperiment`;
- `GameLevelDeepGatingExperiment`;
- `LocalReviewOrchestrationExperiment`;
- `MeasuredLocalReviewPrototype`;
- `LocalSmartAnalysisExecutor`;
- `LocalEvalService`.

It does not call Stockfish, FFI, or native bridge code directly. It does not update golden cases automatically.

Opt-in owner command:

```powershell
flutter test integration_test/golden_owner_android_proof_queue_test.dart -d <android-device-id> --dart-define=APEX_RUN_GOLDEN_OWNER_ANDROID_PROOF_QUEUE=true
```

Optional performance proof:

```powershell
flutter test integration_test/golden_owner_android_proof_queue_test.dart -d <android-device-id> --dart-define=APEX_RUN_GOLDEN_OWNER_ANDROID_PROOF_QUEUE=true --dart-define=APEX_RUN_GOLDEN_OWNER_ANDROID_PROOF_QUEUE_PERFORMANCE=true
```

Without the opt-in flag, the integration test skips safely and does not start the local engine. Normal tests use fake engine execution only.

Per-case proof statuses:

- `proofCaptured`: selected-deep evidence was captured for the case.
- `proofCapturedWithWarnings`: proof exists, but warnings such as budget pressure remain visible.
- `proofIncomplete`: selected-deep, PV, or MultiPV evidence is still missing or insufficient.
- `proofFailed`: local stack execution failed or guardrails rejected the result.
- `proofSkipped`: the target was not mappable or a cap prevented execution.

Recommended next actions are internal workflow actions only: update golden evidence, rerun with performance, add fake evidence, investigate engine result, or keep queued.

The proof report renders safe JSON and markdown with target counts, selected/executed deep counts, PV and MultiPV presence, engine-call counts, elapsed time, warnings, failures, and owner command guidance. It intentionally excludes raw UCI logs, long PV dumps, final move labels, official accuracy, ACPL, backend URLs, and secrets.

Captured proof is evidence for a later pure documentation or golden-evidence update. Phase 30U does not mark a case protected unless the owner-run output actually supports that update, and it does not create product labels.

## Owner Android Proof Ingestion

Phase 30V ingests the owner-run Phase 30U proof queue as static developer evidence.

Proof source:

- source ID: `s22-ultra-phase-30u-owner-queue`;
- device: S22 Ultra / `SM S908U1`;
- platform: Android;
- ABI: `arm64-v8a`;
- engine identity: `apex-stockfish-bridge/0.3.0`;
- stub identity detected: false;
- source note: owner-run Android proof, developer evidence only.

Captured balanced-default facts:

- status: `completedWithWarnings`;
- target cases: 3;
- executed targets: 3;
- selected deep: 3;
- executed deep: 3;
- fast engine calls: 3;
- deep engine calls: 6;
- total engine calls: 9;
- elapsed ms: 1672;
- timeouts: 0;
- failures: 0;
- budget pressure: 0;
- missing PV rows: 0;
- insufficient MultiPV rows: 0.

Captured performance-measured facts:

- status: `completedWithWarnings`;
- target cases: 3;
- executed targets: 3;
- selected deep: 6;
- executed deep: 6;
- fast engine calls: 6;
- deep engine calls: 12;
- total engine calls: 18;
- elapsed ms: 4505;
- timeouts: 0;
- failures: 0;
- budget pressure: 0;
- missing PV rows: 0;
- insufficient MultiPV rows: 0.

Android-proof-backed cases:

- `mate-threat-fast-evidence`: selected deep and executed deep both 1, PV present, MultiPV line count 3, reason-code evidence for candidate spread, check, and tactical signal;
- `queen-win-major-swing`: selected deep and executed deep both 1, PV present, MultiPV line count 3, reason-code evidence for capture or promotion, major eval swing, material swing, and previous eval availability;
- `simple-tactical-capture-check`: selected deep and executed deep both 1, PV present, MultiPV line count 3, reason-code evidence for candidate spread, capture or promotion, check, and tactical signal.

The proof evidence is stored as compact model data and a deterministic fixture. It does not store raw UCI logs, long PV lines, final move labels, official accuracy, ACPL, backend URLs, secrets, or product claims.

After ingestion:

- the three owner-proven cases satisfy their real-device proof requirement;
- `realDeviceEvidenceReferenceOnly` no longer lists those case IDs as needing future proof;
- the triage proof queue is empty unless a future unproven case is added;
- quiet preparatory uncertainty remains incomplete and visible;
- weak motif-group recommendations remain visible, especially king-safety and mating-net coverage.

Phase 30V does not update product review output and does not add labels. Golden cases remain regression inputs and evidence records only.

## Handcrafted Hard Cases Expansion

Phase 30W adds the smallest next handcrafted case set for weak motif coverage. The new rows are compact, license-safe regression inputs only:

- `king-safety-mating-net-hard-case`: exposed-king, mating-net, king-hunt, mate-threat, and forcing-line evidence without claiming a forced mate;
- `quiet-preparatory-hard-case`: quiet preparatory uncertainty that stayed incomplete until stronger supporting evidence was supplied in Phase 30Y;
- `sacrifice-compensation-hard-case`: sacrifice and exchange-sacrifice compensation requiring material and tactical evidence;
- `endgame-precision-hard-case`: conservative endgame-precision coverage without exact score assertions;
- `forcing-line-variation-hard-case`: forcing-line/check-sequence variation with tactical reason-code coverage.

Post-30W review state:

- total golden cases: 15;
- protected cases: 13;
- incomplete cases: 2 (`quiet-preparatory-uncertain` and `quiet-preparatory-hard-case`);
- real-device-needed cases: 0;
- owner proof queue: empty.

The Phase 30U/30V S22 Ultra proof remains attached only to:

- `mate-threat-fast-evidence`;
- `queen-win-major-swing`;
- `simple-tactical-capture-check`.

The new hard cases are not product claims. They do not add final labels, official metrics, UI activation, persistence, backend behavior, or classifier thresholds. Any row without enough evidence remains incomplete instead of being treated as protected. Future real-device proof should only be queued for cases that explicitly need PV or MultiPV proof.

## Evidence-To-Classifier Readiness Gate

Phase 30X adds `GoldenClassifierReadinessGate`, a deterministic developer-only gate over the existing golden evidence stack. It consumes the Golden Analysis Suite cases, Golden Evidence Review results, Golden Evidence Triage results, and the static S22 Ultra Android proof evidence. It does not classify moves and does not call Stockfish, FFI, native bridge code, or `LocalEvalService`.

Readiness statuses are deliberately conservative:

- `blockedByUnsafeClaim`: unsafe source metadata or product-claim content blocks all classifier planning;
- `blockedByMismatch`: behavior, budget, or structural mismatches must be investigated first;
- `blockedByRealDeviceProof`: real-device proof is still needed or the owner proof queue is non-empty;
- `blockedByIncompleteEvidence`: evidence gaps affect the requested scope;
- `readyForEvidenceOnly`: evidence can be reported but not used for classifier foundation;
- `readyForBasicClassifierFoundation`: basic developer-only foundation could proceed with no open blockers;
- `readyForLimitedClassifierFoundation`: only a narrow developer-only prototype/design scope is allowed;
- `notReadyForAdvancedLabels`: advanced label gates remain blocked.

Scope readiness is tracked per future foundation area:

- `basicMoveQualityFoundation` may be allowed only as developer-only prototype/design, with no product labels and no product review replacement;
- tactical, material-swing, forcing-line, and king-safety foundations are stronger than quiet evidence, but still developer-only and not label-ready;
- `endgamePrecisionFoundation` is design-only because current evidence is conservative;
- `quietPreparatoryFoundation` is blocked while quiet-preparatory evidence is incomplete;
- advanced candidate gates and `productFacingLabels` are blocked by policy.

Scope blockers keep exact case IDs visible. The Phase 30X input decision was:

- total golden cases: 15;
- protected cases: 13;
- incomplete cases: 2 (`quiet-preparatory-uncertain` and `quiet-preparatory-hard-case`);
- real-device-needed cases: 0;
- owner proof queue: empty;
- captured Android proof remains attached only to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`;
- product-facing labels are not ready;
- advanced candidate gates are not ready;
- quiet/preparatory classification is not ready;
- basic classifier foundation may be discussed only as developer-only design/prototype and must exclude incomplete quiet-preparatory motifs.

The deterministic command is:

```powershell
dart run tool/golden_classifier_readiness_report.dart
```

Supported formats are markdown and JSON. `--strict` exits nonzero when readiness remains blocked or an unsafe readiness claim is detected. The report excludes raw UCI logs, long PV dumps, final move labels, official accuracy, ACPL, backend URLs, and secrets.

Phase 30X recommended `Phase 30Y -- Quiet Preparatory Evidence Resolution` while the two quiet-preparatory rows remained incomplete.

## Quiet Preparatory Evidence Resolution

Phase 30Y adds `QuietPreparatoryEvidence` and `GoldenQuietPreparatoryEvidencePolicy`, a pure internal evidence model for quiet/preparatory cases. It does not classify moves, does not add product labels, does not change scheduler thresholds, and does not call Stockfish, FFI, native bridge code, or `LocalEvalService`.

Quiet moves are dangerous to over-promote because they often look plausible without proving that the move improves a future line, reduces an opponent threat, or changes candidate quality. The quiet policy therefore separates:

- `unsupportedQuietMove`: a quiet/preparatory tag has no support and must not pass;
- `incompleteQuietEvidence`: uncertainty remains intentionally visible;
- `fakeEvidenceSupported`: deterministic internal evidence supports a broad regression expectation;
- `needsRealDeviceProof`: PV/MultiPV support is explicitly required and must be queued for future owner proof rather than faked;
- `quietEvidenceProtected`: enough broad support groups exist to protect a developer-only golden regression case;
- `quietEvidenceMismatch`: supplied quiet evidence contradicts the case or fails the no-immediate-capture/check/promotion guard.

Supported quiet cases require at least one strong support group, and protected quiet cases should normally have multiple groups. Current groups include candidate spread plus future tactical threat, threat reduction, king-safety or positional improvement, forcing line enabled next, PV support, MultiPV support, alternative weakness, and passed-pawn/endgame-plan support. These groups are evidence taxonomy only; they are not product-facing move labels.

Phase 30Y resolves the two quiet rows differently:

- `quiet-preparatory-hard-case` is now protected as an internal golden case because it has deterministic broad support: candidate spread plus future tactical threat, key-square control improvement, and a forcing line enabled next.
- `quiet-preparatory-uncertain` remains incomplete by design because it has no quiet support beyond an explicit uncertainty reason.

Current post-30Y decision:

- total golden cases: 15;
- protected cases: 14;
- incomplete cases: 1 (`quiet-preparatory-uncertain`);
- real-device-needed cases: 0;
- owner proof queue: empty;
- captured Android proof remains attached only to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`;
- quiet/preparatory foundation remains blocked while `quiet-preparatory-uncertain` is unresolved;
- basic classifier foundation remains developer-only and must exclude unresolved quiet/preparatory evidence;
- product-facing labels and advanced candidate gates remain blocked.

Reports now include quiet evidence status, support groups, blockers, and the readiness effect in markdown and JSON. They still exclude raw UCI logs, long PV dumps, final move labels, official accuracy, ACPL, backend URLs, and secrets.

## Quiet Negative Guard

Phase 30Z clarifies `quiet-preparatory-uncertain` as an intentional negative guard. Its purpose is to prove that Apex must not trust, promote, or classify a quiet/preparatory move when the evidence is insufficient. The row remains visible, but it is not treated as an ordinary evidence gap that should be fixed by simply adding fake evidence.

The suite now distinguishes four evidence outcomes:

- protected: deterministic evidence is strong enough for a golden regression guard;
- negative guard: intentionally unsupported evidence is preserved to exclude an unsafe scope;
- incomplete: a case still lacks evidence that should be supplied or clarified;
- real-device-needed: PV/MultiPV or selected-deep proof must be queued for future owner Android proof.

Negative guards are valuable because quiet moves can look strategically plausible without showing candidate spread, future tactical pressure, threat reduction, square control, king-safety improvement, or a forcing line enabled next. Keeping an unsupported quiet row as a guard prevents future classifier work from treating quiet style as evidence.

Current post-30Z decision:

- total golden cases: 15;
- protected cases: 14;
- negative guard cases: 1 (`quiet-preparatory-uncertain`);
- incomplete cases: 0;
- real-device-needed cases: 0;
- owner proof queue: empty;
- captured Android proof remains attached only to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`;
- `quiet-preparatory-hard-case` remains protected by broad deterministic support groups;
- quiet/preparatory foundation remains blocked or explicitly excluded by the negative guard;
- basic non-quiet classifier foundation may proceed later only as developer-only design/prototype work with quiet/preparatory scope excluded;
- product-facing labels and advanced candidate gates remain blocked.

Evidence review, triage, and classifier-readiness reports now include negative guard counts, negative guard case IDs, excluded scope information, and the readiness effect. They still do not emit classifier labels, raw UCI logs, long PV dumps, official accuracy, ACPL, backend URLs, or secrets.

## Phase 31A Basic Classifier Foundation Design

Phase 31A adds a developer-only `BasicClassifierFoundationDesign` layer. This is not classifier implementation. It defines the evidence contract, scope support mapping, output policy, and blockers that a future basic classifier would have to respect. It does not classify moves, does not emit move-quality labels, does not compute official metrics, and is not wired into UI, saved analysis, product review output, backend, persistence, or the engine.

Allowed Phase 31A design scopes are non-quiet only:

- `nonQuietBasicEvidenceDesign`;
- `tacticalEvidenceDesign`;
- `materialSwingEvidenceDesign`;
- `forcingLineEvidenceDesign`;
- `kingSafetyEvidenceDesign`;
- `endgameEvidenceDesign`;
- `safetySuppressionEvidenceDesign`.

The design maps each allowed scope to supporting protected golden cases. Tactical, material, forcing-line, king-safety, conservative endgame, and safety/suppression evidence can be studied as developer-only inputs. That support is evidence taxonomy only; it is not a user-facing claim and it does not tune classifier thresholds.

Blocked Phase 31A scopes are:

- `quietPreparatoryEvidenceClassification`;
- `productFacingLabels`;
- `advancedBrilliantGate`;
- `advancedGreatMoveGate`;
- `advancedMissedWinGate`;
- `officialAccuracy`;
- `officialAcpl`.

Quiet/preparatory classification remains excluded by `quiet-preparatory-uncertain`. `quiet-preparatory-hard-case` remains protected evidence, but one supported quiet row is not enough to override the negative guard. Product-facing labels and advanced gates remain blocked regardless of non-quiet evidence strength.

The evidence contract is a checklist, not computation. It records which future inputs are already represented by golden evidence, such as candidate spread, PV/MultiPV proof, material swing, tactical signal, forcing-line signal, king-safety signal, mate signal, opening/forced/invalid-FEN suppression, budget pressure, and negative-guard exclusion. It also records future product inputs that are not implemented in this phase, such as previous eval, played-move eval, best-move eval, centipawn loss, and win probability.

Current post-31A decision:

- foundation status: `readyForLimitedDeveloperPrototype`;
- non-quiet basic evidence design: allowed only for developer-only design/prototype;
- quiet/preparatory classification: excluded;
- product-facing labels: blocked;
- advanced candidate gates: blocked;
- official metrics: blocked;
- evidence contract complete for product: false;
- next recommended phase: `Phase 31B -- Evidence Contract Prototype With Product Labels Blocked`.

The optional command is:

```powershell
dart run tool/basic_classifier_foundation_design_report.dart
```

It renders deterministic markdown or JSON, supports `--strict`, does not run Android, does not load real Stockfish, does not call `LocalEvalService`, does not read network, and does not write files.

## Phase 31B Evidence Contract Prototype

Phase 31B adds a developer-only `BasicClassifierEvidenceContract` prototype. It turns the Phase 31A design checklist into a structured evidence object and validator that a later internal classifier prototype could consume. It still does not classify moves, score moves, compute official metrics, emit move-quality labels, or connect to UI, saved analysis, product review output, backend, persistence, or the engine.

The contract groups fields by evidence domain:

- evaluation availability: previous eval, played-move eval, best-move eval, candidate spread, PV, and MultiPV availability;
- tactical evidence: tactical signal, capture/promotion signal, check signal, candidate-spread signal, forcing-line signal, and mate signal;
- material evidence: material swing, major eval swing, queen-win evidence, and sacrifice-compensation evidence;
- king-safety evidence: king-safety signal, exposed-king signal, mating-net signal, and king-hunt signal;
- safety/suppression evidence: opening suppression, forced-move suppression, invalid-FEN suppression, budget pressure, and negative-guard scope exclusion;
- future product inputs: centipawn-loss availability, win-probability availability, officialAccuracy availability, officialAcpl availability, and product-label output availability.

Field statuses are explicit: `present`, `missing`, `blockedByPolicy`, `futureOnly`, `excludedByNegativeGuard`, `notImplemented`, or `unsupported`. Product-facing output, officialAccuracy, officialAcpl, centipawn-loss computation, and win-probability computation remain blocked or not implemented in this phase.

Group readiness is also explicit:

- tactical, material, forcing-line, king-safety, and safety/suppression evidence are ready only as developer evidence groups with supporting protected golden case IDs;
- evaluation availability is partial because broad evidence exists, but eval-input fields remain future-only;
- quiet/preparatory evidence is excluded by `quiet-preparatory-uncertain`;
- future product inputs remain future-only or policy-blocked.

`quiet-preparatory-hard-case` may appear as protected quiet evidence, but it does not unblock quiet/preparatory classification. `quiet-preparatory-uncertain` remains the exclusion guard and keeps unsupported quiet moves out of future classifier scopes.

Current post-31B decision:

- evidence contract status: `readyForDeveloperEvidencePrototype`;
- ready for Phase 31C internal non-label bucket design: true;
- product-facing labels: blocked;
- advanced candidate gates: blocked;
- quiet/preparatory classification: excluded;
- official metrics: blocked;
- CP-loss and win-probability computation: not implemented;
- captured Android proof remains attached only to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`;
- next recommended phase: `Phase 31C -- Internal Non-Label Bucket Design`.

The optional command is:

```powershell
dart run tool/basic_classifier_evidence_contract_report.dart
```

It renders deterministic markdown or JSON, supports `--strict`, does not run Android, does not load real Stockfish, does not call `LocalEvalService`, does not read network, does not write files, and does not execute proof commands.

## Phase 31C Internal Non-Label Evidence Buckets

Phase 31C adds a developer-only `InternalEvidenceBucketPrototype` layer. It consumes the Phase 31B evidence contract and groups current evidence into internal buckets that future non-label experiments can inspect. Buckets are evidence groupings only. They are not user-facing labels, do not classify moves, do not tune thresholds, and do not connect to UI, saved analysis, product review output, backend, persistence, or the engine.

Supported internal buckets include tactical support, material-swing support, forcing-line support, king-safety support, conservative endgame support, safety/suppression support, invalid-FEN suppression, opening suppression, forced-move suppression, budget-pressure visibility, Android-proof backing, candidate-spread support, and PV/MultiPV support. Each supported bucket lists supporting golden case IDs.

Bucket statuses are explicit:

- `supported`: the bucket has current protected golden support;
- `partial`: the bucket has some structure but is not fully supported;
- `excluded`: the bucket is intentionally out of scope;
- `blockedByPolicy`: the bucket is blocked from output or implementation;
- `futureOnly`: the bucket is a future input and is not implemented;
- `unsupported` or `invalid`: the bucket must not be consumed by later experiments.

Quiet/preparatory remains excluded by `quiet-preparatory-uncertain`. `quiet-preparatory-hard-case` may be listed as protected quiet evidence, but it does not unblock the quiet/preparatory bucket. Product output, advanced gates, and official metrics remain blocked. CP-loss and win-probability computation remain future-only/not implemented.

Current post-31C decision:

- bucket prototype status: `readyForInternalBucketPrototype`;
- ready for Phase 31D internal bucket experiment guards: true;
- product-facing labels: blocked;
- advanced gates: blocked;
- quiet/preparatory classification: excluded;
- official metrics: blocked;
- CP-loss and win-probability computation: not implemented;
- Android-proof-backed bucket is limited to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`;
- no labels are emitted.

The optional command is:

```powershell
dart run tool/internal_evidence_buckets_report.dart
```

It renders deterministic markdown or JSON, supports `--strict`, does not run Android, does not load real Stockfish, does not call `LocalEvalService`, does not read network, does not write files, and does not execute proof commands.

## Phase 31D Internal Bucket Experiment Guards

Phase 31D adds a developer-only `InternalBucketExperimentGuard` layer. It protects future internal bucket experiments before any experiment can consume the Phase 31C buckets. This is guard work only: it does not classify moves, does not score moves, does not tune thresholds, does not compute product metrics, and does not connect to UI, saved analysis, product review output, backend, persistence, or the engine.

Allowed experiments must be internal-only and may request only supported or partial non-quiet buckets. Partial buckets are allowed only with warnings. Every allowed request keeps product output, advanced gates, official metrics, CP-loss computation, win-probability computation, direct engine access, UI/backend output, and persistence disabled.

The guard blocks requests that ask for:

- product-facing or final move-quality output;
- advanced candidate output;
- official metrics;
- CP-loss or win-probability computation;
- quiet/preparatory scope;
- direct engine or `LocalEvalService` access;
- UI, backend, persistence, cache, or database output;
- policy-blocked, future-only, unsupported, or excluded buckets;
- Android proof claims outside captured proof IDs.

Android proof claims are evidence references only and are limited to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`. `quiet-preparatory-uncertain` remains the negative guard that excludes quiet/preparatory scope, while `quiet-preparatory-hard-case` remains protected evidence only.

Current post-31D decision:

- safe demo experiment status: `allowedInternalOnly`;
- requested safe buckets: supported non-quiet internal evidence buckets only;
- quiet/preparatory scope: excluded;
- product-facing labels: blocked;
- advanced gates: blocked;
- official metrics: blocked;
- CP-loss and win-probability computation: not implemented;
- direct engine, UI, backend, and persistence access: blocked;
- next recommended phase: `Phase 31E -- Internal Non-Label Bucket Experiment Harness`.

The optional command is:

```powershell
dart run tool/internal_bucket_experiment_guards_report.dart
```

It renders deterministic markdown or JSON, supports `--strict` and `--safe-demo`, does not run Android, does not load real Stockfish, does not call `LocalEvalService`, does not read network, does not write files, and does not execute proof commands.

## Phase 31E Internal Non-Label Bucket Experiment Harness

Phase 31E adds a developer-only `InternalBucketExperimentHarness` layer. The harness can run only after `InternalBucketExperimentGuard` approves the request as `allowedInternalOnly` or `allowedWithWarnings`. If the guard blocks a request, the harness stops and reports the guard decision without inspecting buckets.

Harness observations are internal evidence observations only. They record approved bucket IDs, bucket status, supporting golden case IDs, optional partial-bucket warnings, evidence areas, and proven Android proof references. They are not move labels, do not score moves, do not tune thresholds, and do not emit product-facing judgments.

Quiet/preparatory scope remains excluded by `quiet-preparatory-uncertain`. The harness reports the exclusion in an inactive blocked/excluded section; it does not activate quiet/preparatory observations. Product output, advanced gates, official metrics, CP-loss computation, and win-probability computation remain blocked.

Android proof references are limited to the captured Phase 30U IDs:

- `mate-threat-fast-evidence`;
- `queen-win-major-swing`;
- `simple-tactical-capture-check`.

Current post-31E decision:

- safe demo harness status: `completedInternalOnly`;
- guard status for safe demo: `allowedInternalOnly`;
- observed buckets: supported non-quiet internal evidence buckets only;
- partial buckets: warning-only when explicitly included, skipped deterministically when excluded;
- quiet/preparatory scope: excluded;
- product-facing labels: blocked;
- advanced gates: blocked;
- official metrics: blocked;
- CP-loss and win-probability computation: not implemented;
- direct engine, UI, backend, and persistence access: blocked;
- next recommended phase: `Phase 31F -- Internal Evidence Area Analysis With Labels Still Blocked`.

The optional command is:

```powershell
dart run tool/internal_bucket_experiment_harness_report.dart
```

It renders deterministic markdown or JSON, supports `--strict`, `--safe-demo`, and `--include-partial`, does not run Android, does not load real Stockfish, does not call `LocalEvalService`, does not read network, does not write files, and does not execute proof commands.

## Phase 31F Internal Evidence Area Coverage Matrix

Phase 31F adds a developer-only `InternalEvidenceAreaCoverageMatrix` layer above the Phase 31E harness. It analyzes evidence-area coverage from approved harness output. This is coverage analysis, not chess move quality analysis.

Evidence areas are internal coverage areas only:

- tactical, material-swing, forcing-line, king-safety, conservative endgame, safety/suppression, Android-proof-backed, candidate-spread, PV/MultiPV, budget-pressure, opening-suppression, forced-move-suppression, and invalid-FEN-suppression areas;
- quiet/preparatory exclusion;
- product-label, advanced-label, official-metric, CP-loss, and win-probability policy blocks.

Coverage statuses are explicit: `strong`, `adequate`, `partial`, `weak`, `excluded`, `blockedByPolicy`, `futureOnly`, `unsupported`, or `invalid`. These statuses describe evidence coverage only. They do not classify moves, score moves, tune thresholds, or emit user-facing judgments.

Gap recommendations are deterministic workflow hints: `keepStable`, `addHandcraftedCase`, `addFakeEvidence`, `addOwnerAndroidProofOnlyIfPvRequired`, `keepExcludedByNegativeGuard`, `keepBlockedByPolicy`, `investigateMismatch`, and `futureProductInputOnly`.

Current post-31F decision:

- matrix status: `readyWithWarnings`, because individual suppression areas currently have one supporting case each;
- strong areas: tactical and safety/suppression;
- adequate areas: material swing, forcing line, king safety, conservative endgame, Android proof backing, candidate spread, and PV/MultiPV;
- partial areas: budget pressure, opening suppression, forced-move suppression, and invalid-FEN suppression;
- quiet/preparatory area: excluded by `quiet-preparatory-uncertain`;
- product, advanced, and official metric areas: blocked by policy;
- CP-loss and win-probability computation areas: future-only and not implemented;
- Android proof support remains limited to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`;
- next recommended phase: `Phase 31G -- Internal Non-Label Coverage-Informed Scoring Design`.

The optional command is:

```powershell
dart run tool/internal_evidence_area_coverage_matrix_report.dart
```

It renders deterministic markdown or JSON, supports `--strict`, `--safe-demo`, and `--include-partial`, does not run Android, does not load real Stockfish, does not call `LocalEvalService`, does not read network, does not write files, and does not execute proof commands.

## Phase 31G Internal Non-Label Coverage-Informed Scoring Design

Phase 31G adds a developer-only `InternalNonLabelScoringDesign` layer above the Phase 31F coverage matrix. This phase designs a future internal signal structure only. It does not compute scores, rank moves, create thresholds, classify moves, or emit user-facing judgments.

Design dimensions are internal planning dimensions only:

- tactical pressure, material swing, forcing line, king safety, endgame precision, suppression safety, candidate spread, PV/MultiPV support, Android proof confidence, and budget risk;
- quiet/preparatory exclusion;
- product-label, advanced-label, official-metric, CP-loss, and win-probability blocked or future-only dimensions.

Dimension readiness statuses are explicit: `designReady`, `designReadyWithWarnings`, `partialNeedsMoreCases`, `futureOnly`, `excluded`, `blockedByPolicy`, `unsupported`, or `invalid`. These statuses describe whether a future internal non-label prototype may consider a dimension. They are not move scores and they are not product labels.

Qualitative signal types are also design-only: `primarySignal`, `secondarySignal`, `supportingSignal`, `suppressionSignal`, `confidenceSignal`, `riskSignal`, `excludedSignal`, `blockedSignal`, and `futureSignal`. Phase 31G uses no numeric weights and no score thresholds.

Current post-31G decision:

- scoring design status: `designReadyWithWarnings`, because several dimensions are intentionally limited or partial;
- design-ready dimensions: tactical pressure, material swing, forcing line, candidate spread, PV/MultiPV support, and Android proof confidence;
- warning-ready dimensions: king safety, endgame precision, and suppression safety;
- partial dimension: budget risk, requiring more Golden cases before prototype use;
- quiet/preparatory dimension: excluded by `quiet-preparatory-uncertain`;
- product-label, advanced-label, and official-metric dimensions: blocked by policy;
- CP-loss and win-probability dimensions: future-only and not implemented;
- Android proof confidence remains limited to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`;
- no labels, numeric scores, official metrics, CP-loss computation, or win-probability computation are emitted.

The optional command is:

```powershell
dart run tool/internal_non_label_scoring_design_report.dart
```

It renders deterministic markdown or JSON, supports `--strict`, `--safe-demo`, and `--include-partial`, does not run Android, does not load real Stockfish, does not call `LocalEvalService`, does not read network, does not write files, and does not execute proof commands.

## Phase 31H Guarded Internal Non-Label Signal Profile

Phase 31H adds a developer-only `InternalNonLabelSignalProfilePrototype` layer above the Phase 31G scoring design. It produces qualitative internal signal profiles only. Signals are evidence signals, not labels, not move-quality judgments, and not product output.

Signal statuses are explicit: `active`, `activeWithWarnings`, `partial`, `excluded`, `blockedByPolicy`, `futureOnly`, `inactive`, or `invalid`. These statuses describe internal profile availability only. They do not classify moves, rank moves, compute numeric move scores, create thresholds, or emit user-facing judgments.

Qualitative confidence values are also internal-only: `highConfidence`, `mediumConfidence`, `lowConfidence`, `warningOnly`, `excluded`, `blocked`, and `futureOnly`. Phase 31H uses no numeric weights, aggregate scores, move rankings, or score thresholds.

Current post-31H decision:

- profile status: `readyWithWarnings`, because warning-ready and partial design dimensions remain visible;
- active signals: tactical pressure, material swing, forcing line, candidate spread, PV/MultiPV support, and Android proof confidence;
- warning or partial signals: king safety, endgame support, suppression safety, and budget risk;
- quiet/preparatory signal: excluded by `quiet-preparatory-uncertain`;
- product-label, advanced-label, and official-metric signals: blocked by policy;
- CP-loss and win-probability signals: future-only and not implemented;
- Android proof confidence remains limited to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`;
- no labels, numeric scores, move rankings, official metrics, CP-loss computation, or win-probability computation are emitted.

The optional command is:

```powershell
dart run tool/internal_non_label_signal_profile_report.dart
```

It renders deterministic markdown or JSON, supports `--strict`, `--safe-demo`, and `--include-partial`, does not run Android, does not load real Stockfish, does not call `LocalEvalService`, does not read network, does not write files, and does not execute proof commands.

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

Phase 30W extends that base with compact rows for king-safety mating-net pressure, quiet preparatory uncertainty, sacrifice compensation variation, endgame precision, and forcing-line variation.

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
