#!/usr/bin/env python3
"""Scaffold a lesson skeleton (v2.0 multi-track).

Tracks:
  mastery (default, legacy v1.x): <root>/curriculum/day-NNN/lesson.md, 12 locked
      sections (references/lesson-template.md). Kept for backward compat.
  mastery-v3: same path, 8-section Core format (references/track-mastery.md).
      Use --track mastery-v3 (or mastery with --v3) for the published design.
  video:   <root>/lessons/VideoNN/lesson.md, 11 sections (references/track-video.md).
  article: <root>/lessons/ArticleNN/lesson.md, 11 sections (references/track-article.md).

Usage:
  python scripts/new_lesson.py --root ./my-curriculum --day 42 --title "Handle Shift Handover"
  python scripts/new_lesson.py --root ./my-curriculum --next
  python scripts/new_lesson.py --root ./yt --track video --next --title "Entra Join Explained" --url "https://www.youtube.com/watch?v=..."
  python scripts/new_lesson.py --root ./art --track article --next --title "Bulk Enrollment" --url "https://..."
  python scripts/new_lesson.py --root ./my-curriculum --track mastery-v3 --day 1 --title "..."

Skeletons carry TODOs with exact table counts per track spec. Replace every
TODO (grounded in <root>/profile.md) before validation.
"""
import argparse
import json
import sys
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent


def resolve_root(explicit: str | None) -> Path:
    if explicit:
        return Path(explicit)
    cwd = Path.cwd()
    if (cwd / "curriculum.json").exists() or (cwd / "curriculum").exists():
        return cwd
    raise SystemExit("Not a workspace (no curriculum.json or curriculum/ here). "
                     "Pass --root <workspace>.")


def workspace_days(root: Path) -> int:
    mf = root / "curriculum.json"
    if mf.exists():
        try:
            return int(json.loads(mf.read_text(encoding="utf-8")).get("days", 180))
        except (ValueError, TypeError):
            pass
    return 180


def level_for(day: int) -> str:
    if day <= 20:
        return "A1"
    if day <= 60:
        return "A2"
    if day <= 90:
        return "B1"
    return "B2"


def speaking_for(day: int) -> str:
    if day <= 20:
        return "30 seconds"
    if day <= 60:
        return "60 seconds"
    if day <= 90:
        return "90 seconds"
    return "2 minutes"


