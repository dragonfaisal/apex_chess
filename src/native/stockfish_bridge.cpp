// Copyright (c) Apex Chess authors.
//
// Implementation of the Stockfish C bridge.
//
// ─────────────────────────────────────────────────────────────────────────────
// WHY A PROCESS-PERSISTENT ENGINE
// ─────────────────────────────────────────────────────────────────────────────
//
// Stockfish 17+ keeps its `Threads` ThreadPool — and the std::mutex /
// std::condition_variable members of every worker `Thread` — in
// translation-unit-static globals. Calling `stockfish_main()` a SECOND TIME
// after it has returned from a previous "quit" re-runs `Threads.set(...)` on
// the same statics. In production on Android we observed this re-destroying
// mutexes while worker threads were still unwinding pthread_mutex_lock on
// them, producing:
//
//     F/libc: FORTIFY: pthread_mutex_lock called on a destroyed mutex
//     Fatal signal 6 (SIGABRT)
//
// An earlier mitigation tried to serialise create/destroy with a single
// std::mutex (lock in create, unlock in destroy). That design is *also* UB:
// the Dart side spawns a fresh worker Isolate (⇒ fresh native thread) for
// every new `StockfishEngine`, which means the `std::mutex::unlock` in
// `stockfish_destroy` runs on a different thread than the `lock` in
// `stockfish_create` — std::mutex explicitly forbids that.
//
// The fix here is structural: **we call `stockfish_main()` exactly once per
// process lifetime**. sf_engine becomes a thin, singleton-gated session
// handle:
//
//   * `stockfish_create()` blocks (on a condition variable — properly
//     cross-thread) until the previous session has released the gate, lazy-
//     spawns the persistent worker on first use, resets engine state with
//     `stop` + `ucinewgame` + `isready`, and returns a fresh handle.
//
//   * `stockfish_destroy()` cancels any in-flight search with `stop` and
//     releases the session gate. It does NOT kill the persistent worker —
//     the engine keeps running for the rest of the process lifetime.
//
// This makes the destroyed-mutex SIGABRT structurally impossible because
// the ThreadPool is only ever initialised once.
//
// Two build modes are supported:
//
//   * STOCKFISH_STUB (default when `STOCKFISH_SOURCES_DIR` is not provided at
//     configure time): a minimal UCI-ish stub that responds to `uci`,
//     `isready`, `ucinewgame`, `position`, `go`, and `quit`. This lets the
//     Dart / Flutter layer be exercised end-to-end before the real engine is
//     integrated.
//
//   * Real Stockfish: define `STOCKFISH_REAL` and link against the Stockfish
//     translation units. The upstream `main` entrypoint is renamed to
//     `stockfish_main` (see `CMakeLists.txt`) and invoked on the worker
//     thread, with its std::cin / std::cout rebound to the bridge's queues.
#include "stockfish_bridge.h"

#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <mutex>
#include <string>
#include <thread>

namespace {

// A blocking line queue used by both directions of the bridge.
class LineQueue {
 public:
  void Push(std::string line) {
    std::lock_guard<std::mutex> lock(mutex_);
    queue_.emplace_back(std::move(line));
    cv_.notify_one();
  }

  // Pop up to `timeout_ms` milliseconds. Returns false on timeout or shutdown.
  bool Pop(std::string* out, int timeout_ms) {
    std::unique_lock<std::mutex> lock(mutex_);
    const auto deadline =
        std::chrono::steady_clock::now() +
        std::chrono::milliseconds(timeout_ms < 0 ? 0 : timeout_ms);
    while (queue_.empty() && !closed_) {
      if (timeout_ms < 0) {
        cv_.wait(lock);
      } else if (timeout_ms == 0) {
        return false;
      } else if (cv_.wait_until(lock, deadline) == std::cv_status::timeout) {
        return false;
      }
    }
    if (queue_.empty()) return false;
    *out = std::move(queue_.front());
    queue_.pop_front();
    return true;
  }

  // Blocking pop with no timeout. Returns false only on shutdown.
  bool PopBlocking(std::string* out) {
    std::unique_lock<std::mutex> lock(mutex_);
    cv_.wait(lock, [&] { return !queue_.empty() || closed_; });
    if (queue_.empty()) return false;
    *out = std::move(queue_.front());
    queue_.pop_front();
    return true;
  }

  void Close() {
    std::lock_guard<std::mutex> lock(mutex_);
    closed_ = true;
    cv_.notify_all();
  }

