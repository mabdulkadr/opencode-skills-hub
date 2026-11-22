# Output — 12-Section REPORT + SOURCES.md + Dashboard + QA

## Files per job (jobs/<slug>/) — exactly 3

| File | Content |
|---|---|
| REPORT.md | 12 sections (map below) |
| SOURCES.md | Claim ledger: `[Sxxx]` blocks (research.md format) |
| index.html | Dashboard (below), same folder — no `html/` subfolder |

Partial runs rewrite sections in place: `compare-cv` → §§1,3,4,12 · `salary` → §6 + SOURCES.md · `interview-prep` → §§8-11. Never create numbered files (`00-…09-…`) or `evidence.md`/`sources.md` — if they exist from an older run, delete them (evidence folds inline into §3 REQ blocks).

REPORT.md headings (exact):

```text
# JobFit Intelligence Report
## 1. Executive Summary
## 2. Job Analysis
## 3. Requirement Matrix
## 4. Gap Analysis
## 5. Development Roadmap
## 6. Salary Intelligence
## 7. CV & LinkedIn Optimization
## 8. Interview Preparation
## 9. Mock Interview
## 10. Interview Cheat Sheet
## 11. 30-60-90 Day Plan
## 12. Application Readiness
```

§1 contents: Job · Company · Location · Readiness (§12 value) · Alignment Index (score + verbatim disclaimer line) · Key strengths (with REQ cites) · Critical gaps (with REQ cites) · full decision block (Trainable + Non-trainable + Risks + Highest-value improvements + Effort). §3: summary table (ID | Requirement | Status | Priority | Gating) + one inline-evidence block per REQ (Requirement / Evidence E-xx / Status / Priority / Gating / Assessment / Gap / Action). §6: range table + base/total split + assumptions + Confidence + market + company + inline `[Sxxx]`. §12: strategy outcome (1–5) + Readiness + gating-cap note.

Traceability chain: `REQ-xxx → [E-xx]/[Sxxx] → gap → roadmap → project → question → CV tip`. Keep statuses and numbers identical across REPORT.md, SOURCES.md, and the dashboard.

## HTML Report (self-contained, full standalone Job Intelligence Report)

`index.html` must be a complete, detailed, standalone report — the same analysis as REPORT.md in professional web form. The user opens index.html alone and gets the full job analysis, candidate comparison, salary intelligence, roadmap, interview preparation, and 30-60-90 plan without ever opening Markdown.

Copy `.opencode/skills/jobfit-intelligence/assets/dashboard-template.html` → `jobs/<slug>/index.html` and fill ALL 23 sections:

```text
1. Job Overview (title, company, location, type, seniority, experience, source, dates, readiness)
2. Executive Summary (alignment, strengths, gaps, considerations)
3. Candidate Profile (background, YoE, technologies, certs, education, projects, industry)
4. Job Description (cleaned JD, responsibilities, requirements, preferred, benefits)
5. Requirement Analysis (per requirement: ID, requirement, priority, status, evidence, strength, gap, action)
6. Requirement Matrix (ID | Priority | Status | Requirement)
7. Candidate Strengths (direct matches, experience, transferable skills, certs, domain)
8. Critical Gaps (per gap: skill, why it matters, current → target, how to close, time)
9. Development Roadmap (0–2, 2–6, 6–12 wks, long-term)
10. Recommended Projects / Labs (objective, technologies, build, outcome, CV + interview value)
11. Salary Intelligence (location, currency, low/typical/high, base vs total, monthly/annual, dates, sources, interpretation, limitations)
12. Company Intelligence (overview, industry, location, size, tech environment, context, sources)
13. CV Optimization (changes, keywords, highlights, supported skills only, missing evidence, bullet improvements)
14. LinkedIn Optimization (headline, about, skills, emphasis, keywords)
15. Application Strategy (emphasize, prepare first, documents, gaps to address, considerations)
16. Interview Preparation (HR, technical, behavioral, scenario, company-specific, candidate-specific)
17. Interview Question Bank (per question: ID, category, REQ ID, what is tested, answer points, evidence, prep note)
18. STAR Stories (situation, task, action, result, related REQ)
19. Technical Study Guide (topic, why, what to study, lab, questions)
20. Questions to Ask the Employer (scope, team, reporting, tech, on-call, travel, location, expectations, salary)
21. 30 / 60 / 90 Day Plan
22. Final Readiness Assessment (one of the 4 readiness levels + why)
23. Sources (all external sources: type, date accessed, what each supports)
```

