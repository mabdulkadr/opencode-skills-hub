# Usage

## How loading works

| Kind | Loaded by | Keyed on | Invoked as |
|------|-----------|----------|------------|
| Skills | `skill` tool | `name` in `SKILL.md` frontmatter | automatic, or "use the `<name>` skill" |
| Agents | OpenCode agent registry | file name in `agents/` | subagent launch, or primary agent selection |
| Commands | command registry | file name in `commands/` | `/command-name [arguments]` |
| Rules | config `instructions` glob | file path | applied automatically |

## Using skills

OpenCode selects a skill when the request matches its `description`; you can also name it explicitly:

> "Use the clean-code skill to refactor this module."
> "Use `security-audit` on this repo."

One name differs from its folder — use the frontmatter name: `business-english-it-pro` lives in the folder `Business-English-IT-Pro-Skill`.

Skills run inside the current session, so the same conversation can chain them: plan with `writing-plans`, implement, then `code-review` and `frontend-accessibility`.

### Choosing between similar skills

| You want | Use |
|----------|-----|
| Review a diff or PR | `code-review` |
| Find vulnerabilities | `security-audit` |
| Fix SEO metadata | `seo-audit` (suggests only) |
| Speed up / slim down code | `performance-optimizer` |
| Make a UI look intentional | `frontend-design` or `impeccable` |
| Layout, tokens, components | `ui-design` |
| Research and IA | `ux-design` |
| Full page/site critique | `impeccable` |
| Update docs after a refactor | `update-documentation` |
| Write a plan before coding | `writing-plans` |
| Strip AI tells from prose | `mo-humanizer` |

## Using agents

Subagents are delegated to; primary agents are selected as the session's agent.

```
> Have code-simplifier clean up the files I just changed.
> Ask accessibility-expert to audit the checkout form.
> Switch to security-expert and review this repo.
```

Because every specialist agent has `edit: ask`, expect a confirmation prompt before any write. That is intentional — the agents audit and propose first.

`web-developer` is the `default_agent` in the sample `opencode.jsonc`; remove that key if you'd rather start with the general agent.

## Using commands

```
/code-review 123
/code-review https://github.com/owner/repo/pull/123
/doc-compress AGENTS.md
/scaffold-frontend-project astro my-site
```

Commands are prompt templates, so their output quality depends on the repository they run in. `/code-review` posts to GitHub via `gh`, so it needs an authenticated CLI and a PR number.

## Using rules

Rules are standing instructions. There is nothing to invoke; they are already in context when `instructions` points at `~/.config/opencode/rules/*.md`. To scope a rule to one stack, keep only that file in the rules directory.

## Skill anatomy tips

- Keep `SKILL.md` next to its assets (scripts, references) and copy folders whole.
- Do not flatten nested asset folders.
- Descriptions should state both what the skill does and when to use it — they drive automatic selection.
- `name` must be unique across installed skills; two folders with the same name overwrite each other.

## Best practices

- Install only the skills you need; a long skill list dilutes automatic selection.
- Re-run the installer after pulling updates.
- Pin or note which version of a duplicated skill you installed.
- Check upstream licenses before redistributing individual skills.
- Put project-specific overrides in the project's `AGENTS.md`, not in the global rules.
