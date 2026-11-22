# Natural English System — Locked Rules (v2.7)

> Derived from the "Natural English Curriculum Designer" prompt + the full audit
> behind `IMPROVEMENT-PLAN-v2.md` (Tech-English-Hub). Binding for every lesson
> written or rewritten on ANY track (core / video / article / legacy).
> The internal quality reference is the clean C1 range of the real published
> Core curriculum. Write to that standard everywhere.

## 1. Core principle — natural beats perfect

Write English that sounds like a real person speaking/writing to another real
person. The learner must feel: "I could hear someone say this at work."

Priority order when choosing ANY example:
1. Natural usage → 2. Frequency → 3. Real-world context → 4. Clarity →
5. Grammar → 6. Formality.

Never prefer a sophisticated synonym just to look advanced. `Can you check
this?` beats `Could you kindly investigate this matter?` unless the formal
register is genuinely required by the situation.

## 2. The Naturalness Gate — 12 rules (machine-checkable where marked)

1. **Collocation = natural usable chunk + natural contextual example** — the
   chunk itself may be short (`look into it`, `take a look`, `keep me posted`,
   `back up the server`) — that is healthy English, not a defect. The
   requirement is on the EXAMPLE: a full natural sentence, 6–20 words
   (`look into it` → "I'll look into it and get back to you.").
   Forbidden: telegraphic fragments (`Tended repeat.` / `Wins name.` /
   `Specifics beat.`) and artificially inflating the chunk into a long sentence.
2. Useful Sentences = full, meaningful sentences (subject + verb). Guidance
   minimum: B1 ≥ 6 words · B2 ≥ 8 · C1/C2 ≥ 10 — **naturalness beats length**:
   a natural short expression (`I'm on it.`) is accepted as a standalone
   tagged item; band average 12–24 words. (Band cap still applies — when cap
   and minimum conflict, lower the example's difficulty, not its
   completeness.)
3. `whereas` always connects two full clauses with two subjects. Forbidden:
   `Whereas promises stability, promises revenue.` Model: `Whereas delivery
   landed green, nights suffered.`
4. No formulaic signoff signatures (`Roled, hedged, clocked.` /
   `Thank you. Credited, totalled, owned.`). Replace each with one short FULL
   natural sentence.
5. Key/Vocab `EN` column = a short real dictionary definition, not a meta-gloss.
   Model: `disclose = to reveal formally in writing`. Forbidden:
   `green = success color`, `midnight = page hours`.
6. No repeated headword inside Key on the same day; zero Key ∩ Vocab overlap
   (§4 is expansion, never repeats §3).
7. Last human filter per batch: "Would a real engineer say this in a meeting?"
8. **No AI-pattern sentences** (blacklist — machine filter): `Would you kindly…`,
   `Please be advised…`, `It is important to note…`, `I would like to inform
   you…`, `Kindly investigate this matter`, `I would appreciate it if…`,
   `I am writing to…` (except real cover-letter days). Replace with the natural
   equivalent of the same function. The blacklist is append-only and lives with
   the validator.
9. **Anti-pattern-repetition:** within one lesson, no opening pattern may start
   >30% of the examples of one section (machine: first two words of each
   example). Don't start everything with `I…`; don't make every request
   `Could you please…`.
10. **Register tagging:** every key expression ships with 3–5 realistic
    variations across registers when that exists:
    casual (`Hang on a second.`) · neutral (`Give me a minute.`) ·
    professional (`Give me a moment.`). Never force a formal/business version
    of everything; explain WHEN/WHY each variant is used, don't list them as
    interchangeable.
11. **Spoken forms labelled only:** `gonna`, `gotta`, `lemme`, `kind of`,
    `you know` may appear ONLY with an explicit `[spoken/informal]` tag and
    never inside written-form examples (messages, tables).
12. **Function memory:** every lesson teaches language tied to one observable
    communicative task (ask for a check, give a status update, disagree
    politely) — the day's Mission names what the learner can DO.

## 2b. Naturalness Ranking (A/B/C/D — human/agent review, logged per wave)

The blacklist is only the first line of defense. A sentence outside the
blacklist is NOT automatically natural.

| Rank | Meaning | Curriculum use |
|---|---|---|
| **A** | Very natural / common | Yes — main examples |
| **B** | Natural but context-dependent | Yes — with context explained |
| **C** | Correct but less common | Only as contrast/variation teaching, never as a model |
| **D** | Awkward / avoid | Forbidden — remove (this is what human review catches that the machine cannot) |

## 2c. Quality model — Machine QA + Human QA (never Machine alone)

The validator green does NOT certify Naturalness. Two layers, both required:

- **Machine QA (automated):** sentence completeness/length, duplication,
  forbidden patterns, broken clauses, register/spoken labels present,
  source-integrity labels, counts/structure.
