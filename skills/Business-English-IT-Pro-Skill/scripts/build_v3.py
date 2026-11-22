#!/usr/bin/env python3
"""V3 HTML builder r2 (v2.0): renders mastery | video | article tracks to the
shared V3 shell (single-file, Blogger-ready, offline).

Matches the published HTML design:
  mastery: html/Days-01-15.html ... (15-day chunks) + index.html
  video:   lessons/VideoNN/lesson.html (standalone) + lessons.html (aggregated)
  article: lessons/ArticleNN/lesson.html (standalone) + lessons.html (aggregated)

Shell (CSS + JS) is vendored in scripts/v3_style.css + scripts/v3_script.js
(byte-identical to the published files). Body uses the same components:
#iem-v3-root, .v2-hero, .v2-toolbar, .v2-grid/.v2-card, .v2-lesson,
.v2-lesson-head, details.v2-sec, .v2-sec-body, .v2-kard, .v2-table,
.v2-line[data-say], .v2-nav, #v2-top, V2.init(order, part).

Usage:
  python scripts/build_v3.py --root <workspace> --track mastery
  python scripts/build_v3.py --root <lessons-dir> --track video
  python scripts/build_v3.py --root <lessons-dir> --track article

Re-validates every lesson with validate_track before rendering.
Exit 0 only when FAIL list is empty.
"""
import html
import re
import sys
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(SKILL_DIR / "scripts"))
from validate_track import check_mastery, check_link, collect  # noqa: E402

AR_RE = re.compile(r"[\u0600-\u06FF]")
EXT_RE = re.compile(r"<(a|link|img|script|source|iframe)[^>]*(href|src)\s*=\s*[\"']https?://", re.I)
CSS_URL_RE = re.compile(r"@import|url\(\s*https?://", re.I)
URL_RE = re.compile(r"https?://[^\s<>\"')]+", re.I)
SRC_A_RE = re.compile(r'<a\s[^>]*class="v2-src"[^>]*>.*?</a>', re.I | re.S)
VIDEO_IFRAME_RE = re.compile(r'<iframe\s[^>]*class="v2-player"[^>]*>.*?</iframe>', re.I | re.S)


def youtube_id(url):
    """Extract a YouTube video id from watch / youtu.be / embed / shorts URLs."""
    for pat in (r"[?&]v=([\w-]{6,})", r"youtu\.be/([\w-]{6,})",
                r"/embed/([\w-]{6,})", r"/shorts/([\w-]{6,})"):
        m = re.search(pat, url or "")
        if m:
            return m.group(1)
    return ""


def render_video_source(t):
    """Video head block: embedded player + watch link.

    Parses the md `> Video: <Title> | <YouTube URL>` block. The player uses
    the privacy-enhanced `youtube-nocookie` embed (the video-track network
    exception; see `references/v3-html-spec.md`). Falls back to
    `render_source()` when no YouTube id is found.
    """
    m = re.search(r">\s*Video:\s*(.+)", t)
    if not m:
        return render_source(t)
    raw = m.group(1).strip()[:400]
    parts = raw.split("|")
    title = parts[0].strip() if len(parts) > 1 else raw
    um = URL_RE.search(parts[1] if len(parts) > 1 else raw)
    url = um.group(0).rstrip(".,;)") if um else ""
    vid = youtube_id(url)
    if not title:
        title = "Course video"
    if not vid:
        return render_source(t)
    embed = f"https://www.youtube-nocookie.com/embed/{vid}?rel=0"
    return (f'<div class="v2-video"><iframe class="v2-player" src="{embed}" '
            f'title="{esc(title)}" loading="lazy" '
            f'allow="accelerometer; encrypted-media; picture-in-picture; web-share" '
            f'allowfullscreen referrerpolicy="strict-origin-when-cross-origin"></iframe></div>'
            f'<div class="v2-callout v2-source"><span class="v2-source-lbl">Source:</span> '
            f'<span dir="ltr" lang="en">{esc(title)}</span> '
            f'<a class="v2-src" href="{esc(url)}" target="_blank" rel="noopener">Watch on YouTube &#8599;</a></div>')


