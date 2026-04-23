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
#     UCI commands so the Flutter layer can be exercised end-to-end before the
#     real engine is wired in.
#
#   * REAL: pass `-DSTOCKFISH_SOURCES_DIR=/absolute/path/to/Stockfish/src` when
#     configuring CMake (or set the variable from the parent project). All
#     `.cpp` files in that directory — except `main.cpp` — are compiled into
#     the bridge, and `STOCKFISH_REAL` is defined.
#
# See `src/native/README.md` for end-to-end integration steps.
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

if(DEFINED STOCKFISH_SOURCES_DIR AND EXISTS "${STOCKFISH_SOURCES_DIR}")
  message(STATUS "stockfish_bridge: building with real engine from ${STOCKFISH_SOURCES_DIR}")
  file(GLOB SF_SOURCES CONFIGURE_DEPENDS "${STOCKFISH_SOURCES_DIR}/*.cpp")
  list(FILTER SF_SOURCES EXCLUDE REGEX ".*/main\\.cpp$")
  if(NOT SF_SOURCES)
    message(FATAL_ERROR "STOCKFISH_SOURCES_DIR set but no .cpp files found under ${STOCKFISH_SOURCES_DIR}")
  endif()
  target_sources(stockfish_bridge PRIVATE ${SF_SOURCES})
  target_include_directories(stockfish_bridge PRIVATE "${STOCKFISH_SOURCES_DIR}")
  target_compile_definitions(stockfish_bridge PRIVATE STOCKFISH_REAL=1)
  # Stockfish's `main` is renamed so the bridge can drive the UCI loop itself.
  # The user is expected to patch `main.cpp` to expose `stockfish_main` and
  # the `stockfish_bridge_set_io` hook — see src/native/README.md.
else()
  message(STATUS "stockfish_bridge: building STUB engine (no STOCKFISH_SOURCES_DIR provided)")
  target_compile_definitions(stockfish_bridge PRIVATE STOCKFISH_STUB=1)
endif()

if(MSVC)
  target_compile_options(stockfish_bridge PRIVATE /W3 /EHsc)
  target_compile_definitions(stockfish_bridge PRIVATE _CRT_SECURE_NO_WARNINGS)
else()
  target_compile_options(stockfish_bridge PRIVATE -Wall -Wextra -fno-exceptions -fno-rtti)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Android")
  find_library(log-lib log)
  target_link_libraries(stockfish_bridge PRIVATE ${log-lib})
endif()

set_target_properties(stockfish_bridge PROPERTIES
  OUTPUT_NAME "stockfish_bridge"
  PREFIX "lib"
)
