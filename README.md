# Boku no Natsuyasumi 2 — Native PC Port (early work) | PlayStation 2 Static Recompilation

> [!WARNING]
> This repository does **not** include the game, a disc image/ELF, game assets, a translation patch, generated game code or a precompiled executable.
> You need your own PlayStation 2 disc. See [the full notice](#notice) at the end.

Early work on a port of the PlayStation 2 game *Boku no Natsuyasumi 2: Umi no Bouken-hen* (Japan, "Adventure by the Sea"), built through static recompilation of the Emotion Engine code with [PS2Recomp](https://github.com/ran-j/PS2Recomp). **This public repository is a work-in-progress source snapshot, not a ready-to-play game download or a self-contained build kit.** The game's MIPS code is translated locally from your own disc; no game executable or generated game code is distributed here.

## Status

- The native executable boots to the title screen, the demo gameplay and New Game, at 56–60 fps on the development PC. It is not validated from start to finish.
- Windows, [Linux](LINUX.md) and [macOS](MACOS.md) builds use the same sources. The macOS build is experimental and has not been run on a real Mac.
- EE (R5900) code: 5,329 functions mapped with Ghidra and recompiled; the entry point the function map missed (`0x20a920`) was recovered, plus 791 gap functions.
- A local CMake adaptation (`project/runtime_memory.cmake`) separates the game heap, the runtime arena, callback stacks and the 1 MiB main stack.
- IOP and VU0 still run through interpreters in the runtime; this is not a fully native port yet.
- The new keyboard, mouse and vibration code has not been run in the game yet.

## What is in this repository

- `scripts/` — game-file extraction and verification, Ghidra export scripts, generation, gap-function and SDK-handler generators, SDK tail-call routing, chunking, native build and smoke test.
- `config/` — recompiler configuration (TOML). Ghidra CSV exports are not included.
- `project/` — CMake project, `main.cpp` and runtime layout adaptations; generated and recovered sources are not included.
- [NOTES.md](NOTES.md) — development log (in Portuguese).

The scripts expect the author's local workspace (`../third_party/PS2Recomp` and a local build directory). On Windows the CMake project also takes raylib and FFmpeg from a sibling `codwaw-ff/build/game` folder, with downloads turned off, so a fresh clone stops at configure time. There is no one-step build yet: you also need Ghidra exports of your own disc to generate the game code.

## Your game files

Tested with the Japanese disc (`SCPS-15026`) carrying the Hilltop English translation patch v1.2; the patch has not been validated in the port.

```text
SCPS_150.26  ecdac5741e092099e08834ea16b785cdfd70bc750855caa6c4dd28fc689cb6b1  (tested, patched image)
```

Do not upload the disc image, extracted files, the patch, Ghidra databases, generated code or the built executable.

## Controls

Xbox pads and every pad SDL knows work in the game and in the PC settings menu (F1): DualShock 3/4, DualSense, Switch pads, USB adapters for PS2 and original Xbox pads. The build downloads `gamecontrollerdb.txt` (SDL_GameControllerDB) and, on Windows, `SDL3.dll` (both zlib license) next to the executable. Without them the game behaves as before, with the pads raylib sees. Linux and macOS use the mapping database only. No PlayStation pad or adapter has been tried on real hardware yet.

Keyboard and mouse: W A S D or the arrows move, Space, C or the left button confirm (Circle), X, Esc, Backspace or the right button cancel (Cross), Z or the middle button is Square, V is Triangle, Q / E are L1 / R1, Shift is L2 / R2, Enter is Start, Tab is Select, F1 opens the PC settings. The mouse only moves the right stick if **Mouse look** is turned on in F1, which also has a **Mouse sensitivity** slider, because the game has no such option.

With `SDL3.dll` (Windows) the game also vibrates the pad; **Controller vibration** in F1 turns that off.

## Credits and licenses

- Port integration and tooling: [batatinhafcbatatinha-pixel](https://github.com/batatinhafcbatatinha-pixel).
- [PS2Recomp](https://github.com/ran-j/PS2Recomp) by ran-j and contributors: recompiler, analyzer and runtime base.
- [Ghidra](https://github.com/NationalSecurityAgency/ghidra) with the [ghidra-emotionengine-reloaded](https://github.com/chaoticgd/ghidra-emotionengine-reloaded) extension, and MAME's `chdman`, used locally.
- Boku no Natsuyasumi 2, its code, trademarks and assets belong to Sony Interactive Entertainment, Millennium Kitchen and the respective rights holders; the English translation belongs to its authors. This project is not affiliated with or endorsed by them.

---

<a id="notice"></a>

**⚠️ THIS PROJECT DOES NOT INCLUDE THE GAME, A DISC IMAGE/ELF, GAME ASSETS, GENERATED GAME CODE OR A PRECOMPILED GAME EXECUTABLE. YOU MUST PROVIDE YOUR OWN LAWFULLY OBTAINED GAME FILES AND HAVE THE RIGHTS REQUIRED FOR YOUR USE. THIS PROJECT DOES NOT AUTHORIZE COPYRIGHT INFRINGEMENT. ALL GAME RIGHTS BELONG TO THEIR RESPECTIVE OWNERS. ⚠️**
