#!/usr/bin/env sh
# Local gate for the DedupCommando landing site. Run from the landing/ directory.
#   sh check.sh             build with Zola, then verify the output
#   sh check.sh --no-build  verify an existing public/ only (skip the build)
# Requires zola (for the build step) plus POSIX sh and grep. Non-zero exit on failure.
set -u

PUB="public"
BASE=$(sed -n 's/^base_url *= *"\([^"]*\)".*/\1/p' config.toml)
fail=0
ok()  { printf '  ok   %s\n' "$1"; }
bad() { printf '  FAIL %s\n' "$1"; fail=1; }

if [ "${1:-}" != "--no-build" ]; then
  echo "== zola build =="
  zola build || { echo "build failed"; exit 2; }
fi
[ -d "$PUB" ] || { echo "no $PUB/ (build first)"; exit 2; }

echo "== routes =="
for p in . en ar vi es zh-hans pt-br ru fr hi \
         en/zfs-file-deduplication en/proxmox-ve-duplicate-files \
         en/linux-duplicate-file-finder en/hardlink-vs-reflink \
         en/safety-and-recovery en/docs; do
  if [ -f "$PUB/$p/index.html" ]; then ok "/$p/"; else bad "/$p/ missing"; fi
done
for u in sitemap.xml robots.txt; do
  if [ -f "$PUB/$u" ]; then ok "$u"; else bad "$u missing"; fi
done

echo "== canonical: exactly one per page =="
bad_canon=0
for f in $(find "$PUB" -name index.html); do
  n=$(grep -c 'rel="canonical"' "$f" 2>/dev/null || echo 0)
  [ "$n" = "1" ] || { bad "canonical x$n: $f"; bad_canon=1; }
done
[ "$bad_canon" = "0" ] && ok "one canonical per page"

echo "== home: the retro desktop at / (en, x-default) and /ru/ =="
for p in index.html ru/index.html; do
  if grep -q "hreflang=\"x-default\" href=\"$BASE/\"" "$PUB/$p"; then ok "/$p: x-default -> /"; else bad "/$p: x-default not -> /"; fi
  if grep -q 'id="desktop"' "$PUB/$p"; then ok "/$p: retro desktop"; else bad "/$p: not the retro desktop"; fi
  n=$(grep -c '<h1' "$PUB/$p"); [ "$n" = "1" ] && ok "/$p: one <h1>" || bad "/$p: <h1> x$n"
done
if grep -q 'http-equiv="refresh"' "$PUB/en/docs/index.html"; then ok "/en/docs/ redirects to /en/"; else bad "/en/docs/ is not a redirect"; fi

echo "== sitemap: home pages in, redirects out =="
for u in "$BASE/" "$BASE/ru/" "$BASE/en/"; do
  if grep -q "<loc>$u</loc>" "$PUB/sitemap.xml"; then ok "sitemap has $u"; else bad "sitemap misses $u"; fi
done
if grep -q "<loc>$BASE/en/docs/</loc>" "$PUB/sitemap.xml"; then bad "sitemap lists the /en/docs/ redirect"; else ok "no redirect stubs in sitemap"; fi

echo "== no external scripts / CDNs / trackers =="
ext=$(grep -rhoE '<script[^>]+src="[^"]*"' "$PUB" | sed -E 's/.*src="([^"]*)".*/\1/' | grep -vE "^($BASE/|/)" || true)
if [ -n "$ext" ]; then bad "external script: $ext"; else ok "only own scripts"; fi
if grep -rInE 'googleapis|google-analytics|gtag\(|cdn\.|jsdelivr|unpkg|fonts\.(google|gstatic)' "$PUB" 2>/dev/null; then
  bad "external resource or tracker found"; else ok "no CDNs or trackers"; fi

echo "== forbidden claims =="
if grep -rInE 'TrueNAS|ZFS deduplication|Proxmox DedupCommando|production-ready|production-grade' content "$PUB" 2>/dev/null; then
  bad "forbidden claim found"; else ok "none"; fi

echo "== arabic RTL =="
if grep -q '<html lang="ar" dir="rtl">' "$PUB/ar/index.html"; then ok "/ar/ dir=rtl"; else bad "/ar/ not rtl"; fi

echo
[ "$fail" = "0" ] && echo "PASS" || echo "FAIL"
exit "$fail"
