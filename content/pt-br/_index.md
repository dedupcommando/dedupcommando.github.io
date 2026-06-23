+++
title = "DedupCommando — Localizador seguro de arquivos e pastas duplicados para Linux"
description = "CLI e TUI para Linux com foco em segurança que encontra arquivos e pastas duplicados e recupera espaço com hardlinks, reflinks e fluxos compatíveis com ZFS. Código aberto, em beta."
template = "home.html"
[extra]
lang = "pt-BR"
dir = "ltr"
h1 = "Encontre arquivos e pastas duplicados e recupere espaço, com segurança"
+++

**Beta — v0.9.0-beta.1.** O DedupCommando executa operações destrutivas (excluir, hardlink, reflink) em arquivos reais. Leia o guia de segurança antes de aplicar qualquer coisa e mantenha backups.

O DedupCommando é uma ferramenta de terminal para Linux (CLI e TUI) que encontra **arquivos e pastas idênticos byte a byte** e recupera o espaço que eles desperdiçam — feita para armazenamento em **ZFS**, incluindo o hospedado em sistemas Proxmox VE. A segurança dos dados vem primeiro: cada lote destrutivo é executado sob um snapshot do ZFS, os arquivos "excluídos" vão para uma quarentena em vez de serem removidos, e o conteúdo é revalidado imediatamente antes de cada ação.

## Segurança em primeiro lugar

- Um **snapshot do ZFS** de cada dataset afetado é criado antes da primeira ação; se algum falhar, todo o lote é cancelado.
- **"Excluir" move os arquivos para uma quarentena**, não usa `unlink` — reversível até você esvaziá-la explicitamente.
- O conteúdo é **revalidado** (re-hash / re-stat) logo antes de cada ação; qualquer divergência cancela aquela ação.
- Os arquivos são publicados de forma atômica com `renameat2(RENAME_NOREPLACE)` — sem condição de corrida.
- Um **bloqueio de instância única** impede escritas concorrentes; movimentações entre datasets são recusadas, nunca uma cópia e exclusão silenciosas.

## Três formas de recuperar espaço

- **Excluir para a quarentena** — remova um duplicado mantendo-o recuperável até esvaziá-la.
- **Hardlink** — aponte os duplicados para um mesmo inode (dentro de um único dataset).
- **Reflink** — clone de blocos com cópia na escrita (CoW) no ZFS com `block_cloning` (mesmo pool); metadados independentes e blocos compartilhados até um arquivo mudar.

Em cada grupo, um arquivo é o **mantido** (keeper); o restante vira link ou vai para a quarentena.

## Como funciona

1. **Escanear** — percorre os caminhos escolhidos, calcula o hash dos candidatos com **BLAKE3** (com uma recomparação byte a byte opcional) e agrupa os arquivos idênticos. Os escaneamentos são retomáveis e ficam em cache para repetições quase instantâneas.
2. **Revisar** — navegue pelos grupos de duplicados no **commander** multipainel (padrão) ou em um assistente clássico passo a passo (`--classic`); marque um keeper e a ação de cada grupo. Ele também encontra **"pastas gêmeas"**: árvores de diretórios com conteúdo idêntico.
3. **Aplicar** — revise o plano e aplique-o de forma interativa, ou salve-o como script de shell. Um **regulador de recursos** (Turbo / Balanced / Idle) evita que um escaneamento sufoque as VMs ou os backups de um host ocupado.

## Feito para ZFS, roda em Proxmox VE

O DedupCommando foi projetado para ZFS: snapshots, limites por dataset e reflink se apoiam nele. Foi testado no Proxmox VE 9.1 (OpenZFS 2.3), onde o ZFS está disponível de fábrica. Isto é deduplicação **em nível de arquivo** — encontrar e remover arquivos duplicados — não a deduplicação em nível de bloco embutida no ZFS (`zfs set dedup`), nem compressão.

> Em sistemas de arquivos que não são ZFS o escaneamento funciona, mas não há segurança por snapshots, então não é recomendado aplicar ações ali.

## Requisitos

- **Linux**, kernel ≥ 3.15, x86_64 ou aarch64.
- **ZFS fortemente recomendado** (segurança por snapshots, detecção de datasets, reflink); `zfs` no `PATH`, normalmente executado como root.
- Um terminal UTF-8 de 256 cores.

## Começar

Há binários pré-compilados em cada release do GitHub (amd64 e arm64) — baixe, **verifique** e instale:

```sh
tar xzf dedcom-<version>-<triple>.tar.gz
sudo install -m 755 dedcom /usr/local/bin/dedcom
```

Ou instale com o Cargo: `cargo install dedupcommando` (o binário é `dedcom`). A compilação a partir do código-fonte é feita com Docker, sem necessidade de um toolchain Rust local.

- [Última versão](https://github.com/dedupcommando/DedupCommando/releases) · [Código no GitHub](https://github.com/dedupcommando/DedupCommando)
- Mais detalhes (em inglês): [duplicados no ZFS](@/en/zfs-file-deduplication/_index.md) · [no Proxmox VE](@/en/proxmox-ve-duplicate-files/_index.md) · [localizador de duplicados no Linux](@/en/linux-duplicate-file-finder/_index.md) · [hardlink vs reflink](@/en/hardlink-vs-reflink/_index.md) · [segurança e recuperação](@/en/safety-and-recovery/_index.md) · [documentação](@/en/docs/_index.md)
