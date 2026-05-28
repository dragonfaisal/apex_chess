# Local Engine Substrate Decision

Status: provisionally approved for local scheduler prototype after separate clean APK packaging proof plus owner-provided S22 Ultra Android device proof. This is not final production approval.

## Option A: Current FFI Bridge And Persistent Native Worker

Pros:

- Already integrated into the Flutter engine layer.
- Keeps UCI traffic off the UI isolate through a Dart worker isolate.
- Android real-engine build path exists and current CMake metadata shows real Stockfish sources compiled.
- Fastest path for Phase 30G now that the S22 Ultra smoke, lifecycle, and benchmark collector passed.

Cons:

- Real mode redirects process-level stdin/stdout.
- A native crash can still terminate the Flutter process.
- The process-persistent worker and session gate are complex and must be stress-tested on target devices.
- Host benchmark proof is unavailable on Windows until a host bridge is built.
- Current real-device proof covers one Android target only.
- Thermal, battery, release/profile mode, and long-session scheduler behavior remain unproven.
- Tight native linking needs continued license review before distribution.

Required proof before building scheduling on this path:

- Done in Phase 30D: clean Android rebuild with only configured Stockfish ABI packaged.
- Done in owner Phase 30E run: Android smoke with `uciok`, `readyok`, startpos bestmove, tactical PV, and MultiPV 3.
- Done in owner Phase 30E run: Android lifecycle loop completed 20/20 cycles with no stale bestmove or queue contamination.
- Done in owner Phase 30E run: Android benchmark collector emitted 139 rows.
- Still required before production sign-off: broader device matrix, thermal/battery profiling, release/profile mode proof, and long-session scheduler stress.

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

Continue with the current FFI bridge as provisionally approved for the Phase 30G local scheduler prototype. Phase 30D proved APK packaging after adding explicit JNI ABI exclusions. The owner Phase 30E run on an S22 Ultra proved real engine load, UCI readiness, basic lifecycle stress, MultiPV, and benchmark collection on one Android target.

If scheduler prototyping exposes lifecycle instability, queue contamination, native crash behavior, or unacceptable thermal/battery behavior, Phase 30G/30H should pivot to a subprocess-based UCI prototype instead of trying to hide bridge risk behind scheduling logic.

Current recommendation:

- Short term: use the Phase 30G scheduler planning layer documented in [LOCAL_SMART_SCHEDULER.md](LOCAL_SMART_SCHEDULER.md) as the basis for local-only budgeted engine orchestration.
- Medium term: keep a subprocess prototype on the roadmap as the safer architecture if process-global stdio redirection or native crash behavior remains risky.
- Do not add Brilliant/Great/Miss, official ACPL/accuracy, backend work, persistence, or public UI activation in Phase 30G.

Evidence supporting scheduler prototype approval:

- `engineMode: real`, with engine identity not containing `ApexChess-Stub`.
- `uciok` and `readyok` observed on Android.
- Start position returns a legal-looking bestmove.
- Tactical FEN returns a non-empty PV.
- MultiPV 3 returns at least two distinct candidate lines when supported.
- At least 20 lifecycle cycles complete without timeout, stale bestmove reuse, queue contamination, or dispose hang.
- Benchmark collector emitted 139 rows.
- Separate packaging proof reported `abi-consistent` for `arm64-v8a`.

Continuing guardrails:

- Keep stub fail-closed and visibly unsafe for analysis.
- Rerun the Android collector after native bridge, engine, packaging, or scheduler orchestration changes.
- Collect more devices before production approval.
- Keep thermal and battery budgets explicit.
- Keep subprocess UCI as the fallback if FFI bridge lifecycle risk reappears.
