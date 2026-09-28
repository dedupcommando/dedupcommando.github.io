+++
title = "DedupCommando documentation — install, first scan, manual and safety"
description = "Install DedupCommando from APT or a release binary, run the first scan, and find the manual, the safety model, release notes and guides for Linux and ZFS."
template = "home.html"
aliases = ["/en/docs/"]
[extra]
lang = "en"
dir = "ltr"
h1 = "DedupCommando documentation"
short_title = "Docs"
+++

**Beta — v0.9.0-beta.1.** DedupCommando performs destructive operations (delete, hardlink, reflink) on real files. Read the [safety guide](@/en/safety-model.md) before applying anything, and keep backups.

DedupCommando is a Linux terminal tool (CLI and TUI) that finds **byte-for-byte identical files and whole duplicate folders**, and reclaims the space they waste — built for **ZFS** pools, including storage hosted on Proxmox VE systems. Data safety comes first: every destructive batch runs under a ZFS snapshot, "deleted" files are moved to a quarantine instead of being unlinked, and content is re-validated immediately before each action.

## Install

1. **APT (Debian 13 / Proxmox VE 9+, recommended)** — install from the signed APT repository (auto-updates via `apt upgrade`):
   ```sh
   # as root (Proxmox default); on non-root Debian run: sudo -i
   curl -fsSL https://dedupcommando.github.io/apt/dedcom-archive-keyring.gpg \
     -o /usr/share/keyrings/dedcom-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/dedcom-archive-keyring.gpg] https://dedupcommando.github.io/apt stable main" \
     | tee /etc/apt/sources.list.d/dedcom.list
   apt update && apt install dedcom
   ```
2. **Release binary (any Linux, glibc ≥ 2.39)** — download the tarball for your architecture (amd64 / arm64) from [GitHub Releases](https://github.com/dedupcommando/DedupCommando/releases), [verify it](@/en/verifying-releases.md), then:
   ```sh
   tar xzf dedcom-<version>-<triple>.tar.gz
   install -m 755 dedcom /usr/local/bin/dedcom
   ```
3. **From source** — a Docker-based build, no local Rust toolchain required (see [CONTRIBUTING](https://github.com/dedupcommando/DedupCommando/blob/main/CONTRIBUTING.md)).

Cargo (`cargo install dedcom`) is **planned — not yet available**; for now use APT, the release binary, or build from source. The [installation chapter](@/en/manual/02-install.md) of the manual covers every option in detail.

## First scan

```sh
dedcom              # multi-panel commander (default)
dedcom --classic    # classic stepwise wizard
dedcom --read-only  # read-only observer
dedcom -h           # all options
```

Pick scan roots, choose an intensity profile (Idle on a busy host), and start. After the scan, mark a keeper and an action per group, then review and apply — or save the plan as a shell script. The [quickstart chapter](@/en/manual/04-quickstart.md) walks through a typical session.

## Read the docs

- [User manual](@/en/manual/_index.md) — install, data safety, scanning, actions, the Commando and Classic interfaces, headless/cron, maintenance, troubleshooting, hotkeys.
- [Safety, recovery and limitations](@/en/safety-model.md).
- [Verifying releases](@/en/verifying-releases.md).
- [Release notes](@/en/changelog/_index.md) — what changed in each version.
- On GitHub: [README](https://github.com/dedupcommando/DedupCommando/blob/main/README.md) · [Contributing](https://github.com/dedupcommando/DedupCommando/blob/main/CONTRIBUTING.md) (DCO) · [Security policy](https://github.com/dedupcommando/DedupCommando/blob/main/SECURITY.md) · [Trademarks](https://github.com/dedupcommando/DedupCommando/blob/main/TRADEMARKS.md).

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

- **Linux**, kernel ≥ 3.15, x86_64 or aarch64; the pre-built packages need glibc ≥ 2.39 (Debian 13, Ubuntu 24.04, Proxmox VE 9).
- **ZFS strongly recommended** (snapshot safety, dataset detection, reflink); `zfs` in `PATH`, typically run as root.
- A UTF-8, 256-color terminal.

## Verify your download

Each release ships SHA-256 checksums, minisign signatures, a CycloneDX SBOM and a SLSA build-provenance attestation. See [Verifying releases](@/en/verifying-releases.md).

## Guides

- [File-level deduplication for datasets stored on ZFS](@/en/zfs-file-deduplication/_index.md)
- [Duplicate files on Proxmox VE storage](@/en/proxmox-ve-duplicate-files/_index.md)
- [The Linux duplicate file finder](@/en/linux-duplicate-file-finder/_index.md)
- [Hardlink vs reflink](@/en/hardlink-vs-reflink/_index.md)
- [Safety and recovery in brief](@/en/safety-and-recovery/_index.md)
