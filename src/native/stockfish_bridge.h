// Copyright (c) Apex Chess authors.
//
// Minimal C ABI around the Stockfish UCI engine, designed for consumption from
// Dart via `dart:ffi`. A single bridge instance owns a background engine
// thread and two line-buffered pipes (stdin / stdout). The ABI is intentionally
// small so the Dart side can stay stable even if the underlying engine source
// is upgraded.
//
// Thread-safety: `stockfish_write` and `stockfish_read_line` may be called
// concurrently from different threads for the same handle, but each function
// must be serialized with respect to itself (i.e. one writer, one reader).
// `stockfish_destroy` must not be called while other threads are still
// operating on the handle.
#ifndef APEX_CHESS_STOCKFISH_BRIDGE_H_
#define APEX_CHESS_STOCKFISH_BRIDGE_H_

#include <stddef.h>

#if defined(_WIN32)
#  define SF_API __declspec(dllexport)
#else
#  define SF_API __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

// Opaque handle to a running engine instance.
typedef struct sf_engine sf_engine;

// Create and start a new engine instance. Returns NULL on failure. The engine
// is ready to receive UCI commands as soon as this call returns.
SF_API sf_engine* stockfish_create(void);

// Destroy the engine instance. Sends a "quit" command, joins the worker
// thread, and frees all resources. Safe to call with NULL.
SF_API void stockfish_destroy(sf_engine* engine);

// Write a UCI command to the engine. A trailing newline is appended if not
// present. Returns the number of bytes written, or -1 on error.
SF_API int stockfish_write(sf_engine* engine, const char* utf8_line);

// Read one line of output from the engine. Blocks up to `timeout_ms`
// milliseconds waiting for a complete line. Returns a newly-allocated UTF-8
// C-string (without trailing newline) that the caller must free via
// `stockfish_free_string`. Returns NULL on timeout or shutdown.
SF_API char* stockfish_read_line(sf_engine* engine, int timeout_ms);

// Free a string previously returned by `stockfish_read_line`. Safe on NULL.
SF_API void stockfish_free_string(char* s);

// Semantic version of the bridge ABI. Bump when the surface changes.
SF_API const char* stockfish_bridge_version(void);

#ifdef __cplusplus
}
#endif

#endif  // APEX_CHESS_STOCKFISH_BRIDGE_H_
