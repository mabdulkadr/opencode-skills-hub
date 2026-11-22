# Track: Media Lessons — Videos / Articles / Daily (Binding, v3.3)

This is the shared contract for the three media tracks. It matches the live
hub state after Batch 110 (Listening Notes removed → **10-heading lock**) and
Batch 111 (renamed parts). Hub truth lives in
`tech-english-hub/src/videos/videoNN-<slug>/lesson.md` (50 indexed lessons),
`src/articles/articleNN-<slug>/lesson.md` (50), `src/daily/dailyNN-<slug>/`
(30). Enforced by `node scripts/validate.js` (`MEDIA_SECTIONS`, pool ≥ 30).

Sister tracks: Core-pattern lessons (Core 120 · Career 80 · ITIL 40) are
specified in `references/track-mastery.md`.

## File layout (all three media tracks)

- Hub paths: `src/videos/videoNN-<slug>/lesson.md` ·
  `src/articles/articleNN-<slug>/lesson.md` ·
  `src/daily/dailyNN-<slug>/lesson.md`.
- Header: `## VideoNN: Title` / `## ArticleNN: Title` / `## DailyNN: Title`
  (the legacy `## Lesson: VideoNN:` / `## Lesson: ArticleNN:` form is accepted
  by the workspace validator only — write the short form in new files).
- Meta: `**Level:** B2 | **Speaking:** 2 minutes | **Output:** I can ...`
  (Daily: A1–B1 bands, task time equals the band time — session-rules.md §4).
- Sources block (blockquote, immediately after meta, then the goal line):

```markdown
> Sources:
> Video: <title> | <https://www.youtube.com/watch?v=...>

By the end of this lesson, I can ...
```

(Articles: `> Article: <title> | <url>`; Daily: `> Video: <title> | <url>`.)
The Sources URL/line is copied from the track index, never from memory
(session-rules.md §1). No `### Sources` heading exists.

- Sections (`### Name`, in this order, all required — **10 headings**):

```markdown
### Lesson Map
### Context
### Key Words
### Key Phrases
### Key Sentences
### Collocations
### Vocabulary Expansion
### Common English Patterns
### Real-World Dialogue
### Speaking Practice
```

File ends with `---`. There is NO `### Listening Notes` (removed Batch 110)
and NO authored `### Final Recall` — the page synthesizes a live deck at
render time (pool ≥ 30 hard gate, `validate.js`).

## Section notes (binding)

1. `### Lesson Map` — `> Goal:` + table (`| # | Section | What you learn |`)
   mirroring the lesson's sections + a `**Time:**` line (speaking time first).
   MUST precede `### Context` when present.
2. `### Context` — `> Goal:` + 1–2 paragraphs (what the source covers, why it
   matters now) + 2 bullets (key facts / on-screen actions).
3. `### Key Words` — `> Goal:` + `**Must know …:**` table
   (| Word / Phrase | AR | EN | Example |) + `**Useful …:**` table (same
   columns) + hear-only line
   (`You will also hear these - recognize them, do not study them: *…*`).
   Articles use a single study table (25–36 rows, no Must/Useful split).
4. `### Key Phrases` — `> Goal:` + table
   (| English (Phrase) | العربية | Example |) + channel-filler hear-only line
   where the source has one.
5. `### Key Sentences` — `> Goal:` + Authentic vs Generated labels
   (`**Authentic** = … **Generated** = …`): the speaker's/writer's real lines
   plus practice sentences the learner writes. Never invent quotes
   (session-rules.md §1).
6. `### Collocations` — `> Goal:` + table
   (| English (Collocation) | العربية | Example |); full natural Example
   sentences (headword chunks may be short; their Example cell is full).
7. `### Vocabulary Expansion` — `> Goal:` + table
   (| Word | Arabic | Definition | Example |).
8. `### Common English Patterns` — `> Goal:` + table
   (| Pattern | العربية | Example |), ending with 1 micro-task.
9. `### Real-World Dialogue` — `> Goal:` + a generated transfer scene reusing
   the lesson's expressions (labelled Generated; never presented as source
   content), uneven natural exchanges per `natural-english.md`.
10. `### Speaking Practice` — `> Goal:` (time matches meta `Speaking:`) +
    `**Task:**` (transfer task reusing 3–5 lesson chunks; C bands add one
    pushback + two follow-ups) + `**Model Answer:**` + quoted answer at band
    length. Do not retell the source; transfer to the learner's systems.

## Per-track deltas

| | Videos (50, B2–C1) | Articles (50, B2–C1) | Daily (30, A1–B1) |
|---|---|---|---|
| Transcript | `transcript.srt` next to `lesson.md` (required) | none by design | `transcript.srt` next to `lesson.md` (required) |
| Sources | real verified YouTube link or transcript-in-folder note | real official-doc URL (MS Learn/AWS/Atlassian/CISA/NIST/…) | real Mr. English Channel URL |
| Pool target | Key Words total ≥ 35 (hard gate ≥ 30) | Key Words total ≥ 46 (hard gate ≥ 30) | pool ≥ 30 hard gate |
| Levels | B2–C1 | B2–C1 | A1×8 · A2×17 · B1×5 |

Pool = table rows between `Key Words` and `Key Phrases` (`/^Word/` rows).

## Rules (binding)

- Transcript/article-first fidelity: containment 100% before publish
  (session-rules.md §1). Must/Useful/Optional tiers per
  `references/vocabulary-priority.md`; hear-only items never become study rows.
- Zero Key∩Expansion headword overlap within a file (re-check after the last
  edit). Counts enforced by `validate.js` in hub mode; the workspace
  `validate_track.py --track video|article` is a pre-Batch-110 snapshot
  (11-section) — hub wins on conflict.
- HTML output: V3 shell r2 — one standalone lesson page per lesson +
  aggregated lessons page (cards + collapsible sections, TTS `data-say`,
  search, progress, dark mode). Video head renders the `youtube-nocookie`
  embed (`?rel=0`) + `Watch on YouTube ↗` parsed from Sources; article head
  renders `Read original ↗` (no player).

(End of file)
