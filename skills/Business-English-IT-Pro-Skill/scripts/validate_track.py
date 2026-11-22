#!/usr/bin/env python3
"""Multi-track validator (v3.3): mastery | video | article.

Workspace-mode snapshot (pre-hub-Batch-110/111): section names below are the
legacy ones (Real IT Situation / Workplace English / Listening Notes /
authored Final Recall, 8+Map / 11-section). Hub `src/` follows the CURRENT
contracts in references/track-mastery.md (Core-pattern 9 + Map, new names),
references/track-video.md + track-article.md (Media 10 headings) and is
governed by `node tech-english-hub/scripts/validate.js` — hub wins on
conflict. Do NOT run this script against hub `src/`.

Usage:
  python scripts/validate_track.py --root <workspace> --track mastery [--partial]
  python scripts/validate_track.py --root <lessons-dir> --track video [--partial]
  python scripts/validate_track.py --root <lessons-dir> --track article [--partial]

Exit 0 = clean, 1 = issues found.
"""
import re
import sys
from pathlib import Path


def sec_body(text, name_pat):
    # Accept variant titles: base name + optional " (Review...)" / ": ..." suffix
    m = re.search(r"^### " + name_pat + r"(?:\s*[(|:].*)?\s*$", text, re.M)
    if not m:
        return None
    sub = text[m.end():]
    n = re.search(r"\n### ", sub)
    return sub[:n.start()] if n else sub


def table_rows(body):
    if body is None:
        return -1
    rows = [l for l in body.splitlines() if l.strip().startswith("|") and "---" not in l.strip()]
    return max(0, len(rows) - 1)


def numbered(body):
    if body is None:
        return -1
    return len(re.findall(r"^\d+\.\s", body, re.M))


# --- Naturalness gate (references/natural-english.md, locked) ---------------

ARABIC_RE = re.compile(r"[\u0600-\u06ff]")

AI_PATTERN_RE = re.compile(
    r"(please be advised|it is important to note|i would like to inform|"
    r"would you kindly|kindly investigate|i would appreciate it if|"
    r"i am writing to you)",
    re.I,
)

BROKEN_WHEREAS_RE = re.compile(r"(?i)\bwhereas\b([^.\n?!]{0,60})")


def _whereas_issues(t):
    # Machine proxy only. A whereas-sentence is legitimate when it carries a
    # comma on EITHER side (", whereas B" or "Whereas A, B") with a real
    # clause after/before it. Flag: no comma at all (dangling), or a
    # single-word clause after whereas (fragment). Semantic cases and parallel
    # ellipsis ("Whereas managers skim, engineers follow.") are Human QA.
    out = []
    # Stance-kit markers live inside backticks (`Whereas stuck`, `If phased`)
    # — they are reusable templates, not sentences. Strip them first.
    t = re.sub(r"`[^`]*`", "", t)
    # Split on sentence ends only (period followed by space + capital/end —
    # version numbers like 4.8 must NOT split sentences).
    for sent in re.split(r"(?<=[.?!])\s+(?=[A-Z*\"“\d])|\n", t):
        if not re.search(r"(?i)\bwhereas\b", sent):
            continue
        if "," not in sent:
            out.append("dangling whereas (no second clause)")
            continue
        pre = re.split(r"(?i)\bwhereas\b", sent, maxsplit=1)[1].split(",")[0].strip()
        # Stance-kit placeholders (`Whereas X, Y`, `Whereas [reading], ...`)
        # are teaching templates, not broken English.
        if pre and ("[" in pre or re.match(r"^[XY]\b", pre)):
            continue
        if pre and len(pre.split()) < 2:
            out.append("fragment whereas (no subject+verb)")
    return out


def _table_cells(t):
    """Yield (section, all_english_cells_of_row) for md tables.

    Naturalness rules (references/natural-english.md): inside a Collocations
    table the FIRST column is the chunk headword — chunks may be short, so it
    is exempt from the full-sentence Example check.
    """
    sec = "<top>"
    for line in t.splitlines():
        h = re.match(r"^### (.+)$", line)
        if h:
            sec = re.split(r"\s*[(|:]", h.group(1))[0].strip()
            continue
        s = line.strip()
        if not s.startswith("|") or "---" in s:
            continue
        cells = [c.strip() for c in s.strip("|").split("|")]
        en = [c for c in cells if c and not ARABIC_RE.search(c)]
        if sec.lower().startswith("collocation") and en:
            en = en[1:]  # exemption: headword chunk column
        if en:
            yield sec, en


