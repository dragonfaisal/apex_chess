// Copyright (c) Apex Chess authors.
//
// Implementation of the Stockfish C bridge.
//
// The bridge spawns a worker thread that runs the UCI loop and communicates
// with the caller via two line-oriented queues. Two build modes are supported:
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

}  // namespace

struct sf_engine {
  LineQueue to_engine;
  LineQueue from_engine;
  std::thread worker;
  std::atomic<bool> shutting_down{false};
  std::atomic<bool> destroyed{false};
};

// ─────────────────────────────────────────────────────────────────────────────
// Process-wide singleton guard.
//
// Stockfish 17+ keeps its `Threads` ThreadPool — and the std::mutex /
// std::condition_variable members of every worker `Thread` — in a
// translation-unit-static global. Calling `stockfish_main()` a second time
// from a fresh worker (or while a previous worker is still tearing down)
// re-runs `Threads.set(...)` on the same global pool: the old workers'
// mutexes are destroyed by the resize while the workers are still
// pthread_mutex_lock-ing them on the way out. That is the
//
//   F/libc: FORTIFY: pthread_mutex_lock called on a destroyed mutex
//   Fatal signal 6 (SIGABRT)
//
// crash we hit on Android. Serialising the lifetime of *every* sf_engine
// behind one process-wide mutex makes the second `stockfish_create` block
// until the first engine's `stockfish_destroy` has fully drained the
// ThreadPool, which removes the race entirely.
//
// The guard is a recursive-style "only one engine alive" latch: create
// returns NULL if another engine is still alive in this process. Callers
// that want to recreate must `stockfish_destroy` the previous handle
// first; the Dart side already does this on isolate shutdown.
namespace {
std::mutex& EngineSingletonMutex() {
  static std::mutex m;
  return m;
}
std::atomic<sf_engine*>& ActiveEngine() {
  static std::atomic<sf_engine*> e{nullptr};
  return e;
}
}  // namespace

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

static std::string NativeDir() {
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

static void DrainReader(int fd, sf_engine* engine) {
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
      engine->from_engine.Push(std::move(line));
      buf.erase(0, pos + 1);
    }
  }
  if (!buf.empty()) engine->from_engine.Push(std::move(buf));
  close(fd);
}

static void DrainWriter(int fd, sf_engine* engine) {
  std::string line;
  while (engine->to_engine.PopBlocking(&line)) {
    line += '\n';
    ssize_t remaining = static_cast<ssize_t>(line.size());
    const char* p = line.data();
    while (remaining > 0) {
      const auto n = write(fd, p, remaining);
      if (n <= 0) break;
      p += n;
      remaining -= n;
    }
  }
  close(fd);
}

static void RunEngine(sf_engine* engine) {
  const std::string native_dir = NativeDir();
  int in_pipe[2] = {-1, -1};
  int out_pipe[2] = {-1, -1};
  if (pipe(in_pipe) != 0 || pipe(out_pipe) != 0) {
    engine->from_engine.Push("info string bridge_error pipe_create_failed");
    engine->from_engine.Close();
    return;
  }

  const int saved_stdin = dup(STDIN_FILENO);
  const int saved_stdout = dup(STDOUT_FILENO);
  if (saved_stdin < 0 || saved_stdout < 0) {
    engine->from_engine.Push("info string bridge_error stdio_save_failed");
    close(in_pipe[0]);
    close(in_pipe[1]);
    close(out_pipe[0]);
    close(out_pipe[1]);
    if (saved_stdin >= 0) close(saved_stdin);
    if (saved_stdout >= 0) close(saved_stdout);
    engine->from_engine.Close();
    return;
  }

  // Redirect process stdin/stdout to our pipes. See CAVEAT above.
  dup2(in_pipe[0], STDIN_FILENO);
  dup2(out_pipe[1], STDOUT_FILENO);
  close(in_pipe[0]);
  close(out_pipe[1]);

  std::setvbuf(stdout, nullptr, _IOLBF, 0);

  std::thread writer(DrainWriter, in_pipe[1], engine);
  std::thread reader(DrainReader, out_pipe[0], engine);

  std::string arg0 = native_dir.empty() ? "stockfish" : native_dir + "stockfish";
  if (!native_dir.empty()) {
    const std::string eval_cmd =
        "setoption name EvalFile value " + native_dir + "nn-37f18f62d772.nnue";
    const std::string small_eval_cmd = "setoption name EvalFileSmall value " +
                                       native_dir + "nn-37f18f62d772.nnue";
    engine->to_engine.Push(eval_cmd);
    engine->to_engine.Push(small_eval_cmd);
  }
  char* argv[] = {arg0.data(), nullptr};
  stockfish_main(1, argv);

  // Engine returned — flush and restore stdio so future engine instances work.
  std::fflush(stdout);
  dup2(saved_stdin, STDIN_FILENO);
  dup2(saved_stdout, STDOUT_FILENO);
  close(saved_stdin);
  close(saved_stdout);

  // Push a sentinel to unblock the writer.
  engine->to_engine.Close();

  if (writer.joinable()) writer.join();
  if (reader.joinable()) reader.join();
  engine->from_engine.Close();
}

