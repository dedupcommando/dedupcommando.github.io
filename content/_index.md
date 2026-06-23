+++
title = "DedupCommando — Safety-First Duplicate File & Folder Finder for Linux"
description = "A safety-focused Linux CLI and TUI to find duplicate files and folders and reclaim storage with hardlinks, reflinks, and ZFS-aware workflows. Open source, beta."
template = "home.html"
[extra]
lang = "en"
dir = "ltr"
h1 = "Find duplicate files and folders — reclaim storage safely"
x_default = true
canonical = "@/en/_index.md"
+++

**Beta — v0.9.0-beta.1.** A Linux CLI and TUI for finding **byte-for-byte identical files and folders** and reclaiming wasted space — built for **ZFS** pools, including storage hosted on Proxmox VE systems.

Data safety first: every destructive batch runs under a ZFS snapshot, "deleted" files go to a recoverable quarantine, and content is re-validated right before each action. Reclaim space three ways — **delete to quarantine**, **hardlink**, or **reflink** (ZFS block cloning).

Choose your language above, or **[continue in English →](@/en/_index.md)**.

- [Get the latest release](https://github.com/dedupcommando/DedupCommando/releases) · [Source on GitHub](https://github.com/dedupcommando/DedupCommando)
