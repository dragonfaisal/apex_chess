# Local Stockfish Engine Audit

Phase 30B status: local engine reality is explicit, not assumed.

Phase 30C status: stub builds are fail-closed by default, packaging/ABI audit is first-class, and the FFI bridge remains provisional until Android benchmark and lifecycle proof exists.

Phase 30D status: clean Android debug packaging is now ABI-consistent for Stockfish after adding explicit JNI exclusions for non-target ABIs. Android device smoke, stress, and benchmark execution were not run in this workspace because no Android device/emulator was available.

Phase 30E status: Android proof execution remains blocked in this workspace. `flutter devices` showed Windows desktop, Chrome, and Edge only; no Android device/emulator was available, so the opt-in collector was not executed and no Android benchmark rows were captured.

Phase 30F status: owner-provided S22 Ultra Android proof is now consolidated with the separate clean packaging proof. The local FFI bridge is provisionally approved for the Phase 30G scheduler prototype, not final production architecture.

Phase 30G status: the first pure local smart scheduler prototype now exists as a budgeted planning layer. It does not add UI, backend work, persistence, official accuracy, ACPL, or final move labels.

Phase 30H status: a thin local scheduler executor now consumes scheduler decisions and calls the engine only through `LocalEvalService`. It adds serial execution telemetry and safe failure handling, but still does not add full-game scheduling, UI, persistence, official accuracy, ACPL, or final move labels.

Phase 30I status: the measured local review prototype now applies the scheduler executor across a serial list of positions, aggregates review-level telemetry, and enforces position, engine-call, elapsed-time, and fail-fast budgets. It still does not add UI, backend work, persistence, official accuracy, ACPL, or final move labels.

Phase 30J status: the local review orchestration experiment now maps scheduler-ready inputs, parsed review positions, or PGN-derived positions into measured local review. It returns developer telemetry and future deep-gating observations only; product-facing review output, classifier behavior, official accuracy, ACPL, UI, backend, and persistence remain unchanged.

Phase 30K status: the game-level deep-gating experiment now ranks and suppresses deferred deep-analysis candidates after a fast pass or provided evidence. It keeps execution behind the orchestration/measured/executor/`LocalEvalService` stack and still does not add product labels, official metrics, UI, backend work, or persistence.

Phase 30L status: representative deep-gating budget tuning now runs as a pure local report model over compact scheduler-ready scenarios and profile matrices. It requires no real engine in normal tests and still does not add product labels, official metrics, UI, backend work, or persistence.

Phase 30M status: a developer-only local review integration experiment now compares pure deep-candidate plans, fast-pass measured execution, and selected-deep execution under explicit local budget presets. It remains non-UI, non-persistent, local-first, and keeps product review output unchanged.

Phase 30N status: compact PGN-derived local integration fixtures now compare eco, balanced, performance, owner, low-power, and fake-engine execution modes through `LocalReviewIntegrationExperiment`. The comparison remains developer-only, serial, local-first, and does not change product review output.

Phase 30O status: an opt-in Android PGN fixture selected-deep smoke collector now exists for real-device execution through the existing local review stack. Normal validation still uses fake/local-safe execution; no new Android smoke rows were captured by adding the collector.

Phase 30R status: the Golden Evidence Review report command exposes deterministic markdown/JSON evidence gaps and real-device-needed references without Android, real-engine loading, UI, backend, persistence, official metrics, or final move labels.

Phase 30S status: the golden suite now has expanded internal motif taxonomy, broad motif-to-evidence expectations, and report coverage for motif evidence gaps without changing engine access, UI, backend, persistence, official metrics, or product labels.

Phase 30T status: Golden Evidence Triage now creates a deterministic developer proof queue and weak motif coverage recommendations without running Android, loading real Stockfish, or adding product labels.

Phase 30U status: an opt-in Golden Owner Android Proof Queue now runs triage-selected golden cases through the existing local stack only when explicitly enabled, producing safe proof reports without product labels or normal-test engine requirements.

Phase 30V status: owner-run S22 Ultra golden proof output is now ingested as static developer evidence for three proven cases, clearing only those real-device proof needs while keeping incomplete golden evidence visible.

