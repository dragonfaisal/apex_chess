# PR #8 Test Plan — depth-picker copy + username existence validation

**PR:** https://github.com/dragonfaisal/apex_chess/pull/8
**Branch:** `devin/1777047385-copy-and-username-validation`
**Target:** Linux desktop debug build.

## What changed (user-visible)

1. **Scan-mode header** — the analysis progress dialog now reads `Fast Analysis · D14` for Fast and `Quantum Deep Scan · D22` for Quantum. Previously both read `Quantum Deep Scan` regardless.
2. **Username existence pill** — the Import Match and Opponent Forensics username fields now show an inline pill at the trailing edge: green `verified` when the user exists, red `not found` on 404, amber spinner while debouncing/loading, nothing on network errors. Debounced 400 ms, minimum 2 chars. Re-validates on source toggle.

## Adversarial oracles (pre-computed via curl from this VM)

| Username | Chess.com | Lichess |
|---|---|---|
| `hikaru` | 200 | 200 |
| `lichess_fan` | 200 | **404** |
| `apexchess_nope` | 404 | 404 |

`lichess_fan` is the source-toggle proof: a broken `didUpdateWidget` path would keep the pill green after flipping Chess.com→Lichess.

## Primary flow (single recording)

### Phase 1 — Import Match pill states
1. Home → `IMPORT LIVE MATCH`.
2. Type `h` → **Assert P1a**: no pill, no network call (< 2 chars).
3. Continue typing `hikaru`, stop, wait 500 ms.
4. **Assert P1b**: pill transitions amber spinner → green `verified` chip.
5. Clear field, type `apexchess_nope`, wait 500 ms.
6. **Assert P1c**: pill renders red `not found` chip.
7. Clear field, type `lichess_fan`, wait 500 ms.
8. **Assert P1d**: pill is green `verified` (Chess.com source active).
9. Tap the **Lichess** source pill (field retains `lichess_fan`).
10. **Assert P1e**: pill re-resolves and flips to red `not found` within ~1 s.
11. Tap **Chess.com** back.
12. **Assert P1f**: pill flips back to green `verified`.

### Phase 2 — Opponent Forensics pill
13. Back to home → `OPPONENT FORENSICS`.
14. Type `apexchess_nope`, wait 500 ms.
15. **Assert P2a**: red `not found` pill on the scanner field.
16. Clear, type `hikaru`, wait 500 ms.
17. **Assert P2b**: green `verified` pill.

### Phase 3 — Depth-picker header copy (Fast)
18. Back to home → `IMPORT LIVE MATCH` → `hikaru` → Fetch → tap first game.
19. Depth picker opens. Tap **Fast Analysis** (D14).
20. **Assert P3a**: scanning dialog header reads exactly `Fast Analysis · D14` (icon + text). The literal string `Quantum Deep Scan · D14` would mean `scanHeader` didn't route.

### Phase 4 — Depth-picker header copy (Quantum)
21. Close the dialog (X or back) once Fast header is verified. Re-open depth picker on any game.
22. Tap **Quantum Deep Scan** (D22).
23. **Assert P4a**: scanning dialog header reads exactly `Quantum Deep Scan · D22`. Let engine run ~10 s to confirm the header stays correct, then cancel.

## Pass/fail criteria summary

| # | Assertion | Expected | Failure signal |
|---|---|---|---|
| P1a | < 2 chars | no pill | pill appears |
| P1b | `hikaru` / Chess.com | green `verified` | red, spinner-stuck, or blank |
| P1c | `apexchess_nope` | red `not found` | green |
| P1d | `lichess_fan` / Chess.com | green `verified` | red |
| P1e | `lichess_fan` / Lichess (after toggle) | red `not found` | pill stays green (didUpdateWidget regression) |
| P1f | `lichess_fan` / Chess.com (toggle back) | green `verified` | pill stays red |
| P2a | `apexchess_nope` / Scanner | red `not found` | green |
| P2b | `hikaru` / Scanner | green `verified` | red |
| P3a | Fast dialog header | `Fast Analysis · D14` | `Quantum Deep Scan · D14` |
| P4a | Quantum dialog header | `Quantum Deep Scan · D22` | `Fast Analysis · D22` |

## Evidence plan
- Single screen recording with structured annotations (setup, test_start, assertion per phase).
- Key screenshots: each pill state, Fast header, Quantum header.

## Code grounding
- Pill widget: <ref_file file="/home/ubuntu/repos/apex_chess/lib/features/user_validation/presentation/widgets/username_validation_pill.dart" />
- Controller + debounce: <ref_file file="/home/ubuntu/repos/apex_chess/lib/features/user_validation/presentation/username_validation_controller.dart" />
- Import wiring: `import_match_screen.dart:445-509` (didUpdateWidget on source change)
- Scanner wiring: `profile_scanner_screen.dart:32-70`
- Copy fix: `apex_copy.dart:68-73` (scanHeader), `import_match_screen.dart:1299`, `home_screen.dart:466`