- **Human QA (reviewer/agent judgment):** naturalness · idiomaticity ·
  contextual appropriateness · technical realism · conversational realism ·
  final A/B ranking.

Every batch definition-of-done = Machine QA pass + Human QA sample pass with
ranking documented.

## 3. Language-design principles (binding for writing/rewriting)

1. **Authenticity over perfection** — see §1 priority order.
2. **Collocations are chunks, not lists** — teach as usable units (`take a
   look`, `look into it`, `get back to you`, `keep me posted`, `sort it out`,
   `be back up`); each example shows WHEN it's said, to WHOM, and WHY.
3. **Vocabulary entry depth** — every key word gets: dictionary meaning +
   natural example + work example + common collocations + common alternatives
   + register. (Keep simple frequent words like `check` — never upgrade them
   to exotic synonyms.)
4. **Variations are explained, not equated** — differences in tone/context/
   naturalness must be taught.
5. **Natural environments** — settings matter (chat vs meeting vs email);
   the same function changes wording by medium.
6. **Natural repetition is fine** — repetition of useful language (`check`,
   `I'm on it`) across days/lessons is legitimate English, not a defect.
   Do NOT vary vocabulary artificially just to avoid repetition. Only ban
   mechanical repetition (same 10 sentences verbatim across days).
7. **Per-sentence filter before freezing** — for each sentence: Natural? ·
   Useful (memorize-worthy)? · Contextual? · Common enough? · Right register?
   · Is there a shorter/more common alternative? Any "no" → rewrite or drop.

## 3b. Language Source Hierarchy (golden rule — the curriculum's language is never just invented)

1. **Tier 1 — Authentic source language preferred** whenever available (real
   videos, interviews, Teams meetings, podcasts, workplace transcripts) —
   labelled Authentic.
2. **Tier 2 — Corpus-supported English** for general expressions: common,
   corpus-attested collocations and phrasing.
3. **Tier 3 — Human-reviewed generated English:** AI may create new examples
   only when no suitable one exists, always labelled Generated Practice, and
   subject to human review.
4. **Tier 4 — AI-only invented English:** never enters the curriculum without
   human verification of frequency and naturalness.
5. A grammatically correct sentence is not automatically natural.
6. Human review is required for naturalness, idiomaticity, register, and
   contextual realism — a green validator is not a naturalness certificate.
7. Prefer frequently-used simple English over artificially sophisticated
   alternatives.
8. Repetition of high-frequency language is allowed and encouraged when it
   reflects real usage.

## 3c. Situation domains (the learner is a person, not only an engineer)

Every lesson = one REAL communicative situation — its domain is **IT**,
**general Workplace**, or **Daily Life** according to the lesson's goal.
Not an IT-vocabulary course: an IT professional as a real person.
Examples: IT ("The server is down.") · Workplace ("Do you have a minute?") ·
Daily life ("What time does the bus leave?") · Social ("How was your
weekend?"). Balance is tracked per track/plan; avoid runs of 4+ consecutive
lessons in the same domain within the same band.

## 4. Realistic dialogue rules (role-play / dialogue sections — binding)

Real conversations are not textbook conversations. Allowed and encouraged:
short answers · contractions · repetition · clarification · correction ·
hesitation markers (`Yeah.` `Right.` `Exactly.` `Actually…` `I mean…`) ·
clarification probes (`Sorry?` `What do you mean?` `You mean…?`) — but not
overused.

- FORBIDDEN (textbook): balanced, fully-formal exchanges like
  `A: Would you please explain the issue? B: Certainly. I would be happy to
  explain it.`
- TARGET: uneven, natural, functional —
  `A: Hey, do you have a minute? B: Sure. What's up? A: I'm having trouble
  connecting to the VPN. B: Since when? A: Since this morning. B: Okay. Let me
  take a look.`
- Character variety: rotate pairs by name/role/gender (engineer + CTO,
  support + client, finance + manager…). Never let the same pair repeat more
  than 3 consecutive lessons.
- Source fidelity (video/article tracks): label content as AUTHENTIC /
  NATURAL VARIATION / GENERATED PRACTICE. Never present generated sentences
  as things the speaker said.

## 5. Curriculum policy (locked, from the owner decision)

- **Cancel review DAYS, never review:** no standalone weekly/monthly review
  days, no simulations, Gates/Summits, or project days anywhere on any track.
  Review itself is mandatory INSIDE every lesson: in-lesson reuse (§2 of
  `language-system.md`), spaced cross-lesson reuse (+3/+10/+30), and a Quick
  Check that recycles earlier days' words. The consolidation job the review
  days used to do moves into the real lessons.
- Definition of Done for the curriculum = Machine QA green + Human QA sample
  pass (Naturalness Ranking documented): zero telegraphic examples, zero
  broken `whereas`, zero signoff signatures, zero AI-pattern sentences,
   dictionary-quality definitions — at the standard of the published Core's
   clean C1 range.