def render_source(t):
    """Clickable source line for video/article lessons.

    Parses the md `> Video: <Title> | <URL>` / `> Article: <Title> | <URL>`
    block into a title plus a real link (the article-track network exception;
    video lessons use `render_video_source()` instead;
    see `references/v3-html-spec.md`). Falls back to escaped text when no
    URL is present.
    """
    m = re.search(r">\s*(?:Video|Article):\s*(.+)", t)
    if not m:
        return ""
    raw = m.group(1).strip()[:400]
    title = raw
    url = ""
    parts = raw.split("|")
    if len(parts) > 1:
        title = parts[0].strip()
        um = URL_RE.search(parts[1])
        url = um.group(0).rstrip(".,;)") if um else ""
    else:
        um = URL_RE.search(raw)
        if um:
            url = um.group(0).rstrip(".,;)")
            title = raw.replace(um.group(0), "").strip(" |-–—")
    if url and not re.match(r"https?://", url, re.I):
        url = ""
    if not title:
        title = "Original source"
    if url:
        return (f'<div class="v2-callout v2-source"><span class="v2-source-lbl">Source:</span> '
                f'<span dir="ltr" lang="en">{esc(title)}</span> '
                f'<a class="v2-src" href="{esc(url)}" target="_blank" rel="noopener">Read original &#8599;</a></div>')
    return (f'<div class="v2-callout v2-source"><span class="v2-source-lbl">Source:</span> '
            f'<span dir="ltr" lang="en">{esc(title)}</span></div>')


def _has_forbidden_external(html_text):
    """Offline gate: source links (`a.v2-src`) and video embeds
    (`iframe.v2-player`, youtube-nocookie) are the allowed exceptions."""
    scrubbed = SRC_A_RE.sub("", html_text)
    scrubbed = VIDEO_IFRAME_RE.sub("", scrubbed)
    return bool(EXT_RE.search(scrubbed) or CSS_URL_RE.search(scrubbed))


def esc(s: str) -> str:
    return html.escape(s, quote=True)


def is_ar(s: str) -> bool:
    return bool(AR_RE.search(s or ""))


def load_shell():
    css = (SKILL_DIR / "scripts" / "v3_style.css").read_text(encoding="utf-8")
    # strip the marker comment line we prepended (keep original markers inside)
    js = (SKILL_DIR / "scripts" / "v3_script.js").read_text(encoding="utf-8")
    return css, js


def say_btn(text, lang="en-US"):
    return (f'<button class="v2-iconbtn" data-say="{esc(text)}" data-lang="{lang}" '
            f'title="Listen" aria-label="Listen">🔊</button>')


def para_bidi(text):
    d = "rtl" if is_ar(text) else "ltr"
    return f'<p dir="{d}" lang="{"ar" if d == "rtl" else "en"}">{esc(text)}</p>'


def table_data(body):
    if body is None:
        return [], []
    rows = []
    for l in body.splitlines():
        s = l.strip()
        if s.startswith("|") and "---" not in s:
            rows.append([c.strip() for c in s.strip("|").split("|")])
    if not rows:
        return [], []
    return rows[0], rows[1:]


def sec_body(text, name_pat):
    m = re.search(r"^### " + name_pat + r"(?:\s*[(|:].*)?\s*$", text, re.M)
    if not m:
        return None
    sub = text[m.end():]
    n = re.search(r"\n### ", sub)
    return sub[:n.start()] if n else sub


def strip_tables(body):
    out = []
    for l in (body or "").splitlines():
        if l.strip().startswith("|"):
            continue
        out.append(l)
    return "\n".join(out).strip()


# ---------- section renderers (shared components) ----------

def render_vocab_cards(rows):
    cards = []
    for i, r in enumerate(rows, 1):
        term = r[0] if len(r) > 0 else ""
        ar = r[1] if len(r) > 1 else ""
        en = r[2] if len(r) > 2 else ""
        ex = r[3] if len(r) > 3 else ""
        cards.append(
            f'<div class="v2-kard"><div class="v2-kard-head"><span class="v2-kard-num">{i}</span>'
            f'<span class="v2-kard-word" dir="ltr" lang="en">{esc(term)}</span>'
            f'{say_btn(term)}</div>'
            f'<div class="v2-kard-ar" dir="rtl" lang="ar">{esc(ar)}</div>'
            f'<div class="v2-kard-mean" dir="ltr" lang="en">{esc(en)}</div>'
            f'<div class="v2-kard-ex" dir="ltr" lang="en">{esc(ex)} {say_btn(ex) if ex else ""}</div></div>')
    return '<div class="v2-cards">' + "".join(cards) + "</div>"


