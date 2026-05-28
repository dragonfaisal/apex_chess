# Local Stockfish Engine Audit

Phase 30B status: local engine reality is explicit, not assumed.

Phase 30C status: stub builds are fail-closed by default, packaging/ABI audit is first-class, and the FFI bridge remains provisional until Android benchmark and lifecycle proof exists.

Phase 30D status: clean Android debug packaging is now ABI-consistent for Stockfish after adding explicit JNI exclusions for non-target ABIs. Android device smoke, stress, and benchmark execution were not run in this workspace because no Android device/emulator was available.

Phase 30E status: Android proof execution remains blocked in this workspace. `flutter devices` showed Windows desktop, Chrome, and Edge only; no Android device/emulator was available, so the opt-in collector was not executed and no Android benchmark rows were captured.

## Current Reality

- Apex has a real local Stockfish integration path: Dart `StockfishEngine` -> worker isolate -> FFI -> `libstockfish_bridge`.
- Real Stockfish source is vendored at `src/native/vendor/Stockfish/src/`.
- The required small NNUE file exists at `src/native/vendor/Stockfish/src/nn-37f18f62d772.nnue`.
- `main.cpp` is patched to expose `extern "C" int stockfish_main(...)`.
- Android CMake metadata in this workspace shows `STOCKFISH_REAL=1`, `APEX_LIGHTWEIGHT_NNUE=1`, and 22 Stockfish source files compiled into `stockfish_bridge`.
- Android `defaultConfig.ndk.abiFilters` targets `arm64-v8a`.
- Android Gradle packaging now excludes non-target JNI libraries for `armeabi-v7a`, `x86`, and `x86_64` so debug APK contents match the declared local-engine ABI.
- A clean Phase 30D rebuild produced a debug APK with `libstockfish_bridge.so` only under `lib/arm64-v8a/`.
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

Phase 30B observed stale/additional `armeabi-v7a` and `x86_64` engine libraries in an existing debug APK. Phase 30D reproduced that mismatch after a clean rebuild, then added explicit JNI packaging exclusions in `android/app/build.gradle.kts`.

Phase 30D clean packaging result after that fix:

```text
status: abi-consistent
configured ABI filters: arm64-v8a
packaged engine ABIs: arm64-v8a
extra packaged ABIs: none
missing packaged ABIs: none
```

## Android Real-Engine Benchmark Collector

Phase 30D added an opt-in integration test collector:

```powershell
flutter test integration_test/local_stockfish_device_benchmark_test.dart -d <android-device-id> --dart-define=APEX_RUN_LOCAL_STOCKFISH_DEVICE_BENCHMARK=true
```

Without `APEX_RUN_LOCAL_STOCKFISH_DEVICE_BENCHMARK=true`, the collector skips safely. It does not require UI interaction and does not add product navigation.

The collector prints JSON and markdown summaries containing:

- platform/device/ABI;
- engine mode and engine identity;
- `uciok` / `readyok` status;
- smoke status for start position, tactical FEN, MultiPV 3, invalid FEN rejection, and repeated dispose;
- lifecycle cycle count and stale-output flags;
- benchmark rows with elapsed ms, parsed depth, nodes, nps, score type, PV count, bestmove, and warnings.

The schema is `AndroidLocalEngineProofResult` plus `AndroidStockfishBenchmarkRow`. Pasted Android rows should be copied from device logs into this doc or a linked engineering note exactly as emitted. Do not invent rows, average rows from memory, or convert a host run into Android proof.

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

Opt-in proof command:

```powershell
flutter test integration_test/local_stockfish_device_benchmark_test.dart -d <android-device-id> --dart-define=APEX_RUN_LOCAL_STOCKFISH_DEVICE_BENCHMARK=true
```

Benchmark plan:

- Positions: start position, tactical middlegame, endgame, mate-threat.
- Targets: movetime 50/100/250/500 ms and depth 10/12/14/16.
- MultiPV: capture 1, 2, and 3 where supported.
- Record: device model, Android version, ABI, elapsed ms, parsed depth, nodes, nps, score type, PV count, bestmove, warnings.

The Dart schema `AndroidStockfishBenchmarkRow` can render pasted Android rows as a markdown table after manual/device collection. This is intentionally separate from host `dart run` output so Android facts are not faked.

## Phase 30D Android Proof Status

Packaging proof:

- `flutter clean` passed.
- `flutter pub get` passed.
- `flutter build apk --debug` passed.
- `dart run tool/local_stockfish_benchmark.dart --audit-packaging` passed with `abi-consistent`.

Device proof:

- `flutter devices` showed only Windows desktop, Chrome, and Edge.
- No Android device or emulator was available in this workspace.
- The opt-in Android collector was not executed on Android.
- Real Android `libstockfish_bridge.so` load, `uciok`, `readyok`, bestmove, PV, MultiPV, lifecycle stress, and benchmark timings remain unproven.

## Phase 30E Device Execution Status

Device availability check:

```text
Found 3 connected devices:
Windows (desktop) - windows-x64
Chrome (web) - web-javascript
Edge (web) - web-javascript
```

No Android device or emulator was visible to Flutter in this workspace.

Result:

- Android proof collector was not executed.
- APK install on Android was not tested.
- Packaged `libstockfish_bridge.so` load on Android was not tested.
- `engineMode == real`, `uciok`, `readyok`, startpos bestmove, tactical PV, MultiPV 3, invalid-FEN rejection on device, lifecycle stress, and benchmark timings remain unproven.
- FFI bridge remains provisional.
- Phase 30F scheduler work must not start from this workspace state.

Owner rerun steps on a machine with a real Android target:

```powershell
cd C:\apex_chess
flutter devices
flutter clean
flutter pub get
flutter build apk --debug
dart run tool/local_stockfish_benchmark.dart --audit-packaging
flutter test integration_test/local_stockfish_device_benchmark_test.dart -d <android-device-id> --dart-define=APEX_RUN_LOCAL_STOCKFISH_DEVICE_BENCHMARK=true
```

Acceptance criteria before scheduler work:

- packaging audit reports `abi-consistent`;
- `engineMode` is `real`;
- engine identity does not contain `ApexChess-Stub`;
- `uciok` and `readyok` are true;
- start position returns a legal-looking bestmove;
- tactical FEN returns a non-empty PV;
- MultiPV 3 returns at least two distinct candidate lines where supported;
- invalid FEN is rejected before engine command;
- at least 20 lifecycle cycles complete;
- no timeout, stale bestmove, queue contamination, crash, or dispose hang occurs;
- benchmark rows exist for every Phase 30B target position and movetime/depth target.

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
- Android device proof has not run in this workspace; only APK packaging is proven.
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

- The current FFI bridge remains provisional because packaging is now clean but target-device lifecycle and benchmark behavior are still unproven.
- It is not final until Android proves real engine load, lifecycle stress, and benchmark behavior.
- If Android device proof fails, Phase 30F should pivot toward a standalone subprocess UCI architecture instead of building a scheduler over an uncertain bridge.
- Browser/WASM is not the immediate Android Flutter path.

## Phase 30F Recommendation

Do not add classifiers, ACPL/accuracy, backend phases, or review scheduling until Android target-device smoke and benchmark results are captured.

Phase 30F should either execute Android proof on a real target or choose the subprocess UCI pivot:

- run Android real-engine smoke and lifecycle loops;
- collect benchmark rows for every target position and movetime/depth target;
- decide whether the FFI bridge is good enough to build a scheduler on, or pivot to subprocess UCI first.
