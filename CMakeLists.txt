cmake_minimum_required(VERSION 3.24)

# ---- Change these for your plugin ------------------------------------------------------------------
# PLUGIN_ID is the file name the game sees: <PLUGIN_ID>.wasm / .json / .png in the mods folder.
set(PLUGIN_ID my_plugin)
set(PLUGIN_SOURCES src/plugin.cpp)
set(PLUGIN_MANIFEST ${CMAKE_CURRENT_SOURCE_DIR}/plugin.json)
set(PLUGIN_ICON ${CMAKE_CURRENT_SOURCE_DIR}/plugin.png) # optional, copied if it exists
# ---------------------------------------------------------------------------------------------------

project(${PLUGIN_ID} LANGUAGES C CXX)

# The Perlin SDK. Pin PERLIN_API_TAG to a tag or commit for reproducible builds.
# To use a local checkout instead: -DFETCHCONTENT_SOURCE_DIR_PERLIN_API=/path/to/perlin-api
set(PERLIN_API_TAG main CACHE STRING "perlin-api git tag, branch or commit")
include(FetchContent)
FetchContent_Declare(perlin_api
    GIT_REPOSITORY https://github.com/theperlinproject/perlin-api.git
    GIT_TAG ${PERLIN_API_TAG}
    GIT_SHALLOW TRUE)
FetchContent_MakeAvailable(perlin_api)
include("${perlin_api_SOURCE_DIR}/cmake/PerlinApi.cmake")

if(EMSCRIPTEN OR CMAKE_SYSTEM_NAME STREQUAL "WASI")
    # The real build: <build dir>/<PLUGIN_ID>.wasm plus <PLUGIN_ID>.json next to it.
    perlin_api_add_plugin(${PLUGIN_ID}
        SOURCES ${PLUGIN_SOURCES}
        MANIFEST ${PLUGIN_MANIFEST})
    target_include_directories(${PLUGIN_ID} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src)
    # -mexec-model is a link-time flag; newer clang (wasi-sdk 34+) rejects it when only compiling.
    # perlin_api_add_plugin also passes it to the linker, which is where it takes effect.
    get_target_property(_plugin_copts ${PLUGIN_ID} COMPILE_OPTIONS)
    if(_plugin_copts)
        list(REMOVE_ITEM _plugin_copts -mexec-model=reactor)
        set_property(TARGET ${PLUGIN_ID} PROPERTY COMPILE_OPTIONS ${_plugin_copts})
    endif()
    if(EXISTS "${PLUGIN_ICON}")
        add_custom_command(TARGET ${PLUGIN_ID} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different "${PLUGIN_ICON}" "$<TARGET_FILE_DIR:${PLUGIN_ID}>/${PLUGIN_ID}.png"
            VERBATIM)
    endif()
else()
    # Configured with a normal desktop compiler (an IDE opening the folder, or the `check` preset).
    # This does not make a .wasm; it compiles the sources natively so you get errors and code completion.
    message(STATUS "${PLUGIN_ID}: native compiler, building a compile check only. "
                   "Use `cmake --preset wasm64` (Emscripten) or `cmake --preset wasm32` (wasi-sdk) to get a .wasm.")
    if(MSVC)
        message(WARNING "${PLUGIN_ID}: the Perlin SDK is not tested with MSVC; use clang or gcc for the compile check.")
    endif()
    find_package(Python3 REQUIRED COMPONENTS Interpreter)
    set(gen_dir "${CMAKE_CURRENT_BINARY_DIR}/perlin_gen/${PLUGIN_ID}")
    add_custom_command(OUTPUT "${gen_dir}/mod_settings.hpp"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${gen_dir}"
        COMMAND ${Python3_EXECUTABLE} "${perlin_api_SOURCE_DIR}/tools/perlin_settings.py" "${PLUGIN_MANIFEST}" "${gen_dir}/mod_settings.hpp"
        DEPENDS "${PLUGIN_MANIFEST}" "${perlin_api_SOURCE_DIR}/tools/perlin_settings.py"
        VERBATIM)
    add_library(${PLUGIN_ID}_check OBJECT ${PLUGIN_SOURCES} "${gen_dir}/mod_settings.hpp")
    target_include_directories(${PLUGIN_ID}_check PRIVATE "${gen_dir}" ${CMAKE_CURRENT_SOURCE_DIR}/src)
    target_link_libraries(${PLUGIN_ID}_check PRIVATE perlin::api)
    target_compile_options(${PLUGIN_ID}_check PRIVATE $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:-fno-exceptions -fno-rtti -Wall -Wextra -Wno-attributes>)
    if(APPLE)
        target_compile_definitions(${PLUGIN_ID}_check PRIVATE _LIBCPP_DISABLE_AVAILABILITY)
    endif()
endif()