def render_phrase_cards(rows):
    cards = []
    for i, r in enumerate(rows, 1):
        ph = r[0] if len(r) > 0 else ""
        ar = r[1] if len(r) > 1 else ""
        ex = r[2] if len(r) > 2 else ""
        cards.append(
            f'<div class="v2-kard v2-collo"><div class="v2-kard-head"><span class="v2-kard-num">{i}</span>'
            f'<span class="v2-kard-word" dir="ltr" lang="en">{esc(ph)}</span>{say_btn(ph)}</div>'
            f'<div class="v2-kard-ar" dir="rtl" lang="ar">{esc(ar)}</div>'
            f'<div class="v2-collo-ex" dir="ltr" lang="en">{para_bidi(ex)} {say_btn(ex) if ex else ""}</div></div>')
    return '<div class="v2-cards">' + "".join(cards) + "</div>"


def render_sent_lines(rows):
    lines = []
    for i, r in enumerate(rows, 1):
        en = r[0] if len(r) > 0 else ""
        ar = r[1] if len(r) > 1 else ""
        lines.append(
            f'<div class="v2-line"><span class="v2-num">{i}</span>'
            f'<div class="v2-line-body"><p dir="ltr" lang="en">{esc(en)}</p>'
            f'<p dir="rtl" lang="ar">{esc(ar)}</p></div>'
            f'<div class="v2-line-btns">{say_btn(en)}</div></div>')
    return '<div class="v2-sents">' + "".join(lines) + "</div>"


def render_prose(body):
    text = strip_tables(body)
    text = re.sub(r"^>\s?Goal:.*$", "", text, flags=re.M).strip()
    # keep bold sub-headers (**...**) as headings
    parts = []
    for chunk in re.split(r"\n\s*\n", text):
        chunk = chunk.strip()
        if not chunk:
            continue
        if chunk.startswith("**") and chunk.endswith("**") or re.match(r"^\*\*.+\*\*$", chunk.splitlines()[0].strip()):
            parts.append(f"<h4>{esc(chunk.strip('* '))}</h4>")
            rest = "\n".join(chunk.splitlines()[1:])
            if rest.strip():
                parts.append(para_bidi(rest.strip()) + f" {say_btn(rest.strip()[:120])}")
        elif chunk.startswith("- "):
            items = "".join(f"<li>{esc(x.strip('- ').strip())}</li>" for x in chunk.splitlines() if x.strip().startswith("-"))
            parts.append(f"<ul>{items}</ul>")
        else:
            parts.append(para_bidi(chunk) + f" {say_btn(chunk[:160])}")
    return "\n".join(parts)


def render_numbered(body):
    items = re.findall(r"^\d+\.\s+(.+)$", body or "", re.M)
    out = []
    for i, it in enumerate(items, 1):
        out.append(
            f'<div class="v2-line"><span class="v2-num">{i}</span>'
            f'<div class="v2-line-body"><p dir="auto">{esc(it)}</p></div>'
            f'<div class="v2-line-btns">{say_btn(it[:160])}</div></div>')
    return "".join(out)


def render_recall(body):
    # "1. Q\n> Answer: A" pairs
    chunks = re.split(r"(?m)^(\d+)\.\s+", body or "")
    out = []
    i = 0
    for k in range(1, len(chunks), 2):
        i += 1
        q = chunks[k + 1].splitlines()[0].strip() if k + 1 < len(chunks) else ""
        rest = chunks[k + 1] if k + 1 < len(chunks) else ""
        am = re.search(r">\s?Answer:\s*(.+)", rest)
        a = am.group(1).strip() if am else ""
        out.append(
            f'<div class="v2-pair"><p dir="ltr" lang="en"><strong>{i}.</strong> {esc(q)} {say_btn(q)}</p>'
            f'<p class="v2-gloss" dir="auto">Answer: {esc(a)}</p></div>')
    return "".join(out)


