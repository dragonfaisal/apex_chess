# Golden Analysis Suite

## Phase 32E Targeted Golden Coverage Additions

Phase 32E adds five compact, handcrafted Golden Analysis Suite cases for the hardening gaps identified by the internal packet evidence hardening plan. These cases are regression and evidence inputs only. They do not create move labels, product claims, official metrics, numeric move values, move ordering, or engine calls.

New targeted cases:

- `king-safety-mating-net-pressure-32e`: broad king-safety and mating-net pressure coverage using handcrafted position metadata and candidate-spread evidence.
- `endgame-precision-candidate-spread-32e`: conservative endgame precision coverage using broad candidate-spread behavior, with no exact engine value assertion.
- `suppression-forced-only-legal-32e`: forced/only-legal suppression safety coverage that keeps deep analysis suppressed.
- `budget-pressure-wide-candidate-32e`: budget-pressure visibility coverage for a compact wide-candidate safety input.
- `pv-multipv-support-boundary-32e`: PV/MultiPV support boundary coverage that stays fake-evidence safe and does not claim captured real-device proof.

The existing fifteen cases remain present, including `quiet-preparatory-uncertain` as the quiet/preparatory negative guard. Quiet/preparatory scope remains excluded from core packet generation.

Android proof references remain limited to the existing captured IDs:

- `mate-threat-fast-evidence`
- `queen-win-major-swing`
- `simple-tactical-capture-check`

No new Phase 32E case claims Android proof. The owner proof queue remains empty for the default suite because the PV/MultiPV boundary case does not require captured PV or MultiPV proof.

Phase 32F recommendation: review the targeted Golden coverage impact and update the internal packet hardening plan from the new cases before broader internal packet work.

## Phase 32F Targeted Golden Coverage Impact Review

Phase 32F adds a developer-only impact review for the five Phase 32E cases. The review compares the current 20-case Golden suite with the pre-32E hardening picture and records which internal hardening targets gained support.

Impact summary:

- `king-safety-mating-net-pressure-32e` improves king-safety / mating-net coverage and broadens tactical, forcing-line, and candidate-spread support.
- `endgame-precision-candidate-spread-32e` improves conservative endgame precision coverage and candidate-spread support.
- `suppression-forced-only-legal-32e` improves forced suppression safety coverage.
- `budget-pressure-wide-candidate-32e` improves budget-pressure visibility and keeps budget pressure adequate in the internal coverage matrix.
- `pv-multipv-support-boundary-32e` improves PV/MultiPV boundary coverage without claiming captured Android proof.

The impact review keeps warning-limited scopes visible. King safety, endgame, suppression safety, and budget risk remain warning-limited in higher-level packet hardening even though their targeted support improved. Quiet/preparatory remains the single negative guard and stays excluded.

Owner proof queue status: empty by default. Android proof remains limited to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`; no Phase 32E case is treated as captured Android proof.

Phase 32G recommendation: `refreshInternalPacketHardeningPlanFromCoverageImpact`. This is still an internal evidence review path only. It adds no product labels, scores, rankings, official metrics, CP-loss, win probability, UI integration, backend integration, persistence, direct engine access, engine calls, or Android collector requirement.

## Phase 32G Refreshed Internal Packet Hardening Plan

Phase 32G adds a developer-only refreshed hardening plan that consumes the Phase 32F targeted coverage impact review. It updates the Phase 32D hardening actions from the actual Phase 32E coverage changes without adding new Golden cases and without converting any packet into product output.

Refresh summary:

- tactical and material-swing packets remain preserved as stable packet types.
- forcing-line and candidate-spread packets keep their stable packet treatment while recording broadened Phase 32E support.
- PV/MultiPV support is downgraded from an add-coverage action to a watch-listed warning-aware target because `pv-multipv-support-boundary-32e` improved boundary coverage without claiming captured Android proof.
- Android proof confidence remains proof-limited to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`.
- king safety, endgame, suppression safety, and budget risk are marked warning-limited but improved; they remain outside core packet generation.
- quiet/preparatory remains excluded by the negative guard, and product labels, advanced labels, official metrics, CP-loss, win probability, UI, backend, persistence, and direct engine access remain blocked or future-only.

Owner proof queue status: empty by default. No Phase 32E case is treated as captured Android proof.

Phase 32H recommendation: `validateRefreshedHardeningPlan`. Phase 32G adds no product labels, scores, rankings, official metrics, CP-loss, win probability, UI integration, backend integration, persistence, direct engine access, engine calls, or Android collector requirement.

## Phase 32H Refreshed Hardening Plan Validation

Phase 32H adds a developer-only validation layer for the Phase 32G refreshed internal packet hardening plan. It validates that the refresh consumed the Phase 32F coverage impact review, that improved targets cite Phase 32E support, and that preserved packet targets remain internally stable.

Validation summary:

- tactical and material-swing targets remain preserved.
- forcing-line and candidate-spread targets remain preserved or improved with Phase 32E support.
- PV/MultiPV support remains watch-listed and boundary-only.
- Android proof confidence remains proof-limited to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`.
- king safety, endgame, suppression safety, and budget risk remain warning-limited but improved.
- quiet/preparatory remains excluded by the negative guard, and product labels, advanced labels, official metrics, CP-loss, win probability, UI, backend, persistence, and direct engine access remain blocked or future-only.

Owner proof queue status: empty by default. No Phase 32E case is treated as captured Android proof, and owner proof is not required unless an explicit future PV/MultiPV proof reason is added.

Phase 32I recommendation: `proceedToInternalPacketEvidenceRefresh`. Phase 32H is validation only. It adds no product labels, scores, rankings, official metrics, CP-loss, win probability, UI integration, backend integration, persistence, direct engine access, engine calls, or Android collector requirement.

## Phase 32I Internal Packet Evidence Refresh

Phase 32I adds a developer-only internal packet evidence refresh layer that consumes the validated Phase 32H result and the refreshed Phase 32G hardening plan. It produces refreshed internal packet evidence records only; it does not judge moves and does not convert packet evidence into product-facing claims.

Refresh summary:

- tactical and material-swing packet evidence remains preserved stable.
- forcing-line and candidate-spread packet evidence records refreshed Phase 32E support while staying internal-only.
- PV/MultiPV support remains watch-listed and boundary-only; the Phase 32E PV/MultiPV case improves support without claiming captured Android proof.
- Android proof confidence remains proof-limited to `mate-threat-fast-evidence`, `queen-win-major-swing`, and `simple-tactical-capture-check`.
- king safety, endgame, suppression safety, and budget risk produce warning-limited records with improved support, but remain outside core packet generation.
- quiet/preparatory remains excluded by the negative guard.
- product labels, advanced labels, official metrics, CP-loss, win probability, UI, backend, persistence, cache/database, and direct engine access remain blocked or future-only.

The refreshed record set reports support cases, newly added Phase 32E support, existing Android proof IDs, signal/area/bucket mappings, qualitative confidence, warning reasons, proof-limit reasons, coverage gaps, future prerequisites, and blocked boundaries. These records are evidence artifacts for developers; they are not final labels, numeric values, rankings, official metrics, scheduler behavior, analyzer flow, backend state, UI output, saved analysis, or engine output.

Owner proof queue status: empty by default. No Phase 32E case is treated as captured Android proof. Owner proof remains opt-in only for an explicit future PV/MultiPV proof reason.

Phase 32J recommendation: `reviewRefreshedPacketEvidence`. Phase 32I adds no Golden cases, product labels, scores, rankings, official metrics, CP-loss computation, win probability computation, UI integration, backend integration, persistence, direct engine access, engine calls, Android collector requirement, or third-party data.
