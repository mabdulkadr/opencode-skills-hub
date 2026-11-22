# Quality Gates — Validate Every `.md` Before Done (v3.3 hub-truth)

> Hub contracts below match `validate.js` after Batches 110–112. The workspace
> `validate_track.py` is a pre-Batch-110 snapshot (old names, Listening Notes,
> authored Final Recall) — hub wins on conflict. Session-hardened rules live in
> `references/session-rules.md` and are part of this gate in hub mode.

## 1. Structural gate — pick the track, all must pass

- **Core-pattern: Core / Career / ITIL** (hub: `node scripts/validate.js`
  CORE_SECTIONS; workspace: `validate_track.py --track mastery`, spec
  `track-mastery.md`):
  hub files `src/core/dayNNN-<slug>/lesson.md` · `src/career/careerNN-<slug>/lesson.md` ·
  `src/itil/itilNN-<slug>/lesson.md` (workspace: `curriculum/day-NNN/lesson.md`
  or legacy `md/Day-NNN.md`); headers `## Day NNN:` / `## CareerNN:` /
  `## ITILNN:` match the directory.
  Meta line parses: `**Level:** X | **Speaking:** Y | **Output:** Z`.
  Optional leading `### Lesson Map` allowed (published lessons carry it).
  9 sections in order (Mission, Real-World Scenario, Key Language, Vocabulary,
  Useful Sentences, Collocations, Common Errors, Real-World Dialogue,
  Speaking Practice); NO authored Final Recall (the page synthesizes a live
  deck; hard gate: section absent + pool ≥ 30);
  file ends with `---`.
  Counts: Situation 1 · Key 12–15 · Vocab 15–20 · Sentences 25 ·
  Collocations 12–15 · Errors 8–10 · Dialogue prose present
  (depth floor: 400+ words from B2 up) · Speaking Task + quoted Model Answer present,
  task time = band time.
  No standalone Review/Simulation/Gate/Summit/Project lesson titles anywhere
  (`natural-english.md` §5) — review lives inside every lesson.
- **Media: Videos / Articles / Daily** (hub: `validate.js` MEDIA_SECTIONS;
  specs `track-video.md` / `track-article.md`; published: 50 / 50 / 30):
  `src/videos/videoNN-<slug>/lesson.md` (+ `transcript.srt`) ·
  `src/articles/articleNN-<slug>/lesson.md` (no transcripts by design) ·
  `src/daily/dailyNN-<slug>/lesson.md` (+ `transcript.srt`).
  Headers `## VideoNN:` / `## ArticleNN:` / `## DailyNN:` (+ meta line);
  Sources blockquote (`> Sources:` + `> Video:`/`> Article:` line copied from
  the track index) + `By the end...` goal line; no `### Sources` heading.
  10 headings in order (Lesson Map, Context, Key Words, Key Phrases,
  Key Sentences, Collocations, Vocabulary Expansion, Common English Patterns,
  Real-World Dialogue, Speaking Practice); NO Listening Notes (removed
  Batch 110), NO authored Final Recall (live deck, pool ≥ 30); file ends
  with `---`.
  Counts: Key Words pool ≥ 30 (authoring targets: videos ≥ 35 · articles ≥ 46) ·
  Phrases ≈ 8–14 · Collocations ≈ 10–15 · Expansion ≈ 8–10 · Patterns 6 ·
  Speaking Task + Model Answer, task time = band time.
- **Legacy v1.x** (`validate_all_md.py`, spec `lesson-template.md`,
  backward compat only): sections `1–12`; Key 10 · Vocab 10 · Sentences 10 ·
  Collocations 10 · Dialogue 10 · Errors 5 · Quick 5 · Real message 3+.
- No `|### N.` glued headers; no `part-` filenames; no Day 181+.
- Zero Key/Vocab headword overlap within a file (§4 = expansion, never
  repeats §3).
