# Installation

## Prerequisites

- [OpenCode](https://opencode.ai) installed.
- Write access to `~/.config/opencode/` (`%USERPROFILE%\.config\opencode` on Windows).
- Optional: `gh` CLI for `/code-review`, `pnpm` for `/scaffold-frontend-project`, Python + `uv` for `markitdown` and `deep-research`.

## Quick install

The installers copy `skills/`, `agents/`, `commands/`, and `rules/` into your OpenCode config with a recursive merge. Existing files are overwritten; nothing is deleted.

Windows:

```powershell
.\install.ps1 -All
```

macOS / Linux:

```bash
chmod +x install.sh && ./install.sh --all
```

With no arguments, both installers behave like `--all`.

### Selective install

| Windows | macOS / Linux | Copies |
|---------|---------------|--------|
| `.\install.ps1 -Skills` | `./install.sh --skills` | `skills/` |
| `.\install.ps1 -Agents` | `./install.sh --agents` | `agents/` |
| `.\install.ps1 -Commands` | `./install.sh --commands` | `commands/` |
| `.\install.ps1 -Rules` | `./install.sh --rules` | `rules/` |

Flags combine: `.\install.ps1 -Skills -Agents` / `./install.sh --skills --agents`.

The installers do **not** copy `plugins/`, `opencode.jsonc`, or `docs/`. See [Plugin install](#plugin-install) and [Config](#config).

## Manual install

Windows (PowerShell):

```powershell
$cfg = "$env:USERPROFILE\.config\opencode"
New-Item -ItemType Directory -Force -Path "$cfg\skills","$cfg\agents","$cfg\commands","$cfg\rules" | Out-Null
Copy-Item -Recurse .\skills\*   "$cfg\skills\"
Copy-Item -Recurse .\agents\*   "$cfg\agents\"
Copy-Item -Recurse .\commands\* "$cfg\commands\"
Copy-Item -Recurse .\rules\*    "$cfg\rules\"
```

macOS / Linux:

```bash
cfg="$HOME/.config/opencode"
mkdir -p "$cfg/skills" "$cfg/agents" "$cfg/commands" "$cfg/rules"
cp -r skills/*   "$cfg/skills/"
cp -r agents/*   "$cfg/agents/"
cp -r commands/* "$cfg/commands/"
cp -r rules/*    "$cfg/rules/"
```

## Installing a single skill

Copy the whole folder, not just `SKILL.md`: some skills break without their `references/` or `scripts/`.

```powershell
$cfg = "$env:USERPROFILE\.config\opencode"
Copy-Item -Recurse .\skills\frontend-design "$cfg\skills\"
```

```bash
cp -r skills/frontend-design ~/.config/opencode/skills/
```

Avoid the nested-folder mistake (`skills/frontend-design/frontend-design/`). The target should be `skills/<name>/SKILL.md`.

## Plugin install

`plugins/skill-creator/` is the source of the npm package `opencode-skill-creator`. Install it separately:

```bash
npx opencode-skill-creator install --global
```

That adds `"opencode-skill-creator"` to the `plugin` array in `~/.config/opencode/opencode.json`, leaving existing plugins untouched. The matching end-user skill is `skills/opencode-skill-creator/`.

## Config

`opencode.jsonc` is a sample config, not something the installers place for you. It sets a default agent, loads the rules glob, and registers the `gh_grep` MCP server:

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

Copy it only if you want those defaults; merge the keys into an existing config instead of overwriting one.

## Verify

1. Restart OpenCode.
2. Ask for a skill by name: *"Use the clean-code skill to refactor this module."*
3. Run `/code-review` or `/doc-compress` and confirm the command appears in the command list.
4. Select `web-developer` or `security-expert` and confirm the agent loads.

If a skill does not appear, check that `~/.config/opencode/skills/<name>/SKILL.md` exists and that its frontmatter has both `name` and `description`.

## Update

Pull the repo and re-run the installer: the merge copy overwrites changed files and leaves everything else:

```powershell
git pull; .\install.ps1 -All
```

```bash
git pull && ./install.sh --all
```

## Remove

```powershell
Remove-Item -Recurse "$env:USERPROFILE\.config\opencode\skills\frontend-design"
```

```bash
rm -rf ~/.config/opencode/skills/frontend-design
```

Remove agents, commands, and rules the same way. Nothing in this repo tracks what you installed, so removal is manual.

See [SKILL-REGISTRATION.md](SKILL-REGISTRATION.md) for a verification checklist.
