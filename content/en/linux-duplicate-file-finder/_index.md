+++
title = "Linux Duplicate File Finder (CLI & TUI) — DedupCommando"
description = "A Rust duplicate file finder for Linux with a terminal UI. Scan large trees, review groups, and reclaim space with safe hardlink or reflink actions."
template = "home.html"
[extra]
lang = "en"
dir = "ltr"
h1 = "A duplicate file finder for Linux, built for safety"
+++

DedupCommando is a duplicate file finder for Linux, written in Rust, with a terminal interface. It scans large directory trees, finds **byte-for-byte identical files** with **BLAKE3** hashing (and an optional byte-for-byte re-compare), and helps you reclaim space safely.

## Scan large trees, then review

- **Resumable scans** with on-disk checkpoints and a hash cache, so re-scans are near-instant.
- Results are grouped by identical content; one file per group is the **keeper**.
- It also finds **"twin folders"** — directory trees whose scanned contents are identical.
- Two interfaces: a multi-panel **commander** (default) or a classic stepwise wizard (`--classic`); a **read-only** observer mode is available for a second window.
- A **headless scan mode** fits cron jobs, with CSV export and stats.

## Reclaim space, safely

Mark a keeper and an action per group — **delete to quarantine**, **hardlink**, or **reflink** — then review and apply, or save the plan as a shell script. Destructive actions run under a ZFS snapshot with content re-validation and atomic publishing.

## Good to know

- **Linux only** (x86_64 / aarch64), kernel ≥ 3.15.
- Scanning works on any filesystem, but the snapshot safety model needs **ZFS**, so applying actions outside ZFS is not recommended.

**Beta (v0.9.0-beta.1).** [Documentation](@/en/docs/_index.md) · [Safety & recovery](@/en/safety-and-recovery/_index.md) · [Source on GitHub](https://github.com/dedupcommando/DedupCommando)
