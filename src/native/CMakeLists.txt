# Shared native build for the Stockfish bridge.
#
# This file is included from every platform's CMake project (android, linux,
# windows) via `add_subdirectory`. It produces a single shared library target
# called `stockfish_bridge` that exports a small C ABI consumed by Dart FFI.
#
# Two build modes are supported:
#
#   * STUB (default): only `stockfish_bridge.cpp` is compiled and the
#     `STOCKFISH_STUB` macro is defined. The bridge responds to a handful of
#     UCI commands so the Flutter layer can be exercised end-to-end before
#     the real engine is wired in.
#
#   * REAL: auto-detected when `src/native/vendor/Stockfish/src/` exists.
#     Populated by `scripts/fetch_stockfish.sh`. All `.cpp` files in that
#     directory are compiled into the bridge (except `main.cpp`, which is
#     renamed to `stockfish_main` via the fetch script). The override
#     variable `STOCKFISH_SOURCES_DIR` is still honored for custom layouts.
#
# NNUE handling:
#   `APEX_STOCKFISH_USE_NNUE` (default OFF) controls whether the NNUE weight
#   files are linked into the binary via `incbin`. When OFF, stub `.nnue`
#   files are expected in the Stockfish src/ directory (created by the
#   fetch script); the engine compiles but must be pointed at a real NNUE
#   file at runtime via `setoption name EvalFile value <path>`.
cmake_minimum_required(VERSION 3.14)
project(stockfish_bridge LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

set(BRIDGE_SOURCES
  "${CMAKE_CURRENT_LIST_DIR}/stockfish_bridge.cpp"
)

add_library(stockfish_bridge SHARED ${BRIDGE_SOURCES})
target_include_directories(stockfish_bridge PUBLIC "${CMAKE_CURRENT_LIST_DIR}")

# ── Auto-detect vendored Stockfish. ─────────────────────────────────────────
set(_APEX_VENDORED_SF "${CMAKE_CURRENT_LIST_DIR}/vendor/Stockfish/src")
if(NOT DEFINED STOCKFISH_SOURCES_DIR AND EXISTS "${_APEX_VENDORED_SF}/main.cpp")
  set(STOCKFISH_SOURCES_DIR "${_APEX_VENDORED_SF}")
  message(STATUS "stockfish_bridge: auto-detected vendored Stockfish at ${STOCKFISH_SOURCES_DIR}")
endif()

option(APEX_STOCKFISH_USE_NNUE
       "Embed NNUE weights via incbin (requires real .nnue files in src/)"
       OFF)

if(DEFINED STOCKFISH_SOURCES_DIR AND EXISTS "${STOCKFISH_SOURCES_DIR}")
  message(STATUS "stockfish_bridge: building with real engine from ${STOCKFISH_SOURCES_DIR}")

  # All .cpp files in the top-level src/ directory...
  file(GLOB SF_SOURCES CONFIGURE_DEPENDS "${STOCKFISH_SOURCES_DIR}/*.cpp")
  # ...plus nnue/ and its subdirectories (NNUE code is always compiled; the
  # APEX_STOCKFISH_USE_NNUE flag only controls whether real weights are
  # embedded).
  file(GLOB_RECURSE SF_NNUE_SOURCES CONFIGURE_DEPENDS
       "${STOCKFISH_SOURCES_DIR}/nnue/*.cpp")
  # `syzygy/` tablebase probing.
  file(GLOB SF_SYZYGY_SOURCES CONFIGURE_DEPENDS
       "${STOCKFISH_SOURCES_DIR}/syzygy/*.cpp")

  list(APPEND SF_SOURCES ${SF_NNUE_SOURCES} ${SF_SYZYGY_SOURCES})
  # Stockfish's `main` is renamed by scripts/fetch_stockfish.sh; we still
  # compile main.cpp (it now provides `stockfish_main` which the bridge
  # calls on the worker thread).
  if(NOT SF_SOURCES)
    message(FATAL_ERROR "STOCKFISH_SOURCES_DIR set but no .cpp files found under ${STOCKFISH_SOURCES_DIR}")
  endif()

  target_sources(stockfish_bridge PRIVATE ${SF_SOURCES})
  target_include_directories(stockfish_bridge PRIVATE
    "${STOCKFISH_SOURCES_DIR}"
    "${STOCKFISH_SOURCES_DIR}/nnue"
    "${STOCKFISH_SOURCES_DIR}/syzygy"
  )
  target_compile_definitions(stockfish_bridge PRIVATE STOCKFISH_REAL=1)

  if(NOT APEX_STOCKFISH_USE_NNUE)
    # Stub .nnue files (created by fetch script) satisfy incbin at link
    # time; the engine emits a warning if weights are missing at runtime.
    target_compile_definitions(stockfish_bridge PRIVATE APEX_NO_NNUE_EMBED=1)
    message(STATUS "stockfish_bridge: NNUE weights NOT embedded (stub .nnue files). "
                   "Set APEX_STOCKFISH_USE_NNUE=ON and re-run fetch_stockfish.sh --with-nnue for real weights.")
  else()
    message(STATUS "stockfish_bridge: NNUE weights will be embedded via incbin.")
  endif()

  # Stockfish relies on Makefile build flags that CMake does not forward.
  # Minimum viable flags for a portable build:
  if(NOT MSVC)
    target_compile_options(stockfish_bridge PRIVATE
      -O2
      -DNDEBUG
      -fno-exceptions
      -pthread
    )
  endif()
else()
  message(STATUS "stockfish_bridge: building STUB engine. "
                 "Run `scripts/fetch_stockfish.sh` then reconfigure for real Stockfish.")
  target_compile_definitions(stockfish_bridge PRIVATE STOCKFISH_STUB=1)
endif()

if(MSVC)
  target_compile_options(stockfish_bridge PRIVATE /W3 /EHsc)
  target_compile_definitions(stockfish_bridge PRIVATE _CRT_SECURE_NO_WARNINGS)
else()
  target_compile_options(stockfish_bridge PRIVATE -Wall -Wextra)
endif()

# Pthreads — required for std::thread on Linux/Android.
if(CMAKE_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_SYSTEM_NAME STREQUAL "Android")
  find_package(Threads REQUIRED)
  target_link_libraries(stockfish_bridge PRIVATE Threads::Threads)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Android")
  find_library(log-lib log)
  target_link_libraries(stockfish_bridge PRIVATE ${log-lib})
endif()

set_target_properties(stockfish_bridge PROPERTIES
  OUTPUT_NAME "stockfish_bridge"
  PREFIX "lib"
)
