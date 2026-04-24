# Phase 4 Test Plan — PR #9 (Apex Academy, Global Dashboard, Hyper-Neon VFX)

## Scope
Single ~4-min recording on Linux desktop debug. Validate the three net-new flows plus the two Devin Review fixes (`dff48cb`):
1. **Onboarding CTA rebuild fix** (🔴) — CONNECT must enable same frame the pill turns green.
2. **QuantumShatterLoader + 600 ms debounce auto-fetch** (Tasks 4, 5) — observable on Import.
3. **MistakeVault → Apex Academy SRS drill** (Tasks 3a/3b) — end-to-end persistence.
4. **Global Dashboard charts** (Task 1b) — aggregates from Hive archives.
5. **Opponent Forensics real engine math + CANCEL** (Task 1c) — progress updates per-ply, cancel aborts <~1 s.

Neon Move Quality VFX (Task 2) asserted inline on the Review screen after the Fast D14 scan.

Code paths traced:
- `lib/features/account/presentation/views/connect_account_screen.dart:73-96` (listener + setState wiring)
- `lib/features/import_match/presentation/views/import_match_screen.dart` (`_maybeAutoFetch`, 600 ms window)
- `lib/features/apex_academy/presentation/controllers/academy_controller.dart:140-181` (promotion enumeration + uciOf suffix)
- `lib/features/profile_scanner/data/profile_scanner_service.dart:120-181` (per-ply `ScanProgress` callback)
- `lib/features/mistake_vault/data/mistake_vault_save_hook.dart` (fire-and-forget on analyzer completion)
- `lib/shared_ui/widgets/move_quality_aura.dart` (`Positioned.fill`, color-per-quality)

---

## Prerequisites (not part of recording)
- Clear `SharedPreferences` so `_RootGate` routes to onboarding on cold start.
- Hive archive box starts empty so Dashboard empty state is visible before import.

## Test T1 — Onboarding CTA rebuild (🔴 regression guard)
Cold start → `ConnectAccountScreen` appears.

| Step | Expected |
|---|---|
| Screen loads | Title `CONNECT ACCOUNT`, two source chips, username field, CONNECT button **disabled** (amber outline, no fill) |
| Type `hikaru` in username field | Amber spinner pill appears within ~400 ms |
| Wait ≤ 800 ms | Green `VERIFIED` pill appears **AND** CONNECT button enables (emerald fill) in same frame |
| Tap `SKIP FOR NOW` | Navigates to Home; onboarding flag persisted |

**Failure signature**: pill turns green but CONNECT stays amber/disabled (the exact bug `dff48cb` fixed).

## Test T2 — Home shell (5 tiles + account strip)
After skip, Home screen appears.

- Account strip reads `CONNECT ACCOUNT` in emerald outline (disconnected state since we skipped).
- Exactly five tiles visible: `ENTER LIVE MATCH`, `IMPORT LIVE MATCH`, `ARCHIVED INTEL`, `OPPONENT FORENSICS`, `GLOBAL DASHBOARD`, `APEX ACADEMY`. *(6 tiles total; 5 was stale phrasing — verify 6)*
- Footer reads `APEX AI GRANDMASTER`.
- No yellow overflow stripes.

## Test T3 — Import debounce + QuantumShatterLoader (Tasks 4 + 5)
From Home → `IMPORT LIVE MATCH`.

| Step | Expected |
|---|---|
| Type `hikaru` | After 600 ms idle, list **auto-populates** without tapping FETCH (debounce proof) |
| Observe loader during fetch | `QuantumShatterLoader` visible (emerald shards + electric arcs + pulsing core); **RadarScan is NOT used** (proves Task 5 replacement) |
| Tap first game in list | Scan mode dialog appears |
| Tap `FAST ANALYSIS · D14` | Dialog header reads `Fast Analysis · D14`; QuantumShatterLoader animates behind progress text |

**Failure signature T3**: list stays empty after 600 ms (debounce wiring broken) OR radar sweep appears (old loader still used).

## Test T4 — Neon Move Quality aura on Review (Task 2)
After Fast D14 completes, Review screen opens.

- Scrub to any ply classified Brilliant/Best/Great/Blunder in the quality ribbon.
- **Expected**: the destination square shows a pulsing, vapor-like aura in the correct color (Ruby=brilliant, Electric Blue=great, Emerald=best, Crimson=blunder).
- **Containment**: aura does not bleed into neighbouring squares (the `Positioned.fill` proof).
- Tap back → Archive auto-saved (fire-and-forget hook from PR #6, regression).

## Test T5 — Apex Academy SRS drill (Tasks 3a + 3b)
From Home → `APEX ACADEMY`.

| Step | Expected |
|---|---|
| Screen loads | Header shows streak=0, XP=0, daily quest `0/5` |
| **If drill available** (MistakeVault populated by T3 analysis) | Board locked to mistake FEN, 4 SAN options in 2×2 grid |
| Tap correct option | Emerald glow on correct tile, streak increments to 1, XP +10, "NEXT" appears |
| Tap `NEXT` | Either next drill or "SESSION COMPLETE" state |
| **If no mistakes** (e.g. clean game) | Empty state: `NO DRILLS DUE` with CTA back to Import |

**Failure signature**: drill screen throws (promotion UCI bug would manifest as silent skip / "no drills" despite vault having entries). If we hit this, inspect vault size via Hive dump.

## Test T6 — Global Dashboard (Task 1b)
From Home → `GLOBAL DASHBOARD`.

- 4 KPI cards: Games, Avg Accuracy, Brilliants, Blunders (all non-zero after T3).
- 3 charts render: Line (accuracy trend), Pie (move-quality distribution), Bar (W/D/L split).
- Recent-scans table shows the game from T3 with correct player names + accuracy.
- If >10 games archived, Next/Prev pagination works.

**Failure signature**: charts blank or KPI cards all zero (aggregation broken).

## Test T7 — Opponent Forensics real math + cancel (Task 1c)
From Home → `OPPONENT FORENSICS` → type `hikaru` → FETCH.

| Step | Expected |
|---|---|
| Loading card appears | Progress bar starts at 0 %, text reads `Game 1/5 · ply 0/N · vs <opponent>` (or similar per-ply line) |
| Wait 10 s | Progress text **updates mid-scan** (ply counter advances, not stuck) — proves engine actually analyzing, not 900 ms sleep |
| Tap `CANCEL SCAN` | Cancelled card appears within ~1 s, text reads `SCAN CANCELLED` |

**Failure signature**: progress text frozen (scaffold still returning dummy) OR cancel unresponsive (cancellation token not wired).

---

## Non-assertions
- Audio (VM lacks GStreamer — inconclusive as always).
- Deep D22 scan (too slow for recording; Fast D14 sufficient to exercise loader + aura).
- Full 5-game forensics scan (~3 min; cancel path proves cancellation works, progress updates prove engine is real).