 private:
  std::mutex mutex_;
  std::condition_variable cv_;
  std::deque<std::string> queue_;
  bool closed_ = false;
};

// ─────────────────────────────────────────────────────────────────────────────
// Process-persistent engine state.
//
// Exactly one of these exists for the process lifetime. It owns the line
// queues the session handles talk through and the worker thread that runs
// `stockfish_main()` (or the stub loop).
// ─────────────────────────────────────────────────────────────────────────────
struct PersistentEngine {
  LineQueue to_engine;
  LineQueue from_engine;
  std::once_flag start_flag;
  std::atomic<bool> started{false};
};

PersistentEngine& Persistent() {
  static PersistentEngine p;
  return p;
}

// Session gate — ensures at most one sf_engine* is "active" at a time.
//
// Implemented with a std::mutex + std::condition_variable + bool rather
// than a plain std::mutex held across create/destroy so the lock and the
// unlock can legally happen on different native threads (the Dart side
// spawns a fresh Isolate thread per StockfishEngine; the previous engine's
// destroy therefore races with the new engine's create on potentially
// distinct threads, which would be UB for std::mutex).
std::mutex& GateMutex() {
  static std::mutex m;
  return m;
}

std::condition_variable& GateCv() {
  static std::condition_variable cv;
  return cv;
}

bool& GateActive() {
  static bool active = false;  // guarded by GateMutex().
  return active;
}

// Forward declaration — concrete worker bodies are defined below per build
// mode (STOCKFISH_REAL vs STOCKFISH_STUB).
void RunPersistentWorker();

void EnsurePersistentStarted() {
  auto& p = Persistent();
  std::call_once(p.start_flag, []() {
    std::thread(RunPersistentWorker).detach();
    Persistent().started.store(true, std::memory_order_release);
  });
}

// Best-effort drain of stale engine output between sessions. Each session
// ends with an in-flight `stop`, after which Stockfish emits a final
// `bestmove` line plus any trailing `info` chatter. Draining here ensures
// the next session starts with a clean from_engine queue and its handshake
// isn't confused by leftovers from the previous session.
void DrainStaleOutput() {
  std::string discarded;
  while (Persistent().from_engine.Pop(&discarded, 0)) {}
}

// Issue the reset handshake at the start of a new session.
//
// We intentionally do NOT block on `readyok` here: on a cold start
// Stockfish can take a few seconds to load NNUE weights and the caller
// is expected to run its own `isready` handshake anyway (the test suite
// and `StockfishEngine` both do). Pushing `stop` + `ucinewgame` is
// enough to guarantee a clean slate; stale from_engine lines left over
// from the previous session are drained non-blockingly so they don't
// leak into the new session's event stream.
void QuiesceAtSessionStart() {
  auto& p = Persistent();
  DrainStaleOutput();
  p.to_engine.Push("stop");
  p.to_engine.Push("ucinewgame");
}

}  // namespace

struct sf_engine {
  std::atomic<bool> destroyed{false};
};

// ─────────────────────────────────────────────────────────────────────────────
// Worker implementations
// ─────────────────────────────────────────────────────────────────────────────

#if defined(STOCKFISH_REAL)
// Real Stockfish integration.
//
// The bridge keeps Stockfish's sources untouched except for renaming the
// upstream `int main(int, char**)` to `extern "C" int stockfish_main(...)`
// (done by `scripts/fetch_stockfish.sh`). All UCI I/O is shuttled through
// two OS pipes that we attach to the process's fd 0 / fd 1 at worker-thread
// startup — so `std::getline(std::cin, …)` and `std::cout << …` inside the
// engine implicitly route through the bridge without any source patches.
//
// CAVEAT: dup2 on STDIN/STDOUT is process-wide. Flutter's own logging on
// Android/iOS does not use raw stdout (it goes via platform loggers), so
// this is safe in production. On desktop `flutter run`, Dart `print()` may
// also land on stdout — which means while the engine is running, some
// `print()` output may be captured by the bridge reader. Production builds
// are unaffected; in debug builds, prefer the STUB engine for diagnostics.

#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#if defined(_WIN32)
  #include <io.h>
  #define pipe(fds) _pipe(fds, 65536, _O_BINARY)
  #define read      _read
  #define write     _write
  #define close     _close
  #define dup       _dup
  #define dup2      _dup2
  #define STDIN_FILENO  0
  #define STDOUT_FILENO 1
#endif
#if !defined(_WIN32)
  #include <dlfcn.h>
#endif

extern "C" int stockfish_main(int argc, char** argv);

