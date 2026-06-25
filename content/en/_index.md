+++
title = "DedupCommando — Safety-First Duplicate File & Folder Finder for Linux"
description = "A safety-focused Linux CLI and TUI to find duplicate files and folders and reclaim storage with hardlinks, reflinks, and ZFS-aware workflows. Open source, beta."
template = "home.html"
[extra]
lang = "en"
dir = "ltr"
h1 = "Find duplicate files and folders — reclaim storage safely"
+++

**Beta — v0.9.0-beta.1.** DedupCommando performs destructive operations (delete, hardlink, reflink) on real files. Read the safety guide before applying anything, and keep backups.

DedupCommando is a Linux terminal tool (CLI and TUI) that finds **byte-for-byte identical files and whole duplicate folders**, and reclaims the space they waste — built for **ZFS** pools, including storage hosted on Proxmox VE systems. Data safety comes first: every destructive batch runs under a ZFS snapshot, "deleted" files are moved to a quarantine instead of being unlinked, and content is re-validated immediately before each action.

## Safety first

- A **ZFS snapshot** of every dataset the batch touches is taken before the first action — if any snapshot fails, the whole batch is aborted.
- **"Delete" moves files to a quarantine**, not `unlink` — reversible until you explicitly purge it.
- Content is **re-validated** (re-hash / re-stat) right before each action; a mismatch aborts that action.
- Files are published atomically with `renameat2(RENAME_NOREPLACE)` — no check-then-rename race.
- A **single-instance lock** prevents concurrent writers; cross-dataset moves are refused, never a silent copy-and-delete.

## Three ways to reclaim space

- **Delete to quarantine** — remove a duplicate, keep it recoverable until purged.
- **Hardlink** — point duplicates at one shared inode (within a single dataset).
- **Reflink** — copy-on-write block clone on ZFS with `block_cloning` (same pool); independent metadata, blocks shared until a file changes.

One file in each group is the **keeper**; the rest become links or go to quarantine.

## How it works

1. **Scan** — walk your chosen roots, hash candidates with **BLAKE3** (with an optional byte-for-byte re-compare), and group identical files. Scans are resumable and cached for near-instant re-runs.
2. **Review** — browse duplicate groups in the multi-panel **commander** (default) or a classic stepwise wizard (`--classic`); mark a keeper and the action for each group. It also finds **"twin folders"** — directory trees whose scanned contents are identical.
3. **Apply** — review the plan and apply interactively, or save it as a shell script. A **resource governor** (Turbo / Balanced / Idle) keeps a scan from starving VMs or backups on a busy host.

## Built for ZFS, runs on Proxmox VE

DedupCommando is designed for ZFS: snapshots, dataset-aware boundaries, and reflink all build on it. It is tested on Proxmox VE 9.1 (OpenZFS 2.3), where ZFS is available out of the box. This is **file-level** deduplication — finding and removing duplicate files — not ZFS's built-in block-level dedup (`zfs set dedup`), and not compression.

> On non-ZFS filesystems scanning still works, but there is no snapshot safety, so applying actions is not recommended there.

## Requirements

- **Linux**, kernel ≥ 3.15, x86_64 or aarch64.
- **ZFS strongly recommended** (snapshot safety, dataset detection, reflink); `zfs` in `PATH`, typically run as root.
- A UTF-8, 256-color terminal.

## Get started

**Debian 13 / Proxmox VE 9+** — install from the signed APT repository (auto-updates via `apt upgrade`):

```sh
sudo curl -fsSL https://dedupcommando.github.io/apt/dedcom-archive-keyring.gpg \
  -o /usr/share/keyrings/dedcom-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/dedcom-archive-keyring.gpg] https://dedupcommando.github.io/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/dedcom.list
sudo apt update && sudo apt install dedcom
```

Pre-built binaries are attached to each GitHub release (amd64 and arm64) — download, **verify**, and install:

```sh
tar xzf dedcom-<version>-<triple>.tar.gz
sudo install -m 755 dedcom /usr/local/bin/dedcom
```

Building from source is Docker-based — no local Rust toolchain required.

- [Get the latest release](https://github.com/dedupcommando/DedupCommando/releases) · [Source on GitHub](https://github.com/dedupcommando/DedupCommando)
- Read more: [duplicate files on ZFS](@/en/zfs-file-deduplication/_index.md) · [on Proxmox VE storage](@/en/proxmox-ve-duplicate-files/_index.md) · [the Linux duplicate finder](@/en/linux-duplicate-file-finder/_index.md) · [hardlink vs reflink](@/en/hardlink-vs-reflink/_index.md) · [safety & recovery](@/en/safety-and-recovery/_index.md) · [documentation](@/en/docs/_index.md)
