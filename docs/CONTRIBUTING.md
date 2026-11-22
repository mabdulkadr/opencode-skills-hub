# Contributing

## Adding a skill

1. Create a folder `skills/<skill-name>/`.
2. Add `SKILL.md` with YAML frontmatter containing at least `name` and `description`.
3. Add supporting assets (`references/`, `scripts/`, `resources/`, `assets/`) if needed — keep them inside the skill folder.
4. Include the upstream license file when applicable.
5. Update [`SKILLS.md`](SKILLS.md) and the catalog in [`../README.md`](../README.md).

### Rules for skills

- **The `name` must be unique across all installed skills.** OpenCode keys skills off `name`, so a duplicate silently shadows another skill at install time.
- Prefer `name` == folder name. If they must differ (as with `business-english-it-pro` in `Business-English-IT-Pro-Skill/`), note the mapping in [`STRUCTURE.md`](STRUCTURE.md).
- `description` drives automatic selection: state what the skill does **and** when to use it, including trigger phrases.
- Do not paste a license into `SKILL.md`; ship a `LICENSE`/`LICENSE.txt` file and reference it.
- Keep the frontmatter honest — do not claim `risk: safe` for a skill that runs shell commands.

### Frontmatter shape

```yaml
---
name: skill-name
description: "What it does and when to use it."
---
```

Optional metadata used elsewhere in this repo: `risk`, `source`, `date_added`, `license`, `version`, `metadata`, `allowed-tools`.

## Adding an agent

1. Create `agents/<agent-name>.md` with frontmatter (`description`, `mode`, optional `color`, optional `permissions`).
2. Write the system prompt body.
3. Document it in [`AGENTS.md`](AGENTS.md), including the skills it needs.
4. Document the skills it allows in the permission list.

Permission baseline for specialist agents in this repo:

```yaml
permissions:
  - action: skill
    resource: <skill-name>
    effect: allow
  - action: edit
    resource: "*"
    effect: ask          # approval gate
  - action: webfetch
    resource: "*"
    effect: allow
  - action: websearch
    resource: "*"
    effect: allow
  - action: "*_*"        # MCP tools
    resource: "*"
    effect: allow
  - action: external_directory
    resource: "*"
    effect: deny         # must stay last — last match wins
```

## Adding a command

1. Create `commands/<command-name>.md` with frontmatter (`description`).
2. Use `$ARGUMENTS` for input, and document the expected argument order.
3. Document it in [`COMMANDS.md`](COMMANDS.md).
4. If the command overwrites files (like `/doc-compress`), document the backup path.

## Adding a rule

1. Create `rules/<rule-name>.md` as plain Markdown — no frontmatter.
2. Keep it stack-scoped where possible; avoid duplicating a sibling rule's content.
3. State precedence explicitly if the rule can conflict with project conventions.
4. Add it to [`RULES.md`](RULES.md). No config change is needed — the `instructions` glob picks it up.

## Pull requests

- Keep changes focused.
- Update documentation in the same change as the code or content.
- Run the install step once (`./install.sh --all` in a scratch `HOME`) to confirm the files land where expected.
- Verify counts in `README.md`, `docs/INDEX.md`, `docs/STRUCTURE.md`, and `docs/SKILLS.md` still match the tree.
- Respect upstream licenses and record their sources.
