# Track: Tech English Core — `.md` Source Format (Binding, v3.5)

This is Track 1 of the workspace model. Its hub contract matches the live
curriculum in the Tech-English-Hub repo:
`tech-english-hub/src/core/dayNNN-<slug>/lesson.md` (120 lessons, the single
source of truth; mirrored to `data/curriculum/content/core-part1..4.json`,
30-day chunks; `core-part5..6.json` are empty retired placeholders).
Same Core-pattern contract for Career (80: `src/career/careerNN-<slug>/`)
and ITIL (40: `src/itil/itilNN-<slug>/`). Hub total = 370 published lessons,
0 planned. Enforced by `node scripts/validate.js` (CORE_SECTIONS, pool ≥ 30).
Workspace `validate_track.py --track mastery` is a pre-Batch-111 snapshot
(old names, Final Recall) — hub wins on conflict.

## File layout

- Mastery workspace: `<root>/curriculum/day-NNN/lesson.md` OR legacy
  `<root>/md/Day-NNN.md` (both accepted by the workspace validator). In the Hub repo:
  `tech-english-hub/src/core/dayNNN-<slug>/lesson.md` (Career:
  `src/career/careerNN-<slug>/lesson.md`, header `## CareerNN:`; ITIL:
  `src/itil/itilNN-<slug>/lesson.md`, header `## ITILNN:`).
- Header: `## Day NNN: Title Here`
- Meta: `**Level:** C1 | **Speaking:** 3 minutes | **Output:** 3-minute readout plus memo (300 words)`
  (hub bands: Core B2 Days 001–090 · C1 091–120; Career/ITIL B2–C1).
- Optional first section `### Lesson Map` (the published lessons carry it):
  the day's section map — MUST precede Mission when present (rows mirror the
  lesson's sections, e.g. Core Day120 lists 8 rows; media maps carry a
  self-row — follow the file's own convention).
- Sections (unnumbered `### Name`, in this order, all required, **9 total** in hub):

```markdown
## Day 001: Daily Standup: Simple Status Update
**Level:** A1 | **Speaking:** 30 seconds  | **Output:** 10-min daily status update

### Mission
By the end of this lesson, I can ...

### Real IT Situation
> Goal: Understand the real work situation for this lesson.

| English | الترجمة العربية |
|---|---|
| 2-4 sentence workplace scenario. | الترجمة العربية الكاملة. |

(new files: use the hub heading `### Real-World Scenario` — same table.
The workspace validator still accepts the legacy `Real IT Situation` name;
hub wins on conflict.)

### Key Language
> Goal: Learn the 12–15 key words and use them in your sentences.

| Word / Phrase | AR | EN | Example |
|---|---|---|---|
... 14-15 rows (Day-001: 15, Day-150: 14 — accept 12-15) ...

### Vocabulary
> Goal: Learn 15–20 more words about the same topic.

| Word | Arabic | Definition | Example |
|---|---|---|---|
... 19-20 rows (accept 15-20) ...

### Useful Sentences
> Goal: Practice 20–25 ready sentences for work.

| English | الترجمة العربية |
|---|---|
... 25 rows exactly (all sampled days: 25) ...

### Collocations
> Goal: Learn 12–15 fixed phrases that sound natural.

| English (Collocation) | العربية | Example |
|---|---|---|
... 15 rows (accept 12-15) ...

### Common Errors
> Goal: Avoid these 8–10 common mistakes.

1. ❌ wrong. ✅ correct.
... 9-10 numbered items ...

### Workplace English

> Goal: Read the article, notice the natural workplace expressions, and reuse them in your own professional communication.

Paragraph(s) of workplace prose — in the published lessons a live role-play
dialogue where the learner uses everything. No table.
(New files: use the hub heading `### Real-World Dialogue` — same body.
The workspace validator still accepts the legacy `Workplace English` name;
hub wins on conflict.)

### Speaking Practice
> Goal: Say the lesson back in your own words in [meta Speaking time].

**Task:** Retell/role-play aloud in [meta time], tied to the Mission, reusing
3–5 chunks from this day's Key Language/Collocations. C1 tasks add one
pushback to handle plus two follow-ups. Task time equals the band time
(session-rules.md §4).

