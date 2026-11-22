# Changelog — business-english-it-pro skill

All notable changes to this skill are documented here.
Version numbers follow `references/versioning.md` (SemVer: MAJOR.MINOR.PATCH).

## [3.3.0] — 2026-10-11

MINOR: hub-truth resync (batches 110–112) + session-rules fold-in. Both copies
(project `skill/` + installed opencode skill) are byte-identical at v3.3.0.

### Added
- `references/session-rules.md` (new, binding in hub mode): 26 hardened
  operating rules distilled from `tech-english-hub/LESSONS-LEARNED.md`
  (batches 68–77, 93–112) — transcript/article-first containment, Sources
  from index, section-scoped edits + recount, expected-vs-actual counts,
  detector hygiene, draft-residue grep, parser↔renderer one-contract rule
  with on-screen samples, task-time-equals-band-time, index↔body alignment
  (mirror syncs bodies only), numbers-with-definitions, transcript-only
  audio claims, dated state + live read-only check, batch numbering under
  parallel sessions, backup-first, Temp-outside-repo, `users/`/Drive freeze,
  audit→approve→fix→re-verify, documented-deviation policy — plus a
  copy-per-batch pre-publish checklist.

### Changed
- Media contract 11 → **10 headings** everywhere (Batch 110 removed Listening
  Notes; Batch 111 renamed parts): `SKILL.md` (description, table, modes,
  daily loop rewritten without legacy § numbers, output contracts, levels
  bullet now hub-locked with workspace B1–C2 marked workspace-only, pipeline,
  What NOT to do), `README.md`, `track-video.md` (rewritten: shared
  Videos/Articles/Daily contract + per-track deltas + pool targets),
  `track-article.md` (rewritten: reading-twin deltas on the shared contract),
  `quality-gates.md` §1 + §4b (`--tracks`, `planned` skip, exit 0/1/2).
- Core-pattern contract corrected to **9 sections + optional Map, no authored
  Final Recall** (live deck, pool ≥ 30): `track-mastery.md` (v3.5: hub paths,
  `## CareerNN:`/`## ITILNN:` forms, B2/C1 bands, rename map, Anki deck
  marked workspace-only experiment, B1–C2 addendum marked workspace-only),
  `quality-gates.md`, `SKILL.md`, `README.md`.
- `references/hub-project.md`: live state 2026-10-11 — page v9.4.5, planned
  TODO-only dirs (videos video41/video50, articles article31), videos 53 dirs
  / 50 indexed + video03 orphan, mirror bodies-only limitation (Batch 112),
  `--strict`/BOM-tolerant/planned-aware gates, doc-lag note (scripts/README
  "11 sections", repo README state table v9.3.4 — tools + indexes win).
- `scripts/validate_track.py` header docstring: marked as pre-Batch-110
  workspace snapshot (hub `validate.js` governs hub `src/`).

## [3.2.0] — 2026-10-10

MINOR: live-hub mirror (curriculum v10: 6 tracks, 370 published, 0 planned) +
ported v7.4 engineering fixes. Both copies (project `skill/` + installed
opencode skill) are byte-identical at v3.2.0.

### Added
- `brand_hits()` product-name gate (port of global v7.4.1): case-insensitive
  canonical-capitals check (`Microsoft/Purview/Entra/Intune/SharePoint/Zabbix/
  Defender/OneDrive`), URLs excluded (slugs stay lowercase legitimately) —
  wired into `scripts/validate_track.py` (`check_mastery` + `check_link`) and
  `scripts/validate_all_md.py` (`check_file`).
- UTF-8 stdout guard (port of global v7.4.1) in `scripts/check.py`,
  `scripts/new_curriculum.py`, `scripts/new_lesson.py` — no more
  `UnicodeEncodeError: charmap` crashes on Windows consoles under non-ASCII
  paths; `import sys` added where missing.
- YouTube embed hardening (port of global v7.3.1) in `scripts/build_v3.py`:
  `?rel=0` on the `youtube-nocookie` embed + `web-share` permission
  (playback Error 153 class of failures).

