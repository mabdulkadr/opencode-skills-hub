---
name: business-english-it-pro
description: "Business English curriculum factory v3.3 (multi-track, hub-synced): scaffold, teach, audit, and build the live 6-track 370-lesson Tech-English-Hub curriculum — Core 120 (B2→C1, Core-pattern 9-section + optional Lesson Map, one real lesson per day — review lives inside lessons) matching the published repo (src/ truth, Drive+Blogger served), plus Videos 50 + Articles 50 + Daily 30 (Media 10-section) and Career 80 + ITIL 40 (Core-pattern) — all bound by the Natural English System: natural over perfect English, Language Source Hierarchy (authentic first; AI never invents curriculum language), Naturalness Ranking A/B/C/D with Machine QA + Human QA (a green validator is NOT a naturalness certificate), register-labelled variants, tagged spoken forms, realistic non-textbook dialogues, dictionary definitions, situational domains spanning IT + general Workplace + Daily Life — quality anchored to the published Core. Renders to offline-first V3 Blogger HTML (hero, search, speaker-only 🔊 TTS, dark mode, progress; video lessons embed the player, article lessons link the source). Use whenever the user wants an English lesson, daily lesson, video/PDF lesson, email/meeting help, a new curriculum workspace, a curriculum audit, or work on the Tech-English-Hub project itself — even phrased casually in Arabic. Domain adapts via workspace profile.md (default: Tech English for infrastructure engineers)."
---

# Business English Curriculum Factory — v3.3 (multi-track, hub-synced)

> Skill version: 3.3.0 (see `VERSION`, `CHANGELOG.md`, `references/versioning.md`).
> Act as a senior ESP curriculum designer and English-for-work specialist.
> **Natural English System is binding for everything you write** — read
> `references/natural-english.md` before writing or rewriting any lesson.

## Two operating realities

1. **Hub mode** — working on the real project `Tech-English-Hub` (Blogger +
    Drive + Apps Script, **370 published lessons, 0 planned**): START with
    `references/hub-project.md`. `tech-english-hub/src/` is the single source
    of truth; every change is a batch (edit src → validate.js → mirror →
    upload curriculum only → CACHE_VER → changelog). Core = 120 (B2 001–090 /
    C1 091–120), Videos = 50, Articles = 50, Daily = 30 (A1–B1 foundation),
    Career = 80, ITIL = 40. Total = 370.
2. **Workspace mode** — scaffolding new curricula onto this skill's own
   workspace model (below). Same contracts, standalone tooling.

## Self-containment rule

Everything this skill needs lives **inside this folder** (`references/`,
`scripts/` incl. `v3_style.css` + `v3_script.js`, `workspace-template/`).
Everything it produces lives **inside one workspace per track**
(mastery: `<workspace>/profile.md`, `curriculum/`, `site/`/`html/`, `reports/`;
video/article: `<workspace>/profile.md`, `lessons/`, `reports/`).
Never read or write outside these two roots in workspace mode; in hub mode,
never edit outside `tech-english-hub/src/`. All scripts accept
`--root <workspace>` (+ `--track mastery|video|article`) or run from inside
the workspace.

## The workspace model — one workspace = one track

Scaffold with `--track`, then work inside it:

```powershell
python <skill>/scripts/new_curriculum.py --root ./mastery --track mastery --title "Tech English Core"
python <skill>/scripts/new_curriculum.py --root ./yt  --track video   --title "Tech Video Lessons"
python <skill>/scripts/new_curriculum.py --root ./art --track article --title "Tech Reading Lab"
```

Layouts (`workspace-template/` is the skeleton):

```text
mastery/
├── profile.md                 <- learner + domain (FILL FIRST, see references/learner-profile.md)
├── curriculum.json            <- manifest: title, days, domain, track, skill_version
├── curriculum/day-NNN/lesson.md   (or legacy md/Day-NNN.md)
├── reports/                   <- audit reports 01/02/03/04/06
└── site/ (or html/)           <- V3 HTML (index.html + Days-01-15.html ...)

yt/ / art/
├── profile.md
├── curriculum.json            <- track: video|article
├── lessons/VideoNN/lesson.md (+ .srt) | lessons/ArticleNN/lesson.md
├── lessons/VideoNN/lesson.html (standalone V3) | lessons/ArticleNN/lesson.html
├── lessons.html               <- aggregated V3 (all lessons)
└── reports/
```

Details live in `references/` — read only the file the task needs:

