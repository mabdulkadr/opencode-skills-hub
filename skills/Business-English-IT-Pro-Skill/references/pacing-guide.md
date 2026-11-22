# Pacing Guide — Adaptive Rhythm, Review, and Acceleration (v3.1)

The 180-day curriculum follows a structured progression, but real workplace learners do not learn at a strictly uniform speed. This guide defines how to adapt lesson pacing, keep review alive, handle retries, and accelerate when appropriate without breaking the locked section contract.

---

## 1. Adaptive Review — inside real lessons (no standalone review days)

Standalone review days are **cancelled** (no Review/Simulation/Gate/Summit/
Project days anywhere — `natural-english.md` §5). Review instead lives at two
mandatory, always-on layers:

- **In-lesson review:** the day's Quick Check and role-play re-appear items
  from the previous 4–5 days that need reinforcement (spaced reuse ladder
  +3/+7/+14/+30 in `language-system.md` §2), inside a NEW day's real
  workplace situation — never a `.md` containing only repeats.
- **Adaptive review day equivalent:** when a learner demonstrates hesitation
  or vocabulary overload, the NEXT scheduled day regenerates
  (`new_lesson.py --day N --force`) keeping its own new lesson topic while
  loading §5/§8/role-play with the struggling items in a novel context.
  Sequence stays strictly `day-001` through `day-180` — no extra days, no
  review-only files.

---

## 2. Retry Day Protocol (Handling Core Gaps)

If the learner scores ≤2 out of 5 on §12 Quick Check or expresses lack of confidence in the day's communicative outcome:

### Protocol:
1. **Never create branch filenames:** Do not create `day-014-retry.md` or sub-days. The workspace sequence remains strictly `day-001` through `day-180`.
2. **Immediate targeted coaching:** Provide targeted drill in chat on the missed items.
3. **Regenerate / Alternate Lesson option:** If a full repeat is requested, rewrite the day's file (`new_lesson.py --day N --force`) keeping the target vocabulary and grammar focus, but shifting the scenario and dialogue to an alternate speaker pair from `scenarios.md`.

---

## 3. Acceleration Criteria (Moving Faster Safely)

Learners with prior English exposure may move through A1 (Days 001–020) quickly.

### Criteria to Accelerate:
- Consistent 5/5 on §12 Quick Check over 5 consecutive days.
- Fluent production of §9 Speaking task within the time target without reading the model answer.
- Accurate writing in §10 Real IT Task with zero critical grammar errors.

### How to Accelerate:
- Proceed directly to the weekly output or mini-project challenge day.
- Do not skip the mini-projects (Days 030, 060, 090, 120, 150, 180) — these are the objective checkpoints that validate moving to the next CEFR band.

---

## 4. Workload Balancing (Preventing Burnout)

| Day Type | Estimated Learner Time | Cognitive Load | Frequency |
|---|---|---|---|
| **Core Lesson (AI Topic)** | 20–25 minutes | Medium | 3–4× per week |
| **Video Day** | 25–35 minutes | High (Listening + Accents) | 2× per week max |
| **Article Day** | 25–30 minutes | High (Technical Reading) | 1–2× per week max |
| **Weekly Review / Transfer** | 15–20 minutes | Medium-Low | Every 7th day |
| **Monthly Mini-Project** | 35–45 minutes | Climax Performance | Day 030, 060, ... |

Never schedule two video days back-to-back. Balance intense input days (Video/Article) with consolidated core days.
