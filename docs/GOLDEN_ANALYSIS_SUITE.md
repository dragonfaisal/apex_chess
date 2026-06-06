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
