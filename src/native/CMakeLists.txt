# Shared native build for the Stockfish bridge.
#
# This file is included from every platform's CMake project (android, linux,
# windows) via `add_subdirectory`. It produces a single shared library target
# called `stockfish_bridge` that exports a small C ABI consumed by Dart FFI.
#
# Two build modes are supported, but only the real mode is valid for
# analysis/release builds:
#
#   * STUB (explicit development fallback only): only `stockfish_bridge.cpp`
#     is compiled and the `STOCKFISH_STUB` macro is defined. The bridge
#     responds to a handful of UCI commands so the Flutter layer can be
#     exercised end-to-end before the real engine is wired in. This mode is
#     unsafe for analysis and is disabled unless
#     `-DAPEX_ALLOW_STOCKFISH_STUB=ON` is passed deliberately.
#
#   * REAL: auto-detected when `src/native/vendor/Stockfish/src/` exists.
#     Populated by `scripts/fetch_stockfish.sh`. All `.cpp` files in that
#     directory are compiled into the bridge (except `main.cpp`, which is
#     renamed to `stockfish_main` via the fetch script). The override
#     variable `STOCKFISH_SOURCES_DIR` is still honored for custom layouts.
#
# NNUE handling:
#   Apex Chess builds Stockfish in lightweight mobile mode by default: the
#   small NNUE is packaged beside the shared object and loaded at runtime.
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
       ON)
option(APEX_ALLOW_STOCKFISH_STUB
       "Allow the unsafe development-only stub engine when real Stockfish sources are missing"
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
  target_compile_definitions(stockfish_bridge PRIVATE APEX_LIGHTWEIGHT_NNUE=1)

  if(APEX_STOCKFISH_USE_NNUE)
    message(STATUS "stockfish_bridge: lightweight small NNUE embedded via incbin.")
  else()
    target_compile_definitions(stockfish_bridge PRIVATE NNUE_EMBEDDING_OFF=1)
    message(STATUS "stockfish_bridge: lightweight small NNUE copied beside native library.")
  endif()

  set(_APEX_NNUE_SMALL "${STOCKFISH_SOURCES_DIR}/nn-37f18f62d772.nnue")
  foreach(_APEX_NNUE_FILE IN ITEMS "${_APEX_NNUE_SMALL}")
    if(NOT EXISTS "${_APEX_NNUE_FILE}")
      message(FATAL_ERROR "Missing Stockfish NNUE file: ${_APEX_NNUE_FILE}. Run scripts/fetch_stockfish.sh --with-nnue.")
    endif()
    get_filename_component(_APEX_NNUE_NAME "${_APEX_NNUE_FILE}" NAME)
    add_custom_command(TARGET stockfish_bridge POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
              "${_APEX_NNUE_FILE}"
              "$<TARGET_FILE_DIR:stockfish_bridge>/${_APEX_NNUE_NAME}"
      VERBATIM)
  endforeach()

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
  if(NOT APEX_ALLOW_STOCKFISH_STUB)
    message(FATAL_ERROR
      "stockfish_bridge: real Stockfish sources were not found and "
      "APEX_ALLOW_STOCKFISH_STUB is OFF. Stub builds are unsafe for local "
      "analysis/release. Run `scripts/fetch_stockfish.sh --with-nnue` or "
      "configure with `-DAPEX_ALLOW_STOCKFISH_STUB=ON` only for explicit "
      "development fallback.")
  endif()
  message(WARNING "stockfish_bridge: building unsafe STUB engine because "
                  "APEX_ALLOW_STOCKFISH_STUB=ON. Do not use this artifact "
                  "for analysis, benchmarks, release, or QA sign-off.")
  target_compile_definitions(stockfish_bridge PRIVATE STOCKFISH_STUB=1)
  target_compile_definitions(stockfish_bridge PRIVATE
    APEX_STOCKFISH_STUB_UNSAFE_FOR_ANALYSIS=1)
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