### Changed
- `references/hub-project.md` rewritten for the live project: 6-track/370
  layout (`dayNNN-`/`videoNN-`/`articleNN-`/`dailyNN-`/`careerNN-`/`itilNN-`
  dirs, `lesson.md` + `transcript.srt` policy per track, `core-part1..4`
  30-day chunks + empty `part5..6` placeholders, `Code.gs.txt` v2.4.2 /
  `CACHE_VER v13`, page v9.3.4 live), all four hub tools
  (`validate.js` 120/50/50/30/80/40 gates, `mirror-from-src.js`,
  `itil-batch-qa.js`, `audit-language.ps1`), known-state facts (video03
  orphan dir, generated artifacts), CEFR bands per track.
- `SKILL.md`: frontmatter + hub-mode block + pipeline commands updated to
  370/6-track reality (was: 212 lessons, 180/18/14, `--days 121-180`).
- `README.md`: track catalog, hub batch workflow, layout tree, contracts,
  self-test paths updated to the live repo.
- `references/track-mastery.md`, `references/quality-gates.md`: hub mirror
  facts corrected (`dayNNN-<slug>/`, part1..4, `--days 091-120`); workspace
  B1→C2 bands explicitly marked workspace-only vs live-hub B2/C1 Core 120.
- `references/natural-english.md`, `references/language-system.md`: quality
  anchor repointed from historical "Core Days 151–180" to the published
  Core's clean C1 range; stale `core/version.json` pointer fixed to
  `data/curriculum/config.json`.

### Fixed
- `scripts/new_lesson.py`: Mission scaffold no longer force-lowercases the
  whole mission (port of global v7.4.1) — strips only the leading "I can"
  prefix and one trailing period, preserving `Microsoft Purview`, `Entra`, ….

## [3.1.0] — 2026-10-06

MINOR: Hub sync + Natural English System (built on the v3.0 B1→C2 deep
re-ranging; folds the 2026-10-06 natural-english work into one compatible
release). Quality anchor: the published Core Days 151–180 (the curriculum's
clean range).

### Added
- `references/natural-english.md` (new, locked): 12-rule Naturalness Gate
  (full-sentence examples with short-chunk exemption, no broken `whereas`,
  no signoff signatures, dictionary definitions, Key dedupe, AI-pattern
  blacklist, anti-pattern-repetition filter, register-tagged variations,
  labelled spoken forms, function-tied lessons) + **Naturalness Ranking
  A/B/C/D** + **Machine QA / Human QA split** (a green validator is not a
  naturalness certificate) + **Language Source Hierarchy (Tiers 1–4 — AI
  never invents curriculum language**) + **situation domains (IT + general
  Workplace + Daily Life — the learner is a person)** + realistic-dialogue
  rules (uneven natural exchanges, character-pair rotation,
  Authentic/Variation/Generated labels) + the **cancel review DAYS /
  keep mandatory in-lesson review** policy (no review/simulation/gate/
  summit/project days on any track — review lives inside every lesson via
  spaced reuse + Quick Check).
- CEFR bands realigned to the published Core curriculum (locked):
  B1 001–030 → B2 031–090 → C1 091–150 → C2 151–180 (A1/A2 legacy banding):
  `SKILL.md` bands bullet, `language-system.md` §3 grammar spine + band
  demands + §4 Arabic taper, `quality-gates.md` sentence caps / A1 legacy note.
- `scripts/validate_track.py`: Naturalness machine gate on ALL tracks —
  AI-pattern blacklist + broken `whereas` as hard failures; ≤3-word examples
  as **human-QA warnings** below C1/C2 (a natural short sentence outranks a
  stuffed long one — human QA ranks them) and hard failures inside C1/C2
  lessons; Collocation **headword-chunk column exempt** from the full-sentence
  check (chunks may be short; their Example cell must be full); accepts the
  optional leading `### Lesson Map` section the published Core carries
  (verified against the real 180-day src: clean on Day-170, hard failures on
  Day-100-style C1 fragments, warnings on B2 short examples).

