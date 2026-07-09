# Apex Chess Phase 39A Dev-Gated Review Preview Blockers

## Purpose

Phase 39A inspected whether Apex can safely add the smallest dev-gated neutral
review preview surface from `AnalyzerProductSafeReviewGateway` or
`AnalyzerProductSafeReviewContract`.

Decision: Option B. Do not add an Android-visible UI surface yet.

## Inspection Summary

- App entry is `MaterialApp` in `lib/main.dart`, with `_RootGate` routing only
  to onboarding or `HomeScreen`.
- `HomeScreen` owns the normal Analyze, Archive, Stats, and Academy shell.
- Normal analysis and saved-review reopen paths load `ReviewController`, then
  push `ReviewSummaryScreen` or `ReviewScreen`.
- `ReviewController` is built around `AnalysisTimeline`,
  `CanonicalAnalysisPayload`, and `MoveAnalysis`.
- `ReviewSummaryScreen` displays public review concepts: move-quality counts,
  accuracy, ACPL, phase breakdowns, and review CTAs.
- `ReviewScreen` displays board state, eval UI, public move-quality styling,
  better-move affordances, coach copy, move list, and brilliant glow from
  `MoveAnalysis`.
- The existing `OnlineReviewProductDevHarness` is scoped to the online-review
  path only, disabled by default, and tests assert it is not exposed through
  `main.dart` or `HomeScreen`.
- `AnalyzerProductSafeReviewGateway` currently allows product review planning
  only. It explicitly keeps UI rendering, saved analysis, archive/stats, public
  labels, and official metrics blocked.

## Dev and Debug Gate Pattern Found

The repo has two relevant opt-in patterns:

- Android proof tests use `--dart-define` flags and remain outside product
  navigation.
- The online-review dev harness has a dedicated runtime gate and is disabled by
  default, but it is intentionally specific to online review and not wired into
  the main app shell.

No safe app-wide dev-only route, drawer, hidden gesture, or neutral local
review preview entry point currently exists for the product-safe analysis
contract chain.

## Review UI Risk

Direct integration into current review UI is unsafe because it would require
mapping a single controlled, developer-evidence-backed source into product
surfaces that assume full-game analysis and public review semantics.

Risks include:

- leaking public labels or label-like colors/icons through existing review
  widgets;
- reviving `MoveQuality` concepts before public-label policy exists;
- displaying official-looking accuracy, ACPL, CP-loss, or Win% before official
  metric policy exists;
- polluting `ReviewController` with non-timeline developer evidence;
- implying saved-analysis or archive consistency that the contract does not
  provide;
- adding an Android-visible route without a dedicated product-safe UI contract
  and Android visual proof.

## Safe Integration Point

The current safe source of truth is domain-only:

- `AnalyzerProductSafeReviewContract`
- `AnalyzerProductSafeReviewGatewayDecision`

The current safe consumption boundary is not UI. A future step may create a
non-visible neutral display/read model from the gateway, but it must remain
outside `ReviewController`, `ReviewScreen`, `ReviewSummaryScreen`, saved
analysis, archive, stats, backend, and product navigation.

## Blocker

Option A is blocked because `AnalyzerProductSafeReviewGateway` explicitly sets
`gatewayAllowsUiRendering` to `false`, and no existing app-wide dev-gated UI
entry point can consume the local product-safe review chain without touching
normal product navigation or review surfaces.

## Why UI Is Unsafe Now

The contract is product-safe for planning, not presentation. It contains
neutral readiness and private internal counts, but it intentionally does not
contain presentation fields, public labels, official metrics, saved-analysis
identifiers, archive data, explanation text, UI colors, icons, badges, or
timeline rows.

Building a dev-gated UI now would either show too little to justify a route or
require inventing presentation semantics that the current contract deliberately
does not define.

## Minimal Required Next Step

The next safe implementation step is a non-visible neutral preview display
model or read model that consumes `AnalyzerProductSafeReviewGatewayDecision`
and proves:

- source contract is clean;
- gateway is computed;
- preview is read-only and developer-only;
- no public labels are present;
- no official metrics are present;
- no saved-analysis, persistence, archive, stats, backend, or UI side effects
  are represented;
- `ReviewController`, `ReviewScreen`, and `ReviewSummaryScreen` remain
  untouched.

Only after that non-visible model exists should the project decide whether to
add a separate dev-gated UI route with Android visual proof.

## Stop List

- No default-visible product UI.
- No normal `ReviewScreen` or `ReviewSummaryScreen` integration.
- No `ReviewController` changes.
- No saved-analysis writes or saved-review reopen coupling.
- No archive or stats output.
- No backend payload.
- No public labels.
- No `MoveQuality` mapping.
- No official CP-loss, Win%, accuracy, or ACPL.
- No explanation or coach copy.
- No badge, icon, color, or animation implying move quality.
- No old `MoveClassifier`, `LocalGameAnalyzer`, or `CloudGameAnalyzer`
  integration.

## Phase 39B Gate

- `safeForPhase39B`: true, limited to a non-visible neutral preview display
  model or read model without UI.
- `nextRecommendation`:
  `implementNonVisibleNeutralReviewPreviewDisplayModelWithoutUi`