TEMPLATE = """## Day {day:03d}: {title}
**Level:** {level} | **Speaking:** {speaking} | **Output:** {output}

### 1. Mission
By the end of this lesson, I can {mission}.

### 2. Real IT Situation
> Goal: Understand the real work situation for this lesson.

| English | الترجمة العربية |
|---|---|
| TODO: 2-4 sentence workplace scenario with names, numbers, time (from profile.md). | TODO: الترجمة العربية الكاملة. |

### 3. Key Language
> Goal: Learn the 10 key words and use them in your sentences.

| Word / Phrase | AR | EN | Example |
|---|---|---|---|
| word01 | كلمة01 | definition | Example sentence. |
| word02 | كلمة02 | definition | Example sentence. |
| word03 | كلمة03 | definition | Example sentence. |
| word04 | كلمة04 | definition | Example sentence. |
| word05 | كلمة05 | definition | Example sentence. |
| word06 | كلمة06 | definition | Example sentence. |
| word07 | كلمة07 | definition | Example sentence. |
| word08 | كلمة08 | definition | Example sentence. |
| word09 | كلمة09 | definition | Example sentence. |
| word10 | كلمة10 | definition | Example sentence. |

### 4. Vocabulary
> Goal: Learn 10 more words about the same topic.

| Word | Arabic | Definition | Example |
|---|---|---|---|
| vocab01 | مفردة01 | definition | Example sentence. |
| vocab02 | مفردة02 | definition | Example sentence. |
| vocab03 | مفردة03 | definition | Example sentence. |
| vocab04 | مفردة04 | definition | Example sentence. |
| vocab05 | مفردة05 | definition | Example sentence. |
| vocab06 | مفردة06 | definition | Example sentence. |
| vocab07 | مفردة07 | definition | Example sentence. |
| vocab08 | مفردة08 | definition | Example sentence. |
| vocab09 | مفردة09 | definition | Example sentence. |
| vocab10 | مفردة10 | definition | Example sentence. |

### 5. Useful Sentences
> Goal: Practice 10 ready sentences for work.

| English | الترجمة العربية |
|---|---|
| Sentence 01. | جملة 01. |
| Sentence 02. | جملة 02. |
| Sentence 03. | جملة 03. |
| Sentence 04. | جملة 04. |
| Sentence 05. | جملة 05. |
| Sentence 06. | جملة 06. |
| Sentence 07. | جملة 07. |
| Sentence 08. | جملة 08. |
| Sentence 09. | جملة 09. |
| Sentence 10. | جملة 10. |

### 6. Collocations
> Goal: Learn 10 fixed phrases that sound natural.

| English (Collocation) | العربية | Example |
|---|---|---|
| collocation 01 | ترجمة 01 | Example. |
| collocation 02 | ترجمة 02 | Example. |
| collocation 03 | ترجمة 03 | Example. |
| collocation 04 | ترجمة 04 | Example. |
| collocation 05 | ترجمة 05 | Example. |
| collocation 06 | ترجمة 06 | Example. |
| collocation 07 | ترجمة 07 | Example. |
| collocation 08 | ترجمة 08 | Example. |
| collocation 09 | ترجمة 09 | Example. |
| collocation 10 | ترجمة 10 | Example. |

### 7. Dialogue
> Goal: Read the dialogue aloud, play both roles, then answer the questions.

| English | العربية |
|---|---|
| **Speaker A:** Sentence 01. | **المتحدث أ:** جملة 01. |
| **Speaker B:** Sentence 02. | **المتحدث ب:** جملة 02. |
| **Speaker A:** Sentence 03. | **المتحدث أ:** جملة 03. |
| **Speaker B:** Sentence 04. | **المتحدث ب:** جملة 04. |
| **Speaker A:** Sentence 05. | **المتحدث أ:** جملة 05. |
| **Speaker B:** Sentence 06. | **المتحدث ب:** جملة 06. |
| **Speaker A:** Sentence 07. | **المتحدث أ:** جملة 07. |
| **Speaker B:** Sentence 08. | **المتحدث ب:** جملة 08. |
| **Speaker A:** Sentence 09. | **المتحدث أ:** جملة 09. |
| **Speaker B:** Sentence 10. | **المتحدث ب:** جملة 10. |

**Comprehension:** 1) Question 01? 2) Question 02? 3) Question 03?
### 8. Grammar in Context: TODO FOCUS
> Goal: Learn the rule from lesson examples, then do the practice.

- **Form 01** example.
- **Form 02** example.
- **Form 03** example.
- **Form 04** example.

**Practice:**
1. Controlled item.
2. Personalized item.
3. Question item.

### 9. Speaking ({speaking})
> Goal: Read the task, study the model answer, then speak for {speaking}.

**Task:** TODO speaking task (same topic, different modality from writing).

**Reference Answer ({speaking}):**
"TODO model answer - 5-9 sentences, built only from this lesson's language."

### 10. Real IT Task
> Goal: Write a real work message, then compare it with the model.

| English (Task / Solution) | الترجمة العربية / الحل |
|---|---|
| **Task:** TODO message task (rotate Teams/Email/Ticket). | **المهمة:** TODO الترجمة. |
| **Reference Message (Solution):** "Sentence 01. Sentence 02. Sentence 03." | **الرسالة المرجعية (الحل):** "جملة 01. جملة 02. جملة 03." |

### 11. Common Errors
> Goal: Avoid these 5 common mistakes.

1. ❌ wrong. ✅ correct.
2. ❌ wrong. ✅ correct.
3. ❌ wrong. ✅ correct.
4. ❌ wrong. ✅ correct.
5. ❌ wrong. ✅ correct.

### 12. Quick Check
> Goal: Answer 5 questions and confirm you mastered the lesson.

1. Question 01?
2. Question 02?
3. Question 03?
4. Question 04?
5. Question 05?

---
"""


def _rows_4(n, a="TODO", b="TODO", c="definition", d="Example sentence."):
    return "\n".join(f"| word{i:02d} | {a} | {c} | {d} |" for i in range(1, n + 1))


