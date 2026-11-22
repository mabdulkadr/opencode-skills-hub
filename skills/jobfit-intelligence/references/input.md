# Input — Tool Mapping, JD Acquisition, CV-First Profile

## Step 0 — Map environment tools (do this first, every run)

Never assume tool names (`Read`, `webfetch`, `websearch`). Inspect the tools available in the current agent environment and map them to these capabilities:

- file reading (CVs, PDFs, Markdown, exports)
- web fetch (single URL retrieval)
- web search (market/salary/company research)
- filesystem read/write (workspace files)

If a capability is missing: run that stage offline and mark its output `weak-data` with the exact disclaimer from research.md — never fail the whole run, never silently skip.

## Workflow A — Job URL

1. Fetch URL with the mapped web-fetch capability. On redirect to another host, fetch the redirect target immediately. Extract: title, company, country, city, department, seniority, employment type, required experience, required/preferred skills, certs, education, responsibilities, tech stack, languages, salary/benefits if published, clearance requirements. Never guess a missing field — write UNKNOWN.
2. Save verbatim JD to `jobs/<slug>/REPORT.md` §2 with source URL + access date (`YYYY-MM-DD`). Never paraphrase away details. Slug: `<company>-<role>` lowercased, spaces → `-` (company UNKNOWN → use country or `unknown`).
3. On fetch failure (auth wall, JS, 404): say so, switch to Workflow B, ask the user to paste the JD.

## Workflow B — Pasted JD

Use pasted text directly. Same extraction, same UNKNOWN rule.

## Depth Modes (pick before writing anything)

| Mode | Trigger | Budget | Produces |
|---|---|---|---|
| **Full** | default | 12 REPORT sections · ≤6 searches · ≤8 sources | REPORT 12/12 + SOURCES + JSON green |
| **Quick lane** | user says `quick` / backlog mode (`analyze-job <url> quick`) | **3 searches max** (1 salary band, 1 market context, 1 company fact if essential) · ≤4 sources · 0 rewrite loops | JSON green (id/slug/index/meta/summary/careerMove/time/alignment-lite/reqs/reqRefs/gaps top-3/salary/interview empty/readiness) + REPORT §§1,2,3-lite,4,6,12 only |

Quick-lane rules (order matters — this is where the hours go):

1. Fetch+extract first, then a SINGLE pass writing REPORT §§1,2,3,4,6,12 (no rewrites, no polish loops). §3-lite = the summary matrix table + one compact evidence block per REQ (Status/Priority/Gating + 1-2 bullet evidence + gap/action one-liners — the MATCH scope rule and gating caps are NOT shortcut).
2. Leave §7-§11 as one line each: `Deferred to interview-prep lane (REQs N..M)`. Do not draft bank/mock/cheatsheet.
3. Write `Data/jobs/content/job-<slug>.json` in the same pass (migrate-report.js contract absent → fill directly): index block (fitIndex/fitLabel/readiness/salary/decision/statusCode), evidence-lite {totals, scoreExplain, reqRefs summary}, summary fields, reqs[], gaps[], salary, readiness, empty terms/skills/bank arrays. `validate: GREEN` with ZERO fails is the exit gate (zero-glossary warnings are acceptable).
4. Upgrade path is explicit: full lane later.
5. The alignment total, label, and readiness must come out identically honest to the full lane — quick ≠ inflating (never value a dimension you did not verify).

Full-lane hygiene caps (prevent hour-long drafts):

- ≤6 web searches per job in the research stage — batch queries (one search may answer salary+market).
- Every REPORT section is written once, top-down; corrections are edits, not re-drafts.
- Cap authored artifacts per job: terms 15-20 · skills 14-18 · bank 12-16 · mock 5 rounds × 3-4.
- After the JSON: build-index → evidence-ledger → macro-aggregate → overlays → validate ONCE (one command chain, not per-artifact loops).

## CV / Candidate Input (CV-first, low friction)

If `candidate/profile.md` does not exist or is empty:

1. If a CV is supplied (file, pasted text, LinkedIn export): parse it with the mapped file-reading capability, normalize verified information into the single `candidate/profile.md` (sections: Profile / Skills table / Experience / Certifications / Projects), mark missing fields UNKNOWN, never invent. Do not ask the user to fill a template when the CV already answers.
2. If no CV is supplied: create `candidate/profile.md` from the template asset and ask the user to provide CV/profile data.

Rules: never infer sensitive data (age, religion, photo). Never upgrade "exposure" to "production". Skill depth without dated evidence → `stated-only`. Quote the CV — every profile bullet must be traceable to supplied text.
