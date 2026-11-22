#!/usr/bin/env python3
"""Bulk-validate workspace lessons against the locked Quality Gates (v1.2).

Scope: <root>/curriculum/day-NNN/lesson.md only (workspace layout).

Usage:
  python scripts/validate_all_md.py --root ./my-curriculum                  # strict: all days present, 0 issues
  python scripts/validate_all_md.py --root ./my-curriculum --partial        # incremental: check existing days only
  python scripts/validate_all_md.py --root ./my-curriculum --lint-quality  # quality lint (warnings-only, never fails build)
  (If cwd is a workspace, --root may be omitted.)

Checks per file: sections 1-12 in order + header/meta match filename,
Key 10 / Vocab 10 / Sentences 10 / Collocations 10 / Dialogue 10 turns
/ Errors 5 / Quick 5 / Real message 3+ sentences, Goal lines,
zero Key/Vocab overlap, A1 banned forms, §9 duration match,
end marker, no placeholders/em dashes.
Exit 0 = clean, 1 = issues found.
"""
import collections
import json
import re
import sys
from pathlib import Path

EXPECT_SECS = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']


def resolve_root(explicit: str | None) -> Path:
    if explicit:
        return Path(explicit)
    cwd = Path.cwd()
    if (cwd / "curriculum.json").exists() or (cwd / "curriculum").exists():
        return cwd
    raise SystemExit("Not a workspace (no curriculum.json or curriculum/ here). "
                     "Pass --root <workspace>.")


def workspace_days(root: Path) -> int:
    mf = root / "curriculum.json"
    if mf.exists():
        try:
            return int(json.loads(mf.read_text(encoding="utf-8")).get("days", 180))
        except (ValueError, TypeError):
            pass
    return 180


def sec_body(text, num):
    m = re.search(r'^### ' + num + r'\.', text, re.M)
    if not m:
        return None
    sub = text[m.end():]
    n = re.search(r'\n### \d+', sub)
    return sub[:n.start()] if n else sub


def table_rows(body):
    if body is None:
        return -1
    rows = [l for l in body.splitlines() if l.strip().startswith('|') and '---' not in l.strip()]
    return max(0, len(rows) - 1)


def table_data(body):
    """Return (header_cells, data_rows) for the first markdown table in body."""
    if body is None:
        return [], []
    rows = []
    for l in body.splitlines():
        s = l.strip()
        if s.startswith('|') and '---' not in s:
            rows.append([c.strip() for c in s.strip('|').split('|')])
    if not rows:
        return [], []
    return rows[0], rows[1:]


def numbered(body):
    if body is None:
        return -1
    return len(re.findall(r'^\d+\.\s', body, re.M))


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
    # Product names keep canonical capitals. URLs stay lowercase legitimately
    # (slugs) — exclude them first. Case-insensitive match, exact compare.
    text = re.sub(r"https?://\S+", "", text)
    bad = set()
    for low, canon in BRANDS.items():
        for m in re.finditer(r"(?<![A-Za-z])" + low + r"(?![A-Za-z])", text, re.I):
            if m.group(0) != canon:
                bad.add(canon)
                break
    return sorted(bad)


