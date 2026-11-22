<div align="center">

# 🧩 OpenCode Skills Hub

**A curated collection of skills, agents, commands, and rules for [OpenCode](https://opencode.ai)**

[![Skills](https://img.shields.io/badge/Skills-42-10B981?style=for-the-badge)](#-skills-catalog)
[![Agents](https://img.shields.io/badge/Agents-8-8B5CF6?style=for-the-badge)](#-agents)
[![Commands](https://img.shields.io/badge/Commands-3-F59E0B?style=for-the-badge)](#-commands)
[![Rules](https://img.shields.io/badge/Rules-3-3B82F6?style=for-the-badge)](#-rules)
[![Plugin](https://img.shields.io/badge/Plugin-skill--creator-EC4899?style=for-the-badge)](#-plugin)

[Overview](#-overview) • [On-Disk Layout](#-on-disk-layout) • [Skills Catalog](#-skills-catalog) • [Agents](#-agents) • [Commands](#-commands) • [Rules](#-rules) • [Installation](#-installation) • [Usage](#-usage) • [Docs](#-docs) • [License](#-license)

</div>

---

# 📖 Overview

This repository is a curated, ready-to-use collection of **skills**, **agents**, **commands**, and **rules** for [OpenCode](https://opencode.ai). Drop the folders into your OpenCode config directory and they become available instantly.

What ships in this repo, as counted on disk:

| Kind | Count | Location | Installed to |
|------|-------|----------|--------------|
| Skills | **42** folders | `skills/` | `~/.config/opencode/skills/` |
| Agents | **8** | `agents/` | `~/.config/opencode/agents/` |
| Commands | **3** | `commands/` | `~/.config/opencode/commands/` |
| Rules | **3** | `rules/` | `~/.config/opencode/rules/` |
| Plugin | **1** (`opencode-skill-creator`) | `plugins/skill-creator/` | npm / OpenCode `plugin` array |

Skills are aggregated from [openskills.cc/skills](https://openskills.cc/skills), [web-dev-agent](https://github.com/Domenico-Tenace-Open-Labs/web-dev-agent), and a number of individual upstream authors. See [`docs/LICENSES.md`](docs/LICENSES.md).

Canonical docs live in [`docs/`](docs/): [`docs/SKILLS.md`](docs/SKILLS.md) is the full skills catalog, [`docs/INSTALLATION.md`](docs/INSTALLATION.md) covers setup, and [`docs/USAGE.md`](docs/USAGE.md) explains how to use everything.

---

# 📂 On-Disk Layout

What actually exists at the repo root:

```text
opencode-skills-hub/
├── README.md                       <- you are here
├── LICENSE                         <- collection license note
├── .gitignore
├── opencode.jsonc                  <- OpenCode config sample (rules + MCP + default agent)
├── install.ps1                     <- Windows installer
├── install.sh                      <- macOS / Linux installer
├── skills/                         <- 42 skill folders (each with a SKILL.md)
├── agents/                         <- 8 subagent/primary-agent definitions
├── commands/                       <- 3 slash commands
├── rules/                          <- 3 global rule files (Markdown)
├── plugins/
│   └── skill-creator/              <- opencode-skill-creator plugin (TypeScript + tests)
└── docs/                           <- documentation
    ├── INDEX.md
    ├── STRUCTURE.md
    ├── SKILLS.md
    ├── AGENTS.md
    ├── COMMANDS.md
    ├── RULES.md
    ├── INSTALLATION.md
    ├── USAGE.md
    ├── CONTRIBUTING.md
    ├── LICENSES.md
    └── SKILL-REGISTRATION.md
```

See [`docs/SKILLS.md`](docs/SKILLS.md) for the full skills catalog and [`docs/STRUCTURE.md`](docs/STRUCTURE.md) for skill anatomy, naming rules, and the folder → skill-name mapping.

---

# ℹ️ About the Project

* **What:** a curated collection of reusable skills, agents, commands, and rules for OpenCode.
* **Skills (42):** backend/frontend architecture, code review, security & SEO audits, accessibility, performance, UI/UX and design systems, research, memory systems, career tooling (job fit, resumes), English curriculum authoring, writing cleanup, and PowerShell enterprise automation.
* **Agents (8):** `code-simplifier` plus 7 specialists (accessibility, code review, documentation, security, SEO, UX/UI, web development). Two of them (`security-expert`, `web-developer`) are primary agents; the rest are subagents. See [`docs/AGENTS.md`](docs/AGENTS.md).
* **Commands (3):** `/code-review`, `/doc-compress`, `/scaffold-frontend-project`.
* **Rules (3):** `astro`, `bulma`, `clean-code` global baselines.
* **Plugin (1):** `opencode-skill-creator` — create, test, evaluate, and package skills; published on npm and kept in-tree under `plugins/`.
* **How to use:** run `./install.sh --all` or `.\install.ps1 -All`, or copy the folders manually into `~/.config/opencode/`. See [`docs/INSTALLATION.md`](docs/INSTALLATION.md).
* **Quality bar:** each skill is a self-contained folder with a `SKILL.md` carrying YAML frontmatter (`name`, `description`) plus optional `references/`, `scripts/`, `resources/`, or `assets/`. Bundled assets must be copied along with `SKILL.md`.
* **Start here:** [`docs/INSTALLATION.md`](docs/INSTALLATION.md) for setup, then [`docs/USAGE.md`](docs/USAGE.md).

---

# 🧩 Skills Catalog

42 skills, one folder each. Full descriptions and per-skill extras are in [`docs/SKILLS.md`](docs/SKILLS.md).

## Development & Architecture (7)
| Skill | Description |
|-------|-------------|
| `backend-architect` | Scalable API design, microservices architecture, distributed systems. |
| `software-architecture` | Quality-focused software architecture guidance. |
| `frontend-developer` | React components, responsive layouts, client-side state (React 19, Next.js 15). |
| `clean-code` | Clean Code principles by Robert C. Martin. |
| `code-refactoring-refactor-clean` | Refactoring with clean code, SOLID, modern best practices. |
| `code-documentation-doc-generate` | API docs, architecture diagrams, user guides, technical references. |
| `update-documentation` | Update READMEs, changelogs, API docs, comments, docstrings, examples. |

## Review, Security & Performance (5)
| Skill | Description |
|-------|-------------|
| `code-review` | Code review, testing, and bug fixing. |
| `frontend-accessibility` | Analyze frontends for accessibility issues and apply verified improvements. |
| `performance-optimizer` | Find performance and code-quality problems, then apply optimizations. |
| `security-audit` | Severity-ranked security audit of source, dependencies, config, and IaC. |
| `seo-audit` | SEO/marketing audit with concrete suggested fixes (never edits code). |

## UI / UX / Design (15)
| Skill | Description |
|-------|-------------|
| `frontend-design` | Distinctive, intentional visual design; avoid templated defaults. |
| `impeccable` | Design, redesign, audit, polish, animate, and document frontend interfaces. |
| `ui-design` | Layouts, components, visual hierarchy, grids, design tokens. |
| `ux-design` | User research, IA, interaction patterns, five-plane model, UX laws. |
| `ui-patterns` | Real-world UI patterns from shipped products. |
| `design-process` | Briefing → concept → wireframe → prototype → review → handoff. |
| `design-trends` | Award-winning patterns and emerging techniques (Q1/Q2 2026). |
| `responsive-design` | Mobile-first strategy, breakpoints, fluid layouts, Grid/Flexbox. |
| `ui-skills` | Opinionated constraints for building interfaces. |
| `ui-ux-designer` | Interface designs, wireframes, design systems. |
| `ui-ux-pro-max` | Comprehensive web and mobile design guide. |
| `agent-ui-design` | Chat/agent UX, streaming UI, tool execution cards. |
| `ai-design-workflow` | AI tooling in design work, prompting, review workflows. |
| `branding-identity` | Brand strategy, visual identity, positioning, consistency. |
| `theme-factory` | 10 preset themes with colors and fonts for artifacts. |

## Planning & Research (3)
| Skill | Description |
|-------|-------------|
| `writing-plans` | Turn a spec into a bite-sized, file-and-test-level implementation plan. |
| `deep-research` | Autonomous research: plan, search, read, synthesize into reports. |
| `interview-me` | One-question-at-a-time interview to surface real intent. |

## Memory, Files & Productivity (4)
| Skill | Description |
|-------|-------------|
| `agent-memory-mcp` | Hybrid persistent memory system for AI agents. |
| `agent-memory-systems` | Tenant-scoped memory, RAG, retrieval, retention. |
| `file-organizer` | Organize files with duplicate review before changes. |
| `markitdown` | Convert documents and URIs to Markdown (Microsoft MarkItDown). |

## Skill Tooling (2)
| Skill | Description |
|-------|-------------|
| `skill-creator` | Create, edit, evaluate, and optimize skills. |
| `opencode-skill-creator` | Same workflow built on the OpenCode plugin's tools. |

## Career & Business (5)
| Skill | Description |
|-------|-------------|
| `jobfit-intelligence` | Job-fit analysis, gap analysis, salary intelligence, interview prep. |
| `review-resume` | PM resume review against 10 best practices. |
| `tailored-resume-generator` | Generate resumes tailored to a job description. |
| `business-english-it-pro` | Business/IT English curriculum factory v3.3 (folder `Business-English-IT-Pro-Skill`). |

## Writing (1)
| Skill | Description |
|-------|-------------|
| `mo-humanizer` | Rewrite AI-sounding prose without changing meaning (AI tells, filler, inflated claims; Arabic, English, mixed technical). |

## Platform (1)
| Skill | Description |
|-------|-------------|
| `powershell-enterprise-admin` | PowerShell tooling, WPF GUIs, Intune remediation, Graph/Entra automation. |

---

# 🤖 Agents

| Agent | Mode | Description |
|-------|------|-------------|
| `code-simplifier` | subagent | Refines recently modified code for clarity and consistency without changing behavior. |
| `accessibility-expert` | subagent | WCAG 2.2 AA audit; proposes fixes, applies after approval. |
| `code-reviewer` | subagent | Reviews changes; proposes fixes, applies after approval. |
| `documentation-updater` | subagent | Keeps docs in sync with code; proposes first. |
| `security-expert` | primary | Vulnerability and misconfiguration audit across source, secrets, deps, IaC. |
| `seo-expert` | subagent | On-page, technical, and content SEO audit. |
| `ux-ui-expert` | subagent | UI/UX and graphics design and review. |
| `web-developer` | primary | Astro, Vue, TypeScript, modern frontend work. |

All agents are sandboxed to the current workspace and gate every edit behind approval. Details in [`docs/AGENTS.md`](docs/AGENTS.md).

---

# ⚡ Commands

| Command | Description |
|---------|-------------|
| `/code-review` | Review a pull request and post findings with `gh`. |
| `/doc-compress` | Compress memory docs into caveman format, keeping a `.original.md` backup. |
| `/scaffold-frontend-project` | Scaffold a 3-page pnpm frontend project. |

Details in [`docs/COMMANDS.md`](docs/COMMANDS.md).

---

# 📏 Rules

| Rule | Purpose |
|------|---------|
| `astro` | Astro project structure and conventions (styling-agnostic). |
| `bulma` | Bulma CSS conventions (template-agnostic). |
| `clean-code` | Language-agnostic clean-code baseline applied to every edit. |

`opencode.jsonc` loads them with `"instructions": ["~/.config/opencode/rules/*.md"]`. Details in [`docs/RULES.md`](docs/RULES.md).

---

# 🔌 Plugin

`plugins/skill-creator/` is the source of the npm package **`opencode-skill-creator`** (v0.2.25): TypeScript tools for validating, evaluating, benchmarking, and optimizing skills.

```bash
npx opencode-skill-creator install --global
```

It is not installed by `install.sh` / `install.ps1`; see [`plugins/skill-creator/README.md`](plugins/skill-creator/README.md).

---

# 🚀 Installation

## Quick install (recommended)

Windows:
```powershell
.\install.ps1 -All
```

macOS / Linux:
```bash
chmod +x install.sh && ./install.sh --all
```

Selective: `.\install.ps1 -Skills -Agents` or `./install.sh --skills --agents`.

The installers merge recursively into `~/.config/opencode/{skills,agents,commands,rules}` and never delete anything you already have.

## Windows (PowerShell) — manual

```powershell
$cfg = "$env:USERPROFILE\.config\opencode"
New-Item -ItemType Directory -Force -Path "$cfg\skills","$cfg\agents","$cfg\commands","$cfg\rules" | Out-Null
Copy-Item -Recurse .\skills\*   "$cfg\skills\"
Copy-Item -Recurse .\agents\*   "$cfg\agents\"
Copy-Item -Recurse .\commands\* "$cfg\commands\"
Copy-Item -Recurse .\rules\*    "$cfg\rules\"
```

## macOS / Linux — manual

```bash
cfg="$HOME/.config/opencode"
mkdir -p "$cfg/skills" "$cfg/agents" "$cfg/commands" "$cfg/rules"
cp -r skills/*   "$cfg/skills/"
cp -r agents/*   "$cfg/agents/"
cp -r commands/* "$cfg/commands/"
cp -r rules/*    "$cfg/rules/"
```

## Selective install

```powershell
$cfg = "$env:USERPROFILE\.config\opencode"
Copy-Item -Recurse .\skills\frontend-design "$cfg\skills\"
```

Restart OpenCode after installing. See [`docs/INSTALLATION.md`](docs/INSTALLATION.md) for verification, updates, and removal.

---

# 🧭 Usage

* **Skills** are loaded by OpenCode via the `skill` tool using the skill's `name` (from `SKILL.md` frontmatter). Request explicitly: *"Use the clean-code skill to refactor this module."*
* **Agents** in `agents/` are invoked as subagents (e.g. `code-simplifier` runs after code edits) or selected as primary agents.
* **Commands** are invoked with `/`: `/code-review 123`, `/doc-compress`, `/scaffold-frontend-project`.
* **Rules** are global instruction files applied across agents.

See [`docs/USAGE.md`](docs/USAGE.md) for best practices.

---

# 📚 Docs

* [`docs/INDEX.md`](docs/INDEX.md) — documentation index and quick start.
* [`docs/STRUCTURE.md`](docs/STRUCTURE.md) — repository layout, skill anatomy, naming rules.
* [`docs/SKILLS.md`](docs/SKILLS.md) — complete skills catalog (42 folders).
* [`docs/AGENTS.md`](docs/AGENTS.md) — agent definitions, modes, permissions.
* [`docs/COMMANDS.md`](docs/COMMANDS.md) — slash commands reference.
* [`docs/RULES.md`](docs/RULES.md) — global rules reference.
* [`docs/INSTALLATION.md`](docs/INSTALLATION.md) — install, verify, update, remove.
* [`docs/USAGE.md`](docs/USAGE.md) — how to use skills, agents, commands.
* [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) — contributing guide.
* [`docs/LICENSES.md`](docs/LICENSES.md) — license inventory.

---

## 👤 Author

**Mohammad Abdelkader Omar**
GitHub: [@mabdulkadr](https://github.com/mabdulkadr)
Website: [momar.tech](https://momar.tech)

---

## 📜 License

Individual skills may carry their own licenses (see `docs/LICENSES.md` and license files inside skill folders). The collection itself is provided as-is. See [`docs/LICENSES.md`](docs/LICENSES.md).

---

## ⚠ Disclaimer

This project and every script it contains are provided as-is with no warranty of any kind. Test in a staging environment before deploying to production. The authors assume no liability for any damage or data loss resulting from their use. Skills are sourced from third parties — please respect upstream licenses and terms.

---

<div align="center">

⭐ **If this project saves you time, star the repo — it helps others find it.**

[Report an Issue](../../issues) · [momar.tech](https://momar.tech)

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/mabdulkadrx)

Built with [**OpenCode**](https://opencode.ai)

</div>
