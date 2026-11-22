# Skill Registration Checklist

Use this after installing to confirm a skill is registered with OpenCode. Replaces an earlier ad-hoc verification log that referenced machine-specific paths.

## 1. Confirm the files landed

```powershell
# Windows
Get-ChildItem "$env:USERPROFILE\.config\opencode\skills\frontend-design" -Recurse | Select-Object FullName
```

```bash
# macOS / Linux
ls -la ~/.config/opencode/skills/frontend-design
```

Expected: `SKILL.md` at the top level, plus any bundled assets.

## 2. Check for the nested-folder mistake

The most common failure is a duplicated directory level:

```
skills/frontend-design/frontend-design/SKILL.md    # wrong
skills/frontend-design/SKILL.md                    # right
```

Fix it by moving the inner folder's contents up one level.

## 3. Check frontmatter

`SKILL.md` must start with a YAML block containing both `name` and `description`:

```yaml
---
name: frontend-design
description: "..."
---
```

## 4. Check name uniqueness

Two installed skills with the same `name` shadow each other. This repo has one such pair, `business-english-it-pro` (folders `business-english-it-pro` and `Business-English-IT-Pro-Skill`) — keep only one.

```powershell
Select-String -Path "$env:USERPROFILE\.config\opencode\skills\*\SKILL.md" -Pattern '^name:' | Group-Object Line | Where-Object Count -gt 1
```

```bash
grep -h '^name:' ~/.config/opencode/skills/*/SKILL.md | sort | uniq -d
```

## 5. Invoke it

Restart OpenCode, then ask for the skill by name:

> "Use the frontend-design skill to review this page."

A skill that never triggers usually has a vague `description` rather than a registration problem.

## 6. Confirm assets are present

Skills that need their support files:

| Skill | Needs |
|-------|-------|
| `deep-research` | `scripts/`, `requirements.txt` |
| `markitdown` | `scripts/`, `references/` |
| `ui-ux-pro-max` | `data/`, `scripts/` |
| `theme-factory` | `themes/` |
| `skill-creator` | `scripts/`, `references/`, `assets/`, `eval-viewer/` |
| `powershell-enterprise-admin` | `references/`, `scripts/`, `templates/`, `snippets/` |

Copying `SKILL.md` alone breaks these.
