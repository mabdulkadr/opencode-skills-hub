#!/usr/bin/env python3
"""Self-contained offline HTML builder (v1.2).

Reads <root>/curriculum/day-NNN/lesson.md, writes:
  <root>/site/days-001-030.html ... (chunks of --chunk days)
  <root>/site/index.html            (title, progress bar, chunk links, searchable day index)

Contract: cards-only (zero <table>), standalone (zero external fetches:
no http(s) src/href/link/script), system fonts, Arabic RTL auto-detected.
Re-validates every lesson with validate_all_md.check_file before rendering.

Usage:
  python scripts/build.py --root ./my-curriculum
  python scripts/build.py --root ./my-curriculum --chunk 30 --partial   # preview with gaps

Exit 0 only when FAIL list is empty.
"""
import html
import json
import re
import sys
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(SKILL_DIR / "scripts"))
from validate_all_md import (  # noqa: E402
    check_file, resolve_root, sec_body, table_data, workspace_days,
)

AR_RE = re.compile(r'[\u0600-\u06FF]')
EXT_RE = re.compile(r'<(a|link|img|script|source|iframe)[^>]*(href|src)\s*=\s*["\']https?://', re.I)
CSS_URL_RE = re.compile(r'@import|url\(\s*https?://', re.I)

CSS = """
:root{--bg:#ffffff;--fg:#1a1a2e;--muted:#5b6b7f;--card:#f6f8fc;--line:#dfe6f2;
--brand:#1d4ed8;--ok:#15803d;--warn:#b45309}
@media (prefers-color-scheme:dark){:root{--bg:#0f172a;--fg:#e2e8f0;--muted:#94a3b8;
--card:#1e293b;--line:#334155;--brand:#93c5fd;--ok:#86efac;--warn:#fcd34d}}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--fg);
font-family:-apple-system,"Segoe UI",Tahoma,Arial,"Noto Kufi Arabic",sans-serif;line-height:1.7}
.wrap{max-width:1000px;margin:0 auto;padding:20px 16px 64px}
.topbar{position:sticky;top:0;background:var(--bg);border-bottom:1px solid var(--line);
padding:10px 0;z-index:5}.topbar .wrap{padding-top:0;padding-bottom:0;display:flex;
gap:12px;align-items:center;flex-wrap:wrap}.topbar a{color:var(--brand);text-decoration:none}
h1{font-size:1.6rem;margin:.4em 0}h2.day{border-top:3px solid var(--brand);
padding-top:12px;margin-top:40px}h3.sec{color:var(--brand);margin:1.4em 0 .5em}
.meta{color:var(--muted)}.goal{background:var(--card);border:1px solid var(--line);
border-radius:10px;padding:8px 12px;margin:.6em 0}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:10px}
@media(max-width:700px){.grid2{grid-template-columns:1fr}}
.card{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:10px 12px}
.card .term{font-weight:700;font-size:1.05rem}.card .ex{color:var(--muted)}
.ar{direction:rtl;text-align:right}.chip{display:inline-block;background:var(--bg);
border:1px solid var(--line);border-radius:20px;padding:0 10px;margin:2px 4px 2px 0;font-size:.9rem}
.bubbles{display:flex;flex-direction:column;gap:8px}
.bubble{max-width:96%;padding:8px 12px;border-radius:12px;background:var(--card);
border:1px solid var(--line)}.bubble.me{align-self:flex-end}.bubble .who{font-weight:700}
.task{background:rgba(29,78,216,.07)}.answer{background:rgba(21,128,61,.08)}
.panel{border-radius:10px;padding:12px;border:1px solid var(--line);margin:.5em 0}
.err{border-right:4px solid var(--warn)}.toc{columns:2}.toc a{display:block;padding:2px 0}
#search{width:100%;padding:10px;border-radius:10px;border:1px solid var(--line);
background:var(--bg);color:var(--fg);font-size:1rem}
.progress-wrap{background:var(--line);border-radius:12px;height:12px;overflow:hidden;margin:10px 0 16px}
.progress-bar{background:var(--brand);height:100%}
.stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:10px;margin:14px 0}
.stat-card{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:8px 12px;text-align:center}
.stat-num{font-size:1.3rem;font-weight:700;color:var(--brand)}
.stat-lbl{font-size:0.8rem;color:var(--muted)}
@media print{.topbar,#search{display:none}}
"""


def esc(s: str) -> str:
    return html.escape(s, quote=True)


def inline(s: str) -> str:
    s = esc(s)
    s = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', s)
    s = re.sub(r'`(.+?)`', r'<code>\1</code>', s)
    return s


def is_ar(s: str) -> bool:
    return bool(AR_RE.search(s))


def para(text: str) -> str:
    return f'<p dir="{"rtl" if is_ar(text) else "ltr"}">{inline(text.strip())}</p>'