SECS_MASTERY = [
    ("Mission", "📌", "Read your goal for today."),
    ("Real IT Situation", "📌", "Meet the work situation."),
    ("Key Language", "📌", "Learn the key words."),
    ("Vocabulary", "📌", "Learn more words on the topic."),
    ("Useful Sentences", "💬", "Practice ready work sentences."),
    ("Collocations", "🔗", "Learn natural fixed phrases."),
    ("Common Errors", "⚠️", "Avoid these mistakes."),
    ("Workplace English", "🎤", "Read and reuse workplace English."),
]

SECS_VIDEO_BASE = [
    ("Video Context", "📌", "Meet the source: what it is about and why it matters."),
    ("Key Words from the Video", "📌", "Learn every important word you will hear."),
    ("Important Phrases from the Video", "💬", "Learn the key phrases you will hear."),
    ("Important Sentences from the Video", "💬", "Read what the speaker actually says."),
    ("Collocations", "🔗", "Learn 10 fixed phrases that sound natural."),
    ("Vocabulary Expansion", "📌", "Learn extra words you need for the topic."),
    ("Listening Notes", "💬", "Catch the hard parts when listening."),
    ("Common English Patterns", "💬", "Reuse the speaker's patterns."),
    ("Workplace English", "🎤", ""),
    ("Speaking Practice", "🎤", "Say it back in your own words."),
    ("Final Recall", "🎯", "Check what you remember."),
]

SECS_ARTICLE_BASE = [(n.replace("Video", "Article"), i, s) for (n, i, s) in SECS_VIDEO_BASE]
SECS_ARTICLE_BASE[0] = ("Article Context", "📌", "Meet the article: what it is about and why it matters.")
SECS_ARTICLE_BASE[1] = ("Key Words from the Article", "📌", "Learn every important word you will read.")
SECS_ARTICLE_BASE[2] = ("Important Phrases from the Article", "💬", "Learn the key phrases you will read.")
SECS_ARTICLE_BASE[3] = ("Important Sentences from the Article", "💬", "Read what the author actually says.")


def render_mastery_section(name, body):
    if body is None:
        return ""
    if name in ("Key Language", "Vocabulary"):
        _, rows = table_data(body)
        return render_vocab_cards(rows)
    if name in ("Useful Sentences",):
        _, rows = table_data(body)
        return render_sent_lines(rows)
    if name in ("Collocations",):
        _, rows = table_data(body)
        return render_phrase_cards(rows)
    if name in ("Real IT Situation",):
        _, rows = table_data(body)
        if rows:
            en, ar = rows[0][0], rows[0][1] if len(rows[0]) > 1 else ""
            return (f'<div class="v2-situ"><div class="v2-situ-block">'
                    f'<span class="v2-situ-lbl">Situation</span><p dir="ltr">{esc(en)}</p>'
                    f'<p dir="rtl" lang="ar">{esc(ar)}</p>{say_btn(en)}</div></div>')
        return render_prose(body)
    if name in ("Common Errors",):
        return render_numbered(body)
    return render_prose(body)


