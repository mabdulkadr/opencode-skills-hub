# Track: Article Lessons — Reading Twin (Binding, v3.3)

Article lessons share the **10-heading media contract** specified in
`references/track-video.md` — same headings, same order, same closer, same
pool ≥ 30 hard gate, same renderer. This file specifies only the
**article deltas** (reading skill instead of listening). Where this file is
silent, track-video.md governs. Hub truth lives in
`tech-english-hub/src/articles/articleNN-<slug>/lesson.md` (50 indexed
lessons).

## Article deltas (binding)

- Header/meta/Sources: `## ArticleNN: Title` +
  `**Level:** B2/C1 | **Speaking:** … | **Output:** I can …` +
  `> Sources:` / `> Article: <title> | <url>` blockquote + goal line.
  The URL is a real official doc (MS Learn / AWS / Atlassian / CISA / NIST /
  HashiCorp / GitHub…), copied from `articles-index.json`, never from memory.
- `### Context` — 1 paragraph (what the article covers, author, date, steps)
  + 2 bullets (key facts). Skim/scan/infer tasks run as prose here.
- `### Key Words` — **single** study table
  (| Word / Phrase | AR | EN | Example |), 25–36 rows, technical + general
  mixed; no Must/Useful split — all rows are study items. Authoring target:
  pool ≥ 46 rows (hard gate ≥ 30).
- `### Key Phrases` — 10–14 rows. `### Key Sentences` — Core + Practical +
  Repeated + for-work tables paraphrasing the real article; comprehension
  items must be answerable from the article text.
- `### Collocations` — 10 rows. `### Vocabulary Expansion` — 8 rows.
  `### Common English Patterns` — 6 rows + 1 micro-task.
- `### Real-World Dialogue` — discussion dialogue transferring the article to
  the learner's systems (`profile.md`); never a pasted article passage.
- `### Speaking Practice` + transfer writing follow the media contract;
  task time equals the band time.
- **No transcripts by design** (unlike videos/daily). No `### Listening
  Notes`, no authored `### Final Recall` (live deck, pool-gated).
- Technical terminology preserved verbatim (product names, cmdlets, GUIDs).
  Never invent source content (session-rules.md §1).

## Rules (binding)

- Counts enforced by `validate.js` in hub mode; workspace
  `validate_track.py --track article` is a pre-Batch-110 snapshot (11-section
  with Listening Notes + Final Recall) — hub wins on conflict.
- HTML head renders the Sources block as title + `Read original ↗` link
  (no player on this track).

(End of file)