def check_file(path: Path, day: int):
    t = path.read_text(encoding="utf-8", errors="ignore")
    issues = []
    lines = t.splitlines()
    if not lines or not re.match(rf'^## Day {day:03d}:', lines[0]):
        issues.append('DAY HEADER/NUMBER mismatch')
    if len(lines) < 2 or not re.match(
            r'^\*\*Level:\*\*\s*.*?\s*\|\s*\*\*Speaking:\*\*\s*.*?\s*\|\s*\*\*Output:\*\*\s*.*$',
            lines[1]):
        issues.append('BAD META line')
    secs = re.findall(r'^### (\d+)\.', t, re.M)
    if secs != EXPECT_SECS:
        issues.append(f'SECTIONS {secs}')
    counts = {
        'key': table_rows(sec_body(t, '3')),
        'vocab': table_rows(sec_body(t, '4')),
        'sent': table_rows(sec_body(t, '5')),
        'colloc': table_rows(sec_body(t, '6')),
        'dialogue': table_rows(sec_body(t, '7')),
        'errors': numbered(sec_body(t, '11')),
        'quick': numbered(sec_body(t, '12')),
    }
    for k, c in counts.items():
        if k in ('key', 'vocab', 'sent', 'colloc', 'dialogue') and c != 10:
            issues.append(f'{k}={c} (want 10)')
        elif k in ('errors', 'quick') and c != 5:
            issues.append(f'{k}={c} (want 5)')
    sec10 = sec_body(t, '10') or ''
    m = re.search(r'\*\*Reference Message \(Solution\):\*\*\s*["\'](.*?)["\']', sec10, re.S)
    if m:
        sents = [s for s in re.split(r'[.!?]+', m.group(1)) if s.strip()]
        if len(sents) < 3:
            issues.append(f'real_msg sentences={len(sents)} (want >=3)')
    else:
        issues.append('no Reference Message in §10')
    if not t.strip().endswith('---'):
        issues.append('no ending ---')
    for num in EXPECT_SECS[1:]:
        b = sec_body(t, num) or ''
        if '> Goal:' not in b:
            issues.append(f'§{num} missing Goal line')
            break
    if '(ترجمة' in t or 'TODO' in t:
        issues.append('placeholders present')
    if '—' in t:
        issues.append('em dash present')
    _bh = brand_hits(t)
    if _bh:
        issues.append(f"Capitalize product names: {', '.join(_bh)}")

    # §3/§4 headword overlap check
    _, krows = table_data(sec_body(t, '3'))
    _, vrows = table_data(sec_body(t, '4'))
    k_words = {r[0].strip().lower() for r in krows if r}
    v_words = {r[0].strip().lower() for r in vrows if r}
    overlap = k_words & v_words
    if overlap:
        issues.append(f'Key/Vocab overlap: {sorted(overlap)[:3]}')

    # Dialogue alternation check (§7 must be 10 alternating turns)
    _d7 = sec_body(t, '7') or ''
    _roles = []
    for _line in _d7.splitlines():
        _s = _line.strip()
        if not _s.startswith('|') or '---' in _s:
            continue
        _cells = [c.strip() for c in _s.strip('|').split('|')]
        if _cells and _cells[0].lower() == 'english':
            continue
        _rm = re.match(r'\*\*(.+?):\*\*', _cells[0]) if _cells else None
        if _rm:
            _roles.append(_rm.group(1))
    if _roles and (len(_roles) != 10 or any(r != _roles[i % 2] for i, r in enumerate(_roles))):
        issues.append(f'DIALOGUE roles broken: {_roles[:4]}')

    # A1 strict bans (Days 001–020)
    if day <= 20:
        _ban = re.compile(
            r'\b(will|would|did\b|was|were|had\b|learned|learnt)\b'
            r'|yesterday|last (night|week)|if needed', re.I)
        for _ln in t.splitlines():
            if _ban.search(_ln) and 'Present Simple only' not in _ln:
                issues.append(f'A1-BANNED: {_ln.strip()[:60]}')
                break

    # §9 duration match (header vs Goal vs Reference Answer)
    sec9_header = re.search(r'^### 9\.\s*Speaking\s*\(([^)]+)\)', t, re.M | re.I)
    sec9_body = sec_body(t, '9') or ''
    if sec9_header:
        h_dur = sec9_header.group(1).strip().lower()
        if h_dur not in sec9_body.lower():
            issues.append(f'§9 duration mismatch (want {h_dur} in Goal + Reference Answer)')
        else:
            _goal_m = re.search(r'^>\s*Goal:.*$', sec9_body, re.M | re.I)
            if _goal_m and h_dur not in _goal_m.group(0).lower():
                issues.append(f'§9 Goal duration mismatch (want {h_dur})')
            _ref_m = re.search(r'\*\*Reference Answer\s*\(([^)]+)\):\*\*', sec9_body, re.I)
            if not _ref_m:
                issues.append('§9 missing **Reference Answer (TIME):** marker')
            elif _ref_m.group(1).strip().lower() != h_dur:
                issues.append(
                    f'§9 Reference Answer duration mismatch: "{_ref_m.group(1).strip()}" vs header "{h_dur}"')

    if re.search(r'\|### \d+\.', t):
        issues.append('GLUED HEADER (missing blank line before ###)')

    return issues


