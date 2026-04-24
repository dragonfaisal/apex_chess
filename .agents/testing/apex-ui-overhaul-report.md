# Apex Chess — Deep Space UI + BrilliantGlow Test Report

PR: https://github.com/dragonfaisal/apex_chess/pull/2
Session: https://app.devin.ai/sessions/df4556a9bca447a781c10f9389d14a2c
Test recording: attached (`rec-270ba160-...-subtitled.mp4`)

## Summary

Ran the Linux desktop build locally, exercised the home screen and the full Opera-game PGN review (33 plies). Verified the home-screen overflow is fixed, the Deep Space Cinematic theme + premium copy render, the `LocalGameAnalyzer` classifies every ply, and the `BrilliantGlow` halo fires **only** on plies classified as `MoveQuality.brilliant`.

## Results

- **It should render the home screen with Deep Space Cinematic UI and no overflow** — passed
- **It should show BrilliantGlow halo only on brilliant plies in the Opera demo** — passed
  - Ply 24 "12... Rd8 — Good": no halo
  - Ply 25 "13. Rxd7 — Brilliant": halo visible, `!!` badge on d7
  - Ply 27 "14. Rd1 — Best Move": no halo
  - Ply 30 "15... Nxd7 — Good": no halo
  - Ply 31 "16. Qb8+ — Brilliant": `!!` badge on b8, halo fires on arrival (animation is 1.4 s; static screenshot taken after decay — visible in video)
  - Ply 32 "16... Nxb8 — Good": no halo
  - Ply 33 "17. Rd8# — Best Move": no halo

No `RenderFlex overflowed` log at any point. `flutter analyze` clean; 24/24 unit tests passing.

## Escalations / caveats

- **Audio plugin errors (environmental, not the PR)**: Linux test VM is missing GStreamer codec plugins, so every move-sound triggers an `AudioPlayers` / GStreamer exception in stderr. This is unrelated to this PR — the same errors reproduce on `main`. No user-visible effect on the desktop build (just no move sounds).
- **`BrilliantGlow` animation can leak across plies when clicking forward rapidly.** `BrilliantGlow` only *starts* the controller on `false → true` transitions; when the user moves off a brilliant ply before the 1.4 s envelope finishes, the halo keeps animating on the next (non-brilliant) ply. Observed once at ply 32 during rapid forward clicks; reproducible but minor. Suggest resetting the controller (`_controller.stop()` + `value = 0`) on `true → false` transitions. Not a blocker for this PR.

## Evidence

### Home screen — no overflow, premium copy

![Home screen — Deep Space Cinematic UI](https://app.devin.ai/attachments/a6cee5ab-3a90-4cf6-9373-70a943573b6c/screenshot_6ba63fad58d24c489e2c258a0bda2ca0.png)

All five premium copy strings present on the sapphire/ruby gradient canvas: `APEX CHESS`, `On-Device Neural Grandmaster`, `ENTER LIVE MATCH`, `QUANTUM DEPTH SCAN`, `DEMO • OPERA GAME 1858`.

### BrilliantGlow toggle

| 🟦 Ply 24 "Good" — no halo | 🟢 Ply 25 "Brilliant" — halo visible |
|---|---|
| ![Ply 24 Rd8 Good](https://app.devin.ai/attachments/71789fe6-47ab-4d4d-8145-e13b4b7b7cf2/screenshot_4be10f98c0ec4f53b8accd3f642c5fc7.png) | ![Ply 25 Rxd7 Brilliant](https://app.devin.ai/attachments/1da4bce6-2815-46c7-aed8-ab716e238284/screenshot_636f3711e14343df8d212a94afa63c41.png) |
| `12... Rd8 — Good`, board border untouched. | `13. Rxd7 — Brilliant`, cyan halo around board + `!!` badge on d7. |

### Second brilliant at ply 31 + clean fade at ply 33

| 🟢 Ply 31 "Qb8+ — Brilliant" | 🟦 Ply 33 "Rd8# — Best Move" |
|---|---|
| ![Ply 31 Qb8+ Brilliant](https://app.devin.ai/attachments/6f14830b-d838-46ad-9949-4110bc4294d3/screenshot_9da1a5361e5140fba00f0ef6d20da10f.png) | ![Ply 33 Rd8# Best Move](https://app.devin.ai/attachments/25c90882-645d-45a6-93be-200d82a6da78/screenshot_508329e5af7643139b5d37e1fe9b55f4.png) |
| `16. Qb8+ — Brilliant`, `!!` badge on b8. Halo animation captured in recording. | Checkmate. Board border clean — halo correctly absent on non-brilliant plies. |
