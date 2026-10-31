# Checkpoint — 31/10/2026 (Claude): rastro do personagem corrigido

`sceGsSetDefClear` do runtime é um stub vazio; o `sceGsSetDefDBuffDc` do jogo o usa para preencher a limpeza da troca de buffer, então o Z nunca era limpo e o sprite de fundo falhava onde o personagem tinha passado. Solução: função em `config/sdk-handlers-exclude.txt` (roda o código do jogo). Demo sem rastro em todas as cenas (só modo demonstração, sem input).

# Checkpoint — 29/10/2026 (Codex): comparação de builds e roteiro de input

- `build-location.txt` já aponta para `build/native-opt`; não foi alterado nesta sessão.
- Teste inicial otimizado, sem input por heurística de FPS, permaneceu em preto no intervalo de 55 s. Log preservado: `analysis/opt-boot-20261029.log`. Não estabelece regressão do otimizador.
- Testes com espera explícita de boot e Start/Círculo chegaram visualmente ao diário, tela "Class number?", nos builds native e native-opt. Evidências em `runs/native-20261029` e `runs/opt-input-20261029`; imagens e logs separados. Trechos de menu em ~54–60 game_fps; amostra posterior otimizada ~42. Não são medições de gameplay.
- Ambos os processos terminaram com código 1; otimizado antes do limite solicitado. Logs não apresentam causa explícita. Origem do encerramento não determinada; estabilidade não validada.
- `scripts/drive_newgame.py`: argumentos --boot-seconds/--run-name, comparação numérica de FPS (o teste de prefixo antigo aceitava 2 ou 3 fps), padrão Start/Círculo, proc.wait e relatório JSON com razão de término. CLI verificada; novo relatório ainda precisa de execução completa.
- Próximo: diagnosticar encerramento com debugger e avançar do diário de forma controlada (capturas por etapa); depois verificar gameplay/artefato vermelho. Não modificar o runtime compartilhado sem isolamento.
# Checkpoint — 28/10/2026 noite (Claude): relógio do EE em tempo de parede — boot ~10 s, título 60 fps, demo roda

Sintoma: sem input, após ~100 s o título ia para a demo e "congelava" (game_fps 0); boot até o logo ~35 s.
Causa (cdb + diagnóstico `[boku:pacing]`): o patch local "relógio segue o host" somava a cada amostra o tempo de
host desde a amostra anterior — incluindo as esperas de ritmo — por cima da estimativa. O relógio ficava sempre
≥1 quadro adiantado, todo checkpoint vencia e cada fatia esperava o VBlank: ~512 despachos por quadro. O `bzero` de
4,7 MB (`0x248588`, chamado de `0x16cd30`) e o boot levavam minutos. Uma antecedência fixa de 2 ms também falhou:
~700 esperas curtas/s, cada uma custando a granularidade do timer do Windows.
Correção (`project/runtime_scheduler.cmake`): em `accountCycles`, a cada despacho, `m_eeCycle = max(estimativa,
ciclos de parede desde o início)`; sem antecedência. Eventos vencem por ciclo quando vencem no host → ritmo quase
não dorme (waits ~0 ms). CP0 Count continua igual. Resultado: logos 60 fps, imagem aos ~10 s, título, demo de
gameplay (menino andando por várias cenas) a ~10 fps.
Também: `/Z7` + `/DEBUG:FULL` no runtime/entry (PDB com nomes para cdb: `cdb -y <dir do exe> -pv -p PID`),
`BOKU2_PROBE_RA=<hex>` filtra a sonda por ra (a sonda só pega chamadas via tabela), runtime IOP compartilhado com as
correções do Ben10 (identidade de thread no RPC, ioman, sprintf, SetDmaIntr).
Em andamento: build otimizado do AOT (`/O1`) em `build/native-opt` (log `analysis/native-opt-build.log`) — o
gameplay a 10 fps vem do código do jogo em `/Od`. Depois: trocar build-location para ele se funcionar.
Pendente: Círculo não passa do "Press Start" (usar Start 0x8 no drive_newgame), artefato vermelho na demo.

# Checkpoint — 28/10/2026 (Claude, cont.): menu + New Game até o diário; ~30 fps; usuário jogando

6. Relógio do EE: prazos (VBlank/alarmes) só venciam pelo contador estimado (8 ciclos/despacho) → VBlank ~10 Hz,
   jogo ~9 fps. Cópia local do EeScheduler soma o tempo real medido quando maior que a estimativa → ~30 fps no menu.
   (Boot até o logo ficou ~35 s; deixado para depois a pedido do usuário.)