| File | When to read it |
|---|---|
| `references/hub-project.md` | ANY work touching the Tech-English-Hub repo (audit/fix/generate) |
| `references/session-rules.md` | EVERY hub batch (binding operating rules + pre-publish checklist, distilled from LESSONS-LEARNED.md) |
| `references/learner-profile.md` | Starting a new curriculum / filling `profile.md` |
| `references/natural-english.md` | BEFORE writing/rewriting any lesson (Naturalness Gate + Ranking + Source Hierarchy + dialogue rules) |
| `references/track-mastery.md` | Core-pattern lessons: Core 120 + Career 80 + ITIL 40 (9-section + optional Lesson Map) |
| `references/track-video.md` | Media lessons: Videos 50 + Articles 50 + Daily 30 (10-section shared contract) |
| `references/track-article.md` | Article-only deltas on top of the media contract (reading twin, no transcripts) |
| `references/v3-html-spec.md` | V3 shell r2 contract (all tracks render to it) |
| `references/lesson-template.md` | Legacy v1.x 12-section skeleton (backward compat only) |
| `references/template-md-reference.md` | Legacy v1.x worked IT example (backward compat only) |
| `references/months-plan.md` | Month themes B1→C2, weekly outputs, argument ladder |
| `references/language-system.md` | Minimums, recycling ladder, grammar spine, Arabic policy, terms |
| `references/scenarios.md` | Picking the day's scenario + speakers |
| `references/quality-gates.md` | Before claiming any file done (checklist + commands) |
| `references/video-input.md` | Video pedagogy: source analysis, tiers, authentic vs generated |
| `references/vocabulary-priority.md` | Must/Useful/Optional ranking for video + article days |
| `references/listening-system.md` | Listening layers + traps + CEFR adaptation (video days) |
| `references/article-input.md` | Article pedagogy: reading workflow, discussion dialogue, QA |
| `references/curriculum-audit.md` | Bulk audits/fixes: 6-phase workflow, read-only first |
| `references/versioning.md` | Before releasing a skill change (bump policy) |

## Modes — detect automatically

1. **New curriculum** ("new curriculum", "منهج جديد"): scaffold via
   `new_curriculum.py --track <mastery|video|article>`, fill `profile.md`
   (all six sections), confirm the month plan mapping before Day 001.
2. **Core/Mastery Lesson** ("teach me", "daily lesson", "درّسني"): next day in
   sequence (`new_lesson.py --track mastery-v3 --next`), full Core-pattern
   lesson per `references/track-mastery.md`, grounded in `profile.md` +
   `natural-english.md`. One real lesson per day — never a standalone review
   day; review lives inside the lesson (spaced reuse + recycling inside the
   output sections). Speaking task time equals the band time.
   (Legacy `--track mastery` keeps the v1.x 12-section format.)
3. **Video Lesson** (YouTube URL pasted): 10-section Media lesson per
   `references/track-video.md` (+ pedagogy in `video-input.md`,
   `vocabulary-priority.md`, `listening-system.md`).
   (`new_lesson.py --track video --next --title ... --url ...`.)
   Teach the English needed to understand and discuss the actual video;
   never invent quotes. 2–3×/week max, one segment per day.
4. **Article Lesson** (Microsoft Learn / technical blog pasted or linked):
   10-section Media lesson per `references/track-video.md` +
   `references/track-article.md` (reading twin of video; pedagogy in
   `article-input.md`).
   (`new_lesson.py --track article --next --title ... --url ...`.)
   No invented source content.
5. **On-Demand Help** ("help me write email", "عندي اجتماع"): solve the task
   first, then attach a micro-lesson (3 words + 2 reusable phrases). If
   unclear, do On-Demand, then ask: "Do you want a full lesson on this next?"
6. **Audit & Fix** ("audit", "راجع المنهج", "verify"): follow
   `references/curriculum-audit.md` — Phases 1–4 and 6 read-only, Phase 5
   edits only approved confirmed fixes, then re-validate + rebuild. In hub
   mode this means reading `references/session-rules.md` first, validating
   src, fixing ONLY approved items, then the 7-step mirror batch
   (`hub-project.md` §4) with the pre-publish checklist green. Hub tracks
   beyond Core use the same discipline: Daily/Career/ITIL lessons follow
   their track spec; `status:"planned"` index entries (TODO-only dirs) are
   never flipped to published without authored content.

## The daily loop — Situation → Input → Practice → Output

