# Session Rules — Hardened Operating Rules from Published Batches (binding, v3.3)

> Distilled from `tech-english-hub/LESSONS-LEARNED.md` (batches 68–77, 93–112)
> and the repo CHANGELOG. **Binding in hub mode**: any batch violating these
> rules is rejected. Every rule exists because a published batch paid for it
> (lesson numbers in brackets refer to `LESSONS-LEARNED.md`).
> In workspace mode these are strongly recommended for any bulk fix.

## 0. Read before any authoring batch

- `LESSONS-LEARNED.md` in full, the repo CHANGELOG head (for the next batch
  number — parallel sessions can collide, #15), and the real `--help`/usage
  header of every tool you will invoke (never copy a command from memory —
  #20: `--strict` exists on `validate.js` today, exit 2 report-only).
- Where numbers disagree, **indexes win**:
  `data/curriculum/*-index.json` over prose docs (hub-project.md §6).

## 1. Fidelity — transcript/article-first (zero tolerance)

- Every quote cell is verified by a **containment check** against the real
  transcript/article text before publish; 100% match except documented ASR
  cleanups (#1, #2). A quote is one contiguous literal span or it is not
  written — never merge across turns, never compress (#2).
- Sources are **copied from the index** (`videos-index.json → url`), never
  from memory (#3). No invented episode URLs, no invented source claims; SRTs
  that are authored stand-ins (not real transcripts) are disclosed as such
  (Batch 109 known debt).
- No phonetic/stress claims without audio: from SRT text alone write
  `transcript-only` + `audio-not-checked` (#22).

## 2. Edit discipline — scope every mechanical change

- Row-numbered replacements are scoped inside their section (`sectionBetween`)
  and followed by a recount — the same `| 11 |` pattern can match two tables
  (#4). After every headword change, check the new headword against **all**
  tables in the file (Key ∩ Expansion/Vocab overlap, #8).
- Hand-edit in `src/` only; no content-generating scripts (Batch 68: 110 files
  with zero machine drift). Multi-line check logic goes in a **file**, never
  `python -c` in PowerShell (#26). Scratch/test files live in the Temp dir,
  never in the repo; `git status` before closing shows only intended files
  (#25).
- Backup before any structural change (`backup-YYYYMMDD-…/`, Batch 68).
- Every script prints **`expected vs actual` counts**; silence is failure — a
  merger that skips 5 files quietly is worse than one that crashes (#5).
- Network batches always use sleep + retries + count verification (#13); new
  tools are evaluated inside the real (proxied) environment before adoption
  (#14).

## 3. Detector hygiene

- A detector that flags correct content is broken: the raw-`ترجمة` check
  counts only the real placeholder pattern/empty cells, and grammar-term
  glosses are documented exceptions (#6, #9). Test every detector on known
  positive/negative cases before trusting its report.
- Pre-publish grep on every touched file: `؟` / `?` inside tables, stray
  non-English/non-Arabic tokens (draft residue: `balm؟`, `attic؟`, Gujarati
  chars…), empty Arabic cells, full English sentences inside Arabic columns
  (#7, #9).

## 4. Parser ↔ renderer — one contract, proven on screen

- Validator and page share **one section contract**; after any parser or
  renderer change, render a real sample from **every touched track** before
  closing (#16). Test a fix against **all real variants** found by grep
  first, not two samples (#17).
- Speaking task time **equals the band time** — no 60–90s tasks in B2/C1
  lessons; gate it automatically (#18). Model Answer presence/form follows
  the current renderer contract (`validate.js` + page `CUR_SECTIONS`
  blueprints move together, Batch 111).
- **Mirror syncs bodies only**: index titles/levels/missions can go stale
  silently — check index↔body title/level/mission alignment before every
  release (#19, Batch 112).

## 5. Numbers with definitions, claims with proof

- Every reported number carries its definition: threshold + population + tool
  (#21). Never compare counts taken under different thresholds.
- State sections are **dated**; deployment state is proven live and read-only
  (`?action=version` + two real lessons) before any status is announced
  (#23, Batch 68). Stale-page/README claims next to live ones cause decisions
  on expired state — sync or date them.

## 6. Batch and publish discipline

- One batch = one owner-approved, focused correction (repo CHANGELOG
  convention). Audit Phases 1–4 read-only, approval, then Phase 5 edits,
  then re-verify: mirror → validate green → containment green → document
  (#4 in §6 of lessons: re-verify caught Batch-77 collateral immediately).
- `users/` and Drive are frozen unless explicitly ordered; upload
  `data/curriculum/` only, bump `CACHE_VER`, redeploy as New version, record
  the batch (hub-project.md §4).
- Any rule that matters gets an automated gate in CI — an ungated rule **will**
  be silently violated (#24: speaker-pair rotation drifted over 10–20 days).

## 7. Deviation and quality policy

- A documented deviation is a **decision** (ASR cleanups, caps, accepted
  over-spec tables with pool justification, #12); an undocumented one is a
  **defect**. Disclose stand-ins and debt in the batch note (Batch 109).
- **A green validator is NOT a quality certificate** — every batch still gets
  a Human QA sample (Naturalness Ranking A/B/C/D, `natural-english.md`).

## Pre-publish checklist (copy into every hub batch)

- [ ] Quotes containment = 100% (modulo documented ASR cleanups); Sources =
      index verbatim; SRT present where the track requires it
- [ ] No `(ترجمة`, no empty cells, no Latin inside Arabic columns (modulo
      documented grammar-term exceptions); no draft residue (`؟`/`?`/stray
      tokens); no Key∩Expansion/Vocab headword overlap (re-checked after
      the last edit)
- [ ] Headings = current contract (post-Batch-111 names); `---` closers;
      Lesson Map precedes Mission where present
- [ ] Speaking task time = band time; `**Task:**` + `**Model Answer:**` present
- [ ] Index↔body titles/levels/missions aligned; every number carries its
      definition; no audio claims from text alone
- [ ] mirror → validate green → containment green; batch recorded;
      `git status` shows only intended files; live check before announcing
      state (version + two lessons, read-only)
- [ ] Renderer/parser change? Real on-screen sample rendered per touched
      track; no temp files left in the repo

(End of file)