### Changed
- `references/language-system.md`: new §6 "Naturalness (locked)" binding all
  tracks to the new system.
- `references/quality-gates.md`: Language gate extended with the Naturalness
  machine checks + Human QA notice.
- `references/track-mastery.md`: binding Naturalness + one-real-lesson-per-day +
  review-inside-lesson rules added (was `track-core.md`).
- `SKILL.md`: v3.1 description, hub-mode + reading-table entries
  (`hub-project.md`, `natural-english.md`), hardened "What NOT to do".
- `references/hub-project.md` (new): the real Tech-English-Hub repo —
  src-as-truth layout, `data/curriculum/content/core-part1..6.json` +
  indexes, the three hub tools (`validate.js` exit 0/1/2, `mirror-from-src.js`
  `--days/--rebuild/--write`, `audit-language.ps1`), the locked 7-step batch
  (upload `curriculum/` only, never `users/`; `CACHE_VER` redeploy),
  naming/doD: Core 180 + Media 32 (18 video + 14 article) = 212.
- Hub sync completed: both skill copies (project + installed opencode skill)
  are byte-identical at v3.1.0; `track-core.md` folded into
  `track-mastery.md`; months-plan/pacing-guide aligned to no-standalone-review
  policy; scripts reference `track-mastery.md`.
- `VERSION`: 3.0.0 → 3.1.0.

## [3.0.0] — 2026-10-01

MAJOR: B1→C2 deep-content re-ranging. New workspaces start at B1 Day 001 and
climb to C2 Day 180; A1/A2 generation retired (old workspaces still validate —
validator checks structure, never the level string). Counts, section order,
and builder contract unchanged.

### Added
- C-level outcomes (binding from C1 up): blameless post-mortem, ADR + defense,
  scope negotiation with hedging, cost/architecture memo, exec Q&A
  (acknowledge → answer → commit), BATNA salary framing; every C day pairs
  speaking + writing on one topic with dissent handling.
- Depth floors (review-enforced): body B1 10k / B2 12k / C1 14k / C2 14–18k
  chars; Workplace prose 400+ words from B2 up with 5+ reusable stance bullets;
  C checklist per day (3+ hedges, 1 concession, 1 blameless passive,
  1 band-conditional, numbers + owners). No standalone review days from B1 up.
- `track-mastery.md` Depth addendum v3.0; `months-plan.md` B1→C2 month rows
  with migration note; `language-system.md` v3 spine + caps
  (B1 ≤18 → B2 ≤22 → C1 ≤26 → C2 ≤30) + v3 Arabic taper;
  `quality-gates.md` v3 caps + depth floor.

### Changed
- `SKILL.md` levels + Arabic + depth bullets rewritten to v3.0; description
  bumped v2.6 → v3.0.
- `VERSION`: 2.6.0 → 3.0.0.

### Migration
- Old Days 001–060 elevate to B1/B2 outcomes; old Days 091–180 push one band
  up (B2→C1, career→C2 with reflection + BATNA). Re-run audit Phases 2/4/6
  after migration. Rebuild every track after this bump.

## [2.6.0] — 2026-09-30

MINOR: Lesson Generation Quality Upgrade extended to the article track
(same v2.4 video treatment, reading-adapted; backward-compatible —
11-section binding, validator counts, and builder contract unchanged).

### Added
- `references/article-input.md` (v2.6): source-fidelity labels (Paraphrased /
  Generated Practice), section reading tasks (skim → scan → infer) as prose
  in Article Context, pattern grammar notes + 1 micro-task, meeting-
  pronunciation features per Listening row, 5-rung speaking ladder, Final
  Recall active exercises + review box + Day 1/3/7/14 spaced line,
  `Generated Workplace Practice` label + reusable-sentence bullets.

### Changed
- `references/track-article.md`: counts line fixed to the validator truth
  (Key 25–36, Expansion 8–10).