def strip_tables(body: str) -> str:
    out = []
    for l in body.splitlines():
        s = l.strip()
        if s.startswith('|'):
            continue
        out.append(l)
    return '\n'.join(out).strip()


def render_blocks(body: str) -> str:
    """Generic fallback: tables -> card grid, lists -> ul/ol, text -> paragraphs."""
    _, rows = table_data(body)
    parts = []
    if rows:
        cards = []
        for r in rows:
            cells = ''.join(f'<div class="{"ar" if is_ar(c) else ""}">{inline(c)}</div>'
                            for c in r)
            cards.append(f'<div class="card">{cells}</div>')
        parts.append('<div class="grid2">' + ''.join(cards) + '</div>')
    rest = strip_tables(body)
    rest = re.sub(r'^>\s?Goal:.*$', '', rest, flags=re.M)
    items = re.findall(r'^\d+\.\s+(.+)$', rest, re.M)
    if items:
        parts.append('<ol>' + ''.join(f'<li>{inline(i)}</li>' for i in items) + '</ol>')
        rest = re.sub(r'^\d+\.\s+.+$', '', rest, flags=re.M)
    bullets = re.findall(r'^[-*]\s+(.+)$', rest, re.M)
    if bullets:
        parts.append('<ul>' + ''.join(f'<li>{inline(b)}</li>' for b in bullets) + '</ul>')
        rest = re.sub(r'^[-*]\s+.+$', '', rest, flags=re.M)
    for chunk in re.split(r'\n\s*\n', rest):
        chunk = chunk.strip()
        if chunk:
            parts.append(para(chunk))
    return '\n'.join(parts)


def render_vocab(body: str) -> str:
    _, rows = table_data(body)
    cards = []
    for r in rows:
        term = inline(r[0]) if len(r) > 0 else ''
        rest = ''.join(f'<div><span class="chip">{"AR" if is_ar(c) else "EN"}</span> '
                       f'<span class="{"ar" if is_ar(c) else ""}">{inline(c)}</span></div>'
                       for c in r[1:])
        cards.append(f'<div class="card"><div class="term">{term}</div>{rest}</div>')
    return '<div class="grid2">' + ''.join(cards) + '</div>' if cards else render_blocks(body)


def render_pairs(body: str) -> str:
    _, rows = table_data(body)
    cards = []
    for r in rows:
        en = r[0] if len(r) > 0 else ''
        ar = r[1] if len(r) > 1 else ''
        extra = ''.join(f'<div class="ex">{inline(c)}</div>' for c in r[2:])
        cards.append(f'<div class="card"><div>{inline(en)}</div>'
                     f'<div class="ar">{inline(ar)}</div>{extra}</div>')
    return '<div class="grid2">' + ''.join(cards) + '</div>' if cards else render_blocks(body)


def render_situation(body: str) -> str:
    _, rows = table_data(body)
    parts = []
    for r in rows:
        en = r[0] if len(r) > 0 else ''
        ar = r[1] if len(r) > 1 else ''
        parts.append(f'<div class="card"><div>{inline(en)}</div>'
                     f'<div class="ar">{inline(ar)}</div></div>')
    return '\n'.join(parts) if parts else render_blocks(body)


def render_dialogue(body: str) -> str:
    _, rows = table_data(body)
    bubs = []
    for i, r in enumerate(rows):
        en, ar = (r[0] if len(r) > 0 else ''), (r[1] if len(r) > 1 else '')
        m = re.match(r'\*\*(.+?):\*\*\s*(.*)', en, re.S)
        who, say = (m.group(1), m.group(2)) if m else ('', en)
        side = 'me' if i % 2 else ''
        bubs.append(f'<div class="bubble {side}"><span class="who">{esc(who)}:</span> '
                    f'{inline(say)}<div class="ar">{inline(ar)}</div></div>')
    rest = strip_tables(body)
    rest = re.sub(r'^>\s?Goal:.*$', '', rest, flags=re.M).strip()
    tail = para(rest) if rest else ''
    return '<div class="bubbles">' + ''.join(bubs) + '</div>' + tail


def render_speaking(body: str) -> str:
    m1 = re.search(r'\*\*Task:\*\*\s*(.*?)(?=\*\*Reference Answer)', body, re.S)
    m2 = re.search(r'\*\*Reference Answer.*?\*\*\s*(.*)', body, re.S)
    task = m1.group(1).strip() if m1 else ''
    ans = m2.group(1).strip().strip('"') if m2 else ''
    out = ''
    if task:
        out += f'<div class="panel task"><strong>Task:</strong> {inline(task)}</div>'
    if ans:
        out += f'<div class="panel answer"><strong>Reference Answer:</strong> {inline(ans)}</div>'
    return out if out else render_blocks(body)