def render_link_section(name, body):
    if body is None:
        return ""
    if body is None:
        return ""
    # tables -> cards; numbered -> recall/lines; prose otherwise
    if name.startswith("Key Words"):
        # keep Must/Useful sub-headers
        parts = re.split(r"(\*\*Must know.*?\*\*|\*\*Useful.*?\*\*)", body)
        out = []
        for part in parts:
            _, rows = table_data(part)
            if rows:
                out.append(render_vocab_cards(rows))
            else:
                txt = strip_tables(part).strip()
                if txt:
                    # hear-only line / goal
                    if txt.startswith(">"):
                        continue
                    if re.match(r"^\*\*.+\*\*$", txt):
                        out.append(f"<h4>{esc(txt.strip('* '))}</h4>")
                    else:
                        out.append(para_bidi(txt[:500]))
        # hear-only line (plain text with *...*)
        m = re.search(r"You will also hear.*", body)
        if m:
            out.append(f'<div class="v2-callout">{esc(m.group(0).replace("*", ""))}</div>')
        return "\n".join(out)
    if name.startswith("Important Phrases") or name.startswith("Collocations") or name.startswith("Common English Patterns"):
        _, rows = table_data(body)
        if rows:
            return render_phrase_cards(rows)
        return render_prose(body)
    if name.startswith("Important Sentences"):
        # sub-sections with **headers** each followed by a table
        chunks = re.split(r"(\*\*.+?\*\*)", body)
        out = []
        for j in range(1, len(chunks), 2):
            head = chunks[j].strip("* ").strip()
            tab = chunks[j + 1] if j + 1 < len(chunks) else ""
            _, rows = table_data(tab)
            if rows:
                out.append(f"<h4>{esc(head)}</h4>" + render_sent_lines(rows))
        return "\n".join(out) if out else render_prose(body)
    if name.startswith("Vocabulary Expansion"):
        _, rows = table_data(body)
        return render_vocab_cards(rows) if rows else render_prose(body)
    if name.startswith("Listening Notes"):
        chunks = re.split(r"(\*\*.+?\*\*)", body)
        out = []
        for j in range(1, len(chunks), 2):
            head = chunks[j].strip("* ").strip()
            tab = chunks[j + 1] if j + 1 < len(chunks) else ""
            _, rows = table_data(tab)
            if rows:
                out.append(f"<h4>{esc(head)}</h4>" + render_phrase_cards(rows))
        if out:
            return "\n".join(out)
        _, rows = table_data(body)
        return render_phrase_cards(rows) if rows else render_prose(body)
    if name.startswith("Speaking Practice"):
        task = re.search(r"\*\*Task:\*\*\s*(.+)", body)
        ans = re.search(r"\*\*Model Answer:\*\*\s*(.+)", body, re.S)
        out = ""
        if task:
            out += f'<div class="v2-exp"><strong>Task:</strong> {esc(task.group(1).strip())}</div>'
        if ans:
            a = ans.group(1).strip().strip("\"")
            out += f'<div class="v2-teams"><p dir="ltr">{esc(a)}</p>{say_btn(a[:160])}</div>'
            out += f'<label class="v2-draft-label">Your turn (speak, then type your version):</label><textarea class="v2-draft" data-draft="spk"></textarea>'
        return out
    if name.startswith("Final Recall"):
        return render_recall(body)
    return render_prose(body)


def sec_block(idx, icon, title, sub, inner_html, open_first=False):
    return (
        f'<details class="v2-sec"{ " open" if open_first else ""}>'
        f"<summary><span class=\"v2-ico\">{icon}</span>"
        f'<span class="v2-sec-titles"><span>{esc(title)}</span>'
        f'<span class="v2-sec-sub">{esc(sub)}</span></span></summary>'
        f'<div class="v2-sec-body">{inner_html}</div></details>')


def parse_meta(lines):
    for cand in (lines[0] if lines else "", lines[1] if len(lines) > 1 else ""):
        m = re.search(r"\*\*Level:\*\*\s*(.*?)\s*\|\s*\*\*Speaking:\*\*\s*(.*?)\s*\|\s*\*\*Output:\*\*\s*(.*)$", cand)
        if m:
            return m.group(1).strip(), m.group(2).strip(), m.group(3).strip()
    return "", "", ""


def lesson_uid_mastery(day):
    return f"v3d{day:03d}"


def lesson_uid_link(n):
    return f"v3d{900 + n}"


def render_mastery_lesson(path, day):
    t = path.read_text(encoding="utf-8")
    lines = t.splitlines()
    title = re.sub(r"^##\s*", "", lines[0]).strip()
    level, speaking, output = parse_meta(lines)
    uid = lesson_uid_mastery(day)
    secs_html = []
    for i, (name, icon, sub) in enumerate(SECS_MASTERY):
        body = sec_body(t, re.escape(name))
        inner = render_mastery_section(name, body)
        secs_html.append(sec_block(i, icon, name, sub, inner, open_first=(i == 0)))
    head = (
        f'<div class="v2-lesson-head"><div class="v2-meta"><span class="v2-badge">{esc(level)}</span>'
        f"<span>Day {day:03d}</span><span>⏱️ {esc(speaking)}</span></div>"
        f'<div class="v2-head-titles"><h2 dir="ltr" lang="en">{esc(title)}</h2></div>'
        f'<div class="v2-brief-box"><div class="v2-brief-row"><span class="v2-brief-lbl">Goal</span>'
        f'<span class="v2-brief-val" dir="ltr">{esc(output)}</span></div></div>'
        f'<label class="v2-complete"><input type="checkbox" id="done-{uid}" data-done="{uid}"> Mark complete</label></div>')
    nav = f'<div class="v2-nav"><button class="v2-btn" data-home="1">All lessons</button></div>'
    return uid, title, level, output, f'<article class="v2-lesson" id="lesson-{uid}">{head}{"".join(secs_html)}{nav}</article>'