- `references/input-qa-prompt.md` article pre-flight: fidelity labels,
  micro-task, rungs, review prose.
- `references/quality-gates.md` article QA now references the v2.6 method.
- Curriculum fixes (strict gate now green 13/13): Article01 colloc 17→10,
  Article02 16→10, Article04 Key 24→26, Article05 colloc 11→10, Article06
  expansion 11→10, Article07 colloc 13→10 (weakest/duplicate rows removed).
- `SKILL.md` / `VERSION`: 2.5.1 → 2.6.0.

## [2.5.1] — 2026-09-30

PATCH: Key Words sub-headers rendered with literal `**` in HTML
(e.g. `**Must know - ...:**` showed as plain text). Builder now renders them
as `<h4>` headings; hear-only callout strips `*` emphasis markers.

### Fixed
- `scripts/build_v3.py` (`render_link_section`, Key Words branch): `**Must
  know...**` / `**Useful...**` parts now emit `<h4>` (asterisks stripped)
  instead of an escaped paragraph — same pattern as the Sentences renderer.
- Same branch: hear-only `v2-callout` strips `*` so no raw markdown remains.
- `SKILL.md` / `VERSION`: 2.5.0 → 2.5.1. Rebuild every track after this bump.

## [2.5.0] — 2026-09-30

MINOR: speaker-only UI — the Copy button is removed from all generated HTML;
every English row keeps only the 🔊 TTS button (backward-compatible: validator
counts and lesson `.md` format unchanged; old HTML still works).

### Removed
- `scripts/build_v3.py`: `copy_btn()` deleted; `render_sent_lines()` now emits
  only `{say_btn(en)}` (cards and prose were already speaker-only).
- `scripts/v3_script.js`: clipboard/`data-copy` handler deleted.
- `references/v3-html-spec.md`: spec now says speaker-only (`data-say`, no
  `data-copy`).

### Changed
- `SKILL.md` / `VERSION`: 2.4.0 → 2.5.0.
- Rebuild every track after this bump so no `data-copy` remains in outputs.

## [2.4.0] — 2026-09-30

MINOR: Lesson Generation Quality Upgrade merged into the video track method
(backward-compatible — 11-section binding, validator counts, and builder
contract unchanged; existing Video01–05 rebuild as-is).

### Added
- `references/video-input.md` (v2.4): source-fidelity labels (Authentic /
  Lightly Edited / Generated Practice), timestamped segment task blocks
  (gist → specific → recognition → transcript-check → analysis → recall) as
  prose inside Video Context + Listening Notes, pronunciation feature list
  per trap row, pattern grammar notes + 1 micro-task, 5-rung speaking ladder,
  Final Recall active exercises + review box + Day 1/3/7/14 spaced line,
  Workplace English reusable-sentence bullets.
- `references/listening-system.md` (v2.4): segment task template + transcript
  check rule + pronunciation feature checklist (no invented IPA).
- `references/vocabulary-priority.md` (v2.4): word-writing rules (contextual
  examples, no orphans, no filler repeats, verbatim technical terms,
  similar-word distinctions, contextual Arabic).
- `references/input-qa-prompt.md` (v2.4 §4): Quality-Upgrade Gates (source /
  language / educational / practical checklists).

### Changed
- `references/quality-gates.md` §3: Video QA now references the v2.4 method
  (segment tasks, spoken-feature fixes, micro-task, rungs, retention prose).
- `SKILL.md` / `VERSION`: 2.3.2 → 2.4.0.

### Why not 14 sections
- The proposed 14-section shape (overview, segmented practice, pronunciation
  table, grammar tables, active practice, 5-level speaking, assessment,
  retention) would be a MAJOR break (validator + builder + 12 published
  lessons). v2.4 delivers every one of its ideas as enrichment prose inside
  the locked 11 sections instead — same learning value, zero migration.

## [2.3.2] — 2026-09-28

