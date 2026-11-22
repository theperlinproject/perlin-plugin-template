# Toolchain for wasm32 plugins with wasi-sdk (version 25 or newer).
# Only needs WASI_SDK_PATH to point at an unpacked wasi-sdk: <path>/bin/clang and <path>/share/wasi-sysroot.
# It does not use wasi-sdk's own CMake files, whose names and locations change between releases.

set(WASI_SDK_PATH "$ENV{WASI_SDK_PATH}" CACHE PATH "wasi-sdk install folder")
if(NOT WASI_SDK_PATH)
    message(FATAL_ERROR "Set WASI_SDK_PATH to the folder you unpacked wasi-sdk into (it contains bin/ and share/wasi-sysroot).")
endif()
file(TO_CMAKE_PATH "${WASI_SDK_PATH}" WASI_SDK_PATH)

if(CMAKE_HOST_WIN32)
    set(_wasi_exe ".exe")
else()
    set(_wasi_exe "")
endif()
if(NOT EXISTS "${WASI_SDK_PATH}/bin/clang${_wasi_exe}")
    message(FATAL_ERROR "WASI_SDK_PATH=${WASI_SDK_PATH} has no bin/clang${_wasi_exe}; point it at the unpacked wasi-sdk folder.")
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")
set(CMAKE_SYSTEM_NAME WASI)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR wasm32)

set(_wasi_triple wasm32-wasip1)
set(CMAKE_C_COMPILER "${WASI_SDK_PATH}/bin/clang${_wasi_exe}")
set(CMAKE_CXX_COMPILER "${WASI_SDK_PATH}/bin/clang++${_wasi_exe}")
set(CMAKE_AR "${WASI_SDK_PATH}/bin/llvm-ar${_wasi_exe}" CACHE FILEPATH "")
set(CMAKE_RANLIB "${WASI_SDK_PATH}/bin/llvm-ranlib${_wasi_exe}" CACHE FILEPATH "")
set(CMAKE_C_COMPILER_TARGET ${_wasi_triple})
set(CMAKE_CXX_COMPILER_TARGET ${_wasi_triple})
set(CMAKE_SYSROOT "${WASI_SDK_PATH}/share/wasi-sysroot")

# Plugins are reactors with no main(); don't make CMake link a test program.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
