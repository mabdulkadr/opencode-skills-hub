# Documentation Index

Documentation for the OpenCode Skills Hub. Every page describes the repository as it exists on disk.

## Start here

1. [Repository README](../README.md) — what the project is, catalog overview, quick install.
2. [INSTALLATION.md](INSTALLATION.md) — install, verify, update, remove.
3. [USAGE.md](USAGE.md) — how skills, agents, commands, and rules load and get invoked.

## Reference

| File | Purpose |
|------|---------|
| [STRUCTURE.md](STRUCTURE.md) | Repository layout, skill anatomy, naming rules, config mapping |
| [SKILLS.md](SKILLS.md) | Complete catalog: 42 skills and their bundled extras |
| [AGENTS.md](AGENTS.md) | All 8 agents: modes, required skills, permission model |
| [COMMANDS.md](COMMANDS.md) | The 3 slash commands and their workflows |
| [RULES.md](RULES.md) | The 3 global rule files and how they are wired up |
| [LICENSES.md](LICENSES.md) | Collection license note and per-skill upstream license files |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to add a skill, agent, command, or rule |
| [SKILL-REGISTRATION.md](SKILL-REGISTRATION.md) | Post-install verification checklist |

## At a glance

| Kind | Count | Folder |
|------|-------|--------|
| Skills | 42 | [`skills/`](../skills/) |
| Agents | 8 | [`agents/`](../agents/) |
| Commands | 3 | [`commands/`](../commands/) |
| Rules | 3 | [`rules/`](../rules/) |
| Plugin | 1 (`opencode-skill-creator`) | [`plugins/skill-creator/`](../plugins/skill-creator/) |

## Note

- `rules/` requires an `instructions` entry in `opencode.jsonc`; copying the files alone does nothing.

## Quick links

- [Skills folder](../skills/)
- [Agents folder](../agents/)
- [Commands folder](../commands/)
- [Plugin source](../plugins/skill-creator/)