PATCH: docs catch up with the 2.2.0–2.3.1 builder improvements (no behavior
change, no validator change).

### Changed
- `references/quality-gates.md`: offline rule rewritten as offline-first with
  the two per-track exceptions (article source link, video embed); added
  head-block QA (player vs link) and the 🔊-last-on-the-right rule.
- `references/track-video.md`: HTML output bullet now documents the embedded
  `youtube-nocookie` player + `Watch on YouTube ↗` link.
- `references/track-article.md`: HTML output bullet now documents the
  clickable `Read original ↗` link (no player on this track).
- `README.md`: version header 2.0.0 → current; layout notes no longer pin a
  stale version number.

## [2.3.1] — 2026-09-28

PATCH: speaker (TTS) button is now always the last control on the physical
right of every row (no `lesson.md` or validator change).

### Fixed
- `scripts/build_v3.py` (`render_sent_lines`): button order swapped to
  Copy-then-Listen, so 🔊 sits at the row end on the right — matching every
  other row type (cards, situations, recall), where 🔊 was already last.
- `scripts/v3_style.css`: new `V3-SPEAKER-RIGHT` rule pins `.v2-line-btns`
  (plus card-head and situation buttons) with `margin-left:auto`, so the
  speaker stays right even when rows wrap on mobile or direction shifts.

## [2.3.0] — 2026-09-28

MINOR: video lessons render an embedded player again, split by track
(backward-compatible — `lesson.md` format unchanged).

### Added
- `scripts/build_v3.py`: new `render_video_source()` + `youtube_id()` — the md
  `> Video: <Title> | <YouTube URL>` block now renders a responsive 16:9
  embedded player (`iframe.v2-player`, privacy-enhanced `youtube-nocookie`
  embed, lazy load, `allowfullscreen`) above the source callout, which keeps a
  `Watch on YouTube ↗` link. Supports watch / youtu.be / embed / shorts URLs;
  falls back to the plain source link when no video id is found.
- `scripts/v3_style.css`: `.v2-video` responsive wrapper + `.v2-player` rules.

### Changed
- `scripts/build_v3.py`: video lessons use `render_video_source()`, article
  lessons keep `render_source()` (clickable `Read original ↗` link, no
  player). Offline gate allowlists both (`a.v2-src` + `iframe.v2-player`);
  any other external `href/src` still fails.
- `references/v3-html-spec.md`: offline-first rule now documents the two
  per-track exceptions (article link vs video embed).

## [2.2.0] — 2026-09-28

MINOR: clickable source links in video/article HTML (backward-compatible —
`lesson.md` format unchanged, old lessons rebuild as-is).

### Added
- `scripts/build_v3.py`: new `render_source()` — the md
  `> Video: <Title> | <URL>` / `> Article: <Title> | <URL>` block now renders
  as title + real link (`a.v2-src`, `target="_blank" rel="noopener"`,
  `Read original ↗`) instead of escaped plain text with a stray `> Article:`
  prefix. Falls back to title text when no URL is present.
- `scripts/v3_style.css`: `.v2-source` link styles (brand color, underline,
  long-URL wrapping, visited/hover states, dark-mode aware).

### Changed
- `scripts/build_v3.py`: offline gate now allowlists the single source link
  per lesson (`_has_forbidden_external()` strips `a.v2-src` before the
  `EXT_RE`/`CSS_URL_RE` check); any other external `href/src` still fails.
- `references/v3-html-spec.md`: standalone rule documented as offline-first
  with the one source-link exception.

## [2.1.0] — 2026-09-28

MINOR: video/article pedagogy rewritten to match the Video01/Article01 gold
standard (11-section tracks). `track-video.md` / `track-article.md` were already
binding; now `video-input.md`, `article-input.md`, `vocabulary-priority.md`,
`listening-system.md`, and `input-qa-prompt.md` teach that exact shape instead
of the legacy 12-section (§3 Key 10 / §7 dialogue / §8 grammar) model.