- A1 workspaces (legacy 001–020 only): zero `will`, zero
  `if`-conditionals/`if needed`, zero finite past
  (`did/was/learned/last night/yesterday`).
- §9 `> Goal:` duration matches the `Speaking (TIME)` header (legacy);
  link tracks: Speaking Practice Task + Model Answer present.

## 2. Language gate

- Zero `(ترجمة` placeholders; zero empty Arabic cells; Arabic columns always present;
  Arabic depth follows the band taper (B1 full but concise → C1/C2 term
  glosses); no English sentences inside Arabic columns (product names
  excepted).
- No mixed-language sentences (`All servers (خوادم) are...`); single-word glosses only.
- Sentence caps v3: B1 ≤18 · B2 ≤22 · C1 ≤26 · C2 ≤30 words. Legacy A1 ≤12 /
  A2 ≤16 still accepted by validator for old workspaces (backward compat only).
- Month grammar focus respected (§8); errors banked per month, never repeated
  within a month.
- Depth floor v3 (review, not parser): Mastery body B1 10k / B2 12k / C1 14k /
  C2 14–18k chars; Workplace prose 400+ words from B2 up with 5+ stance
  bullets; every C day pairs speaking + writing on one topic with dissent
  handling; A1 hard-ban rule applies to legacy workspaces only.
- Collocation/example hygiene (from past audits in `curriculum-audit.md`
  Phase 3): no terminal dangling preposition (`... alert in.`), no doubled
  connector (`before ... before`), no forced infra tail glued to every
  sentence (`via Intune for all 5,000 devices`), no verbatim 10-sentence §5
  repeat block across days. Regenerate the example from the day's words.
- **Naturalness gate** (`references/natural-english.md` — locked, all tracks):
  hard failures: AI-pattern blacklist hits (`Would you kindly…`,
  `Please be advised…`, `It is important to note…`, `I would like to inform
  you…`, `Kindly …`) · broken `whereas` (machine proxy: fragment single-word
  clause or dangling with no second clause; full two-subject well-formedness
  plus parallel-ellipsis legitimacy are Human QA — "Whereas managers skim,
  engineers follow." is correct and never flagged)
  · telegraphic fragments inside C1/C2 lessons · repeated headword inside Key
  or Key∩Vocab overlap within a day. Human-QA warnings (Naturalness Ranking
  required, per §2b): ≤3-word examples below C1 (a natural short full
  sentence like "I exported PDFs." may outrank a stuffed long one — reviewer
  ranks A/B/D); collocation **headword chunks** are exempt (chunks are units,
  not sentences — their Example cell must be a full natural sentence). Also
  required: Key/Vocab EN column = short real dictionary definition (no
  meta-glosses like `green = success color`) · no opening pattern starting
  >30% of one section's examples · spoken forms (`gonna`, `lemme`) only with
  an explicit `[spoken/informal]` tag and never in written-form examples ·
  key expressions carry 3–5 register variations when they exist.
  **A green validator is NOT a naturalness certificate** — every batch still
  passes the Human QA sample (Naturalness Ranking, contextual + technical +
  conversational realism).
- Deep checks (CEFR jumps, translation accuracy, pedagogy) belong to
  `references/curriculum-audit.md`, not to this gate. This gate is the
  per-file parser contract; the audit is the bulk quality workflow.

## 3. Video / Article QA (manual checklist, on link days only — validator does not enforce)

Video days (`references/video-input.md`): source authentic + URL verified +
segment named if long · Must/Useful/Optional done, Key from Must/Useful ·
authentic vs generated separated (Authentic / Lightly Edited / Generated
Practice labels) · segment tasks as prose (gist/specific/recognition/
transcript-check/recall) when timestamps exist · 2–4 listening traps max,
each naming one spoken feature, no invented phonetics · technical terms
preserved · patterns end with 1 micro-task · speaking offers 5 rungs ·
recall includes exercises + review box + Day 1/3/7/14 line (prose, counts
unchanged) · speaking retells the video (advise/decide tasks from B2 up) ·
comprehension asks about the video · no invented speaker claims.

Article days (`references/article-input.md`): article actually analyzed, main
idea + section named · essential vocab + technical terms preserved ·
Paraphrased vs Generated Practice labelled · sentence patterns extracted ·
skim/scan/infer tasks as prose in Context · 6 recall Q/A answerable from the
text + active exercises + review box + Day 1/3/7/14 line (prose) · §7 is a
discussion dialogue (never pasted article) · speaking (5 rungs) + writing
transfer to `profile.md` systems · no invented source content.

## 4. Machine validation

### 4a. Skill tooling (standalone workspaces; all scripts take `--root`;

default: current directory if it contains `curriculum.json` or `curriculum/`)

