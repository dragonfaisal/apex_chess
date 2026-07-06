# Apex Chess Phase 38A Product-Safe Review Contract Plan

## Purpose

Phase 38A defines the first product-safe analysis review contract boundary
before any Review UI, saved analysis, archive, stats, backend, or public label
integration.

This is a planning decision only. It does not create runtime code, UI,
persistence behavior, or another developer-only wrapper.

## Current State

Phase 37A and Phase 37D proved the developer-only analysis preview chain on an
Android device for the controlled single-move scenario:

- played move: `e2e4`
- candidate move: `e2e3`
- mover color: `white`
- requested depth: `1`

The current safe source is
`AnalyzerNonUiDeveloperPreviewConsumerResult`, produced by the Phase 37D
non-UI developer preview consumer. It is safe only as a developer-only,
read-only, non-UI diagnostic consumer because it explicitly reports:

- `consumerComputed: true`
- `consumerReady: true`
- `consumerIsDeveloperOnly: true`
- `consumerIsReadOnly: true`
- `consumerIsProductReview: false`
- `consumerIsSavedAnalysis: false`
- `consumerIsArchiveStatsOutput: false`
- `consumerContainsPublicLabels: false`
- `consumerContainsOfficialMetrics: false`
- `publicLabelComputed: false`
- `officialMoveQualityComputed: false`
- `officialCpLossComputed: false`
- `officialWinPercentComputed: false`
- `accuracyComputed: false`
- `acplComputed: false`
- `savedAnalysisWritten: false`
- `uiOutputProduced: false`
- `archiveStatsTouched: false`

The following remains developer-only and must not be treated as product truth:

- the controlled depth-1 proof scenario;
- private bucket counts such as positive, neutral, negative, and unavailable;
- developer chain trace and sanitized proof logs;
- the read-only developer preview adapter;
- the non-UI developer preview consumer.

The existing product review UI is already substantial and is not compatible
with direct developer-chain consumption. Current review surfaces include:

- `ReviewController` and `ReviewState`, which load `AnalysisTimeline` or
  `CanonicalAnalysisPayload` into product review state;
- `ReviewScreen`, which renders board state, move quality chips, brilliant
  glow, eval display, better-move arrows, and coach copy from `MoveAnalysis`;
- `ReviewSummaryScreen`, which displays public move-quality counts, accuracy,
  ACPL, phase breakdowns, and review CTAs;
- archive and saved-review reopen paths that load cached timelines through
  `ReviewEntryContract`, `CanonicalAnalysisPayload`, and `ArchivedGame`.

Direct integration is risky because these surfaces assume full-game timelines,
public `MoveQuality` concepts, official-looking accuracy/ACPL, persisted
timeline consistency, and review UI semantics that the Phase 37 developer chain
does not provide.

## Product-Safe Contract Boundary

The future product-safe review contract may contain only neutral, non-public,
non-official fields until public classifier, saved-analysis, and metric policies
exist.

Allowed future contract fields:

- contract identity, source, and version;
- neutral readiness status such as ready, unavailable, or blocked;
- source/proof status that states whether the internal chain was available and
  safe;
- request/proof scope such as single-move, controlled input, requested depth,
  and evidence strength;
- private counts only when clearly marked internal and non-public;
- private bucket summaries only when clearly marked non-public and not mapped
  to user-facing move quality;
- explicit guard flags proving no public labels, official metrics, UI output,
  saved-analysis writes, persistence writes, backend payloads, archive/stat
  output, or raw engine output are present;
- neutral failure or unavailable reasons suitable for product-safe gating.

The future contract must not contain UI presentation fields. Product display
models can be designed later after the contract exists and has focused safety
tests.

## Forbidden Fields

The product-safe review contract must explicitly forbid these public labels,
official metric fields, and integration fields until separately scoped:

- `Brilliant`
- `Great`
- `Best`
- `Excellent`
- `Good`
- `Book`
- `Inaccuracy`
- `Mistake`
- `Miss`
- `Blunder`
- `Checkmate`
- `officialMoveQuality`
- `officialCpLoss`
- `officialWinPercent`
- `accuracy`
- `acpl`
- `savedAnalysisId`
- `archiveId`
- UI badge fields
- UI icon fields
- UI color fields
- UI route fields
- backend payload fields

The contract also must not expose old `MoveClassifier` output, `MoveQuality`,
raw UCI output, raw principal variations, explanation text, persisted review
payloads, archive/stat fields, or saved-analysis reopen identifiers.

## Product Review Risk Analysis

Direct integration into `ReviewScreen`, `ReviewSummaryScreen`, or
`ReviewController` is unsafe now.

The current `ReviewController` loads `AnalysisTimeline` and exposes
`MoveAnalysis` by current ply. `MoveAnalysis` already contains Win%, delta,
`MoveQuality`, engine best move, CP/mate scores, opening state, coach text,
analysis versions, and debug metadata. Mapping a developer-only private result
into that shape would either fabricate missing product fields or quietly revive
old classifier assumptions.

The current review board display model turns `MoveAnalysis` into public chips,
markers, brilliant glow, better-move arrows, eval labels, and coach copy. The
Phase 37 chain has no public label policy, no official move-quality policy, no
official Win% policy, no official CP-loss policy, and no explanation-copy
policy. Showing it in the review UI would risk presenting provisional evidence
as product truth.

The summary screen and archive paths are also coupled to full-game product
analysis. They depend on move-quality counts, accuracy, ACPL, cached timelines,
classifier versions, analysis schema versions, and reopen consistency. The
developer chain is a single controlled depth-1 path and cannot satisfy saved
review or archive guarantees.

Therefore, the next step must be a typed product-safe domain contract without
UI, saved analysis, archive writes, official metrics, or public labels.

## Recommended Next Build Phase

The next phase should be:

`Phase 38B - Product-Safe Analysis Review Contract Model Without UI`

Phase 38B should create the first typed product-safe domain contract. It should
remain pure domain work with focused tests only. It should not wire UI, saved
analysis, archive, stats, backend, LocalGameAnalyzer, CloudGameAnalyzer, old
MoveClassifier output, or product review routes.

Phase 38B should prove:

- allowed neutral contract fields are present;
- forbidden public labels and official metrics are absent;
- source safety is fail-closed;
- private counts remain internal/non-public;
- no saved-analysis, archive/stat, UI, persistence, file, or backend side
  effects are represented.

## Stop List

- No UI integration until the product-safe review contract model exists.
- No saved analysis until review contract persistence and reopen consistency
  policy exists.
- No archive or stats integration until saved-analysis policy exists.
- No public labels until public classifier and label policy exists.
- No official move quality until classifier policy exists.
- No official CP-loss or Win% until official metric policy exists.
- No accuracy or ACPL until official metric policy exists.
- No old `MoveClassifier`, `LocalGameAnalyzer`, or `CloudGameAnalyzer` product
  integration in this boundary.
- No more developer wrappers.
- No more golden-case-only phases unless the phase touches public labels, UI,
  persistence, or classifier policy.
