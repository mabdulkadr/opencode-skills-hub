# Language System — Minimums, Recycling, Grammar, Arabic (v3.1)

## 1. Daily minimums (locked, every file)

Core deck counts (Tech English Core, 8-day section track): Key Language
12–15 · Vocabulary 15–20 · Useful Sentences 25 · Collocations 12–15 ·
Common Errors 8–10 · Situation 1 · Workplace prose 400+ words from B2 up ·
media link tracks keep their own binding counts (`track-video.md`,
`track-article.md`). Legacy deck: 10/10/10/10 · Dialogue 10 · Errors 5 ·
Quick 5 · message 5+ sentences. No orphan words: every §3/§4 item MUST be
used in §5, §6, §7, or §10.

## 2. Reuse engine + mandatory review (locked)

No standalone review days exist or are allowed — review itself is mandatory
INSIDE every lesson. Retention is structural:
- Every §3/§4 word is reused inside the same lesson (§5 sentence, §6 chunk,
  §7 turn, or §10 message / §8 prose).
- Key (§3, productive core) never repeats inside Vocabulary (§4, expansion)
  of the same day.
- Cross-lesson spaced reuse ladder (recommended, never a new section):

```text
Introduce → Reuse (+3 days) → Reuse in different context (+7)
→ Contrast (+14) → Free production (+30)
```

Example: `configure` — Day 020 `configure a device` → Day 031
`configure Intune` → Day 048 `configure a policy` → Day 075
`configure conditional access`. Prefer `verb + IT noun` growth
(`enroll a device` → `enroll users` → `automatic enrollment` →
`enrollment restrictions`) over repeating the same sentence. Domain priority:
General → Workplace → IT → Infrastructure → Microsoft/Intune/Entra/PowerShell.
Do not add a Recycling/Review section to any file; do not create review days.

## 3. Grammar spine (serves the situation, never isolated) — v3 B1→C2

Bands (locked for all new workspace work): B1 Days 001–030 → B2 031–090 →
C1 091–150 → C2 151–180. (The live hub curriculum v10 is narrower: Core 120
at B2 001–090 → C1 091–120 per `data/curriculum/config.json`; workspace bands
above still govern new standalone workspaces.)
Legacy A1/A2 workspaces stay valid but are no longer generated (backward
compat only — see `lesson-template.md`).

Month grammar map v3: M1 B1 fluency (complex sentences, linkers,
Past vs Present Perfect, polite requests) → M2 B2 incidents (passive,
conditionals I/II, modals of deduction, reported-speech intro) → M3 B2 docs
(sequencers + nominalization intro + versioning language) → M4 C1 meetings
(hedging, concession `although/despite/whereas`, unreal past, diplomacy) →
M5 C1 architecture (nominalization, mixed conditionals, cause→mitigation
chains, stance markers) → M6 C2 leadership (thesis→antithesis→synthesis,
executive summary, BATNA framing, irony-free nuance).

B1 entry floor (Days 001–030): multi-clause sentences expected from Day 001;
no single-clause-only days. C1+ hard requirement: every day carries 3+ hedging
devices and 1 concession structure in §5/§8/Workplace prose; every C day also
lands one decision + one handled objection + one dated commitment (argument
ladder). Whereas always connects two full clauses with two subjects.
Teach the point because the day's task needs it (post-mortem → past perfect +
blameless passive; ADR → conditionals + stance), never as theory.

## 4. Arabic taper (locked, B1→C2)

Keep every Arabic column (the parser reads them), but taper depth by band:
B1 full but concise · B2 English-first with one-line glosses ·
C1/C2 English-first, Arabic gloss for hard terms only.
No placeholders (`ترجمة`), no English sentences inside Arabic cells except product names
(Intune, Zabbix, SharePoint). Complexity grows through longer English sentences
and structures (B1 ≤18 → B2 ≤22 → C1 ≤26 → C2 ≤30 words), not by dropping columns.

## 5. Terminology lock (use exactly these names, no synonyms)

Key Language · Vocabulary · Useful Sentences · Collocations ·
Dialogue · Grammar in Context · Speaking · Real IT Task · Common Errors · Quick Check.
Never `Target Words`, `New Words`, `Chunks`, `Quiz` for the same concepts.
No `(Full Text)`, `(Bilingual)`, `(10 turns)` parentheticals in titles or table
headers — write `| English |`, `### 6. Collocations`, `### 7. Dialogue`.

## 6. Naturalness (locked — binds ALL tracks)

`references/natural-english.md` is binding for every lesson on every track:
the 12-rule Naturalness Gate (full-sentence examples with short-chunk
exemption, no AI-pattern sentences, register-tagged variations, labelled
spoken forms, dictionary definitions), Naturalness Ranking A/B/C/D, the
Machine QA + Human QA split (validator green ≠ naturalness certificate), the
Language Source Hierarchy (authentic → corpus-supported → human-reviewed
generated; AI never invents curriculum language), IT + Workplace + Daily Life
situation domains, the language-design principles (authenticity over
perfection, chunks, explained variants), the realistic-dialogue rules, and
the cancel-review-DAYS policy (review itself mandatory inside every lesson
 via spaced reuse + Quick Check). Quality anchor: the clean C1 range of the
 published Core curriculum, everywhere. In the hub repo the machine layer runs via
`node scripts/validate.js` (language reports) + `audit-language.ps1`.