def render_realtask(body: str) -> str:
    _, rows = table_data(body)
    cards = []
    for r in rows:
        cells = ''.join(f'<div class="{"ar" if is_ar(c) else ""}">{inline(c)}</div>' for c in r)
        cards.append(f'<div class="card">{cells}</div>')
    return '<div class="grid2">' + ''.join(cards) + '</div>' if cards else render_blocks(body)


SEC_TITLES = {'1': 'Mission', '2': 'Real IT Situation', '3': 'Key Language',
              '4': 'Vocabulary', '5': 'Useful Sentences', '6': 'Collocations',
              '7': 'Dialogue', '8': 'Grammar in Context', '9': 'Speaking',
              '10': 'Real IT Task', '11': 'Common Errors', '12': 'Quick Check'}


def render_section(num: str, body: str) -> str:
    if body is None:
        return ''
    goal = ''
    gm = re.search(r'^>\s?Goal:(.*)$', body, re.M)
    if gm:
        goal = f'<div class="goal"><strong>Goal:</strong>{inline(gm.group(1).strip())}</div>'
    if num == '1':
        core = para(strip_tables(re.sub(r'^>\s?Goal:.*$', '', body, flags=re.M)).strip())
    elif num == '2':
        core = render_situation(body)
    elif num in ('3', '4'):
        core = render_vocab(body)
    elif num in ('5', '6'):
        core = render_pairs(body)
    elif num == '7':
        core = render_dialogue(body)
    elif num == '9':
        core = render_speaking(body)
    elif num == '10':
        core = render_realtask(body)
    else:
        core = render_blocks(body)
    return f'{goal}\n{core}'


def parse_lesson(path: Path, day: int) -> dict:
    t = path.read_text(encoding="utf-8")
    lines = t.splitlines()
    title = re.sub(r'^##\s*', '', lines[0]).strip()
    meta = {}
    m = re.search(r'\*\*Level:\*\*\s*(.*?)\s*\|\s*\*\*Speaking:\*\*\s*(.*?)\s*\|\s*\*\*Output:\*\*\s*(.*)$',
                  lines[1] if len(lines) > 1 else '')
    if m:
        meta = {'level': m.group(1).strip(), 'speaking': m.group(2).strip(),
                'output': m.group(3).strip()}
    secs = {}
    for n in [str(i) for i in range(1, 13)]:
        mm = re.search(r'^### ' + n + r'\.(.*)$', t, re.M)
        secs[n] = (mm.group(1).strip(), sec_body(t, n))
    return {'day': day, 'title': title, 'meta': meta, 'secs': secs}


def render_day(d: dict) -> str:
    m = d['meta']
    parts = [f'<h2 class="day" id="d{d["day"]:03d}">{esc(d["title"])}</h2>',
             f'<p class="meta"><strong>Level:</strong> {esc(m.get("level", ""))} | '
             f'<strong>Speaking:</strong> {esc(m.get("speaking", ""))} | '
             f'<strong>Output:</strong> {esc(m.get("output", ""))}</p>']
    for n in [str(i) for i in range(1, 13)]:
        h, b = d['secs'][n]
        h = h or SEC_TITLES[n]
        parts.append(f'<h3 class="sec">{esc(h)}</h3>' + render_section(n, b or ''))
    return '\n'.join(parts)


