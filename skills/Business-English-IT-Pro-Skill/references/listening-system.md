# Listening System — Video Track (v2.4)

Maps a listening workflow onto the 11 video sections
(Video Context → Key Words → Sentences → Listening Notes → Speaking Practice).
Gold standard: Video01 (Entra Join).

> v2.4: adds timestamped segment tasks, transcript-check rule, and the
> pronunciation feature list. Section binding unchanged — all of this lives
> inside Video Context (segments) + Listening Notes (tasks + traps) as prose.

## The layers (one video segment, 1–5 min; long videos split, Video01: two parts)

- **Before listening (Video Context first read):** gist — what the video is
  about, why it matters at work. No vocabulary study yet.
- **First listen (Context bullets, no subtitles):** main idea only.
  Question: "What problem does the speaker solve?"
- **Second listen (Key Words Must table):** Tier 1 words only.
  Task: spot the Must-Know terms in the stream.
- **Third listen (Phrases/Sentences/Collocations):** chunks and reusable
  patterns, not isolated words. Task: shadow 5–8 high-value sentences.
- **Replay:** re-play only the 1–2 hard passages named in Listening Notes.
- **Retell (Speaking Practice, no notes):** explain the video in the track's
  CEFR time (A1 30s → A2 60s → B1 90s → B2 2 min). B2 adds: explain + compare +
  example + opinion on the technical choice.

## Listening Notes (dedicated section, two tables)

`Listening Notes` is a standalone section with `**Traps ...:**` + `**Hard terms
...:**` tables (`| Word / Phrase | العربية | How to catch it |`), each row a
one-line fix. Video01: 5 traps (`pros and cons` blur, `source of authority`
replay twice, `Entra ID` EN-tra I-D, `single sign-on` three beats,
`automatic enrollment` listen for ENROLL) + 5 hard terms
(`hybrid, Joni, Contoso, Seattle, BitLocker`). 2–5 genuine traps; never invent.

General fast speech:

```text
pros and cons → heard as one blur; stress PROS and CONS
going to → gonna
want to → wanna
What are the... → compressed in natural speech
```

IT terms that confuse the ear:

```text
Entra ID / Active Directory / single sign-on
group policy / automatic enrollment / conditional access
enrollment vs registration (different steps, similar sound)
retire vs wipe (both remove, different severity)
```

Format: `form → what you hear → one-line fix`. If the video has no real trap,
keep the tables minimal — do not invent traps.

### v2.4 segment task template (prose inside Listening Notes, per taught segment)

```text
Segment N — Title (MM:SS–MM:SS): 1-line main idea.
Gist: 1 Q (general meaning, no transcript).
Specific: 1–2 Qs (terms, roles, actions, cause/fix).
Recognition: quote 1 authentic chunk — "catch it while listening".
Transcript check: 1–3 authentic lines, key chunk **bolded**.
Analysis: 1 line — the one spoken feature that blocks understanding.
Recall: say the segment in your own words (1–2 sentences).
```

Rules: timestamps only when reliable; transcript excerpts only from the real
`.srt`; audio-only claims (stress, reductions, accent) only when audio was
heard — otherwise write "transcript-based guidance only". Corrupt/missing
transcript → state the gap, teach the verified part, never reconstruct speech.

### v2.4 pronunciation feature checklist (pick ONE per row)

Word stress · sentence stress · connected speech · reductions
(`gonna/wanna`) · contractions · difficult consonant/vowel ·
similar-sounding pair (`enrollment/registration`, `retire/wipe`) ·
acronym spoken form (`I-D`, `M-F-A`). No invented IPA. Comprehension first:
prefer the feature that actually stops the learner hearing the word.

## CEFR adaptation (same video, different language)

Same technical content, graded language:

- B1: `Hybrid join connects the device to both on-premises Active Directory
  and Microsoft Entra ID.`
- B2: `Hybrid Microsoft Entra join allows organizations to maintain their
  existing on-premises identity infrastructure while extending device
  management capabilities to the cloud.`

Difficulty grows through sentence length/structures (A1 ≤12 → B2 ≤20 words),
never by simplifying product terms.

## Arabic policy (locked taper, applied)

- A1/A2: full Arabic (meaning + explanation).
- B1: Arabic for vocabulary meaning + hard concepts; guidance in English
  (Video01 pattern).
- B2: English-first; Arabic gloss for hard terms only. Columns always present.
