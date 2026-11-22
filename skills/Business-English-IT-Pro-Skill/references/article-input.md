# Article Pedagogy — How to Build an 11-Section Article Lesson (v2.6)

Binding structure: `references/track-article.md` (section order, counts, validator ranges).
Reading twin of the video track: same 11-section shape, only the input source
and core skill change (listening → reading).
Gold standard: `curriculum/Article Lessons/lessons/Article01/lesson.md`.

Goal: **teach the English required to understand, discuss, and apply the actual
article** — never invent source content.

> v2.6 quality upgrade (backward-compatible): the 11-section binding is
> unchanged — validator counts are identical. What changes is the *method
> inside* each section: source-fidelity labels, section reading tasks,
> pronunciation features, pattern grammar notes, leveled speaking, active
> recall, and spaced review. All enrichment lives as prose/guidance inside
> the existing sections, never as new `###` sections or extra tables that
> would break `validate_track.py --track article`.

## When to use it

User pastes (or links) a real Microsoft Learn page, technical blog, or vendor
doc (1–3 pages of body text ideal). If no text is provided, ask for it.
Long articles: teach one section only and name it in `Article Context`.

## Workflow (map onto the 11 sections, add nothing)

```text
Article → topic + main idea (Article Context) → Key Words (single 25–36 table)
→ Phrases (10–14) → Sentences (Core 4 + Practical 6 + Repeated 3 + Work 3)
→ Collocations (10) → Expansion (8) → Listening Notes (7 pronunciation rows)
→ Patterns (6) → Workplace English (transfer prose) → Speaking (retell + opine)
→ Final Recall (6 Q/A)
```

## Vocabulary layers (see `vocabulary-priority.md`)

- **Key Words from the Article**: ONE table
  (`| Word / Phrase | AR | EN | Example |`), 25–36 rows, technical + general
  mixed. No Must/Useful split (unlike video) — every row is a study item.
  Technical terms preserved verbatim (cmdlets, GUID, OOBE, UAC, product names).
- **Expansion**: 8 rows (`| Word | Arabic | Definition | Example |`) for
  background words needed to fully own the topic.
- Frequency alone does not determine value — a once-mentioned error code can
  outrank a repeated filler verb.

## Reading skills (distribute across sections, no new sections)

- Main idea → Article Context + Final Recall Q1.
- Scanning for details → Recall Q2–Q3 (answerable ONLY from the article text —
  never from general knowledge).
- Technical references (`this policy`, `it`, `they`) → one Recall Q.
- Long sentences (split + paraphrase) → 1–2 sentence-pattern rows.
- Cause/effect + conditionals → Patterns rows when the article needs them.
- Paraphrase → Speaking (say it in your own words) + Workplace English
  (report it to your manager on YOUR systems from `profile.md`).

### Source-fidelity labels (v2.6, use exactly these words)

- **Paraphrased:** real article content reworded for study (Core/Practical
  tables). Never paste whole paragraphs; keep facts, change wording.
- **Generated Practice:** new drill sentences (Repeated-when-reusable / Work
  tables). Never present them as the author's words.
- No invented steps, error codes, or claims the article did not make. Missing
  or thin source → state the gap, teach the verified part only.

### Section reading tasks (v2.6, prose inside existing sections)

For long articles (taught section named in Article Context), add a compact
task block as prose in Article Context: `Skim (1 Q, gist, no dictionary) →
Scan (1–2 Qs, find the step/value/name) → Infer (1 Q, why this step matters)`.
Never assess facts outside the article text.

## The 11-section build order

1. **Article Context**: `> Goal:` + 1 paragraph (what/why, author, date, steps)
   + 2 bullets (key facts).
2. **Key Words**: single 25–36 table, no split, no hear-only line.
3. **Important Phrases**: 10–14 rows
   (`| English (Phrase) | العربية | Example |`).
4. **Important Sentences**: 4 labelled tables — **Core** 4 + **Practical** 6 +
   **Repeated expressions** 3 + **Sentences for work** 3
   (`| English | الترجمة العربية |`). Core/Practical paraphrase the real
   article; Work rows are new drill sentences.