def _rows_3(n):
    return "\n".join(f"| phrase{i:02d} | ترجمة {i:02d} | Example. |" for i in range(1, n + 1))


def _rows_2(n):
    return "\n".join(f"| Sentence {i:02d}. | جملة {i:02d}. |" for i in range(1, n + 1))


def mastery_v3_template(day, title, level, speaking, output):
    key = _rows_4(14)
    voc = "\n".join(f"| vocab{i:02d} | مفردة{i:02d} | definition | Example sentence. |" for i in range(1, 21))
    sents = _rows_2(25)
    colloc = _rows_3(15)
    errors = "\n".join(f"{i}. ❌ wrong. ✅ correct." for i in range(1, 10))
    return f"""## Day {day:03d}: {title}
**Level:** {level} | **Speaking:** {speaking} | **Output:** {output}

### Mission
By the end of this lesson, I can TODO.

### Real IT Situation
> Goal: Understand the real work situation for this lesson.

| English | الترجمة العربية |
|---|---|
| TODO: 2-4 sentence workplace scenario with names, numbers, time (from profile.md). | TODO: الترجمة العربية الكاملة. |

### Key Language
> Goal: Learn the 12–15 key words and use them in your sentences.

| Word / Phrase | AR | EN | Example |
|---|---|---|---|
{key}

### Vocabulary
> Goal: Learn 15–20 more words about the same topic.

| Word | Arabic | Definition | Example |
|---|---|---|---|
{voc}

### Useful Sentences
> Goal: Practice 20–25 ready sentences for work.

| English | الترجمة العربية |
|---|---|
{sents}

### Collocations
> Goal: Learn 12–15 fixed phrases that sound natural.

| English (Collocation) | العربية | Example |
|---|---|---|
{colloc}

### Common Errors
> Goal: Avoid these 8–10 common mistakes.

{errors}

### Workplace English

> Goal: Read the article, notice the natural workplace expressions, and reuse them in your own professional communication.

TODO: 2-3 paragraphs of workplace prose reusing this lesson's language.

---
"""


