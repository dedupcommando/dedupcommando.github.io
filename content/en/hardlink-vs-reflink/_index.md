+++
title = "Hardlink vs Reflink for Deduplication — DedupCommando"
description = "How hardlinks and reflinks reclaim space from duplicate files, their trade-offs on Linux and ZFS, and how DedupCommando applies them atomically."
template = "home.html"
[extra]
lang = "en"
dir = "ltr"
h1 = "Hardlink vs reflink: reclaiming space from duplicates"
+++

When two files are identical, you can reclaim the wasted space without deleting either one — by **hardlinking** or **reflinking** them. They behave differently; DedupCommando supports both.

## Hardlink

A hardlink makes two paths point at the **same inode**. There is only one copy of the data and one set of metadata.

- Space is reclaimed immediately.
- Works **within a single dataset / filesystem**.
- Because the inode is shared, editing through one path changes the file seen at every other path — best for content that does not change.

## Reflink (copy-on-write block clone)

A reflink gives each path its **own inode** that initially **shares data blocks** with the other. Each file keeps independent metadata (owner, permissions); when one is modified, only the changed blocks diverge (copy-on-write).

- Space is reclaimed immediately, while each file stays independent.
- On ZFS, needs `block_cloning` (ZFS 2.3+); keeper and target may be in different datasets of the **same pool**.

## Which should you use?

Prefer **reflink** when `block_cloning` is available — files keep independent metadata and stay safe to edit. Use **hardlink** when block cloning is not available and the duplicates live in the same dataset and won't be edited independently. When in doubt, **delete to quarantine** keeps a removed file recoverable.

DedupCommando applies every action atomically (`renameat2(RENAME_NOREPLACE)`), re-validates content first, and runs the batch under a ZFS snapshot.

**Beta (v0.9.0-beta.1).** [Safety & recovery](@/en/safety-and-recovery/_index.md) · [Documentation](@/en/docs/_index.md)