BRANDS = {
    "microsoft": "Microsoft",
    "purview": "Purview",
    "entra": "Entra",
    "intune": "Intune",
    "sharepoint": "SharePoint",
    "zabbix": "Zabbix",
    "defender": "Defender",
    "onedrive": "OneDrive",
}


def brand_hits(text):
    # Product names keep canonical capitals (MICROSOFT / MicroSoft / microsoft
    # in prose are all wrong). URLs stay lowercase legitimately (slugs) —
    # exclude them first. Case-insensitive match, exact-canonical compare.
    text = re.sub(r"https?://\S+", "", text)
    bad = set()
    for low, canon in BRANDS.items():
        for m in re.finditer(r"(?<![A-Za-z])" + low + r"(?![A-Za-z])", text, re.I):
            if m.group(0) != canon:
                bad.add(canon)
                break
    return sorted(bad)


def naturalness_issues(t):
    issues, warns = [], []
    # Intentional learner errors (Common Errors ❌ lines) are teaching
    # content — never flag them; check only the ✅ corrections and models.
    clean = "\n".join(
        ln for ln in t.splitlines() if not re.match(r"^\d+\.\s*❌", ln.strip()))
    t = clean
    hit = AI_PATTERN_RE.search(t)
    if hit:
        issues.append(f"AI-pattern sentence: '{hit.group(0)}'")
    if "(ترجمة" in t:
        issues.append("PLACEHOLDER (ترجمة)")
    wh = _whereas_issues(t)
    if wh:
        issues.append(f"broken whereas: {wh[0]} ({len(wh)}x)")
    level = re.search(r"\*\*Level:\*\*\s*([A-C]1?|C2)", t)
    is_c = bool(level and level.group(1) in ("C1", "C2"))
    short = [
        c for sec, en in _table_cells(t) for c in en
        if len(c.split()) <= 3 and c.endswith(".") and not c.lower().endswith(("etc.", "e.g.", "vs."))
        # pronunciation-guide rows are teaching content, not broken examples
        # (e.g. "Stress NOS: dy-ag-NOS-tiks." / "Tool name: VEE-em-ware.")
        and not re.search(r":\s*[\w-]*[A-Z]{2,}[\w-]*", c)
    ]
    if short:
        # C1/C2 telegraphic fragments are never acceptable; below C they need
        # human QA ranking (a natural full sentence like "I exported PDFs."
        # may outrank a longer stuffed one).
        (issues if is_c else warns).append(
            f"short examples ({len(short)}, human QA): {short[:3]}")
    return issues, warns


def check_mastery(path: Path):
    t = path.read_text(encoding="utf-8", errors="ignore")
    issues = []
    lines = t.splitlines()
    m0 = re.match(r"^## Day (\d{3}):\s*(.+)$", lines[0] if lines else "")
    if not m0:
        issues.append("DAY HEADER mismatch (want '## Day NNN: Title')")
    else:
        num = m0.group(1)
        if path.name != f"Day-{num}.md" and path.name != "lesson.md":
            issues.append(f"FILENAME/HEADER mismatch ({path.name} vs Day-{num})")
    if len(lines) < 2 or not re.match(
        r"^\*\*Level:\*\*\s*.*?\s*\|\s*\*\*Speaking:\*\*\s*.*?\s*\|\s*\*\*Output:\*\*\s*.*$", lines[1] if len(lines) > 1 else ""):
        issues.append("BAD META line")
    secs = re.findall(r"^### (.+)$", t, re.M)
    want = ["Mission", "Real IT Situation", "Key Language", "Vocabulary",
            "Useful Sentences", "Collocations", "Common Errors", "Workplace English"]
    norm = [re.split(r"\s*[(|:]", s)[0].strip() for s in secs]
    if norm != want:
        # published Core curriculum also carries an optional leading Lesson Map
        if not (norm[:1] == ["Lesson Map"] and norm[1:] == want):
            issues.append(f"SECTIONS {secs} (want {want})")
    counts = {
        "situation": table_rows(sec_body(t, "Real IT Situation")),
        "key": table_rows(sec_body(t, "Key Language")),
        "vocab": table_rows(sec_body(t, "Vocabulary")),
        "sent": table_rows(sec_body(t, "Useful Sentences")),
        "colloc": table_rows(sec_body(t, "Collocations")),
        "errors": numbered(sec_body(t, "Common Errors")),
    }
    if counts["situation"] != 1:
        issues.append(f'situation={counts["situation"]} (want 1)')
    if not (12 <= counts["key"] <= 15):
        issues.append(f'key={counts["key"]} (want 12-15)')
    if not (15 <= counts["vocab"] <= 20):
        issues.append(f'vocab={counts["vocab"]} (want 15-20)')
    if counts["sent"] != 25:
        issues.append(f'sent={counts["sent"]} (want 25)')
    if not (12 <= counts["colloc"] <= 15):
        issues.append(f'colloc={counts["colloc"]} (want 12-15)')
    if not (8 <= counts["errors"] <= 10):
        issues.append(f'errors={counts["errors"]} (want 8-10)')
    for sec in ("Real IT Situation", "Key Language", "Vocabulary", "Useful Sentences", "Collocations", "Common Errors"):
        b = sec_body(t, re.escape(sec))
        if b is not None and "> Goal:" not in b and sec != "Mission":
            # Workplace English also has Goal; Mission has none
            if sec in ("Real IT Situation", "Key Language", "Vocabulary", "Useful Sentences", "Collocations", "Common Errors"):
                issues.append(f"{sec} missing Goal line")
                break
    wb = sec_body(t, "Workplace English")
    if wb is None or len(wb.strip()) < 200:
        issues.append("Workplace English too short (<200 chars)")
    if not t.rstrip().endswith("---"):
        issues.append("NO END MARKER")
    if "(ترجمة" in t:
        issues.append("PLACEHOLDER (ترجمة)")
    _bh = brand_hits(t)
    if _bh:
        issues.append(f"Capitalize product names: {', '.join(_bh)}")
    iss, w = naturalness_issues(t)
    issues += iss
    return issues, w