#else  // STOCKFISH_STUB

// Minimal UCI stub so the full Dart pipeline can be tested without the real
// engine. It replies to the handful of commands the app uses today.
static void HandleStubCommand(sf_engine* engine, const std::string& cmd) {
  if (cmd == "uci") {
    engine->from_engine.Push("id name ApexChess-Stub");
    engine->from_engine.Push("id author Apex Chess");
    engine->from_engine.Push("uciok");
  } else if (cmd == "isready") {
    engine->from_engine.Push("readyok");
  } else if (cmd.rfind("go", 0) == 0) {
    engine->from_engine.Push(
        "info depth 1 seldepth 1 multipv 1 score cp 0 nodes 1 nps 1 time 1 "
        "pv e2e4");
    engine->from_engine.Push("bestmove e2e4");
  }
  // Silently accept: ucinewgame, position, setoption, stop, debug, register
}

static void RunEngine(sf_engine* engine) {
  std::string cmd;
  while (!engine->shutting_down.load()) {
    if (!engine->to_engine.PopBlocking(&cmd)) break;
    if (cmd == "quit") break;
    HandleStubCommand(engine, cmd);
  }
  engine->from_engine.Close();
}

#endif  // STOCKFISH_REAL / STOCKFISH_STUB

// ─────────────────────────────────────────────────────────────────────────────
// Public C ABI
// ─────────────────────────────────────────────────────────────────────────────

extern "C" SF_API sf_engine* stockfish_create(void) {
  // Hold the singleton mutex for the lifetime of the create call; the
  // matching unlock happens in stockfish_destroy after the worker has
  // joined. We use a try_lock here so a leaked / still-shutting-down
  // previous engine surfaces as a NULL-return rather than a deadlock.
  if (!EngineSingletonMutex().try_lock()) {
    return nullptr;
  }
  if (ActiveEngine().load(std::memory_order_acquire) != nullptr) {
    EngineSingletonMutex().unlock();
    return nullptr;
  }
  auto* engine = new (std::nothrow) sf_engine();
  if (engine == nullptr) {
    EngineSingletonMutex().unlock();
    return nullptr;
  }
  ActiveEngine().store(engine, std::memory_order_release);
  // Spawn the worker AFTER publishing the active-engine pointer so that
  // any concurrent observer (e.g. a unit test reading the singleton)
  // never sees a half-initialised engine.
  engine->worker = std::thread(RunEngine, engine);
  return engine;
}

extern "C" SF_API void stockfish_destroy(sf_engine* engine) {
  if (engine == nullptr) return;
  // Idempotent: if destroy is called twice (e.g. once by the Dart isolate
  // teardown path and once by a finalizer), the second call is a no-op.
  if (engine->destroyed.exchange(true)) return;

  // Cancel any in-flight search BEFORE asking Stockfish to quit. Without
  // this, `quit` while a `go` search is still running races with the
  // ThreadPool's own teardown of its per-worker mutexes — which is the
  // origin of the destroyed-mutex SIGABRT in production logs.
  if (!engine->shutting_down.exchange(true)) {
    engine->to_engine.Push("stop");
    engine->to_engine.Push("quit");
  }
  // Closing the input queue unblocks DrainWriter / the stub PopBlocking
  // even if the engine somehow swallows "quit" (defence in depth).
  engine->to_engine.Close();

  if (engine->worker.joinable()) engine->worker.join();
  engine->from_engine.Close();

  // Clear the singleton BEFORE deleting so a concurrent stockfish_create
  // observer sees the slot as free as soon as the engine memory is
  // unreachable.
  ActiveEngine().store(nullptr, std::memory_order_release);
  delete engine;
  EngineSingletonMutex().unlock();
}

extern "C" SF_API int stockfish_write(sf_engine* engine,
                                      const char* utf8_line) {
  if (engine == nullptr || utf8_line == nullptr) return -1;
  std::string line(utf8_line);
  while (!line.empty() &&
         (line.back() == '\n' || line.back() == '\r')) {
    line.pop_back();
  }
  const int bytes = static_cast<int>(line.size());
  engine->to_engine.Push(std::move(line));
  return bytes;
}

extern "C" SF_API char* stockfish_read_line(sf_engine* engine,
                                            int timeout_ms) {
  if (engine == nullptr) return nullptr;
  std::string line;
  const bool ok = timeout_ms < 0
                      ? engine->from_engine.PopBlocking(&line)
                      : engine->from_engine.Pop(&line, timeout_ms);
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
  return "apex-stockfish-bridge/0.1.0";
}
