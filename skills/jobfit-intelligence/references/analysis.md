# Analysis — REQ IDs, MATCH Scope Rule, Gating, Gaps, Roadmap, CV/LinkedIn, Index

## Step 1 — Extract requirements, assign IDs

Split the JD into atomic requirements. Assign each `REQ-001`, `REQ-002`, … in order. Tag each Required or Preferred ("preferred/plus/nice-to-have" → Preferred; else Required). Flag gating candidates (required certs, work authorization, required language, clearance, mandatory years, legal licenses) with `Gating: yes`.

## Step 2 — Assess with evidence inline (→ REPORT.md §3)

One block per requirement — evidence lives here, no separate ledger:

```text
REQ-007
Microsoft Intune administration (Required, Gating: no)

Status: PARTIAL
Priority: P1

Candidate Evidence:
E-03 — Managed Intune policies and device configuration.

Assessment:
Intune experience is documented, but the JD requires enterprise-scale
ownership that is not explicitly demonstrated.

Gap:
Enterprise-scale administration evidence.

Action:
Build/document an enterprise Intune lab and emphasize verified production scope.
```

MATCH requires evidence covering ALL of: technology/domain · responsibility level · relevant recency (≤3y production) · scale when specified · duration when specified. Keyword overlap alone is never MATCH. PARTIAL = adjacent/older/homelab/smaller-scale/scope-unproven. GAP = no evidence. UNKNOWN = JD vague or profile silent — state what to ask. Also write the summary matrix table (ID | Requirement | Status | Priority | Gating) at the top of §3.

Every downstream artifact (gaps §4, roadmap §5, projects §5, questions §8, CV tips §7) cites its `REQ-xxx` — an item without a REQ parent must not exist.

## Step 3 — Gating (flag in §3, summarize in §4)

For each `Gating: yes` requirement state consequence + obtainability (yes + time | no). Never mathematically hide a gating gap inside the index: any gating GAP caps Application Readiness (§12) at SIGNIFICANT PREPARATION REQUIRED or lower. Say so explicitly.

## Step 4 — Gap Analysis (→ REPORT.md §4)

- **Critical gaps:** P0 items blocking competitiveness now.
- **Trainable gaps (0–12 wks):** course/lab-fixable with time per item.
- **Experience gaps (not course-fixable):** leadership tenure, large migrations, regulated-industry years, prod on-call at scale — honest compensation strategy (adjacent evidence + lab + positioning), never pretend a course equals experience.

## Step 5 — Development Roadmap (→ REPORT.md §5)

For each GAP/PARTIAL with P0-P2: Skill / Why / Linked REQ(s) / Current → Target / Objectives / Hands-on Lab / Portfolio Project / Certification (only if it pays for THIS job) / Time / Priority. Phases: 0–2 wks (application boosters) · 2–6 wks · 6–12 wks. Labs over videos. No cert-stuffing.

Portfolio projects per project: Name / Linked REQ(s) / Business Problem / Technologies / Architecture / Steps / Expected Result / What It Demonstrates / CV line (marked LAB) / Interview explanation. Realistic enterprise builds over toys.

## Step 6 — CV & LinkedIn (→ REPORT.md §7)

CV audit: missing keywords (from REQ list), buried skills, weak bullets, ATS risks (tables, graphics, unexplained acronyms). Output: Summary / Core Skills (Production vs LABS split) / Experience / Projects / Certs / Education — bullets tagged with REQ where applicable, rewritten ONLY from real evidence (cite `[E-xx]`). Labs in a separate LABS section, never under employment. Never fabricate metrics.
LinkedIn: Headline `<Title> | <Top 3 stacks> | <Domain>` · About in 3 paragraphs (who, proof, target) · pin JD-matched real skills first · feature portfolio labs. All truthful.

## Step 7 — Requirement Alignment Index (→ REPORT.md §1)

Dimensions and weights: Technical 25, Experience 20, Responsibilities 15, Certs 10, Education 5, Industry 5, Leadership 5, Cloud-Platform 5, Language 5, Location-Auth 5. Score each 0–100 with one-line justification. Total = Σ(score × weight)/100. Bands: ≥75 Strong / 55–74 Moderate / 35–54 Partial / <35 Low.

Calibration anchors: 85–100 current production evidence (tool + scale + date quoted) · 60–84 solid but incomplete · 35–59 weak PARTIAL · 10–34 GAP on the core ask (no AWS → Cloud ≤25; no active certs → Certs ≤40) · Language/Location 85–95 only with stated evidence, else 50–70 with UNKNOWN noted.

Print verbatim in §1: "This index summarizes documented requirement alignment. It is not a probability of interview, hiring, or job success."

## Quick-lane compression of the steps above (when the input routing picks quick)

Same scoring engine, same honesty, smaller artifact surface:

- Step 1-3: unchanged in substance — every REQ keeps id/type/status/priority/gating; evidence to 1-2 bullets per REQ (still per-REQ inline, REQ-traced).
- Step 4: top-3 gaps only (P0s first), each gap one-line `detail` + one-line `plan` + `reqIds`.
- Step 5-6: skipped (deferred to interview-prep / full lane).
- Step 7: dimensions still scored per calibration anchors — quick never inflates. `alignment.dimensions[]` still required in the JSON (each: name/weight/score/contribution + one-line justification).