7. `scripts/drive_newgame.py [s] [botões hex]`: boot oculto + PS2X_PAD_FILE + snapshots em runs/drive/. Com Círculo:
   menu → New Game → diário (classe/nome) → "Everything look correct? Yep".
8. Depois do "Yep" a thread principal morria em chamada virtual para 0x1b6e70 (stub `jr ra` após um `j` de tail-call,
   ponteiro numa vtable em .data 0x26e5d0). `gen_gap_functions.py` agora também cria entradas após `j`+delay slot e
   para ponteiros em dados (0x25225C..0x2A5AB8) que caem em código com cara de início (1.975 funções-buraco).
   Compilado; ainda não testado — usuário está jogando pelo Jogar-Boku2.cmd.

# Checkpoint — 28/10/2026 madrugada (Claude): primeira imagem (logo Millennium Kitchen), ~10 fps

Build atual: `boku2/build/native` (AOT completo refeito em 27/10 com o patch de tail-calls). Rebuild incremental:
`build-native.cmd --jobs 4` (só runtime/main/gap). Smoke: `python scripts/smoke.py --seconds 40`; captura de frame:
`PS2X_FRAME_DUMP=<png>`. Corrigido nesta sessão, em ordem:
1. Funções faltando (`0x227790`, `0x228008`, ponteiros preenchidos em tempo de execução): `gen_gap_functions.py` agora
   também cria entradas para código após o fim de cada função do Ghidra e após cada `jr ra`+delay slot fora delas
   (1.524 funções-buraco).
2. `sceIpuInit` do runtime compartilhado tem endereços de outro jogo (`SETD4_CHCR_ENTRY=0x126428`, tabelas IQ/VQ em
   `0x1721e0`): chamava uma função qualquer do Boku2 com lixo. Excluído em `config/sdk-handlers-exclude.txt` (roda o
   código do jogo). **Ben10 também liga sceIpuInit** — excluir lá.
3. `sceCdDiskReady` (0x21E3C8, servidor 0x8000059A) não identificado pelo analisador: ligado ao handler nativo via
   novo `config/sdk-handlers-extra.txt` (lido por `gen_sdk_handlers.py`).
4. O jogo lê o disco por setor (PVD no LBN 16): ISO crua extraída do CHD com `third_party/chdman-0.289` →
   `D:\ISO\Boku2-disc.iso` (3.576.135.680 bytes); `cd-image.txt` aponta para ela; smoke e `Jogar-Boku2.cmd` passam
   como argv[2].
5. Escalonador: handler de alarme (pacer de frame em 0x233780) era preemptado entre `iSignalSema(3)` e a limpeza do
   slot de callback → thread principal travava no WaitSema após ~8 frames. Cópia local do EeScheduler
   (`project/runtime_scheduler.cmake`) não preempta durante invocações Interrupt/Alarm (fica pendente até o handler
   voltar). Candidato a ir para o runtime compartilhado depois de checar o CoD.
Diagnósticos locais: `[boku:bad-load]` (endereço inválido em load), `BOKU2_PROBE=<hex>` + `BOKU2_PEEK=<hex>` (trail e
memória), `PS2X_TRACE_PRIORITY=1` sem limite de 400.
Próximo: ver o que vem depois do logo (menus/intro), fps baixo (~10; present ~57).

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


## Instalador compartilhado — 29/10/2026

Integração publicada em tools/port-installer, installer.json e Instalar-Arquivos.cmd. Fonte compartilhada: https://github.com/batatinhafcbatatinha-pixel/port-installer (main 225df3d, autoria batatinhafcbatatinha-pixel). O launcher local passa apenas o ELF em game_files; sem argumento de ISO. project/CMakeLists inclui o adaptador isolado de leituras EE/IOP para arquivos extraídos. Build native-opt foi recompilado. Mapa local .disc gerado a partir de iso-inventory (926 arquivos; ~92 KB de metadados na primeira versão).
Teste runs/extracted-only-20261029, 70 s sem argv de ISO e PS2X_CD_IMAGE vazio, permaneceu em tela preta. Não confirma boot nem gameplay; investigar com o runtime compartilhado atual. Patch opcional de dump MPEG ficou sob BOKU2_MPEG_DIAGNOSTICS (OFF), pois o trecho compartilhado mudou.
Correção de interpretação: exitCode=1 com stopReason=time limit é o encerramento via taskkill, não evidência de crash. Ver INSTALLER-STATUS.md na raiz do workspace para escopo e limitações.
