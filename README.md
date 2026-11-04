# Boku no Natsuyasumi 2 — Native PC Port (early work) | PlayStation 2 Static Recompilation

> [!WARNING]
> This repository does **not** include the game, a disc image/ELF, game assets, a translation patch, generated game code or a precompiled executable.
> You need your own PlayStation 2 disc. See [the full notice](#notice) at the end.

Early work on a port of the PlayStation 2 game *Boku no Natsuyasumi 2: Umi no Bouken-hen* (Japan, "Adventure by the Sea"), built through static recompilation of the Emotion Engine code with [PS2Recomp](https://github.com/ran-j/PS2Recomp). **This public repository is a work-in-progress source kit, not a ready-to-play game download.** The game's MIPS code is translated locally from your own disc; no game executable or generated game code is distributed here.

## How to play

> [!IMPORTANT]
> **There is no ready-to-play download.** This page has only tools: they turn *your own* game disc into a PC game,
> on your computer. The first time takes a while (60-180 minutes on a recent PC), mostly waiting.
> After that, you just double-click to play.

**You need**

- **Windows 10 or 11** (64-bit) with about **32 GB** free. (Linux and Mac: see below.)
- Your own **Boku no Natsuyasumi 2** (PlayStation 2, Japan (SCPS-15026)), as a disc image (`.iso`) made from your disc, or its extracted
  files. Other versions are not accepted; the setup checks this for you.

**Steps**

**Easiest: `Setup.exe`.** Open [Releases](https://github.com/batatinhafcbatatinha-pixel/boku-no-natsuyasumi-2-pc/releases), download **`Setup.exe`** from the newest one and run it.
It downloads this kit (source code only), shows what your PC already has and what is missing on its
*Dependencies* tab, installs what is missing, asks for your `.iso` and builds the game. Afterwards the same
program (and its desktop shortcut) is your launcher: **Play**, and **PC settings** (the same options as F1 in
the game, before it starts). Windows may say it protected your PC because the program is not signed: click
*More info* > *Run anyway*. The program is built by GitHub from [tools/launcher](tools/launcher); nothing from the game is in it.

**Or step by step:**

1. **Download**, one of these two ways:
   <details open><summary><b>Easiest: the ZIP</b></summary>

   Open [Releases](https://github.com/batatinhafcbatatinha-pixel/boku-no-natsuyasumi-2-pc/releases/latest), download **Source code (zip)** and extract it to a short folder, such as
   `C:\Games\boku-no-natsuyasumi-2-pc`.
   </details>
   <details><summary><b>With Git: always the newest version</b></summary>

   ```powershell
   git clone --recursive https://github.com/batatinhafcbatatinha-pixel/boku-no-natsuyasumi-2-pc.git C:\Games\boku-no-natsuyasumi-2-pc
   ```
   To update later: `git pull --recurse-submodules`, then run `Setup.cmd` again.
   </details>

2. **Double-click `Setup.cmd`.** It asks before installing anything, then:
   - installs Python and Microsoft's C++ Build Tools if you don't have them (free; Windows asks for permission once);
   - downloads the other build tools (about 1 GB) **into this folder only**; It also downloads Ghidra and Java (about 0.8 GB more), which find the functions of your game executable.
   - opens a window where you **pick your `.iso`**: it checks the version and copies the game files;
   - builds your PC version, and offers a desktop shortcut.

   If anything stops, run `Setup.cmd` again: finished steps are skipped.

3. **Play:** double-click **`Play-Boku2.cmd`** (or the desktop shortcut).

**In the game:** **F1** opens the PC settings. Controllers and the keyboard work: see [Controls](#controls).

**Problems?** Open an [issue](https://github.com/batatinhafcbatatinha-pixel/boku-no-natsuyasumi-2-pc/issues) with `setup-log.txt` and a screenshot. Never attach game files.

`Setup.cmd` is new: so far it has been tried from a fresh download only with the FIFA Street 3 port. If it stops for you, please open an issue with `setup-log.txt`.

<details><summary><b>Linux and Mac</b></summary>

- **Linux:** works natively (no Wine), but the setup is by hand for now: see [Linux](#linux).
- **Mac:** experimental. Native builds for Apple Silicon and Intel Macs exist but have never been run on a real Mac. Details in [MACOS.md](MACOS.md); if you have a Mac and want to help test, open an issue.

</details>

<details><summary><b>Questions</b></summary>

- **Is this legal?** This page contains no game, only tools. You use the game you already own.
- **Can I share my built game?** No: it contains the game's code. Keep it on your PC.
- **Will it run on my PC?** Any graphics card with DirectX 11 should work. Measured: 56-60 fps on a Ryzen 5 3600 + RTX 3050 Laptop.
- **How do I remove it?** Delete the folder. Python and the Build Tools can be removed in Windows Settings > Apps.

</details>

## Status

- The native executable boots to the title screen, the demo gameplay and New Game, at 56–60 fps on the development PC. It is not validated from start to finish.
- Windows, [Linux](LINUX.md) and [macOS](MACOS.md) builds use the same sources. The macOS build is experimental and has not been run on a real Mac.
- EE (R5900) code: 5,329 functions mapped with Ghidra and recompiled; the entry point the function map missed (`0x20a920`) was recovered, plus 791 gap functions.
- A local CMake adaptation (`project/runtime_memory.cmake`) separates the game heap, the runtime arena, callback stacks and the 1 MiB main stack.
- IOP and VU0 still run through interpreters in the runtime; this is not a fully native port yet.
- The new keyboard, mouse and vibration code has not been run in the game yet.

## Controls

### Controller

Xbox pads and every pad SDL knows work in the game and in the PC settings menu (F1): DualShock 3/4, DualSense, Switch pads, USB adapters for PS2 and original Xbox pads. The build downloads `gamecontrollerdb.txt` (SDL_GameControllerDB) and, on Windows, `SDL3.dll` (both zlib license) next to the executable. Without them the game behaves as before, with the pads raylib sees. Linux and macOS use the mapping database only. No PlayStation pad or adapter has been tried on real hardware yet.

With `SDL3.dll` (Windows) the game also vibrates the pad; **Controller vibration** in F1 turns that off.

### Keyboard and mouse

| Key | PS2 button |
| --- | --- |
| W A S D or arrows | Move |
| Space, C or left mouse button | Circle (confirm) |
| X, Esc, Backspace or right mouse button | Cross (cancel) |
| Z or middle mouse button | Square |
| V | Triangle |
| Q / E | L1 / R1 |
| Shift | L2 / R2 |
| Enter | Start |
| Tab | Select |
| F1 | PC settings |

The mouse only moves the right stick if **Mouse look** is turned on in F1, which also has a **Mouse sensitivity** slider, because the game has no such option.

### PC settings

- **F1** (or Select + Start on a pad) opens the PC settings: display mode, monitor, aspect, picture filter and upscaling (AMD FSR 1.0), VSync, refresh rate, frame limit, graphics card, volume, vibration, FPS counter and menu language, with help text on every row. They are saved in `pc-settings.ini`; the display mode in `video-settings.cfg`.
- **F9:** 1920×1080 window (resizable). **F10:** borderless window at the desktop resolution. **F11** or **Alt+Enter:** fullscreen (1080p).
- **F8:** shows or hides the controls help overlay. **Alt+F4** quits.

## Your game files

Tested with the Japanese disc (`SCPS-15026`) carrying the Hilltop English translation patch v1.2; the patch has not been validated in the port.

```text
SCPS_150.26  ecdac5741e092099e08834ea16b785cdfd70bc750855caa6c4dd28fc689cb6b1  (tested, patched image)
```

Do not upload the disc image, extracted files, the patch, Ghidra databases, generated code or the built executable.

## Building by hand

`Setup.cmd` ([How to play](#how-to-play)) does all of this on Windows. The steps below are for doing it yourself, or on Linux. `Prepare-Build.cmd` does only the preparation (tools, your game, the function lists and the translation from your disc), if you want to compile by hand afterwards.

### Windows

Requirements: Git, Python 3.11+, Visual Studio 2022 or its Build Tools (C++ workload) with CMake and Ninja, [Ghidra](https://github.com/NationalSecurityAgency/ghidra) with the [ghidra-emotionengine-reloaded](https://github.com/chaoticgd/ghidra-emotionengine-reloaded) extension, and your own disc. Keep about 10 GB free. Raylib, FFmpeg, `SDL3.dll` and `gamecontrollerdb.txt` are downloaded by the build.

```powershell
git clone --recurse-submodules <this repository>
cd <the cloned folder>
.\Install-Files.cmd           # your disc into game_files
$env:GHIDRA = "C:\path\to\ghidra"
.\ghidra-export.cmd               # function lists of your own executable
.\build-recompiler.cmd            # PS2Recomp tools from the submodule
python scripts\prepare_game_code.py
.\build-native.cmd                # two compile jobs by default; 6 ran out of memory on a 16 GB PC
.\Play-Boku2.cmd
```

Generated code, Ghidra exports and the executable stay on your PC: do not upload them.

### Linux

See [LINUX.md](LINUX.md): the same sources build natively (GCC or Clang, no Wine).

### macOS

Experimental: see [MACOS.md](MACOS.md).

## Why a native port instead of an emulator

An emulator such as [PCSX2](https://pcsx2.net) recreates the PlayStation 2: it interprets or JIT-translates the Emotion Engine's MIPS code at run time and models the Graphics Synthesizer, the vector units and the I/O processor. That is the right approach for the whole PS2 library. This port takes a different route for one game:

- **Ahead-of-time code.** [PS2Recomp](https://github.com/ran-j/PS2Recomp) translates the game's MIPS code into C++ before you play, and a modern optimizing compiler builds it: no JIT, no warm-up.
- **PC-side improvements in one place.** The PC settings menu (display mode, upscaling with AMD FSR 1.0, frame limit, refresh rate, graphics card, vibration), every SDL controller, the keyboard and the mouse are part of the port.
- **Readable and fixable.** Runtime fixes and game-specific handlers are plain source you can read and change.

The trade-off: it covers only this game, it is early work, and parts of the console (the I/O processor and VU0) still run through interpreters in the runtime. An emulator is the more general and better-tested option.

## What is in this repository

- `scripts/` — game-file extraction and verification, Ghidra export scripts, generation, gap-function and SDK-handler generators, SDK tail-call routing, chunking, native build and smoke test.
- `config/` — recompiler configuration (TOML). Ghidra CSV exports are not included.
- `project/` — CMake project, `main.cpp` and runtime layout adaptations; generated and recovered sources are not included.
- [NOTES.md](NOTES.md) — development log (in Portuguese).

## Credits and licenses

- Port integration and tooling: [batatinhafcbatatinha-pixel](https://github.com/batatinhafcbatatinha-pixel).
- [PS2Recomp](https://github.com/ran-j/PS2Recomp) by ran-j and contributors: recompiler, analyzer and runtime base.
- [Ghidra](https://github.com/NationalSecurityAgency/ghidra) with the [ghidra-emotionengine-reloaded](https://github.com/chaoticgd/ghidra-emotionengine-reloaded) extension, and MAME's `chdman`, used locally.
- Boku no Natsuyasumi 2, its code, trademarks and assets belong to Sony Interactive Entertainment, Millennium Kitchen and the respective rights holders; the English translation belongs to its authors. This project is not affiliated with or endorsed by them.

---

<a id="notice"></a>

**THIS PROJECT DOES NOT INCLUDE THE GAME, A DISC IMAGE/ELF, GAME ASSETS, GENERATED GAME CODE OR A PRECOMPILED GAME EXECUTABLE. YOU MUST PROVIDE YOUR OWN LAWFULLY OBTAINED GAME FILES AND HAVE THE RIGHTS REQUIRED FOR YOUR USE. THIS PROJECT DOES NOT AUTHORIZE COPYRIGHT INFRINGEMENT. ALL GAME RIGHTS BELONG TO THEIR RESPECTIVE OWNERS.**
