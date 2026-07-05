# Apex Chess Phase 37B Consumption Boundary

## Purpose

Phase 37A proved the Android-backed chain reaches
`AnalyzerReadOnlyDeveloperPreviewAdapterResult`. Phase 37B inspected the
current app surfaces to decide whether that result can be consumed safely
without becoming product UI.

Decision: document the boundary and stop. Do not add a developer UI, route,
ViewModel, or product review integration in Phase 37B.

## Inspection Summary

- App entry is `MaterialApp` with `_RootGate` routing to onboarding or
  `HomeScreen`.
- `HomeScreen` owns the visible Analyze, Archive, Stats, and Academy shell.
- Review flow is still driven through `ReviewController`,
  `ReviewSummaryScreen`, and `ReviewScreen`.
- The current PGN review flow can invoke legacy analysis, archive saving, and
  saved-review payload loading.
- The existing online-review dev harness is scoped to the online-review path,
  disabled by default, and intentionally kept out of `main.dart` and
  `HomeScreen`.
- Phase 37A currently has an Android integration proof and domain adapter, but
  no safe app-wide developer entry point for consumption.

## Boundary Decision

Option B is safer for Phase 37B.

Do not implement a visible or routable consumer yet. The existing product
navigation and review screens are user-facing surfaces, and the existing dev
harness pattern is online-review-specific rather than a general local analyzer
preview entry point.

## Source Of Truth

The source of truth for future read-only developer preview consumption is:

`AnalyzerReadOnlyDeveloperPreviewAdapterResult`

Allowed neutral developer fields for a future consumer:

- `previewReady`
- `previewUnavailableReason`
- `totalPrivateEntries`
- `positiveCandidateCount`
- `neutralCandidateCount`
- `negativeCandidateCount`
- `unavailableCount`
- `adapterIsDeveloperOnly`
- `adapterIsReadOnly`
- `adapterContainsPublicLabels`
- `adapterContainsOfficialMetrics`
- `safeForPhase37B`
- `nextRecommendation`

## Blocked Outputs

A future consumer must not expose:

- public move labels
- official move quality
- official CP-loss
- official Win percent
- accuracy or ACPL
- product explanations
- saved analysis payloads
- archive or stats data
- backend payloads
- persistence writes
- file exports
- product UI state

## UI Exposure Risk

Current review UI is not a safe first consumption boundary because it already
renders legacy review state, public move-quality concepts, evaluation UI,
saved-review payloads, and archive flow side effects.

Current home navigation is not a safe first consumption boundary because adding
a visible or hidden route there would create product UI exposure and would need
Android proof.

The existing online-review harness should not be reused for this local analyzer
preview chain because it is scoped to online-review activation and shell
composition.

## Recommended Next Implementation

Next phase should build a non-UI developer-only consumer, not a new safety
wrapper and not product UI.

Recommended next phase:

`Phase 37C - Non-UI Developer Preview Consumer Without Public Labels`

The consumer should:

- consume an existing `AnalyzerReadOnlyDeveloperPreviewAdapterResult`
- read only the neutral developer fields listed above
- remain pure or command/test-only
- avoid routes, screens, ViewModels, providers, persistence, archive, stats,
  saved analysis, backend, and product review integration
- include one focused pure test proving the consumed output is read-only,
  developer-only, label-free, and official-metric-free

## Phase 37C Gate

- `safeForPhase37C`: true for a non-UI developer-only consumer only.
- `nextRecommendation`: `implementNonUiDeveloperPreviewConsumerWithoutPublicLabels`

