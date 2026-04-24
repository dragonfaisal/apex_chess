# Platinum Features + Engine Audit — Test Report

Target commit: `c142c0f` (pre-fixes) → re-verified on `60a5c7d` (post-fixes).
Plan: [platinum-features-test-plan.md](./platinum-features-test-plan.md)
Recording: <https://app.devin.ai/attachments/36397bbc-defd-4cd7-8e81-0f043fb49a32/rec-fffd51b8-adff-48f3-b5aa-a63f98694c6a-subtitled.mp4>

## Methodology

Flutter Linux desktop in debug mode (`flutter run -d linux`). Single
continuous recording covering all 8 planned assertions. App was
quit and relaunched mid-flow to exercise the shared_preferences
persistence path.

## Results

| # | Assertion | Result |
|---|---|---|
| A1 | Home cold start: no `RenderFlex overflowed` | **PASS** |
| A2 | Quantum Deep Scan card: no right overflow at ~260px width | **PASS** |
| A3 | `[apex.engine] uci_eval …` lines with `elapsed_ms ≥ 100` | **INCONCLUSIVE** (stdout forwarding) |
| A4 | Radar sweep rotates continuously during scan | **PASS** |
| A5 | Scroll-to-bottom grows list with footer spinner | **PASS** |
| A6 | Persisted `hikaru` survives quit+relaunch | **PASS** |
| A7 | O-O exercises `ChessSoundType.castle` code path | **PASS** (render) / **INCONCLUSIVE** (audio) |
| A8 | Analysis completes; review renders | **PASS** |

## Evidence

### A2 — Quantum Deep Scan card at ~260 px width
Card renders with `"Quantum Deep ..."` ellipsis, no yellow overflow stripe.
![narrow-width](https://app.devin.ai/attachments/923ccd3b-53b3-4a41-a566-2a3387cf9781/screenshot_df4d046b531a48ca9d0b9a2267b9fcb3.png)

### A5 — Infinite scroll paged beyond the initial 25
List grew past the first archive's games. Second archive ("3w ago")
entries visible at the bottom.
![scroll-pagination](https://app.devin.ai/attachments/6db5cae3-3fd9-407c-98b7-6e0692a087d8/screenshot_68d348e42bc04dbb99904f9a494d4a67.png)

### A6 — Recent searches persist across restart
Session 1: search `hikaru`, dropdown shows entry:
![dropdown-session1](https://app.devin.ai/attachments/9b515449-69f8-4216-9055-0c272be89748/screenshot_025c95d55842493eb581c1e2a6de6e0e.png)

Quit via `q` → `flutter run` again → navigate to Import Match → tap
empty field → dropdown still shows `hikaru`:
![dropdown-session2](https://app.devin.ai/attachments/b4014338-be43-4af8-8e73-6652d3ca7b18/screenshot_1b1356a4008d4ce486771b1978904f5f.png)

### A7 — O-O rendered atomically
King e1 → g1 **and** rook h1 → f1 in one frame. The apex_chess board
treats "click king → click friendly rook" as the castling gesture,
which is what synced the two pieces into a single atomic update.
![castle-complete](https://app.devin.ai/attachments/4924e716-32f6-4c7c-905a-4b4ecc344c1c/screenshot_f12e3a3dce184973be3341e35378d1fe.png)

Audio inconclusive: Linux test VM is missing GStreamer plugins
(`PlatformException(LinuxAudioError, … missing a plug-in …)` on
even the existing `confirmation.mp3`), same baseline as PR #2.
Code path is exercised by definition since the board reached the
castled state.

## Inconclusive items (not failures)

### A3 — `[apex.engine]` log visibility
`developer.log(name: 'apex.engine')` writes to the Dart VM service's
Logging stream. On Linux desktop `flutter run` does **not** forward
those entries to stdout by default — they're visible in Flutter
DevTools. I verified engine health *by proxy* through A4 + A8:

- Fast D14 took **~55 s** for 85 plies (**~1.55 plies/s**) — matches
  the timing baseline measured on PR #3 (recording rec-a29b1787).
- Classifier produced varied real outputs: `Excellent`, `Best Move`,
  `Book` (with ECO pill), including a negative float (`-0.1`) at
  ply 85.
- None of these are observable if the engine were returning instantly
  at depth 1 as the "fake-out" claim would predict.

Both signals together rule out the short-circuit scenario. If you
want the literal log visible in your local terminal, attach
DevTools to `http://127.0.0.1:40791/…/devtools/` and watch the
Logs view with filter `name: apex.engine`.

## Bugs discovered (separate from PR)

### B1 — Live Play bottom overflow at wide landscape (pre-existing)

`ENTER LIVE MATCH` on Linux desktop at 1024×768 shows **`BOTTOM
OVERFLOWED BY 666 PIXEL`**. Board is sized for portrait aspect;
at landscape it extends past the viewport. Workaround: shrink
the window to a portrait aspect (~500×780) — then the board
fits and O-O is reachable.

![live-play-overflow](https://app.devin.ai/attachments/cd7f3e9c-38af-4358-9e2b-2948a5ab523c/screenshot_20c0f0711293444893e5b380d0f854a2.png)

This is pre-existing on `main` (not introduced by PR #5) — my
commits didn't touch `live_play_screen.dart`'s layout. Flagging for
a follow-up PR: the board should be wrapped in a `Center` +
`AspectRatio(1)` inside a `LayoutBuilder` that caps max side to
the shorter of `width` / `height - reservedChrome`.

## Devin Review findings — addressed in 60a5c7d

1. **RED — Chess.com pagination drops games when page fills mid-archive.**
   Cursor now encodes `"archiveIx:rawOffset"`.
2. **YELLOW — Castle-with-check audio inconsistency.**
   `live_play` priority reordered to match `review_audio`.
3. **YELLOW — Radar leading edge invisible.**
   Added `PaintingStyle.stroke`.

Each reply posted individually to the original review thread.

## Pass / fail verdict

**Pass with follow-ups.** 7/8 planned assertions pass or are
verifiable from evidence. A3 is inconclusive for a tooling reason,
not an engine-behaviour reason. B1 is a real bug I found but it
pre-dates PR #5 and is unrelated to the four tasks in scope.
