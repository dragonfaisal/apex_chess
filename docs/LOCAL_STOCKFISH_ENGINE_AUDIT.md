# Local Stockfish Engine Audit

Phase 30B status: local engine reality is explicit, not assumed.

## Current Reality

- Apex has a real local Stockfish integration path: Dart `StockfishEngine` -> worker isolate -> FFI -> `libstockfish_bridge`.
- Real Stockfish source is vendored at `src/native/vendor/Stockfish/src/`.
- The required small NNUE file exists at `src/native/vendor/Stockfish/src/nn-37f18f62d772.nnue`.
- `main.cpp` is patched to expose `extern "C" int stockfish_main(...)`.
- Android CMake metadata in this workspace shows `STOCKFISH_REAL=1`, `APEX_LIGHTWEIGHT_NNUE=1`, and 22 Stockfish source files compiled into `stockfish_bridge`.
- Android `defaultConfig.ndk.abiFilters` targets `arm64-v8a`.
- Existing debug artifacts contain `libstockfish_bridge.so` for `arm64-v8a`. The current debug APK in this workspace also contains stale/additional `armeabi-v7a` and `x86_64` engine libraries, so rebuild/packaging should be rechecked before release.
- The Windows host used for this audit cannot load `stockfish_bridge.dll`, so host benchmark rows are unavailable unless a host bridge is built and put on the loader path.

## Stub Status

The native bridge still contains an explicit `STOCKFISH_STUB` fallback. If `STOCKFISH_SOURCES_DIR` is absent at configure time, CMake can build a UCI stub that reports `ApexChess-Stub`, constant `score cp 0`, depth/nodes `1`, and `bestmove e2e4`.

This stub path is now detected by:

- source marker checks for `STOCKFISH_STUB`, `ApexChess-Stub`, and constant `cp 0` / `e2e4` output;
- runtime benchmark checks for stub UCI id;
- behavioral checks for same bestmove, constant cp, and immediate no-search responses across unrelated positions.

The stub was not removed in this phase because it is part of the native bridge build fallback. It should not be accepted silently for analysis builds.

## Architecture Summary

- `StockfishEngine` spawns a dedicated Dart isolate.
- The worker isolate owns the FFI handle and polls native output without blocking the UI isolate.
- `stockfish_bridge.cpp` starts a process-persistent Stockfish worker once and gates sessions to avoid repeated Stockfish static thread-pool teardown crashes.
- `LocalEvalService` serializes searches, sends `stop` / `isready` / `ucinewgame`, sets sticky `MultiPV`, validates FEN before UCI, and normalizes engine scores to White perspective for review/domain callers.

This architecture is good enough for controlled smoke and benchmark work, but it is not yet a final world-class engine substrate. The bridge redirects process stdin/stdout for real Stockfish, keeps process-global state alive, and needs more target-device lifecycle proof before Phase 30C builds scheduling on top of it.

## Parser And Score Contract

- UCI parser handles `depth`, `seldepth`, `multipv`, `score cp`, `score mate`, score bounds, `nodes`, `nps`, `time`, `pv`, `currmove`, `currmovenumber`, `bestmove`, id, options, `uciok`, and `readyok`.
- Unknown UCI tokens are ignored safely.
- Sparse `info` lines are accepted without assuming every field exists.
- Mate scores are not parsed as centipawns.
- Internal raw `EngineInfo.scoreCp` / `scoreMate` are side-to-move scores.
- `LocalEvalService` converts scores to White perspective before returning `EvalSnapshot` and `EngineLine`.

## FEN Guard

`validateFenForEngineCommand` rejects empty, partial, malformed, bad-rank-width, invalid-piece, invalid-side, invalid-castling, invalid-en-passant, invalid-clock, and control-character FENs before `position fen` reaches Stockfish.

## Benchmark Command

Run:

```powershell
dart run tool/local_stockfish_benchmark.dart
```

The command prints:

- engine mode: `real`, `unavailable`, or `stub-detected`;
- platform/ABI;
- target position count;
- movetime/depth rows when a real engine is loadable;
- average/max elapsed ms;
- parsed depth;
- score type `cp`/`mate`;
- MultiPV support;
- warnings;
- next recommendation.

On this Windows host during the audit, the command reported `engine mode: unavailable` because `stockfish_bridge.dll` was not on the host loader path. It did not fake benchmark success.

## Benchmark Targets

The harness defines:

- start position;
- tactical middlegame FEN;
- endgame FEN;
- mate-threat FEN.

For each target it can run:

- movetime 50 ms, 100 ms, 250 ms, 500 ms;
- depth 10, 12, 14, 16.

The full benchmark is opt-in and not part of normal fast tests.

## Optional Real-Engine Tests

Optional smoke tests live in:

```powershell
flutter test test/features/pgn_review/infrastructure/local_stockfish_benchmark_test.dart
```

They skip unless the current host can load the bridge library. To enable them on a host, build the native bridge for that host and put the output directory on the loader path before running Flutter tests. On Windows, that means a loadable `stockfish_bridge.dll`; on Linux, `libstockfish_bridge.so` via `LD_LIBRARY_PATH`.

The smoke tests verify:

- `uciok` and `readyok`;
- legal-looking startpos bestmove;
- tactical FEN returns non-empty PV;
- MultiPV returns at least two candidate lines when supported.

## Known Risks

- The stub fallback is still selectable at native configure time.
- Host benchmark facts are unavailable until a host bridge is built or the harness is run on Android.
- Existing debug APK contents include extra ABI libraries outside the current `arm64-v8a` filter; rebuild output should be checked before release packaging.
- The real bridge uses process-level stdin/stdout redirection and a process-persistent worker. This should be stress-tested on Android before scheduling many concurrent review jobs around it.
- Current tests prove parser, FEN, stub guards, and fake-engine benchmark behavior; they do not prove Android target-device speed on this machine.

## Phase 30C Recommendation

Do not add classifiers, ACPL/accuracy, backend phases, or review scheduling until Android target-device smoke and benchmark results are captured.

Phase 30C should focus on hardening the local engine substrate:

- make stub builds fail closed for analysis/release configurations;
- run the benchmark on target Android hardware;
- decide whether to keep the current process-persistent FFI bridge or rebuild around a stricter subprocess/isolate engine architecture;
- only then design the local-first review scheduler.
