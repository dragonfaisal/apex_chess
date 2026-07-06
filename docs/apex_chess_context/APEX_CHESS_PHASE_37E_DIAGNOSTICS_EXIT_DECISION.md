# Apex Chess Phase 37E Diagnostics Exit Decision

## Purpose

Phase 37E decides whether the current developer diagnostics and proof tooling
are sufficient, then defines the exit from the Phase 37 developer-proof chain.

Decision: the current diagnostics are sufficient for now. Exit the Phase 37
developer-proof chain and move next to product-safe contract planning.

## Current Proof Status

Phase 37A adapter proof status:

- The Android opt-in adapter proof exists in
  `integration_test/analyzer_read_only_developer_preview_adapter_probe_device_test.dart`.
- It proves the existing Android-backed chain reaches
  `AnalyzerReadOnlyDeveloperPreviewAdapterResult`.
- It preserves the full internal chain trace through legacy reintegration,
  read models, developer snapshot, debug facade, debug preview contract, and
  read-only developer preview adapter.

Phase 37D consumer proof status:

- The Android opt-in consumer proof exists in
  `integration_test/analyzer_non_ui_developer_preview_consumer_probe_device_test.dart`.
- The proof ran successfully on `SM S908U1`, device id `R5CT33FXE5K`, Android
  16 API 36.
- The final non-UI consumer result reported `consumerComputed: true`,
  `consumerReady: true`, `consumerUnavailableReason: none`,
  `consumerIsDeveloperOnly: true`, `consumerIsReadOnly: true`,
  `consumerContainsPublicLabels: false`, `consumerContainsOfficialMetrics:
  false`, and `safeForPhase37E: true`.

Controlled scenario used:

- `playedMoveUci: e2e4`
- `candidateMoveUci: e2e3`
- `moverColor: white`
- `requestedDepth: 1`

Chain proved:

- Android controlled engine proof path
- legacy reintegration
- move result read model
- timeline entry read model
- timeline collection read model
- review summary read model
- review envelope read model
- developer snapshot
- export contract
- debug read facade
- debug preview contract
- read-only developer preview adapter
- non-UI developer preview consumer

## Diagnostics Boundary

Current 37A and 37D proofs are enough for developer diagnostics now.

A new probe harness is not needed now. The current opt-in Android proofs already
cover the developer-only adapter and the final non-UI consumer. Adding another
harness would be more developer-only rotation without product/runtime value.

Do not keep adding developer-only wrappers. The useful boundary is the
non-UI developer preview consumer, backed by focused pure tests and opt-in
Android proof.

Diagnostics that should remain opt-in only:

- Android adapter proof behind its explicit dart define.
- Android non-UI consumer proof behind its explicit dart define.
- Focused pure boundary tests for adapter and consumer fail-closed behavior.
- Sanitized JSON logs that contain no raw UCI output, public labels, official
  metrics, product UI state, persistence payload, file export, backend payload,
  archive output, or stats output.

## Exit Decision

Exit the Phase 37 developer proof chain.

The next work should not add another developer wrapper, export, facade, preview,
consumer, or golden-only phase. The next work should define a product-safe
analysis review contract before any UI, saved analysis, archive, stats, backend,
or public label integration.

What must remain blocked before product UI:

- public labels
- official move quality
- official CP-loss
- official Win percent
- accuracy or ACPL
- saved analysis writes
- persistence/cache/database writes
- backend payloads
- archive or stats output
- direct use of raw engine output
- direct use of old classifier paths
- product routes, widgets, or ViewModels fed by developer-only contracts

What is allowed in the next phase:

- inspect current review-domain and review-UI contracts;
- define a product-safe analysis review contract plan;
- decide what fields can cross from developer/private evidence into future
  product review state;
- keep all public labels and official metrics absent;
- define validation for the future contract before implementation.

## Recommended Next Phase

Recommend exactly:

`Phase 38A - Product-Safe Analysis Review Contract Planning Without Public Labels`

Why this is safer:

- The current review UI still consumes legacy review state and public
  move-quality concepts.
- Saved analysis and archive consistency are not ready to receive this new
  chain.
- A review consumption gateway would be premature before the product-safe
  contract is designed.
- Contract planning can define the allowed product boundary without creating UI,
  persistence, public labels, or another developer wrapper.

## Stop List

- No more wrapper-only phases.
- No more export/facade/preview/consumer layers unless a real product/runtime
  boundary changes.
- No more golden-case-only phases unless touching public labels, UI,
  persistence, or classifier behavior.
- No UI integration until a product-safe analysis review contract exists.
- No saved analysis until the stable review contract and reopen consistency are
  designed.
- No public labels until classifier and public-label policy are separately
  designed and validated.
- No official CP-loss, Win percent, accuracy, or ACPL until the math, evidence
  depth, perspective handling, and persistence policy are proven.

