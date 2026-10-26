# Checkpoint — 26/10/2026 noite (Claude): threads do jogo rodando; falta rebuild completo do AOT

Feito (build atual em D:\CodexBuilds
ative-portsoku2, testado com `python scripts/smoke.py --seconds 40`):
- Analisador SDK rodado (`analysis/analyzer.log`, `config/analyzer-heuristic.toml`: 632 matches, 255 com handler).
  `scripts/gen_sdk_handlers.py` → `project/sdk-handlers.inc`; `main.cpp` instala 253 handlers nativos na tabela
  (`BOKU2_GUEST_SDK=1` desliga). SifInitRpc agora nativo.
- Runtime compartilhado: `ChangeThreadPriority` aceitava só 1..127; o escalonador do jogo usa prioridade 0 (rejeitado
  com -403, a thread 4 nunca rodava). Agora 0..127. Trace: `PS2X_TRACE_PRIORITY=1`.
- `scripts/gen_gap_functions.py`: 787 funções fora do mapa Ghidra (analisador + rótulos `entry_` em buracos) num único
  TU `project/gap-functions.cpp` (compila em ~15 s). Resolveu a morte da thread 4 em `0x2329A0`.
- `BOKU2_PROBE=<hex>` em `main.cpp` imprime ra/a0 das primeiras chamadas a um endereço.

Bloqueio atual: o laço em `0x21E040` é o `_CdCheckSCmd` da libcdvd tentando `sceSifBindRpc(0x80000593)` (cdvdfsv, da
BIOS; não existe no IOP emulado). Chega lá porque `FUN_0022a168` faz *tail-jump* (`j`) para `sceCdMmode`, e o gerador
emite tail-jumps para funções conhecidas como chamada C++ direta, sem passar pela tabela. `scripts/route_sdk_tailcalls.py`
já reescreveu os 48 fontes afetados (55 chamadas) para `runtime->lookupFunction(...)`, MAS o build usa
`BOKU2_PREBUILT_AOT=.../ps2_game_code.lib`, então é preciso **reconstruir ps2_game_code (168 chunks; build longa)**:
configure com `-DBOKU2_PREBUILT_AOT=` e build com VSLANG=1033 (sem isso o ninja não lê as dependências em pt-BR).
Rodar `route_sdk_tailcalls.py` de novo depois de qualquer `generate.cmd`.



## Reservas de espaço removidas — 26/10/2026



Por solicitação do usuário, os pipelines não exigem mais reservas mínimas de 20 GiB nem de 1 GiB para fontes/logs. As referências anteriores a essas reservas são históricas. Permanecem os limites de tamanho de artefatos e logs, as verificações de integridade e, nas extrações, a verificação de espaço para os próprios arquivos. A estimativa de build do Ben10 é apenas informativa.



## Continuação Boku2 — AOT e diagnóstico de execução



Ghidra local (o provider REA desta instalação rejeitou ELF/MIPS), 5.329 funções reais, geração e build concluídos. Recuperação adicional de 0x20a920..0x20a998 com registro de nove entradas, reproduzível por `generate.cmd --recovered-only`. Runtime e AOT em D:\CodexBuilds\native-ports\boku2; launcher consulta build-location.txt.



Correção isolada de memória: cópias locais de ps2_runtime.cpp e System.cpp usam limite de heap 0x01e00000; callbacks ficam em 0x01ee0000..0x01f00000 e pilha principal em 0x01f00000..0x02000000. O teste anterior falhava com EE invocation stack space exhausted; teste de 25 segundos com a adaptação permaneceu vivo até o limite, parado em 0x2338dc, depth=1, depois de iChangeThreadPriority. Investigar retomada do scheduler/callback e prioridades; não pular a rotina do jogo nem presumir que timeout significa boot concluído. Fontes compartilhados estão sendo alterados por outra sessão: evitar modificá-los aqui.