**Model Answer:**
"First-person natural retell built from the lesson's own sentences.
Length scaled to meta: B2 2-min ≈ 150–205 · C1 3-min ≈ 220–285 (stance +
one dissent line)."
File ends with `---`.
```

> No authored `### Final Recall` in hub files: the page synthesizes a live
> deck at render time (hard gate: section absent + live pool ≥ 30 rows from
> Key Language + Vocabulary + Useful Sentences + Collocations). An authored
> flip-card Recall section exists only as a workspace-mode experiment —
> never write one into hub `src/`.

## Rules (binding)

- Section names + order fixed as above (hub: 9 sections + optional leading Lesson Map with section-mirroring rows). No numbered `1.` prefixes, no Dialogue/Grammar/Quick-Check sections (those belong to v1.x locked format, not this track). Post-Batch-111 hub names are `Real-World Scenario` and `Real-World Dialogue` — the workspace validator's legacy names still pass locally but hub files must use the new names.
- `### Real-World Dialogue` has a `> Goal:` line (no blank-line strictness beyond validator).
- `### Speaking Practice` requires `> Goal:` (time matches meta `Speaking:`) + `**Task:**` (reuse 3–5 lesson chunks; C bands add dissent + follow-ups; task time = band time) + quoted `**Model Answer:**` at band length with stance/dissent on C bands.
- No authored `### Final Recall` in hub files: the deck feeds live (pool ≥ 30 rows from Key + Vocab + Sentences + Collocations). `validate.js` fails any file carrying an authored Final Recall section.
- Counts enforced by `node scripts/validate.js` in hub mode:
  Key 12-15 · Vocab 15-20 · Sentences 25 · Collocations 12-15 · Errors 8-10 ·
  pool ≥ 30 (Core-pattern: all 120 Core + 80 Career + 40 ITIL against `data/`
  mirrors; media tracks gated separately).
- Situation table: exactly 1 data row, 2 columns.
- File ends with `---`. Meta labels exact. `## Day NNN:` matches filename.
- No placeholders (`ترجمة`), no empty Arabic cells.
- **Naturalness (binding):** every Example/Sentences/Collocations row passes
  `references/natural-english.md` — full natural example sentences (collocation
  chunks may be short; their Example cell is full), no AI-pattern sentences,
  dictionary-quality EN definitions, register-tagged variants, labelled spoken
  forms. Machine QA + Human QA sample (Naturalness Ranking A/B) per batch.
- **One real lesson per day:** no standalone Review/Simulation/Gate/Summit/
  Project days — review lives inside every lesson (spaced reuse +3/+10/+30
  and recycling inside Useful Sentences / Speaking Practice). C-traits checklist (from the
  addendum) travels with the output sections accordingly.
- HTML output: V3 shell r2 (`references/v3-html-spec.md`); workspace chunks of
  15 days + `index.html`. The published hub serves via Drive JSON
  (`core-part1..4.json`) + Apps Script bridge + Blogger page (see
  `references/hub-project.md`) — never hand-edit generated outputs.

## Depth addendum — v3.0 B1→C2 (binding for new/rewritten WORKSPACE days only, counts unchanged)

- Levels: B1 001–030 (≤18 words/sent, 90-sec speaking, 120–150-word writing) →
  B2 031–090 (≤22, 2-min, 180–250) → C1 091–150 (≤26, 3-min, 250–350) →
  C2 151–180 (≤30, 4-min + Q&A, 350–450). Validator checks structure; this
  addendum is enforced by `quality-gates.md` review + audit Phase 2 +
  `node scripts/validate.js` language reports in the Hub repo.
- Body floor: B1 10k → B2 12k → C1 14k → C2 14–18k chars. Workplace prose 400+
  words from B2 up, ending with 5+ reusable stance bullets
  (`The evidence suggests... / While I agree..., I recommend...`).
- Every C1/C2 day: paired output (speak the decision, write the memo/ADR/email
  on the same topic) + dissent handling (acknowledge → answer → commit with
  owner + date). No standalone review days from B1 up — review lives inside
  every real lesson (spaced reuse + in-lesson Quick Check).
- C-traits checklist (each C day carries all): 3+ hedges, 1 concession, 1
  passive-blameless construction, 1 conditional of the band, numbers + owners.
