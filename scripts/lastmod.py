#!/usr/bin/env python3
"""Write data/lastmod.json: the date each section of the site last changed, for <lastmod> in the sitemap.

Zola gives pages a date but not sections, and most of this site is sections. A section's date is the
last commit that touched its _index.md or, when the section uses its own template (the retro home
pages), that template. The manual and changelog indexes come from data/upstream-lastmod.json, which
scripts/sync_docs.py writes from the code repository's history.

    python scripts/lastmod.py [--root <site>]

Files with uncommitted changes get today's date, so a local preview never shows a stale date.
"""
from __future__ import annotations

import argparse
import datetime
import json
import re
import subprocess
import sys
from pathlib import Path

GENERATED_DIRS = {"en/manual", "en/changelog"}  # written by sync_docs.py; dated from the code repo


def git_date(root: Path, files: list[Path]) -> str | None:
    rel = [str(f.relative_to(root)).replace("\\", "/") for f in files]
    dirty = subprocess.run(["git", "-C", str(root), "status", "--porcelain", "--", *rel],
                           capture_output=True, text=True).stdout.strip()
    if dirty:
        return datetime.date.today().isoformat()
    out = subprocess.run(["git", "-C", str(root), "log", "-1", "--format=%cs", "--", *rel],
                         capture_output=True, text=True).stdout.strip()
    return out or None


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--root", default=str(Path(__file__).resolve().parents[1]))
    root = Path(ap.parse_args().root).resolve()
    content = root / "content"

    entries: dict[str, str] = {}
    for index in sorted(content.rglob("_index.md")):
        section_dir = index.parent.relative_to(content).as_posix()
        if section_dir == ".":
            section_dir = ""
        if section_dir in GENERATED_DIRS:
            continue
        sources = [index]
        m = re.search(r'^template\s*=\s*"([^"]+)"', index.read_text(encoding="utf-8"), re.M)
        if m and (root / "templates" / m.group(1)).exists() and m.group(1) not in ("home.html",):
            sources.append(root / "templates" / m.group(1))
        date = git_date(root, sources)
        if not date:
            print(f"lastmod: no date for {index}", file=sys.stderr)
            return 1
        entries["/" + (section_dir + "/" if section_dir else "")] = date

    upstream = root / "data" / "upstream-lastmod.json"
    if upstream.exists():
        for item in json.loads(upstream.read_text(encoding="utf-8")):
            entries[item["path"]] = item["lastmod"]

    (root / "data").mkdir(exist_ok=True)
    with open(root / "data" / "lastmod.json", "w", encoding="utf-8", newline="\n") as f:
        json.dump([{"path": p, "lastmod": d} for p, d in sorted(entries.items())], f, indent=2)
        f.write("\n")
    print(f"lastmod: {len(entries)} sections dated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
