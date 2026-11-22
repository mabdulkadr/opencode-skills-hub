# Input QA Protocol — Pre-Generation Verification (v2.4)

Interactive checklist to run **before** generating any Video or Article lesson.
Ensures compliance with `references/track-video.md` / `references/track-article.md`
(binding counts), `references/video-input.md` / `references/article-input.md`
(method), and `references/quality-gates.md`.
Gold standards: Video01 (Entra Join, Andy Malone) / Article01.

> v2.4 adds the Lesson Generation Quality Upgrade gates (source accuracy,
> language accuracy, educational purpose, practical relevance) as §4. Counts
> unchanged — validator is still the gate.

---

## 1. Video Pre-Flight (11-section track)

1. **Source:**
   - [ ] URL genuine and verified (or Sources text with no fabricated link)?
   - [ ] Audio clear, natural English? `.srt` saved next to `lesson.md`?
   - [ ] Long video (>10 min) → ONE segment named in Video Context?
2. **Vocabulary tiers:**
   - [ ] Must / Useful / Hear-only classified (5-axis score)?
   - [ ] Key total 25–75 with `**Must know**` + `**Useful**` tables + hear-only line?
   - [ ] Channel filler (subscribe/Patron/bell) excluded from Key rows?
3. **Sentences (4 labelled tables):**
   - [ ] Core authentic 5 + Practical steps 3 + Reusable patterns 3 + Work 4?
   - [ ] Generated rows clearly distinct from speaker quotes (never quoted as his words)?
4. **Remaining counts:**
   - [ ] Phrases 8–13 + filler line? Collocations 10–12 (`verb + IT noun`)?
   - [ ] Expansion 8–10? Patterns exactly 6? Recall 8–9 Q/A?
   - [ ] Listening Notes has `**Traps**` + `**Hard terms**` tables (2–5 genuine traps)?
5. **Transfer:**
   - [ ] Workplace English = applied prose on learner systems (not a summary)?
   - [ ] Speaking = retell 60–90 s with Task + quoted Model Answer?
   - [ ] Technical terms verbatim, no invented claims?

## 2. Article Pre-Flight (11-section track)

1. **Source:**
   - [ ] Reputable technical source (Microsoft Learn, vendor doc, engineering blog)?
   - [ ] Text actually provided (1–3 pages)? Long article → section named in Context?
2. **Vocabulary:**
   - [ ] Key single table 25–36 (no Must/Useful split)?
   - [ ] Technical terms verbatim (cmdlets, GUID, product names)?
3. **Sentences (4 labelled tables):**
   - [ ] Core 4 + Practical 6 + Repeated 3 + Work 3, paraphrased (never pasted paragraphs)?
   - [ ] Paraphrased vs Generated Practice labelled; no invented source content?
4. **Remaining counts:**
   - [ ] Phrases 10–14? Collocations exactly 10 (`verb + IT noun`)? Expansion 8–10?
   - [ ] Listening exactly 7 (meeting pronunciation, one spoken feature per row)?
   - [ ] Patterns exactly 6 + 1 micro-task (prose)? Recall exactly 6 + review prose?
5. **Transfer:**
   - [ ] Speaking summarizes + opines (B2: compare + example from learner env)?
   - [ ] Workplace English applies it (email/ticket/Teams proposal on `profile.md` systems)?

---

## 3. Failure Actions

- **Video >5 min without segment:** pause, pick a concrete 2–4 min segment first.
- **Vague / broken URL:** request transcript text or fall back to AI-topic workflow.
- **Low-density article:** request a deeper technical document or supplement with
  real system context from `profile.md`.
- **Count mismatch:** fix the tables before claiming done — validator
  (`validate_track.py --track video|article`) is the gate, not memory.

---

## 4. Quality-Upgrade Gates (v2.4 — run before claiming done)

**Source accuracy**
- [ ] Every Authentic row traceable to the transcript; Lightly Edited keeps
  meaning; Generated rows never quoted as the speaker; timestamps only when
  reliable; limitation stated when transcript is missing/corrupt.

**Language accuracy**
- [ ] Spelling/grammar/punctuation checked; Arabic glosses contextual (not
  literal); technical terms consistent + verbatim; no English inside Arabic
  cells (product names excepted).

**Educational quality**
- [ ] Teaches the language, not just the topic; listening is central
  (segment tasks + traps); every section has a distinct purpose; no filler
  repetition; recognition → controlled → independent progression; CEFR-true.

**Practical relevance**
- [ ] Examples reusable in meetings/support/tickets/reporting; IT workplace
  examples preferred over generic ones; learner can (1) follow main ideas,
  (2) catch key chunks while listening, (3) reuse sentences, (4) speak on
  topic, (5) transfer to real work.
