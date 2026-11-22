#!/usr/bin/env python3
"""Scaffold a new curriculum workspace (v2.0, self-contained, multi-track).

Tracks (--track mastery|video|article):
  mastery: <root>/profile.md + <root>/curriculum/day-NNN/lesson.md (8 sections)
           + <root>/reports/ + <root>/site/ (V3 chunks Days-01-15.html + index)
           Spec: references/track-mastery.md
  video:   <root>/profile.md + <root>/lessons/VideoNN/lesson.md (+ .srt)
           + <root>/lessons.html (V3 aggregated) + per-lesson lesson.html
           Spec: references/track-video.md
  article: <root>/profile.md + <root>/lessons/ArticleNN/lesson.md
           + <root>/lessons.html (V3 aggregated) + per-lesson lesson.html
           Spec: references/track-article.md

Creates curriculum.json manifest incl. skill version + track + layout.

Usage:
  python scripts/new_curriculum.py --root ./my-curriculum --title "English for Nurses"
  python scripts/new_curriculum.py --root ./my-curriculum --title "Business English for IT" --days 180 --domain "IT infrastructure"
  python scripts/new_curriculum.py --root ./yt --track video --title "YouTube Lessons"
  python scripts/new_curriculum.py --root ./art --track article --title "Article Lessons"
  python scripts/new_curriculum.py --root ./existing --force   # refresh skeleton files + manifest (never touches lessons/profile)

Only missing skeleton files are created; existing lessons and profile.md are
never overwritten. With --force, skeleton .gitkeep files and curriculum.json
are refreshed (lessons/profile still preserved).
"""
import argparse
import json
import shutil
import sys
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent


def skill_version() -> str:
    vf = SKILL_DIR / "VERSION"
    try:
        return vf.read_text(encoding="utf-8").strip()
    except OSError:
        return "unknown"


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True, help="Workspace directory to create")
    ap.add_argument("--title", default="New English Curriculum", help="Curriculum title")
    ap.add_argument("--days", type=int, default=180, help="Total days (default 180)")
    ap.add_argument("--domain", default="IT infrastructure",
                    help="Domain label recorded in the manifest")
    ap.add_argument("--track", default="mastery", choices=["mastery", "video", "article"],
                    help="Curriculum track (default mastery)")
    ap.add_argument("--force", action="store_true",
                    help="Recreate skeleton files (lessons are still preserved)")
    args = ap.parse_args()

    if not 1 <= args.days <= 365:
        ap.error("--days must be 1-365")

    root = Path(args.root)
    root.mkdir(parents=True, exist_ok=True)

    tpl = SKILL_DIR / "workspace-template"
    created = []

    # 1) profile.md from template (never overwrite an edited profile)
    profile = root / "profile.md"
    if not profile.exists():
        src = tpl / "profile.md"
        if src.exists():
            shutil.copy2(src, profile)
            created.append("profile.md")
    else:
        print(f"Keep existing profile.md (edit it per references/learner-profile.md)")

    # 2) skeleton dirs + .gitkeep (only if dir is new/empty, unless --force)
    if args.track == "mastery":
        want_dirs = ("curriculum", "reports", "site")
    else:
        want_dirs = ("lessons", "reports")
    for d in want_dirs:
        dd = root / d
        dd.mkdir(parents=True, exist_ok=True)
        if not any(dd.iterdir()) or args.force:
            src = tpl / d / ".gitkeep"
            if src.exists():
                shutil.copy2(src, dd / ".gitkeep")
                created.append(f"{d}/.gitkeep")
            elif d == "lessons":
                (dd / ".gitkeep").write_text("", encoding="utf-8")
                created.append(f"{d}/.gitkeep")

    # 3) manifest (merge: keep existing keys, refresh skill_version/title/days)
    manifest_path = root / "curriculum.json"
    manifest = {}
    if manifest_path.exists():
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        except ValueError:
            manifest = {}
    layout = {"mastery": "curriculum/day-NNN/lesson.md",
                "video": "lessons/VideoNN/lesson.md",
                "article": "lessons/ArticleNN/lesson.md"}[args.track]
    manifest.update({
        "title": args.title,
        "days": args.days,
        "domain": args.domain,
        "track": args.track,
        "skill": "business-english-for-tech",
        "skill_version": skill_version(),
        "layout": layout,
    })
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
                             encoding="utf-8")
    created.append("curriculum.json")

    print(f"Workspace ready: {root.resolve()}")
    print(f"  title='{args.title}' days={args.days} domain='{args.domain}' track='{args.track}'")
    for c in created:
        print(f"  wrote {c}")
    print("Next:")
    print("  1. Fill profile.md (all six sections).")
    if args.track == "mastery":
        print(f"  2. python {SKILL_DIR}/scripts/new_lesson.py --root {root} --track mastery --next --title \"...\"")
        print(f"  3. python {SKILL_DIR}/scripts/validate_track.py --root {root} --track mastery --partial")
        print(f"  4. python {SKILL_DIR}/scripts/build_v3.py --root {root} --track mastery")
    else:
        print(f"  2. python {SKILL_DIR}/scripts/new_lesson.py --root {root} --track {args.track} --next --title \"...\"")
        print(f"  3. python {SKILL_DIR}/scripts/validate_track.py --root {root} --track {args.track} --partial")
        print(f"  4. python {SKILL_DIR}/scripts/build_v3.py --root {root} --track {args.track}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
