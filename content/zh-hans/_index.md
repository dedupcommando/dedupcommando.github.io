+++
title = "DedupCommando — 注重安全的 Linux 重复文件和文件夹查找工具"
description = "用于 Linux 的 CLI 与 TUI，注重安全：查找重复的文件和文件夹，并通过硬链接（hardlink）、reflink 和面向 ZFS 的流程回收空间。开源，beta 版。"
template = "home.html"
[extra]
lang = "zh-Hans"
dir = "ltr"
h1 = "安全地查找重复的文件和文件夹并回收存储空间"
+++

**Beta — v0.9.0-beta.1。** DedupCommando 会对真实文件执行破坏性操作（删除、hardlink、reflink）。在执行任何操作前，请阅读安全指南，并保留备份。

DedupCommando 是一个用于 Linux 的终端工具（CLI 与 TUI），用于查找**逐字节完全相同的文件和文件夹**并回收它们浪费的空间——专为 **ZFS** 存储而设计，包括托管在 Proxmox VE 系统上的存储。数据安全优先：每一批破坏性操作都在 ZFS 快照（snapshot）下执行，“删除”的文件会被移入隔离区而非直接删除，并在每个操作前立即重新校验内容。

## 安全优先

- 在第一个操作之前，会为受影响的每个数据集（dataset）创建 **ZFS 快照**；只要有任何快照失败，整批操作都会中止。
- **“删除”会把文件移入隔离区**，而非 `unlink`——在你显式清空之前都可恢复。
- 在每个操作前**重新校验**内容（重新哈希 / 重新 stat）；任何不一致都会中止该操作。
- 文件通过 `renameat2(RENAME_NOREPLACE)` 原子地发布——不存在“先检查后改名”的竞态。
- **单实例锁**防止并发写入；跨数据集的移动会被拒绝，绝不会静默地复制后删除。

## 三种回收空间的方式

- **删除到隔离区**——移除一个重复文件，并在清空前保持可恢复。
- **Hardlink**——让重复文件指向同一个 inode（在单个数据集内）。
- **Reflink**——在启用 `block_cloning` 的 ZFS 上进行写时复制（CoW）块克隆（同一存储池）；元数据相互独立，块在文件改变前共享。

每个分组中有一个文件是**保留项**（keeper）；其余的会变成链接或进入隔离区。

## 工作方式

1. **扫描**——遍历所选路径，用 **BLAKE3** 对候选文件做哈希（可选逐字节再比对），并将相同文件分组。扫描可恢复，并有缓存，使重复扫描几乎即时。
2. **审阅**——在多面板 **commander**（默认）或经典分步向导（`--classic`）中浏览重复分组；为每组标记 keeper 和操作。它还能发现**“孪生文件夹”**：内容完全相同的目录树。
3. **应用**——审阅计划并交互式应用，或保存为 shell 脚本。**资源调节器**（Turbo / Balanced / Idle）可避免扫描在繁忙主机上抢占 VM 或备份的资源。

## 为 ZFS 而生，可在 Proxmox VE 上运行

DedupCommando 专为 ZFS 设计：快照、数据集边界和 reflink 都以它为基础。它已在 Proxmox VE 9.1（OpenZFS 2.3）上测试，那里 ZFS 开箱即用。这是**文件级**去重——查找并移除重复文件——而非 ZFS 内置的块级去重（`zfs set dedup`），也不是压缩。

> 在非 ZFS 文件系统上，扫描仍可工作，但没有快照保护，因此不建议在那里应用操作。

## 系统要求

- **Linux**，内核 ≥ 3.15，x86_64 或 aarch64。
- **强烈推荐 ZFS**（快照保护、数据集检测、reflink）；`PATH` 中需有 `zfs`，通常以 root 运行。
- 一个 UTF-8、256 色的终端。

## 开始使用

每个 GitHub 发行版都附带预编译二进制文件（amd64 和 arm64）——下载、**校验**，然后安装：

```sh
tar xzf dedcom-<version>-<triple>.tar.gz
sudo install -m 755 dedcom /usr/local/bin/dedcom
```

从源码构建基于 Docker，无需本地 Rust 工具链。

- [最新发行版](https://github.com/dedupcommando/DedupCommando/releases) · [GitHub 源码](https://github.com/dedupcommando/DedupCommando)
- 更多细节（英文）：[ZFS 上的重复文件](@/en/zfs-file-deduplication/_index.md) · [Proxmox VE 上](@/en/proxmox-ve-duplicate-files/_index.md) · [Linux 重复文件查找工具](@/en/linux-duplicate-file-finder/_index.md) · [hardlink 与 reflink](@/en/hardlink-vs-reflink/_index.md) · [安全与恢复](@/en/safety-and-recovery/_index.md) · [文档](@/en/docs/_index.md)
