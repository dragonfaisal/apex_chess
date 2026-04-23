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

### Real engine

To build against the real Stockfish sources:

1. Clone Stockfish into `src/native/vendor/stockfish` (or anywhere else):

   ```bash
   git clone --depth 1 https://github.com/official-stockfish/Stockfish.git \
       src/native/vendor/stockfish
   ```

2. Patch `src/main.cpp` in the Stockfish tree so the bridge can drive the
   UCI loop:

   * Rename `int main(int argc, char* argv[])` to
     `extern "C" int stockfish_main(int argc, char* argv[])`.
   * Replace every `std::getline(std::cin, cmd)` with a call to the
     `bridge_read` hook.
   * Replace every `std::cout << ... << std::endl;` inside the UCI loop with
     a call to the `bridge_write` hook.
   * Implement the hook registration function:

     ```c++
     extern "C" void stockfish_bridge_set_io(
         std::string (*read_line)(void*),
         void (*write_line)(void*, const char*),
         void* ctx);
     ```

   These hooks are declared in `stockfish_bridge.cpp` under
   `#if defined(STOCKFISH_REAL)`.

3. Configure with `-DSTOCKFISH_SOURCES_DIR=<absolute path to Stockfish/src>`.
   All `.cpp` files in that directory (except `main.cpp`) are compiled into
   the bridge and the `STOCKFISH_REAL` macro is defined.

The exact patching steps will be automated in a follow-up (a `fetchcontent`
block plus a patch file), but are left manual here so the boilerplate does
not prescribe a specific Stockfish revision.

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
