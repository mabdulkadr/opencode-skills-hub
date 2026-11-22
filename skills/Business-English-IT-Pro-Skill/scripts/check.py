#!/usr/bin/env python3
"""Full workspace check (v2.0 multi-track): strict validation + HTML build + output check.

Usage:
  python scripts/check.py --root ./my-curriculum                       # mastery legacy (v1.x 12-section)
  python scripts/check.py --root ./my-curriculum --track mastery       # mastery V3 (8 sections)
  python scripts/check.py --root ./yt/lessons --track video            # video track
  python scripts/check.py --root ./art/lessons --track article         # article track
  (If cwd is a workspace, --root may be omitted.)

Exit 0 only when validation is clean AND the build QA passes AND
expected HTML outputs exist.
"""
import subprocess
import sys
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    args = sys.argv[1:]
    root = None
    if "--root" in args:
        i = args.index("--root")
        try:
            root = args[i + 1]
        except IndexError:
            raise SystemExit("--root needs a directory")
    else:
        cwd = Path.cwd()
        if (cwd / "curriculum.json").exists() or (cwd / "curriculum").exists():
            root = str(cwd)
    if not root:
        raise SystemExit("Not a workspace. Pass --root <workspace>.")
    root_p = Path(root)

    track = "mastery-legacy"
    rest = [a for a in args if a != "--track" and a != track]
    if "--track" in args:
        i = args.index("--track")
        try:
            track = args[i + 1]
        except IndexError:
            raise SystemExit("--track needs mastery|video|article")
        rest = [a for j, a in enumerate(args) if j not in (i, i + 1)]

    code = 0
    if track == "mastery-legacy":
        steps = (("validate_all_md.py", []), ("build.py", []))
    else:
        if track not in ("mastery", "video", "article"):
            raise SystemExit("--track must be mastery|video|article")
        steps = (("validate_track.py", ["--track", track]), ("build_v3.py", ["--track", track]))
    for script, extra in steps:
        cmd = [sys.executable, str(SKILL_DIR / "scripts" / script),
               "--root", str(root_p)] + extra
        print(f"$ {' '.join(cmd)}")
        r = subprocess.run(cmd)
        code |= r.returncode

    if track in ("mastery-legacy", "mastery"):
        site = root_p / "site" if (root_p / "site").exists() else root_p / "html"
        # legacy layout uses site/, published mastery uses html/
        cands = []
        if (root_p / "site").exists():
            cands += sorted((root_p / "site").glob("days-*.html")) + sorted((root_p / "site").glob("Days-*.html"))
        if (root_p / "html").exists():
            cands += sorted((root_p / "html").glob("Days-*.html")) + sorted((root_p / "html").glob("days-*.html"))
        idx = (root_p / "site" / "index.html") if (root_p / "site" / "index.html").exists() else (root_p / "html" / "index.html")
        if not idx.exists() or not cands:
            print(f"CHECK FAIL: missing generated HTML (index={idx.exists()}, chunks={len(cands)})")
            code |= 1
        else:
            print(f"CHECK OK: {len(cands)} chunk(s) + index")
    else:
        lessons_html = root_p / "lessons.html"
        singles = sorted(root_p.glob("*/lesson.html"))
        if not lessons_html.exists() or not singles:
            print(f"CHECK FAIL: missing V3 HTML in {root_p} (lessons.html={lessons_html.exists()}, singles={len(singles)})")
            code |= 1
        else:
            print(f"CHECK OK: lessons.html + {len(singles)} single(s) in {root_p}")
    _ = rest
    return 1 if code else 0


if __name__ == "__main__":
    raise SystemExit(main())
