# Local Stockfish Engine Audit

Phase 30B status: local engine reality is explicit, not assumed.

Phase 30C status: stub builds are fail-closed by default, packaging/ABI audit is first-class, and the FFI bridge remains provisional until Android benchmark and lifecycle proof exists.

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

The native bridge still contains an explicit `STOCKFISH_STUB` fallback. The fallback reports `ApexChess-Stub`, constant `score cp 0`, depth/nodes `1`, and `bestmove e2e4`.

Phase 30C changed the CMake policy:

- `APEX_ALLOW_STOCKFISH_STUB` exists and defaults to `OFF`.
- If real Stockfish sources are missing and `APEX_ALLOW_STOCKFISH_STUB` is `OFF`, CMake configuration fails with a clear `FATAL_ERROR`.
- Stub artifacts built with explicit opt-in are marked with `APEX_STOCKFISH_STUB_UNSAFE_FOR_ANALYSIS=1`.
- Stub mode is not acceptable as a real local analysis engine.

This stub path is now detected by:

- source marker checks for `STOCKFISH_STUB`, `ApexChess-Stub`, and constant `cp 0` / `e2e4` output;
- runtime benchmark checks for stub UCI id;
- behavioral checks for same bestmove, constant cp, and immediate no-search responses across unrelated positions.

The stub was not removed because it is useful for explicit development fallback. It is controlled and visible, not silently accepted.

Explicit dev-only stub build:

```powershell
cmake -S src/native -B build/native-stub -DAPEX_ALLOW_STOCKFISH_STUB=ON
```

Do not use that artifact for analysis, benchmarks, QA sign-off, or release.

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

Additional audit modes:

```powershell
dart run tool/local_stockfish_benchmark.dart --audit-only
dart run tool/local_stockfish_benchmark.dart --audit-packaging
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

The host command cannot prove Android speed. It reports host availability and Android packaging facts only.

## Benchmark Targets

The harness defines:

- start position;
- tactical middlegame FEN;
- endgame FEN;
- mate-threat FEN.

For each target it can run:

- movetime 50 ms, 100 ms, 250 ms, 500 ms;
- depth 10, 12, 14, 16.
- MultiPV 1, 2, and 3 should be captured on Android target hardware.

The full benchmark is opt-in and not part of normal fast tests.

## Android Packaging And ABI Audit

The audit reads Gradle `abiFilters` and, when a debug APK exists, inspects `lib/<abi>/libstockfish_bridge.so` entries.

Current policy:

- Normal unit tests do not fail only because stale local APK artifacts exist.
- The audit reports `artifact-missing`, `abi-consistent`, or `abi-mismatch`.
- Extra packaged ABIs and missing configured ABIs are listed as warnings.

Clean packaging verification runbook:

```powershell
cd C:\apex_chess
flutter clean
flutter pub get
flutter build apk --debug
dart run tool/local_stockfish_benchmark.dart --audit-packaging
```

Expected clean result: configured ABI filters and packaged `libstockfish_bridge.so` ABIs match. With the current Gradle config that means `arm64-v8a` only.

Phase 30B observed stale/additional `armeabi-v7a` and `x86_64` engine libraries in an existing debug APK. Phase 30C keeps that mismatch visible but does not fake a clean rebuild.

## Android Real-Engine Benchmark Runbook

Android benchmark facts must be captured on a real device or emulator that runs the packaged native bridge.

Build/install baseline:

```powershell
cd C:\apex_chess
flutter clean
flutter pub get
flutter build apk --debug
flutter install
```

Benchmark plan:

- Positions: start position, tactical middlegame, endgame, mate-threat.
- Targets: movetime 50/100/250/500 ms and depth 10/12/14/16.
- MultiPV: capture 1, 2, and 3 where supported.
- Record: device model, Android version, ABI, elapsed ms, parsed depth, nodes, nps, score type, PV count, bestmove, warnings.

The Dart schema `AndroidStockfishBenchmarkRow` can render pasted Android rows as a markdown table after manual/device collection. This is intentionally separate from host `dart run` output so Android facts are not faked.

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

- The stub fallback is still selectable only by explicit CMake opt-in.
- Host benchmark facts are unavailable until a host bridge is built or the harness is run on Android.
- Existing debug APK contents include extra ABI libraries outside the current `arm64-v8a` filter; rebuild output should be checked before release packaging.
- The real bridge uses process-level stdin/stdout redirection and a process-persistent worker. This should be stress-tested on Android before scheduling many concurrent review jobs around it.
- Current tests prove parser, FEN, stub guards, and fake-engine benchmark behavior; they do not prove Android target-device speed on this machine.

## Phase 30C Lifecycle Findings

Phase 30C added fake-engine lifecycle substrate tests:

- repeated FEN analyses are serialized and do not overlap;
- invalid FEN is rejected before engine start/send;
- search timeout returns a safe failure and sends `stop`;
- repeated ready/stop/dispose paths do not hang in fake mode.

What remains unproven:

- real Android repeated start/search/stop/dispose loops;
- process-global stdio behavior under Flutter Android logging;
- native crash isolation;
- stale bestmove leakage under real engine stress.

## FFI Vs Subprocess Decision

Decision record: [LOCAL_ENGINE_SUBSTRATE_DECISION.md](LOCAL_ENGINE_SUBSTRATE_DECISION.md).

Summary:

- The current FFI bridge is a provisional Phase 30D candidate because it already exists and Android real CMake metadata is present.
- It is not final until Android proves packaging, lifecycle, and benchmark behavior.
- If Android proof fails, Phase 30D should pivot toward a standalone subprocess UCI architecture instead of building a scheduler over an uncertain bridge.
- Browser/WASM is not the immediate Android Flutter path.

## Phase 30D Recommendation

Do not add classifiers, ACPL/accuracy, backend phases, or review scheduling until Android target-device smoke and benchmark results are captured.

Phase 30D should focus on Android proof:

- run the clean packaging verification runbook;
- run Android real-engine smoke and lifecycle loops;
- collect benchmark rows for every target position and movetime/depth target;
- decide whether the FFI bridge is good enough to build a scheduler on, or pivot to subprocess UCI first.