namespace {

std::string NativeDir() {
#if defined(_WIN32)
  return {};
#else
  Dl_info info{};
  if (dladdr(reinterpret_cast<void*>(&NativeDir), &info) == 0 ||
      info.dli_fname == nullptr) {
    return {};
  }

  std::string path(info.dli_fname);
  const auto slash = path.find_last_of('/');
  return slash == std::string::npos ? std::string() : path.substr(0, slash + 1);
#endif
}

void DrainReaderFd(int fd) {
  auto& p = Persistent();
  std::string buf;
  char chunk[4096];
  while (true) {
    const auto n = read(fd, chunk, sizeof(chunk));
    if (n <= 0) break;
    buf.append(chunk, static_cast<size_t>(n));
    size_t pos;
    while ((pos = buf.find('\n')) != std::string::npos) {
      std::string line = buf.substr(0, pos);
      // Trim trailing CR for Windows line endings.
      if (!line.empty() && line.back() == '\r') line.pop_back();
      p.from_engine.Push(std::move(line));
      buf.erase(0, pos + 1);
    }
  }
  if (!buf.empty()) p.from_engine.Push(std::move(buf));
}

void DrainWriterFd(int fd) {
  auto& p = Persistent();
  std::string line;
  while (p.to_engine.PopBlocking(&line)) {
    line += '\n';
    ssize_t remaining = static_cast<ssize_t>(line.size());
    const char* ptr = line.data();
    while (remaining > 0) {
      const auto n = write(fd, ptr, remaining);
      if (n <= 0) break;
      ptr += n;
      remaining -= n;
    }
  }
}

void RunPersistentWorker() {
  const std::string native_dir = NativeDir();
  int in_pipe[2] = {-1, -1};
  int out_pipe[2] = {-1, -1};
  if (pipe(in_pipe) != 0 || pipe(out_pipe) != 0) {
    Persistent().from_engine.Push(
        "info string bridge_error pipe_create_failed");
    return;
  }

  // Redirect process stdin/stdout to our pipes. Done exactly once per
  // process — we never restore, because the engine is persistent.
  dup2(in_pipe[0], STDIN_FILENO);
  dup2(out_pipe[1], STDOUT_FILENO);
  close(in_pipe[0]);
  close(out_pipe[1]);

  std::setvbuf(stdout, nullptr, _IOLBF, 0);

  // Drain helpers run for the full process lifetime too.
  std::thread(DrainWriterFd, in_pipe[1]).detach();
  std::thread(DrainReaderFd, out_pipe[0]).detach();

  std::string arg0 = native_dir.empty() ? "stockfish" : native_dir + "stockfish";
  // Only point Stockfish at an on-disk NNUE *if the file is actually
  // readable at that path*. On Android, files dropped into `jniLibs/`
  // beside the .so are not always extracted to `nativeLibraryDir` at
  // install time (the platform only guarantees `lib*.so` is). Pushing
  // `setoption name EvalFile value <bogus path>` made Stockfish 17
  // fall through unpredictably — sometimes it loads the incbin-embedded
  // weights, sometimes its NNUE init aborts the process. Skipping the
  // setoption when the file is missing forces the embedded path, which
  // is what `APEX_STOCKFISH_USE_NNUE=ON` (the default in CMakeLists) is
  // built for.
  if (!native_dir.empty()) {
    const std::string nnue_path = native_dir + "nn-37f18f62d772.nnue";
    struct stat st{};
    if (::stat(nnue_path.c_str(), &st) == 0 && S_ISREG(st.st_mode)) {
      Persistent().to_engine.Push(
          "setoption name EvalFile value " + nnue_path);
      Persistent().to_engine.Push(
          "setoption name EvalFileSmall value " + nnue_path);
    } else {
      // Surface a single diagnostic line on the engine output channel so
      // the Dart side can see in logs that we deliberately fell back to
      // the embedded NNUE (vs. the on-disk one).
      Persistent().from_engine.Push(
          "info string apex_bridge nnue_on_disk=missing path=" + nnue_path);
    }
  }
  char* argv[] = {arg0.data(), nullptr};
  // stockfish_main returns only if the engine receives "quit" at process
  // exit. The bridge never sends "quit" from stockfish_destroy any more,
  // so in practice this call never returns during normal app use.
  stockfish_main(1, argv);
}

}  // namespace

#else  // STOCKFISH_STUB