VIDEO_SECS = ["Video Context", "Key Words from the Video", "Important Phrases from the Video",
              "Important Sentences from the Video", "Collocations", "Vocabulary Expansion",
              "Listening Notes", "Common English Patterns", "Workplace English",
              "Speaking Practice", "Final Recall"]

ARTICLE_SECS = ["Article Context", "Key Words from the Article", "Important Phrases from the Article",
                "Important Sentences from the Article", "Collocations", "Vocabulary Expansion",
                "Listening Notes", "Common English Patterns", "Workplace English",
                "Speaking Practice", "Final Recall"]


def check_link(path: Path, kind: str):
    t = path.read_text(encoding="utf-8", errors="ignore")
    issues = []
    lines = t.splitlines()
    tag = "Video" if kind == "video" else "Article"
    # Published hub form: '## Video01: Title' · legacy form: '## Lesson: Video01: Title'
    idpat = r"^## (?:Lesson: )?(Video\d+|Article\d+):\s*(.+)$"
    m0 = re.match(idpat, lines[0] if lines else "")
    if not m0:
        issues.append(f"LESSON HEADER mismatch (want '## {tag}NN: Title' or '## Lesson: {tag}NN: Title')")
    # Meta may be a separate line 2, or appended to the H1 line with " | **Level:** ..."
    meta_ok = False
    for cand in (lines[0] if lines else "", lines[1] if len(lines) > 1 else ""):
        if re.search(
            r"\*\*Level:\*\*\s*.*?\s*\|\s*\*\*Speaking:\*\*\s*.*?\s*\|\s*\*\*Output:\*\*\s*.*", cand):
            meta_ok = True
            break
    if not meta_ok:
        issues.append("BAD META line")
    if "> Sources:" not in t:
        issues.append("MISSING Sources block (> Sources: ...)")
    if "By the end of this lesson, I can" not in t:
        issues.append("MISSING 'By the end of this lesson, I can...' line")
    secs = re.findall(r"^### (.+)$", t, re.M)
    want = VIDEO_SECS if kind == "video" else ARTICLE_SECS
    norm = [re.split(r"\s*[(|:]", s)[0].strip() for s in secs]
    if norm != want:
        # published media lessons also carry an optional leading Lesson Map
        if not (norm[:1] == ["Lesson Map"] and norm[1:] == want):
            issues.append(f"SECTIONS {secs} (want {want})")
    ctx = sec_body(t, f"{tag} Context")
    if ctx is None or "> Goal:" not in ctx:
        issues.append(f"{tag} Context missing Goal")
    kw = sec_body(t, f"Key Words from the {tag}")
    if kind == "video":
        if kw is None or "**Must know" not in kw or "**Useful" not in kw:
            issues.append("Key Words missing Must/Useful split")
        if kw is not None and "You will also hear these" not in kw and "You will also hear this" not in kw:
            issues.append("Key Words missing hear-only line")
        # ranges (source-driven, wide)
        total = table_rows(kw)
        if not (25 <= total <= 75):
            issues.append(f"key_total={total} (want 25-75)")
    else:
        total = table_rows(kw)
        if not (25 <= total <= 36):
            issues.append(f"key_total={total} (want 25-36)")
    ph = table_rows(sec_body(t, f"Important Phrases from the {tag}"))
    if kind == "video":
        if not (8 <= ph <= 13):
            issues.append(f"phrases={ph} (want 8-13)")
    else:
        if not (10 <= ph <= 14):
            issues.append(f"phrases={ph} (want 10-14)")
    coll = table_rows(sec_body(t, "Collocations"))
    if kind == "video":
        if not (10 <= coll <= 12):
            issues.append(f"colloc={coll} (want 10-12)")
    else:
        if coll != 10:
            issues.append(f"colloc={coll} (want 10)")
    exp = table_rows(sec_body(t, "Vocabulary Expansion"))
    if not (8 <= exp <= 10):
        issues.append(f"expansion={exp} (want 8-10)")
    if kind == "video":
        lb = sec_body(t, "Listening Notes") or ""
        if "**Traps" not in lb or "**Hard terms" not in lb:
            issues.append("Listening Notes missing Traps/Hard-terms split")
    else:
        lb = table_rows(sec_body(t, "Listening Notes"))
        if lb != 7:
            issues.append(f"listening={lb} (want 7)")
    pats = table_rows(sec_body(t, "Common English Patterns"))
    if pats != 6:
        issues.append(f"patterns={pats} (want 6)")
    sp = sec_body(t, "Speaking Practice") or ""
    if "**Task:**" not in sp or "**Model Answer:**" not in sp:
        issues.append("Speaking Practice missing Task/Model Answer")
    fr = sec_body(t, "Final Recall") or ""
    nq = numbered(fr)
    if kind == "video":
        if not (8 <= nq <= 9):
            issues.append(f"recallQ={nq} (want 8-9)")
    else:
        if nq != 6:
            issues.append(f"recallQ={nq} (want 6)")
    if "> Goal:" not in fr:
        issues.append("Final Recall missing Goal")
    if not t.rstrip().endswith("---"):
        issues.append("NO END MARKER")
    if "(ترجمة" in t:
        issues.append("PLACEHOLDER (ترجمة)")
    _bh = brand_hits(t)
    if _bh:
        issues.append(f"Capitalize product names: {', '.join(_bh)}")
    iss, w = naturalness_issues(t)
    issues += iss
    return issues, w