### Changed
- `references/video-input.md`: full method for the 11-section video lesson
  (source analysis + Must/Useful/Hear-only tiers + 4 labelled sentence tables
  5+3+3+4 + section build order with Video01 counts + Video QA).
- `references/article-input.md`: reading-twin method (Key single table 25–36,
  sentence tables 4+6+3+3, Listening 7, Recall 6, transfer rules).
- `references/vocabulary-priority.md`: tiers remapped to Must/Useful/Hear-only
  tables + Phrases/Collocations/Expansion slots (validator ranges 25–75 / 8–13 /
  10–12 / 8–10).
- `references/listening-system.md`: layers remapped onto Video Context → Key
  Words → Sentences → Listening Notes (Traps + Hard terms) → Speaking Practice.
- `references/input-qa-prompt.md`: pre-flight checklists rewritten to the
  validator counts (video: Key 25–75, Phrases 8–13, Colloc 10–12, Patterns 6,
  Recall 8–9; article: Key 25–36, Colloc 10, Listening 7, Recall 6).

## [2.0.0] — 2026-09-28

MAJOR: multi-track factory matching the three published curricula. New
workspace layouts, new section contracts, new V3 builder (V3 shell r2 replaces
the v1.x cards-only builder for new work; v1.x scripts kept for backward compat).

### Added
- `references/track-mastery.md`: Track 1 binding spec (8 sections; Key 12-15,
  Vocab 15-20, Sentences 25, Collocations 12-15, Errors 8-10; review-day title
  variants allowed) — matches `curriculum/IT English Mastery/md/Day-NNN.md`.
- `references/track-video.md`: Track 2 binding spec (11 sections; Must/Useful
  split + hear-only line; authentic vs generated; Recall 8-9) — matches
  `curriculum/YouTube Lessons/lessons/VideoNN/lesson.md`.
- `references/track-article.md`: Track 3 binding spec (11 sections; Key 25-36
  single table; Recall 6) — matches `curriculum/Article Lessons/lessons/ArticleNN/lesson.md`.
- `references/v3-html-spec.md`: V3 shell r2 output contract shared by all tracks
  (hero, toolbar/search/progress/theme, cards, collapsible sections, TTS
  data-say, copy, drafts, V2.init routing; offline; Blogger `<!--more-->`).
- `scripts/validate_track.py`: per-track strict validator (`--track
  mastery|video|article`, `--partial`); accepts review variants, combined H1+meta
  lines, singular/plural hear-only lines. Verified: 180 mastery + 12 video +
  11 article reference files pass.
- `scripts/build_v3.py`: V3 builder (`--track`) — mastery 15-day chunks
  (`Days-01-15.html` + `index.html`) or `site/`; video/article standalone
  `lesson.html` + aggregated `lessons.html`. Shell vendored in
  `scripts/v3_style.css` + `scripts/v3_script.js` (byte-identical CSS/JS to the
  published HTML).
- `scripts/v3_style.css`, `scripts/v3_script.js`: vendored V3 shell assets.
- `workspace-template/lessons/.gitkeep`: skeleton for video/article workspaces.
- `new_curriculum.py --track`: per-track scaffold + manifest (`track`, `layout`).
- `new_lesson.py --track`: `mastery-v3` (8-section), `video`/`article`
  (11-section + `--url`) scaffolds with exact table counts.

### Changed
- `SKILL.md`: v2.0 multi-track (modes, contracts, build commands, what-not-to-do).
- `references/quality-gates.md`: per-track structural gates + commands.
- `scripts/check.py`: `--track` support (track validators + V3 outputs).
- `VERSION`: 2.0.0. `SKILL.md` version line: 2.0.0.

### Backward compat
- `references/lesson-template.md`, `template-md-reference.md`,
  `scripts/validate_all_md.py`, `scripts/build.py` unchanged and still work for
  v1.x 12-section workspaces. New work should use the track specs + `build_v3.py`.

## [1.1.1] — 2026-09-27

Patch fixes from skill audit (no behavior change to lessons, validator gates,
or builder contract).

