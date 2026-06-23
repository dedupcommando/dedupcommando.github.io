+++
title = "Duplicate Files on Proxmox VE Storage — DedupCommando"
description = "DedupCommando for storage hosted on Proxmox VE systems: find and remove duplicate files safely, with ZFS snapshots and quarantine. Independent project."
template = "home.html"
[extra]
lang = "en"
dir = "ltr"
h1 = "DedupCommando for storage hosted on Proxmox VE systems"
+++

Proxmox VE deployments commonly store data on ZFS. Over time, ISO images, templates, backups, and guest files accumulate **byte-for-byte duplicates** that quietly consume pool space. DedupCommando finds those duplicate files on ZFS datasets and helps you reclaim the space — under the same snapshot-and-quarantine safety model it uses everywhere.

It **runs on Proxmox VE systems**, where a recent kernel and ZFS are available out of the box. DedupCommando is an independent tool: it is not a Proxmox plugin and does not modify Proxmox itself — it operates on the files in your ZFS datasets.

## Working safely on a live host

- **Snapshot insurance** before every batch, with per-file quarantine and dataset rollback for recovery.
- A **resource governor** (Turbo / Balanced / **Idle**) keeps a scan from starving running VMs or backups — use Idle on a busy host.
- **Reflink** (ZFS `block_cloning`) and **hardlink** reclaim space without copying data; **delete** moves files to a recoverable quarantine.

## Honest expectations

This is **beta** software that performs destructive actions on real files. Try it on non-critical data first, keep backups, and read [safety & recovery](@/en/safety-and-recovery/_index.md) before applying anything.

> Proxmox® is a registered trademark of Proxmox Server Solutions GmbH. DedupCommando is an independent project and is not affiliated with or endorsed by Proxmox Server Solutions GmbH.

[Documentation](@/en/docs/_index.md) · [Source on GitHub](https://github.com/dedupcommando/DedupCommando)
