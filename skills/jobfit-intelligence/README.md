<div align="center">

# 🎯 JobFit Intelligence

**Evidence-Based Job Fit, Gap Analysis, Salary Intelligence, and Interview Prep**

An agent skill that compares a real candidate profile against a real job description and produces a verifiable decision package.

[![Skill](https://img.shields.io/badge/Skill-OpenCode%20Agent-8B5CF6?style=for-the-badge)](#-overview)
[![Pipeline](https://img.shields.io/badge/Pipeline-7%20Engines-10B981?style=for-the-badge)](#-core-features)
[![Outputs](https://img.shields.io/badge/Outputs-10%20Files%20plus%20HTML-5391FE?style=for-the-badge)](#-scripts-included)
[![Mode](https://img.shields.io/badge/Mode-Online%20with%20Offline%20Fallback-0F172A?style=for-the-badge)](#-requirements)
[![Evidence](https://img.shields.io/badge/Evidence-No%20Fabrication-334155?style=for-the-badge)](#-operational-notes)
[![License](https://img.shields.io/badge/License-MIT-F59E0B?style=for-the-badge)](#-license)

[Overview](#-overview) • [Features](#-core-features) • [Structure](#-project-structure) • [Files](#-scripts-included) • [Requirements](#-requirements) • [License](#-license)

</div>

---

# 📖 Overview

**JobFit Intelligence** is an OpenCode skill that acts as senior technical recruiter, hiring manager, career strategist, salary analyst, and interview coach in one pipeline. It never exaggerates the candidate. Every claim is labeled as proven experience, reasonable inference with evidence, unknown, or gap, and every external claim carries a source.

Given a job URL or pasted job description plus a reusable candidate master profile, the skill produces one folder per job with a 12-section `REPORT.md`, a `SOURCES.md` ledger, and a self-contained HTML dashboard. The folder is never overwritten: a repeated analysis for the same company and role appends `-2`, `-3`.

Typical inputs: a job link, a pasted job description, `compare-cv <job-slug>`, `salary <job-slug>`, `interview-prep <job-slug>`, or `update-profile`.

---

# ✨ Core Features

### 🔹 Command Routing Before Execution

* URL only runs the full pipeline from fetch to dashboard.
* Pasted job text skips fetching and uses the verbatim-text workflow.
* `compare-cv`, `salary`, and `interview-prep` reuse the stored job folder and candidate profile for partial runs.
* `update-profile` edits candidate files only.

### 🔹 Seven-Engine Pipeline

* Input Layer acquires the job description and normalizes the CV without inventing details.
* Analysis builds the requirement matrix (`REQ-xxx` IDs) with `MATCH`, `PARTIAL`, `GAP`, and `UNKNOWN` plus priorities `P0` through `P3`, gating flags, and a transparent Requirement Alignment Index.
* Research collects live salary data (title → country → city → seniority → industry) with low, typical, and high bands plus base/total split and claim IDs.
* Analysis also writes the phased roadmap (0-2, 2-6, 6-12 weeks), portfolio projects, CV rewrite, and LinkedIn optimization from real evidence only.
* Interview writes HR, technical, behavioral (STAR), scenario, and candidate-specific questions (each traced to a REQ) with answers, a study guide, a 5-round mock interview, a cheat sheet, due-diligence questions, application strategy, and a 30-60-90 plan.
* Output writes `REPORT.md` (12 sections), `SOURCES.md`, and `index.html` with identical statuses and numbers everywhere.
* QA checklist (at the end of `references/output.md`) blocks delivery on failure.

### 🔹 Requirement Alignment Index (not a probability)

* Weights: Technical 25, Experience 20, Responsibilities 15, Education 5, Certs 10, Industry 5, Leadership 5, Cloud-Platform 5, Language 5, Location-Authorization 5, total 100.
* Bands: 75 and above Strong, 55-74 Moderate, 35-54 Partial, below 35 Low.
* Every score display carries the sentence: This index summarizes documented requirement alignment. It is not a probability of interview, hiring, or job success.
* Gating requirements (certs, authorization, language, clearance, mandatory years) are never averaged away — a gating GAP caps readiness.

### 🔹 Honest Gap Handling

* Gaps are written as gaps with a lab plan, never filled with invented experience.
* Interview answers for gaps use the bridge pattern: no direct production experience stated plainly, adjacent real experience cited, lab implementation described, production approach listed.
* Readiness uses exactly one of `READY NOW`, `READY WITH TARGETED PREPARATION`, `SIGNIFICANT PREPARATION REQUIRED`, or `CURRENTLY MISALIGNED`.

### 🔹 Reusable Candidate System

* One master profile under `candidate/` reused across all jobs.
* One folder per job under `jobs/<company>-<role-slug>/`.
* CV PDFs are read and normalized into Markdown once, then reused without asking again.

---

# 📂 Project Structure

```text
jobfit-intelligence/
├── README.md                        <- you are here
├── SKILL.md                         <- agent definition, routing, pipeline
├── references/                      <- 5 specs (read as needed)
│   ├── input.md                     <- tool mapping, JD acquisition, CV-first profile
│   ├── analysis.md                  <- REQ IDs, MATCH rule, gating, gaps, roadmap, CV/LinkedIn, index
│   ├── research.md                  <- salary methodology, claim IDs, company spec
│   ├── interview.md                 <- REQ-traced questions, due diligence, strategy, 30-60-90
│   └── output.md                    <- 12-section REPORT + SOURCES.md + dashboard + QA
└── assets/                          <- starting templates
    ├── candidate-profile-template.md <- starter for candidate/profile.md (single file)
    └── dashboard-template.html       <- self-contained dashboard base
```

Generated workspaces (created at runtime, not stored in this repo):

```text
candidate/
└── profile.md
jobs/
└── <company>-<role-slug>/
    ├── REPORT.md      # 12 sections: summary → readiness
    ├── SOURCES.md     # [Sxxx] salary/market/company claims
    └── index.html
```

---

# 🚀 Scripts Included

## 🔎 Skill Definition (Agent Config)

**File**

```powershell
SKILL.md
```

### Purpose

Defines the agent role, operating principles, command routing table, slug rule, execution pipeline order, fit-score weights, status vocabulary, bridge answer pattern, reference file map, asset paths, and readiness vocabulary.

### Example

```text
analyze-job https://company.example/careers/senior-system-engineer
compare-cv microsoft-senior-system-engineer
salary microsoft-senior-system-engineer
interview-prep microsoft-senior-system-engineer
update-profile
```

## 🔎 Engine References (Pipeline Specs)

**Files**

```powershell
references/input.md
references/analysis.md
references/research.md
references/interview.md
references/output.md
```

### Purpose

Each file is the executable specification for one pipeline stage. The orchestrator reads them in order and delegates the stage to that file. They define workflows (URL fetch with redirect refetch and pasted-text fallback), matrix columns, salary search queries and source tables, roadmap phases, interview banks and mock structure, output file specs and dashboard badge colors (`MATCH` green, `PARTIAL` amber, `GAP` red, `UNKNOWN` gray), and the QA audit checklist.

### Exit States

| State | Meaning |
|---|---|
| Complete package | `REPORT.md` + `SOURCES.md` + `index.html`, QA passed |
| Weak-data package | Salary or market sections marked with the exact weak-data disclaimer, produced fully offline |
| Blocked | QA audit failed, failures fixed before finishing |

## 🧰 Core Commands

| Command | Purpose | Docs |
|---|---|---|
| `analyze-job <URL>` | Full pipeline from job fetch to dashboard | [OpenCode Skills](https://opencode.ai/docs) |
| `compare-cv <job-slug>` | Reuses candidate profile and stored job description | [OpenCode Skills](https://opencode.ai/docs) |
| `salary <job-slug>` | Research engine only for compensation and market context | [OpenCode Skills](https://opencode.ai/docs) |
| `interview-prep <job-slug>` | Interview engine only for questions, mock, and 30-60-90 | [OpenCode Skills](https://opencode.ai/docs) |

> The reader should be able to understand the full job-fit decision from these four commands plus the generated `REPORT.md §1`.

---

# ⚙️ Requirements

### Operating System

* Any OS that runs the OpenCode agent (Windows 10 / 11 verified).

### Agent Tools

* File read for CV PDFs and Markdown profiles.
* Web fetch for job URLs, with redirect refetch and pasted-text fallback.
* Web search for salary and market research. When search or fetch is unavailable, the skill runs fully offline and marks salary and market sections as weak-data with the exact disclaimer sentence.

### Permissions

* Read the candidate profile and job folder. Write one new job folder per analysis. No elevation, no credentials, no external services beyond public web search and fetch.

---

## 🏗️ Architecture

The pipeline is strictly ordered: Input, Analysis, Research, Interview, Output (with QA checklist at the end). Statuses and salary numbers are computed once and copied identically into every output file. The HTML dashboard is a single self-contained file with inline CSS, system fonts, card grid, badge colors, and in-page anchors only. No frameworks, no external assets.

## 🔍 Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Job URL fetch fails or redirects | Source site blocks fetch or moves the posting | Paste the full job text; the skill switches to the verbatim-text workflow |
| Salary section marked weak-data | Search tool unavailable or no reliable sources found | Treat the band as indicative only; rerun `salary <job-slug>` when search is available |
| Slug folder already exists | Same company and role analyzed before | The skill appends `-2`, `-3` automatically; never rename or merge manually |
| Candidate files empty on first run | No master profile yet | Copy `assets/candidate-profile-template.md` into `candidate/`, fill once, then run `update-profile` |

## ❓ FAQ

**Does the skill rewrite my CV with invented achievements?**

No. CV and LinkedIn outputs use only real evidence. Missing experience is written as a gap with a lab plan.

**Is the fit score a hiring prediction?**

No. It is a heuristic alignment signal with published weights and bands.

**Can I run it offline?**

Yes. The full package is produced offline with weak-data marking on salary and market sections.

**How is one job kept separate from another?**

Each analysis lives in its own `jobs/<company>-<role-slug>/` folder with its own sources file and dashboard.

---

# 🛡 Operational Notes

* Never invent experience, certifications, projects, metrics, salary numbers, or company facts.
* Every recommendation must trace to an identified requirement ID (`REQ-xxx`).
* Every external claim carries `[Sxxx]` with a block in `SOURCES.md`. Weak evidence is stated explicitly.
* Output reports are written in English. Chat may follow the user language.
* Never overwrite a prior job folder. Suffix and keep history.
* Keep requirement status and salary numbers identical across REPORT.md, SOURCES.md, and the dashboard.

---

## 👤 Author

**Mohammad Abdelkader Omar**
GitHub: [@mabdulkadr](https://github.com/mabdulkadr)
Website: [momar.tech](https://momar.tech)

---

## 📜 License

MIT License. If you fork this skill into a public repository, add the standard MIT `LICENSE` file at the root.

---

## ⚠ Disclaimer

This skill and every script it generates are provided as-is with no warranty of any kind. Test generated tools in a staging environment before deploying to production. The authors assume no liability for any damage or data loss resulting from their use.

> Career note: fit scores and salary bands are research signals, not offers or hiring decisions. Verify critical application details against the original posting and independent sources.

---

<div align="center">

⭐ **If this skill saves you time, star the repo — it helps others find it.**

[Report an Issue](../../issues) · [momar.tech](https://momar.tech)

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/mabdulkadrx)

Built with [**PowerShell Enterprise Admin**](https://github.com/mabdulkadr/powershell-enterprise-admin-skill)

</div>