HTML REPORT REQUIREMENTS — design principles: professional · clean · detailed · highly readable · structured for long-form analysis · desktop-first but responsive · white background · light gray borders · one primary professional accent color · clear section hierarchy · comfortable line height · generous spacing · compact readable tables · status badges (MATCH/PARTIAL/GAP/UNKNOWN) · priority badges (P0–P3) · visible Requirement and Evidence IDs · callout boxes for key conclusions.

Do NOT use: large circular score gauges · excessive KPI cards · decorative gradients · heavy shadows · animations · excessive icons · large hero sections · dashboard-style clutter · tiny text · dense walls of text.

Content rules: do not summarize away important analysis — preserve the same information as REPORT.md · present repeated structures as TABLES wherever possible (matrix, gaps, roadmap, projects, salary, study guide, questions, STAR, 30-60-90) · write complete, clear, simple sentences — no terse fragments, no unexplained jargon · every requirement traceable · every GAP explains why it matters + how to close it · salary methodology and limitations visible · interview questions carry related REQ IDs · sources accessible from the HTML · never invent evidence or facts · headings, tables, bullets, and short paragraphs keep detail scannable.

Interactive behavior (all inline, no libraries): status filter buttons above the matrix table (All / MATCH / PARTIAL / GAP / UNKNOWN) that hide non-matching rows and show a live count · each long section collapsible via a toggle that never hides content from print · TOC highlights the section in view · back-to-top link. Gating callout: any gating GAP shows a red banner under the header (from §4) — never look "green" when a gate fails. Print-first `@media print` (hide nav/toolbar/controls, expand all collapsed sections, unbreak sections, exact badge colors). Semantic HTML. No fake charts. No unfilled `{{PLACEHOLDERS}}`.

Technical: single file, inline CSS + small inline vanilla JS only (matrix status filter, collapsible sections, active-TOC highlight, back-to-top, print button) — no frameworks/CDN/webfonts. JS must be progressive enhancement: with JS disabled, all content stays fully visible and readable.

## QA Checklist (run before finishing — fix any failure)

- [ ] JD fully captured verbatim + fields extracted (§2)
- [ ] Candidate facts traceable to supplied CV text; nothing invented
- [ ] Every requirement has REQ-xxx + Required/Preferred + Gating flag + MATCH/PARTIAL/GAP/UNKNOWN (§3)
- [ ] MATCH never rests on keyword overlap (technology · level · recency · scale/duration evidenced) with one-line Assessment per block
- [ ] Every GAP has Gap + Action + time + priority; P0 gaps in §1
- [ ] Gating listed with consequence + obtainability (§4); no gating gap hidden in the index; §12 capped accordingly
- [ ] Roadmap phased, lab-first, no cert-stuffing; every item cites a parent REQ (§5)
- [ ] Salary follows the 11 research rules; location = JD location; ≥2 sources or weak-data notice (§6); figures cite `[Sxxx]`; disagreements reported
- [ ] Adjacent tech never auto-counted; interview Qs cite REQ with `[E-xx]`/bridge answers (§8); CV truthful + ATS (§7); due diligence specific
- [ ] Every `[Sxxx]` resolves to a SOURCES.md block with URL + dates; exactly 3 files per job (no numbered files, no evidence.md/lowercase sources.md)
- [ ] REPORT.md, SOURCES.md, index.html mutually consistent (statuses, numbers, readiness); HTML covers the full analysis standalone (all 23 sections filled)
- [ ] HTML renders, responsive, anchors work, no external deps; gating banner when a gate fails; print-to-PDF clean; index labeled heuristic, not hiring probability
