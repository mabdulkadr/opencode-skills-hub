# Curriculum Audit System — 7 Phases, Self-Contained (v1.2)

This file is the complete bulk-quality workflow. Nothing here depends on any
folder outside the skill or the workspace. Run phases in order 0 → 6.
**Phases 0–4 and 6 are read-only** (report only, never touch a lesson).
**Phase 5 is the only edit phase** (user-approved confirmed fixes only).
Reports live in `<workspace>/reports/`:

| Phase | Report file | Focus |
|---|---|---|
| 0 Summary Dashboard | `reports/00-audit-dashboard.md` | Executive health summary & metrics across phases |
| 1 Full audit | `reports/01-full-audit.md` | Comprehensive 25-area scan across all lessons |
| 2 CEFR + grammar | `reports/02-cefr-grammar.md` | CEFR bands, progression jumps, grammar accuracy |
| 3 English + Arabic | `reports/03-english-arabic.md` | Collocations, prepositions, natural phrasing, translations |
| 4 Pedagogy + domain | `reports/04-pedagogy.md` | Work authenticity, cognitive load, message genres |
| 4b Scenario rotation | `reports/05-scenario-rotation.md` | Rotation frequency & adjacent scenario check (sub-phase of Phase 4) |
| 5 Apply fixes | lesson edits (approved only, no report file) | Targeted minimal corrections to confirmed issues |
| 6 Final verification | `reports/06-final-verification.md` | 20-gate check (`PASS / PASS WITH MINOR ISSUES / FAIL`) |

---

## Global rules (every phase)

- Separate language difficulty from domain-term difficulty. Keep the
  workspace's authentic terms (defined in `profile.md`) no matter how
  technically advanced they sound — judge only the surrounding syntax.
- Never turn the curriculum into General English. The identity stays:
  work English for the profile's domain, grounded in the profile's real
  systems, numbers, and times.
- Classify every issue: CRITICAL (must fix) / MAJOR (hurts learning) /
  MINOR (small correction) / OPTIONAL (Phase 5 skips it unless clearly necessary).
- Record for every issue: File + Day + Section + Current text + Problem +
  Why it matters + Recommended correction + Priority.

---

## Phase 0 — Audit Summary Dashboard (read-only)

Before diving into granular reports, initialize `reports/00-audit-dashboard.md` to summarize the overall curriculum state:

```markdown
# Audit Dashboard — <Workspace Title>
**Date:** YYYY-MM-DD | **Skill Version:** 1.2.0 | **Days Audited:** N / 180

## Executive Health Summary
Overall Status: 🔴 Needs Work / 🟡 Minor Issues / 🟢 Clean

| Phase | Status | Critical | Major | Minor | Fixed |
|---|---|---|---|---|---|
| Phase 1: Full Audit | Done | X | Y | Z | - |
| Phase 2: CEFR & Grammar | Done | X | Y | Z | - |
| Phase 3: English & Arabic | Done | X | Y | Z | - |
| Phase 4: Pedagogy & Domain | Done | X | Y | Z | - |
| Phase 5: Corrections Applied | Pending | - | - | - | 0 |
| Phase 6: Final Verification | Pending | - | - | - | - |
```

Update this dashboard after each audit phase completes.

---

## Phase 1 — Full curriculum audit (read-only)

Audit the entire workspace before ANY change. Do not modify, rewrite,
redesign, delete, or invent. Scope: all `curriculum/day-NNN/lesson.md`
(plus `profile.md` for grounding checks). Cover all 25 areas:

1. CEFR progression · 2. Grammar progression · 3. Vocabulary progression ·
4. Domain vocabulary difficulty · 5. Speaking progression · 6. Writing
   progression · 7. Reading difficulty · 8. Listening/pronunciation coverage ·
9. Review and spaced recycling · 10. Repetition and duplication ·
11. Lesson-to-lesson continuity · 12. Month-to-month progression ·
13. Difficulty jumps · 14. English naturalness · 15. Grammar accuracy ·
16. Arabic translation accuracy · 17. Professional domain terminology ·
18. Technical accuracy of domain examples · 19. Learning objectives ·
20. Assessment structure · 21. Terminology consistency ·
22. Lesson-structure consistency · 23. Content gaps · 24. Unnecessary content ·
25. Template-generated repetition.

Output: `reports/01-full-audit.md`, detailed report only. DO NOT MODIFY FILES.

---

