# Locked Lesson Template — `.md` Source Format (Binding)

Every file `<workspace>/curriculum/day-NNN/lesson.md` MUST match this skeleton exactly.
Master copy: `references/template-md-reference.md` (same structure, worked IT example).
Domain content (names, systems, numbers) always comes from `<workspace>/profile.md`.

```markdown
## Day NNN: Title Here
**Level:** A1 | **Speaking:** 30 seconds | **Output:** one-goal phrase

### 1. Mission
One "I can..." paragraph = the single goal of the day.

### 2. Real IT Situation
> Goal: Understand the real work situation for this lesson.

| English | الترجمة العربية |
|---|---|
| 2-4 sentence workplace scenario. | الترجمة العربية الكاملة. |

### 3. Key Language
> Goal: Learn the 10 key words and use them in your sentences.
| Word / Phrase | AR | EN | Example |
|---|---|---|---|
... 10 rows exactly ...

### 4. Vocabulary
> Goal: Learn 10 more words about the same topic.
| Word | Arabic | Definition | Example |
|---|---|---|---|
... 10 rows exactly ...

### 5. Useful Sentences
> Goal: Practice 10 ready sentences for work.
| English | الترجمة العربية |
|---|---|
... 10 rows exactly ...

### 6. Collocations
> Goal: Learn 10 fixed phrases that sound natural.
| English (Collocation) | العربية | Example |
|---|---|---|
... 10 rows exactly ...

### 7. Dialogue
> Goal: Read the dialogue aloud, play both roles, then answer the questions.

| English | العربية |
|---|---|
... exactly 10 turns, alternating speakers ...

**Comprehension:** 1) ...? 2) ...? 3) ...?
### 8. Grammar in Context: FOCUS NAME
> Goal: Learn the rule from lesson examples, then do the practice.

- **Bold form** rule/example. (4 bullets)
- ...
**Practice:**
1. Controlled item.
2. Personalized item.
3. Question item.

### 9. Speaking (TIME)
> Goal: Read the task, study the model answer, then speak for TIME.

**Task:** One speaking task on the same topic, different modality from writing.

**Reference Answer (TIME):**
"Quoted model answer, 5-9 sentences, built only from this lesson's language."

### 10. Real IT Task
> Goal: Write a real work message, then compare it with the model.

| English (Task / Solution) | الترجمة العربية / الحل |
|---|---|
| **Task:** ... | **المهمة:** ... |
| **Reference Message (Solution):** "3+ sentence real message." | **الرسالة المرجعية (الحل):** "الترجمة." |

### 11. Common Errors
> Goal: Avoid these 5 common mistakes.

1. ❌ wrong. ✅ correct. (5 items, banked per month, never repeated within a month)
... 5 items ...

### 12. Quick Check
> Goal: Answer 5 questions and confirm you mastered the lesson.

1. Task or question. (5 items)
... 5 items ...

---
```

## Rules

- Section numbers are fixed sequential `1–12` in the order above. Never renumber, never skip, never add sections.
- Every section except §1 opens with a one-line `> Goal:` callout telling the learner what to do.
- File ends with `---` on its own line. Meta line format: `**Level:** X | **Speaking:** Y | **Output:** Z` (parser reads it — keep the exact labels). `## Day NNN:` matches the filename.
- Dialogue speakers alternate (Manager/Tech default; see `scenarios.md` for rotation). Arabic role names match (`**المدير:**` / `**الفني:**`, or the rotated pair's names).
- Speaking (§9) comes as Task first, then Reference Answer. Writing (§10) is a different modality/audience on the same topic (speak vs write, team vs manager).
- Real IT Task is the performance climax: rotate Teams/Email/Ticket across days. It sits at
  §10 by design, closed by §11 + §12 (the old must-be-last rule is cancelled).
- Every word in §3/§4 MUST appear in a §5 sentence, §6 chunk, §7 turn, or §10 message (no orphan words to hit a number).
