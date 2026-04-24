# PR #8 Test Report — depth-picker copy + debounced username validation

**PR:** https://github.com/dragonfaisal/apex_chess/pull/8
**Branch:** `devin/1777047385-copy-and-username-validation`
**Build:** Linux desktop debug.
**Session:** https://app.devin.ai/sessions/df4556a9bca447a781c10f9389d14a2c

## Summary

All **7/7 assertions passed**. Tested Import + Opponent Forensics pill behavior against three pre-computed curl oracles (`hikaru` = 200/200, `lichess_fan` = 200/404 — the source-toggle adversarial proof, `apexchess_nope` = 404/404) and the scanning dialog header for both Fast D14 and Quantum D22.

## Assertion matrix

| # | Phase | Test | Expected | Observed | Result |
|---|---|---|---|---|---|
| P1a | Import | `<` 2-char input | no pill | no pill on `h` | pass |
| P1b | Import | `hikaru` / Chess.com | green `verified` | green `verified` | pass |
| P1c | Import | `apexchess_nope` / Chess.com | red `not found` | red `not found` | pass |
| P1d | Import | `lichess_fan` / Chess.com | green `verified` | green `verified` | pass |
| P1e | Import | Toggle Chess.com→Lichess (field keeps `lichess_fan`) | red `not found` | pill flipped to red | pass |
| P1f | Import | Toggle Lichess→Chess.com | green `verified` | pill flipped back to green | pass |
| P2a | Scanner | `apexchess_nope` / Chess.com | red `not found` | red `not found` | pass |
| P2b | Scanner | `hikaru` / Chess.com | green `verified` | green `verified` | pass |
| P3a | Import | Fast D14 dialog header | `Fast Analysis · D14` | exact match | pass |
| P4a | Import | Quantum D22 dialog header | `Quantum Deep Scan · D22` | exact match | pass |

(P1e/P1f grouped as the single "source-toggle re-validates" adversarial test.)

## Evidence

### Phase 1 — Import pill states

| hikaru (200) → verified | apexchess_nope (404) → not found |
|---|---|
| ![hikaru verified](https://app.devin.ai/attachments/4b4fa95a-34ac-4e15-8f32-7ccf9ba20bd5/screenshot_a629eb05cd56470fa33ea38730d1fc77.png) | ![apexchess_nope not found](https://app.devin.ai/attachments/bb4407fd-b67c-468b-a885-965c9f714c72/screenshot_3fd1b1a7fa5547a98081db03ab96fafa.png) |

### Phase 1 — Source-toggle adversarial proof (lichess_fan 200 on Chess.com / 404 on Lichess)

| Chess.com active → verified | Toggle Lichess → not found |
|---|---|
| ![lichess_fan on Chess.com](https://app.devin.ai/attachments/d877657a-37c0-48ff-9ef2-223782b9c82d/screenshot_842c717022cf410596738631f4199d3e.png) | ![lichess_fan on Lichess](https://app.devin.ai/attachments/70a02f9d-fd0f-49de-b88f-0e1551c48f3e/screenshot_7da628e1d4f24211bdb142a3d6b0f7d6.png) |

Toggle back to Chess.com restores green (bidirectional `didUpdateWidget`): ![toggle back](https://app.devin.ai/attachments/11f63cdc-6569-44f5-b53b-60a68599bcdc/screenshot_3e865e708af545bf92b2bef73c51630d.png)

### Phase 2 — Opponent Forensics pill

`hikaru` verified on Scanner (pill wired identically across screens): ![scanner hikaru](https://app.devin.ai/attachments/92165b0c-800f-4b91-a8fd-c1405b3a2d2d/screenshot_0fac2195376f4639846091751ae4dd19.png)

### Phases 3 & 4 — Scanning dialog header copy

| Fast D14 header | Quantum D22 header |
|---|---|
| ![Fast Analysis · D14](https://app.devin.ai/attachments/5860b0a8-3dcb-4c7f-ba45-11b0052e328c/screenshot_83b99975c6c44f42a23777f54356476f.png) | ![Quantum Deep Scan · D22](https://app.devin.ai/attachments/68dd2627-f92e-4e11-8e35-5881a3d7c7de/screenshot_18a3bb226827490da7255d23c988f8e1.png) |

Before the fix, both modes shared the `deepAnalysis` constant and Fast mis-advertised as `Quantum Deep Scan · D14`. `ApexCopy.scanHeader(depth)` now routes correctly.

## Recording

Full walkthrough (Import pill → source toggle → Scanner pill → Fast header → Quantum header), with structured annotations:
https://app.devin.ai/attachments/96f42b6b-dcef-41e2-988d-c50f9e5a87d2/rec-7e4b775b-f143-4182-9260-930cacc411c9-subtitled.mp4

## Non-blocking observations

- Fast D14 on 85-ply Parhamov game completed in ~55 s — matches prior PR #3 measurement, rules out any engine-speed regression from the copy / validation changes.
- `dbind-WARNING AT-SPI` at launch is environmental (VM lacks the a11y bus); not app code.