5. **Collocations**: exactly 10 rows, prefer `verb + IT noun`.
6. **Vocabulary Expansion**: exactly 8 rows.
7. **Listening Notes**: exactly 7 rows, single table
   (`| Word / Phrase | العربية | How to catch it |`) — pronunciation for
   meetings (stress, spelling, syllables), not video traps.
8. **Common English Patterns**: exactly 6 rows.
9. **Workplace English**: 3–4 paragraphs applying the article to learner systems
   (`profile.md`). Not a summary.
10. **Speaking Practice**: `**Task:**` retell 60–90 s (summarize + opine; B2:
    compare options + example from your environment) + `**Model Answer:**`.
11. **Final Recall**: exactly 6 numbered Q + `> Answer:` (last may be an ordering
    task). Mix Detail / Meaning / Inference / Recall.

File ends with `---`. Every section opens with `> Goal:`.

## Transfer, not summary (§9 vs §10-shape)

- Speaking: summarize the article's recommendation + give your opinion.
- Workplace English: workplace message applying it (email proposing the change,
  ticket documenting the fix). Same topic, applied — grounded in `profile.md`.

### Pattern grammar + active practice + retention (v2.6, inside existing sections)

- **Common English Patterns (exactly 6 rows, table unchanged):** under the
  table add 1–2 lines per pattern as prose: original sentence → simple English
  explanation → Arabic meaning → 2 new IT examples. End the section with ONE
  short micro-task line. Grammar serves the article only — never a general
  textbook topic.
- **Listening Notes (exactly 7 rows, table unchanged):** each `How to catch
  it` cell names ONE spoken feature for meetings (word stress, sentence
  stress, spelling/syllables, similar-sounding pair, acronym spoken form).
  No invented phonetics.
- **Speaking Practice (Task + Model Answer required, prose may grow):** offer
  5 rungs as a short numbered prose list before the Model Answer —
  1 Controlled (complete 3 sentence halves) → 2 Guided (answer 2 content Qs
  with starters) → 3 Retell (60–90 s, CEFR time) → 4 Workplace transfer (same
  idea on learner systems) → 5 Independent (no notes). The quoted Model Answer
  stays ONE reference answer, labelled generated — never to be memorized.
- **Final Recall (exactly 6 numbered Q/A required, prose may grow):** keep the
  6 `> Answer:` items, then append as prose: (a) 3–5 active-use micro-exercises
  with a separate mini answer key (article vocabulary only), (b) a 5–10 item
  high-value review box, (c) a spaced-review line:
  `Day 1 → Day 3 → Day 7 → Day 14`. Do not assess facts outside the article.
- **Workplace English:** label the prose transfer (`Generated Workplace
  Practice`). After it, add 2–3 bullet lines naming the most reusable sentences
  and where to reuse them (ticket / meeting / email).

## Article QA (before claiming done)

- [ ] Article actually analyzed (main idea identified, section named if long).
- [ ] Key 25–36 (single table); Phrases 10–14; Collocations exactly 10;
  Expansion 8–10 (validator: 8–10); Listening exactly 7; Patterns exactly 6;
  Recall exactly 6.
- [ ] Core/Practical rows paraphrase the real article (labelled Paraphrased);
  Work rows labelled Generated Practice; no invented source content.
- [ ] Technical terminology preserved verbatim; Arabic glosses contextual.
- [ ] Recall questions answerable from the article text (+ prose tasks:
  skim/scan/infer in Context; micro-exercises + review box + Day 1/3/7/14
  in Recall — counts unchanged).
- [ ] Patterns section ends with 1 micro-task; Speaking offers 5 rungs.
- [ ] Speaking + Workplace English transfer to learner systems (`profile.md`).
- [ ] `validate_track.py --track article` passes; `build_v3.py --track article`
  renders standalone + aggregated HTML (V3 shell r2, TTS `data-say`).
