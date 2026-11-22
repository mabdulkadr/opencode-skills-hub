# Repository Structure

## Top-level layout

```
opencode-skills-hub/
├── README.md          # Project overview and catalog
├── LICENSE            # Collection-level license note
├── .gitignore
├── opencode.jsonc     # OpenCode config sample: default agent, rules glob, MCP server
├── install.ps1        # Windows installer (merge copy)
├── install.sh         # macOS / Linux installer (merge copy)
├── skills/            # 42 skill folders, each with SKILL.md
├── agents/            # 8 agent definitions (.md)
├── commands/          # 3 slash commands (.md)
├── rules/             # 3 global rule files (.md)
├── plugins/
│   └── skill-creator/ # opencode-skill-creator plugin source (TypeScript, tests)
└── docs/              # Documentation
```

Counts are verified on disk: 42 folders under `skills/`, each containing a `SKILL.md`.

## Skill anatomy

Each skill is a folder under `skills/<folder>/` containing at minimum a `SKILL.md`:

```
skills/<folder>/
├── SKILL.md           # Required: YAML frontmatter (name, description) + instructions
├── LICENSE / LICENSE.txt / UPSTREAM-LICENSE.txt   # Optional: upstream license
├── references/        # Optional: detailed guides, per-topic documents
├── reference/         # Optional: same idea (some upstreams use the singular)
├── scripts/           # Optional: helper scripts
├── resources/         # Optional: implementation playbooks
├── assets/            # Optional: templates, checklists
├── data/              # Optional: datasets used by the skill
└── templates/         # Optional: file scaffolds
```

Optional metadata keys seen in frontmatter: `risk`, `source`, `date_added`, `license`, `version`, `metadata`, `allowed-tools`. OpenCode requires only `name` and `description`; the rest is informational.

### SKILL.md frontmatter

```yaml
---
name: skill-name
description: "Short description of when to use this skill."
---
```

The body contains the full instructions the agent follows when the skill is invoked. `description` is what drives automatic skill selection, so it should state both *what* the skill does and *when* to use it.

### Folder name vs. skill name

OpenCode keys skills off `name`, not the folder. Most folders match their skill name; one does not:

| Folder | `name` |
|--------|--------|
| `skills/Business-English-IT-Pro-Skill/` | `business-english-it-pro` |

## Agents

Files in `agents/` are Markdown with frontmatter plus the agent's system prompt.

```yaml
---
description: What the agent does and when to use it.
mode: subagent        # or: primary
color: "#hex"         # optional UI accent
permissions:          # optional list of {action, resource, effect}
  - action: skill
    resource: code-review
    effect: allow
---
```

`mode` determines how the agent is reached: `primary` agents are selectable directly, `subagent` agents are launched by another agent or by the user as a delegated task. Six of the eight agents add a `permissions` list that allows specific skills, allows web access and MCP tools, sets `edit` to `ask` (every write needs approval), and denies `external_directory` last so the agent stays inside the workspace.

## Commands

Files in `commands/` are Markdown with frontmatter (`description`) plus the command template.

```yaml
---
description: One line shown in the command list.
---
```

The body is the prompt run when the command is invoked; `$ARGUMENTS` is replaced with whatever follows the command name. A command file at `commands/code-review.md` is invoked as `/code-review`.

## Rules

Files in `rules/` are plain Markdown instruction files with no frontmatter. They are global and stack-agnostic where possible:

| File | Scope |
|------|-------|
| `rules/astro.md` | Astro projects (styling-agnostic; pair with `bulma.md`) |
| `rules/bulma.md` | Bulma CSS (template-agnostic; pair with `astro.md`) |
| `rules/clean-code.md` | Every file, any stack |

`opencode.jsonc` wires them up with `"instructions": ["~/.config/opencode/rules/*.md"]`.

## Plugins

`plugins/skill-creator/` is the source of the npm package `opencode-skill-creator` (v0.2.25). It is a TypeScript OpenCode plugin, not a skill, and is installed separately:

```bash
npx opencode-skill-creator install --global
```

Layout:

```
plugins/skill-creator/
├── bin/               # CLI entry point
├── dist/              # Build output (published files)
├── lib/               # TypeScript sources (validate, eval, improve-description, report, …)
├── skill/             # The SKILL.md that ships with the plugin
├── templates/         # eval viewer HTML
├── scripts/build.mjs  # Build script
└── test/              # node:test + bun tests
```

`skills/opencode-skill-creator/` is the end-user skill that drives this plugin; the two are separate artifacts.

## OpenCode config mapping

| Repo folder | OpenCode config path |
|-------------|----------------------|
| `skills/` | `~/.config/opencode/skills/` |
| `agents/` | `~/.config/opencode/agents/` |
| `commands/` | `~/.config/opencode/commands/` |
| `rules/` | `~/.config/opencode/rules/` (referenced via `instructions` in `opencode.jsonc`) |
| `opencode.jsonc` | `~/.config/opencode/opencode.jsonc` (optional sample config) |
| `plugins/skill-creator/` | installed via npm, referenced in the `plugin` array |

## What is not copied by the installers

`install.ps1` and `install.sh` only copy `skills/`, `agents/`, `commands/`, and `rules/`. They do not copy:

- `plugins/` — the skill-creator plugin installs through npm.
- `opencode.jsonc` — copy it yourself if you want the sample default agent, rules glob, and `gh_grep` MCP server.
- `docs/` and `README.md` — documentation only.