def lint_quality(files: list[tuple[int, Path]]) -> dict[Path, list[str]]:
    warnings = collections.defaultdict(list)
    prev_s2_text = None

    for day, path in files:
        t = path.read_text(encoding="utf-8", errors="ignore")

        # 1. §5 Sentence starter repetition
        s5 = sec_body(t, '5')
        if s5:
            _, rows = table_data(s5)
            starters = []
            for r in rows:
                if r:
                    en_sent = r[0].strip()
                    first_word = en_sent.split()[0].rstrip('.,:;!?').lower() if en_sent.split() else ''
                    if first_word:
                        starters.append(first_word)
            counts = collections.Counter(starters)
            for w, count in counts.items():
                if count >= 5:
                    warnings[path].append(f"§5 repetitive starter '{w}' used {count}/10 times")

        # 2. §2 Consecutive scenario check
        s2 = sec_body(t, '2')
        if s2:
            s2_clean = re.sub(r'\s+', ' ', s2.strip())
            if prev_s2_text and s2_clean == prev_s2_text:
                warnings[path].append("§2 identical scenario text to previous day")
            prev_s2_text = s2_clean

        # 3. §10 Genre detection check
        s10 = sec_body(t, '10')
        if s10:
            if not any(g in s10.lower() for g in ('teams', 'email', 'ticket', 'message')):
                warnings[path].append("§10 does not explicitly specify genre (Teams/Email/Ticket)")

    return warnings


def collect_files(root: Path, total: int):
    files = []
    for i in range(1, total + 1):
        p = root / "curriculum" / f"day-{i:03d}" / "lesson.md"
        if p.exists():
            files.append((i, p))
    return files


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    if "--help" in sys.argv or "-h" in sys.argv:
        print(__doc__.strip())
        print("Options: --root <workspace> [--partial] [--lint-quality]")
        return 0
    partial = "--partial" in sys.argv
    lint = "--lint-quality" in sys.argv
    argv = [a for a in sys.argv[1:] if a not in ("--partial", "--lint-quality")]
    explicit = None
    if "--root" in argv:
        i = argv.index("--root")
        try:
            explicit = argv[i + 1]
        except IndexError:
            raise SystemExit("--root needs a directory")
    root = resolve_root(explicit)
    total = workspace_days(root)
    files = collect_files(root, total)
    if not files:
        print(f"No lessons in {root}/curriculum (expected day-001..day-{total:03d}/lesson.md)")
        return 1
    missing = sorted(set(range(1, total + 1)) - {d for d, _ in files})
    bad = {}
    for day, path in files:
        iss = check_file(path, day)
        if iss:
            bad[path] = iss
    mode = "partial" if partial else "strict"
    print(f"Checked {len(files)}/{total} | missing={len(missing)} | "
          f"files with issues={len(bad)} | mode={mode} | root={root}")
    if missing and not partial:
        print(f"  MISSING days: {missing[:12]}{'...' if len(missing) > 12 else ''}")
    for p, iss in sorted(bad.items(), key=lambda x: str(x[0]))[:15]:
        print(f"  {p}: {iss}")

    if lint:
        print("\n--- QUALITY LINT ANALYSIS ---")
        q_warnings = lint_quality(files)
        if not q_warnings:
            print("  Quality lint clean: good starter diversity and scenario rotation.")
        else:
            for p, warns in sorted(q_warnings.items(), key=lambda x: str(x[0]))[:10]:
                for w in warns:
                    print(f"  [WARN] {p.name}: {w}")

    fail = bool(bad) or (bool(missing) and not partial)
    return 1 if fail else 0


if __name__ == "__main__":
    raise SystemExit(main())
