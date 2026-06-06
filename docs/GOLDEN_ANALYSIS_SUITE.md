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
