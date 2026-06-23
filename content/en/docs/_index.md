+++
title = "Documentation — DedupCommando"
description = "Install DedupCommando, run your first scan, understand the safety model, and verify releases. Links to the full English manual and verification guide."
template = "home.html"
[extra]
lang = "en"
dir = "ltr"
h1 = "Documentation"
+++

All documentation is in English. The project lives on [GitHub](https://github.com/dedupcommando/DedupCommando).

## Install

1. **Release binary (recommended)** — download the tarball for your architecture (amd64 / arm64) from [GitHub Releases](https://github.com/dedupcommando/DedupCommando/releases), **verify it**, then:
   ```sh
   tar xzf dedcom-<version>-<triple>.tar.gz
   sudo install -m 755 dedcom /usr/local/bin/dedcom
   ```
2. **Cargo** — `cargo install dedupcommando` (the binary is `dedcom`; Linux only).
3. **From source** — a Docker-based build, no local Rust toolchain required (see CONTRIBUTING).

## First scan

```sh
dedcom              # multi-panel commander (default)
dedcom --classic    # classic stepwise wizard
dedcom --read-only  # read-only observer
dedcom -h           # all options
```

Pick scan roots, choose an intensity profile (Idle on a busy host), and start. After the scan, mark a keeper and an action per group, then review and apply — or save the plan as a shell script.

## Read the docs

- [README](https://github.com/dedupcommando/DedupCommando/blob/main/README.md) — overview and quickstart.
- [Full manual](https://github.com/dedupcommando/DedupCommando/tree/main/docs/manual) — install, data safety, scanning, actions, the Commando and Classic interfaces, headless/cron, maintenance, troubleshooting, hotkeys.
- [Safety, recovery & limitations](https://github.com/dedupcommando/DedupCommando/blob/main/docs/SAFETY.md).
- [Verifying releases](https://github.com/dedupcommando/DedupCommando/blob/main/docs/VERIFYING-RELEASES.md).
- [Contributing](https://github.com/dedupcommando/DedupCommando/blob/main/CONTRIBUTING.md) (DCO) · [Security policy](https://github.com/dedupcommando/DedupCommando/blob/main/SECURITY.md) · [Trademarks](https://github.com/dedupcommando/DedupCommando/blob/main/TRADEMARKS.md).

## Verify your download

Each release ships SHA-256 checksums, a CycloneDX SBOM, and a SLSA build-provenance attestation; minisign signatures are added once the project publishes its public key. See [Verifying releases](https://github.com/dedupcommando/DedupCommando/blob/main/docs/VERIFYING-RELEASES.md).

**Beta (v0.9.0-beta.1).**
