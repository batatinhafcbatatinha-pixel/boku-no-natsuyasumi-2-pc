# Boku no Natsuyasumi 2 — Native PC Port (early work) | PlayStation 2 Static Recompilation

> [!WARNING]
> This repository does **not** include the game, a disc image/ELF, game assets, a translation patch, generated game code or a precompiled executable.
> You need your own PlayStation 2 disc. See [the full notice](#notice) at the end.

Early work on a port of the PlayStation 2 game *Boku no Natsuyasumi 2: Umi no Bouken-hen* (Japan, "Adventure by the Sea"), built through static recompilation of the Emotion Engine code with [PS2Recomp](https://github.com/ran-j/PS2Recomp). **This public repository is a work-in-progress source snapshot, not a ready-to-play game download or a self-contained build kit.** The game's MIPS code is translated locally from your own disc; no game executable or generated game code is distributed here.

## Status

- **Not playable yet.** The native executable builds, initializes graphics and audio, creates the game's threads and then stalls at `0x2338dc` after `ChangeThreadPriority`; no scene has been validated.
- EE (R5900) code: 5,329 functions mapped with Ghidra and recompiled; the entry point the function map missed (`0x20a920`) was recovered, plus 791 gap functions.
- A local CMake adaptation (`project/runtime_memory.cmake`) separates the game heap, the runtime arena, callback stacks and the 1 MiB main stack.
- IOP and VU still run through interpreters in the runtime; this is not a fully native port.

## What is in this repository

- `scripts/` — game-file extraction and verification, Ghidra export scripts, generation, gap-function and SDK-handler generators, SDK tail-call routing, chunking, native build and smoke test.
- `config/` — recompiler configuration (TOML). Ghidra CSV exports are not included.
- `project/` — CMake project, `main.cpp` and runtime layout adaptations; generated and recovered sources are not included.
- [NOTES.md](NOTES.md) and [CONTINUACAO.md](CONTINUACAO.md) — development log (in Portuguese).

The scripts expect the author's local workspace (`../third_party/PS2Recomp` and a local build directory).

## Your game files

Tested with the Japanese disc (`SCPS-15026`) carrying the Hilltop English translation patch v1.2; the patch has not been validated in the port.

```text
SCPS_150.26  ecdac5741e092099e08834ea16b785cdfd70bc750855caa6c4dd28fc689cb6b1  (tested, patched image)
```

Do not upload the disc image, extracted files, the patch, Ghidra databases, generated code or the built executable.

## Credits and licenses

- Port integration and tooling: [batatinhafcbatatinha-pixel](https://github.com/batatinhafcbatatinha-pixel).
- [PS2Recomp](https://github.com/ran-j/PS2Recomp) by ran-j and contributors: recompiler, analyzer and runtime base.
- [Ghidra](https://github.com/NationalSecurityAgency/ghidra) with the [ghidra-emotionengine-reloaded](https://github.com/chaoticgd/ghidra-emotionengine-reloaded) extension, and MAME's `chdman`, used locally.
- Boku no Natsuyasumi 2, its code, trademarks and assets belong to Sony Interactive Entertainment, Millennium Kitchen and the respective rights holders; the English translation belongs to its authors. This project is not affiliated with or endorsed by them.

---

<a id="notice"></a>

**⚠️ THIS PROJECT DOES NOT INCLUDE THE GAME, A DISC IMAGE/ELF, GAME ASSETS, GENERATED GAME CODE OR A PRECOMPILED GAME EXECUTABLE. YOU MUST PROVIDE YOUR OWN LAWFULLY OBTAINED GAME FILES AND HAVE THE RIGHTS REQUIRED FOR YOUR USE. THIS PROJECT DOES NOT AUTHORIZE COPYRIGHT INFRINGEMENT. ALL GAME RIGHTS BELONG TO THEIR RESPECTIVE OWNERS. ⚠️**