Phase 30W status: five compact handcrafted golden hard cases expand weak motif coverage while keeping quiet preparatory gaps incomplete and avoiding Android execution, direct engine access, product labels, official metrics, UI, backend, or persistence changes.

Phase 30X status: the Evidence-to-Classifier Readiness Gate reports developer-only classifier foundation readiness from existing golden evidence while keeping product labels, advanced labels, UI, backend, persistence, direct engine access, and Android execution blocked.

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

This architecture is now proven enough for a controlled local scheduler prototype on one Android target. It is not yet a final world-class engine substrate. The bridge redirects process stdin/stdout for real Stockfish, keeps process-global state alive, and still needs broader device, thermal, battery, and long-session proof before production sign-off.

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

Phase 30F adds a consolidated approval gate that separates:

- packaging proof: `missing`, `abiConsistent`, or `abiMismatch`;
- device proof: `missing`, `passed`, or `failed`;
- approval recommendation: `needsPackagingProof`, `needsDeviceProof`, `approvedForSchedulerPrototype`, or `pivotToSubprocessRecommended`.

This avoids treating `artifact-missing` from inside the integration-test runtime as a blocker when a separate host-side packaging audit has already passed.

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

## Phase 30F Proof Consolidation

Stored proof record:

```text
test/fixtures/local_stockfish/android_proof/s22_ultra_phase_30e.json
```

Packaging proof was captured separately with:

```powershell
flutter build apk --debug
dart run tool/local_stockfish_benchmark.dart --audit-packaging
```

Packaging result:

- status: `abi-consistent`;
- configured ABI: `arm64-v8a`;
- packaged Stockfish ABI: `arm64-v8a`;
- extra ABIs: none;
- missing ABIs: none.

Device proof was captured from an owner run on:

- device: S22 Ultra / `SM S908U1`;
- platform: Android / `android-arm64`;
- Android version: Android 16;
- ABI: `arm64-v8a`.

Collector summary:

- engine mode: `real`;
- engine name: `Stockfish 17`;
- bridge version: `apex-stockfish-bridge/0.3.0`;
- `uciok`: true;
- `readyok`: true;
- startpos bestmove legal-looking: true;
- tactical PV non-empty: true;
- MultiPV supported: true;
- MultiPV 3 distinct: true;
- invalid FEN rejected before engine: true;
- repeated dispose safe: true;
- lifecycle cycles: 20/20;
- stale bestmove detected: false;
- queue contamination detected: false;
- benchmark rows: 139;
- integration test: passed.

The collector-local recommendation was still `needsAndroidProof` because the integration-test runtime could not inspect the host APK artifact and therefore reported packaging as `artifact-missing`. Phase 30F treats this as a false combined recommendation, not as a device failure. The new approval gate combines the separate `abi-consistent` packaging proof with the passed device proof and returns `approvedForSchedulerPrototype`.

Raw benchmark rows were not pasted into this repository fixture. The fixture records the owner-provided row count and proof summary only. A future rerun should preserve the emitted JSON/markdown rows if detailed timing analysis is needed.

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
- Android proof is currently from one S22 Ultra target only; broader device matrix, release/profile mode, thermal behavior, battery impact, and long-session behavior remain unproven.
- The real bridge uses process-level stdin/stdout redirection and a process-persistent worker. Scheduler prototype work must keep stress, timeout, and queue-contamination checks active around it.
- Current tests prove parser, FEN, stub guards, and fake-engine benchmark behavior; they do not prove Android target-device speed on this machine.

## Phase 30C Lifecycle Findings

Phase 30C added fake-engine lifecycle substrate tests:

- repeated FEN analyses are serialized and do not overlap;
- invalid FEN is rejected before engine start/send;
- search timeout returns a safe failure and sends `stop`;
- repeated ready/stop/dispose paths do not hang in fake mode.

What remains unproven after Phase 30F:

- broader Android device behavior beyond the S22 Ultra proof target;
- release/profile mode behavior;
- native crash isolation under long-running scheduler load;
- thermal, battery, and long-session stability.

Phase 30F owner evidence closes the basic real Android smoke and 20-cycle lifecycle gap for one Android target. The remaining lifecycle risks are broader-device and long-duration risks, not immediate blockers for a prototype.

