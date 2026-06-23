#!/usr/bin/env sh
# Local gate for the DedupCommando landing site. Run from the landing/ directory.
#   sh check.sh             build with Zola, then verify the output
#   sh check.sh --no-build  verify an existing public/ only (skip the build)
# Requires zola (for the build step) plus POSIX sh and grep. Non-zero exit on failure.
set -u

PUB="public"
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

echo "== hreflang x-default -> /en/ (home) =="
if grep -q 'hreflang="x-default" href="https://dedupcommando.github.io/en/"' "$PUB/index.html"; then
  ok "x-default -> /en/"; else bad "x-default not -> /en/"; fi

echo "== sitemap excludes bare root / =="
if grep -q '<loc>https://dedupcommando.github.io/</loc>' "$PUB/sitemap.xml"; then
  bad "sitemap has bare root /"; else ok "no bare root in sitemap"; fi

echo "== no external scripts / CDNs / trackers =="
if grep -rInE '<script[^>]+src=|googleapis|google-analytics|gtag\(|cdn\.|jsdelivr|unpkg|fonts\.(google|gstatic)' "$PUB" 2>/dev/null; then
  bad "external resource or tracker found"; else ok "none"; fi

echo "== forbidden claims =="
if grep -rInE 'TrueNAS|ZFS deduplication|Proxmox DedupCommando|production-ready|production-grade' content "$PUB" 2>/dev/null; then
  bad "forbidden claim found"; else ok "none"; fi

echo "== arabic RTL =="
if grep -q '<html lang="ar" dir="rtl">' "$PUB/ar/index.html"; then ok "/ar/ dir=rtl"; else bad "/ar/ not rtl"; fi

echo
[ "$fail" = "0" ] && echo "PASS" || echo "FAIL"
exit "$fail"