## Phase 2 — CEFR and grammar audit (read-only)

Second pass, CEFR + grammar only. For each day: grammar introduced, grammar
recycled, grammar difficulty, introduced-before-required check, jump size,
beginner bands genuinely beginner, each higher band appropriately harder,
recycling present, overload absent, no inconsistencies, correct explanations,
correct examples. Produce:

`| Day | CEFR | Grammar Target | Actual Difficulty | Problem | Recommendation |`

then: critical grammar errors · CEFR classification problems · missing
prerequisites · unnecessary grammar · recommended progression changes.
Goal stays: simple English + authentic domain terminology. Do not redesign.
Output: `reports/02-cefr-grammar.md`. DO NOT MODIFY FILES.

---

## Phase 3 — English and Arabic language audit (read-only)

English: grammar accuracy, naturalness, workplace professionalism, awkward
phrasing, literal-translation influence, collocations, prepositions, articles,
verb patterns, tense usage, technical expressions, AI-generated wording,
repeated sentence patterns. Naturalness audit (machine + human, per
`natural-english.md`): telegraphic examples, broken `whereas` clauses,
formulaic signoff signatures, AI-pattern blacklist hits, opening-pattern
repetition >30%, missing dictionary definitions, register-tagged variants,
textbook dialogues. Arabic: translation accuracy, natural Arabic,
correct technical terminology, contextual meaning, literal translations, wrong
terminology, missing meaning, over/under-translation. Never replace valid
domain terminology with generic English. For every error: File, Day, Section,
Original, Corrected version, Explanation, Priority. Known repeat offenders:
terminal dangling prepositions (`... alert in.`), doubled connectors
(`before ... before`), forced domain tails glued to every sentence, filler
repetition (`morning/today` style). Intentional learner errors in §11 ❌ lines
and §8 fix-items are teaching content — never flag them.
Output: `reports/03-english-arabic.md`. DO NOT MODIFY FILES.

---

## Phase 4 — Domain content, pedagogy, and scenarios (read-only)

Designer view. Evaluate: authenticity of workplace situations, technical
accuracy, real-world usefulness, speaking/writing/reading progression,
vocabulary load, daily cognitive load, lesson length, review frequency, spaced
repetition, weekly/monthly assessments, practical workplace output, role-play
quality, message-genre communication (Teams/email/ticket or profile equivalents),
troubleshooting, meetings, vendor, management, career/interview communication.

Cross-reference with `reports/on-demand-log.md` if available to incorporate real user work needs.

### Scenario Rotation Audit (`reports/05-scenario-rotation.md`):
- Ensure all 7 workplace scenarios are distributed evenly across days.
- Check the **Adjacent Scenario Rule**: no two consecutive days should reuse the same scenario or identical speaker pair.
- Output: `reports/04-pedagogy.md` and `reports/05-scenario-rotation.md`. DO NOT MODIFY FILES.

---

## Phase 5 — Apply approved corrections (edit phase)

Only after the user approves the audit findings. Rules: preserve architecture
(day structure, valid content, authentic domain terms); do not rewrite
everything; do not touch generated HTML (rebuild instead); do not remove valid
lessons or invent new ones; do not grow daily workload; fix confirmed problems
with minimal targeted corrections; keep English natural/professional and Arabic
natural/accurate; maintain CEFR progression and domain authenticity. Order:
critical first, then major, then minor. Skip OPTIONAL. Before each file: list
required changes, apply only those, preserve the rest. After: verify nothing
valid was removed, then re-run:

```powershell
python <skill>/scripts/validate_all_md.py --root <workspace>
python <skill>/scripts/build.py --root <workspace>
```

---

## Phase 6 — Final verification (read-only)

Compare the workspace against the audit requirements. Verify 20 gates: no
critical grammar errors · no wrong grammar explanations · coherent
CEFR/grammar/vocabulary progression · gradual speaking/writing ramp · review
and recycling present · no major needless repetition · natural Arabic ·
natural professional English · authentic domain terms · accurate technical
statements · practical lessons · reasonable daily workload · logical
month-to-month flow · no accidental deletions · no broken Markdown/HTML · no
duplicate lessons · no design-principle violations. Output header:

`FINAL STATUS: PASS / PASS WITH MINOR ISSUES / FAIL`

then remaining critical/major/minor issues + files requiring correction with
exact fixes. Output: `reports/06-final-verification.md`. DO NOT MODIFY FILES.