### Fixed
- `scripts/validate_all_md.py`: `--help`/`-h` now prints usage instead of the
  misleading "Not a workspace" error (the only script without argparse).
- All 5 script docstrings: stale `(v1.0)` → `(v1.1)` to match the skill version.

## [1.1.0] — 2026-09-27

Selective V8 learnings, backward-compatible (no locked-section or count changes,
no validator/builder contract changes). Video mode upgraded, article mode added
as a reading twin, vocabulary priority + listening systems extracted.

### Added
- `references/vocabulary-priority.md`: Must/Useful/Optional tiers + scoring
  rule (frequency alone ≠ value) + mapping to locked §3/§4/§5/§6.
- `references/listening-system.md`: Before/First/Second/Third/Replay/Retell
  layers + 2–4 listening traps + CEFR adaptation + video Arabic policy.
- `references/article-input.md`: article-day workflow mapped onto locked 12
  sections (§7 = discussion dialogue, never pasted article) + Article QA.
- `references/video-input.md`: Video QA checklist; authentic vs generated
  separation rule; comprehension 4-type mix (Detail/Meaning/Inference/Recall).

### Changed
- `references/video-input.md` rewritten: source analysis first, tiers-driven
  word selection, `verb + IT noun` collocation bias, speaking rungs
  (Guided → Structured → Free retell). Locked 12 sections unchanged.
- `references/language-system.md` §2: kept in-lesson reuse lock, added guided
  cross-lesson ladder (Introduce → +3 → +7 → +14 → +30) with domain priority
  General → Workplace → IT → Infrastructure → Microsoft stack.
- `SKILL.md`: modes 3/4 now explicit Video Lesson + Article Lesson; references
  table lists the 3 new files; description bumped to v1.1.
- `references/quality-gates.md`: new §3 Video/Article QA manual checklist
  (validator untouched — strict gate still §§1–2 only).
- `README.md`: version + layout + everyday-use table updated for video/article.

## [1.0.0] — 2026-09-10

First standalone release. The skill is now a self-contained package: everything
it needs lives inside this folder, and everything it produces lives inside a
curriculum workspace it scaffolds. No dependency on any external repo layout.

### Added
- `VERSION` (1.0.0) + this CHANGELOG + `references/versioning.md` (bump policy).
- `references/learner-profile.md`: how to define learner/domain per workspace
  (default worked example: IT infrastructure engineer).
- `references/curriculum-audit.md`: full 6-phase audit workflow vendored inside
  the skill (full → CEFR/grammar → English/Arabic → pedagogy → apply fixes →
  final verification); reports go to `<workspace>/reports/`.
- `scripts/new_curriculum.py`: scaffold a new workspace
  (`profile.md`, `curriculum/`, `site/`, `reports/`, `curriculum.json`).
- `scripts/build.py`: self-contained offline HTML builder (cards-only, no
  external URLs) → `<workspace>/site/days-001-030.html` … + `index.html`.
- `workspace-template/`: skeleton (`profile.md`, `.gitkeep` dirs).
- `--root` on every script: operate on any workspace; `--partial` on the
  validator for incremental day-by-day building.

### Changed
- Skill is domain-parameterized: methodology (12 locked sections,
  Situation → Input → Practice → Output, minimums, levels, audit) is fixed;
  learner, domain, stack, scenarios come from the workspace `profile.md`.
- `SKILL.md` v1.0: workspace model, no absolute paths, no `site/v3`, `tools/`,
  or `docs/` references. `README.md` is now a full usage guide.

### Removed / superseded
- Dependency on repo-root `curriculum/`, `site/v3/src/build_v3b.py`,
  `tools/build.py`, `tools/check.py`, and `docs/Prompts.md`. (The legacy
  Business-English-for-IT-Professionals repo keeps its own copies; this skill
  no longer reads them.)
- Legacy `monthN-dayNNN.md` mirror layout: v1.0 workspaces use
  `curriculum/day-NNN/lesson.md` only.
