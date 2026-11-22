# V3 HTML Shell r2 — Output Contract (Binding, v2.0)

All three tracks render to the **same V3 shell r2** (single-file, Blogger-ready,
offline). This matches the published HTML in:

- `curriculum/Tech English Core/html/Days-*.html + index.html` (15-day chunks)
- `curriculum/Tech Video Lessons/lessons/VideoNN/lesson.html` (standalone) + `lessons.html` (aggregated 12)
- `curriculum/Tech Reading Lab/lessons/ArticleNN/lesson.html` (standalone) + `lessons.html` (aggregated 11)

## Shell requirements (every HTML file)

- First line: `<!-- <Course>: <Range/Title> -->` comment.
- `<!DOCTYPE html><html lang="en">`, `<meta charset="utf-8">`, responsive viewport, `<title>`.
- `<span><!--more--></span>` after `<title>` (Blogger jump-break).
- One `<style>` block: `/* V3 shell r2: full redesign. Single-file, Blogger-ready. */` + CSS variables (`--bg`, `--card`, `--ink`, `--brand`, `--ok`, `--bad`, `--warn`), hero/toolbar/cards/sections/tables/chat/forms/nav/responsive/print rules. Dark mode via `[data-theme=dark]`. Print hides toolbar/nav.
- Body root: `<div id="iem-v3-root">` (isolates from `.post-body`).
- Hero: `.v2-hero` (badge `Business English - IT Track | 6 Months Max`, `h1` course title, `.v2-hero-part`, `.v2-hero-sub` Arabic tagline, `.v2-stats` pills, `.v2-sibling` next/prev note).
- Toolbar: `.v2-toolbar` (search `#v2-q`, counter `#v2-count`, theme button `#v2-theme`, progress `#v2-bar` + `#v2-progtext`).
- Cards grid: `.v2-grid` of `.v2-card` buttons (`data-uid`, `data-open`, `data-level`, `data-scen`, `data-search`) with badge/day-pill/scen-pill/goal/CTA/done-tag.
- Lessons: `.v2-lesson` blocks (`id="lesson-<uid>"`), each with `.v2-lesson-head` (meta, titles, brief, complete checkbox `data-done`), `.v2-sec` collapsible `<details>` sections (`<summary>` with `.v2-ico` + titles + sub), `.v2-sec-body` (tables `.v2-table`, lines `.v2-line` with speaker-only `data-say` TTS, chat `.v2-chat`, callouts, quizzes, drafts `data-draft`).
- TTS: every English sentence/term gets one speaker button `🔊` (`data-say="<text>"` + `data-lang` for Arabic). No copy buttons anywhere.
- Footer nav: `.v2-nav` prev/next/home (`data-home`, `data-open`), `.v2-foot`, `#v2-top` button.
- One `<script>`: V2 controller (`V2.init(order, part)`) — home/lesson routing (`#/day/<uid>`), filter, `markDone` (localStorage `done-<part>-<uid>`), progress, `speak` (speechSynthesis), quiz, draft persistence, theme persistence, hash routing, top button. Init call: `<script>V2.init([...uids...],"...")</script>`.
- Offline-first: no `http(s)` in `href/src/link/script`, no `@import`/`url(http`. System fonts (`Inter,Cairo,system-ui,...`). Two deliberate network exceptions, split by track:
  - **Article**: one clickable source link per lesson (`a.v2-src`, `target="_blank" rel="noopener"`, styled by `.v2-source`).
  - **Video**: one embedded player per lesson (`iframe.v2-player`, privacy-enhanced `youtube-nocookie` embed in a responsive 16:9 `.v2-video` wrapper) plus the watch link (`a.v2-src`).
  Both are explicitly allowlisted in the `build_v3.py` offline gate; everything else stays offline.
- Zero `<table>`? No — V3 **uses** `<table>` inside `.v2-table` wrappers (unlike v1.x cards-only builder). Tables are required for vocab/phrases/sentences.

## Per-track mapping

- **Core chunk** (`Days-01-15.html`): 15 lessons × 10 sections (Mission, Real IT Situation, Key Language, Vocabulary, Useful Sentences, Collocations, Common Errors, Workplace English, Speaking Practice, Final Recall). UIDs `v3d001...`. Hero `Month X of 6`. Sibling links prev/next chunk.
- **Video/Article standalone** (`VideoNN/lesson.html`): 1 lesson × 11 sections. UIDs `v3d900`. Hero `Link Lesson · <ID>: <Title>`. Sibling: back to `lessons.html`.
- **Video/Article aggregated** (`lessons.html`): N lessons × 11 sections. UIDs `v3d900...`. Hero `Link Course · N lessons`.

## Builder

`scripts/build_v3.py --root <workspace> --track <mastery|video|article>` implements this spec.
It re-validates every lesson with `scripts/validate_track.py` before rendering.
Never hand-edit `site/*.html` or `lessons/*.html` — edit `lesson.md`, then rebuild.