namespace {

// Minimal UCI stub so the full Dart pipeline can be tested without the real
// engine. It replies to the handful of commands the app uses today.
void HandleStubCommand(const std::string& cmd) {
  auto& p = Persistent();
  if (cmd == "uci") {
    p.from_engine.Push("id name ApexChess-Stub");
    p.from_engine.Push("id author Apex Chess");
    p.from_engine.Push("uciok");
  } else if (cmd == "isready") {
    p.from_engine.Push("readyok");
  } else if (cmd.rfind("go", 0) == 0) {
    p.from_engine.Push(
        "info depth 1 seldepth 1 multipv 1 score cp 0 nodes 1 nps 1 time 1 "
        "pv e2e4");
    p.from_engine.Push("bestmove e2e4");
  }
  // Silently accept: ucinewgame, position, setoption, stop, debug, register
}

void RunPersistentWorker() {
  auto& p = Persistent();
  std::string cmd;
  // The stub worker runs for the full process lifetime. It never breaks on
  // "quit" because that would leave the to_engine queue unclaimed for any
  // subsequent session; tests expect stockfish_destroy + stockfish_create
  // to cycle cleanly.
  while (p.to_engine.PopBlocking(&cmd)) {
    if (cmd == "quit") continue;
    HandleStubCommand(cmd);
  }
}

}  // namespace

#endif  // STOCKFISH_REAL / STOCKFISH_STUB

// ─────────────────────────────────────────────────────────────────────────────
// Public C ABI
// ─────────────────────────────────────────────────────────────────────────────

extern "C" SF_API sf_engine* stockfish_create(void) {
  // Wait for any previous session to release the gate. Unlike the previous
  // try_lock() design, this cleanly serialises back-to-back recreations
  // without surfacing spurious "couldn't create engine" errors to the UI.
  {
    std::unique_lock<std::mutex> lock(GateMutex());
    GateCv().wait(lock, [] { return !GateActive(); });
    GateActive() = true;
  }

  auto* engine = new (std::nothrow) sf_engine();
  if (engine == nullptr) {
    {
      std::lock_guard<std::mutex> lock(GateMutex());
      GateActive() = false;
    }
    GateCv().notify_one();
    return nullptr;
  }

  // Lazy-spawn the persistent worker on first use. Subsequent sessions
  // reuse the same worker — this is the core of the destroyed-mutex fix.
  EnsurePersistentStarted();

  // Reset engine state so the new session starts from a known baseline
  // even if the previous session left a search or custom position behind.
  QuiesceAtSessionStart();

  return engine;
}

extern "C" SF_API void stockfish_destroy(sf_engine* engine) {
  if (engine == nullptr) return;
  // Idempotent: if destroy is called twice (e.g. once by the Dart isolate
  // teardown path and once by a finalizer), the second call is a no-op.
  if (engine->destroyed.exchange(true)) return;

  // Cancel any in-flight search so its `bestmove` doesn't leak into the
  // NEXT session's event stream. The persistent worker — and therefore
  // Stockfish's ThreadPool — is NOT torn down; the next create() will
  // reuse it.
  Persistent().to_engine.Push("stop");

  delete engine;

  {
    std::lock_guard<std::mutex> lock(GateMutex());
    GateActive() = false;
  }
  GateCv().notify_one();
}

extern "C" SF_API int stockfish_write(sf_engine* engine,
                                      const char* utf8_line) {
  if (engine == nullptr || utf8_line == nullptr) return -1;
  if (engine->destroyed.load(std::memory_order_acquire)) return -1;
  std::string line(utf8_line);
  while (!line.empty() &&
         (line.back() == '\n' || line.back() == '\r')) {
    line.pop_back();
  }
  const int bytes = static_cast<int>(line.size());
  Persistent().to_engine.Push(std::move(line));
  return bytes;
}

extern "C" SF_API char* stockfish_read_line(sf_engine* engine,
                                            int timeout_ms) {
  if (engine == nullptr) return nullptr;
  std::string line;
  const bool ok = timeout_ms < 0
                      ? Persistent().from_engine.PopBlocking(&line)
                      : Persistent().from_engine.Pop(&line, timeout_ms);
  if (!ok) return nullptr;
  char* out = static_cast<char*>(std::malloc(line.size() + 1));
  if (out == nullptr) return nullptr;
  std::memcpy(out, line.data(), line.size());
  out[line.size()] = '\0';
  return out;
}

extern "C" SF_API void stockfish_free_string(char* s) {
  std::free(s);
}

extern "C" SF_API const char* stockfish_bridge_version(void) {
  return "apex-stockfish-bridge/0.3.0";
}