```powershell
python <skill>/scripts/new_curriculum.py --root ./my-curriculum --track mastery --title "English for Nurses"
python <skill>/scripts/new_lesson.py --root ./my-curriculum --track mastery-v3 --next --title "Handle Shift Handover"
python <skill>/scripts/new_lesson.py --root ./yt --track video --next --title "Entra Join" --url "https://www.youtube.com/watch?v=..."
python <skill>/scripts/new_lesson.py --root ./art --track article --next --title "Bulk Enrollment" --url "https://..."
python <skill>/scripts/validate_track.py --root ./my-curriculum --track mastery            # strict gate
python <skill>/scripts/validate_track.py --root ./my-curriculum --track mastery --partial  # incremental
python <skill>/scripts/build_v3.py --root ./my-curriculum --track mastery                  # V3 HTML (v3_style.css/js shell)
python <skill>/scripts/check.py --root ./my-curriculum --track mastery                     # strict + build + output check
# Legacy: validate_all_md.py + build.py (cards-only, v1.x workspaces only)
```

`validate_track.py` checks per track (headers, Sources, section order incl.
the optional Lesson Map, Goal lines, counts above, end marker, placeholders)
plus the Naturalness machine gate (hard AI-pattern/whereas/C-telegraphic
failures + ≤3-word human-QA warnings, collocation headword column exempt).
`build_v3.py` re-validates and enforces V3 HTML QA (V3 shell r2 marker,
offline-first — only per-track exceptions allowed: article `a.v2-src` source
link, video `iframe.v2-player` embed + watch link; no duplicate lesson IDs).
Head-block QA: video lessons show the embedded player, article lessons the
`Read original ↗` link; 🔊 is the last control on the right of every row.
Fix `BAD META` and header/filename mismatches immediately — both break the build.

### 4b. Hub pipeline (Tech-English-Hub repo — see `references/hub-project.md`)

```powershell
node tech-english-hub/scripts/validate.js                              # ALL hard gates + language reports (exit 0/1; --strict adds exit 2 report-only)
node tech-english-hub/scripts/mirror-from-src.js --days 091-120 --write  # src -> data (one-way; or --tracks <track>)
node tech-english-hub/scripts/mirror-from-src.js --rebuild --write      # full rebuild (repairs JSON escaping + indexes)
node tech-english-hub/scripts/itil-batch-qa.js                          # focused QA for src/itil
./tech-english-hub/scripts/audit-language.ps1 -ExportCsv lang-audit.csv  # Node-free language audit (Core)
```

Mirror is DRY-RUN unless `--write`; `--tracks` selects tracks; `status:"planned"`
index entries are skipped (their TODO-only dirs stay until authored).
`validate.js` exit codes: 0 green · 1 hard-gate failure · 2 report-only
findings under `--strict`.

Batch rule (locked): edit in `src/` only → `validate.js` green →
`mirror-from-src.js --write` → re-run `validate.js` → upload only changed
`data/curriculum/` files (never `users/`) → bump `CACHE_VER` in `Code.gs`
and redeploy as a New version → record the batch in the repo CHANGELOG.
`validate.js` exit codes: 0 green · 1 hard-gate failure · 2 report-only
findings under `--strict`.
