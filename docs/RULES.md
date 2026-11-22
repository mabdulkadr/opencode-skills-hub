# Rules

Rules are global instruction files (plain Markdown, no frontmatter) applied across agents and every file they write. Source: [web-dev-agent](https://github.com/Domenico-Tenace-Open-Labs/web-dev-agent).

| Rule | File | Lines | Purpose |
|------|------|-------|---------|
| `astro` | `rules/astro.md` | 86 | Astro project structure and conventions. Styling-agnostic — pair with a CSS-solution rule file (`bulma.md`) rather than duplicating it. |
| `bulma` | `rules/bulma.md` | 52 | Bulma CSS conventions. Template-agnostic — works with Astro, plain HTML, React, Vue. Use Bulma utility classes as intended and prefer Bulma over custom CSS. |
| `clean-code` | `rules/clean-code.md` | 156 | Language-agnostic clean-code baseline applied to every file, any stack. Project conventions win only when stricter; otherwise this file wins. |

## How rules are applied

Rules are not copied per project. They are loaded globally through the `instructions` glob in `opencode.jsonc`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "web-developer",
  "instructions": ["~/.config/opencode/rules/*.md"],
  "mcp": {
    "gh_grep": { "type": "remote", "url": "https://mcp.grep.app" }
  }
}
```

Every request then carries the rule files as standing instructions. Because the glob matches all `.md` files in that directory, adding a rule file is enough; no config edit required.

## Precedence

`clean-code.md` states the precedence explicitly: project conventions (`AGENTS.md`, linter config, existing style) win **only** when they are stricter than the rule. When in doubt, the rule file wins. That keeps the baseline from being diluted by loose project configs.

## Using a subset

If you don't want all three active, either copy only the rule files you want into `~/.config/opencode/rules/` or list them individually:

```jsonc
"instructions": ["~/.config/opencode/rules/clean-code.md"]
```

## Installation

```powershell
# Windows
Copy-Item .\rules\* "$env:USERPROFILE\.config\opencode\rules\"
```

```bash
# macOS / Linux
cp rules/*.md ~/.config/opencode/rules/
```

Then make sure `opencode.jsonc` (or your own config) contains the `instructions` glob. Run `.\install.ps1 -Rules` / `./install.sh --rules` to copy the files; the config entry is not added automatically.
