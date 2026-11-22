# Role Analysis — the position-level standard (PRAS)

## When this file applies

Use it when the request is about **a role or position**, not about one advert:

| Request | File to read |
|---|---|
| "حلل وظيفة IT Operations Manager" · "what is an NOC Lead" · "compare these four titles" · "how do I get into Service Delivery Manager" | **this file** |
| "حلل هذه الوظيفة" + a URL or a pasted advert | `analysis.md` (job level) — plus this file for role context |

The two layers meet only through shared ids: `position_id`, `skill_id`, `REQ-xxx`.
A role analysis never names a candidate. A job analysis never generalises about a role.

**The contract is `docs/POSITION-ROLE-ANALYSIS-STANDARD.md` (`pras-1.0.1`).** This file is its
operating procedure. If they disagree, the standard wins — and say so.

---

## Step 0 — Establish the evidence position before writing anything

This is the step that decides whether the output is an analysis or a plausible essay.

```text
1. Read the KB record   derived/kb/positions/position-<id>.json
2. Read evidence_status, confidence_level, corpus_evidence[], salary_evidence[],
   market_demand_evidence[], unresolved_data_gaps[]
3. State the position in one line in the output: what is evidenced, what is inferred,
   what is absent. Carry that line through §7 and §11.
```

Three states you will meet, and what each one obliges you to do:

| Record state | What you may assert | What you must do |
|---|---|---|
| `corpus-backed` with postings | Quote postings by `JobNNN` / `REQ-xxx`. Derive prevalence claims — scoped to that corpus, never market-wide. | Say the sample size every time. |
| `framework-inferred`, `corpus_evidence: []` | Occupational convention, labelled as such. | Never write "employers ask for". Write "this role normally carries". |
| `verified` / `source-backed` | Citable, with the `source_id` inline. | Still verify the source supports the specific claim. |

**Never upgrade a record's state in prose.** If the analysis is better evidenced than the
record, that is a §11 gap to fix in the record — not a licence to write around it.

---

## Step 1 — Section contract (all eleven, in order)

Use these headings verbatim. Do not drop a section; if there is nothing to say, say that.

| § | Heading | Non-negotiable content |
|---|---|---|
| 1 | Role definition and scope | Canonical + alternative + Arabic titles; one-paragraph definition; **delineation table vs 4-6 nearest neighbours on the axis of accountability**; the org-dependency statement; the known boundary failure mode |
| 2 | Core responsibilities, in detail | 6-9 **domains**, each ending in an **expected output** or observable success measure; the **altitude ladder**; the commonly-confused distinctions |
| 3 | Skills and competency matrix | Three columns: domain · expected proficiency · **practical proof (the artefact)** |
| 4 | Technologies and tools | Grouped by capability; each group has a **purpose** line and a stated **expected depth**; flagged as examples |
| 5 | Key performance indicators | Columns: indicator · how it is computed · what it reveals; commitment vs internal measure; numerator/denominator/population/window or an explicit `method undefined`; **set balanced across service/money/project/people/risk; every cost or throughput indicator names its guardrail** |
| 6 | Qualifications, experience, certifications | A defensible floor **plus what varies it**; degree = *usually preferred* unless a gate is sourced; certs = what they actually signal + verification note; mandatory = only real blockers, each naming its market |
| 7 | Role specifics in the Saudi market | **Sector variation matrix**; regulatory context by body with the applicability caveat; market-intelligence discipline — what a defensible figure needs, and whether it exists |
| 8 | Professional development plan | Three phases (0-30 / 31-60 / 61-90), each with an **output artefact**; 4-5 portfolio projects; the production/lab/plan labelling rule |
| 9 | Technical and managerial interview guide | 8 questions each with concrete checkpoints; one shared-definition question; one non-binary trade-off question; an evaluation rubric |
| 10 | Candidate fit *(conditional)* | Three-status legend + the **anti-inference rule** + evidence-to-produce list. **No scores.** Omit entirely if no candidate basis exists, and say why. |
| 11 | Required data structure | Entity → where it lives; the **cross-linking contract** + the actual trace table; §11.1 known gaps; links the canonical schema, never restates it |
| 12 | Conclusion | The three axes the role rests on, and what the real challenge is |

### Step 1b — the four additions of `pras-1.0.1`

These were added after review and each one closes a failure that survived `pras-1.0.1`.

**1. §1 — a deciding question on every delineation row.** The accountability column states the
difference; the deciding question is what a reader can put to themselves or a recruiter and
get an unambiguous answer. A delineation table with no test is a description.

**2. §2 — the altitude ladder is mandatory.** Take one concrete decision and show what each
level of the family contributes to it. A list of "transitions from engineer to manager" is
abstract and a candidate can agree with it without holding any of it; the ladder is
falsifiable. It is also the best self-check available — if every example a reader can offer
lands in the first two rows, the analysis has told them something they already suspected.

**3. §5 — balance and guardrails.** The KPI set must span service / money / project / people
/ risk, and every cost or throughput indicator must name the guardrail that stops it being won
by degrading something else. Cost reduction that degrades availability or security is not a
saving; an availability figure produced by quietly removing a service is not an improvement.
This is the most common way a well-measured role still fails, and a table of percentages cannot
show it.

**4. §11 — the cross-linking contract, and actually do the trace.** Every responsibility domain
must be traceable to a skill, a KPI and an interview question. Then produce the trace table.
A role analysis is a graph, not a list. **A domain with no KPI, or no interview question, is a
finding — report it as one. Never invent an indicator or a question to fill the gap.**

Also in `pras-1.0.1`: §9's "technical correctness is not sufficient" rule, and §10's
anti-inference rule (years in a technical specialism never auto-convert into managerial
readiness, in either direction).