def render_link_lesson(path, n, kind):
    t = path.read_text(encoding="utf-8")
    lines = t.splitlines()
    title = re.sub(r"^##\s*", "", lines[0]).strip()
    # strip combined meta from title for display
    title_disp = re.sub(r"\s*\|\s*\*\*Level:\*\*.*$", "", title).strip()
    level, speaking, output = parse_meta(lines)
    lid = re.match(r"^## Lesson:\s*(Video\d+|Article\d+)", lines[0]).group(1) if re.match(r"^## Lesson:\s*(Video\d+|Article\d+)", lines[0]) else f"{kind}{n:02d}"
    uid = lesson_uid_link(n)
    specs = SECS_VIDEO_BASE if kind == "video" else SECS_ARTICLE_BASE
    secs_html = []
    for i, (name, icon, sub) in enumerate(specs):
        # normalize: match base name (strip parenthetical variants not present here)
        body = sec_body(t, re.escape(name))
        inner = render_link_section(name, body)
        secs_html.append(sec_block(i, icon, name, sub or name, inner, open_first=(i == 0)))
    # sources head: video -> embedded player + watch link; article -> source link
    src_html = render_video_source(t) if kind == "video" else render_source(t)
    head = (
        f'<div class="v2-lesson-head"><div class="v2-meta"><span class="v2-badge">{esc(level)}</span>'
        f"<span>{esc(lid)}</span><span>⏱️ {esc(speaking)}</span></div>"
        f'<div class="v2-head-titles"><h2 dir="ltr" lang="en">{esc(title_disp)}</h2></div>'
        f'<div class="v2-brief-box"><div class="v2-brief-row"><span class="v2-brief-lbl">Goal</span>'
        f'<span class="v2-brief-val" dir="ltr">{esc(output)}</span></div></div>{src_html}'
        f'<label class="v2-complete"><input type="checkbox" id="done-{uid}" data-done="{uid}"> Mark complete</label></div>')
    nav = '<div class="v2-nav"><button class="v2-btn" data-home="1">All lessons</button></div>'
    return uid, title_disp, level, output, lid, f'<article class="v2-lesson" id="lesson-{uid}">{head}{"".join(secs_html)}{nav}</article>'


def page_shell(comment, title, hero_h1, hero_part, stats, sibling, home_grid, lessons_html, css, js, order, part):
    return (
        f"<!-- {esc(comment)} -->\n<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\">"
        f'<meta name="viewport" content="width=device-width,initial-scale=1">'
        f"<title>{esc(title)}</title><span><!--more--></span>"
        f"<style>{css}</style></head><body>\n"
        f'<div id="iem-v3-root">\n'
        f'<header class="v2-hero"><span class="v2-hero-badge">Business English - IT Track | 6 Months Max</span>'
        f"<h1>{esc(hero_h1)}</h1>"
        f'<p class="v2-hero-part" dir="ltr" lang="en">{esc(hero_part)}</p>'
        f'<p class="v2-hero-sub" dir="rtl" lang="ar">تعلم إنجليزية الأعمال لتقنية المعلومات: درس قصير كل يوم</p>'
        f'<div class="v2-stats">{"".join(f"<span class=\"v2-stat\">{esc(s)}</span>" for s in stats)}</div>'
        f'<div class="v2-sibling"><span class="v2-stat">{esc(sibling)}</span></div></header>\n'
        f'<div class="v2-toolbar" id="v2-toolbar"><div class="v2-wrap"><div class="v2-tool-top">'
        f'<div class="v2-search-wrap"><span class="v2-search-ico">🔍</span>'
        f'<input id="v2-q" class="v2-search" type="search" dir="auto" placeholder="Search lessons, vocabulary, scenarios..." aria-label="Search lessons"></div>'
        f'<div class="v2-tool-actions"><span class="v2-counter-pill" id="v2-count" aria-live="polite"></span>'
        f'<button class="v2-chipbtn v2-theme-btn" id="v2-theme" title="Dark / light mode">Theme</button></div></div>'
        f'<div class="v2-progress-row"><div class="v2-progress" role="progressbar" aria-label="Course progress"><i id="v2-bar"></i></div>'
        f'<div class="v2-progtext" id="v2-progtext"></div></div></div></div>\n'
        f'<div class="v2-wrap"><main id="v2-home"><div class="v2-grid" id="v2-grid">{home_grid}</div></main>'
        f"{lessons_html}"
        f'<div class="v2-foot">Offline V3 course · generated by business-english-for-tech v2.0</div></div>'
        f'<button id="v2-top" title="Top" aria-label="Top"></button></div>\n'
        f"<script>{js}</script>\n"
        f"<script>V2.init({order},\"{part}\")</script>\n</body></html>")