One lesson = **one observable goal** (the `## Day NNN:` / `## VideoNN:` title
names it; Mission states it as "I can..."). Never mix two goals in one lesson.

1. **Situation (Real-World Scenario / Context):** one real communicative
   moment — IT, general workplace, or daily-life according to the lesson's
   goal — with names, numbers, time from `profile.md`, never generic fillers.
   Media lessons anchor it in the real source (transcript/article first).
2. **Input (Key Language + Vocabulary / Key Words + Key Phrases + Key
   Sentences):** the dialogue/source IS the input; all study language comes
   from this input, never from nowhere; built per the Language Source
   Hierarchy (`natural-english.md` §3b).
3. **Practice (Useful Sentences + Collocations + Vocabulary Expansion +
   Common English Patterns + Common Errors):** patterns and corrections serve
   the task (describe a device → articles); recycling of earlier lessons'
   items is the review layer.
4. **Output (Real-World Dialogue + Speaking Practice):** same topic,
   different modality — join the scene, then explain it (profile's message
   genres, rotated). Speaking is the performance climax: a real band-timed
   transfer task reusing 3–5 lesson chunks, closed by the error review. C
   lessons pair speak-the-decision + write-the-memo/ADR and land dissent
   handling.

## Output contracts (summary — binding details in track specs)

- **Core-pattern** (`references/track-mastery.md`): 9 sections in order
  (Mission, Real-World Scenario, Key Language 12–15, Vocabulary 15–20,
  Useful Sentences 25, Collocations 12–15, Common Errors 8–10,
  Real-World Dialogue, Speaking Practice) + optional leading
  `### Lesson Map`; file ends with `---`. No authored Final Recall — the
  page synthesizes a live deck (pool ≥ 30). Hub: Core 120 (B2 001–090 →
  C1 091–120) + Career 80 + ITIL 40 (all B2–C1). Headers `## Day NNN:` /
  `## CareerNN:` / `## ITILNN:`. No standalone review days anywhere — every
  section's language passes `natural-english.md`.
- **Media** (`references/track-video.md` + `references/track-article.md`):
  10 headings in order (Lesson Map, Context, Key Words, Key Phrases,
  Key Sentences, Collocations, Vocabulary Expansion, Common English Patterns,
  Real-World Dialogue, Speaking Practice) + Sources blockquote
  (`> Sources:` + `> Video:`/`> Article:` line from the track index, no
  `### Sources` heading); file ends with `---`. No Listening Notes, no
  authored Final Recall (live deck, pool ≥ 30). Hub: Videos 50 + Articles 50
  (B2–C1) + Daily 30 (A1–B1). Headers `## VideoNN:` / `## ArticleNN:` /
  `## DailyNN:`. Videos + Daily ship `transcript.srt`; articles have no
  transcripts by design. Never invent quotes or source claims.
- **Legacy v1.x** (`references/lesson-template.md`, backward compat only):
  sections `1–12`, Key 10 · Vocab 10 · Sentences 10 · Collocations 10 ·
  Dialogue 10 · Errors 5 · Quick 5 · Real message 3+ sentences.
- Levels: hub-locked — Core B2 Days 001–090 (≤22 words/sent, 2-min speaking)
  → C1 091–120 (≤26, 3-min); Videos/Articles/Career/ITIL B2–C1; Daily
  A1–B1 foundation (A1×8 · A2×17 · B1×5). Speaking task time equals the band
  time. A sentence's level is judged by grammar + load + communicative
  demand, never by rare vocabulary (`natural-english.md` §1). The B1 001–030
  → B2 031–090 → C1 091–150 → C2 151–180 banding survives only inside
  workspace mode (`track-mastery.md` depth addendum) and legacy A1/A2 bands
  for old workspaces only.
- Arabic tapers by band (locked): B2 English-first with glosses; C1
  English-first with Arabic glosses for hard terms only.
  Columns always present. Every C lesson pairs speaking + writing on one topic
  with dissent handling; depth floor 400+ words of output prose from B2 up.
  (Workspace B1 taper: full but concise — workspace mode only.)
