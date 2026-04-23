# Android externalNativeBuild entry point for the Stockfish bridge.
#
# Pulls in the cross-platform build rules from `src/native/` so Android, Linux,
# and Windows all produce a library with identical sources and flags.
cmake_minimum_required(VERSION 3.14)
project(apex_chess_native LANGUAGES CXX)

get_filename_component(APEX_REPO_ROOT
  "${CMAKE_CURRENT_SOURCE_DIR}/../../../../.." ABSOLUTE)

add_subdirectory(
  "${APEX_REPO_ROOT}/src/native"
  "${CMAKE_CURRENT_BINARY_DIR}/stockfish_bridge"
)