def card(uid, badge, pill, scen, h3, goal):
    return (
        f'<button class="v2-card" data-uid="{uid}" data-open="{uid}" data-level="{esc(badge)}" data-scen="{esc(scen)}" '
        f'data-search="{esc((h3 + " " + goal).lower())}"><div class="v2-card-top"><div class="v2-meta">'
        f'<span class="v2-badge">{esc(badge)}</span><span class="v2-day-pill">{esc(pill)}</span>'
        f'<span class="v2-scen-pill">📖 {esc(scen)}</span></div><span class="v2-card-arrow"></span></div>'
        f'<div class="v2-card-body"><h3 dir="ltr" lang="en">{esc(h3)}</h3>'
        f'<p class="v2-card-goal" dir="ltr" lang="en">{esc(goal)}</p></div>'
        f'<div class="v2-card-foot"><span class="v2-card-cta">Start Lesson</span>'
        f'<span class="v2-done-tag" style="display:none">Done</span></div></button>')


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=None)
    ap.add_argument("--track", required=True, choices=["mastery", "video", "article"])
    ap.add_argument("--chunk", type=int, default=15)
    args = ap.parse_args()
    root = Path(args.root) if args.root else Path.cwd()
    css, js = load_shell()
    fails = []
    if args.track == "mastery":
        files = collect(root, "mastery")
        if not files:
            print(f"No mastery lessons under {root}")
            return 1
        for day, p in files:
            for iss in check_mastery(p):
                fails.append(f"{p.name}: {iss}")
        lessons = []
        for day, p in sorted(files):
            try:
                lessons.append(render_mastery_lesson(p, day))
            except Exception as e:
                fails.append(f"day-{day:03d}: parse error {e}")
        # chunk output: mastery uses html/ (legacy) or site/
        outdir = root / ("html" if (root / "html").exists() or (root / "md").exists() else "site")
        if (root / "md").exists():
            outdir = root / "html"
        else:
            outdir = root / "site"
        outdir.mkdir(parents=True, exist_ok=True)
        chunks = {}
        for uid, title, level, output, art in lessons:
            day = int(uid[3:])
            key = ((day - 1) // args.chunk) * args.chunk + 1
            chunks.setdefault(key, []).append((uid, title, level, output, art))
        chunk_files = []
        for start in sorted(chunks):
            sel = sorted(chunks[start])
            end = int(sel[-1][0][3:])
            fname = f"Days-{start:02d}-{end:02d}.html"
            grid = "".join(card(uid, lvl, f"Day {int(uid[3:]):03d}", "Lesson", ti, go) for uid, ti, lvl, go, _ in sel)
            arts = "".join(a for _, _, _, _, a in sel)
            order = "[" + ", ".join(f'"{u}"' for u, _, _, _, _ in sel) + "]"
            html_text = page_shell(
                f"Business English for Tech: Days {start:02d}-{end:02d}",
                f"Business English for Tech: Days {start:02d}-{end:02d}",
                f"Business English for Tech: Days {start:02d}-{end:02d} (Month {(start // 30) + 1} of 6)",
                f"Month {(start // 30) + 1} of 6: Days {start:02d}-{end:02d}",
                [f"📚 {len(sel)} Daily Lessons", f"🎯 CEFR Level: {sel[0][2]}", "⏱️ 6 Months Max"],
                f"Next: {fname}", grid, arts, css, js, order, f"days-{start:03d}")
            if _has_forbidden_external(html_text):
                fails.append(f"{fname}: external URL reference")
            (outdir / fname).write_text(html_text, encoding="utf-8")
            chunk_files.append(fname)
        idx_grid = "".join(
            card(uid, lvl, f"Day {int(uid[3:]):03d}", "Lesson", ti, go)
            for key in sorted(chunks) for uid, ti, lvl, go, _ in sorted(chunks[key]))
        idx = page_shell("Business English for Tech index",
                         "Business English for Tech",
                         "Business English for Tech", "Link Course",
                         [f"📚 {len(lessons)} Daily Lessons", "🎯 CEFR Level: A1–B2", "⏱️ 6 Months Max"],
                         "Course complete: review all lessons", idx_grid, "", css, js,
                         "[" + ", ".join(f'"v3d{int(u[3:]):03d}"' for u, _, _, _, _ in lessons) + "]", "index")
        (outdir / "index.html").write_text(idx, encoding="utf-8")
        print(f"BUILD DONE — mastery: lessons={len(lessons)} chunks={len(chunk_files)} FAIL: {fails[:5] if fails else 'none'}")
        return 0 if not fails else 1
    # video / article
    kind = args.track
    files = collect(root, kind)
    if not files:
        print(f"No {kind} lessons under {root}")
        return 1
    for n, p in files:
        for iss in check_link(p, kind):
            fails.append(f"{p.parent.name}: {iss}")
    rendered = []
    for n, p in sorted(files):
        try:
            rendered.append(render_link_lesson(p, n, kind))
        except Exception as e:
            fails.append(f"{p.parent.name}: parse error {e}")
    tag = "Video" if kind == "video" else "Article"
    # standalone per-lesson files
    for uid, title, level, output, lid, art in rendered:
        lesson_dir = next(p.parent for n, p in files if lesson_uid_link(n) == uid)
        grid = card(uid, level, "Lesson", "Lesson", f"{lid}: {title.split(':', 1)[-1].strip()}", output)
        order = f'["{uid}"]'
        course = "YouTube Lessons" if kind == "video" else "Business English for Tech"
        html_text = page_shell(
            f"{course}: {lid}: {title.split(':', 1)[-1].strip()}" if ":" in title else f"{course}: {title}",
            f"{course}: {lid}", f"{course}: {lid}: {title.split(':', 1)[-1].strip()}" if ":" in title else title,
            f"Link Lesson · {lid}", ["📚 1 Daily Lessons", f"🎯 CEFR Level: {level}", "⏱️ 6 Months Max"],
            "Single link lesson", grid, art, css, js, order, lid.lower())
        (lesson_dir / "lesson.html").write_text(html_text, encoding="utf-8")
    # aggregated lessons.html
    grid_all = "".join(card(uid, lvl, "Lesson", "Lesson", f"{lid}: {ti.split(':', 1)[-1].strip()}" if ":" in ti else ti, go)
                       for uid, ti, lvl, go, lid, _ in rendered)
    arts_all = "".join(a for _, _, _, _, _, a in rendered)
    order_all = "[" + ", ".join(f'"{u}"' for u, _, _, _, _, _ in rendered) + "]"
    course_all = "YouTube Lessons: Link Lessons" if kind == "video" else "Business English for Tech: Link Lessons"
    agg = page_shell(f"{course_all} ({len(rendered)} lessons)", f"{course_all} ({len(rendered)} lessons)",
                     f"{course_all} ({len(rendered)} lessons)", f"Link Course · {len(rendered)} lessons",
                     [f"📚 {len(rendered)} Daily Lessons", "🎯 CEFR Level: A1–B2", "⏱️ 6 Months Max"],
                     "Course complete: review all lessons", grid_all, arts_all, css, js, order_all, "link-lessons-course")
    agg_path = root / "lessons.html" if (root / "lessons.html").exists() or root.name == "lessons" else root / "lessons.html"
    # if root is the lessons/ dir itself, write there; else write root/lessons.html
    agg_path.write_text(agg, encoding="utf-8")
    if _has_forbidden_external(agg):
        fails.append("lessons.html: external URL reference")
    print(f"BUILD DONE — {kind}: lessons={len(rendered)} FAIL: {fails[:5] if fails else 'none'}")
    return 0 if not fails else 1


if __name__ == "__main__":
    raise SystemExit(main())
