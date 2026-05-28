# Local Engine Substrate Decision

Status: provisional. Clean Android APK packaging is proven for `arm64-v8a`, but Android target benchmark and lifecycle proof are still pending.

## Option A: Current FFI Bridge And Persistent Native Worker

Pros:

- Already integrated into the Flutter engine layer.
- Keeps UCI traffic off the UI isolate through a Dart worker isolate.
- Android real-engine build path exists and current CMake metadata shows real Stockfish sources compiled.
- Likely fastest path if Android lifecycle stress and benchmark data are clean.

Cons:

- Real mode redirects process-level stdin/stdout.
- A native crash can still terminate the Flutter process.
- The process-persistent worker and session gate are complex and must be stress-tested on target devices.
- Host benchmark proof is unavailable on Windows until a host bridge is built.
- Tight native linking needs continued license review before distribution.

Required proof before building scheduling on this path:

- Done in Phase 30D: clean Android rebuild with only configured Stockfish ABI packaged.
- Still required: Android smoke with `uciok`, `readyok`, startpos bestmove, tactical PV, and MultiPV 3.
- Still required: Android lifecycle loop with repeated start/search/stop/dispose cycles and no hangs, crashes, stale bestmoves, or queue contamination.
- Still required: Android benchmark rows for all Phase 30B target positions and movetime/depth targets.

## Option B: Standalone Subprocess Plus Dart Isolate Over UCI

Pros:

- Stronger process isolation; an engine crash can be handled as a child-process failure instead of a Flutter process crash.
- Cleaner UCI lifecycle model: start process, write stdin, read stdout, kill process.
- Avoids process-global stdio redirection inside Flutter.
- Easier to reason about one engine process per analysis worker.
- Potentially cleaner license aggregation boundary, subject to legal review.

Cons:

- Android executable packaging and permissions must be validated.
- `Process.start` behavior on Android devices must be proven for Flutter release/profile modes.
- More packaging complexity than a shared library.
- Some I/O overhead versus in-process FFI, although likely acceptable for UCI text traffic.

## Option C: Browser/WASM Engine

Pros:

- Familiar web-style asset model.
- Could share concepts with browser-based local analysis products.

Cons:

- Not the immediate native Android Flutter path.
- WebView/WASM overhead is likely worse than native Stockfish.
- More moving parts for mobile lifecycle, threading, and memory.

## Decision

Continue with the current FFI bridge only as a provisional Phase 30E candidate. Phase 30D proved APK packaging after adding explicit JNI ABI exclusions, but no Android device/emulator was available in this workspace, so real engine load, UCI readiness, lifecycle stress, and speed remain unproven.

If Android proof fails, Phase 30E should pivot to a subprocess-based UCI prototype instead of trying to hide bridge risk behind scheduling logic.

Current recommendation:

- Short term: run the opt-in Android proof collector on a real Android target and preserve the emitted JSON/markdown rows.
- Medium term: keep a subprocess prototype on the roadmap as the safer architecture if process-global stdio redirection or native crash behavior remains risky.
- Do not add classifier, ACPL, or scheduler work until one engine substrate is proven.

Evidence required to allow scheduler work on the FFI bridge:

- `engineMode: real`, with engine identity not containing `ApexChess-Stub`.
- `uciok` and `readyok` observed on Android.
- Start position returns a legal-looking bestmove.
- Tactical FEN returns a non-empty PV.
- MultiPV 3 returns at least two distinct candidate lines when supported.
- At least 20 lifecycle cycles complete without timeout, stale bestmove reuse, queue contamination, or dispose hang.
- Benchmark rows exist for start, tactical middlegame, endgame, and mate-threat positions across the Phase 30B movetime/depth targets.
