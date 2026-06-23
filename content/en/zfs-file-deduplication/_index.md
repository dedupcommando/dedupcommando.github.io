+++
title = "ZFS File Deduplication on Linux — DedupCommando"
description = "File-level deduplication for datasets stored on ZFS. Find duplicate files and reclaim space with snapshot-protected hardlink and reflink actions."
template = "home.html"
[extra]
lang = "en"
dir = "ltr"
h1 = "File-level deduplication for datasets stored on ZFS"
+++

DedupCommando finds **byte-for-byte identical files** on datasets stored on ZFS and reclaims the space they waste — safely, under ZFS snapshots.

This is **file-level** deduplication: it finds and removes duplicate *files*. It is **not** ZFS's built-in block-level dedup (`zfs set dedup`), so there is no always-on dedup table consuming RAM, and it is not compression.

## Why ZFS makes it safer

- **Snapshot before every batch** — DedupCommando snapshots each dataset it touches before the first change; if a snapshot fails, the batch is aborted. You can roll a dataset back, or restore individual files from the quarantine.
- **Dataset-aware** — it understands ZFS dataset boundaries and refuses cross-dataset moves rather than silently copying and deleting.

## Reflink and hardlink on ZFS

- **Reflink (copy-on-write block clone)** — on pools with `block_cloning` enabled (ZFS 2.3+), duplicates can share blocks while keeping independent metadata; a file's blocks diverge only when it changes. Keeper and target may live in different datasets of the **same pool**.
- **Hardlink** — duplicates share a single inode within the **same dataset**.
- **Delete to quarantine** — always available; removed files stay recoverable until you purge them.

## Requirements

- ZFS with `zfs` in `PATH`; typically run as root.
- Reflink needs `zpool feature@block_cloning=active` (ZFS 2.3+).

**Beta (v0.9.0-beta.1).** Read [safety & recovery](@/en/safety-and-recovery/_index.md) before applying actions, and keep backups. · [Documentation](@/en/docs/_index.md) · [Source on GitHub](https://github.com/dedupcommando/DedupCommando)