## FFI Vs Subprocess Decision

Decision record: [LOCAL_ENGINE_SUBSTRATE_DECISION.md](LOCAL_ENGINE_SUBSTRATE_DECISION.md).

Summary:

- The current FFI bridge is provisionally approved for a local scheduler prototype because separate packaging proof and S22 Ultra device proof now pass.
- It is not final production architecture until broader Android device, release/profile, thermal, battery, and long-session behavior is proven.
- If scheduler prototyping exposes lifecycle instability, Phase 30G/30H should pivot toward a standalone subprocess UCI architecture instead of masking bridge risk.
- Browser/WASM is not the immediate Android Flutter path.

Phase 30Y status: quiet/preparatory evidence resolution is pure model/report work only; it adds no direct engine calls, no Android collector requirement, and no new real-device proof need.

Phase 30Z status: quiet/preparatory negative guard and scope exclusion are pure model/report work only; they add no direct engine calls, no Android collector requirement, and no new real-device proof need.

Phase 31A status: basic classifier foundation design is pure model/report work only; it adds no direct engine calls, no scheduler/product integration, no Android collector requirement, and no new real-device proof need.

Phase 31B status: basic classifier evidence contract prototyping is pure model/report work only; it adds no direct engine calls, no scheduler/product integration, no Android collector requirement, and no new real-device proof need.

Phase 31C status: internal non-label evidence bucket prototyping is pure model/report work only; it adds no direct engine calls, no scheduler/product integration, no Android collector requirement, and no new real-device proof need.

## Phase 30G Recommendation

Scheduler design: [LOCAL_SMART_SCHEDULER.md](LOCAL_SMART_SCHEDULER.md).

Phase 30G implemented a pure planning layer with strict limits.

Allowed:

- schedule a fast local pass plus controlled deep reanalysis decisions;
- keep all engine calls behind the current local engine service;
- enforce benchmark/time budgets to avoid overheating;
- make scheduler behavior test-driven and device-profile-ready.

Still not allowed:

- Brilliant/Great/Miss classifier changes;
- official ACPL/accuracy calculations;
- backend/server/preflight work;
- persistence/cache/database work;
- public UI activation.

Phase 30H added a thin executor around this planning model while keeping all engine calls behind `LocalEvalService` and preserving the classifier/accuracy layers unchanged. Phase 30I added a measured serial review prototype over the executor. Phase 30J added a local orchestration experiment over measured review outputs. Phase 30K added a game-level deep-gating experiment with pure candidate ranking, budget suppression, and optional selected deep execution through the existing local stack. Phase 30L added pure representative budget tuning so default local integration budgets are selected from measured candidate distributions rather than guesswork. Phase 30M added a developer-only integration experiment over the deep-gating layer; it compares plan-only candidates, fast-pass measurement, and selected-deep execution without changing product review behavior. Phase 30N added compact PGN-derived profile comparisons so the integration path is no longer validated only with synthetic scheduler-ready inputs. Phase 30O added an opt-in real-device selected-deep PGN fixture smoke command that runs through the same local stack and prints safe JSON/markdown telemetry. Phase 30P added Golden Analysis Suite v1 as a pure, license-safe regression and evidence layer for hard analysis cases without adding labels, official metrics, backend work, UI activation, or persistence. Phase 30Q added a pure Golden Evidence Review workflow that marks cases as protected, incomplete, needing future real-device proof, mismatched, or blocked without requiring real Stockfish in normal tests. Phase 30R added a plain-Dart Golden Evidence Review report command that exposes markdown/JSON evidence gaps and real-device-needed references without running Android, loading real Stockfish, adding UI, backend, persistence, official metrics, or final move labels. Phase 30S expanded the internal motif taxonomy and motif-to-evidence policy so evidence gaps are visible as structured developer review data before any classifier work. Phase 30T added deterministic Golden Evidence Triage and an owner proof queue so the next evidence work is explicit before classifier work begins. Phase 30U added an opt-in Android golden proof queue collector for triage-selected cases, with normal tests still fake/local-safe. Phase 30V ingested the owner-run Android proof output as static developer evidence for only the three supported golden cases.
