<#
.SYNOPSIS
  Build and check the site locally the way CI does: sync the docs, build with Zola, run check.sh.

.DESCRIPTION
  1. scripts/sync_docs.py writes the manual, docs and release notes from a checkout of
     dedupcommando/DedupCommando at the commit pinned in upstream.lock.
  2. scripts/lastmod.py dates every section for the sitemap.
  3. Zola 0.19.2 builds public/ (from the official Docker image unless -Native is given).
  4. check.sh verifies the result with Git for Windows' sh.

.EXAMPLE
  pwsh scripts/build.ps1 -Repo ../DedupCommando
.EXAMPLE
  $env:DEDCOM_REPO = '../DedupCommando'; pwsh scripts/build.ps1 -Serve
#>
[CmdletBinding()]
param(
  # Checkout of dedupcommando/DedupCommando; defaults to $env:DEDCOM_REPO.
  [string]$Repo = $env:DEDCOM_REPO,
  # Build with the text already in content/ (skip the sync).
  [switch]$NoSync,
  # Live preview instead of a build; serves on http://127.0.0.1:<Port>/.
  [switch]$Serve,
  [int]$Port = 1111,
  # Use a zola binary from PATH instead of Docker.
  [switch]$Native
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$image = 'ghcr.io/getzola/zola:v0.19.2'

if (-not $NoSync) {
  if (-not $Repo) { throw 'Pass -Repo <checkout of dedupcommando/DedupCommando> or set $env:DEDCOM_REPO.' }
  python "$root/scripts/sync_docs.py" --repo $Repo --out $root
  if ($LASTEXITCODE) { throw 'sync_docs.py failed' }
}
python "$root/scripts/lastmod.py" --root $root
if ($LASTEXITCODE) { throw 'lastmod.py failed' }

function Invoke-Zola([string[]]$ZolaArgs, [int[]]$Publish = @()) {
  if ($Native) {
    Push-Location $root
    try { & zola @ZolaArgs } finally { Pop-Location }
  } else {
    $ports = @(); foreach ($p in $Publish) { $ports += @('-p', "$($p):$($p)") }
    # The image's entrypoint is zola itself, so only the subcommand is passed.
    docker run --rm @ports -v "$($root):/site" -w /site $image @ZolaArgs
  }
  if ($LASTEXITCODE) { throw "zola $($ZolaArgs[0]) failed" }
}

if ($Serve) {
  Invoke-Zola @('serve', '--interface', '0.0.0.0', '--port', "$Port", '--base-url', '127.0.0.1') @($Port)
  return
}

Invoke-Zola @('build')

# git.exe may sit in Git\cmd, Git\bin or Git\mingw64\bin; sh.exe is in Git\bin.
$dir = Split-Path (Get-Command git).Source -Parent
$sh = $null
for ($i = 0; $i -lt 4 -and $dir; $i++) {
  $candidate = Join-Path $dir 'bin\sh.exe'
  if (Test-Path $candidate) { $sh = $candidate; break }
  if (Test-Path (Join-Path $dir 'sh.exe')) { $sh = Join-Path $dir 'sh.exe'; break }
  $dir = Split-Path $dir -Parent
}
if (-not $sh) { throw 'sh.exe from Git for Windows not found near git.exe' }
Push-Location $root
try {
  & $sh ./check.sh --no-build
  if ($LASTEXITCODE) { throw 'check.sh failed' }
} finally { Pop-Location }