def collect(root: Path, track: str):
    files = []
    if track == "mastery":
        for p in sorted(root.rglob("Day-*.md")) + sorted(root.rglob("day-*/lesson.md")) + sorted(root.rglob("lesson.md")):
            # avoid duplicates: only accept Day-NNN.md or day-NNN/lesson.md
            if re.search(r"Day-\d+\.md$|day-\d+/lesson\.md$", str(p).replace("\\", "/")):
                # derive day number
                m = re.search(r"[Dd]ay-(\d+)", str(p).replace("\\", "/"))
                day = int(m.group(1)) if m else 0
                files.append((day, p))
        files = sorted(set(files))
    else:
        tag = "Video" if track == "video" else "Article"
        # Hub layout: src/videos/videoNN-<slug>/lesson.md · src/articles/articleNN-<slug>/lesson.md
        # Workspace layout: lessons/VideoNN/lesson.md (both accepted, case-insensitive)
        for p in sorted(root.rglob("lesson.md")):
            parts = str(p).replace("\\", "/").split("/")
            parent = parts[-2] if len(parts) >= 2 else ""
            m = re.match(rf"(?i)^({tag.lower()})(\d+)", parent)
            if m:
                n = int(m.group(2))
                files.append((n, p))
    return files


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=None)
    ap.add_argument("--track", required=True, choices=["mastery", "video", "article"])
    ap.add_argument("--partial", action="store_true")
    args = ap.parse_args()
    root = Path(args.root) if args.root else Path.cwd()
    files = collect(root, args.track)
    if not files:
        print(f"No {args.track} lessons under {root}")
        return 1
    bad, warns = {}, {}
    for n, p in files:
        iss, w = check_mastery(p) if args.track == "mastery" else check_link(p, args.track)
        if iss:
            bad[str(p)] = iss
        if w:
            warns[str(p)] = w
    mode = "partial" if args.partial else "strict"
    print(f"Checked {len(files)} {args.track} lessons | files with issues={len(bad)} |"
          f" files with human-QA warnings={len(warns)} | mode={mode} | root={root}")
    for p, w in sorted(warns.items())[:8]:
        print(f"  WARN {p}: {w}")
    for p, iss in sorted(bad.items())[:15]:
        print(f"  {p}: {iss}")
    return 1 if bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