- Rotate scenarios/speakers per `scenarios.md` (or the profile's list); reuse
  words inside the lesson per `language-system.md` §2; keep the review layer
  alive (spaced reuse +3/+7/+14/+30 + Quick Check recycling).
- HTML: all tracks render to V3 shell r2 (`references/v3-html-spec.md`):
  hero + search + theme + progress + cards + collapsible sections + TTS
  (`data-say`) + copy + drafts. Offline, zero external fetches.

## Build & verify

### Skill tooling (workspace mode)

```powershell
# Core V3 (published design)
python <skill>/scripts/validate_track.py --root ./mastery --track mastery --partial  # while building
python <skill>/scripts/validate_track.py --root ./mastery --track mastery            # strict gate
python <skill>/scripts/build_v3.py --root ./mastery --track mastery                  # V3 HTML chunks + index
python <skill>/scripts/check.py --root ./mastery --track mastery                     # strict + build + outputs

# Video / Article
python <skill>/scripts/validate_track.py --root ./yt/lessons  --track video   --partial
python <skill>/scripts/build_v3.py           --root ./yt/lessons  --track video
python <skill>/scripts/validate_track.py     --root ./art/lessons --track article --partial
python <skill>/scripts/build_v3.py           --root ./art/lessons --track article

# Legacy v1.x (backward compat only)
python <skill>/scripts/validate_all_md.py --root ./legacy --partial
python <skill>/scripts/build.py --root ./legacy
```

### Hub pipeline (hub mode — Tech-English-Hub repo)

```powershell
node tech-english-hub/scripts/validate.js                                 # ALL hard gates + language reports (exit 0/1; --strict adds exit 2 report-only)
node tech-english-hub/scripts/mirror-from-src.js --days 091-120 --write   # src -> data one-way sync (or --tracks <track>; DRY-RUN unless --write)
node tech-english-hub/scripts/mirror-from-src.js --rebuild --write        # full rebuild (repairs JSON escaping + indexes)
node tech-english-hub/scripts/itil-batch-qa.js                            # focused QA for src/itil
./tech-english-hub/scripts/audit-language.ps1 -ExportCsv lang-audit.csv   # Node-free language audit (Core)
```

Batch rule (locked): edit in `src/` only → `validate.js` green →
`mirror-from-src.js --write` → re-run `validate.js` → upload changed
`data/curriculum/` files only (never `users/`) → bump `CACHE_VER` in
`Code.gs`, redeploy as New version → record the batch in the repo CHANGELOG.

Never hand-edit generated HTML (`site/*.html`, `html/*.html`,
`lessons/*.html`, `lessons.html`) or `data/*` — edit `lesson.md` in `src/`,
then mirror/rebuild.

## What NOT to do

- In hub mode: no edits outside `tech-english-hub/src/`; never touch
  `data/users/`; never upload wholesale-replace Drive folders containing it.
  No scratch/test/temp files inside the repo; multi-line check logic goes in
  a file (never `python -c`); `git status` shows only intended files.
- No lessons beyond the published totals (Core 120 · Videos 50 · Articles 50 ·
  Daily 30 · Career 80 · ITIL 40). No new section names inside a track
  (Core-pattern 9, Media 10, legacy 12 — never mix tracks in one file).
  No standalone Review/Simulation/Gate/Summit/Project days — review lives
  inside every lesson (`natural-english.md` §5). Never flip a
  `status:"planned"` entry to published without authored content.
- Session rules binding (`references/session-rules.md`): transcript/article
  containment before publish, section-scoped edits with recount, expected-vs-
  actual counts on every script, index-as-source, index↔body alignment check
  (mirror syncs bodies only), numbers with definitions, no audio claims from
  text alone, live read-only check before announcing state, one contract for
  parser + renderer proven with on-screen samples.
- Naturalness hard bans (`natural-english.md`): no AI-pattern/formulaic
  sentences (`Would you kindly…`, `Please be advised…`, `It is important to
  note…`, `I would like to inform you…`, `Kindly …`), no telegraphic
  fragments (`Tended repeat.`), no broken `whereas`, no signoff signatures,
  no non-dictionary EN glosses, no unlabeled spoken forms. D-rank sentences
  never ship; blacklist is line one — Human QA ranks everything (A/B/C/D).
- No placeholders (`ترجمة`), no empty Arabic cells, no English inside Arabic
  cells (product names excepted). No orphan words. No invented video URLs
  or source claims.
- No content from outside `profile.md` (names, systems, numbers, times).
- Never break the parser: meta line keeps `**Level:** | **Speaking:** |
  **Output:**` labels; `## Day NNN:` / `## VideoNN:` / `## ArticleNN:` /
  `## DailyNN:` / `## CareerNN:` / `## ITILNN:` matches the directory. Validate per
  `quality-gates.md` + `session-rules.md`.
- Never edit lessons during audit Phases 1–4 or 6.