def link_template(kind, num, title, level, speaking, output, url):
    tag = "Video" if kind == "video" else "Article"
    ctx = "Video Context" if kind == "video" else "Article Context"
    kw = f"Key Words from the {tag}"
    ph = f"Important Phrases from the {tag}"
    st = f"Important Sentences from the {tag}"
    lid = f"{tag}{num:02d}"
    srcline = f"> {tag}: TODO Title | {url}" if url else f"> {tag}: TODO Title | TODO-URL"
    if kind == "video":
        kw_body = ("**Must know - without these you cannot follow the video:**\n\n"
                   "| Word / Phrase | AR | EN | Example |\n|---|---|---|---|\n" +
                   "\n".join(f"| word{i:02d} | كلمة{i:02d} | definition | Example. |" for i in range(1, 15)) +
                   "\n\n**Useful - high work value, learn next:**\n\n"
                   "| Word / Phrase | AR | EN | Example |\n|---|---|---|---|\n" +
                   "\n".join(f"| useful{i:02d} | مفيد{i:02d} | definition | Example. |" for i in range(1, 15)) +
                   "\n\nYou will also hear these - recognize them, do not study them: *TODO* (channel talk, zero work value).")
        sent_body = ("**Core sentences (authentic)**\n\n| English | الترجمة العربية |\n|---|---|\n" + _rows_2(5) +
                     "\n\n**Practical steps (authentic - what he does on screen, phrased for study)**\n\n| English | الترجمة العربية |\n|---|---|\n" + _rows_2(3) +
                     "\n\n**Reusable patterns (take the chunk, change the words)**\n\n| English | الترجمة العربية |\n|---|---|\n" + _rows_2(3) +
                     "\n\n**Sentences for work**\n\n| English | الترجمة العربية |\n|---|---|\n" + _rows_2(4))
        listen_body = ("**Traps - fast or confusable speech:**\n\n| Word / Phrase | العربية | How to catch it |\n|---|---|---|\n" + _rows_3(4) +
                       "\n\n**Hard terms - names and products:**\n\n| Word / Phrase | العربية | How to catch it |\n|---|---|---|\n" + _rows_3(4))
        recall_n = 8
    else:
        kw_body = ("| Word / Phrase | AR | EN | Example |\n|---|---|---|---|\n" +
                   "\n".join(f"| word{i:02d} | كلمة{i:02d} | definition | Example. |" for i in range(1, 29)))
        sent_body = ("**Core sentences**\n\n| English | الترجمة العربية |\n|---|---|\n" + _rows_2(4) +
                     "\n\n**Practical sentences**\n\n| English | الترجمة العربية |\n|---|---|\n" + _rows_2(6) +
                     "\n\n**Repeated expressions**\n\n| English | الترجمة العربية |\n|---|---|\n" + _rows_2(3) +
                     "\n\n**Sentences for work**\n\n| English | الترجمة العربية |\n|---|---|\n" + _rows_2(3))
        listen_body = "| Word / Phrase | العربية | How to catch it |\n|---|---|---|\n" + _rows_3(7)
        recall_n = 6
    phrases = "| English (Phrase) | العربية | Example |\n|---|---|---|\n" + _rows_3(10)
    colloc = "| English (Collocation) | العربية | Example |\n|---|---|---|\n" + _rows_3(10)
    exp = ("| Word | Arabic | Definition | Example |\n|---|---|---|---|\n" +
           "\n".join(f"| exp{i:02d} | توسع{i:02d} | definition | Example. |" for i in range(1, 9)))
    pats = "| Pattern | العربية | Example |\n|---|---|---|\n" + _rows_3(6)
    recall_q = "\n".join(f"{i}. TODO question?\n> Answer: TODO answer." for i in range(1, recall_n + 1))
    goal_kw = "Learn the Must-Know words first, then the Useful ones. Hear-only items at the bottom need no study." if kind == "video" else "Learn every important word you will read - technical and general."
    return f"""## Lesson: {lid}: {title}
**Level:** {level} | **Speaking:** {speaking} | **Output:** {output}

> Sources:
{srcline}

By the end of this lesson, {output if output else 'I can TODO'}.

### {ctx}
> Goal: Meet the {'video' if kind == 'video' else 'article'}: what it is about and why it matters.

TODO: 1-2 paragraphs (author, date, steps) + 2 bullets of key facts.

- TODO key fact 1.
- TODO key fact 2.

### {kw}
> Goal: {goal_kw}

{kw_body}

### {ph}
> Goal: Learn the {'transferable chunks you will hear and can reuse' if kind == 'video' else 'key phrases and chunks you will read'}.

{phrases}

### {st}
> Goal: {'Separate what the speaker really said from practice you build on it.' if kind == 'video' else 'Read what the author actually says, grouped by use.'}
> **Authentic** = his real lines (lightly cleaned). **Generated** = new work sentences for drill - never quote these as his words.

{sent_body}

### Collocations
> Goal: Learn the natural IT collocations behind the {'video' if kind == 'video' else 'article'} language.

{colloc}

### Vocabulary Expansion
> Goal: Learn extra words you need to fully understand the topic.

{exp}

### Listening Notes
> Goal: {'Catch the hard parts when you listen again.' if kind == 'video' else 'Catch the hard parts when you hear these words in meetings.'}

{listen_body}

### Common English Patterns
> Goal: Reuse the {'speaker' if kind == 'video' else 'author'}'s sentence patterns anywhere.

{pats}

### Workplace English
> Goal: Read the article, notice the natural workplace expressions, and reuse them in your own professional communication.

TODO: 3 paragraphs applying this to your systems (from profile.md).

### Speaking Practice
> Goal: Say the {'video' if kind == 'video' else 'article'} back in your own words in {speaking}.

**Task:** TODO retell task (60-90 seconds, using its words and chunks).

**Model Answer:**
"TODO model answer."

### Final Recall
> Goal: Check what you remember from the {'video' if kind == 'video' else 'article'}.

{recall_q}

---
"""


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=None, help="Workspace dir (default: cwd if workspace)")
    ap.add_argument("--track", default="mastery", choices=["mastery", "mastery-v3", "video", "article"],
                    help="Lesson track (default mastery = legacy 12-section)")
    ap.add_argument("--day", type=int, help="Day number (mastery) / lesson number (video/article)")
    ap.add_argument("--title", default="TODO Title", help="Lesson title")
    ap.add_argument("--next", action="store_true", help="Auto-detect next missing lesson")
    ap.add_argument("--force", action="store_true", help="Overwrite existing file")
    ap.add_argument("--output", default="I can do the task of this lesson.")
    ap.add_argument("--url", default="", help="Source URL (video/article tracks)")
    args = ap.parse_args()

    root = resolve_root(args.root)
    total = workspace_days(root)

    if args.track in ("video", "article"):
        tag = "Video" if args.track == "video" else "Article"
        base = root / "lessons" if (root / "lessons").exists() else root
        existing = sorted([p for p in base.glob(f"{tag}*/lesson.md")]) if base.exists() else []
        nums = []
        for p in existing:
            m = __import__("re").search(r"(\d+)", p.parent.name)
            if m:
                nums.append(int(m.group(1)))
        if args.next:
            n = (max(nums) + 1) if nums else 1
            args.day = n
        if not args.day or args.day < 1:
            ap.error("--day N required (or --next)")
        n = args.day
        level = level_for(min(n * 10, total))
        speaking = speaking_for(min(n * 10, total))
        text = link_template(args.track, n, args.title, level, speaking, args.output, args.url)
        path = base / f"{tag}{n:02d}" / "lesson.md"
        if path.exists() and not args.force:
            print(f"Exists (use --force to overwrite): {path}")
            return 1
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        print(f"Created {path}")
        print("Next: fill every TODO from profile.md (+ transcript), then:")
        print(f"  python {SKILL_DIR}/scripts/validate_track.py --root {base} --track {args.track} --partial")
        print(f"  python {SKILL_DIR}/scripts/build_v3.py --root {base} --track {args.track}")
        return 0

    if args.track == "mastery-v3":
        if args.next:
            for d in range(1, total + 1):
                p = root / "curriculum" / f"day-{d:03d}" / "lesson.md"
                alt = root / "md" / f"Day-{d:03d}.md"
                if not p.exists() and not alt.exists():
                    args.day = d
                    break
            if not args.day:
                print(f"All {total} days already exist.")
                return 1
        if not args.day or not (1 <= args.day <= total):
            ap.error(f"--day 1-{total} required (or --next)")
        day = args.day
        text = mastery_v3_template(day, args.title, level_for(day), speaking_for(day), args.output)
        path = root / "curriculum" / f"day-{day:03d}" / "lesson.md"
        if path.exists() and not args.force:
            print(f"Exists (use --force to overwrite): {path}")
            return 1
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        print(f"Created {path}")
        print("Next: fill every TODO from profile.md, then:")
        print(f"  python {SKILL_DIR}/scripts/validate_track.py --root {root} --track mastery --partial")
        return 0

    if args.next:
        for d in range(1, total + 1):
            p = root / "curriculum" / f"day-{d:03d}" / "lesson.md"
            if not p.exists():
                args.day = d
                break
        if not args.day:
            print(f"All {total} days already exist.")
            return 1
    if not args.day or not (1 <= args.day <= total):
        ap.error(f"--day 1-{total} required (or --next)")

    day = args.day
    level = level_for(day)
    speaking = speaking_for(day)
    out = args.output
    # Mission scaffold: strip only the leading "I can" prefix and one trailing
    # period — never lowercase (product names like Microsoft Purview / Entra
    # must keep their capitals).
    mission = out
    if mission[:6].lower() == "i can ":
        mission = mission[6:].lstrip()
    mission = mission.rstrip()
    if mission.endswith("."):
        mission = mission[:-1]
    text = TEMPLATE.format(day=day, title=args.title, level=level,
                           speaking=speaking, output=out, mission=mission)

    path = root / "curriculum" / f"day-{day:03d}" / "lesson.md"
    if path.exists() and not args.force:
        print(f"Exists (use --force to overwrite): {path}")
        return 1
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    print(f"Created {path}")
    print("Next: fill every TODO from profile.md, then:")
    print(f"  python {SKILL_DIR}/scripts/validate_all_md.py --root {root} --partial")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