---

## Step 2 — The honesty contract (the part that must not be relaxed)

1. **A claim without a source is a hypothesis — label it.** Salary, market size, demand,
   prevalence, growth rate: no registered source, no number.
2. **A number without a definition is decoration.** No `99.9%`, `8-12 years` or `SAR 25,000`
   without the denominator, scope, window, geography and type.
3. **Examples are captioned as examples.** An illustrative KPI block must say it is not a
   threshold, a benchmark or a market standard.
4. **Absence of evidence is not absence of capability.** Say which one you mean, every time.

Two traps specific to this repository:

- **The US trap.** `SRC-ONET` / `SRC-BLS-OOH-*` are US-only. A US median for SOC 15-1242 is a
  figure for the *managerial function*, not for your title, and it is never a Saudi or Gulf
  salary. If you state it at all, state all three limits.
- **The circularity trap.** `derived/aggregates/<key>.market.json` may hold
  **estimated** ranges derived from a handful of postings, and the lower bound may coincide
  with the candidate's own target salary in `src/candidate/profile.md`. A number that agrees
  with the candidate's goal because it was built from the candidate's goal proves nothing.
  Check `analystNote`, `basisEn`, `sampleSize` and `confidenceMix` before quoting any of it.

---

## Step 3 — Vocabulary discipline

Three vocabularies exist here. Never substitute one for another.

| Vocabulary | Where | Use |
|---|---|---|
| `foundational` · `working` · `advanced` · `expert` · `not-expected-at-this-level` | §3 proficiency | The only permitted terms |
| `LIKELY MATCH` · `UNDETERMINED` · `EVIDENCE GAP` | §10 role level | With the legend. `UNDETERMINED` ≠ negative. `EVIDENCE GAP` ≠ absent. |
| `MATCH` / `PARTIAL` / `GAP` / `UNKNOWN` | `analysis.md` job level | `REQ-xxx` blocks. `GAP` = no evidence. |

Note the drift risk: the KB schema enum is `awareness · working · proficient · advanced ·
expert`, and records do contain `proficient`. **Render it into the PRAS vocabulary and disclose
the mapping in §11.1.** Do not silently translate, and do not edit the record to match prose.

---

## Step 4 — Reconcile the analysis with the machine record

After drafting, check both directions. This is what stops the document drifting from the database.

```text
For every §11 entity row:  does the field actually exist in the record, with the state claimed?
For every KPI cited:       does the record carry the formula, or is it flagged as authored?
For every id mentioned:     does it resolve (skill / cert / source / position)?
```

Then, if the record is missing something the analysis needs:

1. Add the field to `src/positions/kb/positions/<domain>.json` (never to `data/` or `derived/` — generated).
2. If the field is new to the schema, add it to
   `src/positions/kb/schema/position.schema.json` and `docs/POSITIONS-KB-MODEL.md`.
3. Append a `change_history` entry with the date, what changed, and what deliberately did not.
4. `node scripts/build-positions.js` → `node scripts/validate.js` → `node scripts/validate-framework.js` → `node scripts/build-index.js`.
5. Re-read the analysis and update any claim that the earlier state invalidated.

Rule 5 is not optional. A note saying "the record does not carry X" is wrong the moment X is
added, and a stale honesty note is worse than a missing one.

**Never add `responsibility_domains` / `sector_variation` / KPI `formula`/`reveals` to a record
that has no analysis behind them.** Those fields are authored-from-convention. Populating them
across all 220 records would turn three honest optional fields into 220 fabricated ones.

---

## Step 5 — Self-check before publishing

Work the checklist in standard §5. It is short and every line is there because it caught
something. If any line cannot be answered, fix it or say why in §11.1 — do not ship it
unanswered.

Highest-yield checks, in order of how often they fail:

- [ ] §1's delineation table would still identify the right role if the title were removed — and every row has a deciding question.
- [ ] §2 has the **altitude ladder** (one real decision, each altitude's contribution), not just an abstract transition list.
- [ ] §5 — every KPI has numerator, denominator, population, window, or an explicit `method undefined`.
- [ ] §5 — the set spans service / money / project / people / risk, and each cost or throughput indicator names its guardrail.
- [ ] §7 — no number that cannot name its source, geography, date, type and confidence.
- [ ] §8 — every phase output is a document, not an activity ("hold the DR test" is not an output; "DR test report with measured RTO" is).
- [ ] §9 — every question reaches beyond technical correctness: method of deciding, ownership, measurement, business consequence.
- [ ] §10 — the legend is present, no score appears anywhere, and the anti-inference rule is stated.
- [ ] §11 — the cross-link trace was actually produced, and any dead thread is reported as a finding rather than filled in.

---

## Step 6 — Where to put the file

```text
docs/positions/<slug>.md          <- the analysis (one per role)
docs/positions/README.md          <- the family index; add the new role to it
```

Relative links from `docs/positions/`: `../POSITION-ROLE-ANALYSIS-STANDARD.md`,
`../POSITIONS-KB-MODEL.md`, `<other-role>.md`,
`../../derived/kb/positions/position-<id>.json`.

A retired or superseded analysis is **replaced, not deleted** — move it and leave a pointer at
the old path so no external reference dangles.

---

## Step 7 — Reporting back to the user

Say, plainly:

1. Which sections are **evidenced** and which are **inferred**, with the record state that
   drove it.
2. Every number you **declined** to state, and why — this is the valuable half of the report.
3. Every record gap the analysis exposed, as a list against `POSITIONS-KB-MODEL.md`.
4. What you did **not** do, if you stopped short.

Do not report a completeness score as evidence quality. The schema-population score and the
evidential strength of a record are different numbers, and a record can be 94% complete while
resting on convention alone.