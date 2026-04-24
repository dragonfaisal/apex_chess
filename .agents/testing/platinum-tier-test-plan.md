# Platinum Tier (PR #6) — Test Plan

Branch: `devin/1777040014-platinum-tier` (commits `cb69bce`, `97a2968`, `6b9ffc1`)
PR: https://github.com/dragonfaisal/apex_chess/pull/6
Target: Linux desktop debug build (`flutter run -d linux`).

## Scope

Three commits, three features, one recording. Each assertion is chosen so a broken implementation would produce a visibly different result — assertions with exact expected text or numeric values, not "looks right".

**Code traced to:**
- `lib/features/home/presentation/views/home_screen.dart:80-121` — 5 home tiles, exact label/icon wiring.
- `lib/features/archives/presentation/views/archive_screen.dart:78-90` — empty-state copy constants.
- `lib/features/archives/presentation/views/archive_screen.dart:105-135` — re-analyze flow (dialog → analyzer → push ReviewScreen).
- `lib/features/archives/data/archive_save_hook.dart:27-50` — save-on-analyze hook.
- `lib/features/profile_scanner/data/profile_scanner_service.dart:21-72` — deterministic dummy scanner.
- `lib/main.dart:10-17` — Hive init path.

## Deterministic seed math (verified by running Dart locally)

```
hikaru        → seed=363900798  → accuracy=75.79  → clean (green dial)
magnuscarlsen → seed=116455090  → accuracy=89.40  → moderate (amber dial)
penguingm1    → seed=375054367  → accuracy=83.55  → moderate (amber dial)
```

These are exact numbers from `Random(username.hashCode & 0x7fffffff).nextDouble()` in `ProfileScannerService.scan`. Used as pass/fail oracles below.

## Primary flow (single recording, ~3–4 minutes)

### A. Home screen — 5 tiles present, copy correct

1. Cold start the app.
2. **Assertion A1**: home renders **exactly 5 action tiles** in this order:
   - `ENTER LIVE MATCH` (play icon)
   - `IMPORT LIVE MATCH` (cloud_download icon)
   - `QUANTUM DEPTH SCAN` (auto_graph icon)
   - `ARCHIVED INTEL` (inventory_2 icon) **← new**
   - `OPPONENT FORENSICS` (radar icon) **← new**
   - If the bottom two are absent, commit `6b9ffc1` didn't land — fail.
3. **Assertion A2**: footer text reads `Apex AI Grandmaster • On-Device`. A build on the old copy would say `Apex AI Analyst • On-Device` — fail.
4. **Assertion A3**: no `RenderFlex overflowed` in the `flutter run` stdout while the home screen is visible.

### B. Archived Intel empty state

5. Tap **ARCHIVED INTEL** tile.
6. **Assertion B1**: the Archive screen pushes in. Header title reads `ARCHIVED INTEL` (exact casing).
7. **Assertion B2**: body shows the empty state with text: `No archived intel yet. Run a Quantum Scan — results land here automatically.` (exact text from archive_screen.dart:82). If the text is different or the body shows an error card instead, Hive init in main.dart failed — fail.
8. Back to Home.

### C. Import → Fast D14 → save hooks fire → game appears in Archive

9. Tap **IMPORT LIVE MATCH**.
10. Type `hikaru` in the username field → tap `FETCH GAMES`.
11. **Assertion C1**: a list of real game cards renders (Hikaru's recent public games).
12. Tap the first game.
13. Depth picker opens → tap **FAST ANALYSIS (D14)**.
14. **Assertion C2**: the radar sweep rotates behind the progress readout; progress advances monotonically.
15. When the Review Screen renders, note the player names + depth in the header.
16. Navigate back to Home.
17. Tap **ARCHIVED INTEL**.
18. **Assertion C3 (the critical one)**: the game analyzed in step 13 appears as a glass card with:
    - Player names + ratings matching what I saw in step 11.
    - A `D14` depth pill.
    - A source pill reading `CHESS.COM`.
    - Quality counts (brilliant/blunder/mistake) totalling to non-zero plies.
   - If the card is absent, the `unawaited(saveAnalysisToArchive(...))` hook didn't fire — fail.

### D. Re-analyze from Archive → fresh Review screen

19. Tap the Archive card.
20. **Assertion D1**: the `_ReanalysisDialog` appears with the radar sweep (same visual as the first Fast D14 scan, not a bare spinner).
21. When analysis completes, the Review Screen pushes in.
22. **Assertion D2**: header shows the same players; at least one ply's classification matches what I saw in step 15 (non-trivial check that the re-analysis produced plausibly identical output on the same PGN).

### E. Opponent Forensics — deterministic hikaru oracle

23. Navigate back to Home → tap **OPPONENT FORENSICS**.
24. **Assertion E1**: screen title reads `OPPONENT FORENSICS`; subtitle reads `Calibrate an opponent's move quality against the Apex AI baseline.`
25. Type `hikaru` → tap `INITIATE SCAN`.
26. **Assertion E2**: radar sweep spins for ~900ms, then result card renders.
27. **Assertion E3 (the deterministic oracle)**: the Suspicion Dial shows:
    - **Accuracy: `75.79` ±0.01** (exact seed-derived value).
    - Ring color: **green (clean)** — NOT amber, NOT red.
    - Label: `CLEAN` (from `SuspicionLevel.clean.label`).
   - If any of these three differ, the service isn't deterministic or the color mapping is wrong — fail.
28. **Assertion E4**: below the dial, 10 sample game rows render with per-game accuracy bars.

### Stop recording.

## Out-of-scope (explicitly untested)

- Filters on Archive screen (sort/result/min-brilliants) — covered by code review, one primary flow only.
- Cross-restart Hive persistence — covered by the save hook contract; restart is heavy for a recording.
- Scanner dial for other usernames — the deterministic oracle on `hikaru` is decisive enough.
- Quantum D22 path — Fast D14 is faster and exercises the same wiring.

## What a broken build looks like

- Missing bottom 2 home tiles → A1 fails visibly.
- Old copy strings → A2 / E1 fail visibly (different text).
- Hive init crash → B1/B2 fail with an error card instead of empty state.
- Save hook misfired → C3 fails (no card in archive).
- Re-analyze regression → D1/D2 fail with a different dialog or wrong navigation.
- Dummy service nondeterministic → E3 fails with a different accuracy value.
