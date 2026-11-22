# Video Pedagogy — How to Build an 11-Section Video Lesson (v2.4)

Binding structure: `references/track-video.md` (section order, counts, validator ranges).
This file is the *method*: how to turn a YouTube video into that structure.
Gold standard: `curriculum/YouTube Lessons/lessons/Video01/lesson.md`
(Entra Join vs Hybrid Join vs Registered — Andy Malone, https://www.youtube.com/watch?v=2Tl09sXWG1w).

Goal: **teach the English required to understand and discuss the actual video**
— not "an English lesson about the video's topic."

> v2.4 quality upgrade (backward-compatible): the 11-section binding is
> unchanged — validator counts are identical. What changes is the *method
> inside* each section: source-fidelity labels, timestamped segment tasks,
> pronunciation features, pattern grammar notes, leveled speaking, active
> recall, and spaced review. All enrichment lives as prose/guidance inside
> the existing sections, never as new `###` sections or extra tables that
> would break `validate_track.py --track video`.

## 1. Source analysis (do first, keep short)

URL → title/channel/date → transcript (`.srt` saved next to `lesson.md`)
→ length → CEFR difficulty → IT topic → language extraction.

- 2–3 video days per week max; public YouTube IT video, clear audio.
- Preferred: 1–5 min segment. Long video (>10 min, e.g. Video01 ≈ 17 min):
  teach ONE segment only, name it in `Video Context`
  (Video01: "study it in two parts (join methods, then hybrid + registration),
  and replay the hard parts listed under Listening Notes").
- Never invent a URL. Verified link or no link (Sources text only — the
  builder `scripts/build_v3.py --track video` renders the Sources line
  verbatim and never invents an embed).
- Preserve product terms verbatim (Entra ID, Intune, Active Directory,
  BitLocker, group policy). Never simplify them for CEFR.

## 2. Vocabulary tiers — Must / Useful / Hear-only (see `vocabulary-priority.md`)

Classify BEFORE writing. Frequency alone does not determine value
(`Patreon` may repeat, zero study value; `source of authority` appears once,
critical).

- **Must know** (Video01: 14 rows — `device, enrollment, credentials, hybrid,
  registration, conditional access, single sign-on, group policy, configure,
  retire, wipe, sync, source of authority, registered`): without these the
  learner cannot follow the video. Fills the first table in
  `Key Words from the Video`.
- **Useful** (Video01: 20 rows — `Entra, Intune, method, pros, cons, confusion,
  demo, settings, multi-factor authentication, default, local administrator,
  BitLocker, restart, licensed, profile, organizational unit, update, authority,
  portal, partial wipe`): high work value, learn next. Second table.
- **Hear-only** (Video01: `episode, stay tuned, ring the bell, bomb that button,
  jibber-jabber, Patreon` + channel filler `stay tuned, ring the bell, bomb that
  button, without any more jibber-jabber, get those down below`): one line
  `You will also hear these - recognize them, do not study them: *...*`,
  never a Key row. Total Key tables: 25–75 rows (validator).

## 3. Authentic vs Generated — never mix (label them)

`Important Sentences from the Video` has 4 labelled tables (Video01 pattern)
plus a fixed source-label rule (3 labels, use exactly these words):

- **Authentic:** directly supported by the transcript (lightly cleaned for
  readability only — no word changes that alter meaning).
- **Lightly Edited:** a genuine spoken sentence with minor edits for
  readability (cut false starts, fix ASR errors). Preserve meaning, keep it
  in an Authentic table, and never silently rewrite it.
- **Generated Practice:** a new sentence created for learning. Never attribute
  it to the speaker; it lives only in Reusable/Work tables.

1. **Core sentences (authentic)** — 5 rows, his real lines lightly cleaned:
   `There seems to be a lot of confusion on which method to choose.`
   `Doing an Entra join is super simple.`
   `It is complete single sign-on, and Joni is good to go.`
2. **Practical steps (authentic — what he does on screen, phrased for study)** —
   3 rows: `Go into Intune and enable automatic enrollment to all.`
3. **Reusable patterns (take the chunk, change the words)** — 3 rows:
   `Make sure that MFA is set to yes.` →
   `Make sure that automatic enrollment is enabled.`
4. **Sentences for work** — 4 rows, new drill sentences for tomorrow:
   `I can retire the device from Intune.`

Never present a generated sentence as a quote. Never invent claims about what
the speaker said (Video QA gate).

## 4. The 11-section build order (Video01 gold values)

1. **Video Context**: `> Goal:` + 1–2 paragraphs (who/when/what/why) +
   segment note for long videos + 2 bullets of on-screen action
   (Video01: joins Win11 as Joni with SSO; domain controller syncs first).
2. **Key Words**: Must table + Useful table (`| Word / Phrase | AR | EN | Example |`)
   + hear-only line.
3. **Important Phrases**: 8–13 rows (`| English (Phrase) | العربية | Example |`)
   (Video01: 8 — `kick off, up to 50 devices, by default, in reality,
   a couple of minutes, source of authority, down below, pros and cons`)
   + channel-filler hear-only line.
4. **Important Sentences**: the 4 labelled tables above (5 + 3 + 3 + 4).
5. **Collocations**: 10–12 rows, prefer `verb + IT noun`
   (Video01: 10 — `join/assign/manage/retire/wipe/sync a device,
   configure hybrid join, update group policy, register a device,
   restart a machine`).
6. **Vocabulary Expansion**: 8–10 rows (`| Word | Arabic | Definition | Example |`)
   (Video01: 10 — `onboarding, writeback, BYOD, autopilot,
   mobile device management, domain controller, flavor, migration,
   work account, sign-in`).
7. **Listening Notes**: two tables — `**Traps ...:**` 5 rows + `**Hard terms ...:**`
   5 rows (`| Word / Phrase | العربية | How to catch it |`), each with a one-line
   pronunciation fix (Video01 traps: `pros and cons` blur, `source of authority`
   replay twice, `Entra ID` EN-tra I-D; hard: `hybrid, Joni, Contoso, Seattle,
   BitLocker`).
8. **Common English Patterns**: exactly 6 rows (Video01: `What are the pros and
   cons of ...? / Do I use X or Y? / Make sure that ... / You can't ... in ... /
   The reason for that is ... / What happens if ...?`).
9. **Workplace English**: 3–4 paragraphs of transfer prose on learner systems
   (Video01: 20 new laptops, check licenses, Entra join + Intune, hybrid during
   migration, per-user limit 20). Not a summary — a workplace task using the
   video's language.
10. **Speaking Practice**: `**Task:**` retell 60–90 s (CEFR time) +
    `**Model Answer:**` quoted answer reusing Must/Useful + patterns
    (Video01: Entra check → join → SSO → license → enroll → retire/wipe/sync →
    hybrid → registration).
11. **Final Recall**: 8–9 numbered Q + `> Answer:` (Video01: 8 — three methods,
    device-settings check, missing license, auto-enrollment, hybrid management,
    partial wipe, source of authority, why keep hybrid).

File ends with `---`. Every section except the goal line opens with `> Goal:`.

## 5. Listening layer (see `listening-system.md`)

1. Gist (no subtitles, Video Context first read): main idea?
2. Details (re-read Context bullets): what happens first, cause, fix?
3. Language (Key/Phrases/Sentences/Collocations): shadow 5–8 high-value sentences.
4. Recall (no notes, Speaking Practice): explain using extracted patterns.
Replay only the 1–2 hard passages named in Listening Notes.

### 5a. Segmented listening tasks (v2.4, inside existing sections)

For videos with clear topic shifts or timestamps, distribute the segment
workflow across the sections you already have — do NOT create new sections:

- **Video Context:** list 2–4 segments as bullets with timestamp ranges when
  available (`00:00–02:10 Setup`), each with a one-line main idea. Name the
  ONE taught segment for long videos (>10 min).
- **Listening Notes:** for each taught segment add a compact 4-line task block
  as prose (not a table, so counts never change):
  `Gist (1 Q) → Specific info (1–2 Q) → Language recognition (quote 1 chunk,
  ask the learner to catch it while listening) → Segment recall (say it in
  your own words, 1–2 sentences).`
- **Transcript check:** after the tasks, quote the short relevant excerpt
  (1–3 lines, Authentic) with the key chunk **bolded**. If only text was
  supplied and no audio was heard, state explicitly: "pronunciation analysis
  needs the audio — transcript-based guidance only."
- Never invent timestamps, transcript lines, or pronunciation claims. Missing
  or corrupted transcript → state the limitation, teach the verified part only.

### 5b. Pronunciation inside Listening Notes (v2.4)

Each Traps/Hard-terms row's `How to catch it` cell must name ONE spoken
feature in plain words: word stress (`PROS and CONS`), sentence stress,
connected speech / reductions (`going to → gonna`, `want to → wanna`),
difficult consonant/vowel, similar-sounding pair
(`enrollment vs registration`, `retire vs wipe`), or acronym spoken form
(`Entra I-D`, `M-F-A`). No invented IPA, no claim about the speaker's accent
without audio evidence. Prioritize features that block comprehension.

## 6. Transfer, not summary

Speaking + Workplace English move the video's language to the learner's world
(`profile.md`; e.g. Intune, Zabbix, Veeam, FortiGate): explain the same process
on the learner's systems, or solve a similar ticket.

### 6a. Pattern grammar + active practice + retention (v2.4, inside existing sections)

- **Common English Patterns (exactly 6 rows, table unchanged):** under the
  table add 1–2 lines per pattern as prose: original sentence → simple English
  explanation → Arabic meaning → 2 new IT examples. End the section with ONE
  short micro-task line (e.g. "Rewrite 2 sentences with `Make sure that ...`").
  Grammar serves the video only — never a general textbook topic.
- **Speaking Practice (Task + Model Answer required, prose may grow):** offer
  5 rungs as a short numbered prose list before the Model Answer —
  1 Controlled (complete 3 sentence halves) → 2 Guided (answer 2 content Qs
  with starters) → 3 Retell (60–90 s, CEFR time) → 4 Workplace transfer (same
  idea on learner systems) → 5 Independent (no notes). The quoted Model Answer
  stays ONE reference answer, labelled generated — never to be memorized.
- **Final Recall (8–9 numbered Q/A required, prose may grow):** keep the 8–9
  `> Answer:` items, then append as prose: (a) 3–5 active-use micro-exercises
  with a separate mini answer key (match / fill / choose / rewrite / complete
  a dialogue — video vocabulary only), (b) a 5–10 item high-value review box
  (words + expressions + sentences), (c) a spaced-review line:
  `Day 1 → Day 3 → Day 7 → Day 14`. Do not assess facts outside the video.
- **Workplace English:** label the prose transfer (`Generated Workplace
  Practice`). After it, add 2–3 bullet lines naming the most reusable sentences
  and where to reuse them (ticket / meeting / email).

## Video QA (before claiming done)

- [ ] Source authentic, URL verified, segment named if long; `.srt` saved.
- [ ] Must/Useful/Hear-only classified; Key total 25–75; hear-only never a Key row.
- [ ] Authentic vs Generated separated into the 4 labelled sentence tables.
- [ ] Phrases 8–13 + filler line; Collocations 10–12 (`verb + IT noun`);
  Expansion 8–10; Patterns exactly 6; Recall 8–9 Q/A.
- [ ] Listening Notes has **Traps** + **Hard terms** tables, 2–5 traps max,
  each with a one-line fix; no invented traps. v2.4: segment task blocks
  (gist / specific / recognition / recall) present as prose when timestamps
  exist; each fix names one spoken feature; transcript excerpts short + bolded.
- [ ] Technical terms preserved verbatim; no invented quotes or claims.
  v2.4 source labels used exactly (Authentic / Lightly Edited / Generated
  Practice); Arabic translations contextual, not literal.
- [ ] Patterns section ends with 1 micro-task; Speaking offers 5 rungs;
  Final Recall appends active exercises + review box + Day 1/3/7/14 line —
  all as prose, counts unchanged (Patterns 6, Recall 8–9).
- [ ] `validate_track.py --track video` passes; `build_v3.py --track video`
  renders standalone + aggregated HTML (V3 shell r2, TTS `data-say`).
