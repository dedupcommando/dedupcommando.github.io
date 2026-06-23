+++
title = "Safety, Recovery, and Limitations — DedupCommando"
description = "How DedupCommando protects your data: ZFS snapshots, quarantine instead of delete, content revalidation, atomic publish, and how to recover."
template = "home.html"
[extra]
lang = "en"
dir = "ltr"
h1 = "Safety, recovery, and honest limitations"
+++

DedupCommando relinks and removes real files, so it is built around layered safeguards. This is a summary; the authoritative guide is [docs/SAFETY.md](https://github.com/dedupcommando/DedupCommando/blob/main/docs/SAFETY.md) in the repository.

## The safety model

- **ZFS snapshot before the batch** — every dataset the batch touches is snapshotted before the first action; if any snapshot fails, the entire batch is aborted.
- **Quarantine, not unlink** — "delete" moves files to a per-dataset quarantine, preserving permissions and ownership; reversible until you explicitly purge.
- **Content revalidation** — files are re-hashed / re-stated before each action; a mismatch aborts that action.
- **Atomic publish** — new links are placed with `renameat2(RENAME_NOREPLACE)`, so there is no check-then-rename race on the destination.
- **Single-instance lock** — only one writing operator at a time; a second instance can open read-only.
- **Consent gating and a resource governor** — a one-time disclaimer, and Turbo / Balanced / Idle profiles to cap I/O on live systems.
- **Cross-dataset moves are refused** — never a silent copy-and-delete.

### An honest caveat

DedupCommando acts by path, so a theoretical check-to-act (TOCTOU) window exists. It is mitigated by snapshots, atomic publishing, repeated symlink checks, and quarantine-based restore, within a single-administrator model.

## Recovery

- **Restore one file** — move it back from the quarantine to its original path.
- **Roll back a batch** — `zfs rollback <dataset>@dedcom-<timestamp>`. This reverts the **entire dataset** to snapshot time, so prefer quarantine restore when other writes happened since.
- **Purge quarantine** — `dedcom --purge-quarantine` reports the size and deletes only with `--yes` (irreversible).

## Limitations

- **Linux only** (x86_64 / aarch64), kernel ≥ 3.15.
- The safety model depends on **ZFS**; on other filesystems scanning works but applying is not recommended.
- **Applying is interactive by design** — headless mode scans only.
- Typically requires **root** (to snapshot and scan outside your home directory).
- Reflink needs ZFS 2.3+ with `block_cloning`; hardlink is within a single dataset.
- Grouping a very large scan can use significant memory; DedupCommando estimates it and warns first.

**Beta (v0.9.0-beta.1). Keep backups.** [Documentation](@/en/docs/_index.md) · [Source on GitHub](https://github.com/dedupcommando/DedupCommando)