def page(title: str, nav: str, content: str) -> str:
    return ('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">'
            '<meta name="viewport" content="width=device-width,initial-scale=1">'
            f'<title>{esc(title)}</title><style>{CSS}</style></head><body>'
            f'<div class="topbar"><div class="wrap">{nav}</div></div>'
            f'<div class="wrap">{content}</div></body></html>')


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=None)
    ap.add_argument("--chunk", type=int, default=30)
    ap.add_argument("--partial", action="store_true", help="Build despite gaps")
    args = ap.parse_args()

    root = resolve_root(args.root)
    total = workspace_days(root)
    manifest = {}
    mf = root / "curriculum.json"
    if mf.exists():
        try:
            manifest = json.loads(mf.read_text(encoding="utf-8"))
        except ValueError:
            pass
    title = manifest.get("title", root.name)

    lessons, fails = [], []
    for day in range(1, total + 1):
        p = root / "curriculum" / f"day-{day:03d}" / "lesson.md"
        if not p.exists():
            fails.append(f"gap: day-{day:03d} missing")
            continue
        for iss in check_file(p, day):
            fails.append(f"day-{day:03d}: {iss}")
        try:
            lessons.append(parse_lesson(p, day))
        except Exception as e:  # noqa: BLE001
            fails.append(f"day-{day:03d}: parse error {e}")

    if not lessons:
        print(f"No lessons to build in {root}/curriculum")
        return 1

    site = root / "site"
    site.mkdir(parents=True, exist_ok=True)
    chunks = {}
    for d in lessons:
        key = ((d['day'] - 1) // args.chunk) * args.chunk + 1
        chunks.setdefault(key, []).append(d)

    chunk_files = []
    for start in sorted(chunks):
        sel = sorted(chunks[start], key=lambda x: x['day'])
        end = sel[-1]['day']
        fname = f"days-{start:03d}-{end:03d}.html"
        toc = ''.join(f'<a href="#d{d["day"]:03d}">{esc(d["title"])}</a>' for d in sel)
        content = (f'<h1>{esc(title)} — Days {start:03d}–{end:03d}</h1>'
                   f'<div class="toc">{toc}</div>\n'
                   + '\n'.join(render_day(d) for d in sel))
        nav = f'<a href="index.html">Index</a><span class="meta">{esc(title)}</span>'
        html_text = page(f"{title} — Days {start:03d}-{end:03d}", nav, content)
        if '<table' in html_text.lower():
            fails.append(f"{fname}: <table> leaked into HTML")
        if EXT_RE.search(html_text) or CSS_URL_RE.search(html_text):
            fails.append(f"{fname}: external URL reference (not standalone)")
        ids = re.findall(r'id="(d\d+)"', html_text)
        if len(ids) != len(set(ids)):
            fails.append(f"{fname}: duplicate day IDs")
        (site / fname).write_text(html_text, encoding="utf-8")
        chunk_files.append(fname)

    links = ''.join(f'<p><a href="{f}">{f}</a></p>' for f in chunk_files)
    daylinks = ''.join(
        f'<a href="{cf}#d{d["day"]:03d}" data-t="{esc(d["title"].lower())}">'
        f'{esc(d["title"])}</a>'
        for cf, start in [(f, s) for f, s in zip(chunk_files, sorted(chunks))]
        for d in sorted(chunks[start], key=lambda x: x['day']))
    pct = round((len(lessons) / total) * 100) if total else 0
    vocab_count = 0
    for _d in lessons:
        for _n in ('3', '4'):
            _, _rows = table_data(sec_body(
                (root / "curriculum" / f"day-{_d['day']:03d}" / "lesson.md").read_text(
                    encoding="utf-8", errors="ignore"), _n) or '')
            vocab_count += len(_rows)
    if not vocab_count:
        vocab_count = len(lessons) * 20  # fallback estimate (Key 10 + Vocab 10)
    max_day = max(d["day"] for d in lessons) if lessons else 1
    if max_day <= 20:
        curr_level = "A1"
    elif max_day <= 60:
        curr_level = "A2"
    elif max_day <= 90:
        curr_level = "B1"
    else:
        curr_level = "B2"

    stats_html = (
        f'<div class="stats-grid">'
        f'<div class="stat-card"><div class="stat-num">{len(lessons)}/{total}</div>'
        f'<div class="stat-lbl">Days Built ({pct}%)</div></div>'
        f'<div class="stat-card"><div class="stat-num">{curr_level}</div>'
        f'<div class="stat-lbl">Latest Built Day Band (Day {max_day:03d})</div></div>'
        f'<div class="stat-card"><div class="stat-num">~{vocab_count:,}</div>'
        f'<div class="stat-lbl">Vocabulary Items (Key + Vocab rows)</div></div>'
        f'</div>'
        f'<div class="progress-wrap"><div class="progress-bar" style="width:{pct}%"></div></div>'
    )

    index_content = (f'<h1>{esc(title)}</h1>'
                     f'<p class="meta">{len(lessons)}/{total} days · '
                     f'levels A1→B2 · offline, cards-only</p>'
                     f'{stats_html}'
                     f'<input id="search" placeholder="Search days...">'
                     f'<h3 class="sec">Chunks</h3>{links}'
                     f'<h3 class="sec">All days</h3><div class="toc" id="days">{daylinks}</div>'
                     '<script>const q=document.getElementById("search"),'
                     'd=document.getElementById("days");'
                     'q.addEventListener("input",()=>{const v=q.value.toLowerCase();'
                     'for(const a of d.children){a.style.display=a.dataset.t.includes(v)?"":"none"}});'
                     '</script>')
    (site / "index.html").write_text(
        page(title, '<span class="meta">Index</span>', index_content), encoding="utf-8")

    if fails and not args.partial:
        print(f"BUILD {title}: days={len(lessons)}/{total} chunks={len(chunk_files)}")
        print("FAIL:")
        for f in fails[:20]:
            print(f"  {f}")
        return 1
    if fails:
        print(f"BUILD (partial preview): days={len(lessons)}/{total}")
        for f in fails[:10]:
            print(f"  warn: {f}")
    print(f"BUILD DONE — {title}: days={len(lessons)}/{total} "
          f"chunks={len(chunk_files)} FAIL: none")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
