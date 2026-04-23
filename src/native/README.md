# `stockfish_bridge` native sources

Thin C-ABI shim that wraps the Stockfish UCI engine so it can be driven from
Dart via `dart:ffi`. The Dart side of this lives under
[`lib/core/infrastructure/engine/`](../../lib/core/infrastructure/engine/).

## Layout

```
src/native/
├── CMakeLists.txt          # Builds libstockfish_bridge (shared)
├── stockfish_bridge.h      # Public C ABI (opened via DynamicLibrary.open)
├── stockfish_bridge.cpp    # Worker thread + blocking line queues
├── vendor/Stockfish/       # Vendored engine (gitignored; fetched via script)
└── README.md               # This file
```

The same `CMakeLists.txt` is pulled in from every platform folder
(`android/app/src/main/cpp/CMakeLists.txt`, `linux/CMakeLists.txt`,
`windows/CMakeLists.txt`). A single shared library called
`libstockfish_bridge.{so,dll,dylib}` is produced and loaded at runtime.

## Build modes

### Stub (default)

By default the bridge compiles **only** `stockfish_bridge.cpp` with the
`STOCKFISH_STUB` macro defined. The stub understands enough of the UCI
protocol (`uci` / `isready` / `go` / `quit`) to exercise the full
Flutter → Isolate → FFI → worker round-trip before the real engine is wired
in. This keeps the Dart pipeline testable with zero external dependencies.

### Real engine — one command

From the repo root:

```bash
scripts/fetch_stockfish.sh           # vendor Stockfish 17, no NNUE weights
cmake -S src/native -B build/native  # auto-detects vendor/Stockfish
cmake --build build/native -j
```

What the fetch script does:

1. Shallow-clones `https://github.com/official-stockfish/Stockfish.git` at
   the `${APEX_STOCKFISH_TAG:-sf_17}` tag into `src/native/vendor/Stockfish/`.
2. Renames `int main(int, char**)` → `extern "C" int stockfish_main(...)` in
   `src/main.cpp` (the one and only source patch — Stockfish's UCI I/O is
   redirected via OS pipes, not patched inline).
3. Creates stub `.nnue` files (empty) so `incbin` can link. Pass
   `--with-nnue` to download the real weights (~70 MB).

Version bumping: `APEX_STOCKFISH_TAG=sf_18 scripts/fetch_stockfish.sh --force`.

### Why pipes, not source patches?

The worker thread creates two anonymous pipes and `dup2`s them onto the
process's `STDIN_FILENO` / `STDOUT_FILENO` before calling `stockfish_main()`.
All of Stockfish's `std::getline(std::cin, …)` and `std::cout << …` calls
then route transparently through the bridge's queues. This means we vendor
upstream Stockfish with a single one-line patch (the `main` rename) instead
of a sprawling unified diff that drifts every release.

Caveat: `dup2` on stdin/stdout is process-wide. On Android/iOS Flutter
never writes to raw stdout (its loggers use platform channels), so this is
safe. In debug builds on desktop, `print()` from Dart may land on stdout
and be captured by the bridge reader while the engine is running — prefer
the STUB for diagnostic work on desktop.

## NNUE handling

Stockfish 16+ requires NNUE at runtime for reasonable play strength. The
bridge compiles without embedded weights by default:

* `APEX_STOCKFISH_USE_NNUE=OFF` (default) — stub `.nnue` files satisfy
  `incbin` at link time; the engine emits a warning when eval is first
  requested. Load real weights at runtime with:
  `setoption name EvalFile value /path/to/real.nnue`.

* `APEX_STOCKFISH_USE_NNUE=ON` — downloads weights via
  `scripts/fetch_stockfish.sh --with-nnue` and embeds them via `incbin` as
  upstream Stockfish does.

## C ABI

See `stockfish_bridge.h`. In short:

| Function                   | Purpose                                       |
| -------------------------- | --------------------------------------------- |
| `stockfish_create`         | Start a new engine + worker thread.           |
| `stockfish_destroy`        | Send `quit`, join worker, free all memory.    |
| `stockfish_write`          | Enqueue a UCI command.                        |
| `stockfish_read_line`      | Block up to N ms for one line of output.      |
| `stockfish_free_string`    | Free a string returned by `stockfish_read_line`. |
| `stockfish_bridge_version` | Semantic version of the bridge.               |

Threading contract: one writer + one reader is the expected pattern, and the
Dart layer upholds it by keeping all FFI calls on a single dedicated worker
`Isolate`.
