# Perlin plugin template

A starting point for a [Perlin](https://github.com/theperlinproject/perlin-api) plugin: C++23, built with CMake on Windows, macOS or Linux, and compiled automatically by GitHub Actions on every push.

## Start a plugin

1. Click **Use this template → Create a new repository** at the top of this page.
2. In `CMakeLists.txt`, set `PLUGIN_ID` to your plugin's file name (for example `speedometer`). The game loads `<PLUGIN_ID>.wasm`.
3. In `plugin.json`, fill in the name, description, author and any [permissions](https://github.com/theperlinproject/perlin-api/blob/main/docs/manifest.md) your plugin needs.
4. Write your plugin in `src/plugin.cpp`. Add more `.cpp` files to `PLUGIN_SOURCES` in `CMakeLists.txt` as you go.
5. Optional: add a `plugin.png` icon; it is shipped as `<PLUGIN_ID>.png` for the Mods screen.

```
.
├── src/plugin.cpp           your code
├── plugin.json              manifest: name, version, permissions, settings
├── CMakeLists.txt           PLUGIN_ID and source list
├── CMakePresets.json        wasm64 / wasm32 / check builds
└── .github/workflows/       CI build + releases
```

## Build with GitHub Actions (no setup needed)

Every push builds the plugin on Linux, Windows and macOS, for both wasm64 and wasm32. To get the result, open the **Actions** tab, pick the run, and download the `wasm64` artifact (or `wasm32`). Unzip it into your `mods/` folder.

To publish a release, set `version` in `plugin.json`, then push a matching tag:

```
git tag v1.0.0
git push origin v1.0.0
```

The workflow creates a GitHub Release with `<PLUGIN_ID>-v1.0.0.zip` (wasm64, the default) and `<PLUGIN_ID>-v1.0.0-wasm32.zip` attached.

## Build on your own computer

You need [CMake](https://cmake.org/download/) 3.24+, [Ninja](https://ninja-build.org) (`pip install ninja`, `winget install Ninja-build.Ninja`, `brew install ninja` or `apt install ninja-build`), Python 3, and one WebAssembly toolchain.

### wasm64 with Emscripten (default)

Install [emsdk](https://emscripten.org/docs/getting_started/downloads.html), then activate it in your terminal:

| | |
| --- | --- |
| Linux / macOS | `source /path/to/emsdk/emsdk_env.sh` |
| Windows (cmd) | `C:\emsdk\emsdk_env.bat` |
| Windows (PowerShell) | `C:\emsdk\emsdk_env.ps1` |

Then, from this folder:

```
cmake --preset wasm64
cmake --build --preset wasm64
```

The plugin is in `build/wasm64/`: `<PLUGIN_ID>.wasm` and `<PLUGIN_ID>.json` (and the `.png` if you added one).

### wasm32 with wasi-sdk

Download [wasi-sdk](https://github.com/WebAssembly/wasi-sdk/releases) 25 or newer, set `WASI_SDK_PATH` to the folder you unpacked, then:

```
cmake --preset wasm32
cmake --build --preset wasm32
```

The result is in `build/wasm32/`. 32-bit plugins run on every host, including ones without 64-bit memory.

### Install

Copy the files from `build/wasm64/` into `<data dir>/mods/`. Plugins hot-reload when the file changes (Options → Hot Reload On Save) and can be managed from **Pause → Mods**. A plugin that asks for dangerous permissions shows as *Needs approval* until you press **Allow & Enable**.

## Editor support

Opening the folder in VS Code (CMake Tools), CLion or Visual Studio picks up the presets. The `check` preset compiles your plugin with your normal desktop compiler (clang or gcc), which gives you error checking and code completion without a WebAssembly toolchain. It does not produce a `.wasm`.

The wasm presets also write `compile_commands.json` into their build folder for clangd.

## Settings

Settings live in `plugin.json` under `"settings"`. At build time they are turned into a typed header, `<mod_settings.hpp>`, so `settings::show_text` in the example is a real `bool`. See [Settings](https://github.com/theperlinproject/perlin-api/blob/main/docs/settings.md) for all the setting types.

## SDK version

The build fetches perlin-api from its `main` branch. For reproducible builds, pin it to a tag or commit:

```
cmake --preset wasm64 -DPERLIN_API_TAG=<tag or commit>
```

or change the default of `PERLIN_API_TAG` in `CMakeLists.txt`. To build against a local checkout of perlin-api, pass `-DFETCHCONTENT_SOURCE_DIR_PERLIN_API=/path/to/perlin-api`.

## Docs

* [Getting started](https://github.com/theperlinproject/perlin-api/blob/main/docs/getting-started.md)
* [Plugins and the C++ API](https://github.com/theperlinproject/perlin-api/blob/main/docs/cpp-api.md)
* [Every operation and event](https://github.com/theperlinproject/perlin-api/blob/main/docs/API.md)
* [Manifest and permissions](https://github.com/theperlinproject/perlin-api/blob/main/docs/manifest.md)
