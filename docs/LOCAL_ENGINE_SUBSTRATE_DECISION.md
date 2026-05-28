# Local Engine Substrate Decision

Status: provisional, pending Android target benchmark and lifecycle proof.

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

- Clean Android rebuild with only configured engine ABIs packaged.
- Android smoke: `uciok`, `readyok`, startpos bestmove, tactical PV, MultiPV 3.
- Android lifecycle loop: repeated start/search/stop/dispose cycles without hangs, crashes, stale bestmoves, or queue contamination.
- Android benchmark rows for all Phase 30B target positions and movetime/depth targets.

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

Continue with the current FFI bridge only as a provisional Phase 30D candidate. It is not final enough for a smart scheduler until Android proves packaging, lifecycle, and benchmark behavior.

If Android proof fails, Phase 30D should pivot to a subprocess-based UCI prototype instead of trying to hide bridge risk behind scheduling logic.

Current recommendation:

- Short term: harden and benchmark the existing FFI bridge on Android.
- Medium term: keep a subprocess prototype on the roadmap as the safer architecture if process-global stdio redirection or native crash behavior remains risky.
- Do not add classifier, ACPL, or scheduler work until one engine substrate is proven.
